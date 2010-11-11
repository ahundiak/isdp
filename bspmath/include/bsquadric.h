/* Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved. */

# ifndef bsquadric_include
# define bsquadric_include

# define BSQUADRIC_UNUMPOLES 5
# define BSQUADRIC_VNUMPOLES 9

# define BSQUADRIC_NUMPOLES (BSQUADRIC_UNUMPOLES * BSQUADRIC_VNUMPOLES)

# define BSQUADRIC_UORDER 3
# define BSQUADRIC_VORDER 3

# define BSQUADRIC_UNUMKNOTS (BSQUADRIC_UNUMPOLES + BSQUADRIC_UORDER)
# define BSQUADRIC_VNUMKNOTS (BSQUADRIC_VNUMPOLES + BSQUADRIC_VORDER)

# endif /* bsquadric_include */
