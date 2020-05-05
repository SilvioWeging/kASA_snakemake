# Snakemake pipelines for kASA

These pipelines enable you to benchmark [kASA](https://github.com/SilvioWeging/kASA) together with other tools e.g.: [Kraken](https://github.com/DerrickWood/kraken), [Kraken2](https://github.com/DerrickWood/kraken2), [KrakenUniq](https://github.com/fbreitwieser/krakenuniq), [Clark](http://clark.cs.ucr.edu/Overview/) and [Centrifuge](https://github.com/DaehwanKimLab/centrifuge).


## Before you start

These pipelines assume that you are working in a Linux environment since most of the other tools do too.

Please keep the following in mind when using this pipeline: The genomes are downloaded from the NCBI and too many downloads in a short time triggers a "misuse warning" from them without raising a problem while downloading.

 * Download and install the tools you wish to benchmark. If some tool is not of interest to you, write "" instead of the path inside the config file.

 * Install [Snakemake](https://snakemake.readthedocs.io/en/stable/getting_started/installation.html) (we recommend that you install [conda](https://docs.conda.io/projects/conda/en/latest/user-guide/install/download.html#anaconda-or-miniconda) first and then use `pip3 install snakemake --user` inside this conda environment. Please note, that you have to activate the conda environment every time you want to use snakemake.).

 * Check the config file(s) which contain parameters that need to be changed for your platform (like paths, RAM, number of threads, etc.)

 * Call one of the snakefiles with `snakemake -s <snakefile>`.

After each benchmark, you might want to use `.clean.sh` to remove all benchmark related files.

## The different snakefiles

### benchmark

This is the main benchmarking pipeline which will evaluate time and memory consumption as well as sensitivity and precision. 

It downloads genomes given inside the content file, creates indices for every tool from them, and randomly generates and mutates reads out of these genomes. Finally, it measures how many of these reads can be re-identified by every tool and computes the sensitivity and precision from this.

The results are given inside the folder `results` (which is created during the benchmark). Scripts for the evaluation can be found inside the `scripts` folder. Measurements of time and memory consumption are saved inside the `benchmarks` folder for the index creation and identification step of every tool.

If the evaluation of the Centrifuge script should fail then the building step of the tool had a hiccup and "forgot" to assign certain tax IDs. Just run the building step again and it should work...

### testAmbiguous

Very similar genomes tend to confuse identification tools with low sensitivity. This test can be used to benchmark kASA (and KrakenUniq) for those edge cases where two or more genomes are very similar.

We provide an example test of kASA and KrakenUniq with the genomes of E. Coli and Shigella flexneri which are very similar and should lead to many ambiguous reads where the scores are equal.

Should you find an example where kASA cannot distinguish two different species, please let me know. 

### testkASA_intergenic_genic

Because kASA does not distinguish between genic and intergenic areas in genomes, one could argue that there will be different results or even a bias depending on the area.

This pipeline downloads genomes (the provided content.txt is used by default) and their gffs to separate genic from intergenic areas. For every area, reads are generated and mutated in the same manner as in [benchmark](#benchmark).

After the evaluation, the result.txt file contains sensitivity and precision for the genic and intergenic parts.




