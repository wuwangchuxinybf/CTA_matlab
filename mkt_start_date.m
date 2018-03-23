function [] = mkt_start_date(start_date,enddate)
% main contract from 2010-01-01
% start_date = '2010-01-01';
% enddate = '2018-02-04'
fu_main=load('fu_main_res.mat');
fu_str=load('fu_str.mat');
main_fld = fieldnames(fu_main);
fu_main_2010 = struct;
fu_main_2010.sp = fu_main.sp;
for nn=1:length(main_fld)-1
    fu_main_2010.(main_fld{nn}) = fu_main.(main_fld{nn})(fu_str.NTradeDate>=datenum(start_date)&fu_str.NTradeDate<=datenum(enddate),:);
end
save('C:\Users\bfyang.cephei\Desktop\CTA\data\daybar_20180204\data_gene\fu_main_2010.mat','-struct','fu_main_2010');
end

