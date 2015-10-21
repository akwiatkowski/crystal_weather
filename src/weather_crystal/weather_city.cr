class WeatherCrystal::WeatherCity
  @lat :: Float64
  @lon :: Float64
  @metar :: String

  property :name
  property :country
  property :metar

  property :lat
  property :lon

  property :last_metar

  def initialize
    @metar = ""
    # last feftched metar string
    @last_metar = ""

    @lat = 0.0
    @lon = 0.0
  end

  def self.load_yaml(path)
    cities = [] of WeatherCrystal::WeatherCity

    s = File.read(path)
    data = YAML.load(s) as Array

    data.each do |d|
      hash = d as Hash(YAML::Type, YAML::Type)
      coords = hash[":coords"] as Hash(YAML::Type, YAML::Type)

      city = new
      city.name = hash[":name"]
      city.country = hash[":country"]

      if hash.has_key?(":metar")
        city.metar = hash[":metar"].to_s
      end

      city.lat = coords[":lat"].to_s.to_f
      city.lon = coords[":lon"].to_s.to_f

      cities << city
    end

    return cities
  end
end
