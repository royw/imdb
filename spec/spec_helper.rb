$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'imdb'

$samples_dir = File.dirname(__FILE__) + '/samples'

require 'read_page_cache'
ReadPageCache.attach_to_classes($samples_dir)

Spec::Runner.configure do |config|

end
