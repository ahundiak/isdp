/* Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved. */

# ifndef bssfsf_int2_include
# define bssfsf_int2_include

# ifndef igrtypedef_include
#   include "igrtypedef.h" /* IGR types */
# endif

struct BSplsfintgrp
 {
    IGRint    num;                     
    IGRpoint  *pts;
    IGRvector *tans;
    BSpair    *par;
    struct BSplsfintgrp *next;
 };
struct BSintgrp2
 {
    IGRint    num;                     
    IGRpoint  *pts;
    BSpair    *par1, *par2;
    struct BSintgrp2 *next;
 };

struct BSprjgrp
 {
    IGRint    num;                     
    IGRpoint  *pts;
    IGRdouble *u1, *v1;
    struct BSprjgrp *next;
 };

struct BSlnseg
 {
    IGRint          num;
    IGRpoint        *pts;
    BSpair          *par1, *par2;
    IGRint          connect;
    IGRboolean      reverse;
    struct BSlnseg  *next;
 };

struct BStree_ptr
 {
    IGRboolean  over;
    IGRint      n_next;
    IGRpoint    rng[2];
    IGRint      next[4];
 };

# endif /* bssfsf_int2_include */
