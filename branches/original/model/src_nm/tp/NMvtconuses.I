class implementation NMvertex;

/*
  HISTORY

        Sudha   06/28/93        Modified for BSprototype ansification
*/

#include "OMmacros.h"
#include "godef.h"
#include "bsparameters.h"
#include "bserr.h"
#include "emsmacros.h"

#define VtxUseBuffInc	10
#define NmEdInc		10

#define StaticBuf	10

from NMvertex_use import NMget_incedence_info, NMconnect_edges, NMinit, 
			 NMreplace_edge, NMgetsurface_info;
from EMSboundary import EMgetsurface_info;
from EMSedge import EMptproject, EMendpts;
from NMedge import NMconnect_edges, NMinit;
from EMSsubbs import EMpartolbasis;

extern OMuword OPP_NMlistvtxuse_class_id, OPP_NMlistedge_class_id, 
	       OPP_NMvertex_use_class_id, OPP_NMedge_class_id, 
	       OPP_NMfeaturelp_class_id, OPP_NMpartedge_class_id;

extern IGRboolean NMedgevtxuse_assoc;

%safe
static void	NMfind_sf();
%endsafe

method NMconnect_vertex_uses(IGRlong *EMmsg; IGRint num; struct GRid *vtxuses;
			     IGRpoint xyzpoint; struct NMgmSSI *ssi;
			     unsigned int connect_opt)
{
 IGRlong		sts = OM_S_SUCCESS, rc;
 OM_S_CHANSELECT	to_vtx_uses, to_vtx;
 IGRint			i, j, m, n, numedges = 0, nummates = 0, 
			nummating_vtxuse = 0, num_other_vtxuse = 0, 
			nummates_split = 0;
 OMuint			count;
 GRobjid		*edges = NULL, *mating_vtxuse = NULL, 
			*other_vtxuse = NULL;
 struct GRid		*mates = NULL, *mate_sf = NULL, mate_sfbuf[StaticBuf], 
			tmpprted[2];
 IGRboolean		*reverse = NULL, 
			location_modified = FALSE, ref_rev = FALSE;
 IGRdouble		xyztol, mate_uv[2], this_vtxuse_uvpt[2], locxyz[3];
 struct			EMSpartolbasis *partol = NULL, partolbuf[StaticBuf];
 IGRshort		mattyp;
 IGRmatrix		mat;
 struct EMSproj_info	*projinfo = NULL, projinfobuf[StaticBuf];
 struct EMSsfintedpar   splitinfo;
 struct GRid		*locvtxuses = NULL, this_vtxuse, 
			locvtxusesbuf[StaticBuf];
 IGRint			locnum_vtxuses = 0, locvtxuses_bufsize = 0;
 IGRboolean		found = FALSE;
 enum EMScvinttype	*loc_on_edge = NULL;
 struct GRid		*prted[2], prtedbuf[2][StaticBuf];
 IGRint			mateinfo_bufsize;

 struct GRmd_env	env;
 unsigned int	nmquery_opt = NULL; 

 *EMmsg = EMS_S_Success;
 for(i=0; i<2; i++)
  prted[i] = prtedbuf[i];
 mate_sf = mate_sfbuf;
 projinfo = projinfobuf;
 partol = partolbuf;
 mateinfo_bufsize = StaticBuf;

 if(connect_opt & NMconnect_ExternalToModel)
  nmquery_opt = NMquery_ConsiderExternalToModel;

 EMidmatrix(EMmsg, &env.md_env.matrix_type, env.md_env.matrix);
 env.md_id.osnum = OM_Gw_current_OS;
 env.md_id.objid = NULL_OBJID;

 NMmake_chanselect(NMvertex_to_vtx_uses, &to_vtx_uses);
 NMmake_chanselect(NMvertex_use_to_vtx, &to_vtx);
 BSEXTRACTPAR(&rc, BSTOLLENVEC, xyztol);
 EMidmatrix(EMmsg, &mattyp, mat);

 sts = om$get_channel_count(object = me, p_chanselect = &to_vtx_uses, 
       count = &count);
 if(!(1&sts)) goto wrapup;

 /* If no xyzpoint is supplied and there are already some vtx uses connected, 
    assume my instance data to be ok and take the point from there.
 */
 if(!xyzpoint && count)
  {
   OM_BLOCK_MOVE(ME.GR3dpoint->point, locxyz, 3 * sizeof(IGRdouble));
   xyzpoint = locxyz;
  }

 if( (num + VtxUseBuffInc) > StaticBuf)
  {
   locvtxuses = (struct GRid *) om$malloc(size = (num + VtxUseBuffInc) *
		sizeof(struct GRid));
   locvtxuses_bufsize = num + VtxUseBuffInc;
   EMerr_hndlr(!locvtxuses, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
  }
 else
  {
   locvtxuses = (struct GRid *) locvtxusesbuf;
   locvtxuses_bufsize = StaticBuf;
  }
 OM_BLOCK_MOVE(vtxuses, locvtxuses, num * sizeof(struct GRid));

 locnum_vtxuses = num;

 if(connect_opt & NMconnect_NoChecks) goto connect_them;

 for(i=0; i<locnum_vtxuses; i++)
  {
   /* Get all the edges this vertex use is connected to.
   */
   if(edges) om$dealloc(ptr = edges);
   if(loc_on_edge) om$dealloc(ptr = loc_on_edge);
   edges = NULL;
   loc_on_edge = NULL;
   numedges = 0;
   sts = om$send(msg = message NMvertex_use.NMget_incedence_info(EMmsg, 
	 NULL_OBJID, &numedges, &edges, &loc_on_edge, NULL, this_vtxuse_uvpt, 
	 NULL, NULL), 
	 targetid = locvtxuses[i].objid, targetos = locvtxuses[i].osnum);
   if(!(1&*EMmsg&sts)) goto wrapup;

   for(j=0; j<numedges; j++)
    {
     struct GRid refedge;
     IGRboolean ref_in_middle = TRUE;

     /* If the vertex use is not in the middle of the edge, no splitting
	is required. It is assumed here that same holds true for the 
	corresponding vertex uses of all the mates of this edge. A validation
	pass is made later to ensure this.
     */
     if(loc_on_edge[j] != EMScvint_middle)
       ref_in_middle = FALSE;

     refedge.objid = edges[j];
     refedge.osnum = locvtxuses[i].osnum;

     if(mates) om$dealloc(ptr = mates);
     mates = NULL;
     if(reverse) om$dealloc(ptr = reverse);
     reverse = NULL;
     ref_rev = FALSE;

     nummates = 0;

     /* Get all the mating edges of this edge. This edge is also included
        in the list returned.
     */
     sts = NMget_edge_mates(EMmsg, &refedge, &nummates, &mates, &reverse, NULL,
	   NULL, NULL, NULL, NULL, NULL);
     if(!(1&*EMmsg&sts)) goto wrapup;

     /* Allocate space for partedges to be generated. 2 partedge will be
	generated per edge that is split.
     */
     if(nummates > mateinfo_bufsize)
      {
       for(m=0; m<2; m++)
        {
	 if(prted[m] == prtedbuf[m])
          prted[m] = (struct GRid *) om$malloc(size = nummates *
		      sizeof(struct GRid));
	 else
          prted[m] = (struct GRid *) om$realloc(ptr = (IGRchar *)prted[m], 
		      size = nummates * sizeof(struct GRid));
         EMerr_hndlr(!prted[m], *EMmsg, EMS_E_NoDynamicMemory, wrapup);
        }

       if(mate_sf == mate_sfbuf)
        mate_sf = (struct GRid *) om$malloc(size = nummates * 
		    sizeof(struct GRid));
		
       else
        mate_sf = (struct GRid *) om$realloc(ptr = (IGRchar *)mate_sf, size = nummates * 
		    sizeof(struct GRid));
		
       if(projinfo == projinfobuf)
        projinfo = (struct EMSproj_info *) om$malloc(size = nummates * 
		sizeof(struct EMSproj_info));
       else
        projinfo = (struct EMSproj_info *) om$realloc(ptr = (IGRchar *)projinfo, 
		size = nummates * sizeof(struct EMSproj_info));

       if(partol == partolbuf)
        partol = (struct EMSpartolbasis *) om$malloc(size = nummates * 
		sizeof(struct EMSpartolbasis));
       else
        partol = (struct EMSpartolbasis *) om$realloc(ptr = (IGRchar *)partol, 
		size = nummates * sizeof(struct EMSpartolbasis));
		
       EMerr_hndlr(!mate_sf || !projinfo || !partol, *EMmsg, 
		  EMS_E_NoDynamicMemory, wrapup);	
       mateinfo_bufsize = nummates;
      }

     for(m=0; m<nummates; m++)
      {
       partol[m].mattyp = &mattyp;
       partol[m].mat = mat;
       partol[m].is_valid = FALSE;
       if(IF_EQ_GRID(refedge, mates[m])) ref_rev = reverse[m];
      }

     /* For each mating edge, if there is no corresponding vertex use in
	its parametric space, create one. Split the mating edge if the
	vertex use is in the middle, whether it was created here or not.
	The location determined on all the mating edges must be consistent
	for topology to be valid after the splits. The locations should be
	in the middle for ALL edges or at either ends for ALL edges. 
	A validation pre pass is made to ensure this. In case of conflicting
	locations, the middle location is moved to corresponding end location
	thus giving end location a priority. This can be safely done since
	we already know that the points in each parametric space correspond
	to the same model space point (vertex).
     */
     location_modified = FALSE;
     for(m=0; m<nummates; m++)
      {
       mate_sf[m].osnum = mates[m].osnum;
       sts = om$send(msg = message EMSboundary.EMgetsurface_info
             (EMmsg, &mate_sf[m].objid, &partol[m]), targetid = mates[m].objid,
	     targetos = mates[m].osnum);
       if(!(1&*EMmsg&sts)) goto wrapup;
       if((IF_NULL_OBJID(mate_sf[m].objid)) && (IF_EQ_GRID(refedge, mates[m])))
        {
	 IGRboolean junk = TRUE;
	
         NMfind_sf(&locvtxuses[i], &mate_sf[m], ssi->num_sfs, ssi->nmentities);
         if(!IF_NULL_OBJID(mate_sf[m].objid))
	  {          
	   sts = om$send(msg = message EMSsubbs.EMpartolbasis(EMmsg, 
		 partol[m].mattyp, partol[m].mat, &junk, TRUE, &partol[m].tol),
		 targetid = mate_sf[m].objid, targetos = mate_sf[m].osnum);
	   if(!(1&*EMmsg&sts)) goto wrapup;
	   partol[m].is_valid = TRUE;
	  }

	}
	
       if(IF_NULL_OBJID(mate_sf[m].objid))
        {
         sts = NMfind_sf_no_matter_what(EMmsg, &mates[m], &mate_sf[m], 
	       &partol[m], NULL);
	 if(!(1&*EMmsg&sts)) goto wrapup;
	}
	
       /* All attempts to get to the surface of the mate (needed to get to
	  xyz) have failed. Skip this dude and proceed to the next mate.
          Should I error out here?
       */
       if(IF_NULL_OBJID(mate_sf[m].objid))
	{
         goto next_mate;
        }

       if(IF_EQ_GRID(refedge, mates[m]))
        {
	 if(ref_in_middle)
	  {
           sts = om$send(msg = message EMSedge.EMptproject(EMmsg, 
		 this_vtxuse_uvpt, 1, &projinfo[m], NULL, &partol[m]), 
		 targetid = mates[m].objid, targetos = mates[m].osnum);
           if(!(1&*EMmsg&sts)) goto wrapup;
          }
         else
	  OM_BLOCK_MOVE(this_vtxuse_uvpt, projinfo[m].proj_pt, 
		        2 * sizeof(IGRdouble));
         projinfo[m].location = loc_on_edge[j];
	}
       else
        {
	 if(!ref_in_middle)
	  {
	   IGRdouble uv[2];
	   IGRboolean reverse_connect = FALSE, mate_begin = FALSE;
	
	   if( (ref_rev && !reverse[m]) || (!ref_rev && reverse[m]))
	    reverse_connect = TRUE;
	
	   if( (loc_on_edge[j] == EMScvint_lfend) && !reverse_connect)
	    mate_begin = TRUE;
	   else if( (loc_on_edge[j] == EMScvint_rtend) && reverse_connect)
	    mate_begin = TRUE;
   
	   sts = om$send(msg = message EMSedge.EMendpts(EMmsg, 
	         mate_begin ? uv : NULL, mate_begin ? NULL : uv, 
		 NULL, NULL, NULL),
	         targetid = mates[m].objid, targetos = mates[m].osnum);
	   if(!(1&*EMmsg&sts)) goto wrapup;
	
	   projinfo[m].dist = 0.0;
           OM_BLOCK_MOVE(uv, projinfo[m].proj_pt, 2 * sizeof(IGRdouble));
           projinfo[m].location = mate_begin ? EMScvint_lfend : EMScvint_rtend;

	  } /* if(!ref_in_middle) */
         else
          {
   	   IGRint numpar = 0;
           sts = om$send(msg = message GRvg.EMpratpt(EMmsg, &mattyp, mat, 
	         xyzpoint, mate_uv, &numpar), targetid = mate_sf[m].objid, 
	         targetos = mates[m].osnum);
           if(!(1&*EMmsg&sts)) goto wrapup;

           sts = om$send(msg = message EMSedge.EMptproject(EMmsg, mate_uv, 1, 
	         &projinfo[m], NULL, &partol[m]), targetid = mates[m].objid, 
	         targetos = mates[m].osnum);
           if(!(1&*EMmsg&sts)) goto wrapup;
	   projinfo[m].location = EMScvint_middle;
          }

        } /* else for if(IF_EQ_GRID(refedge, mates[m])) */

      }/* for(m=0; m<nummates; m++) */

     nummates_split = 0;
     for(m=0; m<nummates; m++)
      {
       OM_BLOCK_MOVE(projinfo[m].proj_pt, mate_uv, 2 * sizeof(IGRdouble));

       if(mating_vtxuse) om$dealloc(ptr = mating_vtxuse);
       mating_vtxuse = NULL;
       nummating_vtxuse = 0;

       if(IF_EQ_GRID(refedge, mates[m]))
        this_vtxuse = locvtxuses[i];
       else
	{
         sts = NMget_vertex_use(EMmsg, &mates[m], &nummating_vtxuse, 
	       &mating_vtxuse, NULL, NULL, NULL, NULL, NULL, NULL, mate_uv, 
	       NULL, &projinfo[m].location, &partol[m].tol, &xyztol, 
	       nmquery_opt, NULL, NULL);
         if(!(1&*EMmsg&sts)) goto wrapup;

         /* Since a check point is provided, we should get back exactly 1 vtx
	  use.
         */
	 if(nummating_vtxuse > 1)
	  {
	   *EMmsg = EMS_E_InvalidCase;
	   goto wrapup;
	  }
         /* If no mating vertex use is found, create one and connect the mating
	    edge to it.Add it to the list of vertex uses to be connected to me.
	    When creating the vertex use, the information also needs to be
	    stored into the list of created entities for save state purpose.
	
	    If a mating vertex use was found, it should either be already 
	    connected to me or should be in the list of vertex uses being
	    processed. If the mating vertex use is already connected to 
	    another vertex from a previous operation, then move it to myself
	    and record the change made.
         */

         if(!nummating_vtxuse)
          {
	   unsigned char vtuprops = NMvtxuse_Active;
	   unsigned int nminit_opt = NULL;
	
	
	   if(connect_opt & NMconnect_ExternalToModel)
	    vtuprops |= NMvtxuse_ExternalToModel;
	   if(connect_opt & NMconnect_AddToSSI)
	    nminit_opt |= NMinit_AddToSSI;
	
           sts = om$construct(osnum = mates[m].osnum, 
		 p_objid = &this_vtxuse.objid, 
		 classid = NMedgevtxuse_assoc ? OPP_NMvertex_use_class_id : 
			   OPP_NMlistvtxuse_class_id, 
	         msg = message NMvertex_use.NMinit
	         (EMmsg, nminit_opt, vtuprops, 0, NULL, NULL, NULL,
		  ssi, &mate_sf[m]));
	   if(!(1&*EMmsg&sts)) goto wrapup;
	   this_vtxuse.osnum = mates[m].osnum;
  	   sts = om$send(msg = message NMvertex_use.NMconnect_edges(EMmsg, 1, 
	         &mates[m].objid, &projinfo[m].location, mate_uv, 
		 connect_opt, ssi), 
	         targetid = this_vtxuse.objid, targetos = this_vtxuse.osnum);
	   if(!(1&*EMmsg&sts)) goto wrapup;

	   if((locnum_vtxuses + 1) > locvtxuses_bufsize)
	    {
	     if(locvtxuses == locvtxusesbuf)
	      {
               locvtxuses = (struct GRid *) om$malloc(
			    size = (locnum_vtxuses + VtxUseBuffInc) *
			    sizeof(struct GRid));
	       EMerr_hndlr(!locvtxuses, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
	       OM_BLOCK_MOVE(locvtxusesbuf, locvtxuses, locnum_vtxuses *
				sizeof(struct GRid));
	      }
	     else
              locvtxuses = (struct GRid *) om$realloc(ptr = (IGRchar *)locvtxuses, 
			 size = (locnum_vtxuses + VtxUseBuffInc) *
			        sizeof(struct GRid));
             locvtxuses_bufsize = locnum_vtxuses + VtxUseBuffInc;     
	     EMerr_hndlr(!locvtxuses, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
	    }
	   locvtxuses[locnum_vtxuses++] = this_vtxuse;
	
          } /* if(!nummating_vtxuse) */
         else
          {
	   this_vtxuse.objid = mating_vtxuse[0];
	   this_vtxuse.osnum = mates[m].osnum;

           found = FALSE;
           for(n=0; n<locnum_vtxuses; n++) 
            if(IF_EQ_GRID(this_vtxuse, locvtxuses[n]))
	     {
	      found = TRUE;
	      break;
	     }
	   if(!found)
	    {
             sts = om$is_objid_on_channel(object_c = me, 
		   p_chanselect = &to_vtx_uses, objid = this_vtxuse.objid, 
		   osnum2 = this_vtxuse.osnum);
             if(sts == OM_S_SUCCESS) found = TRUE;
             else sts = OM_S_SUCCESS;
	    }
	
	   if(!found)
	    {
	     struct GRid other_vtx;
	     GRobjid my_creator = NULL_OBJID, other_creator = NULL_OBJID;
	
	     /* Is the vertex use already connected to another vertex?
	        Is the creator of that vertex different than mine?
	        If so, move the vertex use to myself.
	     */
	     other_vtx.objid = NULL_OBJID;
	
	     sts = om$send(msg = message NMvertex_use.NMget_incedence_info
		   (EMmsg, NULL_OBJID, NULL, NULL, NULL, &other_vtx, NULL, 
		    NULL, nmquery_opt), targetid = this_vtxuse.objid, 
		    targetos = this_vtxuse.osnum);
	     if(!(1&*EMmsg&sts)) goto wrapup;
             if(IF_NULL_OBJID(other_vtx.objid)) goto invalid_case;

             sts = om$send(msg = message NMcreated.NMget_put_creator_id
		   (EMmsg, &my_creator, FALSE), targetid = my_id);
	     if(!(1&*EMmsg&sts)) goto wrapup;
             sts = om$send(msg = message NMcreated.NMget_put_creator_id
		   (EMmsg, &other_creator, FALSE), targetid = other_vtx.objid, 
		   targetos = other_vtx.osnum);
	     if(!(1&*EMmsg&sts)) goto wrapup;
             if(IF_EQ_OBJID(my_creator, other_creator))	goto invalid_case;

             /* Get all the vertex uses of the other vertex and add them
		to my list of vertex uses.
	     */
	     if(other_vtxuse) om$dealloc(ptr = other_vtxuse);
	     other_vtxuse = NULL;
	     num_other_vtxuse = 0;
	     sts = om$send(msg = message NMvertex.NMget_info(EMmsg, 
		   &num_other_vtxuse, &other_vtxuse, NULL, NULL), 
		   targetid = other_vtx.objid, targetos = other_vtx.osnum);
	     if(!(1&*EMmsg&sts)) goto wrapup;
	
	     if((locnum_vtxuses + num_other_vtxuse) > locvtxuses_bufsize)
 	      {
	       if(locvtxuses == locvtxusesbuf)
	        {
                 locvtxuses = (struct GRid *) om$malloc(
		 size = (locnum_vtxuses + VtxUseBuffInc + num_other_vtxuse) *
			    sizeof(struct GRid));
	         EMerr_hndlr(!locvtxuses, *EMmsg,EMS_E_NoDynamicMemory,wrapup);
	         OM_BLOCK_MOVE(locvtxusesbuf, locvtxuses, locnum_vtxuses *
				sizeof(struct GRid));
	        }
	       else
                locvtxuses = (struct GRid *) om$realloc(ptr = (IGRchar *)locvtxuses, 
		 size = (locnum_vtxuses + VtxUseBuffInc + num_other_vtxuse) *
			        sizeof(struct GRid));
               locvtxuses_bufsize = locnum_vtxuses + VtxUseBuffInc + 
				  num_other_vtxuse;     
	       EMerr_hndlr(!locvtxuses, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
	      }
             
             /* Disconnect all the vertex uses from the other vertex
		and record that fact.
	     */
	     sts = om$send(msg = message Root.wild_disconnect(to_vtx_uses), 
		   targetid = other_vtx.objid, targetos = other_vtx.osnum);
	     if(!(1&sts)) goto wrapup;
	
	     if( (connect_opt & NMconnect_AddToSSI) && ssi)
	      {
               struct GRid sfid;

               sfid.osnum = other_vtx.osnum;
               for(n=0; n<num_other_vtxuse; n++)
                {
	         sts = om$send(msg = message NMvertex_use.NMgetsurface_info
		       (EMmsg, &sfid.objid, NULL), targetid = other_vtxuse[n]);
	         if(!(1&*EMmsg&sts)) goto wrapup;
		 sts = NMstore_vtxuse_transfer(EMmsg, ssi, &sfid, 
		       other_vtxuse[n], other_vtx.objid, my_id);
                }
	      }
             
	     /* Add the new vertex uses to my list and continue on.
	     */
	     for(n=0; n<num_other_vtxuse; n++)
	      {
	       locvtxuses[locnum_vtxuses].objid = other_vtxuse[n];
	       locvtxuses[locnum_vtxuses++].osnum = OM_Gw_current_OS;
	      }
	     found = TRUE;
	
            } /* if(!found) */

invalid_case:
           if(!found)
	    {
	     *EMmsg = EMS_E_InvalidCase;
	     goto wrapup;
	    }
	
          }/* else for if(!nummating_vtxuse) */

        } /* if(!IF_EQ_GRID(refedge, mates[m])) */

       /* If the location on the reference edge is not in the middle, there
	  is no splitting to be done. We can move on to the next mate.
       */
       if(!ref_in_middle) goto next_mate;

       splitinfo.intloc = projinfo[m].location;
       splitinfo.edgeid = mates[m].objid;
       splitinfo.edgepar = projinfo[m].param;
       OM_BLOCK_MOVE(projinfo[m].proj_pt, splitinfo.point, 
			2 * sizeof(IGRdouble));
       splitinfo.info = NULL;
       splitinfo.next = NULL;

       sts = NMsplit_edge(EMmsg, &mates[m], &splitinfo, this_vtxuse.objid, 
	     &partol[m], tmpprted, &mate_sf[m], ssi);
       if(!(1&*EMmsg&sts)) goto wrapup;

       prted[0][nummates_split] = reverse[m] ? tmpprted[1] : tmpprted[0];
       prted[1][nummates_split++] = reverse[m] ? tmpprted[0] : tmpprted[1];


next_mate:
       continue;

      }/* for(m=0; m<nummates; m++) */

     /* Create a NMedge for all the partedges created. If the location on the
	reference edge is not in the middle, there are no partedges
	created. We can move on to the next edge connected to the reference
	vertex use.
     */
     if(!ref_in_middle) goto next_edge;
     if(!nummates_split) goto next_edge;

     for(n=0; n<2; n++)
      {
       GRobjid this_nmedge;
       unsigned char edprops = NMedge_Active;
       unsigned int nminit_opt = NULL;

       /* Need to optimise here by passing in the known edge reverse connect
	  info (change argument list of NMedge.NMconnect_edges).
       */
       if(connect_opt & NMconnect_ExternalToModel)      
        edprops |= NMedge_ExternalToModel;
       if(connect_opt & NMconnect_AddToSSI)
        nminit_opt |= NMinit_AddToSSI;

       sts = om$construct(classid = NMedgevtxuse_assoc ? OPP_NMedge_class_id
				    : OPP_NMlistedge_class_id, 
             p_objid = &this_nmedge, msg = message NMedge.NMinit
             (EMmsg, nminit_opt, edprops,  0, NULL, NULL, NULL, NULL,
	      ssi));
       if(!(1&sts)) goto wrapup;

       sts = om$send(msg = message NMedge.NMconnect_edges
             (EMmsg, nummates, prted[n], mate_sf, reverse, &env, ssi, 
	      connect_opt), 
	     targetid = this_nmedge, senderid = NULL_OBJID);
       if(!(1&sts)) goto wrapup;
      }

next_edge:
     continue;

    } /* for(j=0; j<numedges; j++) */

  }/* for(i=0; i<num; i++) */

connect_them:

 for(i=0; i<locnum_vtxuses; i++) 
  {
   sts = om$is_objid_on_channel(object_c = me, p_chanselect = &to_vtx_uses, 
         objid = locvtxuses[i].objid, osnum2 = locvtxuses[i].osnum);
   if(sts == OM_S_SUCCESS) continue;
   else sts = OM_S_SUCCESS;

   sts = om$send(msg = message Root.connect(to_vtx, count++, 
         my_id, OM_Gw_current_OS, to_vtx_uses, 0), 
         targetid = locvtxuses[i].objid, targetos = locvtxuses[i].osnum);
   if(!(1&*EMmsg&sts)) goto wrapup;
  }

 if(xyzpoint) OM_BLOCK_MOVE(xyzpoint, ME.GR3dpoint->point, sizeof(IGRpoint));

wrapup:
if(other_vtxuse) om$dealloc(ptr = other_vtxuse);
if(edges) om$dealloc(ptr = edges);
if(mates) om$dealloc(ptr = mates);
if(mate_sf && (mate_sf != mate_sfbuf)) om$dealloc(ptr = mate_sf);
if(reverse) om$dealloc(ptr = reverse);
if(projinfo && (projinfo != projinfobuf)) om$dealloc(ptr = projinfo);
if(partol && (partol != partolbuf)) om$dealloc(ptr = partol);
if(mating_vtxuse) om$dealloc(ptr = mating_vtxuse);
if(locvtxuses && (locvtxuses != locvtxusesbuf)) om$dealloc(ptr = locvtxuses);
if(loc_on_edge) om$dealloc(ptr = loc_on_edge);
for(i=0; i<2; i++) 
 if(prted[i] && (prted[i] != prtedbuf[i])) om$dealloc(ptr = prted[i]);

EMWRAPUP(*EMmsg, sts, "NMvertex.NMconnect_vertex_uses");
return(sts);
}


static void NMfind_sf(vtxuse, sf, num_sfs, nm)
struct GRid *vtxuse, *sf;
IGRint num_sfs;
struct NMentities *nm;
{
 IGRint		i, j;
 IGRboolean	found = FALSE;
 struct NMentities *this_nm = NULL;

 for(i=0; i<num_sfs; i++)
  {
   this_nm = &nm[i];
   for(j=0; j<this_nm->num_vtxuses; j++)
    if(IF_EQ_OBJID(this_nm->vtxuses[j], vtxuse->objid))
     {
      *sf = this_nm->sfid;
      found = TRUE;
      break;
     }
    if(found) break;
  }

}

end implementation NMvertex;
