import benchmark

fn main():
    from random import random_si64
    loops = random_si64(98,102).value

    print()
    print("direct   :", benchmark.run[direct_test]().mean["ns"]())
    print()
    print("indirect :", benchmark.run[indirect_test]().mean["ns"]())
    print()
    print("direct   :", benchmark.run[direct_test]().mean["ns"]())
    print()
    print("indirect :", benchmark.run[indirect_test]().mean["ns"]())
    print()


var loops: Int = 100

fn direct_test():
    var a: Float64 = 0
    for i in range(loops): a += direct(5)
    benchmark.keep(a)

fn indirect_test():
    var a: Float64 = 0
    for i in range(loops): a += indirect(Float64(5))
    benchmark.keep(a)

fn direct(a: Float64) -> Float64:
    return a*a*a*a

fn indirect(a: Tuple[Float64]) -> Float64:
    return a.get[0,Float64]()*a.get[0,Float64]()*a.get[0,Float64]()*a.get[0,Float64]()