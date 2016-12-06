class WeatherCrystal::Provider::InteriaPl < WeatherCrystal::HttpProvider
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
    array = Array(WeatherData).new

    parser = Myhtml::Parser.new(data)

    initial_time = Time.new(
      Time.now.year,
      Time.now.month,
      Time.now.day
    )
    day = 0

    parser.css(".main-content").to_a.each do |m|
      m.css(".weather-forecast-day").to_a.each do |day_node|
        # days iteration
        hourly_nodes = day_node.css(".weather-entry").to_a
        hourly_nodes.each do |hourly_node|
          d = WeatherData.new(city)
          d.source = self.class.provider_key

          hour_node = hourly_node.css(".entry-hour .hour").first
          hour = hour_node.children.first.tag_text.to_s.to_i

          minute_node = hourly_node.css(".entry-hour .minutes").first
          minute = hour_node.children.first.tag_text.to_s.to_i

          d.time_from = initial_time + Time::Span.new(day, hour, minute, 0)
          d.time_to = d.time_from + Time::Span.new(1, 0, 0)

          temperature_node = hourly_node.css(".forecast-temp").first
          temperature = temperature_node.children.first.tag_text.to_s.gsub(/°C/, "").to_f
          d.temperature = temperature

          wind_chill_node = hourly_node.css(".forecast-feeltemp").first
          wind_chill = wind_chill_node.children.first.tag_text.to_s.gsub(/Odczuwalna/, "").gsub(/°C/, "").strip.to_f
          d.wind_chill = wind_chill

          wind_speed_in_kmh_node = hourly_node.css(".speed-value").first
          wind_speed_in_kmh = wind_speed_in_kmh_node.children.first.tag_text.to_s.to_f
          d.wind_speed_in_kmh = wind_speed_in_kmh

          max_wind_speed_in_kmh_node = hourly_node.css(".wind-hit").first
          max_wind_speed_in_kmh = max_wind_speed_in_kmh_node.children.first.tag_text.to_s.gsub(/Max/, "").gsub("km/h", "").strip.to_f
          d.max_wind_speed_in_kmh = max_wind_speed_in_kmh

          clouds_nodes = hourly_node.css(".entry-precipitation-value.cloud-cover").to_a
          if clouds_nodes.size > 0
            clouds_node = clouds_nodes.first
            clouds = clouds_node.children.first.tag_text.to_s.gsub(/\D/, "").strip.to_i
            d.clouds = clouds
          end

          rain_mm_nodes = hourly_node.css(".entry-precipitation-value.rain").to_a
          if rain_mm_nodes.size > 0
            rain_mm_node = rain_mm_nodes.first
            rain_mm = rain_mm_node.children.first.tag_text.to_s.gsub(/\D/, "").strip.to_f
            d.rain_mm = rain_mm
          else
            d.rain_mm = 0.0
          end

          snow_mm_nodes = hourly_node.css(".entry-precipitation-value.snow").to_a
          if snow_mm_nodes.size > 0
            snow_mm_node = snow_mm_nodes.first
            snow_mm = snow_mm_node.children.first.tag_text.to_s.gsub(/\D/, "").strip.to_f
            d.snow_mm = snow_mm
          else
            d.snow_mm = 0.0
          end

          d.source = self.class.provider_key

          array << d
        end
      end
    end

    return array
  end
end
