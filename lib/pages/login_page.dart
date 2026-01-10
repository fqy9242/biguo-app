import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  final Function(String username) onLoginSuccess;

  const LoginPage({Key? key, required this.onLoginSuccess}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';
  bool _isLoading = false;

  void _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      setState(() {
        _isLoading = true;
      });

      // 模拟登录延迟
      await Future.delayed(const Duration(seconds: 1));

      // 模拟登录成功
      widget.onLoginSuccess(_username);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('登录'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              // 应用Logo
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.blue, Colors.purple],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      '题库',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              // 用户名输入
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '用户名',
                  hintText: '请输入用户名',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                onSaved: (value) => _username = value!,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return '请输入用户名';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // 密码输入
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '密码',
                  hintText: '请输入密码',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                onSaved: (value) => _password = value!,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return '请输入密码';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              // 登录按钮
              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('登录'),
              ),
              const SizedBox(height: 16),
              // 测试账号提示
              Center(
                child: Column(
                  children: [
                    const Text('测试账号：'),
                    Text('用户名：test'),
                    Text('密码：123456'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
