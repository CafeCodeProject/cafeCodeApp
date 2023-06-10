import 'dart:math';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:developer';
import 'secilenCafeler.dart';

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
        appBarTheme: AppBarTheme(
          color: Color(0xFF37251B), // Set app bar color
          elevation: 0, // Remove app bar elevation
        ),
      ),
      home: LoginPage(),
      routes: {
        '/qr': (context) => qr(),
        '/giris_sayfasi' : (context) => LoginPage(),
        '/kayit_sayfasi':(context)=> RegisterPage(),
        '/anasayfa':(context)=>Cafelerim(),
        '/menu':(context)=>MenuScreen(),
        '/profil':(context)=>ProfilePage(),
        '/cafebul':(context)=>CafeBulSayfasi(),
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

    print(jsonDecode(response.body)['token']);

    if (jsonDecode(response.body)['token'] != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', jsonDecode(response.body)['user']['_id']);
      await prefs.setString('userName', jsonDecode(response.body)['user']['userName']);
      await prefs.setString('userSurname', jsonDecode(response.body)['user']['userSurname']);
      await prefs.setString('userMail', jsonDecode(response.body)['user']['userMail']);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Cafelerim()),
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
    Color backgroundColor = Color(0xFF37251b);
    Color appBarColor = backgroundColor;
    Color squareColor = Color(0xFF4F3E2E);

    final buttonStyle = ElevatedButton.styleFrom(
      primary: Color(0xFF505050),
      onPrimary: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: Color(0xFF4f3e2e),
          width: 4.0,
        ),
      ),
      minimumSize: Size(200.0, 50.0),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
      ),

      backgroundColor: backgroundColor,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 16),
              Container(
                width: 200.0,
                child: Text(
                  'CAFECODE',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    'assets/images/coffee.jpg',
                    width: 200,
                    height: 200,
                  ),
                ],
              ),
              SizedBox(height: 16),
              Container(
                width: 200.0,
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'E-posta',
                    filled: true,
                    fillColor: squareColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Container(
                width: 200.0,
                child: TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Şifre',
                    filled: true,
                    fillColor: squareColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => loginUser(context),
                child: Text('Giriş Yap'),
                style: buttonStyle,
              ),
              SizedBox(height: 16),
              Container(
                width: 200.0,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterPage()),
                    );
                  },
                  child: Text('Kayıt Ol'),
                  style: TextButton.styleFrom(
                    primary: Colors.white,
                    backgroundColor: Color(0xFF505050),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      side: BorderSide(
                        color: Color(0xFFD2C1B1),
                        width: 4.0,
                      ),
                    ),
                    minimumSize: Size(200.0, 50.0),
                  ),
                ),
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
    Color backgroundColor = Color(0xFF37251b); // Background color
    Color appBarColor = backgroundColor; // App bar color

    return Scaffold(
      appBar: AppBar(
        title: Text('Kayıt Sayfası'),
        backgroundColor: appBarColor,
      ),
      backgroundColor: backgroundColor,
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

class Cafelerim extends StatefulWidget {
  @override
  _CafelerimState createState() => _CafelerimState();
}

class _CafelerimState extends State<Cafelerim> {

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Color(0xFF37251b); // Background color

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cafelerim'),
        backgroundColor: backgroundColor, // Set the app bar color here
        elevation: 0, // Set the elevation to 0 to remove the shadow
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Navigator.pushNamed(context, '/menu');
          },
        ),
      ),
      backgroundColor: backgroundColor,
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.0,
          crossAxisSpacing: 6,
          mainAxisSpacing: 12,
        ),
        padding: EdgeInsets.all(10),
        itemCount: SecilenCafeler.secilenCafeler.length, // Replace with the actual number of cafes
        itemBuilder: (BuildContext context, int index) {
          String cafeName = SecilenCafeler.secilenCafeler[index]; // Replace with the actual cafe names
          return buildCafeIcon(Icons.local_cafe_rounded, '4f3e2e', cafeName);
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, '/cafebul');
        },
      ),
    );
  }

  Widget buildCafeIcon(IconData icon, String hexColor, String cafeName) {
    Color squareColor = Color(int.parse('0xFF$hexColor'));
    Color backgroundColor = Color(0xFF37251b);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/qr');
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: squareColor,
                borderRadius: BorderRadius.circular(10),
              ),
              width: 80,
              height: 80,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Icon(
                  icon,
                  size: 60,
                  color: backgroundColor,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              cafeName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//menü sayfası
class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String? userId = '';
  String? userName = '';
  String? userSurname = '';
  String? userMail = '';

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Extract the user data
      String? id = prefs.getString('userId');
      String? name = prefs.getString('userName');
      String? surname = prefs.getString('userSurname');
      String? email = prefs.getString('userMail');

      setState(() {
        // Update the state variables
        userId = id;
        userName = name;
        userSurname = surname;
        userMail = email;
      });
    } catch (e) {
      // Handle network or other errors
      print('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Color(0xFF37251b); // Background color

    return Drawer(
      backgroundColor: backgroundColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: backgroundColor,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 10),
                Text(
                  'İsim: $userName',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Soyisim: $userSurname',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Hesap No: $userId',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Mail: $userMail',
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
              'CAFE BUL',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/cafebul');
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

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? userId = '';
  String? userName = '';
  String? userMail = '';

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Extract the user data
      String? id = prefs.getString('userId');
      String? name = prefs.getString('userName');
      String? email = prefs.getString('userMail');

      setState(() {
        // Update the state variables
        userId = id;
        userName = name;
        userMail = email;
      });
    } catch (e) {
      // Handle network or other errors
      print('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF37251B), // Set background color to the desired hex code
      appBar: AppBar(
        title: Text('Profil'),
        centerTitle: true,
        backgroundColor: Color(0xFF37251B), // Set app bar color to the desired hex code
        elevation: 0, // Set app bar elevation to 0
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 20), // Added SizedBox to add some space
          Align(
            alignment: Alignment.topCenter,
            child: CircleAvatar(
              radius: 80,
              backgroundImage: AssetImage('assets/images/default.jpg'),
            ),
          ),
          SizedBox(height: 20), // Added SizedBox to add some space
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'ID: $userId',
                  style: GoogleFonts.getFont(
                    'Righteous',
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10), // Added SizedBox to add some space
                Text(
                  'Name: $userName',
                  style: GoogleFonts.getFont(
                    'Righteous',
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10), // Added SizedBox to add some space
                Text(
                  'Email: $userMail',
                  style: GoogleFonts.getFont(
                    'Righteous',
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

//cafe bul sayfasi
class CafeBulSayfasi extends StatefulWidget {
  @override
  _CafeBulSayfasiState createState() => _CafeBulSayfasiState();
}

class _CafeBulSayfasiState extends State<CafeBulSayfasi> {
  Color backgroundColor = Color(0xFF37251b); // Background color
  String selectedCafe = '';
  List<String> kampanyalar = [
    '1 kahve alana 1 tane bedava',
    'tüm filtre kahvelerde %50 indirim',
    '100 ₺ üzeri kahve harcamasına 1 kahve hediye'
  ];
  String getRandomKampanya() {
    Random random = Random();
    return kampanyalar[random.nextInt(kampanyalar.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cafe Ekle'),
        backgroundColor: backgroundColor, // Set the app bar color here
        elevation: 0, // Set the elevation to 0 to remove the shadow
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Navigator.pushNamed(context, '/menu');
          },
        ),
      ),
      backgroundColor: backgroundColor,
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.0,
          crossAxisSpacing: 6,
          mainAxisSpacing: 12,
        ),
        padding: EdgeInsets.all(10),
        itemCount: 6, // Replace with the actual number of cafes
        itemBuilder: (BuildContext context, int index) {
          String cafeName = SecilenCafeler().cafeNames[index];
          return buildCafeIcon(Icons.local_cafe_rounded, '4f3e2e', cafeName);
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, '/cafebul');
        },
      ),
    );
  }

  Widget buildCafeIcon(IconData icon, String hexColor, String cafeName) {
    Color squareColor = Color(int.parse('0xFF$hexColor'));
    Color backgroundColor = Color(0xFF37251b);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                selectedCafe = cafeName;
              });
              showCafePopup(context, cafeName);
            },
            child: Container(
              decoration: BoxDecoration(
                color: squareColor,
                borderRadius: BorderRadius.circular(10),
              ),
              width: 80,
              height: 80,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Icon(
                  icon,
                  size: 60,
                  color: backgroundColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            cafeName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            style: TextButton.styleFrom(
              primary: Colors.white,
              backgroundColor: Color(0xFF505050),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
                side: BorderSide(
                  color: Color(0xFF4f3e2e),
                  width: 4.0,
                ),
              ),
              minimumSize: Size(80.0, 40.0),
            ),
            onPressed: () {
              SecilenCafeler.secilenCafeler.add(cafeName);
            },
            child: Text("Cafe'yi Ekle"),
          ),
        ],
      ),
    );
  }

  void showCafePopup(BuildContext context, String cafeName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cafe Popup'),
          content: Text('$cafeName için kampanyalar : ${getRandomKampanya()}'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Kapat'),
            ),
          ],
        );
      },
    );
  }
}

// kafelerin QR kodları sayfası
class qr extends StatefulWidget {
  @override
  QrScreen createState() => QrScreen();
}

class QrScreen extends State<qr> {
  final String cafeName = "Cafe";
  final IconData cafeIcon = Icons.local_cafe_rounded;

  @override
  Widget build(BuildContext context) {
    int generateRandomNumber() {
      Random customerNumber = Random();
      int min = 100000; // Minimum 6-digit number
      int max = 999999; // Maximum 6-digit number

      // Generate a random number between min and max (inclusive)
      return min + customerNumber.nextInt(max - min + 1);
    }
    String qrData = "QR Kod Verisi";

    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF), // Set background color to the desired hex code
      appBar: AppBar(
        backgroundColor: Color(0xFF37251B), // Set app bar color to the desired hex code
        elevation: 0, // Set app bar elevation to 0
        title: const Text(
          "QR KODUNUZ",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Navigator.pushNamed(context, '/menu');
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
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 75.0,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          const Text(
            "Müşteri numaranız",
            style: TextStyle(
              color: Colors.black,
              fontSize: 28.0,
            ),
          ),
          SizedBox(height: 5),
          Text(
            generateRandomNumber().toString(),
            style: const TextStyle(
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
