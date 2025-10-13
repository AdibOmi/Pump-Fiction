import 'package:flutter/material.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _captionController = TextEditingController();
  String? _selectedImage;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('New Post'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          TextButton(
            onPressed: () {
              // Handle post creation
              _createPost();
            },
            child: const Text(
              'Share',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image selection area
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _selectedImage != null
                  ? Image.network(_selectedImage!, fit: BoxFit.cover)
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate,
                          size: 80,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _selectImage,
                          child: const Text('Select Photo'),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 20),

            // Caption input
            const Text(
              'Caption',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _captionController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Write a caption...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Location section
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Add Location'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Handle location selection
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Location feature coming soon!'),
                  ),
                );
              },
            ),

            // Tag people section
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Tag People'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Handle tagging people
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tag people feature coming soon!'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _selectImage() {
    // Simulate image selection
    setState(() {
      _selectedImage = 'https://via.placeholder.com/400x300';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Image selected! (This is a placeholder)')),
    );
  }

  void _createPost() {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first')),
      );
      return;
    }

    // Handle post creation logic here
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Post created successfully!')));

    // Navigate back to social page
    Navigator.pop(context);
  }
}
