#Downloading and checking sequences from GenBank
# To-do:
#       * reference download
#       * currently just uses only one sequences; entry in retmax and stream
# - reset the getterrs and setters
require 'bio'

class Download
  @@n_download = 0
  attr_reader :gene
  def initialize(species, gene, args={}, logger)
    @ncbi = Bio::NCBI::REST.new
    @species = species
    @species_fail = []
    @id = @@n_download
    @@n_download += 1
    @logger = logger
    if args.include? :aliases
      @gene = [gene] + args[:aliases]
    else
      @gene = [gene]
    end
    if args.include? :fussy then @fussy = args[:fussy] else @fussy = true end
    if args.include? :max_dwn then @max_dwn = args[:max_dwn] else @max_dwn = 10 end
    if args.include? :ref_file
      @ref_max = args[:ref_max]
      @ref_min = args[:ref_min]
      @ref_file = args[:ref_file]
    end
    if args.include?(:name_check) then @name_check = args[:name_check] else @name_check = false end
    if args.include? :max_gaps
      #@seq_regexp = Regexp.new("[actg]{#{args[:first_length]},}([-]{3,}[actg]{#{args[:rest_length]},}){#{args[:max_gaps]},}")
      @seq_regexp = Regexp.new("([a-zA-Z\?]+[-]{args[:gap_length],}[a-zA-Z\?]+){#{args[:max_gaps]},}")
    else
      @seq_regexp = Regexp.new(/[a-zA-Z]*/)
    end
    if args.include? :verbose then @verobse = args[:verbose] else @verbose = true end
  end
  #Run downloads
  def stream()
    @logger.info("SeqDownload_#{@@n_download}") {"Beginning search for #{gene[0]}"}
    @species.each do |sp|
      fail_sp = true
      break unless @gene.each do |locus|
        dwn_seqs(sp, locus) do |seq|
          accession = seq.accessions[0]
          if @fussy then seq = find_feature(seq, sp, locus) else seq = seq.to_biosequence end
          unless seq.length == 0
            if @ref_file then
              unless ref_align(seq, @ref_file, min=@ref_min, max=@ref_max, reg_exp=@seq_regexp)
                next
              end
            end
            File.open("#{sp}_#{@gene[0]}.fasta", "w") {|handle| handle << seq.output_fasta("#{accession}")}
            fail_sp = false
            break
          end
        end
      end
      if fail_sp then @species_fail.push(sp) end
    end
    if @verbose
      puts " - - #{@gene[0]}: #{@species.length-@species_fail.length}/#{@species.length} sequences found"
    end
    @logger.info("SeqDownload_#{@@n_download}") {"#{@species.length-@species_fail.length}/#{@species.length} sequences found"}
    return @species_fail
  end
  
  #Internal methods
  private
  def dwn_seqs(organism, locus)
    locker = 0
    begin
      if @fussy then search = "#{organism}[organism] AND #{locus}[gene]" else search = "#{organism}[organism] AND #{locus}" end
        n_ids = @ncbi.esearch(search, { "db"=>"nucleotide", "rettype"=>"gb", "retmax"=> @max_dwn})
      curr_id = 0
      while curr_id < n_ids.length
        seq = Bio::GenBank.new(@ncbi.efetch(ids = n_ids[curr_id], {"db"=>"nucleotide", "rettype"=>"gb", "retmax"=> 1}))
        if @name_check
          if seq.organism.downcase==organism.sub("_"," ").downcase then yield seq end
        else
          yield seq
        end
        curr_id += 1
      end
    rescue Errno::ECONNRESET
      if locker >= 3
        raise
      end
      locker += 1
      sleep 2
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
    return Bio::Sequence.new("#{better}")
  end

  def ref_align(seq, ref_file, ref_min, max=100000, reg_exp=/[bdefhijklmnopqrstuvwxyz]*/)
    if seq.nil? then return false end
    if seq.length < ref_min then return false end
    if seq.length > max then return false end
    FileUtils.cp(ref_file, "download_ref_#{@id}.fasta")
    File.open("download_ref_#{@id}.fasta", "a") {|handle| handle << seq.output_fasta("temp_file")}
    `mafft --quiet download_ref_#{@id}.fasta > download_ref_#{@id}_mafft.fasta`
    seq = Bio::FastaFormat.open("download_ref_#{@id}_mafft.fasta").first
    File.delete("download_ref_#{@id}.fasta", "download_ref_#{@id}_mafft.fasta")
    if seq.nil? then return false end
    if seq.to_biosequence[reg_exp] then return false end
    return true
  end
end
