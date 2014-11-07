#Synchronising all the actors in phyloGenerator 2
require_relative "Thor.rb"
require_relative "Hulk.rb"
require 'set'

class Cap
  def initialize(species, genes, cache=nil, thor_args={}, examl=true)
    @species = species
    @genes = genes
    @thors = genes.map {|gene| Thor.new(@species, gene, thor_args[gene.to_s])}
    @hulk = Hulk.new(examl)
    @cache = cache
    if @cache
      to_check_spp = []
      species.each{|sp| unless Dir["#{@cache}*"] then to_check_spp << sp end}
      puts "- of #{species.length} species, #{to_check_spp.length} are cached"
      @thors = genes.map {|gene| Thor.new(to_check_spp, gene, thor_args[gene.to_s])}
    else
      @thors = genes.map {|gene| Thor.new(@species, gene, thor_args[gene.to_s])}
    end
  end

  #Public methods
  def download()
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

  def hulk
    @hulk.smash(@species, @genes)
  end 
end
