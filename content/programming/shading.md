+++
Title = "Specular + Diffuse Shading"
tags = ["programming", "pixel bender"]
summary_layout = "1and2"
summary_numimgcolumns = 2
summary_imagesrel = "shadowbox[materialshader]"

weight = 3

[[summaryimages]]
imagehref = "../images/BRDF_Shader/rocks1.png"
thumburl = "../images/BRDF_Shader/thumb/rocks1.png"
title = "f2"

[[summaryimages]]
imagehref = "../images/BRDF_Shader/rocks3.png"
thumburl = "../images/BRDF_Shader/thumb/rocks3.png"
title = "f2"
+++
<p><a href="https://www.youtube.com/watch?v=btRh_7UlCwU">Video here</a>.</p>
<p>I implemented a common real-time shading technique. The code has two ways of computing the specular component, a cosine diffuse component, options for glossiness and for moving the light in 3D space. It's done in Adobe Pixel Bender - I found that I can iterate faster with it as opposed to other shader prototyping platforms. Email me for code.</p>