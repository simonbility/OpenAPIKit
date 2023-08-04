//
//  DereferencedParameter.swift
//  
//
//  Created by Mathew Polzin on 6/18/20.
//

import OpenAPIKitCore

/// An `OpenAPI.Parameter` type that guarantees
/// its `schemaOrContent` is inlined instead of
/// referenced.
@dynamicMemberLookup
public struct DereferencedParameter: Equatable {
    /// The original `OpenAPI.Parameter` prior to being dereferenced.
    public let underlyingParameter: OpenAPI.Parameter
    /// The dereferenced schema or content for the parameter.
    ///
    /// Only one of a "schema" or "content" can apply to any given
    /// parameter.
    public let schemaOrContent: Either<DereferencedSchemaContext, DereferencedContent.Map>

    public subscript<T>(dynamicMember path: KeyPath<OpenAPI.Parameter, T>) -> T {
        return underlyingParameter[keyPath: path]
    }

    /// Create a `DereferencedParameter` if all references in the
    /// parameter can be found in the given Components Object.
    ///
    /// - Throws: `ReferenceError.cannotLookupRemoteReference` or
    ///     `ReferenceError.missingOnLookup(name:key:)` depending
    ///     on whether an unresolvable reference points to another file or just points to a
    ///     component in the same file that cannot be found in the Components Object.
    internal init(
        _ parameter: OpenAPI.Parameter,
        resolvingIn components: OpenAPI.Components,
        following references: Set<AnyHashable>
    ) throws {
        switch parameter.schemaOrContent {
        case .a(let schemaContext):
            self.schemaOrContent = .a(
                try DereferencedSchemaContext(
                    schemaContext,
                    resolvingIn: components,
                    following: references
                )
            )
        case .b(let contentMap):
            self.schemaOrContent = .b(
                try contentMap.mapValues {
                    try DereferencedContent(
                        $0,
                        resolvingIn: components,
                        following: references
                    )
                }
            )
        }

        self.underlyingParameter = parameter
    }
}

extension OpenAPI.Parameter: LocallyDereferenceable {
    /// An internal-use method that facilitates reference cycle detection by tracking past references followed
    /// in the course of dereferencing.
    ///
    /// For all external-use, see `dereferenced(in:)` (provided by the `LocallyDereferenceable` protocol).
    /// All types that provide a `_dereferenced(in:following:)` implementation have a `dereferenced(in:)`
    /// implementation for free.
    public func _dereferenced(in components: OpenAPI.Components, following references: Set<AnyHashable>) throws -> DereferencedParameter {
        return try DereferencedParameter(self, resolvingIn: components, following: references)
    }

    public func externallyDereferenced<Context: ExternalLoaderContext>(in context: inout Context) throws -> Self {
        var parameter = self
        
        // TODO: externallyDerefence the schemaOrContent
#warning("need to externally dereference the schemaOrContent here")

        return parameter
    }
}
