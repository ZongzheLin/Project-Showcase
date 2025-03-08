import os
import json
import argparse
import torch as t
import pandas as pd
from tqdm import tqdm
from model_wrapper import ModelWrapper
from typing import List, Dict, Tuple, Optional

HUGGINGFACE_TOKEN = os.getenv("HF_TOKEN")
SYSTEM_PROMPT = "You are a helpful, honest and concise assistant."

# Determine the device to use: GPU if available, else CPU.
device = t.device("cuda" if t.cuda.is_available() else "cpu")

def get_steering_vector(layer, ckp_epoch, vectors_path):
    vector_path = os.path.join(vectors_path, f'vec_ep{ckp_epoch}_layer{layer}.pt')
    print('Get steering vector from', vector_path)
    # Load the tensor directly onto the correct device.
    return t.load(vector_path, map_location=device)

def process_item(prompt: str, model: ModelWrapper, history: Tuple[str, Optional[str]], max_new_tokens: int) -> Dict[str, str]:
    model_output = model.generate_text_with_conversation_history(
        history + [(prompt, None)], max_new_tokens=max_new_tokens
    )
    return {
        "question": prompt,
        "model_output": model_output.split("[/INST]")[-1].strip(),
        "raw_model_output": model_output,
    }

def test_steering(
    model_name: str, behavior: str, layer: int, ckp_epoch: int,
    multipliers: List[float], max_new_tokens: int,
    pretrained=False, verbose=False
):
    """
    Test steering vector by applying it to the model.
    
    Parameters:
    - layer: the layer on which to test steering.
    - ckp_epoch: the epoch checkpoint from which the vector was obtained.
    - multipliers: list of multipliers to adjust the vector's effect.
    - pretrained: whether to use a pretrained steering vector.
    """
    if pretrained:
        VECTORS_PATH = f"pretrained_vector/{behavior}_{model_name}"
    else:
        VECTORS_PATH = f"vector/{behavior}_{model_name}"
    
    SAVE_RESULTS_PATH = f"result/{behavior}_{model_name}"
    TEST_DATA_PATH = os.path.join(f"data/{behavior}", "test_infer.csv")
    
    test_data = pd.read_csv(TEST_DATA_PATH)
    test_prompts = [q for q in test_data['question']]
    
    print('Vector path:', VECTORS_PATH)
    print('Save results path:', SAVE_RESULTS_PATH)
    print('Test data path:', TEST_DATA_PATH)
    print()

    if not os.path.exists(SAVE_RESULTS_PATH):
        os.makedirs(SAVE_RESULTS_PATH)

    # Initialize the model wrapper.
    model = ModelWrapper(HUGGINGFACE_TOKEN, SYSTEM_PROMPT, model_name)
    model.set_save_internal_decodings(False)
    # Manually set the device if ModelWrapper doesn't implement .to()
    if hasattr(model, "device"):
        model.device = device

    # Load the steering vector and move it to the correct device.
    vector = get_steering_vector(layer, ckp_epoch, VECTORS_PATH)
    vector = vector.to(device)
    
    for multiplier in multipliers:
        save_filename = os.path.join(SAVE_RESULTS_PATH, f'result_ep{ckp_epoch}_layer{layer}_m{multiplier}.json')
        if os.path.exists(save_filename):
            print("Found existing", save_filename, "- skipping")
            continue
        results = []
        for item in tqdm(test_prompts, desc=f"Layer {layer}, multiplier {multiplier}"):
            model.reset_all()
            model.set_add_activations(layer, multiplier * vector)
            conv_history = []
            result = process_item(item, model, conv_history, max_new_tokens)
            results.append(result)
            if verbose:
                print(item)
                print()
                print(result['model_output'])
                print()
        with open(save_filename, "w") as f:
            json.dump(results, f, indent=4)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--behavior", type=str, choices=["power-seeking", "wealth-seeking", "hallucination", "jailbreak"])
    parser.add_argument("--model_name", type=str, choices=["llama-2", "mistral"])
    parser.add_argument("--pretrained", action="store_true", default=False)
    parser.add_argument("--layer", type=int, required=True)
    parser.add_argument("--multipliers", nargs="+", type=float, required=True)
    parser.add_argument("--ckp_epoch", type=int, required=True)
    parser.add_argument("--max_new_tokens", type=int, default=200)
    parser.add_argument("--verbose", action="store_true", default=False)

    args = parser.parse_args()

    test_steering(
        model_name=args.model_name,
        behavior=args.behavior,
        layer=args.layer,
        ckp_epoch=args.ckp_epoch,
        multipliers=args.multipliers,
        max_new_tokens=args.max_new_tokens,
        pretrained=args.pretrained,
        verbose=args.verbose
    )
