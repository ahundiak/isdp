/*

Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved.

   BSparameters.h, BSextractpar.c, BSglobals.c and BSchangepar.c are very
   interdependent with one another.  If one is significantly modified,
   odds are all should be.  It is almost certain BSglobals.c and
   BSparameters.h will need to be altered simultaneously.

   Included in this file (adjacent to the appropriate tolerance) are
   the preferred tolerance names to be used inside your routine.

    CHANGE HISTORY:
        
    16-Jan-1986  :  Creation date; J. Brooke King, author. (JBK)
    11-Mar-1986  :  Added BSVALQNWT and BSVALMAXSTEP
    21-May-1987  :  Added BSVALRHO
    15-Sept-1987 :  Added BSVALOVERLAP
    17-Nov-1987  :  Added BSVALCVORD2_OVERLAP
    18-Nov-1987  :  Added macro BSIEXTRACTPAR to extract integer values
    03-Feb-1989  :  Changed default chrdht_tol and off_tol to 1.0e-2.
    20-Apr-1993  :  Addition of pointer indirection for NT DLL's.
    11-Apr-1997  :  For NT, use __declspec(dllimport) to add extra indirection.
*/

# ifndef bsparameters_include
# define bsparameters_include

# ifndef igrtypedef_include
#   include "igrtypedef.h"
# endif

# define BSBASISVAL    (1e-6)   

/*
a tolerance against which to test the nearness of a triple product with
zero  -- (trpl_tol)
 */
# define BSTOLTRPLPROD 0  
# define BSVALTRPLPROD (.5 * BSBASISVAL)

/*
   a tolerance against which to test the nearness of a vectors length
   with zero -- (dist_tol)
 */
# define BSTOLLENVEC 1
# define BSVALLENVEC BSBASISVAL

/*
   a tolerance against which to test the nearness of a vectors squared
   length with zero -- (dist_sqtol)
 */
# define BSTOLSQLENVEC 2
# define BSVALSQLENVEC (BSVALLENVEC * BSVALLENVEC)

/*
   a tolerance against which to test the absolute value of a dot products
   of two vectors to see if if they are orthogonal -- (dot_tol)
 */
# define BSTOLORTHOVEC 3
# define BSVALORTHOVEC (.5 * BSBASISVAL)

/*
   a tolerance against which to test the absolute value of the length of
   the cross product of two vectors to see if they are collinear -- 
   (cross_tol)
 */
# define BSTOLCOLLINVEC 4
# define BSVALCOLLINVEC (.5 * BSBASISVAL)

/*
   a tolerance against which to test the absolute value of the length of
   the cross product of two vectors to see if they are collinear -- 
   (cross_sqtol)
 */
# define BSTOLSQCOLLINVEC 5
# define BSVALSQCOLLINVEC (BSVALCOLLINVEC * BSVALCOLLINVEC)
/*
   incidentally, it would be more efficient to test the absolute value of
   the 1 subtracted from the absolute value of the dot product -- if and
   only if the dotted vectors happened to be unit vectors; it would be
   grossly inefficient to make them unit vectors JUST for this reason,
   however
 */

/*
   a tolerance for detection of end-of-interation conditions and the 
   difference between parameter values -- (par_tol)
 */
# define BSTOLPARAM 6
# define BSVALPARAM (1e-3 * BSBASISVAL)

/*
   a tolerance specifically for BSconicgen4 and anyone else who does such
   bizarre things  -- (conic_tol)
 */
# define BSTOLCONICGENCIRCLE 7
# define BSVALCONICGENCIRCLE (BSBASISVAL)

/*
   a tolerance for detection of end-of-interation conditions and the 
   difference between knot values -- (knot_tol)
 */   
# define BSTOLKNOT 8
# define BSVALKNOT BSBASISVAL

/*
   all points on an offset curve will be within this tolerance of
   the points on the exact offset curve -- (offset_tol)
 */
# define BSTOLOFFSET 9
# define BSVALOFFSET 1e-3

/*
   chord height tolerance -- (chrdht_tol)
 */
# define BSTOLCHRDHT 10
# define BSVALCHRDHT 1e-3

/*
   rational chord tolerance -- (ratchrd_tol)
 */
# define BSTOLRATCHRD 11
# define BSVALRATCHRD 1e-2

/*
   wouldn't you know it.  i forgot to give a way to get BSBASISVAL.
   maybe good.  here is an indirect way. -- (basis_tol)
 */
# define BSTOLBASIS 12
# define BSVALBASIS BSBASISVAL

/*
   the tolerance used to end the iteration in BSqnwt -- (qnwt_tol)
 */
# define BSTOLQNWT 13
# define BSVALQNWT BSBASISVAL*1e-1

/*
   the maximum step size of intersection points on a surface -- (step_tol)
 */
# define BSTOLMAXSTEP 14
# define BSVALMAXSTEP 0.25

/*
   tolerance for calculating arclength -- (arclen_tol)
 */
# define BSTOLARCLEN 15
# define BSVALARCLEN 1e-3

/* 
  tolerance for values close to zero
 */
# define BSTOLCLOSETOZERO 16
# define BSVALCLOSETOZERO (BSBASISVAL * BSBASISVAL / 100.0)

/*
   default rho value
 */
# define BSRHO_VALUE 17
# define BSVALRHO .41421356237309504880

/*
   default overlap value   (overlap_tol)
 */
# define BSTOLOVERLAP 18
# define BSVALOVERLAP (BSBASISVAL)

/*
   be sure BSNUMPARAMETERS alway reflects the number of floating point
   parameters named here
 */
# define BSNUMPARAMETERS 19

/*
   start of integer parameters
 */
 
/*
   a basic complexity factor -- (basis_plex)
 */

# define BSBASISCOMPLEXITY     0
# define BSVALBASISCOMPLEXITY  100

/*
   this value multiplied by the order of each of two spans is the
   maximum number of (redundant) intersections that can be found
   between the two spans (max_spn_int)
 */
 
# define BSMAXSPNINT    8
# define BSPLXMAXSPNINT 1
# define BSVALMAXSPNINT 8

/*
   this value is an indicator for BScvcvint: it is used in the
   line intersection routines to determine if overlaps are
   desired
*/

# define BSCVORD2_OVERLAP  2
# define BSVALCVORD2_OVERLAP 1

# define BSNUMIPARAMETERS 3

#if defined (BSNTDLL)
#define BSDATAIMPORT __declspec(dllimport)
#else
#define BSDATAIMPORT
#endif

  extern BSDATAIMPORT IGRdouble BSparameters[BSNUMPARAMETERS];

# ifdef BSVOID
# define BSEXTRACTPAR( long_rc_addr, name, tol )                         \
  (                                                                      \
      (name) >= 0 && (name) < BSNUMPARAMETERS ?                          \
          ((tol) = BSparameters[(name)], *(long_rc_addr) = BSSUCC)       \
      :                                                                  \
      (*(long_rc_addr) = BSINVPRNAME)                                    \
  )
# else /* BSVOID */
# define BSEXTRACTPAR( long_rc_addr, name, tol )                         \
  (                                                                      \
      (name) >= 0 && (name) < BSNUMPARAMETERS ?                          \
          ((tol) = BSparameters[(name)], *(long_rc_addr) = BSSUCC, TRUE) \
      :                                                                  \
      (*(long_rc_addr) = BSINVPRNAME, FALSE)                             \
  )
# endif /* BSVOID */

extern BSDATAIMPORT IGRint BSiparameters[BSNUMIPARAMETERS];

# ifdef BSVOID
# define BSIEXTRACTPAR( long_rc_addr, name, tol )                        \
  (                                                                      \
      (name) >= 0 && (name) <= BSNUMIPARAMETERS ?                        \
          ((tol) = BSiparameters[(name)], *(long_rc_addr) = BSSUCC)      \
      :                                                                  \
      (*(long_rc_addr) = BSINVPRNAME)                                    \
  )
# else /* BSVOID */
# define BSIEXTRACTPAR( long_rc_addr, name, tol )                        \
  (                                                                      \
      (name) >= 0 && (name) < BSNUMIPARAMETERS ?                         \
          ((tol) = BSiparameters[(name)], *(long_rc_addr) = BSSUCC, TRUE)\
      :                                                                  \
      (*(long_rc_addr) = BSINVPRNAME, FALSE)                             \
  )
# endif /* BSVOID */

/* Fixed definition(s) */

/* NONE AT PRESENT */

# endif /* bsparameters_include */

/* Maximum Legendre interpolation degree.   */

#define MAXLGDEG 320

#define MAXLGTABDEG 320

#define MAXSMTABDEG 40
