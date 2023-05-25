import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter QR Code Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
      routes: {
        '/qr': (context) => qr(),
        '/giris_sayfasi' : (context) => LoginPage(),
        '/kayit_sayfasi':(context)=> RegisterPage(),
        '/anasayfa':(context)=>HomePage(),
        '/menu':(context)=>menu(),
        '/profil':(context)=>profil(),
        '/cafeekle':(context)=>cafeekle()
      },
    );
  }
}
// uygulamaya giriş sayfası
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> loginUser(BuildContext context) async {
    final String email = emailController.text;
    final String password = passwordController.text;

    final response = await http.post(
      Uri.parse('http://localhost:3000/api/auth/login'),
      headers: <String, String>{ 'Content-Type': 'application/json; charset=UTF-8', },
      body: jsonEncode(<String, String>{'userMail': email, 'userPassword': password}),
    );

    log(response.body);
    print(jsonDecode(response.body)['token']);

    if (jsonDecode(response.body)['token'] != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
    else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Hata'),
            content: Text('Hesap bulunamadı'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Tamam'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Giriş Sayfası'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'E-posta',
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Şifre',
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => loginUser(context),
                child: Text('Giriş Yap'),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  );
                },
                child: Text('Kayıt Ol'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



// uygulamaya kayıt olma sayfası
class RegisterPage extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> registerUser(BuildContext context) async {
    final String name = nameController.text;
    final String surname = surnameController.text;
    final String email = emailController.text;
    final String password = passwordController.text;

    final response = await http.post(
      Uri.parse('http://localhost:3000/api/auth/signup'),
      headers: <String, String>{ 'Content-Type': 'application/json; charset=UTF-8', },
      body: jsonEncode(<String, String>{
        'userName': name,
        'userSurname': surname,
        'userMail': email,
        'userPassword': password,
      }),
    );
    log(response.body);

    if (jsonDecode(response.body)['token']) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Başarılı'),
            content: Text('Kayıt başarıyla oluşturuldu'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Tamam'),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Hata'),
            content: Text('Kayıt oluşturulamadı'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Tamam'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kayıt Sayfası'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'İsim',
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: surnameController,
                decoration: InputDecoration(
                  labelText: 'Soyisim',
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'E-posta',
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Şifre',
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => registerUser(context),
                child: Text('Kayıt Ol'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  AnaSayfa createState() => AnaSayfa();
}


class AnaSayfa extends State<HomePage> {
  List<String> cafeNames = ['Cafe A', 'Cafe B', 'Cafe C', 'Cafe D'];
  List<IconData> cafeIcons = [
    Icons.coffee,
    Icons.local_cafe,
    Icons.restaurant,
    Icons.fastfood
  ];
  List<IconData> visibleIcons = [Icons.coffee,
    Icons.local_cafe,
    Icons.restaurant,
    Icons.fastfood];

  String searchText = '';

  bool showErrorMessage = false;

  void filterIcons() {
    visibleIcons.clear();
    for (int i = 0; i < cafeNames.length; i++) {
      if (cafeNames[i].toLowerCase().contains(searchText.toLowerCase())) {
        visibleIcons.add(cafeIcons[i]);
      }
    }
    if (visibleIcons.isEmpty) {
      showErrorMessage = true;
    } else {
      showErrorMessage = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.brown,
          centerTitle: true,
          title: Text(
            'CAFECODE',
            style: TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/menu');
            },
          ),
        ),
        body: Container(
          color: Colors.brown,
          child: Column(
            children: [
              SizedBox(height: 20),
              Text(
                'CAFELERİM',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),

              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      searchText = value;
                      filterIcons();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'CAFE ARA',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              SizedBox(height: 20),
              showErrorMessage
                  ? Text(
                'ARADIĞINIZ CAFE BULUNAMADI. LÜTFEN EKLEME SAYFASINA BAKIN',
                style: TextStyle(color: Colors.white),
              )
                  : Wrap(
                alignment: WrapAlignment.spaceEvenly,
                children: [
                  for (int i = 0; i < visibleIcons.length; i++)
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/qr');
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            cafeIcons[i],
                            color: Colors.white,
                            size: 98,
                          ),
                          SizedBox(height: 8),
                          Text(
                            cafeNames[i],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),


                    )
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/cafeekle');
                },
                child: Text('YENİ CAFE EKLE'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  onPrimary: Colors.brown,
                ),
              ),
            ],
          ),
        ),
    );
  }
}

//menü sayfası
class menu extends StatefulWidget {
  @override
  MenuScreen createState() => MenuScreen();
}

class MenuScreen extends State<menu> {
  final String name="yakup abacı";
  final String accountNumber="123456";
  final String profileImagePath="D:\\resim\\resim.png";

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.brown,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.brown,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                CircleAvatar(
                  backgroundImage: AssetImage(profileImagePath),
                  radius: 30,
                ),
                SizedBox(height: 10),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Hesap No: $accountNumber',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Müşteri Hesabı',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            title: Text(
              'PROFİL',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/profil');
            },
          ),
          ListTile(
            title: Text(
              'CAFELERİM',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/anasayfa');
            },
          ),
          ListTile(
            title: Text(
              'CAFE EKLE',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/cafeekle');
            },
          ),
          ListTile(
            title: Text(
              'Çıkış Yap',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/giris_sayfasi');
            },
          ),
        ],
      ),
    );
  }
}

//profil sayfası

class profil extends StatefulWidget {
  @override
  ProfileScreen createState() => ProfileScreen();
}

class ProfileScreen extends State<profil> {
  String name = "yakup";
  String surname = "abacı";
  String email = "asd";
  String password = "123";

  void updateProfile() {
    setState(() {
      // TODO: Implement update profile functionality
      // Update the profile data in database
      // Show a snackbar to inform user about the update
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown,
        appBar: AppBar(
          backgroundColor: Colors.brown,
          title: Text(
            "PROFİLİNİZ",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Navigator.pushNamed(context, '/menu');
              // Navigate to MenuScreen
            },
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "ad",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: "Adınızı girin",
                ),
                onChanged: (value) {
                  setState(() {
                    name = value;
                  });
                },
                controller: TextEditingController(text: name),
              ),
              SizedBox(height: 16.0),
              Text(
                "soyadı",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: "Soyadınızı girin",
                ),
                onChanged: (value) {
                  setState(() {
                    surname = value;
                  });
                },
                controller: TextEditingController(text: surname),
              ),
              SizedBox(height: 16.0),
              Text(
                "eposta adresi",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: "E-posta adresinizi girin",
                ),
                onChanged: (value) {
                  setState(() {
                    email = value;
                  });
                },
                controller: TextEditingController(text: email),
              ),
              SizedBox(height: 16.0),
              Text(
                "şifresi",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Şifrenizi girin",
                ),
                onChanged: (value) {
                  setState(() {
                    password = value;
                  });
                },
                controller: TextEditingController(text: password),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () => updateProfile(),
                child: Text("GÜNCELLE"),
                style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                  onPrimary: Colors.white,
                ),
              ),
            ],
          ),
        ),
    );
  }
}

//cafe ekleme sayfasi
class cafeekle extends StatefulWidget {
  @override
  CafeEklemeSayfasi createState() => CafeEklemeSayfasi();
}


class CafeEklemeSayfasi extends State<cafeekle> {
  //const CafeEklemeSayfasi({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.brown,
        appBar: AppBar(
          backgroundColor: Colors.brown,
          title: Text(
            'CAFECODE',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Navigator.pushNamed(context, '/menu');
            },
          ),
        ),
        body: GridView.count(
          crossAxisCount: 4,
          children: <Widget>[
            CafeIcon(ad: 'Cofe 1'),
            CafeIcon(ad: 'Cofe 2'),
            CafeIcon(ad: 'Cofe 3'),
            CafeIcon(ad: 'Cofe 4'),
            CafeIcon(ad: 'Cofe 5'),
            CafeIcon(ad: 'Cofe 6'),
          ],
        ),
    );
  }
}

class CafeIcon extends StatelessWidget {
  final String ad;

  const CafeIcon({Key? key, required this.ad}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/qr');
      },
      child: Column(
        children: [
          Icon(Icons.local_cafe,
              size: 64,
              color: Colors.white),
          SizedBox(height: 20),
          Text(
            ad,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}



// kafelerin QR kodları sayfası
class qr extends StatefulWidget {
  @override
  QrScreen createState() => QrScreen();
}


class QrScreen extends State<qr> {
  final String cafeName="Cafe";
  final IconData cafeIcon=Icons.local_cafe;

  //QrScreen({required this.cafeName, required this.cafeIcon});

  @override
  Widget build(BuildContext context) {
    String customerNumber = "123456";//Random().nextInt(999999).toString(); // rastgele sayı yerine burada bir değişken tanımlanabilir
    String qrData = "QR Kod Verisi"; // QR kodunun içeriği burada belirlenir

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.brown,
          title: Text(
            "QR KODUNUZ",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                Navigator.pushNamed(context, '/menu'); // menü sayfasına yönlendirme
              },
            ),
          ],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: QrImage(
                data: "QR kodu verisi",
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  cafeIcon,
                  color: Colors.black,
                  size: 100.0,
                ),
                SizedBox(width: 10),
                Text(
                  cafeName,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 75.0,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              "Müşteri numaranız",
              style: TextStyle(
                color: Colors.black,
                fontSize: 28.0,
              ),
            ),
            SizedBox(height: 5),
            Text(
              customerNumber,
              style: TextStyle(
                color: Colors.black,
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
    );
  }
}