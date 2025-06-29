import 'package:flutter/material.dart';
import '../../data/models/onboarding_item_model.dart';
import '../widgets/onboarding_page_content.dart';
import '../../../auth/presentation/screens/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItemModel> _onboardingItems = [
    OnboardingItemModel(
    imagePath: 'assets/images/img4.png',
    title: 'Bienvenue sur Yollë',
    description: 'La plateforme citoyenne pour signaler les injustices, abus et problèmes publics en toute simplicité.',

    ),
    OnboardingItemModel(
      imagePath: 'assets/images/img6.png',
      title: 'Signalez un problème',
      description: 'Lancez une alerte en cas de hausse des prix, de drogues, de pratiques illégales, et plus encore.',
    ),
    OnboardingItemModel(
      imagePath: 'assets/images/img8.png',
      title: 'Un Sénégal meilleur',
      description: 'Commence par un geste simple. Accédez aux services et lancez des alertes facilement.',
    ),
  ];

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _goToNext() {
    if (_currentPage < _onboardingItems.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  void _goToPrevious() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _onboardingItems.length,
            itemBuilder: (context, index) {
              return OnboardingPageContent(item: _onboardingItems[index]);
            },
          ),
          Positioned(
            bottom: 60.0,
            left: 24.0,
            right: 24.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                (_currentPage == 0)
                    ? TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          );
                        },
                        child: const Text('Passer', style: TextStyle(color: Colors.grey)),
                      )
                    : ElevatedButton(
                        onPressed: _goToPrevious,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        child: const Text('Précédent'),
                      ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.generate(_onboardingItems.length, (int index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      height: 8.0,
                      width: (index == _currentPage) ? 24.0 : 8.0,
                      decoration: BoxDecoration(
                        color: (index == _currentPage)
                            ? Theme.of(context).primaryColor
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    );
                  }),
                ),
                ElevatedButton(
                  onPressed: _goToNext,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: Text(
                    _currentPage < _onboardingItems.length - 1 ? 'Suivant' : 'Terminer',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
