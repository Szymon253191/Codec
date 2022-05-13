%% ENVIRONMENT PREPERATION

clear;
clc;
close all;

%% PICTURE PREPREATION
tic
inImg = imread("kitku.jpg");

% RGB -> YCbCr
convColImg = rgb2ycbcr(inImg);
[H, W, C] = size(convColImg);

%% COMPRESSION

% 8x8 cut prep
row = ceil(H/8) * 8;
col = ceil(W/8) * 8;

% color coding
Y = double(convColImg(:,:, 1));
Cb = double(zeros(row/2, col/2));
Cr = double(zeros(row/2, col/2));

for i = 1 : row/2
   for j = 1 : 2 : (col/2) - 1
      Cb(i, j) = double(convColImg(i * 2 - 1, j * 2 - 1, 2));
      Cr(i, j) = double(convColImg(i * 2 - 1, j * 2, 3)); 
   end
   for j = 2 : 2 : col/2
      Cb(i, j) = double(convColImg(i * 2 - 1, j * 2 - 2, 2));
      Cr(i, j) = double(convColImg(i * 2 - 1, j * 2, 3)); 
   end
end

% lum&chrom
lum = [ 16  11  10  16   24   40    51  61
        12  12  14  19   26   58   60   55
        14  13  16  24   40   57   69   56
        14  17  22  29   51   87   80   62
        18  22  37  56   68  109  103   77
        24  35  55  64   81  104  113   92
        49  64  78  87  103  121  120  101
        72  92  95  98  112  100  103   99 ];
    
chr = [ 17,  18,  24,  47,  99,  99,  99,  99;
        18,  21,  26,  66,  99,  99,  99,  99;
        24,  26,  56,  99,  99,  99,  99,  99;
        47,  66,  99,  99,  99,  99,  99,  99;
        99,  99,  99,  99,  99,  99,  99,  99;
        99,  99,  99,  99,  99,  99,  99,  99;
        99,  99,  99,  99,  99,  99,  99,  99;
        99,  99,  99,  99,  99,  99,  99,  99 ];
    
% DCT separatly
YDCT = blkproc(Y, [8 8], 'dct2(x)');
CbDCT = blkproc(Cb, [8 8], 'dct2(x)');
CrDCT = blkproc(Cr, [8 8], 'dct2(x)');

YDCT = blkproc(YDCT, [8 8], 'round(x./P1)', lum);  YDCT = YDCT + 128;
CbDCT = blkproc(CbDCT, [8 8], 'round(x./P1)', chr); CbDCT = CbDCT + 128;
CrDCT = blkproc(CrDCT, [8 8], 'round(x./P1)', chr); CrDCT = CrDCT + 128;

% Huffman for each color
Hy = floor(YDCT(:));
Hcb = floor(CbDCT(:));
Hcr = floor(CrDCT(:));

[Xy, Yy] = size(Y);
[Xcb, Ycb] = size(Cb);
[Xcr, Ycr] = size(Cr);

H1y = floor(YDCT(:));
H2y = zeros(1, 256);
H1cb = floor(CbDCT(:));
H2cb = zeros(1, 256);
H1cr = floor(CrDCT(:));
H2cr = zeros(1, 256);
k = 0:255;

for i = 1:256
   P1(i) = length(find(H1y == i - 1))/(Xy * Yy);
   P2(i) = length(find(H1cb == i - 1))/(Xcb * Ycb); 
   P3(i) = length(find(H1cr == i - 1))/(Xcr * Ycr); 
end

% dictionary
dicY = huffmandict(k, P1);
dicCb = huffmandict(k, P2);
dicCr = huffmandict(k, P3);

encY = huffmanenco(Hy,dicY);
encCb = huffmanenco(Hcb,dicCb);
encCr = huffmanenco(Hcr,dicCr);

% save compressed file
save('compressedPicture.JSR', 'dicY', 'encY', 'dicCb', 'encCb', 'dicCr', 'encCr', '-mat');