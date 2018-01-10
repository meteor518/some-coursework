I=imread('3.jpg');
I=rgb2gray(I);
imshow(I);
hold on;
I=double(I);
I=I/255;
[m,n]=size(I);
%----求图像的属性函数---%

G = fspecial('gaussian',ceil(3), 1);
GI = filter2(G,I,'same'); %高斯函数与图像卷积  滤波
%---求卷积后GI的梯度 利用中心差分---%
GIx1 = GI(:,[2:n,n]);  %补右边界
GIx0 = GI(:,[1,1:n-1]);%补左边界
Gx = (GIx1-GIx0)/2;    %对x的偏导

GIy1 = GI([2:m,m],:);  %补下边界
GIy0 = GI([1,1:m-1],:);%补上边界
Gy = (GIy1-GIy0)/2;    %对y的偏导
g = 1./(1+5*(Gx.^2+Gy.^2));%属性函数
%---再求属性函数的梯度 利用中心差分---%
gx = (g(:,[2:n,n])-g(:,[1,1:n-1]))/2;
gy = (g([2:m,m],:)-g([1,1:m-1],:))/2;

%---定义一个圆----
r=min(m,n)/2-40;
x0=n/2;
y0=m/2;
Num=20;%圆上点数
for i=1:Num
    x(i)=x0+r*cos(i*2*pi/Num); %圆上各点坐标
    y(i)=y0+r*sin(i*2*pi/Num);
    plot(x(i),y(i),'ro');
end
plot(x,y,'Linewidth',2);

%---对曲线求导迭代更新----%
t=1;  %t为迭代次数
while t<1000
    clf;
    imshow(I);hold on;
    %---先求曲率k，导数同样利用差分进行计算---%
    dx = ([x(2:Num),x(1)]-[x(Num),x(1:Num-1)])/2;
    dy = ([y(2:Num),y(1)]-[y(Num),y(1:Num-1)])/2;
    dxx= [x(2:Num),x(1)]-2.*x+[x(Num),x(1:Num-1)];
    dyy= [y(2:Num),y(1)]-2.*y+[y(Num),y(1:Num-1)];

    k =(dx.*dyy - dy.*dxx)./(dx.^2 +dy.^2).^1.5;
    %---再求法向量---%
    Nx = -dy./sqrt(dx.^2+dy.^2);
    Ny = dx./sqrt(dx.^2+dy.^2);
 
    for i=1:Num
        %---g函数梯度与法向量的内积---%
        gx1=gx(round(y(i)),round(x(i)));
        gy1=gy(round(y(i)),round(x(i)));
        g1=g(round(y(i)),round(x(i)));
     
        neiji=dot([gx1 gy1],[Nx(i) Ny(i)]);
        x(i)=x(i)+20*(g1*k(i)*Nx(i)-neiji*Nx(i));
        y(i)=y(i)+20*(g1*k(i)*Ny(i)-neiji*Ny(i));
        plot(x(i),y(i),'ro');
    end
    plot(x,y,'Linewidth',2);
    t=t+1;
    pause(0.1);
end