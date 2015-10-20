class WeatherCrystal::WeatherStorage
  def initialize
  end

  def store(weather_datas)
    count = 0

    if weather_datas == nil
      return count
    end

    array = weather_datas as Array(WeatherCrystal::WeatherData)

    array.each do |data|
      result = store_data(data)
      count += 1 if result
    end

    return count
  end

  def store_data(data)
    if data.is_metar?
      return store_metar(data)
    else
      return store_regular(data)
    end
  end

  def store_metar(data)
    if data.city.last_metar == data.metar_string
      # was stored
      return false
    end

    monthly_prefix = data.time_from.to_s("%Y_%m")
    metar_code = data.city.metar
    path_dir = File.join("data", "metar", metar_code, monthly_prefix)
    path_file = File.join(path_dir, "#{metar_code}_#{monthly_prefix}.txt")

    Dir.mkdir_p(path_dir)

    file = File.new(path_file, "a")
    file.puts data.metar_string
    file.close

    # not to store equal
    data.city.last_metar = data.metar_string

    return true
  end

  def store_regular(data)
    return false
  end
end
