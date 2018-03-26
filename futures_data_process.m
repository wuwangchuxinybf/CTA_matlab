% read futures market data of CZC,DCE and SHF
% history martket data from wind till 20180204
format compact;
%% get data 
% history data till 2018-02-04
Futures_data = readtable('C:\Users\bfyang.cephei\Desktop\CTA\data\daybar_20180204\futures_20180204.csv');
Futures_data.lastradeday_s = cellstr(Futures_data.lastradeday_s);
Futures_data.last_trade_day = cellstr(Futures_data.last_trade_day);
%% format to struct
% add a field NTradeDate for datenum
date_map = containers.Map(unique(Futures_data.tradedate),datenum(unique(Futures_data.tradedate))); 
Futures_data.NTradeDate = values(date_map,Futures_data.tradedate);
futures_str = table2struct(Futures_data,'ToScalar',true);
futures_fld = fieldnames(futures_str);
%% contract start and end date
begine_end_date = readtable('C:\Users\bfyang.cephei\Desktop\CTA\data\daybar_20180204\begine_and_end_date.xlsx');
be_str = table2struct(begine_end_date,'ToScalar',true);
%% transform str
fu_str = struct;
fu_str.Ticker = unique(Futures_data.Ticker)';
fu_str.tradedate = sort(cellstr(datestr(unique(Futures_data.tradedate),'yyyy-mm-dd')));
fu_str.NTradeDate = datenum(fu_str.tradedate);
% get sp field
fu_sp = cellfun(@(x) int16(x(2))>=65,fu_str.Ticker); 
fu_str.sp(1,fu_sp) = cellfun(@(x) x(1:2),fu_str.Ticker(1,fu_sp),'UniformOutput',false);
fu_str.sp(1,~fu_sp) = cellfun(@(x) x(1),fu_str.Ticker(1,~fu_sp),'UniformOutput',false);
Old_names = {'TC','WT','WS','ER','ME','RO'};
New_names = {'ZC','PM','WH','RI','MA','OI'};
for name=1:length(Old_names)
    fu_str.sp(strcmp(fu_str.sp,Old_names{name})) = New_names(name);
end
% contract StartDate and LastDate
for codenum=1:numel(fu_str.Ticker)
    fu_str.StartDate(codenum) = be_str.begine_date(strcmp(be_str.code,fu_str.Ticker{codenum}));
    fu_str.LastDate(codenum) = be_str.end_date(strcmp(be_str.code,fu_str.Ticker{codenum})); 
end
t_count = size(fu_str.Ticker,2);  %contract num 4330
d_count = size(fu_str.tradedate,1);  %tradedate num 6002
%contract remained days
fu_str.remaindays = (datenum(fu_str.LastDate)-fu_str.NTradeDate) + 1; %plus the present tradeday
AA = fu_str.NTradeDate >= datenum(fu_str.StartDate) & fu_str.NTradeDate <= datenum(fu_str.LastDate);
fu_str.remaindays = fu_str.remaindays.*AA;
% split field to tradedate*contractnum
for i=3:numel(futures_fld)-1
    if isa(futures_str.(futures_fld{i}),'double')
        mat = NaN(d_count,t_count);
    elseif isa(futures_str.(futures_fld{i}),'cell')
        mat = cell(d_count,t_count);
    end
    for j=1:t_count
        % origin has one contract repeating data,drop by handle
        colIndex = strcmp(futures_str.Ticker, fu_str.Ticker{j}); 
        rIndex = ismember(fu_str.NTradeDate,[futures_str.NTradeDate{colIndex}]');
        mat(rIndex,j) = futures_str.(futures_fld{i})(colIndex,:);
    end
    fu_str.(futures_fld{i}) = mat;
end
save('C:\Users\bfyang.cephei\Desktop\CTA\data\daybar_20180204\data_gene\fu_str.mat','-struct','fu_str');
save('C:\Users\bfyang.cephei\Desktop\CTA\data\daybar_20180204\data_gene\be_str.mat','-struct','be_str');
%%
main_contr('oi',0.1,'2018-02-04') % 求主力合约
PreRestoration(); % 前复权
mkt_start_date('2010-01-01','2018-02-04'); % 选取2010年之后的日行情数据进行模型验证
cal_ma(10,'settle'); % 计算settle的10日均线
ATR_DAY(2,10); % ATR_DAY策略中，设置K值为2，TR的M=10日移动平均值为ATR取值
%% for backtest
% fu_str=load('fu_str.mat');
% fu_main_2010=load('fu_main_2010.mat');
% fu_main_2010_ma_ready=load('fu_main_2010_ma_ready.mat');
% model_backtest(fu_main_2010_ma_ready,fu_main_2010,10,fu_main_2010_ma_ready.sp);
% 
% %% 
% fnames = fieldnames(fu_main_2010_ma_ready);
% d_count = size(fu_main_2010_ma_ready.Ticker,1);
% 
% lst_ATR = cell(1,numel(fu_main_2010_ma_ready.sp));
% for rsp=1:length(fu_main_2010_ma_ready.sp)
%     tar = struct;
%     tar.sp = fu_main_2010_ma_ready.sp(1,rsp);
%     tar.tradedate = fu_main_2010_ma_ready.tradedate;
%     tar.NTradeDate = fu_main_2010_ma_ready.NTradeDate;
%     tar.FirstOiDay = fu_main_2010_ma_ready.FirstOiDay(1,rsp);
%     for fna=[4:22,25,27:length(fnames)]
%         if isa(fu_main_2010_ma_ready.(fnames{fna}),'double')   %根据字段不同类型创建不同类型的mat
%             tar.(fnames{fna}) = NaN(d_count,1);
%         elseif isa(fu_main_2010_ma_ready.(fnames{fna}),'cell')
%             tar.(fnames{fna}) = cell(d_count,1);
%         end     
%         tar.(fnames{fna})(:,rsp) = fu_main_2010_ma_ready.(fnames{fna})(:,rsp);
%     end
%     Name6 = ['tar_',fu_main_2010_ma_ready.sp{rsp}];
%     lst_ATR{rsp} = Name6;
%     eval([Name6,'=tar']);
%     clear eval; 
% end