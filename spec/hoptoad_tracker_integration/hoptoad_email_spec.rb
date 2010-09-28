require File.join(File.dirname(__FILE__),"..","spec_helper") 
require File.join(File.dirname(__FILE__),"..","..", "lib", "hoptoad_tracker_integration") 

module HoptoadTrackerIntegration
  describe HoptoadEmail do
    before(:each) do
      sample_email = File.join(File.dirname(__FILE__),"..","sample_email.txt") 
      @hoptoad_email = HoptoadEmail.new(File.open(sample_email))
    end
    it "reports #error_environment" do
      @hoptoad_email.error_environment.should == "dev_qa"
    end

    it "reports #subject" do
      @hoptoad_email.subject.should == "[TCI] Dev qa: RuntimeError: here3"
    end

    it "reports #hoptoad_link" do
      @hoptoad_email.hoptoad_link.should == "http://foraker.hoptoadapp.com/errors/2387110"
    end
    
    describe "#to_story_xml" do
      before(:each) do
        @story_doc = Nokogiri::XML(@hoptoad_email.to_story_xml)
      end

      it "has story_type set to 'bug'" do
        @story_doc.at_css('story_type').content.should == "bug"
      end
      
      it "has name set to the subject of the email" do
        @story_doc.at_css('name').content.should == "[TCI] Dev qa: RuntimeError: here3"
      end
      
      it "has the hoptoad label and the environment" do
        labels = @story_doc.at_css('labels').content.split(',')
        labels.should =~ ['dev_qa','hoptoad']
      end
      
      it "has a proper description" do
        description = @story_doc.at_css('description').content
        description.should match(/Hoptoad reported an error on dev_qa/)
        description.should match(Regexp.new("http://foraker.hoptoadapp.com/errors/2387110"))
      end
    end
  end
end
