#!/usr/bin/ruby
#phyloGenerator 2

#Headers
require "yaml"
require_relative "lib/Cap.rb"

puts "phyloGenerator 2.0-0 DOI: 10.1111/2041-210X.12055"
puts "Please *use with caution*; first version!"
puts "Will Pearse - will.pearse@gmail.com"
if ARGV.length == 1
  begin
    options = YAML.load_file(ARGV[0])
    options = options.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
    options[:genes] = options[:genes].inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
    options[:genes].each do |key,value|
      options[:genes][key] = options[:genes][key].inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
    end
    species = File.open(options[:species], "r").readlines.map {|line| line.chomp}
    unless options.keys.include?(:phylo_args) then options[:phylo_args] = "" end
    unless options.keys.include?(:phy_method) then options[:phy_method]="nothing" end
  rescue Exception => msg
    puts "Error: cannot load settings file. Either malformed or non-existant."
    puts "Printing error message, then exiting..."
    puts msg
    exit
  end
else
  puts "Error: phyloGenerator 2 requires a single argument."
  puts "This argument must be the location of your configuration file."
  puts "Check website (http://willpearse.github.io/phyloGenerator2) if stuck."
  puts "Exiting..."
  exit
end

#Setup
Bio::NCBI.default_email = options[:email]
Dir.chdir options[:working_dir]

#Run
puts " - Setup complete..."
cap = Cap.new(species, options[:genes].keys.map(&:to_s), options[:cache], options[:genes], options[:phy_method], options[:partition], options[:constraint], options[:phylo_args])
cap.download
puts " - Download complete..."
if options[:hawkeye]
  cap.check
  puts " - Secondary check complete..."
end
unless options[:phy_method]=="nothing" then
  cap.phylogen
  puts " - Phylogeny building complete..."
end
cap.cleanup
puts ".Finished."
