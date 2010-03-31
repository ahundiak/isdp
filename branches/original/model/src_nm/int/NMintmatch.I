class implementation NMinters;

#include "emsmacros.h"
#include "EMSdpr.h"

from EMSboundary import EMmatch_topology;

method NMmatch_inters(IGRlong *EMmsg; 
		      struct EMSinters *old_inters, *new_inters)
{
 IGRlong		sts = OM_S_SUCCESS;

#if SM_ENABLE_NM_TOPOLOGY_MATCHING
 IGRboolean		match_failed = FALSE;
 struct EMSinters	*this_oldint, *this_newint;
 struct EMSintobj	*this_oldintobj, *this_newintobj;
 struct EMSdataselect	*this_olddata, *this_newdata;
 struct GRid		*this_oldobj, *this_newobj;
 IGRushort	options = NULL;
 static IGRint		NMinters_mismatch(), NMintobj_mismatch();
#endif

 *EMmsg = EMS_S_Success;

#if SM_ENABLE_NM_TOPOLOGY_MATCHING

 this_oldint = old_inters;
 this_newint = new_inters;

 while(this_oldint && this_newint)
  {
   if(!IF_EQ_GRID(this_oldint->this_obj, this_newint->this_obj))
    {match_failed = TRUE; goto next_surf;}
   else match_failed = FALSE;

   this_oldintobj = this_oldint->cvs;
   this_newintobj = this_newint->cvs;
   while(this_newintobj && this_oldintobj)
    {
     if( (this_newintobj->this_xyzintobj.datatype == EMSdata_object) ||
         (this_oldintobj->this_xyzintobj.datatype == EMSdata_object))
      {
       fprintf(stderr, "XYZ object data not supported in inters matching\n");
       *EMmsg = EMS_E_InvalidArg;
       goto wrapup;
      }
     this_olddata = &this_oldintobj->this_uvintobj;
     this_newdata = &this_newintobj->this_uvintobj;
     this_oldobj = this_olddata->data.object;
     this_newobj = this_newdata->data.object;

     if( (this_olddata->datatype != EMSdata_object) ||
         (this_newdata->datatype != EMSdata_object))
      {
        match_failed = TRUE;
        goto next_intobj;
      }
     else match_failed = FALSE;

     sts = om$send(msg = message EMSboundary.EMmatch_topology(EMmsg, 
           NULL, NULL, this_newobj->objid), 
           targetid = this_oldobj->objid, targetos = this_oldobj->osnum);
     if(!(1&*EMmsg&sts)) goto wrapup;

next_intobj:
     if(match_failed && (this_olddata->datatype == EMSdata_object))
      {
       sts = om$send(msg = message EMSboundary.EMmatch_topology(EMmsg, 
             EMstore_opt_MATCH_FAILED, NULL, NULL_OBJID), 
       targetid = this_oldobj->objid, targetos = this_oldobj->osnum);
       if(!(1&*EMmsg&sts)) goto wrapup;
       match_failed = FALSE;
      }

     this_oldintobj = this_oldintobj->next;
     this_newintobj = this_newintobj->next;
    }

   /* If the old inters has lesser number of intersections, mark its remaining
      data as unmatched.
   */
   if(this_oldintobj && !this_newintobj)
    {
     sts = NMintobj_mismatch(EMmsg, this_oldintobj);
     if(!(1&*EMmsg&sts)) goto wrapup;
    }

next_surf:
   if(match_failed)
    {
     struct EMSinters *junk = NULL;
     junk = this_oldint->next;
     this_oldint->next = NULL;
     sts = NMinters_mismatch(EMmsg, this_oldint);
     this_oldint->next = junk;
     if(!(1&*EMmsg&sts)) goto wrapup;
     match_failed = FALSE;
    }

   this_oldint = this_oldint->next;
   this_newint = this_newint->next;
  }

 /* If the old inters list had intersections on more surfaces than the new
    one, mark the remaing old data as mismatched.
 */
 if(!this_newint && this_oldint) sts = NMinters_mismatch(EMmsg, this_oldint);



wrapup:
EMWRAPUP(*EMmsg, sts, "NMinters.NMmatch_inters");
#endif

return(sts);
}


#if SM_ENABLE_NM_TOPOLOGY_MATCHING

static IGRint NMintobj_mismatch(EMmsg, intobj)
IGRlong *EMmsg;
struct EMSintobj *intobj;
{
 IGRlong		sts = OM_S_SUCCESS;
 struct EMSdataselect 	*this_data;
 struct GRid		*this_obj;

 while(intobj)
  {
   if(intobj->this_xyzintobj.datatype == EMSdata_object)
    {
     fprintf(stderr, "XYZ object data not supported in inters matching\n");
     *EMmsg = EMS_E_InvalidArg;
     goto wrapup;
    }
   this_data = &intobj->this_uvintobj;
   this_obj = this_data->data.object;

   if(this_data->datatype == EMSdata_object) 
    {
     sts = om$send(msg = message EMSboundary.EMmatch_topology(EMmsg, 
           EMstore_opt_MATCH_FAILED, NULL, NULL_OBJID), 
           targetid = this_obj->objid, targetos = this_obj->osnum, 
	   senderid = NULL_OBJID);
     if(!(1&*EMmsg&sts)) goto wrapup;
    }
   intobj = intobj->next;
  }
	
wrapup:
return(sts);
}


static IGRint NMinters_mismatch(EMmsg, inters)
IGRlong *EMmsg;
struct EMSinters *inters;
{
 IGRlong	sts;
 static IGRint	NMintobj_mismatch();

 while(inters)
  {
   sts = NMintobj_mismatch(EMmsg, inters->cvs);
   if(!(1&*EMmsg&sts)) goto wrapup;
   inters = inters->next;
  }
wrapup:
return(sts);
}

#endif

end implementation NMinters;
