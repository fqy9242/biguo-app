import 'package:flutter/material.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  final String? loggedInUser;
  final Function() onLogout;

  const ProfilePage({Key? key, this.loggedInUser, required this.onLogout})
    : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('个人中心'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 用户信息卡片
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // 用户头像
                    Container(
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
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 用户名
                    Text(
                      widget.loggedInUser ?? '未登录',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // 登录状态
                    Text(
                      widget.loggedInUser != null ? '已登录' : '未登录',
                      style: TextStyle(
                        color: widget.loggedInUser != null
                            ? Colors.green
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // 功能菜单
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildMenuItem('我的题库', Icons.book, () {
                    Navigator.pop(context);
                  }),
                  const Divider(height: 1),
                  _buildMenuItem('学习记录', Icons.history, () {
                    _showMessage('学习记录功能开发中');
                  }),
                  const Divider(height: 1),
                  _buildMenuItem('收藏题目', Icons.star, () {
                    _showMessage('收藏题目功能开发中');
                  }),
                  const Divider(height: 1),
                  _buildMenuItem('设置', Icons.settings, () {
                    _showMessage('设置功能开发中');
                  }),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // 登出按钮
            if (widget.loggedInUser != null)
              ElevatedButton.icon(
                onPressed: widget.onLogout,
                icon: const Icon(Icons.logout),
                label: const Text('登出'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            // 登录按钮
            if (widget.loggedInUser == null)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  // 跳转到登录页面
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginPage(
                        onLoginSuccess: (username) {
                          // 登录成功后刷新个人中心页面
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfilePage(
                                loggedInUser: username,
                                onLogout: widget.onLogout,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.login),
                label: const Text('登录'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            // 版本信息
            Center(
              child: Text(
                '版本 1.0.0',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建菜单项
  Widget _buildMenuItem(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  // 显示消息提示
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}
