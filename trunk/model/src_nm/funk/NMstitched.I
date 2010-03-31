class implementation NMnonmanist;

#ifndef DEBUG
#define DEBUG 0
#endif

#include "EMS.h"

#include "EMSmsgdef.h"
#include "emsmacros.h"
#include "emserr.h"
#include "emsdef.h"
# include "EMSbnddef.h"
# include "emsdattyp.h"
# include "emsinter.h"
# include "EMSbnd.h"
#include "EMSprop.h"
#include "EMSopt.h"
#include "bstypes.h"
#include "bserr.h"
#include "bsparameters.h"
#include "OMmacros.h"
#include "grownerdef.h"
#include "EMSfrtdef.h"


#define StaticBuf	10
#define VtxInc 10

from EMSedge import EMget_props, EMget_top_part_edges,
		    EMstitch, EMset_props, EMendpts,  EMxyz_endpt;
from EMSloop import EMget_props, EMset_props;

from EMSboundary import EMget_objid, EMgetsurface_info;
from NMedge import NMconnect_edges, NMget_edge_info, NMinit;
from EMSloop import EMmodify_edge;
from NMvertex_use import NMconnect_edges, NMinit;
from NMvertex import NMconnect_vertex_uses, NMinit;

extern OMuword OPP_NMlistvtxuse_class_id, OPP_NMvertex_class_id, 
               OPP_NMlistedge_class_id, OPP_NMedge_class_id;

extern IGRboolean NMvertex_display_and_Rtree, NMedgevtxuse_assoc;





IGRint NMstitch_edge(EMmsg, thispair, my_GRid, ssi, to_comm, 
		       mod_info, compid1, compid2, newly_connected, 
		       was_connected, num_stitches,
		       part_edges, stitol, comps_to_connect, 
		       num_comps_to_connect, construct)
IGRlong			*EMmsg;
struct EMSstitch_info	*thispair;
struct GRid		*my_GRid;
struct NMgmSSI		*ssi;
OM_S_CHANSELECT		*to_comm;
struct GRmd_env		*mod_info;
GRobjid			compid1, compid2;
IGRboolean		*newly_connected, *was_connected;
IGRint			*num_stitches;
GRobjid			*part_edges;
IGRdouble		stitol;
GRobjid			*comps_to_connect;
IGRint			*num_comps_to_connect;
struct GRvg_construct	*construct;
{
 IGRlong		sts, rc;
 IGRint			i, j, m;
 struct GRid		refedge, *mates = NULL, junksfs[2], nm, nm1, nm2, 
		        *newmates = NULL, *newmates_sf = NULL, 
			newmates_sfbuf[StaticBuf];
 IGRint			num_mates, num_newmates =0;
 GRobjid		old_commed[2], old_loopid[2], thisedge;
 IGRushort	save_edprops[2], save_lpprops[2];
 OM_S_CHANSELECT	to_ed, to_lp;
 IGRint			num_commed_pairs = 0, numtmpprted[2], 
			tmpprtedbufsize = MaxNumPe, commidx[MaxNumPe], 
			edgeidx[MaxNumPe];
			
 GRobjid		tmpprted[2][MaxNumPe], *ped = NULL;
 OM_S_OBJECT_LINKAGE	*deletable_edges = NULL;
 struct NMentities	*this_nm = NULL;
 IGRdouble		xyzlentol;

 thispair->option |= (EMSstitch_NoMoveSurfs | EMSstitch_NoOrientSurfs);
 *EMmsg = EMS_S_Success;
 EMmake_chanselect(EMSbd_owner_to_comps, &to_ed);
 EMmake_chanselect(EMSedge_to_owner, &to_lp);
 BSEXTRACTPAR(&rc, BSTOLLENVEC, xyzlentol);

 /* If these two edges are mates, ignore them. If they were stitched during
    this processing, inlcude their surfaces in the list of surfaces to be
    connected.
 */
 refedge.objid = thispair->edge0;
 refedge.osnum = OM_Gw_current_OS;
 sts = NMget_edge_mates(EMmsg, &refedge, &num_mates, &mates, NULL, 
	 NULL, NULL, &nm, NULL, NULL, NULL);
 if(!(1&*EMmsg&sts)) goto wrapup;
 for(j=0; j<num_mates; j++)
  {
   if(IF_EQ_OBJID(mates[j].objid, thispair->edge1))
    {
     for(i=0; i<ssi->num_nmedges; i++)
      if(IF_EQ_OBJID(nm.objid, ssi->nmedges[i]))
       {
        *EMmsg = EMS_S_Success;
        part_edges[0] = thispair->edge0;
        part_edges[MaxNumPe] = thispair->edge1;
        goto add_comp;
       }
     *EMmsg = EMS_I_Fail;
     was_connected[0] = was_connected[1] = TRUE;
     goto wrapup;
    }
  }

 /* If the two edges have common edges, disconnect them temporarily, send
    the EMstitch message and restore the original channel connections after
    having done the non manifold processing.
 */
 for(i=0; i<2; i++)
  {
   old_commed[i] = NULL_OBJID;
   old_loopid[i] = NULL_OBJID;

   sts = EMsend_loops(&rc, message EMSboundary.EMget_objid(EMmsg, 
	 &old_loopid[i]), i ? thispair->edge1 : thispair->edge0, 0, MAXINT, 
	 EMLP_ACTIVE, NULL, NULL);
   if(!(1&*EMmsg&sts)) goto wrapup;
   EMerr_hndlr(IF_NULL_OBJID(old_loopid[i]), *EMmsg, EMS_E_Fail, wrapup);

   sts = om$send(msg = message EMSloop.EMget_props(EMmsg, &save_lpprops[i]), 
	   targetid = old_loopid[i], senderid = NULL_OBJID);
   EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_LoopError,wrapup);

   sts = om$send(msg = message EMSedge.EMget_props(EMmsg, &save_edprops[i]), 
	   targetid = i ? thispair->edge1 : thispair->edge0, 
	   senderid = NULL_OBJID);
   EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_EdgeError,wrapup);

   sts = om$send(msg = message EMSboundary.EMget_objid(EMmsg, &old_commed[i]), 
	 senderid = i ? thispair->edge1 : thispair->edge0, 
	 p_chanselect = to_comm);
   EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_EdgeError,wrapup);
   if(!IF_NULL_OBJID(old_commed[i]))
     sts = om$send(msg = message Root.wild_disconnect(*to_comm), 
	   targetid = i ? thispair->edge1 : thispair->edge0, 
	   senderid = NULL_OBJID);
   EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_EdgeError,wrapup);
  }

 sts = om$send(msg = message EMSedge.EMstitch(EMmsg, thispair, 
	       mod_info, my_GRid, NULL, stitol, NULL, NULL),
               targetid = thispair->edge0, senderid = NULL_OBJID);
 EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_EdgeError,wrapup);


 /********************************************

   In order to maintain multiple edge mates, we need to create a list of
   new mates that will result out of this stitch.

    Determine the common edge connections established during this stitch. 
    Store the edge id and the index in the top partedges list of the other side
    if there is a common edge.
    Disconnect all common edge connection established during this stitch.

   For each edge in the input pair-
    if(0 split)
     do nothing

    if(1 or 2 splits)
     Disconnect the partedges created from the edge in the pair.
     Create a vertex use and a vertex for each split point. Connection of the
     vertex use to the vertex will result in creation of vertex uses on all
     mates and their splitting. 

  For each common edge connection established during this stitch -
   Pick the appropriate edge on the other side. 
   Get existing NMedge from each edge of the pair, if one exists.
   If 2 NMedges (both have an existing NMedge)
    Disconnect all mates of one NMedge and connect them to the other NMedge.
    Store the connection/disconnection information for those edges which
    were not created here.
   If 1 NMedge, connect the new edge to it.
   If no NMedge, create a new NMedge and connect the pair to it.
**************************************************/

 if(*EMmsg != EMS_I_Fail)
  {
   /* Determine the number of common edge connections established in this
      stitch.
   */
   for(i=0; i<2; i++)
    {
     thisedge = i ? thispair->edge1 : thispair->edge0;

     ped = tmpprted[i];
     numtmpprted[i] = 0;
     for(j=0; j<MaxNumPe; j++) ped[j] = NULL_OBJID;

     /* The stitch just done will produce EMSpartedges if splitting was
	called for. So it is imprtant to send the following message wrt msg
	to invoke EMSedge implementation. The targetid could be a NMpartedge
	which overrides this message to look for NMpartedges only.
     */
     sts = om$send(mode = OM_e_wrt_message, msg = message 
	   EMSedge.EMget_top_part_edges
           (&rc, &ped, &numtmpprted[i], &tmpprtedbufsize),
           targetid = thisedge, senderid = NULL_OBJID);
     EMerr_hndlr (!(1&sts&rc),*EMmsg,EMS_E_EdgeError,wrapup);
     if(!numtmpprted[i])
      {
       numtmpprted[i] = 1;
       ped[0] = thisedge;
      }
     EMerr_hndlr(numtmpprted[i] > MaxNumPe, *EMmsg, EMS_E_Fail, wrapup);

     OM_BLOCK_MOVE(ped, &part_edges[i ? MaxNumPe : 0], numtmpprted[i] *
     sizeof(GRobjid));
    }
   
   ped = tmpprted[0];
   for(i=0; i<numtmpprted[0]; i++)
    {
     GRobjid commedgeid;

     commedgeid = NULL_OBJID;
     sts = om$send(msg = message EMSboundary.EMget_objid (&rc, &commedgeid), 
	   senderid = ped[i], p_chanselect = to_comm);
     EMerr_hndlr (!(1&sts&rc),*EMmsg,EMS_E_EdgeError,wrapup);
     if(!IF_NULL_OBJID(commedgeid))
      {
       edgeidx[num_commed_pairs] = i;
       for(j=0; j<numtmpprted[1]; j++)
        if(IF_EQ_OBJID(tmpprted[1][j], commedgeid))
         {
	  commidx[num_commed_pairs] = j;
	  break;
         }
       num_commed_pairs++;
       sts = om$send(msg = message Root.wild_disconnect(*to_comm), 
	     targetid = ped[i], senderid = ped[i]);
       EMerr_hndlr (!(1&sts),*EMmsg,EMS_E_EdgeError,wrapup);
      }
    }

  } /* if(*EMmsg != EMS_I_Fail) */

/*restore:*/

 /* Restore the edges in the input pair to their original state.
    Put them back into their active loops.
    Reconnect common edges if they existed
    Restore the edge props.
 */
 for(i=0; i<2; i++)
  {
   IGRlong rc;


   ped = tmpprted[i];
   thisedge = i ? thispair->edge1 : thispair->edge0;

   if( (*EMmsg != EMS_I_Fail) && (numtmpprted[i] > 1))
    {
     /* EMSedge.EMsplityourself has replaced the edge with the partedges in 
        all the loops. Undo that by replacing ped[0] with the original
        edge (to maintain the index) and disconnecting other partedges.
     */
     sts = om$send(msg = message EMSloop.EMmodify_edge(&rc, 
	   EMS_INS_REPLACE, 1, ped[0], &thisedge, FALSE), 
           targetid = old_loopid[i], senderid = NULL_OBJID);
     if(!(1&rc&sts)) goto wrapup;

     for(j=1; j<numtmpprted[i]; j++)
      {
       sts = om$send(msg = message Root.disconnect(to_ed, ped[j], 
             OM_Gw_current_OS, to_lp), targetid = old_loopid[i], 
	     senderid = ped[j]);
       if(!(1&*EMmsg&sts)) goto wrapup;
      }
    }

   if(!IF_NULL_OBJID(old_commed[i]))
    {
     sts = om$send(msg = message Root.connect(*to_comm, NULL, old_commed[i], 
	   OM_Gw_current_OS, *to_comm, NULL), senderid = old_commed[i], 
	   targetid = i ? thispair->edge1 : thispair->edge0);
     if(!(1&sts)) goto wrapup;
    }
   /* First clear the props and then deposit saved props.
   */
   sts = om$send(msg = message EMSedge.EMset_props(&rc, NULL, 
	 EMS_O_SET), targetid = i ? thispair->edge1 : thispair->edge0, 
         senderid = NULL_OBJID);
   EMerr_hndlr (!(1&sts&rc),*EMmsg,EMS_E_EdgeError,wrapup);

   sts = om$send(msg = message EMSedge.EMset_props(&rc, save_edprops[i], 
	 EMS_O_SET), targetid = i ? thispair->edge1 : thispair->edge0, 
         senderid = NULL_OBJID);
   EMerr_hndlr (!(1&sts&rc),*EMmsg,EMS_E_EdgeError,wrapup);

   sts = om$send(msg = message EMSloop.EMset_props(&rc, NULL, 
	 EMS_O_SET), targetid = old_loopid[i], 
         senderid = NULL_OBJID);
   EMerr_hndlr (!(1&sts&rc),*EMmsg,EMS_E_LoopError,wrapup);

   sts = om$send(msg = message EMSloop.EMset_props(&rc, save_lpprops[i], 
	 EMS_O_SET), targetid = old_loopid[i], 
         senderid = NULL_OBJID);
   EMerr_hndlr (!(1&sts&rc),*EMmsg,EMS_E_LoopError,wrapup);

  } /* for(i=0; i<2; i++) */

 if (*EMmsg == EMS_I_Fail) goto wrapup;	 /* stitch failed */


 for(i=0; i<2; i++)
  {
   struct GRid 			thissf, thisvtx, thisvtxuse;
   IGRint 			num_splits, m;
   IGRdouble 			split_uv[2][2], split_xyz[2][3];
   enum EMScvinttype 		split_loc[2];
   struct IGRbsp_surface	*thissf_geom = NULL;

   thisedge = i ? thispair->edge1 : thispair->edge0;
   thissf.objid = i ? thispair->surf1 : thispair->surf0;
   thissf.osnum = OM_Gw_current_OS;
   thissf_geom = i ? thispair->surf_geom1 : thispair->surf_geom0;

   /* Obtain split points (end points of the partedges) before deleting
      them.
   */
   num_splits = numtmpprted[i] - 1;
   EMerr_hndlr(num_splits > 2, *EMmsg, EMS_E_Fail, wrapup);

   for(j=0; j<num_splits; j++)
    {
     sts = om$send(msg = message EMSedge.EMendpts(EMmsg, NULL, split_uv[j], 
	   NULL, NULL, NULL), 
	   targetid = tmpprted[i][j], senderid = NULL_OBJID);
     if(!(1&*EMmsg&sts)) goto wrapup;
     
     sts = om$send(msg = message EMSedge.EMxyz_endpt(EMmsg, &thissf, 
	   &mod_info->md_env, NULL, split_uv[j], NULL, split_xyz[j], 
	   &thissf_geom), targetid = tmpprted[i][j], senderid = NULL_OBJID);
     if(!(1&*EMmsg&sts)) goto wrapup;
     split_loc[j] = EMScvint_middle;
    }

   for(j=0; j<numtmpprted[i]; j++)
    {
     if(IF_EQ_OBJID(tmpprted[i][j], thisedge)) continue;

     sts = om$send(msg = message Root.delete(TRUE), 
	   targetid = tmpprted[i][j], senderid = NULL_OBJID);
     if(!(1&*EMmsg&sts)) goto wrapup;
     tmpprted[i][j] = NULL_OBJID;
    }

   /* Create vertex uses at all split points on the original edge from
      the input pair.
   */
   if(numtmpprted[i] > 1)
    {
     sts = NMsetUpSSI(EMmsg, &thissf, ssi, &this_nm);
     EMerr_hndlr(!this_nm, *EMmsg, EMS_E_Fail, wrapup);
    }

   /* Construct vertex_use at each split point and connect it to a vertex.
   */
   for(j=0; j<num_splits; j++)
    {
     sts = om$construct(p_objid = &thisvtxuse.objid, 
	   classid = NMedgevtxuse_assoc ? OPP_NMvertex_use_class_id :
		     OPP_NMlistvtxuse_class_id,
           msg = message NMvertex_use.NMinit(EMmsg, NMinit_AddToSSI, 
		 NMvtxuse_Active, 0, NULL, NULL, NULL, ssi, &thissf));
     if(!(1&*EMmsg&sts)) goto wrapup;
     thisvtxuse.osnum = OM_Gw_current_OS;

     sts = om$send(msg = message NMvertex_use.NMconnect_edges(EMmsg, 1,
           &thisedge, &split_loc[j], split_uv[j], NMconnect_AddToSSI, ssi), 
	   senderid = NULL_OBJID,
	   targetid = thisvtxuse.objid);
     if(!(1&sts)) goto wrapup;

     /* Search the other edge in the pair for an existing vertex. 
        If none found create one.
     */
     thisvtx.objid = NULL_OBJID;
     thisvtx.osnum = OM_Gw_current_OS;

     for(m=0; m<numtmpprted[!i]; m++)
      {
       if(IF_NULL_OBJID(tmpprted[!i][m])) continue;
       sts = NMget_matching_vtx(EMmsg, tmpprted[!i][m], 
	     OM_Gw_current_OS, split_xyz[j], xyzlentol, NULL, &thisvtx.objid, 
	     NULL);
       if(!(1&*EMmsg&sts)) goto wrapup;
       if(!IF_NULL_OBJID(thisvtx.objid)) break;
      }

    if(IF_NULL_OBJID(thisvtx.objid))
     {
      sts = NMconstruct_vertex(EMmsg, construct, split_xyz[j], &thisvtx.objid);
      if(!(1&*EMmsg&sts)) goto wrapup;
      thisvtx.osnum = construct->env_info->md_id.osnum;
      sts = om$send(msg = message NMvertex.NMinit
	    (EMmsg, NMinit_AddToSSI, NMvtx_Active, 0, NULL, NULL, ssi), 
	    senderid = NULL_OBJID, 
	    targetid = thisvtx.objid);
      if(!(1&*EMmsg&sts)) goto wrapup;
     }

     sts = om$send(msg = message NMvertex.NMconnect_vertex_uses(EMmsg, 
           1, &thisvtxuse, split_xyz[j], ssi, NMconnect_AddToSSI), 
	   targetid = thisvtx.objid,
           senderid = NULL_OBJID);
     if(!(1&*EMmsg&sts)) goto wrapup;

    } /* for(j=0; j<num_splits; j++) */

   thisedge = i ? thispair->edge1 : thispair->edge0;

   /* Obtain the top paredges from each edge again, so as to get uptodate
      data. Note that the indexes obtained earlier for common edge pairs should
      not be altered, so as to map them automatically to new edges. Also, the
      partedges to be now obtained will be NMpartedges. So use the 
      corresponding NM function instead of EMSedge.EMget_top_part_edges.
   */

   ped = tmpprted[i];
   numtmpprted[i] = 0;
   for(j=0; j<MaxNumPe; j++) ped[j] = NULL_OBJID;
   sts = NMsend_to_partedges(&rc, message EMSedge.EMget_top_part_edges
         (&rc, &ped, &numtmpprted[i], &tmpprtedbufsize), thisedge,
          my_GRid->osnum, 0, MAXINT, NULL, NULL, NULL);
   EMerr_hndlr (!(1&sts&rc),*EMmsg,EMS_E_EdgeError,wrapup);
   if(!numtmpprted[i])
    {
     numtmpprted[i] = 1;
     ped[0] = thisedge;
    }
   EMerr_hndlr(numtmpprted[i] > MaxNumPe, *EMmsg, EMS_E_Fail, wrapup);

   OM_BLOCK_MOVE(ped, &part_edges[i ? MaxNumPe : 0], numtmpprted[i] *
   sizeof(GRobjid));

   junksfs[i] = thissf;

  } /* for(i=0; i<2; i++) */


 for(i=0; i<num_commed_pairs; i++)
  {
   struct GRid	commedges[2];

   commedges[0].objid = tmpprted[0][edgeidx[i]];
   commedges[1].objid = tmpprted[1][commidx[i]];
   commedges[0].osnum = commedges[1].osnum = OM_Gw_current_OS;
   nm1.objid = NULL_OBJID;
   nm2.objid = NULL_OBJID;

   /* Get existing NMedge (if any) from each edge in the pair.
   */
   sts = NMget_edge_mates(EMmsg, &commedges[0], NULL, NULL, NULL, NULL,
         NULL, &nm1, NULL, NULL, NULL);
   if(!(1&*EMmsg&sts)) goto wrapup;

   sts = NMget_edge_mates(EMmsg, &commedges[1], NULL, NULL, NULL, NULL,
         NULL, &nm2, NULL, NULL, NULL);
   if(!(1&*EMmsg&sts)) goto wrapup;

   if(IF_NULL_OBJID(nm1.objid) && IF_NULL_OBJID(nm2.objid))
    {
     /* If no NMedge exists, create one and connect the pair to it.
     */
     sts = om$construct(classid = NMedgevtxuse_assoc ? OPP_NMedge_class_id : 
			OPP_NMlistedge_class_id, 
           p_objid = &nm.objid, msg = message NMedge.NMinit
           (EMmsg, NMinit_AddToSSI, NMedge_Active, 0, NULL, NULL, NULL, NULL, 
	    ssi));
     if(!(1&sts)) goto wrapup;

     sts = om$send(msg = message NMedge.NMconnect_edges
           (EMmsg, 2, commedges, junksfs, NULL, mod_info, ssi, 
	    NMconnect_CompatibleVertices | NMconnect_AddToSSI), 
	   targetid = nm.objid, senderid = NULL_OBJID);
     if(!(1&sts)) goto wrapup;

    } /* if(IF_NULL_OBJID(nm1.objid) && IF_NULL_OBJID(nm2.objid)) */
   else
    {
     struct GRid	discon_nm, con_nm;
	
     /* Use the existing NMedge to connect up the two edges. When
	using an existing NMedge, store the edge connection info for
	undo. Also if the other edge has some mates transfer them to
	the new nm edge and store the edge disconnection info for
	undo.
     */
     discon_nm.objid = con_nm.objid = NULL_OBJID;
     if(!IF_NULL_OBJID(nm1.objid))
      {
       con_nm = nm1;
       if(!IF_NULL_OBJID(nm2.objid)) discon_nm = nm2;
      }
     else if(!IF_NULL_OBJID(nm2.objid))
      {
       con_nm = nm2;
       if(!IF_NULL_OBJID(nm1.objid)) discon_nm = nm1;
      }

     if(!IF_NULL_OBJID(discon_nm.objid))
      {
       /* Get all the edges from the nm edges to be disconnected and connect
	  them to the nm edge to be used. The edge from the pair being
	  stitched is already included in the edges obtained from
	  discon_nm and the other edge is already connected to the con_nm.
       */
       if(newmates) om$dealloc(ptr = newmates);
       newmates = NULL;
       num_newmates = 0;
       sts = om$send(msg = message NMedge.NMget_edge_info(EMmsg, 
	     &num_newmates, &newmates, NULL, NULL, NULL, NULL), 
	     targetid = discon_nm.objid, targetos = discon_nm.osnum, 
	     senderid = NULL_OBJID);
       if(!(1&*EMmsg&sts)) goto wrapup;
       if(num_newmates > StaticBuf)
	newmates_sf = (struct GRid *) om$malloc(size = num_newmates *
			 sizeof(struct GRid));
       else newmates_sf = (struct GRid *) newmates_sfbuf;
       EMerr_hndlr(!newmates_sf, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
       for(m=0; m<num_newmates; m++)
	{
	 sts = om$send(msg = message EMSboundary.EMgetsurface_info(EMmsg, 
	       &newmates_sf[m].objid, NULL), targetid = newmates[m].objid, 
	       targetos = newmates[m].osnum, senderid = NULL_OBJID);
	 if(!(1&*EMmsg&sts)) goto wrapup;
	 newmates_sf[m].osnum = newmates[m].osnum;

	 sts = NMstore_nmedge_change(EMmsg, ssi, &newmates_sf[m], 
	       discon_nm.objid, newmates[m].objid, FALSE);
	 if(!(1&*EMmsg&sts)) goto wrapup;
	}
	
       sts = om$send(msg = message NDnode.NDdisconnect(0, NULL), 
	     targetid = discon_nm.objid, senderid = NULL_OBJID);
       if(!(1&sts)) goto wrapup;
	  
       sts = om$send(msg = message NMedge.NMconnect_edges
             (EMmsg, num_newmates, newmates, newmates_sf, NULL, mod_info, ssi, 
	     NMconnect_CompatibleVertices | NMconnect_AddToSSI),
             targetid = con_nm.objid, senderid = NULL_OBJID);
       if(!(1&sts)) goto wrapup;

      } /* if(!IF_NULL_OBJID(discon_nm.objid)) */
     else
      {
       struct GRid		refsf;
       GRobjid			coned;
	
       if(IF_EQ_OBJID(nm1.objid, con_nm.objid))
	{
	 coned = commedges[1].objid;
	 refsf = junksfs[1];
	}
       else
	{
	 coned = commedges[0].objid;
	 refsf = junksfs[0];
	}
	
       sts = om$send(msg = message NMedge.NMconnect_edges
             (EMmsg, 2, commedges, junksfs, NULL, mod_info, ssi, 
	      NMconnect_CompatibleVertices | NMconnect_AddToSSI), 
             targetid = con_nm.objid, senderid = NULL_OBJID);
       if(!(1&sts)) goto wrapup;

      }/* else for if(!IF_NULL_OBJID(discon_nm.objid)) */

    } /* else for if(IF_NULL_OBJID(nm1.objid) && IF_NULL_OBJID(nm2.objid)) */

  } /* for(i=0; i<num_commed_pairs; i++) */




add_comp:

 for(i=0; i<2; i++)
  {
   GRobjid compid;
   IGRboolean already_connected = FALSE;

   compid = i ? compid2 : compid1;
   if(IF_NULL_OBJID(compid)) continue;
   
   for(j=0; j<*num_comps_to_connect; j++)
    if(IF_EQ_OBJID(comps_to_connect[j], compid))
     {
      already_connected = TRUE;
      break;
     }

   if(already_connected) was_connected[i] = TRUE;
   else
    {
     comps_to_connect[(*num_comps_to_connect)++] = compid;
     newly_connected[i] = TRUE;
    }
  }
 (*num_stitches)++;



wrapup:
if(mates) om$dealloc(ptr = mates);
if(newmates) om$dealloc(ptr = newmates);
if(newmates_sf && (newmates_sf != newmates_sfbuf)) 
 om$dealloc(ptr = newmates_sf);
if(deletable_edges) om$dealloc(ptr = deletable_edges);
#if DEBUG
if(!(1&*EMmsg&sts))
 printf("Problem in NMstitch_edge\n");
#endif
return(sts);
}

end  implementation NMnonmanist;

