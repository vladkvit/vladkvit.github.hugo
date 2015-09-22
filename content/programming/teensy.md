+++
Title = "Teensy chip programming"
tags = [ "programming", "embedded" ]
summary_layout = "3and0"

weight = 16


+++
<p>I wanted to make the closed-loop response of my quadcopter faster (AHRS to ESC path). I got a <a href="http://www.pjrc.com/teensy/">Teensy 2.0</a> to read serial from AHRS, send PWM to the ESCs, and read USB from the motherboard for direction info.</p>
<p>I only got as far as making a blinking LED and interfacing with x86 through raw USB. See projects <a href="https://bitbucket.org/vkvitnev/teensy_vs2010">here</a> and <a href="https://bitbucket.org/vkvitnev/teensy_vs2010_2">here</a>.</p>
