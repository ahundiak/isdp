class implementation NMvertex_use;

#include "OMmacros.h"

from NMvertex import NMpoint;

method NMget_incedence_info(IGRlong *EMmsg; GRobjid refedge; IGRint *numedges;
			     GRobjid **edges;
			     enum EMScvinttype **loc_on_edge;
			     struct GRid *xyzvtx;
			     IGRdouble *uvpt, *xyzpt;
			     unsigned int nmquery_opt)
{
 IGRlong		sts = OM_S_SUCCESS;
 OM_S_OBJECT_LINKAGE	locxyzvtx;
 OM_S_CHANSELECT	to_vtx;
 OMuint			count, my_numeds = 0;
 IGRint			i;
 struct EMSobject_info	*parents = NULL;
 IGRboolean		was_invalid = FALSE;


 *EMmsg = EMS_S_Success;
 my_numeds = om$dimension_of(varray = ME.NMvertex_use->edloc);

 if(numedges) *numedges = my_numeds;

 if(edges || (loc_on_edge && (!IF_NULL_OBJID(refedge))))
  {
   sts = om$send(msg = message NMassoc.NMget_parent_info(EMmsg, &parents, 
         0, (IGRint *) &count), targetid = my_id);
   if(!(1&*EMmsg&sts)) goto wrapup;
   if(count != my_numeds)
    {
     if(nmquery_opt & NMquery_InTransientState)
      {
       if(numedges) *numedges = count;
       was_invalid = TRUE;
      }
     else
      {
       *EMmsg = EMS_E_Fail;
       goto wrapup;
      }
    }

   if(edges)
    {
     if(count)
      {
       *edges = (GRobjid *) om$malloc(size = count * sizeof(GRobjid));
       EMerr_hndlr(!*edges, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
      }
     else *edges = NULL;

     for(i=0; i<count; i++)
      (*edges)[i] = parents[i].grid.objid;
    }
  }

 if(loc_on_edge)
  {
   if(!edges && (!IF_NULL_OBJID(refedge)))
    {
     if(my_numeds)
      {
       *loc_on_edge = (enum EMScvinttype *) om$malloc(size =
		      sizeof(enum EMScvinttype));
       EMerr_hndlr(!*loc_on_edge, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
       (*loc_on_edge)[0] = EMScvint_unknown;
      }
     else *loc_on_edge = NULL;

     for(i=0; i<my_numeds; i++)
      if(IF_EQ_OBJID(refedge, parents[i].grid.objid))
       {
        (*loc_on_edge)[0] = ME.NMvertex_use->edloc[i];
        break;
       }
    }
   else if(edges)
    {
     if(my_numeds)
      {
       *loc_on_edge = (enum EMScvinttype *) om$malloc(size =
		      my_numeds * sizeof(enum EMScvinttype));
       EMerr_hndlr(!*loc_on_edge, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
       OM_BLOCK_MOVE(ME.NMvertex_use->edloc, *loc_on_edge, 
      		     my_numeds * sizeof(enum EMScvinttype));
      }
     else *loc_on_edge = NULL;
    }
   else
    {
     *EMmsg = EMS_E_InvalidArg;
     goto wrapup;
    }
  }

 if(xyzvtx)
  {
   NMmake_chanselect(NMvertex_use_to_vtx, &to_vtx);
   sts = om$get_channel_objects(object = me, p_chanselect = &to_vtx, 
         list = &locxyzvtx, size = 1, count = &count);
   if(!(1&sts)) goto wrapup;
   EMerr_hndlr(!count, *EMmsg, EMS_I_Fail, wrapup);
   xyzvtx->objid = locxyzvtx.S_objid;
   xyzvtx->osnum = locxyzvtx.osnum;
  }

 if(uvpt) OM_BLOCK_MOVE(ME.NMvertex_use->point, uvpt, 2 * sizeof(IGRdouble));

 if(xyzpt)
  {
   if(!xyzvtx)
    {
     NMmake_chanselect(NMvertex_use_to_vtx, &to_vtx);
     sts = om$get_channel_objects(object = me, p_chanselect = &to_vtx, 
           list = &locxyzvtx, size = 1, count = &count);
     if(!(1&sts)) goto wrapup;
     EMerr_hndlr(!count, *EMmsg, EMS_I_Fail, wrapup);
    }

   sts = om$send(msg = message NMvertex.NMpoint(EMmsg, xyzpt, TRUE), 
         targetid = locxyzvtx.S_objid, targetos = locxyzvtx.osnum);
   if(!(1&*EMmsg&sts)) goto wrapup;
  }


if( (1&*EMmsg&sts) && was_invalid) *EMmsg = EMS_I_InvalidCase;

wrapup:
if(parents) om$dealloc(ptr = parents);
EMWRAPUP(*EMmsg, sts, "NMvertex_use.NMget_incedence_info");
return(sts);
}

end implementation NMvertex_use;
