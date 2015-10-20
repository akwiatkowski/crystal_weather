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
      store_data(data)
      count += 1
    end

    return count
  end

  def store_data(data)
    if data.is_metar?
      store_metar(data)
    else
      store_regular(data)
    end

  end

  def store_metar(data)
    monthly_prefix = data.time_from.to_s("%Y_%m")
    metar = data.city.metar
    path_dir = File.join("data", "metar", metar, monthly_prefix)
    path_file = File.join(path_dir, "#{metar}_#{monthly_prefix}.txt")

    Dir.mkdir_p(path_dir)

    file = File.new(path_file, "a")
    file.puts data.metar_string
    file.close
  end

  def store_regular(data)
  end
end
