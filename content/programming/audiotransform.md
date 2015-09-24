+++
Title = "Audio Transform"
tags = [ "programming", "Matlab" ]
summary_layout = "2and1"
summary_numimgcolumns = 1
summary_imagesrel = "shadowbox[audio]"
weight = 1

[[summaryimages]]
imagehref = "/images/audio_transform/stft_mod3.png"
thumburl = "/images/audio_transform/thumb/stft_mod3.png"
title = "Transform"

[[summaryimages]]
imagehref = "/images/audio_transform/Signal.png"
thumburl = "/images/audio_transform/thumb/Signal.png"
title = "Signal"

+++
Fooling around with wavelet-like transforms. I would like something that has both a high frequency resolution & bandwidth along with a high temporal resolution for high frequencies. By comparison, regular (non-windowed) FFT transforms the entire signal, with no temporal axis. A windowed FFT has a temporal resolution of SIG_LENGTH / WINDOW_LENGTH. A STFT transform (FFT with sliding window) is better, but its temporal resolution is still low-frequency. My transform is inspired by the way ears work, as I believe that is a better space for what I am trying to achieve. Constant Q transforms / Morlet wavelet transform solve this problem on some level as well.

The top picture is the transform of the signal in the bottom picture (two sines added together).
<!--more-->
