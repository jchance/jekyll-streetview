# jekyll-streetview

A Jekyll plugin that adds a `{% streetview %}` Liquid tag for embedding Google Street View static images. No JavaScript required — just a responsive `<img>` tag powered by the Google Street View Static API.

## Installation

Add the gem to your Jekyll site's `Gemfile`:

```ruby
gem "jekyll-streetview", "~> 0.1"
```

Then add it to the `plugins` list in `_config.yml`:

```yaml
plugins:
  - jekyll-streetview
```

Run `bundle install` to install the gem.

## Configuration

Add a `streetview:` block to `_config.yml` with your Google API key:

```yaml
streetview:
  key: AIzaSy...
  width: 800          # optional default width
  height: 400         # optional default height
  fov: 90             # optional default field of view
  pitch: 0            # optional default pitch
```

Your Google API key must have the **Street View Static API** enabled. If you use address strings, it also needs the **Geocoding API** enabled.

## Usage

### By latitude and longitude

```liquid
{% streetview lat=33.248329 lng=-84.263336 %}
```

### By address string

Pass a quoted address string and the plugin geocodes it at build time via the Google Geocoding API. Results are cached in `_streetview_cache.json`.

```liquid
{% streetview "100 S Hill Street, Griffin, GA" %}
```

### Commit `_streetview_cache.json`

Commit `_streetview_cache.json` to your repo so CI builds don't re-geocode addresses on every run.

## Parameters

All parameters are optional and override values in `_config.yml`.

| Parameter | Default | Description |
| --- | --- | --- |
| `lat` | — | Latitude (required if no address string) |
| `lng` | — | Longitude (required if no address string) |
| `width` | `800` | Image width in pixels |
| `height` | `400` | Image height in pixels |
| `heading` | auto | Camera compass heading (0-360). If omitted, Google points toward the location. |
| `fov` | `90` | Horizontal field of view in degrees (10-120). Lower = more zoom. |
| `pitch` | `0` | Camera up/down angle (-90 to 90). Positive = up, negative = down. |
| `radius` | `50` | Search radius in meters for nearest panorama |
| `source` | — | Set to `outdoor` to exclude indoor panoramas |
| `alt` | `"Street View"` | Alt text for the `<img>` tag |

## Examples

```liquid
{% streetview lat=33.248329 lng=-84.263336 %}

{% streetview "100 S Hill Street, Griffin, GA" heading=180 %}

{% streetview lat=33.248329 lng=-84.263336 fov=60 pitch=10 heading=90 width=1200 height=500 %}

{% streetview "City Hall, Atlanta, GA" source=outdoor alt="Atlanta City Hall" %}
```

## Output

The tag renders a single `<img>` element:

```html
<img src="https://maps.googleapis.com/maps/api/streetview?location=33.248329%2C-84.263336&size=800x400&fov=90&pitch=0&radius=50&key=..." alt="Street View" width="800" height="400" class="jekyll-streetview" loading="lazy">
```

Add styles for `.jekyll-streetview` in your site's CSS:

```css
.jekyll-streetview {
  width: 100%;
  height: auto;
  border-radius: 4px;
}
```

## Note on imagery availability

If Street View imagery is not available at the specified location, Google returns a gray placeholder image. Use a nearby address or adjust `radius` to find available coverage. You can check coverage in [Google Maps Street View](https://maps.google.com) before embedding.

## GitHub Pages compatibility

This plugin is compatible with Jekyll sites deployed to GitHub Pages when the site is built through a custom GitHub Actions workflow.

It is not compatible with the default GitHub Pages safe-mode build, because custom plugins are not loaded there.

## License

MIT License. See [LICENSE.txt](LICENSE.txt).
