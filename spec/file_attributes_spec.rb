require "spec_helper"

describe Soundwave::FileAttributes do
  let(:root_dir)    { File.expand_path("../fixtures/site", __FILE__) }
  let(:environment) { Soundwave::Environment.new(root_dir) }

  def attributes_for(pathname)
    environment.attributes_for(pathname)
  end

  before do
    FileUtils.cd(root_dir)
  end

  describe "logical paths" do
    it "are relative to the env's root_dir" do
      attributes_for("about/index.html").logical_path.should == "about/index.html"
    end
    it "strip engine extensions" do
      attributes_for("about.html.mustache").logical_path.should == "about.html"
    end
    it "append a default format extension if necessary" do
      attributes_for("about.mustache").logical_path.should == "about.html"
    end
  end

  describe "extensions" do
    it "gets an array of all extensions" do
      attributes_for("index.html.mustache").extensions.should == [".html", ".mustache"]
    end
    it "gets the format extension" do
      attributes_for("index.html.mustache").format_extension.should == ".html"
    end
    it "gets the engine extension(s)" do
      attributes_for("index.html.mustache").engine_extensions.should == [".mustache"]
    end
    it "allows pathnames with just an engine extension" do
      attributes_for("about.scss").engine_extensions.should == [".scss"]
    end
  end
end