function [] = cal_ma(N,field_name)
%% 计算均线--10日
% N = 10;
% field_name = 'settle'

fu_str=load('fu_str.mat');
fu_main_2010=load('fu_main_2010.mat');

fu_main_2010_ma = fu_main_2010;
fu_main_2010_ma.(field_name) = zeros(size(fu_main_2010_ma.(field_name)));
lst_days_num = zeros(size(fu_main_2010_ma.(field_name)));
for mc=1:size(fu_main_2010.Ticker,2)   % 每一个品种
    for mcd=1:size(fu_main_2010.Ticker,1)  %主力合约序列下的每一天的主力合约
        if ~isempty(fu_main_2010.Ticker{mcd,mc})          
            start_index = find(fu_str.NTradeDate == datenum(fu_main_2010.StartDate(mcd,mc)));% 合约起始日的index
            pdays_index = find(fu_str.NTradeDate == fu_main_2010.NTradeDate(mcd,1));  %主力合约当前交易日的index
            if pdays_index-start_index>= N
                mid_fieldname = fu_str.(field_name)(ismember(fu_str.NTradeDate,fu_str.NTradeDate(pdays_index-N:pdays_index-1)),strcmp(fu_main_2010.Ticker(mcd,mc),fu_str.Ticker));
                fu_main_2010_ma.(field_name)(mcd,mc) = sum(mid_fieldname)/numel(mid_fieldname); 
                lst_days_num(mcd,mc) = numel(mid_fieldname); %建立MA有效日期的记录
            elseif pdays_index-start_index>=1 %判断将要计算该合约的特定交易日的N日均线之前有大于N个交易日或者1个
                mid_fieldname = fu_str.(field_name)(ismember(fu_str.NTradeDate,fu_str.NTradeDate(start_index:pdays_index-1)),strcmp(fu_main_2010.Ticker(mcd,mc),fu_str.Ticker));
                fu_main_2010_ma.(field_name)(mcd,mc) = sum(mid_fieldname)/numel(mid_fieldname); 
                lst_days_num(mcd,mc) = numel(mid_fieldname); %建立MA有效日期的记录
            else
                fu_main_2010_ma.(field_name)(mcd,mc) = fu_main_2010.(field_name)(mcd,mc);
                lst_days_num(mcd,mc) = 1;
            end
        end
    end
end
save('C:\Users\bfyang.cephei\Desktop\CTA\data\daybar_20180204\data_gene\fu_main_2010_ma.mat','-struct','fu_main_2010_ma');  % C:\Users\bfyang.cephei\Desktop\CTA\data\daybar_20180204\data_gene
end

