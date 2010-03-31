/*

Name
  EFrefpln.I

Description
  Reference Plane utilities.

Notes


*/
class implementation EMSdatpln;

#include "EMSdpb.h"
#include "EMSdatumdef.h"
#include "EMdtmacros.h"
#include "FI.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "exmacros.h"
#include "emsdef.h"


/* index of button on menu bar displaying the current mapping */
#define REF_PLN_BUTTON            28

/* indices for the on and off symbols in SPbar.sym */
/* #define ON_SYMBOL               3  */
/* #define OFF_SYMBOL              18 */

/*
 * indices for the locked and  unlocked from MDheaderO.sym
 * 3/12/93 shelley heard TR # 119301998
 */
#define ON_SYMBOL                4    /* locked   */
#define OFF_SYMBOL               6    /* unlocked */
#define ACTIVE_COLOR             2
#define CURRENT_COLOR            1


int EFref_plane_lock(msg, options, mode)
IGRlong *msg;
unsigned int options;
IGRint *mode;
{
 IGRlong sts, msg_loc;
 struct EMdpbinfo dpbinfo;
 void GRdisplay_refpln_symbol();
 extern Form GRgetbarmenu();

 sts = 1;
 *msg = MSSUCC;

 dpbinfo.props = 0;
 EMdpb_getinfo (&msg_loc, &dpbinfo);
 if (!(1&msg_loc)) return (OM_E_ABORT);

 if (options & EMS_REF_PLANE_LOCK_INQ)
 {
  if (!mode)
  {
   *msg = MSFAIL;
   goto wrapup;
  }

  if (dpbinfo.props & EMDPB_REF_LOCK_ON)
   *mode = EMS_REF_PLANE_LOCK_ON;
  else
   *mode = EMS_REF_PLANE_LOCK_OFF;
 }
 else if (options & EMS_REF_PLANE_LOCK_SET)
 {
   if (options & EMS_REF_PLANE_LOCK_ON)
   {
     struct GRid datplanid;

     datplanid.objid = NULL_OBJID;
     ems$get_active_datum_plane(msg = &msg_loc,
                                datpln = &datplanid);
     if (!(1&msg_loc)) return (OM_E_ABORT);

     if (datplanid.objid != NULL_OBJID)
     {
       dpbinfo.props |= EMDPB_REF_LOCK_ON;
       EFref_pln_lock_onoff(&msg_loc, 0x2);
       EMdpb_putinfo(&msg_loc, &dpbinfo);
       (void) GRdisplay_refpln_symbol(1);
     }
     else
     {
       msg_loc = MSINARG;
       goto wrapup;
     }
   }
  else if (options & EMS_REF_PLANE_LOCK_OFF)
  {
   dpbinfo.props &= ~EMDPB_REF_LOCK_ON;
   EFref_pln_lock_onoff(&msg_loc, 0x1);
   EMdpb_putinfo(&msg_loc, &dpbinfo);
   (void) GRdisplay_refpln_symbol(0);
  }
  else if (options & EMS_REF_PLANE_LOCK_TOGGLE)
  {
   if (dpbinfo.props & EMDPB_REF_LOCK_ON)
   {  
     sts = EFref_plane_lock(&msg_loc, 
                             EMS_REF_PLANE_LOCK_SET | EMS_REF_PLANE_LOCK_OFF, 
                             (int *) NULL );
     if (!(1&msg_loc)) goto wrapup;
   }
   else
   {
     sts = EFref_plane_lock(&msg_loc,
                             EMS_REF_PLANE_LOCK_SET | EMS_REF_PLANE_LOCK_ON, 
                             (int *) NULL );
     if (!(1&msg_loc)) goto wrapup;
   }
  }
 }

wrapup:
 if (msg_loc == MSINARG)
 {
  *msg = msg_loc;
  sts = 0;
 }
 else if (!(1&msg_loc))
 {
  *msg = MSFAIL;
  sts = 0;
 }

 return (sts);
}


/*

Name
  GRdisplay_refpln_symbol

Abstract
  Sets the reference plane lock symbol on the bar menu to reflect the state of the
  lock.
  
Synopsis
  void GRdisplay_refpln_symbol( int on; )
  
Description

Notes

Index

Keywords
  reference plane, menu, locks

History
  --/--/-- : unknown          : created
  03/15/93 : Shelley R. Heard : changed the lock icon display for the new interface
                                delivered in the 2.2 release.
 */

void GRdisplay_refpln_symbol(on)
int on;
{
  Form   menu_bar;
  int    sts, 
         button_label,
         index; 
  extern Form GRgetbarmenu();
  
  /* get the menu bar form id */

  menu_bar = NULL;
  menu_bar = GRgetbarmenu();
/*  sts = FI_get_form_by_name("BAR_MENU", &menu_bar); */
  if (menu_bar == NULL)
  {
      return;
  }

  /* command key for icon id changed in 2.2 interface (3/93) */
  sts = GRfind_button_on_menu_bar("MDSlAcRfPl", &menu_bar, &button_label);
  if (!sts)
  {
   return;
  }

  if (on)
   index = ON_SYMBOL;
  else
   index = OFF_SYMBOL;

  /* change the symbol on the button */

  FIg_set_symbol_index (menu_bar, button_label, index);
  FIg_set_state_off(menu_bar, button_label);
  FIg_set_off_color(menu_bar, button_label, FI_BLACK);
  FIg_display(menu_bar, button_label);

  return;
}

/*
 * This function defines the construction plane and turns it on in all
 * windows where it makes sense.
 */
int EFconstruction_plane_on(msg, options, inmx)
IGRlong *msg;
unsigned int options;
IGRdouble *inmx;
{
 IGRlong sts, loc_msg;
 IGRint flags[2],i;
 IGRlong num_bytes, error;
 struct var_list var_list[3];
  
 IGRint num_ret, total;
 struct GRid windows_GRid[32];
 sts = 1;

 *msg = MSSUCC;
 loc_msg = MSSUCC;

/*
 * Get all the windows
 */

 sts = dp$get_gragad_id (msg = &loc_msg,
                         name = "*",
                         array_size = 32,
                         total_num = &total,
                         numberofids = &num_ret,
                         found_GRids = windows_GRid);
 if (!(1&sts&loc_msg)) goto wrapup;
                       
 if (total != num_ret)
 {
  *msg = MSINARG;
  goto wrapup;
 }
 var_list[0].var = GRAGAD_FLAGS;
 var_list[0].var_ptr = (IGRchar *)flags;
 var_list[0].num_bytes = sizeof (IGRint) * 2;
 var_list[0].bytes_returned = &num_bytes;

 var_list[1].var = CONSTRUCT_PLANE;
 var_list[1].var_ptr = (IGRchar *) inmx;
 var_list[1].num_bytes = sizeof (IGRdouble) * 16;
 var_list[1].bytes_returned = &num_bytes;
 
 var_list[2].var = END_PARAM;

 flags[0] = CONST_PL_DEF | CONST_PLANE_ON | VALID_ALT_INV;
 flags[1] = flags[0];

 for (i=0;i<num_ret;i++)
 {
   dp$inq_set_gragad(msg = &loc_msg,
                        inq0_set1=1,
                        which_error = &error,
                        var_list = var_list,
                        osnum = windows_GRid[i].osnum,
                        gragad_objid = windows_GRid[i].objid,
                        calc_info = 1,
                        update = 0);
 }

wrapup:
 if (!(1&sts&loc_msg)) *msg = MSFAIL;
 return (sts);
}

/*
 * This function turns the construction plane on, if it is off and, off
 * if it is on.
 * If options is set to 0x1 : then it turns the lock off
 * else if optinos is set to 0x2: then it turns the lock on.
 */
int EFref_pln_lock_onoff(msg, options)
IGRlong *msg;
unsigned int options;
{
 IGRlong loc_sts, sts, loc_msg;
 IGRint set_flags[2], inq_flags,i;
 IGRlong num_bytes, error;
 struct var_list var_list[3];
 IGRint num_ret, total;
 struct GRid windows_GRid[32];
 sts = 1;

 *msg = MSSUCC;
 loc_msg = MSSUCC;

/*
 * Get all the windows
 */

 sts = dp$get_gragad_id (msg = &loc_msg,
                         name = "*",
                         array_size = 32,
                         total_num = &total,
                         numberofids = &num_ret,
                         found_GRids = windows_GRid);
 if (!(1&sts&loc_msg)) goto wrapup;
                       
 if (total != num_ret)
 {
  *msg = MSINARG;
  goto wrapup;
 }
 var_list[0].var = GRAGAD_FLAGS;
 var_list[0].bytes_returned = &num_bytes;
 
 var_list[1].var = END_PARAM;

 for (i=0;i<num_ret;i++)
 {
   var_list[0].var_ptr = (char *) &inq_flags;
   var_list[0].num_bytes = sizeof (IGRint);
   loc_sts  = dp$inq_set_gragad(msg = &loc_msg,
                     which_error = &error,
                     var_list = var_list,
                     gragad_objid = windows_GRid[i].objid);
   if (loc_sts & 1)
   {
    if ((inq_flags & CONST_PL_DEF) &&
        (options & 0x1))
    {
     set_flags[0] = CONST_PLANE_ON | VALID_ALT_INV;
     set_flags[1] = 0;
    }
    else
    {
      if ((inq_flags & CONST_PL_DEF) &&
          (options & 0x2))
      {
       set_flags[0] = CONST_PLANE_ON | VALID_ALT_INV;
       set_flags[1] = set_flags[0];
      }
    }

    if (inq_flags & CONST_PL_DEF)
    {
      var_list[0].var_ptr = (char *) set_flags;
      var_list[0].num_bytes = sizeof (IGRint) * 2;

      dp$inq_set_gragad(msg = &loc_msg,
                        inq0_set1 = 1,
                        which_error = &error,
                        var_list = var_list,
                        gragad_objid = windows_GRid[i].objid,
                        calc_info = 1,
                        update = 0);
    }
   }
 }

wrapup:
 if (!(1&sts&loc_msg)) *msg = MSFAIL;
 return (sts);
}


/*
 * This function will suppress a reference plane if there is a profile
 * depending on it.
 *
 * History 
 * Creation : PP : 06/26/92
 */

int EFsuppress_reference_plane(msg, options, datum_id,datum_os)
IGRlong *msg;
IGRint options;
OM_S_OBJID datum_id;
OMuword datum_os;
{
 IGRlong status;
 IGRint i;
 OMuint child_count;
 OM_S_OBJID childid;
 OMuword childos;
 OM_S_CHANSELECT children;
 extern OMuword OPP_SKmgr_class_id;

 status = OM_S_SUCCESS;
 *msg = MSSUCC;

 EMmake_chanselect (NDchildren_children, &children);

 status = om$get_channel_count(p_chanselect = &children,
                               objid = datum_id,
                               osnum = datum_os,
                               count = &child_count);
 if (!(1&status)) goto wrapup;

 for (i=0;i<child_count;i++)
 {
   status = om$get_objid_at_index(objid = datum_id,
                                  osnum = datum_os,
                                  p_chanselect = &children,
                                  objidaddr = &childid,
                                  osnumaddr = &childos,
                                  index = i);
   if (!(1&status)) goto wrapup;

   if (EFisAncestryValid(msg, childid, childos,
                          OPP_SKmgr_class_id, FALSE))
   {

    IGRint bytes_in, bytes_out;
    struct GRid  mod_GRid;
    struct GRmd_env display_env;
    enum GRdpmode dpmode;
    
    dpmode = GRbe;
    ex$get_cur_mod(id = &mod_GRid.objid, osnum = &mod_GRid.osnum);

    bytes_in = sizeof(display_env);
    gr$get_display_env(
      msg = msg,
      sizbuf = &bytes_in,
      buffer = &display_env,
      nret = &bytes_out);

    dpmode = GRbe;
    om$send (msg = message GRgraphics.GRdisplay(msg, 
                &display_env.md_env.matrix_type,
                 display_env.md_env.matrix,
                 &dpmode,
                 &mod_GRid),
          senderid = NULL_OBJID,
          targetid = datum_id,
          targetos = datum_os);

     status = om$send (msg = message EMSdatpln.EMtoggle_on_off(msg,
                             EMS_OPT_OFF),
                       senderid = NULL_OBJID,
          targetid = datum_id,
          targetos = datum_os);
     break;
   }
 }

wrapup:
 return (status);
}

/*
Name
        EFswap_bar_menu_callback

Description
        This function is called when the bar menu is swapped. It sets the
        reference plane icon to reflect the state of reference plane lock.
        The method EMSdpb.wake_up arranges to have this function called.

History
        mrm     04/07/93    creation
*/

#argsused
void EFswap_bar_menu_callback(char *name, Form form)
{
    int sts, mode;
    long msg;

    sts = ems$ref_plane_lock(msg = &msg,
                             options = EMS_REF_PLANE_LOCK_INQ,
                             mode = &mode);
    if (sts & msg & 1)
    {
        mode = (mode == EMS_REF_PLANE_LOCK_ON) ? TRUE : FALSE;
        GRdisplay_refpln_symbol(mode);
    }
}

end implementation EMSdatpln;
