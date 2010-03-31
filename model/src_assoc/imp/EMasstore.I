/* ###################   APOGEE COMPILED   ################## */
class implementation EMSassoc;

#include <alloca.h>
#include "DIdef.h"
#include "DIprims.h"

method EMastore (IGRlong *EMmsg; 
                 IGRushort options;
                 struct GRmd_env *md_env; GRobjid new_objid)

/* *********************************************************************

Description
 This message causes the information that is contained in contained in the
 object to which this message is sent to be stored into the new object.
 The default implementation moves the parent channel, child channel, 
 vla, notification channel and the tag.

Arguments
 Input
 md_env: Environment of the master file.
 options : Currently not supported
 new_objid: new object id from which information is to be extracted.

 Output
 EMmsg: Completion message

Notes
 Upon exit the completion code will be one of the following:
 EMS_S_Success: If all goes well
 EMS_E_Fail: If there if failure

History
 DLB   04/10/92 Ignore errors from om$move_tag.  Also always do move_tag
                    regardless of option (effectively removing the option).
                    This was done in the past because the matching scheme was
                    tag based.  Now its key based.  I had to remove this
                    option because the tagcon record would get hosed up if
                    a move_chan was done BEFORE the tag was moved.
 DLB   03/30/92 Enable tagged connection global before issuing
                move_chan.
 DLB   01/29/92 Add support for EMSagrp class.  I do a class specific check
                in this code which would more "correctly" be done by a message.
                However, the EMSagrp situation is well understood so this
                additional class specific code does not pose a problem.
 DLB   12/20/91 Add notification of listeners that the channel has been moved.
 DLB    3/18/91 If info_size == 0 then don't get and put info (Bus error if
                put_info of NULL ptr) .
                Also, add option to not move tags, sf/sl stuff will do more
                indepth work with tags (recording mismatch tags etc.).
 Creation : PP : 03/07/91
 
************************************************************************ */
{
 IGRlong status;
 IGRchar *info_ptr=NULL;
 OM_S_CHANSELECT to_children, to_father, to_owners;
 OM_S_CHANSELECT notify;
 IGRuint type,info_size, tag_con_stat;
 IGRboolean agrp_class;
 OMuword               old_tag_os;
 extern OMuword        OPP_EMSagrp_class_id;
 IGRlong               EFmove_curve_info();
 IGRchar               name[DI_PATH_MAX];


 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;
 if (new_objid == my_id) goto wrapup;
 name[0] = '\0';

 status = EMmake_chanselect(GRconnector_to_owners, &to_owners);
 EMmake_chanselect(GRnotify_notification, &notify);

/*
 * Move the name from the old guy to the new guy.
 * pp 08/19/93
 */

 di$move_names (old_objid = my_id, new_objid = new_objid);

 status = om$send(msg = message Root.move_chan(to_owners, my_id,          
                        OM_Gw_current_OS,
                        to_owners), 
                   targetid = new_objid);
 if (!(1 & status)) goto wrapup;
 
 if (ME.GRgraphics->properties & GR_RIGID_RELATIONSHIP)
 {
  IGRshort props, set_bits;
  set_bits = 1;
  props = GR_RIGID_RELATIONSHIP;
  status = om$send(msg = message GRvg.GRchgprops(EMmsg,
                             &set_bits, &props),
                   targetid = new_objid);
  EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
 }

 /*Ensure that tag connections remain tagged - i.e. notification*/
 tag_con_stat = om$enable_tag_connects(flag = TRUE);

 om$set_tag_os(p_prev_osnum = &old_tag_os, osnum = OM_Gw_current_OS);

 /*DLB 1/29/92*/
 agrp_class = EFisAncestryValid(EMmsg, my_id, OM_Gw_current_OS, 
                                OPP_EMSagrp_class_id, FALSE);


 /******************************************************************
  *Always move tag regardless of options (see note above)***********
  ******* if (!(options & EMastore_DONT_MOVE_TAGS) && !agrp_class)**
  ******************************************************************/
 {/*INTENTIONAL*/
  /*
   * Ignore errors.
   */
   om$remove_tag(objid = new_objid, osnum = OM_Gw_current_OS);
  
   status = om$move_tag(old_objid = my_id,
                        new_objid = new_objid,
                        osnum = OM_Gw_current_OS);
   if (!(1 & status) && OM_Gf_verbose_warning)
   {
     fprintf(stderr,"EMastore: om$move_tag failed\n");
     EFprintcode(0, status);
     status = OM_S_SUCCESS;
   }
 }

 status = om$send(msg = message Root.move_chan(notify, my_id,          
                        OM_Gw_current_OS,
                        notify), 
                 targetid = new_objid);
 if (!(1 & status) && (status != OM_E_INVCHAN))
 {
#  if DEBUG
   if (OM_Gf_verbose_warning)
   {
     fprintf(stderr,"EMastore: move_chan failed for notification\n");
     EFprintcode(0, status);
   }
#  endif
   status = OM_S_SUCCESS;   
 }
 else
 {
   /*Notify the listeners that the chan was moved*/
   IGRlong      funk_msg=EMS_S_Success, loc_msg=EMS_S_Success;
   IGRlong      mask=GR_CHANGED;
   IGRshort     num_ids=1;
   struct GRid  newids;      

   newids.osnum = OM_Gw_current_OS;
   newids.objid = new_objid;
   GRnotifylisteners(&funk_msg, &loc_msg, &mask,
              message GRgraphics.GRidchanged(&funk_msg, &num_ids, &newids), 
              &new_objid); 
 }

 status = om$make_chanselect(channame = "NDchildren.children",
                                p_chanselect = &to_children);
 if (!(1 & status)) goto wrapup;

 status = om$make_chanselect(channame = "NDfather.father",
                              p_chanselect = &to_father);
 if (!(1 & status)) goto wrapup;

 status = om$send(msg = message Root.move_chan(to_children, my_id,          
                        OM_Gw_current_OS,
                          to_children), 
                   targetid = new_objid);
 if (!(1 & status)) status = 1;

 status = om$send(msg = message Root.move_chan(to_father, my_id,          
                        OM_Gw_current_OS,
                        to_father), 
                   targetid = new_objid);
 if (!(1 & status)) status = 1;

 status = om$send (msg = message EMSassoc.EMget_info(EMmsg,NULL,&type,
                        &info_size, NULL),
                   targetid = my_id);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);

 if (info_size > 0)
 {
  info_ptr = (IGRchar *) stackalloc(info_size);
  EMerr_hndlr(!info_ptr, *EMmsg, EMS_E_NoStackMemory,wrapup); 
 }
 else info_ptr = NULL;

 /*Even if no info, must store the type.*/
 status = om$send (msg = message EMSassoc.EMget_info(EMmsg, NULL, &type,
                         &info_size, 
                         &info_ptr),
                   targetid = my_id);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);

 status = om$send (msg = message EMSassoc.EMput_info(EMmsg,NULL,
                         type, info_size, info_ptr),
                   targetid = new_objid);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);


 /****DLB addition to handle moving info on curves owned by the EMSagrp*/
 if (agrp_class)
 {
   status = EFmove_curve_info(EMmsg, my_id, new_objid, OM_Gw_current_OS, 
                              md_env, NULL);
 }

wrapup:
 om$enable_tag_connects(flag = tag_con_stat);
 om$set_tag_os(p_prev_osnum = &old_tag_os, osnum = old_tag_os);
 if (info_ptr) stackfree (info_ptr);
 EMWRAPUP (*EMmsg, status, "In EMSassoc: EMastore error");
 return (status);
}


IGRlong EFmove_curve_info(EMmsg, from_id, to_id, osnum, md_env, options)
IGRint            *EMmsg;
GRobjid           from_id, to_id;
OMuword           osnum;
struct GRmd_env   *md_env;
IGRushort options;
{
  IGRlong               OM_stat=OM_S_SUCCESS;
  IGRint                from_count=0, to_count=0;
  OM_S_OBJECT_LINKAGE   *from_chan=NULL, *to_chan=NULL;
  OM_S_CHANSELECT       to_comps;
  IGRint                ii;
  extern OMuword        OPP_GRowner_class_id;


  *EMmsg = EMS_S_Success;

  /*Move my stuff*/
  OM_stat = EFmove_to_rhs(EMmsg, from_id, to_id, NULL_OBJID, osnum, NULL);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  if (!EFisAncestryValid(EMmsg, from_id, osnum, OPP_GRowner_class_id, FALSE))
  {
    goto wrapup;
  }

  EMmake_chanselect(GRcmpowner_to_components, &to_comps);

  OM_stat = om$get_channel_count(objid = from_id,
                                 osnum = osnum,
                                 p_chanselect = &to_comps,
                                 count = (OMuint *)&from_count);
  if (!(1 & OM_stat)) goto wrapup;
  
  if (!from_count)
  {
    *EMmsg = EMS_I_Useless;
    goto wrapup;
  }  

  OM_stat = om$get_channel_count(objid = to_id,
                                 osnum = osnum,
                                 p_chanselect = &to_comps,
                                 count = (OMuint *)&to_count);
  if (!(1 & OM_stat)) goto wrapup;
 
  if (from_count != to_count)
  {
#   if DEBUG
    if (OM_Gf_verbose_warning)
    {
      IGRchar from_name[OM_K_MAXCLASS_LEN],
              to_name[OM_K_MAXCLASS_LEN],
              channame[OM_K_MAXCHANNAME_LEN];

      om$get_classname(objid = from_id,
                       osnum = osnum,
                       classname = from_name);
      om$get_classname(objid = to_id,
                       osnum = osnum,
                       classname = to_name);
      if (to_comps.type == OM_e_num)
        om$get_channel_name(channum = to_comps.u_sel.number,
                            channame = channame);
      else if (to_comps.type == OM_e_name)
        strcpy(channame, to_comps.u_sel.name);

      fprintf(stderr, "WARNING: chan count mismatch\n");
      fprintf(stderr,"	from_id %d (%s), from_cnt %d, to %d (%s), to_cnt %d\n",
              from_id, from_name, from_count, to_id, to_name, to_count);
      fprintf(stderr, "	chan %s\n", channame);
    }
#   endif

    goto wrapup;
  }    

  from_chan = (OM_S_OBJECT_LINKAGE *) alloca
              (from_count * sizeof(OM_S_OBJECT_LINKAGE));
  if (!from_chan) {*EMmsg=EMS_E_NoStackMemory; goto wrapup;}

  to_chan = (OM_S_OBJECT_LINKAGE *) alloca
            (to_count * sizeof(OM_S_OBJECT_LINKAGE));
  if (!to_chan){*EMmsg=EMS_E_NoStackMemory; goto wrapup;}

  OM_stat = om$get_channel_objects(objid = from_id,
                                   osnum = osnum,
                                   p_chanselect = &to_comps,
                                   list = from_chan,
                                   size = from_count,
                                   count = (OMuint *)&from_count);
  if (!(1 & OM_stat)) goto wrapup;
                                       
  OM_stat = om$get_channel_objects(objid = to_id,
                                   osnum = osnum,
                                   p_chanselect = &to_comps,
                                   list = to_chan,
                                   size = to_count,
                                   count = (OMuint *)&to_count);
  if (!(1 & OM_stat)) goto wrapup;
    
  for(ii=0; ii<from_count; ii++)
  {
    OM_stat = EFmove_curve_info(EMmsg, 
                                from_chan[ii].S_objid, to_chan[ii].S_objid,
                                osnum, md_env, options);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  }

wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "EFsend_store_on")
  return(OM_stat);
}

end implementation EMSassoc;
