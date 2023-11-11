import benchmark


fn main():
    from random import random_si64
    let loops: Int = random_si64(9998,10002).value
    let v1: Int = random_si64(10,20).value
    let v2: Int = random_si64(10,20).value
    let v3: Int = random_si64(10,20).value

    @parameter
    fn direct1_test():
        for i in range(loops):
            benchmark.keep(direct1(v1))

    @parameter
    fn tuple1_test():
        for i in range(loops):
            benchmark.keep(tuple1(Float64(v1)))

    @parameter
    fn direct2_test():
        for i in range(loops):
            benchmark.keep(direct2(v1, v2))

    @parameter
    fn tuple2_test():
        for i in range(loops):
            benchmark.keep(tuple2((Float64(v1), Float64(v2))))

    @parameter
    fn variad2_test():
        for i in range(loops):
            benchmark.keep(variad(v1, v2))

    @parameter
    fn direct3_test():
        for i in range(loops):
            benchmark.keep(direct3(v1, v2, v3))

    @parameter
    fn tuple3_test():
        for i in range(loops):
            benchmark.keep(tuple3((Float64(v1), Float64(v2), Float64(v3))))

    @parameter
    fn variad3_test():
        for i in range(loops):
            benchmark.keep(variad(v1, v2, v3))

    print()
    print("#--- 1 ---#")
    print("direct :", benchmark.run[direct1_test]().mean["ns"]())
    print("tuple  :", benchmark.run[tuple1_test]().mean["ns"]())
    print("direct :", benchmark.run[direct1_test]().mean["ns"]())
    print("tuple  :", benchmark.run[tuple1_test]().mean["ns"]())
    print()
    print()
    print("#--- 2 ---#")
    print("direct :", benchmark.run[direct2_test]().mean["ns"]())
    print("tuple  :", benchmark.run[tuple2_test]().mean["ns"]())
    print("variad :", benchmark.run[variad2_test]().mean["ns"]())
    print("direct :", benchmark.run[direct2_test]().mean["ns"]())
    print("tuple  :", benchmark.run[tuple2_test]().mean["ns"]())
    print("variad :", benchmark.run[variad2_test]().mean["ns"]())
    print()
    print()
    print("#--- 3 ---#")
    print("direct :", benchmark.run[direct3_test]().mean["ns"]())
    print("tuple  :", benchmark.run[tuple3_test]().mean["ns"]())
    print("variad :", benchmark.run[variad3_test]().mean["ns"]())
    print("direct :", benchmark.run[direct3_test]().mean["ns"]())
    print("tuple  :", benchmark.run[tuple3_test]().mean["ns"]())
    print("variad :", benchmark.run[variad3_test]().mean["ns"]())
    print()




fn direct1(a: Float64) -> Float64:
    benchmark.keep(a)
    return a

fn tuple1(a: Tuple[Float64]) -> Float64:
    benchmark.keep(a.get[0,Float64]())
    return a.get[0,Float64]()

fn direct2(a1: Float64, a2: Float64) -> Float64:
    benchmark.keep(a1)
    benchmark.keep(a2)
    return a1

fn tuple2(a: Tuple[Float64, Float64]) -> Float64:
    benchmark.keep(a.get[0,Float64]())
    benchmark.keep(a.get[1,Float64]())
    return a.get[0,Float64]()

fn direct3(a1: Float64, a2: Float64, a3: Float64) -> Float64:
    benchmark.keep(a1)
    benchmark.keep(a2)
    benchmark.keep(a3)
    return a1

fn tuple3(a: Tuple[Float64, Float64, Float64]) -> Float64:
    benchmark.keep(a.get[0,Float64]())
    benchmark.keep(a.get[1,Float64]())
    benchmark.keep(a.get[2,Float64]())
    return a.get[0,Float64]()

fn variad(*a: Float64) -> Float64:
    benchmark.keep(a[0])
    for i in range(1,len(a)): benchmark.keep(a[i])
    return a[0]