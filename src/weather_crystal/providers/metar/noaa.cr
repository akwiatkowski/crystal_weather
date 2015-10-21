class WeatherCrystal::Provider::Noaa < WeatherCrystal::MetarProvider
  def url_for_city(city)
    return "" if city.metar == ""
    return "http://weather.noaa.gov/pub/data/observations/metar/stations/#{city.metar.to_s.upcase}.TXT"
  end

  def process_body(string)
    string = string.gsub(/\d{4}\/\d{1,2}\/\d{1,2} \d{1,2}\:\d{1,2}\s*/, ' ')
    string = string.gsub(/\n/, ' ')
    string = string.gsub(/\t/, ' ')
    string = string.gsub(/\s{2,}/, ' ')
    string.strip
  end
end
