#Synchronising all the actors in phyloGenerator 2
require_relative "Thor.rb"
require_relative "Hulk.rb"
require_relative "Hawkeye.rb"
require 'fileutils'

class Cap
  def initialize(species, genes, cache=nil, thor_args={}, examl=true, partition=false)
    @species = species
    @genes = genes
    @thors = genes.map {|gene| Thor.new(@species, gene, thor_args[gene.to_s])}
    @hawks = genes.map {|gene| Hawkeye.new(@species, gene, thor_args[gene.to_s])}
    @hulk = Hulk.new(examl, partition)
    @cache = cache
    if @cache
      to_check_spp = []
      Dir["#{cache}/*.fasta"].each {|file| FileUtils.copy(file, file.split("/")[-1])}
      species.each{|sp| unless Dir["#{@cache}*"] then to_check_spp << sp end}
      puts " - - of #{species.length} species, #{to_check_spp.length} are not cached"
      @thors = genes.map {|gene| Thor.new(to_check_spp, gene, thor_args[gene.to_s])}
    else
      @thors = genes.map {|gene| Thor.new(@species, gene, thor_args[gene.to_s])}
    end
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
    failed_species.each {|sp_gene| File.rename("#{sp_gene}.fasta", "#{sp_gene}_bad.fasta") }
  end

  def hulk
    @hulk.smash(@species, @genes)
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
