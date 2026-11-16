# `pipeline/`: shared preprocessing and qEEG features

`config.py` (paths and settings), `data.py` (loading, channel resolution, filter chain), `features.py`
(the 17 qEEG features), `stats_tools.py` and `selection.py`. LICA imports these modules through
`lica/lica_common.py`. `python config.py` checks the data paths.
