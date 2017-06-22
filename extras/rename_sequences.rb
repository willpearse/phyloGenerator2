#!/usr/bin/ruby
#phyloGenerator 2

#Headers
require 'bio'

puts "phyloGenerator 2 DOI: 10.1111/2041-210X.12055"
puts "Helper script: renaming sequence files"
puts "Will Pearse - will.pearse@gmail.com"
if ARGV.length == 3
  begin
    seq_dir = ARGV[0].to_s
    gene = ARGV[1].to_s
    output = ARGV[2]
  rescue Exception => msg
    puts "Error: cannot process input arguments"
    puts "Please give the full path to sequences, name of gene, and output file location-align"
    puts "Printing error message, then exiting..."
    puts msg
    exit
  end
else
  puts "Error: this requires three arguments."
  puts "Please give the full path to sequences, name of gene, and output file location-align"
  puts "Exiting..."
  exit
end

File.open("#{output}", "w") do |output_file|
  Dir["#{seq_dir}/*.fasta"].each do |file|
    if file["_#{gene}.fasta"]
      seq = Bio::FastaFormat.open(file, "r").first
      name = file[/[a-zA-Z]*_[a-zA-Z]*_[a-zA-Z]*/]
      output_file << seq.to_biosequence.output_fasta(name)
    end
  end
end

puts "Done!"
