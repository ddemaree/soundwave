#!/usr/bin/env rake
require "bundler/gem_tasks"
require 'rspec/core/rake_task'
require 'annotations/rake_task'

RSpec::Core::RakeTask.new(:spec)
Annotations::RakeTask.new(:notes)

task :default => [:spec, :notes]

