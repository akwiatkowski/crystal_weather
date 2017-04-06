require "yaml"
require "logger"
require "colorize"

class WeatherCrystal::WeatherFetcher
  THREADED = false

  def initialize(@config_path : String, @keys_path : String)
    @cities = WeatherCrystal::WeatherCity.load_yaml(@config_path)

    @logger = Logger.new(STDOUT)
    @logger.formatter = Logger::Formatter.new do |severity, datetime, progname, message, io|
      io << severity[0] << ", [" << datetime.to_s("%H:%M:%S.%L") << "] "
      io << severity.rjust(5) << ": " << message
    end
    @logger.level = Logger::DEBUG

    # providers keys
    WeatherCrystal::Provider::OpenWeatherMap.load_key(@keys_path)

    # providers
    @metar_noaa = WeatherCrystal::Provider::Noaa.new(logger: @logger)
    @metar_wunderground = WeatherCrystal::Provider::Wunderground.new(logger: @logger)
    @metar_aviation_weather = WeatherCrystal::Provider::AviationWeather.new(logger: @logger)

    @regular_interia_pl = WeatherCrystal::Provider::InteriaPl.new(logger: @logger)
    @open_weather_map = WeatherCrystal::Provider::OpenWeatherMap.new(logger: @logger)

    @storage = WeatherCrystal::WeatherStorage.new(logger: @logger)
    @web_storage = WeatherCrystal::WeatherWebStorage.new(logger: @logger)

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
    total = @cities.size
    @cities.each_with_index do |city, i|
      if city.metar != ""
        begin
          @logger.info "#{city.metar.colorize(:green)}/#{city.name.colorize(:blue)} fetching metar (#{i + 1}/#{total})"

          weathers = single_fetch_metar_per_city(city)
          count = @storage.store(weathers)
          @web_storage.post_store_array(weathers)

          @logger.info "#{city.metar.colorize(:green)}/#{city.name.colorize(:blue)} done with #{count.to_s.colorize(:magenta)} weather data" if count > 0
        rescue e : ArgumentError
          @logger.error "#{city.metar.colorize(:green)}/#{city.name.colorize(:blue)} ArgumentError #{e.inspect}"
        end
      end
    end
  end

  def single_fetch_regular
    total = @cities.size
    @cities.each_with_index do |city, i|
      @logger.info "#{city.name.colorize(:blue)}/#{city.country.colorize(:cyan)} fetching regular (#{i + 1}/#{total})"

      weathers = single_fetch_regular_per_city(city)
      count = @storage.store(weathers)
      @web_storage.post_store_array(weathers)

      @logger.info "#{city.name.colorize(:blue)}/#{city.country.colorize(:cyan)} done with #{count.to_s.colorize(:magenta)} weather data" if count > 0
    end
  end

  def single_fetch_metar_per_city(city)
    weathers = Array(WeatherCrystal::WeatherData).new

    ta = @metar_wunderground.fetch_for_city(city)
    @logger.debug(" + #{@metar_wunderground.class.provider_key} done with #{ta.size.to_s.colorize(:magenta)}")
    weathers += ta

    ta = @metar_noaa.fetch_for_city(city)
    @logger.debug(" + #{@metar_noaa.class.provider_key} done with #{ta.size.to_s.colorize(:magenta)}")
    weathers += ta

    return weathers
  end

  def single_fetch_regular_per_city(city)
    weathers = Array(WeatherCrystal::WeatherData).new

    ta = @regular_interia_pl.fetch_for_city(city)
    @logger.debug(" + #{@regular_interia_pl.class.provider_key} done with #{ta.size.to_s.colorize(:magenta)}")
    weathers += ta

    if @open_weather_map.class.enabled?
      ta = @open_weather_map.fetch_for_city(city)
      @logger.debug(" + #{@open_weather_map.class.provider_key} done with #{ta.size.to_s.colorize(:magenta)}")
      weathers += ta

      # TODO
      sleep 1
    end

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
        if THREADED
          metar_fetch_thread
        else
          metar_fetch_now
        end
      end

      if regular_span <= @zero_time_span
        if THREADED
          regular_fetch_thread
        else
          regular_fetch_now
        end
      end

      sleep @sleep_loop
    end
  end

  def metar_fetch_thread
    future do
      metar_fetch_now
    end
  end

  def regular_fetch_thread
    future do
      regular_fetch_now
    end
  end

  def metar_fetch_now
    @next_metar_at += Time::Span.new(0, 0, @sleep_metar_amount)
    metar_fetch
  end

  def regular_fetch_now
    @next_regular_at += Time::Span.new(0, 0, @sleep_regular_amount)
    regular_fetch
  end

  def metar_fetch
    single_fetch_metar
    @last_done_metar_at = Time.now
    @logger.info("Metar done".colorize(:yellow))
    @web_storage.materialize_metar

    puts 1
  end

  def regular_fetch
    single_fetch_regular
    @last_done_regular_at = Time.now
    @logger.info("Regular done".colorize(:yellow))
    @web_storage.materialize_regular

    puts 2
  end
end
