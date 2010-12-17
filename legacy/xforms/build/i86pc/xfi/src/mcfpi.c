#include "FImin.h"

#include <stdio.h>
#include "FIscroll.h"
#include "FIbtn.h"
#include "FIfield.h"
#include "FImcf.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"

/*****************************************************************/
/* */
/* FImcf_set_scroll_link */
/* */
/* This function allows the application to connect two MCF */
/* gadgets. The master MCF will then control the scrolling */
/* of the header MCF. This information is saved to disk so */
/* that it can be read in later. */
/* */
/*****************************************************************/

int FImcf_set_scroll_link (Form form,
                           int  master_mcf,
                           int  header_mcf)
{
   struct FImcf_obj *mcfield;
   struct FImcf_obj *mcfield2;
   unsigned char low_byte;
   unsigned char high_byte;

   mcfield = (struct FImcf_obj *) _FI_g_get_id ( (struct FIform_obj *) form, master_mcf);
   if (! mcfield)
      {
	  return (FI_NO_SUCH_GADGET);
      }
   if (mcfield->FIgadget.type != FI_MULTI_COL)
      {
	  return (FI_INVALID_GADGET_TYPE);
      }

   mcfield2 = (struct FImcf_obj *) _FI_g_get_id ( (struct FIform_obj *) form, header_mcf);
   if (! mcfield2)
      {
	  return (FI_NO_SUCH_GADGET);
      }
   if (mcfield2->FIgadget.type != FI_MULTI_COL)
      {
	  return (FI_INVALID_GADGET_TYPE);
      }

   low_byte = header_mcf % 256;
   high_byte = header_mcf / 256;

   mcfield->FIgadget.off_color2 = low_byte;
   mcfield->FIgadget.on_color2 = high_byte;

   /**********************************/
   /* */
   /* Set last col_off for later use */
   /* */
   /**********************************/

  /* CHUNN problem if they call set_standard_vars after this function */

   mcfield->FIgadget.sym_width_scale_factor = mcfield->FImcf.col_off;

   return (FI_SUCCESS);
}

/*****************************************************************/
/* */
/* FImcf_get_scroll_link */
/* */
/* This function allows the application to find out if a MCF */
/* is linked to a header MCF. Any non-zero value is the */
/* gadget label of the header MCF. */
/* */
/*****************************************************************/

int FImcf_get_scroll_link (Form  form,
                           int   master_mcf,
                           int  *header_mcf)
{
   struct FImcf_obj *mcfield;
   unsigned char low_byte;
   unsigned char high_byte;

   mcfield = (struct FImcf_obj *) _FI_g_get_id ( (struct FIform_obj *) form, master_mcf);
   if (! mcfield)
      {
	  return (FI_NO_SUCH_GADGET);
      }
   if (mcfield->FIgadget.type != FI_MULTI_COL)
      {
	  return (FI_INVALID_GADGET_TYPE);
      }

   low_byte = mcfield->FIgadget.off_color2;
   high_byte = mcfield->FIgadget.on_color2;

   *header_mcf = (high_byte * 256) + low_byte;

   return (FI_SUCCESS);
}

/************************************************************/
/* */
/* FImcf_insert_col */
/* */
/* This function allows the application to insert a */
/* column into a multi-column field. The application */
/* needs to specify the new column's mode, type, */
/* attributes, and the number of characters in the */
/* column. */
/* */
/************************************************************/

int FImcf_insert_col (Form form,
                      int label,
                      int col,
                      int chars,
                      int mode,
                      int Type)
{
   struct FImcf_obj *mcfield;
   struct FIfld_obj *field;
   struct FIfld_obj *field2;
/*   Gadget gadget; dmb:04/15/91:exp */
   struct FIgadget_obj *gadget;
   int xx;
   int display_flag;
   int neg_label, status;
   float bodysize;

   mcfield = (struct FImcf_obj *) _FI_g_get_id ( (struct FIform_obj *) form, label);
   if (! mcfield)
      {
	  return (FI_NO_SUCH_GADGET);
      }
   if (mcfield->FIgadget.type != FI_MULTI_COL)
      {
	  return (FI_INVALID_GADGET_TYPE);
      }

   if ((col > (int)mcfield->FImcf.ncol) || (col < 0))
      {
	  return (FI_INVALID_COL);
      }

   mcfield->FImcf.ncol++;

   /* Add a new pointer to the end of the array, if needed */

   if (mcfield->FIgroup.size < mcfield->FImcf.ncol)
     {
	  _FI_grp_alloc ((struct FIgroup_obj *)mcfield, 1);
     }

   /****************************************************/
   /* */
   /* Shift gadget pointers up by one if column isn't */
   /* being added to the end. */
   /* */
   /****************************************************/

   if (col != (mcfield->FImcf.ncol - 1))
   {
      for (xx = mcfield->FImcf.ncol - 1; xx >= col; xx--)
       {
	 mcfield->FIgroup.gadgets[xx]= mcfield->FIgroup.gadgets[xx - 1];
       }
   }

   /*****************************************************************/
   /* */
   /* Create a new column and place it into the proper gadget slot. */
   /* */
   /*****************************************************************/

   _FI_f_get_next_neg_label (mcfield->FIgadget.form, &neg_label);

   status = _FI_g_new (mcfield->FIgadget.form, FI_FIELD, neg_label, &gadget);

   mcfield->FIgroup.gadgets[col]= (struct FIgadget_obj *) gadget;

   field = (struct FIfld_obj *) gadget;

   field->FIgadget.xlo = mcfield->FIgadget.xlo + 8;
   field->FIgadget.ylo = mcfield->FIgadget.ylo + 2;
   field->FIgadget.xhi = mcfield->FIgadget.xhi - 2;
   field->FIgadget.yhi = mcfield->FIgadget.yhi - 2;
   field->FIgadget.off_color = OFF_COLOR(mcfield);
   field->FIgadget.on_color = ON_COLOR(mcfield);

   if (col > 0)
   {
	  bodysize = mcfield->FIgroup.gadgets[0]->FIgadget.bodysize;
	  field->FIgadget.group = mcfield->FIgroup.gadgets[0]->FIgadget.group;
   }
   else
   {
	  bodysize = mcfield->FIgroup.gadgets[1]->FIgadget.bodysize;
	  field->FIgadget.group = mcfield->FIgroup.gadgets[1]->FIgadget.group;
   }

   /* Place scaled bodysize in new column in case the form has */
   /* been scaled. GMD 10/2/90 */

   _FI_s_rep (&field->FIgadget.fontname, mcfield->FIgadget.fontname);
   field->FIgadget.bodysize = bodysize;
   field->FIfield.flags.is_a_col = 1;
   field->FIfield.mode = mode;
   field->FIfield.field_type = Type;
   field->FIfield.prev_sel = -1;
   field->FIfield.flags.lrs = 1;
   field->FIfield.flags.uds = 1;

   _FI_fld_activate (field);

   /* column needs to be filled with blank rows */
   /* equal to the other columns in the MCF. */

   if (col == (mcfield->FImcf.ncol - 1))
   {
	  field2 = (struct FIfld_obj *) mcfield->FIgroup.gadgets[col - 1];
	  field->FIfield.nvr = field2->FIfield.nvr;
	  _FI_fld_set_buffer (field, field2->FIfield.buffer_size, 0);
   }
   else
   {
	  field2 = (struct FIfld_obj *) mcfield->FIgroup.gadgets[col + 1];
	  field->FIfield.nvr = field2->FIfield.nvr;
	  field->FIgadget.font_width = field2->FIgadget.font_width;
	  _FI_fld_set_buffer (field, field2->FIfield.buffer_size, 0);
   }

   for (xx = 0; xx < field->FIfield.buffer_size; xx++)
   {
	  _FI_fld_add_to_line (field, xx, 2);
	  field->FIfield.buffer[xx].line[0] = '\0';
   }

   if (mcfield->FImcf.flags.uds)
   {
	  field->FIfield.flags.uds = 1;
	  field->FIfield.nr = 0;	/* Unlimited number of rows */
	  field->FIgadget.font_width = field2->FIgadget.font_width;
   }
   else
   {
	  field->FIfield.nr = field->FIfield.nvr;
   }

   /*** <pds-1/4/90> A width less than 1 does not make any sense ***/
   if (chars < 1)
      {
	  chars = 1;
      }

   field->FIfield.nvc = chars;
   field->FIfield.nc = 0;	/* Unlimited character entry */

   /****************************************************/
   /* */
   /* If a column is inserted before the view area, */
   /* then FImcf.col_off needs to be incremented. */
   /* */
   /****************************************************/

   if (col < (int)mcfield->FImcf.col_off)
   {
	  mcfield->FImcf.col_off++;
   }

   /*******************************************************/
   /* */
   /* If a column is deleted within or beyond view, */
   /* then FImcf.col_off can remain the same. */
   /* */
   /*******************************************************/

   display_flag = IT_IS_DISPLAYED(mcfield);
   _FI_g_erase ( (struct FIgadget_obj *) mcfield);

   _FI_mcf_adjust_cols (mcfield);

   if (display_flag)
   {
	  FIg_display ( (Form) mcfield->FIgadget.form, mcfield->FIgadget.label);
   }

   return (FI_SUCCESS);
}

/************************************************************/
/* */
/* FImcf_delete_col */
/* */
/* This function allows the application to delete a */
/* column from a multi-column field. */
/* */
/************************************************************/

int FImcf_delete_col (Form  form,
                      int   label,
                      int   col)
{
   struct FImcf_obj *mcfield;
   int	xx;
   int	display_flag;
   float temp_float_xhi, temp_float_xlo;

   mcfield = (struct FImcf_obj *) _FI_g_get_id ( (struct FIform_obj *) form, label);
   if (! mcfield)
      {
	  return (FI_NO_SUCH_GADGET);
      }
   if (mcfield->FIgadget.type != FI_MULTI_COL)
      {
	  return (FI_INVALID_GADGET_TYPE);
      }

   if ((col >= (int)mcfield->FImcf.ncol) || (col < 0))
      {
	  return (FI_INVALID_COL);
      }

   /*************************************************************/
   /* */
   /* Deleting a column corrupts the mcfield xlo and xhi values */
   /* so I am saving them here to be restored later. */
   /* */
   /*************************************************************/

   temp_float_xhi = mcfield->FIgadget.xhi;
   temp_float_xlo = mcfield->FIgadget.xlo;

   mcfield->FImcf.ncol--;

   _FI_g_delete ((struct FIgadget_obj *)mcfield->FIgroup.gadgets[col], TRUE);
   mcfield->FIgroup.gadgets[col]= 0;

   /* Shift gadget pointers up by one if it wasn't the */
   /* last column to be deleted. */

  for (xx = col; xx < (int)mcfield->FImcf.ncol; xx++)
    {
	 mcfield->FIgroup.gadgets[xx]= mcfield->FIgroup.gadgets[xx + 1];
    }
   mcfield->FIgroup.gadgets[mcfield->FImcf.ncol]= 0;

   /****************************************************/
   /* */
   /* If a column is deleted before the view area, */
   /* then FImcf.col_off needs to be decremented. */
   /* */
   /* FImcf.col_off also needs to be decremented if */
   /* the view area contains the rightmost columns */
   /* of the mcf. This could result in a col_off of */
   /* -1 if all columns are currently visible. The */
   /* lowest valid col_off is zero, so it will be */
   /* changed to zero if this is the case. */
   /* */
   /****************************************************/

   if ((col < (int)mcfield->FImcf.col_off) || (((short)mcfield->FImcf.col_off + (short)mcfield->FImcf.nvcol) == (short)mcfield->FImcf.ncol + 1.0))
   {
	  if (mcfield->FImcf.col_off != 0)
	    {
		 mcfield->FImcf.col_off--;
	    }
	  else
	  {
         /*********************************************************
         mcfield->FImcf.nvcol--;

         if(mcfield->FImcf.vscrl_id)
         {
           if(IT_IS_DISPLAYED(mcfield->FImcf.vscrl_id))
           {
             _FI_g_erase(mcfield->FImcf.vscrl_id);
           }

            temp_float_xhi =
		 mcfield->FIgroup.gadgets[mcfield->FImcf.ncol - 1]->FIgadget.xhi + 4 ;

           _FI_generic_move_hort(mcfield->FImcf.vscrl_id, temp_float_xhi);
         }
         *********************************************************/
	  }
   }

   /*******************************************************/
   /* */
   /* If a column is deleted within or beyond view, */
   /* then FImcf.col_off can remain the same. */
   /* */
   /*******************************************************/

   mcfield->FIgadget.xhi = temp_float_xhi;
   mcfield->FIgadget.xlo = temp_float_xlo;

   display_flag = IT_IS_DISPLAYED(mcfield);
   _FI_g_erase ( (struct FIgadget_obj *) mcfield);

   _FI_mcf_adjust_cols (mcfield);

   if (display_flag)
   {
  FIg_display ( (Form) mcfield->FIgadget.form, mcfield->FIgadget.label);
   }

   return (FI_SUCCESS);
}


/*====================================================================*/

int FImcf_get_view_data (Form  form,
                         int   label,
                         int  *col_offset,
                         int  *num_vis_cols)
{
   struct FImcf_obj *mcfield;

   mcfield = (struct FImcf_obj *) _FI_g_get_id ( (struct FIform_obj *) form, label);
   if (! mcfield)
      {
	  return (FI_NO_SUCH_GADGET);
      }
   if (mcfield->FIgadget.type != FI_MULTI_COL)
      {
	  return (FI_INVALID_GADGET_TYPE);
      }

   *col_offset = mcfield->FImcf.col_off;
   *num_vis_cols = mcfield->FImcf.nvcol;

   return (FI_SUCCESS);
}



/*====================================================================*/
/*********************************************************************/
/* */
/* FImcf_set_low_value - allows you to set the low value for */
/* each of the columns of a MCF. */
/* */
/* Mack Draper - June 1st, 1989 */
/* */
/*********************************************************************/

int FImcf_set_low_value (Form    form,
                         int     label,
                         int     col,
                         double  value)
{
   struct FImcf_obj *mcfield;

   mcfield = (struct FImcf_obj *) _FI_g_get_id ( (struct FIform_obj *) form, label);
   if (! mcfield)
      {
	  return (FI_NO_SUCH_GADGET);
      }

   if (mcfield->FIgadget.type != FI_MULTI_COL)
      {
	  return (FI_INVALID_GADGET_TYPE);
      }

   if ((col >= (int)mcfield->FImcf.ncol) || (col < 0))
      {
	  return (FI_INVALID_COL);	/* 12/01/89 GMD */
      }

   ((struct FIfld_obj *) mcfield->FIgroup.gadgets[col])->FIfield.min = value;

   return (FI_SUCCESS);
}



/*====================================================================*/

int FImcf_set_high_value (Form    form,
                          int     label,
                          int     col,
                          double  value)
{
   struct FImcf_obj *mcfield;

   mcfield = (struct FImcf_obj *) _FI_g_get_id ( (struct FIform_obj *) form, label);
   if (! mcfield)
      {
	  return (FI_NO_SUCH_GADGET);
      }
   if (mcfield->FIgadget.type != FI_MULTI_COL)
      {
	  return (FI_INVALID_GADGET_TYPE);
      }

   if ((col >= (int)mcfield->FImcf.ncol) || (col < 0))
      {
	  return (FI_INVALID_COL);	/* 12/01/89 GMD */
      }

   ((struct FIfld_obj *) mcfield->FIgroup.gadgets[col])->FIfield.max = value;

   return (FI_SUCCESS);
}

/*====================================================================*/

int FImcf_get_low_value (Form     form,
                         int      label,
                         int      col,
                         double  *value)
{
   struct FImcf_obj *mcfield;

   mcfield = (struct FImcf_obj *) _FI_g_get_id ( (struct FIform_obj *) form, label);
   if (! mcfield)
      {
	  return (FI_NO_SUCH_GADGET);
      }
   if (mcfield->FIgadget.type != FI_MULTI_COL)
      {
	  return (FI_INVALID_GADGET_TYPE);
      }

   if ((col >= (int)mcfield->FImcf.ncol) || (col < 0))
      {
	  return (FI_INVALID_COL);	/* 12/01/89 GMD */
      }

   *value = ((struct FIfld_obj *) mcfield->FIgroup.gadgets[col])->FIfield.min;

   return (FI_SUCCESS);
}

/*====================================================================*/

int FImcf_get_high_value (Form     form,
                          int      label,
                          int      col,
                          double  *value)
{
   struct FImcf_obj *mcfield;

   mcfield = (struct FImcf_obj *) _FI_g_get_id ( (struct FIform_obj *) form, label);
   if (! mcfield)
      {
	  return (FI_NO_SUCH_GADGET);
      }
   if (mcfield->FIgadget.type != FI_MULTI_COL)
      {
	  return (FI_INVALID_GADGET_TYPE);
      }

   if ((col >= (int)mcfield->FImcf.ncol) || (col < 0))
      {
	  return (FI_INVALID_COL);	/* 12/01/89 GMD */
      }

   *value = ((struct FIfld_obj *) mcfield->FIgroup.gadgets[col])->FIfield.max;

   return (FI_SUCCESS);
}

/*====================================================================*/
/*********************************************************************/
/* */
/* FImcf_get_justification - allows you to get justification for */
/* each of the columns of a MCF. */
/* */
/* Mack Draper - May 15th, 1989 */
/* */
/*********************************************************************/

int FImcf_get_justification (Form  form,
                             int   label,
                             int   col,
                             int  *just)
{
   struct FImcf_obj *mcfield;

   mcfield = (struct FImcf_obj *) _FI_g_get_id ( (struct FIform_obj *) form, label);
   if (! mcfield)
      {
	  return (FI_NO_SUCH_GADGET);
      }
   if (mcfield->FIgadget.type != FI_MULTI_COL)
      {
	  return (FI_INVALID_GADGET_TYPE);
      }

   if ((col >= (int)mcfield->FImcf.ncol) || (col < 0))
      {
	  return (FI_INVALID_COL);	/* 12/01/89 GMD */
      }

   *just = mcfield->FIgroup.gadgets[col]->FIgadget.justification;

   return (FI_SUCCESS);
}

/*====================================================================*/

int FImcf_set_justification (Form  form,
                             int   label,
                             int   col,
                             int   just)
{
   struct FImcf_obj *mcfield;

   mcfield = (struct FImcf_obj *) _FI_g_get_id ( (struct FIform_obj *) form, label);
   if (! mcfield)
      {
	  return (FI_NO_SUCH_GADGET);
      }
   if (mcfield->FIgadget.type != FI_MULTI_COL)
      {
	  return (FI_INVALID_GADGET_TYPE);
      }

   if ((col >= (int)mcfield->FImcf.ncol) || (col < 0))
      {
	  return (FI_INVALID_COL);	/* 12/01/89 GMD */
      }

   mcfield->FIgroup.gadgets[col]->FIgadget.justification = just;

   return (FI_SUCCESS);
}


/*====================================================================*/

int FImcf_get_attr (Form   form,
                    int    label,
                    long  *attr_mask)
{
   struct FImcf_obj *mcfield;
   struct FIgadget_obj *gadget;

   gadget = _FI_g_get_id ( (struct FIform_obj *) form, label);
   if (! gadget)
      {
	  return (FI_NO_SUCH_GADGET);
      }

   if (gadget->FIgadget.type == FI_MULTI_COL)
      {
	  mcfield = (struct FImcf_obj *) gadget;
      }
   else
      {
	  return (FI_INVALID_GADGET_TYPE);
      }

   *attr_mask = 0;

   if (mcfield->FImcf.flags.uds)
      {
	  *attr_mask |= FI_VERT_SCROLL;
      }

   if (mcfield->FImcf.flags.lrs)
      {
	  *attr_mask |= FI_HORT_SCROLL;
      }

   if (mcfield->FImcf.flags.draw_vscrl)
      {
	  *attr_mask |= FI_DISPLAY_VSCROLL;
      }

   if (mcfield->FImcf.flags.draw_hscrl)
      {
	  *attr_mask |= FI_DISPLAY_HSCROLL;
      }

   if (mcfield->FImcf.flags.disable_vscrl)
      {
	  *attr_mask |= FI_DISABLE_VSCROLL;
      }

   if (mcfield->FImcf.flags.disable_hscrl)
      {
	  *attr_mask |= FI_DISABLE_HSCROLL;
      }

   if (mcfield->FImcf.flags.row_select)
      {
	  *attr_mask |= FI_ROW_SELECT;
      }

   if (mcfield->FImcf.flags.no_row_buttons)	/* GMD 3/20/90 */
      {
	  *attr_mask |= FI_NO_ROW_BUTTONS;
      }

   return (FI_SUCCESS);
}



/*====================================================================*/

int FImcf_set_attr (Form  form,
                    int   label,
                    long  attr_mask)
{
   int ii;
   struct FImcf_obj *mcfield;
   struct FIgadget_obj *gadget;

   gadget = _FI_g_get_id ( (struct FIform_obj *) form, label);
   if (! gadget)
      {
	  return (FI_NO_SUCH_GADGET);
      }

   if (gadget->FIgadget.type == FI_MULTI_COL)
      {
	  mcfield = (struct FImcf_obj *) gadget;
      }
   else
      {
	  return (FI_INVALID_GADGET_TYPE);
      }

   if (attr_mask & FI_ROW_SELECT)	/*** <pds-2/27/90> ***/
      {
	  mcfield->FImcf.flags.row_select = 1;
      }
   else
      {
	  mcfield->FImcf.flags.row_select = 0;
      }

   if (attr_mask & FI_NO_ROW_BUTTONS)	/*** <GMD 3/20/90> ***/
      {
	  mcfield->FImcf.flags.no_row_buttons = 1;
      }
   else
      {
	  mcfield->FImcf.flags.no_row_buttons = 0;
      }

   if (attr_mask & FI_DISPLAY_VSCROLL)
      {
	  mcfield->FImcf.flags.draw_vscrl = 1;
      }
   else
      {
	  mcfield->FImcf.flags.draw_vscrl = 0;
      }

   if (attr_mask & FI_DISPLAY_HSCROLL)
      {
	  mcfield->FImcf.flags.draw_hscrl = 1;
      }
   else
      {
	  mcfield->FImcf.flags.draw_hscrl = 0;
      }

   if (attr_mask & FI_DISABLE_VSCROLL)
      {
	  mcfield->FImcf.flags.disable_vscrl = 1;
      }
   else
      {
	  mcfield->FImcf.flags.disable_vscrl = 0;
      }

   if (attr_mask & FI_DISABLE_HSCROLL)
      {
	  mcfield->FImcf.flags.disable_hscrl = 1;
      }
   else
      {
	  mcfield->FImcf.flags.disable_hscrl = 0;
      }

   if (attr_mask & FI_VERT_SCROLL)
   {
	  mcfield->FImcf.flags.uds = 1;
	  if (! mcfield->FImcf.vscrl_id)
	      {
		 _FI_mcf_add_vscrl (mcfield);
	      }

	  for (ii = 0; ii < (int)mcfield->FImcf.ncol; ii++)
	  {
		 ((struct FIfld_obj *) mcfield->FIgroup.gadgets[ii])->FIfield.flags.uds = 1;
	  }

      /*** <pds-2/7/90> Display or erase the scroll bar ***/

	  if (IT_IS_DISPLAYABLE(mcfield) && mcfield->FImcf.vscrl_id)
	  {
		 if (mcfield->FImcf.flags.draw_vscrl && IT_IS_NOT_DISPLAYABLE(mcfield->FImcf.vscrl_id))
		 {
			_FI_g_set_displayable ((struct FIgadget_obj *)mcfield->FImcf.vscrl_id);
			_FI_g_display ( (struct FIgadget_obj *) mcfield->FImcf.vscrl_id, XWINDOW(mcfield));
		 }
		 else if (! mcfield->FImcf.flags.draw_vscrl && IT_IS_DISPLAYABLE(mcfield->FImcf.vscrl_id))
		 {
			_FI_g_erase ( (struct FIgadget_obj *) mcfield->FImcf.vscrl_id);
		 }
	  }

      /*** <pds-2/6/90> dis/enable the vertical scroll bar ***/

	  if (mcfield->FImcf.flags.disable_vscrl && mcfield->FImcf.vscrl_id)
	      {
		 _FI_g_disable ((struct FIgadget_obj *)mcfield->FImcf.vscrl_id);
	      }
	  else if (mcfield->FImcf.vscrl_id)
	      {
		 _FI_g_enable ((struct FIgadget_obj *)mcfield->FImcf.vscrl_id);
	      }
   }
   else
   {
	  mcfield->FImcf.flags.uds = 0;
	  if (mcfield->FImcf.vscrl_id)
	  {
		 _FI_g_delete ((struct FIgadget_obj *)mcfield->FImcf.vscrl_id, TRUE);
		 mcfield->FImcf.vscrl_id = 0;
	  }
	  for (ii = 0; ii < (int)mcfield->FImcf.ncol; ii++)
	  {
		 ((struct FIfld_obj *) mcfield->FIgroup.gadgets[ii])->FIfield.flags.uds = 0;
	  }
   }
   if (attr_mask & FI_HORT_SCROLL)
   {
	  mcfield->FImcf.flags.lrs = 1;
	  if (! mcfield->FImcf.hscrl_id)
	      {
		 _FI_mcf_add_hscrl (mcfield);
	      }

      /*** <pds-2/7/90> Display or erase the scroll bar ***/

	  if (IT_IS_DISPLAYABLE(mcfield) && mcfield->FImcf.hscrl_id)
	  {
		 if (mcfield->FImcf.flags.draw_hscrl && IT_IS_NOT_DISPLAYABLE(mcfield->FImcf.hscrl_id))
		 {
			_FI_g_set_displayable ((struct FIgadget_obj *)mcfield->FImcf.hscrl_id);
			_FI_g_display ( (struct FIgadget_obj *) mcfield->FImcf.hscrl_id, XWINDOW(mcfield));
		 }
		 else if (! mcfield->FImcf.flags.draw_hscrl && IT_IS_DISPLAYABLE(mcfield->FImcf.hscrl_id))
		 {
			_FI_g_erase ( (struct FIgadget_obj *) mcfield->FImcf.hscrl_id);
		 }
	  }
      /*** <pds-2/6/90> dis/enable the horizontal scroll bar ***/

	  if (mcfield->FImcf.flags.disable_hscrl && mcfield->FImcf.hscrl_id)
	      {
		 _FI_g_disable ((struct FIgadget_obj *)mcfield->FImcf.hscrl_id);
	      }
	  else if (mcfield->FImcf.hscrl_id)
	      {
		 _FI_g_enable ((struct FIgadget_obj *)mcfield->FImcf.hscrl_id);
	      }
   }
   else
   {
	  mcfield->FImcf.flags.lrs = 0;
	  if (mcfield->FImcf.hscrl_id)
	  {
		 _FI_g_delete ((struct FIgadget_obj *)mcfield->FImcf.hscrl_id, TRUE);
		 mcfield->FImcf.hscrl_id = 0;
	  }
   }

   return (FI_SUCCESS);
}



/*====================================================================*/

int FImcf_get_num_cols (Form   form,
                        int    label,
                        int   *num_col)
{
   struct FImcf_obj *mcfield;

   mcfield = (struct FImcf_obj *) _FI_g_get_id ( (struct FIform_obj *) form, label);
   if (! mcfield)
      {
	  return (FI_NO_SUCH_GADGET);
      }
   if (mcfield->FIgadget.type != FI_MULTI_COL)
      {
	  return (FI_INVALID_GADGET_TYPE);
      }

   *num_col = mcfield->FImcf.ncol;
   return (FI_SUCCESS);
}

/*====================================================================*/

int FImcf_set_num_cols (Form  form,
                        int   label,
                        int   num_col)
{
   int status, ii, neg_label, flg;
   struct FIgadget_obj *gadget;
   struct FImcf_obj *mcfield;

   mcfield = (struct FImcf_obj *) _FI_g_get_id ( (struct FIform_obj *) form, label);
   if (! mcfield)
      {
	  return (FI_NO_SUCH_GADGET);
      }
   if (mcfield->FIgadget.type != FI_MULTI_COL)
      {
	  return (FI_INVALID_GADGET_TYPE);
      }

   /*** <pds-1/4/90> A negative column will BUSS ERROR !!!! */
   if (num_col < 0)
      {
	  num_col = 0;
      }

   if (num_col < (int)mcfield->FImcf.ncol)
   {
	  for (ii = num_col; ii < (int)mcfield->FImcf.ncol; ii++)
	  {
		 _FI_g_delete ((struct FIgadget_obj *)mcfield->FIgroup.gadgets[ii], TRUE);
		 mcfield->FIgroup.gadgets[ii]= 0;
	  }
   }
   else
   {
	  _FI_grp_alloc ((struct FIgroup_obj *)mcfield, num_col - mcfield->FImcf.ncol);
	  for (ii = mcfield->FImcf.ncol; ii < num_col; ii++)
	  {
		 _FI_f_get_next_neg_label (mcfield->FIgadget.form, &neg_label);

		 status = _FI_g_new (mcfield->FIgadget.form, FI_FIELD, neg_label, &gadget);

		 _FI_g_add_to_group (gadget, mcfield->FIgadget.label, 0);

		 mcfield->FIgroup.gadgets[ii]->FIgadget.xlo = mcfield->FIgadget.xlo + 8;
		 mcfield->FIgroup.gadgets[ii]->FIgadget.ylo = mcfield->FIgadget.ylo + 2;
		 mcfield->FIgroup.gadgets[ii]->FIgadget.xhi = mcfield->FIgadget.xhi - 2;
		 mcfield->FIgroup.gadgets[ii]->FIgadget.yhi = mcfield->FIgadget.yhi - 2;

		 mcfield->FIgroup.gadgets[ii]->FIgadget.off_color = OFF_COLOR(mcfield);
		 mcfield->FIgroup.gadgets[ii]->FIgadget.on_color = ON_COLOR(mcfield);

		 _FI_s_rep (&mcfield->FIgroup.gadgets[ii]->FIgadget.fontname, mcfield->FIgadget.fontname);
		 mcfield->FIgroup.gadgets[ii]->FIgadget.bodysize = mcfield->FIgadget.bodysize;

		 ((struct FIfld_obj *) mcfield->FIgroup.gadgets[ii])->FIfield.flags.is_a_col = 1;
		 ((struct FIfld_obj *) mcfield->FIgroup.gadgets[ii])->FIfield.mode = FI_APPEND;
		 ((struct FIfld_obj *) mcfield->FIgroup.gadgets[ii])->FIfield.prev_sel = -1;

		 if (mcfield->FImcf.flags.uds)
		   {
			((struct FIfld_obj *) mcfield->FIgroup.gadgets[ii])->FIfield.flags.uds = 1;
		   }
	  }
   }
   if (mcfield->FImcf.ncol != 0)	/* not first time */
   {
	  if ((short)mcfield->FImcf.col_off + (short)mcfield->FImcf.nvcol >= (short)mcfield->FImcf.ncol)
	  {
		 flg = TRUE;
	  }
	  else
	  {
		 flg = FALSE;
	  }

	  if (flg)
	  {
		 _FI_g_erase ( (struct FIgadget_obj *) mcfield);
	  }
	  _FI_mcf_adjust_cols (mcfield);
	  if (flg)
	  {
		 _FI_g_set_displayable ((struct FIgadget_obj *)mcfield);
		 _FI_g_display ( (struct FIgadget_obj *) mcfield, XWINDOW(mcfield));
	  }
   }
   mcfield->FImcf.ncol = num_col;
   if (mcfield->FImcf.hscrl_id)
   {
	  mcfield->FImcf.hscrl_id->FIrange.high_value = (short)mcfield->FImcf.ncol - 1.0;
   }
   return (FI_SUCCESS);
}

/*====================================================================*/

int FImcf_get_num_vis_cols (Form  form,
                            int   label,
                            int  *num_col)
{
   struct FImcf_obj *mcfield;

   mcfield = (struct FImcf_obj *) _FI_g_get_id ( (struct FIform_obj *) form, label);
   if (! mcfield)
      {
	  return (FI_NO_SUCH_GADGET);
      }
   if (mcfield->FIgadget.type != FI_MULTI_COL)
      {
	  return (FI_INVALID_GADGET_TYPE);
      }

   *num_col = mcfield->FImcf.nvcol;
   return (FI_SUCCESS);
}

/*====================================================================*/

int FImcf_set_num_vis_cols (Form  form,
                            int   label,
                            int   num_col)
{
   struct FImcf_obj *mcfield;

   mcfield = (struct FImcf_obj *) _FI_g_get_id ( (struct FIform_obj *) form, label);
   if (! mcfield)
      {
	  return (FI_NO_SUCH_GADGET);
      }
   if (mcfield->FIgadget.type != FI_MULTI_COL)
      {
	  return (FI_INVALID_GADGET_TYPE);
      }

   /*** <pds-1/4/90> Assume they mean at least one column ***/
   if (num_col < 1)
      {
	  mcfield->FImcf.nvcol = 1;
      }
   else
      {
	  mcfield->FImcf.nvcol = num_col;
      }

   _FI_mcf_adjust_xhi (mcfield);

   return (FI_SUCCESS);
}

/*====================================================================*/

int FImcf_get_col_size (Form   form,
                        int    label,
                        int    col,
                        int   *xsize,
                        int   *ysize)
{
   struct FImcf_obj *mcfield;
   struct FIfld_obj *field;

   mcfield = (struct FImcf_obj *) _FI_g_get_id ( (struct FIform_obj *) form, label);
   if (! mcfield)
     {
	  return (FI_NO_SUCH_GADGET);
     }

   if (mcfield->FIgadget.type != FI_MULTI_COL)
     {
	  return (FI_INVALID_GADGET_TYPE);
     }

   if ((col >= (int)mcfield->FImcf.ncol) || (col < 0))
     {
	  return (FI_INVALID_COL);	/* 12/01/89 GMD */
     }
 
   field = (struct FIfld_obj *) mcfield->FIgroup.gadgets[col];

   *xsize = field->FIgadget.xhi - field->FIgadget.xlo;

   *ysize = field->FIgadget.yhi - field->FIgadget.ylo;

   return (FI_SUCCESS);
}

/*====================================================================*/

int FImcf_set_col_size (Form  form,
                        int   label,
                        int   col,
                        int   xsize,
                        int   ysize)
{
   struct FImcf_obj *mcfield;
   struct FIfld_obj *field;

   mcfield = (struct FImcf_obj *) _FI_g_get_id ( (struct FIform_obj *) form, label);
   if (! mcfield)
     {
	  return (FI_NO_SUCH_GADGET);
     }

   if (mcfield->FIgadget.type != FI_MULTI_COL)
     {
	  return (FI_INVALID_GADGET_TYPE);
     }

   if ((col >= (int)mcfield->FImcf.ncol) || (col < 0))
     {
	  return (FI_INVALID_COL);	/* 12/01/89 GMD */
     }

   field = (struct FIfld_obj *) mcfield->FIgroup.gadgets[col];

   field->FIgadget.xhi = field->FIgadget.xlo + xsize;
   field->FIgadget.yhi = field->FIgadget.ylo + ysize;

   return (FI_SUCCESS);
}

/*====================================================================*/

int FImcf_get_select (Form  form,
                      int   label,
                      int   row,
                      int  *sel_flg)
{
   struct FImcf_obj *mcfield;
   struct FIfld_obj *field;

   mcfield = (struct FImcf_obj *) _FI_g_get_id ( (struct FIform_obj *) form, label);
   if (! mcfield)
     {
	  return (FI_NO_SUCH_GADGET);
     }

   if (mcfield->FIgadget.type != FI_MULTI_COL)
     {
	  return (FI_INVALID_GADGET_TYPE);
     }

   field = (struct FIfld_obj *) mcfield->FIgroup.gadgets[0];

   if (row < field->FIfield.buffer_size)
    {
	  *sel_flg = field->FIfield.buffer[row].sel;
    }
   else
   {
	  *sel_flg = 0;
	  return (FI_INVALID_ROW);	/* 12/01/89 GMD */
   }
   return (FI_SUCCESS);
}

/*====================================================================*/

int FImcf_set_select (Form  form,
                      int   label,
                      int   row,
                      int   sel_flg)
{
   int ii;
   Window window;
   struct FImcf_obj *mcfield;
   struct FIfld_obj *field;

   mcfield = (struct FImcf_obj *) _FI_g_get_id ( (struct FIform_obj *) form, label);
   if (! mcfield)
     {
	  return (FI_NO_SUCH_GADGET);
     }

   if (mcfield->FIgadget.type != FI_MULTI_COL)
     {
	  return (FI_INVALID_GADGET_TYPE);
     }

   window = XWINDOW(mcfield->FIgroup.gadgets[0]);

   field = (struct FIfld_obj *) mcfield->FIgroup.gadgets[0];

   if ((row >= field->FIfield.buffer_size) || (row < 0))
   {
	  return (FI_INVALID_ROW);	/* 12/01/89 GMD */
   }

   for (ii = 0; ii < (int)mcfield->FImcf.ncol; ii++)
   {
	  field = (struct FIfld_obj *) mcfield->FIgroup.gadgets[ii];
	  if ((field->FIfield.mode == FI_SINGLE_SELECT) && (field->FIfield.prev_sel > -1))
	  {
		 if (sel_flg)
		 {
			field->FIfield.buffer[field->FIfield.prev_sel].sel = 0;
			if ((field->FIfield.prev_sel < field->FIfield.buffer_size) &&
                (window != None))
			  {
			   _FI_fld_refresh_row (field, window, field->FIfield.prev_sel);
			  }
		 }
		 else if (field->FIfield.prev_sel == row)
		      {
			field->FIfield.prev_sel = -1;
		      }
	  }
	  field->FIfield.buffer[row].sel = sel_flg;
	  if (sel_flg)
	      {
		 field->FIfield.prev_sel = row;
	      }
	  if (window != None)
	      {
		 _FI_fld_refresh_row (field, window, row);
	      }
   }

   if (window != None)
      {
      /* sml:01-18-94:TR 249400065                         */
      /*  Add check before flushing.  Don't flush if       */
      /*  initially displaying gadget.  OK to flush if     */
      /*  updating      */
        if (!_FI_dont_flush)
          XFlush ( _FI_display );
      }

   return (FI_SUCCESS);
}
