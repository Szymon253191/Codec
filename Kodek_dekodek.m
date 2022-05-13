%% DECOMPRESION

% read compressed file
acqFile = load('compressedPicture.JSR', '-mat');

% decoding Huffman
preDecY  = huffmandeco(acqFile.encY, acqFile.dicY);
preDecCb = huffmandeco(acqFile.encCb, acqFile.dicCb);
preDecCr = huffmandeco(acqFile.encCr, acqFile.dicCr);

decCb = zeros(H/2, W/2);
decCr = zeros(H/2, W/2);

decY = reshape(preDecY, W, H);
decCb = reshape(preDecCb, W/2, H/2);
decCr = reshape(preDecCr, W/2, H/2);

% deDCT for each color
decY = decY - 128;
decCb = decCb - 128;
decCr = decCr - 128;

postTempY = blkproc(decY, [8,8], 'x.*P1', lum);
postTempCb = blkproc(decCb, [8,8], 'x.*P1', chr);
postTempCr = blkproc(decCr, [8,8], 'x.*P1', chr);

postY = blkproc(postTempY, [8 8], 'idct2(x)');  
postCb = blkproc(postTempCb, [8 8], 'idct2(x)'); 
postCr = blkproc(postTempCr, [8 8], 'idct2(x)');

postY = postY/255;
postCb = postCb/255;
postCr = postCr/255;

% getting YCbCr image
YCbCrPostImg(:, :, 1) = postY;

for i=1:row/2 -1
   for j=1:col/2 -1
       YCbCrPostImg(2*i - 1, 2*j - 1, 2) = postCb(i, j);
       YCbCrPostImg(2*i - 1, 2*j,     2) = postCb(i, j);
       YCbCrPostImg(2*i, 2*j - 1, 2) = postCb(i, j);
       YCbCrPostImg(2*i, 2*j,     2) = postCb(i, j); 
       
       YCbCrPostImg(2*i - 1, 2*j - 1, 3) = postCr(i, j);
       YCbCrPostImg(2*i - 1, 2*j,     3) = postCr(i, j);
       YCbCrPostImg(2*i, 2*j - 1, 3) = postCr(i, j);
       YCbCrPostImg(2*i, 2*j,     3) = postCr(i, j);
   end
end

% YCbCr -> RGB
outImg = ycbcr2rgb(YCbCrPostImg);

toc
%% DISPLAY RESULTS

figure(1)

subplot(1, 2, 1);
imshow(inImg);
title('Oryginalny obraz'); 

subplot(1, 2, 2);
imshow(outImg);
title('Obraz wyjściowy');

imwrite(outImg, 'out.png')

A = imread('out.png');

X = immse(A, inImg);
disp(strcat(['Wartość błędu średniokwadratowego wynosi: ' num2str(X)]));