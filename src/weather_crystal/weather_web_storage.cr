require "json"

class WeatherCrystal::WeatherWebStorage
  def initialize(_logger)
    @logger = _logger
    @last_metar_data = {} of String => WeatherData
    @regular_data = [] of WeatherData

    @metar_path = File.join("www", "metar.json")
    @regular_path = File.join("www", "weather.json")
  end

  getter :logger

  def post_store_array(weathers_data)
    weathers_data.each do |weather_data|
      post_store(weather_data)
    end
  end

  def post_store(weather_data)
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
    @regular_data = @regular_data.select do |w|
                      w.time_from > Time.now
                    end

    @regular_data = @regular_data.sort do |a, b|
                      key_compare = a.key <=> b.key
                      if key_compare != 0
                        key_compare
                      else
                        a.time_from <=> b.time_from
                      end
                    end

    result = String.build do |node|
               node.json_array do |array|
                 @regular_data.each do |w|
                   array << w.to_hash
                 end
               end
             end

    File.write(@regular_path, result)
    @logger.debug("Website regular JSON saved")
  end
end
