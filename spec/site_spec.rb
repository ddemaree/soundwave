require "spec_helper"
require "fakefs/safe"

describe Soundwave::Site do

  let(:root_path) { Pathname(File.expand_path("../fixtures/site", __FILE__)) }
  let(:site) { Soundwave::Site.new(root_path) }

  before do
    Dir.chdir(root_path)
  end

  before(:all) { FileUtils.rm_rf("./_site") }
  after(:all)  { FileUtils.rm_rf("./_site") }

  describe "generate" do
    it "builds the web site" do
      site.generate("./_site")
      Dir["./_site/*"].should == ["./_site/index.html", "./_site/site.js", "./_site/styles.css"]
    end
  end

  describe "find_paths" do
    it "indexes pages and static files" do
      paths = site.find_paths
      paths.should have(3).items
      paths.sort.should == ["index.mustache", "site.js", "styles.css.scss"].map { |p| File.expand_path("./#{p}") }
    end
  end

  describe "filter_entries" do
    it "filters out _files" do
      site.filter_entries(["_file", "a"]).should == ["a"]
    end
    it "preserves .dotfiles" do
      site.filter_entries([".rspec", "a"]).should == [".rspec", "a"]
    end
    it "filters out #files" do
      site.filter_entries(["#wtf", "a"]).should == ["a"]
    end
    it "filters out files~" do
      site.filter_entries(["vimblows~", "~tildesrule", "a"]).should == ["~tildesrule","a"]
    end
    it "filters out files listed in #exclude" do
      pending
      old_exclude = site.exclude
      site.stub!(:exclude).and_return(old_exclude + ["Guardfile"])
      site.filter_entries(["Guardfile", "a"]).should == ["a"]
    end
    it "does not filter out .htaccess" do
      site.filter_entries([".htaccess", "a"]).should == [".htaccess", "a"]
    end
  end

end