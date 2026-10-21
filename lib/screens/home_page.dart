import 'package:flutter/material.dart';
import 'chat_page.dart';
import '../widgets/animated_slider.dart';
import '../widgets/feature_card.dart';
import '../widgets/top_menu.dart';
import '../widgets/notification_banner.dart';

class HomePage extends StatelessWidget {
  final String username;
  const HomePage({super.key, required this.username});

  final List<Map<String, dynamic>> features = const [
    {'icon': Icons.leaderboard, 'label': 'Leaderboards'},
    {'icon': Icons.school, 'label': 'Find Tutor'},
    {'icon': Icons.location_on, 'label': 'Find Mission Places'},
    {'icon': Icons.flag, 'label': 'Start Mission'},
    {'icon': Icons.check_circle, 'label': 'Your Missions'},
    {'icon': Icons.explore, 'label': 'Use Mission'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, $username!'),
        actions: [TopMenu(username: username)],
      ),
      body: Column(
        children: [
          NotificationBanner(
            message: "Your request is ready. View it in AI chat.",
            visible: false,
          ),
          Expanded(
            flex: 3,
            child: AnimatedSlider(
              tips: [
                "Track your health progress.",
                "Start a wellness mission.",
                "Find experts around you.",
                "Monitor your nutrition.",
                "Chat with our AI Coach!",
              ],
            ),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children:
                    features.map((f) {
                      return GestureDetector(
                        onTap: () {
                          switch (f['label']) {
                            case 'Start Mission':
                              Navigator.pushNamed(context, '/start_mission');
                              break;
                            case 'Your Missions':
                              Navigator.pushNamed(
                                context,
                                'view_missions',
                                arguments: username,
                              );
                              break;
                            case 'Find Mission Places':
                              Navigator.pushNamed(
                                context,
                                'view_places'
                              );
                              break;
                            // TODO: Add more cases as needed
                            default:
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${f['label']} not implemented yet',
                                  ),
                                ),
                              );
                          }
                        },
                        child: FeatureCard(icon: f['icon'], label: f['label']),
                      );
                    }).toList(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChatPage()),
          );
        },
        child: const Icon(Icons.chat),
      ),
    );
  }
}
