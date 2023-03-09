
struct AGResources: Equatable {
    let cameraGraphics: [Graphic.CameraPosition: Graphic]
    let videoGraphics: [GraphicVideoPlayer: Graphic]
    let imageGraphics: [AGImage.Source: Graphic]
}