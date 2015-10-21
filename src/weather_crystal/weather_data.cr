require "./weather_city"

class WeatherCrystal::WeatherData
  def initialize(_city)
    @city = _city as WeatherCity
    @metar = nil
    @metar_string = ""

    @time_from = Time.now
    @time_to = Time.now
    @time_created = Time.now

    @temperature = -255.0
    @dew = -255.0
    @humidity = -1.0
    @wind_chill = -255

    @wind = -1.0
    @wind_max = -1.0
    @wind_direction = -1

    @visibility = -1
    @pressure = -1
    @clouds = -1

    @rain_metar = -1
    @snow_metar = -1

    @rain_mm = -1
    @snow_mm = -1
  end

  getter :time_created

  property :city
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
end
