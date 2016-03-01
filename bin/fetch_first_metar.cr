require "../src/weather_crystal"

logger = Logger.new(STDOUT)
logger.level = Logger::DEBUG

path = File.join("config", "weather.yml")

# providers
metar_noaa = WeatherCrystal::Provider::Noaa.new(logger)
metar_wunderground = WeatherCrystal::Provider::Wunderground.new(logger)
metar_aviation_weather = WeatherCrystal::Provider::AviationWeather.new(logger)

cities = WeatherCrystal::WeatherCity.load_yaml(path)
city = cities.first

weathers = [] of WeatherCrystal::WeatherData
weathers += metar_wunderground.fetch_for_city(city)
weathers += metar_noaa.fetch_for_city(city)

puts weathers.inspect
