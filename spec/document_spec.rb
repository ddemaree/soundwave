require 'spec_helper'

describe Soundwave::Document do
  
  let(:root_dir)    { File.expand_path("../fixtures/site", __FILE__) }
  let(:environment) { Soundwave::Environment.new(root_dir) }
  let(:pathname)    { Pathname(File.join(root_dir, "index.mustache")) }
  let(:document) { Soundwave::Document.new(environment, "index.html", pathname) }

  describe "change tracking" do
    it "stores the file's mtime at initialization" do
      document.mtime.should == pathname.stat.mtime
    end
    describe "changed?" do
      it "compares the current mtime with the cached value" do
        document
        sleep 1
        FileUtils.touch pathname
        document.should be_changed
      end
    end
    describe "refresh" do
      it "updates the stored mtime" do
        document
        sleep 1
        FileUtils.touch pathname
        document.refresh
        document.should_not be_changed
      end
    end
  end

  describe "output path" do
    it "is joined on the env's output dir" do
      document = Soundwave::Document.new(environment, "index.html", pathname)
      document.output_path.to_s.should == File.join(root_dir, "_site", "index.html")
    end
  end

end