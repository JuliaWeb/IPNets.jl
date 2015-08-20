using IPNets
using Base.Test
using Compat

ip41 = IPv4("1.2.3.4")
ip42 = IPv4("5.6.7.8")

n1 = IPv4Net("1.2.3.0/24")
n2 = IPv4Net("1.2.3.4/24")
n3 = IPv4Net("1.2.3.4/26")
n4 = IPv4Net("5.6.7.0/24")
n5 = IPv4Net("1.2.3.4/30")

ip61 = IPv6("2001:1::4")
ip62 = IPv6("2001:2::8")

o1 = IPv6Net("2001:1::/64")
o2 = IPv6Net("2001:1::4/64")
o3 = IPv6Net("2001:1::4/68")
o4 = IPv6Net("2001:2::8/64")
o5 = IPv6Net("2001:1::4/126")

# ipv4
@test_throws ErrorException IPv4Net(ip41, 33)
@test IPv4Net("1.2.3.4", "255.255.255.0") == n1
@test IPv4Net("1.2.3.4", 24) == n1
@test IPv4Net(16909060,24) == n1
@test IPv4Net((16909060,24)) == n1

@test IPv4Net("1.2.3.4") == IPv4Net("1.2.3.4/32")
@test n1 == n2

@test isless(n1,n3) == false
@test isless(n1,n4) == true

@test n1[5] == ip41
@test isless(ip41, ip42) == true
@test in(ip42, n4) == true
@test_throws ErrorException ip42 in o4
@test contains(n4, ip42) == true
@test issubset(n3, n2) == true
@test issubset(n1, n2) == true

@test IPNets._contiguousbitcount(240,UInt8) == 0x04
@test IPNets._contiguousbitcount(252,UInt8) == 0x06
@test_throws ErrorException IPNets._contiguousbitcount(241,UInt8)

@test endswith(string(n5),"(\"1.2.3.4/30\")") == true
@test endswith(sprint(print,n5),"(\"1.2.3.4/30\")") == true
@test endswith(sprint(show,n5),"(\"1.2.3.4/30\")") == true
@test endswith(string(display,n5),"(\"1.2.3.4/30\")") == true
@test size(n5) == (4,)
@test [x for x in n5] == [ip"1.2.3.4", ip"1.2.3.5", ip"1.2.3.6", ip"1.2.3.7"]
@test endof(n5) == 4
@test minimum(n5) == ip"1.2.3.4"
@test maximum(n5) == ip"1.2.3.7"
@test extrema(n5) == (ip"1.2.3.4",ip"1.2.3.7")
@test getindex(n5,1:2) == [ip"1.2.3.4", ip"1.2.3.5"]
# @test getindex(n5,(1,)) == ip41
@test_throws BoundsError getindex(n5, 10)
@test IPNets.width(IPv4) == 32
@test_throws BoundsError IPNets._mask2bits(IPv4, @compat(UInt64(33)))



# IPv6
@test_throws ErrorException IPv6Net(ip61, 129)
@test IPv6Net("2001:1::", 64) == o1
@test IPv6Net(0x20010001000000000000000000000004,64) == o1
@test IPv6Net((0x20010001000000000000000000000004,64)) == o1
@test o1 == o2

@test IPv6Net("2001:1::1") == IPv6Net("2001:1::1/128")
@test isless(o1,o3) == false
@test isless(o1,o4) == true

@test o1[5] == ip61
@test isless(ip61, ip62) == true
@test in(ip62, o4) == true
@test_throws ErrorException ip62 in n4
@test contains(o4, ip62) == true


@test endswith(string(o5),"(\"2001:1::4/126\")") == true
@test endswith(sprint(print,o5),"(\"2001:1::4/126\")") == true
@test endswith(sprint(show,o5),"(\"2001:1::4/126\")") == true
@test endswith(string(display,o5),"(\"2001:1::4/126\")") == true
@test size(o5) == (4,)
@test [x for x in o5] == [ip"2001:1::4",ip"2001:1::5",ip"2001:1::6",ip"2001:1::7"]
@test endof(o5) == 4
@test minimum(o5) == ip"2001:1::4"
@test maximum(o5) == ip"2001:1::7"
@test extrema(o5) == (ip"2001:1::4",ip"2001:1::7")
@test getindex(o5,1:2) == [ip"2001:1::4", ip"2001:1::5"]
# @test getindex(o5,(1,)) == ip61
@test_throws BoundsError getindex(o5, 10)
@test IPNets.width(IPv6) == 128

@test_throws BoundsError IPNets._mask2bits(IPv6, @compat(UInt64(129)))
