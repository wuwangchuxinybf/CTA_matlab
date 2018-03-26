% function [] = model_backtest(processed_str,main_str,N) % ,sp
% ATR_DAYģ��

% 

% �Ʋֻ��µ���� ��������ԼƷ�ֱ䶯ʱ��ļ۸���Ծ
% �������ֻ��ǰ����
% �껯���� ���ձ��� ���س�

% ����ɱ�
% ������
% ����

fu_main_2010 = load('fu_main_2010.mat');
fu_main_2010_ma_ready = load('fu_main_2010_ma_ready.mat');
processed_str = fu_main_2010_ma_ready;
main_str = fu_main_2010;
N = 10;
RiskLess=0.035;               %�޷���������(�������ձ���ʱ��Ҫ)
%% backtest
% ��ʼ�ʽ� 1000��,ƽ������
total_InitialE = 1e7;  
InitialE = total_InitialE/numel(processed_str.sp);
% ��λ Pos = 1 ��ͷ1��; Pos = 0 �ղ�; Pos = -1 ��ͷ1��
Pos = zeros(numel(processed_str.tradedate),numel(processed_str.sp));
% �������¼
ReturnD = zeros(numel(processed_str.tradedate),numel(processed_str.sp));

for spe = 1:numel(processed_str.sp)
    % �ز�ģ��
     % position
     % 
    % ��ͼģ��
    % �ź�����ģ��
    % ��������ģ��
    num = length(processed_str.Ticker(:,spe));  % ����
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
    %% �ز���� 
    % �ز����䣺2010-01-04��2018-02-04
    % ��λ Pos = 1 ��ͷ1��; Pos = 0 �ղ�; Pos = -1 ��ͷ1��
    % Pos(:,numel) = zeros(num,1);
    % �������¼
    % ReturnD = zeros(num,1);
    % �ֲ�����
    scale = int16(InitialE/max(processed_str.settle(:,spe)));  %��λ��߼������򵽵�����
    buyline = processed_str.buyline(:,spe);
    sellline = processed_str.sellline(:,spe);
    for t = N+1:num    
        % �����ź� : ���۸�����ͻ���Ϲ�ʱ
        SignalBuy = main_str.close(t,spe)>buyline(t);
        % �����ź� : ���۸�����ͻ���¹�ʱ
        SignalSell = main_str.close(t,spe)<sellline(t);
%         % �ֲ�����
%         scale = int16(InitialE/max(processed_str.close(t,spe)));  %��λ��߼������򵽵�����
        % ��������
        if SignalBuy == 1
            % �ղֿ���ͷ1��
            if Pos(t-1,spe) == 0
                Pos(t,spe) = 1;
                text(t,main_str.close(t,spe),' \leftarrowlong','FontSize',8);
                plot(t,main_str.close(t,spe),'ro','markersize',8);
                continue;
            end
            % ƽ��ͷ����ͷ1��
            if Pos(t-1,spe) == -1
                Pos(t,spe) = 1;
                ReturnD(t,spe) = (main_str.settle(t-1,spe)-main_str.settle(t,spe))*scale;  %ÿ�����
                text(t,main_str.close(t,spe),' \leftarrowlong-long','FontSize',8);
                plot(t,main_str.close(t,spe),'ro','markersize',8);           
                continue;
            end
        end

        % ��������
        if SignalSell == 1
            % �ղֿ���ͷ1��
            if Pos(t-1,spe) == 0
                Pos(t,spe) = -1;
                text(t,main_str.close(t,spe),' \leftarrowshort','FontSize',8);
                plot(t,main_str.close(t,spe),'rd','markersize',8);
                continue;
            end
            % ƽ��ͷ����ͷ1��
            if Pos(t-1,spe) == 1
                Pos(t,spe) = -1;
                ReturnD(t,spe) = (main_str.settle(t,spe)-main_str.settle(t-1,spe))*scale;
                text(t,main_str.close(t,spe),' \leftarrowshort-short','FontSize',8);
                plot(t,main_str.close(t,spe),'rd','markersize',8);
                continue;
            end
        end

        % ÿ��ӯ������
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

        % ���һ��������������гֲ֣�����ƽ��
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
    %% �ۼ�����
    ReturnCum(:,spe) = cumsum(ReturnD(:,spe));
    ReturnCum(:,spe) = ReturnCum(:,spe) + InitialE;
    %% �껯����
    Return_Year(:,spe) = real((ReturnCum(end,spe)/InitialE)^(1/((num-N)/250))-1);
    %% �������س�
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
    %% ʤ��
    
    %% ͼ��չʾ
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

