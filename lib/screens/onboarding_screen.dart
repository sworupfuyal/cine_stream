import 'package:flutter/material.dart';
import 'package:cine_stream/widgets/app_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int currentPage = 0;
  bool isLoading = false;

  void navigateToSignup() {
    Navigator.pushReplacementNamed(context, "/signup");
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    final double verticalPadding = isTablet ? 60 : 40;
    final double titleSize = isTablet ? 34 : 26;
    final double subtitleSize = isTablet ? 20 : 14;
    final double imageHeight = isTablet ? size.height * 0.45 : size.height * 0.35;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isTablet ? 60 : 24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: navigateToSignup,
                  child: const Text(
                    "Skip",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),

              Expanded(
                child: PageView(
                  controller: _controller,
                  onPageChanged: (index) => setState(() => currentPage = index),
                  children: [
                    _onboardingPage(
                      imageHeight,
                      titleSize,
                      subtitleSize,
                      "Discover Movies & Shows",
                      "Find trending movies and series curated just for you.",
                      "assets/images/moviewall1.png",
                    ),
                    _onboardingPage(
                      imageHeight,
                      titleSize,
                      subtitleSize,
                      "Personalized Recommendations",
                      "Enjoy content tailored to your taste and viewing habits.",
                      "assets/images/moviewall1.png",
                    ),
                    _onboardingPage(
                      imageHeight,
                      titleSize,
                      subtitleSize,
                      "Stream Anytime, Anywhere",
                      "Watch your favorite movies without limits.",
                      "assets/images/moviewall1.png",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  bool active = index == currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 18 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active ? Colors.redAccent : Colors.grey.shade700,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                }),
              ),

              SizedBox(height: verticalPadding),

              AppButton(
                text: currentPage == 2 ? "Get Started" : "Next",
                isLoading: isLoading,
                onPressed: () {
                  if (currentPage < 2) {
                    _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut);
                  } else {
                    navigateToSignup();
                  }
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _onboardingPage(
    double imageH,
    double titleSize,
    double subtitleSize,
    String title,
    String subtitle,
    String imagePath,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: imageH,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
            ),
          ),
        ),

        const SizedBox(height: 40),

        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 12),

        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: subtitleSize,
            height: 1.4,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}
