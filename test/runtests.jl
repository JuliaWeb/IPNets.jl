using IPNets, Test, Sockets

@testset "IPNets" begin
    #############
    ## IPv4Net ##
    #############

    ## Constructors
    @test IPv4Net("1.2.3.4") == parse(IPv4Net, "1.2.3.4") ==
          IPv4Net("1.2.3.4/32") == parse(IPv4Net, "1.2.3.4/32") ==
          IPv4Net(ip"1.2.3.4") == IPv4Net(ip"1.2.3.4", 32) ==
          IPv4Net(ip"1.2.3.4", ip"255.255.255.255") ==
          IPNet("1.2.3.4") == IPNet("1.2.3.4/32") ==
          parse(IPv4Net, SubString("1.2.3.4")) ==
          parse(IPNet, "1.2.3.4") == parse(IPNet, "1.2.3.4/32") ==
          IPv4Net(0x01020304, typemax(UInt32))
    @test IPv4Net("1.2.3.0/24") == parse(IPv4Net, "1.2.3.0/24") ==
          IPv4Net(ip"1.2.3.0", ip"255.255.255.0") ==
          IPv4Net(ip"1.2.3.0", 24) == parse(IPNet, "1.2.3.0/24") ==
          IPv4Net(0x01020300, typemax(UInt32) << 8)

    err = ArgumentError("network mask bits must be between 0 and 32, got 33")
    @test_throws err IPv4Net("1.2.3.4/33")
    @test_throws err IPv4Net(ip"1.2.3.4", 33)
    err = ArgumentError("non-contiguous IPv4 subnets not supported, got 255.240.255.0")
    @test_throws err IPv4Net(ip"1.2.3.0", ip"255.240.255.0")
    err = ArgumentError("input 1.2.3.4/24 has host bits set")
    @test_throws err IPv4Net("1.2.3.4/24")
    @test_throws err parse(IPv4Net, "1.2.3.4/24")
    @test_throws err IPv4Net(ip"1.2.3.4", 24)
    @test_throws err parse(IPNet, "1.2.3.4/24")
    err = ArgumentError("malformed IPNet input: 1.2.3.4/32/32")
    @test_throws err IPv4Net("1.2.3.4/32/32")

    ## Print
    ipnet = IPv4Net("1.2.3.0/24")
    @test sprint(print, ipnet) == "1.2.3.0/24"
    @test sprint(show, ipnet) == "IPv4Net(\"1.2.3.0/24\")"


    ## IPNet as collection
    ipnet = IPv4Net("1.2.3.0/24")

    @test ip"1.2.3.4" in ipnet
    @test ip"1.2.3.0" in ipnet
    @test ip"1.2.3.255" in ipnet
    @test !(ip"1.2.4.0" in ipnet)

    @test IPv4Net("1.2.3.4/32") == IPv4Net("1.2.3.4/32")
    @test IPv4Net("1.2.3.0/24") == IPv4Net("1.2.3.0/24")
    @test IPv4Net("1.2.3.4/32") != IPv4Net("1.2.3.4/31")
    @test IPv4Net("1.2.3.4/31") < IPv4Net("1.2.3.4/32")
    @test IPv4Net("1.2.3.4/32") > IPv4Net("1.2.3.4/31")
    @test IPv4Net("1.2.3.0/24") < IPv4Net("1.2.4.0/24")
    @test IPv4Net("1.2.4.0/24") > IPv4Net("1.2.3.0/24")
    nets = map(IPv4Net, ["1.2.3.0/24", "1.2.3.4/31", "1.2.3.4/32", "1.2.4.0/24"])
    @test sort(nets) == nets

    @test length(ipnet) == length(collect(ipnet)) == 256
    @test collect(ipnet) == [x for x in ipnet]
    @test length(IPv4Net("0.0.0.0/0"))::Int64 == Int64(1) << 32
    @test ipnet[0] == #= ipnet[begin] == =# ip"1.2.3.0" # TODO: Requires Julia 1.4
    @test ipnet[1] == ip"1.2.3.1"
    @test ipnet[255] == ipnet[end] == ip"1.2.3.255"
    @test ipnet[0:1] == ipnet[[0, 1]] == [ip"1.2.3.0", ip"1.2.3.1"]
    @test_throws BoundsError ipnet[-1]
    @test_throws BoundsError ipnet[256]
    @test_throws BoundsError ipnet[-1:2]


    #############
    ## IPv6Net ##
    #############

    ## Constructors
    @test IPv6Net("1:2::3:4") == parse(IPv6Net, "1:2::3:4") ==
          IPv6Net("1:2::3:4/128") == parse(IPv6Net, "1:2::3:4/128") ==
          IPv6Net(ip"1:2::3:4") == IPv6Net(ip"1:2::3:4", 128) ==
          parse(IPv6Net, SubString("1:2::3:4")) ==
          parse(IPNet, "1:2::3:4") == parse(IPNet, "1:2::3:4/128") ==
          IPv6Net(0x00010002000000000000000000030004, typemax(UInt128))
    @test IPv6Net("1:2::3:0/112") == parse(IPv6Net, "1:2::3:0/112") ==
          IPv6Net(ip"1:2::3:0", 112) == parse(IPNet, "1:2::3:0/112") ==
          IPv6Net(0x00010002000000000000000000030000, typemax(UInt128) << 16)

    err = ArgumentError("network mask bits must be between 0 and 128, got 129")
    @test_throws err IPv6Net("1:2::3:4/129")
    @test_throws err IPv6Net(ip"1:2::3:4", 129)
    err = ArgumentError("input 1:2::3:4/112 has host bits set")
    @test_throws err IPv6Net("1:2::3:4/112")
    @test_throws err parse(IPv6Net, "1:2::3:4/112")
    @test_throws err IPv6Net(ip"1:2::3:4", 112)
    @test_throws err parse(IPNet, "1:2::3:4/112")
    err = ArgumentError("malformed IPNet input: 1:2::3:4/32/32")
    @test_throws err IPv6Net("1:2::3:4/32/32")

    ## Print
    ipnet = IPv6Net("1:2::3:0/112")
    @test sprint(print, ipnet) == "1:2::3:0/112"
    @test sprint(show, ipnet) == "IPv6Net(\"1:2::3:0/112\")"


    ## IPNet as collection
    ipnet = IPv6Net("1:2::3:0/112")

    @test ip"1:2::3:4" in ipnet
    @test ip"1:2::3:0" in ipnet
    @test ip"1:2::3:ffff" in ipnet
    @test !(ip"1:2::4:0" in ipnet)

    @test IPv6Net("1:2::3:4/128") == IPv6Net("1:2::3:4/128")
    @test IPv6Net("1:2::3:0/112") == IPv6Net("1:2::3:0/112")
    @test IPv6Net("1:2::3:4/128") != IPv6Net("1:2::3:4/127")
    @test IPv6Net("1:2::3:4/127") < IPv6Net("1:2::3:4/128")
    @test IPv6Net("1:2::3:4/128") > IPv6Net("1:2::3:4/127")
    @test IPv6Net("1:2::3:0/112") < IPv6Net("1:2::4:0/112")
    @test IPv6Net("1:2::4:0/112") > IPv6Net("1:2::3:0/112")
    nets = map(IPv6Net, ["1:2::3:0/112", "1:2::3:4/127", "1:2::3:4/128", "1:2::4:0/112"])
    @test sort(nets) == nets

    @test length(ipnet) == length(collect(ipnet)) == 65536
    @test collect(ipnet)::Vector{IPv6} == [x for x in ipnet]
    @test length(IPv6Net("::/0"))::BigInt == BigInt(1) << 128
    @test ipnet[0] == #= ipnet[begin] == =# ip"1:2::3:0" # TODO: Requires Julia 1.4
    @test ipnet[1] == ip"1:2::3:1"
    @test ipnet[65535] == ipnet[end] == ip"1:2::3:ffff"
    @test ipnet[0:1] == ipnet[[0, 1]] == [ip"1:2::3:0", ip"1:2::3:1"]
    @test_throws BoundsError ipnet[-1]
    @test_throws BoundsError ipnet[65536]
    @test_throws BoundsError ipnet[-1:2]
end
