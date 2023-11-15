fn main():
    import random

    # range is inclusive for both min and max

    # these are unseeded, these will be the same each time you run this file
    # the first unseeded integer seems to always give min
    print(random.random_ui64(0,10))
    print(random.random_si64(-10,10))
    print(random.random_float64(0,3.14))

    # after you call seed, they will be different each time you run this file
    random.seed()
    print(random.random_ui64(0,10))
    print(random.random_si64(-10,10))
    print(random.random_float64(0,3.14))