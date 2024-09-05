function [Dummy_Table,First_dummy_indx] = Pgq_Table2Dummy(Table,Name)
% this is a function to transform a table covariates  dummy table

[~,indx] = intersect(Table.Properties.VariableNames,Name);
[n,m] = size(Table);
name_n = length(Name);
if length(indx) ~= name_n
    disp('Name not find all in VariableNames of Table!');
    return
end
Dummy_Table = Table;
Dummy_Table(:,indx) = [];
First_dummy_indx = zeros(name_n,1);
for i = 1 : name_n
    temp = Table.(Name{i});
    temp_value = unique(temp);
    temp_n = length(temp_value);
    temp_table = zeros(n,temp_n);
    temp_name = cell(1,temp_n);
    if isnumeric(temp)
        for j = 1 : temp_n
            temp_indx = temp == temp_value(j);
            temp_table(temp_indx,j) = 1;
            temp_name{j} = [Name{i},'_',num2str(temp_value(j))];
        end
    elseif iscell(temp) || isstring(temp)
         for j = 1 : temp_n
            temp_indx = strcmp(temp,temp_value(j));
            temp_table(temp_indx,j) = 1;
            temp_name{j} = [Name{i},'_',temp_value{j}];
         end
    else
        disp('wrong!');
        return;
    end
    temp_table = array2table(temp_table,'VariableNames',temp_name);
    First_dummy_indx(i) = temp_n;
    Dummy_Table = [Dummy_Table,temp_table];
end
First_dummy_indx(2:end) = cumsum(First_dummy_indx(1:end-1));
First_dummy_indx(1) = 0;
First_dummy_indx = First_dummy_indx + m - name_n + 1;
end
