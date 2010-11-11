/* Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved. */

# ifndef bsisfprtlns_include
# define bsisfprtlns_include

# ifndef igrtypedef_include
#   include "igrtypedef.h" /* IGR types */
# endif

struct BSpartgrp
 {
    IGRint      num;                     
    IGRpoint    *pts;
    BSpair      *par;
    struct BSpartgrp *next;
 };

struct BSpartseg
 {
    IGRint          num;
    IGRpoint        *pts;
    BSpair          *par;
    IGRint          connect;
    IGRboolean      reverse;
    struct BSpartseg  *next;
 };

# endif /* bsisfprtlns_include */
