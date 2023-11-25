import CoreGraphics

public protocol CodableGraphicProtocol {
    
    static var type: CodableGraphicType { get }
    
    var properties: [any AnyGraphicProperty] { get }
    
    init()
    
    func isVisible(propertyKey: String, at resolution: CGSize) -> Bool?
    func isVisible<P: GraphicPropertyType>(property: P, at resolution: CGSize) -> Bool
    
    static func variants() -> [CodableGraphicVariant]
    static func variantIDs() -> [GraphicVariantID]
    func edit(variantKey: String)
    func edit<V: GraphicVariant>(variant: V)
}

extension CodableGraphicProtocol {
    
    var type: CodableGraphicType {
        Swift.type(of: self).type
    }
}

extension CodableGraphicProtocol {
    
    func isVisible<P: GraphicPropertyType>(property: P, at resolution: CGSize) -> Bool {
        true
    }
}


extension CodableGraphicProtocol {
    
    static func variants() -> [CodableGraphicVariant] {
        variantIDs().map { variantID in
            let instance: Self = .init()
            instance.edit(variantKey: variantID.key)
            return CodableGraphicVariant(
                description: variantID.description,
                instance: instance)
        }
    }
    
    func edit<V: GraphicVariant>(variant: V) {}
}
