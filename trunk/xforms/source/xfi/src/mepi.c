#include "FImin.h"

#include <math.h>
#include "FIbtn.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"

/* This routine gets the palette name for the button specified */

int FIbtn_get_palette (Form	 form,
                       int   label,
                       char  pal_name[])
{
  struct FIbtn_obj *btn;

  btn = (struct FIbtn_obj *) _FI_g_get_id ( (struct FIform_obj *) form,
							 label );
  if ( ! btn )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  if ( btn->FIgadget.type != FI_BUTTON )
    {
      return ( FI_INVALID_GADGET_TYPE );
    }

  if ( btn->FIbtn.palette )
    {
      strcpy ( pal_name, btn->FIbtn.palette );
    }
  else
    {
      pal_name[0] = '\0';
    }

  return ( FI_SUCCESS );
}


int FIbtn_set_palette (Form  form,
                       int   label,
                       char *pal_name)
{
  struct FIbtn_obj *btn;

  btn = (struct FIbtn_obj *) _FI_g_get_id ( (struct FIform_obj *) form,
							 label );

  if ( ! btn )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  if ( btn->FIgadget.type != FI_BUTTON )
    {
      return ( FI_INVALID_GADGET_TYPE );
    }

  _FI_s_rep ( &btn->FIbtn.palette, pal_name );

  return ( FI_SUCCESS );
}


int FIbtn_set_menu_status (Form  form,
                           int   label,
                           int   status)
{
  struct FIbtn_obj *btn;

  btn = (struct FIbtn_obj *) _FI_g_get_id ( (struct FIform_obj *) form,
							 label );
  if ( ! btn )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  if ( btn->FIgadget.type != FI_BUTTON )
    {
      return ( FI_INVALID_GADGET_TYPE );
    }

  btn->FIbtn.menu_button = status;

  return ( FI_SUCCESS );
}


int FIbtn_get_menu_status (Form form,
                           int  label,
                           int *status)
{
  struct FIbtn_obj *btn;

  btn = (struct FIbtn_obj *) _FI_g_get_id ( (struct FIform_obj *) form,
							 label );
  if ( ! btn )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  if ( btn->FIgadget.type != FI_BUTTON )
    {
      return ( FI_INVALID_GADGET_TYPE );
    }

  *status = btn->FIbtn.menu_button;

  return ( FI_SUCCESS );
}



int FIg_get_off_color2 (Form  form,
                        int   label,
                        int  *off_color2)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  *off_color2 = OFF_COLOR2 ( gadget );

  return ( FI_SUCCESS );
}



int FIg_get_on_color2 (Form  form,
                       int   label,
                       int  *on_color2)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  *on_color2 = ON_COLOR2 ( gadget );

  return ( FI_SUCCESS );
}



/*******************************************************************

	FIg_set_off_color2

	History:
		sml	07-06-93	Created

*********************************************************************/

int FIg_set_off_color2 (Form  form,
                        int   label,
                        int  off_color2)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  gadget->FIgadget.off_color2 = off_color2;

  return ( FI_SUCCESS );
}



/*******************************************************************

	FIg_set_on_color2

	History:
		sml	07-06-93	Created

*********************************************************************/

int FIg_set_on_color2 (Form  form,
                       int   label,
                       int  on_color2)
{
  struct FIgadget_obj *gadget;

  gadget = _FI_g_get_id ( (struct FIform_obj *) form, label );

  if ( ! gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  gadget->FIgadget.on_color2 = on_color2;

  return ( FI_SUCCESS );
}

