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

    @storage = WeatherCrystal::WeatherStorage.new(@logger)
    @web_storage = WeatherCrystal::WeatherWebStorage.new(@logger)

    @sleep_metar_amount = (10 * 60).as(Int32)
    @sleep_regular_amount = (3 * 60 * 60).as(Int32)
    @sleep_loop = 60

    @next_metar_at = Time.now
    @next_regular_at = Time.now
    @last_done_metar_at = Time.now
    @last_done_regular_at = Time.now

    @zero_time_span = Time::Span.new(0, 0, 0)
  end

  def single_fetch_metar
    @cities.each do |city|
      @logger.info "#{city.metar}/#{city.name} fetching metar" unless city.metar == ""

      weathers = single_fetch_metar_per_city(city)
      count = @storage.store(weathers)
      @web_storage.post_store_array(weathers)

      @logger.info "#{city.metar}/#{city.name} done with #{count} weather data" if count > 0
    end
  end

  def single_fetch_regular
    @cities.each do |city|
      @logger.info "#{city.name}/#{city.country} fetching regular"

      weathers = single_fetch_regular_per_city(city)
      count = @storage.store(weathers)
      @web_storage.post_store_array(weathers)

      @logger.info "#{city.name}/#{city.country} done with #{count} weather data" if count > 0
    end
  end

  def single_fetch_metar_per_city(city)
    weathers = Array(WeatherCrystal::WeatherData).new
    weathers += @metar_wunderground.fetch_for_city(city)
    weathers += @metar_noaa.fetch_for_city(city)

    return weathers
  end

  def single_fetch_regular_per_city(city)
    weathers = Array(WeatherCrystal::WeatherData).new
    weathers += @regular_interia_pl.fetch_for_city(city)

    return weathers
  end

  def loop_fetch
    loop do
      metar_span = @next_metar_at - Time.now
      regular_span = @next_regular_at - Time.now

      metar_done_span = @last_done_metar_at - Time.now
      regular_done_span = @last_done_regular_at - Time.now

      @logger.info(" METAR  : done #{metar_done_span}, next #{metar_span}")
      @logger.info(" REGULAR: done #{regular_done_span}, next #{regular_span}")
      @logger.debug("GC: #{GC.stats.inspect}")

      if metar_span <= @zero_time_span
        future do
          @next_metar_at += Time::Span.new(0, 0, @sleep_metar_amount)
          metar_fetch
        end
      end

      if regular_span <= @zero_time_span
        future do
          @next_regular_at += Time::Span.new(0, 0, @sleep_regular_amount)
          regular_fetch
        end
      end

      sleep @sleep_loop
    end
  end

  def metar_fetch
    single_fetch_metar
    @last_done_metar_at = Time.now
    @logger.info("Metar done")
    @web_storage.materialize_metar
  end

  def regular_fetch
    single_fetch_regular
    @last_done_regular_at = Time.now
    @logger.info("Regular done")
    @web_storage.materialize_regular
  end
end
