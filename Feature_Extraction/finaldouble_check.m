function [ footIndex,  systolicIndex ] = finaldouble_check( Inwave, footIndex,  systolicIndex )

t=length(footIndex);
tt=length(Inwave);

if footIndex(1)<=10
    footIndex(1)=11;
end

for i=1:t
for j=1:10
    x(j)=Inwave(footIndex(i)+j-1);
     a1=find(min(x));
    y(j)=Inwave(footIndex(i)-j+1);
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
footIndex(i)=footIndex(i)+a1-1;
    
else
    footIndex(i)=footIndex(i)-a2+1;
    end
end



for k=1:t

for l=1:10
    x(l)=Inwave(systolicIndex(k)+l-1);
     
    y(l)=Inwave(systolicIndex(k)-l+1);
     
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
systolicIndex(k)=systolicIndex(k)+a1-1;
    
else
    systolicIndex(k)=systolicIndex(k)-a2+1;
    end
end   






