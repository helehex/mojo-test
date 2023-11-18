fn main():
    let string: StringLiteral = "hello"
    let a: IntLiteral = 3

    @parameter
    fn fn0[type: DType]():
        print(string, SIMD[type,1](a))

    let p: OutputChainPtr = OutputChainPtr(DTypePointer[DType.invalid]())

    DType.float32.dispatch_integral[fn0]() # does not run. errors with argument of p
    DType.index.dispatch_integral[fn0](p)  # runs

    #p.wait()
    print(p.__bool__()) # false
    #print(p.get_cuda_stream().stream.handle.__bool__()) # idk
    #print(p.get_runtime().parallelism_level())

    DType.float32.dispatch_floating[fn0]()
    DType.index.dispatch_floating[fn0]()   # does not run