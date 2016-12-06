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

  @humidity : (Nil | Float64)
  @visibility : (Nil | Int32)
  @pressure : (Nil | Float64)
  @pressure_sea_level : (Nil | Float64)
  @pressure_ground_level : (Nil | Float64)
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
  property :temperature, :temperature_min, :temperature_max
  property :dew, :humidity, :wind_chill
  property :wind, :wind_direction
  property :visibility, :clouds
  property :pressure, :pressure_sea_level, :pressure_ground_level
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
    self.metar_string.to_s != ""
  end

  def is_valid?
    return temperature != nil && wind != nil && time_from != nil
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

    h["time_from"] = time_from.not_nil!.epoch
    h["time_to"] = time_to.not_nil!.epoch
    h["time_created"] = time_created.not_nil!.epoch

    h["temperature"] = temperature
    h["temperature_min"] = temperature_min unless temperature_min.nil?
    h["temperature_max"] = temperature_max unless temperature_max.nil?
    h["dew"] = dew unless dew.nil?
    h["humidity"] = humidity unless humidity.nil?
    h["wind_chill"] = wind_chill unless wind_chill.nil?
    h["wind"] = wind unless wind.nil?
    h["wind_direction"] = wind_direction unless wind_direction.nil?
    h["visibility"] = visibility unless visibility.nil?
    h["pressure"] = pressure unless pressure.nil?
    h["pressure_sea_level"] = pressure_sea_level unless pressure_sea_level.nil?
    h["pressure_ground_level"] = pressure_ground_level unless pressure_ground_level.nil?
    h["clouds"] = clouds unless clouds.nil?

    h["metar"] = city.metar unless city.metar.to_s == ""
    h["metar_string"] = metar_string unless metar_string.nil?

    h["source"] = source unless source.nil?
    h["rain_mm"] = rain_mm unless rain_mm.nil?
    h["snow_mm"] = snow_mm unless snow_mm.nil?

    return h
  end

  def to_json
    self.to_hash.to_json
  end
end
