#!/bin/bash

function csv_kontrol() {

   for file in "depo.csv" "log.csv" "kullanici.csv" ; do   # "depo.csv", "log.csv", "kullanici.csv" dosyalarının her birini kontrol edilir

              if [ ! -f "$file" ]; then
                       touch "$file"
              fi
   done

}

function log_hata() {  # log_hata fonksiyonu, bir hata mesajını log.csv dosyasına kaydeder.

    hata_numarasi=$(($(wc -l < log.csv) + 1)) # Hata numarası,dosyadaki mevcut satır sayısına bir eklenerek belirlenir.

    zaman_bilgisi=$(date "+%Y-%m-%d %H:%M:%S") # Zaman bilgisi
  
   # Hata bilgilerini log.csv dosyasına eklenir.
   echo "$hata_numarasi, $zaman_bilgisi, Kullanıcı: $kullanici_adi, Detay: $1" >> log.csv
}

function oturum_ekrani() {

    deneme_sayisi=0

    while [[ $deneme_sayisi -lt 3 ]]; do
        # Kullanıcı adı ve şifre alınır
        kullanici_adi=$(zenity --entry --title="Giriş" --text="Kullanıcı Adınızı Giriniz:" --width=400 --height=150)
        sifre=$(zenity --password --title="Giriş" --text="Şifrenizi Giriniz:" --width=400 --height=150)

        # İlerleme çubuğu
        (
            echo "0"; sleep 2
            echo "# Kullanıcı bilgileri kontrol ediliyor..."; sleep 2

            # Kullanıcı satırını CSV dosyasından alınır.
            kullanici_satir=$(grep -i "^$kullanici_adi," kullanici.csv)
            
            # Kullanıcı adı bulunamadıysa eğer hata mesajı verilir
            if [[ -z "$kullanici_satir" ]]; then
                echo "100"; sleep 1
                zenity --error --text="Hatalı kullanıcı adı veya şifre"
                log_hata "Hatalı giriş: Kullanıcı adı bulunamadı"
                deneme_sayisi=$((deneme_sayisi + 1))
                continue
            fi

            # Kullanıcı bilgileri ayrıştırılır şifre için
            echo "50"; sleep 2
            echo "# Şifre kontrol ediliyor..."
            mevcut_sifre=$(echo "$kullanici_satir" | awk -F, '{print $4}')

            # Şifre doğrulaması yapılır
            if [[ "$sifre" == "$mevcut_sifre" ]]; then
                echo "100"; sleep 2
                echo "# Giriş başarılı!"; sleep 1
            else
                echo "100"; sleep 1
                zenity --error --text="Hatalı kullanıcı adı veya şifre"
                log_hata "Hatalı giriş: Şifre eşleşmedi"
                deneme_sayisi=$((deneme_sayisi + 1))
                continue
            fi
        ) | zenity --progress --title="Giriş İşlemi" --text="Giriş yapılıyor..." --percentage=0 --auto-close --width=400 --height=150

        # Giriş başarılıysa eğer kullancıya bilgi verilir.
        zenity --info --text="Giriş Başarılı, Hoşgeldiniz $kullanici_adi"
        return
    done

    # 3 hatalı girişte hesap kilitlenir
    sed -i "s/^$kullanici_adi,.*$/&kilitli/" kullanici.csv
    zenity --error --text="Hatalı girişler nedeniyle hesabınız kilitlenmiştir."
    log_hata "Hesap kilitlendi: $kullanici_adi"
    exit 1
}

function sifre_sifirla() {  # sifre_sifirla fonksiyonu, bir kullanıcının şifresini sıfırlar.
   
    # Kullanıcıdan şifre sıfırlanacak hesap adı istenir.
    kullanici_adi=$(zenity --entry --title="Şifre Sıfırlama" --text="Şifresi sıfırlanacak kullanıcı adını girin:")

     # Kullanıcı adı, kullanici.csv dosyasından aratılır.Kullanıcı bulunamazsa, hata mesajı gönderilir.
    kullanici=$(grep -i "^$kullanici_adi," kullanici.csv)
    if [[ -z "$kullanici" ]]; then
        zenity --error --text="Kullanıcı bulunamadı!"
        log_hata "Şifre sıfırlama hatası: Kullanıcı bulunamadı"
        return
    fi


     # Kullanıcıyı bulduktan sonra şifre sıfırlamak için yöneticiye bir onay penceresi gösterilir.
    if zenity --question --text="Şifreyi sıfırlamak istediğinizden emin misiniz?" --ok-label="Evet" --cancel-label="Hayır"; then
       
        # onay verilirse yeni şifreyi girmesi için bir pencere açılır.
        yeni_sifre=$(zenity --entry --title="Yeni Şifre" --text="Yeni şifreyi girin:")
        kullanici_rol=$(echo "$kullanici" | cut -d',' -f3)
        sed -i "s/^$kullanici_adi,.*/$kullanici_adi,$yeni_sifre,$kullanici_rol,0/" kullanici.csv
       
         # Şifreninin sıfırlandığı bilgisi verilir.
        zenity --info --text="Şifre başarıyla sıfırlandı."
    else
         # İşlem iptal edilirse mesaj gönderilir.
        zenity --info --text="Şifre sıfırlama işlemi iptal edildi."
    fi
}


function kilitli_hesap_ac() {  # Kilitli hesap açma fonksiyonu

    # Yalnızca yönetici hesap kilidi açabilir o yüzden kontrol yapılır.
    if [[ "$kullanici_rol" != "Yönetici" ]]; then
        zenity --error --text="Bu işlemi yapmak için yetkiniz yok!"
        log_hata "Yetkisiz hesap açma girişimi, Kullanıcı: $kullanici_adi"
        return
    fi

    kullanici_adi=$(zenity --entry --title="Hesap Kilit Açma" --text="Kilitli hesabı açmak için kullanıcı adı girin:")

    # Kullanıcı kontrol edilir.
    kullanici=$(grep -i "^$kullanici_adi," kullanici.csv)
    if [[ -z "$kullanici" ]]; then
        zenity --error --text="Kullanıcı bulunamadı!"
        log_hata "Hesap kilit açma hatası: Kullanıcı bulunamadı"

        return
    fi

    # Kilitli olup olmadığı kontrol edilir.
    kilitli=$(echo $kullanici | awk -F, '{print $5}')
    if [[ "$kilitli" == "0" ]]; then
        zenity --info --text="Hesap zaten açık!"
        log_hata "Hesap açma denemesi: Hesap zaten açık"
        return
    fi

    # Yönetici onayı istenilir.
    onay=$(zenity --question --text="Hesap açılacak. Emin misiniz?" --ok-label="Evet" --cancel-label="Hayır")
    if [[ $? -eq 0 ]]; then
        # Kilidi aç
        sed -i "s/^$kullanici_adi,.*/$kullanici_adi,$kullanici_sifre,$kullanici_rol,0/" kullanici.csv
        zenity --info --text="Hesap başarıyla açıldı."
    else
        zenity --info --text="Hesap açma işlemi iptal edildi."
    fi
}

function urun_ekleme() {
   
    # Kullanıcı rolü kontrolü yapılır sadece Yönetici rolüne sahip kullanıcılar işlem yapabilir.
   if [[ "$kullanici_rol" != "Yönetici" ]]; then
      
      # Eğer kullanıcı yönetici değilse hata mesajı gösterilir ve işlem sonlandırılır.
     zenity --error --text="Ürün ekleme işlemi sadece yöneticilere aittir!"
     log_hata "Ürün ekelme işlemi sadece yöneticilere ait"
     return
   fi
  
  # Kullanıcıdan ürün bilgilerini almak için form açılır.
  urun_bilgi=$(zenity --forms --title="Ürün Ekle" \
        --text="Ürün Bilgilerini Girin" \
        --add-entry="Ürün Adı (Boşluk kullanmayın)" \
        --add-entry="Stok Miktarı (Pozitif sayı olmalı)"\
        --add-entry="Birim Fiyatı (Pozitif sayı olmalı)" \
        --add-entry="Kategori (Boş bırakmayın)")
 

    # Eğer kullanıcı formu iptal ederse işlem sonlandırılır.
    if [ $? -ne 0 ]; then
        return
    fi

  ( # İlerleme çubuğu işlemleri burada başlar

       echo "10
   Ürün bilgileri kontrol ediliyor..."
       sleep 2


     # Veri ayırma yapılır. pipe karakteri ile ayırarak her bir değeri alıyoruz
    IFS='|' read -r urun_adi stok_miktari birim_fiyati kategori <<< "$urun_bilgi"

    # Girilen değerleri kontrol etme
    echo "Ürün Adı: '$urun_adi'"
    echo "Stok Miktarı: '$stok_miktari'"
    echo "Birim Fiyatı: '$birim_fiyati'"
    echo "Kategori: '$kategori'"

   # Girilen değerleri kontrol etme
       echo "20
   Ürün adı kontrol ediliyor..."
       sleep 2

      # Ürün adı boşluk içeriyor mu kontrol edilir.
    if [[ "$urun_adi" =~ \s  ]]; then
  
     zenity --error --text="Ürün adı boşluk içermemeli!"
     log_hata "Hatalı giriş , ürün adı boşluk içermemeli"
    fi

       echo "40
   Çakışma kontrol ediliyor..."
       sleep 2
  
     # Aynı ürün adının daha önce eklenip eklenmediği kontrol edilir.
    if grep -i ",$urun_adi," depo.csv > /dev/null; then
      zenity --error --text="Bu ürün adıyla başka bir kayıt vardır. Lütfen farklı bir ad giriniz."
      log_hata "Hatalı giriş, aynı adla başka bir ürün var"
      return
    fi


       echo "60
   Stok miktarı ve birim fiyatı kontrol ediliyor..."
       sleep 2


       # Stok miktarının pozitif bir sayı olup olmadığı kontrol edilir.
    if [[ -z "$stok_miktari" || ! "$stok_miktari" =~ ^[0-9]+$ ]]; then
       zenity --error --text="Stok miktarı pozitif bir sayı olmalı! Giriş geçersiz."
       log_hata "Hatalı giriş, stok miktarı pozitif sayı olmalı"
       return
    fi

       # Birim fiyatının pozitif bir sayı olup olmadığı kontrol edilir.
    if ! [[ "$birim_fiyati" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then

     zenity --error --text="Birim fiyatı geçersiz. Pozitif bir sayı giriniz!"
     log_hata "Hatalı giriş , geçersiz birim fiyatı"
     return
    
    fi

        echo "80
    Kategori kontrol ediliyor..."
       sleep 2

     # Kategorinin boş olup olmadığı kontrol edilir.
    if [[ -z "$kategori" ]]; then
        zenity --error --text="Kategori boş olamaz!"
        log_hata "Hatalı giriş: Kategori boş"
        return
    fi

             echo "90
    Ürün bilgileri kaydediliyor..."
          sleep 2

    if [ -f depo.csv ]; then
        max_numara=$(awk -F',' '{print $1}' depo.csv | sort -n | tail -n 1)
         if [[ -z "$max_numara" ]]; then
            urun_numarasi=1 
         else
            urun_numarasi=$((max_numara + 1)) 
         fi
     else
        urun_numarasi=1 
    fi
    
    # Ürün bilgileri geçerliyse  depo.csv dosyasına eklenir.
 echo "$urun_numarasi,$urun_adi,$stok_miktari,$birim_fiyati,$kategori" >> depo.csv

           echo "100      # İlerleme çubuğunda işlem tamamlanır.
    Ürün başarıyla kaydedildi."
       sleep 2
   ) | zenity --progress --title="İşlem Durumu" --text="Ürün ekleniyor..." --percentage=0 --auto-close --width=400 --height=150

 
   # Ürün ekleme işlemi başarılıysa kullanıcıya bilgi verilir.
 zenity --info --text="Ürün başarılı bir şekilde eklendi."

ana_menu    # Ana menüye dönülür.

}    

function urun_listele() {
   
   # Depo dosyasının varlığı kontrol edilir. Eğer yoksa, hata mesajı gösterilir.
   if [ ! -f depo.csv ]; then
   (echo "50\nDepo dosyası kontrol ediliyor..."; sleep 2) |\
   zenity --progress --title="İşlem Durumu" --text="Depo dosyası kontrol ediliyor..." --percentage=0 --auto-close
   zenity --error --text="Depo dosyası bulunamadı!"
       return
   fi

   (echo "25\nÜrünler okunuyor..."; sleep 2) |\
   zenity --progress --title="İşlem Durumu" --text="Ürünler okunuyor..." --percentage=0 --auto-close
   

    # Depo dosyasındaki ürünler, her ürün için detaylı bilgi ile birlikte alınır.
   urunler=$(awk -F',' '
   BEGIN {ORS="\n\n"} 
   {
       print "Ürün Numarası: " $1 "\nÜrün Adı: " $2 "\nStok Miktarı: " $3 "\nBirim Fiyatı: " $4 "\nKategori: " $5
   }' depo.csv)


    # Eğer depo.csv dosyası boşsa kullanıcıya bilgi verilir.
   if [ -z "$urunler" ]; then
   (echo "75\nÜrün bilgisi kontrol ediliyor..."; sleep 2) |\
   zenity --progress --title="İşlem Durumu" --text="Ürün bilgisi kontrol ediliyor..." --percentage=50 --auto-close
   zenity --info --text="Hiç ürün bulunmamaktadır!"
       return
   fi
       # Ürünler başarıyla okunduktan sonra kullanıcıya  mesaj gönderilir..
    (echo "100\nÜrünler listeleniyor..."; sleep 2) |\
   zenity --progress --title="İşlem Durumu" --text="Ürünler listeleniyor..." --percentage=100 --auto-close --width=400 --height=150
    
     # Okunan ürünler listelenir.
   echo "$urunler" | zenity --text-info --title="Ürün Listele" --width=600 --height=600
  
  
 ana_menu  # Ana menüye dönülür.

}

function urun_guncelle() { #Fonksiyon, yöneticilerin ürün bilgilerini güncellemesini sağlar.
  
  # Kullanıcı rolü yönetici değilse hata mesajı gönderilir.
  if [[ "$kullanici_rol" != "Yönetici" ]]; then

   (echo "50\nRol kontrol ediliyor..."; sleep 2) |\
    zenity --progress --title="İşlem Durumu" --text="Rol kontrol ediliyor..." --percentage=0 --auto-close
    zenity --error --text="Ürün güncelleme işlemi sadece yöneticilere aittir!"
    log_hata "Ürün güncelleme işlemi sadece yöneticilere aittir!"
     return
  fi 

   # Kullanıcıdan güncellemek istediği ürünün adını girmesi istenir.
  urun_adi=$(zenity --entry --title="Ürün Güncelle" --text="Güncellemek istediğiniz ürünün adını girin:")


    # Ürün adı kontrol edilir.
   (echo "25\nÜrün adı kontrol ediliyor..."; sleep 2) |\
  zenity --progress --title="İşlem Durumu" --text="Ürün adı kontrol ediliyor..." --percentage=0 --auto-close

  # Ürün adındaki baş ve son boşlukları temizlenir
  urun_adi=$(echo "$urun_adi" | xargs)

  # Ürün adını içeren satır kontrol edilir (depo.csv dosyasındaki ürün adıyla)
  urun_kontrol=$(grep -i ",$urun_adi," depo.csv)


   # Eğer ürün bulunamazsa hata mesajı gönderilir.
  if [ -z "$urun_kontrol" ]; then
      zenity --error --text="Ürün bulunamadı!"
      log_hata "Ürün bulunamadı"
      return
  fi

  # Burada ürün bilgilerini ayırıyoruz, , ile ayırmak için IFS kullanıyoruz
  IFS=',' read -r urun_numarasi urun_adi stok_miktari birim_fiyati kategori <<< "$urun_kontrol"

  
  (echo "50\nÜrün bilgileri alınıyor..."; sleep 2) |\
  zenity --progress --title="İşlem Durumu" --text="Ürün bilgileri alınıyor..." --percentage=50 --auto-closeecho


  # Hangi bilgiyi güncellemek istediğini soruyoruz
  secim=$(zenity --list --title="Ürün Güncelle" --text="Hangi bilgiyi güncellemek istiyorsunuz?" \
        --radiolist --column="Seçim" --column="Bilgi" \
        TRUE "Stok Miktarı" FALSE "Birim Fiyatı")
  
  if [[ "$secim" == "Stok Miktarı" ]]; then
        yeni_stok_miktari=$(zenity --entry --title="Ürün Güncelle" --text="Mevcut Stok Miktarı: $stok_miktari\nYeni Stok Miktarını Girin:")

        if ! [[ "$yeni_stok_miktari" =~ ^[0-9]+$ ]]; then
            zenity --error --text="Stok miktarı geçersiz. Pozitif bir sayı giriniz!"
            log_hata "Hatalı giriş, stok miktarı geçersiz"
            return 
       fi


    (echo "75\nStok miktarı güncelleniyor..."; sleep 2) |\
    zenity --progress --title="İşlem Durumu" --text="Stok miktarı güncelleniyor..." --percentage=75 --auto-close

        # Stok miktarı güncelleniyor
        sed -i "/^$urun_numarasi,/c\\$urun_numarasi,$urun_adi,$yeni_stok_miktari,$birim_fiyati,$kategori" depo.csv
  fi

  if [[ "$secim" == "Birim Fiyatı" ]]; then
        yeni_birim_fiyati=$(zenity --entry --title="Ürün Güncelle" --text="Mevcut Birim Fiyatı: $birim_fiyati\nYeni Birim Fiyatını Girin:")

        if ! [[ "$yeni_birim_fiyati" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
            zenity --error --text="Birim fiyatı geçersiz. Pozitif bir sayı giriniz!"
            log_hata "Hatalı giriş, birim fiyatı geçersiz"
            return
        fi

       (echo "75\nBirim fiyatı güncelleniyor..."; sleep 2) |\
       zenity --progress --title="İşlem Durumu" --text="Birim fiyatı güncelleniyor..." --percentage=75 --auto-close

        # Birim fiyatı güncelleniyor
        sed -i "/^$urun_numarasi,/c\\$urun_numarasi,$urun_adi,$stok_miktari,$yeni_birim_fiyati,$kategori" depo.csv
  fi

  (echo "100\nÜrün güncelleniyor..."; sleep 2) |\
  zenity --progress --title="İşlem Durumu" --text="Ürün güncelleniyor..." --percentage=100 --auto-close --width=400 --height=150

  zenity --info --text="Ürün başarılı bir şekilde güncellendi!"

ana_menu  # Ana menüye dönülür.

}

function urun_sil() {  # urun_sil fonksiyonu yöneticilerin ürünleri silmesini sağlar.

   # Kullanıcı rolü Yönetici değilse, işlem durumu kontrol edilir ve hata mesajı gösterilir.
   if [[ "$kullanici_rol" != "Yönetici" ]]; then
     zenity --error --text="Ürün silme işlemi sadece yöneticilere aittir!"
     log_hata "Ürün silme işlemi sadece yöneticilere aittir!"
     return
  fi 
  
    # Kullanıcıdan silmek istediği ürünün adını girmesi istenir.
  urun_adi=$(zenity --entry --title="Ürün Sil" --text="Silmek istediğiniz ürünün adını girin:")

  # Ürün adındaki baş ve son boşlukları temizlenir
  urun_adi=$(echo "$urun_adi" | xargs)

  # Ürün adını içeren satır kontrol edilir
  urun_kontrol=$(grep -i ",$urun_adi," depo.csv)


   # Eğer ürün bulunamazsa hata mesajı gösterilir.
  if [ -z "$urun_kontrol" ]; then
      zenity --error --text="Ürün bulunamadı!"
      log_hata "Ürün bulunamadı"
      return
  fi

  # Ürün silme onayı
  zenity --question --title="Ürün Sil" --text="Bu ürünü silmek istediğinizden emin misiniz?"

   # Eğer kullanıcı Evet derse, ürün silme işlemi yapılır.
  if [ $? -eq 0 ]; then
      # Ürünü silme işlemi
      
      (
        echo "0\nSilme işlemi başlatılıyor..."; sleep 2
        echo "50\nÜrün dosyadan siliniyor..."; sleep 2
       
        # Ürün dosyadan silinir.
        sed -i "/^.*,$urun_adi,/d" depo.csv
        echo "100\nSilme işlemi tamamlandı."; sleep 1
      ) |
      zenity --progress --title="Ürün Sil" --text="Silme işlemi devam ediyor..." --percentage=0 --auto-close --no-cancel --width=400 --height=150

      zenity --info --text="Ürün başarıyla silindi."
  else
      zenity --info --text="Silme işlemi iptal edildi."
  fi

ana_menu
}

function rapor_al() { # rapor_al fonksiyonu kullanıcıya stok durumuyla ilgili rapor seçenekleri sunar.
    
     # Kullanıcıya rapor seçenekleri sunulur.
    rapor_secim=$(zenity --list --title="Rapor Al" --column="Seçenekler" \
        "Stokta Azalan Ürünler" \
        "En Yüksek Stok Miktarına Sahip Ürünler"
                          --width=1000 --height=400 --scrollable)
   
  # Kullanıcının seçimine göre işlemler yapılır.
    case $rapor_secim in
 
       "Stokta Azalan Ürünler") # Stokta azalan ürünler seçildiyse stok_azalan_urunler fonksiyonu çağrılır.
            stok_azalan_urunler
            ;;

        "En Yüksek Stok Miktarına Sahip Ürünler")  # En yüksek stok miktarına sahip ürünler seçildiyse yuksek_stok_urunler fonksiyonu çağrılır.
            yuksek_stok_urunler
            ;;
        *)
            # Kullanıcı bir şey seçmezse veya iptal ederse bilgi mesajı verilir.
            zenity --info --text="Hiçbir seçenek seçilmedi."
            ;;
    esac
}

function stok_azalan_urunler() {
    # Eşik değeri alınıyor
    esik_degeri=$(zenity --entry --title="Stok Azalan Ürünler" --text="Eşik değeri girin:"   --width=400 --height=150)

    # Eşik değeri boşsa, kullanıcıya hata mesajı gösterilir
    if [ -z "$esik_degeri" ]; then
        zenity --error --text="Eşik değeri girilmelidir!"
        return
    fi

    # Eşik değerinin sayısal olup olmadığını kontrol ediyoruz
    if ! [[ "$esik_degeri" =~ ^[0-9]+$ ]]; then
        zenity --error --text="Lütfen geçerli bir sayısal eşik değeri girin!"
        return
    fi

    # Ürünleri filtrelemek için değişken tanımlıyoruz
    urunler=""
    echo "Eşik değeri: $esik_degeri"  # Hata ayıklama için log
    
    # CSV dosyasını satır satır okuyoruz
    while IFS=',' read -r urun_no urun_adi stok miktar kategori; do
        # Boş veya hatalı satırları atlıyoruz
        if [ -z "$urun_no" ] || [ -z "$urun_adi" ] || [ -z "$stok" ]; then
            echo "Atlanan satır (eksik bilgi): $urun_no, $urun_adi, $stok, $miktar, $kategori"  # Log
            continue
        fi

        # Stok miktarını eşik değeriyle karşılaştırıyoruz
        if [[ "$stok" =~ ^[0-9]+$ && "$stok" -lt "$esik_degeri" ]]; then
            urunler+="Ürün Numarası: $urun_no\nÜrün Adı: $urun_adi\nStok Miktarı: $stok\nBirim Fiyatı: $miktar\nKategori: $kategori\n\n"
            echo "Eklendi: $urun_no, $urun_adi, $stok, $miktar, $kategori"  # Log
        else
            echo "Eşik üstü ya da hatalı: $urun_no, $urun_adi, $stok"  # Log
        fi
    done < depo.csv

    # Eğer ürünler boşsa, kullanıcıya uyarı mesajı gösterilir
    if [ -z "$urunler" ]; then
        zenity --info --text="Stok miktarı eşik değerinin altında olan ürün bulunmamaktadır."
        echo "Eşik altında ürün yok."  # Log
    else

        (
    echo "0\nStok azalan ürünler alınıyor..."
    sleep 1  # İlk işlem süresi
    echo "50\nStokta azalan ürünler kontrol ediliyor..."
    sleep 1  # İkinci işlem süresi
    echo "100\nStok azalan ürünler listelendi."
    sleep 1  # Üçüncü işlem süresi
      ) | zenity --progress --title="Stok Azalan Ürünler" --text="İşlem devam ediyor..." --percentage=0 --auto-close --width=400 --height=150

        # Zenity ile çok satırlı metin penceresi açıyoruz
        echo -e "$urunler" > urunler.txt  # Zenity'ye gönderilmeden önce dosyaya yazıyoruz
        zenity --text-info --title="Stokta Azalan Ürünler" --filename=urunler.txt
        echo "Zenity'de gösterildi: $urunler"  # Log
    fi

ana_menu
}

function yuksek_stok_urunler() {
    # Eşik değeri alınıyor
    esik_degeri=$(zenity --entry --title="Yüksek Stok Ürünler" --text="Eşik değeri girin:" --width=400 --height=100 )

    # Eşik değeri boşsa, kullanıcıya hata mesajı gösterilir
    if [ -z "$esik_degeri" ]; then
        zenity --error --text="Eşik değeri girilmelidir!"
        return
    fi

    # Eşik değerinin sayısal olup olmadığını kontrol ediyoruz
    if ! [[ "$esik_degeri" =~ ^[0-9]+$ ]]; then
        zenity --error --text="Lütfen geçerli bir sayısal eşik değeri girin!"
        return
    fi

    # Ürünleri filtrelemek için değişken tanımlıyoruz
    urunler=""
    echo "Eşik değeri: $esik_degeri"  # Hata ayıklama için log

    # CSV dosyasını satır satır okuyoruz
    while IFS=',' read -r urun_no urun_adi stok miktar kategori; do
        # Boş veya hatalı satırları atlıyoruz
        if [ -z "$urun_no" ] || [ -z "$urun_adi" ] || [ -z "$stok" ]; then
            echo "Atlanan satır (eksik bilgi): $urun_no, $urun_adi, $stok, $miktar, $kategori"  # Log
            continue
        fi

        # Stok miktarını eşik değeriyle karşılaştırıyoruz
        if [[ "$stok" =~ ^[0-9]+$ && "$stok" -gt "$esik_degeri" ]]; then
            urunler+="Ürün Numarası: $urun_no\nÜrün Adı: $urun_adi\nStok Miktarı: $stok\nBirim Fiyatı: $miktar\nKategori: $kategori\n\n"
            echo "Eklendi: $urun_no, $urun_adi, $stok, $miktar, $kategori"  # Log
        else
            echo "Eşik altı ya da hatalı: $urun_no, $urun_adi, $stok"  # Log
        fi
    done < depo.csv

    # Eğer ürünler boşsa, kullanıcıya uyarı mesajı gösterilir
    if [ -z "$urunler" ]; then
        zenity --info --text="Stok miktarı eşik değerinin üstünde olan ürün bulunmamaktadır."
        echo "Eşik üstünde ürün yok."  # Log
    else

         (
    echo "0\nürünler alınıyor..."
    sleep 1 # İlk işlem süresi
    echo "50\nStokta eşik üstünde olan ürünler kontrol ediliyor..."
    sleep 1  # İkinci işlem süresi
    echo "100\nürünler listelendi."
    sleep 1  # Üçüncü işlem süresi
      ) | zenity --progress --title="Yüksek Stok Miktarına Sahip Ürünler" --text="İşlem devam ediyor..." --percentage=0 --auto-close --width=400 --height=150

        # Zenity ile çok satırlı metin penceresi açıyoruz
        echo -e "$urunler" > yuksek_stok_urunler.txt  # Zenity'ye gönderilmeden önce dosyaya yazıyoruz
        zenity --text-info --title="Yüksek Stok Miktarına Sahip Ürünler" --filename=yuksek_stok_urunler.txt
        echo "Zenity'de gösterildi: $urunler"  # Log
    fi 

ana_menu
}

# kullanici_yonetimi fonksiyonu, yöneticiye farklı kullanıcı yönetim işlemleri sunar.
function kullanici_yonetimi() {

    # Kullanıcı rolü Yönetici değilse işlem yapılmaz ve hata mesajı gösterilir
    if [[ "$kullanici_rol" != "Yönetici" ]]; then

     zenity --error --text="Ürün ekleme işlemi sadece yöneticilere aittir!"
     log_hata "Ürün ekleme işlemi sadece yöneticilere aittir!"

     return
   fi
  
    # Kullanıcıya sunulacak seçenekler listelenir.
    kullanici_secim=$(zenity --list --title="Kullanıcı Yönetimi" --column="Seçenekler" \
        "Yeni Kullanıcı Ekle" \
        "Kullanıcıları Listele" \
        "Kullanıcı Güncelle" \
        "Kullanıcı Sil"\
        "Kullanıcı Şifresini Sıfırla"\
        "Kilitli Hesapları Aç"
              --width=1920 --height=1080)

    # Kullanıcının seçimine göre ilgili fonksiyonlar çağrılır.
    case $kullanici_secim in
        "Yeni Kullanıcı Ekle")
            yeni_kullanici_ekle
            ;;

        "Kullanıcıları Listele")
            kullanici_listele
            ;;


        "Kullanıcı Güncelle")
            kullanici_guncelle
            ;;

        "Kullanıcı Sil")
            kullanici_sil
            ;;
        
          "Kullanıcı Şifresini Sıfırla")
        sifre_sifirla
           ;;
         
         "Kilitli Hesapları Aç")
         kilitli_hesap_ac
          ;;
        *)
          # Eğer geçersiz bir seçenek girilirse hata mesajı gösterilir.
            zenity --error --text="Geçersiz seçenek!"
            log_hata "Geçersiz Seçenek"
            ;;
    esac
}

function yeni_kullanici_ekle() {  # yeni_kullanici_ekle fonksiyonu, yeni bir kullanıcı ekler.
  
   # Kullanıcıdan yeni kullanıcı adı, soyadı, rol ve şifre bilgileri alınır.
   kullanici_adi=$(zenity --entry --title="Yeni Kullanıcı Ekle" --text="Yeni Kullanıcı Adı:")
   kullanici_soyadi=$(zenity --entry --title="Yeni Kullanıcı Ekle" --text="Yeni Kullanıcı Soyadi:")
   kullanici_rol=$(zenity --entry --title="Yeni Kullanıcı Ekle" --text="Rol:")
   sifre=$(zenity --entry --title="Yeni Kullanıcı Ekle" --text="Sifre:")
    
    # Şifreyi MD5 ile şifreleme işlemi yapılır.
    sifre_md5=$(echo -n "$parola" | md5sum | awk '{print $1}')
    
    # Kullanıcı bilgileri kullanici.csv dosyasına eklenir.
    echo "$kullanici_adi,$kullanici_soyadi,$kullanici_rol,$sifre_md5" >> kullanici.csv
   
    (  # İlerleme durumu göstergesi (progress bar) ile kullanıcı ekleme işlemi yapılır.
    
        echo "0\nİşlem başlatılıyor..."
        sleep 1
        echo "50\nKullanıcı kaydediliyor..."
        sleep 1
        echo "100\nKullanıcı başarıyla eklendi."
        sleep 1
    ) | zenity --progress --title="Yeni Kullanıcı Ekle" --text="Kullanıcı kaydediliyor..." --percentage=0 --auto-close --width=400 --height=150
    

     # Kullanıcı ekleme işlemi tamamlandığında yöneticiye başarı mesajı gösterilir.
    zenity --info --text="Kullanıcı başarıyla eklendi."

ana_menu # Ana menü çağırılır.

}

function kullanici_listele() {

   # Dosya var mı kontrol edilir.
   if [ ! -f kullanici.csv ]; then
      zenity --error --text="kullanici.csv dosyası bulunamadı!"
      return
   fi

   # Dosya okunabilir mi kontrolü yapılır.
   if [ ! -r kullanici.csv ]; then
      zenity --error --text="kullanici.csv dosyası okunamıyor! Lütfen dosya izinlerini kontrol edin."
      return
   fi

   # Dosya okunur ve temizlenir.
   kullanici_listesi=$(cat kullanici.csv | tr -d '\r')

   # Dosya boşsa uyarı gösterilir
   if [ -z "$kullanici_listesi" ]; then
      zenity --info --text="Hiç kullanıcı kaydı bulunmamaktadır."
      return
   fi


   # İlerleme çubuğu 
    (
        echo "0\nKullanıcılar yükleniyor..."
        sleep 1  # Yükleniyor mesajı
        echo "100\nKullanıcılar başarıyla listelendi."
        sleep 1  # Listeleme tamamlandığında bekleme
    ) | zenity --progress --title="Kullanıcı Listesi" --text="Kullanıcılar listeleniyor..." --percentage=0 --auto-close --width=400 --height=150

   # Zenity ile kullanıcı listesini gösterilir
   echo "$kullanici_listesi" | zenity --text-info --title="Kullanıcılar" --width=600 --height=400
   zenity --info --text="Kullanıcılar başarıyla listelendi."

ana_menu #ana menü çağırılır.

 }


function kullanici_guncelle() { # kullanici_guncelle fonksiyonu kullanıcının bilgilerini günceller.
    
    # Kullanıcıdan güncellemek istediği kullanıcı adı, soyadı, rol ve yeni şifre bilgileri alınır.
    kullanici_adi=$(zenity --entry --title="Kullanıcı Güncelle" --text="Güncellemek istediğiniz kullanıcı adı:")
    kullanici_soyadi=$(zenity --entry --title="Kullanıcı Güncelle" --text="Güncellemek istediğiniz kullanıcı soyadı:")
    kullanici_rol=$(zenity --entry --title="Kullanıcı Güncelle" --text="Yeni Rol:")
    kullanici_sifre=$(zenity --entry --title="Kullanıcı Güncelle" --text="Yeni Sifre:")
   
    # Yeni şifre MD5 ile şifrelenir
    sifre_md5=$(echo -n "$kullanici_sifre" | md5sum | awk '{print $1}')
    
    # Kullanıcının bilgileri kullanici.csv dosyasındaki ilgili satırda güncellenir.
    sed -i "/^$kullanici_adi,/c\\$kullanici_adi,$kullanici_soyadi,$kullanici_rol,$sifre_md5" kullanici.csv


  # İlerleme çubuğu
    (
        echo "0\nKullanıcı bilgileri güncelleniyor..."
        sleep 1  # Güncelleniyor mesajı
        sed -i "/^$kullanici_adi,/c\\$kullanici_adi,$kullanici_soyadi,$kullanici_rol,$sifre_md5" kullanici.csv
        echo "100\nKullanıcı başarıyla güncellendi."
        sleep 1  # Güncelleme tamamlandığında bekleme
    ) | zenity --progress --title="Kullanıcı Güncelle" --text="Kullanıcı güncelleniyor..." --percentage=0 --auto-close --width=400 --height=150

      # İşlem tamamlandığında başarı mesajı verilir.
    zenity --info --text="Kullanıcı başarıyla güncellendi."

 ana_menu # Ana menüyü tekrar çağırır.

}

function kullanici_sil() { # kullanici_sil fonksiyonu, kullanıcıyı silmek için kullanılır.
 
     # Kullanıcıdan silmek istediği kullanıcı adı alınır.
   kullanici_adi=$(zenity --entry --title="Kullanıcı Sil" --text="Silmek istediğiniz kullanıcı adı:")
    
      # Kullanıcı adını içeren satır kullanici.csv dosyasından silinir.
    sed -i "/^$kullanici_adi,/d" kullanici.csv
    
    # İlerleme çubuğu
    (
        echo "0\nKullanıcı siliniyor..."
        sleep 1  # Siliniyor mesajı
        sed -i "/^$kullanici_adi,/d" kullanici.csv
        echo "100\nKullanıcı başarıyla silindi."
        sleep 1  # Silme işlemi tamamlandığında bekleme
    ) | zenity --progress --title="Kullanıcı Sil" --text="Kullanıcı siliniyor..." --percentage=0 --auto-close --width=400 --height=150

    # İşlem tamamlandığında başarı mesajı verilir
    zenity --info --text="Kullanıcı başarıyla silindi."

ana_menu

}

function program_yonetimi() {

    # Kullanıcıdan seçim yapması istenir.
    program_secim=$(zenity --list --title="Program Yönetimi" --column="Seçenekler" \
        "Diskteki Alanı Göster" \
        "Diske Yedekle" \
        "Hata Kayıtlarını Göster"
                   --width=500 --height=500)

    # Seçilen seçeneğe göre ilgili fonksiyon çağrılır.
    case $program_secim in

        "Diskteki Alanı Göster")
            disk_alanini_goster
            ;;

        "Diske Yedekle")
            diske_yedekle
            ;;

        "Hata Kayıtlarını Göster")
            hata_kayitlari
            ;;
        *) 
            # Geçersiz bir seçenek girildiğinde hata mesajı gösterilir.
            zenity --error --text="Geçersiz seçenek!"
            log_hata "Geçersiz Seçenek"
            ;;
    esac


}

function disk_alanini_goster() {
   
   # Disk alanı bilgisi alınır.
    alan=$(df -h)

    # Eğer df komutu boş bir çıktı döndürürse hata mesajı verilir.
    if [ -z "$alan" ]; then
        zenity --error --text="Disk alanı bilgisi alınamadı!"
        return
    fi

    # İlerleme çubuğu
    (
        echo "0\nDisk alanı bilgisi alınıyor..."
        sleep 1  # Disk alanı bilgisi alınıyor mesajı
        echo "100\nDisk alanı bilgisi alındı."
        sleep 1  # Bilgi alındığında bekleme
    ) | zenity --progress --title="Disk Alanı Bilgisi" --text="İşlem devam ediyor..." --percentage=0 --auto-close --width=400 --height=150
0


    # Zenity penceresi  ile disk alanı bilgisi gösterilir
    echo "$alan" | zenity --text-info --title="Disk Alanı" --width=600 --height=400

ana_menu
}


function diske_yedekle() {

    (
        echo "0\nDosyalar yedekleniyor..."
        sleep 1  # Yedekleniyor mesajı
        cp depo.csv yedek_depo.csv
        echo "50\nDepo dosyası yedeklendi..."
        sleep 1  # Depo dosyasının yedeklenmesi tamamlandığında bekleme
        cp kullanici.csv yedek_kullanici.csv
        echo "100\nKullanıcı dosyası yedeklendi."
        sleep 1  # Kullanıcı dosyasının yedeklenmesi tamamlandığında bekleme
    ) | zenity --progress --title="Dosya Yedekleme" --text="İşlem devam ediyor..." --percentage=0 --auto-close --width=400 --height=200


    # Yedekleme tamamlandıktan sonra kullanıcıya bilgi verilir
    zenity --info --text="Dosyalar başarıyla yedeklendi."
ana_menu
}


# hata_kayitlari fonksiyonu, hata kaydını içeren dosyayı kontrol eder ve içeriklerini kullanıcıya gösterir.
function hata_kayitlari() {
    
    # Eğer log.csv dosyası yoksa hata mesajı gösterilir.
    if [ ! -f log.csv ]; then
        zenity --error --text="Hata kayıt dosyası bulunamadı!"
        return
    fi
   
    # Eğer log.csv dosyası boşsa bilgilendirme mesajı gösterilir.
    if [ ! -s log.csv ]; then
        zenity --info --text="Hata kayıtları boş!"
        return
    fi
     
     # log.csv dosyasındaki tüm kayıtlar okunur.
     hata_kayitlari=$(awk '{print $0}' log.csv)

    # İlerleme çubuğu 
    (
        echo "0\nHata kayıtları okunuyor..."
        sleep 1  # Hata kayıtları okunuyor mesajı
        echo "100\nHata kayıtları başarıyla alındı."
        sleep 1  # Kayıtların alınması tamamlandığında bekleme
    ) | zenity --progress --title="Hata Kayıtları" --text="İşlem devam ediyor..." --percentage=0 --auto-close --width=400 --height=200

     # Zenity penceresi ile hata kayıtları gösterilir
    echo "$hata_kayitlari" | zenity --text-info --title="Hata Kayıtları" --width=600 --height=400

ana_menu
}



function cikis() {
    
    # Kullanıcıya çıkış yapmak isteyip istemediğini soran bir onay penceresi açılır.
    zenity --question \
           --title="Çıkış Onayı" \
           --width=300 \
           --height=150 \
           --text="Sistemden çıkmak istediğinize emin misiniz?"

    
    if [ $? -eq 0 ]; then
        # Kullanıcı Evet dedi sistemden çıkılır
       
       (
            echo "0\nÇıkış işlemi başlatılıyor..."
            sleep 1  # Çıkış başlatılıyor mesajı
            echo "100\nSistemden çıkış yapılıyor..."
            sleep 1  # Çıkış yapılıyor
        ) | zenity --progress --title="Çıkış" --text="Çıkış yapılıyor..." --percentage=0 --auto-close --width=400 --height=150
        
         exit 0
    else
        # Kullanıcı Hayır dedi  bildirim gösterilir
        zenity --info \
               --title="Bilgilendirme" \
               --width=250 \
               --height=100 \
               --text="Çıkış iptal edildi."
    fi
}


# ana_menu fonksiyonu, ana menüdeki seçenekleri sunar ve kullanıcı seçimlerine göre ilgili işlemi başlatır.
function ana_menu() {
  
   # Kullanıcıya ana menüyü göstermek için Zenity ile bir seçim penceresi açılır.

   menu_secim=$(zenity --list --title="Ana Menü" --column="Seçenekler" \
        "Ürün Ekle" \
        "Ürün Listele" \
        "Ürün Güncelle" \
        "Ürün Sil" \
        "Rapor Al" \
        "Kullanıcı Yönetimi" \
        "Program Yönetimi" \
        "Çıkış" \
        --width=600 --height=400)

    # Kullanıcının seçimine göre, ilgili fonksiyon çağrılır.
   
    case $menu_secim in
 
       "Ürün Ekle")
            urun_ekleme
            ;;

        "Ürün Listele")
            urun_listele
            ;;

        "Ürün Güncelle")
            urun_guncelle
            ;;

        "Ürün Sil")
            urun_sil
            ;;

        "Rapor Al")
            rapor_al
            ;;

        "Kullanıcı Yönetimi")
            kullanici_yonetimi
            ;;

        "Program Yönetimi")
            program_yonetimi
            ;;

        "Çıkış")
            cikis
            ;;
        *)
            zenity --error --text="Geçersiz seçenek!" # Geçersiz bir seçenek girildiğinde hata mesajı gösterilir.
            log_hata "Geçersiz Seçenek"  # Hata kaydı tutulur.
            ;;
    esac
}

# Sistem açıldığında, kullanıcılara hoşgeldiniz mesajı gösterilir.

zenity --info --title="Hoşgeldiniz" --text="Envanter Yönetim Sistemine Hoşgeldiniz!" --width=400 --height=200

 
csv_kontrol    # Sistemde CSV dosyasının kontrol edilmesi gerekir.
oturum_ekrani  # Oturum açma işlemi başlatılır.
ana_menu      # Ana menü çağrılır ve kullanıcı işlemi beklenir.
