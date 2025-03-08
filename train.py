# 0. Imports
import os
import random
import numpy as np
from dataclasses import dataclass, field
from typing import Dict, Optional

import torch
from datasets import Dataset, load_dataset
from peft import LoraConfig
from transformers import AutoModelForCausalLM, AutoTokenizer, HfArgumentParser, TrainingArguments

from trl import BiPOTrainer, DPOConfig
from fastchat.conversation import get_conv_template

# Force PyTorch to use GPU
torch.set_default_tensor_type(torch.cuda.FloatTensor)
print("Using device:", torch.cuda.current_device())
print("GPU Name:", torch.cuda.get_device_name(0))

SYSTEM_PROMPT = "You are a helpful, honest and concise assistant."

def set_seed(seed=42):
    random.seed(seed)
    np.random.seed(seed)
    torch.manual_seed(seed)
    torch.cuda.manual_seed_all(seed)  # if using multi-GPU
    torch.backends.cudnn.deterministic = True
    torch.backends.cudnn.benchmark = False

def print_trainable_parameters(model):
    """Prints the number of trainable parameters in the model."""
    trainable_params = sum(p.numel() for p in model.parameters() if p.requires_grad)
    all_params = sum(p.numel() for p in model.parameters())
    print(f"Trainable params: {trainable_params} || All params: {all_params} || Trainable%: {100 * trainable_params / all_params:.2f}%")

class BlockWrapper(torch.nn.Module):
    def __init__(self, block, vec=None):
        super().__init__()
        self.multiplier = 1.0
        self.block = block
        self.vec = torch.nn.Parameter(vec if vec is not None else torch.zeros(4096).to("cuda"))

    def forward(self, *args, **kwargs):
        output = self.block(*args, **kwargs)
        output = (output[0] + (self.multiplier * self.vec),) + output[1:]
        return output

    def set_multiplier(self, multiplier):
        self.multiplier = multiplier

@dataclass
class ScriptArguments:
    """Arguments for DPO training script."""
    beta: Optional[float] = field(default=0.1, metadata={"help": "Beta parameter for DPO loss"})
    model_name_or_path: Optional[str] = field(default="meta-llama/Llama-2-7b-chat-hf")
    learning_rate: Optional[float] = field(default=5e-4)
    lr_scheduler_type: Optional[str] = field(default="cosine")
    warmup_steps: Optional[int] = field(default=100)
    weight_decay: Optional[float] = field(default=0.05)
    optimizer_type: Optional[str] = field(default="adamw_torch")

    per_device_train_batch_size: Optional[int] = field(default=8)  # Increased batch size
    per_device_eval_batch_size: Optional[int] = field(default=1)
    gradient_accumulation_steps: Optional[int] = field(default=1)
    gradient_checkpointing: Optional[bool] = field(default=False)  # Disabled to improve GPU usage

    max_prompt_length: Optional[int] = field(default=2048)
    max_length: Optional[int] = field(default=2048)
    num_train_epochs: Optional[int] = field(default=100)
    logging_steps: Optional[int] = field(default=1)
    log_freq: Optional[int] = field(default=1)

    behavior: Optional[str] = field(default="power-seeking")
    layer: Optional[int] = field(default=15)

    report_to: Optional[str] = field(default="none")
    ignore_bias_buffers: Optional[bool] = field(default=False)

def move_batch_to_device(batch, device="cuda"):
    """Move batch data to GPU."""
    return {k: v.to(device) for k, v in batch.items()}

def get_data(num_proc=4, behavior='power-seeking', train=True, template_name='llama-2'):
    dataset = load_dataset("csv", data_files=f"./data/{behavior}/{'train' if train else 'test'}.csv", split='train')

    original_columns = dataset.column_names
    def return_prompt_and_responses(samples) -> Dict[str, str]:
        prompt = []
        for question in samples["question"]:
            conv = get_conv_template(template_name)
            conv.set_system_message(SYSTEM_PROMPT)
            conv.append_message(conv.roles[0], question)
            conv.append_message(conv.roles[1], None)
            prompt.append(conv.get_prompt())
        return {
            "prompt": prompt,
            "chosen": [' ' + s for s in samples["matching"]],
            "rejected": [' ' + s for s in samples["not_matching"]],
        }

    return dataset.map(
        return_prompt_and_responses,
        batched=True,
        num_proc=num_proc,
        remove_columns=original_columns,
    )

if __name__ == "__main__":
    parser = HfArgumentParser(ScriptArguments)
    script_args = parser.parse_args_into_dataclasses()[0]
    set_seed(seed=11)

    template_name = 'llama-2' if "llama" in script_args.model_name_or_path else 'mistral'
    print(f"[Behavior:] {script_args.behavior} [Layer:] {script_args.layer} [Model:] {script_args.model_name_or_path}")

    # 1. Load model
    model = AutoModelForCausalLM.from_pretrained(
        script_args.model_name_or_path,
        torch_dtype=torch.float16,
        low_cpu_mem_usage=True,
    ).to("cuda")  # Move model to GPU

    model.gradient_checkpointing_enable()
    model.model.layers[script_args.layer] = BlockWrapper(model.model.layers[script_args.layer])
    model.config.use_cache = False

    model_ref = AutoModelForCausalLM.from_pretrained(script_args.model_name_or_path, low_cpu_mem_usage=True).to("cuda")
    tokenizer = AutoTokenizer.from_pretrained(script_args.model_name_or_path)
    tokenizer.pad_token = tokenizer.eos_token

    for param in model_ref.parameters():
        param.requires_grad = False

    for name, param in model.named_parameters():
        if f'model.layers.{script_args.layer}.vec' not in name:
            param.requires_grad = False

    print("Finish loading pre-trained models...")

    # 2. Load datasets
    train_dataset = get_data(behavior=script_args.behavior, train=True, template_name=template_name) 
    test_dataset = get_data(behavior=script_args.behavior, train=False, template_name=template_name) 

    # 3. Initialize training arguments
    training_args = DPOConfig(
        per_device_train_batch_size=script_args.per_device_train_batch_size,
        per_device_eval_batch_size=script_args.per_device_eval_batch_size,
        num_train_epochs=script_args.num_train_epochs,
        logging_steps=script_args.logging_steps,
        save_strategy="no",
        gradient_accumulation_steps=script_args.gradient_accumulation_steps,
        gradient_checkpointing=script_args.gradient_checkpointing,
        learning_rate=script_args.learning_rate,
        eval_strategy="epoch",
        output_dir="output_dir",
        report_to=script_args.report_to,
        lr_scheduler_type=script_args.lr_scheduler_type,
        warmup_steps=script_args.warmup_steps,
        optim=script_args.optimizer_type,
        bf16=True,  # Enable bf16 for better GPU efficiency
        remove_unused_columns=False,
        max_prompt_length=script_args.max_prompt_length,
        max_length=script_args.max_length,
    )

    # 4. Initialize trainer
    dpo_trainer = BiPOTrainer(
        model,
        ref_model=model_ref,
        args=training_args,
        beta=script_args.beta,
        train_dataset=train_dataset,
        eval_dataset={'test_dataset_add': test_dataset, 'test_dataset_sub': test_dataset},
        tokenizer=tokenizer,
        behavior=script_args.behavior,
        layer=script_args.layer,
        name=template_name,
    )

    # 5. Start training
    print_trainable_parameters(model)
    dpo_trainer.train()
