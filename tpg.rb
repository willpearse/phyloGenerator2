#!/usr/bin/ruby
#Running ThePhyloGenerator

require_relative "lib/Cap.rb"
require 'optparse'
require 'io/console'



options = {}
OptionParser.new do |opts|  
  opts.banner = "ThePhyloGenerator - BETA version"
  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end
  opts.on("-s FILE", "--species FILE", "File with genus_species on each line") {|x| options[:species] = x}
  opts.on("-g FILE", "--genes FILE", "File with gene names on each line)") {|x| options[:genes] = x}
  opts.on("-e EMAIL", "--email EMAIL", "Email address for downloads") {|x| options[:email] = x}
  opts.on("-d DIRECTORY", "--directory DIRECTORY", "Absolute path for all output data") {|x| options[:working_dir] = x}
end.parse!

#Setup
puts "ThePhyloGenerator - BETA version"
species = File.open(options[:species], "r").readlines.map {|line| line.chomp}
genes = File.open(options[:genes]).readlines.map {|line| line.chomp}
Bio::NCBI.default_email = options[:email]
Dir.chdir options[:working_dir]

#Run
puts " - Setup complete..."
cap = Cap.new(species, genes)
cap.download
puts " - Download complete..."
cap.hulk
puts ".Finished."
