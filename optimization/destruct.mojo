from random import random_si64
import benchmark


fn main():
    alias loops: Int = 10000
    let r1: Int = random_si64(9,11).value
    let r2: Int = random_si64(9,11).value
    let r3: Int = random_si64(9,11).value
    let r4: Int = random_si64(9,11).value


    @parameter
    fn cc[dt: DType, sq: SIMD[dt,1]]():
        @unroll(100)
        for i in range(loops):
            var o: CC[dt,sq] = CC[dt,sq](r1, r2) * CC[dt,sq](r3, r4)
            o = o * CC[dt,sq](0, i)
            benchmark.keep(o)

    @parameter
    fn sa[dt: DType, sq: SIMD[dt,1]]():
        @unroll(100)
        for i in range(loops):
            var o: SA[dt,sq] = SA[dt,sq](r1, r2) * SA[dt,sq](r3, r4)
            o = o * A[dt,sq](i)
            benchmark.keep(o)


    print()
    print("#------ -1 ------#")
    print("cc  :", benchmark.run[cc[DType.index, -1]]().mean["ns"]())
    print("sa  :", benchmark.run[sa[DType.index, -1]]().mean["ns"]())
    print()
    print("#------ 0 ------#")
    print("cc  :", benchmark.run[cc[DType.index, 0]]().mean["ns"]())
    print("sa  :", benchmark.run[sa[DType.index, 0]]().mean["ns"]())
    print()
    print("#------ 1 ------#")
    print("cc  :", benchmark.run[cc[DType.index, 1]]().mean["ns"]())
    print("sa  :", benchmark.run[sa[DType.index, 1]]().mean["ns"]())
    print()
    print()
    print("#------ -1.0 ------#")
    print("cc  :", benchmark.run[cc[DType.float64, -1]]().mean["ns"]())
    print("sa  :", benchmark.run[sa[DType.float64, -1]]().mean["ns"]())
    print()
    print("#------ 0.0 ------#")
    print("cc  :", benchmark.run[cc[DType.float64, 0]]().mean["ns"]())
    print("sa  :", benchmark.run[sa[DType.float64, 0]]().mean["ns"]())
    print()
    print("#------ 1.0 ------#")
    print("cc  :", benchmark.run[cc[DType.float64, 1]]().mean["ns"]())
    print("sa  :", benchmark.run[sa[DType.float64, 1]]().mean["ns"]())
    print()




@value
struct CC[dt: DType, sq: SIMD[dt,1]]:

    var s: SIMD[dt,1]
    var a: SIMD[dt,1]

    fn __add__(self, other: Self) -> Self:
        return Self(self.s + other.s, self.a + other.a)
    
    fn __mul__(self, other: Self) -> Self:
        return Self(self.s*other.s + sq*self.a*other.a, self.s*other.a + self.a*other.s)

@value
struct SA[dt: DType, sq: SIMD[dt,1]]:

    var s: S[dt,sq]
    var a: A[dt,sq]

    fn __init__(inout self, c1: SIMD[dt,1], c2: SIMD[dt,1]):
        self.s = c1
        self.a = c2

    fn __add__(self, other: Self) -> Self:
        return Self(self.s + other.s, self.a + other.a)

    fn __add__(self, other: S[dt,sq]) -> Self:
        return Self(self.s + other, self.a)

    fn __add__(self, other: A[dt,sq]) -> Self:
        return Self(self.s, self.a + other)
    
    fn __mul__(self, other: Self) -> Self:
        return Self(self.s*other.s + self.a*other.a, self.s*other.a + self.a*other.s)

    fn __mul__(self, other: S[dt,sq]) -> Self:
        return Self(self.s*other, self.a*other)

    fn __mul__(self, other: A[dt,sq]) -> Self:
        return Self(self.a*other, self.s*other)

@value
struct S[dt: DType, sq: SIMD[dt,1]]:

    var c: SIMD[dt,1]

    fn __add__(self, other: Self) -> Self:
        return Self(self.c + other.c)
    
    fn __mul__(self, other: Self) -> Self:
        return Self(self.c*other.c)
    
    fn __mul__(self, other: A[dt,sq]) -> A[dt,sq]:
        return A[dt,sq](self.c*other.c)


@value
struct A[dt: DType, sq: SIMD[dt,1]]:

    var c: SIMD[dt,1]

    fn __add__(self, other: Self) -> Self:
        return Self(self.c + other.c)

    fn __mul__(self, other: S[dt,sq]) -> Self:
        return Self(self.c*other.c)
    
    fn __mul__(self, other: Self) -> S[dt,sq]:
        return S[dt,sq](sq*self.c*other.c)
