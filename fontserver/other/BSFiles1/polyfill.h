
/*
 *   File:  POLYFILL.H
 */

/*****  DATA STRUCTURES:  *****
 *
 *  XI_LE -- List element from a list of x-intercept data
 *           For a given y, where y marks the center of a pixel, there is a
 *           sorted list of all x-intercepts for the active character.
 *      XINT -- x-intercept, range -32768 - +32767.999985. The high 16-bits
 *              are the integer part; the low 16 bits are the fractional part.
 *      XINT_NX -- pointer to next x-intercept for the same value of y, or 0
 */

typedef
struct  xi
    {
    fix31   intc;               /* x- or y-intercept, with 16 fraction bits */
    struct xi  *int_next;       /* pointer to next one, or 0 */
    }   xi_le;                  /* x- or y-intercept list element */



typedef
struct
    {
    fix31   xx;                 /* endpoint x-coordinate */
    fix31   yy;                 /* endpoint y-coordinate */
    fix31   bugfat;             /* bulge-factor, 32-bit signed fraction */
    }   arc_type;



typedef  struct
    {
    real    xx;                 /* ordered pair */
    real    yy;
    fix15   level;              /* recursion level in arc splitting */
    }
    vector_data;


typedef  struct
    {
    float   xoff;               /* ordered pair */
    float   yoff;
    float   xscale;             /* actual scaling */
    float   yscale;
    float   xscale_nom;         /* nominal scaling */
    float   yscale_nom;
    ufix16 *pc;                 /* program counter */
    }
    stack_frame;



typedef
struct
    {
    fix31   xmin;               /* minimum x extent */
    fix31   xmax;               /* maximum x extent */
    fix31   ymin;               /* minimum y extent */
    fix31   ymax;               /* maximum y extent */
    }   ext_grp;
