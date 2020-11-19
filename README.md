# Snakemake pipelines for kASA

These pipelines enable you to benchmark [kASA](https://github.com/SilvioWeging/kASA) together with other tools e.g.: [Kraken](https://github.com/DerrickWood/kraken), [Kraken2](https://github.com/DerrickWood/kraken2), [KrakenUniq](https://github.com/fbreitwieser/krakenuniq), [Clark](http://clark.cs.ucr.edu/Overview/), [ganon](https://github.com/pirovc/ganon), [MetaCache](https://github.com/muellan/metacache), and [Centrifuge](https://github.com/DaehwanKimLab/centrifuge).


## Before you start

These pipelines assume that you are working in a Linux environment since most of the other tools do too.

 * Download and install the tools you wish to benchmark. If some tool is not of interest to you, write "" instead of the path inside the config file.

 * Install [Snakemake](https://snakemake.readthedocs.io/en/stable/getting_started/installation.html) (we recommend that you install [conda](https://docs.conda.io/projects/conda/en/latest/user-guide/install/download.html#anaconda-or-miniconda) first and then use `pip3 install snakemake --user` inside this conda environment. Please note, that you have to activate the conda environment every time you want to use snakemake.).

 * Check the config file(s) which contain parameters that need to be changed for your platform (like paths, RAM, number of threads, etc.)

 * Call one of the snakefiles with `snakemake -s <snakefile>`.

After each benchmark, you might want to use `.clean.sh` to remove all benchmark related files.

Remember, that for Kraken/KrakenUniq Jellyfish needs to be in the PATH variable: `export PATH=path/to/krakenuniq/build/jellyfish-install/bin:$PATH`

## The different snakefiles

### benchmark

This is the main benchmarking pipeline which will evaluate time and memory consumption as well as sensitivity, precision, MCC, and F1 score. 

It downloads genomes given inside the content file, creates indices for every tool from them, and randomly generates and mutates reads out of these genomes. Finally, it measures how many of these reads can be re-identified by every tool and computes the sensitivity and precision from this.

The results are given inside the folder `results` (which is created during the benchmark). Scripts for the evaluation can be found inside the `scripts` folder. Measurements of time and memory consumption are saved inside the `benchmarks` folder for the index creation and identification step of every tool.

If the evaluation of the Centrifuge script should fail then the building step of the tool had a hiccup and "forgot" to assign certain tax IDs. Just run the building step again and it should work...

KrakenUniq has a bug in that it seems to take forever to build the index. If that should happen, just use the index from Kraken.

The script `scripts/gatherResults.py` can gather all results from the tools inside a matrix for every measurement. It needs the path (usually `results/`), the number of tools checked (a higher number only leads to empty rows so may as well use 100 or something), the number of mutations (aka the columns, usually 21) and the path where to write the output.

Should you wish to make further thresholding experiments like we did in our ROC experiment for specificity vs sensitivity, call `scripts/evaluateWThreshold.sh` after changing the path inside the file to your path. Afterwards you can gather the results inside a table with `scripts/gatherThresholdResults.py <path> <prefix> <path for the resulting files>`.

For kASA, different benchmarks can be chosen (by setting 1 or 0 in the config file): 
 * 64: Normal kASA with a maximum k of 12.
 * 128: Extended version which allows a maximum k of 25 (and thus has a larger index).
 * shrink: Shrinks the index of a normal kASA version by percentages ranging from 0% to 90%.
 * alphabets: Tries different alphabets (standard, 16, 27) and checks whether a different alphabet has an influence on the accuracy.

### testAmbiguous

Very similar genomes tend to confuse identification tools with low sensitivity. This test can be used to benchmark kASA (and KrakenUniq) for those edge cases where two or more genomes are very similar.

We provide an example test of kASA and KrakenUniq with the genomes of E. Coli and Shigella flexneri which are very similar and should lead to many ambiguous reads where the scores are equal.

Should you find an example where kASA cannot distinguish two different species, please let me know. 

### testkASA_intergenic_genic

Because kASA does not distinguish between genic and intergenic areas in genomes, one could argue that there will be different results or even a bias depending on the area.

This pipeline downloads genomes (the provided content.txt is used by default) and their gffs to separate genic from intergenic areas. For every area, reads are generated and mutated in the same manner as in [benchmark](#benchmark).

After the evaluation, the result.txt file contains sensitivity and precision for the genic and intergenic parts.




