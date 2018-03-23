function [] = ATR_DAY(K,M)
%% ATR_DAYģ��
% K = 2;   % K ����ͨ������Ĳ���
% M = 10;  % ��ʵ������Χ��TR��������ƽ������

fu_main_2010=load('fu_main_2010.mat');
fu_main_2010_ma = load('fu_main_2010_ma.mat');
% �����Ϲ�Buyline ���¹�Sellline
% add specific specie first day has oi  
for nl=1:size(fu_main_2010_ma.oi,2)
    fu_main_2010_ma.FirstOiDay(1,nl) = find(fu_main_2010_ma.oi(:,nl)>0,1,'first')+ fu_main_2010_ma.NTradeDate(1)-1;
end
mat_T = NaN(1968,48,3);
mat_T(:,:,1) = fu_main_2010.high - fu_main_2010.low;
mat_T(:,:,2) = abs(fu_main_2010.high - fu_main_2010.pre_close);
mat_T(:,:,3) = abs(fu_main_2010.low - fu_main_2010.pre_close);
fu_main_2010_ma.TR = max(mat_T,[],3);
% ����ATR
for nsp=1:size(fu_main_2010_ma.TR,2)
    for ntr=1:size(fu_main_2010_ma.TR,1)
        if ntr - fu_main_2010_ma.FirstOiDay(1,nsp)> M
            fu_main_2010_ma.ATR(ntr,nsp) = sum(fu_main_2010_ma.TR(ntr-M:ntr-1,nsp))/M;
        elseif ntr - fu_main_2010_ma.FirstOiDay(1,nsp)>1
            fu_main_2010_ma.ATR(ntr,nsp) = sum(fu_main_2010_ma.TR(1:ntr-1,nsp))/numel(fu_main_2010_ma.TR(1:ntr-1,nsp));
        else
            fu_main_2010_ma.ATR(ntr,nsp) = fu_main_2010_ma.TR(ntr,nsp);
        end
    end
    fu_main_2010_ma.buyline(:,nsp) = fu_main_2010_ma.settle(:,nsp) + fu_main_2010_ma.ATR(:,nsp) * K;  %settle��ȡֵ��һ��� ��ATR��ȡֵ��һ�ٶൽ��ٶ�
    fu_main_2010_ma.sellline(:,nsp) = fu_main_2010_ma.settle(:,nsp) - fu_main_2010_ma.ATR(:,nsp) * K;
end    
save('C:\Users\bfyang.cephei\Desktop\CTA\data\daybar_20180204\data_gene\fu_main_2010_ma_ready.mat','-struct','fu_main_2010_ma');  % C:\Users\bfyang.cephei\Desktop\CTA\data\daybar_20180204\data_gene
end

















