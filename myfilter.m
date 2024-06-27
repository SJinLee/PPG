function yyy = myfilter(x)
    mm = length(x);
    yyy = zeros(1,length(x));
    
    %-------   FIR 16degree Filter   ---------------------
    yyy(1)=0.0625*x(1);
    for n=2:15 
        yyy(n)=0.0625*x(n);
        for k=1:n-1
        yyy(n)= yyy(n)+0.0625*x(n-k);
        end
    end
    for n=16:mm 
    yyy(n)=0.0625*(x(n)+x(n-1)+x(n-2)+x(n-3)+x(n-4)+x(n-5)+x(n-6)+x(n-7)...
        +x(n-8)+x(n-9)+x(n-10)+x(n-11)+x(n-12)+x(n-13)+x(n-14)+x(n-15)); 
end
