class implementation NMnonmanigm;

#include "OMmacros.h"

extern struct NMgmssi_cache NMnonmanigm_ssi_cache;

method NMget_SSI(IGRlong *EMmsg; struct NMgmSSI *ssi;IGRushort options)
{
 IGRlong		sts = OM_S_SUCCESS;
 IGRint			i, j, n, total_edgesin = 0, thisnm_edinidx = 0, 
			num_idx = 0, ids_idx = 0;
 struct NMentities 	*this_nm = NULL;
 struct NMgmSSI		locssi;

 *EMmsg = EMS_S_Success;
 NMinit_ssi(&locssi);

 if(options & NMgetssi_cache)
  {
   if(!NMnonmanigm_ssi_cache.is_valid ||
      (!IF_EQ_OBJID(NMnonmanigm_ssi_cache.elemid.objid, my_id)))
    {
     IGRushort locopt;

     locopt = options & (~NMgetssi_cache) & (~NMgetssi_NoVtx) 
	      & (~NMgetssi_NoNmEdge) & (~NMgetssi_NoNmEntities);
	
     sts = om$send(msg = message NMnonmanigm.NMget_SSI(EMmsg, &locssi, 
	   locopt), targetid = my_id);
     if(!(1&*EMmsg&sts)) goto wrapup;

     /* Free the existing buffer and set the new buffer.
     */
     NMfree_ssi(&NMnonmanigm_ssi_cache.ssi);

     NMnonmanigm_ssi_cache.elemid.objid = my_id;
     NMnonmanigm_ssi_cache.elemid.osnum = OM_Gw_current_OS;
     NMnonmanigm_ssi_cache.is_valid = TRUE;
     NMnonmanigm_ssi_cache.ssi = locssi;
     NMinit_ssi(&locssi);
    }

   /* Return buffer and exit.
   */
   *ssi = NMnonmanigm_ssi_cache.ssi;
   goto wrapup;
  }

 NMinit_ssi(ssi);
 ssi->num_sfs = ME.NMnonmanigm->num_sfs;

 if(!(options & NMgetssi_NoNmEntities))
  { 
	
   if(ssi->num_sfs)
    {
     ssi->nmentities = (struct NMentities *) om$malloc(size = ssi->num_sfs
                 * sizeof(struct NMentities));
     EMerr_hndlr(!ssi->nmentities, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
    }

   /* Initialize all structure nodes, to prevent junk pointers from being
      returned in case of premature exit of the method.
   */
   NMinit_nmentities(ssi->num_sfs, ssi->nmentities);

   for(i=0; i<ssi->num_sfs; i++)
    {
     this_nm = &ssi->nmentities[i];
     sts = NMtag(EMmsg, &this_nm->sfid, &ME.NMnonmanigm->sfid[i], FALSE);
     if(!(1&*EMmsg&sts)) goto wrapup;

     sts = om$is_objid_valid(objid = this_nm->sfid.objid);
     if(sts != OM_S_SUCCESS)
      {
       sts = OM_S_SUCCESS;
       this_nm->sfid.objid = NULL_OBJID;
      }
     if(!(1&sts)) goto wrapup;

     this_nm->num_flps = ME.NMnonmanigm->num[num_idx++];
     if(this_nm->num_flps)
      {
       this_nm->flps = (GRobjid *) om$malloc(size = this_nm->num_flps *
		       sizeof(GRobjid));
       EMerr_hndlr(!this_nm->flps, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
      }
     for(j=0; j<this_nm->num_flps; j++)
      {
       this_nm->flps[j] = ME.NMnonmanigm->ids[ids_idx++];
       sts = om$is_objid_valid(objid = this_nm->flps[j]);
       if(sts != OM_S_SUCCESS)
        {
         sts = OM_S_SUCCESS;
         this_nm->flps[j] = NULL_OBJID;
        }
       if(!(1&sts)) goto wrapup;
      }

     this_nm->num_vtxuses = ME.NMnonmanigm->num[num_idx++];
     if(this_nm->num_vtxuses)
      {
       this_nm->vtxuses = (GRobjid *) om$malloc(size = this_nm->num_vtxuses *
		           sizeof(GRobjid));
       EMerr_hndlr(!this_nm->vtxuses, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
      }
     for(j=0; j<this_nm->num_vtxuses; j++)
      {
       this_nm->vtxuses[j] = ME.NMnonmanigm->ids[ids_idx++];
       sts = om$is_objid_valid(objid = this_nm->vtxuses[j]);
       if(sts != OM_S_SUCCESS)
        {
         sts = OM_S_SUCCESS;
         this_nm->vtxuses[j] = NULL_OBJID;
        }
       if(!(1&sts)) goto wrapup;
      }

     this_nm->num_edges = ME.NMnonmanigm->num[num_idx++];
     if(this_nm->num_edges)
      {
       this_nm->edges = (GRobjid *) om$malloc(size = this_nm->num_edges *
		        sizeof(GRobjid));
       EMerr_hndlr(!this_nm->edges, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
      }
     for(j=0; j<this_nm->num_edges; j++)
      {
       this_nm->edges[j] = ME.NMnonmanigm->ids[ids_idx++];
       sts = om$is_objid_valid(objid = this_nm->edges[j]);
       if(sts != OM_S_SUCCESS)
        {
         sts = OM_S_SUCCESS;
         this_nm->edges[j] = NULL_OBJID;
        }
       if(!(1&sts)) goto wrapup;
      }


     this_nm->numedgesrev = ME.NMnonmanigm->num[num_idx++];
     if(this_nm->numedgesrev)
      {
       this_nm->edgesrev = (GRobjid *) om$malloc(size = this_nm->numedgesrev *
		        sizeof(GRobjid));
       EMerr_hndlr(!this_nm->edgesrev, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
      }
     for(j=0; j<this_nm->numedgesrev; j++)
      {
       this_nm->edgesrev[j] = ME.NMnonmanigm->ids[ids_idx++];
       sts = om$is_objid_valid(objid = this_nm->edgesrev[j]);
       if(sts != OM_S_SUCCESS)
        {
         sts = OM_S_SUCCESS;
         this_nm->edgesrev[j] = NULL_OBJID;
        }
       if(!(1&sts)) goto wrapup;
      }

     this_nm->numedgesout = ME.NMnonmanigm->num[num_idx++];
     if(this_nm->numedgesout)
      {
       this_nm->edgesout = (GRobjid *) om$malloc(size = this_nm->numedgesout *
		        sizeof(GRobjid));

       this_nm->numedgesin = (IGRint *) om$malloc(size = this_nm->numedgesout *
		        sizeof(IGRint));

       EMerr_hndlr(!this_nm->edgesout || !this_nm->numedgesin, *EMmsg, 
		   EMS_E_NoDynamicMemory, wrapup);
      }

     total_edgesin = 0;
     for(j=0; j<this_nm->numedgesout; j++)
      {
       this_nm->edgesout[j] = ME.NMnonmanigm->ids[ids_idx++];
       this_nm->numedgesin[j] = ME.NMnonmanigm->num[num_idx++];
       total_edgesin += this_nm->numedgesin[j];
      }

     if(total_edgesin)
      {
       this_nm->edgesin = (GRobjid *) om$malloc(size = total_edgesin *
		        sizeof(GRobjid));
       EMerr_hndlr(!this_nm->edgesin, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
      }

     thisnm_edinidx = 0;
     for(j=0; j<this_nm->numedgesout; j++)
      {
       sts = om$is_objid_valid(objid = this_nm->edgesout[j]);
       if(sts != OM_S_SUCCESS)
        {
         sts = OM_S_SUCCESS;
         this_nm->edgesout[j] = NULL_OBJID;
        }
       if(!(1&sts)) goto wrapup;

       for(n=0; n<this_nm->numedgesin[j]; n++)
        {
	 this_nm->edgesin[thisnm_edinidx] = 
	   ME.NMnonmanigm->ids[ids_idx++];
         sts = om$is_objid_valid(objid = this_nm->edgesin[thisnm_edinidx]);
         if(sts != OM_S_SUCCESS)
          {
           sts = OM_S_SUCCESS;
           this_nm->edgesin[thisnm_edinidx++] = NULL_OBJID;
          }
         else thisnm_edinidx++;
         if(!(1&sts)) goto wrapup;
        }

      } /* for(j=0; j<this_nm->numedgesout; j++) */


     this_nm->numvtxusechg = ME.NMnonmanigm->num[num_idx++];
     if(this_nm->numvtxusechg)
      {
       this_nm->vtxusechg = (GRobjid *) om$malloc(size = this_nm->numvtxusechg
			    * sizeof(GRobjid));
       this_nm->origedges = (GRobjid *) om$malloc(size = this_nm->numvtxusechg
			    * sizeof(GRobjid));
       this_nm->repledges = (GRobjid *) om$malloc(size = this_nm->numvtxusechg
			    * sizeof(GRobjid));
       EMerr_hndlr(!this_nm->vtxusechg || !this_nm->origedges || 
		   !this_nm->repledges, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
      }
     for(j=0; j<this_nm->numvtxusechg; j++)
      {
       this_nm->vtxusechg[j] = ME.NMnonmanigm->ids[ids_idx++];
       sts = om$is_objid_valid(objid = this_nm->vtxusechg[j]);
       if(sts != OM_S_SUCCESS)
        {
         sts = OM_S_SUCCESS;
         this_nm->vtxusechg[j] = NULL_OBJID;
        }
       if(!(1&sts)) goto wrapup;
      }

     for(j=0; j<this_nm->numvtxusechg; j++)
      {
       this_nm->origedges[j] = ME.NMnonmanigm->ids[ids_idx++];
       sts = om$is_objid_valid(objid = this_nm->origedges[j]);
       if(sts != OM_S_SUCCESS)
        {
         sts = OM_S_SUCCESS;
         this_nm->origedges[j] = NULL_OBJID;
        }
       if(!(1&sts)) goto wrapup;
      }

     for(j=0; j<this_nm->numvtxusechg; j++)
      {
       this_nm->repledges[j] = ME.NMnonmanigm->ids[ids_idx++];
       sts = om$is_objid_valid(objid = this_nm->repledges[j]);
       if(sts != OM_S_SUCCESS)
        {
         sts = OM_S_SUCCESS;
         this_nm->repledges[j] = NULL_OBJID;
        }
       if(!(1&sts)) goto wrapup;
      }


     this_nm->numvtxusetr = ME.NMnonmanigm->num[num_idx++];
     if(this_nm->numvtxusetr)
      {
       this_nm->vtxusetr = (GRobjid *) om$malloc(size = this_nm->numvtxusetr
			    * sizeof(GRobjid));
       this_nm->origvtx = (GRobjid *) om$malloc(size = this_nm->numvtxusetr
			    * sizeof(GRobjid));
       this_nm->replvtx = (GRobjid *) om$malloc(size = this_nm->numvtxusetr
			    * sizeof(GRobjid));
       EMerr_hndlr(!this_nm->vtxusetr || !this_nm->origvtx || 
		   !this_nm->replvtx, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
      }
     for(j=0; j<this_nm->numvtxusetr; j++)
      {
       this_nm->vtxusetr[j] = ME.NMnonmanigm->ids[ids_idx++];
       sts = om$is_objid_valid(objid = this_nm->vtxusetr[j]);
       if(sts != OM_S_SUCCESS)
        {
         sts = OM_S_SUCCESS;
         this_nm->vtxusetr[j] = NULL_OBJID;
        }
       if(!(1&sts)) goto wrapup;
      }

     for(j=0; j<this_nm->numvtxusetr; j++)
      {
       this_nm->origvtx[j] = ME.NMnonmanigm->ids[ids_idx++];
       sts = om$is_objid_valid(objid = this_nm->origvtx[j]);
       if(sts != OM_S_SUCCESS)
        {
         sts = OM_S_SUCCESS;
         this_nm->origvtx[j] = NULL_OBJID;
        }
       if(!(1&sts)) goto wrapup;
      }

     for(j=0; j<this_nm->numvtxusetr; j++)
      {
       this_nm->replvtx[j] = ME.NMnonmanigm->ids[ids_idx++];
       sts = om$is_objid_valid(objid = this_nm->replvtx[j]);
       if(sts != OM_S_SUCCESS)
        {
         sts = OM_S_SUCCESS;
         this_nm->replvtx[j] = NULL_OBJID;
        }
       if(!(1&sts)) goto wrapup;
      }


     this_nm->numedcon = ME.NMnonmanigm->num[num_idx++];
     if(this_nm->numedcon)
      {
       this_nm->edcon = (GRobjid *) om$malloc(size = this_nm->numedcon *
		         sizeof(GRobjid));
       EMerr_hndlr(!this_nm->edcon, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
       this_nm->nmedgescon = (GRobjid *) om$malloc(size = this_nm->numedcon *
		        sizeof(GRobjid));
       EMerr_hndlr(!this_nm->nmedgescon, *EMmsg, EMS_E_NoDynamicMemory,wrapup);
      }

     for(j=0; j<this_nm->numedcon; j++)
      {
       this_nm->edcon[j] = ME.NMnonmanigm->ids[ids_idx++];
       sts = om$is_objid_valid(objid = this_nm->edcon[j]);
       if(sts != OM_S_SUCCESS)
        {
         sts = OM_S_SUCCESS;
         this_nm->edcon[j] = NULL_OBJID;
        }
       if(!(1&sts)) goto wrapup;
      }

     for(j=0; j<this_nm->numedcon; j++)
      {
       this_nm->nmedgescon[j] = ME.NMnonmanigm->ids[ids_idx++];
       sts = om$is_objid_valid(objid = this_nm->nmedgescon[j]);
       if(sts != OM_S_SUCCESS)
        {
         sts = OM_S_SUCCESS;
         this_nm->nmedgescon[j] = NULL_OBJID;
        }
       if(!(1&sts)) goto wrapup;
      }

     this_nm->numeddiscon = ME.NMnonmanigm->num[num_idx++];
     if(this_nm->numeddiscon)
      {
       this_nm->eddiscon = (GRobjid *) om$malloc(size = this_nm->numeddiscon *
		            sizeof(GRobjid));
       EMerr_hndlr(!this_nm->eddiscon, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
       this_nm->nmedgesdiscon = (GRobjid *) om$malloc(size = 
		this_nm->numeddiscon * sizeof(GRobjid));
       EMerr_hndlr(!this_nm->nmedgesdiscon, *EMmsg, EMS_E_NoDynamicMemory, 
		wrapup);
      }

     for(j=0; j<this_nm->numeddiscon; j++)
      {
       this_nm->eddiscon[j] = ME.NMnonmanigm->ids[ids_idx++];
       sts = om$is_objid_valid(objid = this_nm->eddiscon[j]);
       if(sts != OM_S_SUCCESS)
        {
         sts = OM_S_SUCCESS;
         this_nm->eddiscon[j] = NULL_OBJID;
        }
       if(!(1&sts)) goto wrapup;
      }

     for(j=0; j<this_nm->numeddiscon; j++)
      {
       this_nm->nmedgesdiscon[j] = ME.NMnonmanigm->ids[ids_idx++];
       sts = om$is_objid_valid(objid = this_nm->nmedgesdiscon[j]);
       if(sts != OM_S_SUCCESS)
        {
         sts = OM_S_SUCCESS;
         this_nm->nmedgesdiscon[j] = NULL_OBJID;
        }
       if(!(1&sts)) goto wrapup;
      }


    } /* for(i=0; i<ssi->num_sfs; i++) */

  } /* if(!(options & NMgetssi_NoNmEntities)) */

 if(!(options & NMgetssi_NoNmEdge))
  {
   ssi->num_nmedges = ME.NMnonmanigm->num_nmedges;
   if(ssi->num_nmedges)
    {
     ssi->nmedges = (GRobjid *) om$malloc(size = ssi->num_nmedges * 
		     sizeof(GRobjid));
     EMerr_hndlr(!ssi->nmedges, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
     for(i=0; i<ssi->num_nmedges; i++)
      {
       ssi->nmedges[i] = ME.NMnonmanigm->ids[ids_idx++];
       sts = om$is_objid_valid(objid = ssi->nmedges[i]);
       if(sts != OM_S_SUCCESS)
        {
         sts = OM_S_SUCCESS;
         ssi->nmedges[i] = NULL_OBJID;
        }
       if(!(1&sts)) goto wrapup;
      }
    }
  } /* if(!(options & NMgetssi_NoNmEdge)) */


 if(!(options & NMgetssi_NoVtx))
  {
   ssi->num_vtx = ME.NMnonmanigm->num_vtx;
   if(ssi->num_vtx)
    {
     ssi->vtx = (GRobjid *) om$malloc(size = ssi->num_vtx * sizeof(GRobjid));
     EMerr_hndlr(!ssi->vtx, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
     for(i=0; i<ssi->num_vtx; i++)
      {
       ssi->vtx[i] = ME.NMnonmanigm->ids[ids_idx++];
       sts = om$is_objid_valid(objid = ssi->vtx[i]);
       if(sts != OM_S_SUCCESS)
        {
         sts = OM_S_SUCCESS;
         ssi->vtx[i] = NULL_OBJID;
        }
       if(!(1&sts)) goto wrapup;
      }
    }

  } /* if(!(options & NMgetssi_NoVtx)) */

wrapup:
NMfree_ssi(&locssi);
EMWRAPUP(*EMmsg, sts, "NMnonmanigm.NMget_SSI");
return(sts);
}

end implementation NMnonmanigm;
		
