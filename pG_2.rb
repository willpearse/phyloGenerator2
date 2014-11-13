#!/usr/bin/ruby
#phyloGenerator 2

require_relative "lib/Cap.rb"
require 'optparse'

options = {:examl=>true, :partition=>nil}
OptionParser.new do |opts|  
  opts.banner = "ThePhyloGenerator - BETA version"
  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end
  opts.on("-s FILE", "--species FILE", "File with genus_species on each line") {|x| options[:species] = x}
  opts.on("-g FILE", "--genes FILE", "File with gene names on each line)") {|x| options[:genes] = x}
  opts.on("-e EMAIL", "--email EMAIL", "Email address for downloads") {|x| options[:email] = x}
  opts.on("-d DIRECTORY", "--directory DIRECTORY", "Absolute path to existing folder for output") {|x| options[:working_dir] = x}
  opts.on("-c DIRECTORY", "--cache DIRECTORY", "Directory with existing sequence data") {|x| options[:cache] = x}
  opts.on("--bayes", "Use ExaBayes to calculate phylogeny") {|x| options[:examl] = false}
  opts.on("--partition", "Partition phylogenetic searches") {|x| options[:partition] = true}
end.parse!

#Setup
puts "ThePhyloGenerator - BETA version"
species = File.open(options[:species], "r").readlines.map {|line| line.chomp}
genes = []
thor_args = {}
File.open(options[:genes]).each do |line|
  if line.include? ","
    line = line.chomp.split(",")
    if line.length > 4
      genes << line[0]
      thor_args[line[0].to_s] = {:ref_file=>line[1], :ref_min=>line[2].to_i, :ref_max=>line[3].to_i, :gap_length=>line[4].to_s, :max_gaps=>line[5].to_s}
    else
      genes << line[0]
      thor_args[line[0].to_s] = {:ref_file=>line[1], :ref_min=>line[2].to_i, :ref_max=>line[3].to_i}
    end
  else
    genes << line.chomp
    thor_args[line.chomp.to_s] = {}
  end
end
Bio::NCBI.default_email = options[:email]
Dir.chdir options[:working_dir]

#Run
puts " - Setup complete..."
cap = Cap.new(species, genes, options[:cache], thor_args, options[:examl], options[:partition])
cap.download
puts " - Download complete..."
cap.check
puts " - Secondary check complete..."
cap.hulk
puts " - Phylogeny building complete..."
cap.cleanup
puts ".Finished."
