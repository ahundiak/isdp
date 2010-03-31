/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI   COMPILED   ################## */
class implementation EMSdpr;

#include "emsdef.h"     
#include "EMSdpr.h"
#include "EMSopt.h"
#include "OMmacros.h"

#if DEBUG
#include "stdio.h"
#endif

from EMSsurface import EMmatch_geometry;
from EMSboundary import EMmatch_topology;

extern OMuint OM_Gf_verbose_warning;

IGRlong EFmatch_surfs_added(EMmsg,
                            old_num_surfs,
                            old_surfs,
                            new_num_surfs,
                            new_surfs,
                            osnum,
                            options,
                            env)
IGRlong           *EMmsg;
IGRint            old_num_surfs;
GRobjid           *old_surfs;
IGRint            new_num_surfs;
GRobjid           *new_surfs;
OMuword           osnum;
IGRushort options;
struct GRmd_env   *env;
/*
Description
    Topology and geometry tag matching code on surfaces added.

Return values
    EMSS_S_Success if match succeeds.
    EMSI_I_Fail id match fails.

History
    10/14/91    DLB Pass DONT_ORIENT option since orientation should ALWAYS
                    be correct for added geometry of a dpr operation.
    09/05/91    DLB Add env param.
    02/18/91    DLB If match fails, be sure to add rhs surfs to r-tree.
    02/12/91    DLB Creation.
*/
{
  IGRlong               OM_stat=OM_S_SUCCESS;
  IGRint                ii;
  GRobjid               new_id;
  IGRushort     match_options;
  IGRboolean            match_failed=FALSE;


  *EMmsg = EMS_S_Success;

  match_options = EMstore_opt_DONT_DISPLAY;

  if (old_num_surfs != new_num_surfs)
  {
   /*old and new count mismatch*/
    match_failed = TRUE;
    match_options |= EMstore_opt_MATCH_FAILED;

    if (OM_Gf_verbose_warning)
    {
      fprintf(stderr, "Mismatch: old # added surfs %d, new added surfs %d\n",
              old_num_surfs, new_num_surfs);
    }
  }    

  for(ii=0; ii<old_num_surfs; ii++)
  {
    new_id = match_failed ? NULL_OBJID : new_surfs[ii];
    OM_stat = om$send(msg = message EMSsurface.EMmatch_geometry(EMmsg,
                            match_options | EMstore_opt_DONT_ORIENT,
                            env, new_id),
                      senderid = NULL_OBJID,
                      targetid = old_surfs[ii],
                      targetos = osnum);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  }

  if (match_failed) *EMmsg = EMS_I_Fail;

wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "EFmatch_surfs_added")
  return(OM_stat);
}                            


IGRlong EFmatch_comps_surfs(EMmsg,
                            old_num_comps,
                            old_comps,
                            new_num_comps,
                            new_comps,
                            old_num_surfs_out,
                            old_surfs_out,
                            new_num_surfs_out,
                            new_surfs_out,
                            options)
IGRlong           *EMmsg;
IGRint            old_num_comps;
GRobjid           *old_comps;
IGRint            new_num_comps;
GRobjid           *new_comps;
IGRint            *old_num_surfs_out;
GRobjid           *old_surfs_out;
IGRint            *new_num_surfs_out;
GRobjid           *new_surfs_out;
IGRushort options;
/*
Description
    Topology and geometry tag matching code on composite and surface_out.

Return values
    EMSS_S_Success if match succeeds.
    EMSI_I_Fail id match fails.

History
    03/25/91    DLB Don't error out if out surf ids don't match.
    02/01/91    DLB Creation.
*/
{
  IGRlong               OM_stat=OM_S_SUCCESS;
  IGRint                ii, jj;
  GRobjid               *old_id, *id;
  IGRboolean            match_failed=FALSE;


  *EMmsg = EMS_S_Success;
 
  if (old_num_comps != new_num_comps)
  {
    /*Num composite mod mismatch*/
    match_failed = TRUE;

    if (OM_Gf_verbose_warning) 
    {
      fprintf(stderr, "Mismatch: old # comp %d, new # comp %d\n",
              old_num_comps, new_num_comps);
    }
  }
  else
  {
    /*First compare composite ids and removed surface ids.*/
    old_id = old_surfs_out;
    id = new_surfs_out;
    for(ii=0; ii<old_num_comps; ii++)
    {
      if (old_comps[ii] != new_comps[ii] ||
          old_num_surfs_out[ii] != new_num_surfs_out[ii])
      {
        /*Composite mod id or # surf out mismatch*/
        match_failed = TRUE;
      }
      else
      {
        for(jj=0; jj<old_num_surfs_out[ii]; jj++, old_id++, id++)
        {
          if (*old_id != *id)
          {
            /*Surface out id mismatch*/
            if (OM_Gf_verbose_warning)             
            {
              fprintf(stderr, "Mismatch:  old sf out %d, newsf out %d\n\n",
                      *old_id, *id); 
            }
            break;
          }
        }
      }
      if (match_failed)
      {
        /*Composite id or surface out id mismatch*/
        if (OM_Gf_verbose_warning) 
        {
          fprintf(stderr, "Mismatch: old comp %d, new comp %d\n",
                  old_comps[ii], new_comps[ii]);
          fprintf(stderr, "Mismatch: old #sf out %d, new #sf out %d\n",
                  old_num_surfs_out[ii], new_num_surfs_out[ii]);
        }
        break;
      }     
    }     
  }

  if (match_failed) *EMmsg = EMS_I_Fail;

  EMWRAPUP(*EMmsg, OM_stat, "EFmatch_comps_surfs")
  return(OM_stat);
}


IGRlong EFmatch_surfs_loops(EMmsg,
                            old_num_surfs,
                            old_surfs,
                            new_num_surfs,
                            new_surfs,
                            old_num_lps_out,
                            old_lps_out,
                            new_num_lps_out,
                            new_lps_out,
                            old_num_lps_in,
                            old_lps_in,
                            new_num_lps_in,
                            new_lps_in,
                            osnum, options)
IGRlong           *EMmsg;
IGRint            old_num_surfs;
GRobjid           *old_surfs;
IGRint            new_num_surfs;
GRobjid           *new_surfs;
IGRint            *old_num_lps_out;
GRobjid           *old_lps_out;
IGRint            *new_num_lps_out;
GRobjid           *new_lps_out;
IGRint            *old_num_lps_in;
GRobjid           *old_lps_in;
IGRint            *new_num_lps_in;
GRobjid           *new_lps_in;
OMuword           osnum;
IGRushort options;
/*
Description
    Topology and geometry tag matching code on surfs mod and loops in/out.

Return values
    EMSS_S_Success if match succeeds.
    EMSI_I_Fail id match fails.

History
    02/01/91    DLB Creation.
*/
{
  IGRlong               OM_stat=OM_S_SUCCESS;
  IGRint                ii, jj;
  GRobjid               *old_id, *id, new_id;
  IGRushort     EMstore_options=NULL; 
  IGRboolean            match_failed;


  *EMmsg = EMS_S_Success;

  old_id = old_lps_out;
  id = new_lps_out;

  match_failed = options & EMstore_opt_MATCH_FAILED;

  if (!match_failed)
  {
    if (old_num_surfs != new_num_surfs)
    {
      /*# surfaces mod mismatch!!*/
      match_failed = TRUE;

      if (OM_Gf_verbose_warning) 
      {
        fprintf(stderr, "Mismatch: old # sf %d, new # sf %d\n\n",
                old_num_surfs, new_num_surfs);
      }
    }

    if (!match_failed)
    {
      /*Compare surfaces mod and loops out.*/
      for(ii=0; ii<old_num_surfs; ii++)
      {
        if (old_surfs[ii] != new_surfs[ii])
        {
          /*Surface mod id mismatch!!*/
          if (OM_Gf_verbose_warning)
          {
            fprintf(stderr, "Mismatch: old sf mod %d, new sf mod %d\n",
                    old_surfs[ii], new_surfs[ii]);
          }
          match_failed = TRUE;
          break;
        }
  
        if (old_num_lps_out[ii] != new_num_lps_out[ii])
        {
          /*# loop out mismatch!!*/
          if (OM_Gf_verbose_warning)
          {
            fprintf(stderr, "Mismatch: old # loop out %d, new # loop out %d\n",
                    old_num_lps_out[ii], new_num_lps_out[ii]);
          }
        }
  
        for(jj=0; jj<old_num_lps_out[ii]; jj++, old_id++, id++)
        {
          if (*old_id != *id)
          {
            if (OM_Gf_verbose_warning)
              fprintf(stderr, "Mismatch: old lp out %d, new lp out %d\n",
                      *old_id, *id);
             break;
          }
        }
        if (match_failed) break;
      }
    }
  }

  /*Now match loops in*/
  old_id = old_lps_in;
  id = new_lps_in;

  for(ii=0; ii<old_num_surfs; ii++)
  {
    if (!match_failed)
    {
      if (old_num_lps_in[ii] != new_num_lps_in[ii])
      {
        if (OM_Gf_verbose_warning)
        {
          fprintf(stderr, "Mismatch: old # lp in %d, new # lp in %d\n",
                  old_num_lps_in[ii], new_num_lps_in[ii]);
        }
        match_failed = TRUE;
      }
    }

    if (match_failed) EMstore_options = EMstore_opt_MATCH_FAILED;

    for(jj=0; jj<old_num_lps_in[ii]; jj++, old_id++, id++)
    {
      new_id = match_failed ? NULL_OBJID : *id;
      OM_stat = om$send(msg = message EMSboundary.EMmatch_topology(EMmsg,
                              EMstore_options, NULL, new_id),
                        senderid = NULL_OBJID,
                        targetid = *old_id,
                        targetos = osnum);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;
    }
  }

  if (match_failed) *EMmsg = EMS_I_Fail;

wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "EFmatch_surfs_loops")
  return(OM_stat);
}


IGRlong EFmatch_loops_edges(EMmsg,
                            num_lps,
                            lps,
                            old_num_eds_out,
                            old_eds_out,
                            new_num_eds_out,
                            new_eds_out,
                            old_num_eds_in,
                            old_eds_in,
                            new_num_eds_in,
                            new_eds_in,
                            osnum, options)
IGRlong           *EMmsg;
IGRint            num_lps;
GRobjid           *lps;
IGRint            old_num_eds_out;
GRobjid           *old_eds_out;
IGRint            new_num_eds_out;
GRobjid           *new_eds_out;
IGRint            *old_num_eds_in;
GRobjid           *old_eds_in;
IGRint            *new_num_eds_in;
GRobjid           *new_eds_in;
OMuword           osnum;
IGRushort options;
/*
Description
    Topology and geometry tag matching code on loopss mod and edges in/out.

Return values
    EMSS_S_Success if match succeeds.
    EMSI_I_Fail id match fails.

History
    02/01/91    DLB Creation.
*/
{
  IGRlong               OM_stat=OM_S_SUCCESS;
  IGRint                ii, jj;
  GRobjid               *old_id, *id, new_id;
  IGRushort     EMstore_options=NULL; 
  IGRboolean            match_failed;


  *EMmsg = EMS_S_Success;

  match_failed = options & EMstore_opt_MATCH_FAILED;

  /*Now match edges in*/
  old_id = old_eds_in;
  id = new_eds_in;

  for(ii=0; ii<old_num_eds_out; ii++)
  {
    if (!match_failed)
    {
      if (old_num_eds_in[ii] != new_num_eds_in[ii])
      {
        if (OM_Gf_verbose_warning)
        {
          fprintf(stderr, "Mismatch: old # ed in %d, new # ed in %d\n",
                  old_num_eds_in[ii], new_num_eds_in[ii]);
        }
        match_failed = TRUE;
      }
    }

    if (match_failed) EMstore_options = EMstore_opt_MATCH_FAILED;

    for(jj=0; jj<old_num_eds_in[ii]; jj++, old_id++, id++)
    {
      new_id = match_failed ? NULL_OBJID : *id;
      OM_stat = om$send(msg = message EMSboundary.EMmatch_topology(EMmsg,
                              EMstore_options , NULL, new_id),
                        senderid = NULL_OBJID,
                        targetid = *old_id,
                        targetos = osnum);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;
    }
  }

  if (match_failed) *EMmsg = EMS_I_Fail;

wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "EFmatch_loops_edges")
  return(OM_stat);
}
end implementation EMSdpr;
