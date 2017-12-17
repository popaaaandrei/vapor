/// A required argument for a command.
///
///     exec command <arg>
///
public struct Argument {
    /// The argument's unique name.
    public let name: String

    /// The arguments's help text when `--help` is passed.
    public let help: [String]

    /// Creates a new command argument
    public init(name: String, help: [String] = []) {
        self.name = name
        self.help = help
    }
}



/// A supported option for a command.
///
///     exec command [--opt]
///
public struct Option {
    /// The option's unique name.
    ///     --foo
    public let name: String

    /// This option's unique short name.
    ///     -f
    public let short: Character?

    /// The option's help text when `--help` is passed.
    public let help: [String]

    /// The specific type of option
    public let type: OptionType

    /// Creates a new command option.
    public init(
        name: String,
        short: Character? = nil,
        help: [String] = [],
        type: OptionType
    ) {
        self.name = name
        self.help = help
        self.type = type
    }

    /// Creates a new Option with OptionType = `.flag`.
    /// See `OptionType.flag` for more information.
    public static func flag(
        name: String,
        short: Character? = nil,
        help: [String] = []
    ) -> Option {
        return .init(name: name, short: short, help: help, type: .flag)
    }

    /// Creates a new Option with OptionType = `.normal`.
    /// See `OptionType.normal` for more information.
    public static func normal(
        name: String,
        short: Character? = nil,
        help: [String] = [],
        default: String? = nil
    ) -> Option {
        return .init(name: name, short: short, help: help, type: .normal(default: `default`))
    }
}

/// Supported option types.
public enum OptionType {
    /// Value is always `"true"` if this option is supplied.
    /// Passing a value will result in an error.
    ///     --release
    case flag
    /// Option that supports a value. If a default value is
    /// supplied, the option can be passed like a flag.
    /// If there is no default value, an error will be thrown
    /// if the option appears without a value.
    ///     --name foo
    case normal(default: String?)
}
