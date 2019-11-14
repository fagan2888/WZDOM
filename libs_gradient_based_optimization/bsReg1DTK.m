function [f, g, data] = bsReg1DTK(x, data, isInitial)
%% Regularization function, return the value and gradient of function $|Dx|_2^2$
% Bin She, bin.stepbystep@gmail.com, March, 2019
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INPUT
%
% x             is a column vector; refers to the parameter to be estimated.
%
% data.diffOrder is a scalar; refers to the order of difference operator D
% (D will be generated by this parameter, defaut data.diffOrder is 1,
% meaning D is a first-order difference operator.
% 
% data.nSegments is a scalar; refers to how many parts n is. For example, 
% for pre-stack three-term AVO inversion, nsegments is 3.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OUTPUT
% f             is a scalar; refers to |Dx|_2^2.
%
% g             is a column vector; refers to the gradient of |Dx|_2^2 with respect to x.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % if the funcion is called at first time and the difference matrix D is
    % not given, we first generate the difference matix D and save it in
    % data.
    if nargin == 3 && isInitial && (~isfield(data, 'D') || isempty(data.D))
        [~, data] = bsGetFieldsWithDefaults(data, {'diffOrder', 2; 'nSegments', 1});
        validateattributes(data.diffOrder, {'double'}, {'>=', 1, '<=', 3});
        data.D = bsGen1DDiffOperator(length(x), data.nSegments, data.diffOrder);
    end
    
    z = data.D * x;
    f = z' * z;
    
    g = 2 * (data.D' * z);
end