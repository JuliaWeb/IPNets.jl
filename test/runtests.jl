tests = [
    "ipnet" ]

for t in tests
    tp = joinpath(Pkg.dir("IPNets"),"test","$(t).jl")
    println("running $(tp) ...")
    include(tp)
end
