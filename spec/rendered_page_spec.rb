require 'spec_helper'

describe Soundwave::RenderedPage do
  let(:root_dir)    { Pathname(File.expand_path("../fixtures/site", __FILE__)) }
  let(:environment) { Soundwave::Environment.new(root_dir) }

  let(:pathname) { root_dir.join("index.mustache") }
  let(:data_pathname) { root_dir.join("_data", "index.yml") }
  let(:page) { Soundwave::RenderedPage.new(environment, "index.html", pathname) }

  before do
    FileUtils.cd(root_dir)
  end

  describe "with data" do
    it "reads YAML data file on initialization" do
      page.data.should == {"page_title" => "Hello World!"}
    end
    it "sets mtime to data file's mtime if it is later" do
      pending "Need to add dependency tracking to RenderedPage"
      FileUtils.touch(pathname)
      sleep 1
      FileUtils.touch(data_pathname)

      page.mtime.should == data_pathname.stat.mtime
    end
  end

  describe "rendering" do
    it "renders content with data" do
      output = page.render
      output.should == <<-HTML
<html>
  <head><title>Hello World!</title></head>
  <body>
    <h1>Hello World!</h1>
  </body>
</html>
      HTML
    end
    it "can chain multiple engines" do
      page = Soundwave::RenderedPage.new(environment, "index.html", root_dir.join("about.mustache.erb"))
      page.data = {"page_title" => "This is page title"}
      output = page.render
      output.should == "Title: About this site"
    end
  end

end