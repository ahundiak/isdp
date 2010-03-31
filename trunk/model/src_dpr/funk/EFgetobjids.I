/* ###################   APOGEE COMPILED   ################## */
class implementation EMScomposite;

#include "EMS.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igetypedef.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "EMSmsgdef.h"
#include "emserr.h"

void EFgetobjids(EMmsg, from_object, from_chan, id_list, num_ids, class_id,
                 rejectid_list, num_rejectids)

IGRlong         *EMmsg;
struct GRid     *from_object;
OM_S_CHANSELECT *from_chan;
struct GRid     **id_list;
IGRint          *num_ids;
OMuword         class_id;
struct GRid     *rejectid_list;
IGRint          num_rejectids;

/*
Description
     This function will return an array of GRid's corresponding to the
     objects of the specified class or subclass of the specified class on
     the channel. 
     
     One particular user of this function is the DPR objects who can have
     true component objects and other composite objects on its to_components
     channel and yet want to send to only one type or the other.

     Input arguments:

     *from_object;   Object to get the ids from.                
     *from_chan;     Channel of object to get the ids from.     
     class_id;       Class id to search for on 'from_chan'.     
     *rejectid_list; List of ids NOT to return as objects on 'from_chan'
     num_rejectids;  Number of ids in 'rejectid_list'.

Return Values
     *EMmsg;       EMS_S_Success if all goes well.           
     **id_list;    Array of object ids that are the same class
                    as or a subclass of the class id listed.  
     *num_ids;     Number of ids on 'id_list'.                

Notes 
     This function mallocs 'id_list' and it is assumed that the user will 
     free this memory using om$dealloc.

History
     DLB  11/02/87 Added last two params indicating ids to reject.
     DLB  10/22/87 creation.
*/
{
 IGRlong	     OM_stat;
 IGRint          i, j, temp_cnt;
 OMuint          count;
 struct GRid     *temp_ptr;
 OMuword         current_classid;
 IGRboolean      match;
      

 OM_stat = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
    
 *num_ids = 0;
 *id_list = NULL;

 OM_stat = om$get_channel_count(objid = from_object->objid,
                                osnum = from_object->osnum,
                                p_chanselect = from_chan,
                                count = &count);
 if (!(1 & OM_stat)) goto wrapup;

 /*I may malloc too much but I feel its better than calling realloc*/
 if (count)
 {
   *id_list = (struct GRid *) om$malloc(size = count * sizeof(struct GRid));
   if (!*id_list) {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}
 }
 else 
   goto wrapup;

 temp_cnt = 0;         /*to cut down on indirection code*/ 
 temp_ptr = *id_list;  /*to cut down on indirection code*/

 for (i = 0; i < count; i ++)
 {
   /*Get the id of the chan index i.  If its a an object of 'class_id'
    * or a subclass of it then place the id on the list.
    */
   OM_stat = om$get_objid_at_index(objid = from_object->objid,
                                   osnum = from_object->osnum,
                                   p_chanselect = from_chan,
                                   index = i,
                                   objidaddr = &temp_ptr[temp_cnt].objid,
                                   osnumaddr = &temp_ptr[temp_cnt].osnum);
   if (! (1 & OM_stat)) goto wrapup;

   match = FALSE;
   for (j = 0; j < num_rejectids; j ++)
   {
     if ((temp_ptr[temp_cnt].objid == rejectid_list[j].objid) &&
         (temp_ptr[temp_cnt].osnum == rejectid_list[j].osnum)) 
     {
       match = TRUE;
       break;  /*Got one so no need to continue*/
     }
   }

   if (!match)
   {
     OM_stat = om$get_classid(objid = temp_ptr[temp_cnt].objid,
                              osnum = temp_ptr[temp_cnt].osnum,
                              p_classid = &current_classid);
     if (!(1 & OM_stat)) goto wrapup;

     OM_stat = om$is_ancestry_valid(subclassid = current_classid, 
                                    superclassid = class_id);
     if (!(1 & OM_stat)) goto wrapup;
  
     if (OM_stat != OM_I_INVANCESTRY || current_classid == class_id)
       temp_cnt++; /*Got a match of the class*/
   }
 } /*end for*/

 *num_ids = temp_cnt;   

 wrapup:
  if (!(1 & OM_stat & *EMmsg) && (*id_list)) om$dealloc(ptr = *id_list);

  /* If no match, dealloc alloced memory */
  if (!(*num_ids))
  { om$dealloc(ptr = *id_list);
    *id_list = NULL; /* important, since this is output */
  }

  EMWRAPUP(*EMmsg, OM_stat, "In EFgetobjids")
  return;
}
end implementation EMScomposite;
