#Checking alignments and fixing as best-can
require "bio"

class Hawkeye
  @@n_hawkeye = 0
  attr_reader :gene, :spp
  def initialize(species, gene, args={}, logger)
    @spp = species
    @gene = gene
    @id = @@n_hawkeye
    @@n_hawkeye += 1
    @gap_length = args[:gap_length]
    @check_gap = /[-]{#{@gap_length},}/
    @check_dna = /[a-zA-Z\?]{#{@gap_length},}/
    @ref_file = args[:ref_file]
    @logger = logger
    if args.include? :verbose then @verobse = args[:verbose] else @verbose = true end
  end

  def check()
    @logger.info("HawkEye_#{@id}") {"Beginning check"}
    align()
    bad_seq = []
    #Find danger spots in alignment
    seqs = Bio::FastaFormat.open("hawkeye_#{@id}_#{@gene}_mafft.fasta").to_a
    #Check those are danger spots in the reference sequences (--> need to be fixed)
    ref_align = Bio::Alignment.new(seqs[0..@ref_seqs])
    danger_spots = ref_align.consensus_string(1.0).enum_for(:scan, @check_gap).map { [Regexp.last_match.begin(0),Regexp.last_match.end(0)] }
    danger_spots.reject! {|x,y| x==0 | y=ref_align.size}
    seqs.each do |seq|
      seq = seq.to_biosequence
      danger_spots.each do |x, y|
        if seq[x..y][@check_dna]
          bad_seq << seq.primary_accession
          break
        end
      end
    end
    @logger.info("HawkEye_#{@@n_hawkeye}") {"#{seqs.length-bad_seq.length}/#{seqs.length} sequences passed"}
    if @verbose
      puts "#{seqs.length-bad_seq.length}/#{seqs.length} sequences passed HawkEye check"
    end
    return bad_seq
  end
  
  #Internal functions
  private
  def align()
    species_to_delete = []
    File.open("hawkeye_#{@id}_#{gene}.fasta", "w") do |file|
      @ref_seqs = Bio::FastaFormat.open(@ref_file, "r").to_a.length
      file << File.read(@ref_file)
      @spp.each do |sp|
        if File.exists? "#{sp}_#{@gene}.fasta"
          file << Bio::FastaFormat.open("#{sp}_#{@gene}.fasta", "r").first.to_biosequence.output_fasta("#{sp}_#{@gene}")
        else
          species_to_delete << sp
        end
      end
    end
    `mafft --quiet hawkeye_#{@id}_#{@gene}.fasta > hawkeye_#{@id}_#{@gene}_mafft.fasta`
    species_to_delete.each { |x| @spp.delete(x) }
  end
end
