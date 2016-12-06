require "./spec_helper"
require "xml"

describe WeatherCrystal::Provider::OpenWeatherMap do
  it "gets single weather from OpenWeatherMap" do
    city = WeatherCrystal::WeatherCity.new
    city.name = "Poznań"
    city.country = "Poland"
    city.lat = 52.411048
    city.lon = 16.928329

    key_path = File.join("config", "keys.yml")
    WeatherCrystal::Provider::OpenWeatherMap.load_key(key_path)

    f = WeatherCrystal::Provider::OpenWeatherMap.new
    array = f.fetch_for_city(city)

    puts array.last.inspect
  end
end
