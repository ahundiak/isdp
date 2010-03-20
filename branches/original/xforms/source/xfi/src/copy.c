#include "FImin.h"

#include "FIscroll.h"
#include "FIbtn.h"
#include "FImcf.h"
#include "FItog.h"
#include "FItext.h"
#include "FIdial.h"
#include "FIgraphic.h"
#include "FIline.h"
#include "FIrect.h"
#include "FIbezel.h"
#include "FIgroup.h"
#include "FIgauge.h"
#include "FIfield.h"
#include "FIslider.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"

void _FI_g_copy (struct FIgadget_obj *old_gadget,
                 struct FIgadget_obj *new_gadget)
{
  struct FIgroup_obj * save_new_gadget_group =
					new_gadget->FIgadget.group ;

	/**************************************************/
	/*** Copy everything in the FIgadget structure	***/
	/**************************************************/

  new_gadget->FIgadget = old_gadget->FIgadget;


	/**********************************************************/
	/*** Put back things in the new_gadget's structure	***/
	/***   that didn't need to be copied.			***/
	/**********************************************************/

  new_gadget->FIgadget.group	  = save_new_gadget_group;
  new_gadget->FIgadget.text	  = (unsigned char *) 0;
  new_gadget->FIgadget.help_topic = (char *) 0;
  new_gadget->FIgadget.command	  = (char *) 0;
  new_gadget->FIgadget.fontname   = (char *) 0;


  _FI_s_rep ( (char **) &new_gadget->FIgadget.text,
				(char *) old_gadget->FIgadget.text );

  _FI_s_rep ( &new_gadget->FIgadget.help_topic,
				old_gadget->FIgadget.help_topic );

  _FI_s_rep ( &new_gadget->FIgadget.command,
				old_gadget->FIgadget.command );

  _FI_s_rep ( &new_gadget->FIgadget.fontname,
				old_gadget->FIgadget.fontname );
}



void _FI_fld_copy (struct FIfld_obj *old_field,
                   struct FIfld_obj *new_field)
{
  int			ii, len, xx, sel_flag;
  int			label;
  struct FIgadget_obj * gadget;
  unsigned char		t_str[32000];
  int			num_rows;


	/**************************************************/
	/*** Copy everything in the FIfield structure	***/
	/**************************************************/

  new_field->FIfield = old_field->FIfield;

	/**********************************************************/
	/*** Put back things in the new_gadget's structure	***/
	/***   that didn't need to be copied.			***/
	/**********************************************************/

  new_field->FIfield.buffer	  = (struct FI_buf_st * ) 0;
  new_field->FIfield.buffer_size  = 0;
  new_field->FIfield.defaults	  = (struct FI_buf_st * ) 0;
  new_field->FIfield.default_size = 0;

  new_field->FIfield.fmt	  = (char *) 0;
  new_field->FIfield.list_id	  = (struct FIfld_obj *) 0;
  new_field->FIfield.vscrl_id	  = (struct FIscrl_obj *) 0;
  new_field->FIfield.hscrl	  = (struct FIbtn_obj **) 0;

  if ( old_field->FIfield.fmt )
    {
      _FI_s_rep ( &new_field->FIfield.fmt, old_field->FIfield.fmt );
    }

  _FI_fld_set_defaults ( new_field, old_field->FIfield.default_size );

  for ( ii = 0; ii < old_field->FIfield.default_size; ii++ )
    {
      len = strlen ((char *)old_field->FIfield.defaults[ii].line);

      new_field->FIfield.defaults[ii].line = (unsigned char *)
			calloc ( len + 1, sizeof (unsigned char) );

#if defined(hp9000)
      strcpy ( (char *) new_field->FIfield.defaults[ii].line,
			(char *) old_field->FIfield.defaults[ii].line);
#else
      strcpy ( new_field->FIfield.defaults[ii].line,
			old_field->FIfield.defaults[ii].line);
#endif

      new_field->FIfield.defaults[ii].sel =
				old_field->FIfield.defaults[ii].sel;
    }

	/********************************************/
	/*** copy associated list if there is one ***/
	/********************************************/

  if ( old_field->FIfield.list_id )
    {
      _FI_f_get_next_neg_label ( old_field->FIgadget.form, &label );

      _FI_g_new ( old_field->FIgadget.form, FI_FIELD, label, &gadget );

      new_field->FIfield.list_id = (struct FIfld_obj *) gadget;

      _FI_g_copy ( (struct FIgadget_obj *) old_field->FIfield.list_id,
				(struct FIgadget_obj *) gadget );

      _FI_fld_copy ( (struct FIfld_obj *) old_field->FIfield.list_id,
				(struct FIfld_obj *) gadget );

      FIfld_get_list_num_rows ( (Form) old_field->FIgadget.form,
			old_field->FIgadget.label, 0, &num_rows );

      if ( num_rows > 0 )
        {
	  for ( xx = 0; xx < num_rows; xx++ )
	    {
	      FIfld_get_list_text ( (Form) old_field->FIgadget.form,
					old_field->FIgadget.label,
					xx, 0, 1000, t_str, &sel_flag );

	      FIfld_set_list_text ( (Form) old_field->FIgadget.form,
					new_field->FIgadget.label, xx,
					0, t_str, 0);
	    }
        }
    }
}


/*  int old_label;	** INPUT - label of existing gadget to	      */
			/* be copied			  	      */
/*  int *new_label;	** INPUT/OUTPUT - label of copied gadget      */
/*  int generate_new_label_flag; */
			/* INPUT - 0 => use label input in *new_label */
			/* as new gadget's label		      */
			/* !0 => generate new gadget's label	      */
			/* with FIf_get_next_label and		      */
			/* return as OUTPUT via *new_label	      */

int FIg_copy (Form  form,
              int   old_label,
              int  *new_label,
              int   generate_new_label_flag)
{
  struct FIgadget_obj *old_gadget;
  struct FIgadget_obj *new_gadget;
  int type, status;


  old_gadget = _FI_g_get_id ( (struct FIform_obj *) form, old_label);
  if ( ! old_gadget )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  type = old_gadget->FIgadget.type;

  if ( generate_new_label_flag )
    {
      FIf_get_next_label ( form, new_label );
    }

  status = _FI_g_new ( (struct FIform_obj *) form, type,
					*new_label, &new_gadget );
  if ( status != FI_SUCCESS )
    {
      return ( status );
    }


	/**********************************************************/
	/*** Add to group because the _FI_g_new will not	***/
	/***  add a gadget with label less than 0.		***/
	/**********************************************************/

  if ( *new_label < 0 )
    {
      _FI_g_add_to_group ( new_gadget, FI_FORM_GROUP, 0 );
    }

	/*************************************************/
	/*** copy the attributes common to all gadgets ***/
	/*************************************************/

  _FI_g_copy ( old_gadget, new_gadget );


/* GMD 10/5/91     When Jeff changed _FI_g_copy to copy the entire   */
/*                 stucture of the old gadget to the new gadget, it  */
/*                 wiped out the new gadget label that had been      */
/*                 assigned with a copy of what the old gadget label */
/*                 had been.  Thus, after FIg_copy, you have two     */
/*                 identical gadgets with the same gadget label.     */
/*                                                                   */
/*                 I am restoring the new gadget label here to fix   */
/*                 this problem.                                     */

        new_gadget->FIgadget.label = *new_label;

	/********************************************************/
	/*** copy the attributes peculiar to each gadget type ***/
	/********************************************************/

  switch (type)
    {
      case FI_TEXT:

		/**************************************************/
		/*** Copy everything in the FItext structure	***/
		/**************************************************/

	((struct FItext_obj *) new_gadget)->FItext =
			((struct FItext_obj *) old_gadget)->FItext;

	_FI_g_activate (new_gadget);

	break;


      case FI_BUTTON:

		/**************************************************/
		/*** Copy everything in the FIbtn structure	***/
		/**************************************************/

	((struct FIbtn_obj *) new_gadget)->FIbtn =
		((struct FIbtn_obj *) old_gadget)->FIbtn;

	    /******************************************************/
	    /*** Put back things in the new_gadget's structure	***/
	    /***   that didn't need to be copied.		***/
	    /******************************************************/

	((struct FIbtn_obj *) new_gadget)->FIbtn.palette = (char *) 0;


	if (((struct FIbtn_obj *) old_gadget)->FIbtn.menu_button == 1)
	  {
	    _FI_s_rep (  &((struct FIbtn_obj *)
			new_gadget)->FIbtn.palette,
		     ((struct FIbtn_obj *) old_gadget)->FIbtn.palette );
	  }

	_FI_g_activate ( new_gadget );

	break;


      case FI_GAUGE:

		/**************************************************/
		/*** Copy everything in the FIgauge structure	***/
		/**************************************************/

	((struct FIgauge_obj *) new_gadget)->FIgauge =
			((struct FIgauge_obj *) old_gadget)->FIgauge;

		/**************************************************/
		/*** Copy everything in the FIrange structure	***/
		/**************************************************/

	((struct FIgauge_obj *) new_gadget)->FIrange =
			((struct FIgauge_obj *) old_gadget)->FIrange;
	break;


      case FI_SCROLL:
	{
		/**************************************************/
		/*** Save the existing FI_SCROLL allocated	***/
		/*** structure pointers.			***/
		/**************************************************/

	  struct FIbtn_obj *  save_puck =
		((struct FIscrl_obj *) new_gadget)->FIscroll.puck;
	  struct FIbtn_obj ** save_btns =
		((struct FIscrl_obj *) new_gadget)->FIscroll.btns;

		/**************************************************/
		/*** Copy everything in the FIscroll structure	***/
		/**************************************************/

	  ((struct FIscrl_obj *) new_gadget)->FIscroll =
			((struct FIscrl_obj *) old_gadget)->FIscroll;

		/*****************************************************/
		/*** Put back things in the new_gadget's structure ***/
		/***   that didn't need to be copied.		   ***/
		/*****************************************************/


	  ((struct FIscrl_obj *) new_gadget)->FIscroll.puck = save_puck;
	  ((struct FIscrl_obj *) new_gadget)->FIscroll.btns = save_btns;


		/**************************************************/
		/*** Copy everything in the FIrange structure	***/
		/**************************************************/

	  ((struct FIscrl_obj *) new_gadget)->FIrange =
			((struct FIscrl_obj *) old_gadget)->FIrange;

	  _FI_g_activate ( new_gadget );
	}
	break;



      case FI_FIELD:

	_FI_fld_copy ( (struct FIfld_obj *) old_gadget,
				(struct FIfld_obj *) new_gadget );
	_FI_g_activate ( new_gadget );
	_FI_g_reset ( new_gadget );	/* GMD 2/28/91 */
	break;


      case FI_MULTI_COL:
      {
	int ii, label;
	struct FIgadget_obj *gadget;
	struct FImcf_obj *old_mcf = ((struct FImcf_obj *) old_gadget);
	struct FImcf_obj *new_mcf = ((struct FImcf_obj *) new_gadget);
	struct FIscrl_obj   *save_vscrl_id = new_mcf->FImcf.vscrl_id;
	struct FIscrl_obj   *save_hscrl_id = new_mcf->FImcf.hscrl_id;


		/**************************************************/
		/*** Copy everything in the FImcf structure	***/
		/**************************************************/

	new_mcf->FImcf = old_mcf->FImcf;


		/******************************************************/
		/*** Put back things in the new_gadget's structure  ***/
		/***   that didn't need to be copied.		    ***/
		/******************************************************/

	new_mcf->FImcf.vscrl_id = save_vscrl_id;
	new_mcf->FImcf.hscrl_id = save_hscrl_id;


		/**************************************************/
		/*** Copy everything in the FIgroup structure	***/
		/**************************************************/

	new_mcf->FIgroup	 	= old_mcf->FIgroup;
	new_mcf->FIgroup.size	 	= 0;
	new_mcf->FIgroup.gadgets	= (struct FIgadget_obj **) 0;
	new_mcf->FIgroup.current_active_gadget = 0;
	new_mcf->FIgroup.last_active_gadget = 0;
	new_mcf->FIgroup.begin_slot	    = 0;

	_FI_grp_alloc ( (struct FIgroup_obj *)new_mcf, old_mcf->FIgroup.size );

	for ( ii = 0; ii < (int)new_mcf->FIgroup.size; ii++ )
	  {
	    _FI_f_get_next_neg_label ( old_mcf->FIgadget.form, &label );
	    _FI_g_new ( old_mcf->FIgadget.form, FI_FIELD, label,
							&gadget );
	    _FI_g_add_to_group ( gadget, *new_label, 0 );
	    _FI_g_copy ( old_mcf->FIgroup.gadgets[ii], gadget );
	    _FI_fld_copy ( (struct FIfld_obj *)
				old_mcf->FIgroup.gadgets[ii],
				(struct FIfld_obj *) gadget);
	  }
	_FI_g_activate (new_gadget);
	_FI_g_reset (new_gadget);	/* GMD 2/28/91 */
      }
	break;


      case FI_RECT:

	/**************************************************/
	/*** Copy everything in the FIgraphic structure	***/
	/**************************************************/

	((struct FIrect_obj *) new_gadget)->FIgraphic =
			((struct FIrect_obj *) old_gadget)->FIgraphic;

	break;


      case FI_LINE:

	/**************************************************/
	/*** Copy everything in the FIgraphic structure	***/
	/**************************************************/

	((struct FIline_obj *) new_gadget)->FIgraphic =
			((struct FIline_obj *) old_gadget)->FIgraphic;
	break;


      case FI_TOGGLE:

	if ( IT_HAS_TEXT ( old_gadget ) )
          {
	     _FI_s_rep ( (char **) &((struct FItog_obj *)
					new_gadget)->FItog.on_text,
			(char *) ((struct FItog_obj *)
					old_gadget)->FItog.on_text);

	     ((struct FItog_obj *) new_gadget)->FItog.on_text_length =
				strlen ((char *)((struct FItog_obj *)
					new_gadget)->FItog.on_text );
          }

	_FI_g_activate (new_gadget);

	break;


      case FI_SLIDER:

	/**************************************************/
	/*** Copy everything in the FIslider structure	***/
	/**************************************************/

	((struct FIsld_obj *) new_gadget)->FIslider =
			((struct FIsld_obj *) old_gadget)->FIslider;

	/**************************************************/
	/*** Copy everything in the FIrange structure	***/
	/**************************************************/

	((struct FIsld_obj *) new_gadget)->FIrange =
			((struct FIsld_obj *) old_gadget)->FIrange;

	_FI_g_activate ( new_gadget );

	break;


      case FI_DIAL:

	/**************************************************/
	/*** Copy everything in the FIdial structure	***/
	/**************************************************/

	((struct FIdial_obj *) new_gadget)->FIdial =
		((struct FIdial_obj *) old_gadget)->FIdial ;

	/**************************************************/
	/*** Copy everything in the FIrange structure	***/
	/**************************************************/

	((struct FIdial_obj *) new_gadget)->FIrange =
	      ((struct FIdial_obj *) old_gadget)->FIrange ;

	_FI_g_activate ( new_gadget );

	break;

      case FI_CHECKLIST:
      case FI_SYM:
	_FI_g_activate ( new_gadget );
	break;
    }

  return ( FI_SUCCESS );
}
