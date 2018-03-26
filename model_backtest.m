% function [] = model_backtest(processed_str,main_str,N) % ,sp
% ATR_DAY模型

% 

% 移仓换月的情况 即主力合约品种变动时候的价格跳跃
% 不向后换月只向前换月
% 年化收益 夏普比率 最大回撤

% 冲击成本
% 手续费
% 滑点

fu_main_2010 = load('fu_main_2010.mat');
fu_main_2010_ma_ready = load('fu_main_2010_ma_ready.mat');
processed_str = fu_main_2010_ma_ready;
main_str = fu_main_2010;
N = 10;
RiskLess=0.035;               %无风险收益率(计算夏普比率时需要)
%% backtest
% 初始资金 1000万,平均分配
total_InitialE = 1e7;  
InitialE = total_InitialE/numel(processed_str.sp);
% 仓位 Pos = 1 多头1手; Pos = 0 空仓; Pos = -1 空头1手
Pos = zeros(numel(processed_str.tradedate),numel(processed_str.sp));
% 日收益记录
ReturnD = zeros(numel(processed_str.tradedate),numel(processed_str.sp));

for spe = 1:numel(processed_str.sp)
    % 回测模块
     % position
     % 
    % 画图模块
    % 信号生成模块
    % 计算因子模块
    num = length(processed_str.Ticker(:,spe));  % 天数
    scrsz = get(0,'ScreenSize'); 
    h1 = figure('Position',[scrsz(3)*1/4 scrsz(4)*1/6 scrsz(3)*4/5 scrsz(4)]*3/4);
    plot(processed_str.close(:,spe),'b','LineStyle','-','LineWidth',1.5);
    hold on;
    plot(processed_str.buyline(:,spe),'r','LineStyle','--','LineWidth',1.5);
    plot(processed_str.sellline(:,spe),'k','LineStyle','-.','LineWidth',1.5);
    grid on;
    legend('close','buyline','sellline','Location','Best');
    title(strcat('signal record--',processed_str.sp(:,spe)),'FontWeight', 'Bold');
    hold on;
    %% 回测过程 
    % 回测区间：2010-01-04至2018-02-04
    % 仓位 Pos = 1 多头1手; Pos = 0 空仓; Pos = -1 空头1手
    % Pos(:,numel) = zeros(num,1);
    % 日收益记录
    % ReturnD = zeros(num,1);
    % 持仓数量
    scale = int16(InitialE/max(processed_str.settle(:,spe)));  %仓位最高价下能买到的数量
    buyline = processed_str.buyline(:,spe);
    sellline = processed_str.sellline(:,spe);
    for t = N+1:num    
        % 买入信号 : 当价格向上突破上轨时
        SignalBuy = main_str.close(t,spe)>buyline(t);
        % 卖出信号 : 当价格向下突破下轨时
        SignalSell = main_str.close(t,spe)<sellline(t);
%         % 持仓数量
%         scale = int16(InitialE/max(processed_str.close(t,spe)));  %仓位最高价下能买到的数量
        % 买入条件
        if SignalBuy == 1
            % 空仓开多头1手
            if Pos(t-1,spe) == 0
                Pos(t,spe) = 1;
                text(t,main_str.close(t,spe),' \leftarrowlong','FontSize',8);
                plot(t,main_str.close(t,spe),'ro','markersize',8);
                continue;
            end
            % 平空头开多头1手
            if Pos(t-1,spe) == -1
                Pos(t,spe) = 1;
                ReturnD(t,spe) = (main_str.settle(t-1,spe)-main_str.settle(t,spe))*scale;  %每天结算
                text(t,main_str.close(t,spe),' \leftarrowlong-long','FontSize',8);
                plot(t,main_str.close(t,spe),'ro','markersize',8);           
                continue;
            end
        end

        % 卖出条件
        if SignalSell == 1
            % 空仓开空头1手
            if Pos(t-1,spe) == 0
                Pos(t,spe) = -1;
                text(t,main_str.close(t,spe),' \leftarrowshort','FontSize',8);
                plot(t,main_str.close(t,spe),'rd','markersize',8);
                continue;
            end
            % 平多头开空头1手
            if Pos(t-1,spe) == 1
                Pos(t,spe) = -1;
                ReturnD(t,spe) = (main_str.settle(t,spe)-main_str.settle(t-1,spe))*scale;
                text(t,main_str.close(t,spe),' \leftarrowshort-short','FontSize',8);
                plot(t,main_str.close(t,spe),'rd','markersize',8);
                continue;
            end
        end

        % 每日盈亏计算
        if Pos(t-1,spe) == 1
            Pos(t,spe) = 1;
            ReturnD(t,spe) = (main_str.settle(t,spe)-main_str.settle(t-1,spe))*scale; 
        end
        if Pos(t-1,spe) == -1
            Pos(t,spe) = -1;
            ReturnD(t,spe) = (main_str.settle(t-1,spe)-main_str.settle(t,spe))*scale;
        end
        if Pos(t-1,spe) == 0
            Pos(t,spe) = 0;
            ReturnD(t,spe) = 0;
        end    

        % 最后一个交易日如果还有持仓，进行平仓
        if t == length(main_str.settle(:,spe)) && Pos(t-1) ~= 0
            if Pos(t-1,spe) == 1
                Pos(t,spe) = 0;
                ReturnD(t,spe) = (main_str.settle(t,spe)-main_str.settle(t-1,spe))*scale;
                text(t,main_str.close(t,spe),' \leftarrowclose-long','FontSize',8);
                plot(t,main_str.close(t,spe),'rd','markersize',8);
            end
            if Pos(t-1,spe) == -1
                Pos(t,spe) = 0;
                ReturnD(t,spe) = (main_str.settle(t-1,spe)-main_str.settle(t,spe))*scale;
                text(t,main_str.close(t,spe),' \leftarrowclose-short','FontSize',8);
                plot(t,main_str.close(t,spe),'ro','markersize',8);
            end
        end

    end
    saveas(h1,strcat('C:\Users\bfyang.cephei\Desktop\CTA\ATR_DAY_RESULT\',processed_str.sp{:,spe},'_signal.jpg'));
    close(figure(h1));
    %% 累计收益
    ReturnCum(:,spe) = cumsum(ReturnD(:,spe));
    ReturnCum(:,spe) = ReturnCum(:,spe) + InitialE;
    %% 年化收益
    Return_Year(:,spe) = real((ReturnCum(end,spe)/InitialE)^(1/((num-N)/250))-1);
    %% 计算最大回撤
    MaxDrawD(:,spe) = zeros(length(main_str.settle(:,spe)),1);
    for t = N+1:length(main_str.settle(:,spe))
        C = max( ReturnCum(1:t,spe) );
        if C == ReturnCum(t,spe)
            MaxDrawD(t,spe) = 0;
        else
            MaxDrawD(t,spe) = (ReturnCum(t,spe)-C)/C;
        end
    end
    MaxDrawD(:,spe) = abs(MaxDrawD(:,spe));    
    %% sharp ratio
     DailyReturn(:,spe) = ReturnD(:,spe)/InitialE;
     SharpR(:,spe) = (mean(DailyReturn(:,spe))*365-RiskLess)/(std(DailyReturn(:,spe))*sqrt(365));
    %% 胜率
    
    %% 图形展示
    scrsz = get(0,'ScreenSize');
    h2 = figure('Position',[scrsz(3)*1/4 scrsz(4)*1/6 scrsz(3)*4/5 scrsz(4)]*3/4);
    subplot(3,1,1);
    plot(ReturnCum(:,spe)/InitialE);
    grid on;
    axis tight;
    title(strcat('PNL--',processed_str.sp(:,spe)),'FontWeight', 'Bold');

    subplot(3,1,2);
    plot(Pos(:,spe),'LineWidth',1.8);
    grid on;
    axis tight;
    title(strcat('Positions--',processed_str.sp(:,spe)),'FontWeight', 'Bold');

    subplot(3,1,3);
    plot(MaxDrawD(:,spe));
    grid on;
    axis tight;
    title(strcat(['Max-Drawdown--'],processed_str.sp(:,spe)),'FontWeight', 'Bold');
    saveas(h2,strcat('C:\Users\bfyang.cephei\Desktop\CTA\ATR_DAY_RESULT\',processed_str.sp{:,spe},'_result.jpg'));
    close(figure(h2));
end

