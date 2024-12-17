import 'package:flutter/material.dart';
import 'package:lab12_m22/service/AuthService.dart';

// Import your AuthService class

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String email = '';
  String password = '';
  final _formKey = GlobalKey<FormState>();
  String error = '';
  final AuthService _auth = AuthService(); // Create an instance of AuthService

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: const Text('Register Page'),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 60.0, horizontal: 50.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
Image.asset('assets/images/covid.png', height: 150, width: 150),
              const SizedBox(height: 100.0),
              TextFormField(
                decoration:  InputDecoration(
                  border: UnderlineInputBorder(
                  borderRadius:BorderRadius.circular(10.0)),
                  hintText: 'Email',
                  prefixIcon: Icon(Icons.person),
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding: EdgeInsets.all(20.0),
                ),
                 style: TextStyle(fontSize: 20), 
                onChanged: (val) {
                  setState(() {
                    email = val;
                  });
                },
                validator: (val) => val == null || val.isEmpty ? 'Enter a valid email' : null,
              ),
              SizedBox(height: 20.0),
              TextFormField(
                decoration: InputDecoration(
                  border: UnderlineInputBorder(
                  borderRadius:BorderRadius.circular(10.0)),
                  hintText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  fillColor: Colors.white,
                  filled: true,
                contentPadding: const EdgeInsets.all(20.0),
                ),
                style: TextStyle(fontSize: 20), 
                onChanged: (val) {
                  setState(() {
                    password = val;
                  });
                },
                validator: (val) => (val == null || val.length < 6) 
                    ? 'Enter a valid password (6+ chars)' : null,
                obscureText: true,
              ),
            SizedBox(height: 20.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent,fixedSize: const Size(3000, 50),shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),maximumSize: Size(300, 50)),
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    // Call the AuthService's register method
                    dynamic result = await _auth.registerWithEmailAndPassword(email, password);
                    if (result == null) {
                      setState(() {
                        error = 'Please enter a valid email or password'; // Error message
                      });
                    } else {
                      Navigator.pop(context); // Navigate back or to another page after registration
                    }
                  }
                },
                child: const Text(
                  'Sign Up',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                  
                ),
              ),
              const SizedBox(height: 12.0),
              Text(
                error,
                style: const TextStyle(color: Colors.red, fontSize: 14.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
