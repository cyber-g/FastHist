% DEMO - Script to demonstrate histogram computation using various methods
% 
% This script performs histogram computation on a normalized signal using
% different methods (histcounts, hist_int, hist_accumarray (which actually uses
% Matlab's accumarray), hist_int_mex, hist_int_mex_openmp) and compares their
% results and performance.
%
% Other m-files required:   hist_int.m, hist_accumarray.m, hist_int_mex.c,
%                           hist_int_mex_openmp.c
% MAT-files required: none
%
% See also: HISTCOUNTS, ACCUMARRAY
% 
% Thanks:
%    Denis Gilbert (2025). M-file Header Template
%    (https://www.mathworks.com/matlabcentral/fileexchange/4908-m-file-header-template),
%    MATLAB Central File Exchange. Accessed on April 26, 2025. 
% 
% Author: Germain PHAM
% C2S, Télécom ParisTech, IP Paris
% email: dpham@telecom-paris.fr
% May 2025; Last revision: 

%------------- BEGIN CODE --------------

% Equality check
check_equal_flag = false; % Set to true to check equality of the results

signal_option = 1;
switch signal_option
    case 1
        datafile = 'Tx_20MHz_245.76Msps_PeakScaling3.0dBFS_ETM1.1_PAR7.5dB_Offset0MHz.txt';
    case 2
        datafile = 'Tx_20MHz_245.76Msps_PeakScaling3.0dBFS_ETM1.1_PAR7.5dB_Offset0MHz_4Carrier.txt';
    otherwise
        error('Invalid signal option. Choose 1 or 2.');  
end

filename = fullfile('signal', datafile);
if ~exist(filename, 'file')
    if ~exist('signal', 'dir')
        % Create the directory if it doesn't exist
        mkdir('signal');
    end
    % Get the file from "https://github.com/analogdevicesinc/iio-oscilloscope/raw/refs/heads/main/waveforms/"
    unix(['cd signal && wget -c https://github.com/analogdevicesinc/iio-oscilloscope/raw/refs/heads/main/waveforms/' datafile]);
end

% Check if the file hist_int_mex.mexa64 exists
if ~exist('hist_int_mex.mexa64', 'file')
    % Compile the MEX file
    mex hist_int_mex.c
    unix('mex CFLAGS="$CFLAGS -fopenmp" LDFLAGS="$LDFLAGS -fopenmp" hist_int_mex_openmp.c')
end

% Import the file
data = readmatrix(filename, "NumHeaderLines", 1);

% Form the signal
signal = complex(data(:, 1), data(:, 2));
signal = signal/max(abs(signal)); % Normalize the signal

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Experiment : compute the histogram 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Use the histcounts function
num_bins          = 256; % Number of bins
edges             = linspace(0,1, num_bins+1); % Bin edges
histcounts_counts = histcounts(abs(signal), edges,"Normalization", "probability");
disp('histcounts:');
timeit(@() histcounts(abs(signal), edges,"Normalization", "probability")) % Measure the time taken


% Use the hist_int function
extrema = [0, 1]; % Extrema
hist_int_counts = hist_int(abs(signal), extrema, num_bins);
disp('hist_int:');
timeit(@() hist_int(abs(signal), extrema, num_bins)) % Measure the time taken

% use the hist_accumarray function
hist_accumarray_counts = hist_accumarray(abs(signal), extrema, num_bins);
disp('hist_accumarray:');
timeit(@() hist_accumarray(abs(signal), extrema, num_bins)) % Measure the time taken

% use the hist_int_mex function
hist_int_mex_counts = hist_int_mex(abs(signal), extrema, num_bins);
disp('hist_int_mex:');
timeit(@() hist_int_mex(abs(signal), extrema, num_bins)) % Measure the time taken

% use the hist_int_mex_openmp function
hist_int_mex_openmp_counts = hist_int_mex_openmp(abs(signal), extrema, num_bins);
disp('hist_int_mex_openmp:');
timeit(@() hist_int_mex_openmp(abs(signal), extrema, num_bins)) % Measure the time taken

% Check equality of the results
if check_equal_flag
    % Check if the results are equal
    assert(isequal(histcounts_counts, hist_int_counts), 'histcounts and hist_int results are not equal');
    assert(isequal(histcounts_counts, hist_accumarray_counts), 'histcounts and hist_accumarray results are not equal');
    assert(isequal(histcounts_counts, hist_int_mex_counts), 'histcounts and hist_int_mex results are not equal');
    assert(isequal(histcounts_counts, hist_int_mex_openmp_counts), 'histcounts and hist_int_mex_openmp results are not equal');
end

%------------- END OF CODE --------------
