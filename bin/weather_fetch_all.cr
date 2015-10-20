require "../src/weather_crystal"
require "yaml"
require "logger"

path = File.join("config", "weather.yml")
cities = WeatherCrystal::WeatherCity.load_yaml(path)
logger = Logger.new(STDOUT)

cities.each do |city|
  o = WeatherCrystal::Provider::Noaa.new( city )
  weathers = o.fetch

  storage = WeatherCrystal::WeatherStorage.new
  count = storage.store( weathers )

  logger.info("#{city.metar} done with #{count} weather data") if count > 0
end
