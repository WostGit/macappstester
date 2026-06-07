# Realtime Graph Fidelity Rankings

Lower score is better. This run adds heavier render paths and memory churn. CPU error compares in-app `proc_taskinfo` sampling against external `ps`; memory gap compares app physical footprint against `ps` RSS, so it is diagnostic rather than exact Activity Monitor parity.

| Rank | Mode | Samples | CPU MAE | Memory gap vs ps RSS MB | Avg app CPU | CPU jitter | Score |
|---:|---|---:|---:|---:|---:|---:|---:|
| 1 | appkit | 12 | 0.071 | 16.443 | 0.024 | 0.052 | 0.155 |
| 2 | numeric | 12 | 0.228 | 16.246 | 0.028 | 0.059 | 0.31 |
| 3 | heavy-redraw | 16 | 97.568 | 16.283 | 2.401 | 0.02 | 97.697 |
| 4 | burst-redraw | 15 | 98.219 | 16.461 | 2.415 | 0.013 | 98.349 |
| 5 | memory-churn | 16 | 98.648 | 207.523 | 2.427 | 0.015 | 99.735 |
