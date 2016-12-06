require "../src/weather_crystal"

path = File.join("config", "weather_test.yml")
f = WeatherCrystal::WeatherFetcher.new(path)
f.metar_fetch
f.regular_fetch
