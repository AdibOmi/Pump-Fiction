# Frontend Integration Guide for Posts API

This guide shows how to integrate the posts API with your Flutter frontend.

## API Service Class

Create a service class to handle API calls:

```dart
// lib/services/posts_api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class PostsApiService {
  static const String baseUrl = 'http://your-backend-url/posts';
  
  static Future<Map<String, dynamic>> createPost({
    required String token,
    String? content,
    List<File>? photos,
  }) async {
    var request = http.MultipartRequest('POST', Uri.parse(baseUrl + '/'));
    
    // Add authorization header
    request.headers['Authorization'] = 'Bearer $token';
    
    // Add content if provided
    if (content != null) {
      request.fields['content'] = content;
    }
    
    // Add photos if provided
    if (photos != null) {
      for (File photo in photos) {
        var multipartFile = await http.MultipartFile.fromPath(
          'photos',
          photo.path,
        );
        request.files.add(multipartFile);
      }
    }
    
    var response = await request.send();
    var responseBody = await response.stream.bytesToString();
    
    if (response.statusCode == 200) {
      return json.decode(responseBody);
    } else {
      throw Exception('Failed to create post: ${response.statusCode}');
    }
  }
  
  static Future<Map<String, dynamic>> getUserPosts({
    required int userId,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/$userId?page=$page&page_size=$pageSize'),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load posts: ${response.statusCode}');
    }
  }
  
  static Future<Map<String, dynamic>> getMyPosts({
    required String token,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/my-posts?page=$page&page_size=$pageSize'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load my posts: ${response.statusCode}');
    }
  }
  
  static Future<bool> deletePost({
    required String token,
    required int postId,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$postId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    
    return response.statusCode == 200;
  }
}
```

## Data Models

Create Dart models for the API responses:

```dart
// lib/models/post_model.dart
class Post {
  final int id;
  final int userId;
  final String? content;
  final String? imageUrl;
  final String? imagePath;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<PostPhoto> photos;
  final User user;

  Post({
    required this.id,
    required this.userId,
    this.content,
    this.imageUrl,
    this.imagePath,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.photos,
    required this.user,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      userId: json['user_id'],
      content: json['content'],
      imageUrl: json['image_url'],
      imagePath: json['image_path'],
      isActive: json['is_active'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      photos: (json['photos'] as List)
          .map((photo) => PostPhoto.fromJson(photo))
          .toList(),
      user: User.fromJson(json['user']),
    );
  }
}

class PostPhoto {
  final int id;
  final int postId;
  final String photoUrl;
  final String photoPath;
  final bool isPrimary;
  final DateTime createdAt;

  PostPhoto({
    required this.id,
    required this.postId,
    required this.photoUrl,
    required this.photoPath,
    required this.isPrimary,
    required this.createdAt,
  });

  factory PostPhoto.fromJson(Map<String, dynamic> json) {
    return PostPhoto(
      id: json['id'],
      postId: json['post_id'],
      photoUrl: json['photo_url'],
      photoPath: json['photo_path'],
      isPrimary: json['is_primary'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class User {
  final int id;
  final String email;

  User({required this.id, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
    );
  }
}

class PostsResponse {
  final List<Post> posts;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  PostsResponse({
    required this.posts,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory PostsResponse.fromJson(Map<String, dynamic> json) {
    return PostsResponse(
      posts: (json['posts'] as List)
          .map((post) => Post.fromJson(post))
          .toList(),
      total: json['total'],
      page: json['page'],
      pageSize: json['page_size'],
      totalPages: json['total_pages'],
    );
  }
}
```

## Profile Page Widget

Create a widget to display user posts on a profile page:

```dart
// lib/widgets/user_posts_widget.dart
import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../services/posts_api_service.dart';

class UserPostsWidget extends StatefulWidget {
  final int userId;
  final bool isMyProfile;

  const UserPostsWidget({
    Key? key,
    required this.userId,
    this.isMyProfile = false,
  }) : super(key: key);

  @override
  _UserPostsWidgetState createState() => _UserPostsWidgetState();
}

class _UserPostsWidgetState extends State<UserPostsWidget> {
  List<Post> posts = [];
  bool isLoading = true;
  bool hasError = false;
  int currentPage = 1;
  bool hasMorePages = true;

  @override
  void initState() {
    super.initState();
    loadPosts();
  }

  Future<void> loadPosts() async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
      });

      PostsResponse response;
      if (widget.isMyProfile) {
        // Load current user's posts (requires authentication)
        final token = await getAuthToken(); // Implement this method
        response = PostsResponse.fromJson(
          await PostsApiService.getMyPosts(token: token, page: currentPage),
        );
      } else {
        // Load specific user's posts (public)
        response = PostsResponse.fromJson(
          await PostsApiService.getUserPosts(
            userId: widget.userId,
            page: currentPage,
          ),
        );
      }

      setState(() {
        if (currentPage == 1) {
          posts = response.posts;
        } else {
          posts.addAll(response.posts);
        }
        hasMorePages = currentPage < response.totalPages;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      print('Error loading posts: $e');
    }
  }

  Future<void> loadMorePosts() async {
    if (!hasMorePages || isLoading) return;
    
    currentPage++;
    await loadPosts();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading && posts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (hasError && posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Failed to load posts'),
            ElevatedButton(
              onPressed: () {
                currentPage = 1;
                loadPosts();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (posts.isEmpty) {
      return const Center(
        child: Text(
          'No posts yet',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () {
        currentPage = 1;
        return loadPosts();
      },
      child: ListView.builder(
        itemCount: posts.length + (hasMorePages ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == posts.length) {
            // Load more indicator
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final post = posts[index];
          return PostCard(
            post: post,
            isMyPost: widget.isMyProfile,
            onDelete: widget.isMyProfile ? () => deletePost(post.id) : null,
          );
        },
      ),
    );
  }

  Future<void> deletePost(int postId) async {
    try {
      final token = await getAuthToken();
      final success = await PostsApiService.deletePost(
        token: token,
        postId: postId,
      );

      if (success) {
        setState(() {
          posts.removeWhere((post) => post.id == postId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post deleted successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete post: $e')),
      );
    }
  }

  Future<String> getAuthToken() async {
    // Implement your authentication token retrieval logic
    throw UnimplementedError('Implement token retrieval');
  }
}
```

## Post Card Widget

Create a widget to display individual posts:

```dart
// lib/widgets/post_card.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/post_model.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final bool isMyPost;
  final VoidCallback? onDelete;

  const PostCard({
    Key? key,
    required this.post,
    this.isMyPost = false,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info header
          ListTile(
            leading: CircleAvatar(
              child: Text(post.user.email[0].toUpperCase()),
            ),
            title: Text(post.user.email),
            subtitle: Text(_formatDateTime(post.createdAt)),
            trailing: isMyPost
                ? PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'delete',
                        child: const Text('Delete'),
                        onTap: onDelete,
                      ),
                    ],
                  )
                : null,
          ),
          
          // Post content
          if (post.content != null && post.content!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(post.content!),
            ),
          
          // Photos
          if (post.photos.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildPhotosGrid(post.photos),
          ],
          
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildPhotosGrid(List<PostPhoto> photos) {
    if (photos.length == 1) {
      return Container(
        height: 300,
        width: double.infinity,
        child: CachedNetworkImage(
          imageUrl: photos[0].photoUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => 
              const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) => 
              const Icon(Icons.error),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: photos.length == 2 ? 2 : 3,
        childAspectRatio: 1,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        return CachedNetworkImage(
          imageUrl: photos[index].photoUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => 
              const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) => 
              const Icon(Icons.error),
        );
      },
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
```

## Usage in Profile Page

```dart
// In your profile page widget
class ProfilePage extends StatelessWidget {
  final int userId;
  final bool isMyProfile;

  const ProfilePage({
    Key? key,
    required this.userId,
    this.isMyProfile = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Column(
        children: [
          // Profile info section
          // ... other profile widgets
          
          // Posts section
          Expanded(
            child: UserPostsWidget(
              userId: userId,
              isMyProfile: isMyProfile,
            ),
          ),
        ],
      ),
    );
  }
}
```

This integration guide provides a complete frontend implementation for displaying and managing posts in your Flutter app!