FAQ
======

Causal Inference
----------------
**Q: What is causal inference? How is this different than ML?**

Causal inference is about understand the true effect of a variable (or treatment), call it `$D$`, on an outcome, call it `$Y$`. How would `Y` change if we changed `D`? We want an unbiased estimate of `D`'s effect on `Y` including uncertainty measures of p-value or confidence intervals. This is what the statistical part of sciences (e.g. Econometrics and Biostats) often works towards. ML, on the other hand, is usually about coming up with a good predictor function of `Y` using many features `X` (that may include `D`). These are fundamentally different and therefore one should be careful when moving from one domain to the other or combining the two.
One important way that causal inference is the same is that there is no "ground-truth" that we can compare estimates against. For example, in ML it is common to iterate heavily on models and then to use a hold-out set of the data to prevent over-fitting. When looking for causal inference we can't do the same thing because we don't know what the right answer in the test set is. In causal inference therefore we are much more careful about how we do model iteration so as to prevent over-fitting. The general rule of thumb is that you should use the same data for selecting your model as you do to get estimates.

**Q: Why is causal inference so hard?**

When `D` is randomly assigned inference is straightforward and can be done using ordinary least squares (OLS) regression. When trying to draw conclusions from data where `D` wasn't randomly assigned this is more complicated. One has to control for factors that independently affects both `Y` and `D`. These are called confounders (call them `C`). Omitting these will cause our causal estimates to be wrong ("omitted variable bias"). Sometimes we know vaguely what `C` and if we have data on it we can try to control for it directly (what we will talk about here). If don't, then we have to look for slices of the data where there is "exogenous variation" so that looking at it in a particular way is like an experiment (instrumental variables, regression discontinuity).

When trying to directly control for confounder, we often aren't sure exactly what form it takes or how it interacts with other elements of the system. So we would like a flexible strategy for controlling for confounders. But OLS has bad statistical properties when there are lots of variables, this presents a tension. We deal with this using a method called DoubleML.

**Q: What is DoubleML?**

In DoubleML structure the overall causal inference question so as to split out the parts of causal inference that are pure prediction problems so that we can hand them over to ML. In our control-based approach this amounts to trying to estimate how the outcome is driven by confounders given a set of features, `f(X)`, and how `D` is driven by confounders, `g(X)`. We then remove the portions of `Y` and `D` that are driven by the confounders so that `Y_r=Y-f(X)` and `D_r=D-g(x)`, ie we are removing the "predictable part". The remaining "residuals" now act like mini experiments and we can regress `Y_r` on `D_r` and OLS will give us the effect and statistical significance.

**Q: What can go in the predictor features set (`X`)?**

The only thing you shouldn't add to `X` is something that is caused by `D` and can effect `Y`. These are called "bad controls" and they will also bias our results for `D` (they capture part of the overall affect of `D` on `Y`). Often this is easily accommodated by using lagged values of controls so that `D` at a particular time couldn't cause `X` from earlier.

**Q: Why don't I just use a rich ML model to model `Y` as a function of `D` and `X`? If I use a linear model (e.g. Lasso) I can just get the coefficient, and in a non-linear model and can approximate the derivative of the prediction function with respect to the feature `D`.**

ML models broadly, as they usually optimize for out-of-sample fit, don’t provide treatment estimates that we think are “accurate” (“unbiased’), no matter if the effect is identified from a coefficient or by taking the partial-derivative of a complex prediction function. A simple example is that many models involve some sort of regularization/penalization so as not to overfit. Typically this means that coefficients on features are shrunk to zero (or set exactly to 0 if the features isn’t selected). This means that the coefficients will be wrong and it’s really hard to figure out how much they’re wrong! The take-away is that one doesn’t want to optimize on fit when trying to get good parameter estimates. That’s why in DoubleML  the core treatments are separated from the control terms and only do ML fit-based penalization on the later.
ML models also don't provide p-values on coefficients. One can construct metrics that give a sense of coefficient stability (e.g. via bootstrapping), but that is inherently much different. A classic case is that features selected by a Lasso are not necessarily statistically significant in a (perfectly specific) linear regression. In DoubleML, that’s why we separate the prediction `f()` and `g()` from the effect estimation. Another way of seeing this is that related to the point above, if the estimates are biased and one doesn’t know by how much, one can’t really get p-values.

DoubleML also improves upon traditional controlling strategies by looking separately for how potential confounders could be driving sales and treatment variables (we residualize both). This gives us two chances of catching confounders and is superior when there are confounders that are highly related to treatment. The intuition is that omitted variable bias is proportional to the product of the omitted variable’s relation to treatment and sales and so therefore we want to be able to control for factors that are only moderately related to sales but strongly related to treatment and these are more likely to be missed if we just control for the relation to sales. An example of this type of situation would be if the end of the month strongly caused a retailer to cut their prices (e.g. trying to meet quotas) but also moderately affected consumer behavior (e.g. they have monthly budgets they are trying to stretch).

Model Building
---------------
**Q: General advice on building linear models**

Look at the PennState Stat501 - Regression Methods free online material. See for example:
* [4.4 - Identifying Specific Problems Using Residual Plots](https://onlinecourses.science.psu.edu/stat501/node/279) (Note: we already deal with non-constant error variance and we don't care as much about non-normal errors) and the multiple regressor version [7.4 - Assessing the Model Assumptions](https://onlinecourses.science.psu.edu/stat501/node/317) (Note: we care most about the **L**inear and **I**ndependence assumptions)
* [11.7 - A Strategy for Dealing with Problematic Data Points](https://onlinecourses.science.psu.edu/stat501/node/343) for how to deal with influential points: outliers (unusual y for an x) and high-leverage points (unusual x). 
* [10.1 - What if the Regression Equation Contains "Wrong" Predictors?](https://onlinecourses.science.psu.edu/stat501/node/328) What happens if you omit a necessary regressor? The coefficients on variables correlated with the omitted variable will be biased.
* [12 - Multicollinearity & Other Regression Pitfalls](https://onlinecourses.science.psu.edu/stat501/node/343) If your parameter changes a lot (even switch sign) when adding different controls, multicollinearity is the usual suspect. Basically, if your variables are positively correlated, they will compete for the same effect so the coefficients will be negatively correlated, which can lead to a wrong sign on one of the coefficients. We use a ridge in the last stage that helps correct the signs to some degree. 

Also, our linear model at the end is a Statsmodel linear model so have a look at their specific [diagnostics](http://www.statsmodels.org/dev/stats.html#module-statsmodels.stats.stattools) 

**Q: Why is this coefficient different (e.g. wrong sign) than I expected?**

First off, if a coefficient is insignificant, then you should worry too much. An insignificant coefficient does not contradict either hypothesis that the true effect is positive or negative.

If a coefficient is significant and the "wrong" sign then several things could be going on. See the above links for more diagnosis.


Package usage
---------------
**Q: What parts use randomization?**

The main source of randomness is the shuffling used in the data-splitting for separately fitting the baseline models. You can eliminate the randomness by providing your own splitter to [DynamicDML](pricingengine/pricingengine.estimation.html#pricingengine.estimation.dynamic_dml.DynamicDML). See `msecore.randomex.set_random_seeds()` to set a random seed. Some of the models use cross validation, but none currently randomize; `RidgeCV` uses the non-random leave-one-out method and `LassoCV` uses a non-random K-fold split. The models that explicitly randomize (`RandomForest` and `BoostedTrees`) accept a `random_state` argument. The current base optimizations (`sklearn`, `statsmodels`) do not appear to use randomization in their solvings.

**Q: How can I use the package in AzureML Studio/Workbench?**

Azure ML Studio uses Python 2.7 which is incompatible with our package. 

Azure ML Workbench, however, works fine as it uses Python 3.5. The only package you will likely need to install in addition to the base environment is `statsmodels==0.8.0`.

Internal Operation
------------------
**Q: What scaling or normalization is used in estimation.**

Normalization happens in two places. First, at both the baseline and causal stage, `VarBuilder`s take their core variable and normalize them to have mean=0 and var=1 (if they are interacted with other variables those are brought without modification). Second, at the causal-stage if a core-variable is marked as "unpenalized" then it is scaled so that it is not significantly affected by penalization. Low-level models will see normalized features and therefore their "raw" coefficients/standard errors are transformed by `DynamicDML` for use by the user.