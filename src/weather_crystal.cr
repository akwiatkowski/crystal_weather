require "./weather_crystal/version"

require "./weather_crystal/weather_city"
require "./weather_crystal/weather_data"
require "./weather_crystal/weather_storage"
require "./weather_crystal/weather_fetcher"

require "./weather_crystal/providers/provider"
require "./weather_crystal/providers/http_provider"
require "./weather_crystal/providers/metar_provider"

require "./weather_crystal/providers/metar/noaa"
require "./weather_crystal/providers/metar/wunderground"

module WeatherCrystal
end
