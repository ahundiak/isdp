#include "FImin.h"

#include "FIscroll.h"
#include "FIbtn.h"
#include "FImcf.h"
#include "FIsym.h"
#include "FItog.h"
#include "FIdial.h"
#include "FItext.h"
#include "FIgraphic.h"
#include "FIline.h"
#include "FIrect.h"
#include "FIbezel.h"
#include "FIcklst.h"
#include "FIgauge.h"
#include "FIgroup.h"
#include "FIfield.h"
#include "FIslider.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"

/* This function deletes a gadget on a form. This also erase it. */
/* If this is sent to a group gadget, the group itself is left */
/* alone and all its member gadgets are deleted. */
/* Use FIgrp_delete()to delete a group itself(along with its */
/* gadgets). */
/* int calc_flag;  ** == 0 means being called from FIf_delete, so:   **/
/**         1. delete group gadgets themselves   **/
/**            (along with gadgets inside group) **/
/**         2. Don't recalculate group's size    **/

int _FI_g_delete (struct FIgadget_obj *gadget,
                  int                  calc_flag)
{
   if (gadget->FIgadget.type == FI_GROUP)
   {
      /*** delete only the gadgets within the group, ***/
      /*** and not the group itself-- JAJ:02-09-89 ***/

      /* If the whole group is being deleted then do not	*/
      /* calculate the group each time a gadget is deleted	*/
      /* but set to zero once					*/

      /*** JAJ:05/09/90 ***/
      /* _FI_grp_pass_on_id_int(gadget, _FI_g_delete, FALSE); */

	  if (! calc_flag)
	  {
         /*** THIS ASSUMES calc_flag == 0 ONLY FOR FIf_delete()***/

		 _FI_grp_pass_on_id_int_always (gadget, _FI_g_delete, FALSE, 0);

		  /*************************************************/
		  /* sml:01-11-94:TR 249304932  Purify errors      */
		  /*  Free the text field; else have memory leaks  */
		  /*  We don't free text field of group gadgets    */
		  /*  This is set when creating palette (group)    */
		  /*  for panel menus.  The menu name is stored    */
		  /*  in the palette's text member.                */
		  /*************************************************/
		  _FI_s_free ( (char *) gadget->FIgadget.text);
		 
         /****************************  JAJ:03/15/91 *******/
         /***  Delete the group gadget itself --         ***/
         /***  only when FIf_delete is being called.     ***/
         /**************************************************/
		 _FI_grp_delete ((struct FIgroup_obj *)gadget);
	  }
	  else
	  {
		 _FI_grp_pass_on_id_int (gadget, _FI_g_delete, TRUE, 0);
	  }
   }
   else
   {
	  struct FIgroup_obj *group = gadget->FIgadget.group;
	  Window window = XWINDOW(gadget);
	  int ii;
	  int slot = -1;

      /*** erase the gadget first ***/

	  if ((window != None) && gadget->FIgadget.form->displayed)
	  {
		 _FI_g_erase (gadget);
	  }

      /*** delete the non-group gadget ***/

	  switch (gadget->FIgadget.type)
	  {
	  case FI_MULTI_COL:
         /*** JAJ:05/09/90 ***/
         /* _FI_grp_pass_on_id_int(gadget, _FI_g_delete, calc_flag); */
		 _FI_grp_pass_on_id_int_always (gadget, _FI_g_delete, calc_flag, 0);

		 if (((struct FImcf_obj *) gadget)->FImcf.vscrl_id)
		 {
			_FI_g_delete ( (struct FIgadget_obj *) ((struct FImcf_obj *) gadget)->FImcf.vscrl_id, calc_flag);
		 }

		 if (((struct FImcf_obj *) gadget)->FImcf.hscrl_id)
		 {
			_FI_g_delete ( (struct FIgadget_obj *) ((struct FImcf_obj *) gadget)->FImcf.hscrl_id, calc_flag);
		 }
		 break;

	  case FI_FIELD:
		 _FI_fld_delete ((struct FIfld_obj *)gadget);
		 break;

	  case FI_SCROLL:
		 _FI_g_delete ( (struct FIgadget_obj *) ((struct FIscrl_obj *) gadget)->FIscroll.puck, calc_flag);

		 for (ii = 0; ii < 4; ii++)
		 {
			_FI_g_delete ( (struct FIgadget_obj *) ((struct FIscrl_obj *) gadget)->FIscroll.btns[ii], calc_flag);
		 }
		 
	  /*************************************************/
	  /* sml:01-11-94:TR 249304932  Purify errors      */
	  /*  Free these guys too; else have memory leaks  */
	  /*  Do the btns ptr and the gadget ptr.          */
	  /* sml:03-04-94:NO TR: Purify errors             */
	  /*  Don't free the scroll.btns or the gadget.    */
	  /*  This will be done after the switch stmt.     */
	  /*************************************************/
/***************
		 _FI_s_free( (char *) 
			((struct FIscrl_obj *) gadget)->FIscroll.btns);
		 _FI_s_free ( (char *) gadget);
****************/
		 break;

	  case FI_TOGGLE:

		 _FI_tog_delete ((struct FItog_obj *)gadget);
		 break;

	  case FI_LINE:
		 if (((struct FIline_obj *) gadget)->FIgraphic.dash_list)
			_FI_s_free ( (char *) ((struct FIline_obj *) gadget)->FIgraphic.dash_list);
		 break;

	  case FI_RECT:
		 if (((struct FIrect_obj *) gadget)->FIgraphic.dash_list)
			_FI_s_free ( (char *) ((struct FIrect_obj *) gadget)->FIgraphic.dash_list);
		 break;
	  }	/* end switch type */

	  _FI_s_free ( (char *) gadget->FIgadget.text);
	  _FI_s_free ( (char *) gadget->FIgadget.fontname);
	  _FI_s_free ( (char *) gadget->FIgadget.help_topic);
	  _FI_s_free ( (char *) gadget->FIgadget.command);

	  /*************************************************/
	  /* sml:01-11-94:TR 249304932  Purify errors      */
	  /*  Free these guys too; else have memory leaks  */
	  /*  menu_user_pointer is set in MIm_new when     */
	  /*  creating the palette structure for buttons   */
	  /*  for panel menus.                             */
	  /*************************************************/
	  _FI_s_free ( (char *) gadget->FIgadget.menu_user_pointer);

	  /*************************************************/
	  /* sml:03-02-94: More purify errors              */
	  /*  Upon further review, it has become apparent  */
	  /*  that a gadget's user pointer always holds a  */
	  /*  pointer to the gadget's parent gadget.       */
	  /*  E.g., a scroll bar's user_pointer might      */
	  /*  might point to its parent field.             */
	  /*  Deleting the memory at user_pointer will     */
	  /*  mess up the parent gadget.  So don't free it */
	  /*************************************************/
	  /*_FI_s_free ( (char *) gadget->FIgadget.user_pointer);*/

	  _FI_g_free_symbols (gadget);

      /* Dont _FI_s_free if the gadget has no group */

	  if (group)
	  {
		 slot = _FI_grp_get_slot (group, gadget);
	  }

      /* If no gadget was found then do not clear */
      /* out slot of re-calculate the group size */

	  if (slot > -1)
	  {
		 group->FIgroup.gadgets[slot]= 0;

		 if (calc_flag)
		 {
			if (slot < (int)group->FIgroup.begin_slot)
			   group->FIgroup.begin_slot = slot;

            /* reset the start_look_for_next_available counters */

			if ((gadget->FIgadget.label > 0) && (gadget->FIgadget.form->begin_label > gadget->FIgadget.label))
			{
			   if (gadget->FIgadget.label >= BEGIN_USER_LABEL)
				  gadget->FIgadget.form->begin_label = gadget->FIgadget.label;
			   else
				  gadget->FIgadget.form->begin_label = BEGIN_USER_LABEL;

			}
			else if ((gadget->FIgadget.label < 0) && (gadget->FIgadget.form->begin_neg_label < gadget->FIgadget.label))
			{
			   gadget->FIgadget.form->begin_neg_label = gadget->FIgadget.label;
			}
		 }
	  }

	  if (gadget)
		 _FI_s_free ( (char *) gadget);

   }	/* non-group gadget type */

   return (FI_SUCCESS);
}




/* This function constructs a new gadget with the structure given and */
/* type specified. */

int _FI_g_new (struct FIform_obj    *form,
               int                   gadget_type,
               int                   label,
               struct FIgadget_obj **ret_gadget)
{
   struct FIgadget_obj *gadget;

   switch (gadget_type)
   {
   case FI_TEXT:
	  {
		 struct FItext_obj *text = (struct FItext_obj *) calloc (1, sizeof (struct FItext_obj));
		 if (! text)
			return (FI_NO_MEMORY);

		 gadget = (struct FIgadget_obj *) text;

		 break;
	  }

   case FI_FIELD:
	  {
		 struct FIfld_obj *field = (struct FIfld_obj *) calloc (1, sizeof (struct FIfld_obj));
		 if (! field)
			return (FI_NO_MEMORY);

		 gadget = (struct FIgadget_obj *) field;

		 break;
	  }

   case FI_BUTTON:
	  {
		 struct FIbtn_obj *button = (struct FIbtn_obj *) calloc (1, sizeof (struct FIbtn_obj));

		 if (! button)
			return (FI_NO_MEMORY);

		 gadget = (struct FIgadget_obj *) button;

         /* Default setting because older version do not
         dump the hook */

		 gadget->FIgadget.justification = FI_CENTER_JUSTIFIED;

		 break;
	  }

   case FI_LINE:
	  {
		 struct FIline_obj *line = (struct FIline_obj *) calloc (1, sizeof (struct FIline_obj));
		 if (! line)
			return (FI_NO_MEMORY);

         /* default to a solid line */

		 line->FIgraphic.line_style = -1;
		 line->FIgraphic.dash_list = None;
		 line->FIgraphic.list_len = 0;

		 gadget = (struct FIgadget_obj *) line;

		 break;
	  }

   case FI_RECT:
	  {
		 struct FIrect_obj *rect = (struct FIrect_obj *) calloc (1, sizeof (struct FIrect_obj));
		 if (! rect)
			return (FI_NO_MEMORY);

         /* default to a solid line */

		 rect->FIgraphic.line_style = -1;
		 rect->FIgraphic.dash_list = None;
		 rect->FIgraphic.list_len = 0;

		 gadget = (struct FIgadget_obj *) rect;

		 break;
	  }

   case FI_CHECKLIST:
	  {
		 struct FIcklst_obj *cklst = (struct FIcklst_obj *) calloc (1, sizeof (struct FIcklst_obj));

		 if (! cklst)
			return (FI_NO_MEMORY);

		 cklst->FIcklst.box_size = BOX_SIZE;

		 gadget = (struct FIgadget_obj *) cklst;

		 break;
	  }

   case FI_TOGGLE:
	  {
		 struct FItog_obj *toggle = (struct FItog_obj *) calloc (1, sizeof (struct FItog_obj));

		 if (! toggle)
			return (FI_NO_MEMORY);

		 gadget = (struct FIgadget_obj *) toggle;

         /* Default setting because older version do not
         dump the hook */

		 gadget->FIgadget.justification = FI_CENTER_JUSTIFIED;

		 break;
	  }

   case FI_SYM:
	  {
		 struct FIsym_obj *sym = (struct FIsym_obj *) calloc (1, sizeof (struct FIsym_obj));
		 if (! sym)
			return (FI_NO_MEMORY);

		 gadget = (struct FIgadget_obj *) sym;

		 break;
	  }

   case FI_BEZEL:
	  {
		 struct FIbez_obj *bezel = (struct FIbez_obj *) calloc (1, sizeof (struct FIbez_obj));

		 if (! bezel)
			return (FI_NO_MEMORY);

		 gadget = (struct FIgadget_obj *) bezel;

		 break;
	  }

   case FI_SLIDER:
	  {
		 struct FIsld_obj *slider = (struct FIsld_obj *) calloc (1, sizeof (struct FIsld_obj));

		 if (! slider)
			return (FI_NO_MEMORY);

         /* Set the default increment to low number */

		 slider->FIrange.increment = .0000001;

		 gadget = (struct FIgadget_obj *) slider;

		 break;
	  }

   case FI_DIAL:
	  {
		 struct FIdial_obj *dial = (struct FIdial_obj *) calloc (1, sizeof (struct FIdial_obj));

		 if (! dial)
			return (FI_NO_MEMORY);

         /* Set the default increment to 1.0 */

		 dial->FIrange.increment = 1.0;

		 dial->FIdial.direction = FI_CLOCKWISE;

		 gadget = (struct FIgadget_obj *) dial;

		 break;
	  }

   case FI_GAUGE:
	  {
		 struct FIgauge_obj *gauge = (struct FIgauge_obj *) calloc (1, sizeof (struct FIgauge_obj));

		 if (! gauge)
			return (FI_NO_MEMORY);

		 gadget = (struct FIgadget_obj *) gauge;

		 break;
	  }

   case FI_GROUP:
	  {
		 struct FIgroup_obj *group = (struct FIgroup_obj *) calloc (1, sizeof (struct FIgroup_obj));

		 if (! group)
			return (FI_NO_MEMORY);

		 if (_FI_grp_alloc (group, FI_GRP_ALLOC_SIZE))
			return (FI_NO_MEMORY);

		 gadget = (struct FIgadget_obj *) group;

		 break;
	  }

   case FI_SCROLL:
	  {
		 int i;

		 struct FIscrl_obj *scroll = (struct FIscrl_obj *) calloc (1, sizeof (struct FIscrl_obj));
		 if (! scroll)
			return (FI_NO_MEMORY);

		 scroll->FIscroll.puck = (struct FIbtn_obj *) calloc (1, sizeof (struct FIbtn_obj));

		 scroll->FIscroll.puck->FIgadget.label = -1;
		 scroll->FIscroll.puck->FIgadget.pass_label = -1;
		 scroll->FIscroll.puck->FIgadget.type = FI_BUTTON;
		 scroll->FIscroll.puck->FIgadget.form = form;
		 scroll->FIscroll.puck->FIgadget.erase_color = -1;
		 scroll->FIscroll.puck->FIgadget.symbol_ptr.sym_index = 0;

		 _FI_s_rep (&scroll->FIscroll.puck->FIgadget.fontname, "FIsym");

		 scroll->FIscroll.puck->FIgadget.sym_width_scale_factor = 1.0;
		 scroll->FIscroll.puck->FIgadget.sym_height_scale_factor = 1.0;

		 scroll->FIscroll.btns = (struct FIbtn_obj **) calloc (4, sizeof (struct FIbtn_obj *));

		 for (i = 0; i < 4; i++)
		 {
			scroll->FIscroll.btns[i]= (struct FIbtn_obj *) calloc (1, sizeof (struct FIbtn_obj));

			scroll->FIscroll.btns[i]->FIgadget.label = -1;
			scroll->FIscroll.btns[i]->FIgadget.pass_label = -1;
			scroll->FIscroll.btns[i]->FIgadget.type = FI_BUTTON;
			scroll->FIscroll.btns[i]->FIgadget.form = form;
			scroll->FIscroll.btns[i]->FIgadget.off_color = FI_BLACK;
			scroll->FIscroll.btns[i]->FIgadget.on_color = FI_WHITE;
			scroll->FIscroll.btns[i]->FIgadget.erase_color = -1;

			_FI_s_rep (&scroll->FIscroll.btns[i]->FIgadget.fontname, "FIsym");

			scroll->FIscroll.btns[i]->FIgadget.sym_width_scale_factor = 1.0;
			scroll->FIscroll.btns[i]->FIgadget.sym_height_scale_factor = 1.0;
		 }
		 gadget = (struct FIgadget_obj *) scroll;

		 break;
	  }

   case FI_MULTI_COL:
	  {
		 struct FImcf_obj *mcfield = (struct FImcf_obj *) calloc (1, sizeof (struct FImcf_obj));

		 if (! mcfield)
			return (FI_NO_MEMORY);

		 gadget = (struct FIgadget_obj *) mcfield;

		 break;
	  }

   default:
	  return (FI_INVALID_GADGET_TYPE);

   }

   gadget->FIgadget.type = gadget_type;
   gadget->FIgadget.label = label;
   gadget->FIgadget.form = form;

   /* minus one means use form bgcolor */

   gadget->FIgadget.erase_color = -1;

   /* Set pass label to -1 by default */

   gadget->FIgadget.pass_label = -1;

   if (gadget_type == FI_GROUP)
   {
	  _FI_g_add_to_group (gadget, FI_FORM_GROUP, 1);
   }
   else if (gadget->FIgadget.label > -1)
   {
	  _FI_g_add_to_group (gadget, FI_FORM_GROUP, 0);
   }

   *ret_gadget = gadget;

   return (FI_SUCCESS);
}

