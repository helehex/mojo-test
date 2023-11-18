fn main():
    var three: Int = 3
    var result: SIMD[DType.float64,1] = three

    @parameter
    fn fn0[type: DType]():
        result = (SIMD[type,1](three)/2).cast[DType.float64]()

    let out: OutputChainPtr = OutputChainPtr(DTypePointer[DType.invalid]())

    result = three
    DType.float32.dispatch_integral[fn0]() # does not run. errors with argument of p
    print(result)

    result = three
    DType.index.dispatch_integral[fn0](out)  # runs
    print(result)

    #out.wait()
    print(out.__bool__()) # false
    #print(out.get_cuda_stream().stream.handle.__bool__()) # idk
    #print(out.get_runtime().parallelism_level())

    result = three
    DType.float32.dispatch_floating[fn0]() # runs
    print(result)

    result = three
    DType.index.dispatch_floating[fn0]()   # does not run
    print(result)