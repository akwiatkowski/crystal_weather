require "../src/weather_crystal"

path = File.join("config", "weather.yml")
f = WeatherCrystal::WeatherFetcher.new(path)
f.loop_fetch
