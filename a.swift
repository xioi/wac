
func foo( _ x: Int, cb: (Int) -> Int) {
    print( cb( x))
}

foo( 2) { x in
    return x * 2
}
