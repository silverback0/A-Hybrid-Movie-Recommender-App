# Hybrid Movie Recommender App

A Flutter-based hybrid movie recommendation system combining machine learning and real-time movie data to deliver personalized movie suggestions using a FastAPI backend, Firebase services, and the TMDB API.

---

## Project Overview

This application integrates content-based filtering and collaborative filtering techniques to generate personalized movie recommendations.

It combines the MovieLens dataset with live metadata from TMDB to provide a dynamic movie discovery experience.

Users can search for movies, view details, receive recommendations, and manage their watchlists through a mobile application built with Flutter.

---

## Features

- Hybrid recommendation engine using content-based and collaborative filtering
- TF-IDF and cosine similarity for content-based recommendations
- User-based collaborative filtering using ratings
- Firebase authentication and user management
- Movie search using TMDB API
- Trending and recommended movies
- Personalized recommendations
- Movie rating system
- Watchlist functionality
- FastAPI backend for recommendation processing
- Firebase Remote Config integration

---

## Recommendation System Architecture

The system combines multiple approaches:

### Content-Based Filtering
Movies are recommended based on similarity in metadata such as genres. TF-IDF vectorization and cosine similarity are used to compute relationships between movies.

### Collaborative Filtering
Recommendations are generated based on user rating patterns and similarities between users with similar preferences.

### Hybrid Model
The final recommendation score is produced by combining results from both content-based and collaborative filtering methods to improve accuracy.

---

## Application Flow

1. User creates an account or logs in
2. Movies are fetched from TMDB API
3. User searches, views, or rates movies
4. The Flutter app sends a request to the FastAPI backend
5. The recommendation engine processes the request
6. Personalized recommendations are returned
7. Results are displayed in the application

---

## Dataset

The recommendation system uses the MovieLens Latest Small dataset, which includes:

- movies.csv
- ratings.csv
- links.csv
- tags.csv

---

## Screenshots
<p align="center">
  <img src="screenshots/home.jpg" width="400" height="450"/>
  <img src="screenshots/search.jpg" width="400" height="450"/>
</p>

<p align="center">
  <img src="screenshots/details.jpg" width="400" height="450"/>
  <img src="screenshots/poster.jpg" width="400" height="450"/>
</p>

<p align="center">
  <img src="screenshots/movies.jpg" width="400" height="450"/>
  <img src="screenshots/recommendations.jpg" width="400" height="450"/>
</p>

<p align="center">
  <img src="screenshots/similar.jpg" width="400" height="600"/>
  <img src="screenshots/watchlist.jpg" width="400" height="600"/>
</p>

---

## Limitations

- Backend was developed and tested in a local environment during development
- Watchlist persistence is partially implemented
- The application is currently Android-focused
- Recommendation quality depends on dataset size and sparsity

---

## Future Improvements

- Deploy FastAPI backend to cloud platforms such as Render or Railway
- Improve watchlist synchronization across devices
- Add iOS and web support
- Improve recommendation ranking algorithms
- Add Docker support for backend deployment
- Explore deep learning-based recommendation models

---

## Setup Instructions

1. Clone the repository
2. Install Flutter dependencies:
   ```
   flutter pub get
   ```
3. Run FastAPI backend:
   ```
   uvicorn main:app --host 0.0.0.0 --port 8000
   ```
4. Run Flutter application:
   ```
   flutter run
   ```

---

## Author

Chris Ngatia  
Software Developer | Flutter and AI Enthusiast
