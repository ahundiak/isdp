/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This file contains the wakeup, perform construction, 
 and perform duty methods for the cross hatch command.

 History

 09/10/87 : RC  : Creation Date
 12/03/87 : RC  : Modified for version 1.1.0 and 
                  also to cross hatch in both directions.
 07/28/88 : rlw : Rewrote the command to support identification of
                  curves with possible auto search.
 08/26/88 : rlw : Modified to erase surface before cross hatching, and
                  to redraw it on failure.  Also declared macro functions
                  as extern for 1.2.0 release.
 02/23/88 : RC  : Modified to add a hook for material cross
                  hatch pattern.
 04/17/89 : rlw : Modified to support material cross hatching types
                  from the wireframe based cross hatching form.
                  Also modified to use the cross hatch parameters namely
                  the angle and spacing factors.
                  Added logic to support the material type status display form.
 08/04/89 : rlw : Modified such that if COXH_PATTERN_TYPE variable is not
                  initialized then the software still works.  Also modified
                  name of cross hatch form since GRNUC went to a C based form
                  and added no scale flag to co$expreval call for getting
                  the hatch angle.
 09/15/89 : pp  : Outputting a message into the prompt area to indicate
                  the presence of status display form.
 09/29/89 : rlw : Modified such that fields in status display form are changed
                  in the database as the user changes them.
 10/10/89 : pp  : Changed the call from EFconvert_to_user_units to
                  EFshort_cvtn to handle inverse scaling while outputting
                  spacing for the crosshatch.
 11/28/89 : RC  : Added code to use origin of the active coordinate
                  system as the cross hatch origin.
 04/02/91 : msm : changed to c-based form. Removed the form_input method. 
                  Override status_disp method.
 01/20/93 : Kumar N : ported to NT. 
 06/14/93 : scw : Removed references to the X11 directory for include files.
 08/13/94 : scw : Added X11 for the Intel Solaris port
 */

class implementation ECxhatch;

%safe
#include <math.h>
%endsafe

#if ! DEBUG
#include "EMS.h"		/* Shared library stuff */
#include <stdio.h>
#endif

#include "EC_I.h"		/* Message keys for status strings */
#include "EC_F.h"		/* Message keys for fatal strings */
#include "EC_M.h"		/* Message keys for command names */
#include "EC_P.h"		/* Message keys for prompt names */
#include "madef.h"		/* Define pi = 3.14159... */
#include "EMSmsgdef.h"		/* EMS_I_OutOfBounds defined here */
#include "dpdef.h"		/* Has defines for dp$inq... */
#include "EMSchatch.h"
#include "grxhdef.h"		/* Material types, form numbers, etc. */
#include "csdef.h"
#include "csmacros.h"
#if defined( NT )
#if 0  /* because opp can not handle it */
#  include <windows.h>
#endif
#endif

#ifdef X11
#  include <X11/Xlib.h>
#  include <X11/Xutil.h>
#endif

#if defined(__STDC__) || defined(__cplusplus)
#if 0  /* because opp can not handle it */
#  if defined( X11 )
#    include <XFIproto_pub.h>
#  elif defined( ENV5 )
#    include <FIproto_pub.h>
#  elif defined( NT )
#    include <shampub.h>
#  endif
#  endif
#else
#  include <FI.h>
#endif

#define WINDOW_BUTTON       5
#define FORM1               1

extern OMuword OPP_EMSplane_class_id;

from EMSplane import EMcross_hatch;
from GRgraphics import GRdisplay, GRdelete;
from GRcoords import GRcvt_to_wld_coords;

method perform_construction()
{
 OMuword	space_number;
 IGRboolean	delete_surface;
 IGRshort	element_type;
 IGRlong	*my_msg, sts;
 GRobjid	*my_constructed_object;
 struct		GRlc_info *lc_info;
 struct		GRmd_env *md_env;
/*
 * Compiler code reductions
 */
 my_msg = &me->msg;
 my_constructed_object = &me->constructed_object;
/*
 * Initialize
 */
 *my_msg = MSSUCC;
 *my_constructed_object = NULL_OBJID;
 delete_surface = FALSE;
 lc_info = &me->events[0].located_object[0];
 element_type = lc_info->geom_parms.polygon_inx;
 me->have_a_constructed_object = TRUE;
/*
 * Construct the surface
 */
 if (element_type != GRSURFACE)
  {
   sts = om$send(
     mode = OM_e_wrt_message,
     msg = message ECautoplane.perform_construction(),
     targetid = my_id);
    if (! (1 & sts)) goto wrapup;
   space_number = me->construct_env.md_id.osnum;
   md_env = &me->construct_env;
   delete_surface = TRUE;
  }
/*
 * Since cross hatching an existing surface will
 * change the existing rule lines, we must erase
 * this surface before we cross hatch it.
 */
 else
  {
   enum		GRdpmode DisplayMode;
   struct	GRmdenv_info *mdenv_info;

   *my_constructed_object = lc_info->located_obj.objid;
   space_number = lc_info->located_obj.osnum;
   md_env = &lc_info->module_info;
   mdenv_info = &md_env->md_env;
   DisplayMode = GRbe;
   sts = om$send(
     msg = message GRgraphics.GRdisplay(
      my_msg,
      &mdenv_info->matrix_type,
      mdenv_info->matrix,
      &DisplayMode, 
      &me->display_env.md_id),
     targetid = *my_constructed_object,
     targetos = space_number);
    if (! (1 & sts)) goto wrapup;
  }
/*
 * Get the view matrix
 */
 {
  extern	void EFget_xh_definition();
  IGRchar	material_type[40], act_cs_name[80], act_cs_desc[80];
  GRobjid   active_cs_objid;
  IGRint    name_size = 80, desc_size = 80, ret_name_size, 
            ret_desc_size;
  IGRlong	error, bytes_ret;
  IGRpoint	local_origin, hatch_origin;
  IGRdouble 	view_matrix[4][4];
  struct	EX_button *button;
  struct	var_list list[2];
  struct	EMSxh_info xh_info;

  button = &me->events[1].event.button;
  list[0].var = VIEWPORT_TO_WLD;
  list[0].var_ptr = (IGRchar *) view_matrix;
  list[0].num_bytes = sizeof(IGRmatrix);
  list[0].bytes_returned = &bytes_ret;
  list[1].var = END_PARAM;
  list[1].var_ptr = NULL;
  list[1].num_bytes = 0;
  list[1].bytes_returned = NULL;
  sts = dp$inq_set_gragad(
    msg = my_msg,
    osnum = button->osnum,
    gragad_objid = button->objid, 
    which_error = &error,
    var_list = list);
   if (! (1 & *my_msg)) goto wrapup;
/*
 * Determine the active material type
 */
  switch (me->material_type)
   {
    case GRXH_ANSI_IRON:
    case GRXH_DIN_IRON:
     strcpy (material_type, "cast_iron");
     break;
    case GRXH_ANSI_BRONZE:
    case GRXH_DIN_COPPER:
     strcpy (material_type, "bronze");
     break;
    case GRXH_ANSI_TITANIUM:
     strcpy (material_type, "titanium");
     break;
    case GRXH_ANSI_PLASTIC:
     strcpy (material_type, "plastic");
     break;
    case GRXH_ANSI_STEEL:
    case GRXH_DIN_STEEL:
     strcpy (material_type, "steel");
     break;
    case GRXH_ANSI_WHITE_METAL:
    case GRXH_DIN_SEAL_INSULAT:
     strcpy (material_type, "white_metal");
     break;
    case GRXH_DIN_CAST_STEEL:
     strcpy (material_type, "cast_steel");
     break;
    case GRXH_DIN_BRASS:
     strcpy (material_type, "brass");
     break;
    case GRXH_DIN_BRONZE:
     strcpy (material_type, "dbronze");
     break;
    case GRXH_DIN_ZINC_LEAD:
     strcpy (material_type, "zinc");
     break;
    case GRXH_DIN_LIGHT_METAL:
     strcpy (material_type, "light");
     break;
    case GRXH_DIN_HARD_RUBBER:
     strcpy (material_type, "rubber");
     break;
    default:
     strcpy (material_type, "mat_uv_hatch");
     break;
   } /* switch (me->material_type) */

/*
 * Get the origin of the active coordinate system and use it as
 * cross hatch origin -- RC 11/28/89
 */

  sts = cs$get_active_info(msg = my_msg, osnum = space_number,
                  namebuf_size = name_size, name = act_cs_name,
                  namebytes_ret = &ret_name_size,
                  descbuf_size = desc_size, desc = act_cs_desc,
                  descbytes_ret = &ret_desc_size,
                  objid = &active_cs_objid);
  if (! (1 & sts & *my_msg)) goto wrapup;

  local_origin[0] = local_origin[1] = local_origin[2] = 0.0;

  sts = om$send ( msg = message GRcoords.GRcvt_to_wld_coords(my_msg,
                    Rectangular, 1, local_origin, hatch_origin),
                   targetid = active_cs_objid, targetos = space_number);
  if (! (1 & sts & *my_msg)) goto wrapup;

/*
 * Cross hatch the sucker
 */

  EFget_xh_definition(
    my_msg, 
    me->hatch_angle, 
    hatch_origin, 
    me->hatch_spacing, 
    me->hatch_spacing, 
    material_type, 
    &xh_info);
  if (! (1 & *my_msg)) goto wrapup;
  sts = om$send(
    msg = message EMSplane.EMcross_hatch(
     my_msg,
     md_env,
     &xh_info,
     view_matrix),
    targetid = *my_constructed_object,
    targetos = space_number);
   if (! (1 & sts)) goto wrapup;
  if (*my_msg != EMS_I_OutOfBounds)	/* Not too many rule lines? */
   delete_surface = FALSE;
  if (xh_info.u_sgrp_info) om$dealloc (ptr = xh_info.u_sgrp_info);
  if (xh_info.v_sgrp_info) om$dealloc (ptr = xh_info.v_sgrp_info);
 }
/*
 * Wrap up our work
 */
wrapup:
 if (delete_surface)
  {
   IGRlong	loc_msg;

   sts = om$send(
     msg = message GRgraphics.GRdelete(
      &loc_msg,
      md_env),
     targetid = *my_constructed_object,
     targetos = space_number);
  }
 if (*my_msg == EMS_I_OutOfBounds)
  {
   ex$message(msgnumb = EMS_I_00095)	/* Excessive rule lines */
   *my_msg = MSSUCC;
   *my_constructed_object = NULL_OBJID;
  }
 else if (! (1 & *my_msg))
  {
   ex$message(msgnumb = EMS_I_00002)	/* Construction failed */
   *my_msg = MSSUCC;
   *my_constructed_object = NULL_OBJID;
  }
 if ((*my_constructed_object != NULL_OBJID) ||	/* Cross hatch OK */
     (element_type == GRSURFACE))		/* Had a sf to begin with */
  {
   IGRboolean	cross_hatch_ok;
   enum		GRdpmode DisplayMode;
   struct	GRmdenv_info *mdenv_info;

   cross_hatch_ok = TRUE;
   if (element_type == GRSURFACE)
    {
     if (*my_constructed_object == NULL_OBJID)
      cross_hatch_ok = FALSE;
     else
      me->have_a_constructed_object = FALSE;
    }
   if (cross_hatch_ok)
    {
     ex$message(				/* Processing . */
      msgnumb = EMS_I_00004,
      type = "%s",
      var = " . ")
    }
   DisplayMode = GRbd;
   mdenv_info = &md_env->md_env;
   sts = om$send(
     msg = message GRgraphics.GRdisplay(
      my_msg,
      &mdenv_info->matrix_type,
      mdenv_info->matrix,
      &DisplayMode, 
      &me->display_env.md_id),
     targetid = (cross_hatch_ok ? *my_constructed_object : 
                 lc_info->located_obj.objid),
     targetos = space_number);
    if (! (1 & sts))
     {
      *my_msg = MSFAIL;
      return(OM_E_ABORT);
     }
   if (cross_hatch_ok)
    {
     ex$message(msgnumb = EMS_I_00000)	/* Clear field */
    }
  }
 if (1 & *my_msg)
  return(OM_S_SUCCESS);
 else
  return(OM_E_ABORT);
}
/*
 * Perform duty method for cross hatching
 */
method perform_duty()
{
 IGRlong	sts;
/*
 * Construct the desired object
 */
 sts = om$send(
   msg = message ECconstruct.perform_construction(),
   targetid = my_id);
/*
 * eof
 */
 return(sts);
}
/*
 * Wake up method for cross hatching
 */
method wakeup(int pos)
{
 IGRint		i, bytes_in, bytes_out, sts;
 extern IGRint  GRdpb_get();
/*
 * Get the active color, weight, etc..
 */
 sts = om$send(
   mode = OM_e_wrt_message,
   msg = message ECautoplane.wakeup(pos),
   targetid = my_id);
  ERROR_ABORT  
/*
 * Get the active angle
 */
 bytes_in = sizeof(IGRdouble);
 gr$get_xhatch_angle(
   msg = &me->msg, 
   sizbuf = &bytes_in,
   buffer = &me->hatch_angle,
   nret = &bytes_out);
  ERROR_ABORT
/*
 * Get the spacing
 */
 gr$get_xhatch_spacing(
   msg = &me->msg, 
   sizbuf = &bytes_in,
   buffer = &me->hatch_spacing,
   nret = &bytes_out);
  ERROR_ABORT
/*
 * Get the material type
 */
 {
  IGRint	msg;
  struct	GRIOvar_def material_stuff;
  struct	GRid active_module;

  sts = ex$get_cur_mod(
    id = &active_module.objid,
    osnum = &active_module.osnum);
  sts = co$cvtvar(
    msg = &msg,
    alias = "COXH_PATTERN_TYPE",
    osnum = active_module.osnum,
    var = &material_stuff);
  if (! (1 & sts))
   {
    me->material_type = GRXH_ANSI_IRON;
    material_stuff.type = GRIO_VAR_INT;
    material_stuff.contents.ivalue = me->material_type;
    sts = co$addvar(
     msg = &msg,
     input_alias = "COXH_PATTERN_TYPE",
     osnum = active_module.osnum,
     input_string = &material_stuff);
   } /* if (! (1 & sts)) */
  else
   me->material_type = material_stuff.contents.ivalue;
  if (me->form_requested == TRUE)
     FIf_display (me->form1);
 }
/*
 * Display the active parameters
 */      
 {
  IGRchar	spacing[80];
  extern	IGRlong EFshort_cvtn();
  IGRdouble	hatch_angle_d;

  hatch_angle_d = me->hatch_angle * 180.0 / PI;
  spacing[0] = '\0';
  sts = EFshort_cvtn(
    spacing,
    me->hatch_spacing, 
    4, /* Respect inverse scaling and concatenate units with master string */
    80); /* Maximum size of the character array being passed in */
   ERROR_ABORT  
  ex$message(
   msgnumb = EMS_I_00096,
   type = "%.1f%s",
   var = `hatch_angle_d, spacing`)
 }
/*
 * Process illegal numbers
 */
 if (me->hatch_spacing <= 0.0)
  {
   ex$message(msgnumb = EM_M_0111)	/* Tell them who we are */
   ex$message(msgnumb = EMS_F_0005)	/* Invalid cross hatch spacing */
   me->msg = MSINARG;
   return (OM_E_ABORT);
  }
/*
 * eof
 */
 return(OM_S_SUCCESS);
}

method init(int type; char *str_ptr)
{
 IGRlong	sts;
/*
 * Let my parent do it's stuff
 */
 sts = om$send(
  mode = OM_e_wrt_message,
  msg = message ECautoplane.init(
   type,
   str_ptr),
  targetid = my_id);
/*
 * Inform the user that a status display form is available
 */
 {
  ex$message(msgnumb = EMS_I_InvkStatusFrm);
  GRstatus_display_button(1);
  (void) sleep(1);
 }
 return(OM_S_SUCCESS);
}

/*
 * It is important that this method not modify the variable
 * me->msg as this screws up the locate filter.  In general,
 * this method should be extremely careful about modifying
 * any instance data.
 */
method update_status_form()
{
 extern		IGRlong EFshort_cvtn();
 IGRlong	sts, msg, i, j, pattern_array[12];
 char       alpha[132];
 
 pattern_array[0] = GRXH_ANSI_IRON;
 pattern_array[1] = GRXH_DIN_SEAL_INSULAT; 
 pattern_array[2] = GRXH_DIN_STEEL;
 pattern_array[3] = GRXH_DIN_CAST_STEEL;
 pattern_array[4] = GRXH_DIN_COPPER; 
 pattern_array[5] = GRXH_DIN_BRASS;
 pattern_array[6] = GRXH_DIN_BRONZE;
 pattern_array[7] = GRXH_DIN_ZINC_LEAD;
 pattern_array[8] = GRXH_DIN_LIGHT_METAL;
 pattern_array[9] = GRXH_DIN_HARD_RUBBER;
 pattern_array[10] = GRXH_ANSI_PLASTIC;
 pattern_array[11] = GRXH_ANSI_TITANIUM;

  alpha[0] = '\0';
  sts = EFshort_cvtn(
    alpha,
    me->hatch_spacing, 
    4,          /* Option to respect inverse scaling  and return
                   value concatenated with units */
    132); /* Maximum size of the character array being passed in */
 FIg_set_text(me->form1, SPACING_FIELD, alpha);

 alpha[0] = '\0';
 sprintf(
  alpha,
  "%.1f degrees",
  me->hatch_angle * 180.0 / PI);
 FIg_set_text(me->form1, ANGLE_FIELD, alpha); 

 if(me->material_type == GRXH_ANSI_IRON)
  FIg_set_state_on (me->form1, GRXH_ANSI_IRON);
 else 
  FIg_set_state_off (me->form1, GRXH_ANSI_IRON);

 for (i = 1; i < 10; i++)
  {
   j = 101 + i;   /* patterns from gadget number 102 to 110 */
   if(me->material_type == pattern_array[i])
   FIg_set_state_on (me->form1, j);
   else
   FIg_set_state_off (me->form1, j);
  }
 for (i = 10; i < 12; i++)
  {
   j = 295 + i;   /* patterns from gadget number 305 to 306 */
   if(me->material_type == pattern_array[i])
   FIg_set_state_on (me->form1, j);
   else
   FIg_set_state_off (me->form1, j);
  }
 return(OM_S_SUCCESS);
}

/*
 * It is important that this method not modify the variable
 * me->msg as this screws up the locate filter.  In general,
 * this method should be extremely careful about modifying
 * any instance data.
 */

method status_disp()
{
  IGRlong status, EMmsg;
  OM_S_OBJID set_id = NULL_OBJID;
  int ret;
  IGRint ECxhatch_process_form();

  status = OM_S_SUCCESS;
  EMmsg = 1;
  ret = FIf_new (FORM1, "Crosshatch", ECxhatch_process_form, &me->form1);
  if (ret) {
      status = FALSE;
      goto wrapup;
   }
  ret = FIf_set_cmd_oid_os(me->form1, my_id, OM_Gw_current_OS);
  if (ret) {
      status = FALSE;
      goto wrapup;
   }

  FIg_erase (me->form1, ASSOC_FLAG_TOGGLE); /* not needed in MODEL */

  status = om$send(msg = message ECconstruct.update_status_form(),
                targetid = my_id);
  if (!me->form_requested)
  {
    ret = FIf_set_location (me->form1, 0, 125);
    if (ret) {
       status = FALSE;
      goto wrapup;
   }
  ret = FIf_display(me->form1);
    if (ret) {
       status = FALSE;
      goto wrapup;
   }
 me->form_requested = TRUE;
  }
wrapup:
 if (!(1&status&EMmsg))
   return (OM_E_ABORT);
 return (status);
}

IGRint ECxhatch_process_form (form_label, gadget_label, value, form_ptr)
int form_label, gadget_label;
double value;
Form  form_ptr;
{
  IGRint stat_func, stat_OM;
  IGRlong msg_loc;
  GRobjid cmdobj;
  GRspacenum cmdos;


  stat_OM = OM_S_SUCCESS;

  stat_func = FIf_get_cmd_oid_os (form_ptr, &cmdobj, &cmdos);
  if (stat_func)
    return (OM_E_ABORT);

  stat_OM = om$send (msg = message ECxhatch.do_form (&msg_loc, form_label,
                     gadget_label, value),
             senderid = NULL_OBJID, targetid = cmdobj, targetos = cmdos);
  if(! (stat_OM & 1))
   return (OM_E_ABORT);
return (stat_OM);
}

method do_form (IGRlong *msg; IGRint form_label; IGRint gadget_label;
               IGRdouble value)
{
 IGRboolean	update_form, change_material_type;
 IGRlong	msg, sts;
 int sel_flag, r_pos;
 char alpha[132];

/*
 * Initialize
 */
 update_form = TRUE;
 change_material_type = TRUE;
/*
 * Branch based on the form label
 * which was affected.
 */
if (form_label == FORM1) {
 switch (gadget_label)
  {
   case ACCEPT_BUTTON:
    update_form = FALSE;
    FIg_set_state_off (me->form1, gadget_label);
    me->form_requested = FALSE;
    FIf_erase (me->form1);
    break;
   case EXIT_BUTTON:
     FIg_set_state_off (me->form1, gadget_label);
     update_form = FALSE;     
    /* FIf_erase is being put here to react to shamrock (NT) - 1/20/93*/ 
    FIf_erase (me->form1);
     break;
   case ANGLE_FIELD:
    {
     IGRdouble	angle;

     change_material_type = FALSE;
     FIfld_get_text(me->form1, gadget_label, 0, 0, 132, alpha, &sel_flag, 
                    &r_pos);
     sts = co$expreval(
       msg = &msg,
       scale_flag = GRIO_NO_SCALE,
       expression = alpha,
       unit_type = "UOM_ANGLE",
       result = &angle);
      if ((1 & sts) && (1 & msg)) 
       {
        IGRlong		num_bytes;

        me->hatch_angle = angle;
        num_bytes = sizeof(IGRdouble);
        gr$put_xhatch_angle(
         msg = &msg,
         sizbuf = &num_bytes,
         buffer = &me->hatch_angle);
       } /* if ((1 & sts) && (1 & msg)) */
    }
    break;
   case SPACING_FIELD:
    {
     IGRdouble	spacing;

     change_material_type = FALSE;
     FIfld_get_text(me->form1, gadget_label, 0, 0, 132, alpha, &sel_flag,
                    &r_pos);
     sts = co$expreval(
       msg = &msg,
       expression = alpha,
       unit_type = "UOM_DISTANCE",
       result = &spacing);
      if ((1 & sts) && 
          (1 & msg) &&
          (spacing > 0.0))
       {
        IGRlong		num_bytes;

        me->hatch_spacing = spacing;
        num_bytes = sizeof(IGRdouble);
        gr$put_xhatch_spacing(
         msg = &msg,
         sizbuf = &num_bytes,
         buffer = &me->hatch_spacing);
       } /* if ((1 & sts) &&  ... */
    }
    break;
   case GRXH_ANSI_IRON:
    me->material_type = GRXH_ANSI_IRON;
    break;
   case GRXH_DIN_STEEL:
    me->material_type = GRXH_DIN_STEEL;
    break;
   case GRXH_DIN_CAST_STEEL:
    me->material_type = GRXH_DIN_CAST_STEEL;
    break;
   case GRXH_DIN_COPPER:
    me->material_type = GRXH_DIN_COPPER;
    break;
   case GRXH_DIN_BRASS:
    me->material_type = GRXH_DIN_BRASS;
    break;
   case GRXH_DIN_BRONZE:
    me->material_type = GRXH_DIN_BRONZE;
    break;
   case GRXH_DIN_ZINC_LEAD:
    me->material_type = GRXH_DIN_ZINC_LEAD;
    break;
   case GRXH_DIN_LIGHT_METAL:
    me->material_type = GRXH_DIN_LIGHT_METAL;
    break;
   case GRXH_DIN_SEAL_INSULAT:
    me->material_type = GRXH_DIN_SEAL_INSULAT;
    break;
   case GRXH_DIN_HARD_RUBBER:
    me->material_type = GRXH_DIN_HARD_RUBBER;
    break;
   case GRXH_ANSI_PLASTIC:
    me->material_type = GRXH_ANSI_PLASTIC;
    break;
   case GRXH_ANSI_TITANIUM:
    me->material_type = GRXH_ANSI_TITANIUM;
    break;
   case WINDOW_BUTTON:
     FIg_erase (me->form1, gadget_label);   /* No break on purpose */
   default:
    update_form = FALSE;
    break;
 } /* switch (gadget_label) */
}
/*
 * Update the form, if required
 */
 if (update_form)
  {
   if (change_material_type)
    {
     struct	GRid module;
     struct	GRIOvar_def pattern_type;

     sts = ex$get_cur_mod(
      id = &module.objid,
      osnum = &module.osnum);
     pattern_type.type = GRIO_VAR_INT;
     pattern_type.contents.ivalue = me->material_type;
     sts = co$addvar(
      msg = &msg,
      input_alias = "COXH_PATTERN_TYPE",
      osnum = module.osnum,
      input_string = &pattern_type);
    } /* if (change_material_type) */
   sts = om$send(
    msg = message ECconstruct.update_status_form(),
    targetid = my_id);
  } /* if (update_form) */
/*
 * eof
 */
 return(OM_S_SUCCESS);
}

end implementation ECxhatch;
