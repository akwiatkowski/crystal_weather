require "xml"

class WeatherCrystal::Provider::InteriaPl < WeatherCrystal::HttpProvider
  def self.provider_name
    "Interia.pl"
  end

  def self.provider_key
    "InteriaPl"
  end

  def url_for_city(city)
    if city.url_hash.has_key?( self.class.provider_key )
      return city.url_hash[ self.class.provider_key ]
    else
      return ""
    end
  end

  def process_for_city(city, data)
    d = WeatherData.new(city)

    x = XML.parse_html(data)
    #forecast_days = x.xpath_node("*[contains(@class,weather-forecast-day)]")
    forecast_days = x.xpath_node("//*[contains(@class,hour)]")
    puts forecast_days.attributes

    puts data

    #forecast_days.si.each do |day_node|
    #  puts day_node.attributes
      #puts day_node.xpath_node("//*[contains(@class,weather-entry)]").children.size
    #  hourly_nodes = day_node.xpath_node("//*[contains(@class,weather-entry)]")
    #  hourly_nodes.each do |hour_node|
    #    hour = hour_node.xpath_node("//*[contains(@class,hour)]")
    #    puts hour.inner_text
    #  end
    #end

    return d
  end
end
