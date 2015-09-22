+++
Title = "Quadcopter"
tags = [ "programming", "real-time", "embedded" ]
summary_layout = "1and2"
summary_numimgcolumns = 2
summary_imagesrel = "shadowbox[quad]"
weight = 0

[[summaryimages]]
imagehref = "../images/Quadcopter/DSCN7754.JPG"
thumburl = "../images/Quadcopter/thumb/DSCN7754.JPG"
title = "f2"

[[summaryimages]]
imagehref = "../images/Quadcopter/DSCN9035.JPG"
thumburl = "../images/Quadcopter/thumb/DSCN9035.JPG"
title = "g2"

[[summaryimages]]
imagehref = "../images/Quadcopter/DSCN7753.JPG"
thumburl = "../images/Quadcopter/thumb/DSCN7753.JPG"
title = "g2"

[[summaryimages]]
imagehref = "../images/Quadcopter/DSCN7767.JPG"
thumburl = "../images/Quadcopter/thumb/DSCN7767.JPG"
title = "g2"

+++
<p>I sponsored and did quite a bit of work to help with my brother's quadcopter. This was his Gr.12 robotics club project, and they ended up winning second place @ World championship. Unfortunately, I don't have any pictures of it flying - I'll post some up later, hopefully.</p>
<p><a href="https://github.com/larrykvit/Motion_Detection_Suite">Here's</a> the code Github page. The basic idea was to try using a tiny x86 board with TCP/IP over WiFi, and a Ground Control Station. We used <a href="http://qgroundcontrol.org/">QGroundControl</a> as the GCS. We were using 500Hz ESCs (brushless motor controllers), a 500Hz AHRS (heading and reference fusion of 3D gyro + 3D magnetometer + 3D accelerometer), and a Maestro USB-PWM adapter. Although using x86 + OS wasn't the best idea, it still worked.</p>