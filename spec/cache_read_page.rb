module CacheReadPage
  def read_page(page)
    html = nil
    filespec = self.url.gsub(/^http:\//, 'spec/samples').gsub(/\/$/, '.html')
    if File.exist?(filespec)
      html = fetch(filespec)
    else
      html = fetch(self.url)
      cache_html_files(html)
    end
    html
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
