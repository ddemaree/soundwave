require "spec_helper"
require "soundwave/server"

describe Soundwave::Server do

  let(:root_path) { Pathname(File.expand_path("../fixtures/site", __FILE__)) }
  let(:site)      { Soundwave::Site.new(root_path) }
  let(:server)    { Soundwave::Server.new(site) }

  it "returns index.html given a blank path" do
    path = server.find_template("/")
    path.should == root_path.join("index.mustache").to_s
  end

  it "converts html paths to mustache ones" do
    path = server.find_template("/index.html")
    path.should == root_path.join("index.mustache").to_s
  end

  it "renders the found template" do
    response = server.call("PATH_INFO" => "/")
    response.should == [200, {"Content-Type" => "text/html; charset=utf-8", "Content-Length" => "12"}, ["Hello world!"]]
  end

  it "returns 404 if the template was not found" do
    response = server.call("PATH_INFO" => "/bogus.html")
    response[0].should == 404
  end

end