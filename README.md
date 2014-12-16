## IPNets.jl
[![Build Status](https://travis-ci.org/sbromberger/IPNets.jl.svg?branch=master)](https://travis-ci.org/sbromberger/IPNets.jl)



*IPNets.jl* is a Julia package that provides IP network types. Both IPv4 and IPv6
networks can be described using *IPNets.jl* using standard, intuitive syntax.


### Main Features

An important aspect of *IPNets.jl* is the ability to treat IP networks as
vectors. That is, common vector operations such as membership testing and
indexing are fully supported with IPNet types. The following examples should help clarify:

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

*alternate construction and comparison*
```
julia> newnet = IPv4Net("1.2.4.0", 24)
IPv4Net("1.2.4.0/24")

julia> ip4net < newnet
true
```
Though these examples use the `IPv4Net` type, the `IPv6Net` type is also available with similar behavior.
