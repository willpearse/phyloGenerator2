#Synchronising all the actors in phyloGenerator 2
require_relative "Thor.rb"
require_relative "Hulk.rb"
require_relative "Hawkeye.rb"
require 'fileutils'

class Cap
  def initialize(species, genes, cache=nil, thor_args={}, hulk_method="examl", partition=false, constraint=false)
    @species = Marshal::load(Marshal.dump(species)) #Multicore --> copy paranoia
    @genes = genes
    @hulk = Hulk.new(hulk_method, partition)
    @cache = cache
    if @cache
      to_check_spp = []
      Dir["#{cache}/*.fasta"].each {|file| FileUtils.copy(file, file.split("/")[-1])}
      @species.each{|sp| unless Dir["#{@cache}*"] then to_check_spp << sp end}
      puts " - - of #{species.length} species, #{to_check_spp.length} are not cached"
      @thors = genes.map {|gene| Thor.new(to_check_spp, gene, thor_args[gene.to_sym])}
      @hawks = genes.map {|gene| Hawkeye.new(to_check_spp, gene, thor_args[gene.to_sym])}
    else
      @thors = genes.map {|gene| Thor.new(@species, gene, thor_args[gene.to_sym])}
      @hawks = genes.map {|gene| Hawkeye.new(@species, gene, thor_args[gene.to_sym])}
    end
    if constraint then @constraint = Bio::Newick.new(File.read(constraint)).tree else @constraint = false end
  end

  #Public methods
  def download
    failed_species = []
    threads = []
    @thors.each do |thor|
      f_spp = []
      threads << Thread.new {
        failed_species << thor.stream
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
    failed_species.each {|sp_gene| if File.exists?("#{sp_gene}.fasta") then File.rename("#{sp_gene}.fasta", "#{sp_gene}_bad.fasta") end }
  end

  def hulk
    if @constraint
      to_drop = @species - @constraint.leaves.map{|x| x.name.sub(" ","_")}
      to_drop.each {|sp| @constraint.remove_node(sp.sub("_"," ")) }
    end
    @hulk.smash(@species, @genes, @constraint)
  end

  def cleanup
    Dir.mkdir "hawkeye"
    Dir["*_bad.fasta"].each {|x| FileUtils.mv(x, "hawkeye/#{x}")}
    Dir["hawkeye_*"].each {|x| FileUtils.mv(x, "hawkeye/#{x}")}
    Dir.mkdir "hulk"
    Dir["hulk_*"].each {|x| FileUtils.mv(x, "hulk/#{x}")}
    Dir["ExaBayes_*"].each {|x| FileUtils.mv(x, "hulk/#{x}")}
    Dir["ExaML_*"].each {|x| FileUtils.mv(x, "hulk/#{x}")}
    Dir["RAxML_*"].each {|x| FileUtils.mv(x, "hulk/#{x}")}
    Dir.mkdir "thor"
    Dir["*.fasta"].each {|x| FileUtils.mv(x, "thor/#{x}")}
  end
end
