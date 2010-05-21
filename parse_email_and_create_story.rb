require 'rubygems'

class HoptoadEmail
  require 'builder'

  def initialize(io)
    @raw = ''
    io.each_line do |line|
      @raw << line
    end
  end
  
  def error_environment
    subject.match(%r{\] ([^:]+): })[1].downcase.gsub(' ', '_')
  end
  
  def subject
    @raw.match(/Subject: (.*)/)[1]
  end

  def to
    @raw.match(/To: (.*)/)[1]
  end

  def hoptoad_link
    @raw.match(%r{(http://foraker.hoptoadapp.com/errors/\d+)})[1]
  end

  def to_story_xml
    Builder::XmlMarkup.new.story do |s| 
      s.story_type 'bug'
      s.name self.subject
      s.labels ['hoptoad', self.error_environment].join(',')
      s.description "Hoptoad reported an error on #{self.error_environment}\n\n#{self.hoptoad_link}"
      s.requested_by Pivotal::Config[:username]
    end
  end

end

module Pivotal
  class ResourceFactory
    require 'restclient'
    API_URL = "https://www.pivotaltracker.com/services/v3"

    def self.project
      resource_path = "#{API_URL}/projects/#{Config[:project_id]}"
      RestClient::Resource.new(resource_path, :headers => {'X-TrackerToken' => Config[:api_key]})
    end
  end

  class Config
    require 'yaml'
    CONFIG_FILE_NAME = 'pivotal_config.yml'

    # Load config file with symbolized keys
    @@config = YAML.load_file(CONFIG_FILE_NAME).inject({}){|memo, (k,v)| memo.merge({k.to_sym => v})}

    def self.[](attribute)
      @@config[attribute]
    end
  end

end

error_story = HoptoadEmail.new($stdin).to_story_xml

Pivotal::ResourceFactory.project['stories'].post(error_story, :content_type => 'application/xml')

