require 'yaml'
require 'xmlsimple'

class ImdbMovie
  include Comparable

  attr_reader :id, :url#, :title

  def initialize(id, title = nil)
    @id = id
    @url = "http://www.imdb.com/title/tt#{@id}/"
    @title = title
  end

  # this is intended to be stubed by rspec where it
  # should return true.
  def self.use_html_cache
    false
  end

  # add comparator so Arrays containing ImdbMovie objects
  # can use uniq()
  def <=>(other)
    @id <=> other.id
  end

  def title
    if @title.nil?
      @title = document.at("div#tn15title h1").innerHTML.split('<span>').first.strip.unescape_html rescue nil
    end
    @title
  end

  def directors
    document.search("h5[text()^='Director'] ~ a").map { |link| link.innerHTML.strip.unescape_html }.reject { |w| w == 'more' }.uniq rescue []
  end

  def poster_url
    document.at("a[@name='poster']")['href'] rescue nil
  end

  def tiny_poster_url
    document.at("a[@name='poster'] img")['src'] rescue nil
  end

  def poster
    ImdbImage.new(poster_url) rescue nil
  end

  def rating
    document.at("h5[text()='User Rating:'] ~ b").innerHTML.strip.unescape_html.split('/').first.to_f rescue nil
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

  def year
    document.search('a[@href^="/Sections/Years/"]').innerHTML
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

  # return the raw title
  def raw_title
    document.at("h1").innerText
  end

  # is this a video game as indicated by a '(VG)' in the raw title?
  def video_game?
    raw_title =~ /\(VG\)/
  end

  # find the release year
  # Note, this is needed because not all entries on IMDB have a full
  # release date as parsed by release_date.
  def release_year
    document.search("//h5[text()^='Release Date']/..").innerHTML[/\d{4}/]
  end

  # return an Array of Strings containing AKA titles
  def also_known_as
    el = document.search("//h5[text()^='Also Known As:']/..").at('h5')
    aka = []
    while(!el.nil?)
      aka << el.to_s unless el.elem?
      el = el.next
    end
    aka.collect!{|a| remove_parens(a).strip}
    aka.uniq!
    aka.compact!
    aka.select{|a| !a.empty?}
  end

  def remove_parens(str)
    while str =~ /\(.*\)/
      str.gsub!(/\([^\)\(]*\)/, '')
    end
    str
  end

  # The MPAA rating, i.e. "PG-13"
  def mpaa
    document.search("//h5[text()^='MPAA']/..").text.gsub('MPAA:', '').strip rescue nil
  end

  # older films may not have MPAA ratings but usually have a certification.
  # return a hash with country abbreviations for keys and the certification string for the value
  # example:  {'USA' => 'Approved'}
  def certifications
    cert_hash = {}
    certs = document.search("h5[text()='Certification:'] ~ a[@href*=/List?certificates']").map { |link| link.innerHTML.strip } rescue []
    certs.each { |line| cert_hash[$1] = $2 if line =~ /(.*):(.*)/ }
    cert_hash
  end

  def to_hash
    hash = {}
    [:title, :directors, :poster_url, :tiny_poster_url, :poster, :rating, :cast_members,
     :writers, :year, :genres, :plot, :tagline, :aspect_ratio, :length, :release_date,
     :countries, :languages, :color, :company, :photos, :raw_title, :release_year,
     :also_known_as, :mpaa, :certifications
    ].each do |sym|
      begin
        value = send(sym.to_s)
        hash[sym.to_s] = value unless value.nil?
      rescue Exception => e
        puts "Error getting data for hash for #{sym} - #{e.to_s}"
      end
    end
    hash
  end

  def to_xml
    XmlSimple.xml_out(to_hash, 'NoAttr' => true, 'RootName' => 'movie')
  end

  def to_yaml
    YAML.dump(to_hash)
  end

  private

#   def update_title
#     @title = document.at("h1").innerHTML.split('<span').first.strip.unescape_html rescue nil
#     #document.at("div#tn15title h1").innerHTML.split('<span>').first.unescape_html rescue nil
#   end

  MAX_ATTEMPTS = 3
  SECONDS_BETWEEN_RETRIES = 1.0

  # Fetch the document with retry to handle the occasional glitches
  def document
    attempts = 0
    begin
      if ImdbMovie::use_html_cache
        begin
          filespec = self.url.gsub(/^http:\//, 'spec/samples').gsub(/\/$/, '.html')
          html = open(filespec).read
        rescue Exception
          html = open(self.url).read
          cache_html_files(html)
        end
      else
        html = open(self.url).read
      end
      @document ||= Hpricot(html)
    rescue Exception => e
      attempts += 1
      if attempts > MAX_ATTEMPTS
        raise
      else
        sleep SECONDS_BETWEEN_RETRIES
        retry
      end
    end
    @document
  end

  # this is used to save imdb pages so they may be used by rspec
  def cache_html_files(html)
    begin
      filespec = self.url.gsub(/^http:\//, 'spec/samples').gsub(/\/$/, '.html')
      unless File.exist?(filespec)
        puts "caching #{filespec}"
        File.mkdirs(File.dirname(filespec))
        File.open(filespec, 'w') { |f| f.puts html }
      end
    rescue Exception => eMsg
      puts eMsg.to_s
    end
  end

end
