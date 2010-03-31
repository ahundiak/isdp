/*

Name
  COmeas1.I

Description
  Implementation of measurement command methods.
  
Notes
  For the 2.4 release, this file and COmeasure.S were created from the
  state language file COmeasure.sl) and headers were added to some
  methods.  The methods are usually called from the CEO/CEO_LOCATE execute 
  code commands are usually designed from state transition (.t) files.

  For all methods below:  if *sts is the first (or only) argument, it
  returns the status of the method.  If this argument is not described 
  in the method header, it should be checked only for TRUE (*sts & 1) or 
  FALSE (! (*sts & 1)).

  Methods for COmeasure are in several files (COmeas1.I, COmeas2.I, ...).

History
  Shelley Heard:  5/24/93 : In all calls to co$cvt_imp_to_alias(), 
                            left justification is enforced (set locally)

 */

class implementation COmeasure;

#include "grownmacros.h"
#include "codebug.h"
#include "igrmacros.h"
#include "coplcmac.h"
#include "FI.h"
#include "coniarray.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "griomacros.h"
#include "exmacros.h"
#include "comiscmac.h"
#include "igrdp.h"
#include "dpstruct.h"
#include "igrdef.h"
#include "comeasure.h"
#include "grmessage.h"
#include "coreadout.h"
#include "codef.h"
#include "msmacros.h"
#include "madef.h"
#ifdef ENABLE_MATH_H
%safe
#include <math.h>
%endsafe
#else
#include <math.h>
#endif
#include <stdio.h>
#include "csdef.h"
#include "grcoordsys.h"
#include "csmacros.h"
#include "codynmeas.h"

#ifdef X11
#include <X11/Xlib.h>
#include <X11/Xos.h>
#include <ctype.h>
#endif

#define TOGGLE_FLAG(f) f = f ? FALSE : TRUE

extern    IGRboolean    COproj_pt_to_view_pl();
from GRdrawview  import GRget_drawview_scale;

%safe
static IGRint field_position[] = 
{ 
  DIST_PREV_TO_CURR_FLD,
  DIST_BASE_TO_CURR_FLD,
  DIST_CUMULATIVE_FLD,
  BASE_POINT_X_FLD,
  BASE_POINT_Y_FLD,
  BASE_POINT_Z_FLD,
  CURRENT_POINT_X_FLD,
  CURRENT_POINT_Y_FLD,
  CURRENT_POINT_Z_FLD,
  BASE_TO_CURRENT_X_FLD,
  BASE_TO_CURRENT_Y_FLD,
  BASE_TO_CURRENT_Z_FLD,
  PREV_TO_CURRENT_X_FLD,
  PREV_TO_CURRENT_Y_FLD,
  PREV_TO_CURRENT_Z_FLD 
};
%endsafe                                    


/*

Name
  init

Abstract
  overriding init to claer all fields, store current module environment, 
  and initialize lots of instance data.
  
Return Value

Keywords
  initialization,measure,method

History
  03/05/93 : Shelley R. Heard : first documented

 */
method init(int type; char *str_ptr )
{
  IGRlong               status;
  struct GRid           module_grid;
  IGRint                rc,sizbuf;
  struct GRIOvar_def    draw_mode_var;
  IGRlong               sts;
  extern IGRint         GRcvt_to_var();
  extern IGRint         GRaddvar();

  status = om$send ( msg = message COnpt.init ( type, str_ptr ),
                     targetid = my_id,
                     mode = OM_e_wrt_message );

  status = om$send (msg = message COmeasure.clear_fields (&sts),
                    targetid = my_id);

  status = ex$get_cur_mod( id    = &module_grid.objid,
                          osnum = &module_grid.osnum );

  sizbuf = sizeof(struct GRmd_env);
  status = gr$get_module_env( msg = &rc,
                              sizbuf = &sizbuf,
                              buffer = &me->mod_env,
                              nret = &rc);

  status = co$cvtvar(msg = &sts,
                     alias = "CO_MEAS_DRAW_MODE",
                     osnum = module_grid.osnum,
                     var = &draw_mode_var);

  if( sts == MSFAIL)
    {
      me->draw_mode = DRAW_LINE;
      draw_mode_var.type = GRIO_VAR_INT;
      draw_mode_var.contents.ivalue = me->draw_mode;
      status = co$addvar(msg = &sts,
                         input_alias = "CO_MEAS_DRAW_MODE",
                         osnum = module_grid.osnum,
                         input_string = &draw_mode_var);
    }
  else
    {
       me->draw_mode = (IGRshort) draw_mode_var.contents.ivalue;
    }

  me->scale_fac =1.0;
  me->display_field = 0;
  me->push_event_flag = FALSE;
  me->SuspendedByImmediate = FALSE;
  me->app_flag = FALSE;
  me->model_flag = FALSE;
  me->dat_pt_flag = TRUE;
  me->adv_flag = FALSE;
  me->ref_att_flag = FALSE;
  me->ref_lock_flag= TRUE;
  me->disp_flag = FALSE;
/*
  draw_mode_var.contents.ivalue = DRAW_LINE;
  me->draw_mode = DRAW_LINE;
*/
  return OM_S_SUCCESS;
}


/*

Name
  wakeup

Abstract
 adds the setting of the SuspendedByImmediate flag to FALSE.
 
Synopsis

Return Value

Notes

Index

Keywords
  measure,method

History
  03/05/93 : Shelley R. Heard : created

 */
method wakeup ( int pos )
{
  IGRlong               status;

  status = om$send ( msg = message COnpt.wakeup ( pos ),
                     targetid = my_id,
                     mode = OM_e_wrt_message );

  me->SuspendedByImmediate = FALSE;
  return OM_S_SUCCESS;
}

/*

Name
  sleep

Abstract
  Overriden to set the SuspendedByImmediate flag, as specified by 'pos'.

Index

Keywords
  measure,method

History
  03/05/93 : Shelley R. Heard : added header

 */
method super_cmd.sleep( int pos )
{
  IGRlong               status;

  status = om$send ( msg = message COnpt.sleep ( pos ),
                     targetid = my_id,
                     mode = OM_e_wrt_message );

/*
 * We need to know how we are being suspended so that event generating
 * forms know wheteher or not to terminate the measurement command or
 * not when they.
 *
 * Types from exec (exdef.h) are :
 *    EX_nonsuspend ==  0
 *    EX_suspend    ==  1
 */

  me->SuspendedByImmediate =  (! pos );
  return OM_S_SUCCESS;
}

/*

Name
  status_disp

Abstract
  Handles the display and update of the statue display form for measurement
  commands.

Keywords
  status_display,measure,method

History
  04/07/93 : Shelley R. Heard : added header

 */
method status_disp()
{
  IGRlong                msg;
  IGRlong                local_status;

  local_status = om$send ( msg = message CEO.status_disp ( ),
                     targetid = my_id,
                     mode = OM_e_wrt_message );

  local_status = om$send (msg = message COmeasure.update_meas_form (&msg),
                          targetid = my_id);

  return OM_S_SUCCESS;
}

/*

Name
  form_input

Abstract
  We override this message and it basically does nothing because we use
  a different method of handling form notification.

Keywords
  status_display,measure,method

History
  04/07/93 : Shelley R. Heard : added header

 */
method form_input ( IGRint form_label;  IGRchar *value )
{
  return OM_S_SUCCESS;
}


/*
Name
  update_cursor_fields ( long *sts )

Abstract
  Updates the information that is displayed near the cursor.

Keywords
  measure,method

History
  04/07/93 : Shelley R. Heard : added header

 */
method update_cursor_fields ( long *sts )
{
  IGRlong               status;
  IGRchar          *string_ptr[NUM_DISTANCE_OUTPUT_FLDS];
  IGRchar           form_flds[NUM_DISTANCE_OUTPUT_FLDS][80];
  IGRchar           disp_flds[NUM_CURSOR_OUTPUT_FLDS][80];
  IGRchar           ums_str0[GR_COMEAS_FIELD_SIZE];
  IGRchar           ums_str1[GR_COMEAS_FIELD_SIZE];
  IGRchar           ums_str2[GR_COMEAS_FIELD_SIZE];
  IGRchar           ums_str3[GR_COMEAS_FIELD_SIZE];
  IGRchar           ums_str4[GR_COMEAS_FIELD_SIZE];
  IGRchar           ums_str5[GR_COMEAS_FIELD_SIZE];
  IGRchar          *str_ptr[NUM_CURSOR_OUTPUT_FLDS];
  IGRshort          num_entries = 6;
  IGRshort          offset[(NUM_CURSOR_OUTPUT_FLDS*2)];
  IGRshort          i;
  IGRlong           ums_key9, ums_key10;
  IGRshort          num_alias = 3;
  IGRint            len;
  IGRshort          field_size = sizeof(IGRchar) * 80;
  IGRint            local_display_flag;
  IGRdouble         saved_dist; /* part of KLUDGE (see below) */
  struct GRevent    *events[7];
  struct GRIOreadout_spec  readout_spec;
  struct disp_val_info     dval_in;
     

  set_up_event_array;
  *sts = MSSUCC;
  status = OM_S_SUCCESS;

  for(i=0; i<NUM_DISTANCE_OUTPUT_FLDS; i++)
  {
    string_ptr[i] = &form_flds[i][0];
  }

  for(i=0; i <NUM_CURSOR_OUTPUT_FLDS ;i++)
    str_ptr[i] = &disp_flds[i][0];

  status = ex$get_cur_mod(id = &dval_in.ModuleGrid.objid,
                          osnum = &dval_in.ModuleGrid.osnum );

  /* KLUDGE - replace base_to_current value with saved prev_dist value */
  saved_dist = me->form_fields[DIST_BASE_TO_CURR_IND];
  me->form_fields[DIST_BASE_TO_CURR_IND] = me->seventh_event.event.value;
  /* end KLUDGE part 1 */
  if(me->adv_flag) 
  {
    me->cur_fields[1] = me->form_fields[DIST_BASE_TO_CURR_IND]/me->scale_fac;
    me->cur_fields[0] = me->form_fields[CURRENT_MEAS_IND]/me->scale_fac;
    me->cur_fields[2] = me->form_fields[CUMULATIVE_MEAS_IND]/me->scale_fac;
  }
  else 
  {
    me->cur_fields[1] = me->form_fields[DIST_BASE_TO_CURR_IND];
    me->cur_fields[0] = me->form_fields[CURRENT_MEAS_IND];
    me->cur_fields[2] = me->form_fields[CUMULATIVE_MEAS_IND];
  }
      
  /*
   * TR 119304151: in this situation, we force justification of output to be 
   * LEFT since it makes no sence to do anything else.  SRH 5/25/93
   */ 
  status = co$update_readout_spec(msg = sts,
                                  unit_type = me->Units,
                                  osnum = dval_in.ModuleGrid.osnum,
                                  update_flag = FALSE,
                                  readout_spec = &readout_spec);
  readout_spec.justification = GRIO_LEFT_JUSTIFY;

  status = co$cvt_imp_to_alias( msg = sts,
                                unit_type = me->Units,
                                working_units = me->cur_fields,
                                num_alias = &num_alias,
                                field_size = &field_size,
                                readout_spec = &readout_spec,
                                inverse_scale_flag = GRIO_NO_SCALE,
                                osnum = dval_in.ModuleGrid.osnum,
                                num_conversions = 9,
                                cvt_list = str_ptr);

  memcpy(dval_in.units,me->Units,24*sizeof(IGRchar));

  memcpy(&dval_in.events[0],events[3],sizeof(struct GRevent));
  memcpy(&dval_in.events[1],events[4],sizeof(struct GRevent));

  /* 3/1/93 - UMS conversion of dynamic cursor text */
  ex$message ( msgnumb = GR_I_DistEq,     
               buff = ums_str0, 
               buffer_size = GR_COMEAS_FIELD_SIZE );
  ex$message ( msgnumb = GR_I_PrevDistEq, 
               buff = ums_str1, 
               buffer_size = GR_COMEAS_FIELD_SIZE );
  ex$message ( msgnumb = GR_I_CumDistEq,  
               buff = ums_str2, 
               buffer_size = GR_COMEAS_FIELD_SIZE );
  ex$message ( msgnumb = GR_I_DeltaXEq,   
               buff = ums_str3, 
               buffer_size = GR_COMEAS_FIELD_SIZE );
  ex$message ( msgnumb = GR_I_DeltaYEq,   
               buff = ums_str4, 
               buffer_size = GR_COMEAS_FIELD_SIZE );
  ex$message ( msgnumb = GR_I_DeltaZEq,   
               buff = ums_str5, 
               buffer_size = GR_COMEAS_FIELD_SIZE );

  len = GRIO_strprepend(ums_str0,disp_flds[0]);
  len = GRIO_strprepend(ums_str1,disp_flds[1]);
  len = GRIO_strprepend(ums_str2,disp_flds[2]);
  len = GRIO_strprepend(ums_str3,disp_flds[3]);
  len = GRIO_strprepend(ums_str4,disp_flds[4]);
  len = GRIO_strprepend(ums_str5,disp_flds[5]);

   
  if(!( me->display_field &  GR_COMEAS_DISPLAY_CURRENT_DISTANCE) )
  {
    form_flds[CURRENT_MEAS_IND][0] = 0;
  }

  if(!( me->display_field &  GR_COMEAS_DISPLAY_BASE_CURRENT_DISTANCE ) )
  {
    form_flds[DIST_BASE_TO_CURR_IND][0] = 0;
  }

  dval_in.disp_dist_flag = FALSE;
  if(me->form_fields[CURRENT_MEAS_IND] == me->form_fields[CUMULATIVE_MEAS_IND])
  {
    form_flds[CUMULATIVE_MEAS_IND][0] = 0;
    dval_in.disp_dist_flag= TRUE;
  }

  local_display_flag = me->display_field;
  for(i=3; i< NUM_DISTANCE_OUTPUT_FLDS; i++)
  {
    if( (i%3) == 0 && i > 5) local_display_flag = local_display_flag >> 1;
    if( !(local_display_flag & 1)) form_flds[i][0] = 0;
  }

  str_ptr[0] = disp_flds[0];
  str_ptr[1] = disp_flds[1];
  str_ptr[2] = disp_flds[2];
  str_ptr[3] = disp_flds[3];
  str_ptr[4] = disp_flds[4];
  str_ptr[5] = disp_flds[5];

  offset[0]=offset[2]=offset[4]=offset[6]=offset[8]=offset[10]=10;
  offset[18] = offset[20]=10;
  offset[12]=85;
  offset[14]=55;
  offset[16]=45;

  offset[13]=-5;
  offset[15]=-35;
  offset[17]=10;

  offset[1]=-110;
  offset[3]=-95;
  offset[5]=-80;

  offset[7]=60;
  offset[9]=75;
  offset[11]=90;

  offset[19] = -60;
  offset[21] =  40;

  /* filling dynamic structure */ 
  dval_in.disp_fld_flag = me->disp_flag;
  dval_in.supr_act_flag = FALSE;
  dval_in.supr_dz_flag = FALSE;
  dval_in.change_flag = me->ref_lock_flag;
  dval_in.mode_flag = me->draw_mode;

  /* UMS complient (2/93 Shelley Heard) */
  ums_key9  = GR_I_Clear;
  ums_key10 = GR_I_Clear;
     
  if (me->ref_lock_flag)
  {
    ums_key9 = GR_I_RelToView;
  }
  else
  {
    ums_key9 = GR_I_RelToActRefPlane;
  }
  if (!me->dat_pt_flag)
  {
    ums_key10 = GR_I_RelToActCoordSys;
  }
  if (me->adv_flag) 
  { 
    dval_in.change_flag = FALSE; 
        ums_key9 = GR_I_RelToDrawView;
  }
  else if(!me->model_flag) 
  {
    dval_in.change_flag = TRUE;
    ums_key10 = GR_I_RelToView;
  }
  if (me->ref_att_flag) 
  {
    ums_key9  = GR_I_RelToDrawView;
    ums_key10 = GR_I_RelToRefFileCoordSys;
    dval_in.change_flag = FALSE;
    dval_in.supr_dz_flag = TRUE;
  }

  if (me->app_flag || me->dat_pt_flag) 
  {
    dval_in.supr_act_flag = TRUE;
    dval_in.supr_dz_flag = TRUE;
  }
  ex$message( msgnumb=ums_key9,  
              buff=str_ptr[9],  
              buffer_size=GR_COMEAS_FIELD_SIZE);
  ex$message( msgnumb=ums_key10, 
              buff=str_ptr[10],
              buffer_size=GR_COMEAS_FIELD_SIZE);

  DYrbrasdisp(&num_entries,offset,str_ptr,&dval_in);

  /* KLUDGE - replace prev_dist value with saved base_to_current value */
  me->form_fields[DIST_BASE_TO_CURR_IND] = saved_dist;
  /* end KLUDGE part 2 */
  if (dval_in.disp_fld_flag)
    me->fourth_event = me->fifth_event;

  return OM_S_SUCCESS;
}

/*
Name
  update_readout_form

Abstract
  Updates the fields on the MEASUREMENT READOUT form

Keywords
  measure,method,form

History
  04/07/93 : Shelley R. Heard : added header

 */
method update_readout_form ( long *sts )
{
  IGRlong               status;
  struct GRIOreadout_spec readout_spec;
  IGRchar                 form_text[GR_COMEAS_FIELD_DIM];
  struct GRid             module_grid;
  Form                    form_ptr;
  extern int FIg_set_state_on();
  extern int FIg_set_state_off();
  extern int FIfld_set_text();
  extern int FIfld_get_text();
  extern int FIfld_set_select();

  *sts = MSSUCC;
  status = OM_S_SUCCESS;

  status = ex$get_cur_mod(id = &module_grid.objid,
                          osnum = &module_grid.osnum );

  form_ptr = me->forms[0].form_ptr;
  if(strcmp(me->forms[0].name,MEASURE_DISTANCE_FORM) == 0)
  {
    strcpy(me->Units,GRIO_DISTANCE);
  }
  else if(strcmp(me->forms[0].name,MEASURE_ANGLE_FORM) == 0)
  {
    strcpy(me->Units,GRIO_ANGLE);
  }
  else if(strcmp(me->forms[0].name,"LinReadout") == 0)
  {
    strcpy(me->Units,GRIO_DISTANCE);
  }
  else if(strcmp(me->forms[0].name,"AngReadout") == 0)
  {
    strcpy(me->Units,GRIO_ANGLE);
  }


  status = co$update_readout_spec(msg = sts,
                                  unit_type = me->Units,
                                  osnum = module_grid.osnum,
                                  update_flag = FALSE,
                                  readout_spec = &readout_spec);

  status = (readout_spec.leading_zeros) ?
    FIg_set_state_on(form_ptr,LEADING_ZERO_TOG) :
      FIg_set_state_off(form_ptr,LEADING_ZERO_TOG);

  status = (readout_spec.trailing_zeros) ?
    FIg_set_state_on(form_ptr,TRAILING_ZERO_TOG) :
      FIg_set_state_off(form_ptr,TRAILING_ZERO_TOG);

  status = ( readout_spec.decimal_char == GRIO_PERIOD) ?
    FIg_set_state_off(form_ptr,DECIMAL_COMMA_TOG) :
      FIg_set_state_on(form_ptr,DECIMAL_COMMA_TOG);

  status = (readout_spec.alias_displayed) ?
    FIg_set_state_on(form_ptr,DISPLAY_UNITS_TOG) :
      FIg_set_state_off(form_ptr,DISPLAY_UNITS_TOG);

  sprintf(form_text,"%d",readout_spec.intermeas_spacing);
  status = FIfld_set_text(form_ptr, INTER_UNIT_SPC_FLD, 0, 0, form_text, 0);

  sprintf(form_text,"%d",readout_spec.intrameas_spacing);
  status = FIfld_set_text(form_ptr, INTRA_UNIT_SPC_FLD, 0, 0, form_text, 0);

  sprintf(form_text,"%c",readout_spec.left_fill_char);
  status = FIfld_set_text(form_ptr, FILL_CHAR_FLD, 0, 0, form_text, 0);

  sprintf(form_text,"%d",readout_spec.precision);
  status = FIfld_set_text(form_ptr, DECIMAL_ACCUR_FLD, 0, 0, form_text, 0);

  sprintf(form_text,"%d",readout_spec.denominator );
  status = FIfld_set_text(form_ptr, FRAC_DENOM_FLD, 0, 0, form_text, 0);

  status = FIfld_set_select(form_ptr,CASE_FLD,readout_spec.case_type,0,0);
  status = FIfld_set_select(form_ptr,JUSTIFICATION_FLD,
                            readout_spec.justification,0,0);
  status = FIfld_set_select(form_ptr,THOUS_DELIM_FLD,
                            readout_spec.thousands_char,0,0);
  status = FIfld_set_select(form_ptr,DEC_FRAC_MODE_TOG,readout_spec.mode,0,0);

  return OM_S_SUCCESS;
}


/*
Name
  update_meas_form

Abstract
  Updates the fields on the MEASUREMENT form from the table of stored  values

Keywords
  measure,method,form

History
  04/07/93 : Shelley R. Heard : added header

 */
method update_meas_form ( long *sts )
{
  IGRlong               status;
  IGRint                i;
  IGRlong               size;
  IGRlong               ret_size;
  IGRlong               num_gadgets_to_update;
  IGRlong               num_form_fields = 0;
  IGRboolean            apparent_flag;
  IGRboolean            absolute_flag;
  IGRshort              num_alias = 3;
  IGRchar               *string_ptrs[NUM_DISTANCE_OUTPUT_FLDS];
  IGRchar               form_flds[NUM_DISTANCE_OUTPUT_FLDS][80];
  struct GRid           module_grid;
  IGRshort              field_size = sizeof(IGRchar) * 80;
  IGRint                local_display_flag;
  struct GRIOreadout_spec readout_spec;
  
/*  double                  scale; */
  extern int FIg_set_state_on();
  extern int FIg_set_state_off();
  extern int FIfld_set_text();
  extern int FIfld_get_text();
  extern int FIfld_set_select();

  *sts = MSSUCC;
  status = OM_S_SUCCESS;

  for(i=0; i<NUM_DISTANCE_OUTPUT_FLDS; i++)
  {
    form_flds[i][0] = 0;      
    string_ptrs[i] = &form_flds[i][0];
  }
  /* clear message field  */
  status = FIfld_set_text(me->status_display_form_ptr,MSG_FLD,
                          0,0,"  ",0);


  if(strcmp(me->active_form_name,MEASURE_DISTANCE_FORM) == 0)
  {
    num_form_fields = NUM_DISTANCE_OUTPUT_FLDS;
    strcpy(me->Units,GRIO_DISTANCE);
    num_gadgets_to_update =
      NUM_DISTANCE_OUTPUT_FLDS+NUM_DISTANCE_TOGGLES+2;


    size = sizeof(absolute_flag);
    status = gr$get_local_abs_flag( msg = sts,
                                    sizbuf = &size,
                                    buffer = &absolute_flag,
                                    nret= &ret_size );

    status = (absolute_flag) ?
      FIg_set_state_off(me->status_display_form_ptr,ABS_LOCAL_TOGGLE) :
        FIg_set_state_on(me->status_display_form_ptr,ABS_LOCAL_TOGGLE);


    FIg_set_state_off(me->status_display_form_ptr,NO_DRAW);
    FIg_set_state_off(me->status_display_form_ptr,DRAW_LINE);
    FIg_set_state_off(me->status_display_form_ptr,PLACE_LINE);
    FIg_set_state_on(me->status_display_form_ptr,me->draw_mode);
  }
  else if(strcmp(me->active_form_name,MEASURE_ANGLE_FORM)  == 0)
  {
    num_form_fields = NUM_ANGLE_OUTPUT_FLDS;
    num_gadgets_to_update = NUM_ANGLE_OUTPUT_FLDS+NUM_ANGLE_TOGGLES;
    strcpy(me->Units,GRIO_ANGLE);
  }

  status = ex$get_cur_mod( id = &module_grid.objid,
                           osnum = &module_grid.osnum );
  /*
   * TR 119304151: in this situation, we force justification of output to be 
   * LEFT since it makes no sence to do anything else.  SRH 5/25/93
   */ 
  status = co$update_readout_spec( msg = sts,
                                   unit_type = me->Units,
                                   osnum = module_grid.osnum,
                                   update_flag = FALSE,
                                   readout_spec = &readout_spec);
  readout_spec.justification = GRIO_LEFT_JUSTIFY;
                                  
  status = co$cvt_imp_to_alias( msg = sts,
                                unit_type = me->Units,
                                working_units = me->form_fields,
                                num_alias = &num_alias,
                                field_size = &field_size,
                                readout_spec = &readout_spec,
                                osnum = module_grid.osnum,
                                num_conversions = num_form_fields,
                                cvt_list = string_ptrs);

  if(!( me->display_field &  GR_COMEAS_DISPLAY_CURRENT_DISTANCE) )
  {
    form_flds[CURRENT_MEAS_IND][0] = 0;
  }

  if(!( me->display_field &  GR_COMEAS_DISPLAY_BASE_CURRENT_DISTANCE ) )
  {
    form_flds[DIST_BASE_TO_CURR_IND][0] = 0;
  }

  if(me->form_fields[CURRENT_MEAS_IND] ==
     me->form_fields[CUMULATIVE_MEAS_IND])
  {
    form_flds[CUMULATIVE_MEAS_IND][0] = 0;
  }

  local_display_flag = me->display_field;
  for(i=3; i< NUM_DISTANCE_OUTPUT_FLDS; i++)
  {
    if( (i%3) == 0 && i > 5) local_display_flag = local_display_flag >> 1;
    if( !(local_display_flag & 1)) form_flds[i][0] = 0;
  }

  for(i=0; i<num_form_fields; i++)
  {
    status = FIfld_set_text( me->status_display_form_ptr,
                             field_position[i],
                             0,
                             0,
                             form_flds[i],
                             0);
  }

  /* update TRUE/APPARENT toggle */
  size = sizeof(apparent_flag);
  status = gr$get_apparent_flag(msg = sts,
                                sizbuf = &size,
                                buffer = &apparent_flag,
                                nret= &ret_size);

  me->app_flag = apparent_flag;

  status = (apparent_flag) ?
    FIg_set_state_on(me->status_display_form_ptr,TRUE_APPARENT_TOGGLE) :
      FIg_set_state_off(me->status_display_form_ptr,TRUE_APPARENT_TOGGLE);

  if(((strcmp(me->forms[0].name,MEASURE_DISTANCE_FORM) == 0) ||
       (strcmp(me->forms[0].name,MEASURE_ANGLE_FORM) == 0) &&
       me->forms[0].displayed))
  {
    FIg_set_state_on(me->status_display_form_ptr,READOUT_BUTTON);
  }
  else
  {
    FIg_set_state_off(me->status_display_form_ptr,READOUT_BUTTON);
  }

  return OM_S_SUCCESS;
}


/*
Name
  clear_fields

Abstract
  Clears the stored values to start the process over again.

Keywords
  measure,method

History
  04/07/93 : Shelley R. Heard : added header

 */
method clear_fields ( long *sts )
{
  IGRlong      status;
  IGRshort     i;

  *sts = MSSUCC;
  status = OM_S_SUCCESS;
  me->display_field  =  0;
  for(i=0;i<9;i++)
  {
    me->cur_fields[i] = 0.0;
  }
  for(i=0; i<(NUM_DISTANCE_OUTPUT_FLDS - 1); i++)
  {
    me->form_fields[i] = 0.0;
  }

  return OM_S_SUCCESS;
}


/*
Name
  is_form_displayed 

Abstract
  Returns MSSUCC (in *sts) if the measurement form is displayed 
  Returns MSFAIL (in *sts) if the measurement form is not displayed 

Keywords
  measure,method,form

History
  04/07/93 : Shelley R. Heard : added header

 */
method is_form_displayed ( long *sts )
{
  IGRlong               status;

  status = OM_S_SUCCESS;
  *sts = (me->form_requested) ? MSSUCC : MSFAIL;

  return OM_S_SUCCESS;
}


/*
Name
  save_current_readout_spec

Abstract
  Saves the user's new readout specs in the appropriate UOM object

Keywords
  measure,method,units

History
  04/07/93 : Shelley R. Heard : added header

 */
method save_current_readout_spec ( long *sts )
{
  IGRlong                 status;
  struct GRid             module_grid;
  IGRint                  Index;
  Form                    form;

  *sts = MSSUCC;
  status = OM_S_SUCCESS;

  status = om$send(msg = message CEO.get_form_ptr(READOUT_SPEC_FORM,
                                                 &form,
                                                 &Index,
                                                 (int *) sts),
                   targetid = my_id );
  _m_check2q(status,*sts);

  if(strcmp(me->forms[Index].name,MEASURE_DISTANCE_FORM) == 0)
  {
    strcpy(me->Units,GRIO_DISTANCE);
  }
  else if(strcmp(me->forms[Index].name,MEASURE_ANGLE_FORM) == 0)
  {
    strcpy(me->Units,GRIO_ANGLE);
  }
  else if(strcmp(me->forms[Index].name,"LinReadout") == 0)
  {
    strcpy(me->Units,GRIO_DISTANCE);
  }
  else if(strcmp(me->forms[Index].name,"AngReadout") == 0)
  {
    strcpy(me->Units,GRIO_ANGLE);
  }

  status = ex$get_cur_mod(id = &module_grid.objid,
                          osnum = &module_grid.osnum );

  status = co$update_readout_spec(msg = sts,
                                  unit_type = me->Units,
                                  osnum = module_grid.osnum,
                                  update_flag = FALSE,
                                  readout_spec = &me->cur_readout_spec);
quit:
  return OM_S_SUCCESS;
}


/*
Name
  form_notification 

Abstract
  Override of form_notification method for the measurement command
  status forms.  Standard protocol.

Keywords
  measure,method,form

History
  04/07/93 : Shelley R. Heard : added header

 */
method form_notification ( int   form_label;
                           int   gadget_label;
                           double value;        
                           char * form_ptr )
{
  IGRlong                 status;
  IGRchar                 text_buffer[GR_COMEAS_FIELD_DIM];
  IGRchar                 form_text[GR_COMEAS_FIELD_DIM];
  IGRint                  sel_flag;
  IGRint                  r_pos;
  IGRint                  i,msg;
  IGRlong                 msg2;
  IGRint                  temp;
  struct GRIOreadout_spec readout_spec;
  struct GRid             module_grid;
  IGRint                  terminate = TERMINATE;
  IGRchar                 buffer[2];
  IGRlong                 size;
  IGRlong                 ret_size;
  IGRboolean              apparent_flag;
  IGRboolean              absolute_flag;
  struct  GRevent         event;
  struct  EX_button       button;
  IGRint                  Index;
  Form                    form;
  struct GRIOvar_def      draw_mode_var;
  extern IGRint           GRaddvar();
  extern int FIg_set_state_on();
  extern int FIg_set_state_off();
  extern int FIfld_set_text();
  extern int FIfld_get_text();
  extern int FIf_get_attr();
  extern int FIf_set_attr();

#ifdef X11
  int                     form_mask;
#endif


  switch (form_label)
  {
    case MEASUREMENT_FORM:
    {
      /*
       * clear the form message field and the status field
       */
      if(gadget_label > (DRAW_LINE-1) && gadget_label < (NO_DRAW+1))
      {
        FIg_set_state_off(form_ptr,me->draw_mode);
        me->draw_mode = gadget_label;
        ex$get_cur_mod( id    = &module_grid.objid,
                        osnum = &module_grid.osnum );
        draw_mode_var.type = GRIO_VAR_INT;
        draw_mode_var.contents.ivalue = me->draw_mode;

        status = co$addvar( msg = &msg,
                            input_alias = "CO_MEAS_DRAW_MODE",
                            osnum = module_grid.osnum,
                            input_string = &draw_mode_var);

        FIg_set_state_on(form_ptr,me->draw_mode);

        break;
      }
      if(gadget_label >= 100 && gadget_label <= 211)
      {
        if(me->push_event_flag)
        {
          me->push_event_flag = FALSE;
          if( gadget_label == 202 || gadget_label == 205 ||
              gadget_label == 208 || gadget_label == 211 )
          {
            size = sizeof(struct EX_button);
            gr$get_last_point( msg    = &msg,
                               sizbuf = &size,
                               buffer = &button,
                               nret   = &ret_size );

            button.x = me->form_fields[gadget_label-199];
            button.y = me->form_fields[gadget_label-198];
            button.z = me->form_fields[gadget_label-197];
            status = co$build_event( msg = &msg,
                                     button  = &button,
                                     event   = &event );
          }
          else
          {
            co$build_event( msg = &msg,
                            event_response = VALUE,
                            event_nbytes = sizeof(IGRdouble),
                            value = &me->form_fields[gadget_label-100],
                            event = &event );
          }
                
          size = sizeof( struct GRevent ) - ( 2 * sizeof( IGRlong ) );
          event.num_id = 0;
          status = ex$putque( msg = &msg2,
                              response = &event.response,
                              pos=FRONT,
                              byte = &size,
                              buffer = (char *)&event.event.button );

          if ( ! me->SuspendedByImmediate )
          {
            size = 2; /* probably not necessary anymore */
            status = ex$putque(msg = &msg2,
                               byte = &size,
                               pos=FRONT,
                               response = &terminate,
                               buffer = buffer );
          }
              
          FIg_set_state_off(form_ptr,gadget_label);
          FIg_set_state_off(form_ptr,PUSH_EVENT_BUTTON);
        }

        if(me->cut_value_flag)
        {
          me->cut_value_flag = FALSE;
          if( gadget_label == 202 || gadget_label == 205 ||
              gadget_label == 208 || gadget_label == 211 )
          {
            char ums_str[GR_COMEAS_FIELD_SIZE];

            ex$message( msgnumb = GR_I_FldDistNotPt, 
                        buff = ums_str,
                        buffer_size=GR_COMEAS_FIELD_SIZE);
            status = FIfld_set_text(form_ptr,MSG_FLD,0,0, ums_str,0);
          }
          else
          {
            IGRchar      keybuf[124];
            IGRshort     field_size = sizeof(IGRchar) * 124;
            IGRint       num_alias = 1;
            struct GRIOreadout_spec readout_spec;


            num_alias = 1; /* force to look compatable */

            /*
             * TR 119304151: in this situation, we force justification of 
             * output to be LEFT since it makes no sence to do anything
             * else.  SRH 5/25/93
             */ 
            ex$get_cur_mod(id    = &module_grid.objid,
                           osnum = &module_grid.osnum );

            status = co$update_readout_spec( msg = &msg,
                                             unit_type = me->Units,
                                             osnum = module_grid.osnum,
                                             update_flag = FALSE,
                                             readout_spec = &readout_spec);
            readout_spec.justification = GRIO_LEFT_JUSTIFY;

            status = co$cvt_imp_to_alias(
                         msg =  &msg,
                         osnum = module_grid.osnum,
                         unit_type = GRIO_DISTANCE,
                         field_size = &field_size,
                         readout_spec = &readout_spec,
                         working_units = &me->form_fields[gadget_label-100],
                         inverse_scale_flag = GRIO_X_SCALE,
                         num_alias = &num_alias,
                         cvt_list = keybuf );

            /* 
             *  WARNING: Calling GRput_keybuff() is DANGEROUS!
             *  I'm only doing it in order to fix (spelled 
             *  K_L_U_D_G_E) a hyper-critical TR for NAVSEA.
             *  SRH 05/23/91
             */
            GRput_keybuff( keybuf );
          }
            FIfld_set_text(form_ptr,MSG_FLD,0,0,"",0);
            FIg_set_state_off(form_ptr,gadget_label);
            FIg_set_state_off(form_ptr,CUT_VALUE_BUTTON);
        }
      }

      switch (gadget_label)
      {
        case STANDARD_HELP_BUTTON:
        {
          status = om$send( mode = OM_e_wrt_message,
                            msg = message super_cmd.help(),
                            targetid = my_id );
          FIg_set_state_off(form_ptr,STANDARD_HELP_BUTTON);
          break;
        }

        case STANDARD_ACCEPT_BUTTON:
        {
          FIg_set_state_off(form_ptr,STANDARD_ACCEPT_BUTTON);
          me->form_requested = FALSE;
          status= om$send( msg = message CEO.erase_form_by_label( form_label,
                                                                  0,
                                                                 &msg),
                           targetid = my_id);

          for(i=0; i<me->number_of_forms; i++)
          {
            if(me->forms[i].displayed)
            {
              status= om$send( msg = message CEO.erase_form_by_label(
                                                  me->forms[i].label,
                                                  0,
                                                 &msg),
                               targetid = my_id);

              me->forms[i].displayed = FALSE;
            }
          }

          break;
        }

        case TRUE_APPARENT_TOGGLE:
        {
          size = sizeof(apparent_flag);
          status = gr$get_apparent_flag( msg = &msg,
                                         sizbuf = &size,
                                         buffer = &apparent_flag,
                                         nret= &ret_size );

          TOGGLE_FLAG(apparent_flag);

          status = gr$put_apparent_flag( msg = &msg,
                                         sizbuf = &size,
                                         buffer = &apparent_flag);

          break;
        }

        case ACTIVE_REF_TOGGLE:
        {
          break;
        }

        case SET_ACTIVE_ANGLE:
        {
          size = sizeof(me->form_fields[0]);
          status = gr$put_active_angle( msg = &msg,
                                        sizbuf = &size,
                                        buffer = &me->form_fields[0]);
          FIg_set_state_off(form_ptr,SET_ACTIVE_ANGLE);
          break;
        }


        case ABS_LOCAL_TOGGLE:
        {
          size = sizeof( absolute_flag );
          status = gr$get_local_abs_flag( msg = &msg,
                                          sizbuf = &size,
                                          buffer = &absolute_flag,
                                          nret= &ret_size);

          TOGGLE_FLAG(absolute_flag);

          status = gr$put_local_abs_flag( msg = &msg,
                                          sizbuf = &size,
                                          buffer = &absolute_flag);
          break;
        }

        case READOUT_BUTTON:
        {
          if(!value)
          {
            status = om$send (
               msg = message CEO.erase_form_by_label(READOUT_SPEC_FORM,1,&msg),
               targetid = my_id );

            status = om$send (
               msg = message COmeasure.update_meas_form ((long *)&msg),
               targetid = my_id);
          }
          else
          {
            status = ex$get_cur_mod( id = &module_grid.objid,
                                     osnum = &module_grid.osnum );

            status = co$update_readout_spec( 
                        msg = &msg,
                        unit_type = me->Units,
                        osnum = module_grid.osnum,
                        update_flag = FALSE,
                        readout_spec = &me->cur_readout_spec );

            status = om$send(
               msg = message CEO.get_form_ptr( READOUT_SPEC_FORM, 
                                              &form, 
                                              &Index, 
                                              &msg ),
               targetid = my_id );

            if(form != NULL)
            {
/* Begin of fix TR# 11925899 which is a SUN specific problem */
                   
#ifdef X11
              FIf_get_attr(form,&form_mask);
              form_mask &= FI_DEFAULT;
              FIf_set_attr(form,form_mask);
#endif
/* End of fix TR# 11925899 */

              status = om$send (
                 msg = message COmeasure.update_readout_form((long *)&msg),
                 targetid = my_id );

/* display form after filling in form.  port to NT.  01/13/93.  elp */
                   
              status = om$send( 
                 msg = message CEO.display_form_by_label( READOUT_SPEC_FORM,
                                                         &msg ),
                 targetid = my_id );
            }
          }

          break;
        }

        case PUSH_EVENT_BUTTON:
        {
          char ums_str[GR_COMEAS_FIELD_SIZE];

          ex$message( msgnumb = GR_I_IdFldToPush, 
                      buff = ums_str,
                      buffer_size=GR_COMEAS_FIELD_SIZE);
          me->push_event_flag = TRUE;
          status = FIfld_set_text(form_ptr,MSG_FLD,0,0,ums_str,0);
          FIg_set_state_off(form_ptr,PUSH_EVENT_BUTTON);

          break;
        }

        case CUT_VALUE_BUTTON:
        {
          char ums_str[GR_COMEAS_FIELD_SIZE];

          ex$message( msgnumb = GR_I_IdFldToCut, 
                      buff = ums_str,
                      buffer_size=GR_COMEAS_FIELD_SIZE);
          me->cut_value_flag = TRUE;
          status = FIfld_set_text(form_ptr,MSG_FLD,0,0, ums_str,0);
          FIg_set_state_off(form_ptr,CUT_VALUE_BUTTON);

          break;
        }

      }  /* end switch on gadget_label */
        
      break;
        
    }

    case READOUT_SPEC_FORM:
    case DISTANCE_READOUT_FORM:
    case ANGULAR_READOUT_FORM:
    {
      status = ex$get_cur_mod( id = &module_grid.objid,
                               osnum = &module_grid.osnum );
        
      status = co$update_readout_spec( msg = &msg,
                                       unit_type = me->Units,
                                       osnum = module_grid.osnum,
                                       update_flag = FALSE,
                                       readout_spec = &readout_spec);
      switch ( gadget_label )
      {
        case STANDARD_HELP_BUTTON:
        {
          status = om$send( mode = OM_e_wrt_message,
                            msg = message super_cmd.help(),
                            targetid = my_id );
          FIg_set_state_off(form_ptr,STANDARD_HELP_BUTTON);
        }

        case FI_CANCEL:        
        {
          readout_spec = me->cur_readout_spec;
          FIg_set_state_off(form_ptr,FI_CANCEL);
        }

        case STANDARD_ACCEPT_BUTTON: /* FI_ACCEPT */
        {
          status= om$send(
             msg = message CEO.erase_form_by_label(form_label, 0, &msg),
             targetid = my_id);

          FIg_set_state_off(form_ptr,gadget_label);
          if(!me->form_requested) /* not a status display request */
          {
            size = 2;
            status = ex$putque( msg = &msg2,
                                byte = &size,
                                pos=FRONT,
                                response = &terminate,
                                buffer = buffer );
          }
          else
          {
            FIg_set_state_off( me->status_display_form_ptr,
                               READOUT_BUTTON);
            status = om$send(
               msg = message COmeasure.update_meas_form ((long *)&msg),
               targetid = my_id );

          }

          break;        
        }

        case DEC_FRAC_MODE_TOG:
        {
          readout_spec.mode = (IGRint)value;
          break;
        }

        case CASE_FLD:
        {
          readout_spec.case_type = (IGRint)value;
          break;
        }

        case JUSTIFICATION_FLD:
        {
          readout_spec.justification = (IGRint)value;
          break;
        }

        case FILL_CHAR_FLD:
        {
          status = FIfld_get_text( form_ptr, 
                                   FILL_CHAR_FLD, 
                                   0, 
                                   0, 
                                   GR_COMEAS_FIELD_DIM,
                                   form_text, 
                                  &sel_flag, 
                                  &r_pos);
          i=0;
          while(form_text[i] != 0)
          {
            readout_spec.left_fill_char = (IGRchar)form_text[i];
            i++;
          }
          break;
        }

        case LEADING_ZERO_TOG:
        {
          TOGGLE_FLAG(readout_spec.leading_zeros);
          break;
        }

        case TRAILING_ZERO_TOG:
        {
          TOGGLE_FLAG(readout_spec.trailing_zeros);
          break;
        }

        case INTER_UNIT_SPC_FLD:
        {
          status = FIfld_get_text( form_ptr, 
                                   INTER_UNIT_SPC_FLD, 
                                   0, 
                                   0,
                                   GR_COMEAS_FIELD_DIM, 
                                   form_text, 
                                  &sel_flag,
                                  &r_pos);
          readout_spec.intermeas_spacing = (IGRshort)atoi(form_text);
          break;
        }

        case INTRA_UNIT_SPC_FLD:
        {
          status = FIfld_get_text( form_ptr, 
                                   INTRA_UNIT_SPC_FLD, 
                                   0,
                                   0,
                                   GR_COMEAS_FIELD_DIM,
                                   form_text,
                                  &sel_flag,
                                  &r_pos);
          readout_spec.intrameas_spacing = (IGRshort)atoi(form_text);

          break;
        }

        case DECIMAL_COMMA_TOG:
        {
          if(readout_spec.decimal_char == GRIO_COMMA)
          {
            readout_spec.decimal_char = GRIO_PERIOD;
          }
          else if(readout_spec.decimal_char == GRIO_PERIOD)
          {
            readout_spec.decimal_char = GRIO_COMMA;
          }

          break;
        }

        case THOUS_DELIM_FLD:
        {
          readout_spec.thousands_char = (IGRint)value;
          break;
        }

        case FRAC_DENOM_FLD:
        {
          status = FIfld_get_text( form_ptr, 
                                   FRAC_DENOM_FLD,
                                   0,
                                   0,
                                   GR_COMEAS_FIELD_DIM,
                                   form_text,
                                  &sel_flag,
                                  &r_pos);
          readout_spec.denominator = (IGRshort)atoi(form_text);

          break;
        }

        case DECIMAL_ACCUR_FLD:
        {
          status = FIfld_get_text( form_ptr, 
                                   DECIMAL_ACCUR_FLD, 
                                   0, 
                                   0,
                                   GR_COMEAS_FIELD_DIM,
                                   form_text,
                                  &sel_flag,
                                  &r_pos);

          temp = (IGRshort)atoi(form_text);
          if( temp >= 0 && temp <= 16)
          {
            readout_spec.precision = temp;
          }
          else
          {
            ex$message( msgnumb = GR_E_InvInp, 
                        field = ERROR_FIELD,
                        justification = LEFT_JUS);

            sprintf(text_buffer,"%d",readout_spec.precision);
            status = FIfld_set_text( form_ptr,
                                     DECIMAL_ACCUR_FLD,
                                     0,
                                     0,
                                     text_buffer,
                                     0);

          }

          break;
        }

        case DISPLAY_UNITS_TOG:
        {
          TOGGLE_FLAG(readout_spec.alias_displayed);
          break;
        }

        default:
          break;
      }/* end switch on label in readout form */
        
      status = co$update_readout_spec( msg = &msg,
                                       unit_type = me->Units,
                                       osnum = module_grid.osnum,
                                       update_flag = TRUE,
                                       readout_spec = &readout_spec );
    }
  }
  return OM_S_SUCCESS;
}
end implementation COmeasure;
