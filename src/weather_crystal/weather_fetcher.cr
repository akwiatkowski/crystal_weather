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
    @logger.level = Logger::DEBUG

    # providers
    @metar_noaa = WeatherCrystal::Provider::Noaa.new(@logger)
    @metar_wunderground = WeatherCrystal::Provider::Wunderground.new(@logger)
    @metar_aviation_weather = WeatherCrystal::Provider::AviationWeather.new(@logger)

    @regular_interia_pl = WeatherCrystal::Provider::InteriaPl.new(@logger)

    @storage = WeatherCrystal::WeatherStorage.new

    @sleep_metar_amount = 60 * 10
    @sleep_regular_amount = 3 * 60 * 60
  end

  def single_fetch_metar
    @cities.each do |city|
      @logger.info "#{city.metar}/#{city.name} fetching metar" unless city.metar == ""

      weathers = single_fetch_metar_per_city(city)
      count = @storage.store(weathers)

      @logger.info "#{city.metar}/#{city.name} done with #{count} weather data" if count > 0
    end
  end

  def single_fetch_regular
    @cities.each do |city|
      @logger.info "#{city.name}/#{city.country} fetching regular"

      weathers = single_fetch_regular_per_city(city)
      count = @storage.store(weathers)

      @logger.info "#{city.name}/#{city.country} done with #{count} weather data" if count > 0
    end
  end

  def single_fetch_metar_per_city(city)
    weathers = [] of WeatherData
    weathers += @metar_noaa.fetch_for_city(city)
    weathers += @metar_wunderground.fetch_for_city(city)
    weathers += @metar_aviation_weather.fetch_for_city(city)

    return weathers
  end

  def single_fetch_regular_per_city(city)
    weathers = [] of WeatherData
    weathers += @regular_interia_pl.fetch_for_city(city)

    return weathers
  end

  def loop_fetch
    future do
      loop do
        metar_fetch
      end
    end
    future do
      loop do
        regular_fetch
      end
    end

    loop do
      sleep 10
    end
  end

  def metar_fetch
    single_fetch_metar
    sleep @sleep_metar_amount
  end

  def regular_fetch
    single_fetch_regular
    sleep @sleep_regular_amount
  end
end
