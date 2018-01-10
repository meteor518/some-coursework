figure(2);
%读入原水印图片
I=imread('a.png');
I=im2bw(I);
%读取原始语音
audio = audioread('open-cc.wav'); 
A=audio(1:160000);
%读取含水印音频
[A1,fs]=audioread('new.wav'); 
AL=length(A1);
%绘制音频图： 
subplot(211);plot(A1); 
axis([0,160000,-1,1]);
title('含水印音频信号');
%{
%加入攻击
%0 未攻击
%1 加入高斯噪声
A1=awgn(A1,70);
%2 重采样
A1=resample(A1,22050,fs);
A1=resample(A1,fs,22050);
%3 进行低通滤波
% [B1,B2]=butter(1,3/4,'low');
% A1=filter(B1,B2,A1);
%}

%对音频进行2级小波分解：  
[c,l]=wavedec(A1,2,'haar');     
%提取2级小波分解的低频（高能量）高频（低能量）： 
ca2=appcoef(c,l,'haar',2); 
cd2=detcoef(c,l,2); 
cd1=detcoef(c,l,1); 
ca2L=length(ca2); 

%DCT变换
ca2DCT=dct(ca2);

k=100;      %段数
DL=ca2L/k;  %ca2每段的长度
j=1;
delta=0.5;
%分段提取水印信息
for i=1:k
    ca22=ca2DCT(j:j+DL-1);
    Y=ca22(1:DL/4);         %提取每段前1/4系数
    Y=reshape(Y,10,10);
    
    [U,S,V]=svd(Y);         %进行SVD变换
    S1=S(1,1);
    S2=S(2,2);
    D=round(S1/(S2*delta)); %判别式
    %根据判别式的奇偶性提取水印
    if(mod(D,2)==0)
        water(i)=0;
    else                                      
        water(i)=1;
    end  
    j=j+DL;
end
%将一维数据恢复成二维图像
for i=1:10
    for j=1:10
        p=j+10*(i-1);
        J(i,j)=water(p);
    end
end
subplot(212);imshow(J);
title('提取的水印图像');
imwrite(J,'b.png');

%评价指标
%0 峰值信噪比PSNR
AA = A.*A;
maxAA=max(AA);
Dist = A1-A;
sum=0;
for i=1:AL
    DAA1=Dist(i)*Dist(i);
    sum=sum+DAA1;
end
psnr = 10*log10(maxAA/sum);
%1 误码率BER
eber=0;
for i=1:10
    for j=1:10
        if I(i,j)==J(i,j)
        else
            eber=eber+1;
        end
    end
end
ber=eber/100;
%2 归一化系数NC
IJ = I.*J;
II = I.*I;
JJ=J.*J;
sumII=0;
sumIJ=0;
sumJJ=0;
for i=1:10
    for j=1:10
        sumII=sumII+II(i,j);
        sumIJ=sumIJ+IJ(i,j);
        sumJJ=sumJJ+JJ(i,j);
    end
end
nc=sumIJ/(sqrt(sumII)*sqrt(sumJJ));