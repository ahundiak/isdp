class implementation NMassoctrans;

#include "OMmacros.h"
#include "emsmacros.h"

method NDparent_deleted(IGRlong *EMmsg;
   		        IGRint count_deleted; struct GRid list_deleted []; 
                        struct GRid *new_obj;struct GRmd_env *md_env)

{
 IGRlong	sts = OM_S_SUCCESS;
 struct GRid    *my_base_st = NULL, this_st;
 IGRint		num_base_states = 0, i, j;


 *EMmsg = EMS_S_Success;
 num_base_states = om$dimension_of(varray = ME.NMassoctrans->base_state);
 my_base_st = ME.NMassoctrans->base_state;

 for(i=0; i<num_base_states; i++)
  {
   /* Get the base st id from the tagid stored in instance data.
   */
   this_st.objid = NULL_OBJID;
   sts = NMtag(EMmsg, &this_st, &my_base_st[i], FALSE);
   if(!(1&*EMmsg&sts)) goto wrapup;
   if(IF_NULL_OBJID(this_st.objid))
    {
     my_base_st[i].objid = NULL_OBJID;
     continue;
    }

   /* If this base state is in the deleted list, set it to NULL_OBJID.
   */
   for(j=0; j<count_deleted; j++)
    {
     if(IF_EQ_GRID(list_deleted[j], this_st))
      {
       my_base_st[i].objid = NULL_OBJID;
       break;
      }
    }

  }

 sts = om$send(mode = OM_e_wrt_message, msg = message NDnode.NDparent_deleted
       (EMmsg, count_deleted, list_deleted, new_obj, md_env), 
       targetid = my_id);

wrapup:
EMWRAPUP(*EMmsg, sts, "NMassoctrans.NDparent_deleted");
return(sts);
}

end implementation NMassoctrans;
