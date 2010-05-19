/*\
Name
   GRintersection

Description
   Finds the intersection between two graphic groups and puts the results
   into a third graphic group (result_gg_id = my_gg_id intersection gg_id).

Arguments
   *msg           IGRlong           return code
   *gg_id         struct GRid       graphic group
   *result_gg_id  struct GRid       result graphic group

Notes
   If the third graphic group object id is the same as one of the graphic
   group object ids that the operation is being performed upon, the 
   contents of that group are replaced with the results from the operation.

Return Values
   MSSUCC  if successful
   MSFAIL  if failure

History
   Adz and cvrao
	Changed the file to accomadate reference file set operations
\*/   

class implementation VDgrset;

#include "msdef.h"
#include "OMerrordef.h"
#include "grownerdef.h"
#include "exmacros.h"
#include "asmacros.h"
#include "nddef.h"
#include "AS_status.h"


extern  GRclassid       OPP_VDpretendin_class_id;

from    NDnodein        import  NDconnect;

method GRintersection (IGRlong *msg; struct GRid *gg_id;
                       struct GRid *result_gg_id)
{
IGRlong           om_msg, myMsg;
IGRlong           status;
IGRint            i,j,rc;
IGRint            loop;
OMuint            count1;
OMuint            count2;
IGRint            channel_type;
IGRint            connection_type;
IGRint            operand1_flag;
IGRint            operand2_flag;
IGRint            num;
struct GRid       operand1;
struct GRid       operand2;
IGRchar           *buffer1;
IGRchar           *buffer2;
OM_S_CHANSELECT   chansel;

   *msg = MSSUCC;
   om_msg = OM_S_SUCCESS;
   buffer1 = NULL;
   buffer2 = NULL;
   chansel.type = OM_e_name;
   chansel.u_sel.name = "GRcmpowner.to_components";


      om_msg = 
      om$send ( msg = message GRowner.GRget_channel_type (
                                                        msg,
                                                        &channel_type,
                                                        &connection_type),
               senderid = NULL_OBJID, 
               targetid = result_gg_id->objid,
               targetos = result_gg_id->osnum);

      /*
       *  Check to see if either of the operand graphic group is
       *  the same as the result graphics group.
       */

      operand1.objid = my_id;
      operand1.osnum = OM_Gw_current_OS;
      operand2.objid = gg_id->objid ;
      operand2.osnum = gg_id->osnum ;

      if (result_gg_id->objid == my_id)
      {
         operand1_flag = TRUE;
         operand2_flag = FALSE;
      }else if (result_gg_id->objid == gg_id->objid)
      {
         operand1_flag = FALSE;
         operand2_flag = TRUE;
      }else
      {
         operand1_flag = FALSE;
         operand2_flag = FALSE;
      }            
      
      om_msg = om$get_channel_count (objid = operand1.objid,
                                     osnum = operand1.osnum,
                                     p_chanselect = &chansel, 
                                     count = &count1);

      if (om_msg & 1)
      {
         if (buffer1 = om$malloc (size = sizeof(OM_S_OBJECT_LINKAGE) 
                       * count1))
         {
            num = (int)(count1);
            om_msg = om$get_channel_objects (objid = operand1.objid,
                                             osnum = operand1.osnum, 
                                             p_chanselect = &chansel, 
                                             list = (OM_S_OBJECT_LINKAGE *)buffer1, 
                                             size = count1, 
                                             count = &count1);
            rc =  VDcheck_if_pretend( buffer1, &num );
        }
      }

      if (om_msg & 1)
      {
         om_msg = om$get_channel_count (objid = operand2.objid,
                                        osnum = operand2.osnum,
                                        p_chanselect = &chansel, 
                                        count = &count2);
   
         if (om_msg & 1)
         {
            if (buffer2 = om$malloc (size = sizeof(OM_S_OBJECT_LINKAGE) 
                          * count2))
            {
               num = (int)(count2);
               om_msg = om$get_channel_objects (objid = operand2.objid,
                                                osnum = operand2.osnum, 
                                                p_chanselect = &chansel, 
                                                list = (OM_S_OBJECT_LINKAGE *)buffer2, 
                                                size = count2, count = &count2);
               rc = VDcheck_if_pretend( buffer2, &num ); 
           }
         }
      }

      if ((om_msg & 1) && ((operand1_flag) || (operand2_flag)))
      {
         om_msg = om$send (msg = message Root.wild_disconnect (chansel),
                  targetid = result_gg_id->objid);
      }

      if (om_msg & 1)
      {
         for (i=0; i < count1; ++i)
         {
            for (j=0, loop = TRUE; ((loop) && (j < count2)); ++j)
            {
               if (   ( ((OM_S_OBJECT_LINKAGE *)buffer1)[i].S_objid == 
                        ((OM_S_OBJECT_LINKAGE *)buffer2)[j].S_objid )  &&
                      ( ((OM_S_OBJECT_LINKAGE *)buffer1)[i].osnum == 
                        ((OM_S_OBJECT_LINKAGE *)buffer2)[j].osnum   ) )
               {
                  /*
                   *  Connect the component to the result graphic group.
                   */

                        struct  GRid    pretend,
                                        null_grid,
                                        temp,
                                        temp1, ctxt;
                        OMuword         curos;

                        pretend.osnum = result_gg_id->osnum ;
                        pretend.objid = NULL_OBJID;
                        null_grid.objid = NULL_OBJID;

                        temp.objid = ((OM_S_OBJECT_LINKAGE *)buffer1)[i].S_objid
;
                        temp.osnum = ((OM_S_OBJECT_LINKAGE *)buffer1)[i].osnum;

                        status = ex$get_cur_mod( osnum    = &curos );

                        /* get the context */

                        if( temp.osnum == curos )
                            ctxt = null_grid;
                        else
                        {
                              status = GRfindcontext( &myMsg, NULL, NULL, &temp.osnum, &ctxt );

                              if( !(status & 1) )
                              {
                                 ctxt = null_grid;
                              }
                        }
                        status =
                        as$make_source(go_grid = temp,
                                       context_grid = ctxt,
                                       as_os = result_gg_id->osnum,
                                       as_grid = &temp1);
/**
                        if( !(temp1.objid == temp.objid &&
                                        temp1.osnum == temp.osnum) )
**/ 
                          status =
                          om$construct(classid = OPP_VDpretendin_class_id,
                                       osnum   = pretend.osnum,
                                       p_objid = &pretend.objid,
                                       msg = message NDnodein.NDconnect(
                                                              1,
                                                              &temp1,
                                                              null_grid,
                                                              ND_NEW));

                         ((OM_S_OBJECT_LINKAGE *)buffer1)[i].osnum = pretend.osnum;

                         ((OM_S_OBJECT_LINKAGE *)buffer1)[i].S_objid = pretend.objid;
    
                  loop = FALSE;
                  om_msg = GRconnect_object (msg, 
                           ((OM_S_OBJECT_LINKAGE *)buffer1)[i].osnum,
                           ((OM_S_OBJECT_LINKAGE *)buffer1)[i].S_objid,
                           result_gg_id, channel_type, connection_type,
                           OM_K_MAXINT, OM_K_MAXINT);
                }
            }
         }
      }

   if (buffer1) om$dealloc (ptr = buffer1);
   if (buffer2) om$dealloc (ptr = buffer2);
   return (om_msg);
}
end implementation VDgrset;
