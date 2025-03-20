rm(list=ls())

set.seed(1234)

data <- read.table("data.txt", header=T)
prior <- read.table("prior.txt", header=T)

source("hw2.r")

monteCarloSamples <- 500

posteriorSamples <- normalInvGamma(monteCarloSamples, data, prior)

# A 
# Extract necessary variables
n <- data$sampleSize          # Sample size
yBar <- data$sampleMean       # Sample mean
s <- sqrt(data$sampleVariance) # Sample standard deviation

# Compute the standard error of the mean
se <- s / sqrt(n)

# Compute the critical value for the 95% confidence interval (using the t-distribution)
t_value <- qt(0.975, df = n - 1) # Degrees of freedom = n - 1

# Calculate the lower and upper bounds of the confidence interval
ci_lower <- yBar - t_value * se
ci_upper <- yBar + t_value * se

# Print the 95% confidence interval
cat("Classical 95% Confidence Interval for μ:\n")
cat("(", round(ci_lower, 4), ", ", round(ci_upper, 4), ")\n", sep = "")


# B
# Calculate posterior credible intervals
# Function to calculate posterior credible interval
calculate_posterior_interval <- function(data, theta, n0, a = 2, b = 3, monteCarloSamples = 500) {
  # Define prior parameters as a list
  prior <- list(priorMean = theta, priorSampleSize = n0, shape = a, rate = b)
  
  # Generate posterior samples
  posteriorSamples <- normalInvGamma(monteCarloSamples, data, prior)
  
  # Compute 95% credible interval
  credibleInterval <- quantile(posteriorSamples$mu, probs = c(0.025, 0.975))
  
  return(list(mean = mean(posteriorSamples$mu), interval = credibleInterval))
}

display_posterior_results <- function(case, result) {
  cat(sprintf("Case %s: θ = %.3f, n0 = %.3f\n", case, result$theta, result$n0))
  cat(sprintf("    Mean of posterior: %.4f\n", result$posterior$mean))
  cat(sprintf("    95%% Credible Interval: [%.4f, %.4f]\n\n", 
              result$posterior$interval[1], result$posterior$interval[2]))
}

# Cases
cases <- list(
  list(case = "(a)", theta = 176, n0 = 0.5),
  list(case = "(b)", theta = 176, n0 = 9),
  list(case = "(c)", theta = 0, n0 = 9e-6)
)

# Compute and display results for each case
for (case in cases) {
  posterior_result <- calculate_posterior_interval(data, case$theta, case$n0)
  display_posterior_results(case$case, list(theta = case$theta, n0 = case$n0, posterior = posterior_result))
}


# C
# Hypothesis test 
# Generalized function for all cases with hypothesis testing
calculate_posterior_with_test <- function(data, theta, n0, a = 2, b = 3, monteCarloSamples = 500, test_value = 200) {
  prior <- list(priorMean = theta, priorSampleSize = n0, shape = a, rate = b)
  
  # Generate posterior samples
  posteriorSamples <- normalInvGamma(monteCarloSamples, data, prior)
  
  # Compute posterior mean and credible interval
  posteriorMean <- mean(posteriorSamples$mu)
  credibleInterval <- quantile(posteriorSamples$mu, probs = c(0.025, 0.975))
  
  # Test if test_value is within the credible interval
  test_result <- ifelse(test_value >= credibleInterval[1] && test_value <= credibleInterval[2],
                        "Fail to Reject", "Reject")
  
  list(mean = posteriorMean, interval = credibleInterval, test = test_result)
}

# List of cases
cases <- list(
  list(case = "Case (a)", theta = 176, n0 = 0.5),
  list(case = "Case (b)", theta = 176, n0 = 9),
  list(case = "Case (c)", theta = 0, n0 = 9e-6)
)

# Iterate over cases and print results
for (case in cases) {
  result <- calculate_posterior_with_test(data, theta = case$theta, n0 = case$n0)
  cat(case$case, ":\n")
  cat("  Mean of posterior:", result$mean, "\n")
  cat("  95% Credible Interval:", result$interval, "\n")
  cat("  Hypothesis Test (H0: μ = 200):", result$test, "\n\n")
}


## The credible interval does not include 𝜇= 200, leading to the rejection of the null hypothesis for a, b, and c. 







