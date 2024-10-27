import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Sign Up",
                style: TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              SizedBox(height: 30.0),
              _buildSignUpForm(),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _signUp,
                child: Text("Sign Up"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 50.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: "Email",
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty || !value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          SizedBox(height: 20.0),
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              labelText: "Password",
              prefixIcon: Icon(Icons.lock),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty || value.length < 6) {
                return 'Password must be at least 6 characters long';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  void _signUp() {
    if (_formKey.currentState!.validate()) {
      // Perform sign-up action
      print("Sign-up successful");
    }
  }
}
