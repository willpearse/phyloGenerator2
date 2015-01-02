require_relative "../lib/Cap.rb"
require_relative "wrapper.rb"
require 'minitest/spec'
require 'minitest/autorun'

species = ["quercus_robur", "quercus_ilex", "pinus_strobus", "quercus_rubra", "poa_pratensis", "jabberwocky"]

describe Cap do
  it "Runs a basic instance and can cache" do
    Wrap.new.folder("cap_test") do
      test = Cap.new(species, ["rbcL"], false, {:rbcL=>{:ref_file=>"/home/will/Code/phyloGenerator2/demo/rbcL_reference.fasta", :ref_min=>400,:ref_max=>1500,:gap_length=>5,:max_gaps=>10,:max_dwn=>10}}, 'raxml', false)
      missed = test.download
      assert Dir["*.fasta"].length > 1
      downloaded = Dir["*.fasta"]
      assert missed == species.reject {|sp| downloaded.any? {|x| x[sp] } }
      test.check
      test.hulk
      test.cleanup
      cache = Cap.new(species, ["rbcL"], Dir.getwd+"/thor", {:rbcL=>{:ref_file=>"/home/will/Code/phyloGenerator2/demo/rbcL_reference.fasta", :ref_min=>400,:ref_max=>1500,:gap_length=>5,:max_gaps=>10,:max_dwn=>10}}, 'examl', false)
      cache.download
    end
  end
end
      
