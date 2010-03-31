class implementation EMSdatplnmgr;

#include <stdio.h>
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "OMmacros.h"
#include "EMSdpb.h"
#include "exmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "EMSdatumdef.h"
#include "EMdtmacros.h"
#include "emsdef.h"

#include "actparam.h"

from EMSdatpln import EMput_pln_info, EMget_pln_info;
from EMSdatpln import EMcreate_resize_handle, EMtoggle_on_off;
from GRvg import GRchgweight;
from GRgraphics import GRgetprops;
from expression import NDgive_value;
from GRvg import GRgetsymb;

extern OMuword OPP_EMSdatpln_class_id;

static IGRboolean aflag;
static GRspacenum osn;
static struct GRmd_env rfenv;


method super_construct ()
/* *********************************************************************

Description
 This method initialises the datum plane manager object. This also
 constructs the three datum planes associated with the base 
 coordinate system by default.

Notes
 Always has a return status of OM_S_SUCCESS;

History
 PP  : 07/04/91                Creation.
******************************************************************** */
{
 IGRlong status;
 int i;
 IGRlong EMmsg;
 OM_S_OBJID datpln_id;
 IGRdouble *xptr, *yptr, *zptr;
 IGRdouble xdir[3],def_size;
 IGRdouble ydir[3];
 IGRdouble zdir[3];
 IGRdouble origin[3];
 OM_S_OBJID expid;
 OMuword expos;
 struct GRmd_env loc_mdenv;
 struct IGRdisplay loc_disp;
 struct GRvg_construct construct_list;

 EMmsg = MSSUCC;
 status = OM_S_SUCCESS;

 ME.EMSdatplnmgr->props = 0;
 ME.EMSdatplnmgr->default_size = 5;
 ME.EMSdatplnmgr->num_datums = 0;

 /* Initialise associative subsystem */
 ASsuper_construct();

 status = di$translate(objname="def_refpln_size",
                       p_objid = &expid,
                       p_osnum = &expos);
 if (status == DIR_S_SUCCESS)
 {
  status = om$send (msg = message expression.NDgive_value(&def_size),
                          targetid = expid,
                          targetos = expos);
  ME.EMSdatplnmgr->default_size = def_size;
 }
 else
  def_size = ME.EMSdatplnmgr->default_size;
              

 me->active_datum = NULL_OBJID;
 for (i=0;i<3;i++)
 {
  xdir[i] = 0.0;
  ydir[i] = 0.0;
  zdir[i] = 0.0;
  origin[i] = 0.0;
 }
 xdir[0] = 1.0;
 ydir[1] = 1.0;
 zdir[2] = 1.0;


 construct_list.msg = &EMmsg;
 construct_list.env_info = &loc_mdenv;;
 construct_list.newflag = FALSE;
 construct_list.level = 0;
 construct_list.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE;
 construct_list.geometry = NULL;
 construct_list.display = &loc_disp;
 construct_list.class_attr = NULL;
 construct_list.name = NULL;

 {
  IGRint bytes_in, bytes_out;
  IGRlong msg_loc;

  bytes_in = sizeof (struct GRmd_env);
  gr$get_module_env (msg = &msg_loc, sizbuf = &bytes_in, 
    buffer = construct_list.env_info, nret = &bytes_out);

  bytes_in = sizeof (IGRshort);
   gr$get_active_level (msg = &msg_loc, sizbuf = &bytes_in,
    buffer = &construct_list.level, nret = &bytes_out);

  bytes_in = sizeof (struct IGRdisplay);
    gr$get_active_display (msg = &msg_loc, sizbuf = &bytes_in,
     buffer = construct_list.display, nret = &bytes_out);
 }

 construct_list.display->weight = INACTIVE_DATUM_WEIGHT;
 construct_list.display->style = DATUM_STYLE;
  
 for (i=0;i<3;i++)
 {
  switch (i)
  {
   case 0:
    xptr = xdir;
    yptr = ydir;
    zptr = zdir;
   break;

   case 1:
    xptr = ydir;
    yptr = zdir;
    zptr = xdir;
   break;

   case 2:
    xptr = xdir;
    yptr = zdir;
    zptr = ydir;
    zptr[1] = -1.0;
   break;
  }

  status = om$construct(classid = OPP_EMSdatpln_class_id,
                        p_objid = &datpln_id);
  if (!(1&status&EMmsg)) goto wrapup;

  status = om$send (msg = message EMSdatpln.EMput_pln_info(&EMmsg,
                         EMS_OPT_SET_EXTERNAL_CONSTRAINT,
                         construct_list.env_info,
                         xptr,
                         yptr,
                         zptr,
                         origin,
                         EMS_BASE_REFERENCE_PLANE),
                    targetid = datpln_id);
  if (!(1&status&EMmsg)) goto wrapup;

  ME.EMSdatplnmgr->datum_id[i] = datpln_id;
  ++(ME.EMSdatplnmgr->num_datums);

  om$send (msg = message EMSdatpln.EMcreate_resize_handle(&EMmsg,
                          NULL,
                          construct_list.env_info,
                          &construct_list,
                          def_size,
                          def_size,
                          NULL),
                    targetid = datpln_id);
  if ((i==2) &&
      (!(ex$is_invis(mod_osnum = OM_Gw_current_OS)))) 
  {
   om$send (msg = message EMSdatplnmgr.EMactivate(&EMmsg,NULL, &datpln_id,NULL),
                  targetid = my_id);
  }
 }

wrapup:
 if (!(1&status&EMmsg))
 {
  fprintf (stderr,"Error in creating datum plane manager");
 }
 return (OM_S_SUCCESS);
}


method wake_up()
{
 IGRint i=0;
 IGRlong sts,msg_loc;
   /*
    * Since we don't use channels here, we have to do our own cleanup
    * of deleted elements (Shelley 10/3/92)

    * Added an additional check to see if the datum entity is indeed a 
    * subclass of a reference plane.
    * Moved the code from EMget_datums to wake_up.
    * pp (10/15/92)
    */

 if (!(ex$is_invis(mod_osnum = OM_Gw_current_OS))) 
 {
  while (TRUE)
  {
   if (i>=(me->num_datums))
    break;

   sts = om$is_objid_valid ( objid = me->datum_id[i] );
   if (1 & sts)
   {
    if (!(EFisAncestryValid(&msg_loc, me->datum_id[i], OM_Gw_current_OS,
                          OPP_EMSdatpln_class_id, FALSE)))
     sts = 0;
   }

   if ( !(sts & 1) )
   {
     int ndx, limit;
       /*
        * shift id's in vla from (i+1) to (me->num_datums-1) to the slot
        * before.  Then reduce the size of the vla by one.  If the bogus id
        * is the last id in the vla (e.g. me->datum_id[me->num_datums-1]),
        * then we want to break out of the for loop.
        */
       limit = me->num_datums-1;
       for (ndx=i; ndx < limit ; ndx++)
       {
         me->datum_id[ndx] = me->datum_id[ndx+1];
       }
       --me->num_datums;
/*
 * Just a safety check 
 */
       if (me->num_datums < 0) me->num_datums = 0;
     }
     else 
       i++;
   }
  }
 return (OM_S_SUCCESS);
}

method global_class.sleep(IGRint type)
{
 return(OM_S_SUCCESS);
}

method delete (IGRint defer_flag)
{
/*
 * This object cannot be deleted
 */

 return(OM_S_SUCCESS);
}

method EMget_info (IGRlong *EMmsg; 
                    unsigned int options;
                    unsigned int *props;
                    IGRdouble *default_size;
                    OM_S_OBJID *active_datum;
                    int *num_datums)
{
 IGRlong status;
 *EMmsg = MSSUCC;
 status = OM_S_SUCCESS;

 if (props)
  *props = ME.EMSdatplnmgr->props;

 if (default_size)
 {
  OM_S_OBJID expid;
  OMuword expos;

  *default_size = me->default_size;

aflag = pwIsActivationOn();
if (aflag)
{
  osn = pwGetActiveOs();
  status = di$translate(objname="def_refpln_size",
                        osnum = osn,
                       p_objid = &expid,
                       p_osnum = &expos);
}
else
{

  status = di$translate(objname="def_refpln_size",
                       p_objid = &expid,
                       p_osnum = &expos);
}
  if (status == DIR_S_SUCCESS)
  {
   status = om$send (msg = message expression.NDgive_value(default_size),
                           targetid = expid,
                           targetos = expos);
   }
 }

 if (active_datum)
  *active_datum = me->active_datum;

 if (num_datums)
  *num_datums = me->num_datums;

 return (OM_S_SUCCESS);
}

method EMactivate(IGRlong *EMmsg;
                  unsigned int options;
                  OM_S_OBJID *new_datum;
                  OM_S_OBJID *old_datum)
{
 IGRuchar weight;
 IGRint msg_loc;
 struct EMdpbinfo dpbinfo;
 IGRlong status;
 IGRdouble *rfmx;
 IGRmatrix rot_mx;
 IGRint rfmx_type;
 long one = 1;
 
 *EMmsg = MSSUCC;
 status = OM_S_SUCCESS;

 if (old_datum)
  *old_datum = me->active_datum;

 if ((me->active_datum != NULL_OBJID) &&
     (!(options & EMS_OPT_DEACTIVATE)))
 {
   weight = INACTIVE_DATUM_WEIGHT;

  aflag = pwIsActivationOn();
  if (aflag)
  {
   osn = pwGetActiveOs();
   EFsuppress_reference_plane(EMmsg, NULL, me->active_datum, osn);
   status = om$send (msg = message GRvg.GRchgweight(EMmsg,&weight),
                  targetid = me->active_datum,
                  targetos = osn);
   if (!(1&status&*EMmsg)) goto wrapup;
  }
  else
  {

   EFsuppress_reference_plane(EMmsg, NULL, me->active_datum, OM_Gw_current_OS);
   status = om$send (msg = message GRvg.GRchgweight(EMmsg,&weight),
                  targetid = me->active_datum);
   if (!(1&status&*EMmsg)) goto wrapup;
  }



   me->active_datum = NULL_OBJID;

 }

 if (!(options & EMS_OPT_DEACTIVATE) && new_datum && 
      (*new_datum != NULL_OBJID))
 {
  IGRint i, lock_mode;
  IGRdouble mx[16], xdir[3], ydir[3], zdir[3], origin[3];
  

  aflag = pwIsActivationOn();
  if (aflag)
  {
     osn = pwGetActiveOs();
  }

  for (i=0;i<16;i++)
   mx[i] = 0.0;

  mx[0] = mx[5] = mx[10] = mx[15] = 1.0;
  me->active_datum = *new_datum;
  weight = ACTIVE_DATUM_WEIGHT;

  if (aflag)
  {
     status = om$send (msg = message GRvg.GRchgweight(EMmsg,&weight),
                       targetid = *new_datum,
                       targetos = osn);
     if (!(1&status&*EMmsg)) goto wrapup;
  }
  else
  {
     status = om$send (msg = message GRvg.GRchgweight(EMmsg,&weight),
                      targetid = *new_datum);
     if (!(1&status&*EMmsg)) goto wrapup;
  }

/*
 * Make sure the active object is displayable and locatable. This is
 * to be fault tolerant.
 */

  if (aflag)
  {
     status = om$send (msg = message EMSdatpln.EMtoggle_on_off(EMmsg,
                             EMS_OPT_ON),
                       targetid = *new_datum,
                       targetos = osn);
     if (!(1&status&*EMmsg)) goto wrapup;
  }
  else
  {
     status = om$send (msg = message EMSdatpln.EMtoggle_on_off(EMmsg,
                             EMS_OPT_ON),
             targetid = *new_datum);
     if (!(1&status&*EMmsg)) goto wrapup;
  }

  lock_mode = 0;

  ems$ref_plane_lock(msg = EMmsg,
                     options = EMS_REF_PLANE_LOCK_INQ,
                     mode = &lock_mode); 


  if (aflag)
  {
     status = pwGetActiveModuleEnv(&rfenv);

     status = om$send (msg = message EMSdatpln.EMget_pln_info(EMmsg,
                          NULL,
                          &rfenv,
                          xdir,
                          ydir,
                          zdir,
                          origin,
                          NULL),
                       targetid = *new_datum,
                       targetos = osn);
     if (!(1&status&*EMmsg)) goto wrapup;
  }
  else
  {
     status = om$send (msg = message EMSdatpln.EMget_pln_info(EMmsg,
                          NULL,
                          NULL,
                          xdir,
                          ydir,
                          zdir,
                          origin,
                          NULL),
                       targetid = *new_datum); 
     if (!(1&status&*EMmsg)) goto wrapup;
  }

  for (i=0;i<3;i++)
  {
   mx[0+i] = xdir[i];
   mx[4+i] = ydir[i];
   mx[8+i] = zdir[i];
   mx[3+4*i] = origin[i];
  }



  status = EFconstruction_plane_on(EMmsg,NULL,mx);
  EMdpb_getinfo (&msg_loc, &dpbinfo);
  if (!(dpbinfo.props & EMDPB_REF_LOCK_ON))
   status =  EFref_pln_lock_onoff(&msg_loc, 0x1);
 }

wrapup:
 return (status);
}

method EMget_datums(IGRlong *EMmsg;
                     unsigned int options;
                     int *datum_count;
                     struct GRid *datum_GRids)

/* *******************************************************************
Description
 This message gets the datums managed by the datum plane manager.
 The following options are supported: 
  EMS_OPT_OFF_DATUMS:  Datums whose display has been turned off.
  EMS_OPT_ON_DATUMS :  Datums whose display has been turned on
  EMS_OPT_HIDDEN_DATUMS : Datums which are hidden from the user.
  EMS_OPT_BASE_DATUMS:    Datums which correspond to the base datum
                          planes

Arguments
 EMmsg : Completion code
 options : See above.
 datum_count : The number of datums that meet the specified option criteria
 datum_GRids : The grids of datums. Can be set to NULL if not interested.
               Otherwise enough memory is assumed to have been passed.

Related files:
 EMSdatumdef.h

Notes
 Upon exit the completion code will be one of the following:
 MSSUCC : If all goes well.
 MSFAIL : If there is failure
********************************************************************** */
{
 IGRboolean valid;
 IGRlong sts,i;
 IGRshort props;
 IGRuint datum_props;

 osn = OM_Gw_current_OS;

 aflag = pwIsActivationOn();
 if (aflag)
 {
    osn = pwGetActiveOs();
 } 

 sts = OM_S_SUCCESS;
 *EMmsg = MSSUCC;
 *datum_count = 0;

 for ( i=0; i < me->num_datums; i++ )
 {
   props = 0;
   valid = FALSE;
  
   sts = om$send (msg = message GRgraphics.GRgetprops(EMmsg,&props),
                  senderid = me->datum_id[i],
                  p_chanselect = &AS_to_comp);
   if ((sts == OM_I_CHAN_EMPTY) || (sts == OM_W_UNKNOWN_MSG))
   {
     sts = OM_S_SUCCESS;
   }

   if (!(1&sts&*EMmsg)) goto wrapup;

   sts = om$send (msg = message EMSdatpln.EMget_pln_info(
			   EMmsg,
			   NULL,
                           NULL,
			   NULL,
			   NULL,
			   NULL,
	 		   NULL, 
			  &datum_props),
                  targetid = me->datum_id[i],
                  targetos = osn);
   if (!(1&sts&*EMmsg)) goto wrapup;

   if (options & EMS_OPT_OFF_DATUMS)
   {
   /*
    * Only return those datums for which there does not exist a profile as
    * a dependent.
    */
  if (!(props & GRIS_LOCATABLE)  && !(props & GRIS_DISPLAYABLE))
    valid = TRUE;

#if SUPPRESS
  if (valid)
  {
    IGRint ii;
    OMuint child_count;
    OM_S_OBJID childid;
    OMuword childos;
    OM_S_CHANSELECT children;
    extern OMuword OPP_SKmgr_class_id;

    EMmake_chanselect (NDchildren_children, &children);

    sts = om$get_channel_count(p_chanselect = &children,
                                  objid = me->datum_id[i],
                                  osnum = osn,
                                  count = &child_count);
    if (!(1&sts)) goto wrapup;

    for (ii=0;ii<child_count;ii++)
    {
      sts = om$get_objid_at_index(objid = me->datum_id[i],
                                  osnum = osn,
                                     p_chanselect = &children,
                                     objidaddr = &childid,
                                     osnumaddr = &childos,
                                     index = ii);
      if (!(1&sts)) goto wrapup;

      if (EFisAncestryValid(EMmsg, childid, childos,
                          OPP_SKmgr_class_id, FALSE))
      {
        valid = FALSE;
        break;
      }
     }
   } 
#endif
  }

  if (options & EMS_OPT_ON_DATUMS)
  {
   if ((props & GRIS_LOCATABLE)  && (props & GRIS_DISPLAYABLE))
    valid = TRUE;
  }

  if (options & EMS_OPT_HIDDEN_DATUMS)
  {
   if (datum_props & EMS_HIDDEN_REFERENCE_PLANE)
    valid = TRUE;
  }

  if (options & EMS_OPT_BASE_DATUMS)
  {
   if (datum_props & EMS_BASE_REFERENCE_PLANE)
    valid = TRUE;
  }
  
  if (valid)
  {
   if (datum_GRids)
   {
    if (aflag)
    {
      datum_GRids[*datum_count].objid = me->datum_id[i];
      datum_GRids[*datum_count].osnum = osn;
    }
    else
    {
      datum_GRids[*datum_count].objid = me->datum_id[i];
      datum_GRids[*datum_count].osnum = OM_Gw_current_OS;
    }
   }
    ++(*datum_count);
  }
 }

wrapup:
 return (sts);
}

method EMmanage_datum_entry(IGRlong *msg;
                            unsigned int options;
                            OM_S_OBJID datum_id)
/* *******************************************************************

Description
 This message adds/deletes a datum  entry in the datum plane manager.

Arugments
 EMmsg : Completion code
 options : The following options are supported:
           EMS_OPT_ADD : Add an entry.      
           EMS_OPT_DELETE : Delete an entry
 datum_id :the id to be added or deleted.

Notes
 Upon exit the completion code will be one of the following:
  MSSUCC : If all goes well.
  MSFAIL : If there is failure

History
 pp : 07/16/91 : Creation
********************************************************************** */
{
 IGRlong sts;
 IGRint i,j;
 IGRint vla_size;

 sts = OM_S_SUCCESS;
 *msg = MSSUCC;

 if (options & EMS_OPT_ADD)
 {
   vla_size = OM_DIMENSION_OF(me->datum_id);

   if ((me->num_datums + 1) > vla_size)
     OM_SET_DIMENSION(me->datum_id,me->num_datums+1);
   me->datum_id[me->num_datums] = datum_id;
   ++(me->num_datums);

   if (options & EMS_OPT_ACTIVATE)
   {
    sts = om$send (msg = message EMSdatplnmgr.EMactivate(msg,
                         NULL,&datum_id,NULL),
                   targetid = my_id);
    if (!(1&sts&*msg)) goto wrapup;
   }
 }
 
 if (options & EMS_OPT_DELETE)
 {
  for (i=0;i<me->num_datums;i++)
  {
    if (me->datum_id[i] == datum_id)
    {
      for (j=i;j<me->num_datums;j++)
       me->datum_id[j] = me->datum_id[j+1];
      --(me->num_datums);
      break;
    }
  }
  if (me->active_datum == datum_id)
   me->active_datum = NULL_OBJID;
 }

wrapup:
 return (sts);
}
end implementation EMSdatplnmgr;
