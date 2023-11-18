from random import random_float64
from autotune import cost_of
import benchmark

fn random_simd(inout simd: SIMD, min: Float64, max: Float64):
    for i in range(simd.size):
        simd[i] = random_float64(min, max).cast[simd.type]()

fn main():
    alias floatlit: Float64 = 5
    alias simdlit: SIMD[DType.float64,32] = 5

    alias loops: Int = 100

    var float: Float64 = random_float64(10,20)
    var simd1: SIMD[DType.float64,32] = SIMD[DType.float64,32](random_float64(10,10))
    var simd2: SIMD[DType.float64,32] = SIMD[DType.float64,32](random_float64(10,10))

    random_simd(simd1, 10, 20)
    random_simd(simd2, 10, 20)

    # bug: benchmark.keep(SIMD)

    @parameter
    fn simd_floatlit():
        for i in range(loops):
            var o = simd1 * floatlit
            benchmark.keep(o)

    @parameter
    fn simd_simdlit():
        for i in range(loops):
            var o = simd1 * simdlit
            benchmark.keep(o)

    @parameter
    fn simd_float():
        for i in range(loops):
            var o = simd1 * float
            benchmark.keep(o)

    @parameter
    fn simd_simd():
        for i in range(loops):
            var o = simd1 * simd2
            benchmark.keep(o)
    
    print()
    print("simd_floatlit :", benchmark.run[simd_floatlit]().mean["ns"]())
    print("mlir_ops      :", String(cost_of[fn() capturing -> None, simd_floatlit]()))
    print()
    print("simd_simdlit  :", benchmark.run[simd_simdlit]().mean["ns"]())
    print("mlir_ops      :", String(cost_of[fn() capturing -> None, simd_simdlit]()))
    print()
    print("simd_float    :", benchmark.run[simd_float]().mean["ns"]())
    print("mlir_ops      :", String(cost_of[fn() capturing -> None, simd_float]()))
    print()
    print("simd_simd     :", benchmark.run[simd_simd]().mean["ns"]())
    print("mlir_ops      :", String(cost_of[fn() capturing -> None, simd_simd]()))
    print()