/* ###################   APOGEE COMPILED   ################## */
class implementation EMScompsurf;

#include "EMS.h"
method EMget_point_on_surface (IGRlong *EMmsg;
                                struct GRmd_env *md_env;
                                IGRuint attempt_no;
                                IGRint number_of_points;
                                IGRdouble *points;
                                struct EMparms *params)

/* *************************************************************************
 
Description

    This message gets points lying on the area region of the surface, when
    supplied with the module environment of the surface. Since it is not a 
    leaf node, all this method does is pass the message down to its
    components.

    Input
     md_env - module environment of the surface
     attempt_no - Number of attempts the caller  has tried before.  This is 
           a mechanism by which the caller can ensure that he does
           not get the same points by calling the method again. If the caller
           is calling this method for the first time, the attempt_no
           should be set to 0. If he is interested in random points, he
           may set the attempt_no to be a random number ranging from 0
           to MAXINT.
     number_of_points - The number of points the caller is interested in

     Output
      EMmsg - Completion message
      points - The points that are returned. Memory should be preallocated.
               Maybe set to NULL, if the caller is not interested.
      params - Information about the u, and v parameter corresponding to
               the point and the surface id on which the point exists etc.
               It may be set to NULL, if the caller is not interested in 
               this field. The memory should be preallocated if the caller is
               interested in this field.

Notes
     Upon exit the completion code will be one of the following:
       EMS_S_Success - if successful
       EMS_I_NotFound - if an active surface could not be located
       EMS_E_DynamicMemoryAllocated - if unsucessful in allocating memory
       EMS_E_SurfaceError - if the method could not get the abstract
                            geometry.
       EMS_E_Fail - if the send to the topology methods was not successful
       EMS_E_BSerror - if there is a math error

History
     PP : 12/07/87             Creation
     SM : 03-Aug-89	       Try sending down all the indices starting
			       with the initially chosen one and go circularly
			       untill the point is found or we run out
			       of the indices. This includes
			       continuation if an inactive surface is
			       encountered or if there is an error.
			
************************************************************************ */
{
 IGRlong         status;
 OMuint          count;
 IGRint          index, i;
 OM_S_CHANSELECT to_comps;

 status  = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 to_comps.type = OM_e_addr;
 to_comps.u_sel.addr = &ME.GRcmpowner->to_components;

/*
 * The below code decides on which index the message is to be sent to
 * the components. If the attempt no is 0, the index on which the message
 * is sent is 0 and so on. But if there are no surfaces attached to
 * this composite, then return a NotFound return code.
 */


 status = om$get_channel_count (objid = my_id, p_chanselect = &to_comps,
                                count = &count);
 if (!(1&status)) goto wrapup;
 if (!count)
   {
   *EMmsg = EMS_I_NotFound;
   goto wrapup;
   }

 if (count > attempt_no)
  index = attempt_no; 
 else 
  index = (attempt_no % count);

 for (i=0; i<count; i++)
   {
   status = om$send(msg = OPPmargs, p_chanselect = &to_comps,
             from = index, to = index);

   /* Commented out the following statement -- SM 03-Aug-89. */
   /* if (!(1&status&*EMmsg)) goto wrapup; */

   /* Added error check and break statements -- SM 03-Aug-89. */

   if ( (*EMmsg == EMS_I_NotFound) || !(1&*EMmsg&status))
     index = (index+1)%count;
   else break;
   }

 wrapup:
  EMWRAPUP(*EMmsg, status, "In EMScompsurf:EMget_point_on_surf error");
  return (status);
}
end implementation EMScompsurf;
