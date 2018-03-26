function [] = PreRestoration()
% ����������Լ���������ݽ�����ǰ��Ȩ����Ȩ����Ϊ ��������Լת������T����������Լ��close�Ⱦ�������ԼT�յ�close��
% AL(spn=3)Ʒ�֣�factors = 200ʱ�����ھ�������Լ����һ������û�����ݣ���Լ�Ѿ���ǰһ�����յ��ڣ������Ը�Ȩ���Ӳ����˿�ֵ��
% FU(1480:1634)Ʒ����ʱ��Σ�5518:5527��û��close���ݣ���Ϊfu_str.oi(5518:5527,1480:1634)��ԭʼ����û���������ݣ�
% JR(1958:1987)Ʒ�������closeΪ��ֵ,����Ϊ��������Լ���������ֲ����ĺ�Լ����Ӧ�Ľ�����û��close�۸񣬽��ײ���Ծ��
% LR��PM��RI��������ֵ�����������JR.

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
    tdays_spe = df.NTradeDate(~cellfun(@isempty,df.Ticker(:,spn)));  % ������Լ�ǿյĽ�����
    Stday = find(tdays_spe(1,1)==df.NTradeDate);  %��һ���ǿս�����
    Ltday = find(tdays_spe(end,1)==df.NTradeDate);  %���һ���ǿս�����    
    tickers = unique(df.Ticker(Stday:Ltday,spn),'stable'); % ������Լ����
    
    if numel(tickers) > 1
        % ���µ�������Լ
    	mid = strcmp(df.Ticker(:,spn),tickers(end));
        for fm=[8:12,19,20]
            main_rest.(fln{fm})(mid,spn) = df.(fln{fm})(mid,spn);
        end
        n=1;
        factors = ones(numel(tickers),1);  %ǰ��Ȩ����
        % ��ʷ������Լ
        while 1
            first_contr_day =find(mid,1,'first');
            % factors = ���º���������Լ��һ�յ����̼�/��������Լ����һ�����գ�����������Լ��һ�գ������̼�
            % AL(spn=3)Ʒ�֣�factors = 200ʱ�����ھ�������Լ����һ������û�����ݣ���Լ�Ѿ���ǰһ�����յ��ڣ������Ը�Ȩ���Ӳ����˿�ֵ��
            % ����취��ֱ�ӽ�factors��ֵ��ֵΪ1
            % Ϊ���������Է��գ�main_contr.m���趨������ԼӦ�ò��������ϵ��ڣ�����һ�����ڣ��ĺ�Լ
            factors(n) = df.close(first_contr_day,spn)/fu_str.close(first_contr_day,strcmp(df.Ticker(first_contr_day-1,spn),fu_str.Ticker(1,:)));
            factors(isnan(factors)==1) = 1;
            n=n+1;
            tickers = tickers(1:end-1);
            mid = strcmp(df.Ticker(:,spn),tickers(end));
            New_Stday =find(mid,1,'first');
            for spt=[8:12,19,20]
                % �µ�������Լ�����̼۵��ھ�������Լ�����̼�*��Ȩ����               
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