class implementation EMSedge;

#include "EMS.h"
#define START 0
#define STOP 1
#define DEBUG 0
#define FROM_SPAN_INX 0
#define NO_SPANS 1

#include "emssfint.h"
#include "emsdef.h"
#include "emsmacros.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "EMSerrordef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "EMSbstrim.h"
#include "emsinterdef.h"
#include "OMmacros.h"

extern OMuword OPP_EMSlinedge_class_id;

method EMedbstrimint (IGRlong *EMmsg;
                      struct IGRbsp_curve *curve0;
                      IGRdouble *c0range;    
                      struct EMSpartolbasis *partol_basis;
                      struct EMSpartedinfo *partinfo;
                      IGRushort options;
                      IGRint *num_inters;
                      struct EMSsfintedpar **myinters;
                      struct EMSpypoint **polyinters)

/* **********************************************************************

 Description

         This method accepts a bspline geometry and trims it with respect
         to itself. The input arguments are as follows:
 
 Notes
         Mind you this routine accepts a 3d range in keeping with the fact
         that the uv bspline that it gets is also 3d with z=0. When we change
         to 2d we need to keep these things in mind.

         I doctored the main curve curve intersection routine of the math
         group to result in the following method. The rationale for doing
         this is for efficiency purposes.  Since, the 
         intersection curves in our case are planar, a lot of checks need
         not be performed. 

 PP : 08/12/88 : I was multiplying the tolerance with 0.01 in order
                 to process tangenciences more efficiently. But with
                 the code to handle ambiguous cases in place, I felt this
                 is not necessary and should be removed.
 PP   06/15/88 : Fixed a problem wherein I was assuming that all order 2
                 edges are going to be linear edges.
 PP : 02/17/88 : Fixed a problem wherein I was causing a stop_sending when
                 my_inters and poly_inters was NULL

 ************************************************************************ */


{

    IGRlong		status;
    GRobjid		dumid;

    IGRushort	edge_props;
    OMuword             bottom_classid;
    GRobjid             bottom_edgeid;
    IGRboolean		want_bnd_format = FALSE;
    IGRdouble 		uvlentol;
    struct IGRbsp_curve mygeom;
    struct EMSgetadjgeom adjgeom;

    IGRlong EMadjbs ();


    *EMmsg = EMS_S_Success;
    mygeom.poles = NULL;
    mygeom.weights = NULL;
    mygeom.knots = NULL;
    mygeom.bdrys = NULL;

    if (!partol_basis->is_valid)
    {
      status = om$send (msg = message EMSboundary.EMgetsurface_info (EMmsg,
                              &dumid, partol_basis),
                        targetid = my_id);
      EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_EdgeError, wrapup);
    }
/*
 * Get my active bspline geometry
 */
    status = om$send (msg = message EMSedge.EMgetbcgeom (EMmsg, FROM_SPAN_INX,
                            NO_SPANS, FALSE, partinfo, &mygeom,
                            partol_basis, NULL),
                      targetid = my_id);
    EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);


    if (partinfo)
     {
      adjgeom.this_edge = partinfo->edid;
      edge_props = partinfo->edprops;
     }
    else
     {
      adjgeom.this_edge = my_id;
      edge_props = ME.EMSedge->ed_props;
     }

    adjgeom.geninfo = NULL;

    status = om$send (msg = message EMSedge.EMget_bottom_edge (EMmsg,
                            &bottom_edgeid),
                      targetid = my_id);
    EMerr_hndlr (!(1&*EMmsg), *EMmsg, EMS_E_EdgeError, wrapup);
    
    status = om$get_classid (objid = bottom_edgeid,
                             p_classid = &bottom_classid);
    EMerr_hndlr (!(1&*EMmsg), *EMmsg, EMS_E_OMerror, wrapup);

    if (bottom_classid == OPP_EMSlinedge_class_id)
     want_bnd_format = TRUE;

    if (options & EMS_INTER_USECHTTOL)
      {
      IGRdouble chttol, lentol;
      
      BSEXTRACTPAR (EMmsg, BSTOLCHRDHT, chttol);
      BSEXTRACTPAR (EMmsg, BSTOLLENVEC, lentol);
      uvlentol = partol_basis->tol * (chttol / lentol);
      EMadjust_paramtol (EMmsg, NULL, uvlentol, &uvlentol);
      }
    uvlentol = partol_basis->tol;

    EMtrim_bspline_against_bspline (EMmsg, options, curve0, &mygeom,
          uvlentol, c0range,partinfo, want_bnd_format,
          edge_props, EMadjbs, &adjgeom, 
          num_inters, myinters, polyinters);
    EMerr_hndlr (!(1&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
  
    if (!myinters && !polyinters && (*num_inters))
    {
            status = OM_I_STOP_SENDING;
            goto wrapup;
    }
     
wrapup:

  if (mygeom.poles) free (mygeom.poles);
  if (mygeom.knots) free (mygeom.knots);
  if (mygeom.weights) free (mygeom.weights);
  if (mygeom.bdrys) free (mygeom.bdrys);

  EMWRAPUP (status, *EMmsg,"In EMSedge:EMedbstrimint error");
  return (status);

}

end implementation EMSedge;
