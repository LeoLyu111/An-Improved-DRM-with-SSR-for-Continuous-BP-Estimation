function [ footIndex, systolicIndex ] = double_check( Inwave, footIndex, systolicIndex )
t=length(footIndex);
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
tt=t-1;
for i=1:tt
    if footIndex(i)==footIndex(i+1)
        footIndex(i+1)=0;
    end
end
for i=1:tt
     if systolicIndex(i)==systolicIndex(i+1)
        systolicIndex(i+1)=0;
    end
end
 f_zero=find(footIndex==0);
 s_zero=find(systolicIndex==0);


    footIndex(f_zero)=[];
    systolicIndex(s_zero)=[];

end