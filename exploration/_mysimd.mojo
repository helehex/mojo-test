alias SIMD1 = SIMD[DType.float32,1]
alias SIMD4 = SIMD[DType.float32,4]
alias M1 = MySIMD[DType.float32,1]
alias M4 = MySIMD[DType.float32,4]

fn main():
    
    let a1: M1 = 6
    let b1: M1 = SIMD1(6)

    let c1: M1 = M1(6)
    let d1: M1 = M1(SIMD1(6))


    let a4: M4 = 6
    let b4: M4 = SIMD1(6)
    let c4: M4 = SIMD4(6)
    let d4: M4 = M1(6)

    let e4: M4 = M4(6)
    let f4: M4 = M4(SIMD1(6))
    let g4: M4 = M4(SIMD4(6))
    let h4: M4 = M4(M1(6))


    print(a1.value, b1.value, c1.value, d1.value)
    print(a4.value, b4.value, c4.value, d4.value, e4.value, f4.value, g4.value, h4.value)
    
@register_passable("trivial")
struct MySIMD[type: DType, size: Int]:

    var value: SIMD[type,size]

    fn __init__(value: Int) -> Self: return Self{value: value}

    fn __init__(*value: SIMD[type,1]) -> Self: return Self{value: value[0]}

    fn __init__(value: SIMD[type,size]) -> Self: return Self{value: value}

    fn __init__(value: MySIMD[type,1]) -> Self: return Self{value: value.value}