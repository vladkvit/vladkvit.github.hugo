+++
Title = "Quadcopter"
tags = ["tag1", "tag2"]
summary_layout = "1and2"
summary_numpics = 4
+++
I sponsored and did quite a bit of work to help with my brother's quadcopter. This was his Gr.12 robotics club project, and they ended up winning second place @ World championship. Unfortunately, I don't have any pictures of it flying - I'll post some up later, hopefully.

Here's the code Github page. The basic idea was to try using a tiny x86 board with TCP/IP over WiFi, and a Ground Control Station. We used QGroundControl as the GCS. We were using 500Hz ESCs (brushless motor controllers), a 500Hz AHRS (heading and reference fusion of 3D gyro + 3D magnetometer + 3D accelerometer), and a Maestro USB-PWM adapter. Although using x86 + OS wasn't the best idea, it still worked.