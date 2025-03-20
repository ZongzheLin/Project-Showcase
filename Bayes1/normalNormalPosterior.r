
normalNormalPosterior <- function(monteCarloSamples, sampleMean, populationVariance, dataSampleSize, priorMean, priorSampleSize) {
	n = dataSampleSize
	n0 = priorSampleSize
	wt = n/(n0+n)
	posteriorMean = (1-wt)*priorMean + wt*sampleMean
        posteriorVariance = populationVariance/(n0+n)
	posteriorSD = sqrt(posteriorVariance)

	posteriorSamples = rnorm(monteCarloSamples, posteriorMean, posteriorSD)

	return(posteriorSamples)	
}

normalNormalPosteriorExact <- function(sampleMean, populationVariance, dataSampleSize, priorMean, priorSampleSize){
	n = dataSampleSize
	n0 = priorSampleSize
	wt = n/(n0+n)
	posteriorMean = (1-wt)*priorMean + wt*sampleMean
	posteriorVariance = populationVariance/(n0+n)
	posteriorSD = sqrt(posteriorVariance)
	posteriorQnt = qnorm(c(0.50, 0.025, 0.975), posteriorMean, posteriorSD)

	posteriorSummary <- list("posterior_mean" = posteriorMean, "posterior_standard_deviation" = posteriorSD, "posterior_quantiles" = posteriorQnt)
	return(posteriorSummary)
}

