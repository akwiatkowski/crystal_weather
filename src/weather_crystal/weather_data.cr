require "./weather_city"
require "json"

class WeatherCrystal::WeatherData
  @city : WeatherCity
  @metar : (Nil | CrystalMetarParser::Metar)
  @metar_string : (Nil | String)
  @source : (Nil | String)

  @time_from : (Nil | Time)
  @time_to : (Nil | Time)
  @time_created : (Time)

  # temperature
  @temperature : (Nil | Float64)
  @temperature_min : (Nil | Float64)
  @temperature_max : (Nil | Float64)
  @dew : (Nil | Float64)
  @wind_chill : (Nil | Float64)

  # wind
  @wind : (Nil | Float64)
  @wind_max : (Nil | Float64)
  @wind_direction : (Nil | Int32)

  @visibility : (Nil | Int32)
  @pressure : (Nil | Int32)
  @clouds : (Nil | Int32)

  @rain_metar : (Nil | Int32)
  @snow_metar : (Nil | Int32)

  @rain_mm : (Nil | Float64)
  @snow_mm : (Nil | Float64)

  def initialize(@city : WeatherCity)
    @time_created = Time.now
  end

  getter :time_created

  property :city
  property :source
  property :metar_string, :metar
  property :time_from, :time_to, :time_created
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

  def is_valid?
    return temperature != BLANK_TEMP && wind != BLANK_WIND
  end

  def wind_speed_in_kmh=(_kmh)
    @wind = _kmh.to_f / 3.6
  end

  def max_wind_speed_in_kmh=(_kmh)
    @wind_max = _kmh.to_f / 3.6
  end

  def to_hash
    h = {} of String => (Nil | String | Int32 | Int64 | Float64)

    h["city"] = city.name
    h["country"] = city.country

    h["lat"] = city.lat
    h["lon"] = city.lon

    h["time_from"] = time_from.epoch
    h["time_to"] = time_to.epoch
    h["time_created"] = time_created.epoch

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
