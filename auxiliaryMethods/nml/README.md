# Which version to use?

For the confused among us, a word from the code historian, Manuel Berning:

> parseNml_webKnossos was added recently (initative by Benedikt and Martin to account for [1 1 1] offset between webKnossos and matlab Indexing). parseNml_noInVP is needed for older skeletons (e.g. generated in early days of KNOSSOS that did have a different set of parameters per node (e.g. no inVP attribute, Retina skeletons))
> 
> I have never used writeNml_webKnossos (I think) but I would assume this also accounts for the [1 1 1] indexing offset. writeNmlOld is necessary to write skeletons read in with parseNml_noInVP or other older results (e.g. Moritz IPL paper skeletons provided in mat files)
> 
> So i would vote for not removing them, but depends on how we evaluate the tradeoff between scope vs. clarity we want the auxiliaryMethods to have. We could just add/seperate them in a different branch or repo.

Source:
https://gitlab.mpcdf.mpg.de/connectomics/auxiliaryMethods/issues/4
