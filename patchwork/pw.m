function [iswater]=pw(d) 
%%% d �����޸�ֵ  
%%% iswater ������ȡ��ˮӡ��Ϣ 

%%%%%%%%%%%%%%%% ����ԭʼ����ͼ�� %%%%%%%%%%%%%%%%%%%%%%%%%%% 
I=imread('lenna.bmp'); 
I=rgb2gray(I);
[m,n]=size(I); 
subplot(221),imshow(I); title('ԭʼͼ��'); 
h=imhist(I);
subplot(223),bar(h),title('ԭͼ��ֱ��ͼ');
%%%%%%%%%%%%%%%% Ƕ��ˮӡ��Ϣ %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
I1=double(I); 
for i=1:m 
    for j=1:n 
        if mod(i+j,2)==0 
            I1(i,j)=I1(i,j)+d;
            if(I1(i,j)>255)
                I1(i,j)=255;
            end
        else 
            I1(i,j)=I1(i,j)-d; 
            if(I1(i,j)<0)
                I1(i,j)=0;
            end
        end 
    end 
end 
imwrite(uint8(I1),'lenna_watermarked.bmp'); 
subplot(222),imshow(uint8(I1)); title('Ƕ��ˮӡͼ��');
h1=imhist(uint8(I1));
subplot(224),bar(h1),title('Ƕ��ˮӡ���ֱ��ͼ');
%%%%%%%%%%%%%%%%%%%%% ˮӡ��ȡ %%%%%%%%%%%%%%%%% 
threshold=0.5;
I2=imread('lenna_watermarked.bmp');
I2=double(I2);
A=0; 
B=0;
num=m*n/2;
for i=1:m 
    for j=1:n 
        if mod(i+j,2)==0 
            A=A+I2(i,j);
        else
            B=B+I2(i,j);
        end
    end
end
A=A/num;
B=B/num;
dist=abs(A-B);
if(dist>threshold)
    iswater=1;
else
    iswater=0;
end