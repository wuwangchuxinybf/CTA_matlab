function [] = main_contr(field_name,percent_fn,end_tdate)
%������Լ�䶯����
% 1���ڵ�һ�������գ��Ե���ĳһ�ֶ����ĺ�Լ��Ϊ��Ʒ�ֵ�������Լ����oiΪ����
% 2���ں�ߵ�ĳһ�����գ����ȼ��㵱��oi���ĺ�Լ�����Ҵ���������յĺ�Լ������Ϊ������Լ��
%   ����ú�Լ�����һ������������Լ���䣬����������Լ���䣻 ...(1)
%   ����ú�Լ�����һ������������Լ�����仯����ô�����Ƚϸú�Լ��oi�����ǰ������Լ���յ�oi��
%       ������1.1�����ϣ���
%           ����ú�Լ��֮ǰδ����������Լ�����Ըú�Լ��Ϊ���յ�������Լ����������ԼΪֻ����£�...(2)
%           ����ú�Լ��֮ǰ����������Լ�����Ե���oi�ڶ���ĺ�Լ��Ϊ���ո���Ʒ��������Լ��...(3)
%       ��С�ڵ���1.1����������һ�����յ�������Լ��Ϊ���յ�������Լ   ...(4)
% ����  (1)��(2)�Ե�������oi�ĺ�Լ��Ϊ������Լ��
%       (3)�Ե���oi�ڶ���ĺ�Լ��Ϊ������Լ��
%       (4)����һ������������Լ��Ϊ����������Լ��

% field_name��ʾ�Ե��ո��ֶ����ĺ�Լ��Ϊ��Ʒ�ֵ�������Լ��
% percent_fn����ʾ�����һ���oi����ǰһ���ĳһ�ٷֱȣ�����10%�����ڣ�������Լ���䣻
% end_tdate,��ʾ����������Լ���еĽ�ֹ�������ڣ�

% field_name = 'oi'
% percent_fn = 0.1
% end_tdate = '2018-02-04'

%% ÿ�����oiȷ��������Լ
fu_str=load('fu_str.mat');
fln = fieldnames(fu_str);
be_str=load('be_str.mat');
% ����ÿ����Լ�����ڶ��������գ�����������������Լȷ��
for codenum=1:numel(fu_str.Ticker)
    mid_bldate = fu_str.tradedate(find(fu_str.NTradeDate==datenum(be_str.end_date(strcmp(be_str.code,fu_str.Ticker{codenum}))))-1);
    if ~isempty(mid_bldate)
        fu_str.Before_LDate(codenum) = mid_bldate;
    else  % ��һЩ��Լû����StartDate��LastDate֮������еĽ���������
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
% ��ʼ��fu_main
for fm=[18,1,5:17,19:length(fln)]
    if ismember(fm,[1,5,6,23,24])
        fu_main.(fln{fm}) = cell(t_num,length(species));
    else
        fu_main.(fln{fm}) = NaN(t_num,length(species));
    end
end
% ����������Լ���ֶ�ȡֵ
nn=1;
for spn=1:length(species)   %species
    tic
    fu_main.sp(1,spn) = species(spn);    
    for fnn=[18,1,5:17,19:length(fln2)]
        fu_mid.(fln2{fnn}) = fu_str.(fln2{fnn})(:,strcmp(fu_str.sp ,species{spn}));
    end
     % RU���Ʒ����'1995-12-15'��'1996-01-11','1996-08-16'��{'1997-04-11'û�н�������,�򵥴�����
    if spn ==37
        start_min = 492; 
    else
        start_min = find(fu_str.tradedate == min(fu_mid.StartDate));
    end
%     end_max = find(fu_str.tradedate == max(fu_mid.LastDate));  %֮ǰ��max(fu_mid.StartDate)
    end_max = find(fu_str.NTradeDate <= datenum(end_tdate),1,'last' ); %��������Ľ�ֹ����֮ǰ����Ľ�����
    for rn=start_min:end_max
        if ~all(isnan(fu_mid.oi(rn,:))) 
%             % ���oi
%             [max_val,index_mid] = max(fu_mid.(field_name)(rn,:),[],2);
%             % �ڶ���oi
%             mid_fn = fu_mid.(field_name);
%             mid_fn(rn,mid_fn(rn,:) == max(mid_fn(rn,:))) = min(mid_fn(rn,:));
%             [~,index_mid2] = max(mid_fn(rn,:),[],2);
            % ���oi,ԭ���ķ�ʽ���޳���ǰ���ticker��������λ���ò�����ȷ��������Լ�������ꣻ
            earlier_td = datenum(fu_main.tradedate(rn,1))<=cellfun(@datenum,fu_mid.Before_LDate); %������Լ���������һ��������  
            [max_val,index_mid_s] = max(fu_mid.(field_name)(rn,earlier_td),[],2);
            mid_Ticker = fu_mid.Ticker(:,earlier_td);
            index_mid = find(strcmp(mid_Ticker(1,index_mid_s),fu_mid.Ticker(1,:)));
            % �ڶ���oi
            mid_fn = fu_mid;
%             mid_fn(rn,mid_fn(rn,earlier_td) == max(mid_fn(rn,earlier_td))) = min(mid_fn(rn,earlier_td));
            mid_fn.(field_name)(rn,index_mid) = 0;
            [~,index_mid_2s] = max(mid_fn.(field_name)(rn,earlier_td),[],2);
            mid_Ticker2 = mid_fn.Ticker(:,earlier_td);
            index_mid2 = find(strcmp(mid_Ticker2(1,index_mid_2s),mid_fn.Ticker(1,:)));
 
            if  (((rn>start_min+1) && any(strcmp(fu_mid.Ticker(1,index_mid),fu_main.Ticker(1:rn-2,spn)))) || (rn==(start_min+1)))&& ... %��ʷ���ֹ� 
                  (~strcmp(fu_mid.Ticker(1,index_mid),fu_main.Ticker(rn-1,spn))) && ...  %�ֲ������ĺ�Լ�����仯
                    ( max_val>((fu_mid.(field_name)(rn,strcmp(fu_mid.Ticker(1,:),fu_main.Ticker(rn-1,spn))))*(1+ percent_fn))) %oi����1.1��
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
                 (~strcmp(fu_mid.Ticker(1,index_mid),fu_main.Ticker(rn-1,spn))) && ...  %�ֲ������ĺ�Լ�����仯
                    ( max_val<= ((fu_mid.(field_name)(rn,strcmp(fu_mid.Ticker(1,:),fu_main.Ticker(rn-1,spn))))*(1+ percent_fn)))  %oiС�ڵ���1.1��
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
