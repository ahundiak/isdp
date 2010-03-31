/* ###################   APOGEE COMPILED   ################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:  EMStorus
     METHOD NAME:  EMtorus_by_axis_center_radius

     Abstract: 
        This method constructs torus, given two points defining
     the axis, the center of the basis circle, and the radius or
     a point defining the radius of the basis circle.
-----
%SC%    
     EMtorus_by_axis_center_rad( arglist, pnt1, pnt2, center, radius )
-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   ------------------------------------
     *arglist     GRvg_construct construct argument
     pnt1, pnt2   IGRpoint       points that defines the axis of rotation
     center       IGRpoint       center point of the basis circle
     *radius      struct EMSradius       radius or radius point 

     NOTE: (1) struct EMSradius {
                   IGRlong  select;     * 0 if radius is to be used;*
                                        * otherwise, radius pnt is. *
                   union {
                       IGRpoint pnt;    * radius point *
                       IGRdouble value;
                    }input;
                };
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------

-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules: 
        BStoraxctpt, BStoraxctrd, OM_send_object

     Methods:
        GRconstruct, delete
-----
%RL%

     RELATIONS REFERENCED:  none.
-----
%NB%

     NOTES: 
        The return code in the input argument list can have the 
        following values:

                MSSUCC - successfull
                MSFAIL - if failure
                BSINVAXIS - if axis is ill-defined
                BSFAIL - if radius is too small or circle is too
                         close to axis
                GRSNOINVTRAN - if input matrix is not invertible
                GRSDGNEXCEED - if range exceeds design limits

        Note that if an error occurs then the object is deleted.
-----
%CH%

     CHANGE HISTORY:

    AIC : 15-Jul-87 : Do not generate element specific attributes.

        LST     10/02/86                the beginning
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------


----*/
/*EH*/

class implementation EMStorus;

#include "EMS.h"
#include "msdef.h"
#include "bserr.h"
#include "OMerrordef.h"

#define TRUE    1
#define FALSE   0

method EMtorus_by_axis_center_rad( struct GRvg_construct *arglist;
       IGRpoint pnt1, pnt2, center; struct EMSradius *radius )
{
    extern void BStoraxctrd();
    extern void BStoraxctpt();
    IGRboolean  sts;
    IGRdouble   poles[49][3], weight[49], u_knots[10], v_knots[10];
    struct      IGRbsp_surface torus;
/*
 *  Initialization
 */
    *(arglist->msg) = MSSUCC;
/*
 *  Get the surface definition
 */
    torus.poles   = (IGRdouble *) poles;
    torus.weights = (IGRdouble *) weight;
    torus.u_knots = (IGRdouble *) u_knots;
    torus.v_knots = (IGRdouble *) v_knots;
    if( radius->select == 0 ) /* radius value is to be used */
        BStoraxctrd( radius->input.value, center, pnt1, pnt2, 
              &torus, arglist->msg );
    else /* radius point is to be used */
        BStoraxctpt( radius->input.pnt, center, pnt1, pnt2, 
              &torus, arglist->msg );
    if( *(arglist->msg) == BSSUCC ) *(arglist->msg) = MSSUCC;
    else {
        sts = om$send(mode = OM_e_wrt_object,
                      msg = message Root.delete(1),
                      senderid = my_id,
                      targetid = my_id );
        return( OM_E_ABORT );
    }
    /* fix for umr */
    torus.pos_orient = 0;
    arglist->geometry = (IGRchar *) &torus;

/*
 *  Fill the instance data and such
 */
    sts = om$send(mode = OM_e_wrt_object,
                  msg = message GRgraphics.GRconstruct(
          arglist),
                  senderid = my_id,
                  targetid = my_id );
    if( !( 1 & sts ) ){
        sts = om$send(mode = OM_e_wrt_object,
                      msg = message Root.delete(1),
                      senderid = my_id,
                      targetid = my_id );
        return( OM_E_ABORT );
    }
/*
 *  End of routine
 */
    return( OM_S_SUCCESS );
 }

end implementation EMStorus;
