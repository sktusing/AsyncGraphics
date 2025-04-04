import Foundation
import SwiftUI

public class AnyGraphicEnumProperty: AnyGraphicProperty {
    
    public let key: String
    public let name: String
    public let docs: String
    
    public let rawValue: String
    public let defaultRawValue: String
    public let allCases: [GraphicEnumCase]
    
    private var updateValue: (String) throws -> ()
    
    init<T: GraphicEnum>(
        key: String,
        name: String,
        docs: String,
        value: T,
        defaultValue: T,
        allCases: [GraphicEnumCase],
        update: @escaping (T) -> ()
    ) where T.RawValue == String {
        
        self.key = key
        self.name = name
        self.docs = docs
        
        rawValue = value.rawValue
        defaultRawValue = defaultValue.rawValue
        self.allCases = allCases
        
        updateValue = { rawValue in
            guard let value: T = T(rawValue: rawValue) else {
                throw GraphicEnumError.caseUnknown
            }
            update(value)
        }
    }
}

public extension AnyGraphicEnumProperty {
    
    func getRawValue() -> String {
        rawValue
    }
    
    func getDefaultRawValue() -> String {
        defaultRawValue
    }
    
    func getAllCases() -> [GraphicEnumCase] {
        allCases
    }
    
    func setRawValue(_ rawValue: String) throws {
        try updateValue(rawValue)
    }
}

extension AnyGraphicEnumProperty {
    
    enum GraphicEnumError: Error {
        case caseUnknown
    }
}
