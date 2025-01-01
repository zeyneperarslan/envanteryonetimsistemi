# Zenity ile Basit Envanter Yönetim Sistemi


Proje, Zenity ve bash script kullanılarak geliştirilmiş basit bir envanter yönetim sistemi uygulamasıdır. Kullanıcı dostu bir arayüz ile depo yönetimi, kullanıcı işlemleri gibi temel işlevleri yerine getirebilecek şekilde tasarlanmıştır.

## Özellikler

- **Kullanıcı Rolleri:**
  - Yönetici: Ürün ekleyebilir, güncelleyebilir, silebilir ve kullanıcıları yönetebilir.
  - Kullanıcı: Ürünleri görüntüleyebilir ve rapor alabilir.

- **Veri Saklama:**
  - `depo.csv`: Ürün bilgilerini saklar.
  - `kullanici.csv`: Kullanıcı bilgilerini saklar.
  - `log.csv`: Hata kayıtlarını saklar.
  - `yedek_depo.csv`: Ürün bilgilerinin yedeklerini saklamak için kullanılır.
  - `yedek_kullanici.csv`: Kullanıcı bilgilerinin yedeklerini saklamak için kullanılır.    
- **Ana Menü Seçenekleri:**
  - **Ürün Ekle**: Yeni ürün ekleyebilirsiniz.
  - **Ürün Listele**: Mevcut ürünlerinizi listeleyebilirsiniz.
  - **Ürün Güncelle**: Mevcut ürünlerin bilgilerini güncelleyebilirsiniz.
  - **Ürün Sil**: Bir ürünü sistemden silebilirsiniz.
  - **Rapor Al**: 
    - **Stokta Azalan Ürünler**: Eşik değeri sağlanan ve stokta azalan ürünlerin raporunu alabilirsiniz.
    - **En Yüksek Stok Miktarına Sahip Ürünler**: En yüksek stok miktarına sahip ürünlerin raporunu alabilirsiniz.
  - **Kullanıcı Yönetimi**: 
    - **Yeni Kullanıcı Ekle**: Sisteme yeni kullanıcı ekleyebilirsiniz.
    - **Kullanıcıları Listele**: Sistemdeki tüm kullanıcıları listeleyebilirsiniz.
    - **Kullanıcı Güncelle**: Mevcut kullanıcıların bilgilerini güncelleyebilirsiniz.
    - **Kullanıcı Sil**: Sistemdeki bir kullanıcıyı silebilirsiniz.
    - **Kullanıcı Şifresini Sıfırla**: Kullanıcı şifresini sıfırlayabilirsiniz.
    - **Kilitli Hesapları Aç**: Kilitlenmiş hesapları açabilirsiniz.
  - **Program Yönetimi**:
    - **Diskteki Alanı Göster**: Proje dosyalarının disk üzerindeki alan kullanımını görüntüleyebilirsiniz.
    - **Diske Yedekle**: Veri dosyalarını yedekleyebilirsiniz.
    - **Hata Kayıtlarını Göster**: Sistemdeki hata kayıtlarını görüntüleyebilirsiniz.
  - **Çıkış**: Sistemi kapatabilir ve çıkabilirsiniz.
    
 ## Kurulum

 ### Gereksinimler

 Bu projeyi çalıştırabilmek için aşağıdaki yazılımlar gereklidir:

 - **Zenity**: Grafiksel kullanıcı arayüzü pencereleri oluşturmanıza olanak tanır.
 - **Bash**: Bu proje, bash script ile yazılmıştır ve genellikle Linux sistemlerde varsayılan olarak gelir.

 ### Adım Adım Kurulum

 1. **Depoyu Klonlayın**  
    GitHub üzerindeki projeyi bilgisayarınıza klonlamak için terminalde aşağıdaki komutu çalıştırın:
    ```bash
    git clone https://github.com/zeyneperarslan/envanteryonetimsistemi.git

 2. **Proje Klasörüne Gidin**
    Klonladığınız projeye gitmek için şu komutu kullanın:
    ```bash
    cd envanteryonetimsistemi
   
 3. **Çalıştırılabilir İzinler Verin**
    Projeyi çalıştırmak için gerekli izinleri vermek amacıyla şu komutu kullanın:
    ```bash
    chmod +x genel_ekran.sh

 4. **Projeyi Başlatın**
    Şimdi projeyi çalıştırabilirsiniz. Aşağıdaki komut ile uygulamayı başlatın:
    ```bash
    ./genel_ekran.sh

   **Uyarı:** Zenity Yüklenmemişse
     Eğer Zenity sisteminizde yüklü değilse, aşağıdaki komutla yükleyebilirsiniz:
   ```bash
   sudo apt-get install zenity
