# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-08-20

### Added
- Initial release
- `{% streetview %}` Liquid tag for embedding Google Street View Static API images
- Latitude/longitude direct input
- Address string geocoding via Google Geocoding API with local cache (`_streetview_cache.json`)
- Parameters: `width`, `height`, `heading`, `fov`, `pitch`, `radius`, `source`, `alt`
- Config-level defaults via `streetview:` block in `_config.yml`
