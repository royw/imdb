class ImdbSearch

  attr_accessor :query

  def initialize(query)
    self.query = query
  end

  def movies
    @movies ||= parse_movies_from_document
  end

  private

  def document
    @document ||= Hpricot(open("http://www.imdb.com/find?q=#{CGI::escape(query)};s=tt").read)
  end

  def parse_movies_from_document
    exact_match? ? parse_exact_match_search_results : parse_multi_movie_search_results
  end

  def parse_exact_match_search_results
    id = document.at("a[@name='poster']")['href'][/\d+$/]
    title = document.at("h1").innerHTML.split('<span').first.strip.unescape_html rescue nil
    [ImdbMovie.new(id, title)]
  end

  def parse_multi_movie_search_results
    ids_and_titles = document.search('a[@href^="/title/tt"]').reject do |element|
      element.innerHTML.strip_tags.empty?
    end.map do |element|
      [element['href'][/\d+/], element.innerHTML.strip_tags.unescape_html]
    end.uniq
    ids_and_titles.map do |id_and_title|
      ImdbMovie.new(id_and_title[0], id_and_title[1])
    end
  end

  def exact_match?
    document.search("title[text()='IMDb Title Search']").empty?
  end

end