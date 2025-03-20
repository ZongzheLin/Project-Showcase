# Clear the workspace
rm(list = ls())

# Load necessary libraries
library(rjags)
library(coda)

# Set MCMC parameters 
nSamp   <- 10000   # Number of posterior samples to collect
nChains <- 1       # Number of MCMC chains
nAdapt  <- 200     # Number of adaptation iterations
nBurn   <- 1000    # Number of burn-in iterations

# Set a seed for reproducibility
set.seed(1234)

# Read the dataset 
data <- read.table("stockton_real_estate.txt", header = TRUE)

# Remove the columns 'Lat' and 'Longi' (not needed for this analysis)
data <- data[, !(names(data) %in% c("Lat", "Longi"))]

# Get the number of observations
N <- nrow(data)

# Extract the outcome variable and predictors.
Y  <- data$Y
# Create design matrix X: first column is intercept, then X1 to X6
X <- cbind(1, data$X1, data$X2, data$X3, data$X4, data$X5, data$X6)
p <- ncol(X)  # Number of regression coefficients (intercept + 6 covariates)

# Set hyperparameters for the priors
n0 <- 1.0E-6    # You can adjust this value if needed
a0 <- 0.001
b0 <- 0.001

# Prepare the data list to be passed to JAGS
jagsData <- list(
  Y = Y,
  X = X,
  N = N,
  p = p,
  n0 = n0,
  a0 = a0,
  b0 = b0
)

# Define a function to generate initial values for the unknown parameters
inits <- function() {
  list(
    beta = rep(0, p),       # Initialize beta vector of length p with zeros
    tausq = 1,              # Initial value for precision
    yFit = rep(0, N)         # Initial values for fitted values (optional)
  )
}

# Compile the JAGS model from the model file and data
jagsModel <- jags.model(file = "modelJags.txt",
                        data = jagsData,
                        inits = inits,
                        n.chains = nChains,
                        n.adapt = nAdapt)

# Run the burn-in phase 
update(jagsModel, n.iter = nBurn)

# Specify the parameters to monitor during sampling
params <- c("beta", "tausq", "sigmasq", "yFit")

# Draw posterior samples using coda.samples
mOut <- coda.samples(model = jagsModel, variable.names = params, n.iter = nSamp)

# Print summary statistics 
print(summary(mOut))






# Get overall summary statistics from mOut
s <- summary(mOut)

# (4-i) Regression slopes: Extract posterior mean, SD, median and 95% CIs for beta[2] ... beta[p]
beta_rows <- grep("^beta\\[", rownames(s$statistics))
beta_summary <- cbind(s$statistics[beta_rows, ], s$quantiles[beta_rows, ])
slopes <- beta_summary[-1, ]  # Remove intercept (first row)
cat("Posterior summary for regression slopes (excluding intercept):\n")
print(slopes)


# (4-ii) Residual variance: Extract summary for 'sigmasq'
res_var <- c(s$statistics["sigmasq", ], s$quantiles["sigmasq", ])
cat("\nPosterior summary for residual variance (sigmasq):\n")
print(res_var)


# (4-iii) Model-fitted values: Extract summary for yFit (display first 10 only)
yfit_rows <- grep("^yFit\\[", rownames(s$statistics))
yfit_summary <- cbind(s$statistics[yfit_rows, ], s$quantiles[yfit_rows, ])
cat("\nPosterior summary for the first 10 model-fitted values (yFit):\n")
print(yfit_summary[1:10, ])


# (5) Identify significant covariates:
# A covariate (slope) is significant if its 95% credible interval (2.5% and 97.5% quantiles) does not include 0.
slopes_quant <- as.data.frame(s$quantiles[beta_rows, ])[-1, ]  # Remove intercept row
significant <- apply(slopes_quant, 1, function(q) {
  (q["2.5%"] > 0 & q["97.5%"] > 0) | (q["2.5%"] < 0 & q["97.5%"] < 0)
})
cat("\nSignificance of covariates (TRUE means 95% CI does not include 0):\n")
print(significant)

# (6) Check how many yFit 95% credible intervals include the observed Y values.
# I use the 2.5% and 97.5% quantiles of yFit.
yfit_lower <- s$quantiles[yfit_rows, "2.5%"]
yfit_upper <- s$quantiles[yfit_rows, "97.5%"]
coverage <- sum(Y >= yfit_lower & Y <= yfit_upper)
cat("\nOut of", length(Y), "observations, the 95% credible intervals for yFit include the observed Y in", coverage, "cases.\n")

