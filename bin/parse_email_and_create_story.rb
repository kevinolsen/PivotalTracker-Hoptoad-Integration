$LOAD_PATH.push File.join(File.dirname(__FILE__),"..","lib") 
require 'hoptoad_tracker_integration'

include HoptoadTrackerIntegration

error_story = HoptoadEmail.new($stdin).to_story_xml

puts Pivotal::ResourceFactory.project['stories'].post(error_story, :content_type => 'application/xml')
