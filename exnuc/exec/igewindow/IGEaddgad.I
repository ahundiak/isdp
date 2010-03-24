class implementation IGEgadget;

/* add to dperr.h file later  */

#include "igewinerr.h"

method add_gadget( IGRlong *msg; GRobjid *gadget_id; IGRint num_gadgets;)

{       
    IGRint           status = 1;
    OM_S_CHANSELECT  chandef1, chandef2;
    IGRdouble        min_x, min_y, max_x, max_y;
    IGRboolean       intersect = FALSE;
    IGRint           i;
    OMuint           count;
        *msg = MSSUCC;

        
                                
        chandef1.type = OM_e_name;
        chandef1.u_sel.name = "to_parent";

        chandef2.type = OM_e_name;
        chandef2.u_sel.name = "to_children";
        
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   We need to see if the range of this gadget intersects with the other
   gadgets connected to this channel.  If so, this gadget cannot connect.
   
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

        for (i=0; i < num_gadgets; i++, gadget_id++)
        {
        
           status = om$send(    msg = message IGEgadget.indep_extents(msg, 
                                        &min_x, &min_y, &max_x, &max_y), 
                                senderid = my_id, 
                                targetid = *gadget_id);
                        
           if (!(status & 1))
           {
              om$report_error(sts = status);
              goto wrapup;
           }
           
           status = om$get_channel_count(  objid = my_id, 
                                           p_chanselect = &chandef2, 
                                           count = &count);
                        
           if (!(status & 1))
           {
              om$report_error(sts = status);
              goto wrapup;
           }
                                
           if (count)
           {
              status = om$send( msg = message IGEgadget.range_intersect(msg, 
                                    min_x, min_y, max_x, max_y, &intersect), 
                                senderid = my_id, 
                                p_chanselect = &chandef2);
                                
              if (!(status & 1))
              {
                 om$report_error(sts = status);
                 goto wrapup;
              }
           }
        
           if (!intersect)
           {
              status = om$send (  msg =message Root.connect(chandef1, NULL, 
                                    my_id, OM_Gw_current_OS, 
                                    chandef2, NULL), 
                            senderid = my_id, 
                            targetid = *gadget_id);
                        
              
              if (!(status & 1))
              {
                 om$report_error(sts = status);
                 goto wrapup;
              }
           }
           else
           {
              *msg = DP_GADGET_OVERLAPED;
              goto wrapup;
           }
        

        } /* end of for loop  */
wrapup:

    return ( status );
}

end implementation IGEgadget;
