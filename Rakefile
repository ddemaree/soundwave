#!/usr/bin/env rake
require "bundler/gem_tasks"
require 'rspec/core/rake_task'
require 'annotations/rake_task'
require 'rocco/tasks'

RSpec::Core::RakeTask.new(:spec)
Annotations::RakeTask.new(:notes)
Rocco::make 'docs/'

task :default => [:spec, :notes]

