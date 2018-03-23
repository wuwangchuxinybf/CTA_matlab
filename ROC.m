function ROCValue = ROC(Price,Length)
ROCValue = zeros(length(Price),1);
ROCValue(Length+1:end)=(Price(Length+1:end)-Price(1:end-Length))./Price(1:end-Length)*100;
end

