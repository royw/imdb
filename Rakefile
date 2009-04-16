require 'rubygems'
require 'rake'
require 'spec/rake/spectask'

desc "Run all specs"
task :default => :spec

Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new('spec:html') do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
  spec.spec_opts = ["--format", "html:spec.html"]
end

Spec::Rake::SpecTask.new('spec:readme') do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
  spec.spec_opts = ["--format", "specdoc:README"]
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end


begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "imdb"
    gem.summary = %Q{TODO}
    gem.email = "roy@wright.org"
    gem.homepage = "http://github.com/royw/imdb"
    gem.authors = ["Roy Wright"]
    gem.files.reject! { |fn| File.basename(fn) =~ /^tt\d+\.html/}

    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION.yml')
    config = YAML.load(File.read('VERSION.yml'))
    version = "#{config[:major]}.#{config[:minor]}.#{config[:patch]}"
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "imdb #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
