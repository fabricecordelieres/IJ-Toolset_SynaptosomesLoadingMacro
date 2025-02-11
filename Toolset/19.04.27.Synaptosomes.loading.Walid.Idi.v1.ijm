//----------------Global variables----------------
var regRad=6;

var medRad=5;
var gaussRad=5;
var subBkgd=15;
var tolerance=0.3;

var quantRad=7;

//----------------Assemble data stacks----------------
macro "Assemble Data Action Tool - C652Df3Cfc0D8aD9aDaaDb9Dc9Caa9D23C740D14Cfe0D2dD3dD4dD5dD6dD7dD8dD9dDadDbdDcdDddCfd0D1dD2bD3bD4bD5bDedCdddD30C440D0eD2fD3fD4fD5fD6fD7fD8fD9fDafDbfDcfDdfDfeCa60D34Cfc0D1cD29D2aD39D3aD49D4aD59D5aD69D6aD6bD79D7aD7bD89D8bD99D9bDa9DabDbbDcbDdbDecCff9D27D37D47D57Cdb0D1eDeeCfd2D88Cfe0D2cD3cD4cD5cD6cD7cD8cD9cDacDbcDccDdcCfffD00D01D02D03D10D11D12D20D21D22Da4Db3Db4Db5Dd0De0De1Df0Df1C420D0aD0bDf4DfbC665Dc2CcccD73D83D93Cf70D15Cfd1Dc8Cfd0D2eD3eD4eD5eD6eD7eD8eD9eDaeDbeDceDdeCeeeD43C550D1fDefC875D04CdddD95Cfb0D1aDd4Cfe4D36D56C410D07D08D09Df9DfaC555D50D60D70D80D90Da0CbbbDc0Cc30De6CeedDa5Cfa0D16CdddD51D53D61D71D81D91Cfa0De8DeaCfd4D26D28D38D48D58D68C420D0cD0dDfcDfdC666D40CccdD62Cf90D76Da7Cfd2D98Da8Db8CfffDb2Cfb2D55CdddD52Da2Cfb0D19D1bDbaDcaDd9DdaDebCfe4D46C410D05D06C555D33CbbaD0fDffCb50De7CeeeD42Da3Cd81D86CddcD54Cfa0D35Db7De4De9Cfc4Dc4C666Db0Dc1CddcD13Cf90D25D87D97Dc7Dd5CfffD84Dd1Df2Ceb3Dc3CdddDa1CcccD63Cc80Dd3CeeeD74Cfc1Dd8C667D32CcddD72D82D92Cfc3D77Cfd6D17C310Df5Df8CaaaD41C950D24Cc82D96Cfd3D45Cf80De5CeffD94Caa8De2CbccDb1Ce40Dd6Cfa2D65Cfa3Db6C764Dd2C970De3Cd82Da6CedcD85Cfd3D66Ceb6D75CdccD64Cf60Dc6CffdD44Cfc2D18C777D31Cfb4Dc5Cff8D67C300Df6Cfd3D78Ce70Dd7"{
	in=getDirectory("Where is the raw data ?");
	out=getDirectory("Where to save compiled data ?");
	run("Close All");
	
	assembleStacks(in, out);
}

//----------------Performs hyperstack manual registration----------------
macro "Register HyperStack Manually Action Tool - Cf00D0cD0dD1bD1cD1dD1eD2aD2bD2cD2dD2eD2fD39D3aD3bD3cD3dD3eD3fD45D48D49D4aD4bD4cD4dD4eD55D56D57D58D59D5aD5bD5cD5dD64D65D66D67D68D69D6aD6bD6cD74D75D76D77D78D79D7aD7bD84D85D86D87D88D89D8aD93D94D95D96D97D98D99D9aDa3Da4Da5Da6Da7Da8Da9DaaDabDb2Db3Db4Db5Db6Db7Db8Db9Dc2Dc3Dc4Dc5Dc6Dd1Dd2Dd3Dd4De1De2Df0"{
	in=getDirectory("Where is the raw data ?");
	out=getDirectory("Where to save registered data ?");
	run("Close All");
	
	radius=getNumber("Search radius for registration", regRad);
	batchRegistration(in, out, radius);
}

//----------------Performs quantifications----------------
macro "Quantify Synaptosomes Loading Action Tool - Cf44D1eD1fD2dD2eD2fD3fD4fD5fD6fD7fD8fD9fDafDbfDcfDdeDdfDedDeeDefC00fD24D25D26D27D28D32D33D34D38D39D3aD41D42D4aD4bD51D5bD60D61D6bD6cD70D7cD80D8cD90D9cDa0Da1DabDacDb1DbbDc1Dc2DcaDcbDd2Dd3Dd4Dd8Dd9DdaDe4De5De6De7De8CfbbD0eD0fD1cD1dD3dD4eD5eD6eD7eD8eD9eDaeDbeDceDdcDddDfdDfeCf66D2cD3eDecDff"{
	in=getDirectory("Where is the registered data ?");
	out=getDirectory("Where to save registered data ?");
	run("Close All");

	GUIAnalysis();
	batchAnalyze(in, out);
}




//----------------Get specific files based on extension----------------
function getSpecificFilesList(dir, ext){
	tmp=getFileList(dir);
	filesList=newArray(0);

	for(i=0; i<tmp.length; i++) if(endsWith(tmp[i], ext)) filesList=Array.concat(filesList, tmp[i]);
	
	return filesList;
}

//----------------Parse .nd files----------------
function parseNdFile(path){
	if(File.exists(path)){
		List.clear() ;
		content=File.openAsString(path);
		
		List.set("path", File.getParent(path)+File.separator);
		List.set("basename", replace(File.getName(path), ".nd", ""));
		
		lines=split(content, "\n");
		for(i=0; i<lines.length; i++){
			lines[i]=replace(lines[i], "\"", "");
			if(lines[i]!="EndFile"){
				keyVal=split(lines[i], ",");
				keyVal[1]=substring(keyVal[1], 1);
				List.set(keyVal[0], keyVal[1]);
			}
		}
	}
}

//----------------Assemble all time points, per position----------------
function assembleStacks(in, out){
	setBatchMode(true);
	//Get list of nd files
	files=getSpecificFilesList(in, ".nd");

	//Read the 1st nd file
	parseNdFile(in+files[0]);

	//Stores all the relevant acquisition parameters
	nPos=List.getValue("NStagePositions");
	nChannels=List.getValue("NWavelengths");
	nZ=List.getValue("NZSteps");

	//Retrieve the channels names
	waveNames=newArray(nChannels);
	for(i=0; i<nChannels; i++) waveNames[i]=List.get("WaveName"+(i+1));

	//Assembles the stacks
	for(i=0; i<nPos; i++){
		for(j=0; j<files.length; j++){
			basename=replace(files[j], ".nd", "");
			for(k=0; k<nChannels; k++){
				filename=basename+"_w"+d2s(k+1,0)+waveNames[k]+"_s"+d2s(i+1, 0)+".TIF";
				open(in+filename);
				
				if(nSlices>1){
					run("Z Project...", "projection=[Sum Slices]");
					close(filename);
				}else{
					run("32-bit");
				}
				rename("tmp");
				
				if(j+k!=0) run("Concatenate...", "  image1=Stack image2=tmp");
				rename("Stack");
			}
		}
		run("Stack to Hyperstack...", "order=xyczt(default) channels="+nChannels+" slices=1 frames="+files.length+" display=Composite");
		resetMinMaxStack();
		saveAs("Tiff", out+"Position_"+(i+1)+".tif");
		close();
	}
	setBatchMode("exit and display");
}

//----------------Manual registration, single image----------------
function batchRegistration(in, out, radius){
	files=getSpecificFilesList(in, ".tif");

	for(i=0; i<files.length; i++){
		open(in+files[i]);
		manualRegistration(radius, files[i]);
		saveAs("Tiff", out+replace(files[i], ".tif", "_registered.tif"));
		close();
	}
}

//----------------Manual registration, single image----------------
function manualRegistration(radius, img2Reg){
	selectWindow(img2Reg);
	Stack.getDimensions(width, height, refChannel, slices, frames);

	x=newArray(nSlices);
	y=newArray(nSlices);
	
	index=1;
	
	run("Point Tool...", "type=Cross color=Yellow size=Large label");
	
	while(index<=frames){
		selectWindow(img2Reg);
		
		run("Select None");
		while(selectionType==-1){
			Stack.setPosition(refChannel, 1, index);
			resetMinAndMax;
			setTool("point");
			waitForUser("Click on a reference point then press Ok");
		}
		getSelectionCoordinates(xpoints, ypoints);
	
		makeOval(xpoints[0]-radius, ypoints[0]-radius, 2*radius+1, 2*radius+1);
		List.setMeasurements;
		x[index-1]=List.getValue("XM");
		y[index-1]=List.getValue("YM");
		index++;
		
		run("Select None");
	}
	setTool("rectangle");
	
	applyRegistration(x, y, img2Reg);
}

//----------------Apply registration----------------
function applyRegistration(x, y, img){
	selectWindow(img);
	Stack.getDimensions(width, height, channels, slices, frames);
	
	for(i=1; i<=channels; i++){
		for(j=1; j<=frames; j++){
			Stack.setPosition(i, 1, j);
			run("Translate...", "x="+(x[0]-x[j-1])+" y="+(y[0]-y[j-1])+" interpolation=None slice");
		}
		resetMinAndMax;
	}
}

//----------------GUI----------------
function GUIAnalysis(){
	Dialog.create("Synaptosomes loading analysis");
	
	Dialog.addMessage("Detection");
	Dialog.addNumber("Median filter radius", gaussRad);
	Dialog.addNumber("Gaussian filter radius", gaussRad);
	Dialog.addNumber("Background subtraction radius", subBkgd);
	Dialog.addNumber("Noise tolerance", tolerance);

	Dialog.addMessage("Quantification");
	Dialog.addNumber("Quantification radius", quantRad);
	Dialog.show();

	medRad=Dialog.getNumber();
	gaussRad=Dialog.getNumber();
	subBkgd=Dialog.getNumber();
	tolerance=Dialog.getNumber();
	quantRad=Dialog.getNumber();
}

//----------------Locate structures----------------
function batchAnalyze(in, out){
	files=getSpecificFilesList(in, ".tif");

	for(i=0; i<files.length; i++){
		open(in+files[i]);
		locateStructures(medRad, gaussRad, subBkgd, tolerance);
		quantify(quantRad);
		
		roiManager("Deselect");
		roiManager("Save", out+replace(files[i], ".tif", "_RoiSet.zip"));
		saveAs("Results", out+replace(files[i], ".tif", "_Results.csv"));
		close();
	}
}

//----------------Locate structures----------------
function locateStructures(medRad, gaussRad, subBkgd, tolerance){
	run("Duplicate...", "title=tmp duplicate");
	run("Hyperstack to Stack");

	for(i=1; i<=nSlices; i++){
		setSlice(i);
		getStatistics(area, mean, min, max, std, histogram);
		run("Subtract...", "value="+mean+" slice");
		run("Divide...", "value="+std+" slice");
	}
	
	run("Z Project...", "projection=[Max Intensity]");
	setMinAndMax(-3, 3);
	run("Median...", "radius="+medRad);
	run("Gaussian Blur...", "sigma="+gaussRad);
	run("Subtract Background...", "rolling="+subBkgd);
	run("Find Maxima...", "prominence="+tolerance+" output=[Point Selection]");
	getSelectionCoordinates(xpoints, ypoints);
	close("*tmp");
	makeSelection("point", xpoints, ypoints);
}

//----------------Quantify signal----------------
function quantify(quantRad){
	setBatchMode("hide");
	run("Clear Results");
	roiManager("Reset");
	
	getSelectionCoordinates(xpoints, ypoints);
	Stack.getDimensions(width, height, channels, slices, frames);
	
	for(r=0; r<xpoints.length; r++){
		makeOval(xpoints[r]-quantRad, ypoints[r]-quantRad, 2*quantRad+1, 2*quantRad+1);
		Roi.setName("Detection_"+(r+1));
		roiManager("Add");
		
		for(t=1; t<=frames; t++){
			line=nResults;
			setResult("Detection", line, r+1);
			setResult("Time", line, t);
			
			for(c=1; c<=channels; c++){
				Stack.setPosition(c, 1, t);
				getStatistics(area, mean, min, max, std, histogram);
				setResult("Channel_"+c, line, area*mean);
			}
		}
		showStatus("Processing ROI "+r+"/"+xpoints.length);
		showProgress(r/(xpoints.length-1));
	}
	setBatchMode("exit and display");

	roiManager("Remove Channel Info");
	roiManager("Remove Slice Info");
	roiManager("Remove Frame Info");
	roiManager("Show All");
}

//----------------Reset display for all channels of the hyperstack----------------
function resetMinMaxStack(){
	Stack.getDimensions(width, height, channels, slices, frames);
	
	for(i=1; i<=channels; i++){
		Stack.setPosition(i, slices/2, frames);
		resetMinAndMax();
	}
}
