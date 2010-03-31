class implementation NMedge;

#include "EMSprop.h"
#include "OMmacros.h"
#include "emsmacros.h"

extern OMuword OPP_EMSedge_class_id;

method NMcheck(IGRlong *EMmsg; struct GRid *refuse, *refsf)
{
 IGRlong		sts = OM_S_SUCCESS;
 IGRint			count, i;
 struct GRid		locrefuse, junk;
 struct EMSobject_info	*parents = NULL;

 *EMmsg = EMS_S_Success;

 sts = om$send(msg = message NMassoc.NMget_parent_info(EMmsg, &parents, 
       0, &count), targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;
 EMerr_hndlr(!count, *EMmsg, EMS_E_Fail, wrapup);

 if( (i = om$dimension_of(varray = ME.NMedge->reverse)) != count)
  {
   *EMmsg = EMS_E_Fail;
   goto wrapup;
  }

 locrefuse = parents[0].grid;

 junk = ME.NMedge->refuse;

 if(!IF_EQ_GRID(locrefuse, ME.NMedge->refuse))
  {
   *EMmsg = EMS_E_Fail;
   goto wrapup;
  }
 if(refuse) *refuse = locrefuse;
 if(refsf) *refsf = ME.NMedge->refsf;

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
/*EMWRAPUP(*EMmsg, sts, "NMedge.NMcheck");*/
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

 if( (i = om$dimension_of(varray = ME.NMedge->reverse)) != count)
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

 /* If the edge being reversed is the reference edge, reverse all flags.
    Otherwise reverse the flag only for the particular edge.
 */
 if(!IF_EQ_GRID(ME.NMedge->refuse, *edgeid))
  ME.NMedge->reverse[i] = !ME.NMedge->reverse[i];
 else
   for(i=1; i<count; i++)
    ME.NMedge->reverse[i] = !ME.NMedge->reverse[i];

wrapup:
if(parents) om$dealloc(ptr = parents);
EMWRAPUP(*EMmsg, sts, "NMedge.NMedge_reversed");
return(sts);
}

end implementation NMedge;
