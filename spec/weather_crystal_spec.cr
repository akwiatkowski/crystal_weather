require "./spec_helper"

describe WeatherCrystal do
  it "gets METAR" do
    url = "http://pogoda.interia.pl/prognoza-szczegolowa-poznan,cId,27457"

    city = WeatherCrystal::WeatherCity.new
    city.name = "Poznań"
    city.country = "Poland"
    city.url_hash["InteriaPl"] = url

    f = WeatherCrystal::Provider::InteriaPl.new
    f.fetch_for_city(city)
  end
end
