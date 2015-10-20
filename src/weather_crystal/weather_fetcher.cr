require "yaml"
require "logger"

class WeatherCrystal::WeatherFetcher
  def initialize(config_path)
    @cities = WeatherCrystal::WeatherCity.load_yaml(config_path)
    @sleep_amount = 60*10
    @sleep_amount = 10
  end

  property :sleep_amount

  def one_fetch
    @cities.each do |city|

      o = WeatherCrystal::Provider::Noaa.new( city )
      weathers = o.fetch

      storage = WeatherCrystal::WeatherStorage.new
      count = storage.store( weathers )

      puts "#{city.metar} done with #{count} weather data" if count > 0
    end
  end

  def loop_fetch
    while true
      one_fetch

      puts "Sleep #{@sleep_amount} seconds"
      sleep sleep_amount
    end
  end
end
