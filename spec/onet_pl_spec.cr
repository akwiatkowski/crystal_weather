# require "./spec_helper"
# require "xml"
#
# describe WeatherCrystal::Provider::OnetPl do
#   it "gets single weather from OnetPl" do
#     url = "http://pogoda.onet.pl/prognoza-pogody/dzis/europa,polska,poznan,9204.html"
#
#     city = WeatherCrystal::WeatherCity.new
#     city.name = "Poznań"
#     city.country = "Poland"
#     city.url_hash["OnetPl"] = url
#
#     f = WeatherCrystal::Provider::OnetPl.new
#     array = f.fetch_for_city(city)
#
#     puts array.inspect
#   end
# end
