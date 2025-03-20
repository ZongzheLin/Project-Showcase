This file provides the answers to Homework 1. 
Author: [Zongzhe Lin]
Date: [01/16/2015]


Q1. Classical 95% Confidence Interval
Result:
    Classical 95% Confidence Interval: [174.1406, 177.8594]

---

Q2. Bayesian 95% Posterior Credible Intervals
Results:
(a) Prior: θ = 176, τ = 8
    - Monte Carlo CI: [174.1411, 177.7339]
    - Exact CI:       [176, 177.8464]

(b) Prior: θ = 176, τ = 1000
    - Monte Carlo CI: [174.1985, 177.9199]
    - Exact CI:       [176, 177.8594]

(c) Prior: θ = 0, τ = 1000
    - Monte Carlo CI: [174.1546, 177.8567]
    - Exact CI:       [175.9998, 177.8592]

---

Q3. Comparison of Classical and Bayesian Methods
The classical confidence interval ([174.1406, 177.8594]) is most similar to the Bayesian credible interval under **Prior (b)** with θ = 176 and τ = 1000. This prior represents a weakly informative prior centered on the sample mean, allowing the data to dominate the posterior.

Conclusion:
    The results show that a weakly informative prior leads to Bayesian credible intervals that closely align with classical confidence intervals.


