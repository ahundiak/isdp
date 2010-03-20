#include "FImin.h"

#include "FIscroll.h"
#include "FIbtn.h"
#include "FIfield.h"
#include "FImcf.h"
#include "FIseq.h"
#include "FIread.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"


int _FI_mcf_vscrl (struct FImcf_obj  *mcfield,
                   double             value)
{
   int status;

   status = _FI_fld_vscrl ((struct FIfld_obj *)mcfield->FIgroup.gadgets[0], value);

   if (status != FI_SUCCESS)
	  return (status);

   if (mcfield->FIgadget.form->notification_routine && IT_HAS_COMPLETE_NOTIFY(mcfield) && (mcfield->FIgadget.attr_mask & FI_VERT_SCROLL_NOTIFY))
   {
      /*** <pds-1/9/90> Have to send a field, not a MCF, to fld_notify
      _FI_fld_notify(mcfield, value);
      ****************************************************************/

	  status = _FI_fld_notify ((struct FIfld_obj *)mcfield->FIgroup.gadgets[0], (double) -3.0);	/* Vertical scroll poked */

      /*** if field/form was deleted in notification routine ***/
      /*** then return ***/
	  if (status != FI_SUCCESS)
	  {
		 return (status);
	  }
   }

   return (FI_SUCCESS);
}

/*============================================================================*/

void _FI_mcf_set_hscrl (struct FImcf_obj *mcfield)
{
   double view;

   if (mcfield->FImcf.hscrl_id)
   {
	  if (mcfield->FImcf.nvcol < mcfield->FImcf.ncol)
	  {
		 view = ((double) mcfield->FImcf.nvcol / (double)mcfield->FImcf.ncol) - 0.03;
	  }
	  else
	  {
		 view = 1.0;
	  }
	  if (mcfield->FImcf.hscrl_id->FIscroll.view != view)
	  {
		 mcfield->FImcf.hscrl_id->FIgadget.value = -1;
		 mcfield->FImcf.hscrl_id->FIscroll.view = view;
	  }
	  if (mcfield->FImcf.ncol > mcfield->FImcf.nvcol)
		 mcfield->FImcf.hscrl_id->FIrange.high_value = (double)mcfield->FImcf.ncol - (double)mcfield->FImcf.nvcol;
	  else
		 mcfield->FImcf.hscrl_id->FIrange.high_value = 0;
	  _FI_scrl_set_value (mcfield->FImcf.hscrl_id, (double) mcfield->FImcf.col_off * 100);
   }
}

/*============================================================================*/

int _FI_mcf_hscrl (struct FImcf_obj  *mcfield,
                   double             value)
{
   int old_off, coff;
   int scroll_link;
   int gdt_type;
   struct FImcf_obj *linked_mcfield;
   int status;

   old_off = mcfield->FImcf.col_off;
   if (value == (double)((int)FI_COL_LEFT))
   {
	  if (mcfield->FImcf.col_off > 0)
		 mcfield->FImcf.col_off--;
   }
   else if (value == (double)((int)FI_VIEW_LEFT))
   {
      if ((mcfield->FImcf.nvcol == 1 ) &&
          (mcfield->FImcf.col_off > 0))
               mcfield->FImcf.col_off--;
      else
	  if ((short)mcfield->FImcf.col_off + 1.0 > (short)mcfield->FImcf.nvcol)
		 mcfield->FImcf.col_off = mcfield->FImcf.col_off - mcfield->FImcf.nvcol + 1;
	  else
		 mcfield->FImcf.col_off = 0;
   }
   else if (value == (double)((int)FI_LEFT_END))
   {
	  mcfield->FImcf.col_off = 0;
   }
   else if (value == (double)((int)FI_COL_RIGHT))
   {
	  if ((short)mcfield->FImcf.col_off + (short)mcfield->FImcf.nvcol < (short)mcfield->FImcf.ncol)
		 mcfield->FImcf.col_off++;
   }
   else if (value == (double)((int)FI_VIEW_RIGHT))
   {
      if ((mcfield->FImcf.nvcol == 1 ) &&
          ((short)mcfield->FImcf.col_off < ((short)mcfield->FImcf.ncol - 1.0)))
               mcfield->FImcf.col_off++;
      else
	  if ((short)mcfield->FImcf.col_off + (short)mcfield->FImcf.nvcol <= (short)mcfield->FImcf.ncol - (short)mcfield->FImcf.nvcol)
		 mcfield->FImcf.col_off += mcfield->FImcf.nvcol - 1;
	  else
		 mcfield->FImcf.col_off = mcfield->FImcf.ncol - (int) mcfield->FImcf.nvcol;
   }
   else if (value == (double)((int)FI_RIGHT_END))
   {
	  mcfield->FImcf.col_off = mcfield->FImcf.ncol - (int) mcfield->FImcf.nvcol;
   }
   else
   {
      /*****************************************************************/
      /* */
      /* Note: this formula will only work if all columns are the same */
      /* in width. */
      /* */
      /*****************************************************************/

      /*
      coff =(int)(value * mcfield->FImcf.ncol)- 
      ((int)mcfield->FImcf.nvcol / 2);
      */

	  coff = (int) (value + 0.05);

	  if ((short)coff + (short)mcfield->FImcf.nvcol >= (short)mcfield->FImcf.ncol)
	  {
		 coff = mcfield->FImcf.ncol - (int) mcfield->FImcf.nvcol;
	  }
	  else if (coff < 0)
	  {
		 coff = 0;
	  }
	  mcfield->FImcf.col_off = coff;
   }

   /* recalc coord if offset changed */

   if (old_off != mcfield->FImcf.col_off)
   {
	  _FI_grp_pass_on_id_int_always ( (struct FIgadget_obj *) mcfield, _FI_g_erase, 0, 0);
	  _FI_mcf_adjust_cols (mcfield);
	  _FI_grp_pass_on_id_int_always ( (struct FIgadget_obj *) mcfield, _FI_g_display, XWINDOW(mcfield) , 0);

      /*****************************************************/
      /* */
      /* If the MCF gadget is linked to a Header MCF, then */
      /* scroll that gadget as well. */
      /* */
      /*****************************************************/

	  scroll_link = mcfield->FIgadget.off_color2 + (mcfield->FIgadget.on_color2 * 256);

	  if (scroll_link != 0)
	  {
         /*** <pds-1/9/90> New stuff using internal calls, also removed
         lots-a annoying flashing.
         ***/

		 linked_mcfield = (struct FImcf_obj *) _FI_g_get_id (mcfield->FIgadget.form, scroll_link);

		 if (linked_mcfield)
		 {
            /* make sure that even if the linked gadget exists,
            that it is a multi-column field gadget. GMD 3/28/90 */

			FIg_get_type ( (Form) mcfield->FIgadget.form, scroll_link, &gdt_type);

			if (gdt_type == FI_MULTI_COL)
			{
 			   /* sml:07-23-94:try <= instead of < */
			   if ((short)(mcfield->FImcf.col_off + mcfield->FImcf.nvcol) 
					<= (short)linked_mcfield->FImcf.ncol)
			   {
				  linked_mcfield->FImcf.col_off = mcfield->FImcf.col_off;
			   }
			   else
			   {
				  linked_mcfield->FImcf.col_off = linked_mcfield->FImcf.ncol - linked_mcfield->FImcf.nvcol;
			   }
			   _FI_mcf_adjust_cols (linked_mcfield);

			   if (IT_IS_DISPLAYABLE(linked_mcfield))
			   {
				  XSetForeground (_FI_display, _FI_gc, FI_translate_color (XSCREEN(linked_mcfield) , ERASE_COLOR(linked_mcfield)));

				  _FI_generic_erase ((struct FIgadget_obj *)linked_mcfield, XWINDOW(linked_mcfield));

				  _FI_grp_pass_on_id_int_always ( (struct FIgadget_obj *) linked_mcfield, _FI_g_display, XWINDOW(linked_mcfield) , 0);
			   }
			   _FI_mcf_set_hscrl (linked_mcfield);
			}
		 }
		 mcfield->FIgadget.sym_width_scale_factor = mcfield->FImcf.col_off;
	  }
   }

   if ((mcfield->FIgadget.form->notification_routine) && IT_HAS_COMPLETE_NOTIFY(mcfield))
   {
	  value = (double) (-2.0);	/* Horizontal column scroll poked */

      /*** <pds-1/9/90> Have to send a field not a MCF to fld_notify
      _FI_fld_notify(mcfield, value);
      ***/

	  status = _FI_fld_notify ((struct FIfld_obj *)mcfield->FIgroup.gadgets[0], value);

      /*** if the field/form was ***/
      /*** deleted, then return. ***/
	  if (status != FI_SUCCESS)
	  {
		 return (status);
	  }
   }
   return (FI_SUCCESS);
}

/*============================================================================*/

void _FI_mcf_set_vscrl (struct FImcf_obj *mcfield)
{
   double view;
   struct FIfld_obj *field;

   field = (struct FIfld_obj *) mcfield->FIgroup.gadgets[0];

   if (mcfield->FImcf.vscrl_id)
   {
	  if (field->FIfield.buffer_size > field->FIfield.nvr)
	  {
		 view = (double) field->FIfield.nvr / field->FIfield.buffer_size;
	  }
	  else
	  {
		 view = 1.0;
	  }
	  if (mcfield->FImcf.vscrl_id->FIscroll.view != view)
	  {
		 mcfield->FImcf.vscrl_id->FIgadget.value = -1;
		 mcfield->FImcf.vscrl_id->FIscroll.view = view;
	  }
	  if (field->FIfield.buffer_size > field->FIfield.nvr)
		 mcfield->FImcf.vscrl_id->FIrange.high_value = field->FIfield.buffer_size - field->FIfield.nvr - 1;
	  else
		 mcfield->FImcf.vscrl_id->FIrange.high_value = 0;
	  _FI_scrl_set_value (mcfield->FImcf.vscrl_id, (double) field->FIfield.roff);
   }
   return;
}

/***********************************************************************/
/* */
/* _FI_mcf_add_hscrl() modified May 17, 1989 */
/* by Mack Draper */
/* */
/* Added a check to see if any of the columns in the MCF have */
/* Horizontal scroll buttons displayed. If so, then the MCF */
/* Column scroll bar will have to be moved down an additional */
/* 12 pixels to avoid overwriting the horizontal scroll buttons */
/* for the individual columns. */
/* */
/***********************************************************************/

void _FI_mcf_add_hscrl (struct FImcf_obj *mcfield)
{
   int status, label;
   int i, move_col_scroll_bar_down;	/* NEW -- Mack */

   move_col_scroll_bar_down = 0;	/* Don't move it down */

   for (i = 0; i < (int)mcfield->FImcf.ncol; i++)
	  if (((struct FIfld_obj *) mcfield->FIgroup.gadgets[i])->FIfield.flags.draw_hscrl == 1)
		 move_col_scroll_bar_down = 13;	/* Amount in pixels to move scroll */
   /* bar down. Equal to height of */
   /* dual horz scroll buttons. */

   _FI_f_get_next_neg_label (mcfield->FIgadget.form, &label);
   status = _FI_g_new (mcfield->FIgadget.form, FI_SCROLL, label,
     (struct FIgadget_obj **)&mcfield->FImcf.hscrl_id);
   if (status)
	  return;
   mcfield->FImcf.hscrl_id->FIgadget.xlo = mcfield->FIgadget.xlo + 10;
   mcfield->FImcf.hscrl_id->FIgadget.ylo = mcfield->FIgadget.yhi + move_col_scroll_bar_down;
   mcfield->FImcf.hscrl_id->FIgadget.xhi = mcfield->FIgadget.xhi;
   mcfield->FImcf.hscrl_id->FIgadget.yhi = mcfield->FIgadget.yhi + SCROLL_SIZE + move_col_scroll_bar_down;
   mcfield->FImcf.hscrl_id->FIgadget.fontname = _FI_s_new ("FIsym");
   mcfield->FImcf.hscrl_id->FIscroll.type = FI_HORIZONTAL;
   mcfield->FImcf.hscrl_id->FIgadget.user_pointer = (char *) mcfield;
   mcfield->FImcf.hscrl_id->FIrange.low_value = 0;
   mcfield->FImcf.hscrl_id->FIrange.high_value = 0;

   if (! mcfield->FImcf.flags.draw_hscrl)
   {
	  mcfield->FImcf.hscrl_id->FIgadget.default_attr_mask |= FI_NOT_DISPLAYED;
	  mcfield->FImcf.hscrl_id->FIgadget.attr_mask |= FI_NOT_DISPLAYED;
   }
}

/*============================================================================*/

void _FI_mcf_add_vscrl (struct FImcf_obj *mcfield)
{
   int status, label;

   _FI_f_get_next_neg_label (mcfield->FIgadget.form, &label);
   status = _FI_g_new (mcfield->FIgadget.form, FI_SCROLL, label,
     (struct FIgadget_obj **)&mcfield->FImcf.vscrl_id);
   if (status)
	  return;
   mcfield->FImcf.vscrl_id->FIgadget.xlo = mcfield->FIgadget.xhi;
   mcfield->FImcf.vscrl_id->FIgadget.ylo = mcfield->FIgadget.ylo;
   mcfield->FImcf.vscrl_id->FIgadget.xhi = mcfield->FImcf.vscrl_id->FIgadget.xlo + SCROLL_SIZE;
   mcfield->FImcf.vscrl_id->FIgadget.yhi = mcfield->FIgadget.yhi;
   mcfield->FImcf.vscrl_id->FIgadget.fontname = _FI_s_new ("FIsym");
   mcfield->FImcf.vscrl_id->FIscroll.type = FI_VERTICAL;
   mcfield->FImcf.vscrl_id->FIgadget.user_pointer = (char *) mcfield;
   mcfield->FImcf.vscrl_id->FIrange.low_value = 0;
   mcfield->FImcf.vscrl_id->FIrange.high_value = 0;

   /* This was added to fix scaling problem 10/4/89 */

   mcfield->FImcf.vscrl_id->FIgadget.orig_ysize = mcfield->FImcf.vscrl_id->FIgadget.yhi - mcfield->FImcf.vscrl_id->FIgadget.ylo;

   if (! mcfield->FImcf.flags.draw_vscrl)
   {
	  mcfield->FImcf.vscrl_id->FIgadget.default_attr_mask |= FI_NOT_DISPLAYED;
	  mcfield->FImcf.vscrl_id->FIgadget.attr_mask |= FI_NOT_DISPLAYED;
   }
}

/*====================================================================*/

int _FI_mcf_track_mouse (struct FImcf_obj  *mcfield,
                         Window             window,
                         int                xpos,
                         int                ypos,
                         int               *complete,
                         double            *value)
{
   int status;
   struct FIgadget_obj *gadget;
   struct FIfld_obj *field;
   int current_col;

   _FI_poke_inside_mcf = 1;	/* User has poked inside the MCF gadget */

   if (_FI_g_find_gadget ((struct FIgroup_obj *)mcfield, xpos, ypos, &gadget))
   {
	  mcfield->FIgroup.last_active_gadget = mcfield->FIgroup.current_active_gadget;
	  mcfield->FIgroup.current_active_gadget = _FI_grp_get_slot ((struct FIgroup_obj *)mcfield, gadget);

	  status = _FI_fld_track_mouse ( (struct FIfld_obj *)gadget, window, xpos, ypos,
					 complete, value );

      /*** if the gadget/form was deleted, ***/
      /*** then return ***/

	  if (status != FI_SUCCESS)
		 return (status);
   }
   else
   {
      /*********************************************************/
      /* */
      /* Handle the case of a row selection gadget being poked */
      /* */
      /*********************************************************/

	  if ((mcfield->FIgadget.xlo <= xpos) && (mcfield->FIgadget.xlo + 8 >= xpos) && (mcfield->FIgadget.ylo <= ypos) && (mcfield->FIgadget.yhi >= ypos))
	  {
         /** <pds-2/28/90> **/
		 int col;
		 int row_select = mcfield->FImcf.flags.row_select;

		 mcfield->FImcf.flags.row_select = 1;

		 field = (struct FIfld_obj *) mcfield->FIgroup.gadgets[mcfield->FIgroup.current_active_gadget];

		 if (field->FIfield.mode == FI_SINGLE_SELECT)
		 {
			struct FIfld_obj *column;

            /*** <pds-2/28/90> Only unselect the rows which are single
            select in the column. This may seem like a KLUDGE, but
            it keeps with the theme of field/MCF code
            ***/

			for (col = 0; col < (int)mcfield->FImcf.ncol; col++)
			{
			   column = (struct FIfld_obj *) mcfield->FIgroup.gadgets[col];
			   if (column->FIfield.mode == FI_SINGLE_SELECT && column->FIfield.prev_sel > -1)
			   {
				  column->FIfield.flags.is_a_col = 0;
				  _FI_fld_un_select_row (column, window, column->FIfield.prev_sel);
				  column->FIfield.flags.is_a_col = 1;
			   }
			}

			_FI_fld_adjust_row_col (field, xpos, ypos);

			if (field->FIfield.prev_sel != field->FIfield.ar)
			   _FI_fld_select_row (field, window, field->FIfield.ar);
			else
			{
			   if (field->FIfield.prev_sel > -1)
				  _FI_fld_un_select_row (field, window, field->FIfield.prev_sel);
			   field->FIfield.prev_sel = -1;
			}
		 }
		 else	/** FI_MULTI_SELECT ***/
		 {
			_FI_fld_adjust_row_col (field, xpos, ypos);
			if (field->FIfield.buffer[field->FIfield.ar].sel)
			{
			   if (field->FIfield.ar > -1)
				  _FI_fld_un_select_row (field, window, field->FIfield.ar);
			   field->FIfield.prev_sel = -1;
			}
			else
			   _FI_fld_select_row (field, window, field->FIfield.ar);
		 }

		 XFlush (_FI_display);

		 mcfield->FImcf.flags.row_select = row_select;

         /* Notify application of data */

		 *value = (double) (-1.0);	/* row selection gadget poked */

		 if ((mcfield->FIgadget.form->notification_routine) && IT_HAS_COMPLETE_NOTIFY(mcfield))
		 {
            /*** <pds-1/9/90> Have to send a field not a MCF to fld_notify
            _FI_fld_notify(mcfield, *value);
            ***/
			status = _FI_fld_notify ((struct FIfld_obj *)mcfield->FIgroup.gadgets[0], *value);

			if (status != FI_SUCCESS)
			   return (status);
		 }
	  }
	  else
	  {
		 if (mcfield->FImcf.vscrl_id)
		 {
			if (_FI_generic_find_gadget ( (struct FIgadget_obj *) mcfield->FImcf.vscrl_id, xpos, ypos))
			{
			   status = _FI_g_track_mouse ((struct FIgadget_obj *)mcfield->FImcf.vscrl_id, window, xpos, ypos, complete, value );
			   if (status != FI_SUCCESS)
				  return (status);
			   _FI_grp_pass_on_id_double_always ( (struct FIgadget_obj *) mcfield, _FI_fld_vscrl, *value, 0);
			}
		 }

		 if (mcfield->FImcf.hscrl_id)
		 {
			if (_FI_generic_find_gadget ( (struct FIgadget_obj *) mcfield->FImcf.hscrl_id, xpos, ypos))
			{
			   status = _FI_g_track_mouse ((struct FIgadget_obj *)mcfield->FImcf.hscrl_id, window, xpos, ypos, complete, value );
			   if (status != FI_SUCCESS)
				  return (status);

			   status = _FI_mcf_hscrl (mcfield, *value);

			   if (status != FI_SUCCESS)
				  return (status);
			}
		 }

         /*************************************************************/
         /* */
         /* Here I need to add in a check for each of the horizontal */
         /* scroll buttons for each column. */
         /* */
         /* _FI_generic_find gadget can be used to determine if */
         /* the mouse is over a valid horizontal scroll button. */
         /* processing of the button will have to be handled with */
         /* code from the field gadget, as a button held down must */
         /* allow for rapid scrolling. */
         /* */
         /*************************************************************/

		 current_col = mcfield->FImcf.col_off;

		 field = (struct FIfld_obj *) mcfield->FIgroup.gadgets[current_col];

		 while ((field->FIgadget.xhi < mcfield->FIgadget.xhi) && (current_col <= (int)mcfield->FImcf.ncol))
		 {

			if ((field->FIfield.flags.draw_hscrl) &&
                            (field->FIfield.hscrl))
			{
			   if (_FI_generic_find_gadget ( (struct FIgadget_obj *) field->FIfield.hscrl[0], xpos, ypos))
				  _FI_fld_track_hscrl (field, FI_BACKWARD );
			   else if (_FI_generic_find_gadget ( (struct FIgadget_obj *) field->FIfield.hscrl[1], xpos, ypos))
				  _FI_fld_track_hscrl (field, FI_FORWARD );
			}

			current_col++;

			if (current_col <= (int)mcfield->FImcf.ncol)
			   field = (struct FIfld_obj *) mcfield->FIgroup.gadgets[current_col];
		 }
	  }
   }
   *complete = FALSE;

  return ( FI_SUCCESS );
}

/*============================================================================*/

int _FI_mcf_track_kbd (struct FImcf_obj  *mcfield,
                       int                direction,
                       int                prev_gadget_label)
{
   int complete, act_gad_count, scroll_link;
   int prev_in_seq;
   double value;
   Window window = XWINDOW(mcfield);
   struct FIfld_obj *field;
   struct FImcf_obj *linked_mcf;
   int gdt_type;
   int delete_status;

   if (mcfield->FIgadget.next_in_seq > 0 || prev_gadget_label > 0)
   {
      /*** <pds-1/8/90> This piece of code searches all of the columns for a
      non-REVIEW field and sets the 'current_active_gadget' to the
      one which was found. (Might have to H-scroll the field into
      view.)
      ***/

	  act_gad_count = 0;

	  while (1)
	  {
		 field = (struct FIfld_obj *) mcfield->FIgroup.gadgets[act_gad_count];

		 if ((field->FIfield.mode != FI_INSERT) && (field->FIfield.mode != FI_APPEND))
		 {
			act_gad_count++;
		 }
		 else
		 {
			if ((act_gad_count < (int)mcfield->FImcf.col_off) || (act_gad_count >= (int)((short)mcfield->FImcf.col_off + (short)mcfield->FImcf.nvcol)))
			{
               /* If the new active gadget is out of view, scroll it into
               view.
               */
			   mcfield->FImcf.col_off = act_gad_count;

			   if ( ((short)act_gad_count + (short)mcfield->FImcf.nvcol) > (short)mcfield->FImcf.ncol )
			   {
				  mcfield->FImcf.col_off = mcfield->FImcf.ncol - mcfield->FImcf.nvcol;
			   }
			   _FI_mcf_adjust_cols (mcfield);

               /*** Scroll the linked mcf ***/

			   scroll_link = mcfield->FIgadget.off_color2 + (mcfield->FIgadget.on_color2 * 256);

			   if (scroll_link)
			   {
				  linked_mcf = (struct FImcf_obj *) _FI_g_get_id (mcfield->FIgadget.form, scroll_link);

                  /* Make sure linked gadget is a MCF as well */
                  /* GMD 4/2/90 */

				  FIg_get_type ( (Form) mcfield->FIgadget.form, scroll_link, &gdt_type);
				  if ((linked_mcf) && (gdt_type == FI_MULTI_COL))
				  {
					 linked_mcf->FImcf.col_off = mcfield->FImcf.col_off;
					 _FI_mcf_adjust_cols (linked_mcf);
					 if (IT_IS_DISPLAYABLE(linked_mcf))
					 {
						_FI_grp_pass_on_id_int_always ( (struct FIgadget_obj *) linked_mcf, _FI_g_display, XWINDOW(linked_mcf) , 0);
					 }
					 if (linked_mcf->FImcf.hscrl_id)
						_FI_mcf_set_hscrl (linked_mcf);
				  }
			   }	/*** end linked stuff ***/
			}
			mcfield->FIgroup.current_active_gadget = act_gad_count;
			break;
		 }

		 if (act_gad_count + 1 == (int) mcfield->FImcf.ncol)
			break;
	  }

      /* If any editable fields were found then hilite entire gadget */

	  if ((field->FIfield.mode == FI_INSERT) || (field->FIfield.mode == FI_APPEND))
	  {
		 _FI_g_hilite ((struct FIgadget_obj *)mcfield);
	  }
   }
   else	/*** NO sequencing ***/
   {
	  field = (struct FIfld_obj *) mcfield->FIgroup.gadgets[mcfield->FIgroup.current_active_gadget];
   }

   if (direction == FI_FORWARD)
	  mcfield->FIgadget.prev_in_seq = prev_gadget_label;

   prev_in_seq = mcfield->FIgadget.prev_in_seq;

   /* Track the keyboard now */

   complete = TRUE;

   /* Set this because there was not a CR HIT at this point */

   _FI_mcf_Reason_for_notify = 1;	/* FI_CR_NOT_HIT */


   if ((field->FIfield.mode == FI_INSERT) || (field->FIfield.mode == FI_APPEND))
   {
	  _FI_mcf_track_keyboard (mcfield, window, &complete, &value, &delete_status);

	  if (delete_status != FI_SUCCESS)
		 return (delete_status);
   }

  return ( FI_SUCCESS );
}

/*============================================================================*/

int _FI_mcf_track_keyboard (struct FImcf_obj  *mcfield,
                           Window              window,
                           int                *complete,
                           double             *value,
                           int                *delete_status)
{
   int current_label = mcfield->FIgadget.label;

   struct FIfld_obj *field;
   struct FIform_obj *form = (struct FIform_obj *) mcfield->FIgadget.form;
   struct FImcf_obj *linked_mcfield;

   int x, gdt_type;
   int editable;
   int loop_count;
   int status = 0;
   int scroll_link;
   int already_notified = 0;
   int break_out_of_loop = 0;
   int save_by_line = 0;
   double value2;

   loop_count = 0;

   field = (struct FIfld_obj *) mcfield->FIgroup.gadgets[mcfield->FIgroup.current_active_gadget];

   if (field->FIfield.buffer_size == 0)
   {
	  _FI_fld_set_buffer (field, 1, 1);

	  for (x = 0; x < (int)mcfield->FImcf.ncol; x++)
	  {
		 _FI_fld_add_to_line ((struct FIfld_obj *)mcfield->FIgroup.gadgets[x], 0, 1);
	  }
   }

   while (*complete)
   {
      /**** <pds-2/5/90> Moved following chunk down after fld_track_keyboard, because
      when a column was poked into the user was notified with current values.
      (This is not consistent)

      if((form->notification_routine)&&
      (field->FIfield.flags.by_line))
      {
      *value = field->FIfield.ar;

      _FI_fld_notify(field, *value);

      _FI_g_pass_data((struct FIgadget_obj *)mcfield);
      }

      if(_FI_mcf_break_navigation) *** <pds-2/20/90> ***
      {
      _FI_mcf_break_navigation = FALSE;
      break;
      }

      ****/
	  if (_FI_mcf_Reason_for_notify == 0)	/* FI_CR_HIT */
	  {
		 loop_count++;

		 mcfield->FIgroup.last_active_gadget = mcfield->FIgroup.current_active_gadget;

		 editable = FALSE;

		 while (! editable)
		 {
			int temp_field_mode;

			if (mcfield->FIgroup.current_active_gadget == mcfield->FImcf.ncol - 1)
			{
			   mcfield->FIgroup.current_active_gadget = 0;

			   if (field->FIfield.ar == field->FIfield.buffer_size - 1)
			   {
				  if ((field->FIfield.nr == 0) || (field->FIfield.buffer_size < field->FIfield.nr))
				  {
					 _FI_fld_set_buffer (field, field->FIfield.buffer_size + 1, 1);
				  }
			   }

               /*** <pds-2/6/90> The notification needed to be turned off
               for the _FI_fld_next call. The last field had already
               been notified and an extra notification is not wanted.
               ***/

			   save_by_line = field->FIfield.flags.by_line;
			   field->FIfield.flags.by_line = 0;

			   *delete_status = _FI_fld_next (field, 1);
			   if (*delete_status != FI_SUCCESS)
				  return (status);

			   field->FIfield.flags.by_line = save_by_line;
			}
			else
			{
			   mcfield->FIgroup.current_active_gadget++;
			}

			temp_field_mode = ((struct FIfld_obj *) mcfield->FIgroup.gadgets[mcfield->FIgroup.current_active_gadget])->FIfield.mode;

			if (temp_field_mode == FI_INSERT || temp_field_mode == FI_APPEND)
			{
			   editable = TRUE;
			}

		 }	/*** END while(! editable)***/

		 field = (struct FIfld_obj *) mcfield->FIgroup.gadgets[mcfield->FIgroup.current_active_gadget];

         /*******************************************************/
         /* */
         /* GMD 9/11/90 Make sure that field->FIfield.ac = 0 */
         /* */
         /*******************************************************/

		 field->FIfield.ac = 0;
		 field->FIfield.coff = 0;	/* GMD 11/8/90 */

		 if (IT_IS_NOT_DISPLAYABLE(field))
		 {
			_FI_grp_pass_on_id_int_always ( (struct FIgadget_obj *) mcfield, _FI_g_erase, 0, 0);

			while (IT_IS_NOT_DISPLAYABLE(field))
			{
			   if ((short)mcfield->FImcf.col_off < (short)(mcfield->FImcf.ncol - mcfield->FImcf.nvcol))
				  mcfield->FImcf.col_off++;
			   else
				  mcfield->FImcf.col_off = 0;

			   _FI_mcf_adjust_cols (mcfield);

               /*****************************************************/
               /* */
               /* If the MCF gadget is linked to a Header MCF, then */
               /* scroll that gadget as well. */
               /* */
               /*****************************************************/

			   scroll_link = mcfield->FIgadget.off_color2 + (mcfield->FIgadget.on_color2 * 256);

               /* Make sure linked gadget's type is MCF */
               /* GMD 4/2/90 */

			   FIg_get_type ( (Form) mcfield->FIgadget.form, scroll_link, &gdt_type);

			   if ((scroll_link != 0) && (gdt_type == FI_MULTI_COL))
			   {
                  /*** <pds-1/9/90> New stuff using internal calls, also
                  removed lots-a annoying flashing.
                  ***/

				  linked_mcfield = (struct FImcf_obj *) _FI_g_get_id (mcfield->FIgadget.form, scroll_link);

				  if (linked_mcfield)
				  {
					 linked_mcfield->FImcf.col_off = mcfield->FImcf.col_off;
					 _FI_mcf_adjust_cols (linked_mcfield);
					 if (IT_IS_DISPLAYABLE(linked_mcfield))
					 {
						_FI_grp_pass_on_id_int_always ( (struct FIgadget_obj *) linked_mcfield, _FI_g_display, XWINDOW(linked_mcfield) , 0);
					 }
					 _FI_mcf_set_hscrl (linked_mcfield);
				  }
			   }

			   if ((mcfield->FIgadget.form->notification_routine) && IT_HAS_COMPLETE_NOTIFY(mcfield))
			   {
				  value2 = (double) (-2.0);	/* Horizontal column scroll poked */

                  /*** <pds-1/9/90> Need to pass in a field not a MCF
                  _FI_fld_notify(mcfield, value2);
                  ***/
				  *delete_status = _FI_fld_notify ((struct FIfld_obj *) mcfield->FIgroup.gadgets[0], value2);

				  if (*delete_status != FI_SUCCESS)
					 return (status);
			   }
			}	/*** END while(IT_IS_NOT_DIPLAYABLE)***/

			_FI_grp_pass_on_id_int_always ( (struct FIgadget_obj *) mcfield, _FI_g_display, window, 0);

			if (mcfield->FImcf.hscrl_id)
			{
			   _FI_mcf_set_hscrl (mcfield);
			}
		 }	/*** END if(IT_IS_NOT_DIPLAYABLE)***/
		 else	/* It is displayable, but you need to repaint the */
         /* active column anyway. GMD 11/8/90 */
		 {
			_FI_fld_refresh_data (field, window);
		 }
	  }	/*** END if CR(carriage return)***/

      /*** <pds-1/11/90> Need to cleanup cursor when button is poked ***/

      /************************************/
      /* */
      /* Not sure that this is necessary. */
      /* Xforms left the initial cursor */
      /* erase out. GMD 3/8/91 */
      /* */
      /************************************/

	  _FI_fld_draw_cursor (field, window, 1, _FI_fld_get_line_ON_COLOR (field, field->FIfield.ar), FI_MED_GREY);

	  status = _FI_fld_track_keyboard (field, window, complete, value, delete_status);
	  if (*delete_status != FI_SUCCESS)
		 return (status);

	  _FI_fld_draw_cursor (field, window, 1, FI_MED_GREY,	/* GMD 4/6/90 */ _FI_fld_get_line_ON_COLOR (field, field->FIfield.ar));

	  if (field->FIfield.flags.required == 1)
		 _FI_fld_refresh_row ( (struct FIfld_obj *) field, window, field->FIfield.ar);

	 XFlush (_FI_display);

      /*** <pds-2/5/90> This chunk used to be at the top of the while ***/

	  if ((form->notification_routine) && (field->FIfield.flags.by_line))
	  {
		 *value = field->FIfield.ar;

		 *delete_status = _FI_fld_notify ((struct FIfld_obj *)field, *value);
		 if (*delete_status != FI_SUCCESS)
			return (status);

		 _FI_g_pass_data ((struct FIgadget_obj *)mcfield);
	  }

	  if (_FI_mcf_break_navigation)	/*** <pds-2/20/90> ***/
	  {
		 _FI_mcf_break_navigation = FALSE;
		 break;
	  }

      /* Code for sequencing to next or prev gadget */

	  if (status == 1)
	  {
		 if (mcfield->FIgadget.next_in_seq > 0)
		 {
			struct FIgadget_obj *gadget = _FI_g_get_id (form, mcfield->FIgadget.next_in_seq);

			x = mcfield->FIgroup.current_active_gadget;
			_FI_fld_verify_data ( (struct FIfld_obj *) mcfield->FIgroup.gadgets[x]);
			_FI_fld_justify_data ((struct FIfld_obj *)mcfield->FIgroup.gadgets[x]);

			_FI_g_unhilite ((struct FIgadget_obj *)mcfield);
			if (gadget)
			{
               /*** <pds-1/9/90> This section is used to stop the
               recursive effect on notification. The MCF needs to be
               notified before the next gadget is sequenced.
               ***/
			   if ((form->notification_routine) && IT_HAS_COMPLETE_NOTIFY(mcfield))
			   {
				  *value = field->FIfield.ar;
				  *delete_status = _FI_fld_notify ((struct FIfld_obj *)field, *value);

				  if (*delete_status != FI_SUCCESS)
					 return (status);

				  _FI_g_pass_data ((struct FIgadget_obj *)mcfield);
				  already_notified = 1;
			   }
			   *delete_status = _FI_g_track_kbd (gadget, FI_FORWARD, current_label);
			   if (*delete_status != FI_SUCCESS)
				  return (status);
			}
		 }
		 break_out_of_loop = 1;	/*** out of mongo-huge LOOP ***/
	  }
	  else if (status < 0)
	  {
		 if (mcfield->FIgadget.prev_in_seq > 0)
		 {
			struct FIgadget_obj *gadget = _FI_g_get_id (form, mcfield->FIgadget.prev_in_seq);

			x = mcfield->FIgroup.current_active_gadget;
			_FI_fld_verify_data ( (struct FIfld_obj *) mcfield->FIgroup.gadgets[x]);
			_FI_fld_justify_data ((struct FIfld_obj *)mcfield->FIgroup.gadgets[x]);

			_FI_g_unhilite ((struct FIgadget_obj *)mcfield);
			if (gadget)
			{
               /*** <pds-1/9/90> This section is used to stop the
               recursive effect on notification. The MCF needs to be
               notified before the next gadget is sequenced.
               ***/
			   if ((form->notification_routine) && IT_HAS_COMPLETE_NOTIFY(mcfield))
			   {
				  *value = field->FIfield.ar;
				  *delete_status = _FI_fld_notify ((struct FIfld_obj *)field, *value);

				  if (*delete_status != FI_SUCCESS)
					 return (status);

				  _FI_g_pass_data ((struct FIgadget_obj *)mcfield);
				  already_notified = 1;
			   }
			   *delete_status = _FI_g_track_kbd (gadget, FI_BACKWARD, current_label);

			   if (*delete_status != FI_SUCCESS)
				  return (status);
			}
		 }
		 break_out_of_loop = 1;
	  }

	  _FI_fld_draw_cursor (field, window, 1, FI_MED_GREY,	/* GMD 4/6/90 */ _FI_fld_get_line_ON_COLOR (field, field->FIfield.ar));

	  XFlush (_FI_display);

      /*** <pds-1/9/90> It was breaking out of the loop too soon(before it
      could do all of the cleanup junk above
      ***/

	  if (break_out_of_loop)
		 break;

   }	/*** END mongo-huge LOOP ***/

   /*** <pds-2/5/90> Notify by line is already being handled

   if(loop_count > 0) / * Used CR one or more consecutive times * /
   {
   if((form->notification_routine)&&
   (field->FIfield.flags.by_line))
   {
   *value = field->FIfield.ar;

   _FI_fld_notify(field, *value);

   _FI_g_pass_data((struct FIgadget_obj *)mcfield);
   }
   }
   ***/
   /* Notify application of data */

   if ((_FI_poke_inside_mcf == 0) || break_out_of_loop)
   {
	  if ((mcfield->FIgadget.next_in_seq > 0) || (mcfield->FIgadget.prev_in_seq > 0))
		 _FI_g_unhilite ((struct FIgadget_obj *)mcfield);

	  if ((form->notification_routine) && IT_HAS_COMPLETE_NOTIFY(mcfield) && ! already_notified)
	  {
		 *value = field->FIfield.ar;
		 *delete_status = _FI_fld_notify ((struct FIfld_obj *)field, *value);

		 if (*delete_status != FI_SUCCESS)
		 {
			return (status);
		 }
		 _FI_g_pass_data ((struct FIgadget_obj *)mcfield);
	  }
   }
   return (status);
}
