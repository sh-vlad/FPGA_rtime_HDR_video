clc 
clear all

RGB1_in   = imread('../image_1.bmp','bmp');
RGB2_in   = imread('../image_2.bmp','bmp');
YCbCr1_in = rgb2ycbcr(RGB1_in);
YCbCr2_in = rgb2ycbcr(RGB2_in);
Y1  = YCbCr1_in(:,:,1);
Cb1 = YCbCr1_in(:,:,2);
Cr1 = YCbCr1_in(:,:,3);
Y2  = YCbCr2_in(:,:,1);
Cb2 = YCbCr2_in(:,:,2);
Cr2 = YCbCr2_in(:,:,3);

info=size(RGB1_in);
H=info(1);
W=info(2);

figure(1)
imshow(RGB1_in)
figure(2)
imshow(RGB2_in)

% decimation
for i=1:1:H
    k=1;
    for j=1:2:W
        Cb1_dec(i,k) = Cb1(i,j);
        Cr1_dec(i,k) = Cr1(i,j);
        Cb2_dec(i,k) = Cb2(i,j);
        Cr2_dec(i,k) = Cr2(i,j);
        k=k+1;
    end
end

fileY1  =fopen('Y1_comp.txt','wt'); % 
fileY2  =fopen('Y2_comp.txt','wt'); % 
fileCb1 =fopen('Cb1_comp.txt','wt'); % 
fileCb2 =fopen('Cb2_comp.txt','wt'); % 
fileCr1 =fopen('Cr1_comp.txt','wt'); % 
fileCr2 =fopen('Cr2_comp.txt','wt'); % 
for i=1:1:H
    for j=1:1:W/2
        fprintf(fileY1,'%x\n',Y1(i,2*j-1));
        fprintf(fileY1,'%x\n',Y1(i,2*j));
        fprintf(fileCb1,'%x\n',Cb1_dec(i,j));
        fprintf(fileCr1,'%x\n',Cb1_dec(i,j));
        
        fprintf(fileY2,'%x\n',Y2(i,2*j-1));
        fprintf(fileY2,'%x\n',Y2(i,2*j));
        fprintf(fileCb2,'%x\n',Cb2_dec(i,j));
        fprintf(fileCr2,'%x\n',Cb2_dec(i,j));
    end
end

