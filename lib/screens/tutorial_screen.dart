// tutorial_screen.dart
import 'package:flutter/material.dart';

import 'home_screen.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({Key? key}) : super(key: key);

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> tutorialData = [
    {
      "title": "Bienvenido a QuipuTalk",
      "description": "Aquí podrás traducir lenguaje de señas a texto y generar respuestas.",
      "image": "assets/tutorial/tutorial_img1.png",
    },
    {
      "title": "Graba tu Seña",
      "description": "Usa la cámara para grabar tu seña y nuestro sistema la traducirá.",
      "image": "assets/tutorial/tutorial_img2.png",
    },
    {
      "title": "Elije tu respuesta",
      "description": "Puedes usar una respuesta generada por nuestro sistema o puedes escribir la tuya.",
      "image": "assets/tutorial/tutorial_img3.png",
    },
  ];

  void _goToNextPage() {
    if (_currentPage < tutorialData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      // Navegar al HomeScreen al finalizar el tutorial
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          itemCount: tutorialData.length,
          itemBuilder: (context, index) {
            final item = tutorialData[index];
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Text(
                    item["title"] ?? "",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Image.asset(
                      item["image"] ?? "",
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    item["description"] ?? "",
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _goToNextPage,
                    child: Text(
                      index == tutorialData.length - 1
                          ? "¡Empecemos!"
                          : "Siguiente",
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Indicadores de página
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(tutorialData.length, (dotIndex) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == dotIndex ? 16 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == dotIndex
                              ? Colors.blue
                              : Colors.grey,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
