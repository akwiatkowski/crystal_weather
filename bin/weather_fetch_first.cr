require "../src/weather_crystal"

path = File.join("config", "weather_first.yml")
keys_path = File.join("config", "keys.yml")
f = WeatherCrystal::WeatherFetcher.new(path, keys_path)
f.loop_fetch
