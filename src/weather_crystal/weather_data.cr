require "./weather_city"
require "json"

class WeatherCrystal::WeatherData
  BLANK_TEMP           = -255.0
  BLANK_WIND           =   -1.0
  BLANK_WIND_DIRECTION =     -1
  BLANK_HUMIDITY       =   -1.0
  BLANK_VALUE          =     -1
  BLANK_RAIN           =   -1.0
  BLANK_STRING         = ""

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

  def key
    if is_metar?
      "#{city.metar}"
    else
      "#{city.country}, #{city.name}"
    end
  end

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

  def to_hash
    h = {} of String => (Nil | String | Int32 | Int64 | Float64)

    h["city"] = city.name
    h["country"] = city.country

    h["lat"] = city.lat
    h["lon"] = city.lon

    h["time_from"] = time_from.epoch
    h["time_to"] = time_to.epoch

    h["temperature"] = temperature unless BLANK_TEMP == temperature
    h["dew"] = dew unless BLANK_TEMP == dew
    h["humidity"] = humidity unless BLANK_HUMIDITY == humidity
    h["wind_chill"] = wind_chill unless BLANK_TEMP == wind_chill
    h["wind"] = wind unless BLANK_WIND == wind
    h["wind_direction"] = wind_direction unless BLANK_WIND_DIRECTION == wind_direction
    h["visibility"] = visibility unless BLANK_VALUE == visibility
    h["pressure"] = pressure unless BLANK_VALUE == pressure
    h["clouds"] = clouds unless BLANK_VALUE == clouds

    if is_metar?
      h["metar"] = city.metar
      h["metar_string"] = metar_string
    else
      h["source"] = source
      h["rain_mm"] = rain_mm unless BLANK_RAIN == rain_mm
      h["snow_mm"] = snow_mm unless BLANK_RAIN == snow_mm
    end

    return h
  end

  def to_json
    self.to_hash.to_json
  end
end
