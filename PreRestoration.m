function [] = PreRestoration()
% 对于主力合约的行情数据进行向前复权，复权因子为 新主力合约转换当日T，新主力合约的close比旧主力合约T日的close；
% AL(spn=3)品种，factors = 200时，由于旧主力合约在下一交易日没有数据（合约已经于前一交易日到期），所以复权因子产生了空值。
% FU(1480:1634)品种在时间段（5518:5527）没有close数据；因为fu_str.oi(5518:5527,1480:1634)即原始数据没有行情数据；
% JR(1958:1987)品种有许多close为空值,是因为其主力合约（当日最大持仓量的合约）对应的交易日没有close价格，交易不活跃；
% LR、PM、RI都有许多空值；情况类似于JR.

%%

fu_str=load('fu_str.mat');
df=load('fu_main.mat');

species = numel(df.sp); 
fln = fieldnames(df);

for spm=[1:7,13:18,21:25]
    main_rest.(fln{spm}) = df.(fln{spm});
end
for spm2=[8:12,19,20]
    main_rest.(fln{spm2}) = zeros(size(df.(fln{spm2})));
end

for spn=1:species
    tdays_spe = df.NTradeDate(~cellfun(@isempty,df.Ticker(:,spn)));  % 主力合约非空的交易日
    Stday = find(tdays_spe(1,1)==df.NTradeDate);  %第一个非空交易日
    Ltday = find(tdays_spe(end,1)==df.NTradeDate);  %最后一个非空交易日    
    tickers = unique(df.Ticker(Stday:Ltday,spn),'stable'); % 主力合约代码
    
    if numel(tickers) > 1
        % 最新的主力合约
    	mid = strcmp(df.Ticker(:,spn),tickers(end));
        for fm=[8:12,19,20]
            main_rest.(fln{fm})(mid,spn) = df.(fln{fm})(mid,spn);
        end
        n=1;
        factors = ones(numel(tickers),1);  %前复权因子
        % 历史主力合约
        while 1
            first_contr_day =find(mid,1,'first');
            % factors = 换月后新主力合约第一日的收盘价/旧主力合约在下一交易日（即新主力合约第一日）的收盘价
            % AL(spn=3)品种，factors = 200时，由于旧主力合约在下一交易日没有数据（合约已经于前一交易日到期），所以复权因子产生了空值。
            % 处理办法：直接将factors空值赋值为1
            % 为避免流动性风险，main_contr.m已设定主力合约应该不包括马上到期（比如一天以内）的合约
            factors(n) = df.close(first_contr_day,spn)/fu_str.close(first_contr_day,strcmp(df.Ticker(first_contr_day-1,spn),fu_str.Ticker(1,:)));
            factors(isnan(factors)==1) = 1;
            n=n+1;
            tickers = tickers(1:end-1);
            mid = strcmp(df.Ticker(:,spn),tickers(end));
            New_Stday =find(mid,1,'first');
            for spt=[8:12,19,20]
                % 新的主力合约的收盘价等于旧主力合约的收盘价*复权因子               
                main_rest.(fln{spt})(New_Stday:first_contr_day-1,spn) = df.(fln{spt})(New_Stday:first_contr_day-1,spn)*prod(factors);
            end
            if numel(tickers) > 1
                continue
            else
                break
            end
        end
    else
        for sps=[8:12,19,20]
            main_rest.(fln{sps})(Stday:Ltday,spn) = df.(fln{sps})(Stday:Ltday,spn);
        end
    end
end
save('C:\Users\bfyang.cephei\Desktop\CTA\data\daybar_20180204\data_gene\fu_main_res.mat','-struct','main_rest');
end