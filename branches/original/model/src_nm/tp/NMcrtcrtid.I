class implementation NMcreated;

#include "OMmacros.h"

method NMget_put_creator_id(IGRlong *EMmsg;
                            GRobjid *creator_id;
                            IGRboolean put_it)
{
 IGRlong	sts = OM_S_SUCCESS;
 OMuint		tag_id;

 *EMmsg = EMS_S_Success;

 if(put_it)
  {
   if(!IF_NULL_OBJID(*creator_id))
    {
     sts = om$add_tag(objid = *creator_id, p_tag =  (OMuint *) &tag_id);
     if(sts == OM_E_TAGEXISTS)
      {
       sts = om$objid_to_tag(objid = *creator_id, p_tag = (OMuint *)&tag_id);
       if(!(1&sts)) goto wrapup;
      }
     else if(!(1&sts)) goto wrapup;
    }
   else tag_id = NULL_OBJID;
   ME.NMcreated->creator_id = tag_id;
  }
 else
  {
   if(!IF_NULL_OBJID(ME.NMcreated->creator_id))
    {
     sts = om$tag_to_objid(tag = ME.NMcreated->creator_id, 
           p_objid = (OM_p_OBJID) &tag_id);
     if(sts == OM_E_NOSUCHTAG)
      {
       sts = OM_S_SUCCESS;
       tag_id = NULL_OBJID;
      }
     else if(!(1&sts)) goto wrapup;
    }
   else tag_id = NULL_OBJID;

   *creator_id = tag_id;
   if(IF_NULL_OBJID(*creator_id))
     sts = NMfind_creator(EMmsg, my_id, creator_id, TRUE);
  }

wrapup:
 return(sts);
}
end implementation NMcreated;

