+++
Title = "Rasterization with Perspective-correct Texturing"
tags = [ "Matlab", "3D" ]
summary_layout = "2and1"
summary_numimgcolumns = 1
summary_imagesrel = "shadowbox[rasterization]"
weight = 6

[[summaryimages]]
imagehref = "/images/Matlab_Rasterize/render.png"
thumburl = "/images/Matlab_Rasterize/thumb/render.png"
title = "f2"

+++
<p>A friend of mine wrote a simple 2.5D texture renderer using an algorithm from the Doom & Quake era. I whipped up a Matlab script to see how much difference would a "correct" algoritm make.</p>
<p>The script takes in any 4 verteces and renders the texture over them with a wide (90*) FOV.</p>
