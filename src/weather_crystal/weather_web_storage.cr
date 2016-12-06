require "json"

class WeatherCrystal::WeatherWebStorage
  def initialize(@logger = Logger.new(STDOUT))
    @last_metar_data = {} of String => WeatherData
    @regular_data = [] of WeatherData

    @metar_path = File.join("www", "metar.json")
    @regular_path = File.join("www", "weather.json")

    @regular_store_span = Time::Span.new(6, 0, 0)
  end

  getter :logger

  def clear
    @regular_data = [] of WeatherData
  end

  def post_store_array(weathers_data)
    weathers_data.each do |weather_data|
      post_store(weather_data)
    end
  end

  def post_store(weather_data)
    return unless weather_data.is_valid?

    if weather_data.is_metar?
      @last_metar_data[weather_data.key] = weather_data
    else
      @regular_data << weather_data
    end
  end

  def materialize_metar
    result = String.build do |node|
      node.json_array do |array|
        @last_metar_data.each_key do |metar|
          array << @last_metar_data[metar].to_hash
        end
      end
    end

    File.write(@metar_path, result)
    @logger.debug("Website metar JSON saved")
  end

  def materialize_regular
    regs = [] of WeatherData

    i = 0
    while i < @regular_data.size
      if regs.size == 0 || (@regular_data[i].time_from.not_nil! - regs[-1].time_from.not_nil!) > @regular_store_span ||
         (i > 0 && @regular_data[i].key != @regular_data[i - 1].key) # city change
        regs << @regular_data[i]
      end

      i += 1
    end

    regs = regs.sort do |a, b|
      key_compare = a.key <=> b.key
      if key_compare != 0
        key_compare
      else
        a.time_from.not_nil! <=> b.time_from.not_nil!
      end
    end

    result = String.build do |node|
      node.json_array do |array|
        regs.each do |w|
          array << w.to_hash
        end
      end
    end

    File.write(@regular_path, result)
    @logger.debug("Website regular JSON saved")

    clear
    GC.collect
  end
end
