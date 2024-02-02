from memory.unsafe import DTypePointer, Pointer
from collections.vector import InlinedFixedVector
from sys.info import simdwidthof
from algorithm.functional import unroll, vectorize, parallelize
from memory import memset_zero
from math.math import max, min, iota, tanh, ceil
from os.atomic import Atomic
from utils.variant import Variant
from python.python import Python

#------------ G2 Multivector ------------#
#
#-- Cl(2,0,0) ~ Mat2x2
#-- x*x = 1
#-- y*y = 1
#-- i*i = -1
#-- rename to G2? and use G2.Vector for most purposes
#
@register_passable("trivial")
struct MultivectorG2[type: DType, size: Int](Stringable):

    #------[ Alias ]------#
    #
    alias Unit = MultivectorG2[type,1]

    #------< Data >------#
    #
    var s: SIMD[type,size]     # this multivectors scalar component
    var v: VectorG2[type,size] # this multivectors vector component
    var i: SIMD[type,size]     # this multivectors bivector component
    
    
    #------( Initialize )------#
    
    fn __init__(s: SIMD[type,size] = 0, x: SIMD[type,size] = 0, y: SIMD[type,size] = 0, i: SIMD[type,size] = 0) -> Self:
        return Self{s: s, v: VectorG2(x, y), i: i}

    fn __init__[__:None=None](s: SIMD[type,1] = 0, x: SIMD[type,1] = 0, y: SIMD[type,1] = 0, i: SIMD[type,1] = 0) -> Self:
        return Self{s: s, v: VectorG2(x, y), i: i}
    
    fn __init__(v: VectorG2[type,size]) -> Self:
        return Self{s: 0, v: v, i: 0}

    fn __init__[__:None=None](v: VectorG2[type,1]) -> Self:
        return Self{s: 0, v: v, i: 0}
    
    fn __init__(s: SIMD[type,size], v: VectorG2[type,size], i: SIMD[type,size] = 0) -> Self:
        return Self{s: s, v: v, i: i}

    fn __init__(m: Self.Unit) -> Self:
        return Self{s: m.s, v: m.v, i: m.i}
    
    
    #------( Get / Set )------#
    #
    fn get_lane(self, index: Int) -> Self.Unit:
        return Self.Unit(self.s[index], self.v.x[index], self.v.y[index], self.i[index])

    fn set_lane(inout self, index: Int, value: Self.Unit):
        self.s[index] = value.s
        self.v.x[index] = value.v.x
        self.v.y[index] = value.v.y
        self.i[index] = value.i
    

    #------( Format )------#
    #
    fn __str__(self) -> String:
        return self.to_string()

    fn to_string[separator: StringLiteral = " ", simd_separator: StringLiteral = "\n"](self) -> String:
        @parameter
        if size == 1:
            return String(self.s) + "s" + separator + String(self.v.x) + "x" + separator + String(self.v.y) + "y" + separator + String(self.i) + "i"
        else:
            var result: String = ""
            @unroll
            for index in range(size-1): result += String(self.get_lane(index)) + simd_separator
            return result + String(self.get_lane(size))


    #------( Unary )------#
    #
    fn __neg__(self) -> Self:
        return Self(-self.s, -self.v, -self.i)

    
    #------( Arithmetic )------#
    #
    fn __add__(self, other: SIMD[type,size]) -> Self:
        return Self(self.s + other, self.v, self.i)
    
    fn __add__(self, other: VectorG2[type,size]) -> Self:
        return Self(self.s, self.v + other, self.i)

    fn __add__[__:None=None](self, other: Self) -> Self:
        return Self(self.s + other.s, self.v + other.v, self.i + other.i)
    
    fn __sub__(self, other: SIMD[type,size]) -> Self:
        return Self(self.s - other, self.v, self.i)
    
    fn __sub__(self, other: VectorG2[type,size]) -> Self:
        return Self(self.s, self.v - other, self.i)

    fn __sub__[__:None=None](self, other: Self) -> Self:
        return Self(self.s - other.s, self.v - other.v, self.i - other.i)

    fn __mul__(self, other: SIMD[type,size]) -> Self:
        return Self(self.s * other, self.v * other, self.i * other)
    
    fn __mul__(self, other: VectorG2[type,size]) -> Self:
        return Self(
            self.v.x*other.x + self.v.y*other.y,
            self.s*other.x   + self.i*other.y,
            self.s*other.y   + self.i*other.x,
            self.v.x*other.y - self.v.y*other.x)
    
    fn __mul__[__:None=None](self, other: Self) -> Self:
        return Self(
            self.s*other.s   + self.v.x*other.v.x + self.v.y*other.v.y - self.i*other.i,     # s
            self.s*other.v.x + self.v.x*other.s   + self.i*other.v.y   + self.v.y*other.i,   # x
            self.s*other.v.y + self.v.y*other.s   + self.i*other.v.x   + self.v.x*other.i,   # y
            self.s*other.i   + self.i*other.s     + self.v.x*other.v.y - self.v.y*other.v.x) # i
        
    fn __truediv__(self, other: SIMD[type,size]) -> Self:
        return Self(
            self.s/other,
            self.v.x/other,
            self.v.y/other,
            self.i/other)
    

    #------( Min / Max )------#
    #
    fn __max__(self, other: Self) -> Self:
        return Self(max(self.s, other.s), max(self.v.x, other.v.x), max(self.v.y, other.v.y), max(self.i, other.i))
    
    fn __min__(self, other: Self) -> Self:
        return Self(min(self.s, other.s), min(self.v.x, other.v.x), min(self.v.y, other.v.y), min(self.i, other.i))
    
    fn max_coef(self) -> SIMD[type,size]:
        return max(max(max(self.s, self.v.x), self.v.y), self.i)
    
    fn min_coef(self) -> SIMD[type,size]:
        return min(min(min(self.s, self.v.x), self.v.y), self.i)
    
    # reduce_coefficient reduces across every coefficient present within this structure
    fn reduce_max_coef(self) -> SIMD[type,1]:
        return max(max(max(self.s.reduce_max(), self.v.x.reduce_max()), self.v.y.reduce_max()), self.i.reduce_max())
    
    fn reduce_min_coef(self) -> SIMD[type,1]:
        return min(min(min(self.s.reduce_min(), self.v.x.reduce_min()), self.v.y.reduce_min()), self.i.reduce_min())
    
    # reduce_compose treats each basis channel independently, then uses those to constuct a new multivector
    fn reduce_max_compose(self) -> Self.Unit:
        return Self.Unit(self.s.reduce_max(), self.v.x.reduce_max(), self.v.y.reduce_max(), self.i.reduce_max())
    
    fn reduce_min_compose(self) -> Self.Unit:
        return Self.Unit(self.s.reduce_min(), self.v.x.reduce_min(), self.v.y.reduce_min(), self.i.reduce_min())



    
#------------ Vector ------------#
#
@register_passable("trivial")
struct VectorG2[type: DType, size: Int](Stringable):
    
    #------[ Alias ]------#
    #
    alias Unit = VectorG2[type, 1]
    
    alias ze = VectorG2[type,size](0, 0)
    

    #------< Data >------#
    #
    var x: SIMD[type,size]
    var y: SIMD[type,size]
    
    
    #------( initialize )------#
    #
    fn __init__(x: SIMD[type,size] = 0, y: SIMD[type,size] = 0) -> Self:
        return Self{x: x, y: y}

    fn __init__[__:None=None](x: SIMD[type,1] = 0, y: SIMD[type,1] = 0) -> Self:
        return Self{x: x, y: y}

    fn __init__(v: Self.Unit) -> Self:
        return Self{x: v.x, y: v.y}
    

    #------( Get / Set )------#
    #
    fn get_lane(self, i: Int) -> Self.Unit:
        return Self.Unit(self.x[i], self.y[i])
    
    fn set_lane(inout self, i: Int, item: Self.Unit):
        self.x[i] = item.x
        self.y[i] = item.y
    

    #------( Format )------#
    #
    fn __str__(self) -> String:
        return self.to_string()

    fn to_string[separator: StringLiteral = " ", simd_separator: StringLiteral = "\n"](self) -> String:
        @parameter
        if size == 1:
            return String(self.x) + "x" + separator + String(self.y) + "y"
        else:
            var result: String = ""
            @unroll
            for index in range(size-1): result += String(self.get_lane(index)) + simd_separator
            return result + String(self.get_lane(size))


    #------( Unary )------#
    #
    @always_inline
    fn __neg__(self) -> Self:
        return Self(-self.x, -self.y)

    
    #------( Operations )------#
    
    fn __add__(self, other: Self) -> Self:
        return Self(self.x + other.x, self.y + other.y)
    
    fn __sub__(self, other: Self) -> Self:
        return Self(self.x - other.x, self.y - other.y)
    
    # splat multiply by scalar
    fn __mul__(self, other: SIMD[type,size]) -> Self:
        return Self(self.x * other, self.y * other)

    # simd mulitply by vector
    fn __mul__[__:None=None](self, other: Self) -> MultivectorG2[type,size]:
        return MultivectorG2[type,size](self.x*other.x + self.y*other.y, self.x*other.y - self.y*other.x)




#------------ atomic ------------#
#
struct Atomic4[type: DType]: # Atomic, length 4
    
    alias Unit = MultivectorG2[type, 1]
    
    var a1: Atomic[type]
    var a2: Atomic[type]
    var a3: Atomic[type]
    var a4: Atomic[type]
    
    @always_inline
    fn __init__(inout self, m: Self.Unit):
        self.a1 = m.s
        self.a2 = m.v.x
        self.a3 = m.v.y
        self.a4 = m.i
    
    @always_inline
    fn max_(inout self, other: Self.Unit):
        self.a1.max(other.s)
        self.a2.max(other.v.x)
        self.a3.max(other.v.y)
        self.a4.max(other.i)
    
    fn min_(inout self, other: Self.Unit):
        self.a1.min(other.s)
        self.a2.min(other.v.x)
        self.a3.min(other.v.y)
        self.a4.min(other.i)
    
    @always_inline
    fn to_multivector(self) -> Self.Unit:
        return Self.Unit(self.a1.value, self.a2.value, self.a3.value, self.a4.value)



#------------ color ------------#
        
@value
@register_passable("trivial")
struct Color:
    var r: Float32
    var g: Float32
    var b: Float32
    
fn color_G2[type: DType](m: MultivectorG2[type, 1]) -> Color:
    @parameter
    fn bound(v: SIMD[type, 1]) -> SIMD[DType.float32, 1]:
        return (tanh[DType.float32, 1](v.cast[DType.float32]()) + 1) / 2
    return Color(bound(m.i[0]), bound(m.v.x[0]), bound(m.v.y[0]))



#------------ field ------------#
#
# - the space of a simulation
# - discrete square G2 grid
#

struct Field[type: DType, width: Int, height: Int]: # prime_func: fn[simd_width: Int](Int, Int) -> G2_Multivector[bit_type, simd_width]
    
    alias Word = SIMD[type, 1]
    alias Unit = MultivectorG2[type, 1]
    alias vector_size: Int = simdwidthof[type]()
    alias unit_size: Int = 4
    alias true_width: Int = width * Self.unit_size
    alias true_size: Int = height * Self.true_width
    
    var data: DTypePointer[type]
    var rc: Pointer[Int]
    var step_count: Int # this wont be tracked perfectly, but thats ok. if needed, use Pointer[Int] instead
    
    
    #------ initialize / delete------#
    
    fn __init__(inout self):
        self.data = DTypePointer[type].alloc(Self.true_size)
        self.rc = Pointer[Int].alloc(1)
        self.rc.store(0)
        self.step_count = 0
        self.set_zero()
        
    fn __init__(inout self, prime: Int):
        self.data = DTypePointer[type].alloc(Self.true_size)
        self.rc = Pointer[Int].alloc(1)
        self.rc.store(0)
        self.step_count = 0
        self.set_prime()
    
    fn __copyinit__(inout self, other: Self):
        self.data = other.data
        self.rc = other.rc
        self.rc.store(self.rc.load() + 1)
        self.step_count = other.step_count
        
    fn __moveinit__(inout self, owned other: Self):
        self.data = other.data
        self.rc = other.rc
        self.step_count = other.step_count
    
    fn __del__(owned self):
        let rc = self.rc.load() - 1
        if rc < 0:
            self.data.free()
            self.rc.free()
            return
        self.rc.store(rc)
    
    
    
    #------ get / set ------#
    
    # populate field with all zero's
    @always_inline
    fn set_zero(inout self):
        self.step_count = 0
        memset_zero(self.data, Self.true_size)
    
    # populate field with a map function
    @always_inline
    fn set_prime(inout self):
        self.step_count = 0
        @parameter
        fn prime_row(row: Int):
            @parameter
            fn prime_col[size: Int](col: Int):
                self.simd_store[size](row, col, self.prime_2[size](col, row))
            vectorize[Self.vector_size, prime_col](width)
        parallelize[prime_row](height)
    
    fn prime_1[size: Int](self, col: Int, row: Int) -> MultivectorG2[type, size]:
        alias half_width: Int = width // 2
        alias half_height: Int = height // 2
        let rel: Int = half_width - col
        if (row != half_height) | (rel < 0) | (rel >= size):
            return MultivectorG2[type, size](0)
        var m: MultivectorG2[type, size] = MultivectorG2[type, size](0)
        m.set_lane(rel, Self.Unit(1))
        return m
    
    fn prime_2[size: Int](self, col: Int, row: Int) -> MultivectorG2[type, size]:
        alias half_width: Int = width // 2
        alias half_height: Int = height // 2
        let rel: Int = half_width - col
        if (row != half_height) | (rel < 0) | (rel >= size):
            return MultivectorG2[type, size](0)
        var m: MultivectorG2[type, size] = MultivectorG2[type, size](0)
        m.set_lane(rel, Self.Unit(1, 0, 0, 0))
        return m
    
    fn prime_3[size: Int](self, col: Int, row: Int) -> MultivectorG2[type, size]:
        let cols: SIMD[type, size] = (((col+iota[type, size]()) + row) % 3) // 3
        return MultivectorG2[type, size](cols, 0, 0, 0)
    
    # gets the unsigned maximum between all values contained in the field
    fn reduce_max(self) -> Self.Word:
        var row_max: Atomic[type] = self[0, 0].reduce_max_coef()
        @parameter
        fn reduce_row(row: Int):
            var col_max: Self.Word = self[row, 0].reduce_max_coef()
            @parameter
            fn reduce_col[size: Int](col: Int):
                col_max = max(col_max, self.simd_load[size](row, col).reduce_max_coef())
            vectorize[Self.vector_size, reduce_col](width)
            row_max.max(col_max)
        parallelize[reduce_row](height)
        return row_max.value
    
    # get the composed maximum multivector. each component of the multivector is treated independently, and combined at the end
    fn reduce_max_compose(self) -> Self.Unit:
        let row_max: Atomic4[type] = self[0, 0].reduce_max_compose()
        @parameter
        fn reduce_row(row: Int):
            var col_max: Self.Unit = self[row, 0].reduce_max_compose()
            @parameter
            fn reduce_col[size: Int](col: Int):
                col_max = col_max.__max__(self.simd_load[size](row, col).reduce_max_compose())
            vectorize[Self.vector_size, reduce_col](width)
            row_max.max_(col_max)
        parallelize[reduce_row](height)
        return row_max.to_multivector()
    
    # get the composed minimum multivector. each component of the multivector is treated independently, and combined at the end
    fn reduce_min_compose(self) -> Self.Unit:
        let row_min: Atomic4[type] = self[0, 0].reduce_min_compose()
        @parameter
        fn reduce_row(row: Int):
            var col_min: Self.Unit = self[row, 0].reduce_min_compose()
            @parameter
            fn reduce_col[size: Int](col: Int):
                col_min = col_min.__min__(self.simd_load[size](row, col).reduce_min_compose())
            vectorize[Self.vector_size, reduce_col](width)
            row_min.min_(col_min)
        parallelize[reduce_row](height)
        return row_min.to_multivector()
    
    fn __getitem__(self, row: Int, col: Int) -> Self.Unit:
        let start: Int = row*Self.true_width + col*Self.unit_size
        let simd: SIMD[type, 4] = self.data.simd_load[4](start)
        return Self.Unit(simd[0], simd[1], simd[2], simd[3]) # the mystery meat
    
    fn __setitem__(self, row: Int, col: Int, value: Self.Unit):
        let start: Int = row*Self.true_width + col*Self.unit_size
        let simd: SIMD[type, 4] = SIMD[type, 4](value.s[0], value.v.x[0], value.v.y[0], value.i[0])
        self.data.simd_store[4](start, simd)
    
    

    #------ store / load ------#
    
    fn simd_store[size: Int](self, row: Int, col: Int, value: MultivectorG2[type, size]):
        let start: Int = row*Self.true_width + col*Self.unit_size
        self.data.offset(start + 0).simd_strided_store[size](value.s, 4) # :->
        self.data.offset(start + 1).simd_strided_store[size](value.v.x, 4)
        self.data.offset(start + 2).simd_strided_store[size](value.v.y, 4)
        self.data.offset(start + 3).simd_strided_store[size](value.i, 4)
    
    fn simd_load[size: Int](self, row: Int, col: Int) -> MultivectorG2[type, size]:
        let start: Int = row*Self.true_width + col*Self.unit_size
        let s: SIMD[type, size] = self.data.offset(start + 0).simd_strided_load[size](4) # {s, x, y, i, s, x, y, i, s, x, y, i, ...}
        let x: SIMD[type, size] = self.data.offset(start + 1).simd_strided_load[size](4)
        let y: SIMD[type, size] = self.data.offset(start + 2).simd_strided_load[size](4)
        let i: SIMD[type, size] = self.data.offset(start + 3).simd_strided_load[size](4)
        return MultivectorG2[type, size](s, x, y, i)
    
    fn simd_load_loop[size: Int](self, row: Int, col: Int) -> MultivectorG2[type, size]:
        let row_loop: Int = (row+height) % height
        let col_end: Int = col + size
        let start: Int = row_loop*Self.true_width + col*Self.unit_size
        
        # row is under modulo, as normal.
        # when col is outside of the fields width, it will a simd-range from memory starting at col, but also a simd-range which starts at col modulo width
        # it then uses a mask to choose the correct range from each simd-value to make a seamless result
        if col < 0:
            let col_loop: Int = col + width
            let start_loop: Int = row_loop*Self.true_width + col_loop*Self.unit_size
            let mask: SIMD[DType.bool, size] = iota[type, size](col) < 0 # {col + 0 < 0?, col + 1 < 0?, col + 2 < 0?, ...}
            let s: SIMD[type, size] = mask.select(self.data.offset(start_loop + 0).simd_strided_load[size](4), self.data.offset(start + 0).simd_strided_load[size](4))
            let x: SIMD[type, size] = mask.select(self.data.offset(start_loop + 1).simd_strided_load[size](4), self.data.offset(start + 1).simd_strided_load[size](4))
            let y: SIMD[type, size] = mask.select(self.data.offset(start_loop + 2).simd_strided_load[size](4), self.data.offset(start + 2).simd_strided_load[size](4))
            let i: SIMD[type, size] = mask.select(self.data.offset(start_loop + 3).simd_strided_load[size](4), self.data.offset(start + 3).simd_strided_load[size](4))
            return MultivectorG2[type, size](s, x, y, i)
        
        if col_end > width:
            let col_loop: Int = (col_end % width) - size
            let start_loop: Int = row_loop*Self.true_width + col_loop*Self.unit_size
            let mask: SIMD[DType.bool, size] = iota[type, size](col_loop) >= 0
            let s: SIMD[type, size] = mask.select(self.data.offset(start_loop + 0).simd_strided_load[size](4), self.data.offset(start + 0).simd_strided_load[size](4))
            let x: SIMD[type, size] = mask.select(self.data.offset(start_loop + 1).simd_strided_load[size](4), self.data.offset(start + 1).simd_strided_load[size](4))
            let y: SIMD[type, size] = mask.select(self.data.offset(start_loop + 2).simd_strided_load[size](4), self.data.offset(start + 2).simd_strided_load[size](4))
            let i: SIMD[type, size] = mask.select(self.data.offset(start_loop + 3).simd_strided_load[size](4), self.data.offset(start + 3).simd_strided_load[size](4))
            return MultivectorG2[type, size](s, x, y, i)
        
        return self.simd_load[size](row_loop, col)
    
    

    #------ Step ------#
    
    #fn step(self, VariadicList, fn(VariadicList) -> Multivector) -> Self: neighborhood and rule?
    
    fn step(self) -> Self:
        var new_field: Self = Self()
        new_field.step_count = self.step_count + 1
        @parameter
        fn step_row(row: Int):
            @parameter
            fn step_col[size: Int](col: Int):
                let m: MultivectorG2[type, size] = self.rule_1[size](
                            self.simd_load_loop[size](row + 1, col - 1), self.simd_load_loop[size](row + 1, col), self.simd_load_loop[size](row + 1, col + 1),
                            self.simd_load_loop[size](row + 0, col - 1),                                                self.simd_load_loop[size](row + 0, col + 1),
                            self.simd_load_loop[size](row - 1, col - 1), self.simd_load_loop[size](row - 1, col), self.simd_load_loop[size](row - 1, col + 1))
                new_field.simd_store[size](row, col, m)
            vectorize[Self.vector_size, step_col](width)
        parallelize[step_row](height)
        return new_field
    
    fn rule_1[size: Int](self,
                        pn: MultivectorG2[type, size], pz: MultivectorG2[type, size], pp: MultivectorG2[type, size],
                        zn: MultivectorG2[type, size],                                zp: MultivectorG2[type, size],
                        nn: MultivectorG2[type, size], nz: MultivectorG2[type, size], np: MultivectorG2[type, size],
                       ) -> MultivectorG2[type, size]:
        let m = (
        pn*VectorG2[type, 1](-1, +1) + pz*VectorG2[type, 1](+0, -1) + pp*VectorG2[type, 1](+1, +1) +
        zn*VectorG2[type, 1](+1, +0) +                                zp*VectorG2[type, 1](+1, +0) +
        nn*VectorG2[type, 1](-1, -1) + nz*VectorG2[type, 1](+1, -1) + np*VectorG2[type, 1](+1, 0))/2
        # pn*G2_Vector[bit_type, 1](+1, -1) + pz*G2_Vector[bit_type, 1](+0, -1) + pp*G2_Vector[bit_type, 1](-1, -1) +
        # zn*G2_Vector[bit_type, 1](+1, +0) +                                     zp*G2_Vector[bit_type, 1](-1, +0) +
        # nn*G2_Vector[bit_type, 1](+1, +1) + nz*G2_Vector[bit_type, 1](+0, +1) + np*G2_Vector[bit_type, 1](-1, +1)
        return m
        
        

    #------ IO ------#
    
    fn str_[row_separator: StringLiteral, col_separator: StringLiteral](self) -> String:
        var s: String = String("")
        for row in range(height):
            for col in range(width): # could prbably vectorize the loading, then G2SIMD.str_() idk if that would be too much, although vectoriz simplifies code sometimes it seems
                s += String(self[row, col])
                s += col_separator
            s += row_separator
        return s
    
    fn str_scalars[row_separator: StringLiteral, col_separator: StringLiteral](self) -> String:
        var s: String = String("")
        for row in range(height):
            for col in range(width):
                s += String(self[row, col].s)
                s += col_separator
            s += row_separator
        return s
        
    fn str_info(self) -> String:
        return "Step: " + String(self.step_count) + ", Range: " + String(self.reduce_min_compose()) + " - " + String(self.reduce_max_compose())
    
    fn print_(self): print(self.str_['\n', ", "]())
        
    fn print_scalars(self): print(self.str_scalars['\n', ", "]())
        
    fn print_info(self): print(self.str_info())
    
    def render(self):
        let np = Python.import_module("numpy")
        
        let mat = Python.import_module("matplotlib")
        let plt = Python.import_module("matplotlib.pyplot")
        let colors = Python.import_module("matplotlib.colors")
        let np_array = np.zeros((height, width, 3), np.float32)

        mat.use("TkAgg")

        for col in range(width):
            for row in range(height):
                let color: Color = color_G2(self[row, col])
                np_array.itemset((row, col, 0), color.r)
                np_array.itemset((row, col, 1), color.g)
                np_array.itemset((row, col, 2), color.b)

        dpi = 64
        fig = plt.figure(1, [height // 8, width // 8], dpi)

        plt.imshow(np_array)
        plt.axis("off")
        plt.show()
        



def test(iterations: Int):
    alias size: Int = 128
    var f: Field[DType.float64, size, size] = Field[DType.float64, size, size](5)
    for i in range(iterations + 1):
        f.print_info()
        f = f.step()
    f.render()


alias python_install_packages: StringRef = """
from importlib.util import find_spec
import shutil
import subprocess

def install_if_missing(name: str):
    if find_spec(name):
        return

    print(f"{name} not found, installing...")
    try:
        if shutil.which('python3'): python = "python3"
        elif shutil.which('python'): python = "python"
        else: raise ("python not on path")
        subprocess.check_call([python, "-m", "pip", "install", name])
    except:
        raise ImportError(f"{name} not found")

install_if_missing("numpy")
install_if_missing("tk")
install_if_missing("matplotlib")
"""



def main():
    var py = Python()
    py.eval(python_install_packages)
    test(10)




# the random behaviour at 28 is overflow, you can spot it pretty well. ca's like to make trippy spiral patterns, it's rare to get something really cool
# it's interesting that the overflow spreads in a circle, but the edges spread in a square. this means the magnitude of values are distributed in a circle -> square gradient
# value growth isnt too bad actually, exponential

# i thought it was a bug, but it seems every 4 steps there is a little gain on the max i value, but not the min i value. this is likely due to the initial condition of positive i
# initial condition of -i give similar results, but reversed.

# initial condition of i has a near rotational effect, how surprising
# i compared to 1 roates the vector part?

# todo -- one last test, provide step 2 as the initial condition, and make sure you still get the same behaviour at step 4, 8, and 12
# gotta abstract some stuff