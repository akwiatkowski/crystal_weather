require "./spec_helper"
require "xml"

describe WeatherCrystal::Provider::InteriaPl do
  it "gets single weather from InteriaPl" do
    url = "https://pogoda.interia.pl/prognoza-szczegolowa-poznan,cId,27457"

    city = WeatherCrystal::WeatherCity.new
    city.name = "Poznań"
    city.country = "Poland"
    city.url_hash["InteriaPl"] = url

    f = WeatherCrystal::Provider::InteriaPl.new
    array = f.fetch_for_city(city)

    (array.size == 0).should eq false

    array.each do |d|
      (d.temperature.not_nil! > -50.0).should eq true
    end

    puts array.last.inspect
  end
end
