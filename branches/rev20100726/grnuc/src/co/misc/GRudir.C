/*
Name
        GRudir

Description
        This edge patterning function accepts the start, end, and direction
        points of a curve and determines whether the pattern direction is in
        ascending or descending u-parameter order.  In addition, it will 
        determine whether the pattern will cross the uparm=0 point on the 
        curve.  

Algorithm
        If the curve is open, the start and end u-parameters are compared
        to determine direction.  For closed curves, the start, direction,
        end, and u = 0.0 parameters are compared.  There are six unique
        orderings possible for these four values on closed curves.
        They are:

                1)  zero - start - direction - end      (ascending)
                2)  zero - direction - end - start      (ascending)
                3)  zero - end - start - direction      (ascending)
                4)  zero - start - end - direction      (descending)
                5)  zero - direction - start - end      (descending)
                6)  zero - end - direction - start      (descending)

Synopsis
        IGRint GRudir (msg, curve, start, dir, end, ascending, cross)

        IGRlong                 *msg;           o return code
        struct IGRbsp_curve     *curve;         i curve to pattern
        IGRdouble               *start;         i start parameter
        IGRdouble               *dir;           i direction parameter
        IGRdouble               *end;           i stop parameter
        IGRshort                *ascending;     o flag indicating direction
        IGRshort                *cross;         o flag indicating if pattern
                                                  crosses uparm = 0 point on
                                                  curve.      

Return Values
        on success, () == TRUE, *msg == MSSUCC, *ascending indicates direction;
        on failure, () == FALSE, *msg == MSFAIL, *ascending == -1

History
        mrm     05/25/88    creation
        jjc     04/25/91    modified from GRepudir to calculate 0/1 overlaps 
*/

#include "grimport.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "msdef.h"

IGRint GRudir (msg, curve, start, dir, end, ascending, cross)

IGRlong                 *msg;           /* o return code */
struct IGRbsp_curve     *curve;         /* i curve to pattern */
IGRdouble               *start;         /* i start parameter */
IGRdouble               *dir;           /* i direction parameter */
IGRdouble               *end;           /* i stop parameter */
IGRshort                *ascending;     /* o flag indicating direction */
IGRshort                *cross;         /* o flag indicating if pattern
                                             crosses uparm=0 point on curve */ 

{
    IGRdouble           z = 0.0;        /* zero, start, direction, & end u */

    *msg = MSSUCC;

    if (!curve->phy_closed)
    {
        *ascending = ( *start <= *end );
        *cross = FALSE;
    }
    else
    {
        if ( z <= *start && *start <= *dir && *dir <= *end )
          {
              *ascending = TRUE;
              *cross = FALSE;           
          } 
        else if ((z <= *dir && *dir <= *end   && *end   <= *start) ||
                 (z <= *end && *end <= *start && *start <= *dir))
                  {
                    *ascending = TRUE;
                    *cross = TRUE;
                  }
        else if (( z <= *start && *start <= *end   && *end   <= *dir ) ||
                 ( z <= *dir   && *dir   <= *start && *start <= *end ))
                  {
                    *ascending = FALSE;
                    *cross = TRUE; 
                  }
        else if ( z <= *end && *end <= *dir && *dir <= *start )
               {
                 *ascending = FALSE;
                 *cross = FALSE;
               }
        else
        {
            *ascending = -1;
            *cross = -1;
            *msg = MSFAIL;
        }
    }

    return (*msg == MSSUCC);
}
