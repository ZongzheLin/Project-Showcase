# bayesNonInformative.R

# This function performs Bayesian linear regression with a non-informative prior.
# It uses an 'lm' object and returns posterior samples of beta and sigma^2.

bayesNonInformative <- function(lmObject, NITER) {
  # Load mvtnorm for multivariate normal tools
  library(mvtnorm)
  
  # Extract the model data and determine sample size
  lmData <- model.frame(lmObject)
  n <- nrow(lmData)
  
  # Extract LS estimates for beta and the covariance matrix
  betaHat <- coefficients(lmObject)     # MLE of beta
  lmVcov  <- vcov(lmObject)            # hat(sigma^2)*(X^T X)^(-1)
  
  # Estimate of sigma^2
  sigmaSqHat <- (summary(lmObject)$sigma)^2
  
  # (X^T X)^(-1) = lmVcov / hat(sigma^2)
  tXXinv <- lmVcov / sigmaSqHat
  
  # Number of coefficients
  p <- length(betaHat)
  
  # Posterior of sigma^2 ~ Inverse-Gamma((n-p)/2, (n-p)*hat(sigma^2)/2)
  sigmaSqPost <- 1 / rgamma(
    n     = NITER,
    shape = (n - p)/2,
    rate  = ((n - p)*sigmaSqHat)/2
  )
  
  # Cholesky factor of (X^T X)^(-1)
  L <- chol(tXXinv)   # p x p
  
  # Generate standard normal samples in a single matrix
  Z <- matrix(rnorm(NITER * p), nrow = NITER, ncol = p)
  
  # Multiply Z by L => NITER x p
  ZL <- Z %*% L
  
  # Scale each row by sqrt(sigma^2)
  Zscaled <- sweep(ZL, 1, sqrt(sigmaSqPost), `*`)
  
  # Shift by betaHat to get posterior draws of beta
  betaPost <- sweep(Zscaled, 2, betaHat, `+`)
  
  # Combine beta samples and sigma^2 samples
  posteriorSamples <- data.frame(betaPost, sigmaSqPost)
  
  # Return the data frame of posterior samples
  return(posteriorSamples)
}
