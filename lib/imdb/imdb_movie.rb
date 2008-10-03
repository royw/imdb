class ImdbMovie
  
  attr_accessor :id, :url, :title
  
  def initialize(id, title = nil)
    @id = id
    @url = "http://www.imdb.com/title/tt#{self.id}/"
    # @title = title
  end
  
  def title
    document.at("div#tn15title h1").innerHTML.split('<span>').first.strip.unescape_html rescue nil    
  end
  
  def directors
    document.search("h5[text()^='Director'] ~ a").map { |link| link.innerHTML.strip.unescape_html }.reject { |w| w == 'more' }.uniq rescue []
  end
  
  def poster
    poster_url = document.at("a[@name='poster']")['href']
    Hpricot(open("#{File.join("http://www.imdb.com/", document.at("a[@name='poster']")['href'])}").read).at("table#principal tr td img")['src'] rescue nil
  end
  
  def cast_members
    # document.search("table.cast td.nm a").map { |link| link.innerHTML.strip.unescape_html } rescue []
    document.search("table.cast tr").inject([]) do |result, row|
      a = row.search("td.nm a").innerHTML.strip.unescape_html
      c = row.search("td.char a").innerHTML.strip.unescape_html
      if c.empty?
        c = row.search("td.char").innerHTML.strip.unescape_html
      end
      result << [a,c]
    end
  end
  
  def writers
    document.search("h5[text()^='Writer'] ~ a").map { |link| link.innerHTML.strip.unescape_html }.reject { |w| w == 'more' }.uniq rescue []
  end
  
  def release_date
    date = document.search("//h5[text()^='Release Date']/..").innerHTML[/^\d{1,2} \w+ \d{4}/]
    Date.parse(Chronic.parse(date).strftime('%Y/%m/%d'))
  rescue
    nil
  end
  
  def genres
    document.search("h5[text()='Genre:'] ~ a[@href*=/Sections/Genres/']").map { |link| link.innerHTML.strip.unescape_html } rescue []
  end
  
  def plot
    document.search("//h5[text()^='Plot']/..").innerHTML.split("\n")[2].gsub(/<.+>.+<\/.+>/, '').strip.unescape_html rescue nil
  end
  
  def tagline
    document.search("//h5[text()^='Tagline']/..").innerHTML.split("\n")[2].gsub(/<.+>.+<\/.+>/, '').strip.unescape_html rescue nil
  end
  
  def aspect_ratio
    document.search("//h5[text()^='Aspect Ratio']/..").innerHTML.split("\n")[2].gsub(/<.+>.+<\/.+>/, '').strip.unescape_html rescue nil
  end
  
  def length
    document.search("//h5[text()^='Runtime']/..").innerHTML[/\d+ min/] rescue nil
  end

  def countries
    document.search("h5[text()='Country:'] ~ a[@href*=/Sections/Countries/']").map { |link| link.innerHTML.strip.unescape_html } rescue []
  end

  def languages
    document.search("h5[text()='Language:'] ~ a[@href*=/Sections/Languages/']").map { |link| link.innerHTML.strip.unescape_html } rescue []
  end
  
  def color
    document.at("h5[text()='Color:'] ~ a[@href*=color-info']").innerHTML.strip.unescape_html rescue nil
  end

  def company
    document.at("h5[text()='Company:'] ~ a[@href*=/company/']").innerHTML.strip.unescape_html rescue nil
  end
  
  def photos
    document.search(".media_strip_thumb img").map { |img| img['src'] } rescue []
  end
  
  def get_data
    update_title
  end
  
  def title2
    document.at("div#tn15title h1").innerHTML.split('<span>').first.unescape_html rescue nil
  end
    
  private
  
  def update_title
    # @title = document.at("h1").innerHTML.split('<span').first.strip.unescape_html rescue nil    
    document.at("div#tn15title h1").innerHTML.split('<span>').first.unescape_html rescue nil
  end
  
  def document
    @document ||= Hpricot(open(self.url).read)
  end
  
end
