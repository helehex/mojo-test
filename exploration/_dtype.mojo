fn main():
    let string: StringLiteral = "hello"
    let a: IntLiteral = 3

    @parameter
    fn fn0[type: DType]():
        print(string, SIMD[type,1](a))

    DType.float32.dispatch_integral[fn0]()
    DType.index.dispatch_integral[fn0]()

    DType.float32.dispatch_floating[fn0]()
    DType.index.dispatch_floating[fn0]()