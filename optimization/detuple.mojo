import benchmark

fn main():
    from random import random_si64
    let loops: Int = random_si64(9998,10002).value
    let v1: Int = random_si64(10,20).value
    let v2: Int = random_si64(10,20).value

    @parameter
    fn direct1_test():
        var a: Float64 = 0
        for i in range(loops): a += direct1(v1)
        benchmark.keep(a)

    @parameter
    fn tuple1_test():
        var a: Float64 = 0
        for i in range(loops): a += tuple1(Float64(v1))
        benchmark.keep(a)

    @parameter
    fn direct2_test():
        var a: Float64 = 0
        for i in range(loops): a += direct2(v1, v2)
        benchmark.keep(a)

    @parameter
    fn tuple2_test():
        var a: Float64 = 0
        for i in range(loops): a += tuple2((Float64(v1), Float64(v2)))
        benchmark.keep(a)

    @parameter
    fn variad2_test():
        var a: Float64 = 0
        for i in range(loops): a += variad(v1, v2)
        benchmark.keep(a)

    print("\n#--- 1 ---#")
    print("direct :", benchmark.run[direct1_test]().mean["ns"]())
    print("tuple  :", benchmark.run[tuple1_test]().mean["ns"]())
    print("direct :", benchmark.run[direct1_test]().mean["ns"]())
    print("tuple  :", benchmark.run[tuple1_test]().mean["ns"]())
    print()

    print("\n#--- 2 ---#")
    print("direct :", benchmark.run[direct2_test]().mean["ns"]())
    print("tuple  :", benchmark.run[tuple2_test]().mean["ns"]())
    print("variad :", benchmark.run[variad2_test]().mean["ns"]())
    print("direct :", benchmark.run[direct2_test]().mean["ns"]())
    print("tuple  :", benchmark.run[tuple2_test]().mean["ns"]())
    print("variad :", benchmark.run[variad2_test]().mean["ns"]())
    print()




fn direct1(a: Float64) -> Float64:
    return a+a

fn tuple1(a: Tuple[Float64]) -> Float64:
    return a.get[0,Float64]()+a.get[0,Float64]()

fn direct2(a1: Float64, a2: Float64) -> Float64:
    return a1+a2

fn tuple2(a: Tuple[Float64, Float64]) -> Float64:
    return a.get[0,Float64]()+a.get[1,Float64]()

fn variad(*a: Float64) -> Float64:
    var result: Float64 = a[0] # <- slower if start with 0
    for i in range(1,len(a)): result += a[i]
    return result