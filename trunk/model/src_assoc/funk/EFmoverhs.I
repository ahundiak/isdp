/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI   COMPILED   ################## */
class implementation EMSsurface;
/*
History
    DLB     ??/??/90    Creation.
    DLB     01/14/91    Changed temp object from EMSboundary to Rootmsg class.
    DLB     02/13/91    If match is successful then MOVE the tag to the rhs
                        instead of swapping.  So, if a lhs object has not tag
                        then this indicates that it has already be matched. 
                        Can remove the Rootmsg object construction now.
    DLB     02/18/91    Also before moving see if the lhs object is in the
                        mismatch list.  If so then don't move it.
    DLB     03/11/91    Move only notify chan, name, tag.  Send
                        EMtopology_match, EMgeometry_match.
    AIC     08/06/91    Added md_env argument.
    DLB     01/10/92    Move name via di$move_names.
    DLB     03/30/92    Enable tagged connection global before issuing
                        move_chan.
    DLB     04/10/92    Ignore errors from om$move_tag.  Also remove mismatched
                            tag recording code.
*/    
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "EMSmsgdef.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "emserr.h"
#include "emsdef.h"
#include "EMSdpr.h"
#include "OMmacros.h"
#include "exmacros.h"
#include "stdio.h"
#include "EMSopt.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIprims.h"
#include "DIglob.h"
#include "string.h"

from EMSboundary import EMmatch_topology;

extern OMuint OM_Gf_verbose_warning;

IGRlong EFmove_to_rhs(EMmsg, lhs, rhs, senderid, osnum, options)
IGRlong           *EMmsg;
GRobjid           lhs;
GRobjid           rhs;
GRobjid           senderid;
OMuword           osnum;
IGRushort options;
{
  IGRlong       OM_stat=OM_S_SUCCESS, EFcheck_for_tag();
  OMuint        oldtag, tag_con_stat;
  OMuword       old_tag_os;
  IGRboolean    warning;
  void          EFcvrt_to_from_tag();

 
  *EMmsg = EMS_S_Success;

  if (lhs == rhs) goto wrapup;

  /*DLB 4/10/92 - removed tag recording stuff from here*/

  if (options & EMstore_opt_MATCH_FAILED)
  {
    goto wrapup;
  }   

# if DEBUG
  if (OM_Gf_verbose_warning)
    fprintf(stderr, "Moving tag from %d to %d\n", lhs, rhs);
# endif

  /*Ensure that tag connections remain tagged - i.e. notification*/
  tag_con_stat = om$enable_tag_connects(flag = TRUE);

  om$set_tag_os(p_prev_osnum = &old_tag_os, osnum = OM_Gw_current_OS);

  warning = OM_Gf_verbose_warning;
  OM_Gf_verbose_warning = FALSE;

  EFcvrt_to_from_tag(EMmsg, 1, &lhs, &oldtag, TRUE, osnum);
  OM_Gf_verbose_warning = warning;
  if (!(1 & *EMmsg)) goto wrapup;

  /*If I have a tag delete rhs tag & move my tag*/
  if (*EMmsg != EMS_I_InvalidCase)
  {
    /*Remove the tag on the rhs.  IGNORE failures.*/
    om$remove_tag(objid = rhs, osnum = osnum);

    OM_stat = om$move_tag(old_objid = lhs,
                          new_objid = rhs,    
                          osnum = osnum);
    if (!(1 & OM_stat) && OM_Gf_verbose_warning)
    {
      fprintf(stderr,"EFmove_to_rhs: om$move_tag failed\n");
      EFprintcode(0, OM_stat);
     OM_stat = OM_S_SUCCESS;
    }
  }
    

  /* Move name in the lhs object - if any*/
  di$move_names(old_objid = lhs,
                new_objid = rhs);

  {
    OM_S_CHANSELECT notify;

    EMmake_chanselect(GRnotify_notification, &notify);
    /* move notification to rhs */
    OM_stat = om$send(msg = message Root.move_chan(notify, lhs, osnum, notify),
                      senderid = NULL_OBJID,
                      targetid = rhs,
                      targetos = osnum);
    if (!(1 & OM_stat) && (OM_stat != OM_E_INVCHAN))
    {
      if (OM_Gf_verbose_warning)
      {
        fprintf(stderr,"EFmove_to_rhs: move_chan failed for notification\n");
        EFprintcode(0, OM_stat);
      }
    }
    else
    {
      /*Notify the listeners that the chan was moved*/
      IGRlong      funk_msg=EMS_S_Success, loc_msg=EMS_S_Success;
      IGRlong      mask=GR_CHANGED;
      IGRshort     num_ids=1;
      struct GRid  newids;      

      newids.osnum = osnum;
      newids.objid = rhs;
      GRnotifylisteners(&funk_msg, &loc_msg, &mask,
                 message GRgraphics.GRidchanged(&funk_msg, &num_ids, &newids), 
                 &rhs); 
    }
    OM_stat = OM_S_SUCCESS;
  }

  wrapup:
    om$enable_tag_connects(flag = tag_con_stat);
    om$set_tag_os(p_prev_osnum = &old_tag_os, osnum = old_tag_os);
    EMWRAPUP(*EMmsg, OM_stat, "EFmove_to_rhs")
    return(OM_stat);
}


IGRboolean EFmatch_classes(EMmsg, lhs, rhs, osnum, options)
IGRint            *EMmsg;
GRobjid           lhs;
GRobjid           rhs;
OMuword           osnum;
IGRushort options;
{
  IGRlong OM_stat = OM_S_SUCCESS;
  OMuword lhs_classid, rhs_classid;


  *EMmsg = EMS_S_Success;
  OM_stat = om$get_classid(objid = lhs,
                           osnum = osnum,
                           p_classid = &lhs_classid);
  if (!(1 & OM_stat)) goto wrapup;

  OM_stat = om$get_classid(objid = rhs,
                           osnum = osnum,
                           p_classid = &rhs_classid);
  if (!(1 & OM_stat)) goto wrapup;
                           
# if DEBUG
  if (OM_Gf_verbose_warning && (lhs_classid != rhs_classid))
  {
    IGRchar lhs_name[OM_K_MAXCLASS_LEN], rhs_name[OM_K_MAXCLASS_LEN];
    om$get_classname(objid = lhs,
                     osnum = osnum,
                     classname = lhs_name);
    om$get_classname(objid = rhs,
                     osnum = osnum,
                     classname = rhs_name);
    fprintf(stderr, "WARNING: class match failed lhs %s (%d), rhs %s (%d)\n", 
            lhs_name, lhs, rhs_name, rhs);
  }
# endif
 
wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "EFmatch_classes")  
  return(lhs_classid == rhs_classid);
}


IGRlong EFsend_store_on(EMmsg, lhs, osnum, rhs, chansel, options, md_env)
IGRint            *EMmsg;
GRobjid           lhs;
OMuword           osnum;
GRobjid           rhs;
OM_S_CHANSELECT   *chansel;
IGRushort options;
struct GRmd_env   *md_env;
{
  IGRlong               OM_stat=OM_S_SUCCESS;
  IGRint                lhs_count=0, rhs_count=0;
  OM_S_OBJECT_LINKAGE   *lhs_chan=NULL, *rhs_chan=NULL;
  IGRboolean            match_failed=FALSE;
  IGRint                ii;
  GRobjid               loc_rhs;


  *EMmsg = EMS_S_Success;

  if (options & EMstore_opt_MATCH_FAILED) match_failed = TRUE;

  OM_stat = om$get_channel_count(objid = lhs,
                                 osnum = osnum,
                                 p_chanselect = chansel,
                                 count = (OMuint *) &lhs_count);
  if (!(1 & OM_stat)) goto wrapup;
  
  /* SM 10/10/90 */
  if (!lhs_count)
  {
    *EMmsg = EMS_I_Useless;
    goto wrapup;
  }  
  /* End SM 10/10/90 */

  if (!match_failed)
  {
    OM_stat = om$get_channel_count(objid = rhs,
                                   osnum = osnum,
                                   p_chanselect = chansel,
                                   count = (OMuint *) &rhs_count);
    if (!(1 & OM_stat)) goto wrapup;
  }
 
  if (lhs_count != rhs_count && !match_failed)
  {
    options |= EMstore_opt_MATCH_FAILED;
    match_failed = TRUE;

#   if DEBUG
    if (OM_Gf_verbose_warning)
    {
      IGRchar lhs_name[OM_K_MAXCLASS_LEN],
              rhs_name[OM_K_MAXCLASS_LEN],
              channame[OM_K_MAXCHANNAME_LEN];

      om$get_classname(objid = lhs,
                       osnum = osnum,
                       classname = lhs_name);
      om$get_classname(objid = rhs,
                       osnum = osnum,
                       classname = rhs_name);
      if (chansel->type == OM_e_num)
        om$get_channel_name(channum = chansel->u_sel.number,
                            channame = channame);
      else if (chansel->type == OM_e_name)
        strcpy(channame, chansel->u_sel.name);

      fprintf(stderr, "WARNING: chan count mismatch\n");
      fprintf(stderr, "	lhs %d (%s), lhs_cnt %d, rhs %d (%s), rhs_cnt %d\n",
              lhs, lhs_name, lhs_count, rhs, rhs_name, rhs_count);
      fprintf(stderr, "	chan %s\n", channame);
    }
#   endif
  }    

  /*WARNING! Channel may change during send so can't use chan_access stuff*/ 
  lhs_chan = (OM_S_OBJECT_LINKAGE *) stackalloc
             (lhs_count * sizeof(OM_S_OBJECT_LINKAGE));
  if (!lhs_chan) {*EMmsg=EMS_E_NoStackMemory; goto wrapup;}

  if (!match_failed)
  {
    rhs_chan = (OM_S_OBJECT_LINKAGE *) stackalloc
               (rhs_count * sizeof(OM_S_OBJECT_LINKAGE));
    if (!rhs_chan){*EMmsg=EMS_E_NoStackMemory; goto wrapup;}
  }

  OM_stat = om$get_channel_objects(objid = lhs,
                                   osnum = osnum,
                                   p_chanselect = chansel,
                                   list = lhs_chan,
                                   size = lhs_count,
                                   count = (OMuint *) &lhs_count);
  if (!(1 & OM_stat)) goto wrapup;
                                       
  if (!match_failed)
  {
    OM_stat = om$get_channel_objects(objid = rhs,
                                     osnum = osnum,
                                     p_chanselect = chansel,
                                     list = rhs_chan,
                                     size = rhs_count,
                                     count = (OMuint *) &rhs_count);
    if (!(1 & OM_stat)) goto wrapup;
  }
    
  for(ii=0; ii<lhs_count; ii++)
  {
    loc_rhs = match_failed ? NULL_OBJID : rhs_chan[ii].S_objid;
    OM_stat = om$send(msg = message EMSboundary.EMmatch_topology(
                            (IGRlong  *) EMmsg,
                            options, md_env, loc_rhs), 
                      senderid = NULL_OBJID,
                      targetid = lhs_chan[ii].S_objid,
                      targetos = osnum);
    if (!(1 & OM_stat & *EMmsg))
    {
      OM_stat = om$send(msg = message EMSsurface.EMmatch_geometry(
                              (IGRlong *) EMmsg,
                              options, md_env, loc_rhs),
                        senderid = NULL_OBJID,
                        targetid = lhs_chan[ii].S_objid,
                        targetos = osnum);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;
    }
  }

wrapup:
  if (lhs_chan) stackfree(lhs_chan); /*FREE ONLY 1ST PTR!!! (STACK MEM)*/
  EMWRAPUP(*EMmsg, OM_stat, "EFsend_store_on")
  return(OM_stat);
}


%safe
static OMuint *EMS_tag_list=NULL;
static IGRint EMS_tag_list_size=0;
static IGRint EMS_tag_count=0;
%endsafe

#define EMS_TAG_INCREMENT 50

IGRlong EFadd_tag(tag)
OMuint tag;
{
  IGRlong EMmsg=EMS_S_Success;
  IGRint  tmp_cnt, ii, insert;
  

  tmp_cnt = EMS_tag_list_size;

  (void) EFalloc_list(&EMmsg, &EMS_tag_list, EMS_tag_count, &EMS_tag_list_size,
                      1, EMS_TAG_INCREMENT, NULL);
  if (!(1 & EMmsg)) goto wrapup;

  if (tmp_cnt != EMS_tag_list_size)
  {
    /* Zero the new entries */
    (void) memset((char *) (EMS_tag_list + EMS_tag_count),
                  '\0',
                  EMS_TAG_INCREMENT * sizeof(IGRint));
  }

  if (EMS_tag_count)
    insert = EFget_tag(tag, EMS_tag_list, 0, EMS_tag_count-1);
  else
    insert = 0;

  if (insert < EMS_tag_count)
  {
    for(ii=EMS_tag_count-1; ii>=insert; ii--)
    {
      EMS_tag_list[ii+1] = EMS_tag_list[ii];
    }
  }

  EMS_tag_list[insert] = tag;
  EMS_tag_count++;

wrapup:
  EMWRAPUP(EMmsg, EMmsg, "EFadd_tag")
  return(EMmsg);
}


IGRlong EFcheck_for_tag(tag)
OMuint tag;
{
  IGRint tag_index;

  if (!EMS_tag_count) return(EMS_S_Success);
  tag_index = EFget_tag(tag, EMS_tag_list, 0, EMS_tag_count-1);
  if (EMS_tag_list[tag_index] == tag) return(EMS_I_Found);
  else return(EMS_S_Success);
}


IGRint EFget_tag(tag, tag_list, low, high)
/*
 *      Binary Search of list for tag.
 */
OMuint  tag;
IGRint  *tag_list;
IGRint  low;
IGRint  high;
{
   IGRint mid;

   if (low > high)
   {
           return(low);
   }
   mid = (low + high)/2;
   if (tag == tag_list[mid]) return(mid);
   else if (tag < tag_list[mid])
     return(EFget_tag(tag, tag_list, low, mid-1));
   else
     return(EFget_tag(tag, tag_list, mid+1, high));
}

IGRlong EFremove_tag(tag)
OMuint tag;
/*
 *      Zero the old entry and move everybody forward.
 */
{
  IGRint ii, tag_index;

  tag_index = EFget_tag(tag, EMS_tag_list, 0, EMS_tag_count-1);
  if (EMS_tag_list[tag_index] != tag) return(EMS_E_InvalidArg);

  EMS_tag_count--;  
  for(ii=tag_index; ii<EMS_tag_count; ii++)
  {
    EMS_tag_list[ii] = EMS_tag_list[ii+1];
  }
  EMS_tag_list[EMS_tag_count] = 0;
  
  return(EMS_S_Success);
}

IGRlong EFremove_all_tags()
/*
 *      Zero the old entrys and reset EMS_tag_count
 */
{
  IGRint ii;

  for(ii=0; ii<EMS_tag_count; ii++)
  {
    EMS_tag_list[ii] = 0;
  }
  EMS_tag_count = 0;  
  return(EMS_S_Success);
}

void EFdebug_print_tag()
{
  int ii;
  fprintf(stderr,"EMS_tag_list = %x\n", EMS_tag_list);
  fprintf(stderr,"EMS_tag_count = %d\n", EMS_tag_count);
  fprintf(stderr,"EMS_tag_list_size = %d\n", EMS_tag_list_size);  
  fprintf(stderr,"list dump:\n");
  for(ii=0; ii<EMS_tag_count; ii++)
    fprintf(stderr, "index %d   tag %u\n", ii, EMS_tag_list[ii]);
  return;
}
end implementation EMSsurface;

#if EVER_DO_TOPOLOGY_TAG_MATCHING_AGAIN_DLB_DLB
  warning = OM_Gf_verbose_warning;
  OM_Gf_verbose_warning = FALSE;
  EFcvrt_to_from_tag(EMmsg, 1, &lhs, &oldtag, TRUE, osnum);
  OM_Gf_verbose_warning = warning;
  if (!(1 & *EMmsg)) goto wrapup;

  if (oldtag == EMS_NO_TAG)
  {
#   if DEBUG
    if (OM_Gf_verbose_warning)
      fprintf(stderr, "WARNING: lhs (%d) has no tag\n", lhs);
#   endif
    goto wrapup;
  }
  else if (EFcheck_for_tag(oldtag) != EMS_S_Success)
  {
    /*lhs tag in mismatch list*/
#if DEBUG
    if (OM_Gf_verbose_warning) 
      fprintf(stderr,
         "WARNING: Objid %d (tag %d) already in mismatch list, not moving\n",
         lhs, oldtag);  
#   endif
    goto wrapup;
  }
  else if (options & EMstore_opt_MATCH_FAILED)
  {
    /*Record my mismatched tag*/
    IGRlong EFadd_tag();

#   if DEBUG
    if (OM_Gf_verbose_warning)
      fprintf(stderr,"	RECORDING MISMATCH: objid %d, tag %d\n", lhs, oldtag);
#   endif
    OM_stat = EFadd_tag(oldtag);
    goto wrapup;
  }   
#endif
