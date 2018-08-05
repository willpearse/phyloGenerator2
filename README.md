phyloGenerator 2 - automated phylogeny generation
===========
Will Pearse

##Quickstart
* Clone this repo (````git clone https://github.com/willpearse/phyloGenerator2.git````)
* Ensure you have Ruby and BioRuby installed (````sudo gem install bio````)
* Ensure you have _at least_ RAxML and MAFFT installed (````sudo apt-get install mafft````; ````````git clone https://github.com/stamatak/standard-raxml.git````), ExAML and ExaBayes if you want to use them
* Make sure each program can be run from the command line by typing ````mafft````, ````raxml````, ````examl```` & ````parse-examl```` (ExaML), or ````yyggdrasil```` (part of ExaBayes). This means changing the names of the RAxML and ExaML binaries, and copying things into wherever you keep programs you can run from the command line.
* Run the program with ````./pG_2.rb /full/path/to/param/file````
* ...the parameters are self-explanatory within the demo parameter file. Make sure you set an email addres

##Guidelines and important notes
* Using the output from _any_ program uncritically is a bad idea; using phyloGenerator2 uncritical is exceptionally bad. *Do not* simply run the program and then use the output off the bat; you *must* check your DNA alignments.
* phyloGenerator1 was written for a novice user; pG2 is not. I assume, when using this, that you have a basic understanding of how to build a phylogeny. I do not neaten the output from ExaML etc. beyond creating sub-folders
* The parameter file contains a number of settings, not all of them necessary.
* If you set a minimum or maximum length for an alignment that is smaller or greater than your reference data, the program won't find anything.
* The secondary sequence check ('hawkeye') is a very powerful tool. Use it.

##License
Is in the file 'LICENSE'. It's essentially MIT but you have to cite the program when you use it :D

The license 