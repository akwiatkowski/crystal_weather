require "xml"

class WeatherCrystal::Provider::InteriaPl < WeatherCrystal::HttpProvider
  def self.provider_name
    "Interia.pl"
  end

  def self.provider_key
    "InteriaPl"
  end

  def url_for_city(city)
    if city.url_hash.has_key?(self.class.provider_key)
      return city.url_hash[self.class.provider_key]
    else
      return ""
    end
  end

  def process_for_city(city, data)
    array = [] of WeatherData

    x = XML.parse_html(data)
    initial_time = Time.new(
      Time.now.year,
      Time.now.month,
      Time.now.day
    )
    day = 0

    main_content = x.xpath_node("//*[@class='main-content']")
    forecast_day_nodes = main_content.xpath_nodes(".//*[contains(@class, 'weather-forecast-day')]")
    forecast_day_nodes.each do |day_node|
      hourly_nodes = day_node.xpath_nodes(".//*[@class='weather-entry']")
      hourly_nodes.each do |hour_node|
        begin
          d = WeatherData.new(city)

          hour = hour_node.xpath_node(".//*[@class='hour']").inner_text.to_s.to_i
          d.time_from = initial_time + Time::Span.new(day, hour, 0, 0)
          d.time_to = d.time_from + Time::Span.new(1, 0, 0)

          d.temperature = hour_node.xpath_node(".//*[@class='forecast-temp']").inner_text.to_s.to_f
          wind_chill = hour_node.xpath_node(".//*[@class='forecast-feeltemp']").inner_text.to_s.gsub(/\D/, "").to_f
          d.wind_chill = wind_chill

          d.wind_speed_in_kmh = hour_node.xpath_node(".//*[@class='speed-value']").inner_text.to_s.to_f
          d.max_wind_speed_in_kmh = hour_node.xpath_node(".//*[@class='wind-hit']").inner_text.to_s.gsub(/\D/, "").to_f

          d.clouds = hour_node.xpath_node(".//*[@class='entry-precipitation-value cloud-cover']").inner_text.to_s.gsub(/\D/, "").to_i
          d.rain_mm = hour_node.xpath_node(".//*[@class='entry-precipitation-value rain']").inner_text.to_s.gsub(/\D/, "").to_i

          d.source = self.class.provider_key

          array << d
        rescue
          # error
        end
      end
      day += 1
    end

    return array
  end
end
