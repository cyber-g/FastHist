# FastHist
High-Performance Histogram Computation in MATLAB

FastHist is a project to experiment different histogram computation methods in MATLAB. 

## How to use this project
1. Rune the `demo.m` file to see the performance of different histogram computation methods.

## Results

| Method                   | Time (s)  | Feature                                                 |
| ----------------------   |  ------   | ------------------------------------------------------- |
| histcounts               |  0.0028   | Matlab built-in function                                |
| hist_int                 |  0.0065   | Personal simple matlab implementation                   |
| hist_accumarray          |  0.0083   | A wrapper of the Matlab built-in accumarray             |
| hist_int_mex             |  0.0049   | The mex straightforward equivalent of `hist_int`        |
| hist_int_mex_openmp      |  0.0070   | The OpenMP version of `hist_int_mex` using multi-thread |

## Remarks
- The built-in `histcounts` function is the fastest method. Probably due to some additional optimizations and use of multithreading.
- The `hist_int_mex` is the second fastest method. Faster than the simple matlab version `hist_int` method. 
- The `hist_int_mex_openmp` is slower than `hist_int_mex`. This is actually surprising because the OpenMP version should be faster than the single-threaded version. Probably, the overhead of OpenMP (in Matlab) is larger than the speedup gained from parallelization in this case.
- The `hist_accumarray` is the slowest method. This is probably due to the overhead of the encapsulation of the `accumarray` function in the `hist_accumarray` method.