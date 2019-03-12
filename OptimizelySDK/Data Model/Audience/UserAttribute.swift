/****************************************************************************
 * Copyright 2018, Optimizely, Inc. and contributors                        *
 *                                                                          *
 * Licensed under the Apache License, Version 2.0 (the "License");          *
 * you may not use this file except in compliance with the License.         *
 * You may obtain a copy of the License at                                  *
 *                                                                          *
 *    http://www.apache.org/licenses/LICENSE-2.0                            *
 *                                                                          *
 * Unless required by applicable law or agreed to in writing, software      *
 * distributed under the License is distributed on an "AS IS" BASIS,        *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. *
 * See the License for the specific language governing permissions and      *
 * limitations under the License.                                           *
 ***************************************************************************/

import Foundation

struct UserAttribute: Codable, Equatable {
    
    // MARK: - JSON parse
    
    var name: String?
    var type: String?
    var match: String?
    var value: AttributeValue?
    
    enum CodingKeys: String, CodingKey {
        case name
        case type
        case match
        case value
    }
    
    // MARK: - Forward compatable evaluation support
    
    enum ConditionType: String, Codable {
        case customAttribute = "custom_attribute"
    }
    
    enum ConditionMatch: String, Codable {
        case exact
        case exists
        case substring
        case lt
        case gt
    }
    
    var typeSupported: ConditionType? {
        guard let rawType = type else { return nil }
        
        return ConditionType(rawValue: rawType)
    }
    
    var matchSupported: ConditionMatch? {
        // legacy audience (default = "exact")
        guard let rawMatch = match else { return .exact }
        
        return ConditionMatch(rawValue: rawMatch)
    }

    // MARK: - init
    
    init(from decoder: Decoder) throws {
        // forward compatibility support: accept all string values for {type, match} not defined in enum
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        do {
            self.name = try container.decodeIfPresent(String.self, forKey: .name)
            self.type = try container.decodeIfPresent(String.self, forKey: .type)
            self.match = try container.decodeIfPresent(String.self, forKey: .match)
            self.value = try container.decodeIfPresent(AttributeValue.self, forKey: .value)
        } catch {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath, debugDescription: "Faild to decode User Attribute)"))
        }
    }
    
    init(name: String, type: String, match: String?, value: AttributeValue?) {
        self.name = name
        self.type = type
        self.match = match
        self.value = value
    }
}

extension UserAttribute {
    
    func evaluate(attributes: [String: Any]?) throws -> Bool {
        
        // invalid type - parsed for forward compatibility only (but evaluation fails)
        guard let _ = typeSupported else {
            throw OptimizelyError.conditionInvalidAttributeType(self.type ?? "empty")
        }

        // invalid match - parsed for forward compatibility only (but evaluation fails)
        guard let matchFinal = matchSupported else {
            throw OptimizelyError.conditionInvalidAttributeMatch(self.match ?? "empty")
        }
        
        guard let nameFinal = name else {
            throw OptimizelyError.conditionInvalidFormat("empty name")
        }
        
        if matchFinal != .exists, value == nil {
            throw OptimizelyError.conditionInvalidFormat("missing value (\(nameFinal)))")
        }
        
        guard let attributes = attributes else {
            // TODO: [Jae] confirm this
            return false
        }
        
        guard !attributes.isEmpty else {
            // TODO: [Jae] confirm this
            throw OptimizelyError.conditionInvalidFormat("empty attribute")
        }
        
        let attributeValue = attributes[nameFinal]
        
        switch matchFinal {
        case .exists:
            return attributeValue != nil
        case .exact:
            return try value!.isExactMatch(with: attributeValue)
        case .substring:
            return try value!.isSubstring(of: attributeValue)
        case .lt:
            // user attribute "less than" this condition value
            // so evaluate if this condition value "isGreater" than the user attribute value
            return try value!.isGreater(than: attributeValue)
        case .gt:
            // user attribute "greater than" this condition value
            // so evaluate if this condition value "isLess" than the user attribute value
            return try value!.isLess(than: attributeValue)
        }
    }
    
}
