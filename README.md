## IPNets.jl
[![CI](https://github.com/JuliaWeb/IPNets.jl/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/JuliaWeb/IPNets.jl/actions/workflows/ci.yml)
[![codecov.io](http://codecov.io/github/JuliaWeb/IPNets.jl/coverage.svg?branch=master)](http://codecov.io/github/JuliaWeb/IPNets.jl?branch=master)


*IPNets.jl* is a Julia package that provides IP network types. Both IPv4 and IPv6
networks can be described with *IPNets.jl* using standard, intuitive syntax.


### Main Features

An important aspect of *IPNets.jl* is the ability to treat IP networks as
collections while not actually allocating the memory required to store a full
range of addresses. Operations such as membership testing, indexing and iteration
are supported with `IPNet` types. The following examples should
help clarify.

Constructors:
```julia
julia> using IPNets, Sockets

julia> IPv4Net("1.2.3.0/24") # string in CIDR notation
IPv4Net("1.2.3.0/24")

julia> parse(IPv4Net, "1.2.3.0/24") # same as above
IPv4Net("1.2.3.0/24")

julia> IPv4Net(ip"1.2.3.0", 24) # IPv4 and mask as number of bits
IPv4Net("1.2.3.0/24")

julia> IPv4Net(ip"1.2.3.0", ip"255.255.255.0") # IPv4 and mask as another IPv4
IPv4Net("1.2.3.0/24")

julia> IPv4Net("1.2.3.4") # 32 bit mask default
IPv4Net("1.2.3.4/32")
```

Membership test:
```julia
julia> ip4net = IPv4Net("1.2.3.0/24");

julia> ip"1.2.3.4" in ip4net
true

julia> ip"1.2.4.1" in ip4net
false
```

Length, indexing, and iteration:
```julia
julia> ip4net = IPv4Net("1.2.3.0/24");

julia> length(ip4net)
256

julia> ip4net[0] # index from 0 (!)
ip"1.2.3.0"

julia> ip4net[0xff]
ip"1.2.3.255"

julia> ip4net[4:8]
5-element Vector{IPv4}:
 ip"1.2.3.4"
 ip"1.2.3.5"
 ip"1.2.3.6"
 ip"1.2.3.7"
 ip"1.2.3.8"

julia> for ip in ip4net
           @show ip
       end
ip = ip"1.2.3.0"
ip = ip"1.2.3.1"
[...]
ip = ip"1.2.3.255"
```

Though these examples use the `IPv4Net` type, the `IPv6Net` type is also available with similar behavior:
```julia
julia> IPv6Net("1:2::/64") # string in CIDR notation
IPv6Net("1:2::/64")

julia> parse(IPv6Net, "1:2::/64") # same as above
IPv6Net("1:2::/64")

julia> IPv6Net(ip"1:2::", 64) # IPv6 and prefix
IPv6Net("1:2::/64")

julia> IPv6Net("1:2::3:4") # 128 bit mask default
IPv6Net("1:2::3:4/128")
```


For unknown (string) input use the `IPNet` supertype constructor (or `parse`):
```julia
julia> IPNet("1.2.3.0/24")
IPv4Net("1.2.3.0/24")

julia> parse(IPNet, "1.2.3.4")
IPv4Net("1.2.3.4/32")

julia> IPNet("1:2::3:4")
IPv6Net("1:2::3:4/128")

julia> parse(IPNet, "1:2::/64")
IPv6Net("1:2::/64")
```


### Limitations
- Non-contiguous subnetting for IPv4 addresses (e.g., a netmask of "255.240.255.0")
is not supported. Subnets must be able to be represented as a series of contiguous mask bits.
