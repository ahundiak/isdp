#include "FImin.h"

#include <stdio.h>

#include "FIscroll.h"
#include "FIbtn.h"
#include "FIfield.h"
#include "FIread.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"

extern short _FI_widest_wcharacter;
extern char _FI_widest_character;

#define FLD_CHUNK_BYTES		64


	/************************************************************/
	/* These two calls are used to implement setting colors for */
	/* individual lines in field and MCF gadgets.               */
	/************************************************************/

int _FI_fld_get_line_OFF_COLOR (struct FIfld_obj  *field,
                                int                line)
{
  int field_color = field->FIfield.buffer[line].color;

  /********************************************************************/
  /*								      */
  /* If color = 0 then use the default off color.		      */
  /* If color is < 16, then it is one of the defined form colors,     */
  /* and it needs to have 1 subtracted from it before it is returned. */
  /* If the value is greater than 16 then return it as is.	      */
  /*								      */
  /********************************************************************/

  if ( field_color == 0 )
    {
      return ( field->FIgadget.off_color );
    }
  else if ( field_color < 16 )
    {
      return ( field_color - 1 );
    }
  else
    {
      return ( field_color );
    }
}



int _FI_fld_get_line_ON_COLOR (struct FIfld_obj  *field,
                               int                line)
{
  int field_color = field->FIfield.buffer[line].color;

  /********************************************************************/
  /*								      */
  /* If color = 0 then use the default on color.		      */
  /* If color is < 16, then it is one of the defined form colors,     */
  /* and it needs to have 1 subtracted from it before it is returned. */
  /* If the value is greater than 16 then return it as is.	      */
  /*								      */
  /********************************************************************/

  if ( field_color == 0 )
    {
      return ( field->FIgadget.on_color );
    }
  else if ( field_color < 16 )
    {
      return ( field_color - 1 );
    }
  else
    {
      return ( field_color );
    }
}



int _FI_fld_activate (struct FIfld_obj *field)
{
  _FI_fld_change_text ( field, (float) 1.0, (float) 1.0 );

  if ( field->FIfield.flags.uds )
    {
      if ( ! field->FIfield.flags.is_a_col )
	{
	  if ( ! field->FIfield.vscrl_id )
	    {
	      _FI_fld_add_vscrl ( field );
	    }

	  _FI_g_activate ( (struct FIgadget_obj *)field->FIfield.vscrl_id );
	  _FI_fld_set_vscrl ( field );
	}
    }
  else if (	( field->FIfield.nr == 0 )		&&
		(! field->FIfield.flags.roll_thru )	 )
   {
	/****************************************/
	/* can't have no vscroll and no rows	*/
	/****************************************/

      field->FIfield.nr = field->FIfield.nvr;
   }

  if ( field->FIfield.flags.lrs )
    {
      if ( ! field->FIfield.hscrl )
	{
	  _FI_fld_add_hscrl ( field );
	}

      _FI_g_activate ( (struct FIgadget_obj *)field->FIfield.hscrl[0] );
      _FI_g_activate ( (struct FIgadget_obj *)field->FIfield.hscrl[1] );
    }
  else if ( field->FIfield.nc == 0 )
   {
      field->FIfield.nc = field->FIfield.nvc;
   }

  if ( field->FIfield.list_id )
   {
      _FI_fld_activate ( field->FIfield.list_id );
   }

  return ( FI_SUCCESS );
}



/*====================================================================*/

void _FI_fld_calc_nv (struct FIfld_obj *field)
{
  float xhi;
  int save_nvc = field->FIfield.nvc;  /* sml:12-03-93 added */

  if ( field->FIfield.list_id || field->FIfield.flags.roll_thru )
    {
      xhi = field->FIgadget.xhi - ROLL_THROUGH_SYM_WIDTH + FIELD_BEZEL;
    }
  else
    {
      xhi = field->FIgadget.xhi;
    }

  if ( field->FIgadget.font_width )
    {
      field->FIfield.nvc = (int) ( (xhi - field->FIgadget.xlo ) /
					field->FIgadget.font_width );

      if ( field->FIfield.nvc == 0 )
	{
	  field->FIfield.nvc = 1;
	}

      if ( ( field->FIfield.nc <= field->FIfield.nvc)	&&
	     field->FIfield.nc				 )
	{
	  field->FIfield.flags.lrs = 0;
	}

  /*********************************************************/
  /* sml:12-03-93 TR 249203422                             */
  /*  if the number of visible characters has changed in   */
  /*  field with no scrolling, change number of chars.     */
  /*********************************************************/
  if (field->FIfield.flags.lrs == 0 && field->FIfield.nvc < save_nvc)
  {
	field->FIfield.nc = field->FIfield.nvc;
  }

     /*****************************************************************/
     /*								      */
     /* If the field was right or center justifed, then the contents  */
     /* of the field needs to be altered to fit the new size.	      */
     /*								      */
     /*****************************************************************/

      if ( (( field->FIgadget.justification == FI_RIGHT_JUSTIFIED) ||
	    ( field->FIgadget.justification == FI_CENTER_JUSTIFIED) ) &&
		( field->FIfield.buffer_size > 0 )		)
	{
	  char t_str[2000], t_str2[2000];
	  int xx, yy, blanks, len;

	  for ( xx = 0; xx < field->FIfield.buffer_size; xx++ )
	    {
#if defined(hp9000)
	      strcpy ( t_str, (char *) field->FIfield.buffer[xx].line );
#else
	      strcpy ( t_str, field->FIfield.buffer[xx].line );
#endif
	      t_str2[0]= '\0';

	      len = strlen ( t_str );
	      for ( yy = 0; yy < len; yy++ )
		{
		  if ( t_str[yy]!= ' ')
		    {
		      strcpy ( t_str2, & (t_str[yy]) );
		      break;
		    }
		}

	      if ( t_str2[0] && (strlen (t_str2) < field->FIfield.nc) )
		{
		  t_str[0]= '\0';

			  /********************************************************/
			  /*sml:11-09-93 cast strlen since it returns unsigned int*/
			  /*in ANSI                                               */
			  /********************************************************/

		  if ( field->FIgadget.justification ==
						FI_RIGHT_JUSTIFIED )
		    {
		      blanks = (int)((int)field->FIfield.nvc - (int)strlen (t_str2));
		    }
		  else
		    {
		      blanks = (int)(( (int) field->FIfield.nvc - (int)strlen (t_str2) )
								/ 2);
		    }

		  if ( blanks > 0 )
		    {
		      for ( yy = 0; yy < blanks; yy++ )
			{
			  t_str[yy]= ' ';
			}
		      t_str[blanks]= '\0';
		    }

		  strcat ( t_str, t_str2 );
		}
	      else
		{
		  strcpy ( t_str, t_str2 );
		}

	           /* Now store the string into the field */

	      _FI_fld_add_to_line ( field, xx, strlen (t_str) + 2);

#if defined(hp9000)
	      strcpy ((char *) field->FIfield.buffer[xx].line, (char *) t_str );
#else
	      strcpy ( field->FIfield.buffer[xx].line, t_str );
#endif

	           /* adjust field->FIfield.nc */

	      field->FIfield.nc = field->FIfield.nvc;
	    }
	}
    }
  else
    {
      field->FIfield.nvc = 1;
    }

  if ( field->FIfield.line_height )
    {
      field->FIfield.nvr = (int)
		(( field->FIgadget.yhi - field->FIgadget.ylo ) /
					field->FIfield.line_height );

      if ( field->FIfield.nvr == 0 )
	{
	  field->FIfield.nvr = 1;
	}

      if ( ( field->FIfield.nr < field->FIfield.nvr ) &&
	     field->FIfield.nr )
	{
	  field->FIfield.flags.uds = 0;
	}
    }
  else
   {
      field->FIfield.nvr = 1;
   }
}


/*====================================================================*/
/* dmb:10/10/92:Change floats to doubles for ANSI */
/* ARGSUSED */
void _FI_fld_change_text (struct FIfld_obj *field,
                          double            delta_x,
                          double            delta_y)
{
  int status;

/* sml:08-12-92		don't do this test 
  if ( field->FIgadget.text_length != 1 )
    {
*/
	  /*sml:08-11-92 use widest characters */
 	  char widest_str[10];

	  status = _FI_widest_char(field->FIgadget.font_type, widest_str);
/***********
	  if (field->FIgadget.font_type == 2)
	  {

		widest_str[0] = widest_wchar;
		widest_str[1] = widest_wchar >> 8;
		widest_str[2] = '\0';
		widest_str[3] = '\0';
	  }
	  else
	  {
		widest_str[0] = widest_char;
		widest_str[1] = '\0';
	  }
***************/
      _FI_s_rep ( ( char **) &field->FIgadget.text, /*"M"*/ widest_str);
      field->FIgadget.text_length = 1;
/*    } */

 /* dmb:10/10/92:Added casts for ANSI */

  field->FIgadget.bodysize = (float)((double)field->FIgadget.bodysize * delta_y);
	/********************/
	/* load in new font */
	/********************/

	/***********************************************************/
	/*** ALERT !  ALERT !  STOP !  LOOK !  LISTEN !          ***/
	/***********************************************************/
	/*** FI_find_font_id MAY CHANGE GADGET'S font_id   !!!   ***/
	/*** FI_find_font_id MAY CHANGE GADGET'S font_type !!!   ***/
	/***********************************************************/

  /* dmb:09/30/92: Is this what we're doing here, too? */
  /*************************************************************/
  /*                                                           */
  /* Adjust the size of the gadget so that it will be able to  */
  /* display the same number of rows and columns, even if a    */
  /* different font is substituted for the one that was        */
  /* originally defined for the form.  GMD 3/26/91             */
  /*                                                           */
  /*************************************************************/

  status = FI_find_font_id (	field->FIgadget.fontname,
				(double)field->FIgadget.bodysize,
				(Font *)&field->FIgadget.font_id,
				(float *)&field->FIgadget.font_height,
				field->FIgadget.type,
				&field->FIgadget.font_type );
  if ( status != FI_SUCCESS )
    {
      return;
    }

  FI_calc_text ( field->FIgadget.font_id,
		(char *) field->FIgadget.text,
		 field->FIgadget.text_length,
		&field->FIgadget.font_height,
		&field->FIgadget.font_width,
		&field->FIfield.line_height,
		 field->FIgadget.font_type );

  _FI_fld_calc_nv ( field );
}


/*====================================================================*/

void _FI_fld_add_vscrl (struct FIfld_obj *field)
{
  int		     status, label;
  struct FIscrl_obj *vscrl_id;

  _FI_f_get_next_neg_label ( field->FIgadget.form, &label );

  status = _FI_g_new ( field->FIgadget.form, FI_SCROLL,
				label, (struct FIgadget_obj **)&field->FIfield.vscrl_id );
  if ( status != FI_SUCCESS )
    {
      return;
    }

	/*****************************************************/
	/*** use a local variable to decrease code .o size ***/
	/******************************   JAJ:08/27/91  ******/
  vscrl_id = field->FIfield.vscrl_id;

  vscrl_id->FIgadget.xlo = field->FIgadget.xhi + 2;
  vscrl_id->FIgadget.ylo = field->FIgadget.ylo - 2;
  vscrl_id->FIgadget.xhi = vscrl_id->FIgadget.xlo + SCROLL_SIZE;
  vscrl_id->FIgadget.yhi = field->FIgadget.yhi + 2;

	/* Needed to correct scroll bar scaling 10/4/89 */

  vscrl_id->FIgadget.orig_ysize = vscrl_id->FIgadget.yhi -
				  vscrl_id->FIgadget.ylo;

  vscrl_id->FIgadget.fontname	  = _FI_s_new ( "FIsym" );
  vscrl_id->FIscroll.type	  = FI_VERTICAL;
  vscrl_id->FIgadget.user_pointer = (char *) field;
  vscrl_id->FIrange.low_value	  = 0;
  vscrl_id->FIrange.high_value	  = 0;

  if ( ! field->FIfield.flags.draw_vscrl )
    {
      vscrl_id->FIgadget.default_attr_mask |= FI_NOT_DISPLAYED;
      vscrl_id->FIgadget.attr_mask	   |= FI_NOT_DISPLAYED;
    }
}



/*====================================================================*/

void _FI_fld_add_hscrl (struct FIfld_obj *field)
{
  struct FIbtn_obj *hscrl_0;
  struct FIbtn_obj *hscrl_1;
  int ii;

  if ( field->FIfield.hscrl )	/*** JAJ:03/15/91 ***/
    {
      free ( field->FIfield.hscrl );
    }

  field->FIfield.hscrl = (struct FIbtn_obj **) calloc ( 2,
					sizeof (struct FIbtn_obj *));

  for ( ii = 0; ii < 2; ii++ )
    {
      struct FIbtn_obj *hscrl_ii;

      /********************************** JAJ:11/08/91 **************
      if ( field->FIfield.hscrl[ii] )	/ * JAJ 8/27/90 * /
	{
	  free ( field->FIfield.hscrl[ii] );
	}
      ****************************************************************/

      field->FIfield.hscrl[ii] = (struct FIbtn_obj *) calloc ( 1,
					sizeof (struct FIbtn_obj) );

	/*****************************************************/
	/*** use a local variable to decrease code .o size ***/
	/******************************   JAJ:08/27/91  ******/
      hscrl_ii = field->FIfield.hscrl[ii];

      hscrl_ii->FIgadget.pass_label		 = -1;
      hscrl_ii->FIgadget.type			 = FI_BUTTON;
      hscrl_ii->FIgadget.form			 = field->FIgadget.form;
      hscrl_ii->FIgadget.off_color		 = FI_BLACK;
      hscrl_ii->FIgadget.on_color		 = FI_WHITE;
      hscrl_ii->FIgadget.sym_width_scale_factor  = 1.0;
      hscrl_ii->FIgadget.sym_height_scale_factor = 1.0;
      hscrl_ii->FIgadget.ylo		      = field->FIgadget.yhi + 2;
      hscrl_ii->FIgadget.yhi		  = hscrl_ii->FIgadget.ylo + 12;
      hscrl_ii->FIgadget.fontname		 = _FI_s_new ("FIsym");
      hscrl_ii->FIgadget.user_pointer		 = (char *) field;
      hscrl_ii->FIgadget.erase_color		 = -1;
      hscrl_ii->FIgadget.justification		 = FI_CENTER_JUSTIFIED;
    }

	/*****************************************************/
	/*** use a local variable to decrease code .o size ***/
	/******************************   JAJ:08/27/91  ******/
  hscrl_0 = field->FIfield.hscrl[0];

  hscrl_0->FIgadget.label = -1;
  hscrl_0->FIgadget.xlo   = field->FIgadget.xlo - 2;
  hscrl_0->FIgadget.xhi   = field->FIgadget.xlo +
		    (( field->FIgadget.xhi - field->FIgadget.xlo) / 2);
  hscrl_0->FIgadget.symbol_ptr.sym_index = CHAR_LT_SYM;

  /* New 10/23/89 GMD */

  hscrl_0->FIgadget.orig_xsize = hscrl_0->FIgadget.xhi -
						hscrl_0->FIgadget.xlo;

  hscrl_0->FIgadget.orig_ysize = hscrl_0->FIgadget.yhi -
						hscrl_0->FIgadget.ylo;

	/*****************************************************/
	/*** use a local variable to decrease code .o size ***/
	/******************************   JAJ:08/27/91  ******/
  hscrl_1 = field->FIfield.hscrl[1];

  hscrl_1->FIgadget.label		 = -2;
  hscrl_1->FIgadget.xlo			 = hscrl_0->FIgadget.xhi;
  hscrl_1->FIgadget.xhi			 = field->FIgadget.xhi + 2;
  hscrl_1->FIgadget.symbol_ptr.sym_index = CHAR_RT_SYM;

  /* New 10/23/89 GMD */

  hscrl_1->FIgadget.orig_xsize = hscrl_1->FIgadget.xhi -
					hscrl_1->FIgadget.xlo;

  hscrl_1->FIgadget.orig_ysize = hscrl_1->FIgadget.yhi -
					hscrl_1->FIgadget.ylo;

  if ( ! field->FIfield.flags.draw_hscrl )
    {
      hscrl_0->FIgadget.default_attr_mask |= FI_NOT_DISPLAYED;
      hscrl_0->FIgadget.attr_mask	  |= FI_NOT_DISPLAYED;

      hscrl_1->FIgadget.default_attr_mask |= FI_NOT_DISPLAYED;
      hscrl_1->FIgadget.attr_mask	  |= FI_NOT_DISPLAYED;
    }

  /*********************************************
   FI_g_load_symbol( field->FIfield.hscrl[0] );
   FI_g_load_symbol( field->FIfield.hscrl[1] );
  **********************************************/
}



/*========================================== <pds-2/27/90> ===========*/

int _FI_fld_set_erase_color (struct FIfld_obj  *field,
                             int                erase_color)
{
  field->FIgadget.erase_color = erase_color;

  if ( field->FIfield.vscrl_id )
    {
      /**************************************************************
      _FI_scrl_set_erase_color( field->FIfield.vscrl_id, erase_color );
      **************************************************************/

      field->FIfield.vscrl_id->FIgadget.erase_color = erase_color;
    }

  if ( field->FIfield.hscrl )
    {
      field->FIfield.hscrl[0]->FIgadget.erase_color = erase_color;
      field->FIfield.hscrl[1]->FIgadget.erase_color = erase_color;
    }

  if ( field->FIfield.list_id )
    {
      _FI_fld_set_erase_color ( field->FIfield.list_id, erase_color );
    }

  return ( FI_SUCCESS );
}


/*====================================================================*/

int _FI_fld_erase (struct FIfld_obj  *field,
                   Window             window)
{
  if ( ( window == None ) || ( field->FIgadget.form->displayed == 0 ))
    {
      field->FIgadget.attr_mask |= FI_NOT_DISPLAYED;
      field->FIgadget.displayed = FALSE;
      return ( FI_SUCCESS );
    }

  if ( IT_IS_NOT_DISPLAYED( field ))
   {
      return ( FI_SUCCESS );
   }

  XFillRectangle ( _FI_display, window, _FI_gc,
	(int) ( field->FIgadget.xlo - 2 ),
	(int) ( field->FIgadget.ylo - 2 ),
	(int) ( field->FIgadget.xhi - field->FIgadget.xlo + 5 ),
	(int) ( field->FIgadget.yhi - field->FIgadget.ylo + 5 ) );

  field->FIgadget.displayed = FALSE;

  if ( field->FIfield.list_id )
    {
		/*** <pds-2/26/90> Set its erase color ***/
      field->FIfield.list_id->FIgadget.erase_color =
					field->FIgadget.erase_color;

      _FI_g_erase ( (struct FIgadget_obj *) field->FIfield.list_id );
    }

  if ( field->FIfield.flags.draw_vscrl && field->FIfield.vscrl_id )
    {
		/*** <pds-2/14/90> Set its erase color ***/
      field->FIfield.vscrl_id->FIgadget.erase_color =
					field->FIgadget.erase_color;

      _FI_g_erase ( (struct FIgadget_obj *) field->FIfield.vscrl_id );
    }

  if ( field->FIfield.flags.draw_hscrl && field->FIfield.hscrl )
    {
		/*** <pds-2/26/90> Set their erase color ***/
      field->FIfield.hscrl[0]->FIgadget.erase_color =
					field->FIgadget.erase_color;

      field->FIfield.hscrl[1]->FIgadget.erase_color =
					field->FIgadget.erase_color;

      _FI_g_erase ( (struct FIgadget_obj *) field->FIfield.hscrl[0]);
      _FI_g_erase ( (struct FIgadget_obj *) field->FIfield.hscrl[1]);
    }

  return ( FI_SUCCESS );
}


/*====================================================================*/

int _FI_fld_display (struct FIfld_obj   *field,
                     Window              window)
{
	/****************************************************/
	/*** X11-6/15/90-Called these directly to reduce  ***/
	/*** the number of calls to XFlush() 		  ***/
	/****************************************************/

  field->FIgadget.displayed = TRUE;

  if ( _FI_is_in_clip_rectangle ( & field->FIgadget ) )
    {
      _FI_fld_refresh_data ( field, window );
    }

  if ( field->FIfield.flags.draw_vscrl && field->FIfield.vscrl_id )
    {
      field->FIfield.vscrl_id->FIgadget.attr_mask &= ~ FI_NOT_DISPLAYED;

      _FI_scrl_display ( field->FIfield.vscrl_id, window );

      field->FIfield.vscrl_id->FIgadget.displayed = TRUE;
    }

  if ( field->FIfield.flags.draw_hscrl && field->FIfield.hscrl )
    {
      field->FIfield.hscrl[0]->FIgadget.attr_mask &= ~ FI_NOT_DISPLAYED;
      field->FIfield.hscrl[1]->FIgadget.attr_mask &= ~ FI_NOT_DISPLAYED;

      _FI_btn_display ( field->FIfield.hscrl[0], window );
      field->FIfield.hscrl[0]->FIgadget.displayed = TRUE;

      _FI_btn_display ( field->FIfield.hscrl[1], window );
      field->FIfield.hscrl[1]->FIgadget.displayed = TRUE;
    }

  if ( field->FIfield.list_id 				 	&&
		IT_IS_DISPLAYABLE( field->FIfield.list_id )	 )
     {
       _FI_fld_display ( field->FIfield.list_id, window );
     }

  return ( FI_SUCCESS );
}


/*====================================================================*/

void _FI_fld_draw_bezel (struct FIfld_obj   *field,
                         Window              window)
{
  int	Xscreen	= XSCREEN( field );
  int	xlo	= field->FIgadget.xlo;
  int	xhi	= field->FIgadget.xhi;
  int	ylo	= field->FIgadget.ylo;
  int	yhi	= field->FIgadget.yhi;
  XGCValues gc_values;
  unsigned int value_mask = GCLineStyle | GCLineWidth | GCForeground;

  gc_values.line_width = 1;
  gc_values.line_style = LineSolid;

  if ( IT_IS_HILITED( field ))
    {
      gc_values.foreground = FI_translate_color ( Xscreen, FI_GLINT );
    }
  else
    {
      gc_values.foreground = FI_translate_color ( Xscreen, FI_EDGE );
    }

  XChangeGC ( _FI_display, _FI_gc, value_mask, &gc_values );

  XDrawRectangle ( _FI_display, window, _FI_gc,
		   xlo - 1, ylo - 1, xhi - xlo + 2, yhi - ylo + 2 );

  if ( IT_IS_DISABLED( field ) )
    {
      XSetForeground ( _FI_display, _FI_gc,
			FI_translate_color ( Xscreen, FI_FACE ) );
    }
  else
    {
      XSetForeground ( _FI_display, _FI_gc,
			FI_translate_color (Xscreen, FI_GLINT) );
    }

  XDrawRectangle ( _FI_display, window, _FI_gc,
		   xlo - 2, ylo - 2, xhi - xlo + 2, yhi - ylo + 2 );

  if ( field->FIfield.list_id || field->FIfield.flags.roll_thru )
     {
       _FI_fld_draw_sym_area ( field, window );
     }
}


/*====================================================================*/

void _FI_fld_draw_sym_area (struct FIfld_obj  *field,
                            Window             window)
{
  int	Xscreen	= XSCREEN( field );
  int	center_y;
  int	xlo	= field->FIgadget.xlo;
  int	xhi	= field->FIgadget.xhi;
  int	ylo	= field->FIgadget.ylo;
  int	yhi	= field->FIgadget.yhi;
  XGCValues gc_values;
  unsigned int value_mask = GCForeground | GCLineWidth;


	/************************************************/
	/** Separate field and box with vertical lines **/
	/************************************************/

  XSetForeground ( _FI_display, _FI_gc,
			FI_translate_color ( Xscreen, FI_EDGE ) );

  XDrawLine ( _FI_display, window, _FI_gc,
			xhi + 4 - ROLL_THROUGH_SYM_WIDTH,
			ylo, xhi + 4 - ROLL_THROUGH_SYM_WIDTH, yhi );

  XSetForeground ( _FI_display, _FI_gc,
			FI_translate_color ( Xscreen, FI_GLINT ) );

  XDrawLine ( _FI_display, window, _FI_gc,
			xhi + 3 - ROLL_THROUGH_SYM_WIDTH,
			ylo - 1, xhi + 3 - ROLL_THROUGH_SYM_WIDTH,
			yhi );

  xlo	   = xhi + 5 - ROLL_THROUGH_SYM_WIDTH;
  center_y = ( ylo + yhi ) / 2;

  gc_values.foreground = FI_translate_color ( Xscreen, FI_SHADOW );
  gc_values.line_width = 2;
  XChangeGC ( _FI_display, _FI_gc, value_mask, &gc_values );

  if ( field->FIfield.flags.roll_thru )
    {
      XSegment seg[3];

	/** Left hand line from top to bottom **/

      seg[0].x1 = xlo + 2;
      seg[0].y1 = ylo + 3;
      seg[0].x2 = xlo + 2;
      seg[0].y2 = yhi - 2;

	/** Right hand line from top to center **/

      seg[1].x1 = xhi - 2;
      seg[1].y1 = ylo + 3;
      seg[1].x2 = xhi - 2;
      seg[1].y2 = center_y - 1;

	/** Right hand line from center to bottom **/

      seg[2].x1 = xhi - 2;
      seg[2].y1 = center_y + 3;
      seg[2].x2 = xhi - 2;
      seg[2].y2 = yhi - 2;

      XDrawSegments ( _FI_display, window, _FI_gc, seg, 3 );

	/** Top Trapezoid **/

      _FI_vertices[0].x = xlo + 1;
      _FI_vertices[0].y = ylo + 3;
      _FI_vertices[1].x = xlo + 3;
      _FI_vertices[1].y = ylo + 1;
      _FI_vertices[2].x = xhi - 3;
      _FI_vertices[2].y = ylo + 1;
      _FI_vertices[3].x = xhi;
      _FI_vertices[3].y = ylo + 3;
      _FI_vertices[4].x = xlo + 1;
      _FI_vertices[4].y = ylo + 3;

      XFillPolygon ( _FI_display, window, _FI_gc, _FI_vertices,
				5, Nonconvex, CoordModeOrigin );

	/** Down Arrow **/

      _FI_vertices[0].x = xhi - 5;
      _FI_vertices[0].y = center_y - 2;
      _FI_vertices[1].x = xhi + 1;
      _FI_vertices[1].y = center_y - 2;
      _FI_vertices[2].x = xhi - 2;
      _FI_vertices[2].y = center_y + 1;
      _FI_vertices[3].x = xhi - 3;
      _FI_vertices[3].y = center_y + 1;
      _FI_vertices[4].x = xhi - 5;
      _FI_vertices[4].y = center_y - 2;

      XFillPolygon ( _FI_display, window, _FI_gc, _FI_vertices,
				5, Nonconvex, CoordModeOrigin );

	/** Bottom trapezoid **/

      _FI_vertices[0].x = xlo + 1;
      _FI_vertices[0].y = yhi - 2;
      _FI_vertices[1].x = xhi - 1;
      _FI_vertices[1].y = yhi - 2;
      _FI_vertices[2].x = xhi - 2;
      _FI_vertices[2].y = yhi - 1;
      _FI_vertices[3].x = xlo + 4;
      _FI_vertices[3].y = yhi;
      _FI_vertices[4].x = xlo + 2;
      _FI_vertices[4].y = yhi - 2;

      XFillPolygon ( _FI_display, window, _FI_gc, _FI_vertices, 5,
				Nonconvex, CoordModeOrigin );
    }
  else	/** Associated List **/
    {
      int yy;

      yy = field->FIgadget.ylo - 2;

      while ( yy + 5 < field->FIgadget.yhi )
	{
		/*** X11-4/18/90 - Might want to compile these  ***/
		/*** into segments and then use XDrawSegments() ***/

	  yy += 4;

	  XDrawLine ( _FI_display, window, _FI_gc,
			xlo + 2, yy,
			(int) field->FIgadget.xhi - 2, yy );
	}
    }
}


/*====================================================================*/

int _FI_fld_refresh_data (struct FIfld_obj  *field,
                          Window             window)
{
  int		 ii, len, ndx, ndy, status = 0;
  int		 x1, y1, x2, y2;
  int		 Xscreen = XSCREEN( field );
  unsigned char *str;
  int		 aaa, bbb, ccc;
  int		 bgcolor, temp_bgcolor;
  XRectangle clip_rect;
/*  char		 widest_str[10];*/

  if (	(window == None )			 ||
	( field->FIgadget.form->displayed == 0 ) ||
	(IT_IS_NOT_DISPLAYABLE( field ))	  )
    {
      return ( FI_SUCCESS );	/* dmb:03/14/91:Examine this */
    }

	/*sml:08-12-92 use widest character */
/***** sml:10-05-92	calling FI_calc_text has round trip call when
					using X server fonts; just used gadget members
					font_height and font_width and field member
					line_spacing

	status = _FI_widest_char(field->FIgadget.font_type, widest_str);
    FI_calc_text ( field->FIgadget.font_id, //"m"// widest_str, 1,
		&aaa, &bbb, &ccc, field->FIgadget.font_type );

************/

	  aaa = field->FIgadget.font_height;
	  bbb = field->FIgadget.font_width;
	  ccc = field->FIfield.line_height;

	/**********************************/
	/* determine usable part of field */
	/**********************************/

  x1 = field->FIgadget.xlo;
  y1 = field->FIgadget.ylo;

  if ( field->FIfield.list_id || field->FIfield.flags.roll_thru )
    {
      x2 = (int) field->FIgadget.xhi - ROLL_THROUGH_SYM_WIDTH +
							FIELD_BEZEL;
    }
  else
    {
      x2 = (int) field->FIgadget.xhi;
    }

  y2 = (int) field->FIgadget.yhi;

	/****************************/
	/* display field background */
	/****************************/

  if ( field->FIfield.mode && field->FIfield.mode <= FI_MULTI_SELECT )
    {
      bgcolor = FI_translate_color ( Xscreen, FI_LT_GREY );
    }
  else
    {
      bgcolor = FI_translate_color ( Xscreen, FI_MED_GREY );
    }

  XSetForeground ( _FI_display, _FI_gc, bgcolor );

  if ( field->FIfield.flags.required )
    {
      XGCValues gc_values;
      unsigned long gc_value_mask;

      gc_value_mask	   = GCStipple | GCBackground | GCFillStyle;
      gc_values.background = FI_translate_color ( Xscreen, FI_WHITE );
      gc_values.stipple    = _FIpix_required_array [Xscreen];
      gc_values.fill_style = FillOpaqueStippled;
      XChangeGC ( _FI_display, _FI_gc, gc_value_mask, &gc_values );
    }

  XFillRectangle ( _FI_display, window, _FI_gc,
			x1, y1, x2 - x1, y2 - y1 );

  if ( field->FIfield.flags.required )
    {
      XSetFillStyle ( _FI_display, _FI_gc, FillSolid );
    }

  if ( field->FIfield.flags.no_echo )
    {
      _FI_fld_draw_bezel ( field, window );

      /* sml:01-18-94:TR 249400065                         */
      /*  Add check before flushing.  Don't flush if       */
      /*  initially displaying gadget.  OK to flush if     */
      /*  updating      */
      if (!_FI_dont_flush)
        XFlush ( _FI_display );

      return ( FI_SUCCESS );	/* dmb:03/14/91:Examine this */
    }

  if ( field->FIfield.roff < 0 )
    {
      field->FIfield.roff = 0;
    }

  for ( ii = 0;
	( ii < field->FIfield.nvr ) &&
	( ii + field->FIfield.roff < field->FIfield.buffer_size );
								  ii++ )
    {
      int dither_color;

      temp_bgcolor = bgcolor;

      if ( ( field->FIfield.mode == FI_INSERT)			      ||
	   ( field->FIfield.mode == FI_APPEND)			      ||
	   ( field->FIfield.buffer[field->FIfield.roff + ii].sel & 1 ) )
        {
	  dither_color = FI_MED_GREY;
        }
      else
        {
	  dither_color = FI_LT_GREY;
        }

	/*** <pds-12/14/89> Draw the text row whether   ***/
	/***			it is selected or not.  ***/
	/*** <pds-2/15/90> Added 'font_type'		***/

      if ( FI_strlen ( (char *)field->FIfield.buffer[field->FIfield.roff + ii].line,
				field->FIgadget.font_type ) > 0 )
	{
	  if (  field->FIfield.mode == FI_SINGLE_SELECT ||
		field->FIfield.mode == FI_MULTI_SELECT	 )
	    {
	      if ( ( field->FIfield.buffer[field->FIfield.roff + ii].sel & 1 )
				&& (! field->FIfield.flags.roll_thru ) )
		{
		  int ht, wd, ls;

		  temp_bgcolor = FI_translate_color ( Xscreen,
							FI_MED_GREY );

		  XSetForeground ( _FI_display, _FI_gc, temp_bgcolor );

			/*** <pds-12/14/89> Find the line spacing ***/
			/*** of the field and use it to redraw    ***/
			/*** the select bar.			  ***/

/***** sml:10-05-92	calling FI_calc_text has round trip call when
					using X server fonts; just used gadget members
					font_height and font_width and field member
					line_spacing

		  FI_calc_text ( field->FIgadget.font_id,
			(char *) & ( field->FIfield.buffer[field->FIfield.roff + ii].line ),
			1, &ht, &wd, &ls, field->FIgadget.font_type );

************/

	  ht = field->FIgadget.font_height;
	  wd = field->FIgadget.font_width;
	  ls = field->FIfield.line_height;

		  XFillRectangle ( _FI_display, window, _FI_gc,
						x1, y1, x2 - x1, ls );

	              /* GMD 4/6/90 */
		  XSetForeground ( _FI_display, _FI_gc,
				FI_translate_color ( Xscreen,
				    _FI_fld_get_line_ON_COLOR ( field,
					   field->FIfield.roff + ii)) );
		}
	      else
		{
		  /* GMD 4/6/90 */
		  XSetForeground ( _FI_display, _FI_gc,
			FI_translate_color ( Xscreen,
				_FI_fld_get_line_OFF_COLOR ( field,
					field->FIfield.roff + ii ) ) );
		}
	    }
	  else if ( field->FIfield.mode == FI_REVIEW )
	    {
	      XSetForeground ( _FI_display, _FI_gc,
			FI_translate_color ( Xscreen,
				_FI_fld_get_line_OFF_COLOR ( field,
					field->FIfield.roff + ii ) ) );
	    }
	  else
	    {
	      XSetForeground ( _FI_display, _FI_gc,
			FI_translate_color ( Xscreen,
				_FI_fld_get_line_ON_COLOR ( field,
					field->FIfield.roff + ii ) ) );
	    }

						/*** GMD:08/28/91 ***/
	  XSetBackground ( _FI_display, _FI_gc, temp_bgcolor );

	/*** <pds-12/14/89> Calculate number of characters	***/
	/*** to be drawn.  <pds-2/15/90> Added 'font_type' 	***/

	  len = FI_strlen (
		(char *) field->FIfield.buffer[field->FIfield.roff + ii].line,
		field->FIgadget.font_type ) - field->FIfield.coff;

	  if ( len > field->FIfield.nvc )
	    {
	      len = field->FIfield.nvc;
	    }

	  if ( len > 0 )
	    {
	      if ( field->FIfield.format )
		{
		  field->FIfield.format (
		   field->FIfield.buffer[field->FIfield.roff + ii].line,
			     & str );  /** added '&' --JAJ:08/27/91 **/
		}
	      else
		{
		  str = & ( field->FIfield.buffer[field->FIfield.roff +
			    ii].line[ FI_move_index (
				(char *)field->FIfield.buffer[field->FIfield.roff + ii].line,
				0, field->FIfield.coff,
				field->FIgadget.font_type )]);
		}

			/* Hebrew 8/01/90 */
	      if ( field->FIfield.flags.right_to_left )
		{
		  char	s1[30000], s2[30000];
		  int	ht, wd, ls;
		  int	newx;
		  int	temp_font_height;
/*	 	  char widest_str[10]; */

#if defined(hp9000)
		  strcpy ( s1, (char *) str );
#else
		  strcpy ( s1, str );
#endif
		  s1[len]= '\0';
		  _FI_flip_string ( s1, s2 );

		  /*sml:08-11-92 use widest characters here */

/***** sml:10-05-92	calling FI_calc_text has round trip call when
					using X server fonts; just used gadget members
					font_height and font_width and field member
					line_spacing

		  status = _FI_widest_char(field->FIgadget.font_type, widest_str);
		  FI_calc_text ( field->FIgadget.font_id, //"m"// widest_str, 1,
			     &ht, &wd, &ls, field->FIgadget.font_type );

************/

	  ht = field->FIgadget.font_height;
	  wd = field->FIgadget.font_width;
	  ls = field->FIfield.line_height;

		  newx = (int) field->FIgadget.xlo;
		  newx += ( field->FIfield.nvc - len) * wd;


		  temp_font_height = field->FIgadget.font_height;

		 	/****************************************/
			/* Have to push XFontserver fonts down  */
			/*     GMD 8/30/91                      */
		 	/****************************************/
                  if ( field->FIgadget.font_type != 0 )   /* != .snf */
		    {
		       temp_font_height +=
				( field->FIgadget.font_height / 5 );
		    }

		  status = FI_draw_text ( window,
				field->FIgadget.font_id, s2, len,
				newx, y1,
				temp_font_height,
				&ndx, &ndy,
				field->FIgadget.font_type);
		}
	      else
		{
		  int	temp_font_height;

		  temp_font_height = field->FIgadget.font_height;

			/***************************************/
			/* Have to push XFontserver fonts down */
			/*     GMD 8/30/91                     */
			/***************************************/

                  if ( field->FIgadget.font_type != 0 )   /* != .snf */
		    {
		       temp_font_height +=
				( field->FIgadget.font_height / 5 );
		    }

		  status = FI_draw_text ( window,
					field->FIgadget.font_id, (char *)str,
					len, x1, y1,
					temp_font_height,
					&ndx, &ndy,
					field->FIgadget.font_type);
		}

		/****************************************/
		/* Handle dithering of the line of text */
		/****************************************/

	      if ( field->FIfield.flags.is_a_col )
		{
		  if ( field->FIgadget.group->FIgadget.attr_mask &
						 FI_NO_DITHERING )
		    {
		      field->FIgadget.attr_mask |= FI_NO_DITHERING;
		    }
		  else
		    {
	              /* dmb:03/24/91: fixed typo SMART found. was != */
		      field->FIgadget.attr_mask |= FI_NO_DITHERING;
		      field->FIgadget.attr_mask ^= FI_NO_DITHERING;
		    }
		}

	      if ( IT_IS_DISABLED ( field ) &&
		 (( field->FIgadget.attr_mask & FI_NO_DITHERING) == 0 ))
		{
		  XGCValues gc_values;
		  unsigned long gc_value_mask;

		  gc_value_mask = GCStipple | GCForeground |
							GCFillStyle;
		  gc_values.foreground =
			   FI_translate_color ( Xscreen, dither_color );
		  gc_values.stipple = _FIpix_gray50_array [Xscreen];
		  gc_values.fill_style = FillStippled;
		  XChangeGC ( _FI_display, _FI_gc, gc_value_mask,
							&gc_values );

                 /* dmb:03/08/91:I put this in here so we can compile */
/*
		  XFillRectangle ( _FI_display, window, _FI_gc, x1,
					y1 + ii * ccc, x2 - x1, ccc );
*/
	  /***************************************************/
	  /* sml:02-19-93                                    */
	  /* change clip area to dither gadget's entire area */
	  /***************************************************/
	 	  clip_rect.x = field->FIgadget.xlo;
		  clip_rect.y = field->FIgadget.ylo;
		  clip_rect.width = field->FIgadget.xhi - field->FIgadget.xlo;
 		  clip_rect.height = field->FIgadget.yhi - field->FIgadget.ylo;
		  XSetClipRectangles ( _FI_display, _FI_gc, 0, 0, &clip_rect,
						 1, Unsorted );

           /* GMD   Fix problem with disabled appearance  9/27/91 */

		  XFillRectangle ( _FI_display, window, _FI_gc, x1,
					y1, x2 - x1, ccc );

	             /* Mack's original **********************
	              XFillRectangle( _FI_display, window, 
			                  _FI_gc, xlo, ylo + ii * ccc, 
			                  xhi - xlo, ccc );
		     *****************************************/

	 	 /***************************************************/
 		 /* sml:02-19-93                                    */
		 /* set it back to general clip area                */
	 	 /***************************************************/
		if (_FI_form_clipping_on)
		{
		  clip_rect.x = _FI_clip_xlo;
		  clip_rect.y = _FI_clip_ylo;
		  clip_rect.width = _FI_clip_xhi - _FI_clip_xlo;
		  clip_rect.height = _FI_clip_yhi - _FI_clip_ylo;
		  XSetClipRectangles ( _FI_display, _FI_gc, 0, 0, &clip_rect,
						 1, Unsorted );
		}
		else
		{
		  XSetClipMask(_FI_display, _FI_gc, None);
		}
		  XSetFillStyle ( _FI_display, _FI_gc, FillSolid );
		}
	    }

	  if ( status )
	    {
	      return ( FI_SUCCESS );	/* dmb:03/14/91:Examine this */
	    }
	}
      else	/*** If line is a NULL, but row is selected,	***/
		/*** paint it dark anyway. GMD 10/4/90		***/
	{
	  if (	field->FIfield.mode == FI_SINGLE_SELECT ||
		field->FIfield.mode == FI_MULTI_SELECT	 )
	    {
	      if ( ( field->FIfield.buffer[field->FIfield.roff + ii].sel & 1 ) &&
		  ( ! field->FIfield.flags.roll_thru )		)
		{
		  int ht, wd, ls;

		  XSetForeground ( _FI_display, _FI_gc,
			FI_translate_color ( Xscreen, FI_MED_GREY ) );

			/*** <pds-12/14/89> Find the line spacing  ***/
			/*** of the field and use it to redraw the ***/
			/*** select bar.			   ***/

/***** sml:10-05-92	calling FI_calc_text has round trip call when
					using X server fonts; just used gadget members
					font_height and font_width and field member
					line_spacing

		  FI_calc_text ( field->FIgadget.font_id,
			(char *) & ( field->FIfield.buffer[field->FIfield.roff + ii].line ),
			1, &ht, &wd, &ls, field->FIgadget.font_type );

************/

	  ht = field->FIgadget.font_height;
	  wd = field->FIgadget.font_width;
	  ls = field->FIfield.line_height;

		  XFillRectangle ( _FI_display, window, _FI_gc,
					x1, y1, x2 - x1, ls );
		}
	    }
	}

      y1 += (short) field->FIfield.line_height;

    }  /*** end of for ( # of visible rows ) loop ***/

	/*** <pds-12/13/89> Just in case there are kerning	***/
	/*** characters on the left edge of the field which eat	***/
	/*** up the bezel, redraw the bezel.			***/

  _FI_fld_draw_bezel ( field, window );

      /* sml:01-18-94:TR 249400065                         */
      /*  Add check before flushing.  Don't flush if       */
      /*  initially displaying gadget.  OK to flush if     */
      /*  updating      */
  if (!_FI_dont_flush)
    XFlush ( _FI_display );

  return ( FI_SUCCESS );
}


/*====================================================================*/

int _FI_fld_set_buffer (struct FIfld_obj  *field,
                        int                size,
                        int                reset_all_columns)
{
  int ii, old_size;
  int nn;

  old_size = field->FIfield.buffer_size;

  field->FIfield.buffer_size = size;

  /*******************************************************/
  /*							 */
  /* If max number of lines(size )== 0, then		 */
  /* you want to deallocate everything in the column.	 */
  /*							 */
  /*******************************************************/

  if ( ! size )
    {
      if ( field->FIfield.buffer )
	{
	  for ( ii = 0; ii < old_size; ii++ )
	    {
	      if ( field->FIfield.buffer[ii].line )
		{
		  _FI_s_free ( (char *)
				field->FIfield.buffer[ii].line );

		  field->FIfield.buffer[ii].line = 0;
		}
	    }

		/*** <pds-1/29/90> NEVER release the buffers	***/
		/*** ( until the gadget is deleted ), because	***/
		/*** the user will probably reset the buffers.  ***/

	    /***************************************
	    _FI_s_free( field->FIfield.buffer );

            field->FIfield.buffer = 0;
            ***************************************/
	}

      field->FIfield.roff = 0;
      field->FIfield.coff = 0;
      field->FIfield.ar	  = 0;
      field->FIfield.ac	  = 0;
    }
  else if ( ! field->FIfield.buffer )
    {
	/*******************************/
	/* Create first line of buffer */
	/*******************************/

	/*** <pds-1/25/90> Always grab at least 16 structures     ***/
	/*** Now, only grab 8 (saves 96 bytes/field) JAJ:08/27/91 ***/

      field->FIfield.alloc_size = 8;

      while ( size > field->FIfield.alloc_size )
	{
	  field->FIfield.alloc_size *= 2;
	}

      field->FIfield.buffer = (struct FI_buf_st *) calloc (
		field->FIfield.alloc_size, sizeof (struct FI_buf_st) );

      if ( ! field->FIfield.buffer )
	{
	  return ( FI_NO_MEMORY );
	}
    }
  else if ( size != old_size )
    {
      if ( size < old_size )
	{
		/******************************/
		/* Kill any unnecessary lines */
		/******************************/

	  for ( ii = size; ii < old_size; ii++ )
	    {
	      if ( field->FIfield.buffer[ii].line )
		{
		  _FI_s_free ( (char *)
				field->FIfield.buffer[ii].line );

		  field->FIfield.buffer[ii].line = 0;
		}
	    }
	}

	/*** <pds-1/25/90> The following sets up the memory	***/
	/*** to be allocated in special chunks.			***/
	/*** The realloc is only done if more memory is needed. ***/

      if ( size > field->FIfield.alloc_size )
	{
	  while ( size > field->FIfield.alloc_size )
	    {
	      field->FIfield.alloc_size *= 2;
	    }

	  field->FIfield.buffer = (struct FI_buf_st *) realloc
			( field->FIfield.buffer,
		field->FIfield.alloc_size * sizeof (struct FI_buf_st ));
	}

      if ( size > old_size )
	{
		/********************/
		/* Create new lines */
		/********************/

	  memset ( &field->FIfield.buffer[old_size], 0,
		      (size - old_size ) * sizeof (struct FI_buf_st) );

	  /****************************************************/
	  /*                                                  */
	  /* sml:09-30-94:TR 24946670                         */
	  /* Wrapping doesn't work correctly in fields with   */
	  /* with blank lines that have never been            */
	  /* initialized.  If creating lines that leave       */
	  /* uninitialized lines between last row of text and */
	  /* target line, initialize them and  mark them with */
	  /* paragraph markers.                               */
	  /* Before this change, all we did was initialize    */
	  /* the text first row of the newly allocated memory */
	  /* without a new paragraph marker.                  */
	  /*                                                  */
	  /****************************************************/
/*
  	    field->FIfield.buffer[old_size].line = (unsigned char *)
			    calloc (  FLD_CHUNK_BYTES, 
                      sizeof ( unsigned char ));

	    field->FIfield.buffer[old_size].line[0] = 0;
*/

	  for (nn = old_size; nn < size; nn++)
	  {
  	    field->FIfield.buffer[nn].line = (unsigned char *)
			    calloc (  FLD_CHUNK_BYTES, 
                      sizeof ( unsigned char ));

	    field->FIfield.buffer[nn].line[0] = 0;

		if (field->FIfield.flags.wrap == 1)
		{
		  if (nn != size - 1)
/*
			   ((size - 1 > 0 && nn == size - 1 && 
				(field->FIfield.buffer[nn - 1].line &&
				 strcmp(field->FIfield.buffer[nn - 1].line, "") != 0)))
*/
		  {
			field->FIfield.buffer[nn].paragraph = 1;
		  }
		}
	  }

	  if ( ! field->FIfield.buffer[old_size].line )
	    {
	      return ( FI_NO_MEMORY );
	    }

	  field->FIfield.buffer[old_size].line[0]= '\0';
	}
    }

		/***************************/
		/* adjust scroll if needed */
		/***************************/

  if ( field->FIfield.vscrl_id )
    {
      if ( field->FIfield.buffer_size > field->FIfield.nvr )
        {
	  field->FIfield.vscrl_id->FIrange.high_value =
		field->FIfield.buffer_size - field->FIfield.nvr - 1;
        }
      else
        {
	  field->FIfield.vscrl_id->FIrange.high_value = 0;
        }

	/*** <pds-12/14/89> After the line is deleted, scroll	***/
	/***  the rows down to the same line, so the scroll bar	***/
	/***  does not get hosed up.			 	***/

      if ( field->FIfield.roff  &&  ( size < old_size ) )
        {
	  _FI_fld_scrl_previous ( field, old_size - size );
        }

      _FI_fld_set_vscrl ( field );
    }

  /*********************************************************/
  /* Allocate a new line of space for each column in a MCF */
  /*********************************************************/

  if ( reset_all_columns )
    {
      if ( field->FIfield.flags.is_a_col )
	{
	  _FI_grp_pass_on_id_int_always (
			(struct FIgadget_obj *) field->FIgadget.group,
			_FI_fld_set_buffer, size, 0 );

	  _FI_mcf_set_vscrl ( (struct FImcf_obj *)field->FIgadget.group );
	}
    }

  return ( FI_SUCCESS );
}


/*====================================================================*/

void _FI_fld_add_to_line (struct FIfld_obj  *field,
                          int                row,
                          int                new_len)
{
  int	len;
  int	new_chunks, old_chunks;	/*** changed from "double" to "int" ***/
				/*** -- JAJ:08/27/91		    ***/

	/*************************************************/
	/* calculate number of chunks needed for new len */
	/*************************************************/

  new_chunks = ( new_len / FLD_CHUNK_BYTES ) + 1;


  if ( ! field->FIfield.buffer[row].line )
    {
      if ( field->FIfield.nc )
	{
		/*************************/
		/* allocate fixed number */
		/*************************/

	        /*** <pds-12/13/89> Multiply by 2,	***/
		/*** in case of 16-bit font.		***/

	  field->FIfield.buffer[row].line = (unsigned char *)
			calloc ( 2 * (int) field->FIfield.nc + 1,
					     sizeof (unsigned char) );
	}
      else
	{
		/************************************/
		/* allocate needed number of chunks */
		/************************************/

	  field->FIfield.buffer[row].line = (unsigned char *)
			calloc ( new_chunks * FLD_CHUNK_BYTES,
					sizeof (unsigned char) );
	}
    }
  else	/* already allocated - does realloc need to be called ? */
    {
	/*************************************************/
	/* calculate number of chunks needed for new len */
	/*************************************************/

      len = strlen ( (char *)field->FIfield.buffer[row].line );

      old_chunks =  ( len / FLD_CHUNK_BYTES ) + 1;


      if ( old_chunks != new_chunks )
	{
	  field->FIfield.buffer[row].line = (unsigned char *)
		realloc ( field->FIfield.buffer[row].line,
			   (new_chunks * FLD_CHUNK_BYTES) *
					    sizeof (unsigned char) );

	  if ( new_chunks > old_chunks )
	    {
	      memset ( &field->FIfield.buffer[row].line[
				     old_chunks * FLD_CHUNK_BYTES],
			0, FLD_CHUNK_BYTES * sizeof (unsigned char ));
	    }
	}
    }
}


/*====================================================================*/

void _FI_fld_set_defaults (struct FIfld_obj  *field,
                           int                size)
{
  int ii, old_size;

  old_size = field->FIfield.default_size;
  field->FIfield.default_size = size;

  if ( ! size )
    {
      if ( field->FIfield.defaults )
	{
	  for ( ii = 0; ii < old_size; ii++ )
	    {
	      if ( field->FIfield.defaults[ii].line )
		{
		  _FI_s_free ( (char *)
				field->FIfield.defaults[ii].line );

			/*** field->FIfield.defaults[ii].line = 0;  ***/
			/***   Don't need to set these to 0, since  ***/
			/***   we're freeing the "defaults" ptr     ***/
		}
	    }

	   _FI_s_free ( (char *) field->FIfield.defaults );
	   field->FIfield.defaults = 0;
	}

      field->FIfield.roff = 0;
      field->FIfield.coff = 0;
      field->FIfield.ar   = 0;
      field->FIfield.ac   = 0;
    }
  else if ( ! field->FIfield.defaults )
    {
      field->FIfield.defaults = (struct FI_buf_st *) calloc (
				(int) field->FIfield.default_size,
					sizeof (struct FI_buf_st ));
    }
  else
    {
      if ( size < old_size )
	{
	  for ( ii = size; ii < old_size; ii++ )
	    {
	      if ( field->FIfield.defaults[ii].line )
		{
		  _FI_s_free ( (char *)
				field->FIfield.defaults[ii].line );
		  field->FIfield.defaults[ii].line = 0;
		}
	    }
	}

      field->FIfield.defaults = (struct FI_buf_st *) realloc (
			field->FIfield.defaults,
	     field->FIfield.default_size * sizeof (struct FI_buf_st) );

      memset ( &field->FIfield.defaults[old_size], 0,
		(size - old_size ) * sizeof (struct FI_buf_st) );
    }
}


/*====================================================================*/

void _FI_fld_reset_buffer (struct FIfld_obj *field)
{
  int ii;
  int num_lines;
  int len;

  if ( field->FIfield.nr					    &&
		( field->FIfield.default_size > field->FIfield.nr )  )
    {
      num_lines = field->FIfield.nr;
    }
  else
    {
      num_lines = field->FIfield.default_size;
    }

	/***************************************************/
	/* Pass a 0 in the reset_all_columns field because */
	/* we do not want to reset the other columns.	   */
	/***************************************************/

  _FI_fld_set_buffer ( field, num_lines, 0 );

  field->FIfield.prev_sel = -1;

  for ( ii = 0; ii < num_lines; ii++ )
    {
	/*** <pds-12/13/89> Multiply by 2 in case of 16-bit font ***/

      if ( field->FIfield.nc )
       {
	 len = 2 * field->FIfield.nc;
       }
      else
       {
	 len = strlen ( (char *)field->FIfield.defaults[ii].line );
       }

      _FI_fld_add_to_line ( field, ii, len + 2 );

#if defined(hp9000)
      strncpy ( (char *) field->FIfield.buffer[ii].line,
		(char *) field->FIfield.defaults[ii].line, len + 1 );
#else
      strncpy ( field->FIfield.buffer[ii].line,
		field->FIfield.defaults[ii].line, len + 1 );
#endif

      field->FIfield.buffer[ii].line[len]= (unsigned char) NULL;
      field->FIfield.buffer[ii].sel = field->FIfield.defaults[ii].sel;

      if ( field->FIfield.buffer[ii].sel & 1 )
	{
	  if (( field->FIfield.mode == FI_SINGLE_SELECT) &&
		( field->FIfield.prev_sel >= 0 ) )  /* JAJ 5/21/90 */
	    {
	      field->FIfield.buffer[field->FIfield.prev_sel].sel = 0;
	    }

	 field->FIfield.prev_sel = ii;

	 if ( field->FIfield.flags.roll_thru )
	   {
	     field->FIfield.ar   = ii;
	     field->FIfield.roff = ii;
	   }
	}
    }
}


/*====================================================================*/

void _FI_fld_reset (struct FIfld_obj *field)
{
	/*** Send a zero for the reset_column flag because	***/
	/*** all the columns will get reset by the MCF gadget.	***/

  _FI_fld_set_buffer ( field, 0, 0 );

  field->FIgadget.value     = field->FIgadget.default_value;
  field->FIgadget.attr_mask = field->FIgadget.default_attr_mask;

  _FI_fld_reset_buffer ( field );

  if (	field->FIfield.vscrl_id			&&
	field->FIfield.flags.draw_vscrl 	&&
	( field->FIfield.flags.is_a_list == 0 )  )
    {
      _FI_g_reset ( (struct FIgadget_obj *)field->FIfield.vscrl_id );
    }

  if ( field->FIfield.hscrl )
    {
      _FI_g_reset ( (struct FIgadget_obj *)field->FIfield.hscrl[0] );
      _FI_g_reset ( (struct FIgadget_obj *)field->FIfield.hscrl[1] );
    }

  if ( field->FIfield.list_id )
    {
      _FI_g_reset ( (struct FIgadget_obj *)field->FIfield.list_id );
    }

  if ( ! field->FIfield.flags.is_a_col )
    {
      _FI_g_display ( (struct FIgadget_obj *) field, XWINDOW( field ));
    }
}


/*====================================================================*/

void _FI_fld_set_vscrl (struct FIfld_obj *field)
{
  double value, view;

  if ( field->FIfield.vscrl_id )
    {
      if ( field->FIfield.buffer_size > field->FIfield.nvr )
	{
	  view = ((double) field->FIfield.nvr ) /
			((double) field->FIfield.buffer_size );
	}
      else
	{
	  view = 1.0;
	}

      if ( field->FIfield.vscrl_id->FIscroll.view != view )
	{
	  field->FIfield.vscrl_id->FIgadget.value	= -1;
	  field->FIfield.vscrl_id->FIscroll.view	= view;
	}

      value = (double) field->FIfield.roff;

      if ( field->FIfield.buffer_size > field->FIfield.nvr )
        {
	  field->FIfield.vscrl_id->FIrange.high_value = (double)
		( field->FIfield.buffer_size - field->FIfield.nvr );
        }

      _FI_scrl_set_value ( field->FIfield.vscrl_id, value );
    }
}


/*====================================================================*/

void _FI_fld_load (struct FIfld_obj  *field,
                   int                form_version)
{
  int	status = FI_SUCCESS;
  int	ii, size, list_flag;
  char *d;
  int	field_flags;
  char widest_str[10];


  field->FIfield.field_type	= _FI_read_short ();
  field->FIfield.mode		= _FI_read_short ();
  field->FIfield.nr		= _FI_read_short ();
  field->FIfield.nvr		= _FI_read_short ();
  field->FIfield.nc		= _FI_read_short ();
  field->FIfield.nvc		= _FI_read_short ();
  size				= _FI_read_short ();

  _FI_fld_set_defaults ( field, size );

  field->FIfield.min		= _FI_read_double ();
  field->FIfield.max		= _FI_read_double ();
  field->FIgadget.justification = _FI_read_char ();

  field->FIfield.fmt		= _FI_reada_string ();
  field->FIfield.prev_sel	= -1;

  for ( ii = 0; ii < field->FIfield.default_size; ii++ )
    {
      size = _FI_read_strlen ();

      field->FIfield.defaults[ii].line = (unsigned char *)
			calloc ( size + 1, sizeof (unsigned char) );

      _FI_read_string ( size, (char *)field->FIfield.defaults[ii].line );

      field->FIfield.defaults[ii].sel = _FI_read_short ( );
    }

  _FI_fld_reset_buffer ( field );	/* set to default values */

  d = (char *) &field->FIfield.flags;

  /**   *d = _FI_read_int ( );**/

  field_flags = _FI_read_int ( );

  if ( field_flags & FI_FIELD_UDS )
    {
      field->FIfield.flags.uds = 1;
    }
  else
    {
      field->FIfield.flags.uds = 0;
    }

  if ( field_flags & FI_FIELD_LRS )
    {
      field->FIfield.flags.lrs = 1;
    }
  else
    {
      field->FIfield.flags.lrs = 0;
    }

  if ( field_flags & FI_FIELD_ROLL_THRU )
    {
      field->FIfield.flags.roll_thru = 1;
    }
  else
    {
      field->FIfield.flags.roll_thru = 0;
    }

  if ( field_flags & FI_FIELD_WRAP )
    {
      field->FIfield.flags.wrap = 1;
    }
  else
    {
      field->FIfield.flags.wrap = 0;
    }

  if ( field_flags & FI_FIELD_DRAW_VSCRL )
    {
      field->FIfield.flags.draw_vscrl = 1;
    }
  else
    {
      field->FIfield.flags.draw_vscrl = 0;
    }

  if ( field_flags & FI_FIELD_DRAW_HSCRL )
    {
      field->FIfield.flags.draw_hscrl = 1;
    }
  else
    {
      field->FIfield.flags.draw_hscrl = 0;
    }

  if ( field_flags & FI_FIELD_CLEAR )
    {
      field->FIfield.flags.clear = 1;
    }
  else
    {
      field->FIfield.flags.clear = 0;
    }

  if ( field_flags & FI_FIELD_NO_ECHO )
    {
      field->FIfield.flags.no_echo = 1;
    }
  else
    {
      field->FIfield.flags.no_echo = 0;
    }

  if ( field_flags & FI_FIELD_BY_LINE )
    {
      field->FIfield.flags.by_line = 1;
    }
  else
    {
      field->FIfield.flags.by_line = 0;
    }

  if ( field_flags & FI_FIELD_ASCII_ONLY )
    {
      field->FIfield.flags.ascii_only = 1;
    }
  else
    {
      field->FIfield.flags.ascii_only = 0;
    }

  if ( field_flags & FI_FIELD_IS_A_LIST )
    {
      field->FIfield.flags.is_a_list = 1;
    }
  else
    {
      field->FIfield.flags.is_a_list = 0;
    }

  if ( field_flags & FI_FIELD_POPUP_LIST )
    {
      field->FIfield.flags.popup_list = 1;
    }
  else
    {
      field->FIfield.flags.popup_list = 0;
    }

  if ( field_flags & FI_FIELD_DISMISS )
    {
      field->FIfield.flags.dismiss = 1;
    }
  else
    {
      field->FIfield.flags.dismiss = 0;
    }

  if ( field_flags & FI_FIELD_VALID_LIST )
    {
      field->FIfield.flags.valid_list = 1;
    }
  else
    {
      field->FIfield.flags.valid_list = 0;
    }

  if ( field_flags & FI_FIELD_IS_A_COL )
    {
      field->FIfield.flags.is_a_col = 1;
    }
  else
    {
      field->FIfield.flags.is_a_col = 0;
    }

  if ( field_flags & FI_FIELD_REQUIRED )
    {
      field->FIfield.flags.required = 1;
    }
  else
    {
      field->FIfield.flags.required = 0;
    }

  if ( field_flags & FI_FIELD_RIGHT_TO_LEFT )
    {
      field->FIfield.flags.right_to_left = 1;
    }
  else
    {
      field->FIfield.flags.right_to_left = 0;
    }

  if ( field_flags & FI_FIELD_REVERSE_INPUT )
    {
      field->FIfield.flags.reverse_input = 1;
    }
  else
    {
      field->FIfield.flags.reverse_input = 0;
    }

  if ( field_flags & FI_FIELD_REVERSE_OUTPUT )
    {
      field->FIfield.flags.reverse_output = 1;
    }
  else
    {
      field->FIfield.flags.reverse_output = 0;
    }


  /*************************
     _FI_read_bytes ( 4, d );
  ****************************/

  list_flag = _FI_read_char ( );

  if ( list_flag )
    {
      int	type;
      int	label;
      short	version;

      type = (int) _FI_read_short ( );

      if ( type != FI_END_OF_FILE )
	{
	  version = _FI_read_short ( );

	  if ( form_version >= 5 )	/* JAJ 9/29/90 */
	    {
	      label = _FI_read_int ( );
	    }
	  else
	    {
	      label = (int) _FI_read_short ( );
	    }

	  if ( ! _FI_g_new ( field->FIgadget.form, type, label,
					(struct FIgadget_obj **)&field->FIfield.list_id ) )
	    {
	      _FI_g_load ( (struct FIgadget_obj *)field->FIfield.list_id, form_version,
							    version );

	      field->FIfield.list_id->FIgadget.user_pointer =
							(char *) field;

	      if ( ! field->FIfield.flags.popup_list )
		{
		  field->FIfield.list_id->FIgadget.attr_mask &=
						     ~ FI_NOT_DISPLAYED;
		}

		/*** REMOVE NEXT LINE WHEN ALL LISTS HAVE BEEN	***/
		/*** THROUGH THE FORM BUILDER			***/

	      field->FIfield.list_id->FIfield.flags.by_line = 1;

		/*** REMOVE PREVIOUS LINE WHEN ALL LISTS HAVE	***/
		/*** BEEN THROUGH THE FORM BUILDER		***/
	    }
	}
    }

  /*************************************************************/
  /*                                                           */
  /* Adjust the size of the gadget so that it will be able to  */
  /* display the same number of rows and columns, even if a    */
  /* different font is substituted for the one that was        */
  /* originally defined for the form.  GMD 3/26/91             */
  /*                                                           */
  /*************************************************************/

  status = FI_find_font_id ( field->FIgadget.fontname, 
                            (double)field->FIgadget.bodysize, 
                            (Font *)&field->FIgadget.font_id, 
                            (float *)&field->FIgadget.font_height, 
                            field->FIgadget.type, 
                            &field->FIgadget.font_type );

  if ( status == FI_SUCCESS )
  {

/************
	if (field->FIgadget.font_type == 2)
 	{
	  widest_str[0] = widest_wchar;
	  widest_str[1] = widest_wchar >> 8;
	  widest_str[2] = '\0';
	  widest_str[3] = '\0';
    }
    else
    {
	  widest_str[0] = widest_char;
	  widest_str[1] = '\0';
	}
***************/

	  /*sml:08-11-92 use widest characters here */

	  status = _FI_widest_char(field->FIgadget.font_type, widest_str);
      FI_calc_text ( field->FIgadget.font_id, /*"M"*/ widest_str, 1, 
                   &field->FIgadget.font_height, 
                   &field->FIgadget.font_width, 
                   &field->FIfield.line_height, 
                   field->FIgadget.font_type );
  
	  /* sml:08-13-92	instead of resetting field width, reset nvc */
	  if (field->FIgadget.xhi < field->FIgadget.xlo +
                (float)( field->FIgadget.font_width * field->FIfield.nvc))
	  {
		field->FIfield.nvc = (field->FIgadget.xhi - field->FIgadget.xlo)
								/ field->FIgadget.font_width;
		/* make field horizontally scrollable if it wasn't */
		if (field->FIfield.flags.lrs != 1)
		{
  	      field->FIfield.flags.lrs = 1;
 	  	  field->FIfield.flags.wrap = 0;
	      field->FIfield.nc = 0;

 	      if ( ! field->FIfield.hscrl )
		  {
		   _FI_fld_add_hscrl ( field );
		  }
		}
	  }
/************
      field->FIgadget.xhi = field->FIgadget.xlo +
                           (float)( field->FIgadget.font_width *
                                   field->FIfield.nvc);
************/

/******************************************************************
  sml:08-04-93 don't add this to the size of the gadget

      if ( field->FIfield.list_id || field->FIfield.flags.roll_thru )
	{
          field->FIgadget.xhi +=
		(float)(ROLL_THROUGH_SYM_WIDTH + FIELD_BEZEL);
	}
*******************************************************************/
     field->FIgadget.yhi = field->FIgadget.ylo +
                           (float)( field->FIfield.line_height *
                                   field->FIfield.nvr );
    }
}



/*====================================================================*/

void _FI_fld_delete (struct FIfld_obj *field)
{
  int ii;

  if ( field->FIfield.buffer )
    {
      for ( ii = 0; ii < field->FIfield.buffer_size; ii++ )
	{
	  if ( field->FIfield.buffer[ii].line )
	    {
	      _FI_s_free ( (char *) field->FIfield.buffer[ii].line );

		/*** field->FIfield.buffer[ii].line = 0;    ***/
		/***   Don't need to set these to 0, since  ***/
		/***   we're free-ing the "buffer" ptr      ***/
	    }
	}
      _FI_s_free ( (char *) field->FIfield.buffer );

      field->FIfield.buffer = 0;
      field->FIfield.buffer_size = 0;
      field->FIfield.alloc_size = 0;
    }

  if ( field->FIfield.defaults )
    {
      for (ii = 0; ii < field->FIfield.default_size; ii++)
	{
	  if ( field->FIfield.defaults[ii].line )
	    {
	      _FI_s_free ( (char *) field->FIfield.defaults[ii].line );
		/*** field->FIfield.defaults[ii].line = 0;  ***/
		/***   Don't need to set these to 0, since  ***/
		/***   we're free-ing the "defaults" ptr    ***/
	    }
	}
      _FI_s_free ( (char *) field->FIfield.defaults );
      field->FIfield.defaults = 0;
    }

  if ( field->FIfield.fmt )
    {
      _FI_s_free ( field->FIfield.fmt );
      field->FIfield.fmt = 0;
    }

  if ( field->FIfield.list_id )
    {
      _FI_g_delete ( (struct FIgadget_obj *)field->FIfield.list_id, TRUE );
      field->FIfield.list_id = 0;
    }

  if ( field->FIfield.vscrl_id )
    {
      _FI_g_delete ( (struct FIgadget_obj *)field->FIfield.vscrl_id, TRUE );
      field->FIfield.vscrl_id = 0;
    }

  if ( field->FIfield.hscrl )
    {
      _FI_g_delete ( (struct FIgadget_obj *)field->FIfield.hscrl[0], TRUE );
      _FI_g_delete ( (struct FIgadget_obj *)field->FIfield.hscrl[1], TRUE );
      free ( field->FIfield.hscrl );

      field->FIfield.hscrl = 0;
    }

}  /*** _FI_fld_delete ( ) ***/


/*====================================================================*/

/* dmb:10/10/92:Change floats to doubles for ANSI */
int _FI_fld_adjust (struct FIfld_obj  *field,
                    double             delta_x,
                    double             delta_y)
{
	/* adjust the cordinates */

  /* dmb:10/10/92:Added casts for ANSI */
  field->FIgadget.xlo = (float) ((double)field->FIgadget.xlo * delta_x);
  field->FIgadget.ylo = (float) ((double)field->FIgadget.ylo * delta_y);
  field->FIgadget.xhi = (float) ((double)field->FIgadget.xhi * delta_x);
  field->FIgadget.yhi = (float) ((double)field->FIgadget.yhi * delta_y);

	/* adjust the font */

  _FI_fld_change_text ( field, delta_x, delta_y );

	/* check list */

  if ( field->FIfield.list_id )
    {
      _FI_g_adjust_size ( (struct FIgadget_obj *)field->FIfield.list_id, delta_x, delta_y );
    }

	/* check scroll bar */

  if ( field->FIfield.vscrl_id )
    {
      _FI_g_adjust_size ( (struct FIgadget_obj *)field->FIfield.vscrl_id, delta_x, delta_y );
      _FI_fld_set_vscrl ( field );
    }

  if ( field->FIfield.hscrl )
    {
      _FI_g_adjust_size ( (struct FIgadget_obj *)field->FIfield.hscrl[0], delta_x, delta_y );
      _FI_g_adjust_size ( (struct FIgadget_obj *)field->FIfield.hscrl[1], delta_x, delta_y );
    }

  if ( field->FIfield.flags.wrap == 1 )
    {
      _FI_fld_reshuffle_lines ( field, 0 );
    }

  return ( FI_SUCCESS );
}



/*ARGSUSED*/
int FI_define_widest_wchar(short ch)
{
/*  char *chPtr = (char *) &widest_wchar; */

/*  chinese
		chPtr[0] = 161;
		chPtr[1] = 176;

		widest_wchar = 0xb091;
*/

  /* sml:10-30-92	swap the bytes here */
  _FI_widest_wcharacter = ((ch >> 8) & 0x00FF) | (ch << 8);

  return(FI_SUCCESS);
}


int FI_define_widest_char(char ch)
{
  _FI_widest_character = ch; 

/*  widest_char = 'M'; */
  return(FI_SUCCESS);
}

int _FI_widest_char(int font_type, char *str)
{
	  if (font_type == 2)
	  {

		str[0] = _FI_widest_wcharacter;
		str[1] = _FI_widest_wcharacter >> 8;
		str[2] = '\0';
		str[3] = '\0';
	  }
	  else
	  {
		str[0] = _FI_widest_character;
		str[1] = '\0';
	  }
  return(FI_SUCCESS);
}
