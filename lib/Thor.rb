#Downloading and checking sequences from GenBank
# To-do:
#       * reference download
#       * currently just uses only one sequences; entry in retmax and stream
# - reset the getterrs and setters
require 'bio'

class Thor
  @@n_thor = 0
  attr_reader :gene, :seqs
  def initialize(species, gene, args={})
    @ncbi = Bio::NCBI::REST.new
    @species = species
    @species_fail = []
    @id = @@n_thor
    @@n_thor += 1
    @gene = gene
    if args.include? :max_dwn then @max_dwn = args[:max_dwn] else @max_dwn = 10 end
    if args.include? :ref_file
      @ref_max = args[:ref_max]
      @ref_min = args[:ref_min]
      @ref_file = args[:ref_file]
    end
    if args.include? :max_gaps
      #@seq_regexp = Regexp.new("[actg]{#{args[:first_length]},}([-]{3,}[actg]{#{args[:rest_length]},}){#{args[:max_gaps]},}")
      @seq_regexp = Regexp.new("([a-zA-Z\?]+[-]{args[:gap_length],}[a-zA-Z\?]+){#{args[:max_gaps]},}")
    else
      @seq_regexp = Regexp.new(/[a-zA-Z]*/)
    end
  end
  #Run downloads
  def stream()
    @species.each do |sp|
      fail_sp = true
      dwn_seqs(sp) do |dwn_seq|
        seq = find_feature(dwn_seq, sp, @gene)
        unless seq.empty?
          seq = Bio::Sequence.new("#{seq}")
          if @ref_file then
            unless ref_align(seq, @ref_file, min=@ref_min, max=@ref_max, reg_exp=@seq_regexp)
              next
            end
          end
          File.open("#{sp}_#{gene}.fasta", "w") {|handle| handle << seq.output_fasta("#{sp}_#{gene}")}
          fail_sp = false
          break
        end
      end
      if fail_sp then @species_fail.push(sp) end
    end
    return @species_fail
  end
  
  #Internal methods
  private
  def dwn_seqs(organism, retmax=10)
    n_ids = @ncbi.esearch("#{organism}[organism] AND #{@gene}[gene]", { "db"=>"nucleotide", "rettype"=>"gb", "retmax"=> retmax})
    curr_id = 0
    while curr_id < n_ids.length
      yield Bio::GenBank.new(@ncbi.efetch(ids = n_ids[curr_id], {"db"=>"nucleotide", "rettype"=>"gb", "retmax"=> 1}))
      curr_id += 1
    end
  end
  
  def find_feature(seq, sp, gene)
    better = ""
    seq.features.each do |feature|
      t = [feature['gene'], feature['product'], feature['note'], feature['function']].join(",")
      if t.include? gene
        better << seq.to_biosequence.splicing(feature.position).to_s
      end
    end
    return better
  end

  def ref_align(seq, ref_file, ref_min, max=100000, reg_exp=/[a-zA-Z]*/)
    if seq.length < ref_min then return false end
    FileUtils.cp(ref_file, "thor_ref_#{@id}.fasta")
    File.open("thor_ref_#{@id}.fasta", "a") {|handle| handle << seq.output_fasta("temp_file")}
    `mafft --quiet thor_ref_#{@id}.fasta > thor_ref_#{@id}_mafft.fasta`
    seq = Bio::FastaFormat.open("thor_ref_#{@id}_mafft.fasta").first
    File.delete("thor_ref_#{@id}.fasta", "thor_ref_#{@id}_mafft.fasta")
    if (seq.length > max) then return false end
    if seq.to_biosequence[reg_exp] then return false end
    return true
  end
end
