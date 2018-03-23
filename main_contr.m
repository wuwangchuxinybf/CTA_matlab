function [] = main_contr(field_name,percent_fn,end_tdate)
%主力合约变动规则：
% 1、在第一个交易日，以当日某一字段最大的合约作为该品种的主力合约，以oi为例；
% 2、在后边的某一交易日，首先计算当日oi最大的合约，并且处于最后交易日的合约不能作为主力合约；
%   如果该合约相比上一交易日主力合约不变，则当日主力合约不变； ...(1)
%   如果该合约相比上一交易日主力合约发生变化，那么继续比较该合约的oi相比于前主力合约当日的oi，
%       若大于1.1倍以上，则
%           如果该合约在之前未做过主力合约，则以该合约作为当日的主力合约，即主力合约为只向后换月；...(2)
%           如果该合约在之前做过主力合约，则以当日oi第二大的合约作为当日该商品的主力合约；...(3)
%       若小于等于1.1倍，则以上一交易日的主力合约作为当日的主力合约   ...(4)
% 即，  (1)和(2)以当日最大的oi的合约作为主力合约；
%       (3)以当日oi第二大的合约作为主力合约；
%       (4)以上一交易日主力合约作为当日主力合约；

% field_name表示以当日该字段最大的合约作为该品种的主力合约；
% percent_fn，表示如果后一天的oi超过前一天的某一百分比（比如10%）以内，主力合约不变；
% end_tdate,表示所求主力合约序列的截止交易日期；

% field_name = 'oi'
% percent_fn = 0.1
% end_tdate = '2018-02-04'

%% 每日最大oi确定主力合约
fu_str=load('fu_str.mat');
fln = fieldnames(fu_str);
be_str=load('be_str.mat');
% 计算每个合约倒数第二个交易日，用作后续的主力合约确定
for codenum=1:numel(fu_str.Ticker)
    mid_bldate = fu_str.tradedate(find(fu_str.NTradeDate==datenum(be_str.end_date(strcmp(be_str.code,fu_str.Ticker{codenum}))))-1);
    if ~isempty(mid_bldate)
        fu_str.Before_LDate(codenum) = mid_bldate;
    else  % 有一些合约没有在StartDate和LastDate之间的所有的交易日数据
        mid_bldate2 = fu_str.tradedate(~isnan(fu_str.oi(:,strcmp(fu_str.Ticker,fu_str.Ticker{codenum}))));
        fu_str.Before_LDate(codenum) = mid_bldate2(end-1);
    end 
end

t_num = numel(fu_str.tradedate);
fu_main = struct;
fu_mid = struct;
fu_main.tradedate = fu_str.tradedate;
fu_main.NTradeDate = fu_str.NTradeDate;
species = unique(fu_str.sp); 
fln2 = fieldnames(fu_str);
% 初始化fu_main
for fm=[18,1,5:17,19:length(fln)]
    if ismember(fm,[1,5,6,23,24])
        fu_main.(fln{fm}) = cell(t_num,length(species));
    else
        fu_main.(fln{fm}) = NaN(t_num,length(species));
    end
end
% 计算主力合约各字段取值
nn=1;
for spn=1:length(species)   %species
    tic
    fu_main.sp(1,spn) = species(spn);    
    for fnn=[18,1,5:17,19:length(fln2)]
        fu_mid.(fln2{fnn}) = fu_str.(fln2{fnn})(:,strcmp(fu_str.sp ,species{spn}));
    end
     % RU这个品种在'1995-12-15'至'1996-01-11','1996-08-16'至{'1997-04-11'没有交易数据,简单处理下
    if spn ==37
        start_min = 492; 
    else
        start_min = find(fu_str.tradedate == min(fu_mid.StartDate));
    end
%     end_max = find(fu_str.tradedate == max(fu_mid.LastDate));  %之前是max(fu_mid.StartDate)
    end_max = find(fu_str.NTradeDate <= datenum(end_tdate),1,'last' ); %距离输入的截止日期之前最近的交易日
    for rn=start_min:end_max
        if ~all(isnan(fu_mid.oi(rn,:))) 
%             % 最大oi
%             [max_val,index_mid] = max(fu_mid.(field_name)(rn,:),[],2);
%             % 第二大oi
%             mid_fn = fu_mid.(field_name);
%             mid_fn(rn,mid_fn(rn,:) == max(mid_fn(rn,:))) = min(mid_fn(rn,:));
%             [~,index_mid2] = max(mid_fn(rn,:),[],2);
            % 最大oi,原来的方式会剔除掉前面的ticker，导致移位，得不到正确的主力合约的列坐标；
            earlier_td = datenum(fu_main.tradedate(rn,1))<=cellfun(@datenum,fu_mid.Before_LDate); %主力合约不能是最后一个交易日  
            [max_val,index_mid_s] = max(fu_mid.(field_name)(rn,earlier_td),[],2);
            mid_Ticker = fu_mid.Ticker(:,earlier_td);
            index_mid = find(strcmp(mid_Ticker(1,index_mid_s),fu_mid.Ticker(1,:)));
            % 第二大oi
            mid_fn = fu_mid;
%             mid_fn(rn,mid_fn(rn,earlier_td) == max(mid_fn(rn,earlier_td))) = min(mid_fn(rn,earlier_td));
            mid_fn.(field_name)(rn,index_mid) = 0;
            [~,index_mid_2s] = max(mid_fn.(field_name)(rn,earlier_td),[],2);
            mid_Ticker2 = mid_fn.Ticker(:,earlier_td);
            index_mid2 = find(strcmp(mid_Ticker2(1,index_mid_2s),mid_fn.Ticker(1,:)));
 
            if  (((rn>start_min+1) && any(strcmp(fu_mid.Ticker(1,index_mid),fu_main.Ticker(1:rn-2,spn)))) || (rn==(start_min+1)))&& ... %历史出现过 
                  (~strcmp(fu_mid.Ticker(1,index_mid),fu_main.Ticker(rn-1,spn))) && ...  %持仓量最大的合约发生变化
                    ( max_val>((fu_mid.(field_name)(rn,strcmp(fu_mid.Ticker(1,:),fu_main.Ticker(rn-1,spn))))*(1+ percent_fn))) %oi大于1.1倍
                for fn=[18,1,5:17,19:length(fln)] % caculate all fieldnames,oi first
                    if fn == 1
                        fu_main.(fln{fn})(rn,spn) = fu_mid.(fln{fn})(1,index_mid2); 
                    elseif ismember(fn,[5,6])
                        fu_main.(fln{fn})(rn,spn) = cellstr(fu_mid.(fln{fn})(1,index_mid2)); 
                    else
                        fu_main.(fln{fn})(rn,spn) = fu_mid.(fln{fn})(rn,index_mid2);
                    end
                end
            elseif rn > start_min && ...
                 (~strcmp(fu_mid.Ticker(1,index_mid),fu_main.Ticker(rn-1,spn))) && ...  %持仓量最大的合约发生变化
                    ( max_val<= ((fu_mid.(field_name)(rn,strcmp(fu_mid.Ticker(1,:),fu_main.Ticker(rn-1,spn))))*(1+ percent_fn)))  %oi小于等于1.1倍
                for fn=[18,1,5:17,19:length(fln)] % caculate all fieldnames,oi first
                    if fn == 1
                        fu_main.(fln{fn})(rn,spn) = fu_main.Ticker(rn-1,spn); 
                    elseif ismember(fn,[5,6])
                        fu_main.(fln{fn})(rn,spn) = cellstr(fu_mid.(fln{fn})(1,strcmp(fu_mid.Ticker,fu_main.Ticker(rn-1,spn))));
                    else
                        fu_main.(fln{fn})(rn,spn) = fu_mid.(fln{fn})(rn,strcmp(fu_mid.Ticker,fu_main.Ticker(rn-1,spn)));
                    end
                end
            else
                for fn=[18,1,5:17,19:length(fln)] 
                    if fn == 1
                        fu_main.(fln{fn})(rn,spn) = fu_mid.(fln{fn})(1,index_mid); 
                    elseif ismember(fn,[5,6])
                        fu_main.(fln{fn})(rn,spn) = cellstr(fu_mid.(fln{fn})(1,index_mid)); 
                    else
                        fu_main.(fln{fn})(rn,spn) = fu_mid.(fln{fn})(rn,index_mid);
                    end     
                end
            end     
        end
    end
    nn=nn+1
    toc
end 
save('C:\Users\bfyang.cephei\Desktop\CTA\data\daybar_20180204\data_gene\fu_main.mat','-struct','fu_main');
end
% test = fu_main.Ticker(:,1:3);
