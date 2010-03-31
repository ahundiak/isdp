/* ###################   APOGEE COMPILED   ################## */
class implementation EMSdpr;

#include "EMSdpr.h"         /*EMSinlist; KNOWN_DEPENDENT; etc.*/
#include "OMmacros.h"

#define INCREMENT 50

extern OMuword OPP_EMSloop_class_id;

IGRlong EFget_ininfo_from_lpinfo(EMmsg, num_surfs, num_reg_in, num_reg_out,
                                 reg_in, reg_out, inlist, osnum, options)
IGRlong           *EMmsg; 
IGRint            num_surfs;
IGRint            *num_reg_in, *num_reg_out;
GRobjid           *reg_in, *reg_out;
OMuword           osnum;
struct EMSinlist  *inlist; 

IGRushort options;
/*
Description
    This message will fill the inlist with in information relative to loops.

Return Values    
    EMSS_S_Success if all is well.

Notes

History
    SM  06/18/93    Handle one or more inputs being NULL. For example if
                    a DPR node never adds any loops, the input argument 
                    'reg_in' can be NULL.
    DLB 05/29/91    In order to speed up EFgetedarmu loop thru the lpin/lpout
                    list for each surface.
    DLB 05/22/91    Support new options.
    DLB 05/13/91    Was not asking for resulting edges which are really the
                    same as added edges.
    DLB 01/25/91    Creation.
*/
{
  IGRlong                 OM_stat=OM_S_SUCCESS;
  IGRint                  num_lp_in=0, num_add=0, num_mod=0,
                          *num_res=0, total_res=0, total_add = 0, ii;
  GRobjid                 *add=NULL, *res=NULL;
  void                    EFgetEdgesAddRemModUnchg();
  void                    EFalloc_list();


  *EMmsg = EMS_S_Success;

  /* Following check is asenine for this function. But what the hell, I am
     in a conservative mood after all the NULL pointer references I have
     seen.
  */
  if(!inlist) goto wrapup; 


  /*Get the total number of added/removed loops.*/
  for(ii=0; ii<num_surfs; ii++)  
   if(num_reg_in)
    num_lp_in += num_reg_in[ii];
    
  if (num_lp_in)
  {
    if (!(options & EMget_in_inf_NO_LOOPS) && reg_in)
    {
      EFalloc_list(EMmsg, &inlist->lplist.loop_ids, inlist->lplist.num_loops,
                   &inlist->lplist.array_size, num_lp_in, INCREMENT, NULL);
      if (!(1 & *EMmsg)) goto wrapup;

      /*Now add the loops in.*/
      OM_BLOCK_MOVE(reg_in, 
                    &inlist->lplist.loop_ids[inlist->lplist.num_loops],
                    num_lp_in * sizeof(GRobjid));                
      inlist->lplist.num_loops += num_lp_in;
    }

    if (!((options & EMget_in_inf_NO_EDGES) ||
          (options & EMget_in_inf_NO_EDGES_FROM_LOOPS)))
    {
      /*Now get and add new edges.*/
      OMuint jj;
      GRobjid *curr_reg_in = NULL, *curr_reg_out = NULL;

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
	
        EFgetEdgesAddRemModUnchg(EMmsg,
                                 in_valid ? num_reg_in[ii] : NULL,  
                                 in_valid ? curr_reg_in : NULL,
                                 out_valid ? num_reg_out[ii] : NULL, 
                                 out_valid ? curr_reg_out : NULL,
                                 &num_add,   &add,
                                 NULL,       NULL,
                                 &num_mod,   NULL,          
                                 &num_res,   &res,
                                 NULL,       NULL,
                                 osnum);
        if (!(1 & *EMmsg)) goto wrapup;
    
        for(jj=0; jj<num_mod; jj++)
         if(num_res)
          total_res += num_res[jj];
    
        total_add = num_add + total_res;
   
        if (total_add)
        {
          EFalloc_list(EMmsg, &inlist->edlist.edge_ids,
                       inlist->edlist.num_edges, 
                       &inlist->edlist.array_size, total_add, INCREMENT, NULL);
          if (!(1 & *EMmsg)) goto wrapup;
    
          /*And finally add the new edges.*/
          if (num_add && add)
          {
            OM_BLOCK_MOVE(add,
                          &inlist->edlist.edge_ids[inlist->edlist.num_edges],
                          num_add * sizeof(GRobjid));
            inlist->edlist.num_edges += num_add;
          }
  
          if (total_res && res)
          {
            OM_BLOCK_MOVE(res,
                          &inlist->edlist.edge_ids[inlist->edlist.num_edges],
                          total_res * sizeof(GRobjid));
            inlist->edlist.num_edges += total_res;
          }
        }

        if (add)
        {
          om$dealloc(ptr = add);
          num_add = 0;
          add = NULL;
        }

        if (num_res)
        {
          om$dealloc(ptr = num_res);
          num_res = NULL;
        }
          
        if (res)
        {
          om$dealloc(ptr = res);
          res = NULL;
        }
        num_mod = total_res = 0;        

        if(curr_reg_in && num_reg_in)
         curr_reg_in += num_reg_in[ii];

        if(curr_reg_out && num_reg_out)
         curr_reg_out += num_reg_out[ii];
      }
    }
  }

wrapup:
  if (add) om$dealloc(ptr = add);
  if (num_res) om$dealloc(ptr = num_res);
  if (res) om$dealloc(ptr = res);
  EMWRAPUP(*EMmsg, OM_stat, "EFget_ininfo_from_lpinfo")
  return(OM_stat);
}
end implementation EMSdpr;
