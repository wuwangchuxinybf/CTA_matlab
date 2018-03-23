function [UpperLine,MiddleLine,LowerLine] = BOLL(Price,Length,Width,Type)
% Price,���̼�
% Length���ƶ�ƽ���ĳ��ȣ�����20
% Width�����¹�Ŀ�ȣ������ٸ���׼�����2
% Type �����ƶ�ƽ��ֵ�����ͣ�0Ϊ���ƶ�ƽ����1Ϊָ���ƶ�ƽ����Ĭ��Ϊ0

% [UpperLine,MiddleLine,LowerLine] = BOLL(Price,Length,Width,Type)

% Price = Close;
% Length = 50;
% Width = 1.25;
% Type = 0;

if nargin==3
    Type=0;
end
MiddleLine = zeros(length(Price),1);
UpperLine = zeros(length(Price),1);
LowerLine = zeros(length(Price),1);

if Type==0
    MiddleLine=MA(Price,Length);
    UpperLine(1:Length-1) = MiddleLine(1:Length-1);
    LowerLine(1:Length-1) = MiddleLine(1:Length-1);
    for i = Length:length(Price)
        UpperLine(i) = MiddleLine(i) + Width*std(Price(i-Length+1:i));
        LowerLine(i) = MiddleLine(i) - Width*std(Price(i-Length+1:i));
    end
end

if Type ==1
    MiddleLine=EMA(Price,Length);
    UpperLine(1:Length-1) = MiddleLine(1:Length-1);
    LowerLine(1:Length-1) = MiddleLine(1:Length-1);
    for i = Length:length(Price)
        StanDev(i) = sqrt(sum((Price(i-Length+1:i)-MiddleLine(i)).^2)/Length);
        UpperLine(i) = MiddleLine(i) + StanDev(i);
        LowerLine(i) = MiddleLine(i) - StanDev(i);
    end
end
end

