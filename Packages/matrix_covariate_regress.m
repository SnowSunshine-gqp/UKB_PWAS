function [result_data] = matrix_covariate_regress(data_Y, data_cov)
%% This function is to de-covariate an MxN matrix, 
% where M is the number of subjects and N is the number of brain areas

% Input: data_Y: matrix of M x N, where M is the number of subjects and N is the number of brain regions
% data_cov: matrix of M x K, where K is the number of covariables
% Output: result_data: A new M x N matrix, which is the residual of data_Y by removing the skew variable data_cov
[~,N] = size(data_Y);
result_data = nan(size(data_Y));
RangeNumber = 5000;
X = data_cov;

for i = 1:N
    if mod(i,RangeNumber) ==0
     disp(['Calculating the',num2str(i),'th ~ ',num2str(i + RangeNumber),'th column'])
    end
    y = data_Y(:,i);
    [b,~,r] = regress(y,X);
    result_data(:,i) = b(1) + r;
end



