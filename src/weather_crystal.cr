require "./weather_crystal/version"

require "./weather_crystal/weather_city"
require "./weather_crystal/weather_data"
require "./weather_crystal/weather_storage"
require "./weather_crystal/weather_web_storage"
require "./weather_crystal/weather_fetcher"

require "./weather_crystal/providers/provider"
require "./weather_crystal/providers/http_provider"
require "./weather_crystal/providers/metar_provider"

require "./weather_crystal/providers/metar/noaa"
require "./weather_crystal/providers/metar/wunderground"
require "./weather_crystal/providers/metar/aviation_weather"

require "./weather_crystal/providers/http/interia_pl"
require "./weather_crystal/providers/http/open_weather_map"

module WeatherCrystal
end
