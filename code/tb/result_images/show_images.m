clc 
clear all
H=720;
W=1280;
Y1_matrix=zeros(H,W,'uint8');
Cb1_matrix=zeros(H,W,'uint8');
Cr1_matrix=zeros(H,W,'uint8');

Y2_matrix=zeros(H,W,'uint8');
Cb2_matrix=zeros(H,W,'uint8');
Cr2_matrix=zeros(H,W,'uint8');
Y1_vector  =csvread('Y1_comp_out.txt')';
Cb1_vector =csvread('Cb1_comp_out.txt')';
Cr1_vector =csvread('Cr1_comp_out.txt')';

Y2_vector  =csvread('Y2_comp_out.txt')';
Cb2_vector =csvread('Cb2_comp_out.txt')';
Cr2_vector =csvread('Cr2_comp_out.txt')';
for i=1:1:H
	k=1;
	for j=1:1:W/2	
		Y1_matrix(i,k)     = Y1_vector(2*j -1 +(i-1)*W);
		Y1_matrix(i,k+1)     = Y1_vector(2*j  +(i-1)*W);
		
		Y2_matrix(i,k)     = Y2_vector(2*j -1 +(i-1)*W);
		Y2_matrix(i,k+1)     = Y2_vector(2*j  +(i-1)*W);

		Cb1_matrix(i,k)   = Cb1_vector(j +(i-1)*W/2);
		Cb1_matrix(i,k+1) = Cb1_vector(j +(i-1)*W/2);
		
		Cb2_matrix(i,k)   = Cb2_vector(j + (i-1)*W/2);
		Cb2_matrix(i,k+1) = Cb2_vector(j +(i-1)*W/2);
		
		Cr1_matrix(i,k)   = Cr1_vector(j +(i-1)*W/2);
		Cr1_matrix(i,k+1) = Cr1_vector(j +(i-1)*W/2);
		
		Cr2_matrix(i,k)   = Cr2_vector(j +(i-1)*W/2);
		Cr2_matrix(i,k+1) = Cr2_vector(j +(i-1)*W/2);
		k=k+2;
	end
end
YCbCr_result_1 = cat(3, Y1_matrix, Cb1_matrix, Cr1_matrix);	
YCbCr_result_2 = cat(3, Y2_matrix, Cb2_matrix, Cr2_matrix);	
RGB_result_1 = ycbcr2rgb(YCbCr_result_1);
RGB_result_2 = ycbcr2rgb(YCbCr_result_2);
figure(1)
imshow(RGB_result_1);
figure(2)
imshow(RGB_result_2);


%%% compare image before and after convert2avl_stream %%% 
image1_in=imread('../test_images/image_1.bmp','bmp');
image2_in=imread('../test_images/image_2.bmp','bmp');

R1_in=image1_in(:,:,1);
G1_in=image1_in(:,:,2);
B1_in=image1_in(:,:,3);

R2_in=image2_in(:,:,1);
G2_in=image2_in(:,:,2);
B2_in=image2_in(:,:,3);

R1_out=RGB_result_1(:,:,1);
G1_out=RGB_result_1(:,:,2);
B1_out=RGB_result_1(:,:,3);

R2_out=RGB_result_2(:,:,1);
G2_out=RGB_result_2(:,:,2);
B2_out=RGB_result_2(:,:,3);

sub_r1=R1_in-R1_out;
sub_g1=G1_in-G1_out;
sub_b1=B1_in-B1_out;

sub_r2=R2_in-R2_out;
sub_g2=G2_in-G2_out;
sub_b2=B2_in-B2_out;

PSNR_r=10*log10(H*W*255^2/(sum(sub_r1(:).^2)))
PSNR_g=10*log10(H*W*255^2/(sum(sub_g1(:).^2)))
PSNR_b=10*log10(H*W*255^2/(sum(sub_b1(:).^2)))
