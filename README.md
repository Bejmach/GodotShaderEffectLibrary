# GodotShaderEffectLibrary

## About
Library with graphic effects to godot

## Table of content
### Universal(2D/3D)
#### Color effects
* [Chromatic Aberration](#chromatic-aberration)
* [Quantization](#quantization)
* [grayscale](#grayscale)
#### Blurs
* [Gaussian blur](#gaussian-blur)
#### Outlines
* [Difference of gaussian](#difference-of-gaussian)
* [Sobel filter](#sobel-filter)
#### Components
* [rgb to hsv](#rgb-to-hsv)
* [hsv to rgb](#hsv-to-rgb)
### 3D specyfic
#### Components
* [Linear depth](#linear-depth)

## Color effects
### Chromatic aberration
#### description
returns vec3 of color with red, green and blue dissplaced in direction to the middle to the screen
#### construction
chromaticAberration(sampler2D screen_texture, vec2 uv, vec3 rgbDissplacement, float efectiveDistance, float screenTrim)
#### needed parameters
* sampler2D screen_texture - texture of screen
* vec2 uv - uv
* vec3 rgbDissplacement - vector with dissplacement of color in direction outside the middle of the screen, prefferably less than 0 (redDissplacement, greenDissplacement, blueDissplacement);
* float effectDistance - distance from middle of the screen, where the effect take place, 0 - whole screen, 0.5 - around half the screen, outside of middle
* float screenTrim - when setting rgbDissplacement on more than 0, it doesn't work on edges, so only then screen trim is needed (should use as another effect, change in next patches)

### Quantization
#### description
returns vec3 of quantized color by hue, saturation and/or value
#### construction
quantization(vec3 rgb, float scale, bool hue, bool saturation, bool value)
#### needed parameters
* vec3 rgb - color in rgb
* float scale - number of possible results of quantization
* bool hue/saturation/value - tells what parameters of color should be quantized

### Grayscale
#### description
returns float of grayscale of color
#### construction
grayscale(vec3 rgb)
#### needed parameters
* vec3 rgb - color in rgb

### Gaussian blur
#### desctiption
returns vec3 of average of colors in certain distance around the UV position
#### construction
blur(vec2 viewport_size, sampler2D screen_texture, vec2 screen_uv, int scale, int precision)
#### needed parameters
* vec2 viewport_size - size of viewport
* sampler2D screen_texture - texture of screen
* vec2 screen_uv - uv
* int scale - distance from point to used pixels(WARNING, setting it to big numbers makes program run signifficantly slower, look at precision to prevent it. number of pixels to take is n\*2+1)
* int precision - take less pixels from the same area(precission = 3, take ...,-3,0,3,... pixel)

### Difference of gaussian
#### description
returns vec3 of difference of 2 gaussian blur effects
#### construction
differenceOfGaussian(vec2 viewport_size, sampler2D screen_texture, vec2 screen_uv, int scale_less, int scale_more)
#### needed parameters
* vec2 viewport_size - size of viewport
* sampler2D screen_texture - texture of screen
* vec2 screen_uv - uv
* int scale_less - scale of the first gaussian blur(prefferably lesser)
* int scale_more - scale of the second gaussian blur(prefferably bigger)

### Sobel filter
#### description
return vec3 of grayscale of 9 close pixels by 2 matrixes(look at the rest on web)
#### construction
sobelFilter(vec2 viewport_size, sampler2D screen_texture, vec2 screen_uv, int size)
#### needed parameters
* vec2 viewport_size - size of viewport
* sampler2D screen_texture - texture of screen
* vec2 screen_uv - uv
* int size - distance from one pixel to another(size = 3, take pixels -3,0,3)

### rgb to hsv
#### desctiption
returns vec3 of hsv made from given rgb
#### construction
rgbToHsv(vec3 rgb)

### hsv to rgb
#### desctiption
returns vec3 of rgb made from given hsv
#### construction
hsvToRgb(vec3 hsv)

### Linear depth
#### description
returns float of distance from camera to object by transforming depth taken from texture(depth_texture)(works only in 3D)
#### construction
linearDepth(float depth, vec2 screen_uv, float inv_projection_matrix)
#### needed parameters
* flaot depth - depth taken from texture()
* vec2 screen_uv - uv
* float inv_projection_matrix - inversed projection matrix(whatever that is)
