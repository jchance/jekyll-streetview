require_relative "lib/jekyll-streetview/version"

Gem::Specification.new do |spec|
  spec.name          = "jekyll-streetview"
  spec.version       = Jekyll::Streetview::VERSION
  spec.authors       = ["Jason Chance"]
  spec.email         = ["jason@jasonchance.com"]

  spec.summary       = "A Jekyll plugin for embedding Google Street View static images with a simple Liquid tag."
  spec.description   = "jekyll-streetview adds a {% streetview %} Liquid tag to Jekyll sites. Pass a latitude/longitude or an address string and get a static Street View image with no JavaScript required. Powered by the Google Street View Static API."
  spec.homepage      = "https://jasonchance.com/projects/jekyll-streetview/"
  spec.license       = "MIT"

  spec.required_ruby_version = ">= 2.7.0"

  spec.files = Dir["lib/**/*", "LICENSE.txt", "README.md", "CHANGELOG.md"]
  spec.require_paths = ["lib"]

  spec.add_dependency "jekyll", ">= 4.0", "< 5.0"
end
