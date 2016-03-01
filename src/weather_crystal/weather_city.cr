class WeatherCrystal::WeatherCity
  @lat : Float64
  @lon : Float64
  @metar : String

  property :name
  property :country
  property :metar

  property :lat
  property :lon

  property :last_metar
  property :url_hash

  CLASSES_NAMES = [
    "InteriaPl",
  ]

  def initialize
    @metar = ""
    # last feftched metar string
    @last_metar = ""

    @url_hash = {} of String => String

    @lat = 0.0
    @lon = 0.0
  end

  def self.load_yaml(path)
    cities = [] of WeatherCrystal::WeatherCity

    s = File.read(path)
    data = YAML.parse(s)

    data.each do |hash|
      coords = hash[":coords"]

      city = new
      city.name = hash[":name"].to_s
      city.country = hash[":country"].to_s

      if hash[":metar"]?
        city.metar = hash[":metar"].to_s
      end

      # load data for external classes
      if hash[":classes"]?
        classes_hash = hash[":classes"]

        CLASSES_NAMES.each do |k|
          if classes_hash[k]?
            class_hash = classes_hash["InteriaPl"]
            city.url_hash[k] = class_hash[":url"].to_s
          end
        end
      end

      city.lat = coords[":lat"].to_s.to_f
      city.lon = coords[":lon"].to_s.to_f

      cities << city
    end

    return cities
  end
end
