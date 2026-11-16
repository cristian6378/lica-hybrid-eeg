# LICA: leakage- and interaction-controlled attribution for hybrid EEG models

[![CI](https://github.com/OWNER/lica-hybrid-eeg/actions/workflows/ci.yml/badge.svg)](https://github.com/OWNER/lica-hybrid-eeg/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

This repository holds the code, the published results and the manuscript sources of the article

> **Stable, Plausible and Wrong: How Metadata Leakage Misleads Attribution in Hybrid EEG Models, and How
> to Control It.** S. Valchev, H. Dela Cruz, C. Rodriguez Rivero, P. Rajaram, J. Pucheta, G. Rajan.
> *Neuroinformatics* (2026).

Hybrid models that combine quantitative EEG (qEEG) features with a deep branch can learn shortcuts
through the recording device, age or patient identity, and their feature attributions then describe the
shortcut, not the physiology. LICA is a reproducible evaluation and control framework that

1. **audits** how well each feature family and the deep embedding predict the metadata and patient identity;
2. **removes** that information from the qEEG features (outcome-adjusted confound regression, fitted on the
   training fold) and from an EEGNet-8,2 branch (gradient-reversal adversary);
3. **admits** cross-family interactions only when inner validation supports them;
4. **attributes** with exact Shapley values over seven blocks (six qEEG families and the deep embedding),
   together with a metadata-adjusted permutation diagnostic.

| Study | Data | What it shows |
|---|---|---|
| **1** | Counterfactual EEG simulator with a device shortcut, age, a sex negative control and an a-XOR-b interaction; development, independent, reversed and decorrelated cohorts; 10 replicates | Whether attributions recover the generative and transportable importance, with and without leakage control |
| **2** | 47 acute-stroke patients, 1880 trials, 29 channels (Liu et al., 2024); outcome mRS ≥ 3 | Leakage audit, record-wise versus patient-wise validation, attribution stability |
| **Revision** | Both studies, plus new simulations | Paired effects, factorial shifts, simpler baselines, a benchmark of the diagnostic, an interaction-free control, a re-audit of Study 2 and a clinical comparator |

## Repository layout

```
lica/          LICA implementation, simulator, analysis scripts, tests and run scripts
pipeline/      shared filter chain and the 17 qEEG feature definitions (config.py, data.py, features.py, ...)
tests/         generator of a simulated stand-in for the patient dataset (used by the smoke test)
results/       the outputs behind every table and figure of the article and of Online Resources 1-2
  study1/        Study 1, 10 replicates
  study2/        Study 2, 47 patients
  revision/      analyses added in review: R1_*.csv (re-analysis of stored results) and
                 main/, benchmark/, interactions/, analysis/ (new simulations, S4_*.csv)
paper/         manuscript (LaTeX, Springer Nature sn-jnl), figures, Online Resource 1 (ESM_1) and 2 (ESM_2)
tools/         import_local_code.ps1 (used once, to add the code to this repository)
```

## Installation

```bash
conda env create -f environment.yml
conda activate lica
# or: python -m venv .venv && pip install --extra-index-url https://download.pytorch.org/whl/cpu -r requirements.txt
```

Everything runs on a CPU; a GPU only speeds up the EEGNet branch.

## Data

* **Study 1** needs no data: the seeded simulator in `lica/simulate.py` regenerates every replicate exactly.
* **Study 2** uses the acute-stroke EEG dataset of Liu et al. (2024), figshare,
  <https://doi.org/10.6084/m9.figshare.21679035>. Unpack it into `data/` (so that
  `data/sourcedata/sub-XX/*.mat` and `data/participants.tsv` exist) or point `STROKE_EEG_ROOT` to it;
  `python pipeline/config.py` checks the paths. Subjects 5, 15 and 49 are excluded as duplicate
  recordings, leaving 47 patients.

## Reproducing the article

From the `lica` folder (Windows: `.bat`; Linux/macOS: `.sh` where available):

```bash
run_lica.bat check        # quick check of every step, 10-20 min
run_lica.bat              # Studies 1 and 2 (about 12-16 h on a laptop CPU; restarts resume)
run_revision.bat check    # quick check of the revision analyses
run_revision.bat          # revision analyses (about 10-14 h)
```

New outputs go to `results_lica/` and intermediate files to `work_lica/` (override with `LICA_RESULTS` and
`LICA_WORK`); both are ignored by git. The published outputs are in `results/` with the same file names.

| Script | Produces |
|---|---|
| `S1_synthetic.py`, `S1_analyze.py` | Study 1: models, shift robustness, counterfactual sensitivity, attributions, interactions, diagnostic |
| `S2_prepare_real.py`, `S2_real.py`, `S2_analyze.py` | Study 2: inputs and metadata, patient-grouped CV, audit, record-wise CV, stability |
| `S3_supplementary.py` | Online Resources 1 and 2 |
| `R1_reanalysis.py` | Revision: paired effects with CIs, signed diagnostic, generative reference, exact-pair interactions (Study 1); re-audit with a permutation null, NIHSS comparator, patient-level fitting and within-repeat stability (Study 2) |
| `S4_revision.py`, `S4_analyze.py` | Revision: factorial shifts, simpler baselines, benchmark of the diagnostic, interaction-free control, computation time |

## Tests

```bash
pytest -q                                          # unit tests
SMOKE=1 pytest -q lica/tests/test_smoke_lica.py    # Studies 1 and 2 end to end on simulated data
```

The unit tests cover the exactness and efficiency of the block Shapley values, detection of a planted
interaction, the diagnostic on a planted confounder, the simulator's counterfactual twins and the
gradient reversal. GitHub Actions runs linting, the unit tests on Python 3.10-3.12 and the smoke test on
every push.

## Manuscript

`paper/LICA_Neuroinformatics.tex` compiles with `pdflatex`, `bibtex` and the bundled Springer Nature
class (`sn-jnl.cls`, APA style). Online Resource 1 (`ESM_1.pdf`, source `ESM_1.tex` with `figs/`) and
Online Resource 2 (`ESM_2.xlsx`) are the supplementary files of the article.

## Citation

See [`CITATION.cff`](CITATION.cff). If you use the patient data, also cite Liu et al. (2024).

## License

MIT, see [LICENSE](LICENSE).
