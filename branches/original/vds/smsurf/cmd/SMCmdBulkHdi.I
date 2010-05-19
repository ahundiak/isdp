/* $Id: SMCmdBulkHdi.I,v 1.1.1.1 2001/01/04 21:07:38 cvs Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:        smsurf/cmd/SMCmdBulkHdi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: SMCmdBulkHdi.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:38  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1997/02/06  21:19:00  pinnacle
# Created: smsurf/cmd/SMCmdBulkHdi.I by jwfrosch for vds.241
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *************************************************************************/

class implementation SMCmdBulkHd;

#define AS_DEBUG	1

#define LOAD_PT		519

static int	x_memo,	y_memo;

/*************************************************************************/

#define _start		 0
#define _restart	 1
#define _loc_macro	 2
#define _reloc_macro	 3
#define _modif_form	 4
#define _load_cs	 5
#define _load_point	 6
#define _load_from_occ	 7

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

void VDdisplay_erase_blkhd_symbol ( char *form_ptr, double *height )
{
  char	txt[80];

  txt[0] = 0;

  FIg_get_text ( form_ptr, HIGHT, txt );
  if ( strcmp (txt, "") == NULL )
  {
    *height = 0.0;

    FIg_erase   ( form_ptr, SYMBOL_201 );
    FIg_display ( form_ptr, SYMBOL_200 );
  }
  else
  {
    *height = atof ( txt );
    if ( *height > 0.0 )
    {
      FIg_erase   ( form_ptr, SYMBOL_201 );
      FIg_display ( form_ptr, SYMBOL_200 );
    }
    else
    {
      FIg_erase   ( form_ptr, SYMBOL_200 );
      FIg_display ( form_ptr, SYMBOL_201 );
    }
  }
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method init_all ( long * sts )
{
  int		status = OM_S_SUCCESS;

  long		test;

  om$send(	msg	 = message SMCmdSurf.init_all(&test),
		targetid = my_id,
		mode	 = OM_e_wrt_message);

  me->point.obj_id.objid     = NULL_OBJID;
  me->old_point.obj_id.objid = NULL_OBJID;

  me->dir_axis		= 'z';
  me->x_axis		= 'x';
  me->hight		= 0.;
  me->len1		= 0.;
  me->len2		= 0.;
  me->rad1		= 0.;
  me->rad2		= 0.;
  me->period		= 0;

  me->old_dir_axis	= 'z';
  me->old_x_axis	= 'x';
  me->old_hight		= 0.;
  me->old_len1		= 0.;
  me->old_len2		= 0.;
  me->old_rad1		= 0.;
  me->old_rad2		= 0.;
  me->old_period	= 0;

  if(me->mytype == PLACE)
  {
    (void) GetDefName ( "SMbulkhead_0", me->def_name );
    FIg_set_text ( me->forms[0].form_ptr, OCC_NAME, me->def_name );
    FIg_set_text ( me->forms[0].form_ptr, F_TITLE, "Place Bulkhead" );
  }
  else
  {
    FIg_set_text ( me->forms[0].form_ptr, F_TITLE, "Modify Bulkhead" );
  }
  if(x_memo != 0 && y_memo != 0)
  {
    FIf_set_location ( me->forms[0].form_ptr, x_memo, y_memo );
  }
  FIg_erase   ( me->forms[0].form_ptr, SYMBOL_201 );
  FIg_display ( me->forms[0].form_ptr, SYMBOL_200 );

  return status;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method delete_all ( long * sts )
{
  int		status = OM_S_SUCCESS;

  IGRlong	test;

  *sts = OM_S_SUCCESS;

  om$send(	msg	 = message SMCmdSurf.delete_all(&test),
		targetid = my_id,
		mode	 = OM_e_wrt_message);

  if ( me->forms[0].form_ptr != NULL )
  {
    FIf_get_location ( me->forms[0].form_ptr, &x_memo, &y_memo );
  }
  return status;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method form_notification (	int	 form_label;
				int	 gadget_label;
				double	 value;
				char	*form_ptr)
{
  int	status = OM_S_SUCCESS;
  int	sel_flag, r_pos;

  VDdisplay_erase_blkhd_symbol ( form_ptr, &me->hight );
  FIg_set_text(form_ptr, FI_MSG_FIELD, "");

  switch( gadget_label )
  {
    case FI_ACCEPT:
    case FI_EXECUTE:
    case FI_RESET:
    case FI_CANCEL:
    case LOAD:
    case OCC_NAME:
    case EXTENSION:
    case COORDINATE:
    {
      om$send(	msg	 = message SMCmdSurf.form_notification(
						form_label,
						gadget_label,
						value,
						form_ptr),
		targetid = my_id,
		mode	 = OM_e_wrt_message);
      break;
    }
    case POINT:
    {
      _put_response(resp = LOAD_PT);

      break;
    }
    case HIGHT:
    {
      VDdisplay_erase_blkhd_symbol ( form_ptr, &me->hight );

      break;
    }
    case RAD_1_GAD:
    {
      FIfld_get_value(form_ptr, RAD_1_GAD, 0 ,0 , &me->rad1, &sel_flag, &r_pos);

      if ( me->rad1 < 0.0 )
      {
	FIg_set_text(form_ptr, FI_MSG_FIELD, "Radius must be > 0");
	me->rad1 = fabs(me->rad1);

	FIfld_set_value(me->forms[0].form_ptr, RAD_1_GAD, 0 ,0 , me->rad1, FALSE);
      }

//  printf("6 me->rad1 = %lg\n",me->rad1);

      break;
    }
    case RAD_2_GAD:
    {
      FIfld_get_value(form_ptr, RAD_2_GAD, 0 ,0 , &me->rad2, &sel_flag, &r_pos);

      if ( me->rad2 < 0.0 )
      {
	FIg_set_text(form_ptr, FI_MSG_FIELD, "Radius must be > 0");
	me->rad2 = fabs(me->rad2);

	FIfld_set_value(me->forms[0].form_ptr, RAD_2_GAD, 0 ,0 , me->rad2, FALSE);
      }

      break;
    }
  }
quit:
  return status;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

end implementation SMCmdBulkHd;
