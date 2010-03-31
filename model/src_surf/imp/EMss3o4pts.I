/* ###################   APOGEE COMPILED   ################## */

class implementation EMSsubbs;

#include "EMS.h"

# include "msdef.h" /* MS message codes */
# include "msmacros.h"
# include "bserr.h"
#include "bssf3o4pts.h"
#include "bsptonnsdsf.h"

# define U_NUM_KNOTS 4
# define V_NUM_KNOTS 4
# define U_NUM_POLES 2
# define V_NUM_POLES 2

method EM3o4pts(IGRlong *EMmsg;
                   IGRpoint vtx1, vtx2, vtx3 , vtx4;
                   IGRpoint point_in_solid;
                   struct GRvg_construct *construct_list)

/*******************************************************************

Description

       This method constructs a triangle if given three points or
       a rectangular/parallogram plane if given four points. It also
       set the pos_orient bit of the surface if a point_in_solid
       is coming in. If the caller is not interested in orienting the
       surface, he/she  should set the point_in_solid to NULL.
       If there are only three vertices, then the fourth vertex needs to
       be set to NULL.


       Input
         vtx1,
         vtx2,
         vtx3,
         vtx4              -     vertices
         point_in_solid    -     point lying on the solid side of
                                 the surface.
         construct_list    -     construction information

       Output
         EMmsg             -     pointer to completion code

Notes:
 
       Upon exit the completion code will be one of the following:

         MSSUCC        -     if successful in constructing a plane
         MSINARG        -     if the points inputted are invalid.
                                 If four points are being inputted, the
                                 four points need to form a convex polygon.

       If there are only three vertices, the fourth vertex is set to null.


Algorithm 

1. Allocate memory for the surface structure according to the following
   guideline.
    no of u knots = 4
    no of v knots = 4
    no of poles = 2

    surface is not rational

2. Call the math routine appropriately

3. Initialise the element specific attributes and send a GRconstruct
   message to myself.

History

    Sudha 07/07/93  : Modified for BSprototypes ansification
    rlw : 09/13/88  : Modified not to print out if EMmsg is EMS_S_Success
    AIC : 15-Jul-87 : Do not generate element specific attributes.
    PP  : 01/18/87  : The object commits suicide if it encounters an error
    PP  : 01/01/87  : design date



****************************************************************/ 
 
{

 IGRlong                status;            /* OM return status */
 BSrc                   rc;                /* Math return code */
 IGRboolean             nat_side;          /* true if a given point lies
                                              on the natural side of the
                                              surface
  
                                              false otherwise */

 IGRdouble              u_knots[U_NUM_KNOTS];
 IGRdouble              v_knots[V_NUM_KNOTS];

 IGRpoint               poles[U_NUM_POLES][V_NUM_POLES];

 IGRchar                str[EMMAXERRMSG_LEN];
 IGRlong		cln_sts;

 struct IGRbsp_surface  surf; 


/* **************************************

   Initialisation

   ************************************** */

 *EMmsg = MSSUCC;
 status = OM_S_SUCCESS;
 strcpy(str, "EMSsubbs.EM3o4pts");

 surf.poles = (IGRdouble *)poles;
 surf.u_knots = (IGRdouble *)u_knots;
 surf.v_knots = (IGRdouble *)v_knots;
 surf.weights = NULL;
 surf.bdrys = NULL;
 
 
 (void) BSsf3o4pts (vtx1, vtx2, vtx3, vtx4, &surf, &rc);
 EMerr_hndlr_action(rc != BSSUCC, *EMmsg, MSINARG, goto wrapup)

 if (point_in_solid)
 {
 (void) BSptonnsdsf (&surf, point_in_solid, &nat_side, &rc);
 EMerr_hndlr_action(rc != BSSUCC, *EMmsg, MSINARG, goto wrapup)

 if (nat_side)
  surf.pos_orient = 1;
 else
  surf.pos_orient = 0;
 }

 construct_list->geometry = (IGRchar *)&surf;

 status = om$send (mode = OM_e_wrt_object,
                   msg = message GRgraphics.GRconstruct(construct_list),
                   senderid = my_id,
                   targetid = my_id);
 EMomerr_hndlr_action(status, goto wrapup, "return from GRconstruct")

wrapup:
/*
 * If there was any error in GRconstruct the method should have taken
 * care of cleanup from r-tree because there is no way of knowing whethere
 * r-tree range has been posted or not. 
 * Therefore I am always sending a root.delete message to myself, if I
 * encounter an error all the time. Sending a GRgraphics.GRdelete message
 * to myself causes problems if the geometry has not been posted
 */

 if (!(1&status&*EMmsg))
 {
  cln_sts = om$send (msg = message Root.delete(1),
                     targetid = my_id);
 }
 EMomerr_hndlr_action(status, om$report_error(sts = status), str)
 EMerr_hndlr_action((! (1 & *EMmsg)),*EMmsg,*EMmsg,EMreport_error(*EMmsg,str))
/*
 EMerr_hndlr_action(*EMmsg != MSSUCC,*EMmsg,*EMmsg,EMreport_error(*EMmsg,str))
 */
 return (status);

}

end implementation EMSsubbs;
