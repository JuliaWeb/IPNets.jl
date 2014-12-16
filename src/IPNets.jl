module IPNets

    if VERSION < v"0.4.0-dev+412"
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
        IPNet, IPv4Net, IPv6Net

    include("ipnet.jl")
end
