$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'
require 'open-uri'
require 'date'
require 'cgi'
require 'hpricot'
require 'chronic'
require 'xmlsimple'

# royw gems on github
require 'roys_extensions'

# local files
require 'imdb/optional_logger'
require 'imdb/imdb_search'
require 'imdb/imdb_movie'
require 'imdb/imdb_profile'
require 'imdb/imdb_image'
