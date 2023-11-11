from random import random_si64
import benchmark


fn main():
    alias loops: Int = 10000
    let r1: Int = random_si64(9,11).value
    let r2: Int = random_si64(9,11).value
    let r3: Int = random_si64(9,11).value
    #         very inclusive (9,11)


    @parameter
    fn direct1_test():
        @unroll(100)
        for i in range(loops):
            benchmark.keep(direct1(r1))

    @parameter
    fn tuple1_test():
        @unroll(100)
        for i in range(loops):
            benchmark.keep(tuple1(Float64(r1)))

    @parameter
    fn direct2_test():
        @unroll(100)
        for i in range(loops):
            benchmark.keep(direct2(r1, r2))

    @parameter
    fn tuple2_test():
        @unroll(100)
        for i in range(loops):
            benchmark.keep(tuple2((Float64(r1), Float64(r2))))

    @parameter
    fn variad2_test():
        @unroll(100)
        for i in range(loops):
            benchmark.keep(variad(r1, r2))

    @parameter
    fn direct3_test():
        @unroll(100)
        for i in range(loops):
            benchmark.keep(direct3(r1, r2, r3))

    @parameter
    fn tuple3_test():
        @unroll(100)
        for i in range(loops):
            benchmark.keep(tuple3((Float64(r1), Float64(r2), Float64(r3))))

    @parameter
    fn variad3_test():
        @unroll(100)
        for i in range(loops):
            benchmark.keep(variad(r1, r2, r3))

    print()
    print("#------ 1 ------#")
    print("direct :", benchmark.run[direct1_test]().mean["ns"]())
    print("tuple  :", benchmark.run[tuple1_test]().mean["ns"]())
    print()
    print()
    print("#------ 2 ------#")
    print("direct :", benchmark.run[direct2_test]().mean["ns"]())
    print("tuple  :", benchmark.run[tuple2_test]().mean["ns"]())
    print("variad :", benchmark.run[variad2_test]().mean["ns"]())
    print()
    print()
    print("#------ 3 ------#")
    print("direct :", benchmark.run[direct3_test]().mean["ns"]())
    print("tuple  :", benchmark.run[tuple3_test]().mean["ns"]())
    print("variad :", benchmark.run[variad3_test]().mean["ns"]())
    print()




fn direct1(a: Float64) -> Float64:
    return a

fn tuple1(a: Tuple[Float64]) -> Float64:
    return a.get[0,Float64]()

fn direct2(a1: Float64, a2: Float64) -> Float64:
    benchmark.keep(a2)
    return a1

fn tuple2(a: Tuple[Float64, Float64]) -> Float64:
    benchmark.keep(a.get[1,Float64]())
    return a.get[0,Float64]()

fn direct3(a1: Float64, a2: Float64, a3: Float64) -> Float64:
    benchmark.keep(a2)
    benchmark.keep(a3)
    return a1

fn tuple3(a: Tuple[Float64, Float64, Float64]) -> Float64:
    benchmark.keep(a.get[1,Float64]())
    benchmark.keep(a.get[2,Float64]())
    return a.get[0,Float64]()

fn variad(*a: Float64) -> Float64:
    for i in range(1,len(a)): benchmark.keep(a[i])
    return a[0]