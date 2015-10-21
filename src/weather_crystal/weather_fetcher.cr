require "yaml"
require "logger"

class WeatherCrystal::WeatherFetcher
  def initialize(config_path)
    @cities = WeatherCrystal::WeatherCity.load_yaml(config_path)

    @logger = Logger.new(STDOUT)
    @logger.formatter = Logger::Formatter.new do |severity, datetime, progname, message, io|
                          io << severity[0] << ", [" << datetime.to_s("%H:%M:%S.%L") << "] "
                          io << severity.rjust(5) << ": " << message
                        end

    # providers
    @metar_noaa = WeatherCrystal::Provider::Noaa.new(@logger)
    @metar_wunderground = WeatherCrystal::Provider::Wunderground.new(@logger)
    @metar_aviation_weather = WeatherCrystal::Provider::AviationWeather.new(@logger)

    @storage = WeatherCrystal::WeatherStorage.new

    @sleep_amount = 60 * 10
    @sleep_amount = 1
  end

  property :sleep_amount

  def single_fetch
    @cities.each do |city|
      weathers = single_fetch_per_city(city)
      count = @storage.store(weathers)

      @logger.info "#{city.metar} done with #{count} weather data" if count > 0
    end
  end

  def single_fetch_per_city(city)
    weathers = [] of WeatherData
    weathers += @metar_noaa.fetch_for_city(city)
    weathers += @metar_wunderground.fetch_for_city(city)
    weathers += @metar_aviation_weather.fetch_for_city(city)

    return weathers
  end

  def loop_fetch
    while true
      single_fetch

      @logger.info "Sleep #{@sleep_amount} seconds"
      sleep sleep_amount
    end
  end
end
