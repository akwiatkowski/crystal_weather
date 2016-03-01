require "http"

# All ugly providers who parse even uglier html code and rip off data
class WeatherCrystal::HttpProvider < WeatherCrystal::Provider
  TYPE = :http

  def fetch_for_city(city)
    begin
      url = url_for_city(city)
      return [] of WeatherData if url == ""

      result = download(url)
      if result.status_code == 200
        return process_for_city(city, process_body(result.body))
      else
        self.logger.error("HttpProvider Http status not 200, url #{url}, city #{city.inspect}")
        return [] of WeatherData
      end
    rescue Socket::Error
      self.logger.error("HttpProvider Socket::Error, city #{city.inspect}")
      return [] of WeatherData
      # rescue ex
      #  self.logger.error("HttpProvider Other error, city #{city.inspect}, #{ex.message}")
      #  self.logger.error("#{ex.cause}")
      #  self.logger.error("#{ex.backtrace}")
      #  return [] of WeatherData
    end
  end

  def download(url)
    headers = HTTP::Headers.new
    # there was problem with Zlib and Wunderground
    headers["Accept-Encoding"] = "gzip;q=0,deflate;q=0"
    response = HTTP::Client.exec("GET", url, headers)
    return response
  end

  def process_body(body)
    body
  end

  def url_for_city(city)
    raise NotImplementedError
  end

  def process_for_city(city, data)
    raise NotImplementedError
  end
end
