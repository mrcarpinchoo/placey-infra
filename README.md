# Placey

**Placey** is a proximity-based application that helps users discover
nearby recreational places based on their current location. The platform
allows users to quickly find places such as restaurants, cafes, parks,
cinemas, and shopping centers within a configurable radius.

The goal of Placey is to provide a fast and intuitive way to explore
recreational locations nearby using geospatial search and
proximity-based queries.

## Project Overview

Placey enables users to search for nearby places using their geographic
coordinates. The system performs efficient proximity searches to return
relevant locations sorted by distance and optionally filtered by
category.

The project is designed as a **distributed system with a polyrepo
architecture**, separating infrastructure, backend services, and
frontend applications into independent repositories.

This structure allows each component of the system to evolve and be
deployed independently while maintaining clear separation of concerns.

## Core Features

-   Discover places near the user's location
-   Filter places by category
-   Search within a configurable radius
-   Sort results by distance
-   Display place details (name, category, location, rating)

## Supported Place Categories

Placey focuses on **recreational and leisure locations** organized into
five categories:

1. **Food & Drinks** (e.g., restaurants, cafes, bakeries, ice cream shops)
2. **Entertainment** (e.g., cinemas, arcades, bowling alleys, concert halls)
3. **Shopping** (e.g., shopping malls, bookstores, supermarkets)
4. **Outdoor Recreation** (e.g., parks, beaches, hiking trails)
5. **Social / Leisure Venues** (e.g., nightclubs, karaoke bars, comedy clubs)

## System Architecture

Placey follows a polyrepo architecture composed of three main
repositories:
- placey-infra
- placey-backend
- placey-frontend

### Infrastructure Repository (`placey-infra`)

Responsible for provisioning and managing cloud resources.

Responsibilities may include:

-   Infrastructure as Code
-   Cloud networking
-   Database provisioning
-   Container orchestration
-   Deployment configuration

Potential technologies:

-   Terraform
-   AWS

### Backend Repository (`placey-backend`)

Implements the core application logic and APIs.

Responsibilities:

-   REST API
-   proximity search logic
-   geospatial queries
-   database interactions
-   place management

Example endpoints:
- `GET /places`
- `POST /places`

### Frontend Repository (`placey-frontend`)

Provides the user interface.

Responsibilities:

-   Map interface
-   search interface
-   category filters
-   displaying nearby places

Possible technologies:

-   React
-   Map libraries (OpenStreetMap, Mapbox)

## Core System Flow

1.  The user opens the application and provides location access.
2.  The frontend sends the user's coordinates to the backend API.
3.  The backend performs a geospatial query (possibly using geospatial hashes) to find nearby places.
4.  Results are filtered and sorted by distance.
5.  The frontend displays nearby places to the user.

## Geospatial Search

Placey relies on **geospatial indexing** to efficiently find nearby
locations.

Example query: Find all places within 2 km of a given latitude and longitude.

Possible implementation options:

-   PostgreSQL with PostGIS
-   Redis GEO commands

## Example API Request

`GET /places?lat=20.67&lon=-103.34&radius=2000`

Example response:

``` plaintext
[
    {
        "name": "Central Park",
        "category": "park",
        "distance": "450m"
    },
    {
        "name": "City Cinema",
        "category": "cinema",
        "distance": "900m"
    }
]
```

## Data Model (Conceptual)

Data model will be provided later.

## Project Goals

The purpose of this project is to explore the design and implementation
of an MVP **location-based proximity service** for a System Design class, focusing on:

-   geospatial data handling
-   scalable system architecture
-   efficient location queries
-   distributed application design

## Future Enhancements (Optional)

Potential extensions to the system may include:

-   user accounts
-   reviews and ratings
-   personalized recommendations
-   trending places
-   caching popular searches
-   real-time analytics

## Authors

This project is being developed as part of a **System Design course**.

Project contributors: - (Add team members here)
Project contributors: - (Add team members here)
Project contributors: - (Add team members here)

## License

This project is intended for educational purposes.
