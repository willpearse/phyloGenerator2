#!/usr/bin/ruby
#phyloGenerator 2

#Headers
require "yaml"
require_relative "lib/Cap.rb"

puts "phyloGenerator 2.0-2 DOI: 10.1111/2041-210X.12055"
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
    
    options[:excludes] = []
    if options.keys.include?(:exclude_folder) then
      Dir["#{options[:exclude_folder]}/*.fasta"].each {|file| options[:excludes] << Bio::FastaFormat.open(file).to_a[0].definition}
    end
    if options.keys.include?(:exclude_file) then
      options[:excludes] = File.open(options[:exclude_file], "r").readlines.map {|line| line.chomp}
    end
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
logger = Logger.new("pG2_log_#{Time.now.strftime("%d-%m-%Y_%H-%M")}")
logger.formatter = proc do |severity, datetime, progname, msg|
    date_format = datetime.strftime("%Y-%m-%d %H:%M:%S")
    if severity == "INFO" or severity == "WARN"
        "[#{date_format}] #{severity}  (#{progname}): #{msg}\n"
    else        
        "[#{date_format}] #{severity} (#{progname}): #{msg}\n"
    end
end
logger.info("setup") {"Loaded file #{ARGV[0]}"}
logger.info("setup") {"Outputting to directory #{options[:working_dir]}"}
logger.info("setup") {"Using email address #{options[:email]}"}

cap = Cap.new(species, options[:genes].keys.map(&:to_s), options[:cache], options[:genes], options[:phy_method], options[:partition], options[:constraint], options[:phylo_args], logger, options[:excludes])
logger.info("setup") {"Beginning download"}
cap.download
puts " - Download complete..."
logger.info("setup") {"Download complete"}
if options[:hawkeye]
  logger.info("setup") {"Beginning HawkEye"}
  cap.check
  logger.info("setup") {"Hawkeye complete"}
  puts " - Secondary check complete..."
end
unless options[:phy_method]=="nothing" then
  logger.info("setup") {"Beginning phylogeny search"}
  cap.phylogen
  logger.info("setup") {"Phylogeny search complete"}
  puts " - Phylogeny building complete..."
end
logger.info("setup") {"Beginning cleanup"}
cap.cleanup
logger.info("setup") {"Cleanup complete"}
puts ".Finished."
