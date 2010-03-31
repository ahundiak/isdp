/* ###################   APOGEE COMPILED   ################## */
class implementation EMSdpr;

#include "EMSdpr.h"         /*EMSinlist; KNOWN_DEPENDENT*/
#include "memory.h"
#include "emsdef.h"
#include "OMmacros.h"

#define CON_TOP_BUFF_INCR   50

struct EMScon_top
{
  IGRint  num_mod;
  GRobjid *mod;
  IGRint  *num_res;
  GRobjid *res;
  IGRint  num_ed;
  GRobjid *ed;
  IGRint  *num_ins;
  GRobjid *ins;
};

IGRlong EFconnect_topology(EMmsg, 
                           num_surfs,
                           num_lps_in, lps_in,
                           num_lps_out, lps_out,
                           num_eds_out, eds_out,
                           num_eds_in, eds_in,                            
                           con_top,
                           osnum, options)
IGRlong           *EMmsg; 
IGRint            num_surfs;
IGRint            *num_lps_in;
GRobjid           *lps_in;
IGRint            *num_lps_out;
GRobjid           *lps_out;
IGRint            num_eds_out;
GRobjid           *eds_out;
IGRint            *num_eds_in;
GRobjid           *eds_in;
struct EMScon_top **con_top;
OMuword           osnum;
IGRushort options;
/*
Description
    This function either disconnects or connects the topology created by this
    node to the active topology.

Return Values    
    EMSS_S_Success if all is well.

Notes
    About parameters:
        options - EMconnect_top_DISCONNECT reconnect already diconnected
                  topology. If not set the topology will be disconnected.
                  EMconnect_top_FREE_ONLY - free the list structure ONLY. 

History
    DLB 02/04/91    Creation.
*/
{
  IGRlong                 OM_stat=OM_S_SUCCESS;
  IGRint                  ii, jj, kk, cur_ins, curr_num_res, total_res=0,
                          num_mod=0, mod_arr_size=0, num_res_arr_size=0,
                          res_arr_size=0;  
  GRobjid                 *pe, *curr_lps_in, *curr_lps_out,
                          *mod=NULL, *num_res=NULL, *res=NULL;
  struct EMScon_top       *loc_con_top=NULL;
  OM_S_CHANSELECT         to_comps;


  if (!con_top) {*EMmsg = EMS_E_InvalidArg; goto wrapup;}
  else *EMmsg = EMS_S_Success;

  EMmake_chanselect(EMSbd_owner_to_comps, &to_comps);

  if (options & EMconnect_top_DISCONNECT)
  {
    /*Disconnect my created topology (part edges!)*/
    *con_top = (struct EMScon_top *) om$malloc
               (size = sizeof(struct EMScon_top)); 
    if (! *con_top) {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}

    loc_con_top = *con_top;

    memset((char *) loc_con_top, '\0', sizeof(struct EMScon_top));

    curr_lps_in = lps_in;
    curr_lps_out = lps_out;

    for(ii=0; ii<num_surfs; ii++)
    {
      EFgetEdgesAddRemModUnchg(EMmsg,
                               num_lps_in[ii],        curr_lps_in,
                               num_lps_out[ii],       curr_lps_out,
                               NULL,                  NULL,        
                               NULL,                  NULL,
                               &num_mod,              &mod,
                               &num_res,              &res,
                               NULL,                  NULL,
                               osnum);
      if (!(1 & *EMmsg)) goto wrapup;

      /*Disconnect the part edge.*/
      pe = res;
      curr_num_res=0;
      for(jj=0; jj<num_mod; jj++)
      {
        for(kk=0; kk<num_res[jj]; kk++, pe++)
        {
          OM_stat = om$send(msg = message Root.wild_disconnect(to_comps),
                            senderid = NULL_OBJID,
                            targetid = *pe,
                            targetos = osnum);
          if (!(1 & OM_stat)) goto wrapup;                          
          curr_num_res++;
        }
      }

      if (num_mod)
      {
        EFalloc_list(EMmsg,
                     &loc_con_top->mod,
                     loc_con_top->num_mod, 
                     &mod_arr_size, 
                     num_mod, CON_TOP_BUFF_INCR, NULL);
        if (!(1 & *EMmsg)) goto wrapup;

        OM_BLOCK_MOVE(mod,
                      &loc_con_top->mod[loc_con_top->num_mod],
                      num_mod * sizeof(GRobjid));
                      
        EFalloc_list(EMmsg,
                     &loc_con_top->num_res,
                     loc_con_top->num_mod, 
                     &num_res_arr_size, 
                     num_mod, CON_TOP_BUFF_INCR, NULL);
        if (!(1 & *EMmsg)) goto wrapup;
          
        OM_BLOCK_MOVE(num_res,
                      &loc_con_top->num_res[loc_con_top->num_mod],
                      num_mod * sizeof(GRobjid));
                      
        loc_con_top->num_mod += num_mod;
      }
      
      if (curr_num_res)
      {
        EFalloc_list(EMmsg,
                     &loc_con_top->res,
                     total_res, 
                     &res_arr_size, 
                     curr_num_res, CON_TOP_BUFF_INCR, NULL);
        if (!(1 & *EMmsg)) goto wrapup;
          
        OM_BLOCK_MOVE(res,
                      &loc_con_top->res[total_res],
                      curr_num_res * sizeof(GRobjid));
  
        total_res += curr_num_res;
      }

      if (mod)
      {
        om$dealloc(ptr = mod);
        num_mod = 0;
        mod = NULL;
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

      curr_lps_in += num_lps_in[ii];
      curr_lps_out += num_lps_out[ii];
    }

    if (!num_eds_out) goto wrapup;
    
    /*Now save and disconnect inserted edges*/
    loc_con_top->num_ins = (IGRint *) om$malloc
                           (size = num_eds_out * sizeof(IGRint));
    if (!loc_con_top->num_ins) {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}

    for(ii=0, jj=0; ii<num_eds_out; ii++)
      jj += num_eds_in[ii];

    loc_con_top->ins = (GRobjid *) om$malloc
                       (size = jj * sizeof(GRobjid));
    if (!loc_con_top->ins) {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}

    loc_con_top->num_ed = num_eds_out;

    loc_con_top->ed = (GRobjid *) om$malloc
                      (size = loc_con_top->num_ed * sizeof(GRobjid));
    if (!loc_con_top->ed) {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}

    pe = eds_in;
    cur_ins = 0;
    for(ii=0; ii<num_eds_out; ii++)
    {
      loc_con_top->ed[ii] = eds_out[ii];
      loc_con_top->num_ins[ii] = num_eds_in[ii];
       
      for(jj=0; jj<num_eds_in[ii]; jj++, cur_ins++, pe++)
      {
        loc_con_top->ins[cur_ins] = *pe;

        OM_stat = om$send(msg = message Root.wild_disconnect(to_comps),
                          senderid = NULL_OBJID,
                          targetid = *pe,
                          targetos = osnum);
        if (!(1 & OM_stat)) goto wrapup;                          
      }
    }
  }
  else
  {
    /*Reconnect the part edge.*/
    OM_S_CHANSELECT to_owner;

    loc_con_top = (struct EMScon_top *) *con_top;

    if (options & EMconnect_top_FREE_ONLY) goto wrapup;

    EMmake_chanselect(EMSedge_to_owner, &to_owner);

    pe = loc_con_top->res;
    for(ii=0; ii<loc_con_top->num_mod; ii++)
    {
      for(jj=0; jj<loc_con_top->num_res[ii]; jj++, pe++)
      {
        /*Connect to highest index on mod edge.*/
        OM_stat = om$send(msg = message Root.connect(to_comps,
                                MAXINT, 
                                loc_con_top->mod[ii], osnum,
                                to_owner, 0),
                          senderid = NULL_OBJID,
                          targetid = *pe,
                          targetos = osnum);
        if (!(1 & OM_stat)) goto wrapup;                          
      }
    }

    pe = loc_con_top->ins;
    for(ii=0; ii<loc_con_top->num_ed; ii++)
    {
      for(jj=0; jj<loc_con_top->num_ins[ii]; jj++, pe++)
      {
        /*Connect to highest index on mod edge.*/
        OM_stat = om$send(msg = message Root.connect(to_comps,
                                MAXINT, 
                                loc_con_top->ed[ii], osnum,
                                to_owner, 0),
                          senderid = NULL_OBJID,
                          targetid = *pe,
                          targetos = osnum);
        if (!(1 & OM_stat)) goto wrapup;                          
      }
    }
  }

wrapup:
  if (!(options & EMconnect_top_DISCONNECT) || !(1 & OM_stat & *EMmsg))
  {
    if (loc_con_top)
    {
      if (loc_con_top->mod) om$dealloc(ptr = loc_con_top->mod);
      if (loc_con_top->num_res) om$dealloc(ptr = loc_con_top->num_res);
      if (loc_con_top->res) om$dealloc(ptr = loc_con_top->res);
      if (loc_con_top->ed) om$dealloc(ptr = loc_con_top->ed);
      if (loc_con_top->num_ins) om$dealloc(ptr = loc_con_top->num_ins);
      if (loc_con_top->ins) om$dealloc(ptr = loc_con_top->ins);
      om$dealloc(ptr = *con_top);
      *con_top = NULL;
    }
  }
  if (mod) om$dealloc(ptr = mod);
  if (num_res) om$dealloc(ptr = num_res);
  if (res) om$dealloc(ptr = res);
  EMWRAPUP(*EMmsg, OM_stat, "EFconnect_topology")
  return(OM_stat);
}
end implementation EMSdpr;
