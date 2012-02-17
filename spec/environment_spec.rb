require "spec_helper"

describe Soundwave::Environment do
  let(:environment) { Soundwave::Environment.new }

  before do
    FileUtils.cd File.expand_path("../fixtures/site", __FILE__)
  end

  describe "initialization" do
    it "creates an environment for the current directory" do
      env = Soundwave::Environment.new
      env.root_dir.expand_path.to_s.should == Dir.pwd
    end
    it "allows the root directory to be set" do
      env = Soundwave::Environment.new("/tmp/soundwave")
      env.root_dir.expand_path.to_s.should == "/tmp/soundwave"
    end
  end

  # Indexes the content of the site and stores it as @paths
  describe "read_directories" do
    it "indexes pages and static files" do
      environment.read_directories
      pages = environment.instance_variable_get("@pages")
      pages.keys.should have(3).items
      pages.keys.sort.should == ["about.html", "css/site.css", "index.html"]
    end
  end

  describe "filter_entries" do
    it "filters out _files" do
      environment.filter_entries(["_file", "a"]).should == ["a"]
    end
    it "filters out .files" do
      environment.filter_entries([".rspec", "a"]).should == ["a"]
    end
    it "filters out #files" do
      environment.filter_entries(["#wtf", "a"]).should == ["a"]
    end
    it "filters out files~" do
      environment.filter_entries(["vimblows~", "~tildesrule", "a"]).should == ["~tildesrule","a"]
    end
    it "filters out files listed in #exclude" do
      old_exclude = environment.exclude
      environment.stub!(:exclude).and_return(old_exclude + ["Guardfile"])
      environment.filter_entries(["Guardfile", "a"]).should == ["a"]
    end
    it "does not filter out .htaccess" do
      environment.filter_entries([".htaccess", "a"]).should == [".htaccess", "a"]
    end
  end

end