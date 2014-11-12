#Checking alignments and fixing as best-can

class Hawkeye
  @@n_hawkeye = 0
  attr_reader :gene, :spp
  def initialize(species, gene, args={})
    @spp = species
    @gene = gene
    @id = @@n_hawkeye
    @@n_hawkeye += 1
    @gap_length = args[:gap_length]
    @check_gap = /[-]{#{@gap_length},}/
    @check_dna = /[a-zA-Z\?]{#{@gap_length},}/
  end

  def check()
    align()
    bad_seq = []
    seqs = Bio::FastaFormat.open("hawkeye_#{@id}_#{@gene}_mafft.fasta").to_a
    alignment = Bio::Alignment.new(seqs)
    gaps = alignment.consensus_string(0.75).enum_for(:scan, @check_gap).map { [Regexp.last_match.begin(0),Regexp.last_match.end(0)] }
    dna = alignment.consensus_string(0.75).enum_for(:scan, @check_dna).map { [Regexp.last_match.begin(0),Regexp.last_match.end(0)] }
    danger_spots = gaps + dna
    spot_checker = ([@check_dna] * gaps.length) + ([@check_gap] * dna.length) 
    seqs.each do |seq|
      seq = seq.to_biosequence
      danger_spots.zip(spot_checker).each do |pos, reg|
        if pos and seq[pos[0]..pos[1]][reg]
          bad_seq << seq.primary_accession
          break
        end
      end
    end
    return bad_seq
  end
  
  #Internal functions
  private
  def align()
    species_to_delete = []
    File.open("hawkeye_#{@id}_#{gene}.fasta", "w") do |file|
      @spp.each do |sp|
        if File.exists? "#{sp}_#{@gene}.fasta"
          file << Bio::FastaFormat.open("#{sp}_#{@gene}.fasta", "r").first
        else
          species_to_delete << sp
        end
      end
    end
    `mafft --quiet hawkeye_#{@id}_#{@gene}.fasta > hawkeye_#{@id}_#{@gene}_mafft.fasta`
    species_to_delete.each { |x| @spp.delete(x) }
  end
end
