import Console

/// exec foo --baz=bar
extension Input {
//    /// exec
//    var executable: String
//
//    /// foo
//    var arguments: [String]
//
//    /// --baz=bar
//    var options: [String: String]

    /// Parses raw array of strings into arguments and options.
    static func parse(
        options: [Option],
        arguments: [Argument],
        from raw: [String]
    ) throws -> Input {
        guard raw.count > 0 else {
            throw CommandError(
                identifier: "executableRequired",
                reason: "At least one argument is required."
            )
        }
        let executable = raw[0]
        var raws = Array(raw.dropFirst()).map { $0 as String? }

        let parsedOptions = try [String: String](uniqueKeysWithValues: options.flatMap { option in
            return try parse(option: option, from: &raws)
        })

        let parsedArguments = try arguments.flatMap { arg in
            return try parse(argument: arg, from: &raws)
        }

        let unused = raws.flatMap { raw in
            guard let raw = raw else {
                return nil
            }
            return raw
        }

        guard unused.isEmpty else {
            throw CommandError(
                identifier: "unexpectedArguments",
                reason: "Extraneous arguments were supplied: \(unused)."
            )
        }

        return Input(
            executable: executable,
            arguments: validatedArguments,
            options: validatedOptions
        )
    }

    /// Parses arguments from a raw string array.
    static func parse(argument: Argument, from raws: inout [String?]) throws -> String? {
        var val: String?
        var index = 0
        var iterator = raws.makeIterator()
        while let cur = iterator.next() {
            defer { index += 1 }
            guard let raw = cur else {
                continue
            }
            if raw.hasPrefix("-") {
                continue
            }
            val = raw
            raws.remove(at: index)
        }
        return val
    }

    static func parse(option: Option, from raws: inout [String?]) throws -> (String, String)? {
        let val: String

        var index = 0
        var iterator = raws.makeIterator()
        while let cur = iterator.next() {
            defer { index += 1 }
            guard var raw = cur else {
                continue
            }

            if raw.hasPrefix("--") {
                guard raw.hasPrefix("--\(option.name)") else {
                    return nil
                }

                let parts = raw.dropFirst(2)
                    .split(separator: "=", maxSplits: 1)
                    .map(String.init)

                switch option.type {
                case .flag:
                    switch parts.count {
                    case 1:
                        raws[index] = nil
                        val = "true"
                    default:
                        throw CommandError(
                            identifier: "invalidOption",
                            reason: "Option \(raw) is incorrectly formatted."
                        )
                    }
                case .normal(let d):
                    switch parts.count {
                    case 1:
                        if let d = d {
                            val = d
                        } else {
                            if let n = iterator.next(), let next = n {
                                /// also remove next param from args
                                raws[index + 1] = nil
                                val = next
                            } else {
                                throw CommandError(
                                    identifier: "invalidOption",
                                    reason: "Option \(raw) requires a value."
                                )
                            }
                        }
                    case 2:
                        val = parts[2]
                    default:
                        throw CommandError(
                            identifier: "invalidOption",
                            reason: "Option \(raw) is incorrectly formatted."
                        )
                    }
                }
                raws[index] = nil
            } else if raw.hasPrefix("-"), let short = option.short {
                guard let pos = raw.index(of: short) else {
                    return nil
                }

                switch option.type {
                case .flag:
                    val = "true"
                case .normal(let d):
                    if let d = d {
                        val = d
                    } else {
                        if let n = iterator.next(), let next = n {
                            raws[index + 1] = nil
                            val = next
                        } else {
                            throw CommandError(
                                identifier: "invalidOption",
                                reason: "Option \(raw) requires a value."
                            )
                        }
                    }
                }

                /// remove this shortflag since we've parsed it
                raw.remove(at: pos)
                if raw.count <= 1 {
                    // we've removed all short flags,
                    // get rid of option
                    raws[index] = nil
                } else {
                    raws[index] = raw
                }
            } else {
                return nil
            }
        }

        return (option.name, val)
    }
//
//    /// Parses options from a raw string array.
//    static func parseOptions(from raw: [String]) throws -> [String: String] {
//        var options: [String: String] = [:]
//
//        for arg in raw {
//            guard arg.hasPrefix("--") else {
//                continue
//            }
//
//            let val: String
//
//            let parts = arg.dropFirst(2).split(separator: "=", maxSplits: 1).map(String.init)
//            switch parts.count {
//            case 1:
//                switch
//                val = "true"
//            case 2:
//                val = parts[1]
//            default:
//                throw CommandError(identifier: "invalidOption", reason: "Option \(arg) is incorrectly formatted.")
//            }
//
//            options[parts[0]] = val
//        }
//
//        return options
//    }
}

//extension ParsedInput {
//    /// Generates Input ready to go to a command against
//    /// the supplied arguments and options.
//    mutating func generateInput(arguments: [Argument], options: [Option]) throws -> Input {
//        var validatedArguments: [String: String] = [:]
//
//        guard arguments.count <= arguments.count else {
//            throw CommandError(identifier: "unexpectedArguments", reason: "Too many arguments supplied.")
//        }
//        for arg in arguments {
//            guard let argument = self.arguments.popFirst() else {
//                throw CommandError(identifier: "insufficientArguments", reason: "Insufficient arguments supplied.")
//            }
//            validatedArguments[arg.name] = argument
//        }
//
//        var validatedOptions: [String: String] = [:]
//
//        // ensure we don't have any unexpected options
//        for key in self.options.keys {
//            guard options.contains(where: { $0.name == key }) else {
//                throw CommandError(identifier: "unexpectedOptions", reason: "Unexpected option `\(key)`.")
//            }
//        }
//
//        // set all options to value or default
//        for opt in options {
//            validatedOptions[opt.name] = self.options[opt.name] ?? opt.default
//        }
//
//
//    }
//}

