%读取原始语音
[audio,fs]=audioread('open-cc.wav'); 
A=audio(1:160000);
AL=length(A);
%绘制原始音频图： 
subplot(312);plot(A); 
title('原始音频信号'); 

%读入水印图片
I=imread('a.png');
I=im2bw(I);
subplot(311);imshow(I); 
title('水印图像');
[m,n]=size(I);
%将图片降维 
piexnum=1;
for i=1:m
    for j=1:n
        w(piexnum,1)=I(i,j);
        piexnum=piexnum+1;
    end
end
wl=size(w);

%对原音频进行2级小波分解：  
[c,l]=wavedec(A,2,'haar');     
%提取2级小波分解的低频（高能量）高频（低能量）： 
ca2=appcoef(c,l,'haar',2); 
cd2=detcoef(c,l,2); 
cd1=detcoef(c,l,1); 
ca2L=length(ca2); 

%DCT变换
ca2DCT=dct(ca2);
%分段
k=wl(1);   %段数
DL=ca2L/k;  %ca2每段的长度
j=1;
delta=0.5;
%分段进行水印嵌入
for i=1:k
    ca22=ca2DCT(j:j+DL-1);
    Y=ca22(1:DL/4);        %提取前1/4系数
    Y=reshape(Y,10,10);
    
    [U,S,V]=svd(Y);        %SVD分解
    S1=S(1,1);
    S2=S(2,2);
    D=floor(S1/(S2*delta)); %判别式
    %根据D的奇偶性进行水印嵌入
    if(mod(D,2)==0)
        if (w(i)==1)                                       
            S(1,1)=S(2,2)*delta*(D+1);  
        else   
            S(1,1)=S(2,2)*delta*D;  
        end  
    else                                   
        if (w(i)==1)  
            S(1,1)=S(2,2)*delta*D; 
        else  
            S(1,1)=S(2,2)*delta*(D+1);  
        end  
    end  
    Y11=U*S*V';              %SVD 逆变换还原  
    Y1=reshape(Y11,100,1);
    ca22(1:100)=Y1(1:100);
    ca2DCTnew(j:j+DL-1)=ca22;%用嵌入水印后的系数替换原来的前1/4系数
    j=j+DL;
end
%IDCT
ca2new=idct(ca2DCTnew');
%IDWT
c1=[ca2new',cd2',cd1'];
Anew=waverec(c1',l,'haar');
audiowrite('new.wav',Anew,fs); %保存嵌入水印后的音频
subplot(313);plot(Anew);       %显示嵌入水印后的音频
title('嵌入水印的音频')