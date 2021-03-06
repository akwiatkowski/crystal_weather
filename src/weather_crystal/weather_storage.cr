class WeatherCrystal::WeatherStorage
  def initialize(@logger = Logger.new(STDOUT))
    @metar_last_times = {} of String => Time
  end

  METAR_THRESHOLD_STORE_TIME = Time::Span.new(4, 0, 0)

  getter :logger

  def store(weather_datas)
    count = 0

    if weather_datas == nil
      return count
    end

    array = weather_datas.as(Array(WeatherCrystal::WeatherData))

    array.each do |data|
      result = store_data(data)
      count += 1 if result
    end

    return count
  end

  def store_data(data)
    return false if false == data.is_valid?

    if data.is_metar?
      return store_metar(data)
    else
      return store_regular(data)
    end
  end

  def store_metar?(data)
    interval = Time.utc_now - data.time_from.not_nil!
    return false if interval > METAR_THRESHOLD_STORE_TIME

    if @metar_last_times.has_key?(data.city.metar)
      if @metar_last_times[data.city.metar] >= data.time_from.not_nil!
        # already stored
        return false
      else
        # it is newer
        return true
      end
    else
      # not yet stored
      return true
    end
  end

  def store_metar(data)
    return false if false == store_metar?(data)

    monthly_prefix = data.time_from.not_nil!.to_s("%Y_%m")
    metar_code = data.city.metar
    path_dir = File.join("data", "metar", metar_code, monthly_prefix)
    path_file = File.join(path_dir, "#{metar_code}_#{monthly_prefix}.txt")

    Dir.mkdir_p(path_dir)

    file = File.new(path_file, "a")
    file.puts data.metar_string
    file.close

    # not to store equal
    @metar_last_times[data.city.metar] = data.time_from.not_nil!
    data.city.last_metar = data.metar_string.not_nil!

    return true
  end

  def store_regular(data)
    monthly_prefix = data.time_from.not_nil!.to_s("%Y_%m")
    path_dir = File.join("data", "regular", data.city.name.to_s, data.source.to_s, monthly_prefix)
    path_file = File.join(path_dir, "#{data.city.name}_#{data.source}_#{monthly_prefix}.txt")

    Dir.mkdir_p(path_dir)

    file = File.new(path_file, "a")
    file.puts data.to_json
    file.close

    return true
  end
end
