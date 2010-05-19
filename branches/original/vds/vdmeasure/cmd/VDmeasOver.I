/* $Id: VDmeasOver.I,v 1.1.1.1 2001/01/04 21:08:56 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdmeasure/cmd/VDmeasOver.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDmeasOver.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:56  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/11/08  21:48:36  pinnacle
# Created: vdmeasure/cmd/VDmeasOver.I by v241_int for vds.241
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      11/08/96        mf              creation date
 ***************************************************************************/

class implementation VDCmdMeas;

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
%safe
#include <math.h>
%endsafe
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

#include "vdAPIequips.h"
#include "vdmeasure.h"
#include "vdmeaprotos.h"
#include "AS_status.h"

from	GRvg	import	GRgetgeom, GRgetsize;

method update_cursor_fields ( IGRlong *sts )
{
	IGRlong			status;
	IGRchar			*string_ptr[NUM_DISTANCE_OUTPUT_FLDS];
	IGRchar			form_flds[NUM_DISTANCE_OUTPUT_FLDS][80];
	IGRchar			disp_flds[NUM_CURSOR_OUTPUT_FLDS][80];
	IGRchar			ums_str0[GR_COMEAS_FIELD_SIZE];
	IGRchar			ums_str1[GR_COMEAS_FIELD_SIZE];
	IGRchar			ums_str2[GR_COMEAS_FIELD_SIZE];
	IGRchar			ums_str3[GR_COMEAS_FIELD_SIZE];
	IGRchar			ums_str4[GR_COMEAS_FIELD_SIZE];
	IGRchar			ums_str5[GR_COMEAS_FIELD_SIZE];
	IGRchar			*str_ptr[NUM_CURSOR_OUTPUT_FLDS];
	IGRshort		num_entries = 6;
	IGRshort		offset[(NUM_CURSOR_OUTPUT_FLDS*2)];
	IGRshort		i;
	IGRlong			ums_key9, ums_key10;
	IGRshort		num_alias = 3;
	IGRint			len;
	IGRshort		field_size = sizeof(IGRchar) * 80;
	IGRint			local_display_flag;
	IGRdouble		saved_dist; /* part of KLUDGE (see below) */
struct	GRevent			*events[7];
struct	GRIOreadout_spec	readout_spec;
struct	disp_val_info		dval_in;
struct	IGRbsp_curve		*Crv;

	/* Initialize */
	Crv = NULL;
     

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

	/* MF : enhance dynamic display by buffer for 3D curves	*/
	/* 	Keep existing display for lines			*/ 
	if (me->Mea.prop & VD_MEAS_SUPP) {

		IGRlong	size=0;

		/* Get 3D curve geometry size */
		status = om$send ( msg = message GRvg.GRgetsize (
				   sts,
				   &me->Mea.Ocrv.mod_env.md_env.matrix_type,
				   me->Mea.Ocrv.mod_env.md_env.matrix,
				   &size ),
				   targetid = me->Mea.Ocrv.obj_id.objid,
				   targetos = me->Mea.Ocrv.obj_id.osnum );
		as$status ( msg    = "GRvg.GRgetsize",
			    test   = (!(status & 0x00000001 & (*sts))),
			    action = GOTO_VALUE,
			    value  = quit );

		/* Allocate memory */
		Crv = (struct IGRbsp_curve *) om$calloc ( size = size );

		/* Get 3D curve geometry structure */
		status = om$send ( msg = message GRvg.GRgetgeom (
				   sts,
				   &me->Mea.Ocrv.mod_env.md_env.matrix_type,
				   me->Mea.Ocrv.mod_env.md_env.matrix,
				   (IGRchar *) Crv ),
				   targetid = me->Mea.Ocrv.obj_id.objid,
				   targetos = me->Mea.Ocrv.obj_id.osnum );
		as$status ( msg    = "GRvg.GRgetgeom",
			    test   = (!(status & 0x00000001 & (*sts))),
			    action = GOTO_VALUE,
			    value  = quit );

	}

	/* Call display with additional argument (4th) */
	VDrbrasdisp ( &num_entries, offset, str_ptr, &dval_in, Crv );

  /* KLUDGE - replace prev_dist value with saved base_to_current value */
  me->form_fields[DIST_BASE_TO_CURR_IND] = saved_dist;
  /* end KLUDGE part 2 */
  if (dval_in.disp_fld_flag)
    me->fourth_event = me->fifth_event;

quit:
	if (Crv) {	om$dealloc (ptr = Crv);		Crv = NULL;	}
  	return OM_S_SUCCESS;
}

end implementation VDCmdMeas;
