# All ugly providers who parse even uglier html code and rip off data
class WeatherCrystal::MetarProvider < WeatherCrystal::HttpProvider
  TYPE = :metar
  # treat metars as not current when time_from is not within time range
  MAX_METAR_TIME_THRESHOLD = 4*3600


  def self.provider_name
    "MetarProvider"
  end

  # How often weather is updated
  def self.weather_updated_every
    10*60
  end

  def process(data)
    puts data
    return 1
  end

end
