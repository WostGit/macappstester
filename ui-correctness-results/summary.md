# macOS UI Correctness Results

Tests: accessibility tree button checks, real button clicks, CPU rise, memory rise, sample header/count, screenshots. Negative controls should fail.

| Mode | Passed expectation | Score | Buttons | CPU before/after | Memory before/after |
|---|---:|---:|---|---:|---:|
| fake-static | False | 6 | Start CPU, Stop CPU, +128 MB, missing value, missing value, missing value | 0.0 -> 0.0 | 136.7 -> 296.4 |
| non-clickable | True | 3 | missing value, missing value, missing value | 0.0 -> 0.0 | 136.3 -> 136.4 |
| real-graph | True | 6 | Start CPU, Stop CPU, +128 MB, missing value, missing value, missing value | 0.0 -> 0.0 | 135.8 -> 295.8 |
