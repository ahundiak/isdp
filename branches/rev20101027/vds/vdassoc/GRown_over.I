/*
  
    Override message declared in GRowner

History :
	
	12/30/94	R. Manem	Fix for improper ranges of certain
					equipment, Route objects : return
					MSFAIL if no range found.

*/

class implementation ASnode;

#include "grownerdef.h"
#include "asbox.h"
#include "nddef.h"
#include "ndmacros.h"
#include "AS_status.h"
#define AS_DEBUG

#include "msdef.h"
#include "gocmacros.h"

extern IGRint   GRget_to_comp_info();

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
	  if( range_found ) 
             GRaccumulate_range (&ret_msg, go_range, range);
	  else
	  {
	     range_found = 1;
	     for( j=0; j<6; j++ ) range[j] = go_range[j];
	  }
	} 
    }

wrapup :

   *msg	= MSSUCC;
   if(!range_found) {
        *msg = MSFAIL;
        for (i=0;i<6;i++) range[i] = 0.0;
   }

   return( OM_S_SUCCESS );
}


end implementation ASnode;
