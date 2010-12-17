#include "FImin.h"

#include "FEI.h"
#include "FIbtn.h"
#include "FIfield.h"

#include <sys/types.h>
#include <sys/times.h>

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"

void _FI_generic_move_hort (struct FIgadget_obj  *gadget,
                            int                   new_x)
{
  int width;

  if (gadget)
  {
    width = gadget->FIgadget.xhi - gadget->FIgadget.xlo;

    gadget->FIgadget.xlo = new_x;
    gadget->FIgadget.xhi = gadget->FIgadget.xlo + width;

    _FI_g_adjust_size (gadget, 1.0, 1.0);
  }
}



void _FI_generic_move_vert (struct FIgadget_obj  *gadget,
                            int                   new_y)
{
  int height;

  if (gadget)
  {
    height = gadget->FIgadget.yhi - gadget->FIgadget.ylo;

    gadget->FIgadget.ylo = new_y;
    gadget->FIgadget.yhi = gadget->FIgadget.ylo + height;

    _FI_g_adjust_size (gadget, 1.0, 1.0);
  }
}

/* dmb:10/10/92:Change floats to doubles for ANSI */
int _FI_generic_adjust (struct FIgadget_obj *gadget,
                        double               delta_x,
                        double               delta_y)
{
  /* dmb:10/10/92:Added casts for ANSI */
  gadget->FIgadget.xlo = (float)((double)gadget->FIgadget.xlo * delta_x);
  gadget->FIgadget.ylo = (float)((double)gadget->FIgadget.ylo * delta_y);
  gadget->FIgadget.xhi = (float)((double)gadget->FIgadget.xhi * delta_x);
  gadget->FIgadget.yhi = (float)((double)gadget->FIgadget.yhi * delta_y);

  /* FI_LINE can have width and height of zero */

  if (gadget->FIgadget.type == FI_LINE)
  {
    return (FI_SUCCESS);
  }

  /* Check to make sure the width or height is not zero */

  if ((gadget->FIgadget.xhi - gadget->FIgadget.xlo) == 0)
  {
    gadget->FIgadget.xhi = gadget->FIgadget.xlo + 1;
  }

  if ((gadget->FIgadget.yhi - gadget->FIgadget.ylo) == 0)
  {
    gadget->FIgadget.yhi = gadget->FIgadget.ylo + 1;
  }

  return (FI_SUCCESS);
}


int _FI_generic_find_gadget (struct FIgadget_obj  *gadget,
                             int                   xpos,
                             int                   ypos)
{
  if (IT_IS_NOT_DISPLAYABLE(gadget) || IT_IS_NOT_DISPLAYED(gadget) ||
      IT_IS_DISABLED(gadget))
  {
    return (FALSE);
  }

  if ((gadget->FIgadget.xlo <= xpos) && (gadget->FIgadget.xhi >= xpos) &&
      (gadget->FIgadget.ylo <= ypos) && (gadget->FIgadget.yhi >= ypos))
  {
    return (TRUE);
  }

  return (FALSE);
}



/****** THIS FUNCTION SHOULD BE A void ! -- JAJ:03/26/91 ***/

int _FI_generic_erase (struct FIgadget_obj  *gadget,
                       Window                window)
{
  if (IT_IS_NOT_DISPLAYABLE(gadget))
  {
    return ( FI_SUCCESS );
  }

  XFillRectangle (_FI_display, window, _FI_gc,
      (int) gadget->FIgadget.xlo,
      (int) gadget->FIgadget.ylo,
      (int) gadget->FIgadget.xhi - (int) gadget->FIgadget.xlo + 1,
      (int) gadget->FIgadget.yhi - (int) gadget->FIgadget.ylo + 1 );

  return ( FI_SUCCESS );

}


/* ARGSUSED */
void _FI_clipping_off (struct FIgadget_obj *gadget)
{
  XRectangle rect;

  if (_FI_form_clipping_on)
  {
    rect.x = _FI_clip_xlo;
    rect.y = _FI_clip_ylo;
    rect.width = _FI_clip_xhi - _FI_clip_xlo;
    rect.height = _FI_clip_yhi - _FI_clip_ylo;
    XSetClipRectangles (_FI_display, _FI_gc, 0, 0, &rect, 1, Unsorted);
  }
  else
  {
    XSetClipMask (_FI_display, _FI_gc, None);
  }
}


int _FI_is_in_clip_rectangle (struct FIgadget_instance *gad_inst)
{
  int xlo = gad_inst->xlo;
  int xhi = gad_inst->xhi;
  int ylo = gad_inst->ylo;
  int yhi = gad_inst->yhi;

  if (xlo > xhi)
  {
    xlo = xhi;
    xhi = gad_inst->xlo;
  }
  if (ylo > yhi)
  {
    ylo = yhi;
    yhi = gad_inst->ylo;
  }

  if (_FI_form_clipping_on)
  {
    if ( (xhi < _FI_clip_xlo) || (xlo > _FI_clip_xhi) ||
        (yhi < _FI_clip_ylo) || (ylo > _FI_clip_yhi) )
    {
      return (0);
    }
  }

  return (1);
}



/****** THIS FUNCTION SHOULD BE A void ! -- JAJ:03/26/91 ***/

int _FI_adjust_clip_rectangle (XRectangle *rect)
{
  if (rect->x < _FI_clip_xlo)
  {
    rect->width -= _FI_clip_xlo - rect->x;
    rect->x = _FI_clip_xlo;
  }

  if ((int)(rect->x + rect->width) > _FI_clip_xhi)
  {
    rect->width -= rect->x + rect->width - _FI_clip_xhi;
  }

  if (rect->y < _FI_clip_ylo)
  {
    rect->height -= _FI_clip_ylo - rect->y;
    rect->y = _FI_clip_ylo;
  }

  if ((int)(rect->y + rect->height) > _FI_clip_yhi)
  {
    rect->height -= rect->y + rect->height - _FI_clip_yhi;
  }

  return ( FI_SUCCESS );
}


/****** THIS FUNCTION SHOULD BE A void ! -- JAJ:03/26/91 ***/

int _FI_expand_clip_rectangle (int  x,
                               int  y,
                               int  width,
                               int  height,
                               int *xlo,
                               int *ylo,
                               int *xhi,
                               int *yhi)
{
  if (x < *xlo)
  {
    *xlo = x;
  }

  if ((x + width) > *xhi)
  {
    *xhi = x + width;
  }

  if (y < *ylo)
  {
    *ylo = y;
  }

  if ((y + height) > *yhi)
  {
    *yhi = y + height;
  }

  return ( FI_SUCCESS );
}


/**************************************************/
/*** Returns: 1 if the timer has gone off ***/
/*** 0 otherwise. ***/
/**************************************************/

int _FI_generic_timer (double  wait_secs,
                       int     set)
{
  struct timeval
  {
    long tv_sec;
    long tv_usec;
  }FItimeout;

  if (set)
  {
    if (wait_secs)
    {
      FItimeout.tv_sec = 0;
      FItimeout.tv_usec = (int)(wait_secs * 1000000.0);

      select( 1,0,0,0,&FItimeout);
      return 1;
    }
    else
      return 0;
  }
  else
  {
    return (1);
  }
}
