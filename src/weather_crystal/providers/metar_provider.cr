require "crystal_metar_parser"

class WeatherCrystal::MetarProvider < WeatherCrystal::HttpProvider
  TYPE = :metar
  # treat metars as not current when time_from is not within time range
  MAX_METAR_TIME_THRESHOLD = 4 * 3600

  def self.provider_name
    "MetarProvider"
  end

  # How often weather is updated
  def self.weather_updated_every
    10 * 60
  end

  def process_for_city(city, data)
    metar = CrystalMetarParser::Parser.parse(metar: data.to_s, year: Time.now.year, month: Time.now.month)
    data = WeatherData.new(city)

    # copy properties
    data.metar = metar
    data.metar_string = metar.raw

    data.time_from = metar.time.time_from
    data.time_to = metar.time.time_to

    data.temperature = metar.temperature.degrees
    data.dew = metar.temperature.dew
    data.humidity = metar.temperature.humidity
    data.wind_chill = metar.temperature.wind_chill

    data.wind = metar.wind.speed
    data.wind_direction = metar.wind.direction

    data.visibility = metar.visibility.visibility
    data.pressure = metar.pressure.pressure.to_f
    data.clouds = metar.clouds.clouds_max

    data.rain_metar = metar.specials.rain_metar.to_i
    data.snow_metar = metar.specials.snow_metar.to_i

    return [data]
  end
end
