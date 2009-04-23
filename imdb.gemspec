# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{imdb}
  s.version = "0.1.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Roy Wright"]
  s.date = %q{2009-04-22}
  s.email = %q{roy@wright.org}
  s.extra_rdoc_files = [
    "README"
  ]
  s.files = [
    "History.txt",
    "Rakefile",
    "VERSION.yml",
    "lib/imdb.rb",
    "lib/imdb/imdb_image.rb",
    "lib/imdb/imdb_movie.rb",
    "lib/imdb/imdb_profile.rb",
    "lib/imdb/imdb_search.rb",
    "lib/imdb/optional_logger.rb",
    "spec/imdb_image_spec.rb",
    "spec/imdb_movie_spec.rb",
    "spec/imdb_profile_spec.rb",
    "spec/imdb_search_spec.rb",
    "spec/samples/sample_image.html",
    "spec/samples/sample_incomplete_movie.html",
    "spec/samples/sample_jet_pilot.html",
    "spec/samples/sample_meltdown.html",
    "spec/samples/sample_movie.html",
    "spec/samples/sample_open_season.html",
    "spec/samples/sample_search.html",
    "spec/samples/sample_spanish_search.html",
    "spec/samples/sample_who_am_i_search.html",
    "spec/samples/www.imdb.com/find?q=Meltdown;s=tt",
    "spec/samples/www.imdb.com/find?q=National+Treasure%3A+Book+of+Secrets;s=tt",
    "spec/samples/www.imdb.com/find?q=National+Treasure+2;s=tt",
    "spec/samples/www.imdb.com/find?q=Open+Season;s=tt",
    "spec/samples/www.imdb.com/find?q=The+Alamo;s=tt",
    "spec/samples/www.imdb.com/find?q=Who+Am+I%3F;s=tt",
    "spec/samples/www.imdb.com/find?q=indiana+jones;s=tt",
    "spec/samples/www.imdb.com/find?q=some+extremely+specific+search+for+indiana+jones;s=tt",
    "spec/samples/www.imdb.com/rg/action-box-title/primary-photo/media/rm1203608832/tt0097576",
    "spec/spec_helper.rb",
    "spec/string_extensions_spec.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/royw/imdb}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{TODO}
  s.test_files = [
    "spec/imdb_movie_spec.rb",
    "spec/spec_helper.rb",
    "spec/imdb_search_spec.rb",
    "spec/imdb_image_spec.rb",
    "spec/string_extensions_spec.rb",
    "spec/imdb_profile_spec.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<royw-roys_extensions>, [">= 0.0.2"])
      s.add_runtime_dependency(%q<royw-read_page_cache>, [">= 0.0.1"])
    else
      s.add_dependency(%q<royw-roys_extensions>, [">= 0.0.2"])
      s.add_dependency(%q<royw-read_page_cache>, [">= 0.0.1"])
    end
  else
    s.add_dependency(%q<royw-roys_extensions>, [">= 0.0.2"])
    s.add_dependency(%q<royw-read_page_cache>, [">= 0.0.1"])
  end
end
