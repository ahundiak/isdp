#include "FImin.h"

#include "FIbtn.h"
#include "FIscroll.h"
#include "FIfield.h"
#include "FImcf.h"
#include "FIseq.h"
#include "FIread.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"

void _FI_mcf_set_color (struct FImcf_obj  *mcf,
                        int                color,
                        int                on_color_flag)
{
  if ( on_color_flag )
    {
      mcf->FIgadget.on_color = color;

      _FI_grp_pass_on_id_int_always ( (struct FIgadget_obj *) mcf,
					FIg_set_on_color, color, 0 );
    }
  else
    {
      mcf->FIgadget.off_color = color;

      _FI_grp_pass_on_id_int_always ( (struct FIgadget_obj *) mcf,
					FIg_set_off_color, color, 0 );
    }
}

/*=========================================== <pds-2/27/90> ==========*/

void _FI_mcf_set_erase_color (struct FImcf_obj  *mcf,
                              int                erase_color)
{
  mcf->FIgadget.erase_color = erase_color;

  if ( mcf->FImcf.vscrl_id )
    {
      /**
      _FI_scrl_set_erase_color ( mcf->FImcf.vscrl_id, erase_color );
      **/

      mcf->FImcf.vscrl_id->FIgadget.erase_color = erase_color;
    }

  if ( mcf->FImcf.hscrl_id )
    {
      /**
      _FI_scrl_set_erase_color ( mcf->FImcf.hscrl_id, erase_color );
      **/

      mcf->FImcf.hscrl_id->FIgadget.erase_color = erase_color;
    }

  _FI_grp_pass_on_id_int_always ( (struct FIgadget_obj *) mcf,
			_FI_fld_set_erase_color, erase_color, 0 );
}


/*====================================================================*/
/* Function is called from fldpi.c */

int FImcf_get_active_col (Form  form,
                          int   label,
                          int  *col,
                          int  *pos)
{
  struct FImcf_obj *mcfield;

  mcfield = (struct FImcf_obj *) _FI_g_get_id ( (struct FIform_obj *)
						 form, label );
  if ( ! mcfield )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  if ( mcfield->FIgadget.type != FI_MULTI_COL )
    {
      return ( FI_INVALID_GADGET_TYPE );
    }

  *col = mcfield->FIgroup.current_active_gadget;
  *pos = mcfield->FIgroup.current_active_gadget -
					 mcfield->FImcf.col_off;

  if (( *pos < 0 ) || ( *pos >= (int)mcfield->FImcf.nvcol ))
    {
      *col = mcfield->FImcf.col_off;
      *pos = 0;
    }

  return ( FI_SUCCESS );
}


/*====================================================================*/
/* Function is called from fldpi.c */

int FImcf_set_active_col (Form  form,
                          int   label,
                          int   col,
                          int   pos)
{
  struct FImcf_obj *mcfield;
  int old_col_off;
  int scroll_link;
  int min_valid_pos;  /* sml:12-03-93 added */


  mcfield = (struct FImcf_obj *) _FI_g_get_id ( (struct FIform_obj *)
						 form, label );
  if ( ! mcfield )
    {
      return ( FI_NO_SUCH_GADGET );
    }

  if ( mcfield->FIgadget.type != FI_MULTI_COL )
    {
      return ( FI_INVALID_GADGET_TYPE );
    }

	/* Make sure col and pos are valid */

  if ( ( col < 0 ) || ( col >= (int)mcfield->FImcf.ncol ) || ( pos < 0 )
	|| ( pos >=  (int) mcfield->FImcf.nvcol /*mcfield->FImcf.ncol*/))
                              /* use nvcol for position in view */
                              /* sml:12-03-93 */
    {
      return ( FI_ILLEGAL_VALUES );
    }

  mcfield->FIgroup.current_active_gadget = col;
  old_col_off = mcfield->FImcf.col_off;

  /******************************************************/
  /* sml:12-02-93 NO TR                                 */
  /*  Verify that the pos passed in is valid for the    */
  /*  desired column                                    */
  /******************************************************/

  if (pos > col)  /* The pos can't be greater than the col */
  {
	pos = col;
  }
  else         /* verify the minimum valid position for this column */
  {
	min_valid_pos = col - (mcfield->FImcf.ncol - mcfield->FImcf.nvcol);
	if (min_valid_pos < 0)
	{
	  min_valid_pos = 0;
	}
	if (pos < min_valid_pos)
	{
	  pos = min_valid_pos;
	}
  }

  mcfield->FImcf.col_off = col - pos;

  if ( old_col_off != mcfield->FImcf.col_off )
    {
	/************************************************/
	/* If the MCF gadget is linked to a Header MCF, */
	/* then scroll that gadget as well.		*/
	/************************************************/

      scroll_link = mcfield->FIgadget.off_color2 +
			( mcfield->FIgadget.on_color2 * 256 );

      if ( scroll_link != 0 )
	{
	  FImcf_set_active_col ( (Form) mcfield->FIgadget.form,
		scroll_link, (int) mcfield->FImcf.col_off, 0 );
	}

     /* OLD *******************************************************
     FIg_erase ( mcfield->FIgadget.form, mcfield->FIgadget.label );

     if ( IT_IS_DISPLAYABLE ( mcfield ))
     FIg_display ( mcfield->FIgadget.form, mcfield->FIgadget.label );
     **************************************************************/

     /* NEW Chunn 1-5-90  **************

     _FI_g_erase ( mcfield );

     if ( IT_IS_DISPLAYABLE ( mcfield ))
     _FI_g_display ( mcfield );
     ***********************************/

    }

  return ( FI_SUCCESS );
}

/*====================================================================*/

int _FI_mcf_find_gadget (struct FImcf_obj      *mcfield,
                         int                    xpos,
                         int                    ypos,
                         struct FIgadget_obj  **search_gadget)
{
  int xx;

	/**********************************************/
	/*** Check for row-selection buttons first. ***/
	/**********************************************/

  if (	( xpos  >=  mcfield->FIgadget.xlo )		&&
	( xpos  <=  mcfield->FIgadget.xlo + 8 )		&&
	( ypos  >=  mcfield->FIgadget.ylo )		&&
	( ypos  <=  mcfield->FIgadget.yhi )		&&
	( mcfield->FImcf.flags.no_row_buttons == 0 )	&&
	IT_IS_DISPLAYABLE ( mcfield )			&&
	! IT_IS_DISABLED ( mcfield )			 )
    {
      *search_gadget = (struct FIgadget_obj *) mcfield;

      return ( TRUE );
    }

  if ( _FI_generic_find_gadget ( (struct FIgadget_obj *) mcfield,
						 xpos, ypos )	)
    {
      for ( xx = mcfield->FImcf.col_off;
	     xx < (int)(mcfield->FImcf.col_off + mcfield->FImcf.nvcol); xx++ )
	{
	  if ( mcfield->FIgroup.gadgets[xx] &&
		 _FI_generic_find_gadget ( (struct FIgadget_obj *)mcfield->FIgroup.gadgets[xx],
							 xpos, ypos ))
	    {
	      *search_gadget = (struct FIgadget_obj *) mcfield;
	      return ( TRUE );
	    }
	}
    }
  else if (  mcfield->FImcf.vscrl_id &&
	_FI_generic_find_gadget ( (struct FIgadget_obj *)mcfield->FImcf.vscrl_id, xpos, ypos ))
    {
      *search_gadget = (struct FIgadget_obj *) mcfield->FImcf.vscrl_id;

      return ( TRUE );
    }
  else if (  mcfield->FImcf.hscrl_id &&
	_FI_generic_find_gadget ( (struct FIgadget_obj *)mcfield->FImcf.hscrl_id, xpos, ypos ))
    {
      *search_gadget = (struct FIgadget_obj *) mcfield->FImcf.hscrl_id;

      return ( TRUE );
    }
  else
    {
      struct FIfld_obj *field;

      for ( xx = mcfield->FImcf.col_off;
	  xx < (int)( mcfield->FImcf.col_off + mcfield->FImcf.nvcol ); xx++ )
	{
	  field = (struct FIfld_obj *) mcfield->FIgroup.gadgets[xx];

	  if ( field->FIfield.flags.draw_hscrl && field->FIfield.hscrl )
	    {
	      if ( _FI_generic_find_gadget ( (struct FIgadget_obj *)
				field->FIfield.hscrl[0], xpos, ypos ))
		{
		  *search_gadget = (struct FIgadget_obj *)
						field->FIfield.hscrl[0];
		  return ( TRUE );
		}

	      if ( _FI_generic_find_gadget ( (struct FIgadget_obj *)
				field->FIfield.hscrl[1], xpos, ypos ))
		{
		  *search_gadget = (struct FIgadget_obj *)
					 field->FIfield.hscrl[1];
		  return ( TRUE );
		}
	    }
	}
    }

  return ( FALSE );
}


/*====================================================================*/

void _FI_mcf_hilite (struct FImcf_obj *mcfield)
{
  int			  xx;
  struct FIfld_obj	* field;
  Window		  window = XWINDOW ( mcfield );
  struct FIscrl_obj	* vscrl_id = mcfield->FImcf.vscrl_id;
  struct FIscrl_obj	* hscrl_id = mcfield->FImcf.hscrl_id;


  mcfield->FIgadget.attr_mask |= FI_HILITED;

  if ( IT_IS_DISPLAYABLE ( mcfield ) )
    {
      if ( window != None )
	{
	  _FI_g_display ( (struct FIgadget_obj *) mcfield, window );
	}

      _FI_grp_pass_on_id_int_always ( (struct FIgadget_obj *) mcfield,
						_FI_g_hilite, 0, 0 );

      if ( vscrl_id  &&  mcfield->FImcf.flags.draw_vscrl )
	{
	  _FI_g_hilite ( (struct FIgadget_obj *)vscrl_id );
	}

				/*** JAJ:11/14/91 ***/
				/*** vvvvvvvvvvvv ***/
      if ( hscrl_id  &&  mcfield->FImcf.flags.draw_hscrl )
	{
	  _FI_g_hilite ( (struct FIgadget_obj *)hscrl_id );
	}

      for ( xx = mcfield->FImcf.col_off;
	  xx < (int)( mcfield->FImcf.col_off + mcfield->FImcf.nvcol ); xx++ )
	{
	  field = (struct FIfld_obj *) mcfield->FIgroup.gadgets[xx];

	  if ( field->FIfield.flags.draw_hscrl && field->FIfield.hscrl )
	    {
	      _FI_g_hilite ( (struct FIgadget_obj *)field->FIfield.hscrl[0]);
	      _FI_g_hilite ( (struct FIgadget_obj *)field->FIfield.hscrl[1]);
	    }
	}
    }
  else
    {
			/*** JAJ:11/14/91 ***/
			/*** vvvvvvvvvvvv ***/
      if ( vscrl_id /*** && mcfield->FImcf.flags.draw_vscrl ***/ )
	{
	  vscrl_id->FIgadget.attr_mask |= FI_HILITED;
	  vscrl_id->FIgadget.attr_mask |= FI_HILITED;
	  vscrl_id->FIscroll.puck->FIgadget.attr_mask |= FI_HILITED;

	  for ( xx = 0; xx < 4; xx++ )
	    {
               vscrl_id->FIscroll.btns[xx]->
				FIgadget.attr_mask |= FI_HILITED;
	    }
	}

      if ( hscrl_id )
	{
	  hscrl_id->FIgadget.attr_mask |= FI_HILITED;
          hscrl_id->FIgadget.attr_mask |= FI_HILITED;
          hscrl_id->FIscroll.puck->FIgadget.attr_mask |= FI_HILITED;

	  for ( xx = 0; xx < 4; xx++ )
	    {
              hscrl_id->FIscroll.btns[xx]->
				FIgadget.attr_mask |= FI_HILITED;
	    }
	}

      for ( xx = mcfield->FImcf.col_off;
          xx < (int)( mcfield->FImcf.col_off + mcfield->FImcf.nvcol ); xx++ )
	{
	  field = (struct FIfld_obj * ) mcfield->FIgroup.gadgets[xx];
	  field->FIgadget.attr_mask |= FI_HILITED;           

			/*** JAJ:11/14/91 ***/
			/*** vvvvvvvvvvvv ***/
	  if ( /*** field->FIfield.flags.draw_hscrl && **/
					 field->FIfield.hscrl )
	    {
              field->FIfield.hscrl[0]->FIgadget.attr_mask |= FI_HILITED;
              field->FIfield.hscrl[1]->FIgadget.attr_mask |= FI_HILITED;
	    }
	}
    }
}


/*====================================================================*/

void _FI_mcf_unhilite (struct FImcf_obj *mcfield)
{
  int			  xx;
  struct FIfld_obj	* field;
  Window		  window = XWINDOW ( mcfield );
  struct FIscrl_obj	* vscrl_id = mcfield->FImcf.vscrl_id;
  struct FIscrl_obj	* hscrl_id = mcfield->FImcf.hscrl_id;


  mcfield->FIgadget.attr_mask &= ~ FI_HILITED;

  if ( IT_IS_DISPLAYABLE ( mcfield ) )
    {
      if ( window != None )
	{
	  _FI_g_display ( (struct FIgadget_obj *) mcfield, window );
	}

      _FI_grp_pass_on_id_int_always ( (struct FIgadget_obj *) mcfield,
						 _FI_g_unhilite, 0, 0 );

      if ( vscrl_id && mcfield->FImcf.flags.draw_vscrl )
	{
	  _FI_g_unhilite ( (struct FIgadget_obj *)vscrl_id );
	}
				/*** JAJ:11/14/91 ***/
				/*** vvvvvvvvvvvv ***/
      if ( hscrl_id  &&  mcfield->FImcf.flags.draw_hscrl )
	{
	  _FI_g_unhilite ( (struct FIgadget_obj *)hscrl_id );
	}

      for ( xx = mcfield->FImcf.col_off ;
	  xx < (int)( mcfield->FImcf.col_off + mcfield->FImcf.nvcol ); xx++ )
	{
	  field = (struct FIfld_obj *) mcfield->FIgroup.gadgets[xx];

	  if ( field->FIfield.flags.draw_hscrl && field->FIfield.hscrl )
	    {
	      _FI_g_unhilite ( (struct FIgadget_obj *)field->FIfield.hscrl[0]);
	      _FI_g_unhilite ( (struct FIgadget_obj *)field->FIfield.hscrl[1]);
	    }
	}
    }
  else
    {
			/*** JAJ:11/14/91 ***/
			/*** vvvvvvvvvvvv ***/
      if ( vscrl_id  /**  && mcfield->FImcf.flags.draw_vscrl **/ )
	{
	  vscrl_id->FIgadget.attr_mask &= ~FI_HILITED;
	  vscrl_id->FIgadget.attr_mask &= ~FI_HILITED;
	  vscrl_id->FIscroll.puck->FIgadget.attr_mask &= ~FI_HILITED;

	  for ( xx = 0; xx < 4; xx++ )
	    {
	      vscrl_id->FIscroll.btns[xx]->
				    FIgadget.attr_mask &= ~FI_HILITED;
	    }
	}

      if ( hscrl_id )
	{
	  hscrl_id->FIgadget.attr_mask &= ~FI_HILITED;
	  hscrl_id->FIgadget.attr_mask &= ~FI_HILITED;
	  hscrl_id->FIscroll.puck->FIgadget.attr_mask &= ~FI_HILITED;
	  for ( xx = 0; xx < 4; xx++ )
	    {
	      hscrl_id->FIscroll.btns[xx]->
				FIgadget.attr_mask &= ~FI_HILITED;
	    }
	}

      for ( xx = mcfield->FImcf.col_off;
          xx < (int)( mcfield->FImcf.col_off + mcfield->FImcf.nvcol ); xx++ )
	{
	  field = (struct FIfld_obj * ) mcfield->FIgroup.gadgets[xx];
	  field->FIgadget.attr_mask &= ~FI_HILITED;           

			/*** JAJ:11/14/91 ***/
			/*** vvvvvvvvvvvv ***/
	  if ( /** field->FIfield.flags.draw_hscrl && **/
						field->FIfield.hscrl )
	    {
	     field->FIfield.hscrl[0]->FIgadget.attr_mask &= ~FI_HILITED;
	     field->FIfield.hscrl[1]->FIgadget.attr_mask &= ~FI_HILITED;
	    }
	}
    }
}

/*====================================================================*/

void _FI_mcf_disable (struct FImcf_obj *mcfield)
{
  int			  xx;
  struct FIfld_obj	* field;
  Window		  window = XWINDOW ( mcfield );
  struct FIscrl_obj	* vscrl_id = mcfield->FImcf.vscrl_id;
  struct FIscrl_obj	* hscrl_id = mcfield->FImcf.hscrl_id;


  mcfield->FIgadget.attr_mask |= FI_NOT_ENABLED;

  if ( IT_IS_DISPLAYABLE ( mcfield ) )
    {
      if ( window != None )
	{
          _FI_g_display ( (struct FIgadget_obj *) mcfield, window );
	}

      _FI_grp_pass_on_id_int_always ( (struct FIgadget_obj *) mcfield,
						_FI_g_disable, 0, 0 );

      if ( vscrl_id && mcfield->FImcf.flags.draw_vscrl )
	{
          _FI_g_disable ( (struct FIgadget_obj *)vscrl_id );
          mcfield->FImcf.flags.disable_vscrl = 1;
	}

      if ( hscrl_id && mcfield->FImcf.flags.draw_hscrl )
	{
	  _FI_g_disable ( (struct FIgadget_obj *)hscrl_id );
	  mcfield->FImcf.flags.disable_hscrl = 1;
	}

      for ( xx = mcfield->FImcf.col_off;
	  xx < (int)( mcfield->FImcf.col_off + mcfield->FImcf.nvcol ); xx++ )
	{
	  field = (struct FIfld_obj *) mcfield->FIgroup.gadgets[xx];

	  if ( field->FIfield.flags.draw_hscrl && field->FIfield.hscrl )
	    {
	      _FI_g_disable ( (struct FIgadget_obj *)field->FIfield.hscrl[0]);
	      _FI_g_disable ( (struct FIgadget_obj *)field->FIfield.hscrl[1]);
	    }
	}
    }
  else
    {
			/*** JAJ:11/14/91 ***/
			/*** vvvvvvvvvvvv ***/
      if ( vscrl_id /** && mcfield->FImcf.flags.draw_vscrl **/ )
	{
	  vscrl_id->FIgadget.attr_mask |= FI_NOT_ENABLED;
	  vscrl_id->FIgadget.attr_mask |= FI_NOT_ENABLED;
	  vscrl_id->FIscroll.puck->FIgadget.attr_mask |= FI_NOT_ENABLED;

	  for ( xx = 0; xx < 4; xx++ )
	    {
	      vscrl_id->FIscroll.btns[xx]->
				FIgadget.attr_mask |= FI_NOT_ENABLED;
	    }
	}

      if ( hscrl_id )
	{
	  hscrl_id->FIgadget.attr_mask |= FI_NOT_ENABLED;
	  hscrl_id->FIgadget.attr_mask |= FI_NOT_ENABLED;
	  hscrl_id->FIscroll.puck->FIgadget.attr_mask |= FI_NOT_ENABLED;

	  for ( xx = 0; xx < 4; xx++ )
	    {
              hscrl_id->FIscroll.btns[xx]->
				FIgadget.attr_mask |= FI_NOT_ENABLED;
	    }
	}

      for ( xx = mcfield->FImcf.col_off;
          xx < (int)( mcfield->FImcf.col_off + mcfield->FImcf.nvcol ); xx++ )
	{
	  field = (struct FIfld_obj * ) mcfield->FIgroup.gadgets[xx];

	  field->FIgadget.attr_mask |= FI_NOT_ENABLED;           

			/*** JAJ:11/14/91 ***/
			/*** vvvvvvvvvvvv ***/
	  if ( /** field->FIfield.flags.draw_hscrl && **/
						field->FIfield.hscrl )
	    {
          field->FIfield.hscrl[0]->FIgadget.attr_mask |= FI_NOT_ENABLED;
          field->FIfield.hscrl[1]->FIgadget.attr_mask |= FI_NOT_ENABLED;
	    }
	}
    }
}


/*====================================================================*/

void _FI_mcf_enable (struct FImcf_obj *mcfield)
{
  int			  xx;
  struct FIfld_obj	* field;
  Window		  window = XWINDOW ( mcfield );
  struct FIscrl_obj	* vscrl_id = mcfield->FImcf.vscrl_id;
  struct FIscrl_obj	* hscrl_id = mcfield->FImcf.hscrl_id;


  mcfield->FIgadget.attr_mask &= ~ FI_NOT_ENABLED;

  if ( IT_IS_DISPLAYABLE ( mcfield ) )
    {
      if ( window != None )
	{
	  _FI_g_display ( (struct FIgadget_obj *) mcfield, window );
	}

      _FI_grp_pass_on_id_int_always ( (struct FIgadget_obj *) mcfield,
						 _FI_g_enable, 0, 0 );

      if ( vscrl_id && mcfield->FImcf.flags.draw_vscrl )
	{
	  _FI_g_enable ( (struct FIgadget_obj *)vscrl_id );
	  mcfield->FImcf.flags.disable_vscrl = 0;
	}

      if ( hscrl_id  && mcfield->FImcf.flags.draw_hscrl )
	{
	  _FI_g_enable ( (struct FIgadget_obj *)hscrl_id );
	  mcfield->FImcf.flags.disable_hscrl = 0;
	}

      for ( xx = mcfield->FImcf.col_off;
	  xx < (int)( mcfield->FImcf.col_off + mcfield->FImcf.nvcol ); xx++ )
	{
	  field = (struct FIfld_obj *) mcfield->FIgroup.gadgets[xx];

	  if ( field->FIfield.flags.draw_hscrl && field->FIfield.hscrl )
	    {
	      _FI_g_enable ( (struct FIgadget_obj *)field->FIfield.hscrl[0]);
	      _FI_g_enable ( (struct FIgadget_obj *)field->FIfield.hscrl[1]);
	    }
	}
    }
  else
    {
			/*** JAJ:11/14/91 ***/
			/*** vvvvvvvvvvvv ***/
      if ( vscrl_id  /*** && mcfield->FImcf.flags.draw_vscrl ***/ )
	{
	  vscrl_id->FIgadget.attr_mask &= ~FI_NOT_ENABLED;
          vscrl_id->FIgadget.attr_mask &= ~FI_NOT_ENABLED;
         vscrl_id->FIscroll.puck->FIgadget.attr_mask &= ~FI_NOT_ENABLED;

	  for ( xx = 0; xx < 4; xx++ )
	    {
	      vscrl_id->FIscroll.btns[xx]->
				FIgadget.attr_mask &= ~FI_NOT_ENABLED;
	    }
	}

      if ( hscrl_id )
	{
	  hscrl_id->FIgadget.attr_mask &= ~FI_NOT_ENABLED;
          hscrl_id->FIgadget.attr_mask &= ~FI_NOT_ENABLED;
         hscrl_id->FIscroll.puck->FIgadget.attr_mask &= ~FI_NOT_ENABLED;

	  for ( xx = 0; xx < 4; xx++ )
	    {
	      hscrl_id->FIscroll.btns[xx]->
				FIgadget.attr_mask &= ~FI_NOT_ENABLED;
	    }
	}

      for ( xx = mcfield->FImcf.col_off;
          xx < (int)( mcfield->FImcf.col_off + mcfield->FImcf.nvcol ); xx++ )
	{
	  field = (struct FIfld_obj * ) mcfield->FIgroup.gadgets[xx];
	  field->FIgadget.attr_mask &= ~FI_NOT_ENABLED;           

			/*** JAJ:11/14/91 ***/
			/*** vvvvvvvvvvvv ***/
	  if ( /** field->FIfield.flags.draw_hscrl &&  **/
						field->FIfield.hscrl )
	    {
	      field->FIfield.hscrl[0]->FIgadget.attr_mask &=
						 ~FI_NOT_ENABLED;

	      field->FIfield.hscrl[1]->FIgadget.attr_mask &=
						 ~FI_NOT_ENABLED;
	    }
	}
    }
}

/*====================================================================*/

void _FI_mcf_load (struct FImcf_obj  *mcfield,
                   int                form_version)
{
  int			 ii, count, type;
  short			 version;
  int			 label;
  /*** Gadget		 gadget; dmb:04/15/91:exp ***/
  struct FIgadget_obj	*gadget;
  struct FIfld_obj	*field;
  int			 mcf_flags;


  mcfield->FIgroup.dont_pass_on		 = _FI_read_char ();
  mcfield->FIgroup.single_select	 = _FI_read_char ();
  mcfield->FIgroup.current_active_gadget = 0;
  mcfield->FIgroup.last_active_gadget	 = 0;

  count = _FI_read_int ();

  _FI_grp_alloc ( (struct FIgroup_obj *)mcfield, count );

  for ( ii = 0; ii < (int)mcfield->FIgroup.size; ii++ )
    {
      type = (int) _FI_read_short ();

      if ( type != FI_END_OF_FILE )
	{
	  version = _FI_read_short ();
	  if ( form_version >= 5 )	/*** JAJ:09/29/90 ***/
	    {
		label = _FI_read_int ();
	    }
	  else
	    {
		label = (int) _FI_read_short ();
	    }

	  if ( ! _FI_g_new ( mcfield->FIgadget.form, type, label,
							 &gadget ) )
	    {
	      _FI_g_load ( gadget, form_version, version );

	      _FI_g_add_to_group ( gadget, mcfield->FIgadget.label, 0 );
	    }
	}
      else
	{
	  return;
        }

     /***********************************************************/
     /* The header mcf was saved in column 0's FIgadget data	*/
     /* so retrieve it and store it in FImcf.FIgadget now.	*/
     /***********************************************************/

      if ( ii == 0 )
	{
          field = (struct FIfld_obj *) mcfield->FIgroup.gadgets[0];
          mcfield->FIgadget.off_color2 = field->FIgadget.off_color2;
          mcfield->FIgadget.on_color2 = field->FIgadget.on_color2;
	}
    }

  mcfield->FImcf.ncol	 = _FI_read_short ();
  mcfield->FImcf.nvcol	 = _FI_read_short ();
  mcfield->FImcf.col_off = _FI_read_short ();

  /* CHUNN old ***********************************************
  mcfield->FIgadget.effect = mcfield->FImcf.col_off % 256;
  mcfield->FIgadget.filler3 = mcfield->FImcf.col_off / 256;
  ************************************************************/

	/* Use this to hold col_off */

  mcfield->FIgadget.sym_width_scale_factor = mcfield->FImcf.col_off;

  /***********************************************
    d = ( int *) &mcfield->FImcf.flags;
    *d = _FI_read_int ();
  ************************************************/

  mcf_flags = _FI_read_int ();

  if ( mcf_flags & FI_MCF_UDS )
    {
      mcfield->FImcf.flags.uds = 1;
    }
  else
    {
      mcfield->FImcf.flags.uds = 0;
    }

  if ( mcf_flags & FI_MCF_LRS )
    {
      mcfield->FImcf.flags.lrs = 1;
    }
  else
    {
      mcfield->FImcf.flags.lrs = 0;
    }

  if ( mcf_flags & FI_MCF_DRAW_VSCRL )
    {
      mcfield->FImcf.flags.draw_vscrl = 1;
    }
  else
    {
      mcfield->FImcf.flags.draw_vscrl = 0;
    }

  if ( mcf_flags & FI_MCF_DRAW_HSCRL )
    {
      mcfield->FImcf.flags.draw_hscrl = 1;
    }
  else
    {
      mcfield->FImcf.flags.draw_hscrl = 0;
    }

  if ( mcf_flags & FI_MCF_DISABLE_VSCRL )
    {
      mcfield->FImcf.flags.disable_vscrl = 1;
    }
  else
    {
      mcfield->FImcf.flags.disable_vscrl = 0;
    }

  if ( mcf_flags & FI_MCF_DISABLE_HSCRL )
    {
      mcfield->FImcf.flags.disable_hscrl = 1;
    }
  else
    {
      mcfield->FImcf.flags.disable_hscrl = 0;
    }

  if ( mcf_flags & FI_MCF_ROW_SELECT )
    {
      mcfield->FImcf.flags.row_select = 1;
    }
  else
    {
      mcfield->FImcf.flags.row_select = 0;
    }

  if ( mcf_flags & FI_MCF_NO_ROW_BUTTONS )
    {
      mcfield->FImcf.flags.no_row_buttons = 1;
    }
  else
    {
      mcfield->FImcf.flags.no_row_buttons = 0;
    }

	/* Use the size of column 0 in the Y axis to determine	*/
	/* the vertical size of the MCF.   GMD 4/4/91           */

  mcfield->FIgadget.yhi = mcfield->FIgadget.ylo +
        ( gadget->FIgadget.yhi - gadget->FIgadget.ylo ) + 4.0;
}


/*====================================================================*/

int _FI_mcf_activate (struct FImcf_obj *mcfield)
{

  _FI_grp_pass_on_id_int_always ( (struct FIgadget_obj *) mcfield,
						_FI_g_activate, 0, 0 );
  if ( mcfield->FImcf.nvcol )
    {
      _FI_mcf_adjust_xhi ( mcfield );
    }

  _FI_mcf_adjust_cols ( mcfield );

  if ( mcfield->FImcf.flags.uds )
    {
      if ( ! mcfield->FImcf.vscrl_id )
	{
	   _FI_mcf_add_vscrl ( mcfield );
	}

      _FI_g_activate ( (struct FIgadget_obj *)mcfield->FImcf.vscrl_id );

      _FI_mcf_set_vscrl ( mcfield );
    }

  if ( mcfield->FImcf.flags.lrs )
    {
      if ( ! mcfield->FImcf.hscrl_id )
	{
	  _FI_mcf_add_hscrl ( mcfield );
	}

      _FI_g_activate ( (struct FIgadget_obj *)mcfield->FImcf.hscrl_id );

      _FI_mcf_set_hscrl ( mcfield );
    }

  return ( FI_SUCCESS );
}

/*====================================================================*/

void _FI_mcf_adjust_xhi (struct FImcf_obj *mcfield)
{
  int	ii;
  struct FIfld_obj *field;

  mcfield->FIgadget.xhi = mcfield->FIgadget.xlo + 10;
  for ( ii = 0; ii < (int)mcfield->FImcf.nvcol; ii++ )
    {
      field = (struct FIfld_obj *)
		mcfield->FIgroup.gadgets[ii + mcfield->FImcf.col_off];

      mcfield->FIgadget.xhi += ( field->FIgadget.xhi -
					field->FIgadget.xlo ) + 4 ;
    }

  _FI_generic_move_hort ( (struct FIgadget_obj *)mcfield->FImcf.vscrl_id,
					 (int) mcfield->FIgadget.xhi );
  if ( mcfield->FImcf.hscrl_id )
    {
      mcfield->FImcf.hscrl_id->FIgadget.xhi = mcfield->FIgadget.xhi;

      _FI_g_adjust_size ( (struct FIgadget_obj *)mcfield->FImcf.hscrl_id, 1.0, 1.0 );
    }
}


/**********************************************************************/
/* _FI_mcf_adjust_cols ()					      */
/* During an activate message, setting the active column, sequencing  */
/* into a legal column, or using a button on the horizontal scroll    */
/* bar, the columns shown in the view area of the MCF need to be      */
/* changed. This is the function that accomplishes that task.	      */
/**********************************************************************/

void _FI_mcf_adjust_cols (struct FImcf_obj *mcfield)
{
  int ii;
  struct FIfld_obj *field;

  for ( ii = 0; ii < (int)mcfield->FImcf.col_off ; ii++ )
    {
       mcfield->FIgroup.gadgets[ii]->FIgadget.attr_mask |=
						     FI_NOT_DISPLAYED;
    }

  field = (struct FIfld_obj *)
		    mcfield->FIgroup.gadgets[mcfield->FImcf.col_off];

  field->FIgadget.xlo = mcfield->FIgadget.xlo + 12;

  field->FIgadget.xhi = field->FIgadget.xlo +
		( field->FIgadget.font_width * field->FIfield.nvc );

	/************************************************/
	/* sml:10-17-94:I/FORMS TR 249406874            */
	/*  If the column is wider than the MCF, reset  */
	/*  the column's xhi and nvc.                   */
	/************************************************/

  if (field->FIgadget.xhi > mcfield->FIgadget.xhi)
  {
	field->FIgadget.xhi = mcfield->FIgadget.xhi - 4;

	field->FIfield.nvc = 
	  (int)(
			(field->FIgadget.xhi - field->FIgadget.xlo) / 
		 	field->FIgadget.font_width);
  }

  if ( field->FIfield.list_id || field->FIfield.flags.roll_thru )
    {
      field->FIgadget.xhi += ROLL_THROUGH_SYM_WIDTH + FIELD_BEZEL;
    }

  /*****************************************************************/
  /* Since the position of the column has changed on the screen,   */
  /* the position of the column's horizontal scroll buttons need   */
  /* to change as well.  This case only handles the first column.  */
  /*								   */
  /* Only do these steps if horizontal scrolling is enabled for    */
  /* the column.						   */
  /*****************************************************************/

  if ( field->FIfield.flags.draw_hscrl  &&  field->FIfield.hscrl )
    {
      field->FIfield.hscrl[0]->FIgadget.xlo = field->FIgadget.xlo;
      field->FIfield.hscrl[0]->FIgadget.xhi = field->FIgadget.xlo +
		(( field->FIgadget.xhi - field->FIgadget.xlo ) / 2 );

      field->FIfield.hscrl[1]->FIgadget.xlo =
			field->FIfield.hscrl[0]->FIgadget.xhi + 1;

      field->FIfield.hscrl[1]->FIgadget.xhi = field->FIgadget.xhi;
    }

  field->FIgadget.attr_mask &= ~ FI_NOT_DISPLAYED;

  mcfield->FImcf.nvcol = 1;

  ii = mcfield->FImcf.col_off + 1;

  while ( ( field->FIgadget.xhi + 4 < ( mcfield->FIgadget.xhi ) )    &&
	  ( ii < (int)mcfield->FImcf.ncol )				      )
    {
      field = (struct FIfld_obj *) mcfield->FIgroup.gadgets[ii];

      field->FIgadget.xlo =
		 mcfield->FIgroup.gadgets[ii - 1]->FIgadget.xhi + 4;

      field->FIgadget.xhi = field->FIgadget.xlo +
		 ( field->FIgadget.font_width * field->FIfield.nvc );

      if ( field->FIgadget.xhi <  mcfield->FIgadget.xhi  )
	{
	  field->FIgadget.attr_mask &= ~ FI_NOT_DISPLAYED;
	  mcfield->FImcf.nvcol++;

        /*************************************************************/
        /* Since the position of the column has changed on the       */
        /* screen, the position of the column's horizontal scroll    */
        /* buttons need to change as well. This case only handles    */
        /* the second and later columns that will be displayed       */
        /* in the mcf.						     */
        /*							     */
        /* Only do these steps if horizontal scrolling is enabled    */
        /* for the column.					     */
        /*************************************************************/

	  if ( field->FIfield.flags.draw_hscrl && field->FIfield.hscrl )
	    {
	      field->FIfield.hscrl[0]->FIgadget.xlo =
						 field->FIgadget.xlo;

	      field->FIfield.hscrl[0]->FIgadget.xhi =
				 field->FIgadget.xlo +
		  (( field->FIgadget.xhi - field->FIgadget.xlo ) / 2 );

	      field->FIfield.hscrl[1]->FIgadget.xlo =
			     field->FIfield.hscrl[0]->FIgadget.xhi + 1;

	      field->FIfield.hscrl[1]->FIgadget.xhi =
						field->FIgadget.xhi;
	    }
	}
      else
        {
	  field->FIgadget.attr_mask |= FI_NOT_DISPLAYED;
        }
      ii++;
    }

    /**************************************************************/
    /* sml:TR 249401934:Vertical scroll bar too far away from MCF */
    /*  When calling FIg_display, extra text in the MCF fields    */
    /*  is taken out, but the xhi of the MCF and its vertical     */
    /*  scroll bar wasn't being changed.  This code does that.    */
    /**************************************************************/
    if (ii == mcfield->FImcf.nvcol && mcfield->FImcf.vscrl_id &&
	(field->FIgadget.xhi + 4 < mcfield->FIgadget.xhi))
    {
      struct FIgadget_obj * scroll = 
		(struct FIgadget_obj *)mcfield->FImcf.vscrl_id;
      int xlo = scroll->FIgadget.xlo;
      int xhi = scroll->FIgadget.xhi;

      mcfield->FIgadget.xhi = field->FIgadget.xhi + 4; 
      scroll->FIgadget.xlo = field->FIgadget.xhi + 4; 
      scroll->FIgadget.xhi = field->FIgadget.xhi + 4 + (xhi - xlo + 1) ; 
    }
    /* end of fix for TR 249401934 */

 while ( ii < (int)mcfield->FImcf.ncol )
    {
      mcfield->FIgroup.gadgets[ii++]->FIgadget.attr_mask |=
						 FI_NOT_DISPLAYED;
    }
}


/*====================================================================*/

int _FI_mcf_display (struct FImcf_obj  *mcfield,
                     Window             window)
{
  int			Xscreen = XSCREEN ( mcfield );
  int			ylo, yhi;
  unsigned long		t_l_color, b_r_color, edge_color, face_color;
  struct FIfld_obj     *field;

	/********************************************************/
	/* This code draws the row selection buttons,		*/
	/* so skip this if they are turned off. GMD 3/20/90	*/
	/********************************************************/

  if ( mcfield->FImcf.flags.no_row_buttons == 0 )  /* GMD 3/20/90 */
    {
      field = (struct FIfld_obj *) mcfield->FIgroup.gadgets[0];

      face_color = FI_translate_color ( Xscreen, FI_FACE );

      if ( IT_IS_HILITED ( mcfield ))
	{
          edge_color = FI_translate_color ( Xscreen, FI_GLINT );
	}
      else
	{
          edge_color = FI_translate_color ( Xscreen, FI_EDGE );
	}

      if ( IT_IS_DISABLED ( mcfield ))
	{
	  t_l_color = face_color;
	  b_r_color = t_l_color;
	}
      else
	{
	  t_l_color = FI_translate_color ( Xscreen, FI_GLINT );
	  b_r_color = FI_translate_color ( Xscreen, FI_SHADOW );
	}

      ylo = (int) mcfield->FIgadget.ylo;
      yhi = ylo + field->FIfield.line_height + 2;

      while ( ( ylo < (int) mcfield->FIgadget.yhi )	&&
		field->FIfield.line_height 		 )
	{
	  if ( yhi >= ( (int) mcfield->FIgadget.yhi - 2 ) )
	    {
		yhi = mcfield->FIgadget.yhi;
	    }

	  _FI_draw_bezel ( window, (int) mcfield->FIgadget.xlo, ylo,
				(int) mcfield->FIgadget.xlo + 10, yhi,
				MCF_BEZEL_WIDTH, t_l_color, face_color,
				b_r_color, edge_color, SQUARE );

	  ylo = yhi;
	  yhi += field->FIfield.line_height;
	}
    }

  _FI_grp_pass_on_id_int_always ( (struct FIgadget_obj *) mcfield,
					 _FI_g_display, window, 0 );

  if ( mcfield->FImcf.vscrl_id && mcfield->FImcf.flags.draw_vscrl )
    {
      _FI_mcf_set_vscrl ( mcfield );

      mcfield->FImcf.vscrl_id->FIgadget.attr_mask &= ~ FI_NOT_DISPLAYED;

      _FI_scrl_display ( mcfield->FImcf.vscrl_id, window );

      mcfield->FImcf.vscrl_id->FIgadget.displayed = TRUE;
    }

  if ( mcfield->FImcf.hscrl_id && mcfield->FImcf.flags.draw_hscrl )
    {
      _FI_mcf_set_hscrl ( mcfield );

      mcfield->FImcf.hscrl_id->FIgadget.attr_mask &= ~ FI_NOT_DISPLAYED;

      _FI_scrl_display ( mcfield->FImcf.hscrl_id, window );

      mcfield->FImcf.hscrl_id->FIgadget.displayed = TRUE;
    }

  return ( FI_SUCCESS );
}


/*====================================================================*/

void _FI_mcf_set_active_row (struct FImcf_obj  *mcfield,
                             struct FIfld_obj  *field)
{
  int		ii, row, roff, old_roff;
  Window	window;
  struct FIfld_obj *gadget;


  row = field->FIfield.ar;
  roff = field->FIfield.roff;
  window = XWINDOW ( field );

  for ( ii = 0; ii < (int)mcfield->FImcf.ncol; ii++ )
    {
      if ( field != (struct FIfld_obj *) mcfield->FIgroup.gadgets[ii])
	{
	  gadget = (struct FIfld_obj *) mcfield->FIgroup.gadgets[ii];

	  old_roff = gadget->FIfield.roff;
	  gadget->FIfield.ar = row;
	  gadget->FIfield.roff = roff;

	  if ( ( old_roff != roff ) && ( window != None ) )
	    {
		_FI_fld_refresh_data ( gadget, window );
 	    }
	}
    }
}


/*====================================================================*/

int _FI_mcf_erase (struct FImcf_obj  *mcfield,
                   Window             window)
{
  extern int _FI_mcf_break_navigation;

  if ( mcfield->FImcf.flags.no_row_buttons == 0 )
    {
      _FI_generic_erase ( (struct FIgadget_obj *)mcfield, window );
    }
  else	/*** Erase row selection buttons ***/
    {
      if ( ! ( IT_IS_NOT_DISPLAYABLE ( mcfield ) ) )
	{
	  XFillRectangle ( _FI_display, window, _FI_gc,
		(int) mcfield->FIgadget.xlo + 10,
		(int) mcfield->FIgadget.ylo,
		(int) ( mcfield->FIgadget.xhi -
				    mcfield->FIgadget.xlo + 1 - 10 ),
		(int) ( mcfield->FIgadget.yhi -
				    mcfield->FIgadget.ylo + 1 - 10 ) );
	}
    }

  _FI_grp_pass_on_id_int_always ( (struct FIgadget_obj *) mcfield,
						 _FI_g_erase, 0, 0 );

  if ( mcfield->FImcf.vscrl_id )
    {
      _FI_g_erase ( (struct FIgadget_obj *) mcfield->FImcf.vscrl_id );
    }

  if ( mcfield->FImcf.hscrl_id )
    {
      _FI_g_erase ( (struct FIgadget_obj *) mcfield->FImcf.hscrl_id );
    }

	/*** Prevent endless loop when MCF is erased inside	***/
	/***  notification of the MCF -- GMD 11/27/90		***/

  _FI_mcf_break_navigation = TRUE;

  return ( FI_SUCCESS );
}


/*====================================================================*/
/* dmb:10/10/92:Change floats to doubles for ANSI */
int _FI_mcf_adjust (struct FImcf_obj  *mcfield,
                    double             delta_x,
                    double             delta_y)
{
  /* adjust the cordinates */

  /* dmb:10/10/92:Added casts for ANSI */
  mcfield->FIgadget.xlo = (float)((double)mcfield->FIgadget.xlo * delta_x);
  mcfield->FIgadget.ylo = (float)((double)mcfield->FIgadget.ylo * delta_y);
  mcfield->FIgadget.xhi = (float)((double)mcfield->FIgadget.xhi * delta_x);
  mcfield->FIgadget.yhi = (float)((double)mcfield->FIgadget.yhi * delta_y);

  /* dmb:10/10/92:Changed fron pass_on_*float to pass_on_*_double for ANSI */
  _FI_grp_pass_on_id_double_always ( (struct FIgadget_obj *) mcfield,
				(int (*)())_FI_g_adjust_size, delta_x, delta_y );

	/* check scroll bar */

  if ( mcfield->FImcf.vscrl_id )
    {
      _FI_g_adjust_size ( (struct FIgadget_obj *)mcfield->FImcf.vscrl_id, delta_x, delta_y );
      _FI_mcf_set_vscrl ( mcfield );
    }

  if ( mcfield->FImcf.hscrl_id )
    {
      _FI_g_adjust_size ( (struct FIgadget_obj *)mcfield->FImcf.hscrl_id, delta_x, delta_y );
      _FI_mcf_set_hscrl ( mcfield );
    }

  return ( FI_SUCCESS );
}
