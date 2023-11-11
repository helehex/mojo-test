import benchmark


# ? keep[anytype]() only works with existing variable, unlike keep[Int]()




fn main():
    from random import seed, random_si64
    seed()
    let l1: Int = random_si64(31,39).value
    let l2: Int = random_si64(31,39).value
    let l3: Int = random_si64(31,39).value
    let l4: Int = random_si64(31,39).value

    @parameter
    fn auto[dt: DType, m: Int]():
        for i1 in range(l1):
            for i2 in range(l2):
                for i3 in range(l3):
                    for i4 in range(l4):
                        var o: Auto[dt, m] = Auto[dt, m](i1,i2) + Auto[dt, m](i3,i4)
                        benchmark.keep(o)

    @parameter
    fn manual_negate[dt: DType]():
        for i1 in range(l1):
            for i2 in range(l2):
                for i3 in range(l3):
                    for i4 in range(l4):
                        var o: ManualNegate[dt] = ManualNegate[dt](i1,i2) + ManualNegate[dt](i3,i4)
                        benchmark.keep(o)

    @parameter
    fn manual_zero[dt: DType]():
        for i1 in range(l1):
            for i2 in range(l2):
                for i3 in range(l3):
                    for i4 in range(l4):
                        var o: ManualZero[dt] = ManualZero[dt](i1,i2) + ManualZero[dt](i3,i4)
                        benchmark.keep(o)

    @parameter
    fn manual_one[dt: DType]():
        for i1 in range(l1):
            for i2 in range(l2):
                for i3 in range(l3):
                    for i4 in range(l4):
                        var o: ManualOne[dt] = ManualOne[dt](i1,i2) + ManualOne[dt](i3,i4)
                        benchmark.keep(o)

    @parameter
    fn manual_two[dt: DType]():
        for i1 in range(l1):
            for i2 in range(l2):
                for i3 in range(l3):
                    for i4 in range(l4):
                        var o: ManualTwo[dt] = ManualTwo[dt](i1,i2) + ManualTwo[dt](i3,i4)
                        benchmark.keep(o)
    

    print()
    print("#---  -1  ---#")
    print("auto   : ", benchmark.run[auto[DType.index,-1]]().mean["ns"]())
    print("manual : ", benchmark.run[manual_negate[DType.index]]().mean["ns"]())
    print()
    print("#---  0  ---#")
    print("auto   : ", benchmark.run[auto[DType.index,0]]().mean["ns"]())
    print("manual : ", benchmark.run[manual_zero[DType.index]]().mean["ns"]())
    print()
    print("#---  1  ---#")
    print("auto   : ", benchmark.run[auto[DType.index,1]]().mean["ns"]())
    print("manual : ", benchmark.run[manual_one[DType.index]]().mean["ns"]())
    print()
    print("#---  2  ---#")
    print("auto   : ", benchmark.run[auto[DType.index,2]]().mean["ns"]())
    print("manual : ", benchmark.run[manual_two[DType.index]]().mean["ns"]())
    print()
    print()
    print("#---  -1.0  ---#")
    print("auto   : ", benchmark.run[auto[DType.float64,-1]]().mean["ns"]())
    print("manual : ", benchmark.run[manual_negate[DType.float64]]().mean["ns"]())
    print()
    print("#---  0.0  ---#")
    print("auto   : ", benchmark.run[auto[DType.float64,0]]().mean["ns"]())
    print("manual : ", benchmark.run[manual_zero[DType.float64]]().mean["ns"]())
    print()
    print("#---  1.0  ---#")
    print("auto   : ", benchmark.run[auto[DType.float64,1]]().mean["ns"]())
    print("manual : ", benchmark.run[manual_one[DType.float64]]().mean["ns"]())
    print()
    print("#---  2.0  ---#")
    print("auto   : ", benchmark.run[auto[DType.float64,2]]().mean["ns"]())
    print("manual : ", benchmark.run[manual_two[DType.float64]]().mean["ns"]())
    print()




@value
struct Auto[dt: DType, m: Int]:
    var v1: SIMD[dt,1]
    var v2: SIMD[dt,1]
    fn __add__(self, other: Self) -> Self:
        return Self(m*(self.v1 + other.v1), m*(self.v2 + other.v2))

@value
struct ManualNegate[dt: DType]:
    var v1: SIMD[dt,1]
    var v2: SIMD[dt,1]
    fn __add__(self, other: Self) -> Self:
        return Self(-(self.v1 + other.v1), -(self.v2 + other.v2))

# this should be faster than auto counterpart, floating propogation different
@value
struct ManualZero[dt: DType]:
    var v1: SIMD[dt,1]
    var v2: SIMD[dt,1]
    fn __add__(self, other: Self) -> Self:
        return Self(0, 0)

@value
struct ManualOne[dt: DType]:
    var v1: SIMD[dt,1]
    var v2: SIMD[dt,1]
    fn __add__(self, other: Self) -> Self:
        return Self(self.v1 + other.v1, self.v2 + other.v2)

@value
struct ManualTwo[dt: DType]:
    var v1: SIMD[dt,1]
    var v2: SIMD[dt,1]
    fn __add__(self, other: Self) -> Self:
        let v1 = (self.v1 + other.v1)
        let v2 = (self.v2 + other.v2)
        return Self(v1 + v1, v2 + v2)