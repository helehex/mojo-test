
# theres only one way to arrange zero things now
fn main():
     #alias a: Int = factorial(6)
     print(factorial(0))



from algorithm.functional import unroll
alias constrain: Bool = False

fn factorial[n: Int]() -> Int:
    var result: Int = 1

    @parameter
    fn product[i: Int]():
        alias m: Int = i + 2
        result *= m

    alias count = n - 1
    unroll[count, product]()
    constrained[constrain == False or n >= 0, "negative integer factorial is undefined"]()
    return result

fn factorial(n: Int) -> Int:
    var result: Int = 1
    for i in range(2, n+1): result *= i
    return result

fn arithmetic[n: Int, d: Int]() -> Int:
    var result: Int = n

    @parameter
    fn product[i: Int]():
        alias m: Int = n - (d + 1)
        result *= m

    alias count = d - 1
    unroll[count, product]()
    return result

#n(n-1)(n-2)(n-3)..(n-d-1)/d!
fn simplicial[n:Int, d: Int]() -> Int:
    return arithmetic[n,d]()//factorial[d]()






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