require "spec_helper"

describe Soundwave::Environment do
  let(:environment) { Soundwave::Environment.new("./fixtures/site") }

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

  describe "read_directories" do
  end

  describe "filter_entries" do
    it "filters out _files"
    it "filters out .files"
    it "filters out #files"
    it "filters out ~files"
    it "filters out files listed in #exclude"
    it "does not filter out .htaccess"
  end

end