# Homework 1 Script

# Clear workspace and set seed
rm(list = ls())
set.seed(1234)

# Load required libraries (optional, if needed later for JAGS)
# library(rjags)
# library(coda)

# Load Data
data <- read.table("data.txt", header = TRUE)
prior1 <- read.table("prior1.txt", header = TRUE)
prior2 <- read.table("prior2.txt", header = TRUE)
prior3 <- read.table("prior3.txt", header = TRUE)

# Load the provided functions from `normalNormalPosterior.r`
source("normalNormalPosterior.r")

# Extract data variables
n <- data$sampleSize         # Sample size
ybar <- data$sampleMean      # Sample mean
sigma <- data$sigma          # Population standard deviation
sigmaSq <- sigma^2           # Population variance

# Function to compute classical confidence interval
compute_classical_ci <- function(ybar, sigma, n) {
  z <- qnorm(0.975)  # Z-critical value for 95% CI
  error <- z * (sigma / sqrt(n))
  lower_bound <- ybar - error
  upper_bound <- ybar + error
  return(c(lower_bound, upper_bound))
}

# Compute classical confidence interval
classical_ci <- compute_classical_ci(ybar, sigma, n)
cat("Classical 95% Confidence Interval:", classical_ci, "\n")

# Function to compute Bayesian posterior credible intervals
compute_bayesian_ci <- function(prior, ybar, sigmaSq, n) {
  theta <- prior$theta
  tau <- prior$tau
  tauSq <- tau^2
  n0 <- sigmaSq / tauSq
  
  # Monte Carlo sampling for posterior
  monteCarloSamples <- 1000
  posteriorSamples <- normalNormalPosterior(monteCarloSamples, ybar, sigmaSq, n, theta, n0)
  
  # Exact posterior summary
  posteriorSummary <- normalNormalPosteriorExact(ybar, sigmaSq, n, theta, n0)
  
  # Extract 95% credible interval
  ci_samples <- quantile(posteriorSamples, c(0.025, 0.975))
  ci_exact <- posteriorSummary$posterior_quantiles[c(1, 3)]  # 2.5% and 97.5% quantiles
  
  return(list(samples_ci = ci_samples, exact_ci = ci_exact))
}

# Compute Bayesian credible intervals for each prior
bayesian_ci_prior1 <- compute_bayesian_ci(prior1, ybar, sigmaSq, n)
bayesian_ci_prior2 <- compute_bayesian_ci(prior2, ybar, sigmaSq, n)
bayesian_ci_prior3 <- compute_bayesian_ci(prior3, ybar, sigmaSq, n)

# Display results for each prior
cat("Bayesian 95% Credible Interval (Prior 1 - theta = 176, tau = 8):\n")
print(bayesian_ci_prior1)

cat("Bayesian 95% Credible Interval (Prior 2 - theta = 176, tau = 1000):\n")
print(bayesian_ci_prior2)

cat("Bayesian 95% Credible Interval (Prior 3 - theta = 0, tau = 1000):\n")
print(bayesian_ci_prior3)

# Compare results to classical CI
cat("\nComparison of Classical CI and Bayesian Credible Intervals:\n")
cat("Classical 95% CI:", classical_ci, "\n")
cat("Bayesian Credible Interval (Prior 1):", bayesian_ci_prior1$exact_ci, "\n")
cat("Bayesian Credible Interval (Prior 2):", bayesian_ci_prior2$exact_ci, "\n")
cat("Bayesian Credible Interval (Prior 3):", bayesian_ci_prior3$exact_ci, "\n")

# Identify which Bayesian interval is closest to the classical CI
# This can be done manually by inspecting the output

