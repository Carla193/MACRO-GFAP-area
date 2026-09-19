macro "Astrogliosis GFAP Area" {

// CHOOSE IMAGE
getDimensions(width, height, channels, slices, frames);
if (channels>1) {
	run("Split Channels");
}

all_channels=getList("image.titles");
waitForUser("Select the GFAP chanel and click OK");
GFAP_channel = getTitle();;

//CONVERT TO 8-BIT IF NECESSARY
if (bitDepth() != 8) {
    run("8-bit");
}

//CLOSE THE REST OF THE CHANNELS
for (i=0; i<all_channels.length; i++) {
	if (all_channels[i] != GFAP_channel) {
		selectWindow(all_channels[i]);
		close();
	}
}
selectImage(GFAP_channel);
// APPLY FILTERS
run("Subtract Background...", "rolling=30");
run("Gaussian Blur...", "sigma=1");

// CHOOSE AREA
run("Set Measurements...", "area limit min display redirect=None decimal=4");
setTool("polygon");
waitForUser("Draw the ROI and click OK");
run("ROI Manager...");
roiManager("Add");
roiManager("Select",roiManager("count") - 1 );

//MEASURE ROI AREA
getPixelSize(unit, pixelWidth, pixelHeight);
run("Set Measurements...", "area limit area_fraction display redirect=None decimal=4");
run("Measure");

// MEASURE POSITIVE ROI AREA 
setAutoThreshold("Triangle dark");
run("Convert to Mask");
roiManager("Select",roiManager("count") - 1 );
run("Measure");

// RESULTS
area2 = getResult("Area", nResults-1);
area2_microns = area2 / (pixelWidth * pixelHeight);

area1 = getResult("Area", nResults-2);
area1_microns = area1 / (pixelWidth * pixelHeight);

percentage = getResult("%Area", nResults-1);

//SHOW RESULTS
run("Log");
print("\\Clear");
selectWindow("Log");
print("RESULTS GFAP AREA");
print("==============================");
print("Total area (µm2): " + area1_microns);
print("Positive area (µm2): " + area2_microns);
print("Percentage of positive area (%): " + percentage);
