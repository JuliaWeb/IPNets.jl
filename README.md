## IPNets.jl
[![Build Status](https://travis-ci.org/JuliaWeb/IPNets.jl.svg?branch=master)](https://travis-ci.org/JuliaWeb/IPNets.jl)
[![codecov.io](http://codecov.io/github/JuliaWeb/IPNets.jl/coverage.svg?branch=master)](http://codecov.io/github/JuliaWeb/IPNets.jl?branch=master)

[![IPNets](http://pkg.julialang.org/badges/IPNets_0.3.svg)](http://pkg.julialang.org/?pkg=IPNets)
[![IPNets](http://pkg.julialang.org/badges/IPNets_0.4.svg)](http://pkg.julialang.org/?pkg=IPNets&ver=0.4)
[![IPNets](http://pkg.julialang.org/badges/IPNets_0.5.svg)](http://pkg.julialang.org/?pkg=IPNets)
[![IPNets](http://pkg.julialang.org/badges/IPNets_0.6.svg)](http://pkg.julialang.org/?pkg=IPNets)

*IPNets.jl* is a Julia package that provides IP network types. Both IPv4 and IPv6
networks can be described with *IPNets.jl* using standard, intuitive syntax.


### Main Features

An important aspect of *IPNets.jl* is the ability to treat IP networks as
vectors while not actually allocating the memory required to store a full
range of addresses. Common vector operations such as membership testing and
indexing are fully supported with `IPNet` types. The following examples should
help clarify:

*create a network with 24-bit netmask*
```
julia> using IPNets

julia> ip4 = IPv4("1.2.3.4")            # create a standard IPv4 address
ip"1.2.3.4"

julia> ip4net = IPv4Net("1.2.3.0/24")
IPv4Net("1.2.3.0/24")

```
*membership tests*
```
julia> ip4 in ip4net
true
```

*length, indexing, and iteration*
```
julia> length(ip4net)
256

julia> ip4net[5]
ip"1.2.3.4"

julia> ip4net[4:8]
5-element Array{IPv4,1}:
 ip"1.2.3.3"
 ip"1.2.3.4"
 ip"1.2.3.5"
 ip"1.2.3.6"
 ip"1.2.3.7"

 julia> [x for x in ip4net[1:4]]
4-element Array{Any,1}:
 ip"1.2.3.0"
 ip"1.2.3.1"
 ip"1.2.3.2"
 ip"1.2.3.3"

julia> [x for x in ip4net][1:4]
4-element Array{Any,1}:
 ip"1.2.3.0"
 ip"1.2.3.1"
 ip"1.2.3.2"
 ip"1.2.3.3"
```

*equality*
```
julia> ip4net[5] == ip4
true
```

*minima / maxima*
```
julia> ip4net[end]
ip"1.2.3.255"

julia> extrema(ip4net)
(ip"1.2.3.0",ip"1.2.3.255")
```

*alternate construction and subset comparison*
```
julia> newnet = IPv4Net("1.2.3.16", "255.255.255.240")
IPv4Net("1.2.3.16/28")

julia> newnet ⊆ ip4net
true
```

*memory usage is minimal (476 bytes to represent the entire IPv4 address space)*
```
julia> @time a = IPv4Net("0.0.0.0/0")
elapsed time: 1.3325e-5 seconds (476 bytes allocated)
IPNets.IPv4Net("0.0.0.0/0")

julia> size(a)
(4294967296,)
```

Though these examples use the `IPv4Net` type, the `IPv6Net` type is also available with similar behavior.

###Known Issues
- Extrema measurements for `IPNets` representing the entire IPv4 or IPv6 address
space will fail due to overrun of the native type used to describe the networks.
- Non-contiguous subnetting for IPv4 addresses (e.g., a netmask of "255.240.255.0")
is not supported. Subnets must be able to be represented as a series of contiguous mask bits.
