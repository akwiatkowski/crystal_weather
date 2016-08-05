require "http"

# All ugly providers who parse even uglier html code and rip off data
class WeatherCrystal::HttpProvider < WeatherCrystal::Provider
  TYPE = :http

  def fetch_for_city(city)
    begin
      url = url_for_city(city)
      return [] of WeatherData if url == ""

      result = download(url)
      if is_okay?(result)
        return process_for_city(city, process_body(result.body))
      else
        self.logger.error("HttpProvider Http status not 200 != #{result.status_code}, url #{url}, city #{city.inspect}")
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

  def is_okay?(result)
    return result.success?
  end

  def download(url)
    headers = HTTP::Headers.new
    # there was problem with Zlib and Wunderground
    headers["Accept-Encoding"] = "gzip;q=0,deflate;q=0"
    headers["User-Agent"] = "Mozilla/5.0 (Windows NT 6.0) AppleWebKit/537.11 (KHTML, like Gecko) Chrome/23.0.1271.97 Safari/537.11"
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
