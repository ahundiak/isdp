/* Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved. */

#ifndef mastruct_include
#define mastruct_include

# ifndef igrtypedef_include
#   include "igrtypedef.h"
# endif

# ifndef igr_include
#   include "igr.h"
# endif

/* 
*   cubic polynomial
*/
struct MAcoef
{
    IGRdouble   ax;             /* coefficients for the cubic to */
    IGRdouble   bx;             /* define the 'x' values.        */
    IGRdouble   cx;
    IGRdouble   dx;

    IGRdouble   ay;             /* coefficients for 'y' cubic   */
    IGRdouble   by;
    IGRdouble   cy;
    IGRdouble   dy;

    IGRdouble   az;             /* coefficients for 'z' cubic   */
    IGRdouble   bz;
    IGRdouble   cz;
    IGRdouble   dz;
};


struct  MAinformation_coef
{
    struct      MAcoef *c;
    IGRdouble   *pt;
};


struct MAinformation                     /* input data for f_of_u      */
{
         IGRlong             *msg;       /* return code                */
         IGRdouble           *pt;        /* point on ln                */
         struct IGRbsp_curve *bc;        /* the curve                  */
         IGRdouble           cos_alpha;  /* cosine of alpha            */
         IGRdouble           range[2];   /* valid u par range          */
         IGRboolean          cyclic;     /* cyclic curve flag          */
         IGRdouble           usearch;    /* % of range used for bad u  */
                                         /* adjustment                 */
};


struct MAinfo_struct
{
    struct IGRbsp_curve *bez;
};


struct MAinfo_struct_ln                 /* information structure        */
                                        /* to be sent to MAqnewton and  */
                                        /* back to the static function  */
                                        /* matrix_function in this file */
{
        struct IGRbsp_curve *curve;     /* pointer to curve structure   */
        struct IGRline *line;           /* pointer to line structure    */
};


struct MAinfo_struct_pt                 /* information structure        */
                                        /* to be sent to MAqnewton and  */
                                        /* back to the static function  */
                                        /* matrix_function in this file */
{
        struct IGRbsp_curve *curve;     /* pointer to curve structure   */
        IGRdouble *point;               /* pointer to point             */
};


struct MAinfo                           /* for function evaluator       */
{
         IGRlong *messg;
         struct IGRbsp_curve *bc1;
         struct IGRbsp_curve *bc2;
         IGRdouble cos_alpha1;
         IGRdouble cos_alpha2;
         IGRdouble low[2];
         IGRdouble high[2];
         IGRboolean cyclic[2];
         IGRboolean usearch[2];
};


#endif /* mastruct_include */
