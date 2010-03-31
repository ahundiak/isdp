/* ###################   APOGEE COMPILED   ################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:  EMScylinder
     METHOD NAME:  EMcylinder_by_axis_n_radius

     Abstract: 
        This method constructs cylinder by axis points and radius or
     radius point whose distance from the axis is taken as the
     radius.
-----
%SC%    
     EMcylinder_by_axis_n_radius( arglist, pnt1, pnt2, radius )
-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   ------------------------------------
     *arglist     GRvg_construct construct argument
     pnt1, pnt2   IGRpoint       points that defines the axis of rotation
     *radius      struct EMSradius       radius or radius point whose distance
                                 from the axis is taken as radius
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
        BScylinder1, BScylinder3, OM_send_object

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
                MSINARG - if points given are too close together or 
                          radius is not positive
                GRSNOINVTRAN - if input matrix is not invertible
                GRSDGNEXCEED - if range exceeds design limits

        Note that if an error occurs then the object is deleted.
-----
%CH%

     CHANGE HISTORY:

    AIC : 15-Jul-87 : Do not generate element specific attributes.
        lst     9/30/86         the beginning
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------


----*/
/*EH*/

class implementation EMScylindr;

#include "EMS.h"
#include "msdef.h"
#include "bserr.h"
#include "OMerrordef.h"

#define TRUE    1
#define FALSE   0

method EMcylinder_by_axis_n_radius( struct GRvg_construct *arglist;
       IGRpoint pnt1; IGRpoint pnt2; struct EMSradius *radius )
{
    extern IGRboolean       BScylinder1();
    extern void             BScylinder3();
    IGRboolean              sts;
    IGRdouble               poles[14][3], weight[14],
                            u_knots[10], v_knots[4];
    struct IGRbsp_surface   cylinder;
/*
 *  Initialization
 */
    *(arglist->msg) = MSSUCC;
/*
 *  Get the surface definition
 */
    cylinder.poles   = (IGRdouble *) poles;
    cylinder.weights = (IGRdouble *) weight;
    cylinder.u_knots = (IGRdouble *) u_knots;
    cylinder.v_knots = (IGRdouble *) v_knots;
    cylinder.pos_orient = 0; /* fix for umr */
    if( radius->select == 0 ) /* radius value is to be used */
        sts = BScylinder1( arglist->msg, pnt1, pnt2, &radius->input.value,
              &cylinder );
    else /* radius point is to be used */ {

        BScylinder3( pnt1, pnt2, radius->input.pnt, &cylinder,
              arglist->msg );

        /*
            BScylinder3 is a void function, but it was being
            invoked as sts = BScylinder3(... so I am setting
            sts = TRUE here.    23 Sep 1988 AIC
        */
        sts = TRUE;
    }
    if( *(arglist->msg) == BSSUCC ) *(arglist->msg) = MSSUCC;
    else *(arglist->msg) = MSINARG;
    if( !sts ){
        *(arglist->msg) = MSFAIL;
        sts = om$send(mode = OM_e_wrt_object,
                      msg = message Root.delete(1),
                      senderid = my_id,
                      targetid = my_id );
        return( OM_E_ABORT );
    }
    arglist->geometry = (IGRchar *) &cylinder;

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

end implementation EMScylindr;
