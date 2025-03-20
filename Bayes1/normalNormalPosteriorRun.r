rm(list = ls())

set.seed(1234)

#I put all the prior and data file at the same location as the source file, and set the source file as the working directory. 
#If grader had any error locating the file while running, go to session, set working directory, to source file location. And add the txt files in the same location. 
data = read.table("data.txt", header=T)
prior = read.table("prior3.txt", header=T)

source("normalNormalPosterior.r")

monteCarloSampleSize = 1000

n = data$sampleSize
yBar = data$sampleMean
sigma = data$sigma
sigmaSq = sigma^2

theta = prior$theta
tau = prior$tau
tauSq = tau^2

n0 = sigmaSq/tauSq

posteriorSamples = normalNormalPosterior(monteCarloSampleSize, yBar, sigmaSq, n, theta, n0)

posteriorSummaryExact = normalNormalPosteriorExact(yBar, sigmaSq, n, theta, n0)

# Compute the 95% classical confidence interval
z = qnorm(0.975)  # Critical value for 95% confidence level
lower_bound_classical = yBar - z * (sigma / sqrt(n))
upper_bound_classical = yBar + z * (sigma / sqrt(n))
classicalCI = c(lower_bound_classical, upper_bound_classical)
cat("Classical 95% Confidence Interval:", classicalCI, "\n")

# Display Bayesian results for prior3.txt
bayesianCI_MC = quantile(posteriorSamples, c(0.025, 0.975))  # Interval based on Monte Carlo samples
bayesianCI_exact = posteriorSummaryExact$posterior_quantiles[c(1, 3)]  # Interval based on exact calculations
cat("Bayesian 95% Credible Interval (Monte Carlo):", bayesianCI_MC, "\n")
cat("Bayesian 95% Credible Interval (Exact):", bayesianCI_exact, "\n")

# Loop through all prior files to compute results for each case
prior_files = c("prior1.txt", "prior2.txt", "prior3.txt")
for (prior_file in prior_files) {
  # Load the prior parameters from the file
  prior = read.table(prior_file, header = TRUE)
  
  theta = prior$theta
  tau = prior$tau
  tauSq = tau^2
  n0 = sigmaSq / tauSq
  
  # Compute posterior samples and exact summary
  posteriorSamples = normalNormalPosterior(monteCarloSampleSize, yBar, sigmaSq, n, theta, n0)
  posteriorSummaryExact = normalNormalPosteriorExact(yBar, sigmaSq, n, theta, n0)
  
  # Calculate Bayesian 95% credible intervals
  bayesianCI_MC = quantile(posteriorSamples, c(0.025, 0.975))  # Interval from Monte Carlo
  bayesianCI_exact = posteriorSummaryExact$posterior_quantiles[c(1, 3)]  # Exact interval
  
  # Print results for this prior
  cat("\nResults for Prior from", prior_file, ":\n")
  cat("95% Credible Interval (Monte Carlo):", bayesianCI_MC, "\n")
  cat("95% Credible Interval (Exact):", bayesianCI_exact, "\n")
}

# Display a summary comparison of the classical CI with Bayesian credible intervals
cat("\nComparison of Classical CI and Bayesian Credible Intervals:\n")
cat("Classical 95% CI:", classicalCI, "\n")