class implementation NMvertex_use;

#include "EMSprop.h"
#include "OMmacros.h"
#include "emsmacros.h"

extern OMuword OPP_EMSedge_class_id;
extern OMuint OM_Gf_verbose_warning;

method NMcheck(IGRlong *EMmsg)
{
 IGRlong		sts = OM_S_SUCCESS;
 IGRint			count, i;
 struct EMSobject_info	*parents = NULL;

 *EMmsg = EMS_S_Success;

 sts = om$send(msg = message NMassoc.NMget_parent_info(EMmsg, &parents, 
       0, &count), targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;
 EMerr_hndlr(!count, *EMmsg, EMS_E_Fail, wrapup);

 if( (i = om$dimension_of(varray = ME.NMvertex_use->edloc)) != count)
  {
   *EMmsg = EMS_E_Fail;
   goto wrapup;
  }

  /* make sure all parents are valid.
  */
  for(i=0; i<count; i++)
   if(!EFisAncestryValid(EMmsg, parents[i].grid.objid, parents[i].grid.osnum, 
       OPP_EMSedge_class_id, TRUE))
    {
     *EMmsg = EMS_E_Fail;
     goto wrapup;
    }

wrapup:
if(parents) om$dealloc(ptr = parents);

if(OM_Gf_verbose_warning)
 {
  EMWRAPUP(*EMmsg, sts, "NMvertex_use.NMcheck");
 }

if(!(1&*EMmsg&sts)) *EMmsg = EMS_E_Fail;
return(sts);
}


method NMedge_reversed(IGRlong *EMmsg; struct GRid *edgeid)
{
 IGRlong		sts = OM_S_SUCCESS;
 IGRint			count, i;
 struct EMSobject_info	*parents = NULL;
 IGRboolean             found = FALSE;

 *EMmsg = EMS_S_Success;

 sts = om$send(msg = message NMassoc.NMget_parent_info(EMmsg, &parents, 
       0, &count), targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;
 EMerr_hndlr(!count, *EMmsg, EMS_E_Fail, wrapup);

 if( (i = om$dimension_of(varray = ME.NMvertex_use->edloc)) != count)
  {
   *EMmsg = EMS_E_Fail;
   goto wrapup;
  }

 for(i=0; i<count; i++)
  if(IF_EQ_GRID(parents[i].grid, *edgeid))
   {
    found = TRUE;
    break;
   }
 EMerr_hndlr(!found, *EMmsg, EMS_E_Fail, wrapup);

 if(ME.NMvertex_use->edloc[i] == EMScvint_rtend)
  ME.NMvertex_use->edloc[i] = EMScvint_lfend;
 else if(ME.NMvertex_use->edloc[i] == EMScvint_lfend)
  ME.NMvertex_use->edloc[i] = EMScvint_rtend;

wrapup:
if(parents) om$dealloc(ptr = parents);
EMWRAPUP(*EMmsg, sts, "NMvertex_use.NMedge_reversed");
return(sts);
}

end implementation NMvertex_use;
