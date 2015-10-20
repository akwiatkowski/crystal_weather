require "../src/weather_crystal"
require "yaml"

path = File.join("config", "weather.yml")
cities = WeatherCrystal::WeatherCity.load_yaml(path)

#puts cities.inspect

city = WeatherCrystal::WeatherCity.new
city.metar = "EPPO"

o = WeatherCrystal::Provider::Noaa.new( city )
o.fetch
