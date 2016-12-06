# 3-hour for 5days forecast
class WeatherCrystal::Provider::OpenWeatherMap < WeatherCrystal::HttpProvider
  def self.provider_key
    "OpenWeatherMap"
  end

  def self.enabled?
    @@token != ""
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
      d.temperature_min = w["main"]["temp_min"].to_s.to_f
      d.temperature_max = w["main"]["temp_max"].to_s.to_f
      d.pressure = w["main"]["pressure"].to_s.to_f
      d.pressure_sea_level = w["main"]["sea_level"].to_s.to_f
      d.pressure_ground_level = w["main"]["grnd_level"].to_s.to_f

      d.clouds = w["clouds"]["all"].to_s.to_f.round.to_i

      d.wind = w["wind"]["speed"].to_s.to_f
      d.wind_direction = w["wind"]["deg"].to_s.to_f.round.to_i

      d.rain_mm = w["rain"]["3h"].to_s.to_f if w["rain"]? && w["rain"]["3h"]?
      d.snow_mm = w["snow"]["3h"].to_s.to_f if w["snow"]? && w["snow"]["3h"]?

      array << d
    end

    return array
  end
end
