function counts = hist_accumarray(input, extrema, num_bins)
% HIST_ACCUMARRAY - Computes a normalized histogram using accumarray
% This function normalizes the input data to fit within the specified range
% and computes a histogram with the given number of bins using accumarray.
%
% Syntax:  counts = hist_accumarray(input, extrema, num_bins)
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
%    counts = hist_accumarray([1, 2, 2, 3], [1, 3], 3)
%
% See also: histcounts, accumarray
% 
% Note: 
%   1/  For speed reasons, any checking of the input data is disabled. If you want to
%       check the input data, uncomment the appropriate lines below.
%   2/  The function is inpired by the code provided by Matt J in: 
%       https://fr.mathworks.com/matlabcentral/answers/617208-efficient-number-occurence-count
%   3/  This function assumes that the input data is fully included in the range
%       of extrema. It has not been tested for data outside the range.
%  
% Thanks:
%    Denis Gilbert (2025). M-file Header Template
%    (https://www.mathworks.com/matlabcentral/fileexchange/4908-m-file-header-template),
%    MATLAB Central File Exchange. Accessed on April 26, 2025. 
% 
% License:
%    GNU General Public License v3.0 (GPL-3.0)
% 
% Author: Germain PHAM
% C2S, Télécom Paris, IP Paris
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
    data = floor((input-extrema(1))/((1+1e-10)*diff(extrema))*num_bins)+1;

    counts = accumarray(data, 1);
    % Normalize the counts
    counts = counts.' / sum(counts);

end

%------------- END OF CODE --------------