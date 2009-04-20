$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'imdb'

$samples_dir = File.dirname(__FILE__) + '/samples'

require 'cache_extensions'
CacheExtensions.attach_to_read_page_classes($samples_dir)

Spec::Runner.configure do |config|

end
