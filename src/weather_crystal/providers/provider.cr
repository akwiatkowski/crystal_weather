require "logger"

# Base class for ordinary weather provider
class WeatherCrystal::Provider
  # kind of provider: standard, html (self web based), gem (other gem)
  TYPE = :standard

  # just a constant, seconds in 1 hour
  HOUR = 3600

  # Create an instance, definitions can be set here
  def initialize(_city)
    @city = _city as WeatherCity
    @weathers = [] of WeatherData
    @logger = Logger.new(STDOUT)
  end

  getter :weathers
  getter :logger
  getter :city

  # Name of provider
  def provider_name
    self.class.provider_name
  end

  # Name of provider, should be overrode
  def self.provider_name
    raise NotImplementedError
  end

  def fetch
    raise NotImplementedError
  end

  def process
    raise NotImplementedError
  end

  def unix_time_today
    Time.mktime(
      Time.now.year,
      Time.now.month,
      Time.now.day,
      0, 0, 0, 0)
  end

  def short_class_name
    self.class.short_class_name
  end

end
