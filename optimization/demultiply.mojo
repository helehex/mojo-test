import benchmark


fn main():
    from random import random_si64
    loops = random_si64(98,102).value

    print("\n#---  -1  ---#")
    print("auto   : ", benchmark.run[auto[DType.index,-1]]().mean["ns"]())
    print("manual : ", benchmark.run[manual_negate]().mean["ns"](),)
    print("\n#---  0  ---#")
    print("auto   : ", benchmark.run[auto[DType.index,0]]().mean["ns"]())
    print("manual : ", benchmark.run[manual_zero]().mean["ns"]())
    print("\n#---  1  ---#")
    print("auto   : ", benchmark.run[auto[DType.index,1]]().mean["ns"]())
    print("manual : ", benchmark.run[manual_one]().mean["ns"]())
    print("\n#---  2  ---#")
    print("auto   : ", benchmark.run[auto[DType.index,2]]().mean["ns"]())
    print("manual : ", benchmark.run[manual_two]().mean["ns"]())
    print("\n\n")
        
    print("\n#---  -1.0  ---#")
    print("auto   : ", benchmark.run[auto[DType.float64,-1]]().mean["ns"]())
    print("manual : ", benchmark.run[manual_negate_f]().mean["ns"]())
    print("\n#---  0.0  ---#")
    print("auto   : ", benchmark.run[auto[DType.float64,0]]().mean["ns"]())
    print("manual : ", benchmark.run[manual_zero_f]().mean["ns"]())
    print("\n#---  1.0  ---#")
    print("auto   : ", benchmark.run[auto[DType.float64,1]]().mean["ns"]())
    print("manual : ", benchmark.run[manual_one_f]().mean["ns"]())
    print("\n#---  2.0  ---#")
    print("auto   : ", benchmark.run[auto[DType.float64,2]]().mean["ns"]())
    print("manual : ", benchmark.run[manual_two_f]().mean["ns"]())
    print("\n")




var loops: Int = 100

fn auto[dt: DType, m: Int]():
    for u in range(loops):
        var o: Auto[dt, m] = Auto[dt, m](1,1)
        for i in range(loops): o = o + Auto[dt, m](i,u)
        benchmark.keep(o)

fn manual_negate():
    for u in range(loops):
        var o: ManualNegate = ManualNegate(1,1)
        for i in range(loops): o = o + ManualNegate(i,u)
        benchmark.keep(o)

fn manual_zero():
    for u in range(loops):
        var o: ManualZero = ManualZero(1,1)
        for i in range(loops): o = o + ManualZero(i,u)
        benchmark.keep(o)

fn manual_one():
    for u in range(loops):
        var o: ManualOne = ManualOne(1,1)
        for i in range(loops): o = o + ManualOne(i,u)
        benchmark.keep(o)

fn manual_two():
    for u in range(loops):
        var o: ManualTwo = ManualTwo(1,1)
        for i in range(loops): o = o + ManualTwo(i,u)
        benchmark.keep(o)

fn manual_negate_f():
    for u in range(loops):
        var o: ManualNegateF = ManualNegateF(1,1)
        for i in range(loops): o = o + ManualNegateF(i,u)
        benchmark.keep(o)

fn manual_zero_f():
    for u in range(loops):
        var o: ManualZeroF = ManualZeroF(1,1)
        for i in range(loops): o = o + ManualZeroF(i,u)
        benchmark.keep(o)

fn manual_one_f():
    for u in range(loops):
        var o: ManualOneF = ManualOneF(1,1)
        for i in range(loops): o = o + ManualOneF(i,u)
        benchmark.keep(o)

fn manual_two_f():
    for u in range(loops):
        var o: ManualTwoF = ManualTwoF(1,1)
        for i in range(loops): o = o + ManualTwoF(i,u)
        benchmark.keep(o)


@value
struct Auto[dt: DType, m: Int]:
    var v1: SIMD[dt,1]
    var v2: SIMD[dt,1]
    fn __add__(self, other: Self) -> Self:
        return Self(self.v1 + other.v1, m*(self.v2 + other.v2))

@value
struct ManualNegate:
    var v1: Int
    var v2: Int
    fn __add__(self, other: Self) -> Self: return Self(self.v1 + other.v1, -(self.v2 + other.v2))

@value
struct ManualZero:
    var v1: Int
    var v2: Int
    fn __add__(self, other: Self) -> Self: return Self(self.v1 + other.v1, 0)

@value
struct ManualOne:
    var v1: Int
    var v2: Int
    fn __add__(self, other: Self) -> Self: return Self(self.v1 + other.v1, self.v2 + other.v2)

@value
struct ManualTwo:
    var v1: Int
    var v2: Int
    fn __add__(self, other: Self) -> Self: return Self(self.v1 + other.v1, (self.v2 + other.v2)+(self.v2 + other.v2))

@value
struct ManualNegateF:
    var v1: Float64
    var v2: Float64
    fn __add__(self, other: Self) -> Self: return Self(self.v1 + other.v1, -(self.v2 + other.v2))

@value
struct ManualZeroF:
    var v1: Float64
    var v2: Float64
    fn __add__(self, other: Self) -> Self: return Self(self.v1 + other.v1, 0.0)

@value
struct ManualOneF:
    var v1: Float64
    var v2: Float64
    fn __add__(self, other: Self) -> Self: return Self(self.v1 + other.v1, self.v2 + other.v2)

@value
struct ManualTwoF:
    var v1: Float64
    var v2: Float64
    fn __add__(self, other: Self) -> Self: return Self(self.v1 + other.v1, (self.v2 + other.v2)+(self.v2 + other.v2))