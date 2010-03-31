/* ###################   APOGEE COMPILED   ################## */
class implementation EMSdprparam;

#include "OMmacros.h"
#include "emsdef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

#define COMPUTE_INFO_BUFF_INCR  75

from EMSsurface import EMget_tree_top;

method EMinit(IGRlong           *EMmsg;
              IGRushort option;
              GRobjid           top_state_id)
/*
Description
    This method will init the EMSdprparam object.
    
Notes
  ALL of the instance field are pointers to MALLOC'D memory (pointer size). 
  This is done since the pointers to the arrays are used by the execute, undo,
  and redo code AND MAY BE REALLOC'D.  Additionally if a pointer to INSTANCE
  DATA is returned then it could become bad if the object is moved around in
  memory.  By returning a pointer to malloc'd memory, which contains the item
  of interest, the pointer is assured to remain constant.

History
   DLB    01/14/91  Creation.
*/
{
  IGRlong OM_stat=OM_S_SUCCESS;



  *EMmsg = EMS_S_Success;

  ME.EMSdprparam->display_count = 0;
  ME.EMSdprparam->display_ids = NULL;
  ME.EMSdprparam->num_compute_info = 0;
  ME.EMSdprparam->compute_info = NULL;  
  ME.EMSdprparam->num_chg_ids = 0;
  ME.EMSdprparam->chg_ids = NULL;
  
  {
    IGRlong flag=1, zero=0, maxint=OM_K_MAXINT;
    struct GRid my_GRid;

    my_GRid.objid = my_id;
    my_GRid.osnum = OM_Gw_current_OS;

    OM_stat = om$send(msg = message GRconnector.GRflexconn(EMmsg, &flag,
                            &my_GRid, &zero, &maxint),
                    targetid = top_state_id);
  }
                      
  EMWRAPUP(*EMmsg, OM_stat, "EMSdprparam.EMinit")
  return(OM_stat);
}


method EMput_display_ids(IGRlong           *EMmsg; 
                         IGRint            num_display_ids;
                         GRobjid           *display_ids;
                         IGRushort option)
/*
Description

History
   DLB    01/14/91  Creation.
*/
{
  *EMmsg = EMS_S_Success;

  ME.EMSdprparam->display_count = num_display_ids;
  ME.EMSdprparam->display_ids = display_ids;

  return(OM_S_SUCCESS);
}


method EMget_display_ids(IGRlong           *EMmsg; 
                         IGRint            *num_display_ids;
                         GRobjid           **display_ids;
                         IGRushort option)
/*
Description

Notes
    About parameters:
        display_ids - contains the POINTER stored in instance data.
        display_count - dito.

History
   DLB    01/14/91  Creation.
*/
{
  *EMmsg = EMS_S_Success;

  *num_display_ids = ME.EMSdprparam->display_count;
  *display_ids = ME.EMSdprparam->display_ids;

  return(OM_S_SUCCESS);
}


method EMput_compute_info(IGRlong                *EMmsg; 
                          IGRint                 num_compute_info;
                          struct EMScompute_info *compute_info;
                          IGRushort      option)
/*
Description

History
   DLB    01/14/91  Creation.
*/
{
  IGRint ii;
  

  *EMmsg = EMS_S_Success;

  for(ii=0; ii<num_compute_info; ii++)
  {
    EFrealloc_if_needed(EMmsg, &ME.EMSdprparam->compute_info,
                        ME.EMSdprparam->num_compute_info,
                        COMPUTE_INFO_BUFF_INCR,
                        sizeof(struct EMScompute_info));
    if (!(1 & *EMmsg)) goto wrapup;

    OM_BLOCK_MOVE(&compute_info[ii],
               &ME.EMSdprparam->compute_info[ME.EMSdprparam->num_compute_info],
               sizeof(struct EMScompute_info));
    ME.EMSdprparam->num_compute_info++;
  }    

#if DEBUG
  fprintf(stderr,"\nput_compute_info completed to %d\n", my_id);
  om$send(msg = message Root.debug(),
          targetid = my_id);
#endif           

wrapup:
  EMWRAPUP(*EMmsg, *EMmsg, "EMSdprparam.EMput_compute_info")
  return(OM_S_SUCCESS);
}


method EMget_compute_info(IGRlong                *EMmsg; 
                          IGRint                 *num_compute_info;
                          struct EMScompute_info **compute_info;
                          IGRushort      option)
/*
Description

Notes
    About parameters:
        compute_info - returns the POINTER stored in instance data.
        
History
   DLB    01/14/91  Creation.
*/
{
  *EMmsg = EMS_S_Success;

  *num_compute_info = ME.EMSdprparam->num_compute_info;
  *compute_info = ME.EMSdprparam->compute_info;

  return(OM_S_SUCCESS);
}


method EMdisplay(IGRlong           *EMmsg; 
                 struct GRmd_env   *env;
                 IGRushort option)
/*
Description

Notes
        
History
   DLB    01/14/91  Creation.
*/
{
  IGRint            ii;
  enum GRdpmode     display_mode;
  IGRboolean        aflag = 0;
  struct  GRmd_env  display_env;

  aflag = pwIsActivationOn();
  gr$get_module_env(buffer = &display_env);

  *EMmsg = EMS_S_Success;

  display_mode = GRbd;
  for(ii=0; ii<ME.EMSdprparam->display_count; ii++)
  {
    if (om$is_objid_valid(objid=ME.EMSdprparam->display_ids[ii])==OM_S_SUCCESS)
    {
      om$send(msg = message GRgraphics.GRdisplay(EMmsg, 
                    aflag? &display_env.md_env.matrix_type:
                    &env->md_env.matrix_type,
                    aflag? display_env.md_env.matrix:
                    env->md_env.matrix, &display_mode,
                    aflag? &display_env.md_id:
                    &env->md_id),
              targetid = ME.EMSdprparam->display_ids[ii]);
      /*IGNORE ERRORS!!*/
    }
  }

  if (ME.EMSdprparam->display_ids)
    om$dealloc(ptr = ME.EMSdprparam->display_ids);

  ME.EMSdprparam->display_count = 0;
  ME.EMSdprparam->display_ids = NULL;

  *EMmsg = EMS_S_Success;
  return(OM_S_SUCCESS);
}


method EMdelete(IGRlong           *EMmsg; 
                IGRushort option)
/*
Description
   This method will delete the EMSdprparam object.
    
History
   DLB    01/14/91  Creation.
*/
{
  IGRlong OM_stat=OM_S_SUCCESS;
  struct GRid my_GRid;
  OM_S_CHANSELECT to_comps;

  
  *EMmsg = EMS_S_Success;

  EMmake_chanselect(GRcmpowner_to_components, &to_comps);

  my_GRid.objid = my_id;
  my_GRid.osnum = OM_Gw_current_OS;
  OM_stat = om$send(msg = message GRconnector.GRdisconn(EMmsg, &my_GRid), 
                    p_chanselect = &to_comps);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  if (ME.EMSdprparam->display_ids)
    om$dealloc(ptr = ME.EMSdprparam->display_ids);
  if (ME.EMSdprparam->compute_info)
    om$dealloc(ptr = ME.EMSdprparam->compute_info);
  if (ME.EMSdprparam->chg_ids)
    om$dealloc(ptr = ME.EMSdprparam->chg_ids);

  OM_stat = om$send(msg = message Root.delete(NULL),
                    targetid = my_id);
                                          
wrapup:
  EMWRAPUP(*EMmsg, *EMmsg, "EMSdprparam.EMdelete")
  return(OM_stat);
}

#include "stdio.h"

method debug()
/*
Description
    
History
   DLB    06/27/91  Print status instance data.
   DLB    01/14/91  Creation.
*/
{
  IGRint ii, jj;

  fprintf(stderr,"compute status = 0x%x\n", ME.EMSdprparam->status);

  fprintf(stderr,"display_count = %d\n", ME.EMSdprparam->display_count);
  for(ii=0; ii<ME.EMSdprparam->display_count; ii++)
  {
    fprintf(stderr,"	display_ids[%d] = %d\n",
            ii, ME.EMSdprparam->display_ids[ii]);
  }

  fprintf(stderr,"num_chg_ids = %d\n", ME.EMSdprparam->num_chg_ids);
  for(ii=0; ii<ME.EMSdprparam->num_chg_ids; ii++)
  {
    fprintf(stderr,"	chg_ids[%d] = %d\n",
            ii, ME.EMSdprparam->chg_ids[ii]);
  }

  fprintf(stderr,"num_compute_info = %d\n", ME.EMSdprparam->num_compute_info);
  for(ii=0; ii<ME.EMSdprparam->num_compute_info; ii++)
  {
    fprintf(stderr,"	compute_info[%d].computed_id = %d\n",
            ii, ME.EMSdprparam->compute_info[ii].computed_id);
    fprintf(stderr,"	compute_info[%d].ssi = %x\n",
            ii, ME.EMSdprparam->compute_info[ii].ssi);
    fprintf(stderr,"	compute_info[%d].ri = %x\n",
            ii, ME.EMSdprparam->compute_info[ii].ri);
    fprintf(stderr,"	compute_info[%d].con_top = %x\n",
            ii, ME.EMSdprparam->compute_info[ii].con_top);
    fprintf(stderr,"	compute_info[%d].added_geom.num_added = %x\n",
            ii, ME.EMSdprparam->compute_info[ii].added_geom.num_added);
    for(jj=0; jj<ME.EMSdprparam->compute_info[ii].added_geom.num_added; jj++)
    {
      fprintf(stderr,"		compute_info[%d].added_geom.added_ids[%d] = %d\n",
            ii, jj, ME.EMSdprparam->compute_info[ii].added_geom.added_ids[jj]);
      fprintf(stderr,"		compute_info[%d].added_geom.added_inx[%d] = %d\n",
            ii, jj, ME.EMSdprparam->compute_info[ii].added_geom.added_inx[jj]);
    }      
    fprintf(stderr,"\n");
  }
 
  return(OM_S_SUCCESS);
}

IGRlong EFsend_to_param(EMmsg, messg, tree_id, tree_os, param_id, options)
IGRlong           *EMmsg;
OM_S_MESSAGE      *messg;
GRobjid           tree_id;
OMuword           tree_os;
GRobjid           *param_id;
IGRushort options;
/*
Description
   Send to (and possibly create) the param object a message.
History
   DLB    01/14/91  Creation.
*/
{
  IGRlong        OM_stat=OM_S_SUCCESS;
  IGRint         count, ii;
  GRobjid        loc_param_id, tree_top_id;
  extern OMuword OPP_EMSdprparam_class_id;
  OM_S_CHANSELECT to_owners;


  *EMmsg = EMS_S_Success;

  OM_stat = om$send(msg = message EMSsurface.EMget_tree_top(EMmsg,
                          &tree_top_id, NULL, NULL),
                    senderid = NULL_OBJID,
                    targetid = tree_id,
                    targetos = tree_os);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;                    

  EMmake_chanselect(GRconnector_to_owners, &to_owners);
  OM_stat = om$get_channel_count(objid = tree_top_id,
                                 osnum = tree_os,
                                 p_chanselect = &to_owners,
                                 count = (OMuint *)&count);
  if (!(1 & OM_stat)) goto wrapup;

  for(ii=0; ii<count; ii++)
  {
    OM_stat = om$send(msg = messg,
                      senderid = tree_top_id,
                      targetos = tree_os,
                      p_chanselect = &to_owners,
                      from = ii, to = ii);
    if (1 & OM_stat)
    {
      OM_stat = om$get_objid_at_index
                                (objid = tree_top_id,
                                 osnum = tree_os,
                                 p_chanselect = &to_owners,
                                 index = ii,
                                 objidaddr = &loc_param_id,
                                 osnumaddr = &tree_os);
      if (!(1 & OM_stat)) goto wrapup;
      break;
    }
  }

  if (ii == count)
  {
    /*No EMSdprparam object found, so construct one.*/
    OM_stat = om$construct(classid = OPP_EMSdprparam_class_id,
                           osnum = tree_os,
                           p_objid = &loc_param_id);
    if (!(1 & OM_stat)) goto wrapup;

    OM_stat = om$send(msg = message EMSdprparam.EMinit(EMmsg, NULL,
                            tree_top_id), 
                      senderid = NULL_OBJID,
                      targetid = loc_param_id,
                      targetos = tree_os);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;

    OM_stat = om$send(msg = messg,
                      senderid = NULL_OBJID,
                      targetid = loc_param_id,
                      targetos = tree_os);
    if (!(1 & OM_stat)) goto wrapup;                      
  }                                                 

  if (param_id) *param_id = loc_param_id;

wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "EFsend_to_param")
  return(OM_stat);
}

#include "stdio.h"
#include "grerr.h"

method GRlocate_owner(IGRlong *msg; struct GRlc_cvl *cvl;
                      struct GRlc_path *path; IGRint *path_position)
{
  IGRlong OM_stat=OM_S_SUCCESS, EMmsg=EMS_S_Success;
  extern OMuint OM_Gf_verbose_warning;

  if (OM_Gf_verbose_warning)
  {
    fprintf(stderr,"WARNING: Located EMSdprparam (%d)...deleting it\n", my_id);
  }

  OM_stat = om$send(msg = message EMSdprparam.EMdelete(&EMmsg, NULL),
                    targetid = my_id);
  EMWRAPUP(EMmsg, OM_stat, "dprparam.loc_owner")                      
  return(GR_I_NO_RESPONSE);
}                      

#define CHG_ID_BUFF_INCR  10

method EMputGetChangedId(IGRlong *EMmsg; IGRint  *num_ids; GRobjid **ids;
                         IGRushort options)
/*
Description
    This message will get, put, or delete modified ids in the active states ids
    vla.  This is used for delayed evaluation where the modified/replaced nodes
    are not known.

Returned values
    EMSS_S_Success if all is well.

Notes
    About parameters:
        options - EMputGetChangedId_PUT - Put the specified ids in the active  
                                          id. 
                                          num_ids and ids MUST be provided.
                  EMputGetChangedId_DELETE - Delete the specified ids OR ALL
                                             if num_ids == NULL.
                  NULL - Return the ids. 
                         num_ids and ids MUST be provided.
                         If ids == NULL then only the num_ids will be returned.
 
History
    04/14/91 DLB Move to EMSdprparam, no longer put on end of ids vla.
    12/05/90 DLB Handle case of 0 size vla.
    11/26/90 DLB If all changed ids are deleted, then remove markers also.
    05/31/90 DLB Creation.
*/ 
{
  *EMmsg = EMS_S_Success;

  if (options & EMputGetChangedId_PUT)
  {
    if (! *num_ids) goto wrapup;

    if (!ME.EMSdprparam->chg_ids)
    {
      ME.EMSdprparam->chg_ids = (GRobjid *) om$malloc
                                (size = *num_ids * sizeof(GRobjid));
    }
    else
    {
      ME.EMSdprparam->chg_ids = (GRobjid *) om$realloc
                             (ptr = (IGRchar *)ME.EMSdprparam->chg_ids,
                              size = (ME.EMSdprparam->num_chg_ids + *num_ids) *
                                     sizeof(GRobjid));        
    }

    if (!ME.EMSdprparam->chg_ids)
    {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}

    OM_BLOCK_MOVE(*ids, 
                  &ME.EMSdprparam->chg_ids[ME.EMSdprparam->num_chg_ids],
                  *num_ids * sizeof(GRobjid));

    ME.EMSdprparam->num_chg_ids += *num_ids;
  }
  else if (options & EMputGetChangedId_DELETE)
  {
    IGRint num_chg_ids;

    num_chg_ids = ME.EMSdprparam->num_chg_ids;  /*compiler efficiency.*/

    if (!num_chg_ids) goto wrapup;

    if (num_ids)
    {
      IGRint ii, jj;

      for(ii=0; ii<num_chg_ids;)        /*NO INCREMENT!*/
      {
        for(jj=0; jj<*num_ids; jj++)
        {
          if (ME.EMSdprparam->chg_ids[ii] == (*ids)[jj])
          {
            if (ii != num_chg_ids - 1)
            {
              OM_BLOCK_MOVE(&ME.EMSdprparam->chg_ids[ii+1],
                            &ME.EMSdprparam->chg_ids[ii],
                            (num_chg_ids-ii-1) * sizeof(GRobjid));
            }
            num_chg_ids--;
            break;
          }
        }
        if (jj == *num_ids) ii++;
      }
    }
    else num_chg_ids = 0;  /*Remove all of 'em.*/

    if (num_chg_ids)
    {
      ME.EMSdprparam->chg_ids = (GRobjid *) om$realloc
                        (ptr = (IGRchar *)ME.EMSdprparam->chg_ids,
                         size = num_chg_ids * sizeof(GRobjid));
      if (!ME.EMSdprparam->chg_ids) 
      {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}
    }
    else
    {
      if (ME.EMSdprparam->chg_ids) om$dealloc(ptr = ME.EMSdprparam->chg_ids);
      ME.EMSdprparam->chg_ids = NULL;
    }
    ME.EMSdprparam->num_chg_ids = num_chg_ids;
  }
  else /*GET ids*/
  {
    IGRint num_chg_ids;

    num_chg_ids = ME.EMSdprparam->num_chg_ids; /*compiler opt.*/

    *num_ids = num_chg_ids;

    if (!num_chg_ids) goto wrapup;

    if (! ids) goto wrapup;

    if (! *ids)
    {
      *ids = (GRobjid *) om$malloc(size = num_chg_ids * sizeof(GRobjid));
      if (! *ids) {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}
    }

    OM_BLOCK_MOVE(ME.EMSdprparam->chg_ids,
                  *ids, 
                  num_chg_ids * sizeof(GRobjid));
  }  

wrapup:
  if (!(1 & *EMmsg))
  {
    EFprintcode(0, *EMmsg);
    fprintf(stderr,"EMSdprparam.EMpgchgid\n");
  }
  return(OM_S_SUCCESS);
}


method EMsetStatus(IGRlong *EMmsg; IGRboolean clear; OMuword status)
/*
Description
    This message will set the status bits in the status instance data of
    the EMSdprparam object.

Returned values
    EMSS_S_Success if all is well.

Notes
    About parameters:
      clear - If TRUE clear the specified bits.
 
History
    06/26/91    DLB     Creation.
*/ 
{
  *EMmsg = EMS_S_Success;

  if (clear) ME.EMSdprparam->status &= ~status;
  else  ME.EMSdprparam->status |= status;

  return(OM_S_SUCCESS);
}

method EMgetStatus(IGRlong *EMmsg; OMuword *status)
/*
Description
    This message will get the status bits in the status instance data of
    the EMSdprparam object.

Returned values
    EMSS_S_Success if all is well.

Notes
 
History
    06/26/91    DLB     Creation.
*/ 
{
  *EMmsg = EMS_S_Success;

  *status =  ME.EMSdprparam->status;

  return(OM_S_SUCCESS);
}

end implementation EMSdprparam;
