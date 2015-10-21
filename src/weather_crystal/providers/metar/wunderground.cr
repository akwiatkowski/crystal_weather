class WeatherCrystal::Provider::Wunderground < WeatherCrystal::MetarProvider
  def url_for_city(city)
    return "" if city.metar == ""
    return "http://www.wunderground.com/Aviation/index.html?query=#{city.metar.upcase}"
  end

  def process_body(string)
    reg = /<div class=\"textReport\">\s*METAR\s*([^<]*)<\/div>/
    _s = string.scan(reg)
    return nil if _s.size == 0

    string = _s[0][1].to_s.strip
    string = string.gsub(/\n/, ' ')
    string = string.gsub(/\t/, ' ')
    string = string.gsub(/\s{2,}/, ' ')
    return string.strip
  end
end
