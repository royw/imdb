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
    @document ||= Hpricot(open(self.url).read)
  end
  
end