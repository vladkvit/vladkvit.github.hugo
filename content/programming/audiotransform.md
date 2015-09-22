+++
Title = "Audio Transform"
tags = [ "programming", "Matlab" ]
summary_layout = "2and1"
weight = 1

summaryimagesrel = "shadowbox[audio]"

[[summaryimages]]
imagehref = "../images/audio_transform/stft_mod3.png"
thumburl = "../images/audio_transform/thumb/stft_mod3.png"
title = "f2"

[[summaryimages]]
imagehref = "../images/audio_transform/Signal.png"
thumburl = "../images/audio_transform/thumb/Signal.png"
title = "f2"

+++
<p>This is my work-in-progress for a new audio transform. I would like something that has both a high frequency resolution & bandwidth along with a high temporal resolution. By comparison, regular (non-windowed) FFT transforms the entire signal, with no temporal axis. A windowed FFT has a temporal resolution of SIG_LENGTH / WINDOW_LENGTH. A STFT transform (FFT with sliding window) is better, but its temporal resolution is still low-frequency. My transform is inspired by the way ears work, as I believe that is a better space for what I am trying to achieve.</p>
<p>The top picture is the transform of the signal below. As I'm still developing the transform, more information will come later. </p>