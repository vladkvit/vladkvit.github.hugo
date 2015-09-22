+++
Title = "Mars Rover Webcam Pano"
tags = [ "programming", "Matlab", "Pixel Bender" ]
summary_layout = "2and1"
summary_numimgcolumns = 1
summary_imagesrel = "shadowbox[marspano]"
weight = 15

[[summaryimages]]
imagehref = "../images/Rover_Image_Merging/img_nodots.png"
thumburl = "../images/Rover_Image_Merging/thumb/img_nodots.png"
title = "f2"

+++
<p>I helped out with UW's <a href="http://www.spacesoc.uwaterloo.ca/rover/">Mars Rover team</a>. One of the things I did was try to get a merged view of the webcams that were on the rover. Since there wasn't much time before the competition (and I had a huge workload during that semester), I didn't have time to try any fancy approaches (RANSAC), and approximated with an affine transform. This didn't end up being used for the rover, as anything other than the ground would diverge.</p>
