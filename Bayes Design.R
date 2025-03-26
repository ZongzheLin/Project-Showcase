# Clear the workspace (remove all objects)
rm(list = ls())

# Set seed for reproducibility so that random numbers are consistent on each run
set.seed(1234)

# Function to calculate the required sample size per group using a Bayesian simulation approach.
# The function simulates data from a control group (mean = 0) and a treatment group (mean = delta)
# and calculates the posterior probability that the treatment effect (difference in means) is > 0.
# It iterates, increasing the sample size until at least 95% of simulations yield a posterior probability
# exceeding the specified threshold (default 0.95).
calculate_sample_size <- function(delta, sigma = 4.5, threshold = 0.95, iter = 5000, prior_sd = 10) {
  
  # Start with a small sample size per group
  n <- 2
  
  # Continue increasing sample size until condition is met
  while (TRUE) {
    
    # Vector to store the posterior probability from each simulation iteration
    post_prob <- numeric(iter)
    
    # Run the simulation iter times
    for (i in 1:iter) {
      # Simulate data for the control group: normally distributed with mean 0 and standard deviation sigma
      control <- rnorm(n, 0, sigma)
      # Simulate data for the treatment group: normally distributed with mean delta and standard deviation sigma
      treatment <- rnorm(n, delta, sigma)
      
      # Calculate the observed difference in sample means (treatment - control)
      obs_diff <- mean(treatment) - mean(control)
      
      # Compute the variance of the sampling distribution of the difference in means
      sampling_var <- 2 * sigma^2 / n
      
      # Calculate the posterior variance assuming a normal likelihood and a normal prior
      # For the noninformative prior, prior variance is prior_sd^2.
      # The posterior variance is given by: 1 / (1/prior_sd^2 + 1/sampling_var)
      post_var <- 1 / (1/prior_sd^2 + 1/sampling_var)
      
      # Calculate the posterior mean.
      # Here, the likelihood's contribution is weighted by 1/sampling_var.
      # Since the noninformative prior is centered at 0, the posterior mean is:
      post_mean <- post_var * (obs_diff / sampling_var)
      
      # Compute the posterior probability that the treatment effect is positive.
      # pnorm() with lower.tail = FALSE gives P(effect > 0).
      post_prob[i] <- pnorm(0, post_mean, sqrt(post_var), lower.tail = FALSE)
    }
    
    # Check if at least 95% of simulations have a posterior probability > threshold (default 0.95)
    if (mean(post_prob > threshold) >= 0.95) break
    
    # Increase sample size per group and repeat the simulation
    n <- n + 1
  }
  
  # Return the minimum required sample size per group
  return(n)
}

# Known standard deviation of LDL measurements
sigma <- 4.5
# Clinically significant differences to detect
delta_values <- c(5, 10, 15, 20)

# Calculate the required sample size for each delta using the function defined above
sample_sizes <- sapply(delta_values, calculate_sample_size)
# Label the results for clarity
names(sample_sizes) <- paste0("Delta_", delta_values)

# Print the results
print("Required sample sizes per group (Bayesian, 95% posterior probability):")
print(sample_sizes)
