function counts = hist_int_simpler(input, extrema, num_bins)
% HIST_INT_SIMPLER - Computes a histogram for integer data within specified bins
% This function normalizes the input data to fit within the specified range
% and computes a histogram with the given number of bins.
%
% Compared to the `hist_int` function, `hist_int_simpler` takes a more natural 
% and accurate approach by explicitly checking the trailing edge of the interval 
% for each sample. This avoids the artificial scaling used in `hist_int`, which 
% adjusts the range to include the trailing edge. By handling the trailing edge 
% individually, `hist_int_simpler` ensures more precise bin assignment for edge 
% cases, particularly when input values are equal to the maximum of the range.
%
% Syntax:  counts = hist_int_simpler(input, extrema, num_bins)
%
% Inputs:
%    input   - Column vector of input data (real-valued)
%    extrema - Two-element vector specifying the range [min, max]
%    num_bins - Number of bins for the histogram
%
% Outputs:
%    counts - Normalized histogram counts
%
% Example: 
%    counts = hist_int_simpler([1, 2, 2, 3], [1, 3], 3)
%
% See also: histcounts
% 
% Project: FastHist (https://github.com/cyber-g/FastHist)
% 
% Note: 
%   1/  For speed reasons, any checking of the input data is disabled. If you want to
%       check the input data, uncomment the appropriate lines below.
%   2/  The function is inpired by the code provided by Jan Siegmund in: 
%       https://fr.mathworks.com/matlabcentral/answers/617208-efficient-number-occurence-count
%   3/  This function assumes that the input data is fully included in the range
%       of extrema. IT HAS NOT BEEN TESTED FOR DATA OUTSIDE THE RANGE.
% 
% Thanks:
%    Denis Gilbert (2025). M-file Header Template
%    (https://www.mathworks.com/matlabcentral/fileexchange/4908-m-file-header-template),
%    MATLAB Central File Exchange. Accessed on April 26, 2025. 
% 
% Author: Germain PHAM
% C2S, Télécom ParisTech, IP Paris
% email: dpham@telecom-paris.fr
% July 2025; Last revision: 

%------------- BEGIN CODE --------------

    % % Check that the input is a columnvector
    % if size(input, 2) > 1 
    %     error('Input must be a columnvector  with more than one row.');
    % end

    % % Check that the input is a real-valued array
    % if ~isreal(input)
    %     error('Input must be a real-valued array.');
    % end

    % % Check that the extrema is a 2-element vector in ascending order
    % if length(extrema) ~= 2 || extrema(1) >= extrema(2)
    %     error('Extrema must be a 2-element vector in ascending order.');
    % end

    % prepare data (normalize, and round to integer)
    data = floor(input/diff(extrema)*num_bins)+1;

    counts = zeros(1, num_bins);
    % Loop through each bin
    for row = 1: size(data, 1)
        if input(row) == extrema(2)
            % If the value is equal to the maximum, it should go to the last bin
            % This is because histcounts includes the trailing edge in the last bin
            counts(num_bins) = counts(num_bins) + 1;
        else
            counts(data(row)) = counts(data(row)) + 1;
        end
    end
    % Normalize the counts
    counts = counts / sum(counts);

end


%------------- END OF CODE --------------