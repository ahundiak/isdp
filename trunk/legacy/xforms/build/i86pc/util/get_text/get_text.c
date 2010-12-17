/************************************
		
			main.c

*************************************/

/*
  History
	06-18-92	sml		added -f flag to get text for fields and
						  mcf's ONLY; use global fields_only flag
*/

#include <FImin.h>
#include <FIform.h>
#include <FIgadget.h>
#include <FIfield.h>
#include <FImcf.h>
#include <FItext.h>
#include <FItog.h>
#include <FImacros.h>
#include <stdio.h>
#include <sys/types.h>
#include <time.h>

#include "getsetdef.h"

#include "XFIproto_pub.h"
#include "XFIproto_pri.h"
#include "XFUproto_pri.h"

extern int fields_only;		/* sml:06-18-92 global flag */


/* dmb:10/15/92:Changed char * gadget_text to unsigned char for ANSI */
static void _FI_breakup_output_text (FILE * outfp,
                                     char * text_word,
                                     int	 column,
                                     unsigned char * gadget_text)
{
  unsigned char * ch;
  int	 ii;
  int	 done;


  ch = gadget_text;

  for ( ii = 0, done = 0 ; ! done  ; ii++ )
    {
      if ( column != -1 )
	{
          fprintf ( outfp, "%s[%d,%d]=", text_word, ii, column );
	}
      else
	{
          fprintf ( outfp, "%s[%d]=", text_word, ii );
	}

      for ( ; *ch ; ch++ )
	{
	  if ( *ch != '\n' )
	    {
              fprintf ( outfp, "%c", *ch );
	    }
	  else
	    {
              fprintf ( outfp, "\n" );
	      ch++ ;
	      break;
	    }
	}

      if ( ! *ch )
	{
	  done = 1;
          fprintf ( outfp, "\n" );
	}
    }
}



static void _FI_fill_in_just_str (int just,
                                  char ** just_str)
{
  switch ( just )
    {
      case FI_LEFT_JUSTIFIED:
	*just_str = "FI_LEFT_JUSTIFIED";
	break;

      case FI_RIGHT_JUSTIFIED:
	*just_str = "FI_RIGHT_JUSTIFIED";
	break;

      case FI_CENTER_JUSTIFIED:
	*just_str = "FI_CENTER_JUSTIFIED";
	break;

      case FI_FITTED:
	*just_str = "FI_FITTED";
	break;

      default:
	*just_str = "UNKNOWN";
	break;
    }
}



static void _FI_fill_in_style (int style,
                               char ** style_str)
{
  switch ( style )
    {
      case FI_NORMAL_TEXT:
	*style_str = "FI_NORMAL_TEXT";
	break;

      case FI_EMBOSSED:
	*style_str = "FI_EMBOSSED";
	break;

      case FI_INCISED:
	*style_str = "FI_INCISED";
	break;

      case FI_SHADOWED:
	*style_str = "FI_SHADOWED";
	break;

      default:
	*style_str = "UNKNOWN";
	break;
    }
}



int _FI_g_output_text (struct FIgadget_obj * gadget,
                       FILE                * outfp)
{
  int		     ii,jj;
  int     	     type = gadget->FIgadget.type;
  char		   * temp_string;
  struct FIfld_obj * temp_field;
  struct FIfld_obj * temp_assoc_list;
  struct FImcf_obj * temp_mcf;
  struct FItog_obj * temp_toggle;


  switch ( type )
    {
      case FI_GROUP:
	_FI_grp_pass_on_id_int_always ( gadget, _FI_g_output_text,
					(int) outfp, 0 );
	break;

      case FI_BEZEL:
      case FI_DIAL:
      case FI_GAUGE:
      case FI_LINE:
      case FI_RECT:
      case FI_SCROLL:
      case FI_SLIDER:
      case FI_SYM:
      default:
	break;

      case FI_FIELD:

 	temp_field = (struct FIfld_obj *) gadget;

		/*******************************/
		/*** IGNORE non-ALPHA fields ***/
		/*******************************/
	if ( type == FI_FIELD )
	  {
	    if ( temp_field->FIfield.field_type != FI_ALPHA )
	      break;
	  }

	fprintf ( outfp, "LABEL=%d\n", temp_field->FIgadget.label );

	fprintf ( outfp, "TYPE=FI_FIELD\n" );

	fprintf ( outfp, "pos=%d,%d\n", (int) temp_field->FIgadget.xlo,
				       (int) temp_field->FIgadget.ylo );

	fprintf ( outfp, "font=%s\n", temp_field->FIgadget.fontname );
	fprintf ( outfp, "fontsize=%d\n",
			(short) (temp_field->FIgadget.bodysize + 0.5) );

	_FI_fill_in_just_str ( temp_field->FIgadget.justification,
						     & temp_string );
	fprintf ( outfp, "just=%s\n", temp_string );

	if ( temp_field->FIfield.flags.right_to_left )
	  {
	    fprintf ( outfp, "field_attr=FI_RIGHT_TO_LEFT" );

	    if ( temp_field->FIfield.flags.reverse_input )
	      {
	        fprintf ( outfp, "|FI_REVERSE_INPUT" );
	      }

	    if ( temp_field->FIfield.flags.reverse_output )
	      {
	        fprintf ( outfp, "|FI_REVERSE_OUTPUT" );
	      }

	    fprintf ( outfp, "\n" );
	  }
	else
	  {
	    fprintf ( outfp, "field_attr=FI_LEFT_TO_RIGHT\n" );
	  }

  	for ( ii = 0; ii < temp_field->FIfield.default_size; ii++ )
	  {
	    fprintf ( outfp, "text[%d]=%s\n", ii,
			        temp_field->FIfield.defaults[ii].line );
	  }

        if ( temp_field->FIfield.list_id )
	  {
	    temp_assoc_list = temp_field->FIfield.list_id;

	    fprintf ( outfp, "assoc_list_pos=%d,%d\n",
				(int) temp_assoc_list->FIgadget.xlo,
				(int) temp_assoc_list->FIgadget.ylo );

  	    for ( ii=0;
		     ii < temp_assoc_list->FIfield.default_size; ii++ )
	      {
	        fprintf ( outfp, "assoc_list_text[%d]=%s\n", ii,
			   temp_assoc_list->FIfield.defaults[ii].line );
	      }
          }

	fprintf ( outfp, "#\n" );
	break;


      case FI_MULTI_COL:

 	temp_mcf = (struct FImcf_obj *) gadget;

	fprintf ( outfp, "LABEL=%d\n", temp_mcf->FIgadget.label );

	fprintf ( outfp, "TYPE=FI_MULTI_COL\n" );

	fprintf ( outfp, "pos=%d,%d\n", (int) temp_mcf->FIgadget.xlo,
					(int) temp_mcf->FIgadget.ylo );

	fprintf ( outfp, "font=%s\n", temp_mcf->FIgadget.fontname );
	fprintf ( outfp, "fontsize=%d\n",
			(short) (temp_mcf->FIgadget.bodysize + 0.5) );

	for ( ii = 0; ii < (int)temp_mcf->FIgroup.size; ii++ )
	  {
	    temp_field = (struct FIfld_obj *)
					 temp_mcf->FIgroup.gadgets[ii];

	    if ( temp_field->FIgadget.type != FI_FIELD )
	      {
		continue;
	      }

	    if ( temp_field->FIfield.field_type != FI_ALPHA )
	      {
	        fprintf ( outfp, "# ( column %d is numeric )\n", ii );
	        continue;
	      }

	    _FI_fill_in_just_str ( temp_field->FIgadget.justification,
						     & temp_string );
	    fprintf ( outfp, "column_just[%d]=%s\n", ii, temp_string );

	    if ( temp_field->FIfield.flags.right_to_left )
	      {
	        fprintf ( outfp,
			 "column_attr[%d]=FI_RIGHT_TO_LEFT", ii );

	        if ( temp_field->FIfield.flags.reverse_input )
	          {
	            fprintf ( outfp, "|FI_REVERSE_INPUT" );
	          }

	        if ( temp_field->FIfield.flags.reverse_output )
	          {
	            fprintf ( outfp, "|FI_REVERSE_OUTPUT" );
	          }

	        fprintf ( outfp, "\n" );
	      }
	    else
	      {
	        fprintf ( outfp,
			 "column_attr[%d]=FI_LEFT_TO_RIGHT\n", ii );
	      }

  	    for ( jj = 0; jj < temp_field->FIfield.default_size; jj++ )
	      {
	        fprintf ( outfp, "text[%d,%d]=%s\n", jj, ii,
			        temp_field->FIfield.defaults[jj].line );
	      }
	  }

	fprintf ( outfp, "#\n" );

	break;


      case FI_BUTTON:
      case FI_CHECKLIST:
      case FI_TEXT:
      case FI_TOGGLE:

		/* sml:06-18-92 if doing fields only, skip this */
		if (fields_only)
		{
		  break;
		}

		/****************************************************/
		/*** IGNORE gadgets with symbols instead of text  ***/
		/****************************************************/
	if ( ( type == FI_BUTTON )	||
	     ( type == FI_CHECKLIST )	||
	     ( type == FI_TOGGLE    )	 )
	  {
	    if ( ! ( IT_HAS_TEXT (gadget) )  )
	      break;
	  }

	fprintf ( outfp, "LABEL=%d\n", gadget->FIgadget.label );

	_FI_look_fill_in_type ( type, &temp_string );
	fprintf ( outfp, "TYPE=%s\n", temp_string );

	fprintf ( outfp, "pos=%d,%d\n", (int) gadget->FIgadget.xlo,
					(int) gadget->FIgadget.ylo );

	fprintf ( outfp, "font=%s\n", gadget->FIgadget.fontname );
	fprintf ( outfp, "fontsize=%d\n",
			(short) (gadget->FIgadget.bodysize + 0.5) );

	_FI_fill_in_just_str ( gadget->FIgadget.justification,
						     & temp_string );
	fprintf ( outfp, "just=%s\n", temp_string );

	_FI_fill_in_style ( gadget->FIgadget.effect, & temp_string );
	fprintf ( outfp, "style=%s\n", temp_string );

	_FI_breakup_output_text ( outfp, "text", -1,
						gadget->FIgadget.text );

        if ( type == FI_TOGGLE )
	  {
	    temp_toggle = (struct FItog_obj *) gadget;
	    _FI_breakup_output_text ( outfp, "on_text", -1,
					temp_toggle->FItog.on_text );
	  }

	fprintf ( outfp, "#\n" );
	break;
    }
  return (FI_SUCCESS);
}



int FIf_get_text (Form              form_ptr,
                  FILE              * outfp,
                  char              * form_name)
{
  time_t    dummy_time;
  char	  * dummy_char_time;
  int	    status = FI_SUCCESS;
  struct FIform_obj * form = (struct FIform_obj *)form_ptr;

  fprintf ( outfp, "FORM_TEXT_FILE=%s\n", form_name );
  fprintf ( outfp, "FORM_TEXT_VERSION=%d\n", CURRENT_FORM_TEXT_VERSION );

	/**********************************************/
	/*** output the date the text file was made ***/
	/**********************************************/

  dummy_time = time(0);
  dummy_char_time = ctime ( & dummy_time );
  fprintf ( outfp, "# %s", dummy_char_time );
  if ( dummy_char_time[strlen(dummy_char_time)-1] != '\n' )
    {
      fprintf ( outfp, "\n" );
    }

	/******************************************/
	/*** output the copyright notice	***/
	/************************* JAJ:01/25/92 ***/

  fprintf ( outfp,
	"######################################################\n" );
  fprintf ( outfp,
	"# Copyright 1992 Intergraph Corporation\n");
  fprintf ( outfp,
	"# All Rights Reserved, Including Application Programs,\n");
  fprintf ( outfp,
	"# File Formats, and Visual Displays.\n");
  fprintf ( outfp,
	"######################################################\n" );

	/***********************************************************/
	/*** tell every gadget to write its text out to the file ***/
	/***********************************************************/
  _FI_grp_pass_on_id_int_always ((struct FIgadget_obj *)form->group,
                                 _FI_g_output_text, (int)outfp, 0);

  return ( status );
}
