normalInvGamma <- function(monteCarloSamples, data, prior) {
  n = data$sampleSize
  yBar = data$sampleMean
  sSq = data$sampleVariance
  
  theta = prior$priorMean
  n0 = prior$priorSampleSize
  
  a = prior$shape
  b = prior$rate
  
  aStar = a + n / 2
  bStar = b + (1 / 2) * ((n - 1) * sSq + n0 * n / (n0 + n) * (yBar - theta)^2)
  
  sigmaSqPosterior = 1 / rgamma(monteCarloSamples, aStar, bStar)
  
  wt = n0 / (n0 + n)
  muPosteriorMean = wt * theta + (1 - wt) * yBar
  muPosteriorVariance = sigmaSqPosterior / (n0 + n)
  muPosteriorSD = sqrt(muPosteriorVariance)
  
  muPosterior = rnorm(monteCarloSamples, muPosteriorMean, muPosteriorSD)
  
  posteriorSamples = data.frame(mu = muPosterior, sigmaSq = sigmaSqPosterior)
  
  return(posteriorSamples)
}
