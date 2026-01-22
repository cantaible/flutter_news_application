import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_news_application/config/app_config.dart';
import 'package:flutter_news_application/models/news_source.dart';
import 'package:flutter_news_application/widgets/news_source_list_item.dart';

class NewsSourcePage extends StatefulWidget {
  const NewsSourcePage({super.key});

  @override
  State<NewsSourcePage> createState() => _NewsSourcePageState();
}

class _NewsSourcePageState extends State<NewsSourcePage> {
  String _sourceType = 'rss';
  bool _enabled = true;
  bool _isSubmitting = false;
  List<NewsSource> _sources = <NewsSource>[];

  @override
  void initState() {
    super.initState();
    // Fetch existing sources when the page is created.
    _fetchFeedItems();
  }

  Future<void> _fetchFeedItems() async {
    // Low-level HTTP client; no extra package needed.
    final HttpClient client = HttpClient();
    try {
      final Uri uri = Uri.parse('${AppConfig.baseUrl}/api/feeditems');
      final HttpClientRequest request = await client.getUrl(uri);
      final HttpClientResponse response = await request.close();
      // Read the full response body as a string.
      final String body = await response.transform(utf8.decoder).join();
      if (response.statusCode != 200) {
        throw HttpException(
          'Failed to fetch feed items: ${response.statusCode}',
          uri: uri,
        );
      }
      // Parse JSON and convert "data" to a list of NewsSource.
      final Map<String, dynamic> json =
          jsonDecode(body) as Map<String, dynamic>;
      final List<dynamic> data = json['data'] as List<dynamic>;
      final List<NewsSource> sources = data
          .map((item) => NewsSource.fromJson(item as Map<String, dynamic>))
          .toList();

      if (!mounted) {
        return;
      }

      setState(() {
        _sources = sources;
      });
    } finally {
      // Always close the client to free resources.
      client.close();
    }
  }

  Future<void> _handleSubmit() async {
    setState(() {
      _isSubmitting = true;
    });

    // TODO: Replace with real API call.
    await Future<void>.delayed(const Duration(seconds: 2));

    if (!mounted) {
      return;
    }

    setState(() {
      _isSubmitting = false;
    });
  } // Future<void> _handleSubmit()

  @override
  Widget build(BuildContext context) {
    final BorderRadius borderRadius = BorderRadius.circular(16);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: InkWell(
              borderRadius: borderRadius,
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          // Expanded在 Row/Column 里让子组件“占满剩余空间”，并按 flex 比例分配。
                          flex: 3,
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Name',
                            ),
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            initialValue: _sourceType,
                            decoration: const InputDecoration(
                              labelText: 'Source Type',
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'rss',
                                child: Text('RSS'),
                              ),
                              DropdownMenuItem(
                                value: 'web',
                                child: Text('Web'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value == null) {
                                return;
                              }
                              setState(() {
                                _sourceType = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'URL'),
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Switch(
                                value: _enabled,
                                onChanged: (value) {
                                  setState(() {
                                    _enabled = value;
                                  });
                                },
                              ),
                              const Text('Enabled'),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _handleSubmit,
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Add Source'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _sources.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    const SizedBox(height: 12),
                    NewsSourceListItem(source: _sources[index]),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
