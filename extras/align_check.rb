#!/usr/bin/ruby
#phyloGenerator 2

#Headers
require "yaml"
require_relative "../lib/Cap.rb"

puts "phyloGenerator 2 DOI: 10.1111/2041-210X.12055"
puts "Helper script: alignment checker"
puts "Will Pearse - will.pearse@gmail.com"
if ARGV.length == 2
  begin
    seq_dir = ARGV[0].to_s
    gene = ARGV[1].to_s
  rescue Exception => msg
    puts "Error: cannot process input arguments"
    puts "Please give full path to sequences and name of gene to re-align"
    puts "Printing error message, then exiting..."
    puts msg
    exit
  end
else
  puts "Error: this requires three arguments."
  puts "Please give full path to sequences and name of gene to re-align"
  puts "Exiting..."
  exit
end

File.open("#{gene}.fasta", "w") do |alignment|
  Dir["#{seq_dir}/*.fasta"].each do |file|
    if file["_#{gene}.fasta"]
      seq = Bio::FastaFormat.open(file, "r").first
      alignment << seq.to_biosequence.output_fasta(file)
    end
  end
end
`mafft --quiet #{gene}.fasta > #{gene}_mafft.fasta`

puts "Run complete!"
