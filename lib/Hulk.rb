#Building very large phylogenies from already outputted sequences
# - Hulk smashes, he doesn't think (yet)

class Hulk
  @@n_hulk = 0
  @@n_runs = 0
  def initialize(model_params={})
    @@n_hulk += 1
    @model_params = {}
  end

  def smash(species, genes)
    align(species, genes)
    conc_align(genes)
    result = phylo_generate()
  end
  
  #Internal methods
  private
  def align(species, genes)
    genes.each do |gene|
      File.open("hulk_#{@@n_hulk}_#{gene}.fasta", "w") do |file|
        species.each do |spp|
          if File.exists? "#{spp}_#{gene}.fasta"
            file << Bio::FastaFormat.open("#{spp}_#{gene}.fasta", "r").first
          else
            file << ">#{spp}_#{gene}\n"
          end
        end
      end
      `mafft --quiet hulk_#{@@n_hulk}_#{gene}.fasta > hulk_#{@@n_hulk}_#{gene}_mafft.fasta`
    end
  end
  
  private
  def conc_align(genes)
    seqs = {}
    genes.each do |gene|
      Bio::FastaFormat.open("hulk_#{@@n_hulk}_#{gene}_mafft.fasta").each_entry do |seq|
        seq = seq.to_biosequence
        sp = seq.definition.split("_")[0...-1].join("_")
        if seqs.include? sp
          seqs[sp] = Bio::Sequence.new(seqs[sp] + seq)
          
        else
          seqs[sp] = seq
        end
      end
    end
    File.open("hulk_#{@@n_hulk}.fasta", "w") {|file| seqs.each_pair {|sp, seq| file << seq.output_fasta(sp)} }
  end
  
  private
  def phylo_generate()
    @@n_runs += 1
    `raxml -s hulk_#{@@n_hulk}.fasta -p #{Random.rand(100000)} -m GTRGAMMA -n hulk_#{@@n_hulk}_#{@@n_runs}`
  end
end
