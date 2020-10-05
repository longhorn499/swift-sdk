/****************************************************************************
* Copyright 2020, Optimizely, Inc. and contributors                        *
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

/// A struct for user contexts that the SDK will use to make decisions for.
public struct OptimizelyUserContext {
    weak var optimizely: OptimizelyClient?
    var userId: String
    var attributes: [String: Any]
    
    /// OptimizelyUserContext init
    ///
    /// - Parameters:
    ///   - optimizely: an instance of OptimizelyClient to be used for decisions.
    ///   - userId: The user ID to be used for bucketing.
    ///   - attributes: A map of attribute names to current user attribute values.
    public init(optimizely: OptimizelyClient,
                userId: String,
                attributes: [String: Any]? = nil) {
        self.optimizely = optimizely
        self.userId = userId
        self.attributes = attributes ?? [:]
    }
    
    /// Set an attribute for a given key.
    /// - Parameters:
    ///   - key: An attribute key
    ///   - value: An attribute value
    public mutating func setAttribute(key: String, value: Any) {
        attributes[key] = value
    }
    
    public func decide(key: String, options: [OptimizelyDecideOption]? = nil) -> OptimizelyDecision {
        return OptimizelyDecision.errorDecision(key: key, user: nil, error: .sdkNotReady)
    }

    public func decideAll(keys: [String], options: [OptimizelyDecideOption]? = nil) -> [String: OptimizelyDecision] {
        return [:]
    }

    public func decideAll(options: [OptimizelyDecideOption]? = nil) -> [String: OptimizelyDecision] {
        return [:]
    }

    public func trackEvent(eventKey: String, eventTags:  [String: Any]? = nil) {
    }
}

extension OptimizelyUserContext: Equatable {
    
    public static func ==(lhs: OptimizelyUserContext, rhs: OptimizelyUserContext) -> Bool {
        return lhs.userId == rhs.userId &&
            (lhs.attributes as NSDictionary).isEqual(to: rhs.attributes)
    }
    
}
