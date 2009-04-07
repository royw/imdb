# @imdb_movie.poster.should == 'http://ia.media-imdb.com/images/M/MV5BMTkzODA5ODYwOV5BMl5BanBnXkFtZTcwMjAyNDYyMQ@@._V1._SX216_SY316_.jpg'

class ImdbImage

  attr_accessor :url

  def initialize(url)
    @url = File.join("http://www.imdb.com/", url)
  end

  def image
    document.at("table#principal tr td img")['src'] rescue nil
  end

  def document
    @document ||= Hpricot(fetch(self.url))
  end

  private

  MAX_ATTEMPTS = 3
  SECONDS_BETWEEN_RETRIES = 1.0

  def fetch(page)
    doc = nil
    attempts = 0
    begin
      doc = read_page(page)
    rescue Exception => e
      attempts += 1
      if attempts > MAX_ATTEMPTS
        raise
      else
        sleep SECONDS_BETWEEN_RETRIES
        retry
      end
    end
    doc
  end

  def read_page(page)
    puts "ImdbImage::read_page"
    open(page).read
  end

end