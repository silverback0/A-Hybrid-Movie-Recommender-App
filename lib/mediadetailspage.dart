import 'package:flutter/material.dart';
import 'movie.dart';
import 'user_ratings.dart';

class MediaDetailsPage extends StatefulWidget {
  final Media media;
  final Function(double) onRate;
  final UserRatingsService ratingsService;

  const MediaDetailsPage(
      {Key? key,
      required this.media,
      required this.onRate,
      required this.ratingsService})
      : super(key: key);

  @override
  _MediaDetailsPageState createState() => _MediaDetailsPageState();
}

class _MediaDetailsPageState extends State<MediaDetailsPage> {
  double _userRating = 0.0;

  // Function to update the rating
  void _updateUserRating(Media media, double rating) {
    widget.onRate(rating);
    setState(() {
      media.userRating = rating;
    });
  }

  @override
  void initState() {
    super.initState();
    // Use the media's userRating to initialize the _userRating
    _userRating = widget.media.userRating;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.media.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          widget.media.posterUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      'Rating: ${widget.media.rating}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8.0),
                    const Text(
                      'Description:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(widget.media.description),
                    const SizedBox(height: 8.0),
                    const Text(
                      'Cast:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Wrap(
                      children: widget.media.cast
                          .map((actor) => Text(actor))
                          .toList(),
                    ),
                    const SizedBox(height: 8.0),
                    const Text(
                      'Characters:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Wrap(
                      children: widget.media.characters
                          .map((character) => Text(character))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Go Back'),
            ),
            if (widget.media.userRating == 0.0)
              // Show rating input if the movie hasn't been rated yet
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16.0),
                  const Text(
                    'Rate this movie:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Slider(
                    value: _userRating,
                    min: 0.0,
                    max: 10.0,
                    divisions: 10,
                    onChanged: (value) {
                      setState(() {
                        _userRating = value;
                      });
                    },
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await widget.ratingsService.addUserRating(
                          widget.media.id.toString(), _userRating);
                      widget.onRate(
                          _userRating); // Pass the rating back to the WatchlistScreen
                      Navigator.pop(context);
                    },
                    child: const Text('Submit'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
