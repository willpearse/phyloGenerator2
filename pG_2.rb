#!/usr/bin/ruby
#phyloGenerator 2

require_relative "lib/Cap.rb"
require 'optparse'
require 'io/console'

options = {:examl=>true}
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
  opts.on("--cache", "Working directory will be searched for (*any*) existing species data") {|x| options[:cache] = options[:working_dir]}
  opts.on("--bayes", "Use ExaBayes to calculate phylogeny") {|x| options[:examl] = false}
end.parse!

#Setup
puts "ThePhyloGenerator - BETA version"
species = File.open(options[:species], "r").readlines.map {|line| line.chomp}
genes = []
thor_args = {}
File.open(options[:genes]).each do |line|
  if line.include? ","
    line = line.chomp.split(",")
    genes << line[0]
    thor_args[line[0].to_s] = {:ref_file=>line[1], :ref_min=>line[2].to_i, :ref_max=>line[3].to_i}
  else
    genes << line.chomp
    thor_args[line.chomp.to_s] = {}
  end
end
Bio::NCBI.default_email = options[:email]
Dir.chdir options[:working_dir]

#Run
puts " - Setup complete..."
cap = Cap.new(species, genes, options[:cache], thor_args, options[:examl])
cap.download
puts " - Download complete..."
cap.hulk
puts ".Finished."
