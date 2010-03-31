class              ECmassedit
command_string     EM_M_Edit_mass_area_props,0,EMedtmp
super_class        ECcmd
product_name       "$MODEL"
spec_path          "$MODEL/src_testco/spec"
form		   "EMMassForm",MASS_FORM,0,0,100
form		   "EMAreaForm",AREA_FORM,0,0,0
start_state        get_designator

specification

#include "emsmass.h"

instance
	{
     IGRint     switch1;
     IGRint     operation_type;
     IGRchar    master_units[80];
     IGRdouble  mass_props[NUMB_PROPS];
     IGRint     coord_descr;
     IGRchar    coord_name[50];
     IGRint     axes_orient;
     IGRpoint   refer_pnt;
     IGRdouble  glo_loc[9];
     IGRdouble  density;
     IGRdouble  factor;
	}

implementation

#include "stdio.h"
#include "OMerrordef.h"
#include "msdef.h"

#include "igewindef.h"
#include "igewinmacros.h"
#include "igr.h"

#include "fontdef.h"
#include "font.h"
#include "dp.h"
#include "dpdef.h"
#include "dpstruct.h"
#include "dpmacros.h"
#include "godef.h"

#include "msdef.h"
#include "msmacros.h"
#include "lcdef.h"
#include "lcmacros.h"
#include "emsmass.h"
#include "griodef.h"
#include "griomacros.h"
#include "csdef.h"
#include "grcoordsys.h"
#include "ex.h"
#include "exmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "exfi.h"
#include "FI.h"
#include "grgsdef.h"
#include "grgsmacros.h"
#include "DIdef.h"
#include "ECcmd_def.h"
#include "ECcmd.h"
#include "ECmsg.h"

#define MSMASS_PROPERTY 201
#define MSAREA_PROPERTY 203
#define SAVE 1
#define CANCEL 4
#define MASS_FORM 0
#define AREA_FORM 1

from EMSmassprop import EMreadprop,
                        EMedit_mass_prop;
from GRvg        import GRgetname;

state_table

#define MSMASS_PROPERTY 201
#define MSAREA_PROPERTY 203
#define MASS_FORM 0
#define AREA_FORM 1

#include        "ECcmd.h"
#include        "ECmsg.h"

state get_designator

 message_key          	EM_M_Edit_mass_area_props
 prompt_key             EMS_P_IdMaArDesig
 accept_key           	EMS_P_00038
 relocate_key           EMS_P_MaArDesigNoFound
 locate_class           "EMSmassprop"
 locate_display         6
 locate_properties      29 /* locate locatable, displayable, read_write */
 locate_owner           "LC_RIGID_OWNER |
                         LC_REF_OBJECTS |
                         LC_NO_REF_HEADER"
 filter	                locate
 on EX_BACK_UP          state get_designator
 on EX_DATA do          status " "
        	do          highlight_located   0
            do          ECcmd.EMsave_located_object
                              (&me->event1,&me->located_obj[0])
            do          get_active (&me->ret,
                                    &me->factor,
                                    me->master_units,
                                    me->coord_name,
                                    &me->coord_descr)
                        on MSFAIL state err_in_getprop
            do          get_properties (&me->ret,
                                        me->mass_props,
                                        &me->axes_orient,
                                        &me->operation_type,
                                        me->refer_pnt,
                                        me->glo_loc,
                                        &me->density)
                        on MSFAIL state err_in_getprop
                        on MSMASS_PROPERTY state show_mass_form
                        on MSAREA_PROPERTY state show_area_form
                        state .                        
state err_in_getprop
            status                "ERROR, getting properties"
            on ELSE               state show_mass_form
state show_mass_form

    display_form 0
    execute set_mass_form_defaults
    filter wfi

    on EX_BACK_UP    state    get_designator
    on EX_DATA      state    get_designator	

	on MOVE_ON do erase_form 0
	state	get_designator


state show_area_form

    display_form 1
    execute set_area_form_defaults
    filter wfi

    on EX_BACK_UP    state    get_designator
    on EX_DATA      state    get_designator	

	on MOVE_ON do erase_form 1
	state	get_designator

action get_active(IGRint *sts; IGRdouble *factor; IGRchar *master_units;
                  IGRchar *coord_name; IGRint *coord_descr)
{
 IGRlong    i, msg, bytes_in, bytes_out;
 IGRpoint   point0, point1;
 struct GRmd_env ModuleInfo;

 bytes_in = sizeof(struct GRmd_env);
 gr$get_module_env (msg = &msg,
                    sizbuf = &bytes_in,
                    buffer = &ModuleInfo,
                    nret = &bytes_out);
 if (! (1 & msg)) goto wrapup;

 for (i=0; i<3; i++) point0[i] = 0.0;

 MSconvert_to_active_coordinates (&msg, ModuleInfo, point0, point1,
                                  coord_descr, coord_name);
 if (! (1 & msg)) goto wrapup;

 MSget_master_string (&msg, me->located_obj[0].located_obj.osnum,
                      master_units, factor);

wrapup:
 return (status);
}

action get_properties(IGRint *sts; IGRdouble *prop; IGRint *prop_type;
                      IGRint *op_type; IGRdouble *ref_pnt;
                      IGRdouble *glo_loc; IGRdouble *density)
{
 IGRlong    msg;
 IGRdouble  p_axes[6];

 status = om$send(msg = message EMSmassprop.EMreadprop (&msg,
                        &me->located_obj[0].module_info,
                        op_type, prop_type, prop, ref_pnt, glo_loc,
                        p_axes, density),
                  targetid = me->located_obj[0].located_obj.objid,
                  targetos = me->located_obj[0].located_obj.osnum);
 if (! (1 & status & msg)) goto wrapup;

 if (*op_type == MASS_PROPERTIES) *sts = MSMASS_PROPERTY;
 if (*op_type == AREA_PROPERTIES) *sts = MSAREA_PROPERTY;
wrapup:
 return (status);
}

/*----set_mass_form_defaults-------------------------------------------*/

action set_mass_form_defaults
   {

    IGRlong         msg; 
    OMuint	    count;
    IGRlong         bytes_in, bytes_out;
    Form            form_ptr;
    IGRpoint        save_pt, ref_point;
    IGRchar	    text[100];
    IGRchar         orient[10];
    IGRchar         coord_sys[80];
    IGRchar         object_name[DI_PATH_MAX];
    IGRdouble       scaling_2, scaling_3, scaling_4, scaling_5;
    extern          IGRdouble sqrt();
    struct GRmd_env ModuleInfo;
    OM_S_CHANSELECT to_object;
    OM_S_OBJECT_LINKAGE  chan_object;

    status = om$make_chanselect (channame = "EMSmassprop.to_object",
                                 p_chanselect = &to_object);
    if (! (1 & status)) goto wrapup;

    bytes_in = sizeof(struct GRmd_env);
    gr$get_module_env (msg = &msg,
                       sizbuf = &bytes_in,
                       buffer = &ModuleInfo,
                       nret = &bytes_out);
    if (! (1 & msg)) goto wrapup;

    form_ptr = me->forms[0].form_ptr;

    scaling_2 = me->factor * me->factor;
    scaling_3 = scaling_2 * me->factor;
    scaling_4 = scaling_3 * me->factor;
    scaling_5 = scaling_4 * me->factor;

    strcpy(object_name, " ");

    status = om$get_channel_objects (
                          osnum = me->located_obj[0].located_obj.osnum,
                          objid = me->located_obj[0].located_obj.objid,
                          p_chanselect = &to_object,
                          list = &chan_object,
                          size = 1,
                          count = &count);
    if (! (1 & status)) goto wrapup;

    status = om$send(msg = message GRvg.GRgetname (&msg, object_name),
                     targetid = chan_object.S_objid,
                     targetos = chan_object.osnum);
    if (! (1 & status & msg))
     {
      strcpy(object_name, " ");
      status = OM_S_SUCCESS;
     }

    sprintf (text,"%s", object_name);
	FIg_set_text (form_ptr, OBJECT_NAME, text);

    sprintf (text,"%s",me->master_units);
	FIg_set_text (form_ptr, LEN_UNITS, text);

    switch (me->coord_descr)
     {
      case RECTANGULAR:
	   ex$message(msgnumb = EMS_I_Rectangular, buff = coord_sys);
           break;
      case SPHERICAL:
	   ex$message(msgnumb = EMS_I_Spherical, buff = coord_sys);
           break;
      case CYLINDRICAL:
	   ex$message(msgnumb = EMS_I_Cylindrical, buff = coord_sys);
           break;
      default:
	   ex$message(msgnumb = EMS_I_Unknown, buff = coord_sys);
           break;
     }
 
    strcat(coord_sys, " --");
    strcat(coord_sys, me->coord_name);

    sprintf (text,"%s", coord_sys);
	FIg_set_text (form_ptr, COOD_SYSTEM, text);

	sprintf (text,"%g",me->density);
	FIg_set_text (form_ptr, DENSITY, text);

    switch (me->axes_orient)
     {
      case ACTIVE_AT_CENTROID:
	   ex$message(msgnumb = EMS_I_Active, buff = orient);
           break;
      case PRINCIPAL:
	   ex$message(msgnumb = EMS_I_Principal, buff = orient);
           break;
      case GENERAL:
	   ex$message(msgnumb = EMS_I_General, buff = orient);
           break;
      default:
	   ex$message(msgnumb = EMS_I_Unknown, buff = orient);
           break;
     }

    sprintf (text,"%s", orient);
	FIg_set_text (form_ptr, AXES_ORIENT, text);

    save_pt[0] = (me->axes_orient == GENERAL) ? me->refer_pnt[0] :
                                                me->mass_props[2];
    save_pt[1] = (me->axes_orient == GENERAL) ? me->refer_pnt[1] :
                                                me->mass_props[3];
    save_pt[2] = (me->axes_orient == GENERAL) ? me->refer_pnt[2] :
                                                me->mass_props[4];

    MSconvert_to_active_coordinates (&msg, ModuleInfo, save_pt,
                                     ref_point, &me->coord_descr,
                                     me->coord_name);
    if (! (1 & msg)) goto wrapup;

    sprintf (text,"%g", ref_point[0]/me->factor);
    FIg_set_text (form_ptr, REF_POINT0, text);
    me->refer_pnt[0] = ref_point[0]/me->factor;

    if (me->coord_descr == RECTANGULAR)
     {
      sprintf (text,"%g", ref_point[1]/me->factor);
      me->refer_pnt[1] = ref_point[1]/me->factor;
     }
    else
     {
      sprintf (text,"%g", ref_point[1]);
      me->refer_pnt[1] = ref_point[1]/me->factor;
     }
    FIg_set_text (form_ptr, REF_POINT1, text);

    if (me->coord_descr == SPHERICAL)
     {
      sprintf (text,"%g", ref_point[2]);
      me->refer_pnt[2] = ref_point[2];
     }
    else
     {
      sprintf (text,"%g", ref_point[2]/me->factor);
      me->refer_pnt[2] = ref_point[2]/me->factor;
     }
    FIg_set_text (form_ptr, REF_POINT2, text);

    sprintf (text, "%g", me->glo_loc[0]);
    FIg_set_text (form_ptr, AXIS0, text);
    sprintf (text, "%g", me->glo_loc[1]);
    FIg_set_text (form_ptr, AXIS1, text);
    sprintf (text, "%g", me->glo_loc[2]);
    FIg_set_text (form_ptr, AXIS2, text);
    sprintf (text, "%g", me->glo_loc[3]);
    FIg_set_text (form_ptr, AXIS3, text);
    sprintf (text, "%g", me->glo_loc[4]);
    FIg_set_text (form_ptr, AXIS4, text);
    sprintf (text, "%g", me->glo_loc[5]);
    FIg_set_text (form_ptr, AXIS5, text);
    sprintf (text, "%g", me->glo_loc[6]);
    FIg_set_text (form_ptr, AXIS6, text);
    sprintf (text, "%g", me->glo_loc[7]);
    FIg_set_text (form_ptr, AXIS7, text);
    sprintf (text, "%g", me->glo_loc[8]);
    FIg_set_text (form_ptr, AXIS8, text);

    MSconvert_to_active_coordinates (&msg, ModuleInfo, &me->mass_props[2],
                                     save_pt, &me->coord_descr,
                                     me->coord_name);
    if (! (1 & msg)) goto wrapup;

    sprintf (text, "%g", save_pt[0]/me->factor);
    FIg_set_text (form_ptr, CENTROIDX, text);
    me->mass_props[2] = save_pt[0]/me->factor;

    if (me->coord_descr == RECTANGULAR)    
     {
      sprintf (text, "%g", save_pt[1]/me->factor);
      me->mass_props[3] = save_pt[1]/me->factor;
     }
    else
     {
      sprintf (text, "%g", save_pt[1]);
      me->mass_props[3] = save_pt[1];
     }

    FIg_set_text (form_ptr, CENTROIDY, text);

    if (me->coord_descr == SPHERICAL)
     {
      sprintf (text, "%g", save_pt[2]);
      me->mass_props[4] = save_pt[2];
     }
    else
     {
      sprintf (text, "%g", save_pt[2]/me->factor);
      me->mass_props[4] = save_pt[2]/me->factor;
     }
    FIg_set_text (form_ptr, CENTROIDZ, text);

    sprintf (text, "%g", me->mass_props[0]/scaling_3);
    FIg_set_text (form_ptr, VOLUME, text);

    strcpy (text, me->master_units);
    strcat (text, "**3");
    FIg_set_text (form_ptr, VOLUME_UNIT, text);

    sprintf (text, "%g", me->mass_props[1]/scaling_3);
    FIg_set_text (form_ptr, MASS, text);

    sprintf (text, "%g", me->mass_props[5]/scaling_5);
    FIg_set_text (form_ptr, MOMENTX, text);

    strcpy (text, "MU ");
    strcat (text, me->master_units);
    strcat (text, "**2");
    FIg_set_text (form_ptr, MOMENTX_UNIT, text);

    sprintf (text, "%g", me->mass_props[6]/scaling_5);
    FIg_set_text (form_ptr, MOMENTY, text);

    strcpy (text, "MU ");
    strcat (text, me->master_units);
    strcat (text, "**2");
    FIg_set_text (form_ptr, MOMENTY_UNIT, text);

    sprintf (text, "%g", me->mass_props[7]/scaling_5);
    FIg_set_text (form_ptr, MOMENTZ, text);

    strcpy (text, "MU ");
    strcat (text, me->master_units);
    strcat (text, "**2");
    FIg_set_text (form_ptr, MOMENTZ_UNIT, text);

    sprintf (text, "%g", me->mass_props[8]/scaling_5);
    FIg_set_text (form_ptr, MOMENTXY, text);

    strcpy (text, "MU ");
    strcat (text, me->master_units);
    strcat (text, "**2");
    FIg_set_text (form_ptr, MOMENTXY_UNIT, text);

    sprintf (text, "%g", me->mass_props[9]/scaling_5);
    FIg_set_text (form_ptr, MOMENTYZ, text);

    strcpy (text, "MU ");
    strcat (text, me->master_units);
    strcat (text, "**2");
    FIg_set_text (form_ptr, MOMENTYZ_UNIT, text);

    sprintf (text, "%g", me->mass_props[10]/scaling_5);
    FIg_set_text (form_ptr, MOMENTZX, text);

    strcpy (text, "MU ");
    strcat (text, me->master_units);
    strcat (text, "**2");
    FIg_set_text (form_ptr, MOMENTZX_UNIT, text);

    sprintf (text, "%g", me->mass_props[11]/scaling_2);
    FIg_set_text (form_ptr, SURF_AREA, text);

    strcpy (text, me->master_units);
    strcat (text, "**2");
    FIg_set_text (form_ptr, SURF_AREA_UNIT, text);

    sprintf (text, "%g",
             sqrt(me->mass_props[5]/me->mass_props[1])/me->factor);
    FIg_set_text (form_ptr, RAD_GYR_X, text);

    strcpy (text, me->master_units);
    FIg_set_text (form_ptr, RGX_UNIT, text);

    sprintf (text, "%g",
             sqrt(me->mass_props[6]/me->mass_props[1])/me->factor);
    FIg_set_text (form_ptr, RAD_GYR_Y, text);

    strcpy (text, me->master_units);
    FIg_set_text (form_ptr, RGY_UNIT, text);

    sprintf (text, "%g",
             sqrt(me->mass_props[7]/me->mass_props[1])/me->factor);
    FIg_set_text (form_ptr, RAD_GYR_Z , text);

    strcpy (text, me->master_units);
    FIg_set_text (form_ptr, RGZ_UNIT, text);
 wrapup:
    return (status);
   }

/*----set_area_form_defaults-------------------------------------------*/

action set_area_form_defaults
   {

    IGRlong     msg; 
    OMuint 	count;
    IGRlong     bytes_in, bytes_out;
    Form        form_ptr;
    IGRpoint    save_pt;
    IGRdouble   x, xx;
    IGRdouble   polar_mom;
    IGRdouble   scaling_2, scaling_3, scaling_4, scaling_5;
    IGRchar	    text[100];
    IGRchar     coord_sys[80];
    IGRchar     object_name[DI_PATH_MAX];
    extern      IGRdouble sqrt();
    struct GRmd_env ModuleInfo;
    OM_S_CHANSELECT to_object;
    OM_S_OBJECT_LINKAGE  chan_object;

    status = om$make_chanselect (channame = "EMSmassprop.to_object",
                                 p_chanselect = &to_object);
    if (! (1 & status)) goto wrapup;

    bytes_in = sizeof(struct GRmd_env);
    gr$get_module_env (msg = &msg,
                       sizbuf = &bytes_in,
                       buffer = &ModuleInfo,
                       nret = &bytes_out);
    if (! (1 & msg)) goto wrapup;

    scaling_2 = me->factor * me->factor;
    scaling_3 = scaling_2 * me->factor;
    scaling_4 = scaling_3 * me->factor;
    scaling_5 = scaling_4 * me->factor;

    form_ptr = me->forms[1].form_ptr;

    strcpy(object_name, " ");

    status = om$get_channel_objects (
                          osnum = me->located_obj[0].located_obj.osnum,
                          objid = me->located_obj[0].located_obj.objid,
                          p_chanselect = &to_object,
                          list = &chan_object,
                          size = 1,
                          count = &count);
    if (! (1 & status)) goto wrapup;

    status = om$send(msg = message GRvg.GRgetname (&msg, object_name),
                     targetid = chan_object.S_objid,
                     targetos = chan_object.osnum);
    if (! (1 & status & msg))
     {
      strcpy(object_name, " ");
      status = OM_S_SUCCESS;
     }

    sprintf (text,"%s", object_name);
	FIg_set_text (form_ptr, OBJECT_NAME, text);

    sprintf (text,"%s",me->master_units);
	FIg_set_text (form_ptr, LEN_UNITS, text);

    switch (me->coord_descr)
     {
      case RECTANGULAR:
	   ex$message(msgnumb = EMS_I_Rectangular, buff = coord_sys);
           break;
      case SPHERICAL:
	   ex$message(msgnumb = EMS_I_Spherical, buff = coord_sys);
           break;
      case CYLINDRICAL:
	   ex$message(msgnumb = EMS_I_Cylindrical, buff = coord_sys);
           break;
      default:
	   ex$message(msgnumb = EMS_I_Unknown, buff = coord_sys);
           break;
     }

    strcat(coord_sys, " -");
    strcat(coord_sys, me->coord_name);

    sprintf (text,"%s", coord_sys);
	FIg_set_text (form_ptr, COOD_SYSTEM, text);

    x = me->mass_props[5]*me->mass_props[5] +
        me->mass_props[6]*me->mass_props[6] +
        me->mass_props[7]*me->mass_props[7];

    if(x < 0.95)	/* axis not defined */
     {
      sprintf(text,"%s","Surface non-planar: area and centroid computed");
	  FIg_set_text (form_ptr, STATUS_FIELD, text);
     }
    else
     {
      sprintf(text,"%s",
              "Axes Orientation wrt global co-ordinate system:");
	  FIg_set_text (form_ptr, STATUS_FIELD, text);

      sprintf (text, "%g", me->mass_props[5]);
      FIg_set_text (form_ptr, AXIS0, text);
      sprintf (text, "%g", me->mass_props[6]);
      FIg_set_text (form_ptr, AXIS1, text);
      sprintf (text, "%g", me->mass_props[7]);
      FIg_set_text (form_ptr, AXIS2, text);
      sprintf (text, "%g", me->mass_props[8]);
      FIg_set_text (form_ptr, AXIS3, text);
      sprintf (text, "%g", me->mass_props[9]);
      FIg_set_text (form_ptr, AXIS4, text);
      sprintf (text, "%g", me->mass_props[10]);
      FIg_set_text (form_ptr, AXIS5, text);

      xx = me->mass_props[6]*me->mass_props[10] -
           me->mass_props[9]*me->mass_props[7];
      sprintf (text, "%g", xx);
      FIg_set_text (form_ptr, AXIS6, text);

      xx = me->mass_props[7]*me->mass_props[8] -
           me->mass_props[10]*me->mass_props[5];
      sprintf (text, "%g", xx);
      FIg_set_text (form_ptr, AXIS7, text);

      xx = me->mass_props[5]*me->mass_props[9] -
           me->mass_props[8]*me->mass_props[6];
      sprintf (text, "%g", xx);
      FIg_set_text (form_ptr, AXIS8, text);
     }

    MSconvert_to_active_coordinates (&msg, ModuleInfo, &me->mass_props[2],
                                     save_pt, &me->coord_descr,
                                     me->coord_name);
    if (! (1 & msg)) goto wrapup;

    sprintf (text, "%g", save_pt[0]/me->factor);
    FIg_set_text (form_ptr, CENTROIDX, text);
    me->mass_props[2] = save_pt[0]/me->factor;

    if (me->coord_descr == RECTANGULAR)    
     {
      sprintf (text, "%g", save_pt[1]/me->factor);
      me->mass_props[3] = save_pt[1]/me->factor;
     }
    else
     {
      sprintf (text, "%g", save_pt[1]);
      me->mass_props[3] = save_pt[1];
     }

    FIg_set_text (form_ptr, CENTROIDY, text);

    if (me->coord_descr == SPHERICAL)
     {
      sprintf (text, "%g", save_pt[2]);
      me->mass_props[4] = save_pt[2];
     }
    else
     {
      sprintf (text, "%g", save_pt[2]/me->factor);
      me->mass_props[4] = save_pt[2]/me->factor;
     }
    FIg_set_text (form_ptr, CENTROIDZ, text);

    sprintf (text, "%g", me->mass_props[11]/scaling_2);
    FIg_set_text (form_ptr, SURF_AREA, text);

    strcpy (text, me->master_units);
    strcat (text, "**2");
    FIg_set_text (form_ptr, SURF_AREA_UNIT, text);

    if (x >= 0.95)
     {
      polar_mom = me->mass_props[14] + me->mass_props[15];

      sprintf (text, "%g", me->mass_props[14]/scaling_4);
      FIg_set_text (form_ptr, PRIN_MOMX, text);
      strcpy (text, me->master_units);
      strcat (text, "**4");
      FIg_set_text (form_ptr, PRINMOMX_UNIT, text);

      sprintf (text, "%g", me->mass_props[15]/scaling_4);
      FIg_set_text (form_ptr, PRIN_MOMY, text);
      strcpy (text, me->master_units);
      strcat (text, "**4");
      FIg_set_text (form_ptr, PRINMOMY_UNIT, text);

      sprintf (text, "%g", polar_mom/scaling_4);
      FIg_set_text (form_ptr, POLAR_MOM, text);
      strcpy (text, me->master_units);
      strcat (text, "**4");
      FIg_set_text (form_ptr, POLARMOM_UNIT, text);
      
      sprintf(text, "%g", sqrt(polar_mom/me->mass_props[11])/me->factor);
      FIg_set_text (form_ptr, RADGY_POLAR, text);

      strcpy (text, me->master_units);
      FIg_set_text (form_ptr, RADGYPOLAR_UNIT, text);

      sprintf (text, "%g",
               sqrt(me->mass_props[14]/me->mass_props[11])/me->factor);
      FIg_set_text (form_ptr, RADGY_X, text);

      strcpy (text, me->master_units);
      FIg_set_text (form_ptr, RADGYX_UNIT, text);

      sprintf (text, "%g",
               sqrt(me->mass_props[15]/me->mass_props[11])/me->factor);
      FIg_set_text (form_ptr, RADGY_Y , text);

      strcpy (text, me->master_units);
      FIg_set_text (form_ptr, RADGYY_UNIT, text);
     }
 wrapup:
    return (status);
   }

/*----form_notification-------------------------------------------------*/

action form_notification

   {
    IGRint       i;
    IGRlong      msg, bytes_in, bytes_out;
    Form         form_ptr;
    char         text[50];
    IGRdouble    val;
    IGRdouble    ref_pnt[3];
    IGRdouble    temp;
    IGRdouble     scaling_2, scaling_3, scaling_4, scaling_5;
    struct GRmd_env ModuleInfo;

    bytes_in = sizeof(struct GRmd_env);
    gr$get_module_env (msg = &msg,
                       sizbuf = &bytes_in,
                       buffer = &ModuleInfo,
                       nret = &bytes_out);
    if (! (1 & msg)) goto wrapup;

    scaling_2 = me->factor * me->factor;
    scaling_3 = scaling_2 * me->factor;
    scaling_4 = scaling_3 * me->factor;
    scaling_5 = scaling_4 * me->factor;

    if (form_label == MASS_FORM)
     {
      form_ptr = me->forms[0].form_ptr;

      switch (gadget_label)
       {
        case DENSITY:
             temp = me->density;
             FIg_get_text (form_ptr, DENSITY, text);
             sscanf (text, "%lf", &val);
             if (val < 0)
              {
		ex$message(msgnumb = EMS_I_00009);
              }
             else
              me->density = val;

             sprintf (text, "%g", me->density);
             FIg_set_text (form_ptr, DENSITY, text);

             if (temp != me->density)
              {
               me->mass_props[1] *= me->density/temp;
               sprintf (text, "%g", me->mass_props[1]);
               FIg_set_text (form_ptr, MASS, text);

               for (i=5; i<11; i++)
                    me->mass_props[i] *= me->density/temp;

               sprintf (text, "%g", me->mass_props[5]);
               FIg_set_text (form_ptr, MOMENTX, text);
               sprintf (text, "%g", me->mass_props[6]);
               FIg_set_text (form_ptr, MOMENTY, text);
               sprintf (text, "%g", me->mass_props[7]);
               FIg_set_text (form_ptr, MOMENTZ, text);
               sprintf (text, "%g", me->mass_props[8]);
               FIg_set_text (form_ptr, MOMENTXY, text);
               sprintf (text, "%g", me->mass_props[9]);
               FIg_set_text (form_ptr, MOMENTYZ, text);
               sprintf (text, "%g", me->mass_props[10]);
               FIg_set_text (form_ptr, MOMENTZX, text);
              }
             break;

        case REF_POINT0:
             FIg_get_text (form_ptr, REF_POINT0, text);
             sscanf (text, "%lf", &me->refer_pnt[0]);
             sprintf (text, "%g", me->refer_pnt[0]);
             FIg_set_text (form_ptr, REF_POINT0, text);
             break;

        case REF_POINT1:
             FIg_get_text (form_ptr, REF_POINT1, text);
             sscanf (text, "%lf", &me->refer_pnt[1]);
             sprintf (text, "%g", me->refer_pnt[1]);
             FIg_set_text (form_ptr, REF_POINT1, text);
             break;

        case REF_POINT2:
             FIg_get_text (form_ptr, REF_POINT2, text);
             sscanf (text, "%lf", &me->refer_pnt[2]);
             sprintf (text, "%g", me->refer_pnt[2]);
             FIg_set_text (form_ptr, REF_POINT2, text);
             break;

        case AXIS0:
             FIg_get_text (form_ptr, AXIS0, text);
             sscanf (text, "%lf", &me->glo_loc[0]);
             sprintf (text, "%g", me->glo_loc[0]);
             FIg_set_text (form_ptr, AXIS0, text);
             break;

        case AXIS1:
             FIg_get_text (form_ptr, AXIS1, text);
             sscanf (text, "%lf", &me->glo_loc[1]);
             sprintf (text, "%g", me->glo_loc[1]);
             FIg_set_text (form_ptr, AXIS1, text);
             break;

        case AXIS2:
             FIg_get_text (form_ptr, AXIS2, text);
             sscanf (text, "%lf", &me->glo_loc[2]);
             sprintf (text, "%g", me->glo_loc[2]);
             FIg_set_text (form_ptr, AXIS2, text);
             break;

        case AXIS3:
             FIg_get_text (form_ptr, AXIS3, text);
             sscanf (text, "%lf", &me->glo_loc[3]);
             sprintf (text, "%g", me->glo_loc[3]);
             FIg_set_text (form_ptr, AXIS3, text);
             break;

        case AXIS4:
             FIg_get_text (form_ptr, AXIS4, text);
             sscanf (text, "%lf", &me->glo_loc[4]);
             sprintf (text, "%g", me->glo_loc[4]);
             FIg_set_text (form_ptr, AXIS4, text);
             break;

        case AXIS5:
             FIg_get_text (form_ptr, AXIS5, text);
             sscanf (text, "%lf", &me->glo_loc[5]);
             sprintf (text, "%g", me->glo_loc[5]);
             FIg_set_text (form_ptr, AXIS5, text);
             break;

        case AXIS6:
             FIg_get_text (form_ptr, AXIS6, text);
             sscanf (text, "%lf", &me->glo_loc[6]);
             sprintf (text, "%g", me->glo_loc[6]);
             FIg_set_text (form_ptr, AXIS6, text);
             break;

        case AXIS7:
             FIg_get_text (form_ptr, AXIS7, text);
             sscanf (text, "%lf", &me->glo_loc[7]);
             sprintf (text, "%g", me->glo_loc[7]);
             FIg_set_text (form_ptr, AXIS7, text);
             break;

        case AXIS8:
             FIg_get_text (form_ptr, AXIS8, text);
             sscanf (text, "%lf", &me->glo_loc[8]);
             sprintf (text, "%g", me->glo_loc[8]);
             FIg_set_text (form_ptr, AXIS8, text);
             break;

        case CENTROIDX:
             FIg_get_text (form_ptr, CENTROIDX, text);
             sscanf (text, "%lf", &me->mass_props[2]);
             sprintf (text, "%g", me->mass_props[2]);
             FIg_set_text (form_ptr, CENTROIDX, text);
             break;

        case CENTROIDY:
             FIg_get_text (form_ptr, CENTROIDY, text);
             sscanf (text, "%lf", &me->mass_props[3]);
             sprintf (text, "%g", me->mass_props[3]);
             FIg_set_text (form_ptr, CENTROIDY, text);
             break;

        case CENTROIDZ:
             FIg_get_text (form_ptr, CENTROIDZ, text);
             sscanf (text, "%lf", &me->mass_props[4]);
             sprintf (text, "%g", me->mass_props[4]);
             FIg_set_text (form_ptr, CENTROIDZ, text);
             break;

        case VOLUME:
             FIg_get_text (form_ptr, VOLUME, text);
             sscanf (text, "%lf", &me->mass_props[0]);
             sprintf (text, "%g", me->mass_props[0]);
             FIg_set_text (form_ptr, VOLUME, text);
             me->mass_props[0] *= scaling_3;
             break;

        case MASS:
             FIg_get_text (form_ptr, MASS, text);
             sscanf (text, "%lf", &me->mass_props[1]);
             sprintf (text, "%g", me->mass_props[1]);
             FIg_set_text (form_ptr, MASS, text);
             me->mass_props[1] *= scaling_3;
             break;

        case MOMENTX:
             FIg_get_text (form_ptr, MOMENTX, text);
             sscanf (text, "%lf", &me->mass_props[5]);
             sprintf (text, "%g", me->mass_props[5]);
             FIg_set_text (form_ptr, MOMENTX, text);
             me->mass_props[5] *= scaling_5;
             break;

        case MOMENTY:
             FIg_get_text (form_ptr, MOMENTY, text);
             sscanf (text, "%lf", &me->mass_props[6]);
             sprintf (text, "%g", me->mass_props[6]);
             FIg_set_text (form_ptr, MOMENTY, text);
             me->mass_props[6] *= scaling_5;
             break;

        case MOMENTZ:
             FIg_get_text (form_ptr, MOMENTZ, text);
             sscanf (text, "%lf", &me->mass_props[7]);
             sprintf (text, "%g", me->mass_props[7]);
             FIg_set_text (form_ptr, MOMENTZ, text);
             me->mass_props[7] *= scaling_5;
             break;

        case MOMENTXY:
             FIg_get_text (form_ptr, MOMENTXY, text);
             sscanf (text, "%lf", &me->mass_props[8]);
             sprintf (text, "%g", me->mass_props[8]);
             FIg_set_text (form_ptr, MOMENTXY, text);
             me->mass_props[8] *= scaling_5;
             break;

        case MOMENTYZ:
             FIg_get_text (form_ptr, MOMENTYZ, text);
             sscanf (text, "%lf", &me->mass_props[9]);
             sprintf (text, "%g", me->mass_props[9]);
             FIg_set_text (form_ptr, MOMENTYZ, text);
             me->mass_props[9] *= scaling_5;
             break;

        case MOMENTZX:
             FIg_get_text (form_ptr, MOMENTZX, text);
             sscanf (text, "%lf", &me->mass_props[10]);
             sprintf (text, "%g", me->mass_props[10]);
             FIg_set_text (form_ptr, MOMENTZX, text);
             me->mass_props[10] *= scaling_5;
             break;

        case SURF_AREA:
             FIg_get_text (form_ptr, SURF_AREA, text);
             sscanf (text, "%lf", &me->mass_props[11]);
             sprintf (text, "%g", me->mass_props[11]);
             FIg_set_text (form_ptr, SURF_AREA, text);
             me->mass_props[11] *= scaling_2;
             break;

        case RAD_GYR_X:
             break;

        case RAD_GYR_Y:
             break;

        case RAD_GYR_Z:
             break;

        case SAVE:
             me->switch1 = SAVE;

             me->refer_pnt[0] *= me->factor;
             me->mass_props[2] *= me->factor;
             if (me->coord_descr == RECTANGULAR)
              {
               me->refer_pnt[1] *= me->factor;
               me->mass_props[3] *= me->factor;
              }
             if (me->coord_descr != SPHERICAL)
              {
               me->refer_pnt[2] *= me->factor;
               me->mass_props[4] *= me->factor;
              }

             MSconvert_to_world_coordinates(&msg, ModuleInfo,
                                            me->coord_descr,
                                            me->refer_pnt, ref_pnt);
             if (! (1 & msg)) goto wrapup;
             for (i=0; i<3; i++) me->refer_pnt[i] = ref_pnt[i];

             MSconvert_to_world_coordinates(&msg, ModuleInfo,
                                            me->coord_descr,
                                            &me->mass_props[2], ref_pnt);
             if (! (1 & msg)) goto wrapup;
             for (i=0; i<3; i++) me->mass_props[2+i] = ref_pnt[i];

             status = om$send(msg = message EMSmassprop.EMedit_mass_prop(
                              &msg, &me->located_obj[0].module_info,
                              TRUE, me->mass_props, me->density,
                              me->refer_pnt, me->glo_loc,me->axes_orient),
                         targetid = me->located_obj[0].located_obj.objid,
                         targetos = me->located_obj[0].located_obj.osnum);
             if (! (1 & status & msg)) goto wrapup;
             
             _move_on;
             break;

        case CANCEL:
             me->switch1 = CANCEL;
             _move_on;
             break;

        default:
             break;
       }
     }
    else if (form_label == AREA_FORM)
     {
      form_ptr = me->forms[1].form_ptr;
      val = me->mass_props[5]*me->mass_props[5] +
            me->mass_props[6]*me->mass_props[6] +
            me->mass_props[7]*me->mass_props[7];

      switch (gadget_label)
       {
        case AXIS0:
             if (val < 0.95) break;
             FIg_get_text (form_ptr, AXIS0, text);
             sscanf (text, "%lf", &me->mass_props[5]);
             sprintf (text, "%g", me->mass_props[5]);
             FIg_set_text (form_ptr, AXIS0, text);
             break;

        case AXIS1:
             if (val < 0.95) break;
             FIg_get_text (form_ptr, AXIS1, text);
             sscanf (text, "%lf", &me->mass_props[6]);
             sprintf (text, "%g", me->mass_props[6]);
             FIg_set_text (form_ptr, AXIS1, text);
             break;

        case AXIS2:
             if (val < 0.95) break;
             FIg_get_text (form_ptr, AXIS2, text);
             sscanf (text, "%lf", &me->mass_props[7]);
             sprintf (text, "%g", me->mass_props[7]);
             FIg_set_text (form_ptr, AXIS2, text);
             break;

        case AXIS3:
             if (val < 0.95) break;
             FIg_get_text (form_ptr, AXIS3, text);
             sscanf (text, "%lf", &me->mass_props[8]);
             sprintf (text, "%g", me->mass_props[8]);
             FIg_set_text (form_ptr, AXIS3, text);
             break;

        case AXIS4:
             if (val < 0.95) break;
             FIg_get_text (form_ptr, AXIS4, text);
             sscanf (text, "%lf", &me->mass_props[9]);
             sprintf (text, "%g", me->mass_props[9]);
             FIg_set_text (form_ptr, AXIS4, text);
             break;

        case AXIS5:
             if (val < 0.95) break;
             FIg_get_text (form_ptr, AXIS5, text);
             sscanf (text, "%lf", &me->mass_props[10]);
             sprintf (text, "%g", me->mass_props[10]);
             FIg_set_text (form_ptr, AXIS5, text);
             break;

        case AXIS6:
             if (val < 0.95) break;
             FIg_get_text (form_ptr, AXIS6, text);
             sscanf (text, "%lf", &temp);
             sprintf (text, "%g", temp);
             FIg_set_text (form_ptr, AXIS6, text);
             break;

        case AXIS7:
             if (val < 0.95) break;
             FIg_get_text (form_ptr, AXIS7, text);
             sscanf (text, "%lf", &temp);
             sprintf (text, "%g", temp);
             FIg_set_text (form_ptr, AXIS7, text);
             break;

        case AXIS8:
             if (val < 0.95) break;
             FIg_get_text (form_ptr, AXIS8, text);
             sscanf (text, "%lf", &temp);
             sprintf (text, "%g", temp);
             FIg_set_text (form_ptr, AXIS8, text);
             break;

        case CENTROIDX:
             FIg_get_text (form_ptr, CENTROIDX, text);
             sscanf (text, "%lf", &me->mass_props[2]);
             sprintf (text, "%g", me->mass_props[2]);
             FIg_set_text (form_ptr, CENTROIDX, text);
             break;

        case CENTROIDY:
             FIg_get_text (form_ptr, CENTROIDY, text);
             sscanf (text, "%lf", &me->mass_props[3]);
             sprintf (text, "%g", me->mass_props[3]);
             FIg_set_text (form_ptr, CENTROIDY, text);
             break;

        case CENTROIDZ:
             FIg_get_text (form_ptr, CENTROIDZ, text);
             sscanf (text, "%lf", &me->mass_props[4]);
             sprintf (text, "%g", me->mass_props[4]);
             FIg_set_text (form_ptr, CENTROIDZ, text);
             break;

        case SURF_AREA:
             FIg_get_text (form_ptr, SURF_AREA, text);
             sscanf (text, "%lf", &me->mass_props[11]);
             sprintf (text, "%g", me->mass_props[11]);
             FIg_set_text (form_ptr, SURF_AREA, text);
             me->mass_props[11] *= scaling_2;
             break;

        case PRIN_MOMX:
             if (val < 0.95) break;
             FIg_get_text (form_ptr, PRIN_MOMX, text);
             sscanf (text, "%lf", &temp);
             me->mass_props[14] = temp*scaling_4;
             sprintf (text, "%g", temp);
             FIg_set_text (form_ptr, PRIN_MOMX, text);
             break;

        case PRIN_MOMY:
             if (val < 0.95) break;
             FIg_get_text (form_ptr, PRIN_MOMY, text);
             sscanf (text, "%lf", &temp);
             me->mass_props[15] = temp*scaling_4;
             sprintf (text, "%g", temp);
             FIg_set_text (form_ptr, PRIN_MOMY, text);
             break;

        case POLAR_MOM:
             if (val < 0.95) break;
             FIg_get_text (form_ptr, POLAR_MOM, text);
             sscanf (text, "%lf", &temp);
             sprintf (text, "%g", temp);
             FIg_set_text (form_ptr, POLAR_MOM, text);
             break;

        case RADGY_POLAR:
             break;

        case RADGY_X:
             break;

        case RADGY_Y:
             break;

        case SAVE:
             me->switch1 = SAVE;

             me->mass_props[2] *= me->factor;
             if (me->coord_descr == RECTANGULAR)
              {
               me->mass_props[3] *= me->factor;
              }
             if (me->coord_descr != SPHERICAL)
              {
               me->mass_props[4] *= me->factor;
              }

             MSconvert_to_world_coordinates(&msg, ModuleInfo,
                                            me->coord_descr,
                                            &me->mass_props[2], ref_pnt);
             if (! (1 & msg)) goto wrapup;
             for (i=0; i<3; i++) me->mass_props[2+i] = ref_pnt[i];

             status = om$send(msg = message EMSmassprop.EMedit_mass_prop(
                              &msg, &me->located_obj[0].module_info,
                              TRUE, me->mass_props, me->density,
                              me->refer_pnt, me->glo_loc,me->axes_orient),
                         targetid = me->located_obj[0].located_obj.objid,
                         targetos = me->located_obj[0].located_obj.osnum);
             if (! (1 & status & msg)) goto wrapup;
             _move_on;
             break;

        case CANCEL:
             me->switch1 = CANCEL;
             _move_on;
             break;

        default:
             break;
       }
 wrapup:
    return (status);
     }

   }/* form_notification */



/*
  translate a string into its variable name value
*/

action arg_name_to_value
/* Incoming */
/*  int		  addr_mode;	/* == _COB_regular  for regular data  */
				/* == _COB_indirect for "*<arg>"      */
				/* == _COB_address  for "&<arg>"      */
/*  char	* class_name;	/* not NULL => argname used to start  */
				/*   with "me(class_name)->" of some  */
				/*   form; now this has been stripped */
				/* NULL => original arg had no "me->" */
/*  char  	* arg;		/* arg string to find a value for     */
	/* Outgoing */
/*  COB_arg_union * data;	/* value of arg string variable       */
/*  int		* ret_type;	/* type of value found for arg string */
				/*   (see COB_arg.h)		      */
/*  char	* is_const;	/* set to 1 => this variable value is */
				/*   "constant" and needn't be looked */
				/*   up ever again		      */
{
  int		   arg_num;
  char		 * ch = '\0';


  * ret_type = _COB_UNKNOWN_ARG;
  * is_const = 0;

  if ( class_name[0] )	/*** arg string used to begin with "me->" ***/
    {
	/**************************************************************/
	/*		  ECmassedit instance data	              */
	/**************************************************************/
      if ( !strcmp(arg, "switch1") )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->i = ME.ECmassedit->switch1;
	      * ret_type = _COB_arg_i;
	    }
	  else if ( addr_mode == _COB_address )
	    {
	      data->p = (char *) & ME.ECmassedit->switch1;
	      * ret_type = _COB_arg_p;
	      * is_const = 1;
	    }
	} /*** ME.ECmassedit->switch1 ***/
      else if ( !strcmp(arg, "operation_type") )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->i = ME.ECmassedit->operation_type;
	      * ret_type = _COB_arg_i;
	    }
	  else if ( addr_mode == _COB_address )
	    {
	      data->p = (char *) & ME.ECmassedit->operation_type;
	      * ret_type = _COB_arg_p;
	      * is_const = 1;
	    }
	} /*** ME.ECmassedit->operation_type ***/
      else if ( !strcmp(arg, "coord_descr") )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->i = ME.ECmassedit->coord_descr;
	      * ret_type = _COB_arg_i;
	    }
	  else if ( addr_mode == _COB_address )
	    {
	      data->p = (char *) & ME.ECmassedit->coord_descr;
	      * ret_type = _COB_arg_p;
	      * is_const = 1;
	    }
	} /*** ME.ECmassedit->coord_descr ***/
      else if ( !strcmp(arg, "axes_orient") )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->i = ME.ECmassedit->axes_orient;
	      * ret_type = _COB_arg_i;
	    }
	  else if ( addr_mode == _COB_address )
	    {
	      data->p = (char *) & ME.ECmassedit->axes_orient;
	      * ret_type = _COB_arg_p;
	      * is_const = 1;
	    }
	} /*** ME.ECmassedit->axes_orient ***/
      else if ( !strcmp(arg, "density") )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->d = ME.ECmassedit->density;
	      * ret_type = _COB_arg_d;
	    }
	  else if ( addr_mode == _COB_address )
	    {
	      data->p = (char *) & ME.ECmassedit->density;
	      * ret_type = _COB_arg_p;
	      * is_const = 1;
	    }
	} /*** ME.ECmassedit->density ***/
      else if ( !strcmp(arg, "factor") )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->d = ME.ECmassedit->factor;
	      * ret_type = _COB_arg_d;
	    }
	  else if ( addr_mode == _COB_address )
	    {
	      data->p = (char *) & ME.ECmassedit->factor;
	      * ret_type = _COB_arg_p;
	      * is_const = 1;
	    }
	} /*** ME.ECmassedit->factor ***/
      else if ( ! strcmp ( arg, "mass_props" ) )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->p = (char *) ME.ECmassedit->mass_props;
	      * ret_type = _COB_arg_p;
	      * is_const = 1;
	    }
	}  /*** ME.ECmassedit->mass_props ***/
      else if ( ! strncmp ( arg, "mass_props[", strlen( "mass_props[")))
	{
	  /*** get the # within the [ ]'s ***/
	  arg_num = COB_fetch_first_arg_num ( arg, &ch );

	  if ( arg_num < 0  ||  arg_num >= NUMB_PROPS )
	    {
	      fprintf ( stderr,
		"\nECmassedit.arg_name_to_value():  Reference to ME.ECmassedit->value[%d]\n\tin state table argument is invalid\n\n", arg_num );
	    }
	  else
	    {
	      if ( addr_mode == _COB_regular )
		{
	          data->d = ME.ECmassedit->mass_props[arg_num];
	          * ret_type = _COB_arg_d;
		}
              else if ( addr_mode == _COB_address )
		{
	          data->p = (char *)&ME.ECmassedit->mass_props[arg_num];
	          * ret_type = _COB_arg_d;
		  * is_const = 1;
		}
	    }
	}  /*** ME.ECmassedit->mass_props[x] ***/
      else if ( ! strcmp ( arg, "glo_loc" ) )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->p = (char *) ME.ECmassedit->glo_loc;
	      * ret_type = _COB_arg_p;
	      * is_const = 1;
	    }
	}  /*** ME.ECmassedit->glo_loc ***/
      else if ( ! strncmp ( arg, "glo_loc[", strlen( "glo_loc[")))
	{
	  /*** get the # within the [ ]'s ***/
	  arg_num = COB_fetch_first_arg_num ( arg, &ch );

	  if ( arg_num < 0  ||  arg_num >= 9 )
	    {
	      fprintf ( stderr,
		"\nECmassedit.arg_name_to_value():  Reference to ME.ECmassedit->value[%d]\n\tin state table argument is invalid\n\n", arg_num );
	    }
	  else
	    {
	      if ( addr_mode == _COB_regular )
		{
	          data->d = ME.ECmassedit->glo_loc[arg_num];
	          * ret_type = _COB_arg_d;
		}
              else if ( addr_mode == _COB_address )
		{
	          data->p = (char *)&ME.ECmassedit->glo_loc[arg_num];
	          * ret_type = _COB_arg_d;
		  * is_const = 1;
		}
	    }
	}  /*** ME.ECmassedit->glo_loc[x] ***/
      else if ( ! strcmp ( arg, "refer_pnt" ) )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->p = (char *) ME.ECmassedit->refer_pnt;
	      * ret_type = _COB_arg_p;
	      * is_const = 1;
	    }
	}  /*** ME.ECmassedit->refer_pnt ***/
      else if ( ! strncmp ( arg, "refer_pnt[", strlen("refer_pnt[") ) )
	{
	  /*** get the # within the [ ]'s ***/
	  arg_num = COB_fetch_first_arg_num ( arg, &ch );

#define IGR_POINT_DIM	3
	  if ( arg_num < 0  ||  arg_num >= IGR_POINT_DIM )
	    {
	      fprintf ( stderr,
		"\nECmassedit.arg_name_to_value():  Reference to ME.ECmassedit->refer_pnt[%d]\n\tin state table argument is invalid\n\n", arg_num );
	    }
	  else
	    {
	      if ( addr_mode == _COB_regular )
	        {
	          data->d = ME.ECmassedit->refer_pnt [arg_num];
	          * ret_type = _COB_arg_d;
	        }
	      else if ( addr_mode == _COB_address )
	        {
	          data->p = (char *)&ME.ECmassedit->refer_pnt[arg_num];
	          * ret_type = _COB_arg_p;
	          * is_const = 1;
	        }
	    }
	}  /*** ME.ECmassedit->refer_pnt[x] ***/
      else if ( ! strcmp ( arg, "master_units" ) )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->p = (char *) ME.ECmassedit->master_units;
	      * ret_type = _COB_arg_p;
	      * is_const = 1;
	    }
	}  /*** ME.ECmassedit->master_units ***/
      else if ( ! strcmp ( arg, "coord_name" ) )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->p = (char *) ME.ECmassedit->coord_name;
	      * ret_type = _COB_arg_p;
	      * is_const = 1;
	    }
	}  /*** ME.ECmassedit->coord_name ***/
    }
  else	/*** arg string did not begin with "me->" ***/
    {
    }

	/*** if it's unknown, send it to parent ***/
  if ( * ret_type == _COB_UNKNOWN_ARG )
    {
      status = om$send ( targetid = my_id,
			 mode = OM_e_wrt_message,
			 msg = message ECcmd.arg_name_to_value (
					addr_mode, class_name, arg,
					data, ret_type, is_const ) );
      _check ( status );
    }

} /*** end of ECmassedit.arg_name_to_value method ***/
