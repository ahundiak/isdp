/* ###################   APOGEE COMPILED   ################## */
class implementation EMSdpr;

#include "EMSdpr.h"         /*EMSinlist; KNOWN_DEPENDENT; etc.*/
#include "OMmacros.h"

#define INCREMENT 50

#argsused

extern OMuword OPP_EMSloop_class_id;

IGRlong EFget_outinfo_from_lpinfo(EMmsg, num_comps, num_surfs_out, surfs_out,
                                  num_surfs, surfs, num_reg_in, num_reg_out,
                                  reg_in, reg_out, outlist, osnum, options)
IGRlong           *EMmsg; 
IGRint            num_comps;
IGRint            *num_surfs_out;
GRobjid           *surfs_out;
IGRint            num_surfs;
GRobjid           *surfs;
IGRint            *num_reg_in, 
                  *num_reg_out;
GRobjid           *reg_in, *reg_out;
struct EMSoutlist *outlist; 
OMuword           osnum;
IGRushort options;
/*
Description
    This message will fill the outlist with out information relative to loops.

Return Values    
    EMSS_S_Success if all is well.

Notes

History
    DLB 01/28/91    Creation.
    SM  06/18/93    Handle one or more inputs being NULL. For example if
                    a DPR node never adds any loops, the input argument 
                    'reg_in' can be NULL.
*/
{
  IGRlong                 OM_stat=OM_S_SUCCESS;
  IGRint                  surf_out_cnt=0,
                          num_lp_out=0, num_rem=0, ii; 
  GRobjid                 *rem=NULL, *curr_reg_in = NULL, *curr_reg_out = NULL;
  void                    EFgetEdgesAddRemModUnchg();
  void                    EFalloc_list();


  *EMmsg = EMS_S_Success;

  /* Following check is asenine for this function. But what the hell, I am
     in a conservative mood after all the NULL pointer references I have
     seen.
  */
  if(!outlist) goto wrapup; 

  /*Get the removed surfaces of this node.*/
  for(ii=0; ii<num_comps; ii++) 
   if(num_surfs_out)
    surf_out_cnt += num_surfs_out[ii];

  if (surf_out_cnt && surfs_out)
  {
    EFalloc_list(EMmsg, &outlist->sflist.surf_ids, outlist->sflist.num_surfs,
                 &outlist->sflist.array_size, surf_out_cnt, INCREMENT, NULL);
    if (!(1 & *EMmsg)) goto wrapup;

    /*Now fill the array with the surfaces removed.*/
    OM_BLOCK_MOVE(surfs_out,
                  &outlist->sflist.surf_ids[outlist->sflist.num_surfs],
                  surf_out_cnt * sizeof(GRobjid));
    outlist->sflist.num_surfs += surf_out_cnt;
  }

  if (num_surfs && surfs)
  {
    EFalloc_list(EMmsg, &outlist->sfmodlist.surf_ids,
                 outlist->sfmodlist.num_surfs, 
                 &outlist->sfmodlist.array_size, num_surfs, INCREMENT, NULL);
    if (!(1 & *EMmsg)) goto wrapup;

    /*Now fill the array with the surfaces modified.*/
    OM_BLOCK_MOVE(surfs,
                  &outlist->sfmodlist.surf_ids[outlist->sfmodlist.num_surfs],
                  num_surfs * sizeof(GRobjid));
    outlist->sfmodlist.num_surfs += num_surfs;
  }

  /*Get the total number of added/removed loops.*/
  for(ii=0; ii<num_surfs; ii++)  
   if(num_reg_out)
    num_lp_out += num_reg_out[ii];

    
  if (num_lp_out && reg_out)
  {
    EFalloc_list(EMmsg, &outlist->lplist.loop_ids, outlist->lplist.num_loops,
                 &outlist->lplist.array_size, num_lp_out, INCREMENT, NULL);
    if (!(1 & *EMmsg)) goto wrapup;

    /*Now add the loops out.*/
    OM_BLOCK_MOVE(reg_out, 
                  &outlist->lplist.loop_ids[outlist->lplist.num_loops],
                  num_lp_out * sizeof(GRobjid));                
    outlist->lplist.num_loops += num_lp_out;

    /*Now get and add removed edges.*/
    curr_reg_in = reg_in;
    curr_reg_out = reg_out;
    for(ii=0; ii<num_surfs; ii++)
    {
     IGRboolean in_valid = TRUE, out_valid = TRUE;

     if(curr_reg_in && num_reg_in && *num_reg_in)
      in_valid = EFisAncestryValid(EMmsg, *curr_reg_in, OM_Gw_current_OS, 
	         OPP_EMSloop_class_id, TRUE);
     else in_valid = FALSE;

     if(curr_reg_out && num_reg_out && *num_reg_out)
      out_valid = EFisAncestryValid(EMmsg, *curr_reg_out, OM_Gw_current_OS, 
	         OPP_EMSloop_class_id, TRUE);
     else out_valid = FALSE;

     num_rem = 0;

     EFgetEdgesAddRemModUnchg(EMmsg,
                                 in_valid ? num_reg_in[ii] : NULL,  
                                 in_valid ? curr_reg_in : NULL,
                                 out_valid ? num_reg_out[ii] : NULL, 
                                 out_valid ? curr_reg_out : NULL,
                               NULL,            NULL,
                               &num_rem,        &rem,
                               NULL,            NULL,          
                               NULL,            NULL,
                               NULL,            NULL,
                               osnum);
     if (!(1 & *EMmsg)) goto wrapup;
  
     if (num_rem && rem)
      {
        EFalloc_list(EMmsg,
                     &outlist->edlist.edge_ids,
                     outlist->edlist.num_edges, 
                     &outlist->edlist.array_size, num_rem, INCREMENT, NULL);
        if (!(1 & *EMmsg)) goto wrapup;

        /*And finally add the new edges.*/
        OM_BLOCK_MOVE(rem,
                      &outlist->edlist.edge_ids[outlist->edlist.num_edges],
                      num_rem * sizeof(GRobjid));
        outlist->edlist.num_edges += num_rem;
      }

      if (rem)
      {
        om$dealloc(ptr = rem);
        num_rem = 0;
        rem = NULL;
      }

      if(curr_reg_in && num_reg_in)
       curr_reg_in += num_reg_in[ii];

      if(curr_reg_out && num_reg_out)
       curr_reg_out += num_reg_out[ii];
    }
  }

wrapup:
  if (rem) om$dealloc(ptr = rem);
  EMWRAPUP(*EMmsg, OM_stat, "EFget_outinfo_from_lpinfo")
  return(OM_stat);
}
end implementation EMSdpr;
