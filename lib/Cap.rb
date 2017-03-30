#Synchronising all the actors in phyloGenerator 2
require_relative "Download.rb"
require_relative "PhyloGen.rb"
require_relative "Hawkeye.rb"
require 'fileutils'
require 'logger'

class Cap
  def initialize(species, genes, cache=nil, dwn_args={}, phylo_method="examl", partition=false, constraint=false, phylo_args="", logger)
    @species = Marshal::load(Marshal.dump(species)) #Multicore --> copy paranoia
    @genes = genes
    @phylo_builder = PhyloGen.new(phylo_method, partition, phylo_args, logger)
    @cache = cache
    @logger = logger
    if @cache
      unless @cache[-1]=="/" then @cache+="/" end
      to_check_spp = []
      Dir["#{cache}/*.fasta"].each {|file| FileUtils.copy(file, file.split("/")[-1])}
      @species.each{|sp| if Dir["#{@cache}#{sp}_*"].empty? then to_check_spp << sp end}
      puts " - - of #{species.length} species, #{to_check_spp.length} are not cached"
      @seq_downs = genes.map {|gene| Download.new(to_check_spp, gene, dwn_args[gene.to_sym], @logger)}
      @hawks = genes.map {|gene| Hawkeye.new(@species, gene, dwn_args[gene.to_sym], @logger)}
    else
      @seq_downs = genes.map {|gene| Download.new(@species, gene, dwn_args[gene.to_sym], @logger)}
      @hawks = genes.map {|gene| Hawkeye.new(@species, gene, dwn_args[gene.to_sym], @logger)}
    end
    if constraint then @constraint = Bio::Newick.new(File.read(constraint)).tree else @constraint = false end
  end

  #Public methods
  def download
    failed_species = []
    threads = []
    @seq_downs.each do |seq_dwn|
      f_spp = []
      threads << Thread.new {
        failed_species << seq_dwn.stream
      }
    end
    threads.each {|t| t.join }
    failed_species.flatten!
    failed_species.each {|sp| if failed_species.count(sp)==@genes.length then @species.delete(sp) end}
  end

  def check
    failed_species = []
    threads = []
    @hawks.each {|hawk| threads << Thread.new { failed_species << hawk.check() } }
    threads.each {|t| t.join }
    failed_species.flatten!
    failed_species.each {|sp_gene|
      puts "failed: #{sp_gene}"
      if File.exists?("#{sp_gene}.fasta") then File.rename("#{sp_gene}.fasta", "#{sp_gene}_bad.fasta") end }
  end

  def phylogen
    if @constraint
      to_drop = @species - @constraint.leaves.map{|x| x.name.sub(" ","_")}
      to_drop.each {|sp| @constraint.remove_node(sp.sub("_"," ")) }
    end
    @phylo_builder.build(@species, @genes, @constraint)
  end

  def cleanup
    Dir.mkdir "hawkeye"
    Dir["*_bad.fasta"].each {|x| FileUtils.mv(x, "hawkeye/#{x}")}
    Dir["hawkeye_*"].each {|x| FileUtils.mv(x, "hawkeye/#{x}")}
    Dir.mkdir "phylo"
    Dir["phylo_*"].each {|x| FileUtils.mv(x, "phylo/#{x}")}
    Dir["ExaBayes_*"].each {|x| FileUtils.mv(x, "phylo/#{x}")}
    Dir["ExaML_*"].each {|x| FileUtils.mv(x, "phylo/#{x}")}
    Dir["RAxML_*"].each {|x| FileUtils.mv(x, "phylo/#{x}")}
    Dir.mkdir "seqs"
    Dir["*.fasta"].each {|x| FileUtils.mv(x, "seqs/#{x}")}
  end
end
