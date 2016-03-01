require "../src/weather_crystal"

logger = Logger.new(STDOUT)
logger.level = Logger::DEBUG

path = File.join("config", "weather.yml")

# providers
regular_interia_pl = WeatherCrystal::Provider::InteriaPl.new(logger)

cities = WeatherCrystal::WeatherCity.load_yaml(path)
city = cities.select { |w| w.url_hash["InteriaPl"]? }.first

weathers = [] of WeatherCrystal::WeatherData
weathers += regular_interia_pl.fetch_for_city(city)

puts weathers.inspect
