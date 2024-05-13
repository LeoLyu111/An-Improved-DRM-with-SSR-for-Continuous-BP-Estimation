function [ dicroticIndex,  notchIndex ] = finaldouble_check2( Inwave, dicroticIndex,  notchIndex )

t=length(notchIndex);
tt=length(Inwave);
g=15;
if dicroticIndex(t)+g>tt
    dicroticIndex(t)=tt-g-1;
    notchIndex(t)=dicroticIndex(t);
end


for i=1:t
for j=1:15
    x(j)=Inwave(notchIndex(i)+j-1);
     a1=find(min(x));
    y(j)=Inwave(notchIndex(i)-j+1);
     a2=find(min(y));
end

a1=find(x==min(x));
a2=find(y==min(y));

if length(a1)>1
    a1=min(a1);
end
if length(a2)>1
    a2=min(a2);
end

    if x(a1)<=y(a2)
notchIndex(i)=notchIndex(i)+a1-1;
    
    else
        notchIndex(i)=notchIndex(i)-a2+1;
    end
end



for k=1:t

for l=1:15
    x(l)=Inwave(dicroticIndex(k)+l-1);
     
   
     
end

a1=find(x==max(x));


if length(a1)>1
    a1=min(a1);
end


    
dicroticIndex(k)=dicroticIndex(k)+a1-1;
    

end   