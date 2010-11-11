/* Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved. */

# ifndef bsdiag_include
# define bsdiag_include

/*
The vms standard C library's fscanf returns 0 when an ASCII 0 is
read via a %x format.  Nasty, huh?  That is why READHEX might be
zero.  If it is not, bsreadhex.c has a kluge which gets around
the problem.
*/

# if vms || __vms || __vms__
#    define HARDWARE "VAX"
# endif

# ifdef CLIX
#    define READHEX 1
#    define WRITEHEX 1
#    define HARDWARE "clipper"
# endif

# ifdef SUNOS
#    define READHEX 1
#    define WRITEHEX 1
#    define HARDWARE "sun"
# endif

# ifdef SUNOS5
#    define READHEX 1
#    define WRITEHEX 1
#    define HARDWARE "sun"
# endif

# ifdef IRIX
#    define READHEX 1
#    define WRITEHEX 1
#    define HARDWARE "sgi"
# endif

# ifdef BOSX
#    define READHEX 1
#    define WRITEHEX 1
#    define HARDWARE "ibm"
# endif

# ifdef HPUX
#    define READHEX 1
#    define WRITEHEX 1
#    define HARDWARE "hp"
# endif

# ifdef NT
#    define READHEX 1
#    define WRITEHEX 1
#    define HARDWARE "nt"
# endif

# ifndef WRITEHEX
# define WRITEHEX 0
# endif

# ifndef READHEX
# define READHEX 0
# endif

# define DONT 0
# define CORRECTMACHINE 1
# define WRONGMACHINE 2

# endif /* bsdiag_include */
