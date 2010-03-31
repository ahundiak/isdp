class implementation NMvertex_use;

#include "OMmacros.h"
#include "EMSprop.h"
#include "emsgeteddef.h"

#define StaticBuf 10
#define Inc	  5

from EMSedge import EMptproject, EMget_props;
extern OMuint OM_Gf_verbose_warning;

method NMconnect_edges(IGRlong *EMmsg; IGRint numedges;
		       GRobjid *edges; 
		       enum EMScvinttype *loc_on_edge;
		       IGRdouble *uvpt; unsigned int connect_opt;
		       struct NMgmSSI *ssi)
{
 IGRlong		sts = OM_S_SUCCESS;
 IGRint			i, count = 0, num_new_edges = 0, j, 
			parentsbufsize = 0, numoldp = 0;
 struct EMSobject_info	*parents = NULL, *oldp = NULL, oldpbuf[StaticBuf];
 struct GRvg_construct	construct;
 struct IGRdisplay	disp;
 struct GRmd_env	env;
 enum EMScvinttype	*loc_loc_on_edge = NULL;
 struct EMSproj_info	projinfo;
 struct EMSpartolbasis	partol;
 struct EMSsfintedpar	inedpar, outedpar;
 IGRboolean		already_connected = FALSE, transient_state = FALSE, 
			add_to_ssi = FALSE, nochecks = FALSE;
 IGRushort	initas_opt = EMS_no_const_assoc 
			| EMSinit_dont_store_recomp_info;
 struct GRid		sfid;
 unsigned int	nmquery_opt = NULL;
 
 *EMmsg = EMS_S_Success;

 if(connect_opt & NMconnect_InTransientState) transient_state = TRUE;
 if( (connect_opt & NMconnect_AddToSSI) && ssi) add_to_ssi = TRUE;
 if(connect_opt & NMconnect_ExternalToModel)
  nmquery_opt = NMquery_ConsiderExternalToModel;
 if(connect_opt & NMconnect_NoChecks) nochecks = TRUE;

 if(!numedges)
  {
   if(transient_state) *EMmsg = EMS_I_InvalidArg;
   else *EMmsg = EMS_E_InvalidArg;
   goto wrapup;
  }

 sts = om$send(msg = message NMassoc.NMget_parent_info(EMmsg, &parents, 0, 
       &count), targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;

 if( ((i = om$dimension_of(varray = ME.NMvertex_use->edloc)) != count) &&
     !transient_state)
  {
   *EMmsg = EMS_E_Fail;
   goto wrapup;  
  }

 construct.display = &disp;
 construct.class_attr = NULL;
 construct.msg = EMmsg;
 construct.env_info = &env;
 EMidmatrix(EMmsg, &env.md_env.matrix_type, env.md_env.matrix);
 env.md_id.osnum = OM_Gw_current_OS;
 env.md_id.objid = NULL_OBJID;
 sts = om$send(msg = message EMSassoc.EMget_construction_info(EMmsg, &construct),
       targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;
 construct.newflag = FALSE;

 /* Capture the old parent data for future use.
 */
 if(add_to_ssi && count)
  {
   if(count > StaticBuf)
    oldp = (struct EMSobject_info *) om$malloc(size = count * 
	    sizeof(struct EMSobject_info));
   else
    oldp = oldpbuf;
   EMerr_hndlr(!oldp, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
   OM_BLOCK_MOVE(parents, oldp, count * sizeof(struct EMSobject_info));
   numoldp = count;
  }
 else numoldp = 0;

 if(parents)
  parents = (struct EMSobject_info *) om$realloc(ptr = (IGRchar *)parents, 
	    size = (count + numedges + Inc) * sizeof(struct EMSobject_info));
 else
  parents = (struct EMSobject_info *) om$malloc(size = (numedges + Inc) * 
	    sizeof(struct EMSobject_info));
 EMerr_hndlr(!parents, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

 loc_loc_on_edge = (enum EMScvinttype *) om$malloc(size = (count+numedges+Inc) 
		    * sizeof(enum EMScvinttype));
 EMerr_hndlr(!loc_loc_on_edge, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

 if(count) OM_BLOCK_MOVE(ME.NMvertex_use->edloc, loc_loc_on_edge, count *
	sizeof(enum EMScvinttype));
 parentsbufsize = numedges + Inc;



 /* For each input edge, if my location on it is middle, try to move myself
    to an appropriate NMpartedge if one exists. If such an edge does not
    exist, do nothing at this time. Splitting and creation of such edges
    will occur when connecting up all the vertex uses to the vertex, when
    more information is available.
 */
 partol.is_valid = FALSE;
 partol.in_world = TRUE;
 partol.mattyp = &env.md_env.matrix_type;
 partol.mat = env.md_env.matrix;
 sfid.objid = NULL_OBJID;

 if(!nochecks)
  {
   for(i=0; i<numedges; i++) 
    {
     struct GRid junk;

     junk.objid = edges[i];
     junk.osnum = OM_Gw_current_OS;
     sts = NMfind_sf_no_matter_what(EMmsg, &junk, &sfid, &partol, NULL);
     if(!(1&*EMmsg&sts))
      {
       if(transient_state)
        {
	 *EMmsg = EMS_S_Success;
	 sts = OM_S_SUCCESS;
        }
       else goto wrapup;
      }
     if(partol.is_valid) break;
    }
  }


 num_new_edges = count; 
 for(i=0; i<numedges; i++)
  {
   already_connected = FALSE;
   for(j=0; j<num_new_edges; j++)
    {
     if(!nochecks && !partol.is_valid)
      {
       sts = NMfind_sf_no_matter_what(EMmsg, &parents[j].grid, NULL, &partol, 
		NULL);
       if(!(1&*EMmsg&sts))
        {
         if(transient_state)
          {
	   *EMmsg = EMS_S_Success;
	   sts = OM_S_SUCCESS;
          }
         else goto wrapup;
        }
      }
     if(IF_EQ_OBJID(edges[i], parents[j].grid.objid))
      {
       already_connected = TRUE;
       break;
      }
    }
   if(already_connected) continue;

   if(add_to_ssi && (IF_NULL_OBJID(sfid.objid)))
    {
     *EMmsg = EMS_E_Fail;
     goto wrapup;
    }

  /* Check whether the vertex use can be shifted to some NMpartedge.
  */
  outedpar.edgeid = NULL_OBJID;

  if(!transient_state && !nochecks)
   {
    if(loc_on_edge[i] == EMScvint_middle)
     {
      /* Just to get the edpar. This is required by the NMincedence function
         only of the location on the edge was in middle.
      */
      sts = om$send(msg = message EMSedge.EMptproject(EMmsg, uvpt, 1,&projinfo,
            NULL, &partol), targetid = edges[i]);
      if(!(1&*EMmsg&sts)) goto wrapup;
     }

    inedpar.edgeid = edges[i];
    inedpar.intloc = loc_on_edge[i];
    inedpar.edgepar = projinfo.param;
    OM_BLOCK_MOVE(uvpt, inedpar.point, 2 * sizeof(IGRdouble));

    sts = NMincedence(EMmsg, &inedpar, &sfid, &partol, &outedpar);
    if(!(1&*EMmsg&sts)) goto wrapup;
    if(*EMmsg == EMS_I_NotFound) outedpar.edgeid = NULL_OBJID;
    if(inedpar.intloc != loc_on_edge[i])
     loc_on_edge[i] = inedpar.intloc;
   }

  if(!parentsbufsize)
   {
    parents = (struct EMSobject_info *) om$realloc(ptr = (IGRchar *)parents, 
              size = (num_new_edges + Inc) * sizeof(struct EMSobject_info));
    EMerr_hndlr(!parents, *EMmsg,EMS_E_NoDynamicMemory, wrapup);

    loc_loc_on_edge = (enum EMScvinttype *) om$realloc(
	     ptr = (IGRchar *)loc_loc_on_edge, size = (num_new_edges + Inc) * 
	     sizeof(enum EMScvinttype));
    EMerr_hndlr(!loc_loc_on_edge, *EMmsg,EMS_E_NoDynamicMemory, wrapup);
    parentsbufsize = Inc;
   }


  if(IF_NULL_OBJID(outedpar.edgeid))
   {
    already_connected = FALSE;
    for(j=0; j<num_new_edges; j++)
     {
      if(IF_EQ_OBJID(edges[i], parents[j].grid.objid))
       {
        already_connected = TRUE;
        break;
       }
     }
    if(already_connected) continue;

    parents[num_new_edges].grid.objid = edges[i];
    parents[num_new_edges].grid.osnum = OM_Gw_current_OS;
    parents[num_new_edges].env = env;
    loc_loc_on_edge[num_new_edges++] = loc_on_edge[i];
    parentsbufsize--;
   }
  else
   {
     /* Modified the incedence.
     */
    already_connected = FALSE;
    for(j=0; j<num_new_edges; j++)
     {
      if(IF_EQ_OBJID(outedpar.edgeid, parents[j].grid.objid))
       {
        already_connected = TRUE;
        break;
       }
     }
    if(already_connected) continue;

    parents[num_new_edges].grid.objid = outedpar.edgeid;
    parents[num_new_edges].grid.osnum = OM_Gw_current_OS;
    parents[num_new_edges].env = env;
    loc_loc_on_edge[num_new_edges++] = outedpar.intloc;
    parentsbufsize--;
   }

   /* If the edge which we just added to the parent list, uses this vertex
      use at its either end, then search the active loop in the appropriate
      direction (next/previous) to get the other edge which should also be
      connected to this vertex use. If the original edge or the searched
      edge happens to be degenerate (EMED_DEGENERATE), then continue the
      search to collect all possible edges.
   */
   if(transient_state || nochecks) continue;

   if( (loc_loc_on_edge[num_new_edges - 1] == EMScvint_rtend) ||
       (loc_loc_on_edge[num_new_edges - 1] == EMScvint_lfend))
    {
     GRobjid refedge, search_edge = NULL_OBJID;
     IGRushort lpopt = NULL, edprops = NULL;

     refedge = parents[num_new_edges - 1].grid.objid;
     lpopt = (loc_loc_on_edge[num_new_edges - 1] == EMScvint_rtend) ?
	     EMGetEd_Next : EMGetEd_Previous;
	
     while(TRUE)
      {
       search_edge = NULL_OBJID;
       sts = NMnext_edge(EMmsg, lpopt, refedge, OM_Gw_current_OS,&search_edge);

       /* If the edge found is in the input list, ignore it.
       */
       if(!IF_NULL_OBJID(search_edge))
        for(j=0; j<numedges; j++)
         if(IF_EQ_OBJID(edges[j], search_edge))
          goto next_edge;

       if( (IF_NULL_OBJID(search_edge)) || 
	   (IF_EQ_OBJID(search_edge, refedge))) goto next_edge;

       sts = om$send(msg = message EMSedge.EMget_props(EMmsg, &edprops), 
	     targetid = search_edge);
       if(!(1&*EMmsg&sts)) goto wrapup;

       /* If the edge found is already in the list, ignore it.
       */
       for(j=0; j<num_new_edges; j++)
        if(IF_EQ_OBJID(search_edge, parents[j].grid.objid))
         goto next_edge;

       if(!parentsbufsize)
        {
         parents = (struct EMSobject_info *) om$realloc(ptr = (IGRchar *)parents, 
            size = (num_new_edges + Inc) * sizeof(struct EMSobject_info));
         EMerr_hndlr(!parents, *EMmsg,EMS_E_NoDynamicMemory, wrapup);

         loc_loc_on_edge = (enum EMScvinttype *) om$realloc(
	     ptr = (IGRchar *)loc_loc_on_edge, size = (num_new_edges + Inc) * 
	     sizeof(enum EMScvinttype));
         EMerr_hndlr(!loc_loc_on_edge, *EMmsg,EMS_E_NoDynamicMemory, wrapup);
	 parentsbufsize = Inc;
        }

       parents[num_new_edges].grid.objid = search_edge;
       parents[num_new_edges].grid.osnum = OM_Gw_current_OS;
       parents[num_new_edges].env = env;
       loc_loc_on_edge[num_new_edges++] = lpopt & EMGetEd_Next ?
					  EMScvint_lfend : EMScvint_rtend;
       parentsbufsize--;

next_edge:

       /* If the edge just found was degenerate, continue the search.
       */
       if(edprops & EMED_DEGENERATE)
        refedge = search_edge;
       else
        break;

      } /* while(TRUE) */

    } /* If at end of an edge */

  } /* for(i=0; i<numedges; i++) */


 /* Validation pass. Make sure that none of the edges has another active
    vertex use at the same point.
 */
 if(uvpt && !transient_state && !nochecks)
  for(i=0; i<num_new_edges; i++)
   {
    GRobjid vtxuse = NULL_OBJID, vtx = NULL_OBJID;

    if(!partol.is_valid)
     {
      sts = NMfind_sf_no_matter_what(EMmsg, &parents[i].grid, NULL, &partol, 
		NULL);
      if(!(1&*EMmsg&sts)) goto wrapup;
      if(!partol.is_valid) continue;
     }
    sts = NMget_matching_vtxuse(EMmsg, parents[i].grid.objid,
          parents[i].grid.osnum, uvpt, partol.tol, &loc_loc_on_edge[i], 
          &vtxuse, &vtx, nmquery_opt);
    if(!(1&*EMmsg&sts)) goto wrapup;
    if((!IF_NULL_OBJID(vtxuse)) && (!IF_EQ_OBJID(vtxuse, my_id)))
     {
      *EMmsg = EMS_E_InvalidCase;
      goto wrapup;
     }
   }


 /* Disconnect all parents before reinitialization.
 */
 if(count)
  {
   sts = om$send(msg = message NDnode.NDdisconnect(0, NULL), targetid = my_id);
   if(!(1&sts)) goto wrapup;
  }


 /* Establish parent-child relationship with all the edges.
 */
 sts = om$send(msg = message EMSassoc.EMinit_associative(EMmsg, 
       initas_opt, num_new_edges, parents, NULL, NULL, NULL, 
       &construct), targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;

 sts = om$vla_set_dimension(varray = ME.NMvertex_use->edloc, 
			    size = num_new_edges);
 if(!(1&sts)) goto wrapup;
 OM_BLOCK_MOVE(loc_loc_on_edge, ME.NMvertex_use->edloc, num_new_edges
		* sizeof(enum EMScvinttype));
 if(uvpt) OM_BLOCK_MOVE(uvpt, ME.NMvertex_use->point, 2*sizeof(IGRdouble));

 if(add_to_ssi)
  {
   IGRboolean was_oldp;

   for(i=0; i<num_new_edges; i++)
    {
     was_oldp = FALSE;
     for(j=0; j<numoldp; j++)
      if(IF_EQ_OBJID(oldp[j].grid.objid, parents[i].grid.objid))
       {
	was_oldp = TRUE;
	break;
       }
     if(!was_oldp)
      {
       sts = NMstore_vtxuse_change(EMmsg, ssi, &sfid, my_id, NULL_OBJID, 
             parents[i].grid.objid);
       if(!(1&*EMmsg&sts)) goto wrapup;
      }
    }
  }

wrapup:
if(parents) om$dealloc(ptr = parents);
if(loc_loc_on_edge) om$dealloc(ptr = loc_loc_on_edge);
if(oldp && (oldp != oldpbuf)) om$dealloc(ptr = oldp);

if(OM_Gf_verbose_warning)
 {
  EMWRAPUP(*EMmsg, sts, "NMvertex_use.NMconnect_edges");
 }
return(sts);
}


end implementation NMvertex_use;
