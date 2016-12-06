require "../src/weather_crystal"

config_path = File.join("config", "weather.yml")
keys_path = File.join("config", "keys.yml")
f = WeatherCrystal::WeatherFetcher.new(config_path: config_path, keys_path: keys_path)

f.regular_fetch
