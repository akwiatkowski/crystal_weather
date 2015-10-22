require "json"

class WeatherCrystal::WeatherWebStorage
  def initialize(_logger)
    @logger = _logger
    @last_metar_data = {} of String => WeatherData

    @metar_path = File.join("www", "metar.json")
  end

  getter :logger

  def post_store_array(weathers_data)
    weathers_data.each do |weather_data|
      post_store(weather_data)
    end
  end

  def post_store(weather_data)
    if weather_data.is_metar?
      @last_metar_data[ weather_data.key ] = weather_data
    else
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
  end

end
