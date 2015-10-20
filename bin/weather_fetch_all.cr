require "../src/weather_crystal"
require "yaml"
require "logger"

path = File.join("config", "weather.yml")
cities = WeatherCrystal::WeatherCity.load_yaml(path)
logger = Logger.new(STDOUT)
sleep_amount = 60*10
sleep_amount = 10

loop do
  cities.each do |city|

    o = WeatherCrystal::Provider::Noaa.new( city )
    weathers = o.fetch

    storage = WeatherCrystal::WeatherStorage.new
    count = storage.store( weathers )

    logger.info("#{city.metar} done with #{count} weather data") if count > 0
  end

  logger.info("Sleep #{sleep_amount} seconds")
  sleep sleep_amount

end
