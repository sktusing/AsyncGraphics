# ``AsyncGraphics/Graphic3D``

A Graphic3D is a 3d image, made up out of voxels. It's backed by a `MTLTexture`. 

## Topics

### Data

- ``texture``

### Metadata

- ``bits``
- ``colorSpace``

### Resolution

- ``width``
- ``height``
- ``depth``
- ``resolution``

### Options

- ``Options``


### Voxels

- ``firstVoxelColor``
- ``averageVoxelColor``
- ``voxelColors``
- ``channels``
- ``isVoxelsEqual(to:)``

### Texture

- ``texture(_:)``
- ``Texture3DError``

### Color

- ``color(_:resolution:options:)``

### Box

- ``box(size:origin:cornerRadius:color:backgroundColor:resolution:options:)``
- ``box(size:center:cornerRadius:color:backgroundColor:resolution:options:)``
- ``surfaceBox(size:origin:cornerRadius:surfaceWidth:color:backgroundColor:resolution:options:)``
- ``surfaceBox(size:center:cornerRadius:surfaceWidth:color:backgroundColor:resolution:options:)``

### Sphere

- ``sphere(radius:center:color:backgroundColor:resolution:options:)``
- ``surfaceSphere(radius:center:surfaceWidth:color:backgroundColor:resolution:options:)``

### Blend

Use blending modes to combine two 3d graphics.

- ``blended(with:blendingMode:placement:)``

### Levels

- ``brightness(_:)``
- ``darkness(_:)``
- ``contrast(_:)``
- ``gamma(_:)``
- ``inverted()``
- ``smoothed()``
- ``opacity(_:)``
- ``exposureOffset(_:)``

### Blur

- ``blurredBox(radius:sampleCount:)``
- ``blurredZoom(radius:center:sampleCount:)``
- ``blurredDirection(radius:direction:sampleCount:)``
- ``blurredRandom(radius:)``

### Technical

- ``average(axis:)``
- ``sample(fraction:)``
- ``sample(index:)``
- ``samples()``