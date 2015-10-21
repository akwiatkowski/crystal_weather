require "./spec_helper"
require "xml"

describe WeatherCrystal::Provider::InteriaPl do
  it "gets single weather" do
    url = "http://pogoda.interia.pl/prognoza-szczegolowa-poznan,cId,27457"

    city = WeatherCrystal::WeatherCity.new
    city.name = "Poznań"
    city.country = "Poland"
    city.url_hash["InteriaPl"] = url

    f = WeatherCrystal::Provider::InteriaPl.new
    array = f.fetch_for_city(city)

    puts array.inspect

  end
end
