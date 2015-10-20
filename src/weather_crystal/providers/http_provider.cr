require "http"

# All ugly providers who parse even uglier html code and rip off data
class WeatherCrystal::HttpProvider < WeatherCrystal::Provider

  TYPE = :http

  def fetch
    begin
      result = download(url)
      if result.status_code == 200
        return process(result.body)
      else
        return nil
      end
    rescue Socket::Error
      puts "Socket::Error"
      return nil
    rescue
      puts "Other error"
      return nil
    end
  end

  def download(url)
    return HTTP::Client.get(url)
  end

  def url
    raise NotImplementedError
  end

end
