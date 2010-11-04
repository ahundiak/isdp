#include "FImin.h"

#include "FIbtn.h"
#include "FIfield.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"

/*====================================================================*/

int FIfld_get_list_mode (Form  form,
                         int   label,
                         int   col,
                         int  *mode)
{
  int status;
  struct FIfld_obj *field;

  status = _FI_fld_get_field ( (struct FIform_obj *) form, label,
							 col, &field );
  if ( status )
    {
      return ( status );
    }

  if ( ! field->FIfield.list_id )
    {
      return ( FI_INVALID_GADGET_TYPE );
    }

  *mode = field->FIfield.list_id->FIfield.mode;
  return ( FI_SUCCESS );
}


/*====================================================================*/

int FIfld_set_list_mode (Form  form,
                         int   label,
                         int   col,
                         int   mode)
{
  int status;
  struct FIfld_obj *field;

  /*** <pds-1/4/90> Added check for valid mode ***/
  if (( mode < FI_SINGLE_SELECT ) || ( mode > FI_MULTI_SELECT ))
    {
      return FI_ILLEGAL_VALUES;
    }

  status = _FI_fld_get_field ( (struct FIform_obj *) form, label,
							col, &field );
  if ( status )
    {
      return ( status );
    }

  if ( ! field->FIfield.list_id )
    {
      return ( FI_INVALID_GADGET_TYPE );
    }

  field->FIfield.list_id->FIfield.mode = mode;

  return ( FI_SUCCESS );
}

/*====================================================================*/

int FIfld_get_list_location (Form  form,
                             int   label,
                             int   col,
                             int  *xpos,
                             int  *ypos)
{
  int status;
  struct FIfld_obj *field;

  status = _FI_fld_get_field ( (struct FIform_obj *) form, label,
							col, &field );
  if ( status )
    {
      return ( status );
    }

  if ( ! field->FIfield.list_id )
    {
      return ( FI_INVALID_GADGET_TYPE );
    }

  *xpos = field->FIfield.list_id->FIgadget.xlo;
  *ypos = field->FIfield.list_id->FIgadget.ylo;

  return ( FI_SUCCESS );
}

/*====================================================================*/

int FIfld_set_list_location (Form  form,
                             int   label,
                             int   col,
                             int   xpos,
                             int   ypos)
{
  int		status, delta_x, delta_y;
  struct FIfld_obj *field;
  struct FIfld_obj *list_id;

  status = _FI_fld_get_field ( (struct FIform_obj *) form, label,
							col, &field );
  if ( status )
    {
      return ( status );
    }

  list_id = field->FIfield.list_id;

  if ( ! list_id )
    {
      return ( FI_INVALID_GADGET_TYPE );
    }

  if (	( xpos == list_id->FIgadget.xlo )	&&
	( ypos == list_id->FIgadget.ylo )	 )
    {
      return ( FI_SUCCESS );
    }

  delta_x = xpos - list_id->FIgadget.xlo;
  delta_y = ypos - list_id->FIgadget.ylo;

  list_id->FIgadget.xlo = xpos;
  list_id->FIgadget.ylo = ypos;

  list_id->FIgadget.xhi += delta_x;
  list_id->FIgadget.yhi += delta_y;

  if ( list_id->FIfield.vscrl_id )
    {
      _FI_g_change_location ( (struct FIgadget_obj *)list_id->FIfield.vscrl_id,
						delta_x, delta_y );
    }

  _FI_grp_change_size ( (struct FIgroup_obj *) field->FIgadget.group,
				(struct FIgadget_obj *) list_id );

  return ( FI_SUCCESS );
}

/*====================================================================*/

int FIfld_get_list_size (Form  form,
                         int   label,
                         int   col,
                         int  *xsize,
                         int  *ysize)
{
  int status;
  struct FIfld_obj *field;
  struct FIfld_obj *list_id;

  status = _FI_fld_get_field ( (struct FIform_obj *) form, label,
							col, &field );
  if ( status )
    {
      return ( status );
    }

  list_id = field->FIfield.list_id;

  if ( ! list_id )
    {
      return ( FI_INVALID_GADGET_TYPE );
    }


  *xsize = list_id->FIgadget.xhi - list_id->FIgadget.xlo;
  *ysize = list_id->FIgadget.yhi - list_id->FIgadget.ylo;

  return ( FI_SUCCESS );
}


/*====================================================================*/

int FIfld_set_list_size (Form  form,
                         int   label,
                         int   col,
                         int   xsize,
                         int   ysize)
{
  int		status;
  float		current_xsize;
  float		current_ysize;
  struct FIfld_obj *field;
  struct FIfld_obj *list_id;

  /*** <pds-1/4/89> Check for negative or zero size ***/

  if (( xsize < 1 ) || ( ysize < 1 ))
    {
      return ( FI_ILLEGAL_VALUES );
    }

  status = _FI_fld_get_field ( (struct FIform_obj *) form, label,
							col, &field );
  if ( status )
    {
      return ( status );
    }

  list_id = field->FIfield.list_id;

  if ( ! list_id )
    {
      return ( FI_INVALID_GADGET_TYPE );
    }


  current_xsize = list_id->FIgadget.xhi - list_id->FIgadget.xlo ;
  current_ysize = list_id->FIgadget.yhi - list_id->FIgadget.ylo ;


	/* if size is the same, return */

  if (	( (float) xsize == current_xsize )	&&
	( (float) ysize == current_ysize )	 )
    {
      return ( FI_SUCCESS );
    }

	/**************************************************************/
	/*  Scaling should be handled elsewhere.                      */
	/*  Why this is being done here is beyond me.   GMD 4/4/91    */
	/**************************************************************/

  /**************************************************
  if ( current_xsize && current_ysize )
    {
      delta_x = (float) xsize /  current_xsize ;
      delta_y = (float) ysize /  current_ysize ;
    }
  else
    {
      delta_x = 0.0;
      delta_y = 0.0;
    }
  *****************************************************/


  list_id->FIgadget.xhi = list_id->FIgadget.xlo + xsize;
  list_id->FIgadget.yhi = list_id->FIgadget.ylo + ysize;

  _FI_fld_calc_nv ( list_id );


  /*****************************************************
  if ( delta_x )
    {
      _FI_g_adjust_size ( list_id, delta_x, delta_y );

      if ( list_id->FIfield.vscrl_id )
	{
         _FI_g_adjust_size ( list_id->FIfield.vscrl_id,
						 delta_x, delta_y );
	}
    }
  *********************************************************/

  return ( FI_SUCCESS );
}
