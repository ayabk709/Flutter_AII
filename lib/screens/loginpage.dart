import 'package:flutter/material.dart';
import 'package:lab12_m22/screens/home_page.dart';
import 'package:lab12_m22/screens/registerPage.dart';
import 'package:lab12_m22/service/AuthService.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String email = '';
  String password = '';
  final _formKey = GlobalKey<FormState>();
  final AuthService _auth = AuthService(); // Create an instance of AuthService
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        
        
        backgroundColor: Colors.pinkAccent,

        title: Text('Login COVIDTracker', style: TextStyle(color: Colors.white,fontSize: 19)),
          
        actions: <Widget>[
          TextButton.icon(
            onPressed: () {
              // Navigate to the Register page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Register()),
              );
            },
            icon: Icon(Icons.person, color: Colors.white),
            label: Text('Register', style: TextStyle(color: Colors.white,fontSize: 15),),
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 60.0, horizontal: 50.0),
        child: Form(
          key: _formKey,
          child: Column(
            
            children: <Widget>[
              //suze of
              Image.asset('assets/images/covid.png', height: 150, width: 150),
             

              const SizedBox(height: 100.0),
              TextFormField(
                decoration: InputDecoration(
                  border: UnderlineInputBorder(
                  borderRadius:BorderRadius.circular(10.0)),
                  hintText: 'Email',
                  prefixIcon: Icon(Icons.person),
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding: EdgeInsets.all(20.0),

                ),
                //text styling
                      style: TextStyle(fontSize: 20), 
                      //: The onChanged callback is called every time the user types something
                      // into the text field. It takes a single argument (val), which represents the current value of the text field.
                onChanged: (val) {
                  setState(() {
                    email = val;
                  });
                },
                validator: (val) => val!.isEmpty ? 'Enter a valid email' : null,
              ),


              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  border: UnderlineInputBorder(
                  borderRadius:BorderRadius.circular(10.0)),
                  hintText: 'Password',
                
                  prefixIcon: Icon(Icons.lock),
                  fillColor: Colors.white,
                  filled: true,
                   contentPadding: EdgeInsets.all(20.0),
                ),
                style: TextStyle(fontSize: 20), 
                onChanged: (val) {
                  setState(() {
                    password = val;
                  });
                },
                validator: (val) => val!.length < 6 ? 'Enter a valid password (6+ chars)' : null,
                obscureText: true,
              ),
              /// widget in Flutter. Specifically, it is a box with a fixed size that can be used to create space between other widgets in your layout.
              /// 
              SizedBox(height: 20),
              ElevatedButton(

                child: Text('Sign In', style: TextStyle(color: Colors.white, fontSize: 20)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.pink,fixedSize: const Size(3000, 50),shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),maximumSize: Size(300, 50)),
                
                


                onPressed: () async {
                  // It first validates the form using _formKey.
                  if (_formKey.currentState!.validate()) {
                    // Call the AuthService's sign-in method
                    dynamic result = await _auth.signInWithEmailAndPassword(email, password);
                    if (result == null) {
                      // Handle sign-in error
                      setState(() {
                        error = 'Error signing in! Please check your credentials.';
                      });
                    } else {
                      // Successful sign-in
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
                    }
                  }
                },
              ),
              SizedBox(height: 12.0),
              Text(
                error,
                style: TextStyle(color: const Color.fromARGB(255, 192, 27, 82), fontSize: 14.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
