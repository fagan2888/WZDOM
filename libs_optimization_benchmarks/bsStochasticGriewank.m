function [f, g] = bsStochasticGriewank(x, isGradient, o)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -------------------------------------------------------------------------
% Griewank Function 
% Programmed by Bin She (bin.stepbystep@gmail.com)
% Programming dates: May 2019   
% -------------------------------------------------------------------------
% For function details and reference information, see:
% see http://benchmarkfcns.xyz/benchmarkfcns/griewankfcn.html
%
% Global minimum: min(f) = 0 at x = (0, 0, ...)'; -600<=x(i)<= 600.
% -------------------------------------------------------------------------
% Input
%
% x: it must be a column vector representing the variable to be estimated
%
% isGradient: a logical variabel. The function will calculate gradient
% information of this objective function if it is equal to true, otherwise,
% the subroutine will not compute the gradient information. 
% -------------------------------------------------------------------------
% Output
%
% f: objective function value.
% 
% g: gradient information. g = [] if isGradient = 0.
% -------------------------------------------------------------------------

    if nargin == 1 || isempty(isGradient)
        isGradient = true;
    end

    [n, m] = size(x);
    
    seq = (1 : n)';
    seq = repmat(seq, 1, m);
    o = repmat(o*40, 1, m);
    
    term1 = o .* x.^2 / 4000;
    tmp = x ./ sqrt(seq);
    term2 = cos(tmp);
    prodTerm2 = prod(term2, 1);
    
    f = sum(term1, 1) - prodTerm2 + 1;
    
    if isGradient
        
        g = 2/4000 * (o .* x) + prodTerm2 ./ term2 .* sin(tmp) ./ sqrt(seq);
    else
        g = [];
    end
end