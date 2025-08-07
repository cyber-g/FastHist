/*
 * File: hist_int_mex_openmp.c
 * Project: FastHist (https://github.com/cyber-g/FastHist)
 * Author: Germain PHAM
 * Affiliation: C2S, Télécom Paris, IP Paris
 * Date: 15th May 2025
 * 
 * Description:
 * This file provides a MATLAB MEX implementation of the `hist_int` function
 * with OpenMP support for parallel computation. It computes a histogram for
 * integer data within specified bins, normalizing the input data to fit within
 * the specified range and computing the histogram with the given number of bins.
 * 
 * OpenMP is used to parallelize the histogram computation for improved performance
 * on multi-core systems. 
 * 
 * License: GNU General Public License v3.0
 */

#include "mex.h"
#include <math.h>
#include <stdlib.h>
#include <omp.h>

/* MEX gateway function */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    /* Input/output validation */
    if (nrhs != 3) {
        mexErrMsgIdAndTxt("hist_int_mex:invalidNumInputs", "Three inputs required: input, extrema, num_bins.");
    }
    if (nlhs > 1) {
        mexErrMsgIdAndTxt("hist_int_mex:invalidNumOutputs", "Only one output is allowed.");
    }

    /* Check that the input is a column vector */
    if (mxGetN(prhs[0]) > 1) {
        mexErrMsgIdAndTxt("hist_int_mex:invalidInput", "Input must be a column vector with more than one row.");
    }

    /* Check that the input is a real-valued array */
    if (!mxIsDouble(prhs[0]) || mxIsComplex(prhs[0])) {
        mexErrMsgIdAndTxt("hist_int_mex:invalidInput", "Input must be a real-valued array.");
    }

    /* Check that extrema is a 2-element vector in ascending order */
    if (mxGetNumberOfElements(prhs[1]) != 2) {
        mexErrMsgIdAndTxt("hist_int_mex:invalidExtrema", "Extrema must be a 2-element vector.");
    }

    // declare variables (match https://fr.mathworks.com/help/matlab/matlab_external/upgrade-mex-files-to-use-interleaved-complex.html)
    #if MX_HAS_INTERLEAVED_COMPLEX
        mxDouble *input;
        mxDouble *extrema;
    #else
        double *input;
        double *extrema;
    #endif
    
    /* get arguments */
    #if MX_HAS_INTERLEAVED_COMPLEX
        input   = mxGetDoubles(prhs[0]);
        extrema = mxGetDoubles(prhs[1]);
    #else
        input   = mxGetPr(prhs[0]);
        extrema = mxGetPr(prhs[1]);
    #endif

    /* Check that the extrema are in ascending order */
    if (extrema[1] <= extrema[0]) {
        mexErrMsgIdAndTxt("hist_int_mex:invalidExtrema", "extrema[1] must be greater than extrema[0].");
    }

    int num_bins;
    mwSize num_elements;
    double *counts;
    double range;
    int total_count;

    /* Assign values */
    num_bins     = (int)mxGetScalar(prhs[2]);
    num_elements = mxGetNumberOfElements(prhs[0]);

    /* Allocate memory for the output array */
    plhs[0] = mxCreateDoubleMatrix(1, num_bins, mxREAL);
    counts  = mxGetPr(plhs[0]);

    /* Initialize counts to zero */
    for (int i = 0; i < num_bins; i++) {
        counts[i] = 0;
    }

    /* Compute the histogram */
    range = extrema[1] - extrema[0];

    int i;
    #pragma omp parallel
    {
        /* Use a private copy of counts for each thread */
        double *local_counts = (double *)malloc(num_bins * sizeof(double));
        for (i = 0; i < num_bins; i++) {
            local_counts[i] = 0;
        }

        #pragma omp for
        for (i = 0; i < num_elements; i++) {
            double normalized = (input[i] - extrema[0]) / (range * (1 + 1e-10));
            int bin_index = (int)floor(normalized * num_bins);

            /* Ensure bin_index is within bounds */
            if (bin_index >= 0 && bin_index < num_bins) {
                local_counts[bin_index]++;
            }
        }

        /* Combine local counts into global counts */
        #pragma omp critical
        {
            for (i = 0; i < num_bins; i++) {
                counts[i] += local_counts[i];
            }
        }

        free(local_counts);
    } // End of parallel region


    /* Normalize the counts */
    // Please note this normalization assumes that all the data points are within the range of extrema
    // If the data points are outside the range, they will not be counted, and the histogram will not be normalized correctly.
    for (int i = 0; i < num_bins; i++) {
        counts[i] /= num_elements;
    }
    
}

