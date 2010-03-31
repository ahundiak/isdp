class implementation EMSdpr;

#include "EMSdpr.h"         /*EMSinlist; KNOWN_DEPENDENT*/
#include "EMSdprquery.h"    /*DPR_BUFF_INCR*/
#include "EMSmsgdef.h"
#include "emsdef.h"
#include "msdef.h"
#include "msmacros.h"
#include "ECmsg.h"

#if DEBUG
#include "stdio.h"
#endif

method EMcheckDPROverlap(IGRlong           *EMmsg; 
                         struct EMSinlist  *inlist;
                         struct EMSoutlist *outlist;
                         struct GRmd_env   *env; 
                         IGRushort options)

/*
Description
    This message will determine if an overlap exist between the incoming info
    and this node.  If so the UNEVAL flag is set.

Return Values    
    EMSS_S_Success if all is well.

Notes
    About parameters:
        inlist  - added info to check against
        outlist - removed info to check against
        options - currently unused.

History
    DLB 06/23/91 If overlap, see if I can recompute.  If not return
                 EMS_I_CantRecompute.
    DLB 05/02/91 If im UNEVAL'd don't do check but DO still send up!
    DLB 11/19/90 Creation.
*/
{
  IGRlong           OM_stat=OM_S_SUCCESS;
  IGRint            ii;
  IGRboolean        overlap_detected=FALSE;


  *EMmsg = EMS_S_Success;

  if (!(ME.EMSdpr->dpr_props & EMS_UNEVAL_STATE))
  {
    /*First check against inlist.*/
    OM_stat = om$send(msg = message EMSdpr.EMcheckOverlap(EMmsg, inlist,
                            &overlap_detected, NULL),
                      targetid = my_id);
    if (!(1 & OM_stat & *EMmsg)) 
    {
      /*If check failed assume overlap!*/
#     if DEBUG
      if (!(1 & *EMmsg & OM_stat))
        fprintf(stderr,"		inlist ovlap check failed!\n");
#     endif      
      overlap_detected = TRUE;
    }
  
#   if DEBUG
    if (overlap_detected) 
    {
      fprintf(stderr,"		inlist overlap\n");
    }
#   endif      
  
    if (!overlap_detected)
    {
      /*Next check against outlist.*/
      struct EMSinlist tmp_inlist;
  
      tmp_inlist.sflist = outlist->sflist;
      tmp_inlist.lplist = outlist->lplist;
      tmp_inlist.edlist = outlist->edlist;
      OM_stat = om$send(msg = message EMSdpr.EMcheckOverlap(EMmsg, 
                              &tmp_inlist, &overlap_detected, NULL),
                        targetid = my_id);
      if (!(1 & OM_stat & *EMmsg))
      {
#       if DEBUG
        if (!(1 & *EMmsg & OM_stat))
          fprintf(stderr,"		outlist ovlap check failed!\n");
#       endif
        overlap_detected = TRUE;
      }
  
#     if DEBUG
      if (overlap_detected)
      {
        fprintf(stderr,"		outlist overlap\n");
      }
#     endif      
  
      if (!overlap_detected)
      {
        /*Check against surfs mod.  Some check operations may ignore this
         * so the option is passed to inform them.
         */
        tmp_inlist.sflist = outlist->sfmodlist;
        tmp_inlist.lplist.num_loops = 0;
        tmp_inlist.edlist.num_edges = 0;
        OM_stat = om$send(msg = message EMSdpr.EMcheckOverlap(EMmsg, 
                                &tmp_inlist, &overlap_detected, 
                                EMcheck_overlap_TREAT_SFS_AS_SFMOD),
                          targetid = my_id);
        if (!(1 & OM_stat & *EMmsg))
        {
#         if DEBUG
          if (!(1 & *EMmsg & OM_stat))
            fprintf(stderr,"		sfsmod outlist ovlap check failed!\n");
#         endif
          overlap_detected = TRUE;
        }
  
#       if DEBUG
        if (overlap_detected)
        {
          fprintf(stderr,"		outlist overlap\n");
        }
#       endif      
  
        if (!overlap_detected)
        {
          for(ii=0; ii<outlist->rnglist.num_repl_info; ii++)
          {
            /*And last of all check against the geometric range.*/
            OM_stat = om$send(msg = message EMSdpr.EMcheckRngOverlap(EMmsg,
                                outlist->rnglist.replace_info[ii].replacing_id,
                                outlist->rnglist.replace_info[ii].range, 
                                sender_id, env,
                                &overlap_detected, NULL),
                              targetid = my_id);
            if (!(1 & OM_stat & *EMmsg))
            {
#             if DEBUG
              if (!(1 & *EMmsg & OM_stat))
                fprintf(stderr,"		range ovlap check failed!\n");
#             endif
              overlap_detected = TRUE;
            }
  
            if (overlap_detected)
            {
#             if DEBUG
              fprintf(stderr,"		range overlap\n");
#             endif      
              break;
            }
          }
        }
      }
    }
  
    if (overlap_detected)
    {
      IGRboolean can_rc=TRUE;

#     if DEBUG
      {
        IGRchar my_name[OM_K_MAXCLASS_LEN];
        om$get_classname(object = me, classname = my_name);
        fprintf(stderr,"EMcheckDPROverlap: Overlap on node %d (%s)\n", 
                my_id, my_name);
      }
#     endif    
  
      /*Determine if this node can recompute.  If so then proceed as 
       * normal, otherwise need to recover the original model.
       */
  
      OM_stat = om$send(msg = message EMSdpr.EMcanRecompute(EMmsg, &can_rc),
                        targetid = my_id);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;
      
      if (!can_rc)
      {
        EFcantrc(EMmsg, my_id, OM_Gw_current_OS);

        ex$message ( msgnumb = EMS_S_SupressingAffNd);
      
        *EMmsg = EMS_I_CantRecompute;
        goto wrapup;
      }
      else
      {
        ME.EMSdpr->dpr_props |= EMS_UNEVAL_STATE;
  
        /*Get the in info for this node.*/
        OM_stat = om$send(msg = message EMSdpr.EMgetInInfo(EMmsg, inlist,
                                NULL_OBJID, FALSE, NULL),
                          targetid = my_id);
        if (!(1 & OM_stat & *EMmsg)) goto wrapup;
      }
    }
  }

  { /*INTENTIONAL BLOCK*/
    OM_S_CHANSELECT to_owners;

    EMmake_chanselect(GRconnector_to_owners, &to_owners);
    OM_stat = om$send(msg = message EMSdpr.EMcheckDPROverlap(EMmsg, inlist,
                            outlist, env, options),
                      p_chanselect = &to_owners,
                      from = 0, to = 0);
    if (OM_stat == OM_W_UNKNOWN_MSG) OM_stat = OM_S_SUCCESS;
  }

  wrapup:
    EMWRAPUP(*EMmsg, OM_stat, "EMSdpr.EMcheckDPROverlap")
    return(OM_stat);
}
end implementation EMSdpr;
