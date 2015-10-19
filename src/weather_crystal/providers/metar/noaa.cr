class WeatherCrystal::Provider::Noaa < WeatherCrystal::MetarProvider
  def url
    return "http://weather.noaa.gov/pub/data/observations/metar/stations/#{city.metar.to_s.upcase}.TXT"
  end

  def process_a(string)
    string.gsub!(/\d{4}\/\d{1,2}\/\d{1,2} \d{1,2}\:\d{1,2}\s*/, ' ')
    string.gsub!(/\n/, ' ')
    string.gsub!(/\t/, ' ')
    string.gsub!(/\s{2,}/, ' ')
    string.strip
  end
end
