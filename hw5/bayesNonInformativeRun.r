# bayesNonInformativeRun.R

# Example usage of the bayesNonInformative function

# 1. Source the function file
source("bayesNonInformative.R")

# 2. Read your data (CSV file). Adjust the file path as needed.
#    Replace the column names in the lm formula with your actual names.
dataFile <- "rate_lung_cancer_with_smoking.csv"
data <- read.csv(dataFile, header = TRUE)

# Check the first few rows to confirm column names
head(data)

# 3. Fit a standard linear model
#    Suppose 'Adjus' is the lung cancer rate, and 'Smoking_Rate' is the predictor
my_lm <- lm(Adjus ~ Smoking_Rate, data = data)

# 4. Set the number of iterations
NITER <- 5000

# 5. Call the bayesNonInformative function
posteriorSamples <- bayesNonInformative(my_lm, NITER)

# 6. Print a few rows of the posterior samples
head(posteriorSamples)

# 7. Quick summary of the posterior draws for sigma^2
cat("\nPosterior quantiles for sigma^2:\n")
print(quantile(posteriorSamples$sigmaSqPost, probs = c(0.025, 0.5, 0.975)))

# 8. Quick summary of posterior draws for the smoking coefficient
cat("\nPosterior quantiles for the smoking coefficient:\n")
betaName <- "Smoking_Rate"  # adjust if your predictor name is different
print(quantile(posteriorSamples[[betaName]], probs = c(0.025, 0.5, 0.975)))

# 9. You could also plot histograms of the posterior distributions if desired:
# hist(posteriorSamples$sigmaSqPost, main="Posterior of sigma^2")
# hist(posteriorSamples[[betaName]], main="Posterior of Smoking_Rate")
