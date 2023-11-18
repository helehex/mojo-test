fn main():
    let string: StringLiteral = "hello"
    let a: IntLiteral = 3

    @parameter
    fn fn0[type: DType]():
        print(string, SIMD[type,1](a))

    let p: OutputChainPtr = OutputChainPtr(DTypePointer[DType.invalid]())

    DType.float32.dispatch_integral[fn0]() # does not run. errors with argument of p

    #print(p.get_cuda_stream().stream.handle.load(0)) # idk
    #print(p.__bool__())

    DType.index.dispatch_integral[fn0](p) # runs
    print(p.__bool__())

    DType.float32.dispatch_floating[fn0]()
    DType.index.dispatch_floating[fn0]()   # does not run