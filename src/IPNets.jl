module IPNets

    if VERSION.minor < 4
        const IPAddr = Base.IpAddr
    else
        import Base: IPAddr
    end

    using Compat
    import Base: IPv4, IPv6, parseipv4, parseipv6
    import Base: length, size, endof, minimum, maximum, extrema, isless
    import Base: in, contains
    import Base: display, show, string

    export
        # types
        IPNet, IPv4Net, IPv6Net,

        # methods
        isless
    include("ipnet.jl")
end
