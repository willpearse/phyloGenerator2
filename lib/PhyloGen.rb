#Building very large phylogenies from already outputted sequences
# - PhyloGen smashes, he doesn't think (yet)
# FWIW, this is how to make this work with RAxML
#File.open("phylo_#{@@n_phylogen}.fasta", "w") {|file| seqs.each_pair {|sp, seq| file << seq.output_fasta(sp)} }
#`raxml -s phylo_#{@@n_phylogen}.fasta -p #{Random.rand(100000)} -m GTRGAMMA -n phylo_#{@@n_phylogen}_#{@@n_runs}`
require "bio"

class PhyloGen
  @@n_phylogen = 0
  @@n_runs = 0
  def initialize(method="raxml", partition=false, model_params="")
    @this_phylogen = @@n_phylogen
    @@n_phylogen += 1
    @model_params = model_params
    @phy_string = ""; @parse_string = ""
    @partition = partition
    @partition_file = []
    @method = method
  end

  def build(species, genes, constraint=false)
    @spp_lookup = Hash[species.zip(('a'..'z').to_a.repeated_combination(5).map(&:join)[0..species.length]).map{|x,y| [x,y]}]
    align(species, genes)
    conc_align(genes)
    if constraint then constraint.leaves.each {|x| x.name = @spp_lookup[x]} end
    result = phylo_generate(constraint)
  end
  
  #Internal methods
  private
  def align(species, genes)
    cr_len = 0
    genes.each do |gene|
      File.open("phylo_#{@this_phylogen}_#{gene}.fasta", "w") do |file|
        species.each do |sp|
          if File.exists? "#{sp}_#{gene}.fasta"
            file << Bio::FastaFormat.open("#{sp}_#{gene}.fasta", "r").first.to_biosequence.output_fasta("#{sp}_#{gene}")
          else
            file << ">#{sp}_#{gene}\n"
          end
        end
      end
      `mafft --quiet phylo_#{@this_phylogen}_#{gene}.fasta > phylo_#{@this_phylogen}_#{gene}_mafft.fasta`
      if @partition
        align = Bio::Alignment.new(Bio::FastaFormat.open("phylo_#{@this_phylogen}_#{gene}_mafft.fasta")).alignment_length
        @partition_file << "DNA, #{gene}=#{cr_len+1}-#{cr_len+align}\\3,#{cr_len+2}-#{cr_len+align}\\3,#{cr_len+3}-#{cr_len+align}\\3"
        cr_len += align
      end
    end
  end
  
  private
  def conc_align(genes)
    seqs = {}
    genes.each do |gene|
      Bio::FastaFormat.open("phylo_#{@this_phylogen}_#{gene}_mafft.fasta").each_entry do |seq|
        seq = seq.to_biosequence
        sp = @spp_lookup[seq.definition.split("_")[0...-1].join("_")]
        if seqs.include? sp
          seqs[sp] = Bio::Sequence.new(seqs[sp] + seq)
        else
          seqs[sp] = seq
        end
      end
    end
    align = Bio::Alignment.new(seqs)
    File.open("phylo_#{@this_phylogen}.phylip", "w") {|file| file << align.output_phylip}
  end

  private
  def phylo_generate(constraint=false)
    @@n_runs += 1
    if @partition
      File.open("phylo_#{@this_phylogen}_#{@@n_runs}.partition", "w") {|file| file << @partition_file.join("\n")}
      @parse_string << " -q phylo_#{@this_phylogen}_#{@@n_runs}.partition"
    end
    if constraint
      File.open("phylo_#{@this_phylogen}_#{@@n_runs}.constraint", "w"){|file| file << constraint.output_newick}
      @phy_string << " -g phylo_#{@this_phylogen}_#{@@n_runs}.constraint"
    end
    case @method
    when "examl"
      #Ha! this is shit...
      `Rscript -e "require(ape);t<-read.dna('phylo_#{@this_phylogen}.phylip');t<-rtree(nrow(t),tip.label=rownames(t),br=NULL);write.tree(t,'phylo_#{@this_phylogen}_#{@@n_runs}.tre')"`
      `parse-examl -s phylo_#{@this_phylogen}.phylip -n phylo_#{@this_phylogen}_#{@@n_runs}_parse -m DNA#{@parse_string}`
      `examl -s phylo_#{@this_phylogen}_#{@@n_runs}_parse.binary -p #{Random.rand(100000)} -m PSR -n phylo_#{@this_phylogen}_#{@@n_runs} -t phylo_#{@this_phylogen}_#{@@n_runs}.tre#{@phy_string} #{@model_params}`
    when "exabayes"
      `yggdrasil -f phylo_#{@this_phylogen}.phylip -s #{Random.rand(100000)} -m DNA -n phylo_#{@this_phylogen}_#{@@n_runs}#{@phy_string} #{@model_params}`
    when "raxml"
      `raxml -s phylo_#{@this_phylogen}.phylip -p #{Random.rand(100000)} -m GTRGAMMA -n phylo_#{@@n_phylogen}_#{@@n_runs}#{@phy_string} #{@model_params}`
    else
      raise RuntimeError, "PhyloGen called with unsupported method #{@method}"
    end
  end  
end
