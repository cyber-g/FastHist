function counts = hist_int(input, extrema, num_bins)
% HIST_INT - Computes a histogram for integer data within specified bins
% This function normalizes the input data to fit within the specified range
% and computes a histogram with the given number of bins.
%
% Syntax:  counts = hist_int(input, extrema, num_bins)
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
%    counts = hist_int([1, 2, 2, 3], [1, 3], 3)
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
% May 2025; Last revision: 

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

    % prepare data (normalize (increase range so as to include the trailing edge), and round to integer)
    % This is done because histcounts includes the trailing edge in the last bin
    data = floor((input-extrema(1))/((1+1e-10)*diff(extrema))*num_bins)+1;

    counts = zeros(1, num_bins);
    % Loop through each bin
    for row = 1: size(data, 1)
        counts(data(row)) = counts(data(row)) + 1;
    end
    % Normalize the counts
    counts = counts / sum(counts);

end


%------------- END OF CODE --------------