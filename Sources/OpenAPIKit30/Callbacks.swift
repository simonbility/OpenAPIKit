//
//  Callback.swift
//  
//
//  Created by Mathew Polzin on 11/1/20.
//

import OpenAPIKitCore
import Foundation

extension OpenAPI {
    /// A map from runtime expressions to path items to be used as
    /// callbacks for the API.
    ///
    /// See [OpenAPI Callback Object](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md#callback-object).
    ///
    public typealias Callbacks = OrderedDictionary<CallbackURL, PathItem>

    /// A map of named collections of Callback Objects (`OpenAPI.Callbacks`).
    public typealias CallbacksMap = OrderedDictionary<String, Either<JSONReference<Callbacks>, Callbacks>>
}