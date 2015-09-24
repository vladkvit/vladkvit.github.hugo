+++
Title = "Quadcopter"
tags = [ "programming", "real-time", "embedded" ]
summary_layout = "1and2"
summary_numimgcolumns = 2
summary_imagesrel = "shadowbox[quad]"
weight = 0
linkable = true

[[summaryimages]]
imagehref = "/images/Quadcopter/DSCN9035.JPG"
thumburl = "/images/Quadcopter/thumb/DSCN9035.JPG"
title = "All assembled"

[[summaryimages]]
imagehref = "/images/Quadcopter/DSCN7767.JPG"
thumburl = "/images/Quadcopter/thumb/DSCN7767.JPG"
title = "Test bench	"

+++
I sponsored and did quite a bit of work to help with my brother's quadcopter when he was back in highschool. [Here's](https://github.com/larrykvit/Motion_Detection_Suite) the code Github page.
<!--more-->

 The basic idea was to try using a tiny x86 board with TCP/IP over WiFi, and a Ground Control Station. We used <a href="http://qgroundcontrol.org/">QGroundControl</a> as the GCS. We were using ESCs flashed with SimonK, a YEI 500Hz AHRS, and a Maestro USB-PWM adapter. Although using x86 and custom-writing the flight control software wasn't a good idea, in retrospect, it still sort of worked.