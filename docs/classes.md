Class Hierarchy
======

Models
------

Base Models:
- `Model`: These are standard models that just train on data and produce predictions
  - Examples: `BoostedTrees`, `DebiasedLasso`, `LassoCV`, `NeuralNet`
- `LinearModel` - (Inherits `Model`) Models that also provide coefficients on the features. Not a perfect name.
- `CausalModel` - (Inherits `LinearModel`) Models that also provide standard errors and a covariance matrix of the coefficients.
  - Examples: `OLS`, `RidgeCV`

SampleSplit/Fold-aware model. These are used directly by the estimation models which requir requires cross-fitting
- `SampleSplitModel`: Analogous to `Model`, but takes folds over the data for fit and predict. 
  - Examples: `CrossFitContainer` (can wrap a basic `Model`), and ensemble models such as `StackedSS` ("Stacked Generalization", takes other `SampleSplitModel`s) and `BucketSS` ("Bucket of Models", takes other `SampleSplitModel`s)


Estimation Models:
- `DoubleMLLikeModel`: Models that have a baseline stage where treatment and outcome are predicted (using a `SampleSplitModel`) and then a causal stage where residual outcome is regressed (using a `CausalModel`). They take `VarBuilder` objects that dynamically create variables rather being passed explicit features. They also take a data splitter which is used to split the data in the baseline.
  - Examples: `DoubleML`, `DynamicDML`

Variable Generation
-------------------
The user needs to be able to specify how features are generated in the baseline stages and how to construct treatments in the causal model. At it's core this is done by providing lists of VarBuilders. Interally these lists are managed by `FeatureGenerator`s and `TreatmentGenerator`s.

`VarBuilder`: Takes data (including residualized variables in the treatment stage) and produce output (either features or treatments). For the DynamicDML case they also can make lead-specific variables. At the baseline stage this lead-specific building is necessary to distinguish between variables that are known when they occur (most variables) and those that are pre-determined (e.g. holiday schedules). At the causal stage they can construct variables from multiple different lead-specific residualization models to generate time-related effects like "pull-forward" effects.
- Examples: `OwnVar` (for a simple coefficient), `PToPVar` (e.g. cross-product price effects)

Featurizer methods: These take a schema and produce lists of `VarBuilder`s. 
- Examples: `default_dynamic_featurizer`, `default_panel_featurizer`

Other
--------
`Schema`: Stores the `DataType` of each column (e.g. is an integer really a category variable to be 1-hot encoded) as well as `ColType` (Outcome,  Treatment, (normal control), or Predetermined (a control that is known in advance)).

`EstimationDataset`: Stores data, builds a multiindex, and stores the fold information when it's been fit using one of the Estimation Models

`Predictions`: Computers prediciton statistics from the Estimation Models

`DDMLMarginalEffects`: Helpful utility for complicated treatments
