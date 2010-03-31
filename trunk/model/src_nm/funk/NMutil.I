class implementation NMnonmani;

#include "OMmacros.h"

/*
Following are all the global variables used in the NM system.
*/

%safe
IGRboolean NMedgevtxuse_assoc = FALSE;
struct NMgmssi_cache NMnonmanigm_ssi_cache = {2, 4294967295, FALSE, NULL, 0, 0,
					      0, NULL, NULL, 0, 0, 0};
short NMvertex_locatable = 0;
IGRboolean NMvertex_display_and_Rtree = 0;
IGRboolean NMtp_persistent = FALSE;
%endsafe


IGRint NMdisconnect_edges(EMmsg, inters, loop, to_ed, to_lp)
IGRlong *EMmsg;
struct EMSinters *inters[];
GRobjid *loop;
OM_S_CHANSELECT *to_ed, *to_lp;
{
 IGRlong 		sts = OM_S_SUCCESS;
 struct EMSinters	*this_inters = NULL;
 struct EMSintobj	*this_intobj = NULL;
 struct GRid		*this_edge = NULL;
 IGRint			i;

 *EMmsg = EMS_S_Success;
 if(loop && (IF_NULL_OBJID(*loop))) 
  {
   *EMmsg = EMS_I_InvalidSend;
   goto wrapup;
  }

 for(i=0; i<2; i++)
  {
   this_inters = inters[i];
   while(this_inters)
    {
     this_intobj = this_inters->cvs;
     while(this_intobj)
      {
       if(this_intobj->this_uvintobj.datatype != EMSdata_object)
        {
         this_intobj = this_intobj->next;
         continue;
        }
       this_edge = this_intobj->this_uvintobj.data.object;
       if((IF_NULL_OBJID(this_edge->objid)) ||
          ((sts = om$is_objid_valid(objid = this_edge->objid, 
                 osnum = this_edge->osnum)) != OM_S_SUCCESS))
        {
         this_intobj = this_intobj->next;
	 sts = OM_S_SUCCESS;
         continue;
        }

       if(loop)
        {
         sts = om$is_objid_on_channel(objid_c = *loop, p_chanselect = to_ed, 
               objid = this_edge->objid, osnum2 = this_edge->osnum);
         if(sts == OM_S_SUCCESS)
          {
	   sts = om$send(msg = message Root.disconnect(*to_lp, *loop, 
	         OM_Gw_current_OS, *to_ed), targetid = this_edge->objid, 
	         targetos = this_edge->osnum, senderid = *loop);
	   if(!(1&sts)) goto wrapup;
          }
         else sts = OM_S_SUCCESS;
        }
       else
        {
	 sts = om$send(msg = message Root.wild_disconnect(*to_lp), 
	       targetid = this_edge->objid, 
	       targetos = this_edge->osnum, senderid = NULL_OBJID);
         if(!(1&sts)) goto wrapup;
        }
       this_intobj = this_intobj->next;
      }
     this_inters = this_inters->next;
    }
  }
wrapup:
EMWRAPUP(*EMmsg, sts, "NMdisconnect_edges");
return(sts);
}

void NMinit_tracedata(tracedata)
struct EMSsftracedata *tracedata;
{
	
 tracedata->num_grps = 0;
 tracedata->num_subgrps_grp = NULL;
 tracedata->num_elems_subgrp = NULL;
 tracedata->elems = NULL;
 tracedata->subgrp_rev = NULL;
 tracedata->elem_rev = NULL;
 tracedata->grp_closed = NULL;
 tracedata->subgrp_closed = NULL;
}



extern OMuword OPP_NMvertex_class_id;

IGRint NMconstruct_vertex(EMmsg, construct, point, vtx)
IGRlong *EMmsg;
struct GRvg_construct *construct;
IGRdouble *point;
GRobjid *vtx;
{
 IGRlong		sts = OM_S_SUCCESS;
 IGRchar		*save_geom = NULL;
 IGRdouble		junkpt[6];
 struct IGRpolyline	poly;
 struct GRid 		save_mdid;
 IGRushort 	save_props = NULL;

 *EMmsg = EMS_S_Success;

 OM_BLOCK_MOVE(point, &junkpt[0], 3 * sizeof(IGRdouble));
 OM_BLOCK_MOVE(point, &junkpt[3], 3 * sizeof(IGRdouble));
 poly.num_points = 2;
 poly.points = (IGRdouble *) junkpt;

 save_geom = construct->geometry;
 construct->geometry = (IGRchar *) &poly;
 save_mdid = construct->env_info->md_id;
 save_props = construct->properties;
	
 if(!NMvertex_display_and_Rtree)
  {
   construct->env_info->md_id.objid = NULL_OBJID;
   construct->properties |= GRNOT_IN_RTREE;
  }

 sts = om$construct(osnum = construct->env_info->md_id.osnum, 
       classid = OPP_NMvertex_class_id, p_objid = vtx, 
       msg = message GRgraphics.GRaltconstruct(construct));

construct->env_info->md_id = save_mdid;
construct->properties = save_props;
construct->geometry = save_geom;

return(sts);
}

IGRint NMtag(EMmsg, grid, tagid, tagit)
IGRlong *EMmsg;
struct GRid *grid, *tagid;
IGRboolean tagit;
{
 IGRlong	sts = OM_S_SUCCESS;
 
 *EMmsg = EMS_S_Success;

 if(tagit)
  {
   tagid->objid = NULL_OBJID;
   tagid->osnum = grid->osnum;
   EMerr_hndlr(IF_NULL_OBJID(grid->objid), *EMmsg, EMS_I_Useless, wrapup);

   sts = om$add_tag(objid = grid->objid, osnum = grid->osnum, 
	 p_tag = (OMuint *) &tagid->objid);
   if(sts == OM_E_TAGEXISTS)
    sts = om$objid_to_tag(objid = grid->objid, osnum = grid->osnum, 
	   p_tag = (OMuint *) &tagid->objid);
  }
 else
  {
   grid->objid = NULL_OBJID;
   grid->osnum = tagid->osnum;
   EMerr_hndlr(IF_NULL_OBJID(tagid->objid), *EMmsg, EMS_I_Useless, wrapup);
   sts = om$tag_to_objid(tag = (OMuint) tagid->objid, osnum = tagid->osnum, 
         p_objid = (OM_p_OBJID) &grid->objid);
   if(sts == OM_E_NOSUCHTAG)
    {
     *EMmsg = EMS_I_Fail;
     sts = OM_S_SUCCESS;
    }
  }

wrapup:
EMWRAPUP(*EMmsg, sts, "NMtag");
return(sts);
}

end implementation NMnonmani;
