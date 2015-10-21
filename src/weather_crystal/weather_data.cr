require "./weather_city"
require "json"

class WeatherCrystal::WeatherData
  BLANK_TEMP = -255.0
  BLANK_WIND = -1.0
  BLANK_WIND_DIRECTION = -1
  BLANK_HUMIDITY = -1.0
  BLANK_VALUE = -1
  BLANK_RAIN = -1.0

  def initialize(_city)
    @city = _city as WeatherCity
    @metar = nil
    @metar_string = ""
    @source = ""

    @time_from = Time.now
    @time_to = Time.now
    @time_created = Time.now

    @temperature = BLANK_TEMP
    @dew = BLANK_TEMP
    @humidity = BLANK_HUMIDITY
    @wind_chill = BLANK_TEMP

    @wind = BLANK_WIND
    @wind_max = BLANK_WIND
    @wind_direction = BLANK_WIND_DIRECTION

    @visibility = BLANK_VALUE
    @pressure = BLANK_VALUE
    @clouds = BLANK_VALUE

    @rain_metar = BLANK_VALUE
    @snow_metar = BLANK_VALUE

    @rain_mm = BLANK_RAIN
    @snow_mm = BLANK_RAIN
  end

  getter :time_created

  property :city
  property :source
  property :metar_string, :metar
  property :time_from, :time_to
  property :temperature, :dew, :humidity, :wind_chill
  property :wind, :wind_direction
  property :visibility, :pressure, :clouds
  property :snow_metar, :rain_metar
  property :rain_mm, :snow_mm

  def metar
    self.city.metar
  end

  def is_metar?
    self.metar_string != ""
  end

  def wind_speed_in_kmh=(_kmh)
    @wind = _kmh.to_f / 3.6
  end

  def max_wind_speed_in_kmh=(_kmh)
    @max_wind = _kmh.to_f / 3.6
  end

  def regular_to_hash
    {
      "city" => city.name,
      "country" => city.country,
      "lat" => city.lat,
      "lon" => city.lon,

      "source" => source,
      "time_from" => time_from.epoch,
      "time_to" => time_to.epoch,

      "temperature" => temperature == BLANK_TEMP ? nil : temperature,
      "dew" => dew == BLANK_TEMP ? nil : dew,
      "humidity" => humidity == BLANK_HUMIDITY ? nil : humidity,
      "wind_chill" => wind_chill == BLANK_TEMP ? nil : wind_chill,
      "wind" => wind == BLANK_WIND ? nil : wind,
      "wind_direction" => wind_direction == BLANK_WIND_DIRECTION ? nil : wind_direction,
      "visibility" => visibility == BLANK_VALUE ? nil : visibility,
      "pressure" => pressure == BLANK_VALUE ? nil : pressure,
      "clouds" => clouds == BLANK_VALUE ? nil : clouds,
      "rain_mm" => rain_mm == BLANK_RAIN ? nil : rain_mm,
      "snow_mm" => snow_mm == BLANK_RAIN ? nil : snow_mm
    }
  end

  def regular_to_json
    self.regular_to_hash.to_json
  end
end
