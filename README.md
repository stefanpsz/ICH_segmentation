Automated segmentation of haemorrhage and surrounding oedema in MRI of patients with acute intracerebral haemorrhage
====================================================================================================================

This is a MATLAB tool for automated segmentation of haemorrhage and surrounding oedema in MRI of patients with acute intracerebral haemorrhage.

It was developed by [Stefan Pszczolkowski P.](http://stefanpsz.github.io) at the [University of Nottingham](http://www.nottingham.ac.uk).


Required MATLAB libraries
-------------------------

- For handling of Nifti files the [tools for NIfTI and ANALYZE image](https://www.mathworks.com/matlabcentral/fileexchange/8797-tools-for-nifti-and-analyze-image)
is required.
- For computation of the Minimum Covariance Determinant (MCD) estimator, the [Library for Robust Analysis](https://wis.kuleuven.be/stat/robust/LIBRA)
is required.


Required MRI sequences
----------------------

MRI sequences are expected to be in [NIFTI](https://nifti.nimh.nih.gov/) format.

- T1-weighted sequence (for registration).
- T2* Gradient Echo or Susceptibility-weighted imaging (SWI) sequence.
- Fluid-attenuated inversion recovery (FLAIR) sequence.


Provided template and maps
--------------------------

This tool relies on three precomputed datasets, which can be found in the `data` folder:

- An age-specific T1-weighted template described [here](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3376197/).
- A segmentation of the age-specific template into 138 structures using the [MALPEM](https://github.com/ledigchr/MALPEM) whole-brain segmentation 
framework.
- A White Matter lesion probability map constructed from subjects with small vessel disease and described 
[here](https://link.springer.com/chapter/10.1007/978-3-319-24553-9_64).


Preprocessing
-------------

All the data has to be pre-registered into T1 subject space for the tool to run. We recommend using the [Medical Image Registration ToolKit (MIRTK)](https://github.com/BioMedIA/MIRTK). Parameter files for MIRTK are provided in the `mirtk-params` folder.

1. Non-linearly register the provided T1-weighted template (`data/t1w_atlas.nii.gz`) to the T1 sequence of the subject. We recommend to accomplish this 
by first performing a linear registration of the T1 sequence of the subject to the provided template (using `mirtk-params/mirtk-aff.cfg`), then inverting 
the resulting transformation matrix, and finally performing a non-linear registration of the template to the T1 sequence of the subject (using 
`mirtk-params/mirtk-ffd.cfg`) with this inverse matrix as input.

2. Transform the provided MALPEM (`data/MALPEM_map.nii.gz`) and WMH (`data/WMH_prob_map.nii.gz`) maps into T1 subject space using the transformation 
resulting from the non-linear registration.

3. Rigidly register the subject T2*-weighted (or SWI) and the FLAIR sequences to the subject T1 sequence (using `mirtk-params/mirtk-rig.cfg`).

4. Transform the T2* gradient echo (or SWI) and the FLAIR sequence into T1 subject space using the matrix resulting from step 3.


**IMPORTANT:** On April 2018, the MIRTK software has undergone a major update that requires the energy terms weights to be reformulated. We utilised a 
version prior to that change. This version can be obtained by running the following command after cloning the MIRTK git repository:

```
git reset --hard 23b0fe0
```


Running the tool
----------------

First make sure all required MATLAB libraries are in the MATLAB PATH.

```
nii_t2star = load_untouch_nii('/path/to/t2star_in_t1_space.nii.gz');
nii_flair = load_untouch_nii('/path/to/flair_in_t1_space.nii.gz');
nii_malpem_map = load_untouch_nii('/path/to/MALPEM_map_in_t1_space.nii.gz');
nii_wmh_map = load_untouch_nii('/path/to/WMH_map_in_t1_space.nii.gz');

lambda = 15; %Suggested default

nii_seg = compute_haemorrhagic_segmentation(nii_t2star, nii_flair, nii_malpem_map, nii_wmh_map, lambda);

% To save the segmentation into a nifti file do the following
save_untouch_nii(nii_seg, 'path/to/segmentation.nii.gz');
```

You can also run `help compute_haemorrhagic_segmentation` for a description of inputs and outputs.


Limitations
-----------

- For the moment, this tool can detect just one haemorrhage with its corresponding perihaematomal oedema.
- This tool assumes the haemorrhage is seen as hypointense in T2* (or SWI) and as iso- or hypointense in FLAIR with a brighter oedema. This is mainly seen in
the acute phase (approximately between 2 and 6 days from onset).


License
-------

The tool is distributed under the terms of the MIT licence. See the accompanying [license file](LICENCE.txt) for details. 
