class ImdbSearch

  attr_reader :query

  def initialize(query, search_akas=false)
    @query = query
    @search_akas = search_akas
    @cache = {}
  end

  def movies
    @movies ||= parse_movies_from_document
  end

  def set_cache(cache)
    @cache = cache
  end

  # Find the IMDB ID for the current search title
  # The find can be helped a lot by including a years option that contains
  # an Array of integers that are the production year (plus/minus a year)
  # and the release year.
  def find_id(options={})
    id = nil
    found_movies = self.movies.select do |m|
      result = true
      unless options[:years].nil?
        result = options[:years].include?(m.release_year.to_i)
      end
      result
    end
#     p found_movies.collect{|m| [m.id, m.title, m.year]}
    ids = found_movies.collect{|m| m.id}.uniq.compact
    if ids.length == 1
      id = "tt#{ids[0]}"
    end
    id
  end

  protected

  # compare the imdb title and the imdb title's AKAs against the media title.
  # note, on exact match lookups, IMDB will sometimes set the title to
  # 'trailers and videos' instead of the correct title.
  def imdb_compare_titles(imdb_title, aka_titles, media_title)
    result = fuzzy_compare_titles(imdb_title, media_title)
    unless result
      result = fuzzy_compare_titles(imdb_title, 'trailers and videos')
      unless result
        aka_titles.each do |aka|
          result = fuzzy_compare_titles(aka, media_title)
          break if result
        end
      end
    end
    result
  end

  # a fuzzy compare that is case insensitive and replaces '&' with 'and'
  # (because that is what IMDB occasionally does)
  def fuzzy_compare_titles(title1, title2)
    t1 = title1.downcase
    t2 = title2.downcase
    (t1 == t2) ||
    (t1.gsub(/&/, 'and') == t2.gsub(/&/, 'and')) ||
    (t1.gsub(/[-:]/, ' ') == t2.gsub(/[-:]/, ' ')) ||
    (t1.gsub('more at imdbpro ?', '') == t2)
  end

  def getMovie(id, title)
    obj = nil
    unless id.blank?
      name = id.to_s
      name += ' ' + title unless title.blank?
      obj = @cache[name]
      if obj.nil?
        obj = ImdbMovie.new(id,title)
        @cache[name] = obj
      end
    end
    obj
  end


  private

  def document
    filespec = "http://www.imdb.com/find?q=#{CGI::escape(@query)};s=tt"
    @document ||= Hpricot(fetch(filespec))
  end

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
    open(page).read
  end

  def parse_movies_from_document
    exact_match? ? parse_exact_match_search_results : parse_multi_movie_search_results
  end

  def parse_exact_match_search_results
    id = document.at("a[@name='poster']")['href'][/\d+$/]
    title = document.at("h1").innerHTML.split('<span').first.strip.unescape_html rescue nil
    [getMovie(id, title)]
  end

  def parse_multi_movie_search_results
    ids_and_titles = document.search('a[@href^="/title/tt"]').reject do |element|
      element.innerHTML.strip_tags.empty?
    end.map do |element|
      [element['href'][/\d+/], element.innerHTML.strip_tags.unescape_html]
    end.uniq

    films = ids_and_titles.map do |id_and_title|
      getMovie(id_and_title[0], id_and_title[1])
    end.uniq.compact

    if films.length > 1
      same_title_films = films.select do |m|
        aka = (@search_akas ? m.also_known_as : [])
        !m.video_game? && imdb_compare_titles(m.title, aka, @query)
      end
      if same_title_films.size > 0
        films = same_title_films
      end
    end

    films
  end

  def exact_match?
    document.search("title[text()='IMDb Title Search']").empty? && !document.search("a[@name='poster']").empty?
  end

end