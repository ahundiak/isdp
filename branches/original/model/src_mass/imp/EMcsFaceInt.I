/* ###################   APOGEE COMPILED   ################## */
class implementation EMScompsurf;

#include "EMS.h"
#include "bserr.h"
#include "emsmass.h"
#include "EMSlogic.h"
#include "EMScmacros.h"

method EMfaceintgrl(IGRlong                   *msg;
                    IGRboolean                want_status;
                    IGRboolean                new_tiler;
                    IGRint                    *surf_inx;
                    IGRint                    num_surfaces;
                    struct GRmd_env           *my_env;
		            struct IGRbsp_surface     *surf_in;
		            IGRdouble                 scaling_factor;
		            IGRvector                 trans_vector;
		            IGRdouble                 *tran_mat;
		            IGRlong                   option;
		            IGRdouble                 *density;
		            IGRdouble                 *out_int)
/*
Descrpition
	This method returns the faceintegrals of a composite.

History:
	gk	11/12/87	the begining
    gupta 08/11/89  changes for new tiler etc
*/

{
  IGRlong           status, i, j;
  OMuint	    numb_children;
  IGRdouble	        loc_sf[NUMB_PROPS];
  extern IGRboolean IGEstop();
  IGRboolean        interrupt= FALSE;
  OM_S_CHANSELECT   to_children;


  *msg = EMS_S_Success;
  status = OM_S_SUCCESS;

  status = EMmake_chanselect (GRcmpowner_to_components, &to_children);
  if(EMSmsgReport(status,"EMcsfaceint: chanselect", FALSE) )goto wrapup;

  status = om$get_channel_count(objid = my_id,
                                p_chanselect = &to_children,
                                count = &numb_children);
  if(EMSmsgReport(status, "EMcsfaceint: chan objs", FALSE))goto wrapup;

  for(i=0; i<numb_children; i++)	/* for every face */
   {
    for(j = 0; j < NUMB_PROPS; j++) loc_sf[j] = 0.0;

    status = om$send(msg = message EMSsurface.EMfaceintgrl(msg,
                           want_status, new_tiler, surf_inx, num_surfaces,
                           my_env, surf_in, scaling_factor, trans_vector,
                           tran_mat, option, density, loc_sf),
                     p_chanselect = &to_children,
                     from = i,
                     to = i);
    if ((*msg == EMS_I_Interrupt) || ((interrupt = IGEstop())))
     {
      *msg = EMS_I_Interrupt; return (OM_S_SUCCESS);
     }
    if(EMSmsgReport(status, "EMcsfaceint: EMfaceintgrl", FALSE))
       goto wrapup;
    if( !(1 & *msg))goto wrapup;

    for(j = 0; j < NUMB_PROPS; j++) out_int[j] += loc_sf[j];
   }

wrapup:
  return(status);
}

end implementation EMScompsurf;

