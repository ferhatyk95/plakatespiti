function plakaTanimaUygulamasi2
    % Uygulama figürü ve bileşenlerin oluşturulması
    f = figure('Visible','off','Position',[360,500,450,285]);

    % Resim seçme düğmesi
    selectButton = uicontrol('Style','pushbutton','String','Resim Seç',...
        'Position',[315,220,70,25],...
        'Callback',@selectButton_Callback);

    % Sonuç metni kutusu
    resultText = uicontrol('Style','text','Position',[325,180,120,25]);

    % Seçilen resmin görüntüsü
    axesHandle = axes('Units','Pixels','Position',[50,60,200,185]);

    % Uygulama figürünü görünür yapma
    f.Visible = 'on';

    % Resim seçme düğmesine tıklandığında çalışacak fonksiyon
    function selectButton_Callback(source, event)
        % Resim seçme işlemi
        [fileName, filePath] = uigetfile({'*.jpg';'*.png';'*.jpeg';'*.bmp'}, 'Resim Seç');
        
        if ~isequal(fileName, 0)
            % Seçilen resmi oku
            I = imread(fullfile(filePath, fileName));
            
            % Resmi göster
            imshow(I, 'Parent', axesHandle);

            % Plaka tanıma işlemi
            [recognizedText, ~] = plakaTanimla(I);

            % Sonuç metnini görüntüle
            set(resultText, 'String', recognizedText);
        end
    end
end

function [recognizedText, ~] = plakaTanimla(I)
    %bu kod alınan görüntünün plakasını ayrıştırır okur bunu txt dostyasına
%yazar sonra ise bunu açıp ekrana gösterir

clc; % Komut penceresini temizle.

clear all; % Tüm değişkenleri sil.

close all; % imtool tarafından oluşturulanlar dışındaki tüm figür pencerelerini kapat.

imtool close all; % imtool ile oluşturulan tüm figür pencerelerini kapat.

workspace; % İş alanı panelinin görüntülendiğinden emin ol.

% Resmi Oku

I = imread('ozelplaka.jpg');

figure(1);
imshow(I);

% Gri Bileşeni Çıkar (Bir Görüntüyü Griye Dönüştür)

Igray = rgb2gray(I);

[rows, cols] = size(Igray);

%% Gürültüyü Kaldırmak için Görüntüyü Genişlet ve Erode Et

Idilate = Igray;

for i = 1:rows
    for j = 2:cols-1
        temp = max(Igray(i,j-1), Igray(i,j));
        Idilate(i,j) = max(temp, Igray(i,j+1));
    end
end
I = Idilate;

figure(2);
imshow(Igray);

figure(3);
title('Genişletilmiş Görüntü')
imshow(Idilate);

figure(4);
imshow(I);

difference = 0;
sum = 0;
total_sum = 0;
difference = uint32(difference);

%% YATAY YÖNDE KENARLARI İŞLE

disp('Yatay Kenarlar İşleniyor...');

max_horz = 0;
maximum = 0;

for i = 2:cols
    sum = 0;
    for j = 2:rows
        if(I(j, i) > I(j-1, i))
            difference = uint32(I(j, i) - I(j-1, i));
        else
            difference = uint32(I(j-1, i) - I(j, i));
        end
        if(difference > 20)
            sum = sum + difference;
        end
    end
    horz1(i) = sum;
    
    % Tepe Değerini Bul
    if(sum > maximum)
        max_horz = i;
        maximum = sum;
    end
    total_sum = total_sum + sum;
end

average = total_sum / cols;

figure(5);
% Analiz için Histogramı Çizdir

subplot(3,1,1);
plot(horz1);
title('Yatay Kenar İşleme Histogramı');
xlabel('Sütun Numarası ->');
ylabel('Fark ->');

%% Düşük Geçiş Filtresi Uygulayarak Yatay Histogramı Düzleştir

sum = 0;
horz = horz1;

for i = 21:(cols-21)
    sum = 0;
    for j = (i-20):(i+20)
        sum = sum + horz1(j);
    end
    horz(i) = sum / 41;
end

subplot(3,1,2);
plot(horz);
title('Düşük Geçiş Filtresinden Geçtikten Sonra Histogram');
xlabel('Sütun Numarası ->');
ylabel('Fark ->');

%% Dinamik Eşikleme ile Yatay Histogram Değerlerini Filtrele

disp('Yatay Histogram Filtreleniyor...');

for i = 1:cols
    if(horz(i) < average)
        horz(i) = 0;
        for j = 1:rows
            I(j, i) = 0;
        end
    end
end

subplot(3,1,3);
plot(horz);
title('Filtreden Sonra Histogram');
xlabel('Sütun Numarası ->');
ylabel('Fark ->');

%% DİKEY YÖNDE KENARLARI İŞLE

difference = 0;
total_sum = 0;
difference = uint32(difference);

disp('Dikey Kenarlar İşleniyor...');

maximum = 0;
max_vert = 0;

for i = 2:rows
    sum = 0;
    for j = 2:cols %cols
        if(I(i, j) > I(i, j-1))
            difference = uint32(I(i, j) - I(i, j-1));
        end
        if(I(i, j) <= I(i, j-1))
            difference = uint32(I(i, j-1) - I(i, j));
        end
        if(difference > 20)
            sum = sum + difference;
        end
    end
    vert1(i) = sum;
    
    %% Dikey Histogramda Tepe Değerini Bul
    
    if(sum > maximum)
        max_vert = i;
        maximum = sum;
    end
    total_sum = total_sum + sum;
end

average = total_sum / rows;

figure(6);
subplot(3,1,1);
plot(vert1);
title('Dikey Kenar İşleme Histogramı');
xlabel('Satır Numarası ->');
ylabel('Fark ->');

%% Düşük Geçiş Filtresi Uygulayarak Dikey Histogramı Düzleştir

disp('Düşük Geçiş Filtresinden Geçirme Dikey Histogram...');

sum = 0;
vert = vert1;

for i = 21:(rows-21)
    sum = 0;
    for j = (i-20):(i+20)
        sum = sum + vert1(j);
    end
    vert(i) = sum / 41;
end

subplot(3,1,2);
plot(vert);
title('Düşük Geçiş Filtresinden Geçtikten Sonra Histogram');
xlabel('Satır Numarası ->');
ylabel('Fark ->');

%% Dinamik Eşikleme ile Dikey Histogram Değerlerini Filtrele

disp('Dikey Histogram Filtreleniyor...');

for i = 1:rows
    if(vert(i) < average)
        vert(i) = 0;
        for j = 1:cols
            I(i, j) = 0;
        end
    end
end

subplot(3,1,3);
plot(vert);
title('Filtreden Sonra Histogram');
xlabel('Satır Numarası ->');
ylabel('Fark ->');

figure(7), imshow(I);

%% Plaka Adaylarını Bul

j = 1;

for i = 2:cols-2
    if(horz(i) ~= 0 && horz(i-1) == 0 && horz(i+1) == 0)
        column(j) = i;
        column(j+1) = i;
        j = j + 2;
    elseif((horz(i) ~= 0 && horz(i-1) == 0) || (horz(i) ~= 0 && horz(i+1) == 0))
        column(j) = i;
        j = j+1;
    end
end

j = 1;

for i = 2:rows-2
    if(vert(i) ~= 0 && vert(i-1) == 0 && vert(i+1) == 0)
        row(j) = i;
        row(j+1) = i;
        j = j + 2;
    elseif((vert(i) ~= 0 && vert(i-1) == 0) || (vert(i) ~= 0 && vert(i+1) == 0))
        row(j) = i;
        j = j+1;
    end
end

[temp, column_size] = size(column);

if(mod(column_size, 2))
    column(column_size+1) = cols;
end

[temp, row_size] = size(row);

if(mod(row_size, 2))
    row(row_size+1) = rows;
end

%% Plaka Bölgesini Çıkar

% Her bir olası adayı kontrol et

for i = 1:2:row_size
    for j = 1:2:column_size
        % Eğer en muhtemel bölge değilse, resimden kaldır
        if(~((max_horz >= column(j) && max_horz <= column(j+1)) && (max_vert >=row(i) && max_vert <= row(i+1))))
            % Bu döngü yalnızca kullanıcıya doğru çıktıyı göstermek içindir
            for m = row(i):row(i+1)
                for n = column(j):column(j+1)
                    I(m, n) = 0;
                end
            end
        end
    end
end

figure(8), imshow(I);

imshow(I);
title('Orjinal Görüntü');

% OCR nesnesini oluştur
ocrResults = ocr(I);

% Tanınan metni al
recognizedText = ocrResults.Text;

% Tanınan metni göster
disp('Tanınan Metin:');
% Dosya adı ve yolunu belirleyin
dosyaAdi = 'taninan_metin.txt';

% Dosyayı yazma modunda açın
dosya = fopen(dosyaAdi, 'wt');

% Dosyaya metni yazın
fprintf(dosya, '%s\n', recognizedText); % Yeni satıra geçmek için \n kullanıyoruz

% Yeni bir satır daha ekleyebiliriz
fprintf(dosya, 'Bu da yeni bir satir\n');

% Dosyayı kapatın
fclose(dosya);

% Dosyayı okuma modunda açın ve içeriğini görüntüleyin
dosya = fopen(dosyaAdi, 'r');
dosyaIcerigi = fscanf(dosya, '%c');
fclose(dosya);

disp('Dosya Icerigi:');
  disp(dosyaIcerigi);


    % Burada plaka tanıma kodu olacak
    % Önceki plaka tanıma kodunuzu buraya yerleştirin
    % İşlemleri gerçekleştirin ve sonuçları döndürün
    % Tanınan metni döndürün, işlenmiş resmi döndürmek zorunda değilsiniz (~ kullanarak atama yapabilirsiniz)
end
