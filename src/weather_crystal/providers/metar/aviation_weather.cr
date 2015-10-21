class WeatherCrystal::Provider::AviationWeather < WeatherCrystal::MetarProvider
  def url_for_city(city)
    return "" if city.metar == ""
    return "http://aviationweather.gov/adds/metars/index.php?submit=1&station_ids=#{city.metar.to_s.upcase}"
  end

  def process_body(string)
    reg = /\">([^<]*)<\/FONT>/i
    string = string.scan(reg)[0][1]

    string = string.gsub(/\n/, ' ')
    string = string.gsub(/\t/, ' ')
    string = string.gsub(/\s{2,}/, ' ')
    string = string.strip

    return string
  end

end
