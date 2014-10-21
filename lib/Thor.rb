#Downloading and checking sequences from GenBank
# To-do:
#       * reference download
#       * currently just uses only one sequences; entry in retmax and stream
require 'bio'

class Thor
  @@n_thor = 0
  attr_reader :gene
  def initialize(species, gene)
    @ncbi = Bio::NCBI::REST.new
    @species_stack = species
    @id = @@n_thor
    @@n_thor += @@n_thor
    @seqs = []
    @gene = gene
  end

  #Run downloads
  def stream(clean=false)
    #...later I will want to be more careful what I spit out...
    unless clean
      seqs = @species_stack.map {|sp| dwn_seqs(sp, @gene)}
      seqs.zip(@species_stack).each do |seq, sp|
        File.open("#{sp}_#{@gene}.fasta", "w") {|file| file << seq[0].to_biosequence.to_fasta("#{sp}_#{gene}", 60)}
      end
    end
  end
  
  #Internal methods
  private
  def dwn_seqs(organism, gene, retmax=1)
    ids = @ncbi.esearch("#{organism}[organism] AND #{gene}[gene]", { "db"=>"nucleotide", "rettype"=>"gb", "retmax"=> retmax})
    @seqs = ids.map {|id| Bio::GenBank.new(@ncbi.efetch(ids = id, {"db"=>"nucleotide", "rettype"=>"gb", "retmax"=> retmax}))}
  end
end
