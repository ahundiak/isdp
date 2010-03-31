/*
This function will accept intersection data on a surface and construct
non manifold topological elements.
The incedence information (sfintedpars in the intobj node) WILL BE
MODIFIED.
*/
class implementation NMnonmani;

#include "OMmacros.h"
#include "emsdef.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "nm.h"
#include "EMSprop.h"
#include "EMSopt.h"
#include "emsmacros.h"
#include "godef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "EMSfrtdef.h"

from EMSloop import EMmodify_edge, EMset_props;
from NMfeaturelp import NMflpinit, NMget_nesting_parent;
from EMSedge import EMset_props, EMendpts, EMgetbounds, EMtst_reversibility;
from EMSpartedge import EMputbounds;
from NMedge import NMconnect_edges, NMinit;
from NMvertex_use import NMconnect_edges, NMinit;
from NMvertex import NMconnect_vertex_uses, NMinit;
from EMSsubbs import EMpartolbasis;

extern OMuword OPP_NMlistedge_class_id, OPP_NMedge_class_id, 
	       OPP_NMfeaturelp_class_id, OPP_NMptflp_class_id, 
               OPP_NMlistvtxuse_class_id, OPP_NMvertex_use_class_id, 
	       OPP_NMvertex_class_id, OPP_EMSpartedge_class_id, 
	       OPP_EMSptedge_class_id;

extern IGRboolean NMvertex_display_and_Rtree;

#define NmInc 10
#define VtxInc 10

extern IGRboolean NMedgevtxuse_assoc;

struct NMsfinfo
{
 struct GRid sfid;
 struct EMSpartolbasis ptol;
};

#argsused

IGRlong NMcreate_topology(EMmsg, inters, tr, construct, options, ssi)
IGRlong *EMmsg;
struct EMSinters *inters;
struct EMSsftracedata *tr;
struct GRvg_construct *construct;
IGRushort options;
struct NMgmSSI *ssi;
{
 IGRlong		sts = OM_S_SUCCESS, rc;
 IGRint			i, j, l;
 OMuint			count;
 struct NMentities 	*this_nm = NULL;
 struct GRid		this_sf;
 OM_S_OBJECT_LINKAGE	this_ls;
 struct EMSintobj	*this_intobj;

 GRobjid		this_edge, this_nmedge, this_vtx, this_lp, this_vtxuse,
			this_grp_beginvtxuse = NULL_OBJID, 
			this_grp_beginvtx = NULL_OBJID,
			prev_subgrp_endvtxuse[2], prev_subgrp_endvtx[2] , 
			this_subgrp_endvtxuse[2], this_subgrp_endvtx[2];
 
 struct NMsfinfo	this_grp_beginsfid, prev_subgrp_endsfid[2], 
			this_subgrp_endsfid[2];

 struct EMSsfintedpar	*this_edpar = NULL, *this_grp_beginedpar = NULL, 
			*prev_subgrp_endedpar[2], *this_subgrp_endedpar[2], 
			this_grp_edgeedpar, prev_subgrp_edgeedpar[2], 
			this_subgrp_edgeedpar[2];
			
 GRspacenum		constos;
 IGRboolean		this_edge_reversed;
 IGRushort	lpprops = NULL;
 IGRboolean		onlyvtx = FALSE;
 IGRdouble		thispartol, xyzlentol;
 OM_S_CHANSELECT	to_loopset;

 *EMmsg = EMS_S_Success;
 constos = construct->env_info->md_id.osnum;
 BSEXTRACTPAR(&rc, BSTOLLENVEC, xyzlentol);
 onlyvtx = (options & NMcreatetp_OnlyVtx) ? TRUE : FALSE;
 EMmake_chanselect(EMSsubbs_to_loopset, &to_loopset);


 /* Loop through the intersection data, creating the non manifold topology.
 */
 for(i=0; i<tr->num_grps; i++)
  {
   for(j=0; j<tr->num_subgrps_grp[i]; j++)
    {
     if(tr->elems[i][j])
      {
       this_sf = tr->elems[i][j]->this_obj_node->this_obj;
       sts = om$get_channel_objects(objid = this_sf.objid, 
             osnum = this_sf.osnum, p_chanselect = &to_loopset, 
             list = &this_ls, size = 1, count = &count);
       if(!(1&sts)) goto wrapup;
      }

     if(!IF_NULL_OBJID(this_sf.objid))
      {
        IGRboolean world = TRUE;

       sts = om$send(msg = message EMSsubbs.EMpartolbasis(EMmsg, 
             &construct->env_info->md_env.matrix_type, 
	     construct->env_info->md_env.matrix, &world, TRUE, &thispartol), 
             targetid = this_sf.objid, targetos = this_sf.osnum, 
             senderid = NULL_OBJID);
       if(!(1&*EMmsg&sts)) goto wrapup;
      }
     else thispartol = 0.00000001;

     this_intobj = tr->elems[i][j];
     if(!onlyvtx)
      {
       IGRboolean	isptlp = FALSE;
       struct GRid	*pted;

       if(tr->num_elems_subgrp[i][j] == 1)
        {
         pted = this_intobj->this_uvintobj.data.object;
         isptlp = EFisAncestryValid(EMmsg, pted->objid, pted->osnum, 
		  OPP_EMSptedge_class_id, TRUE);
        }

       lpprops = EMLP_ACTIVE;
       if(!tr->subgrp_closed[i][j]) lpprops |= EMLP_OPEN;
       sts = om$construct(osnum = constos, 
	     classid = isptlp ? OPP_NMptflp_class_id 
			      : OPP_NMfeaturelp_class_id, 
	     p_objid = &this_lp, msg = message EMSloop.EMset_props(EMmsg, 
	     lpprops, EMS_O_ON));
       if(!(1&sts)) goto wrapup;

       /* Untill we know better put loopset as the nesting parent.
       */
       sts = om$send(msg = message NMfeaturelp.NMget_nesting_parent(EMmsg, 
	     &this_ls.S_objid, FALSE), senderid = NULL_OBJID, 
	     targetid = this_lp, targetos = constos);
       if(!(1&sts)) goto wrapup;	
      }

     for(l=0; l<tr->num_elems_subgrp[i][j]; l++)
      {
       GRobjid other_edge = NULL_OBJID;

       this_edge = this_intobj->this_uvintobj.data.object->objid;

       if(!onlyvtx && tr->grp_closed[i] && (tr->num_subgrps_grp[i] == 1) &&
                               (tr->num_elems_subgrp[i][j] == 1))
        {
	 sts = om$send(msg = message EMSedge.EMset_props(EMmsg, 
	       EMED_XYZ_CLOSED, EMS_O_ON), targetid = this_edge, 
	       targetos = constos, 
	       senderid = NULL_OBJID);
	 if(!(1&sts)) goto wrapup;
	 if(this_intobj->other_intobj_node)
	  {
	   other_edge = 
	    this_intobj->other_intobj_node->this_uvintobj.data.object->objid;
	   sts = om$send(msg = message EMSedge.EMset_props(EMmsg, 
	         EMED_XYZ_CLOSED, EMS_O_ON), targetid = other_edge, 
	         targetos = constos, senderid = NULL_OBJID);
	   if(!(1&sts)) goto wrapup;
	  }
	}

       this_edge_reversed = this_intobj->reversed;
       if(tr->elem_rev[i][j][l]) this_edge_reversed = !this_edge_reversed;

       if(!onlyvtx && this_edge_reversed)
        {
         sts = NMreverse_the_edge(EMmsg, this_edge, constos);
	 sts = NMsetUpSSI(EMmsg, &this_sf, ssi, &this_nm);
	 if(!(1&*EMmsg&sts)) goto wrapup;
	
	 this_nm->edgesrev[this_nm->numedgesrev++] = this_edge;
	 this_nm->edgesrevbufsize--;
	 
        } /* if(!onlyvtx && this_edge_reversed) */

       /* Connect this edge to the feature loop */

       if(!onlyvtx)
	{
         sts = om$send(mode = OM_e_wrt_message, 
	       msg = message EMSloop.EMmodify_edge(EMmsg, 
	       EMS_INS_ATEND, 1, NULL_OBJID, &this_edge, FALSE), 
	       targetid = this_lp, 
               targetos = constos, senderid = NULL_OBJID);
         if(!(1&*EMmsg&sts)) goto wrapup;
	}

       if(!onlyvtx && this_intobj->other_intobj_node && 
          !(options & NMcreatetp_NmEdgesConnected))
        {
	 struct GRid	junkedges[2], junksfs[2];
         IGRboolean reverse[2], this_rev, other_rev, *revptr = NULL;

	 junkedges[0].osnum = constos;
	 junkedges[0].objid = this_edge;
	 junkedges[1] = 
	          *(this_intobj->other_intobj_node->this_uvintobj.data.object);
	 junksfs[0] = this_sf;
	 junksfs[1] = this_intobj->other_intobj_node->this_obj_node->this_obj;

         reverse[0] = FALSE;

         /* If the input data is not oriented, check explicitly for the
            reverse connectedness of the two edges.
         */
	 if(options & NMcreatetp_NonOrientedInput)
	  {
	   sts = om$send(msg = message EMSedge.EMtst_reversibility(EMmsg, 
	         &reverse[1], junkedges[1].objid, junksfs[0].objid, 
	         junksfs[1].objid, FALSE, construct->env_info), 
	         senderid = NULL_OBJID, targetid = junkedges[0].objid, 
	         targetos = junkedges[0].osnum);
	   if(!(1&*EMmsg&sts)) goto wrapup;	
	  }
	 else
	  {
	   this_rev = this_intobj->reversed;
	   other_rev = this_intobj->other_intobj_node->reversed;

           if ((this_rev && !other_rev) ||
               (!this_rev && other_rev))
            reverse[1] = TRUE;
           else reverse[1] = FALSE;
          }

        revptr = reverse;

	 this_nmedge = NULL_OBJID;
	 if(options & NMcreatetp_CheckNmEdges)
	  {
	   struct GRid	nm;
	
 	   nm.objid = NULL_OBJID;
	   sts = NMget_edge_mates(EMmsg, &junkedges[1], NULL, NULL, NULL, NULL,
	         NULL, &nm, NULL, NULL, NULL);
	   if(!(1&*EMmsg&sts)) goto wrapup;
           this_nmedge = nm.objid;
	  }

	 if(IF_NULL_OBJID(this_nmedge))
	  {
           /* Construct a NMedge.
           */
           sts = om$construct(osnum = constos, 
		 classid = NMedgevtxuse_assoc ? OPP_NMedge_class_id :
			   OPP_NMlistedge_class_id,
                 p_objid = &this_nmedge, msg = message NMedge.NMinit
                 (EMmsg, NMinit_AddToSSI, NMedge_Active, 0, NULL, NULL, NULL, 
		  NULL, ssi));
           if(!(1&sts)) goto wrapup;
          }

         /* Connect up the two edges to the NMedge.
         */
	 revptr = NULL;
         sts = om$send(msg = message NMedge.NMconnect_edges
               (EMmsg, 2, junkedges, junksfs, revptr, construct->env_info, NULL, 
		NMconnect_AddToSSI), 
               targetid = this_nmedge, targetos = constos, 
               senderid = NULL_OBJID);
         if(!(1&sts)) goto wrapup;
        }

       /* Vertex_Use objects need to be constructed at the ends of the
          feature loop. The vertex use objects from successive subgroups
          also need to be connected to the common Vertex object, since they
          match up in model space.
          The above to be done only if the feature loop ends on an existing
          boundary.
	  A check is made so see whether a vertex_use (and consequently
	  a vertex) already exists at the point under consideration. If so
	  the existing objects need to be used.
	  Even if there is no pre-existing vertex use in this parametric
	  space, there could be a pre_existing model space vertex connected
	  to one of the mating edges of the edge under consideration. A check
	  is made to use such vertices too.
       */

       if(/*!tr->subgrp_closed[i][j] && */
          (!l || (l == (tr->num_elems_subgrp[i][j] - 1))))
        {
	 enum EMScvinttype this_edge_loc;

	 /* Pick the begin point of the first edge or the end point of the
	    last edge as the case may be.
	 */
	 
         if(!l)		/* First edge in the subgroup */
          {
	   this_edpar = (struct EMSsfintedpar *) this_intobj->more_info;
	   if(this_edge_reversed) this_edpar = this_edpar->next;
	
           sts = NMmodify_incedence(EMmsg, this_edpar, thispartol, &this_sf);
           if(!(1&*EMmsg&sts)) goto wrapup;

           this_edge_loc = EMScvint_lfend;
           if(IF_NULL_OBJID(this_edpar->edgeid))
	    {
             this_vtxuse = NULL_OBJID;
	     this_vtx = NULL_OBJID;
	    }
           else
            {
	     GRobjid edges[2];
	     enum EMScvinttype edloc[2];
	
	     edges[0] = this_edge;
	     edges[1] = this_edpar->edgeid;
	     edloc[0] = this_edge_loc;
	     edloc[1] = this_edpar->intloc;

	     this_vtxuse = NULL_OBJID;
   
             sts = NMget_matching_vtxuse(EMmsg, this_edpar->edgeid, 
		   this_sf.osnum, this_edpar->point, thispartol,
		   &this_edpar->intloc, &this_vtxuse, &this_vtx, NULL);
	     if(!(1&*EMmsg&sts)) goto wrapup;
	
	     if(IF_NULL_OBJID(this_vtxuse))
	      {
               sts = NMget_matching_vtxuse(EMmsg, this_edge, 
		   this_sf.osnum, this_edpar->point, thispartol,
		   &this_edge_loc, &this_vtxuse, &this_vtx, NULL);
	       if(!(1&*EMmsg&sts)) goto wrapup;
	      }
	
             if(IF_NULL_OBJID(this_vtxuse))
              {
	       sts = om$construct(osnum = constos, p_objid = &this_vtxuse, 
	             classid = NMedgevtxuse_assoc ? OPP_NMvertex_use_class_id 
			       : OPP_NMlistvtxuse_class_id, 
		     msg = message NMvertex_use.NMinit
			   (EMmsg, NMinit_AddToSSI, NMvtxuse_Active, 0, NULL, 
			    NULL, NULL, ssi, &this_sf));
	       if(!(1&*EMmsg&sts)) goto wrapup;
	      }
             sts = om$send(msg = message NMvertex_use.NMconnect_edges(EMmsg, 2,
                   edges, edloc, this_edpar->point, NMconnect_AddToSSI, ssi), 
		   senderid = NULL_OBJID, targetid = this_vtxuse, 
		   targetos = constos);
	     if(!(1&sts)) goto wrapup;
	
	    }
           this_subgrp_endedpar[0] = this_edpar;
	   this_subgrp_endvtxuse[0] = this_vtxuse;
	   this_subgrp_endsfid[0].sfid = this_sf;
	   this_subgrp_endsfid[0].ptol.tol = thispartol;
	   this_subgrp_endsfid[0].ptol.is_valid = TRUE;	
	   this_subgrp_endvtx[0] = this_vtx;
	   this_subgrp_edgeedpar[0].edgeid = this_edge;
	   this_subgrp_edgeedpar[0].intloc = this_edge_loc;
	   sts = om$send(msg = message EMSedge.EMendpts(EMmsg, 
	         this_subgrp_edgeedpar[0].point, NULL,
	         &this_subgrp_edgeedpar[0].edgepar, NULL, NULL), 
	         targetid = this_edge, targetos = constos, 
	         senderid = NULL_OBJID);
	   if(!(1&*EMmsg&sts)) goto wrapup;
	
          } /* if(!l) */

         /* last edge in the subgroup. */
         if(l == (tr->num_elems_subgrp[i][j] - 1))
          {
  	   this_edpar = (struct EMSsfintedpar *) this_intobj->more_info;
	   if(!this_edge_reversed) this_edpar = this_edpar->next;

           sts = NMmodify_incedence(EMmsg, this_edpar, thispartol, &this_sf);
           if(!(1&*EMmsg&sts)) goto wrapup;

           this_edge_loc = EMScvint_rtend;
           if(IF_NULL_OBJID(this_edpar->edgeid))
	    {
             this_vtxuse = NULL_OBJID;
	     this_vtx = NULL_OBJID;
	    }
           else
            {
	     GRobjid edges[2];
	     enum EMScvinttype edloc[2];
	
	     edges[0] = this_edge;
	     edges[1] = this_edpar->edgeid;
	     edloc[0] = this_edge_loc;
	     edloc[1] = this_edpar->intloc;

	     this_vtxuse = NULL_OBJID;

             sts = NMget_matching_vtxuse(EMmsg, this_edpar->edgeid, 
		   this_sf.osnum, this_edpar->point, thispartol, 
		   &this_edpar->intloc, &this_vtxuse, &this_vtx, NULL);
	     if(!(1&*EMmsg&sts)) goto wrapup;
	     if(IF_NULL_OBJID(this_vtxuse))
	      {
               sts = NMget_matching_vtxuse(EMmsg, this_edge, 
		   this_sf.osnum, this_edpar->point, thispartol,
		   &this_edge_loc, &this_vtxuse, &this_vtx, NULL);
	       if(!(1&*EMmsg&sts)) goto wrapup;
	      }

	     if(IF_NULL_OBJID(this_vtxuse))
	      {
	       sts = om$construct(osnum = constos, p_objid = &this_vtxuse, 
	             classid = NMedgevtxuse_assoc ? OPP_NMvertex_use_class_id
			       : OPP_NMlistvtxuse_class_id, 
	             msg = message NMvertex_use.NMinit
	             (EMmsg, NMinit_AddToSSI, NMvtxuse_Active, 0, NULL, NULL, 
		      NULL, ssi, &this_sf));
	       if(!(1&*EMmsg&sts)) goto wrapup;
	      }
             sts = om$send(msg = message NMvertex_use.NMconnect_edges(EMmsg, 2,
	           edges, edloc, this_edpar->point, NMconnect_AddToSSI, ssi), 
		   senderid = NULL_OBJID, 
	           targetid = this_vtxuse, targetos = constos);
             if(!(1&sts)) goto wrapup;
	    }
	
	   this_subgrp_endedpar[1] = this_edpar;
	   this_subgrp_endvtxuse[1] = this_vtxuse;
	   this_subgrp_endsfid[1].sfid = this_sf;
	   this_subgrp_endsfid[1].ptol.tol = thispartol;
	   this_subgrp_endsfid[1].ptol.is_valid = TRUE;	
	   this_subgrp_endvtx[1] = this_vtx;
	   this_subgrp_edgeedpar[1].edgeid = this_edge;
	   this_subgrp_edgeedpar[1].intloc = this_edge_loc;
	   sts = om$send(msg = message EMSedge.EMendpts(EMmsg, 
	         NULL, this_subgrp_edgeedpar[1].point,
	         NULL, &this_subgrp_edgeedpar[1].edgepar, NULL), 
	         targetid = this_edge, targetos = constos, 
	         senderid = NULL_OBJID);
	   if(!(1&*EMmsg&sts)) goto wrapup;
	
	
	   if(tr->subgrp_rev[i][j])
	    {
	     struct EMSsfintedpar *junkedpar, junkedgepar;
	     GRobjid junkvtxuse, junkvtx;
	     struct NMsfinfo junksfid;
	
	     junkedpar = this_subgrp_endedpar[1];
	     junkvtxuse = this_subgrp_endvtxuse[1];
	     junksfid = this_subgrp_endsfid[1];
	     junkvtx = this_subgrp_endvtx[1];
	     junkedgepar = this_subgrp_edgeedpar[1];
	
	     this_subgrp_endedpar[1] = this_subgrp_endedpar[0];
	     this_subgrp_endvtxuse[1] = this_subgrp_endvtxuse[0];
	     this_subgrp_endsfid[1] = this_subgrp_endsfid[0];
	     this_subgrp_endvtx[1] = this_subgrp_endvtx[0];
	     this_subgrp_edgeedpar[1] = this_subgrp_edgeedpar[0];
	
	     this_subgrp_endedpar[0] = junkedpar;
	     this_subgrp_endvtxuse[0] = junkvtxuse;
	     this_subgrp_endsfid[0] = junksfid;
	     this_subgrp_endvtx[0] = junkvtx;
	     this_subgrp_edgeedpar[0] = junkedgepar;
	    }
	
	   /* Connect this subgroup's begin vertex use to the end vertex
	      use of the previous subgrp
	   */
	   if(j && !(IF_NULL_OBJID(this_subgrp_endvtxuse[0]) &&
	             IF_NULL_OBJID(prev_subgrp_endvtxuse[1])))
	    {
	     struct GRid	vtxuses[2], sfid;
	     IGRpoint		xyzpt;
	     IGRint		num = 0;
	     struct EMSsfintedpar *edpar = NULL, edgeedpar, outedpar;
	     GRobjid		convtx[2];
	     IGRdouble		*ptptr = NULL;
	     struct EMSpartolbasis   struct_partol;
	
	     vtxuses[0].osnum = vtxuses[1].osnum = constos;	
	     if(!IF_NULL_OBJID(prev_subgrp_endvtxuse[1]))    
	      {
	       convtx[num] = prev_subgrp_endvtx[1];
               vtxuses[num++].objid = prev_subgrp_endvtxuse[1];
               sfid = prev_subgrp_endsfid[1].sfid;
               struct_partol = prev_subgrp_endsfid[1].ptol;
               edpar = prev_subgrp_endedpar[1];
          
               outedpar.edgeid = NULL_OBJID;
               sts = NMincedence(EMmsg, edpar, &sfid, &struct_partol, 
			         &outedpar);
               if(!(1&*EMmsg&sts)) goto wrapup;
               if( (*EMmsg != EMS_I_NotFound) && 
		   (!IF_NULL_OBJID(outedpar.edgeid)))
		*edpar = outedpar;

 	       edgeedpar = prev_subgrp_edgeedpar[1];
               outedpar.edgeid = NULL_OBJID;
               sts = NMincedence(EMmsg, &edgeedpar, &sfid, &struct_partol, 
			         &outedpar);
               if(!(1&*EMmsg&sts)) goto wrapup;
               if( (*EMmsg != EMS_I_NotFound) && 
		   (!IF_NULL_OBJID(outedpar.edgeid)))
		edgeedpar = outedpar;

	      }
	     if(!IF_NULL_OBJID(this_subgrp_endvtxuse[0]))
	      {
	       convtx[num] = this_subgrp_endvtx[0];
               vtxuses[num++].objid = this_subgrp_endvtxuse[0];
               sfid = this_subgrp_endsfid[0].sfid;
               struct_partol = this_subgrp_endsfid[0].ptol;
               edpar = this_subgrp_endedpar[0];

               outedpar.edgeid = NULL_OBJID;
               sts = NMincedence(EMmsg, edpar, &sfid, &struct_partol, 
			         &outedpar);
               if(!(1&*EMmsg&sts)) goto wrapup;
               if( (*EMmsg != EMS_I_NotFound) && 
		   (!IF_NULL_OBJID(outedpar.edgeid)))
		*edpar = outedpar;

	       edgeedpar = this_subgrp_edgeedpar[0];
               outedpar.edgeid = NULL_OBJID;
               sts = NMincedence(EMmsg, &edgeedpar, &sfid, &struct_partol, 
			         &outedpar);
               if(!(1&*EMmsg&sts)) goto wrapup;
               if( (*EMmsg != EMS_I_NotFound) && 
		   (!IF_NULL_OBJID(outedpar.edgeid)))
		edgeedpar = outedpar;
	      }
	
	     if(IF_NULL_OBJID(convtx[0]))
	     {
	      sts = NMget_xyz_point(edpar, construct, sfid.objid, xyzpt);
  	      if(!(1&sts)) goto wrapup;
              sts = NMget_matching_vtx(EMmsg, edgeedpar.edgeid, sfid.osnum,
		    xyzpt, xyzlentol, &edgeedpar.intloc, &this_vtx, NULL);
              if(!(1&*EMmsg&sts)) goto wrapup;
              if(IF_NULL_OBJID(this_vtx))
               {
                sts = NMget_matching_vtx(EMmsg, edpar->edgeid, sfid.osnum, 
		      xyzpt, xyzlentol, &edpar->intloc, &this_vtx, NULL);
                if(!(1&*EMmsg&sts)) goto wrapup;
               }

              if(IF_NULL_OBJID(this_vtx))
    	       {
                ptptr = xyzpt;
		sts = NMconstruct_vertex(EMmsg, construct, xyzpt, &this_vtx);
		sts = om$send(msg = message NMvertex.NMinit
		      (EMmsg, NMinit_AddToSSI, NMvtx_Active, 0, NULL, NULL, 
		       ssi), senderid = NULL_OBJID, 
		      targetid = this_vtx, targetos = constos);
		if(!(1&*EMmsg&sts)) goto wrapup;
	       }
	     }
	    else this_vtx = convtx[0];
	
	     sts = om$send(msg = message NMvertex.NMconnect_vertex_uses(EMmsg, 
                   num, vtxuses, ptptr, ssi, NMconnect_AddToSSI), 
		   targetid = this_vtx,
	           senderid = NULL_OBJID, targetos = constos);
	     if(!(1&*EMmsg&sts)) goto wrapup;
	    }
	   else	/* If this is the first subgroup in the group */
	    {
	     this_grp_beginvtxuse = this_subgrp_endvtxuse[0];
	     this_grp_beginsfid = this_subgrp_endsfid[0];
	     this_grp_beginedpar = this_subgrp_endedpar[0];
	     this_grp_beginvtx = this_subgrp_endvtx[0];
	     this_grp_edgeedpar = this_subgrp_edgeedpar[0];
	    }
	
	   /* Connect the end vertex use of the last subgroup with the begin
	      vertex use of the first subgroup, if this group is closed.
	      If the group is open, create individual model space vertex
    	      objects for each use.
	   */
	   if( (j == (tr->num_subgrps_grp[i] - 1)) &&
	       !(IF_NULL_OBJID(this_subgrp_endvtxuse[1]) &&
	         IF_NULL_OBJID(this_grp_beginvtxuse)))
	    {
	     struct GRid	vtxuses[2], sfid;
	     IGRpoint		xyzpt;
	     IGRint		num = 0, q;
       	     struct EMSsfintedpar *edpar = NULL, edgeedpar, outedpar;
	     IGRboolean		closed, gotit = FALSE;
	     GRobjid		convtx[2];
	     IGRdouble		*ptptr = NULL;
	     struct EMSpartolbasis struct_partol;
	
	     vtxuses[0].osnum = vtxuses[1].osnum = constos;
	     closed = tr->grp_closed[i];
	     for(q=0; q<2; q++)
	      {
	       num = 0;
	       ptptr = NULL;
	
	       if(!IF_NULL_OBJID(this_grp_beginvtxuse))
	        {
		 if(!closed && gotit)
	          gotit = FALSE;
		 else
		  {
		   convtx[num] = this_grp_beginvtx;
	           vtxuses[num++].objid = this_grp_beginvtxuse;
	           sfid = this_grp_beginsfid.sfid;
	           struct_partol = this_grp_beginsfid.ptol;	
	           edpar = this_grp_beginedpar;
	
                   outedpar.edgeid = NULL_OBJID;
                   sts = NMincedence(EMmsg, edpar, &sfid, &struct_partol, 
			             &outedpar);
                   if(!(1&*EMmsg&sts)) goto wrapup;
                   if( (*EMmsg != EMS_I_NotFound) && 
		       (!IF_NULL_OBJID(outedpar.edgeid)))
	  	    *edpar = outedpar;

		   edgeedpar = this_grp_edgeedpar;
                   outedpar.edgeid = NULL_OBJID;
                   sts = NMincedence(EMmsg, &edgeedpar, &sfid, &struct_partol, 
			             &outedpar);
                   if(!(1&*EMmsg&sts)) goto wrapup;
                   if( (*EMmsg != EMS_I_NotFound) && 
		       (!IF_NULL_OBJID(outedpar.edgeid)))
	  	    edgeedpar = outedpar;
	
	           gotit = TRUE;
		  }
	        }

  	       if(!IF_NULL_OBJID(this_subgrp_endvtxuse[1]) &&
		  (closed || (!closed && !gotit)))
	        {
		 convtx[num] = this_subgrp_endvtx[1];
	         vtxuses[num++].objid = this_subgrp_endvtxuse[1];
	         sfid = this_subgrp_endsfid[1].sfid;
	         struct_partol = this_subgrp_endsfid[1].ptol;	
	         edpar = this_subgrp_endedpar[1];

                 outedpar.edgeid = NULL_OBJID;
                 sts = NMincedence(EMmsg, edpar, &sfid, &struct_partol, 
		             &outedpar);
                 if(!(1&*EMmsg&sts)) goto wrapup;
                 if( (*EMmsg != EMS_I_NotFound) && 
  	             (!IF_NULL_OBJID(outedpar.edgeid)))
     	          *edpar = outedpar;
	
	         edgeedpar = this_subgrp_edgeedpar[1];
                 outedpar.edgeid = NULL_OBJID;
                 sts = NMincedence(EMmsg, &edgeedpar, &sfid, &struct_partol, 
		             &outedpar);
                 if(!(1&*EMmsg&sts)) goto wrapup;
                 if( (*EMmsg != EMS_I_NotFound) && 
  	             (!IF_NULL_OBJID(outedpar.edgeid)))
     	          edgeedpar = outedpar;

	         gotit = TRUE;
	        }
	
	       if(num && IF_NULL_OBJID(convtx[0]))
	        {
	         sts = NMget_xyz_point(edpar, construct, sfid.objid, xyzpt);
	         if(!(1&sts)) goto wrapup;
		 sts = NMget_matching_vtx(EMmsg, edgeedpar.edgeid, sfid.osnum,
		       xyzpt, xyzlentol, &edgeedpar.intloc, &this_vtx, NULL);
		 if(!(1&*EMmsg&sts)) goto wrapup;
		 if(IF_NULL_OBJID(this_vtx))
		  {
		   sts = NMget_matching_vtx(EMmsg, edpar->edgeid, sfid.osnum, 
			 xyzpt, xyzlentol, &edpar->intloc, &this_vtx, NULL);
		   if(!(1&*EMmsg&sts)) goto wrapup;
		  }
		
		 if(IF_NULL_OBJID(this_vtx))
		  {
	           ptptr = xyzpt;
		   sts = NMconstruct_vertex(EMmsg, construct, xyzpt, &this_vtx);
		   sts = om$send(msg = message NMvertex.NMinit
		         (EMmsg, NMinit_AddToSSI, NMvtx_Active, 0, NULL, NULL,
			  ssi), senderid = NULL_OBJID, targetid = this_vtx, 
			 targetos = constos);
		   if(!(1&*EMmsg&sts)) goto wrapup;
		  }
	        }
	       else this_vtx = convtx[0];

	       if(num)
	        {
	         sts = om$send(msg = message NMvertex.NMconnect_vertex_uses
		       (EMmsg, num, vtxuses, ptptr, ssi, NMconnect_AddToSSI), 
		       targetid = this_vtx, senderid = NULL_OBJID, 
		       targetos = constos);
	         if(!(1&*EMmsg&sts)) goto wrapup;
		}
	       if(closed) break;
	
	      } /* for(q=0; q<2; q++) */
	
	    } /* end of last subgroup/begin of first subgrp processing */
	
          } /* if last edge in the subgroup */

        } /* if first or last edge of an open subgroup */

       this_intobj = this_intobj->next;

      } /* for(l=0; l<tr->num_elems_subgrp[i][j]; l++) */

     if(!onlyvtx)
      {
       struct EMSpartolbasis	junk;

       /* Create vertex use objects at the intersection of this loop with other
          feature loops on the surface.
       */
       sts = NMintersection_vertex(EMmsg, &this_sf, ssi, 
             this_lp, construct, &thispartol);
       if(!(1&*EMmsg&sts)) goto wrapup;

       /* Create vertex for a point loop if so requested in the options.
       */
       if( (options & NMcreatetp_CreateDegenerateVtx) &&
           (EFisAncestryValid(EMmsg, this_lp, constos, OPP_NMptflp_class_id, 
	    FALSE)))
	{
	 sts = NMdegenerate_vertex(EMmsg, &this_sf, ssi, this_lp, construct, 
	       &thispartol);
         if(!(1&*EMmsg&sts)) goto wrapup;	
	}
	
       junk.tol = thispartol;
       junk.is_valid = TRUE;
       sts = om$send(msg = message NMfeaturelp.NMflpinit(EMmsg, &junk,
	     construct->env_info, 
             lpprops, EMGL_HOLD_UPDATE, this_sf.objid, NULL_OBJID, 
	     NMinit_AddToSSI, ssi), 
             targetid = this_lp, targetos = constos, 
	     senderid = NULL_OBJID);
       if(!(1&sts)) goto wrapup;
      } /* if(!onlyvtx) */

     OM_BLOCK_MOVE(this_subgrp_endvtxuse, prev_subgrp_endvtxuse, 
                   2*sizeof(GRobjid));
     OM_BLOCK_MOVE(this_subgrp_endsfid, prev_subgrp_endsfid, 
                   2*sizeof(struct NMsfinfo));
     OM_BLOCK_MOVE(this_subgrp_endvtx, prev_subgrp_endvtx, 
                   2*sizeof(GRobjid));
     OM_BLOCK_MOVE(this_subgrp_endedpar, prev_subgrp_endedpar, 
                   2*sizeof(struct EMSsfintedpar *));
     OM_BLOCK_MOVE(this_subgrp_edgeedpar, prev_subgrp_edgeedpar, 
                   2*sizeof(struct EMSsfintedpar));

    } /* for(j=0; j<tr->num_subgrps_grp[i]; j++) */

  }/* for(i=0; i<tr->num_grps; i++) */

wrapup:
EMWRAPUP(*EMmsg, sts, "NMcreate_topology");
return(sts);
}


end implementation NMnonmani;
