# 3-hour for 5days forecast
class WeatherCrystal::Provider::OpenWeatherMap < WeatherCrystal::HttpProvider
  def self.provider_key
    "OpenWeatherMap"
  end

  def url_for_city(city)
    # http://openweathermap.org/forecast5#JSON
    u = "api.openweathermap.org/data/2.5/forecast?lat=#{city.lat}&lon=#{city.lon}&APPID=#{@@token}&units=metric"
    return u
  end

  def process_for_city(city, data)
    array = Array(WeatherData).new

    data = JSON.parse(data)

    data["list"].each do |w|
      d = WeatherData.new(city: city)
      d.source = self.class.provider_key

      d.time_from = Time.epoch(w["dt"].to_s.to_i)
      d.time_to = d.time_from.not_nil! + Time::Span.new(3, 0, 0)

      d.temperature = w["main"]["temp"].to_s.to_f

      array << d
    end

    return array
  end
end
