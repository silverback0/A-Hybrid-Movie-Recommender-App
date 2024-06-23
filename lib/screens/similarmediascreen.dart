import 'package:flutter/material.dart';
import 'package:my_movie_recommender_app/movie.dart';
import '../mediadetailspage.dart';
import '../user_ratings.dart';

class SimilarMediaScreen extends StatelessWidget {
  final List<dynamic> similarMedia;

  const SimilarMediaScreen({Key? key, required this.similarMedia})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Similar Media'),
      ),
      body: ListView.builder(
        itemCount: similarMedia.length,
        itemBuilder: (context, index) {
          final dynamic item = similarMedia[index];
          if (item is Media) {
            final Media media = item;
            return MediaCard(
              media: media,
              onAddToWatchlist: (Media media) {},
            );
          } else {
            // Handle other types of items if needed
            return Container();
          }
        },
      ),
    );
  }
}

class MediaCard extends StatelessWidget {
  final Media media;

  const MediaCard({
    Key? key,
    required this.media,
    required void Function(Media media) onAddToWatchlist,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Image.network(media.posterUrl),
        title: Text(media.title),
        subtitle: Text(media.genreNames.join(', ')),
        onTap: () {
          // Handle tapping on a similar media item
          // For example, navigate to the details page of the selected media
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MediaDetailsPage(
                media: media,
                onRate: (double) {},
                ratingsService: UserRatingsService(),
              ),
            ),
          );
        },
      ),
    );
  }
}
