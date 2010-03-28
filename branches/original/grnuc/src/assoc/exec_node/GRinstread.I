class implementation ASnode;

#include "grownerdef.h"
#include "AS_status.h"
#include "godef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "OMmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asbox.h"
#include "msdef.h"
#include "gocmacros.h"

#define MAXDOUBLE 1e+300
extern IGRint   GRget_to_comp_info();

method GRgetsymb(IGRlong *msg; struct GRsymbology *sym)
{
 OM_S_CHANSELECT chan;
 IGRlong status;

 chan.type = OM_e_addr;
 chan.u_sel.addr = &me->to_components;

 status = om$send( mode = OM_e_wrt_object,  p_chanselect = &chan,
                   msg = OPPmargs,
		   from = 0, to = 0);
 as$status();
 return(status);

}
		 
 
method GRgenabsg(IGRlong *msg; IGRshort *matrix_type; 
			  IGRmatrix matrix; IGRchar **absgptr)
{
IGRint status;

status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
return(status);
}

method GRgetattr(IGRlong *msg; IGRchar *attr)
{
IGRint status;

status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
return(status);
}

method GRgetgeom(IGRlong *msg; IGRshort *matrix_type;
			  IGRmatrix matrix; IGRchar *geometry)
{
IGRint status;

status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
return(status);
}

method GRgetsize(IGRlong *msg; IGRshort *matrix_type;
			  IGRmatrix matrix; IGRlong *size)
{
IGRint status;

status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
return(status);
}

method GRgetrang (IGRlong *msg; 
                  IGRshort *matrix_type;
                  IGRmatrix matrix; 
                  IGRboolean *world; 
                  GRrange range)
{
    IGRlong           om_msg;
    IGRlong           ret_msg;
    IGRint            i, j;
    IGRint            count;
    IGRshort          local_mx_type,world_mx_type;
    double 	      *world_mx;
    IGRmatrix         local_matrix,world_mx_buffer;
    GRrange           go_range;
    OM_S_CHANSELECT   chansel;
    int range_found;

    range_found = 0;

    /*
     * initialize matrix_type and matrix if not in the arguments 
     */

    if (*world)
    {
        world_mx = matrix;
        world_mx_type = *matrix_type;
    }
    else
    {
        MAidmx(&ret_msg, world_mx_buffer);
        world_mx = world_mx_buffer;
        world_mx_type = MAIDMX;
    }

 
    /* 
     *  Get the number of objects on my channel.
     */
    om_msg = GRget_to_comp_info ( &chansel,
                                  OM_Gw_current_OS,
                                  my_id,
                                  &count );
    if(!(om_msg&1)) goto wrapup;

    /*
     *  Get the component matrix.
     */
    om_msg = om$send (msg = message GRowner.GRget_matrix (msg, 
                                                          &world_mx_type,
                                                          world_mx, 
                                                          &local_mx_type, 
                                                          local_matrix), 
                          targetid = my_id);

    /* 
     * Cumulate component ranges
     */


    for (i=0 ; i<count; ++i) 
     {
      /*
       *  Get the range of the object.
       */
      om_msg = om$send(msg = message GRvg.GRgetrang (msg, 
                                                     &local_mx_type,
                                                     local_matrix, 
                                                     world, 
                                                     go_range),
                       p_chanselect = &chansel, 
                       from = i, 
                       to = i);
      
  
      if ((om_msg & *msg & 1) && (om_msg != OM_I_CHAN_EMPTY))
        {
	  if( range_found ) GRaccumulate_range (&ret_msg, go_range, range);
	  else
	  {
	    range_found = 1;
	    for( j=0; j<6; j++ ) range[j] = go_range[j];
	  }
	} 
    }

wrapup :

   if(!range_found)
        for (i=0;i<6;i++) range[i] = 0.;

	*msg	= MSSUCC;
   return( OM_S_SUCCESS );
}

end implementation ASnode;
