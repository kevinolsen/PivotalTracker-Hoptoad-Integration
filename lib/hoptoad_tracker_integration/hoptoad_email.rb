require 'builder'

module HoptoadTrackerIntegration
  class HoptoadEmail
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

    def hoptoad_link
      @raw.match(%r{(http://.+\.hoptoadapp\.com/errors/\d+)})[1]
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
end
