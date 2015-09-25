+++
Title = "Thinkpad stuff"
tags = [ "Tinkering", "Thinkpad" ]
summary_layout = "1and2"
summary_numimgcolumns = 2
summary_imagesrel = "shadowbox[thinkpad]"
weight = 1
linkable = true

[[summaryimages]]
imagehref = "/images/miniPCIe/DSC_1589.jpg"
thumburl = "/images/miniPCIe/thumb/DSC_1589.jpg"
title = "Testing bootup after soldering"

[[summaryimages]]
imagehref = "/images/fan_swap/CIMG0048.jpg"
thumburl = "/images/fan_swap/thumb/CIMG0048.png"
title = "Heatsink comparison"

+++
I have a Thinkpad T510. It's been modded with an extra mini-PCIe slot and upgraded heatsink.
<!--more-->

##### Extra mini-PCIe slot
This mod brings the total of 2 half size and 1 full size slots. The slot works without any other modifications - my WiFi card worked in the new slot right off the bat. The pins are spaced 0.8mm apart (0.03"), so my temperature-controlled Hakko FX-888 with a flat soldering tip helped a lot. 

I got the plastic adapter itself from digikey. It's a 7.5mm Molex, the height refers to the entire height of the part, not from the motherboard to the card slot. According to the internet, leaving out a connector is not uncommon, other people used to add extra USB pinouts to their Asus netbooks.

##### Cooling upgrade
The T510 shares its body with the more powerful W510, which has a nicer heatsink. The W510 uses copper instead of aluminum, and has two vents instead of one. The mounting is mostly compatible - the form factor is identical, but the GPU pad doesn't clear some inductors that sit where W510's GPU is supposed to be. Cutting the pad with a dremel works.

After the replacement, the load temperatures dropped quite a bit, and I can now run it fanless when just web-browsing. It also comes in useful when doing 3D rendering, as I can run the fan slower (with [TPFanControl](http://www.staff.uni-marburg.de/~schmitzr/donate.html)).

##### Screen upgrade
The laptop uses a typical 40-pin LVDS cable, therefore making it compatible with most 15.6" displays of that era (laptops switched to eDP since then). The swap ended up being fairly straightforward, as screen mounting also seems to be standard.