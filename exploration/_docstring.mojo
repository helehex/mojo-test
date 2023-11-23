from builtin import simd

let a: SIMD[DType.index,1] = 1

fn hover_me[a: Int](b: String) -> AnyType:
    """
    Docstring example.

    Parameters:
        a: An integer.

    Args:
        b: A string.

    Returns:
        AnyType, quite literally.

    """
    return AnyType

fn now_hover_me():
    """
    Exploring docstring formatting. This is normal unindented text.

    ---

    (https://helehex.net/)

    ---

    # H
    ## H
    ### H
    #### H
    ##### H
    ###### H

    ---

    Code:

        #Indented acts like code.
        @parameter
        for i in range(1, 2):
            let a: Int = 5
    \tprint(6)

    ---

    *italics*

    **Bold**

    __Bold__

    ~Strikethrough~

    `Inside of box.`

    > Long indent.
    
    ---

    List items:

    - Bullet
    - Bullet
    * Bullet
    * Bullet
    + Bullet
    + Bullet
    1) Item
    2) Item
    3. Item
    4. Item

    ---

    \"Double quotes.\"
    
    \'Single quotes.\'

    Section
    ------------

    Bigger
    ============
    """
    pass