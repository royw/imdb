Gem::Specification.new do |s|
  s.name = 'imdb'
  s.version = '0.0.11'
  s.summary = 'Internet Movie DataBase'
  s.authors = [ 'Sergio Gil' ]
  s.email = 'sgilperez@gmail.com'
  s.add_dependency('hpricot', '>= 0.6')
  s.add_dependency('chronic')
  s.files = [
    "lib/imdb/imdb_movie.rb",
    "lib/imdb/imdb_search.rb",
    "lib/imdb/imdb_image.rb",
    "lib/imdb.rb",
    "lib/file_extensions.rb",
    "lib/object_extensions.rb",
    "lib/string_extensions.rb",
    "README"
  ]
end