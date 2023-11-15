from random import random_si64
import benchmark


fn main():
    alias loops: Int = 10000
    let r1: Int = random_si64(10,10).value
    let r2: Int = random_si64(10,10).value
    let r3: Int = random_si64(10,10).value
    let r4: Int = random_si64(10,10).value


    @parameter
    fn auto[dt: DType, m: Int]():
        for i in range(loops):
            var o: Auto[dt, m] = Auto[dt, m](r1,r2) + Auto[dt, m](r3,r4) + Auto[dt, m](i,i)
            benchmark.keep(o)

    @parameter
    fn auto_[dt: DType, m: Int]():
        for i in range(loops):
            var o: Auto_[dt, m] = Auto_[dt, m](r1,r2) + Auto_[dt, m](r3,r4) + Auto_[dt, m](i,i)
            benchmark.keep(o)

    @parameter
    fn manual_neg[dt: DType]():
        for i in range(loops):
            var o: ManualNeg[dt] = ManualNeg[dt](r1,r2) + ManualNeg[dt](r3,r4) + ManualNeg[dt](i,i)
            benchmark.keep(o)

    @parameter
    fn manual_zero[dt: DType]():
        for i in range(loops):
            var o: ManualZero[dt] = ManualZero[dt](r1,r2) + ManualZero[dt](r3,r4) + ManualZero[dt](i,i)
            benchmark.keep(o)

    @parameter
    fn manual_one[dt: DType]():
        for i in range(loops):
            var o: ManualOne[dt] = ManualOne[dt](r1,r2) + ManualOne[dt](r3,r4) + ManualOne[dt](i,i)
            benchmark.keep(o)

    @parameter
    fn manual_one_[dt: DType]():
        for i in range(loops):
            var o: ManualOne_[dt] = ManualOne_[dt](r1,r2) + ManualOne_[dt](r3,r4) + ManualOne_[dt](i,i)
            benchmark.keep(o)

    @parameter
    fn manual_two[dt: DType]():
        for i in range(loops):
            var o: ManualTwo[dt] = ManualTwo[dt](r1,r2) + ManualTwo[dt](r3,r4) + ManualTwo[dt](i,i)
            benchmark.keep(o)

    @parameter
    fn manual_two_[dt: DType]():
        for i in range(loops):
            var o: ManualTwo_[dt] = ManualTwo_[dt](r1,r2) + ManualTwo_[dt](r3,r4) + ManualTwo_[dt](i,i)
            benchmark.keep(o)
    

    print()
    print("#------  -1  ------#")
    print("auto    : ", benchmark.run[auto[DType.index,-1]]().mean["ns"]())
    print("manual  : ", benchmark.run[manual_neg[DType.index]]().mean["ns"]())
    print()
    print("#------  0  ------#")
    print("auto    : ", benchmark.run[auto[DType.index,0]]().mean["ns"]())
    print("manual  : ", benchmark.run[manual_zero[DType.index]]().mean["ns"]())
    print()
    print("#------  1  ------#")
    print("auto    : ", benchmark.run[auto[DType.index,1]]().mean["ns"]())
    print("manual  : ", benchmark.run[manual_one[DType.index]]().mean["ns"]())
    print("auto_   : ", benchmark.run[auto_[DType.index,1]]().mean["ns"]())
    print("manual_ : ", benchmark.run[manual_one_[DType.index]]().mean["ns"]())
    print()
    print("#------  2  ------#")
    print("auto    : ", benchmark.run[auto[DType.index,2]]().mean["ns"]())
    print("manual  : ", benchmark.run[manual_two[DType.index]]().mean["ns"]())
    print("auto_   : ", benchmark.run[auto_[DType.index,2]]().mean["ns"]())
    print("manual_ : ", benchmark.run[manual_two_[DType.index]]().mean["ns"]())
    print()
    print()
    print("#------  -1.0  ------#")
    print("auto    : ", benchmark.run[auto[DType.float64,-1]]().mean["ns"]())
    print("manual  : ", benchmark.run[manual_neg[DType.float64]]().mean["ns"]())
    print()
    print("#------  0.0  ------#")
    print("auto    : ", benchmark.run[auto[DType.float64,0]]().mean["ns"]())
    print("manual  : ", benchmark.run[manual_zero[DType.float64]]().mean["ns"]())
    print()
    print("#------  1.0  ------#")
    print("auto    : ", benchmark.run[auto[DType.float64,1]]().mean["ns"]())
    print("manual  : ", benchmark.run[manual_one[DType.float64]]().mean["ns"]())
    print("auto_   : ", benchmark.run[auto_[DType.float64,1]]().mean["ns"]())
    print("manual_ : ", benchmark.run[manual_one_[DType.float64]]().mean["ns"]())
    print()
    print("#------  2.0  ------#")
    print("auto    : ", benchmark.run[auto[DType.float64,2]]().mean["ns"]())
    print("manual  : ", benchmark.run[manual_two[DType.float64]]().mean["ns"]())
    print("auto_   : ", benchmark.run[auto_[DType.float64,2]]().mean["ns"]())
    print("manual_ : ", benchmark.run[manual_two_[DType.float64]]().mean["ns"]())
    print()




@value
struct Auto[dt: DType, m: Int]:
    var v1: SIMD[dt,1]
    var v2: SIMD[dt,1]
    fn __add__(self, other: Self) -> Self:
        return Self(m*(self.v1 + other.v1), m*(self.v2 + other.v2))

# with hints not much changes in this case
@value
@register_passable
struct Auto_[dt: DType, m: Int]:
    var v1: SIMD[dt,1]
    var v2: SIMD[dt,1]
    @always_inline
    fn __add__(self, other: Self) -> Self:
        return Self(m*(self.v1 + other.v1), m*(self.v2 + other.v2))

@value
struct ManualNeg[dt: DType]:
    var v1: SIMD[dt,1]
    var v2: SIMD[dt,1]
    fn __add__(self, other: Self) -> Self:
        return Self(-(self.v1 + other.v1), -(self.v2 + other.v2))

# this should be faster than auto counterpart for floating points, (cant guarantee zero)
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
@register_passable
struct ManualOne_[dt: DType]:
    var v1: SIMD[dt,1]
    var v2: SIMD[dt,1]
    @always_inline
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

@value
@register_passable
struct ManualTwo_[dt: DType]:
    var v1: SIMD[dt,1]
    var v2: SIMD[dt,1]
    @always_inline
    fn __add__(self, other: Self) -> Self:
        let v1 = (self.v1 + other.v1)
        let v2 = (self.v2 + other.v2)
        return Self(v1 + v1, v2 + v2)