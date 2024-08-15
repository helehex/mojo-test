There is a bug when using top-level `var` with `DLHandle` to link to a library from a packaged binary.

Everything works fine when you run `mojo top_level_var_bug/test_src.mojo`

But, if you first package the code, and run `mojo top_level_var_bug/test/test_pkg.mojo`, you get a segfault.

The alternative approach would be to carry the library around in the code and keep track of it's lifetime. Doing that seems to work even with packaged code, but it's not very nice todo.

The example here uses sdl, because thats what i was trying to get working.