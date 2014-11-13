#Building very large phylogenies from already outputted sequences
# - Hulk smashes, he doesn't think (yet)
# FWIW, this is how to make this work with RAxML
#File.open("hulk_#{@@n_hulk}.fasta", "w") {|file| seqs.each_pair {|sp, seq| file << seq.output_fasta(sp)} }
#`raxml -s hulk_#{@@n_hulk}.fasta -p #{Random.rand(100000)} -m GTRGAMMA -n hulk_#{@@n_hulk}_#{@@n_runs}`

class Hulk
  @@n_hulk = 0
  @@n_runs = 0
  def initialize(examl=true, partition=false, model_params={})
    @this_hulk = @@n_hulk
    @@n_hulk += 1
    @model_params = model_params
    @cmd_string = ""
    @partition = partition
    @partition_file = []
    @examl = examl
  end

  def smash(species, genes)
    align(species, genes)
    conc_align(genes)
    result = phylo_generate()
  end
  
  #Internal methods
  private
  def align(species, genes)
    cr_len = 0
    genes.each do |gene|
      File.open("hulk_#{@this_hulk}_#{gene}.fasta", "w") do |file|
        species.each do |spp|
          if File.exists? "#{spp}_#{gene}.fasta"
            file << Bio::FastaFormat.open("#{spp}_#{gene}.fasta", "r").first
          else
            file << ">#{spp}_#{gene}\n"
          end
        end
      end
      `mafft --quiet hulk_#{@this_hulk}_#{gene}.fasta > hulk_#{@this_hulk}_#{gene}_mafft.fasta`
      if @partition
        align = Bio::Alignment.new(Bio::FastaFormat.open("hulk_#{@this_hulk}_#{gene}_mafft.fasta")).alignment_length
        @partition_file << "DNA, #{gene}=#{cr_len+1}-#{cr_len+align}\\3,#{cr_len+2}-#{cr_len+align}\\3,#{cr_len+3}-#{cr_len+align}\\3"
        cr_len += align
      end
    end
  end
  
  private
  def conc_align(genes)
    seqs = {}
    genes.each do |gene|
      Bio::FastaFormat.open("hulk_#{@this_hulk}_#{gene}_mafft.fasta").each_entry do |seq|
        seq = seq.to_biosequence
        sp = seq.definition.split("_")[0...-1].join("_")
        if seqs.include? sp
          seqs[sp] = Bio::Sequence.new(seqs[sp] + seq)
        else
          seqs[sp] = seq
        end
      end
    end
    align = Bio::Alignment.new(seqs)
    File.open("hulk_#{@this_hulk}.phylip", "w") {|file| file << align.output_phylip}
  end

  private
  def phylo_generate()
    @@n_runs += 1
    if @partition
      File.open("hulk_#{@this_hulk}_#{@@n_runs}.partition", "w") {|file| file << @partition_file.join("\n")}
      @cmd_string << " -q hulk_#{@this_hulk}_#{@@n_runs}.partition"
      puts @cmd_string      
    end
    if @examl
      #Ha! this is shit...
      `Rscript -e "require(ape);t<-read.dna('hulk_#{@this_hulk}.phylip');t<-rtree(nrow(t),tip.label=rownames(t),br=NULL);write.tree(t,'hulk_#{@this_hulk}_#{@@n_runs}.tre')"`
      `parse-examl -s hulk_#{@this_hulk}.phylip -n hulk_#{@this_hulk}_#{@@n_runs}_parse -m DNA#{@cmd_string}`
      puts "parse-examl -s hulk_#{@this_hulk}.phylip -n hulk_#{@this_hulk}_#{@@n_runs}_parse -m DNA#{@cmd_string}"
      `examl -s hulk_#{@this_hulk}_#{@@n_runs}_parse.binary -p #{Random.rand(100000)} -m PSR -n hulk_#{@this_hulk}_#{@@n_runs} -t hulk_#{@this_hulk}_#{@@n_runs}.tre`
    else
      `yggdrasil -f hulk_#{@this_hulk}.phylip -s #{Random.rand(100000)} -m DNA -n hulk_#{@this_hulk}_#{@@n_runs}#{@cmd_string}`
    end
  end
end
