import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_drawer.dart';
import 'create_post_page.dart';

class SocialPage extends StatefulWidget {
  const SocialPage({super.key});

  @override
  State<SocialPage> createState() => _SocialPageState();
}

class _SocialPageState extends State<SocialPage> {
  int _selectedIndex = 0;

  // Empty list - posts will be populated when user creates them
  // In a real app, this would come from your backend/API for the current user only
  List<String> userPosts = [];

  List<Widget> get _pages => [
    // Updated Social Profile Page
    Center(
      child: Column(
        children: [
          const SizedBox(height: 20),
          const CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(
              'https://images.unsplash.com/photo-1633332755192-727a05c4013d?q=80&w=150&h=150&fit=crop',
            ), // Real profile image instead of placeholder
          ),
          const SizedBox(height: 10),
          const Text(
            'John Doe',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          const Text(
            'Fitness enthusiast | Traveler | Foodie',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text(
                    '${userPosts.length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Posts',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
              const Column(
                children: [
                  Text(
                    '2.5K',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Followers',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
              const Column(
                children: [
                  Text(
                    '300',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Following',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          Expanded(
            child: userPosts.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.photo, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No posts yet',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Share your first post!',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                        ),
                    itemCount: userPosts.length,
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          userPosts[index],
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.error,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    ),
    const Center(child: Text('Feed Page')), // Placeholder for Feed Page
    const Center(child: Text('Search Page')), // Placeholder for Search Page
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Social'),
      drawer: const CustomDrawer(),
      body: IndexedStack(
        index: _selectedIndex == 3 ? 2 : _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 2) {
            // Navigate to Create Post page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreatePostPage()),
            );
          } else {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.feed), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Create'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        ],
      ),
    );
  }
}
