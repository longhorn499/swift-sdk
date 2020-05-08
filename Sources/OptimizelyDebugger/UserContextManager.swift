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

class UserContextManager {
    public static let shared = UserContextManager()
    
    var userContext: OptimizelyUserContext?

    private init() {}
    
    static func setUserContext(_ user: OptimizelyUserContext?) {
        shared.userContext = user
    }
    
    static func getUserContext() -> OptimizelyUserContext? {
        return shared.userContext
    }
    
    static func syncUserContext(userId: String? = nil, attributes: OptimizelyAttributes? = nil) -> (String, OptimizelyAttributes?) {
        
        if shared.userContext == nil, let userId = userId {
            shared.userContext = OptimizelyUserContext(userId: userId, attributes: attributes)
        }
        
        if userId != nil {
            return (userId!, attributes)
        }
        
        if let uc = shared.userContext {
            return (uc.userId, uc.attributes)
        }
        
        return ("invalid", nil)
    }
    
    static func addForcedVariation(userId: String, experimentKey: String, variationKey: String?) {
        if let uc = shared.userContext, uc.userId == userId {
            uc.addForcedVariation(experimentKey: experimentKey, variationKey: variationKey)
        }
    }
    
    static func getVariation(experimentKey: String,
                             userId: String,
                             attributes: OptimizelyAttributes?) -> String? {
        guard let uc = shared.userContext, uc.userId == userId  else { return nil }

        if let fvs = uc.forcedVariations {
            return fvs[experimentKey]
        } else {
            return nil
        }
    }
    
    static func getFeatureEnabled(featureKey: String,
                                  userId: String,
                                  attributes: OptimizelyAttributes?) -> Bool? {
        guard let uc = shared.userContext, uc.userId == userId  else { return nil }

        if let fvs = uc.forcedFeatures {
            return fvs[featureKey]
        } else {
            return nil
        }
    }

}
