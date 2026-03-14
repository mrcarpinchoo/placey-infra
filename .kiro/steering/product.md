# Placey - Product Overview

Placey is a proximity-based application that helps users discover nearby recreational places based on their current location.

## Core Purpose

Users provide their geographic coordinates and Placey returns nearby places sorted by distance, optionally filtered by category and configurable radius.

## Supported Place Categories

1. Food & Drinks (restaurants, cafes, bakeries)
2. Entertainment (cinemas, arcades, bowling alleys)
3. Shopping (malls, bookstores, supermarkets)
4. Outdoor Recreation (parks, beaches, hiking trails)
5. Social / Leisure Venues (nightclubs, karaoke bars, comedy clubs)

## Key Features

- Proximity search by lat/lon + radius
- Category filtering
- Distance-sorted results
- Place details: name, category, location, rating

## Example API

`GET /places?lat=20.67&lon=-103.34&radius=2000`

Returns places sorted by distance with name, category, and distance fields.

## This Repository

This is the `placey-infra` repository — responsible for provisioning and managing all cloud infrastructure for the Placey system.

## Project Context

Educational MVP built for a System Design course. Focus areas: geospatial data handling, scalable architecture, efficient location queries, distributed system design.
