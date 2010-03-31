class implementation Root;

#include "EMS.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "gr.h"
#include "godef.h"
#include "go.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "nmdef.h"
#include "nmchandef.h"
#include "nm.h"
#include <stdio.h>
#include "EMSmsgdef.h"
#include "emserr.h"
#include "emsmacros.h"

void NMinit_ssi(ssi)
struct NMgmSSI *ssi;
{
 ssi->nmentities = NULL;
 ssi->num_sfs = ssi->num_vtx = ssi->num_nmedges = 0;
 ssi->vtx = NULL;
 ssi->nmedges = NULL;
 ssi->nmbufsize = ssi->nmedgesbufsize = ssi->vtxbufsize = 0;
}

void NMfree_ssi(ssi)
struct NMgmSSI *ssi;
{
 IGRint		j;

 if(ssi->vtx)
   om$dealloc(ptr = ssi->vtx);

 if(ssi->nmedges) 
   om$dealloc(ptr = ssi->nmedges);

 if(ssi->nmentities)
  {
   for(j=0; j<ssi->num_sfs; j++)
    {
     if(ssi->nmentities[j].flps) om$dealloc(ptr = ssi->nmentities[j].flps);
     if(ssi->nmentities[j].vtxuses)om$dealloc(ptr=ssi->nmentities[j].vtxuses);
     if(ssi->nmentities[j].edges)om$dealloc(ptr=ssi->nmentities[j].edges);
     if(ssi->nmentities[j].edgesout)
       om$dealloc(ptr=ssi->nmentities[j].edgesout);
     if(ssi->nmentities[j].edgesin)om$dealloc(ptr=ssi->nmentities[j].edgesin);
     if(ssi->nmentities[j].edgesrev)
       om$dealloc(ptr=ssi->nmentities[j].edgesrev);

     if(ssi->nmentities[j].edcon)
       om$dealloc(ptr=ssi->nmentities[j].edcon);
     if(ssi->nmentities[j].nmedgescon)
       om$dealloc(ptr=ssi->nmentities[j].nmedgescon);

     if(ssi->nmentities[j].eddiscon)
       om$dealloc(ptr=ssi->nmentities[j].eddiscon);
     if(ssi->nmentities[j].nmedgesdiscon)
       om$dealloc(ptr=ssi->nmentities[j].nmedgesdiscon);

     if(ssi->nmentities[j].vtxusechg)
       om$dealloc(ptr=ssi->nmentities[j].vtxusechg);
     if(ssi->nmentities[j].origedges)
       om$dealloc(ptr=ssi->nmentities[j].origedges);
     if(ssi->nmentities[j].repledges)
       om$dealloc(ptr=ssi->nmentities[j].repledges);

     if(ssi->nmentities[j].vtxusetr)
       om$dealloc(ptr=ssi->nmentities[j].vtxusetr);
     if(ssi->nmentities[j].origvtx)
       om$dealloc(ptr=ssi->nmentities[j].origvtx);
     if(ssi->nmentities[j].replvtx)
       om$dealloc(ptr=ssi->nmentities[j].replvtx);

    }
   om$dealloc(ptr = ssi->nmentities);
  }

 NMinit_ssi(ssi);

}


void NMinit_nmentities(num, nmentities)
IGRint num;
struct NMentities *nmentities;
{
 struct NMentities *this_nm = NULL;
 IGRint		i;

 for(i=0; i<num; i++)
  {
   this_nm = (struct NMentities *) &nmentities[i];
   this_nm->sfid.objid = NULL_OBJID;

   this_nm->num_flps = this_nm->num_vtxuses = this_nm->num_edges = 
   this_nm->numedgesout = this_nm->numedgesrev = 
   this_nm->numedcon = this_nm->numeddiscon = 
   this_nm->numvtxusechg = this_nm->numvtxusetr = 0;

   this_nm->numedgesin = NULL;

   this_nm->flps = this_nm->vtxuses = this_nm->edges = 
   this_nm->edgesout = this_nm->edgesin = 
   this_nm->edgesrev = this_nm->edcon = this_nm->nmedgescon =
   this_nm->eddiscon = this_nm->nmedgesdiscon = 
   this_nm->vtxusechg = this_nm->origedges = this_nm->repledges = 
   this_nm->vtxusetr = this_nm->origvtx = this_nm->replvtx = NULL;

   this_nm->flpsbufsize = this_nm->vtxusebufsize = this_nm->edgesbufsize = 
   this_nm->edgesoutbufsize = this_nm->edgesinbufsize = 
   this_nm->edgesrevbufsize = this_nm->edconbufsize = 
   this_nm->eddisconbufsize = this_nm->vtxusechgbufsize = 
   this_nm->vtxusetrbufsize = 0;
  } 
}


extern struct NMgmssi_cache NMnonmanigm_ssi_cache;

void NMprint_ssi_cache()
{
 struct NMgmssi_cache *nm;

 nm = &NMnonmanigm_ssi_cache;
 fprintf(stderr, "NMnonmanigm SSI cache contents - \n");
 fprintf(stderr, "\telemid = %d.%d\n", nm->elemid.osnum, nm->elemid.objid);
 fprintf(stderr, "\tisvalid = %d\n", nm->is_valid);
 fprintf(stderr, "nmentities = 0x%x\n", nm->ssi.nmentities);
 fprintf(stderr, "num_sfs = %d num_vtx = %d num_nmedges = %d\n", 
	 nm->ssi.num_sfs, nm->ssi.num_vtx, nm->ssi.num_nmedges);
 fprintf(stderr, "vtx = 0x%x  nmedges = 0x%x\n", nm->ssi.vtx, nm->ssi.nmedges);
}


extern OMuword OPP_NMedflp_class_id;

void NMprint_ssi_debug(ssi)
struct NMgmSSI *ssi;
{
 IGRint j, i, numedsin = 0;
 struct NMentities *this_nm = NULL;
 IGRboolean isedflp = FALSE;
 IGRlong EMmsg;


 fprintf(stderr, "\tNum surfs affected: %d\n", ssi->num_sfs);
 for(i=0; i<ssi->num_sfs; i++) 
  {
   this_nm = &ssi->nmentities[i];

   fprintf(stderr, "\tSurface %d) Objectid %d\n", i+1, 
           this_nm->sfid.objid);
   if(this_nm->num_flps)
    fprintf(stderr, "\t\t Num Feature loops added: %d\n", 
           this_nm->num_flps);
   for(j=0; j<this_nm->num_flps; j++)
    {
     isedflp = EFisAncestryValid(&EMmsg, this_nm->flps[j], OM_Gw_current_OS, 
	       OPP_NMedflp_class_id, FALSE);
     if(isedflp)	
      fprintf(stderr, "\t\t\t%d   (EdFlp)\n", this_nm->flps[j]);
     else
      fprintf(stderr, "\t\t\t%d\n", this_nm->flps[j]);
    }

   if(this_nm->num_vtxuses)
    fprintf(stderr, "\t\t Num Vertex uses added: %d\n", 
           this_nm->num_vtxuses);
   for(j=0; j<this_nm->num_vtxuses; j++)
    fprintf(stderr, "\t\t\t%d\n", this_nm->vtxuses[j]);

   if(this_nm->num_edges)
    fprintf(stderr, "\t\t Num Edges added: %d\n", 
           this_nm->num_edges);
   for(j=0; j<this_nm->num_edges; j++)
    fprintf(stderr, "\t\t\t%d\n", this_nm->edges[j]);

   if(this_nm->numedgesout)
   fprintf(stderr, "\t\t Num Edges Out: %d\n", 
           this_nm->numedgesout);
   if(this_nm->numedgesout)
    fprintf(stderr, "\t\t\tEdges Out\t\tNum Edges In\n");

   numedsin = 0;
   for(j=0; j<this_nm->numedgesout; j++)
    {
     fprintf(stderr, "\t\t\t%d\t\t\t%d\n", this_nm->edgesout[j], 
             this_nm->numedgesin[j]);
     numedsin+= this_nm->numedgesin[j];
    }
   if(numedsin) fprintf(stderr, "\t\tEdges In:\n");
   for(j=0; j<numedsin; j++)
     fprintf(stderr, "\t\t\t%d\n", this_nm->edgesin[j]);

   if(this_nm->numedgesrev)
    fprintf(stderr, "\t\t Num Edges Reversed: %d\n", 
           this_nm->numedgesrev);
   for(j=0; j<this_nm->numedgesrev; j++)
    fprintf(stderr, "\t\t\t%d\n", this_nm->edgesrev[j]);

   if(this_nm->numedcon)
    {
     fprintf(stderr, "\t\tNum Edges Connected: %d\n", this_nm->numedcon);
     fprintf(stderr, "\t\t\tEdge connected\t\tTo NMedge\n");
     for(j=0; j<this_nm->numedcon; j++)
      fprintf(stderr, "\t\t\t%d\t\t\t%d\n", this_nm->edcon[j], 
	this_nm->nmedgescon[j]);
    }

   if(this_nm->numeddiscon)
    {
     fprintf(stderr, "\t\tNum Edges Disconnected: %d\n", this_nm->numeddiscon);
     fprintf(stderr, "\t\t\tEdge disconnected\tFrom NMedge\n");
     for(j=0; j<this_nm->numeddiscon; j++)
      fprintf(stderr, "\t\t\t%d\t\t\t%d\n", this_nm->eddiscon[j], 
	this_nm->nmedgesdiscon[j]);
    }

   if(this_nm->numvtxusechg)
    {
     fprintf(stderr, "\t\tNum Vtxuses changed: %d\n", this_nm->numvtxusechg);
     fprintf(stderr, "\t\t\tVtxUse Changed\tOrig Edge\tRepl Edge\n");
     for(j=0; j<this_nm->numvtxusechg; j++)
      fprintf(stderr, "\t\t\t%d\t\t%d\t\t%d\n", this_nm->vtxusechg[j], 
	this_nm->origedges[j], this_nm->repledges[j]);
    }

   if(this_nm->numvtxusetr)
    {
     fprintf(stderr, "\t\tNum Vtxuses Transfered: %d\n",this_nm->numvtxusetr);
     fprintf(stderr, "\t\t\tVtxUse Transfered\tOrig Vtx\tRepl Vtx\n");
     for(j=0; j<this_nm->numvtxusetr; j++)
      fprintf(stderr, "\t\t\t%d\t\t\t%d\t\t%d\n", this_nm->vtxusetr[j], 
	this_nm->origvtx[j], this_nm->replvtx[j]);
    }

  } /* for(i=0; i<ssi->num_sfs; i++) */

 if(ssi->num_nmedges)
  fprintf(stderr, "\tNum NMedges created: %d\n", ssi->num_nmedges);
 for(i=0; i<ssi->num_nmedges; i++)
  fprintf(stderr, "\t\t%d\n", ssi->nmedges[i]);

 if(ssi->num_vtx)
  fprintf(stderr, "\tNum NMvertexes created: %d\n", ssi->num_vtx);
 for(i=0; i<ssi->num_vtx; i++)
  fprintf(stderr, "\t\t%d\n", ssi->vtx[i]);

}




IGRint NMstore_edges_created(EMmsg, ssi, sfid, num_edges, edges)
IGRlong *EMmsg;
struct NMgmSSI *ssi;
struct GRid *sfid;
IGRint num_edges;
GRobjid *edges;
{
 struct NMentities *thisnm = NULL;
 IGRlong sts = OM_S_SUCCESS;
 IGRint i;

 *EMmsg = EMS_S_Success;
 for(i=0; i<num_edges; i++)
  {
   sts = NMsetUpSSI(EMmsg, sfid, ssi, &thisnm);
   if(!(1&*EMmsg&sts)) goto wrapup;

   thisnm->edges[thisnm->num_edges++] = edges[i];
   thisnm->edgesbufsize--;
  }

wrapup:
return(sts);
}


IGRint NMstore_edge_change(EMmsg, ssi, sfid, origed, num_repl, repled)
IGRlong *EMmsg;
struct NMgmSSI *ssi;
struct GRid *sfid;
IGRint num_repl;
GRobjid origed, *repled;
{
 struct NMentities *thisnm = NULL;
 IGRlong sts = OM_S_SUCCESS;
 IGRint i, j, totaledsin = 0;

 *EMmsg = EMS_S_Success;

 /* If the original edge was created during this run, no need to store the
    replacements info. Edges 'in' during some previous replacements are also 
    considered to be created during this run. However, if the replacement
    info may not need to be recorded, the 'edges in' still need to be recorded
    as being created during this run. Although this may not be much of a
    saving in space, it will eliminate unnecessary edge replacements during
    'undo' or 'deactivation' of the state.

    Nov 21, 1991 -
    The above made ineffective due to problem discovered due to multiple
    splits. Enough information about the second split does not get recorded
    for undo to work properly.
    The best solution is to collapse all intermediate edges in case of multiple
    splits and store only the top edges as edges in for the bottom most edge
    out.
 */
 /**********************************************
 for(i=0; i<ssi->num_sfs; i++)
  {
   thisnm = &ssi->nmentities[i];
   for(j=0; j<thisnm->num_edges; j++)
    if(IF_EQ_OBJID(thisnm->edges[j], origed))
     {
      sts = NMstore_edges_created(EMmsg, ssi, sfid, num_repl, repled);
      goto wrapup;
     }

   totaledsin = 0;
   for(j=0; j<thisnm->numedgesout; j++)
    totaledsin += thisnm->numedgesin[j];

   for(j=0; j<totaledsin; j++)
    if(IF_EQ_OBJID(thisnm->edgesin[j], origed))
     {
      sts = NMstore_edges_created(EMmsg, ssi, sfid, num_repl, repled);
      goto wrapup;
     }
  }
 ***********************************************/

 thisnm = NULL;
 sts = NMsetUpSSI(EMmsg, sfid, ssi, &thisnm);
 if(!(1&*EMmsg&sts)) goto wrapup;
 
 totaledsin = 0;
 for(j=0; j<thisnm->numedgesout; j++)
  totaledsin += thisnm->numedgesin[j];

 thisnm->edgesout[thisnm->numedgesout] = origed;
 thisnm->numedgesin[thisnm->numedgesout++] = num_repl;
 thisnm->edgesoutbufsize--;

 for(i=0; i<num_repl; i++)
  {
   sts = NMsetUpSSI(EMmsg, sfid, ssi, &thisnm);
   if(!(1&*EMmsg&sts)) goto wrapup;
   thisnm->edgesin[totaledsin++] = repled[i];
   thisnm->edgesinbufsize--;
  }

wrapup:
return(sts);
}



IGRint NMstore_vtxuse_change(EMmsg, ssi, sfid, vtu, origed, repled)
IGRlong *EMmsg;
struct NMgmSSI *ssi;
struct GRid *sfid;
GRobjid vtu, origed, repled;
{
 struct NMentities *thisnm = NULL;
 IGRlong sts = OM_S_SUCCESS;
 IGRint i, j, totaledsin = 0;

 *EMmsg = EMS_S_Success;

 /* If this vtu was created in this run, no need to store the info.
 */
 for(i=0; i<ssi->num_sfs; i++)
  {
   thisnm = &ssi->nmentities[i];
   for(j=0; j<thisnm->num_vtxuses; j++)
    if(IF_EQ_OBJID(thisnm->vtxuses[j], vtu))
      goto wrapup;
  }


 /* If the original edge was created during this run, no need to store the 
    information.
 */
 for(i=0; i<ssi->num_sfs; i++)
  {
   thisnm = &ssi->nmentities[i];
   for(j=0; j<thisnm->num_edges; j++)
    if(IF_EQ_OBJID(thisnm->edges[j], origed))
      goto wrapup;

   totaledsin = 0;
   for(j=0; j<thisnm->numedgesout; j++)
    totaledsin += thisnm->numedgesin[j];

   for(j=0; j<totaledsin; j++)
    if(IF_EQ_OBJID(thisnm->edgesin[j], origed))
      goto wrapup;
  }


 /* If the information is already recorded no need to store it again.
 */
 for(i=0; i<ssi->num_sfs; i++)
  {
   thisnm = &ssi->nmentities[i];
   for(j=0; j<thisnm->numvtxusechg; j++)
    if( (IF_EQ_OBJID(thisnm->vtxusechg[j], vtu)) &&
        (IF_EQ_OBJID(thisnm->origedges[j], origed)) &&
        (IF_EQ_OBJID(thisnm->repledges[j], repled)))
      goto wrapup;
  }

 thisnm = NULL;
 sts = NMsetUpSSI(EMmsg, sfid, ssi, &thisnm);
 if(!(1&*EMmsg&sts)) goto wrapup;

 thisnm->vtxusechg[thisnm->numvtxusechg] = vtu;
 thisnm->origedges[thisnm->numvtxusechg] = origed;
 thisnm->repledges[thisnm->numvtxusechg++] = repled;
 thisnm->vtxusechgbufsize--;

wrapup:
return(sts);
}


IGRint NMstore_nmedge_change(EMmsg, ssi, sfid, nmedge, edge, 
			     connected)
IGRlong *EMmsg;
struct NMgmSSI *ssi;
struct GRid *sfid;
GRobjid nmedge, edge;
IGRboolean connected;
{
 struct NMentities *thisnm = NULL;
 IGRlong sts = OM_S_SUCCESS;
 IGRint i, j, totaledsin = 0;

 *EMmsg = EMS_S_Success;

 /* If this nmedge was created in this run, no need to store the info.
 */
 for(i=0; i<ssi->num_nmedges; i++)
  if(IF_EQ_OBJID(ssi->nmedges[i], nmedge))
      goto wrapup;

 /* If the edge being connected/disconnected was created during this run, 
    no need to store the information.
 */
 for(i=0; i<ssi->num_sfs; i++)
  {
   thisnm = &ssi->nmentities[i];
   for(j=0; j<thisnm->num_edges; j++)
    if(IF_EQ_OBJID(thisnm->edges[j], edge))
      goto wrapup;

   totaledsin = 0;
   for(j=0; j<thisnm->numedgesout; j++)
    totaledsin += thisnm->numedgesin[j];

   for(j=0; j<totaledsin; j++)
    if(IF_EQ_OBJID(thisnm->edgesin[j], edge))
      goto wrapup;
  }

 /* If the information is already recorded no need to store it again.
 */
 for(i=0; i<ssi->num_sfs; i++)
  {
   thisnm = &ssi->nmentities[i];
   if(connected)
    {
     for(j=0; j<thisnm->numedcon; j++)
      if( (IF_EQ_OBJID(thisnm->edcon[j], edge)) &&
          (IF_EQ_OBJID(thisnm->nmedgescon[j], nmedge)))
       goto wrapup;
    }
   else
    {
     for(j=0; j<thisnm->numeddiscon; j++)
      if( (IF_EQ_OBJID(thisnm->eddiscon[j], edge)) &&
          (IF_EQ_OBJID(thisnm->nmedgesdiscon[j], nmedge)))
       goto wrapup;
    }
  }

 thisnm = NULL;
 sts = NMsetUpSSI(EMmsg, sfid, ssi, &thisnm);
 if(!(1&*EMmsg&sts)) goto wrapup;

 if(connected)
  {
   thisnm->edcon[thisnm->numedcon] = edge;
   thisnm->nmedgescon[thisnm->numedcon++] = nmedge;
   thisnm->edconbufsize--;
  }
 else
  {
   thisnm->eddiscon[thisnm->numeddiscon] = edge;
   thisnm->nmedgesdiscon[thisnm->numeddiscon++] = nmedge;
   thisnm->eddisconbufsize--;
  }

wrapup:
return(sts);
}



IGRint NMstore_vtxuse_transfer(EMmsg, ssi, sfid, vtu, origvtx, replvtx)
IGRlong *EMmsg;
struct NMgmSSI *ssi;
struct GRid *sfid;
GRobjid vtu, origvtx, replvtx;
{
 struct NMentities *thisnm = NULL;
 IGRlong sts = OM_S_SUCCESS;
 IGRint i, j;

 *EMmsg = EMS_S_Success;

 /* If this vtu was created in this run, no need to store the info.
 */
 for(i=0; i<ssi->num_sfs; i++)
  {
   thisnm = &ssi->nmentities[i];
   for(j=0; j<thisnm->num_vtxuses; j++)
    if(IF_EQ_OBJID(thisnm->vtxuses[j], vtu))
      goto wrapup;
  }


 /* If the original vtx was created during this run, no need to store the 
    information.
 */
 for(i=0; i<ssi->num_vtx; i++)
  if(IF_EQ_OBJID(ssi->vtx[i], origvtx)) goto wrapup;


 /* If the information is already recorded no need to store it again.
 */
 for(i=0; i<ssi->num_sfs; i++)
  {
   thisnm = &ssi->nmentities[i];
   for(j=0; j<thisnm->numvtxusetr; j++)
    if( (IF_EQ_OBJID(thisnm->vtxusetr[j], vtu)) &&
        (IF_EQ_OBJID(thisnm->origvtx[j], origvtx)) &&
        (IF_EQ_OBJID(thisnm->replvtx[j], replvtx)))
      goto wrapup;
  }

 thisnm = NULL;
 sts = NMsetUpSSI(EMmsg, sfid, ssi, &thisnm);
 if(!(1&*EMmsg&sts)) goto wrapup;

 thisnm->vtxusetr[thisnm->numvtxusetr] = vtu;
 thisnm->origvtx[thisnm->numvtxusetr] = origvtx;
 thisnm->replvtx[thisnm->numvtxusetr++] = replvtx;
 thisnm->vtxusetrbufsize--;

wrapup:
return(sts);
}


#define NmEntInc 10
#define FlpInc 10
#define VtxuseInc 10
#define VtxInc 10
#define EdgesInc 10
#define LpOutInc 3
#define EdOutInc 3
#define EdInInc 4
#define EdRevInc 4
#define EdConInc 4
#define EdDisConInc 4
#define NMedgeInc 5
#define VtxUseChgInc 5
#define VtxUseTrInc 2

IGRint NMsetUpSSI(EMmsg, sfid, ssi, nmnode)
IGRlong *EMmsg;
struct GRid *sfid;
struct NMgmSSI *ssi;
struct NMentities **nmnode; /* Optional */
{
 IGRint			n;
 struct NMentities	*this_nm = NULL;
 IGRlong		sts = OM_S_SUCCESS;

 *EMmsg = EMS_S_Success;

 if(!sfid && !nmnode) goto other_ssi;

 for(n=0; n<ssi->num_sfs; n++)    
  if(IF_EQ_GRID(ssi->nmentities[n].sfid, *sfid))
   {
    this_nm = (struct NMentities *) &(ssi->nmentities)[n];
    break;
   }

 if(!this_nm) 
  {
   /* Need a new node. Malloc/Realloc if necessary.
   */
   if(!ssi->nmbufsize)
    {
     if(ssi->nmentities)
      ssi->nmentities = (struct NMentities *) om$realloc(
		     ptr = (IGRchar *) ssi->nmentities, size = (NmEntInc + ssi->num_sfs) 
 		             * sizeof(struct NMentities));
     else
      ssi->nmentities = (struct NMentities *) om$malloc(size = 
                           NmEntInc * sizeof(struct NMentities));
     EMerr_hndlr(!ssi->nmentities, *EMmsg, EMS_E_NoDynamicMemory,wrapup);
     ssi->nmbufsize = NmEntInc;

     /* Initialize newly malloced nodes.
     */
     NMinit_nmentities(ssi->nmbufsize, &ssi->nmentities[ssi->num_sfs]);

    }/* if(!ssi->nmbuffsize) */

   this_nm = (struct NMentities *) &ssi->nmentities[ssi->num_sfs];
   this_nm->sfid = *sfid;
   ssi->num_sfs++;
   ssi->nmbufsize--;

  } /* if(!this_nm) */


 EMerr_hndlr(!this_nm, *EMmsg, EMS_E_Fail, wrapup);

 if(!this_nm->flpsbufsize)
  {
   if(this_nm->flps)
    this_nm->flps = (GRobjid *) om$realloc(ptr = (IGRchar *)this_nm->flps, 
                    size = (this_nm->num_flps + FlpInc) * sizeof(GRobjid));
   else
    this_nm->flps = (GRobjid *) om$malloc(size = FlpInc * sizeof(GRobjid));
   EMerr_hndlr(!this_nm->flps, *EMmsg, EMS_E_NoDynamicMemory, 
			wrapup);
   this_nm->flpsbufsize = FlpInc;
  }

 if(!this_nm->vtxusebufsize)
  {
   if(this_nm->vtxuses)
    this_nm->vtxuses = (GRobjid *) om$realloc(ptr = (IGRchar *)this_nm->vtxuses, 
                      size = (this_nm->num_vtxuses + VtxuseInc) 
		      * sizeof(GRobjid));
   else
    this_nm->vtxuses = (GRobjid *) om$malloc(size = 
                               VtxuseInc * sizeof(GRobjid));
   EMerr_hndlr(!this_nm->vtxuses, *EMmsg, EMS_E_NoDynamicMemory, 
			wrapup);
   this_nm->vtxusebufsize = VtxuseInc;
  }

 if(!this_nm->edgesbufsize)
  {
   if(this_nm->edges)
    this_nm->edges = (GRobjid *) om$realloc(ptr = (IGRchar *)this_nm->edges, 
                      size = (this_nm->num_edges + EdgesInc) 
		      * sizeof(GRobjid));
   else
    this_nm->edges = (GRobjid *) om$malloc(size = 
                               EdgesInc * sizeof(GRobjid));
   EMerr_hndlr(!this_nm->edges, *EMmsg, EMS_E_NoDynamicMemory, 
			wrapup);
   this_nm->edgesbufsize = EdgesInc;
  }

 if(!this_nm->edgesoutbufsize)
  {
   if(this_nm->edgesout)
    {
     this_nm->edgesout = (GRobjid *) om$realloc(ptr = (IGRchar *)this_nm->edgesout, 
                         size = (this_nm->numedgesout + EdOutInc) 
		         * sizeof(GRobjid));
     this_nm->numedgesin = (IGRint *) om$realloc(ptr = (IGRchar *)this_nm->numedgesin, 
                         size = (this_nm->numedgesout + EdOutInc) 
		         * sizeof(IGRint));
    }
   else
    {
     this_nm->edgesout = (GRobjid *) om$malloc(size = 
                               EdOutInc * sizeof(GRobjid));
     this_nm->numedgesin = (IGRint *) om$malloc(size = 
                               EdOutInc * sizeof(IGRint));
    }
   EMerr_hndlr(!this_nm->edgesout || !this_nm->numedgesin, *EMmsg, 
	      EMS_E_NoDynamicMemory, wrapup);

   this_nm->edgesoutbufsize = EdOutInc;
  }


 if(!this_nm->edgesinbufsize)
  {
   if(this_nm->edgesin)
    {
     IGRint total_edgesin = 0;

     for(n=0; n<this_nm->numedgesout; n++)
      total_edgesin += this_nm->numedgesin[n];

     this_nm->edgesin = (GRobjid *) om$realloc(ptr = (IGRchar *)this_nm->edgesin, 
                        size = (total_edgesin + EdInInc) 
		        * sizeof(GRobjid));
    }
   else
    this_nm->edgesin = (GRobjid *) om$malloc(size = 
                               EdInInc * sizeof(GRobjid));
   EMerr_hndlr(!this_nm->edgesin, *EMmsg, EMS_E_NoDynamicMemory, 
			wrapup);
   this_nm->edgesinbufsize = EdInInc;
  }

 if(!this_nm->edgesrevbufsize)
  {
   if(this_nm->edgesrev)
    this_nm->edgesrev = (GRobjid *) om$realloc(ptr = (IGRchar *)this_nm->edgesrev, 
                      size = (this_nm->numedgesrev + EdRevInc) 
		      * sizeof(GRobjid));
   else
    this_nm->edgesrev = (GRobjid *) om$malloc(size = 
                               EdRevInc * sizeof(GRobjid));
   EMerr_hndlr(!this_nm->edgesrev, *EMmsg, EMS_E_NoDynamicMemory, 
			wrapup);
   this_nm->edgesrevbufsize = EdRevInc;
  }

 if(!this_nm->edconbufsize)
  {
   if(this_nm->edcon)
    {
     this_nm->edcon = (GRobjid *) om$realloc(ptr = (IGRchar *)this_nm->edcon, 
                    size = (this_nm->numedcon + EdConInc) * sizeof(GRobjid));
     this_nm->nmedgescon = (GRobjid *) om$realloc(ptr = (IGRchar *)this_nm->nmedgescon, 
                    size = (this_nm->numedcon + EdConInc) * sizeof(GRobjid));
    }
   else
    {
     this_nm->edcon = (GRobjid *) om$malloc(size = EdConInc * sizeof(GRobjid));
     this_nm->nmedgescon = (GRobjid *) om$malloc(size = EdConInc * 
		sizeof(GRobjid));
    }
   EMerr_hndlr(!this_nm->edcon || !this_nm->nmedgescon, *EMmsg, 
		EMS_E_NoDynamicMemory, wrapup);
   this_nm->edconbufsize = EdConInc;
  }

 if(!this_nm->eddisconbufsize)
  {
   if(this_nm->eddiscon)
    {
     this_nm->eddiscon = (GRobjid *) om$realloc(ptr = (IGRchar *)this_nm->eddiscon, 
                size = (this_nm->numeddiscon + EdDisConInc) * sizeof(GRobjid));
     this_nm->nmedgesdiscon = (GRobjid *) om$realloc(ptr = (IGRchar *)
	this_nm->nmedgesdiscon, size = (this_nm->numeddiscon + EdDisConInc) * 
	sizeof(GRobjid));
    }
   else
    {
     this_nm->eddiscon = (GRobjid *) om$malloc(size = EdDisConInc * 
	sizeof(GRobjid));
     this_nm->nmedgesdiscon = (GRobjid *) om$malloc(size = EdDisConInc * 
	sizeof(GRobjid));
    }
   EMerr_hndlr(!this_nm->eddiscon || !this_nm->nmedgesdiscon, *EMmsg, 
	EMS_E_NoDynamicMemory, wrapup);
   this_nm->eddisconbufsize = EdDisConInc;
  }


 if(!this_nm->vtxusechgbufsize)
  {
   if(this_nm->vtxusechg)
    {
     this_nm->vtxusechg = (GRobjid *) om$realloc(ptr = (IGRchar *)this_nm->vtxusechg, 
              size = (this_nm->numvtxusechg + VtxUseChgInc) * sizeof(GRobjid));
     this_nm->origedges = (GRobjid *) om$realloc(ptr = (IGRchar *)
	this_nm->origedges, size = (this_nm->numvtxusechg + VtxUseChgInc) * 
	sizeof(GRobjid));
     this_nm->repledges = (GRobjid *) om$realloc(ptr = (IGRchar *)
	this_nm->repledges, size = (this_nm->numvtxusechg + VtxUseChgInc) * 
	sizeof(GRobjid));
    }
   else
    {
     this_nm->vtxusechg = (GRobjid *) om$malloc(size = VtxUseChgInc * 
	sizeof(GRobjid));
     this_nm->origedges = (GRobjid *) om$malloc(size = VtxUseChgInc * 
	sizeof(GRobjid));
     this_nm->repledges = (GRobjid *) om$malloc(size = VtxUseChgInc * 
	sizeof(GRobjid));
    }
   EMerr_hndlr(!this_nm->vtxusechg || !this_nm->origedges || 
	       !this_nm->repledges, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
   this_nm->vtxusechgbufsize = VtxUseChgInc;
  }


 if(!this_nm->vtxusetrbufsize)
  {
   if(this_nm->vtxusetr)
    {
     this_nm->vtxusetr = (GRobjid *) om$realloc(ptr = (IGRchar *)this_nm->vtxusetr, 
              size = (this_nm->numvtxusetr + VtxUseTrInc) * sizeof(GRobjid));
     this_nm->origvtx = (GRobjid *) om$realloc(ptr = (IGRchar *)
	this_nm->origvtx, size = (this_nm->numvtxusetr + VtxUseTrInc) * 
	sizeof(GRobjid));
     this_nm->replvtx = (GRobjid *) om$realloc(ptr = (IGRchar *)
	this_nm->replvtx, size = (this_nm->numvtxusetr + VtxUseTrInc) * 
	sizeof(GRobjid));
    }
   else
    {
     this_nm->vtxusetr = (GRobjid *) om$malloc(size = VtxUseTrInc * 
	sizeof(GRobjid));
     this_nm->origvtx = (GRobjid *) om$malloc(size = VtxUseTrInc * 
	sizeof(GRobjid));
     this_nm->replvtx = (GRobjid *) om$malloc(size = VtxUseTrInc * 
	sizeof(GRobjid));
    }
   EMerr_hndlr(!this_nm->vtxusetr || !this_nm->origvtx || 
	       !this_nm->replvtx, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
   this_nm->vtxusetrbufsize = VtxUseTrInc;
  }


 if(nmnode) *nmnode = this_nm;


other_ssi:

 if(!ssi->vtxbufsize)
  {
   if(ssi->vtx)
    ssi->vtx = (GRobjid *) om$realloc(ptr = (IGRchar *)ssi->vtx, 
           size = (VtxInc + ssi->num_vtx) * sizeof(GRobjid));
   else
    ssi->vtx = (GRobjid *) om$malloc(size = VtxInc * sizeof(GRobjid));
   EMerr_hndlr(!ssi->vtx, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
   ssi->vtxbufsize = VtxInc;
  }

 if(!ssi->nmedgesbufsize)
  {
   if(ssi->nmedges)
     ssi->nmedges = (GRobjid *) om$realloc(ptr = (IGRchar *)ssi->nmedges, 
                size = (NMedgeInc+ssi->num_nmedges) * sizeof(GRobjid));
   else
    ssi->nmedges = (GRobjid *) om$malloc(size = NMedgeInc * sizeof(GRobjid));
   EMerr_hndlr(!ssi->nmedges, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
   ssi->nmedgesbufsize = NMedgeInc;
  }


wrapup:
EMWRAPUP(*EMmsg, sts, "NMsetUpSSI");
return(OM_S_SUCCESS);
}


end implementation Root;
