module IPNets

using Sockets: IPAddr, IPv4, IPv6

export IPNet, IPv4Net, IPv6Net

abstract type IPNet end

IPNet(str::AbstractString) = parse(IPNet, str)
Base.parse(::Type{IPNet}, str::AbstractString) =
    ':' in str ? parse(IPv6Net, str) : parse(IPv4Net, str)

############################
## Types and constructors ##
############################

"""
    IPv4Net(str::AbstractString)
    IPv4Net(ip::IPv4, netmask::Int)
    IPv4Net(ip::IPv4, netmask::IPv4)

Type representing a IPv4 network.

# Examples
```julia
julia> IPv4Net("192.168.0.0/24")
IPv4Net("192.168.0.0/24")

julia> IPv4Net(ip"192.168.0.0", 24)
IPv4Net("192.168.0.0/24")

julia> IPv4Net(ip"192.168.0.0", ip"255.255.255.0")
IPv4Net("192.168.0.0/24")
```
"""
struct IPv4Net <: IPNet
    netaddr::UInt32
    netmask::UInt32
    function IPv4Net(netaddr::UInt32, netmask::UInt32)
        netaddr′ = netaddr & netmask
        if netaddr′ !== netaddr
            throw(ArgumentError("input $(IPv4(netaddr))/$(count_ones(netmask)) has host bits set"))
        end
        new(netaddr′, netmask)
    end
end

# "1.2.3.0/24"
IPv4Net(str::AbstractString) = parse(IPv4Net, str)
# ip"1.2.3.0", 24
IPv4Net(netaddr::IPv4, netmask::Integer=32) = IPv4Net(netaddr.host, to_mask(UInt32(netmask)))
# ip"1.2.3.0", ip"255.255.255.0"
function IPv4Net(netaddr::IPv4, netmask::IPv4)
    netmask′ = to_mask(UInt32(count_ones(netmask.host)))
    if netmask′ !== netmask.host
        throw(ArgumentError("non-contiguous IPv4 subnets not supported, got $(netmask)"))
    end
    return IPv4Net(netaddr.host, netmask′)
end

"""
    IPv6Net(str::AbstractString)
    IPv6Net(ip::IPv6, netmask::Int)

Type representing a IPv6 network.

# Examples
```julia
julia> IPv6Net("1::2/64")
IPv6Net("1::/64")

julia> IPv6Net(ip"1::2", 64)
IPv6Net("1::/64")
```
"""
struct IPv6Net <: IPNet
    netaddr::UInt128
    netmask::UInt128
    function IPv6Net(netaddr::UInt128, netmask::UInt128)
        netaddr′ = netaddr & netmask
        if netaddr′ !== netaddr
            throw(ArgumentError("input $(IPv6(netaddr))/$(count_ones(netmask)) has host bits set"))
        end
        return new(netaddr′, netmask)
    end
end

# "2001::1/64"
IPv6Net(str::AbstractString) = parse(IPv6Net, str)
# ip"2001::1", 64
IPv6Net(netaddr::IPv6, prefix::Integer=128) = IPv6Net(netaddr.host, to_mask(UInt128(prefix)))

#############
## Parsing ##
#############
Base.parse(::Type{T}, str::AbstractString) where T <:IPNet = parse(T, String(str))
Base.parse(::Type{IPv4Net}, str::String) = IPv4Net(_parsenet(str, UInt32, IPv4)...)
Base.parse(::Type{IPv6Net}, str::String) = IPv6Net(_parsenet(str, UInt128, IPv6)...)
function _parsenet(str::String, ::Type{IT}, ::Type{IPT}) where {IT, IPT}
    nbits = IT(8 * sizeof(IT))
    parts = split(str, '/')
    if length(parts) == 1
        netaddr, nmaskbits = parts[1], nbits
    elseif length(parts) == 2
        netaddr, maskbits = parts
        nmaskbits = parse(IT, maskbits)
    else
        throw(ArgumentError("malformed IPNet input: $str"))
    end
    netaddr = parse(IPT, netaddr).host
    netmask = to_mask(nmaskbits)
    return netaddr, netmask
end

##############
## Printing ##
##############

Base.print(io::IO, net::IPNet) =
    print(io, eltype(net)(net.netaddr), "/", count_ones(net.netmask))
Base.show(io::IO, net::T) where T <: IPNet = print(io, T, "(\"", net, "\")")

###########################
## IPNets as collections ##
###########################

Base.in(ip::IPv4, network::IPv4Net) = ip.host & network.netmask == network.netaddr
Base.in(ip::IPv6, network::IPv6Net) = ip.host & network.netmask == network.netaddr

# IP Networks are ordered first by starting network address
# and then by network mask. That is, smaller IP nets (with higher
# netmask values) are "less" than larger ones. This corresponds
# to secondary reordering by ending address.
Base.isless(a::T, b::T) where T <: IPNet = a.netaddr == b.netaddr ?
        isless(count_ones(a.netmask), count_ones(b.netmask)) :
        isless(a.netaddr, b.netaddr)

Base.iterate(net::IPNet, state = inttype(net)(0)) =
    state >= length(net) ? nothing : (net[state], state + 0x1)

Base.eltype(::Type{IPv4Net}) = IPv4
Base.eltype(::Type{IPv6Net}) = IPv6
Base.firstindex(net::IPNet) = inttype(net)(0)
Base.lastindex(net::IPNet) = typemax(inttype(net)) >> (count_ones(net.netmask))

Base.length(net::IPv4Net)= Int64(lastindex(net) - firstindex(net)) + 1
Base.length(net::IPv6Net)= BigInt(lastindex(net) - firstindex(net)) + 1

function Base.getindex(net::IPNet, i::Integer)
    fi, li = firstindex(net), lastindex(net)
    fi <= i <= li  || throw(BoundsError(net, i))
    i = i % typeof(fi)
    r = eltype(net)(net.netaddr + i)
    return r
end
Base.getindex(net::IPNet, idxs::AbstractVector{<:Integer}) = [net[i] for i in idxs]

######################
## Internal utility ##
######################
function to_mask(nmaskbits::IT) where IT
    nbits = IT(8 * sizeof(IT))
    if !(0 <= nmaskbits <= nbits)
        throw(ArgumentError("network mask bits must be between 0 and $(nbits), got $(nmaskbits)"))
    end
    return typemax(IT) << (nbits - IT(nmaskbits)) & typemax(IT)
end
inttype(::IPv4Net) = UInt32
inttype(::IPv6Net) = UInt128

end # module
