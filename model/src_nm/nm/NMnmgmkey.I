/*
This node can create 

 1)NM feature loops 
 2) The edges in a feature loop
 3) Can put in some edges in place of some edge taken out.
 4) NMvertex_uses
 5) NMedges
 6) NMvertices.

keying mechanism -

key[0] - the surface modified (for 1 thru 4 this is the surface on which
the element was created. For 4 thru 6 this is the nm node which created the
element)
key[1] - element added by this node.

*/
class implementation NMnonmanigm;

#include "OMmacros.h"
#include "EMSkey.h"

#ifndef DEBUG
#define DEBUG 0
#endif

from EMSboundary import EMget_put_creator_id;
from NMcreated import NMget_put_creator_id;

extern OMuword OPP_EMSboundary_class_id, OPP_NMcreated_class_id;
extern OMuint OM_Gf_verbose_warning;

method EMtranslate_id_key(IGRlong *EMmsg; 
                          unsigned int options;
                          struct GRmd_env *md_env;
                          GRobjid *component_objid;
                          IGRint *key_size;
                          IGRchar **key)
{
 IGRlong		sts = OM_S_SUCCESS;
 GRobjid		creatorid;
 IGRint			i, j, numedsin = 0;
 IGRboolean		bingo = FALSE;
 struct EMSkey		lockey[2];
 struct NMentities	*this_nm = NULL;
 struct NMgmSSI		ssi;
 
 *EMmsg = EMS_S_Success;
 NMinit_ssi(&ssi);

 for(i=0; i<2; i++)
  {
   lockey[i].chan_count = 0;
   lockey[i].chan_index = 0;
   lockey[i].sub_item_type = NMkey_Unknown;
  }

 sts = om$send(msg = message NMnonmanigm.NMget_SSI(EMmsg, &ssi, 
         NMgetssi_cache), targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;

 /* Visit all the feature loops/edges created by me.
 */
 if(options & EMS_OPT_KEY_FROM_ID)   
  {
   /* We know that any element created by this node will always have
      exactly 2 key counts. So if only the size is desired, return it.
   */
   if(key_size && !key)
    {
     *key_size = 2 * sizeof(struct EMSkey);
     goto wrapup;
    }


   if(EFisAncestryValid(EMmsg, *component_objid, OM_Gw_current_OS, 
      OPP_EMSboundary_class_id, TRUE))
    {
     sts = om$send(msg = message EMSboundary.EMget_put_creator_id(EMmsg, 
           &creatorid, FALSE), targetid = *component_objid);
     if(!(1&*EMmsg&sts)) goto wrapup;
    }
   else if(EFisAncestryValid(EMmsg, *component_objid, OM_Gw_current_OS, 
           OPP_NMcreated_class_id, TRUE))
    {
     sts = om$send(msg = message NMcreated.NMget_put_creator_id(EMmsg, 
           &creatorid, FALSE), targetid = *component_objid);
     if(!(1&*EMmsg&sts)) goto wrapup;
    }
   else
    {
     *EMmsg = EMS_E_InvalidArg;
     goto wrapup;
    }

   /* If I am not the creator, why did this message come to me? Untill I find
      out, returning an error.
   */
   EMerr_hndlr(!IF_EQ_OBJID(creatorid, my_id), *EMmsg, EMS_E_InvalidSend,
               wrapup);

   lockey[0].sub_item_type = NMkey_Surface;
   lockey[0].chan_count = (unsigned short) ssi.num_sfs;

   for(i=0; i<ssi.num_sfs; i++)
    {
     this_nm = &ssi.nmentities[i];
     lockey[0].chan_index = (unsigned short) i;

     lockey[1].sub_item_type = NMkey_FeatureLp;
     lockey[1].chan_count = (unsigned short) this_nm->num_flps;

     for(j=0; j<this_nm->num_flps; j++)
      {
       lockey[1].chan_index = (unsigned short) j;
       if(IF_EQ_OBJID(*component_objid, this_nm->flps[j]))
        {
	 bingo = TRUE;
	 break;
        }
      }
     if(bingo) break;

     lockey[1].sub_item_type = NMkey_CreatedEdge;
     lockey[1].chan_count = (unsigned short) this_nm->num_edges;
     for(j=0; j<this_nm->num_edges; j++)
      {
       lockey[1].chan_index = (unsigned short) j;
       if(IF_EQ_OBJID(*component_objid, this_nm->edges[j]))
        {
	 bingo = TRUE;
	 break;
        }
      }
     if(bingo) break;

     numedsin = 0;
     for(j=0; j<this_nm->numedgesout; j++)
      numedsin += this_nm->numedgesin[j];

     lockey[1].sub_item_type = NMkey_ReplacementEdge;
     lockey[1].chan_count = (unsigned short) numedsin;

     for(j=0; j<numedsin; j++)
      {
       lockey[1].chan_index = (unsigned short) j;
       if(IF_EQ_OBJID(*component_objid, this_nm->edgesin[j]))
        {
	 bingo = TRUE;
	 break;
        }
      }
     if(bingo) break;

     lockey[1].sub_item_type = NMkey_NMvertex_use;
     lockey[1].chan_count = (unsigned short) this_nm->num_vtxuses;

     for(j=0; j<this_nm->num_vtxuses; j++)
      {
       lockey[1].chan_index = (unsigned short) j;
       if(IF_EQ_OBJID(*component_objid, this_nm->vtxuses[j]))
        {
	 bingo = TRUE;
	 break;
        }
      }
     if(bingo) break;

    } /* for(i=0; i<ssi.num_sfs; i++) */


   /* Check if it is a NMedge.
   */
   if(!bingo)
    {
     lockey[0].sub_item_type = NMkey_NMnode;
     lockey[0].chan_count = 0;
     lockey[0].chan_index = 0;

     lockey[1].sub_item_type = NMkey_NMedge;
     lockey[1].chan_count = (unsigned short) ssi.num_nmedges;
     for(j=0; j<ssi.num_nmedges; j++)
      {
       lockey[1].chan_index = (unsigned short) j;
       if(IF_EQ_OBJID(*component_objid, ssi.nmedges[j]))
        {
         bingo = TRUE;
         break;
        }
      }
    }

   /* Check if it is a NMvertex.
   */
   if(!bingo)
    {
     lockey[1].sub_item_type = NMkey_NMvertex;
     lockey[1].chan_count = (unsigned short) ssi.num_vtx;
     for(j=0; j<ssi.num_vtx; j++)
      {
       lockey[1].chan_index = (unsigned short) j;
       if(IF_EQ_OBJID(*component_objid, ssi.vtx[j]))
        {
         bingo = TRUE;
         break;
        }
      }
    }
   EMerr_hndlr(!bingo, *EMmsg, EMS_E_Fail, wrapup);


   if(key)
    {
     struct EMSkey *locptr = NULL;

     if(!*key)
      {
       locptr = (struct EMSkey *) om$malloc(size = 2 * sizeof(struct EMSkey));
       EMerr_hndlr(!locptr, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
       *key = (IGRchar *) locptr;
      }
     else locptr = (struct EMSkey *) *key;
     OM_BLOCK_MOVE(lockey, locptr, 2 * sizeof(struct EMSkey));
    }
   if(key_size) *key_size = 2 * sizeof(struct EMSkey);

  } /* if(options & EMS_OPT_KEY_FROM_ID) */

 else if(options & EMS_OPT_ID_FROM_KEY)
  {
   struct EMSkey *locptr;
   
   *component_objid = NULL_OBJID;
   EMerr_hndlr(*key_size != 2 * sizeof(struct EMSkey), *EMmsg, 
	       EMS_E_InvalidArg, wrapup);
   locptr = (struct EMSkey *) *key;



   /* If the first key is not for a surface modified, or if the surface
      index coming in is greater than total number of surfaces modified
      signal a mismatch and quit.
      If there is a total count mismatch between the number of surfaces
      modified, signal a topology mismatch.
   */

   if(locptr[0].sub_item_type == NMkey_Surface)
    {
     if( ((int)(locptr[0].chan_index) > (ssi.num_sfs - 1)) ||
         ((int)(locptr[0].chan_count) != ssi.num_sfs))
      {
       if(OM_Gf_verbose_warning)
        fprintf(stderr, "Possible Topology Mismatch1\n");
       *EMmsg = EMS_I_Fail;
       goto wrapup;
      }
    }
   else if(locptr[0].sub_item_type != NMkey_NMnode)
    {
     if(OM_Gf_verbose_warning)
      fprintf(stderr, "Possible Topology Mismatch1\n");
     *EMmsg = EMS_I_Fail;
     goto wrapup;
    }


   if(locptr[0].sub_item_type == NMkey_Surface)
    {
     this_nm = &ssi.nmentities[(int)(locptr[0].chan_index)];

     if(locptr[1].sub_item_type == NMkey_FeatureLp)
      {
       if(((int)(locptr[1].chan_index) > (this_nm->num_flps - 1)) ||
          ((int)(locptr[1].chan_count) != this_nm->num_flps))
        {
         if(OM_Gf_verbose_warning)
          fprintf(stderr, "Possible Topology Mismatch2\n");
         *EMmsg = EMS_I_Fail;
         goto wrapup;
        }

       *component_objid = this_nm->flps[(int)(locptr[1].chan_index)];
      }
     else if(locptr[1].sub_item_type == NMkey_CreatedEdge)
      {
       if(((int)(locptr[1].chan_index) > (this_nm->num_edges - 1)) ||
	  ((int)(locptr[1].chan_count) != this_nm->num_edges))
        {
         if(OM_Gf_verbose_warning)
          fprintf(stderr, "Possible Topology Mismatch3\n");
         *EMmsg = EMS_I_Fail;
         goto wrapup;
        }

       *component_objid = this_nm->edges[(int)(locptr[1].chan_index)];
      }
     else if(locptr[1].sub_item_type == NMkey_ReplacementEdge)
      {
       numedsin = 0;
       for(j=0; j<this_nm->numedgesout; j++)
        numedsin += this_nm->numedgesin[j];

       if( ((int)(locptr[1].chan_index) > (numedsin - 1)) ||
	   ((int)(locptr[1].chan_count) != numedsin))
        {
         if(OM_Gf_verbose_warning)
          fprintf(stderr, "Possible Topology Mismatch4\n");
         *EMmsg = EMS_I_Fail;
         goto wrapup;
        }
       *component_objid = this_nm->edgesin[(int)(locptr[1].chan_index)];
      }
     else if(locptr[1].sub_item_type == NMkey_NMvertex_use)
      {
       if(((int)(locptr[1].chan_index) > (this_nm->num_vtxuses - 1)) ||
	  ((int)(locptr[1].chan_count) != this_nm->num_vtxuses))
        {
         if(OM_Gf_verbose_warning)
          fprintf(stderr, "Possible Topology Mismatch5\n");
         *EMmsg = EMS_I_Fail;
         goto wrapup;
        }

       *component_objid = this_nm->vtxuses[(int)(locptr[1].chan_index)];
      }
     else
      {
       *EMmsg = EMS_E_InvalidArg;
       goto wrapup;
      }
    }
   else if(locptr[0].sub_item_type == NMkey_NMnode)
    {
     if(locptr[1].sub_item_type == NMkey_NMedge)
      {
       if(((int)(locptr[1].chan_index) > (ssi.num_nmedges - 1)) ||
	  ((int)(locptr[1].chan_count) != ssi.num_nmedges))
        {
         if(OM_Gf_verbose_warning)
          fprintf(stderr, "Possible Topology Mismatch6\n");
         *EMmsg = EMS_I_Fail;
         goto wrapup;
        }
       *component_objid = ssi.nmedges[(int)(locptr[1].chan_index)];
      }
     else if(locptr[1].sub_item_type == NMkey_NMvertex)
      {
       if(((int)(locptr[1].chan_index) > (ssi.num_vtx - 1)) ||
	  ((int)(locptr[1].chan_count) != ssi.num_vtx))
        {
         if(OM_Gf_verbose_warning)
          fprintf(stderr, "Possible Topology Mismatch7\n");
         *EMmsg = EMS_I_Fail;
         goto wrapup;
        }
       *component_objid = ssi.vtx[(int)(locptr[1].chan_index)];
      }
     else
      {
       *EMmsg = EMS_E_InvalidArg;
       goto wrapup;
      }
    
    }


   if(EFisAncestryValid(EMmsg, *component_objid, OM_Gw_current_OS, 
       OPP_EMSboundary_class_id, FALSE))
    {
     sts = om$send(msg = message EMSboundary.EMget_put_creator_id(EMmsg, 
           &creatorid, FALSE), targetid = *component_objid);
     if(!(1&*EMmsg&sts)) goto wrapup;
    }
   else if(EFisAncestryValid(EMmsg, *component_objid, OM_Gw_current_OS, 
        OPP_NMcreated_class_id, FALSE))
    {
     sts = om$send(msg = message NMcreated.NMget_put_creator_id(EMmsg, 
           &creatorid, FALSE), targetid = *component_objid);
     if(!(1&*EMmsg&sts)) goto wrapup;
    }


   /* If I am not the creator, why did this message come to me? Untill I find
      out, returning an error.
   */
   EMerr_hndlr(!IF_EQ_OBJID(creatorid, my_id), *EMmsg, EMS_E_InvalidSend,
               wrapup);

  } /* else if(options & EMS_OPT_ID_FROM_KEY) */
 else
  *EMmsg = EMS_E_InvalidArg;

wrapup:

EMWRAPUP(*EMmsg, sts, "NMnonmanigm.EMtranslate_id_key");
return(sts);
}

end implementation NMnonmanigm;
