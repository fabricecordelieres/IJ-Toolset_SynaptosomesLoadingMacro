# IJ-Toolset_SynaptosomesLoadingMacro


# User's request:
The user has datasets including images of a synaptosome marker GFP and a membrane marker (FM4-64). The sample is acquired several times, each time point giving rise to an nd file. At each step, a treatment is applied. The acquisitions are carried out in 3D in order to obtain a maximum of structures which do not appear at the same level (problem of planarity of the sample and correction of the optics). The aim of the macro is to assemble all the images of the time course into a single composite image and to quantify the evolution of the signals over time, after detection of the objects of interest. Due to the treatments applied and the multi-position acquisition, an XY position drift may be present: this should be corrected. Note: some synaptosomes are not positive for GFP. Nevertheless, it will be necessary to quantify the fluorescence of all the structures, including those which are only FM4-64 positive.

# What does it do?
The macro is in the form of a 3-step toolset:
<p align=center>
	<img src="https://github.com/fabricecordelieres/IJ-Toolset_SynaptosomesLoadingMacro/blob/main/Illustrations/Screenshot.Toolset.jpg?raw=true" width="256">
</p>

## Assemble Data:
This first tool assembles the data sets considering that only one time series is present in the input directory. The list of .nd files is created (in alphabetical order). The first nd file is opened and parsed to determine the characteristics of the acquisition (number and name of channels, number of positions, number of z planes). For each position, for each time point, the images of the channels are loaded, projected (summed intensity projection) and assembled into a hyperstack. The resulting image is saved in the output directory.

## Register HyperStack Manually:
The user is prompted to indicate an input directory (the directory containing the results of the previous step) and an output directory. Each image is opened in turn: for each time point, the user will have to point to an object of interest to be realigned, on which a cross will be placed. Once the operation has been carried out for all the time points, the images are realigned so that the selection made is at the same coordinates at each time point. The realignment is carried out by simple translation, the first time point being taken as a reference. Note: all channels will be realigned with respect to the references entered by the user. In order to refine the process, it is not directly the selection which is taken into account: a dialog box at the beginning of the process asks to enter a search radius. This radius is used to place a circle centered on the user selection. In this circle, the centroid is calculated: it is this which will be used as a reference. This limits pointing errors.

## Quantify Synaptosomes Loading:
In turn, for each image, the following 2-step process is carried out:
### Detection:
The hyperstack is transformed into a simple stack so as to have all the signal (GFP and FM4-64). Since the detection relates to 2 channels of different intensities, evolving over time, a normalization is carried out: each image is centered and reduced (its mean is subtracted from it and it is divided by its standard intensity deviation). A maximum intensity projection is carried out: this will make it possible to detect all the synaptosomes, regardless of their content and their variation in intensity over time. A median filter is applied to reduce noise (default radius: 5 pixels), then a Gaussian filter is applied to reinforce the emergence of local maxima (1 per structure if the default radius of 5 pixels corresponds well to the size of the individual objects). A local maxima detection is carried out with an intensity threshold value of 0.3 by default. The detections are saved in memory in the form of a selection of multiple points.
### Analysis:
For each point detected, a circle of radius defined by the user is placed around the local maximum (default radius: 7 pixels). The intensity measurement is carried out in this zone for each time point, for each channel and logged in a results table. The area in which the analysis was carried out is added to the ROI Manager.

## Outputs:
At the end of the detection and quantification, the results table as well as the contents of the ROI Manager are saved in the output directory, indicated by the user.

# How to use it?
Versions of the software used: Fiji, ImageJ 2.0.0-rc-69/1.52n
Additional required software: None

# How to install and use the macro/toolset?
1. Update ImageJ: Help/update then Ok.
2. Move the toolset to the ImageJ installation directory, under the macros/toolset subdirectory.
3. In the ImageJ toolbar, the last button (red chevrons) allows you to select the toolset to use.
4. Depending on how the functions associated with the toolset work, open an image and then click on the button or click directly on the button.

# Revisions
## Version 1: 28/04/19
## Version 2: 09/05/19
User request: "I would also like to know if it is possible to modify the layout of the final table, so as to have the different steps in columns and the ROIs in rows. This would give a final table comprising 8 columns, with the 4 steps for each of the channels."
## Version 3: 27/06/19
User requests:
1. Possibility of unchecking the ROIs corresponding to bad detections.
2. Due to the registration, some detections are not present on all time points: a way should be found to eliminate them from the analysis.
3. The detection efficiency could be improved by using other default parameters: median/gaussian at 3pixels, quantification radius at 10 pixels.
4. The loading/release values, calculated on channel 1 in the form t2-t1 for the first and t3-t4 for the second, should be logged.
Responses:
1. After the detection of the structures, a window appears giving some indications: simply draw a rectangle above the regions to be eliminated. The process can be repeated several times: the exit of this "editing" mode is done by pressing the space bar on the keyboard.
2. After registration, a region of interest is positioned on the image, the positioning and size of which has been calculated from the displacement data used for the registration. This region contains the part common to the 4 time points: all the pixels located outside this zone are colored in black, which will avoid the situation mentioned by the user.
3. The default values of the 3 parameters have been modified.
4. Two new columns have been added to the results table, containing the calculated values requested.
## Version 4: 15/07/19
User request:
- Correction of the measurements by synaptosomes by means of a local measurement of the background
Responses:
- Measurement of the local background by means of a donut placed around the synaptosome. In order to avoid taking into account too high values (another synaptosome in the vicinity), the minimum intensity value is taken and multiplied by the quantification area and logged. A background corrected intensity value is also logged (quantification area*(intensity in the quantification area-minimum intensity outside the area)). The background corrected loading/release values are also logged.
## Version 5: 16/09/19
Bugs reported by the user and desired improvements:
- The data is inconsistent with the biology of the phenomenon. Ex: the GFP labeling of channel 2 oscillates enormously when it should be stable. It seems that the analyses are carried out on all the images: realigned or not. When sorting/previewing the detections, the selection can only be made on the 1st time point.
Responses:
- A bug has been corrected making it possible to explain the lack of coherence of the data. For each detection, a quantification is carried out for each time point, for each channel. Initially, the region was drawn and then a ring was created. The next time, this ring was used as the base region (where to quantify the signal) and then a ring was drawn around the periphery of this region (where to quantify the background). In short, as we progressed in time and when changing channels, the region was gradually widened. This problem is corrected in version 5. A filter has been put in place, based on the name of the images: only those bearing the suffix "_realigned.tif" will be analyzed. The overlay used to show the regions of interest at the time of selection of the relevant ROIs has been added to each time point.
## Version 6: 21/11/19
User request: use the median intensity rather than the minimum value to estimate the background.
## Version 7: 08/04/22
Bug corrections:
- With the batch mode, ImageJ was unable to locate the ROI on the active image as the call to ROI Manager reset was also removing the current ROI from the image. Corrected this by moving the reset instruction also took the opportunity to remove all ROIs from the image's outlines so that no error would occur when generating a ROI band that would be outside the image. it seems some roiManager functions may trigger its reset: this are functions dealing with removing positional information (slice, time, channel)
## Version 8: 11/04/22
Bug corrections:
- Step 2: modified the message for the first folder selection to point at the compiled data. This avoids any confusion about which folder should be selected. Modified the reject function so that the ROI of detection points is pushed to the ROI Manager. This allows the quantify function to get the coordinates for analysis. It seemed that before, in some case, the ROI disappeared from the image, resulting in an error message (not ROI in the ROI Manager).
## Version 9: 10/08/22
Functions requests:
- Added possibility to select on which channel to perform detection (C1, C2 or both). Added the export of background ROIs to the ROI Manager before saving it to disk.
## Version 10: 03/12/24
Functions requests:
- We are preparing a new experiment to analyze synaptic vesicle reuptake. It will have 3 colours. Thus, ahead of time, and before I even have pilot experiment, I was wondering if we could set up a meeting to alter the macro toolset we have for 2 colours? I actually think that we could run a test for the macro with duplicated channel, trhat I have plenty of examples of, so we get 3 channels to analyze?
Responses:
The toolset is already ready for multicolor analysis: added new options, and options handling in the third tool of the toolset. Checked the process went through.
