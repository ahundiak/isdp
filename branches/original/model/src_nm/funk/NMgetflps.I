/*
This function will return all the NMfeaturelp class (or those within ancestry)
objects on the surface. The output can be controlled as follows -

If a list of exact classids is provided, only those loops whose class matches
exactly with one of those in the list will be returned. Ancestry having 
NMfeaturelp is not enough in this case.

If a list of classes to be ignored is supplied, only those loops with
NMfeaturelp in the ancestry but not of any of the classes in the input list
will be returned.
*/

class implementation NMnonmani;

#include "EMSprop.h"

#define StaticBuf 10

extern OMuword OPP_NMfeaturelp_class_id, OPP_NMnonmanigm_class_id;

from NMfeaturelp import NMprop;
from EMSloop import EMget_props;
from NMnonmanigm import NMget_number_components, NMget_components;

IGRint NMget_feature_loops(EMmsg, sfid, numflps, flps, exact_clsid, 
			   num_exactclsid, no_clsid, num_noclsid, nmquery_opt)
IGRlong *EMmsg;
struct GRid *sfid;
IGRint *numflps;
struct GRid **flps;
OMuword *exact_clsid, *no_clsid;
IGRint num_exactclsid, num_noclsid;
unsigned int nmquery_opt;
{
 OM_S_CHANSELECT	to_flps;
 IGRlong		sts = OM_S_SUCCESS;
 OM_S_OBJECT_LINKAGE	*objlnk = NULL, objlnkbuf[StaticBuf];
 IGRint			count = 0, i, num_comps = 0;
 IGRboolean		is_valid = FALSE;
 IGRint			j;
 OMuword		this_clsid;
 struct GRid		*comps = NULL, compsbuf[StaticBuf];
 struct GRmd_env	env;
 IGRushort	lpprops = NULL;
 unsigned char 	nmprops = NULL;


 *EMmsg = EMS_S_Success;
 *numflps = 0;
 *flps = NULL;
 EMmake_chanselect(EMSrequester_to_helpers, &to_flps);
 EMidmatrix(EMmsg, &env.md_env.matrix_type, env.md_env.matrix);
 env.md_id.objid = NULL_OBJID;
 env.md_id.osnum = sfid->osnum;

  /* If the sfid is a composite, break it down into its leaf components and
    start getting flps from each.
 */
 if(EFisAncestryValid(EMmsg, sfid->objid, sfid->osnum, 
    OPP_GRowner_class_id, FALSE)) 
  {
   if(EFisAncestryValid(EMmsg, sfid->objid, sfid->osnum, 
      OPP_NMnonmanigm_class_id, FALSE)) 
    sts = om$send(msg = message NMnonmanigm.NMget_number_components(EMmsg, 
	  &count), targetid = sfid->objid, targetos = sfid->osnum, 
	  senderid =NULL_OBJID);
   else
    sts = om$send(msg = message GRowner.GRget_number_components(EMmsg, &count),
	 targetid = sfid->objid, targetos = sfid->osnum, senderid =NULL_OBJID);
	
   if(!(1&*EMmsg&sts)) goto wrapup;
   EMerr_hndlr(!count, *EMmsg, EMS_E_Fail, wrapup);

   if(count > StaticBuf)  
    comps = (struct GRid *) om$malloc(size = count * sizeof(struct GRid));
   else comps = compsbuf;
   EMerr_hndlr(!comps, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

   if(EFisAncestryValid(EMmsg, sfid->objid, sfid->osnum, 
      OPP_NMnonmanigm_class_id, FALSE)) 
     sts = om$send(msg = message NMnonmanigm.NMget_components(EMmsg, &env, 
	   comps, count, &num_comps, 0, MAXINT), targetid = sfid->objid, 
	 targetos = sfid->osnum, senderid = NULL_OBJID);
   else
     sts = om$send(msg = message GRowner.GRget_components(EMmsg, &env, comps, 
	 count, &num_comps, 0, MAXINT), targetid = sfid->objid, 
	 targetos = sfid->osnum, senderid = NULL_OBJID);
   if(!(1&*EMmsg&sts)) goto wrapup;
  }
 else
  {
   num_comps = 1;
   comps = compsbuf;
   comps[0] = *sfid;
  }

 for(j=0; j<num_comps; j++)
  {
   if(objlnk && (objlnk != objlnkbuf)) om$dealloc(ptr = objlnk);
   objlnk = NULL;

   sts = om$get_channel_count(objid = comps[j].objid, osnum = comps[j].osnum, 
         p_chanselect = &to_flps, count = (OMuint *) &count);
   if(!(1&sts)) goto wrapup;
   if(!count) goto wrapup;

   if(count > StaticBuf)
    objlnk = (OM_S_OBJECT_LINKAGE *) om$malloc(size = count *
             sizeof(OM_S_OBJECT_LINKAGE));
   else objlnk = (OM_S_OBJECT_LINKAGE *) objlnkbuf;
   EMerr_hndlr(!objlnk, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

   sts = om$get_channel_objects(objid = comps[j].objid, osnum = comps[j].osnum,
       p_chanselect = &to_flps, list = objlnk, size = count, 
       count = (OMuint *) &count);
   if(!(1&sts)) goto wrapup;

   if(*flps)
    *flps = (struct GRid *) om$realloc(ptr = (IGRchar *) *flps, 
	    size = (count + *numflps) * sizeof(struct GRid));
   else
    *flps = (struct GRid *) om$malloc(size = count * sizeof(struct GRid));
   EMerr_hndlr(!*flps, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

   for(i=0; i<count; i++) 
    {
     is_valid = FALSE;

     is_valid = EFisAncestryValid(EMmsg, objlnk[i].S_objid, objlnk[i].osnum, 
        OPP_NMfeaturelp_class_id, FALSE);

     if(!is_valid) continue;

     if(exact_clsid)
      for(j=0; j<num_exactclsid; j++)
       {
        sts = om$get_classid(objid = objlnk[i].S_objid, osnum = objlnk[i].osnum,
            p_classid = &this_clsid);
        if(!(1&sts)) goto wrapup;
        is_valid = (this_clsid == exact_clsid[j]) ? TRUE : FALSE;
        if(is_valid) break;
       }

     if(!is_valid) continue;

     if(no_clsid)
      for(j=0; j<num_noclsid; j++)
       {
        sts = om$get_classid(objid = objlnk[i].S_objid, osnum = objlnk[i].osnum,
            p_classid = &this_clsid);
        if(!(1&sts)) goto wrapup;
        is_valid = (this_clsid == no_clsid[j]) ? FALSE : TRUE;
        if(!is_valid) break;
       }

     if(!is_valid) continue;

     sts = om$send(msg = message EMSloop.EMget_props(EMmsg, &lpprops), 
	   targetid = objlnk[i].S_objid, targetos = objlnk[i].osnum,
	   senderid = NULL_OBJID);
     if(!(1&*EMmsg&sts)) goto wrapup;

     /* If inactive flps are to be ignored, check and do it.
     */
     if( (!(nmquery_opt & NMquery_ConsiderInactive)) && 
         (!(lpprops & EMLP_ACTIVE)))
      {
       is_valid = FALSE;
       continue;
      }

     /* If NM flps created external to modeling operations are to be ignored
        check and do it.
     */

     sts = om$send(msg = message NMfeaturelp.NMprop(EMmsg, NMprop_Get, 
           &nmprops), targetid = objlnk[i].S_objid, targetos = objlnk[i].osnum,
           senderid = NULL_OBJID);
     if(!(1&*EMmsg&sts)) goto wrapup;

     if( (!(nmquery_opt & NMquery_ConsiderExternalToModel)) && 
          (nmprops & NMflp_ExternalToModel))
      is_valid = FALSE;

     if(is_valid)
      {
       (*flps)[*numflps].objid = objlnk[i].S_objid;
       (*flps)[(*numflps)++].osnum = objlnk[i].osnum;
      }

    } /* for(i=0; i<count; i++) */

  } /* for(j=0; j<num_comps; j++) */

wrapup:
if(objlnk && (objlnk != objlnkbuf)) om$dealloc(ptr = objlnk);
if( !(*numflps) && *flps)
 {
  om$dealloc(ptr = *flps);
  *flps = NULL;
 }

EMWRAPUP(*EMmsg, sts, "NMget_feature_loops");
return(sts);
}

end implementation NMnonmani;
