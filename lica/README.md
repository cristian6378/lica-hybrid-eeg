# `lica/`: implementation, simulator and analysis scripts

| Step | Module | What it does |
|---|---|---|
| Leakage audit | `lica.audit` | How well each feature family and the deep embedding predict the metadata (device, age, sex, time since stroke, affected side) and patient identity |
| Leakage control, qEEG | `lica.Residualizer` | Outcome-adjusted confound regression, fitted on the training fold only |
| Leakage control, deep branch | `deep_branch.HybridEEGNet` | EEGNet-8,2 with an 8-d bottleneck and a gradient-reversal adversary per metadata target; cross-fitted training logits |
| Interaction control | `lica.fit_head` | Gradient boosting in which each block interacts only with itself; a cross-family pair is admitted only if it lowers the inner-CV log-loss by more than one standard error (candidates ranked by Friedman's H) |
| Attribution | `lica.coalition_table`, `shapley_from_table`, `h_statistic`, `deletion_curve` | Exact interventional Shapley values over the seven blocks; H and deletion curves from the same coalition table |
| Diagnostic | `lica.permutation_subject`, `leakage_index` | Subject-block permutation importance, marginal and metadata-adjusted; the metadata-adjusted permutation diagnostic |
| Baselines | `lica.permutation_trial`, `lica.shap_features` | Trial-level permutation importance and feature-level SHAP summed per family |

`simulate.py` is the counterfactual EEG simulator of Study 1, `lica_common.py` holds the shared settings
(it finds the pipeline modules in `../pipeline`), and `tests/` holds the unit tests and the end-to-end
smoke test. See the README at the repository root for how to run the studies.
