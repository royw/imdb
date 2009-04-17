$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'
require 'open-uri'
require 'date'
require 'cgi'
require 'hpricot'
require 'chronic'
require 'xmlsimple'

require 'imdb/optional_logger'
require 'imdb/imdb_search'
require 'imdb/imdb_movie'
require 'imdb/imdb_profile'
require 'imdb/imdb_image'
require 'module_extensions'
require 'string_extensions'
require 'file_extensions'
require 'object_extensions'