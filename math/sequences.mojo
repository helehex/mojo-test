
# theres only one way to arrange zero things now
fn main():
    alias a: IntLiteral = factorial[40]()//factorial[39]()
    let b: Int = simplicial(2, 6)
    print(a)
    print(b)
    print(pascal(12,6)) # 924

fn factorial[n: IntLiteral]() -> IntLiteral:
    var result: IntLiteral = 1
    var i: IntLiteral = 2
    while i < n+1:
        result *= i
        i += 1
    return result

fn factorial(n: Int) -> Int:
    var result: Int = 1
    for i in range(2, n+1): result *= i
    return result

fn permutial[n: IntLiteral, r: IntLiteral]() -> IntLiteral:
    alias start = (n-r) + 1
    var result: IntLiteral = 1
    var i: IntLiteral = start
    while i < n+1:
        result *= i
        i += 1
    return result

fn permutial(n: Int, r: Int) -> Int:
    var result: Int = 1
    for i in range((n-r)+1, n+1): result *= i
    return result

fn simplicial[d: IntLiteral, n: IntLiteral]() -> IntLiteral:
    return permutial[n, d]()//factorial[d]()

fn simplicial(d: Int, n: Int) -> Int:
    return permutial(n, d)//factorial(d)

fn pascal[n: IntLiteral, r: IntLiteral]() -> IntLiteral:
    return permutial[n, r]()//factorial[r]()

fn pascal(n: Int, r: Int) -> Int:
    return permutial(n, r)//factorial(r)





from algorithm.functional import unroll
alias constrain: Bool = False
'''
fn factorial[n: IntLiteral]() -> IntLiteral:
    var result: IntLiteral = 1

    @parameter
    fn product[i: Int]():
        alias m: Int = i + 2
        result *= m

    alias count = n - 1
    unroll[count, product]()
    constrained[constrain == False or n >= 0, "negative integer factorial is undefined"]()
    return result
'''
'''
from algorithm.functional import unroll
alias constrain: Bool = False

fn factorial[n: Int]() -> Int:
    var result: Int = 1

    @parameter
    fn mul[i: Int]():
        alias m: Int = i + 2
        result *= m

    alias count = n - 1
    unroll[count, mul]()
    constrained[constrain == False or n >= 0, "negative integer factorial is undefined"]()
    return result

fn factorial2[n: Int]() -> Int:
    var result: Int = 1
    @parameter
    if n > 1:
        @unroll
        for i in range(2, n+1): result *= i
    return result

@always_inline
fn factorial3[n: IntLiteral]() -> IntLiteral:
    @parameter
    if n < 2:
        return IntLiteral(1)
    return n*factorial3[n-1]()
'''

# array stuff?
# auto table lookup generation for runtime?