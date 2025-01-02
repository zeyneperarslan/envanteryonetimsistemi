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
```
## Kullanım Adımları

### 1. Giriş Ekranı
Uygulamayı çalıştırdığınızda ilk olarak hoşgeldiniz mesajı karşılaşacaksınız:

<img src="zenity/hosgeldin.png" alt="Giriş Ekranı" width="250">

Ardından Kullanıcı Adı ve Şifre Giriş Ekranı kullanıcının karşısına çıkacaktır.

<img src="zenity/giriskullanici.png" alt="Giriş Ekranı" width="250" height="150"> <img src="zenity/girissifre.png" alt="Giriş Ekranı" width="250" height="150">
- **Kullanıcı Adı**: Kaydedilmiş kullanıcı adı girilir.
- **Şifre**: Şifre girilir.

OK butonuna tıkladığınızda, doğru bilgileri girerseniz ana menüye yönlendirilirsiniz. Hatalı giriş yapmanız durumunda bir uyarı mesajı alırsınız:

---

### 2. Ana Menü
Başarılı giriş yaptığınızda, aşağıdaki ana menüye yönlendirilirsiniz: Ana menüde kullanıcıya 8 seçenek sunulur.

<img src="zenity/anamenu.png" alt="Giriş Ekranı" width="300">

Buradan kullanıcı istediği işlemi seçebilir.

### Ana Menü Seçenekleri

### 1. Ürün Ekleme
**"Ürün Ekle"** seçeneğine tıklandığında aşağıdaki form ekranı açılacaktır:

<img src="zenity/uruneklememenu.png" alt="Giriş Ekranı" width="250">

Bu ekranda:
- **Ürün Adı**: Ürünün ismi girilir. Eğer arada boşluk varsa kullanıcı uyarılır ve tekrar giriş istenir.
- **Miktar**: Stok miktarı girilir. Stok miktarı pozitif sayı olmalıdır.
- **Birim Fiyat**: Ürünün birim fiyatı girilir. Birim fiyatı pozitif sayı olmalıdır.
- **Kategori**: Ürünün kategorisi girilir.Kategori alanı boş bırakılmamalıdır.

**Kaydet** butonuna basıldığında ürün envantere eklenecektir.

---

### 2. Ürün Listeleme
**"Ürün Listele"** seçeneğine tıkalndığında envanterdeki tüm ürünler görüntülenir:

<img src="zenity/urunlistele.png" alt="Giriş Ekranı" width="250">
Burada tüm ürünler numaraları küçükten büyüğe sıralanmış şekilde adı,stok miktarı,birim fiyatı ve kategorisi ile birlikte listelenir.

---

### 3. Ürün Güncelleme
**"Ürün Güncelle"** seçeneğine tıklandığında ilk olarak güncellenmek istenen ürün girişi çıkar.

<img src="zenity/guncellemegiris.png" alt="Giriş Ekranı" width="250">

Ardından seçilen ürünün hangi özelliğinin güncellenmek istediği radio list formatında kullanıcıya sunulur.

<img src="zenity/guncellemesecim.png" alt="Giriş Ekranı" width="250">

Kullanıcının yaptığı seçim üzerine güncel sayının girilmesi istenir.

<img src="zenity/guncelgiris.png" alt="Giriş Ekranı" width="200">

Tüm işlemler tamamlandıktan sonra ürünün güncellendiğine dair bilgilendirme mesajı verilir.

<img src="zenity/guncelmesaji.png" alt="Giriş Ekranı" width="250">

---

### 4. Ürün Silme
**"Ürün Sil"** seçeneğine tıklandığında istenen bir ürün envanterden kaldırılır.

<img src="zenity/silmegiris.png" alt="Giriş Ekranı" width="250">

Kullanıcıdan silmek istenen ürün girişi alınır.

<img src="zenity/silmeonay.png" alt="Giriş Ekranı" width="250">

Ardından silmek istediğine dair bir onay alınır.

<img src="zenity/urunsilmemesaji.png" alt="Giriş Ekranı" width="200" >

Eğer onay verilirse silme işlemi tamamlanır ve kullanıcıya bilgi verilir.

### 5. Rapor Al
**"Rapor Al"** seçeneğine tıklandığında kullanıcının seçimine göre envanterdeki stoğu azalan ürünleri ya da yüksek stok miktarındaki ürünler listelenir.

<img src="zenity/rapormenu.png" alt="Giriş Ekranı" width="250">

 **Stoğu azalan Ürünler** seçilirse ilk olarak kullanıcıdan eşik değer istenir ardından stok miktarı eşik değerine yakın olan ürünler listelenir.

 <img src="zenity/azstokesik.png" alt="Giriş Ekranı" width="250" height="170"> <img src="zenity/azstokliste.png" alt="Giriş Ekranı" width="200">

 **En Yüksek Stok Miktarına Sahip Ürünler** seçilirse ilk olarak kullanıcıdan eşik değer istenir ardından stok miktarı eşik değerinin üstünde olan ürünler listelenir.

 <img src="zenity/yuksekstokesik.png" alt="Giriş Ekranı" width="250"> <img src="zenity/yuksekstokliste.png" alt="Giriş Ekranı" width="200" height="300">

### 6. Kullanıcı Yönetimi
**"Kullanıcı Yönetimi"** seçeneğine tıklandığında sadece Yöneticinin erişiminde olan işlemler sunulur.

<img src="zenity/yonetimmenu.png" alt="Giriş Ekranı" width="250">

Yönetici rolünde olan kullanıcı seçeneklerden birini seçer.

#### Yeni Kullanıcı Ekle 
**"Yeni Kullanıcı Ekle"** seçeneği seçilirse uygulamaya yeni kullanıcı ekleme işlemi yapılır.

<img src="zenity/yeniad.png" alt="Giriş Ekranı" width="200"> 

Yeni kullanıcının sırasıyla kullanıcı adı , soyadı , rolü ve şifresi zenity pencerisiyle yöneticiden istenir. Yukarıda sadece "Kullanıcı Adı" girişi verilmiştir diğer bilgi girişleri de aynı şekildedir.

<img src="zenity/yenikisimesaji.png" alt="Giriş Ekranı" width="200">

Yeni kullanıcının tüm bilgileri girildikten sonra bilgilendirme mesajı verilir.

#### Kullanıcıları Listele
**"Kullanıcıları Listele"** seçeneği seçilirse var olan kullanıcı listesi görüntülenir.

<img src="zenity/kullaniciliste.png" alt="Giriş Ekranı" width="250">

#### Kullanıcı Güncelle
**"Kullanıcı Güncelle"** seçeneği seçilirse istenen kullanıcının bilgileri güncellenir.

<img src="zenity/soyadguncel.png" alt="Giriş Ekranı" width="250"> 

Güncellenmek istenen kullanıcının  sırasıyla kullanıcı adı , soyadı , rolü ve şifresi güncellenir. Yukarıda sadece "Soyadı" güncelleme girişi verilmiştir diğer güncelleme işlemleri de aynı şekildedir.

<img src="zenity/kisiguncelmesaji.png" alt="Giriş Ekranı" width="250">

Yönetici kullanıcı güncelleme işlemlerini tamamladığında bilgilendirme mesajı verilir.

#### Kullanıcı Sil
**"Kullanıcı Sil"** seçeneği seçilirse istenen kullanıcıya ait hesap uygulamadan silinir.

<img src="zenity/kullanicisil.png" alt="Giriş Ekranı" width="200"> 

Yöneticiden silmek istediği kullanıcı adı istenir.

<img src="zenity/kisiguncelmesaji.png" alt="Giriş Ekranı" width="200">

Ardından silmek istediğine dair onayı alınır.

<img src="zenity/kullanicisilmemesaji.png" alt="Giriş Ekranı" width="200">

Onay doğrulanırsa bilgilendirme mesajı verilir.

#### Kullanıcı Şifresini Sıfırla
**"Kullanıcı Şifrresini Sıfırla"** seçeneği seçilirse istenen kullanıcın şifresi sıfırlanır.

<img src="zenity/sifresifirlama.png" alt="Giriş Ekranı" width="200"> 

İlk olarak yöneticiden şifresini sıfırlamak istediği kullanıcı adı alınır.

<img src="zenity/yenisifresifirlama.png" alt="Giriş Ekranı" width="190"> 

Ardından seçilen kullanıcının yeni şifresi girilir.

<img src="zenity/sifirlamaonay.png" alt="Giriş Ekranı" width="190" > 

İşlemler tamamlandıktan sonra şifrenin sıfırlandığına dair bilgilendirme mesajı verilir.

#### Kilitli Hesapları Aç
**"Kullanıcı Şifrresini Sıfırla"** seçeneği seçilirse yönetici var olan kilitli hesapların açılmasını sağlar.

<img src="zenity/kilitacmaisim.png" alt="Giriş Ekranı" width="200" > 

İlk olarak kilidi açılmak istenen kullanıcı adı istenir.

<img src="zenity/hesapacmaonay.png" alt="Giriş Ekranı" width="200"  > 

Eğer girilen kullanıcı adına sahip hesap kilitli ise tekrardan açılmasına dair onay istenir.

<img src="zenity/hesapacmabilgi.png" alt="Giriş Ekranı" width="200"  > 

Hesap kilidi açma işlemi tammalandığında açıldığına dair bilgilendirme mesajı verilir.

### 7. Program Yönetimi
**"Program Yönetimi"** seçeneğine tıklandığında disk yönetimi ile ilgili seçenekler listelenir.

<img src="zenity/programyonetimiliste.png" alt="Giriş Ekranı" width="220"  > 

Kullanıcı seçeneklerden birini seçer.

#### Diskteki Alanı Göster
**"Diskteki Alanı Göster"** seçeneği seçildiğinde diskteki boş ve kullanılan alan görüntülenir.

<img src="zenity/diskalani.png" alt="Giriş Ekranı" width="300" > 

#### Diske Yedekle
**"Diske Yedekle"** seçeneği seçildiğinde kullanici.csv ve depo.csv dosyaları yedeklenir. Yeni yedek_kullanici.csv ve yedek_depo.csv dosyaları oluşturulur.Ardından yedeklendiğine dair bilgilendirme mesajı verilir.

<img src="zenity/yedeklememesaj.png" alt="Giriş Ekranı" width="250"> 

#### Hata Kayıtlarını Göster
**"Hata Kayıtlarını Göster"** seçeneği seçildiğinde diskle ilgili hata kayıtlarını içeren log.csv dosyası okunur ve içeriği listelenir.

<img src="zenity/hataliste.png" alt="Giriş Ekranı" width="300" > 

### 8. Çıkış Yap
**"Çıkış Yap"** seçeneğine tıklandığında kullanıcı uygulamadan çıkış yapar.

<img src="zenity/cikisonay.png" alt="Giriş Ekranı" width="250" > 

Çıkış yapmak istediğine dair onayı alınır. Onay verilirse çıkış işlemi gerçekleştrilir.











