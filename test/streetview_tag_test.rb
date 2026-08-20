require "minitest/autorun"
require "jekyll"
require_relative "../lib/jekyll-streetview"

class StreetviewTagTest < Minitest::Test
  def base_config
    {
      "source"      => Dir.mktmpdir,
      "destination" => Dir.mktmpdir,
      "streetview"  => { "key" => "test_google_key" }
    }
  end

  def render(markup, site_config = base_config)
    site     = Jekyll::Site.new(Jekyll.configuration(site_config))
    template = Liquid::Template.parse("{% streetview #{markup} %}")
    template.render({}, registers: { site: site })
  end

  def render!(markup, site_config = base_config)
    site     = Jekyll::Site.new(Jekyll.configuration(site_config))
    template = Liquid::Template.parse("{% streetview #{markup} %}")
    template.render!({}, registers: { site: site })
  end

  # --- basic output ---

  def test_renders_img_tag
    result = render("lat=33.248329 lng=-84.263336")
    assert_includes result, "<img"
    assert_includes result, "maps.googleapis.com/maps/api/streetview"
  end

  def test_url_contains_location
    result = render("lat=33.248329 lng=-84.263336")
    assert_includes result, "location=33.248329"
  end

  def test_url_contains_api_key
    result = render("lat=33.248329 lng=-84.263336")
    assert_includes result, "key=test_google_key"
  end

  # --- defaults ---

  def test_default_size_800x400
    result = render("lat=33.248329 lng=-84.263336")
    assert_includes result, "size=800x400"
    assert_includes result, 'width="800"'
    assert_includes result, 'height="400"'
  end

  def test_default_fov_90
    result = render("lat=33.248329 lng=-84.263336")
    assert_includes result, "fov=90"
  end

  def test_default_pitch_0
    result = render("lat=33.248329 lng=-84.263336")
    assert_includes result, "pitch=0"
  end

  def test_default_radius_50
    result = render("lat=33.248329 lng=-84.263336")
    assert_includes result, "radius=50"
  end

  def test_no_heading_by_default
    result = render("lat=33.248329 lng=-84.263336")
    refute_includes result, "heading="
  end

  # --- parameter overrides ---

  def test_custom_width_height
    result = render("lat=33.248329 lng=-84.263336 width=1200 height=600")
    assert_includes result, "size=1200x600"
    assert_includes result, 'width="1200"'
    assert_includes result, 'height="600"'
  end

  def test_custom_fov
    result = render("lat=33.248329 lng=-84.263336 fov=60")
    assert_includes result, "fov=60"
  end

  def test_custom_pitch
    result = render("lat=33.248329 lng=-84.263336 pitch=20")
    assert_includes result, "pitch=20"
  end

  def test_negative_pitch
    result = render("lat=33.248329 lng=-84.263336 pitch=-30")
    assert_includes result, "pitch=-30"
  end

  def test_custom_heading
    result = render("lat=33.248329 lng=-84.263336 heading=90")
    assert_includes result, "heading=90"
  end

  def test_custom_radius
    result = render("lat=33.248329 lng=-84.263336 radius=100")
    assert_includes result, "radius=100"
  end

  def test_source_outdoor
    result = render("lat=33.248329 lng=-84.263336 source=outdoor")
    assert_includes result, "source=outdoor"
  end

  # --- alt text ---

  def test_default_alt
    result = render("lat=33.248329 lng=-84.263336")
    assert_includes result, 'alt="Street View"'
  end

  def test_custom_alt
    result = render('lat=33.248329 lng=-84.263336 alt="Griffin City Hall"')
    assert_includes result, 'alt="Griffin City Hall"'
  end

  # --- HTML attributes ---

  def test_has_loading_lazy
    result = render("lat=33.248329 lng=-84.263336")
    assert_includes result, 'loading="lazy"'
  end

  def test_has_jekyll_streetview_class
    result = render("lat=33.248329 lng=-84.263336")
    assert_includes result, 'class="jekyll-streetview"'
  end

  # --- error handling ---

  def test_raises_without_key
    config = { "source" => Dir.mktmpdir, "destination" => Dir.mktmpdir, "streetview" => {} }
    assert_raises(RuntimeError) { render!("lat=33.248329 lng=-84.263336", config) }
  end

  def test_raises_without_coordinates_or_address
    assert_raises(RuntimeError) { render!("fov=60") }
  end

  # --- config-level defaults ---

  def test_config_fov_default
    config = base_config.merge("streetview" => { "key" => "test_google_key", "fov" => 60 })
    result = render("lat=33.248329 lng=-84.263336", config)
    assert_includes result, "fov=60"
  end

  def test_tag_fov_overrides_config
    config = base_config.merge("streetview" => { "key" => "test_google_key", "fov" => 60 })
    result = render("lat=33.248329 lng=-84.263336 fov=45", config)
    assert_includes result, "fov=45"
  end

  def test_config_size_default
    config = base_config.merge("streetview" => { "key" => "test_google_key", "width" => 600, "height" => 300 })
    result = render("lat=33.248329 lng=-84.263336", config)
    assert_includes result, "size=600x300"
  end
end
