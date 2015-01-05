module IPNets
    using Compat
    import Base: IPAddr, IPv4, IPv6, parseipv4, parseipv6
    import Base: length, size, endof, minimum, maximum, extrema, isless
    import Base: in, contains, issubset
    import Base: display, show, string, start, next

    export
        # types
        IPNet, IPv4Net, IPv6Net

    include("ipnet.jl")
end
