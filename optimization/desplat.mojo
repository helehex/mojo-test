from random import random_float64
from autotune import cost_of
from math import iota
import benchmark

fn randomize_simd(inout simd: SIMD, min: Float64, max: Float64):
    for i in range(simd.size):
        simd[i] = random_float64(min, max).cast[simd.type]()

fn main():
    let loops: Int = random_float64(19,20).to_int()

    alias floatlit: Float64 = 5
    alias simdlit: SIMD[DType.float64,8] = SIMD[DType.float64,8](4,5,4,5,4,5,4,5)

    var float1: Float64 = random_float64(10,20)
    var float2: Float64 = random_float64(10,20)
    var simd1: SIMD[DType.float64,8] = SIMD[DType.float64,8]()
    var simd2: SIMD[DType.float64,8] = SIMD[DType.float64,8]()

    randomize_simd(simd1, 10, 20)
    randomize_simd(simd2, 10, 20)

    # issue: benchmark.keep(SIMD)

    @parameter
    fn simd_floatlit():
        for i in range(loops):
            var o: SIMD[DType.float64,8] = simd1 * floatlit + i
            benchmark.keep(o)

    @parameter
    fn simd_simdlit():
        for i in range(loops):
            var o: SIMD[DType.float64,8] = simd1 * simdlit + i
            benchmark.keep(o)

    @parameter
    fn simd_float():
        for i in range(loops):
            var o: SIMD[DType.float64,8] = simd1 * float1 * float2 + float1 + float2 + simd2 + i
            benchmark.keep(o)

    @parameter
    fn simd_simd():
        for i in range(loops):
            var o: SIMD[DType.float64,8] = simd1 * simd2 + i
            benchmark.keep(o)
    
    print()
    print("simd*floatlit :", benchmark.run[simd_floatlit]().mean["ns"]())
    print("mlir_ops      :", String(cost_of[fn() capturing -> None, simd_floatlit]()))
    print()
    print("simd*simdlit  :", benchmark.run[simd_simdlit]().mean["ns"]())
    print("mlir_ops      :", String(cost_of[fn() capturing -> None, simd_simdlit]()))
    print()
    print("simd*float    :", benchmark.run[simd_float]().mean["ns"]())
    print("mlir_ops      :", String(cost_of[fn() capturing -> None, simd_float]()))
    print()
    print("simd*simd     :", benchmark.run[simd_simd]().mean["ns"]())
    print("mlir_ops      :", String(cost_of[fn() capturing -> None, simd_simd]()))
    print()