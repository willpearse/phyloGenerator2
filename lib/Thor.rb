#Downloading and checking sequences from GenBank
# To-do:
#       * reference download
#       * currently just uses only one sequences; entry in retmax and stream
# - reset the getterrs and setters
require 'bio'

class Thor
  @@n_thor = 0
  attr_reader :gene, :seqs
  def initialize(species, gene)
    @ncbi = Bio::NCBI::REST.new
    @species_stack = species
    @id = @@n_thor
    @@n_thor += @@n_thor
    @seqs = []
    @gene = gene
  end

  #Run downloads
  def stream()
    @species_stack.each do |sp|
      dwn_seqs(sp) do |seq|
        raw_seq = find_feature(seq, sp, @gene)
        if not raw_seq.empty?
          seqs.push Bio::FastaFormat.new(">#{sp}_#{@gene}\n#{raw_seq}")
          break
        end
      end
    end
  end
  
  #Internal methods
  private
  def dwn_seqs(organism, retmax=10)
    ids = @ncbi.esearch("#{organism}[organism] AND #{@gene}[gene]", { "db"=>"nucleotide", "rettype"=>"gb", "retmax"=> retmax})
    curr_id = 0
    while curr_id < ids.length
      yield Bio::GenBank.new(@ncbi.efetch(ids = ids[curr_id], {"db"=>"nucleotide", "rettype"=>"gb", "retmax"=> retmax}))
      curr_id += 1
    end
  end
  
  #Internal methods
  def find_feature(seq, sp, gene)
    better = ""
    seq.features.each do |feature|
      t = [feature['gene'], feature['product'], feature['note'], feature['function']].join(",")
      if t.include? gene
        better << seq.to_biosequence.splicing(feature.position).to_s
      end
    end
    return better
  end
end


thor = Thor.new(["quercus_robur", "quercus_ilex", "rumex_acetosella"], "rbcL")
thor.stream
