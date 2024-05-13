function [ RpeakIndex_ECG ] = ECG_check( Inwave, RpeakIndex_ECG )
t=length(RpeakIndex_ECG);
tt=length(Inwave);
g=10;
if RpeakIndex_ECG(t)+g>tt
    g=(tt-RpeakIndex_ECG(t));
end
for k=1:t
for l=1:g
    x(l)=Inwave(RpeakIndex_ECG(k)+l-1);
     
    y(l)=Inwave(RpeakIndex_ECG(k)-l+1);
     
end

a1=find(x==max(x));
a2=find(y==max(y));

if length(a1)>1
    a1=min(a1);
end
if length(a2)>1
    a2=min(a2);
end

    if x(a1)>=y(a2)
RpeakIndex_ECG(k)=RpeakIndex_ECG(k)+a1-1;
    
else
  RpeakIndex_ECG(k)=RpeakIndex_ECG(k)-a2+1;
    end
end
end