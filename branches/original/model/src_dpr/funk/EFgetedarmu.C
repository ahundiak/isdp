/* ###################   APOGEE COMPILED   ################## */
#include "OMminimum.h"
#include "OMmacros.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igetypedef.h"
#include "igrdp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "dp.h"
#include "EMSmsgdef.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSdpr.h"

#define ARRAY_INC 50



void EFgetEdgesAddRemModUnchg(EMmsg,
                              num_lp_in,  lp_in,
                              num_lp_out, lp_out,
                              num_add,    add,
                              num_rem,    rem,
                              num_mod,    mod,
                              num_res,    res,
                              num_unchg,  unchg,
                              lp_os)
IGRlong *EMmsg;
IGRint  num_lp_in;  GRobjid *lp_in;
IGRint  num_lp_out; GRobjid *lp_out;
IGRint  *num_add;   GRobjid **add;
IGRint  *num_rem;   GRobjid **rem;
IGRint  *num_mod;   GRobjid **mod;
IGRint  **num_res;  GRobjid **res;
IGRint  *num_unchg; GRobjid **unchg;
OMuword lp_os;

/*
Description
    This function will return the edges added, removed, modified (and the
    resulting edges due to the modification), and unchanged.  All that is
    required is an array of loops in and out. 

Return Values    
    EMSS_S_Success if all is well.

Notes
    About parameters:
        All parameters except EMmsg, loops in/out and lp_os are returned by
        this function.  The pointers and pointers to pointers should be passed
        as pointing to variables initialized to zero or NULL.  The arrays will
        be allocated using om$malloc and should be freed using om$dealloc.

        For the edges modified, the edges added as a result are returned in
        the resulting array.  Note that these resulting edges are added but
        do not appear in the added edges array.

        lp_os is the object space the loops reside in.

        All of following parameters may be passed as NULL if not wanted:
            num_add,    add,
            num_rem,    rem,
            num_mod,    mod,
            num_res,    res,
            num_unchg,  unchg.

        If the resulting edges are requested, the num_mod parameter must also
        be specified (in order to know the total number of resulting edges).
        If not specified, EMS_E_InvalidArg will be returned.

    Assumptions:
        This function assumes that any edges resulting from a modification 
        will be directly connected to the modified edge (i.e. not split
        multiple times).  This may not be the case if the input loops are 
        gotten from a state that is not the active state.
        
History
    AMD 09/09/91 Initialized num_loops_in if no in_loops are being
                 passed. Also changed stackalloc to alloca.
    DLB 05/31/91 Remember mod edges even if not asked for in order to find
                 added or resulting edges.  This change is for efficiency.
    DLB 05/13/91 Return InvalidArg if asking for res edges and not specifying
                 num_mod. 
    DLB 10/16/90 Mod to handle NULL_OBJID case of lp out (due to top
                 matching).  Also mod to do stack alloc/free.
    DLB 08/14/89 Modified to allow the selective return of all parameters.
    DLB 06/27/89 Creation.
*/
{
  IGRlong           OM_stat=OM_S_SUCCESS;
  OMuint            lp_in_num_ed, lp_out_num_ed;
  OMuint            ii, jj, ed_cnt, count;
  IGRint            local_num_mod=0;
  GRobjid           *lp_in_ed, *lp_out_ed, *local_mod;
  IGRboolean        local_mod_used;
  OMuword           dumosnum;
  OM_S_CHANSELECT   to_comps, to_owner;

  *EMmsg = EMS_S_Success;

  EMmake_chanselect(EMSbd_owner_to_comps, &to_comps);
  EMmake_chanselect(EMSedge_to_owner, &to_owner);  

  lp_in_ed = NULL;
  lp_out_ed = NULL;

  local_mod = NULL;
  local_mod_used = FALSE;
     
  if (res && !mod && !num_mod)
  {
    *EMmsg = EMS_E_InvalidArg;
    goto wrapup;
  }

  /* AMD        9/8/91 */
  if (!lp_in)  num_lp_in = 0;

  /*Get all the edges of the loops in and out.*/

  /*Get total number of in loop edges.*/
  lp_in_num_ed = 0;
  for(ii=0; ii<num_lp_in; ii++)
  {
    OM_stat = om$get_channel_count(objid = lp_in[ii],
                                   p_chanselect = &to_comps,
                                   count = &ed_cnt);
    if (!(1 & OM_stat)) goto wrapup;

    lp_in_num_ed += ed_cnt;
  }

  if (lp_in_num_ed)     /*This should always be true.*/
  {
    lp_in_ed = (GRobjid *) alloca(lp_in_num_ed * sizeof(GRobjid));
    if (!lp_in_ed) {*EMmsg = EMS_E_NoStackMemory; goto wrapup;}  
  }

  /*Now get the in loop edges.*/
  lp_in_num_ed = 0;
  for(ii=0; ii<num_lp_in; ii++)
  {
    OM_stat = om$get_channel_count(objid = lp_in[ii],
                                   p_chanselect = &to_comps,
                                   count = &ed_cnt);
    if (!(1 & OM_stat)) goto wrapup;
    
    for(jj=0; jj<ed_cnt; jj++)
    {
      OM_stat = om$get_objid_at_index(objid = lp_in[ii],
                                      p_chanselect = &to_comps,
                                      index = jj,
                                      objidaddr = &lp_in_ed[lp_in_num_ed++],
                                      osnumaddr = &dumosnum);
      if (!(1 & OM_stat)) goto wrapup;
    }
  }

  lp_out_num_ed = 0;
  for(ii=0; ii<num_lp_out; ii++)
  {
    if (lp_out[ii] == NULL_OBJID) continue;
    OM_stat = om$get_channel_count(objid = lp_out[ii],
                                   p_chanselect = &to_comps,
                                   count = &ed_cnt);
    if (!(1 & OM_stat)) goto wrapup;

    lp_out_num_ed += ed_cnt;
  }
    
  if (lp_out_num_ed)
  {
    lp_out_ed = (GRobjid *) alloca(lp_out_num_ed * sizeof(GRobjid));
    if (!lp_out_ed) {*EMmsg = EMS_E_NoStackMemory; goto wrapup;}  
  }
  
  lp_out_num_ed = 0;
  for(ii=0; ii<num_lp_out; ii++)
  {
    if (lp_out[ii] == NULL_OBJID) continue;    
    OM_stat = om$get_channel_count(objid = lp_out[ii],
                                   p_chanselect = &to_comps,
                                   count = &ed_cnt);
    if (!(1 & OM_stat)) goto wrapup;

    for(jj=0; jj<ed_cnt; jj++)
    {
      OM_stat = om$get_objid_at_index(objid = lp_out[ii],
                                      p_chanselect = &to_comps,
                                      index = jj,
                                      objidaddr = &lp_out_ed[lp_out_num_ed++],
                                      osnumaddr = &dumosnum);
      if (!(1 & OM_stat)) goto wrapup;
    }
  }

  if (!num_mod) num_mod = &local_num_mod;

  /*Process edges...*/

  /*For each out loop edge.*/
  for(ii=0; ii<lp_out_num_ed; ii++)
  {
    /*If the out loop edge has only one owner then skip it.*/
    OM_stat = om$get_channel_count(objid = lp_out_ed[ii],
                                   osnum = lp_os,
                                   p_chanselect = &to_owner,
                                   count = &count);
    if (count == 1) continue;

    for(jj=0; jj<num_lp_in; jj++)
    {
      /*Is it owned by an in loop?*/
      if (EFis_edge_owned_by_edlp(EMmsg, 
                                  lp_out_ed[ii], 
                                  lp_in[jj],
                                  lp_os))
      {
        /*Yes it is.  Now if it is owned directly then this
         * is an unchanged edge else it is a modified edge.
         */
        if (*EMmsg == EMS_I_DirectlyOwned)
        {
          if (unchg)  
          {
            /*This is an unchanged edge.*/
            EFrealloc_if_needed(EMmsg, unchg, *num_unchg, 
                                ARRAY_INC, sizeof(GRobjid));
            if (!(1 & *EMmsg)) goto wrapup;

            (*unchg)[*num_unchg] = lp_out_ed[ii];
            (*num_unchg)++;
          }
        }
        else
        {
          OM_stat = OM_S_SUCCESS;

          if (!mod)
          {
            mod = &local_mod;
            local_mod_used = TRUE;
          }

          /*This is a modified edge.*/
          EFrealloc_if_needed(EMmsg, mod, *num_mod, 
                              ARRAY_INC, sizeof(GRobjid));
          if (!(1 & *EMmsg)) goto wrapup;

          (*mod)[*num_mod] = lp_out_ed[ii];
          (*num_mod)++;
        }                                           
                                         
        /*Go on to next edge.*/
        break;
      }
      else if (!(1 & *EMmsg)) goto wrapup;
    }      
      
    if (jj == num_lp_in)
    {
      if (rem)
      {
        /*This edge is not owned by any in loop so its a removed edge.*/
        EFrealloc_if_needed(EMmsg, rem, *num_rem, 
                            ARRAY_INC, sizeof(GRobjid));
        if (!(1 & *EMmsg)) goto wrapup;
  
        (*rem)[*num_rem] = lp_out_ed[ii];
        (*num_rem)++;
      }
    }
  }

  /*For each in loop edge.*/
  for(ii=0; ii<lp_in_num_ed; ii++)
  {
    /*If the in loop edge has only one owner then it must be an added or
     * resulting edge.
     */
    OM_stat = om$get_channel_count(objid = lp_in_ed[ii],
                                   osnum = lp_os,
                                   p_chanselect = &to_owner,
                                   count = &count);
    if (count != 1)
    {
      for(jj=0; jj<num_lp_out; jj++)
      {
        /*Is it owned by an out loop?*/
        if (lp_out[jj] == NULL_OBJID) continue;
        if (EFis_edge_owned_by_edlp(EMmsg, 
                                    lp_in_ed[ii], 
                                    lp_out[jj],
                                    lp_os)) break;
        else if (!(1 & *EMmsg)) goto wrapup;
      }
    }
    else jj = num_lp_out;

    if (jj == num_lp_out)
    {
      /*No its not so this is either an added edge or an edge resulting from
       * a modified edge (split edge).  Now determine which it is.
       */
          
      /*For each modified edge...*/
      for(jj=0; jj<(*num_mod); jj++)
      {
        /*Is it owned by the in loop edge?*/
        if (EFis_edge_owned_by_edlp(EMmsg,
                                    (*mod)[jj],
                                    lp_in_ed[ii],
                                    lp_os)) break;
      }
      if (jj == *num_mod)
      {
        /*This edge is not the owner of a modified edge so its added.*/
        if (add)
        {
          EFrealloc_if_needed(EMmsg, add, *num_add, 
                              ARRAY_INC, sizeof(GRobjid));
          if (!(1 & *EMmsg)) goto wrapup;

          (*add)[*num_add] = lp_in_ed[ii];
          (*num_add)++;       
        }
      }
    }
  }

  if (res && *num_mod)
  {
    OMuint kk;

    *num_res = (IGRint *) om$malloc(size = *num_mod * sizeof(IGRint));
    if (!*num_res) {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}

    /*For each modified edge...*/
    ed_cnt = 0;
    for(ii=0; ii<*num_mod; ii++)
    {
      (*num_res)[ii] = 0;
      /*For each in loop edge...*/
      for(jj=0; jj<lp_in_num_ed; jj++)
      {
        /*If it is an added edge then know its not a resulting edge.*/
        if (num_add && add && *num_add)
        {
           for(kk=0; kk<*num_add; kk++)
           {
             if ((*add)[kk] == lp_in_ed[jj]) break;
           }
           if (kk != *num_add) continue;    /*Skip this added edge.*/
        }

        /*Is it owned by this in loop edge?*/
        if (EFis_edge_owned_by_edlp(EMmsg,
                                    (*mod)[ii],
                                    lp_in_ed[jj],
                                    lp_os))
        {
          /*Yes, so add this in loop edge to the resulting array.*/
          EFrealloc_if_needed(EMmsg, res, ed_cnt, 
                              ARRAY_INC, sizeof(GRobjid));
          if (!(1 & *EMmsg)) goto wrapup;

          (*res)[ed_cnt++] = lp_in_ed[jj];
          (*num_res)[ii]++;       
        }
        else if (!(1 & *EMmsg)) goto wrapup;
      }
    }
  }
  
  wrapup:
    if (local_mod_used && local_mod) om$dealloc(ptr = local_mod);
    EMWRAPUP(*EMmsg, OM_stat, "EFgetEdgesAddRemModUnchg")
    return;
}
