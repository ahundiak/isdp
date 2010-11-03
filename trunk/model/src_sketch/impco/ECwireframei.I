class implementation ECwireframe;

#include <alloca.h>
#include "coniarray.h"
#include "coimport.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "ODE.h"
#include "ex.h"
#include "grmessage.h"
#include "exmacros.h"
#include "griomacros.h"
#include "DImacros.h"
#include "FI.h"
#include "lcmacros.h"
#include "grdpbmacros.h"
#include "EMSdatumdef.h"
#include "EMdtmacros.h"
#include <stdio.h>
#include <tools.h>
#include "msdef.h"
#include "msmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "dp.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "ASmessages.h"
#include "expression.h"
#include "expmacros.h"
#include "DIglob.h"
#include "grmsg.h"
#include "DIprims.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "comisc.h"
#include "SKdef.h"
#include "SKmacros.h"

/*----------------------------------------
 *    imports
 *----------------------------------------
 */

from GRvg 	import GRgeomprops;
from expression import NDgive_value;

method convert_to_profile ( long * sts )
{
  int                  status = OM_S_SUCCESS;
  OM_S_OBJECT_LINKAGE  ChannelLinkage[1];
  IGRint               NumberObjectsFound = 0;
  struct GRid          curve;
  IGRboolean           assoc_flag, aflag=0;

  /*
   *  srh  01/06/93 : if associativity is ON convert the wireframe
   *                   element (on const_chansel) to a profile.
   */
  status = gr$get_associative_flag ( buffer = &assoc_flag );
  if (assoc_flag)
  {
    status = lc$get_channel_objects(objid = my_id,
        p_chanselect = &me->const_chansel,
        list = ChannelLinkage,
        size = 1,
        count = &NumberObjectsFound );

    if ( NumberObjectsFound ) {

      curve.objid = ChannelLinkage[0].S_objid;
      curve.osnum = ChannelLinkage[0].osnum;
    
      if (aflag = pwIsActivationOn())
      {
        GRspacenum osn;
        osn = pwGetActiveOs();
        me->ModuleInfo.md_id.osnum = osn;
      }

      sk$convert_to_profile ( msg = sts,
                              options = SK_CONVERT_VERBOSE, 
                              module = &me->ModuleInfo, 
                              geometry = curve,
                              automask = SK_AUTO_GEOMETRIC);
    };
  }

  return OM_S_SUCCESS;
}

method show_assoc_mode(int flag)
{
  long msg_loc;
  IGRboolean assoc_flag;

  /*
   * Flag is TRUE on wakeup and FALSE for sleep.
   * Set the reference plane lock if the associativity flag is on.
   */

  if (flag == FALSE )
  {
    GRdisplay_associative_button(FALSE);
    if (!(me->prev_ref_lock_state))
      EFrefplane_lock_mgr(&msg_loc,NULL,FALSE,NULL);

  }
  else if (flag == TRUE)
  {
    ems$ref_plane_lock(msg = &msg_loc,
        options = EMS_REF_PLANE_LOCK_INQ,
        mode = &me->prev_ref_lock_state);
    gr$get_associative_flag ( buffer = &assoc_flag );
    if (assoc_flag)
    {
      EFrefplane_lock_mgr(&msg_loc,NULL,TRUE,&me->prev_ref_lock_state);
      GRdisplay_associative_button(TRUE);
    }
  }
  else
  {
    printf ("ECwireframe_COnpt_show_assoc_mode_method: bad parm value\n");
  }

  return OM_S_SUCCESS;
}

method construct_polygon( long *sts)
{
  long msg_loc;
  struct GRevent *events[NUMBER_OF_EVENTS];
  struct GRid  NewObjectsGrid; /* grid for the created polygon */

  /*
   *  set up the array of events so that the function that we
   *  called will know all the data points and values that the user
   *  has entered.
   */
  set_up_event_array;

  SKcreate_polygon(&msg_loc, 
      events, 
      &me->DisplayMode,
      FALSE,
      &me->ConstructInfo,
      NULL,
      NULL,
      me->AttributePointer,
      NULL,
      &NewObjectsGrid,
      NULL,
      me->const_class,
      OM_K_NOTUSING_CLASSID,
      OM_GS_NULL_NEIGHBOR,
      my_id,
      OM_Gw_current_OS);

  return OM_S_SUCCESS;

}



method wakeup_form (long *sts; int suppress_flag )
{
  extern int  FIf_set_notification_routine();
  extern int  FIg_erase();
  extern int  FIg_disable();
  extern void AutoProcessForm();
  extern void AutoUpdateCheckList ();
  extern void GRAutoSetAutoForm();

  GRAutoCreate ( NULL );
  GRAutoSetAutoForm(me->status_display_form_ptr);

  *sts = (int) GRAutoSuppress( me->status_display_form_ptr, suppress_flag );

  /* gadget 5 is the save-restore gadget - suppress it */
  FIg_erase   ( me->status_display_form_ptr, 5 );
  FIg_disable ( me->status_display_form_ptr, 5 );
  FIf_set_notification_routine( me->status_display_form_ptr, AutoProcessForm );
  AutoUpdateCheckList ();
  return OM_S_SUCCESS;
}

method delete(int f_defer_flag;)
{
  IGRlong status = OM_S_SUCCESS;
  extern void GRAutoSetAutoForm();

  GRAutoSetAutoForm(NULL);
  status = om$send( mode = OM_e_wrt_message,
      msg = message COnpt.delete( f_defer_flag ),
      targetid = my_id );
  return status;
}

%safe
static Form AutoForm = NULL;
static int  AutoMask = 0xff;
%endsafe


void AutoUpdateCheckList ()
/*
 * This procedure updates the check list according to the current mask setting.
 */
{
  int sMask;
  
  for (sMask = SK_AUTO_HORIZONTAL; sMask != SK_AUTO_LASTONE; sMask <<= 1)
    if (AutoMask & sMask)
      FIg_set_state_on ( AutoForm, sMask + 20 );
    else
      FIg_set_state_off ( AutoForm, sMask + 20 );
}


static void AutoPermanentWindow ()
/*
 * Transforms the form from a save/restore to a permanent window (so that other
 * forms can be activated).
 */
{
  FIf_cvrt_to_perm_win ( AutoForm );
  FIg_disable ( AutoForm, 5 );
}

#argsused
void AutoProcessForm ( FormLabel, GadgetLabel, Value )
int    FormLabel;
int    GadgetLabel;
IGRdouble Value;
{
  GRspacenum Osnum;
  char       Syntax [DI_PATH_MAX];
  GRobjid    Objid;
  int        Msg, sStatus, sMask;
  
  switch (GadgetLabel)
  {
    case 1:
      /*
       * Save the settings in IGENOD:AutoConstrain
       */
      ex$get_cur_mod ( osnum = &Osnum );
      di$cd ( osnum = Osnum, dirname = "IGENOD" );
      sprintf ( Syntax, "%d", AutoMask );
      sStatus = di$translate ( osnum = Osnum, path = "IGENOD",
        objname = "AutoConstrain", p_objid = &Objid );
      if (sStatus & 1)
      {
        exp$modify ( exp_name = "AutoConstrain", osnum = Osnum, exp_syntax = Syntax );
      }
      else
      {
        exp$create ( exp_name = "AutoConstrain", osnum = Osnum, exp_syntax = Syntax,
          p_exp_id= &Objid );
      }
      di$cd ( dirname = "-" );
      di$cd ( dirname = "." );

    case 4:
    {
      unsigned int   oid;
      unsigned short osnum;
      sStatus = FIf_get_cmd_oid_os( AutoForm, &oid, &osnum );
      if (sStatus == 0)
      {
        sStatus = om$send(
                  msg = message CEO.erase_form_by_label( STATUS_FORM, 
                                                         0,
                                                         (IGRint *) &Msg ),
                  senderid = NULL_OBJID,
                  targetid = oid,
                  targetos = osnum );
      }
      else
      {
	/*
	 *  Form has not command object running it
	 */
        FIf_erase ( AutoForm );
      }
      break;
    }

    case 5: 
      AutoPermanentWindow ();
      break;

    case 12:
      AutoMask = 0x00;
      for (sMask = SK_AUTO_HORIZONTAL; sMask != SK_AUTO_LASTONE; sMask <<= 1)
        FIg_set_state_off ( AutoForm, sMask + 20 );
      break;

    case 13:
      AutoMask = 0xff;
      for (sMask = SK_AUTO_HORIZONTAL; sMask != SK_AUTO_LASTONE; sMask <<= 1)
        FIg_set_state_on ( AutoForm, sMask + 20 );
      break;
    
    default:
      /*
       * We check all the possible constrains against GadgetLable + 20
       */
      for (sMask = SK_AUTO_HORIZONTAL; sMask != SK_AUTO_LASTONE; sMask <<= 1)
        if (GadgetLabel == sMask + 20)
        {
          if (AutoMask & sMask)
            AutoMask &= ~sMask;
          else    
            AutoMask |= sMask;
          break;
        }
  }

  if (AutoForm)
    AutoUpdateCheckList ();
}


int GRAutoMask()
/*
 * This routine returns the current mask (what constrains should be placed automatically)
 */
{
  return AutoMask;
}


int GRAutoCreate ( form )
  Form *form;
/*
 * This routine creates the auto-constrain form and returns its form id.
 */
{
  int        sStatus = OM_S_SUCCESS;
  GRspacenum Osnum;
  GRobjid    Objid;
  
  ex$get_cur_mod ( osnum = &Osnum );
  if (!AutoForm)
  {
    sStatus = di$translate ( osnum = Osnum, path = "IGENOD",
      objname = "AutoConstrain", p_objid = &Objid );
    if (sStatus & 1)
    {
      double DoubleMask = 0;

      om$send ( msg = message expression.NDgive_value ( &DoubleMask ),
          targetos = Osnum, targetid = Objid, senderid = NULL_OBJID );
      AutoMask = DoubleMask;
    }
    else
      AutoMask = 0xff;

    sStatus = FIf_new ( 0, "GRAutoCnstr", AutoProcessForm, &AutoForm );
    if (sStatus)
      sStatus = OM_E_ABORT;
    else
    {
      AutoUpdateCheckList ();
    }
  }

  if ( form ) 
  {
    *form = AutoForm;
  }

  return OM_S_SUCCESS;
}

int GRAutoSuppress( form, suppress_mask )
  Form  form;
  int   suppress_mask;
{
  int       sMask;
  extern int GRAutosMask();

  /*
   * We check all the possible constraint gadgets ; 
   * If the cooresponding mask bit is 0 
   *   then we unconditionally enable the gadget;  
   * If the cooresponding mask bit is 1 
   *   then we unconditionally disable the gadget;  
   */
  for (sMask = SK_AUTO_HORIZONTAL; sMask != SK_AUTO_LASTONE; sMask <<= 1)
  {
    if (suppress_mask & sMask)
    {
      FIg_disable( form, (sMask+20) );
    }
    else
    {
      FIg_enable( form, (sMask+20) );
    }
  }
  return OM_S_SUCCESS;
}

void GRAutoSetAutoForm(form)
Form form;
{
  AutoForm = form;
}

end implementation ECwireframe;
