require 'spec_helper'
require 'soundwave/page'

describe Soundwave::Page do
  
  let(:root_path) { Pathname(File.expand_path("../fixtures/site", __FILE__)) }
  let(:site) { Soundwave::Site.new(root_path) }

  # TODO: Write spec for #write()
  
  describe "Mustache template" do
    subject { Soundwave::Page.new(site, root_path.join("index.mustache")) }

    its(:format_extension) { should == ".html" }
    its(:engine_extension) { should == ".mustache" }
    its(:logical_path)     { should == "index.html" }

    it "renders the page" do
      subject.stub!(:read_data => {:and_goodbye => " And goodbye!"})
      subject.render.should == "Hello world! And goodbye!"
    end
  end

  describe "Tilt template" do
    subject { Soundwave::Page.new(site, root_path.join("styles.css.scss")) }

    its(:format_extension) { should == ".css" }
    its(:engine_extension) { should == ".scss" }
    its(:logical_path)     { should == "styles.css" }

    it "renders the document" do
      subject.render.should == "body {\n  background-color: #669900; }\n"
    end
  end

  describe "Static file" do
    subject { Soundwave::Page.new(site, root_path.join("site.js")) }

    its(:format_extension) { should == ".js" }
    its(:engine_extension) { should be_nil }
    its(:logical_path)     { should == "site.js" }

    context "with multiple extensions" do
      subject { Soundwave::Page.new(site, root_path.join("site.min.js")) }
  
      its(:format_extension) { should == ".js" }
      its(:engine_extension) { should be_nil }
      its(:logical_path)     { should == "site.min.js" }      
    end

    it "reads the file" do
      subject.render.should == root_path.join("site.js").read
    end
  end

end