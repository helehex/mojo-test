import pkg

# to package, run:
# `mojo package -o top_level_var_bug/test/pkg.mojopkg  top_level_var_bug/src`

def main():
    print(pkg.top_level[])