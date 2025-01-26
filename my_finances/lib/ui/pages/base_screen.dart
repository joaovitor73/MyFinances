import 'package:flutter/material.dart';

class BaseScreen extends StatefulWidget {
  final Widget child;
  final int currentIndex;

  const BaseScreen({
    required this.child,
    required this.currentIndex,
    super.key,
  });

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  final List<String> _routes = [
    '/home',
    '/list_despesas',
    '/add_limit_categoria',
  ];

  void _onItemTapped(int index) {
    if (index != widget.currentIndex) {
      Navigator.pushReplacementNamed(context, _routes[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: widget.currentIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Despesas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Limites Categoria',
          ),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
      ),
    );
  }
}
