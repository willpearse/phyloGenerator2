#Synchronising all the actors in ThePhyloGenerator
require_relative "Thor.rb"
require_relative "Hulk.rb"
require 'set'

class Cap
  def initialize(species, genes)
    @species = species
    @genes = genes
    @thors = genes.map {|gene| Thor.new(@species, gene)}
    @hulk = Hulk.new
  end

  #Public methods
  def download()
    @thors.each {|thor| thor.stream}
  end

  def hulk
    @hulk.smash(@species, @genes)
  end 
end
