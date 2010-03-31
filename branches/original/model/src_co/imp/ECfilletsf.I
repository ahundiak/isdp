/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This file contains the init, update_status_form, form_input,
 and perform construction methods for the place fillet surface command.

 History

 09/19/89 : rlw : Pulled construction logic from ECprfrmcons.I and editted
                  to add law curve logic.
 18/06/90 : SS  : Made the change to call new fillet-surface method to
                  make use of new math technology.
 04/03/91 : msm : Changed to c-based form.

 04/08/91 : jhw : Changes to call EMplace_fillet function.
 08/08/91 : scw : Converted to use gr$dpb associative flag
 01/24/93 : Kumar N : port to NT
 06/14/93 : scw : Removed references to the X11 directory for include files.
 08/13/94 : scw : Added X11 for Intel Solaris port
 */

class implementation ECfilletsf;

%safe
#include <math.h>
%endsafe

#if defined( NT )
#if 0  /* because opp can not handle it */
#  include <windows.h>
#endif
#endif


#include "EMS.h"
#include "ems_m_inc.h"		/* Includes everything */
#include "EMSmsgdef.h"		/* EMS_I_NotFound */
#include "DIdef.h"
#include "EMSasdef.h"
#include "EMSas.h"
#include "EMSasnucdef.h"
#include "EMSasnuc.h"
#include "EMSasmacros.h"
#include "EMSasopts.h"
#include "EMSdpb.h"
#include "EC_I.h"
#include "EMSascmacros.h"
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
#else
#  include <FI.h>
#endif
#else
#  include <FI.h>
#endif


#define ACCEPT_BUTTON        1
#define WINDOW_BUTTON        5

#define NAME_BUTTON         15

#define  NO_EXT_FILL        24 
#define  EXT_ROLL_BALL      13 
#define  INT_CNV_ROLL_BALL  15
#define  EXT_EXD_CASE       11
#define  INT_CNV_EXD_CASE   14 

#define CIRCULAR_FILL      12
#define CHAMFER_FILL       27
#define ARBITRARY          31 
#define RHO_FLD            26


#define FORM1               1
#define FORM2               2

from EMSsubbs import EMgetfillet;

extern OMuword OPP_EMSgenbs_class_id;

method init(int type; char *str_ptr)
{
 IGRlong	sts;
/*
 * Let my parent do it's stuff
 */
 sts = om$send(
  mode = OM_e_wrt_message,
  msg = message ECconstruct.init(
   type,
   str_ptr),
  targetid = my_id);
    ex$message(msgnumb=EMS_I_InvkStatusFrm);
 GRstatus_display_button(1);
/*
 * Initialize to no law desired
 */
 me->form1 = NULL;
 me->form_requested = NULL;
 me->law_name[0] = '\0';

 /*  default options for constant radius fillet */
     me->ext_ind = 0;
     me->cnv_ind = 1;
     me->cnc_ind = 0;
     me->rho = .41421356237309504880;
/*
 * eof
 */
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
 IGRlong	sts, msg;
 char           nam[20];
 
    if(me->form_number == 1)
    {
      FIg_set_text(me->form1, NAME_BUTTON, me->law_name);
    }
    else
    {
    FIg_set_state_off (me->form1, INT_CNV_EXD_CASE );
    FIg_set_state_off (me->form1, EXT_EXD_CASE );
    FIg_set_state_off (me->form1, NO_EXT_FILL );
    FIg_set_state_off (me->form1, EXT_ROLL_BALL );
    FIg_set_state_off (me->form1, INT_CNV_ROLL_BALL );

    if(me->ext_ind == 0)
        FIg_set_state_on (me->form1, NO_EXT_FILL );
    else if(me->ext_ind == 1)
        FIg_set_state_on (me->form1, EXT_ROLL_BALL );
    else if(me->ext_ind == 2)
        FIg_set_state_on (me->form1, EXT_EXD_CASE );

    if(me->cnv_ind == 1)
        FIg_set_state_on (me->form1, INT_CNV_ROLL_BALL );
    else if(me->cnv_ind == 2)
        FIg_set_state_on (me->form1, INT_CNV_EXD_CASE );
    }

      FIg_set_value(me->form1, RHO_FLD, me->rho);
      if(me->rho == 0.0)
       {
         FIg_set_state_off (me->form1,ARBITRARY);
         FIg_set_state_on (me->form1, CHAMFER_FILL);
       }
      else
         FIg_set_state_off (me->form1, CHAMFER_FILL);

      if(me->rho == 0.41421356237309504880) 
       {
         FIg_set_state_off (me->form1,ARBITRARY);
         FIg_set_state_on (me->form1, CIRCULAR_FILL);
       }
      else
         FIg_set_state_off (me->form1, CIRCULAR_FILL);


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
  IGRint ECfilletsf_process_form();

  status = OM_S_SUCCESS;
  EMmsg = 1;

if(!(me->form_requested))
{
if(me->number_of_events_input <= 5 || me->events[5].response == EX_MAX_RESPONSE)
  {
    me->form_number=2;
    ret = FIf_new (FORM2, "EMactvrtncv3", ECfilletsf_process_form, &me->form1);
  }
 else if(me->number_of_events_input >= 6 && me->events[5].response == EX_VALUE)
  {
    me->form_number=1;
    ret = FIf_new (FORM1, "EMactvrtncv", ECfilletsf_process_form, &me->form1);
  }

  if (ret) {
      status = FALSE;
      goto wrapup;
      }
}


  ret = FIf_set_cmd_oid_os(me->form1, my_id, OM_Gw_current_OS);
  if (ret) {
      status = FALSE;
      goto wrapup;
   }
  status = om$send(msg = message ECconstruct.update_status_form(),
                targetid = my_id);

  if (!me->form_requested)
  {
/**************
    ret = FIf_set_location (me->form1, 0, 125);
    if (ret) {
       status = FALSE;
      goto wrapup;
   }
***************/
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

IGRint ECfilletsf_process_form (form_label, gadget_label, value, form_ptr)
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

  stat_OM = om$send (msg = message ECfilletsf.do_form (&msg_loc, form_label,
                     gadget_label, value),
             senderid = NULL_OBJID, targetid = cmdobj, targetos = cmdos);
  if(! (stat_OM & 1))
   return (OM_E_ABORT);
return (stat_OM);
}

method do_form (IGRlong *msg; IGRint form_label; IGRint gadget_label;
               IGRdouble value)
{
 IGRboolean	update_form;
 IGRlong	msg, sts;
 IGRdouble      rho;
 IGRdouble      gvalue;
/*
 * Initialize
 */
 update_form = TRUE;
/*
 * Branch based on the form label
 * which was affected.
 */

 switch (gadget_label)
  {
   case ACCEPT_BUTTON:
    update_form = FALSE;
    FIg_set_state_off (me->form1, gadget_label);
    me->form_requested = FALSE;
    FIf_erase (me->form1);
    break;

   case ARBITRARY:
    FIg_enable(me->form1,RHO_FLD);
    FIg_set_state_off (me->form1, CIRCULAR_FILL );
    FIg_set_state_off (me->form1, CHAMFER_FILL );
    update_form = FALSE;
    break;

   case RHO_FLD:
    FIg_get_value(me->form1,RHO_FLD,&gvalue);
    me->rho = gvalue;
    if(gvalue != 0.0)
      FIg_set_state_on (me->form1, CHAMFER_FILL );
    else 
      FIg_set_state_off (me->form1, CHAMFER_FILL );

    if(gvalue != 0.4142135623730950488)
       FIg_set_state_on (me->form1, CIRCULAR_FILL );
    else 
       FIg_set_state_off (me->form1, CIRCULAR_FILL );
    break;

   case CIRCULAR_FILL:
    me->rho = .4142135623730950488;
    FIg_set_state_off (me->form1, CHAMFER_FILL );
    FIg_set_state_off (me->form1, ARBITRARY );
    FIg_disable(me->form1,RHO_FLD);
    break;

   case CHAMFER_FILL:
    me->rho = 0.0;
    FIg_set_state_off (me->form1, CIRCULAR_FILL );
    FIg_set_state_off (me->form1, ARBITRARY );
    FIg_disable(me->form1,RHO_FLD);
    break;

/***********
   case WINDOW_BUTTON:
     FIg_erase (me->form1, gadget_label);   
***********/
   default:
    break;
 }

   if (form_label == FORM1) {

   if(gadget_label == NAME_BUTTON)
    {
     extern		void EMget_lawcurve();
     IGRlong		msg, curve_index;
     char        alpha[132];
     int sel_flag, r_pos;

  FIfld_get_text(me->form1, gadget_label, 0, 0, 132, alpha, &sel_flag, &r_pos);
     if (alpha[0] == '\0')
      me->law_name[0] = '\0';
     else
      {
       EMget_lawcurve(
         &msg,
         alpha,
         &curve_index,
         NULL);			/* Don't want the law curve geometry */
        if ((1 & msg) &&
            (msg != EMS_I_NotFound))
         {
          strcpy(
           me->law_name,
           alpha);
         } /* if law was valid */
      } /* ELSE FOR if (alpha[0] == '\0') */
 }
}

else if( form_label == FORM2 )
 {
  switch(gadget_label)
 {

  case NO_EXT_FILL: 
    FIg_set_state_off (me->form1, EXT_ROLL_BALL );
    FIg_set_state_off (me->form1, EXT_EXD_CASE );
    me->ext_ind = 0;
       break;

  case EXT_ROLL_BALL :
    FIg_set_state_off (me->form1, NO_EXT_FILL );
    FIg_set_state_off (me->form1, EXT_EXD_CASE );
    me->ext_ind = 1;
       break;
      
  case EXT_EXD_CASE :
    FIg_set_state_off (me->form1, NO_EXT_FILL );
    FIg_set_state_off (me->form1, EXT_ROLL_BALL );
    me->ext_ind = 2;
       break;

  case INT_CNV_ROLL_BALL:
    FIg_set_state_off (me->form1, INT_CNV_EXD_CASE );
    me->cnv_ind = 1;
       break;

  case INT_CNV_EXD_CASE :
    FIg_set_state_off (me->form1, INT_CNV_ROLL_BALL );
    me->cnv_ind = 2;
       break;
  }
 } /* if form 2 */

/*
 * Update the form, if required
 */
 if (update_form)
  {
   sts = om$send(
    msg = message ECconstruct.update_status_form(),
    targetid = my_id);
  } /* if (update_form) */
/*
 * eof
 */
 return(OM_S_SUCCESS);
}

method perform_construction()
{
 extern		void EFextract_points();
 OMuword        space_number;
 IGRlong        sts, *my_msg;
 IGRdouble	starting_radius, ending_radius;
 IGRpoint       points[20];             /* A conservative estimate */
 GRobjid        *my_constructed_object;
 struct         GRvg_construct *my_construct_list;
 struct		GRlc_info *events_0, *events_2;

/*
 * Compiler code reductions
 */

 my_msg = &me->msg;
 my_construct_list = &me->construct_list;
 my_constructed_object = &me->constructed_object;
/*
 * Initialize
 */
 *my_msg = MSSUCC;
 *my_constructed_object = NULL_OBJID;

 EFextract_points(
  me->number_of_events_input,
  me->events,
  points);
 space_number = me->construct_env.md_id.osnum;

/*
 * Construct the fillet surface
 */
 events_0 = &me->events[0].located_object[0];
 events_2 = &me->events[2].located_object[0];
 starting_radius = me->events[4].event.value;
 if (me->events[5].response == EX_MAX_RESPONSE)
  ending_radius = starting_radius;
 else
  ending_radius = me->events[5].event.value;

 if (me->events[8].response == EX_VALUE)
   me->rho = me->events[8].event.value;

 {
    struct EMSobject_info   loc_surface1, loc_surface2;
    struct EMSpoint_info    loc_start_point, loc_end_point;
    struct EMSvalue_info    loc_start_radius, loc_end_radius;
    IGRboolean              assoc_placement;

    gr$get_associative_flag( buffer = &assoc_placement );

    loc_surface1.env = events_0->module_info;
    loc_surface1.grid = events_0->located_obj;

    loc_surface2.env = events_2->module_info;
    loc_surface2.grid = events_2->located_obj;

    loc_start_point.type = loc_start_radius.type = EMSdatainfo_numeric;
    memcpy(loc_start_point.pt, points[6],  sizeof(IGRpoint));
    loc_start_radius.val = starting_radius;

    loc_end_point.type = loc_end_radius.type = EMSdatainfo_numeric;
    memcpy(loc_end_point.pt, points[7], sizeof(IGRpoint));
    loc_end_radius.val = ending_radius;
/******************************************************************************
    sts = EMplace_fillet ( my_msg,
                           assoc_placement ? NULL : EMSasconst_notassociative,
                           my_construct_list->env_info, 
                           my_construct_list->level,
                           my_construct_list->display,
                           my_construct_list->class_attr,
                           my_construct_list->name,
                           &loc_surface1,
                           events_0->geom_parms.polygon_inx,
                           &loc_surface2,
                           events_2->geom_parms.polygon_inx,
                           &loc_start_point,      
                           &loc_start_radius,
                           &loc_end_point,
                           &loc_end_radius,  
                           (me->law_name[0] != '\0') ? me->law_name : NULL,
                           me->rho,
                           (me->rho  == 0.0),
                           my_constructed_object,
                           me->ext_ind,
                           me->cnv_ind,
                           me->cnc_ind );
******************************************************************************/
     sts = ems$place_fillet(msg = my_msg,
             options = assoc_placement ? NULL : EMSasconst_notassociative, 
             construction_list = my_construct_list,
             surface1 = &loc_surface1,
             natural_normal1 = events_0->geom_parms.polygon_inx,
             surface2 = &loc_surface2,
             natural_normal2 = events_2->geom_parms.polygon_inx,
             start_point = &loc_start_point,
             start_radius = &loc_start_radius,
             end_point = &loc_end_point,
             end_radius = &loc_end_radius,
             variation_curve = (me->law_name[0] != '\0') ? me->law_name : NULL,
             rho_value = me->rho,
             is_chamfer = (me->rho  == 0.0),
             fillet_object = my_constructed_object,
             ext_ind = me->ext_ind,
             cnv_ind = me->cnv_ind,
             cnc_ind = me->cnc_ind );             
    if (!(sts & *my_msg & 1)) goto wrapup;
  }

/*
 * eof
 */
wrapup:
 if (1 & *my_msg)
  return(OM_S_SUCCESS);
 else
  {
   *my_constructed_object = NULL_OBJID;
   return(OM_E_ABORT);
  }
}

end implementation ECfilletsf;
