# Project Structure

This is the `placey-infra` repository. Placey uses a polyrepo architecture — the other repos are `placey-backend` and `placey-frontend`.

## This Repo (`placey-infra`)

Infrastructure as Code for all cloud resources.

```
placey-infra/
  modules/          # Reusable Terraform modules
  environments/     # Per-environment configs (dev, prod)
```

## `placey-backend`

Core API and geospatial logic.

```
placey-backend/
  src/
    routes/         # API route handlers (e.g., /places)
    services/       # Business logic (proximity search, filtering)
    models/         # Data models (Place, Category)
    db/             # Database connection and query helpers
  tests/
```

## `placey-frontend`

React application with map and search UI.

```
placey-frontend/
  src/
    components/     # UI components (Map, SearchBar, PlaceCard, Filters)
    pages/          # Page-level components
    services/       # API client calls to backend
  public/
```

## Conventions

- Each repo is independently deployable
- No shared code between repos — communicate via REST API
- Backend is the single source of truth for place data and proximity logic
- Frontend never performs geospatial calculations directly
