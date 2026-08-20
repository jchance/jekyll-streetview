require "jekyll"
require "net/http"
require "uri"
require "json"
require "cgi"

module Jekyll
  class StreetviewTag < Liquid::Tag
    STREETVIEW_BASE = "https://maps.googleapis.com/maps/api/streetview"
    GEOCODE_BASE    = "https://maps.googleapis.com/maps/api/geocode/json"

    DEFAULT_WIDTH  = 640
    DEFAULT_HEIGHT = 400
    DEFAULT_FOV    = 90
    DEFAULT_PITCH  = 0
    DEFAULT_RADIUS = 50
    MAX_FREE_DIMENSION = 640

    def initialize(tag_name, markup, tokens)
      super
      @raw_markup = markup.strip
    end

    def render(context)
      site   = context.registers[:site]
      config = site.config["streetview"] || {}
      key    = config["key"]

      raise "jekyll-streetview: streetview.key is required in _config.yml" if key.nil? || key.strip.empty?

      params = parse_markup(@raw_markup)

      lat, lng = resolve_coordinates(params, key, site)
      raise "jekyll-streetview: could not resolve coordinates from markup: #{@raw_markup}" if lat.nil?

      width   = (params["width"]   || config["width"]   || DEFAULT_WIDTH).to_i
      height  = (params["height"]  || config["height"]  || DEFAULT_HEIGHT).to_i

      # Google Street View Static API caps dimensions at 640 on the free tier.
      # Clamp silently so HTML attributes match what Google actually returns.
      width  = [width,  MAX_FREE_DIMENSION].min
      height = [height, MAX_FREE_DIMENSION].min
      fov     = (params["fov"]     || config["fov"]     || DEFAULT_FOV).to_i
      pitch   = (params["pitch"]   || config["pitch"]   || DEFAULT_PITCH).to_i
      radius  = (params["radius"]  || config["radius"]  || DEFAULT_RADIUS).to_i
      heading = params["heading"] ? params["heading"].to_i : nil
      source  = params["source"]  || config["source"]
      alt     = params["alt"] || "Street View"

      url = build_url(lat, lng, width, height, fov, pitch, radius, heading, source, key)

      %(<img src="#{url}" alt="#{CGI.escapeHTML(alt)}" width="#{width}" height="#{height}" class="jekyll-streetview no-lightense" loading="lazy">)
    end

    private

    def parse_markup(markup)
      params = {}
      rest   = markup.dup

      if rest =~ /\A["'](.+?)["']\s*(.*)\z/m
        params["address"] = Regexp.last_match(1)
        rest = Regexp.last_match(2)
      end

      rest.scan(/(\w+)=("([^"]*?)"|'([^']*?)'|(\S+))/) do |key, _full, dq, sq, bare|
        params[key] = dq || sq || bare
      end

      params
    end

    def resolve_coordinates(params, key, site)
      return [params["lat"].to_f, params["lng"].to_f] if params["lat"] && params["lng"]
      return geocode(params["address"], key, site) if params["address"]
      [nil, nil]
    end

    def geocode(address, key, site)
      cache_key = address
      cache     = load_cache(site)
      return cache[cache_key] if cache.key?(cache_key)

      uri      = URI.parse("#{GEOCODE_BASE}?address=#{URI.encode_www_form_component(address)}&key=#{key}")
      response = Net::HTTP.get_response(uri)
      raise "jekyll-streetview: geocoding failed (#{response.code}) for: #{address}" unless response.is_a?(Net::HTTPSuccess)

      data    = JSON.parse(response.body)
      results = data["results"]
      raise "jekyll-streetview: no geocoding results for: #{address}" if results.nil? || results.empty?

      loc    = results.first["geometry"]["location"]
      result = [loc["lat"].round(6), loc["lng"].round(6)]
      save_cache(site, cache.merge(cache_key => result))
      result
    end

    def build_url(lat, lng, width, height, fov, pitch, radius, heading, source, key)
      params = {
        location: "#{lat},#{lng}",
        size:     "#{width}x#{height}",
        fov:      fov,
        pitch:    pitch,
        radius:   radius,
        key:      key
      }
      params[:heading] = heading if heading
      params[:source]  = source  if source && !source.empty?

      query = params.map { |k, v| "#{k}=#{CGI.escape(v.to_s)}" }.join("&")
      "#{STREETVIEW_BASE}?#{query}"
    end

    def cache_path(site)
      File.join(site.source, "_streetview_cache.json")
    end

    def load_cache(site)
      path = cache_path(site)
      return {} unless File.exist?(path)
      JSON.parse(File.read(path))
    rescue JSON::ParserError
      {}
    end

    def save_cache(site, cache)
      File.write(cache_path(site), JSON.pretty_generate(cache))
    end
  end
end

Liquid::Template.register_tag("streetview", Jekyll::StreetviewTag)
