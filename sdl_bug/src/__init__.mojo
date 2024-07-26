from sys import ffi as _ffi
var _sdl = _ffi.DLHandle('/lib/x86_64-linux-gnu/libSDL2-2.0.so')

var _init = _sdl.get_function[fn(flags: UInt32) -> Int32]('SDL_Init')
var _quit = _sdl.get_function[fn() -> None]('SDL_Quit')