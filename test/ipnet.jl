using IPNets
using Base.Test

# IPv4

ip41 = IPv4("1.2.3.4")
ip42 = IPv4("5.6.7.8")

n1 = IPv4Net("1.2.3.0/24")
n2 = IPv4Net("1.2.3.4/24")
n3 = IPv4Net("1.2.3.4/26")
n4 = IPv4Net("5.6.7.0/24")

@test IPv4Net("1.2.3.4", "255.255.255.0") == n1
@test IPv4Net("1.2.3.4", 24) == n1
@test n1 == n2

@test isless(n1,n3) == true
@test isless(n1,n4) == true

@test n1[5] == ip1
@test isless(ip41,ip42) == true
@test in(ip42, n4) == true
@test contains(n4,ip42) == true

@test IPNets.contiguousbitcount(240,UInt8) == 0x04
@test IPNets.contiguousbitcount(252,UInt8) == 0x06
@test_throws ErrorException IPNets.contiguousbitcount(240,UInt8)


# IPv6
ip61 = IPv6("2001:1::4")
ip62 = IPv6("2001:2::8")

o1 = IPv6Net("2001:1::/64")
o2 = IPv6Net("2001:1::4/64")
o3 = IPv6Net("2001:1::4/68")
o4 = IPv6Net("2001:2::8/64")

@test IPv6Net("2001:1::", 64) == o1
@test o1 == o2

@test isless(o1,o3) == true
@test isless(o1,o4) == true

@test o1[5] == ip61
@test isless(ip61, ip62) == true
@test in(ip62, o4) == true
@test contains(o4, ip62) == true
