#Synchronising all the actors in ThePhyloGenerator
require_relative "Thor.rb"
require_relative "Hulk.rb"
require 'set'

class Cap
  def initialize(species, genes, thor_args={})
    @species = species
    @genes = genes
    @thors = genes.map {|gene| Thor.new(@species, gene, thor_args[gene.to_s])}
    @hulk = Hulk.new
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
