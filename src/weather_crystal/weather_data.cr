require "./weather_city"

class WeatherCrystal::WeatherData
  def initialize(_city)
    @city = _city as WeatherCity

    @time_from = Time.now
    @time_to = Time.now

    @temperature = -255.0
    @dew = -255.0
    @humidity = -1.0
    @wind_chill = -255

    @wind = -1.0
    @wind_direction = -1

    @visibility = -1
    @pressure = -1
    @clouds = -1

    @rain_metar = -1
    @snow_metar = -1
  end

  property :city
  property :time_from, :time_to
  property :temperature, :dew, :humidity, :wind_chill
  property :wind, :wind_direction
  property :visibility, :pressure, :clouds
  property :snow_metar, :rain_metar

  def metar
    self.city.metar
  end

end
