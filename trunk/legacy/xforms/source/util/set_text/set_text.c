
#include <FImin.h>
#include <FIform.h>
#include <FIgadget.h>
#include <FIfield.h>
#include <FImcf.h>
#include <FItext.h>
#include <FItog.h>
#include <FImacros.h>
#include <stdio.h>



#include "getsetdef.h"

#include "XFIproto_pub.h"
#include "XFUproto_pri.h"

extern char * strchr();

#define LINE_SIZE 10000


/**************  global variables **********************/

char	_FI_form_text_file[256];
int	_FI_form_text_version = 0;

static int	num_keywords				= 0;
static int	current_gadget_label			= 0;
static int	current_gadget_type			= 0;
static char	current_gadget_text_pending		= 0;
static char	current_gadget_on_text_pending		= 0;
static char	current_gadget_text[LINE_SIZE]		= "";
static char	current_gadget_on_text[LINE_SIZE]	= "";
static char	current_gadget_font_name[132]		= "";
static float	current_gadget_font_size		= -1.0;
static int	current_gadget_xpos			= 0;
static int	current_gadget_ypos			= 0;
static int	current_gadget_just;
static int	current_gadget_style;
static int	current_gadget_row;
static int	current_gadget_col;
static int	current_field_attr;
static char	fast_forward_to_label			= 0;


static void sure_msg (void)
{
  fprintf ( stderr,
    "\nAre you sure you're replacing the text into the correct form file ?\n\n" );
}



static void skip_msg (void)
{
  fprintf ( stderr,
	"\t-- Skipping forward to next 'LABEL=' entry.\n" );
}


static char * _FI_skip_attr_delimiters (char  * attr)
{
  char	* new_attr = attr;

  for ( ; * new_attr  &&
	( ( *new_attr == '|' ) || isspace ( *new_attr ) );
						new_attr ++  )
    {
    }

  return ( new_attr );
}



static int _FI_is_all_digits (char * string,
                              int  decimal_points_okay,
                              int  commas_okay)
{
  char * ch;

  for ( ch = string; *ch ; ch++ )
    {
      if ( decimal_points_okay && (*ch == '.') )
	continue;

      if ( commas_okay && (*ch == ',') )
	continue;

      if ( ! isdigit(*ch) )
	return 0;
    }

  return 1;
}



static int _FI_field_attr_string_to_int (char * value,
                                         int  * field_attr,
                                         char   error_attr[])
{
  char * temp_ch;
  char	 temp_attr[256];
  int	 ii;


  *field_attr = -1;

	/***********************************/
	/*** skip leading blanks and "|" ***/
	/***********************************/

  temp_ch = _FI_skip_attr_delimiters ( value );


  /***************************************************************
  fprintf ( stderr, "attr = '%s'\n", value );
  fprintf( stderr,"attr (after skip) = '%s'\n", temp_ch );
  ***************************************************************/


  if ( *temp_ch )
    {
      for ( ii = 0 ; ; )
        {
          if ( *temp_ch == '|'  ||  !(*temp_ch) )
	    {
	      temp_attr[ii] = '\0';
	      ii = 0;

	      if ( !strcmp ( temp_attr, "FI_LEFT_TO_RIGHT" ) )
		{
		  * field_attr = FI_LEFT_TO_RIGHT ;
		}
	      else if ( !strcmp ( temp_attr, "FI_RIGHT_TO_LEFT" ) )
		{
		  * field_attr = FI_RIGHT_TO_LEFT ;
		}
	      else if ( !strcmp ( temp_attr, "FI_REVERSE_INPUT" ) )
		{
		  * field_attr |= FI_REVERSE_INPUT ;
		}
	      else if ( !strcmp ( temp_attr, "FI_REVERSE_OUTPUT" ) )
		{
		  * field_attr |= FI_REVERSE_OUTPUT ;
		}
	      else
		{
		  strcpy ( error_attr, temp_attr );
		  return ( FI_INVALID_BUFFER );
		}

              temp_ch = _FI_skip_attr_delimiters ( temp_ch );

	      if ( ! *temp_ch )
		{
		  break;
		}
	    }
          else
	    {
	      temp_attr[ii++] = *temp_ch;
	      temp_ch ++ ;
	    }
	}
    }
  else
    {
      strcpy ( error_attr, value );
      return ( FI_INVALID_BUFFER );
    }

  return ( FI_SUCCESS );
}




#define FI_TEXT_WORD_HAS_NO_LEFT_BRACKET	1
#define FI_TEXT_WORD_HAS_NO_RIGHT_BRACKET	2

static int _FI_extract_row_col_from_text_word (char * text_word,
                                               int  * gadget_row,
                                               int  * gadget_col)
{
  char * ch;
  char * right_bracket;
  char	 temp_row[64];
  char	 temp_col[64];
  int	 status;
  int	 ii;

  * gadget_row = -1;
  * gadget_col = -1;

  ch = strchr ( text_word, '[' );

  if ( ch == NULL )
    {
      return ( FI_TEXT_WORD_HAS_NO_LEFT_BRACKET );
    }

  ch++ ;  /*** advance ptr past '[' ***/

	/*** advance past spaces after ']' ***/
  while (isspace(*ch))
    ch++;

  right_bracket = strrchr ( ch, ']' );

  if ( right_bracket == NULL )
    {
      return ( FI_TEXT_WORD_HAS_NO_RIGHT_BRACKET );
    }

	/*** ignore spaces before final ']' ***/
  while (isspace(*(right_bracket-1)))
    right_bracket--;

	/*** collect the row characters ***/
  for ( ii = 0 ; (*ch) && (ch != right_bracket) && (*ch != ',') ; ch++ )
    {
      temp_row[ii++] = *ch;
    }
  temp_row[ii] = '\0';

	/*** remove trailing blanks ***/
  while ( (ii > 0) && isspace(temp_row[ii-1]))
    {
      temp_row[--ii]='\0';
    }

  status = sscanf ( temp_row, "%d", gadget_row );

	/*** sscanf will succeed on a string like "1x",	***/
	/***   so do some more checking 		***/
  if ( (status != 1) || (!_FI_is_all_digits (temp_row,0,0))  )
    {
      return ( FI_INVALID_ROW );
    }

  if ( *ch == ',' )
    {
	/*** advance past ',' if necessary ***/
      ch ++;

	/*** advance past spaces after ',' ***/
      while (isspace(*ch))
        ch++;


	/*** collect the column characters ***/
      for ( ii = 0 ; (*ch) && (ch != right_bracket) ; ch++ )
        {
          temp_col[ii++] = *ch;
        }
      temp_col[ii] = '\0';

	/*** remove trailing blanks ***/
      while ( (ii > 0) && isspace(temp_col[ii-1]))
        {
          temp_col[--ii]='\0';
        }

      status = sscanf ( temp_col, "%d", gadget_col );

	/*** sscanf will succeed on a string like "1x",	***/
	/***   so do some more checking 		***/
      if ( (status != 1) || (!_FI_is_all_digits (temp_col,0,0))  )
        {
          return ( FI_INVALID_COL );
        }
    }

  return ( FI_SUCCESS );
}



static int _FI_type_string_to_int (char * type_string,
                                   int  * gadget_type)
{
  if ( ! strcmp ( type_string, "FI_BUTTON" ) )
    {
      * gadget_type = FI_BUTTON ;
      return ( FI_SUCCESS );
    }
  else if ( ! strcmp ( type_string, "FI_CHECKLIST" ) )
    {
      * gadget_type = FI_CHECKLIST ;
      return ( FI_SUCCESS );
    }
  else if ( ! strcmp ( type_string, "FI_FIELD" ) )
    {
      * gadget_type = FI_FIELD ;
      return ( FI_SUCCESS );
    }
  else if ( ! strcmp ( type_string, "FI_MULTI_COL" ) )
    {
      * gadget_type = FI_MULTI_COL ;
      return ( FI_SUCCESS );
    }
  else if ( ! strcmp ( type_string, "FI_TEXT" ) )
    {
      * gadget_type = FI_TEXT ;
      return ( FI_SUCCESS );
    }
  else if ( ! strcmp ( type_string, "FI_TOGGLE" ) )
    {
      * gadget_type = FI_TOGGLE ;
      return ( FI_SUCCESS );
    }


	/********************************************************/
	/*** these types shouldn't be in the form's text file ***/
	/********************************************************/

  if ( ! strcmp ( type_string, "FI_BEZEL"	)	||
       ! strcmp ( type_string, "FI_DIAL"	)	||
       ! strcmp ( type_string, "FI_GAUGE"	)	||
       ! strcmp ( type_string, "FI_GROUP"	)	||
       ! strcmp ( type_string, "FI_LINE"	)	||
       ! strcmp ( type_string, "FI_RECT"	)	||
       ! strcmp ( type_string, "FI_SCROLL"	)	||
       ! strcmp ( type_string, "FI_SLIDER"	)	||
       ! strcmp ( type_string, "FI_SYM"		)	 )
    {
      return ( FI_INVALID_GADGET_TYPE );
    }

	/********************************************************/
	/*** some unknown word was specified as a gadget type ***/
	/********************************************************/

  return ( FI_INVALID_BUFFER );
}



static int _FI_just_string_to_int (char * just_string,
                                   int  * gadget_just)
{
  if ( ! strcmp ( just_string, "FI_LEFT_JUSTIFIED" ) )
    {
      * gadget_just = FI_LEFT_JUSTIFIED ;
      return ( FI_SUCCESS );
    }
  else if ( ! strcmp ( just_string, "FI_RIGHT_JUSTIFIED" ) )
    {
      * gadget_just = FI_RIGHT_JUSTIFIED ;
      return ( FI_SUCCESS );
    }
  else if ( ! strcmp ( just_string, "FI_CENTER_JUSTIFIED" ) )
    {
      * gadget_just = FI_CENTER_JUSTIFIED ;
      return ( FI_SUCCESS );
    }
  else if ( ! strcmp ( just_string, "FI_FITTED" ) )
    {
      * gadget_just = FI_FITTED ;
      return ( FI_SUCCESS );
    }

	/*************************************************************/
	/*** some unknown word was given as a gadget justification ***/
	/*************************************************************/

  return ( FI_INVALID_BUFFER );
}



static int _FI_style_string_to_int (char * style_string,
                                    int  * gadget_style)
{
  if ( ! strcmp ( style_string, "FI_NORMAL_TEXT" ) )
    {
      * gadget_style = FI_NORMAL_TEXT ;
      return ( FI_SUCCESS );
    }
  else if ( ! strcmp ( style_string, "FI_EMBOSSED" ) )
    {
      * gadget_style = FI_EMBOSSED ;
      return ( FI_SUCCESS );
    }
  else if ( ! strcmp ( style_string, "FI_INCISED" ) )
    {
      * gadget_style = FI_INCISED ;
      return ( FI_SUCCESS );
    }
  else if ( ! strcmp ( style_string, "FI_SHADOWED" ) )
    {
      * gadget_style = FI_SHADOWED ;
      return ( FI_SUCCESS );
    }

	/*************************************************************/
	/*** some unknown word was given as a gadget text style    ***/
	/*************************************************************/

  return ( FI_INVALID_BUFFER );
}



static void _FI_skip_comments_blanks (FILE  * infp,
                                      int   * line_num)
{
  char	ch = 0;
  char	temp_line[LINE_SIZE];

  for ( ; !feof(infp) ; )
    {
	/**********************************************************/
	/*** skip whitespace up to the first non-whitespace	***/
	/***   character on the line 				***/
	/**********************************************************/
      for ( ch = fgetc ( infp ) ;
		(!feof(infp)) && ( isspace(ch) || ( ch == '\n' ) ) ;
			  	ch = fgetc ( infp )	)
        {
          if ( ch == '\n' )
	    {
	      (*line_num)++;
	    }
        }

      if ( ch == '#' )
	{
          fgets ( temp_line, LINE_SIZE - 1, infp );
	  (*line_num)++;
	}
      else
	{
	  break;
	}
    }

  if ( ! feof(infp) )
    {
      ungetc ( ch, infp );
    }

}


static int _FI_retrieve_keyword_value (char input_line[],
                                       char keyword[],
                                       char value[],
                                       char *input_text_file,
                                       int  line_num)
{
  int	new_line_index;
  int	ii,jj;


	/*** if there's no '=' on the line, it's an error ***/
  if ( ! strchr ( input_line, '=' ) )
    {
      fprintf ( stderr,
	"\nFATAL ERROR:  Line %d of input text file '%s' has no '=' character:\n  %s\n",
		line_num, input_text_file, input_line );
      return ( FI_SET_TEXT_ERROR );
    }

	/**********************************/
	/*** strip '\n' off end of line ***/
	/**********************************/
  new_line_index = strlen ( input_line ) - 1 ;

  if ( input_line [ new_line_index ] == '\n' )
    {
      input_line [ new_line_index ] = '\0';
    }

  /********************************************************
  printf ( "%4d input_line '%s'\n", line_num, input_line );
  ********************************************************/

	/******************************************/
	/*** get the keyword from the line 	***/
	/***   ( everything up to the '=' )	***/
	/******************************************/
  for ( ii = 0; input_line[ii] ; ii++ )
    {
      if ( input_line[ii] == '=' )
	{
	  keyword[ii] = '\0' ;
	  ii++;
	  break;
	}
      else
	{
	  keyword[ii] = input_line[ii];
	}
    }

	/*********************************************/
	/***  Remove any trailing whitespace from  ***/
	/***  the keyword.			   ***/
	/*******************************************/
  for ( jj = strlen ( keyword ) - 1;
		( jj >= 0 ) &&  ( isspace ( keyword[jj] ) ); jj-- )
    {
      keyword[jj] = '\0' ;
    }

	/******************************************/
	/*** get the value from the line 	***/
	/***   ( everything after '=' )		***/
	/******************************************/
  for ( jj = 0 ; input_line[ii] ; ii++, jj++ )
    {
      value[jj] = input_line[ii];
    }
  value[jj] = '\0';


  return ( FI_SUCCESS );
}



static int _FI_process_keyword_value (struct  FIform_obj * form_ptr,
                                      char  * form_name,
                                      char  keyword[],
                                      char  value[],
                                      char  * text_file_name,
                                      int   line_num)
{
  char	 	temp_form_text_file[256];
  char	 	temp_form_name[256];
  char	      *	temp_type_string;
  char	      * temp_ch;
  char		temp_error_attr[256];
  long		existing_field_attr;
  int		real_type;
  int 		status;


  if ( num_keywords == 0 )
    {
	/*** expect 'keyword' = 'FORM_TEXT_FILE'  ***/

      if ( strcmp ( keyword, "FORM_TEXT_FILE" ) )
	{
	  fprintf ( stderr,
		"\nFATAL ERROR in input text file '%s':\n", text_file_name );
	  fprintf ( stderr,
		"\tFirst keyword in file is '%s' ( line %d );\n",
		keyword, line_num );
	  fprintf ( stderr, "\tshould be 'FORM_TEXT_FILE'.\n" );

	  return ( FI_SET_TEXT_ERROR );
	}

      strcpy ( _FI_form_text_file, value );

	/**********************************************************/
	/*** check specified form_text_file name against name	***/
	/***   of form we're reading ...			***/
	/**********************************************************/
      temp_ch = strrchr ( _FI_form_text_file, '/' );

      if ( temp_ch )
	{
	  strcpy ( temp_form_text_file, temp_ch + 1 );
	}
      else
	{
	  strcpy ( temp_form_text_file, _FI_form_text_file );
	}


      temp_ch = strrchr ( form_name, '/' );

      if ( temp_ch )
	{
	  strcpy ( temp_form_name, temp_ch + 1 );
	}
      else
	{
	  strcpy ( temp_form_name, form_name );
	}

      if ( strcmp ( temp_form_name, temp_form_text_file ) )
	{
	  fprintf ( stderr,
		"\nWARNING:  FORM_TEXT_FILE form name is '%s'; ( line %d ):\n",
		_FI_form_text_file, line_num );
	  fprintf ( stderr,
		"\tForm name specified on command line is '%s'.\n",
		form_name );

	  sure_msg();
	}

    }
  else if ( num_keywords == 1 )
    {
	/*** expect 'keyword' = 'FORM_TEXT_VERSION'  ***/

      if ( strcmp ( keyword, "FORM_TEXT_VERSION" ) )
	{
	  fprintf ( stderr,
		"\nFATAL ERROR in input text file '%s':\n", text_file_name );
	  fprintf ( stderr,
		"\tSecond keyword in file is '%s' ( line %d );\n",
		keyword, line_num );
	  fprintf ( stderr, "\tshould be 'FORM_TEXT_VERSION'.\n" );

	  return ( FI_SET_TEXT_ERROR );
	}

      status = sscanf ( value, "%d", & _FI_form_text_version );

	/*** sscanf will succeed on a string like "1x",	***/
	/***   so do some more checking 		***/
      if ( (status != 1) || (!_FI_is_all_digits (value,0,0))  )
	{
	  fprintf ( stderr,
		"\nFATAL ERROR in input text file '%s', line %d:\n",
		text_file_name, line_num );
	  fprintf ( stderr,
		"\tError converting \"FORM_TEXT_VERSION='%s'\" to integer value.\n",
		value );

	  return ( FI_SET_TEXT_ERROR );
	}


	/**********************************************************/
	/*** Check to make sure we understand this version of	***/
	/***   of the text input file before going on ...	***/
	/**********************************************************/

      if ( _FI_form_text_version != 1 )
	{
	  fprintf ( stderr,
		"\nFATAL ERROR:  Input text file '%s' is version %d;\n",
		text_file_name, _FI_form_text_version );
	  fprintf ( stderr,
		"\tThis version of FIf_set_text can only read\n" );
	  fprintf ( stderr,
		"\tinput text files of version 1.\n" );

	  return ( FI_SET_TEXT_ERROR );
	}
    }
  else	/*** regular keyword ***/
    {
      if ( ! strcmp ( keyword, "LABEL" ) )
	{
	    /********************************************************/
	    /*** first process the text from the previous gadget, ***/
	    /*** if any						  ***/
	    /********************************************************/

		/*** check to see if they've specified		***/
		/*** only one of "font" name or "fontsize"	***/
		/*** and not both.				***/
	  if ( strcmp ( current_gadget_font_name, "" )    &&
	       ( current_gadget_font_size == -1.0    )     )
	    {
	      fprintf ( stderr,
		"\nERROR:  Input text file '%s', before line %d:\n",
		text_file_name, line_num );
	      fprintf ( stderr,
		"Gadget label %d has \"font='%s'\" specified, but no font size specified.\n",
		current_gadget_font_name );

	      skip_msg();

	      fast_forward_to_label = 1;
	    }
	  else if ( ! strcmp ( current_gadget_font_name, "" )  &&
	            ( current_gadget_font_size  > -1.0    )     )
	    {
	      fprintf ( stderr,
		"\nERROR:  Input text file '%s', before line %d:\n",
		text_file_name, line_num );
	      fprintf ( stderr,
		"Gadget label %d has \"font_size=%f\" specified, but no font name specified.\n",
		current_gadget_font_size );

	      skip_msg();

	      fast_forward_to_label = 1;
	    }

		/*** process regular "text" ***/

          if ( current_gadget_text_pending )
	    {
	      status = FIg_set_off_text ( (Form)form_ptr,
			current_gadget_label, current_gadget_text );

              if ( status != FI_SUCCESS )
                {
	          fprintf ( stderr,
	            "\nERROR %d during FIg_set_off_text ( form_ptr = 0x%x,\n",
	            status, form_ptr );
	          fprintf ( stderr,
	            "\t\tgadget_label = %d, text = '%s' ).\n",
	            current_gadget_label, current_gadget_text );

	          skip_msg();

	          fast_forward_to_label = 1;
                }
	      else
		{
	          FIg_activate ( (Form)form_ptr, current_gadget_label );
		}

              current_gadget_text_pending = 0;
	    }

		/*** process ON "text" ***/

          if ( current_gadget_on_text_pending )
	    {
	      status = FIg_set_on_text ( (Form)form_ptr,
			current_gadget_label, current_gadget_on_text );

              if ( status != FI_SUCCESS )
                {
	          fprintf ( stderr,
	            "\nERROR %d during FIg_set_on_text ( form_ptr = 0x%x,\n",
	            status, form_ptr );
	          fprintf ( stderr,
	            "\t\tgadget_label = %d, text = '%s' ).\n",
	            current_gadget_label, current_gadget_on_text );

	          skip_msg();

	          fast_forward_to_label = 1;
                }
	      else
		{
	          FIg_activate ( (Form)form_ptr, current_gadget_label );
		}

              current_gadget_on_text_pending = 0;
	    }


		/*********************************************/
		/*** Begin processing new "LABEL=" keyword ***/
		/*********************************************/

          status = sscanf ( value, "%d", & current_gadget_label );

		/*** sscanf will succeed on a string like "1x",	***/
		/***   so do some more checking 		***/
          if ( (status != 1) || (!_FI_is_all_digits (value,0,0))  )
	    {
	      fprintf ( stderr,
		"\nERROR:  Input text file '%s', line %d:\n",
		text_file_name, line_num );
	      fprintf ( stderr,
		"\tError converting \"LABEL='%s'\" to integer value.\n",
		value );

	      skip_msg();

	      fast_forward_to_label = 1;
	    }
	  else
	    {
              fast_forward_to_label = 0;

			/*** reset temporary variables ***/
	      current_gadget_font_name[0]	= '\0';
	      current_gadget_font_size		= -1.0 ;
	      current_gadget_text[0]		= '\0';
	      current_gadget_on_text[0]		= '\0';
              current_gadget_text_pending	= 0;
              current_gadget_on_text_pending	= 0;

	    }
	}  /*** keyword == "LABEL" ***/
      else if ( fast_forward_to_label )
	{
	  num_keywords ++;
	  return ( FI_SUCCESS );
	}
      else if ( ! strcmp ( keyword, "TYPE" ) )
	{
	  status = _FI_type_string_to_int ( value,
					      & current_gadget_type );

	  if ( status == FI_INVALID_GADGET_TYPE )
	    {
	      fprintf ( stderr,
		"\nERROR:  Input text file '%s', line %d:\n",
		text_file_name, line_num );
	      fprintf ( stderr,
		"\t\"TYPE='%s'\" is of no use in the input text file.\n",
		value );

	      skip_msg();

	      fast_forward_to_label = 1;
	    }
	  else if ( status == FI_INVALID_BUFFER )
	    {
	      fprintf ( stderr,
		"\nERROR:  Input text file '%s', line %d:\n",
		text_file_name, line_num );
	      fprintf ( stderr,
		"\t\"TYPE='%s'\" is an unknown gadget type.\n",
		value );

	      skip_msg();

	      fast_forward_to_label = 1;
	    }

	  status = FIg_get_type ( (Form)form_ptr, current_gadget_label,
							& real_type );
	  if ( status == FI_NO_SUCH_GADGET )
	    {
	      fprintf ( stderr,
		"\nERROR:  Input text file '%s' ( near line %d ):\n",
		text_file_name, line_num );
	      fprintf ( stderr,
		"\tGadget label %d is not a valid gadget label in form '%s'.\n",
		current_gadget_label, form_name );

	      sure_msg();

	      skip_msg();

	      fast_forward_to_label = 1;

	      num_keywords++;

	      return ( FI_SUCCESS );
	    }

	  if ( current_gadget_type != real_type )
	    {
	      fprintf ( stderr,
		"\nERROR:  Input text file '%s' ( line %d ):\n",
		text_file_name, line_num );
	      fprintf ( stderr,
		"\tGadget label %d type is specified as '%s';\n",
		current_gadget_label, value );

	      _FI_look_fill_in_type ( real_type, & temp_type_string );

	      fprintf ( stderr,
		"\tGadget label %d on form '%s' is type '%s';\n",
		current_gadget_label, form_name, temp_type_string );

	      sure_msg();

	      skip_msg();

	      fast_forward_to_label = 1;
	    }
	}  /*** keyword == "TYPE" ***/
      else if ( ! strcmp ( keyword, "font" ) )
	{
	  strcpy ( current_gadget_font_name, value );

	      /*** if the "fontsize" keyword has been seen already ***/
	  if ( current_gadget_font_size > -1.0 )
	    {
	      status = FIg_set_font ( (Form)form_ptr,
			     current_gadget_label,
			     current_gadget_font_name,
			     current_gadget_font_size );

	      if ( status != FI_SUCCESS )
	        {
		  fprintf ( stderr,
		    "\nERROR %d during FIg_set_font ( form_ptr = 0x%x,\n",
		    status, form_ptr );
		  fprintf ( stderr,
		    "\t\tgadget_label = %d, font_name = '%s', font_size = %f\n",
		    current_gadget_label, current_gadget_font_name,
		    current_gadget_font_size );

	          skip_msg();

	          fast_forward_to_label = 1;
	        }
	      else
		{
	          FIg_activate ( (Form)form_ptr, current_gadget_label );
		}
	    }

	}  /*** keyword == "font" ***/
      else if ( ! strcmp ( keyword, "fontsize" ) )
	{
          status = sscanf ( value, "%f", & current_gadget_font_size );

		/*** sscanf will succeed on a string like "1x",	***/
		/***   so do some more checking 		***/
          if ( (status != 1) || (!_FI_is_all_digits (value,1,0))  )
	    {
	      fprintf ( stderr,
		"\nERROR:  Input text file '%s', line %d:\n",
		text_file_name, line_num );
	      fprintf ( stderr,
		"\tError converting \"fontsize='%s'\" to integer value.\n",
		value );

	      skip_msg();

	      fast_forward_to_label = 1;
	    }
	  else
	    {
	      /*** if the "font" keyword has been seen already ***/
	      if ( strcmp ( current_gadget_font_name, "" ) )
	        {
	          status = FIg_set_font ( (Form)form_ptr,
				     current_gadget_label,
				     current_gadget_font_name,
				     current_gadget_font_size );

	          if ( status != FI_SUCCESS )
	            {
		      fprintf ( stderr,
		        "\nERROR %d during FIg_set_font ( form_ptr = 0x%x,\n",
			        status, form_ptr );
		      fprintf ( stderr,
		        "\t\tgadget_label = %d, font_name = '%s', font_size = %f\n",
				current_gadget_label,
				current_gadget_font_name,
				current_gadget_font_size );

	              skip_msg();

	              fast_forward_to_label = 1;
	            }
	          else
		    {
	              FIg_activate ( (Form)form_ptr, current_gadget_label );
		    }
	        }
	    }
	}  /*** keyword == "fontsize" ***/
      else if ( ! strcmp ( keyword, "just" ) )
	{
	  status = _FI_just_string_to_int ( value,
					      & current_gadget_just );

	  if ( status == FI_INVALID_BUFFER )
	    {
	      fprintf ( stderr,
		"\nERROR:  Input text file '%s', line %d:\n",
		text_file_name, line_num );
	      fprintf ( stderr,
		"\t\"just='%s'\" is an unknown gadget justification.\n",
		value );

	      skip_msg();

	      fast_forward_to_label = 1;
	    }
	  else if ( current_gadget_type == FI_MULTI_COL )
	    {
	      fprintf ( stderr,
		    "\nERROR:  Input text file '%s', line %d:\n",
		    text_file_name, line_num );
	      fprintf ( stderr,
		    "\t\"just\" keyword is not valid for FI_MULTI_COL type gadgets.\n" );
	      skip_msg();

	      fast_forward_to_label = 1;
	    }
	  else
	    {
	      status = FIg_set_justification ( (Form)form_ptr,
			current_gadget_label, current_gadget_just );

	      if ( status != FI_SUCCESS )
	        {
		  fprintf ( stderr,
		    "\nERROR %d during FIg_set_justification ( form_ptr = 0x%x,\n",
		    status, form_ptr );
		  fprintf ( stderr,
		    "\t\tgadget_label = %d, just = %d\n",
		    current_gadget_label, current_gadget_just );

	          skip_msg();

	          fast_forward_to_label = 1;
	        }
	      else
		{
	          FIg_activate ( (Form)form_ptr, current_gadget_label );
		}
	    }
	}  /*** keyword == "just" ***/
      else if ( ! strncmp ( keyword, "column_just", 11 ) )
	{
	  status = _FI_extract_row_col_from_text_word ( keyword,
					      & current_gadget_col,
					      & current_gadget_row );

	  if ( status == FI_TEXT_WORD_HAS_NO_LEFT_BRACKET )
	    {
	      fprintf ( stderr,
		"\nERROR:  Input text file '%s', line %d:\n",
		text_file_name, line_num );
	      fprintf ( stderr,
		"\t\"column_just\" keyword has no left bracket: '%s'.\n",
		keyword );

	      skip_msg();

	      fast_forward_to_label = 1;
	    }
	  else if ( status == FI_TEXT_WORD_HAS_NO_RIGHT_BRACKET )
	    {
	      fprintf ( stderr,
		"\nERROR:  Input text file '%s', line %d:\n",
		text_file_name, line_num );
	      fprintf ( stderr,
		"\t\"column_just\" keyword has no right bracket: '%s'.\n",
		keyword );

	      skip_msg();

	      fast_forward_to_label = 1;
	    }
	  else if ( status == FI_INVALID_ROW )
	    {
	      fprintf ( stderr,
		"\nERROR:  Input text file '%s', line %d:\n",
		text_file_name, line_num );
	      fprintf ( stderr,
		"\tError converting row value in \"%s\" to integer value.\n",
		keyword );

	      skip_msg();

	      fast_forward_to_label = 1;
	    }
	  else if ( current_gadget_row  != -1 )
	    {
	      fprintf ( stderr,
		    "\nERROR:  Input text file '%s', line %d:\n",
		    text_file_name, line_num );
	      fprintf ( stderr,
		    "\trow value in \"column_just\" keyword is not valid.\n" );
	      skip_msg();

	      fast_forward_to_label = 1;
	    }
	  else if ( status == FI_INVALID_COL )
	    {
	      fprintf ( stderr,
		"\nERROR:  Input text file '%s', line %d:\n",
		text_file_name, line_num );
	      fprintf ( stderr,
		"\tError converting column value in \"%s\" to integer value.\n",
		keyword );

	      skip_msg();

	      fast_forward_to_label = 1;
	    }

	  status = _FI_just_string_to_int ( value,
					      & current_gadget_just );

	  if ( status == FI_INVALID_BUFFER )
	    {
	      fprintf ( stderr,
		"\nERROR:  Input text file '%s', line %d:\n",
		text_file_name, line_num );
	      fprintf ( stderr,
		"\t\"column_just='%s'\" is an unknown gadget justification.\n",
		value );

	      skip_msg();

	      fast_forward_to_label = 1;
	    }
	  else if ( current_gadget_type != FI_MULTI_COL )
	    {
	      fprintf ( stderr,
		    "\nERROR:  Input text file '%s', line %d:\n",
		    text_file_name, line_num );
	      fprintf ( stderr,
		    "\t\"column_just\" keyword is not valid for non- FI_MULTI_COL field type gadgets.\n" );

	      skip_msg();

	      fast_forward_to_label = 1;
	    }
	  else
	    {
	      status = FImcf_set_justification ( (Form)form_ptr,
			current_gadget_label,
			current_gadget_col,  current_gadget_just );

	      if ( status != FI_SUCCESS )
	        {
		  fprintf ( stderr,
		    "\nERROR %d during FImcf_set_justification ( form_ptr = 0x%x,\n",
		    status, form_ptr );
		  fprintf ( stderr,
		    "\t\tgadget_label = %d, column = %d, just = %d\n",
		    current_gadget_label, current_gadget_col,
		    current_gadget_just );

	          skip_msg();

	          fast_forward_to_label = 1;
	        }
	      else
		{
	          FIg_activate ( (Form)form_ptr, current_gadget_label );
		}
	    }
	}  /*** keyword == "column_just" ***/
      else if ( ! strcmp ( keyword, "style" ) )
	{
	  status = _FI_style_string_to_int ( value,
					      & current_gadget_style );

	  if ( status == FI_INVALID_BUFFER )
	    {
	      fprintf ( stderr,
		"\nERROR:  Input text file '%s', line %d:\n",
		text_file_name, line_num );
	      fprintf ( stderr,
		"\t\"style='%s'\" is an unknown gadget style.\n",
		value );

	      skip_msg();

	      fast_forward_to_label = 1;
	    }
	  else
	    {
	      status = FIg_set_text_style ( (Form)form_ptr,
			current_gadget_label, current_gadget_style );

	      if ( status != FI_SUCCESS )
	        {
		  fprintf ( stderr,
		    "\nERROR %d during FIg_set_text_style ( form_ptr = 0x%x,\n",
		    status, form_ptr );
		  fprintf ( stderr,
		    "\t\tgadget_label = %d, style = %d\n",
		    current_gadget_label, current_gadget_style );

	          skip_msg();

	          fast_forward_to_label = 1;
	        }
	      else
		{
	          FIg_activate ( (Form)form_ptr, current_gadget_label );
		}
	    }
	}  /*** keyword == "style" ***/
      else if ( ! strncmp ( keyword, "text", 4 ) )
	{
	  status = _FI_extract_row_col_from_text_word ( keyword,
					      & current_gadget_row,
					      & current_gadget_col );

	  if ( status == FI_TEXT_WORD_HAS_NO_LEFT_BRACKET )
	    {
	      fprintf ( stderr,
		"\nERROR:  Input text file '%s', line %d:\n",
		text_file_name, line_num );
	      fprintf ( stderr,
		"\t\"text\" keyword has no left bracket: '%s'.\n",
		keyword );

	      skip_msg();

	      fast_forward_to_label = 1;
	    }
	  else if ( status == FI_TEXT_WORD_HAS_NO_RIGHT_BRACKET )
	    {
	      fprintf ( stderr,
		"\nERROR:  Input text file '%s', line %d:\n",
		text_file_name, line_num );
	      fprintf ( stderr,
		"\t\"text\" keyword has no right bracket: '%s'.\n",
		keyword );

	      skip_msg();

	      fast_forward_to_label = 1;
	    }
	  else if ( status == FI_INVALID_ROW )
	    {
	      fprintf ( stderr,
		"\nERROR:  Input text file '%s', line %d:\n",
		text_file_name, line_num );
	      fprintf ( stderr,
		"\tError converting row value in \"%s\" to integer value.\n",
		keyword );

	      skip_msg();

	      fast_forward_to_label = 1;
	    }
	  else if (  ( current_gadget_col  != -1 )		&&
		     ( current_gadget_type != FI_MULTI_COL )	 )
	    {
	      fprintf ( stderr,
		    "\nERROR:  Input text file '%s', line %d:\n",
		    text_file_name, line_num );
	      fprintf ( stderr,
		    "\tcolumn value in \"text\" keyword is not valid for non- FI_MULTI_COL type gadgets.\n" );

	      skip_msg();

	      fast_forward_to_label = 1;
	    }
	  else if ( status == FI_INVALID_COL )
	    {
	      fprintf ( stderr,
		"\nERROR:  Input text file '%s', line %d:\n",
		text_file_name, line_num );
	      fprintf ( stderr,
		"\tError converting column value in \"%s\" to integer value.\n",
		keyword );

	      skip_msg();

	      fast_forward_to_label = 1;
	    }
	  else
	    {
		/******************************************/
		/*** If gadget type is a field or mcf	***/
		/*** then set the text immediately;	***/
		/*** otherwise, append this text to	***/
		/*** the text from the previous row,	***/
		/*** and set the text when the next	***/
		/*** LABEL keyword is reached.		***/
		/******************************************/

	      if (  ( current_gadget_type == FI_FIELD )		||
	            ( current_gadget_type == FI_MULTI_COL )	 )
		{
		  if ( current_gadget_col == -1 )
		    {
		      current_gadget_col = 0;
		    }

	          status = FIfld_set_default_text ( (Form)form_ptr,
			current_gadget_label, current_gadget_row,
			current_gadget_col, value, 0 );

	          if ( status != FI_SUCCESS )
	            {
		      fprintf ( stderr,
		        "\nERROR %d during FIfld_set_default_text ( form_ptr = 0x%x,\n",
		        status, form_ptr );
		      fprintf ( stderr,
		        "\t\tgadget_label = %d, row = %d, column = %d\n",
		        current_gadget_label, current_gadget_row,
			current_gadget_col );
		      fprintf ( stderr,
		        "\t\ttext = '%s', select_flag = 0 )\n",
		        value );

	              skip_msg();

	              fast_forward_to_label = 1;
	            }
	          else
		    {
	              FIg_activate ( (Form)form_ptr, current_gadget_label );
		    }
		}
	      else
		{
		  if ( current_gadget_text_pending )
		    {
		      strcat ( current_gadget_text, "\n" );
		    }

		  strcat ( current_gadget_text, value );

		  current_gadget_text_pending = 1;
		}
	    }
	}  /*** keyword == "text" ***/
      else if ( ! strncmp ( keyword, "on_text", 7 ) )
	{
	  status = _FI_extract_row_col_from_text_word ( keyword,
					      & current_gadget_row,
					      & current_gadget_col );

	  if ( status == FI_TEXT_WORD_HAS_NO_LEFT_BRACKET )
	    {
	      fprintf ( stderr,
		"\nERROR:  Input text file '%s', line %d:\n",
		text_file_name, line_num );
	      fprintf ( stderr,
		"\t\"on_text\" keyword has no left bracket: '%s'.\n",
		keyword );

	      skip_msg();

	      fast_forward_to_label = 1;
	    }
	  else if ( status == FI_TEXT_WORD_HAS_NO_RIGHT_BRACKET )
	    {
	      fprintf ( stderr,
		"\nERROR:  Input text file '%s', line %d:\n",
		text_file_name, line_num );
	      fprintf ( stderr,
		"\t\"on_text\" keyword has no right bracket: '%s'.\n",
		keyword );

	      skip_msg();

	      fast_forward_to_label = 1;
	    }
	  else if ( status == FI_INVALID_ROW )
	    {
	      fprintf ( stderr,
		"\nERROR:  Input text file '%s', line %d:\n",
		text_file_name, line_num );
	      fprintf ( stderr,
		"\tError converting row value in \"%s\" to integer value.\n",
		keyword );

	      skip_msg();

	      fast_forward_to_label = 1;
	    }
	  else if ( current_gadget_type != FI_TOGGLE )
	    {
	      fprintf ( stderr,
		    "\nERROR:  Input text file '%s', line %d:\n",
		    text_file_name, line_num );
	      fprintf ( stderr,
		    "\t\"on_text\" keyword is not valid for non- FI_TOGGLE type gadgets.\n",
		    value );

	      skip_msg();

	      fast_forward_to_label = 1;
	    }
	  else if (  ( current_gadget_col  != -1 )		&&
		     ( current_gadget_type != FI_MULTI_COL )	 )
	    {
	      fprintf ( stderr,
		    "\nERROR:  Input text file '%s', line %d:\n",
		    text_file_name, line_num );
	      fprintf ( stderr,
		    "\tcolumn value in \"on_text\" keyword is not valid for non- FI_MULTI_COL type gadgets.\n" );

	      skip_msg();

	      fast_forward_to_label = 1;
	    }
	  else if ( status == FI_INVALID_COL )
	    {
	      fprintf ( stderr,
		"\nERROR:  Input text file '%s', line %d:\n",
		text_file_name, line_num );
	      fprintf ( stderr,
		"\tError converting column value in \"%s\" to integer value.\n",
		keyword );

	      skip_msg();

	      fast_forward_to_label = 1;
	    }
	  else
	    {
	      if ( current_gadget_on_text_pending )
		{
		  strcat ( current_gadget_on_text, "\n" );
		}

	      strcat ( current_gadget_on_text, value );

	      current_gadget_on_text_pending = 1;
	    }
	}  /*** keyword == "on_text" ***/
      else if ( ! strncmp ( keyword, "assoc_list_text", 15 ) )
	{
	  status = _FI_extract_row_col_from_text_word ( keyword,
					      & current_gadget_row,
					      & current_gadget_col );

	  if ( status == FI_TEXT_WORD_HAS_NO_LEFT_BRACKET )
	    {
	      fprintf ( stderr,
		"\nERROR:  Input text file '%s', line %d:\n",
		text_file_name, line_num );
	      fprintf ( stderr,
		"\t\"assoc_list_text\" keyword has no left bracket: '%s'.\n",
		keyword );

	      skip_msg();

	      fast_forward_to_label = 1;
	    }
	  else if ( status == FI_TEXT_WORD_HAS_NO_RIGHT_BRACKET )
	    {
	      fprintf ( stderr,
		"\nERROR:  Input text file '%s', line %d:\n",
		text_file_name, line_num );
	      fprintf ( stderr,
		"\t\"assoc_list_text\" keyword has no right bracket: '%s'.\n",
		keyword );

	      skip_msg();

	      fast_forward_to_label = 1;
	    }
	  else if ( status == FI_INVALID_ROW )
	    {
	      fprintf ( stderr,
		"\nERROR:  Input text file '%s', line %d:\n",
		text_file_name, line_num );
	      fprintf ( stderr,
		"\tError converting row value in \"%s\" to integer value.\n",
		keyword );

	      skip_msg();

	      fast_forward_to_label = 1;
	    }
	  else if ( current_gadget_type != FI_FIELD )
	    {
	      fprintf ( stderr,
		    "\nERROR:  Input text file '%s', line %d:\n",
		    text_file_name, line_num );
	      fprintf ( stderr,
		    "\t\"assoc_list_text\" keyword is not valid for non- FI_FIELD type gadgets.\n",
		    value );

	      skip_msg();

	      fast_forward_to_label = 1;
	    }
	  else if ( current_gadget_col  != -1 )
	    {
	      fprintf ( stderr,
		    "\nERROR:  Input text file '%s', line %d:\n",
		    text_file_name, line_num );
	      fprintf ( stderr,
		    "\tcolumn value in \"assoc_list_text\" keyword is not valid.\n" );
	      skip_msg();

	      fast_forward_to_label = 1;
	    }
	  else if ( status == FI_INVALID_COL )
	    {
	      fprintf ( stderr,
		"\nERROR:  Input text file '%s', line %d:\n",
		text_file_name, line_num );
	      fprintf ( stderr,
		"\tError converting column value in \"%s\" to integer value.\n",
		keyword );

	      skip_msg();

	      fast_forward_to_label = 1;
	    }
	  else
	    {
	      status = FIfld_set_list_default_text ( (Form)form_ptr,
			current_gadget_label, current_gadget_row,
			0, value, 0 );

	      if ( status != FI_SUCCESS )
	        {
		  fprintf ( stderr,
		    "\nERROR %d during FIfld_set_list_default_text ( form_ptr = 0x%x,\n",
		    status, form_ptr );
		  fprintf ( stderr,
		      "\t\tgadget_label = %d, row = %d, column = %d\n",
		      current_gadget_label, current_gadget_row, 0 );
		  fprintf ( stderr,
		        "\t\ttext = '%s', select_flag = 0 )\n",
		        value );

	          skip_msg();

	          fast_forward_to_label = 1;
	        }
	      else
		{
	          FIg_activate ( (Form)form_ptr, current_gadget_label );
		}
	    }
	}  /*** keyword == "assoc_list_text" ***/
      else if ( ! strcmp ( keyword, "field_attr" ) )
	{
	  status = _FI_field_attr_string_to_int ( value,
					      & current_field_attr,
						temp_error_attr );

	  if ( status == FI_INVALID_BUFFER )
	    {
	      fprintf ( stderr,
		"\nERROR:  Input text file '%s', line %d:\n",
		text_file_name, line_num );
	      fprintf ( stderr,
		"\t\"field_attr='%s'\" is an unknown field attribute.\n",
		temp_error_attr );

	      skip_msg();

	      fast_forward_to_label = 1;
	    }
	  else if ( current_gadget_type != FI_FIELD )
	    {
	      fprintf ( stderr,
		    "\nERROR:  Input text file '%s', line %d:\n",
		    text_file_name, line_num );
	      fprintf ( stderr,
		    "\t\"field_attr\" keyword is not valid for non- FI_FIELD type gadgets.\n" );

	      skip_msg();

	      fast_forward_to_label = 1;
	    }
	  else if ( !(current_field_attr & FI_RIGHT_TO_LEFT) &&
		     (current_field_attr & FI_REVERSE_INPUT)  )
	    {
	      fprintf ( stderr,
		    "\nERROR:  Input text file '%s', line %d:\n",
		    text_file_name, line_num );
	      fprintf ( stderr,
		    "\t\"field_attr\" keyword value \"FI_REVERSE_INPUT\"is only valid when FI_RIGHT_TO_LEFT is set.\n" );

	      skip_msg();

	      fast_forward_to_label = 1;
	    }
	  else if ( !(current_field_attr & FI_RIGHT_TO_LEFT) &&
		     (current_field_attr & FI_REVERSE_OUTPUT)  )
	    {
	      fprintf ( stderr,
		    "\nERROR:  Input text file '%s', line %d:\n",
		    text_file_name, line_num );
	      fprintf ( stderr,
		    "\t\"field_attr\" keyword value \"FI_REVERSE_OUTPUT\"is only valid when FI_RIGHT_TO_LEFT is set.\n" );

	      skip_msg();

	      fast_forward_to_label = 1;
	    }
	  else
	    {
	      status = FIfld_get_attr ( (Form)form_ptr, current_gadget_label,
					0, & existing_field_attr );

	      if ( status != FI_SUCCESS )
	        {
		  fprintf ( stderr,
		    "\nERROR %d during FIfld_get_attr ( form_ptr = 0x%x,\n",
		    status, form_ptr );
		  fprintf ( stderr, "\t\tgadget_label = %d )\n",
		    current_gadget_label);

	          skip_msg();

	          fast_forward_to_label = 1;
	        }

	      if ( existing_field_attr & FI_RIGHT_TO_LEFT )
		{
			/*** un-set these values ***/

		  existing_field_attr &= ~FI_RIGHT_TO_LEFT  ;
		  existing_field_attr &= ~FI_REVERSE_INPUT  ;
		  existing_field_attr &= ~FI_REVERSE_OUTPUT ;
		}

	      status = FIfld_set_attr ( (Form)form_ptr,
			current_gadget_label, 0,
			current_field_attr | existing_field_attr );

	      if ( status != FI_SUCCESS )
	        {
		  fprintf ( stderr,
		    "\nERROR %d during FIfld_set_attr ( form_ptr = 0x%x,\n",
		    status, form_ptr );
		  fprintf ( stderr,
		    "\t\tgadget_label = %d, attr = 0x%x )\n",
		    current_gadget_label,
		    current_field_attr | existing_field_attr );

	          skip_msg();

	          fast_forward_to_label = 1;
	        }
	      else
		{
	          FIg_activate ( (Form)form_ptr, current_gadget_label );
		}
	    }
	}  /*** keyword == "field_attr" ***/
      else if ( ! strncmp ( keyword, "column_attr", 11 ) )
	{
	  status = _FI_extract_row_col_from_text_word ( keyword,
					      & current_gadget_col,
					      & current_gadget_row );

	  if ( status == FI_TEXT_WORD_HAS_NO_LEFT_BRACKET )
	    {
	      fprintf ( stderr,
		"\nERROR:  Input text file '%s', line %d:\n",
		text_file_name, line_num );
	      fprintf ( stderr,
		"\t\"column_attr\" keyword has no left bracket: '%s'.\n",
		keyword );

	      skip_msg();

	      fast_forward_to_label = 1;
	    }
	  else if ( status == FI_TEXT_WORD_HAS_NO_RIGHT_BRACKET )
	    {
	      fprintf ( stderr,
		"\nERROR:  Input text file '%s', line %d:\n",
		text_file_name, line_num );
	      fprintf ( stderr,
		"\t\"column_attr\" keyword has no right bracket: '%s'.\n",
		keyword );

	      skip_msg();

	      fast_forward_to_label = 1;
	    }
	  else if ( status == FI_INVALID_ROW )
	    {
	      fprintf ( stderr,
		"\nERROR:  Input text file '%s', line %d:\n",
		text_file_name, line_num );
	      fprintf ( stderr,
		"\tError converting row value in \"%s\" to integer value.\n",
		keyword );

	      skip_msg();

	      fast_forward_to_label = 1;
	    }
	  else if ( current_gadget_row  != -1 )
	    {
	      fprintf ( stderr,
		    "\nERROR:  Input text file '%s', line %d:\n",
		    text_file_name, line_num );
	      fprintf ( stderr,
		    "\trow value in \"column_attr\" keyword is not valid.\n" );
	      skip_msg();

	      fast_forward_to_label = 1;
	    }
	  else if ( status == FI_INVALID_COL )
	    {
	      fprintf ( stderr,
		"\nERROR:  Input text file '%s', line %d:\n",
		text_file_name, line_num );
	      fprintf ( stderr,
		"\tError converting column value in \"%s\" to integer value.\n",
		keyword );

	      skip_msg();

	      fast_forward_to_label = 1;
	    }

	  status = _FI_field_attr_string_to_int ( value,
					      & current_field_attr,
						temp_error_attr );

	  if ( status == FI_INVALID_BUFFER )
	    {
	      fprintf ( stderr,
		"\nERROR:  Input text file '%s', line %d:\n",
		text_file_name, line_num );
	      fprintf ( stderr,
		"\t\"column_attr='%s'\" is an unknown field attribute.\n",
		temp_error_attr );

	      skip_msg();

	      fast_forward_to_label = 1;
	    }
	  else if ( current_gadget_type != FI_MULTI_COL )
	    {
	      fprintf ( stderr,
		    "\nERROR:  Input text file '%s', line %d:\n",
		    text_file_name, line_num );
	      fprintf ( stderr,
		    "\t\"column_attr\" keyword is not valid for non- FI_MULTI_COL field type gadgets.\n" );

	      skip_msg();

	      fast_forward_to_label = 1;
	    }
	  else if ( !(current_field_attr & FI_RIGHT_TO_LEFT) &&
		     (current_field_attr & FI_REVERSE_INPUT)  )
	    {
	      fprintf ( stderr,
		    "\nERROR:  Input text file '%s', line %d:\n",
		    text_file_name, line_num );
	      fprintf ( stderr,
		    "\t\"column_attr\" keyword value \"FI_REVERSE_INPUT\"is only valid when FI_RIGHT_TO_LEFT is set.\n" );

	      skip_msg();

	      fast_forward_to_label = 1;
	    }
	  else if ( !(current_field_attr & FI_RIGHT_TO_LEFT) &&
		     (current_field_attr & FI_REVERSE_OUTPUT)  )
	    {
	      fprintf ( stderr,
		    "\nERROR:  Input text file '%s', line %d:\n",
		    text_file_name, line_num );
	      fprintf ( stderr,
		    "\t\"column_attr\" keyword value \"FI_REVERSE_OUTPUT\"is only valid when FI_RIGHT_TO_LEFT is set.\n" );

	      skip_msg();

	      fast_forward_to_label = 1;
	    }
	  else
	    {
	      status = FIfld_get_attr ( (Form)form_ptr, current_gadget_label,
			current_gadget_col, & existing_field_attr );

	      if ( status != FI_SUCCESS )
	        {
		  fprintf ( stderr,
		    "\nERROR %d during FIfld_get_attr ( form_ptr = 0x%x,\n",
		    status, form_ptr );
		  fprintf ( stderr,
		    "\t\tgadget_label = %d, column = %d )\n",
		    current_gadget_label, current_gadget_col );

	          skip_msg();

	          fast_forward_to_label = 1;
	        }

	      if ( existing_field_attr & FI_RIGHT_TO_LEFT )
		{
			/*** un-set these values ***/

		  existing_field_attr &= ~FI_RIGHT_TO_LEFT  ;
		  existing_field_attr &= ~FI_REVERSE_INPUT  ;
		  existing_field_attr &= ~FI_REVERSE_OUTPUT ;
		}

	      status = FIfld_set_attr ( (Form)form_ptr,
			current_gadget_label, current_gadget_col,
			current_field_attr | existing_field_attr );

	      if ( status != FI_SUCCESS )
	        {
		  fprintf ( stderr,
		    "\nERROR %d during FIfld_set_attr ( form_ptr = 0x%x,\n",
		    status, form_ptr );
		  fprintf ( stderr,
		    "\t\tgadget_label = %d, column = %d, attr = 0x%x\n",
		    current_gadget_label, current_gadget_col,
		    current_field_attr | existing_field_attr );

	          skip_msg();

	          fast_forward_to_label = 1;
	        }
	      else
		{
	          FIg_activate ( (Form)form_ptr, current_gadget_label );
		}
	    }
	}  /*** keyword == "column_attr" ***/
      else if ( ! strcmp ( keyword, "pos" ) )
	{
          status = sscanf ( value, "%d,%d",
			& current_gadget_xpos, & current_gadget_ypos  );

		/*** sscanf will succeed on a string like "1x",	***/
		/***   so do some more checking 		***/
          if ( (status != 2) || (!_FI_is_all_digits (value,0,1))  )
	    {
	      fprintf ( stderr,
		"\nERROR:  Input text file '%s', line %d:\n",
		text_file_name, line_num );
	      fprintf ( stderr,
		"\tError converting \"pos='%s'\" to integer values.\n",
		value );

	      skip_msg();

	      fast_forward_to_label = 1;
	    }
	  else
	    {
	      status = FIg_set_location ( (Form)form_ptr,
					     current_gadget_label,
					     current_gadget_xpos,
					     current_gadget_ypos );

	      if ( status != FI_SUCCESS )
	        {
		  fprintf ( stderr,
	            "\nERROR %d during FIg_set_location ( form_ptr = 0x%x,\n",
		        status, form_ptr );
		  fprintf ( stderr,
		      "\t\tgadget_label = %d, xpos = %d, ypos = %d )\n",
			current_gadget_label,
			current_gadget_xpos, current_gadget_ypos );

	          skip_msg();

	          fast_forward_to_label = 1;
	        }
	      else
		{
	          FIg_activate ( (Form)form_ptr, current_gadget_label );
		}
	    }
	}  /*** keyword == "pos" ***/
      else if ( ! strcmp ( keyword, "assoc_list_pos" ) )
	{
          status = sscanf ( value, "%d,%d",
			& current_gadget_xpos, & current_gadget_ypos  );

		/*** sscanf will succeed on a string like "1x",	***/
		/***   so do some more checking 		***/
          if ( (status != 2) || (!_FI_is_all_digits (value,0,1))  )
	    {
	      fprintf ( stderr,
		"\nERROR:  Input text file '%s', line %d:\n",
		text_file_name, line_num );
	      fprintf ( stderr,
		"\tError converting \"assoc_list_pos='%s'\" to integer values.\n",
		value );

	      skip_msg();

	      fast_forward_to_label = 1;
	    }
	  else if ( current_gadget_type != FI_FIELD )
	    {
	      fprintf ( stderr,
		    "\nERROR:  Input text file '%s', line %d:\n",
		    text_file_name, line_num );
	      fprintf ( stderr,
		    "\t\"assoc_list_pos\" keyword is not valid for non- FI_FIELD type gadgets.\n",
		    value );

	      skip_msg();

	      fast_forward_to_label = 1;
	    }
	  else
	    {
              /* dmb,sml:09/02/92:Added 0 for column arg for ANSI */
	      status = FIfld_set_list_location ( (Form)form_ptr,
					     current_gadget_label,
                                             0,
					     current_gadget_xpos,
					     current_gadget_ypos );

	      if ( status != FI_SUCCESS )
	        {
		  fprintf ( stderr,
	            "\nERROR %d during FIfld_set_list_location ( form_ptr = 0x%x,\n",
		        status, form_ptr );
		  fprintf ( stderr,
		      "\t\tgadget_label = %d, xpos = %d, ypos = %d )\n",
			current_gadget_label,
			current_gadget_xpos, current_gadget_ypos );

	          skip_msg();

	          fast_forward_to_label = 1;
	        }
	      else
		{
	          FIg_activate ( (Form)form_ptr, current_gadget_label );
		}
	    }
	}  /*** keyword == "assoc_list_pos" ***/
      else	/*** UNKNOWN KEYWORD ***/
	{
	  fprintf ( stderr,
	    "\nERROR:  Input text file '%s', line %d:\n",
	    text_file_name, line_num );
	  fprintf ( stderr,
		"\tkeyword \"%s\" is invalid\n", keyword );

	  skip_msg();

	  fast_forward_to_label = 1;
	}
    }

  num_keywords++;

  return ( FI_SUCCESS );
}




int FIf_set_text (Form              form_ptr,
                  FILE              * infp,
                  char              * form_name,
                  char              * text_file_name)
{
  char		input_line[LINE_SIZE];
  char		keyword   [LINE_SIZE];
  char		value     [LINE_SIZE];
  int		line_num = 0;
  int		status = FI_SUCCESS;
  struct FIform_obj * form = (struct FIform_obj *)form_ptr;

  if ( feof ( infp ) )
    {
      fprintf ( stderr,
	"\nFATAL ERROR:  Input text file '%s' is empty.\n\n",
	text_file_name );
      return ( FI_SET_TEXT_ERROR );
    }

	/******************************************/
	/*** skip leading comments, blanks, etc ***/
	/******************************************/
  _FI_skip_comments_blanks ( infp, & line_num );

  if ( feof ( infp ) )
    {
      fprintf ( stderr,
	"\nFATAL ERROR:  Input text file '%s' contains only white space and comments.\n\n",
	text_file_name );
      return ( FI_SET_TEXT_ERROR );
    }

	/*************************************/
	/*** expect FORM_TEXT_FILE keyword ***/
	/*************************************/
  for ( ; ; )
    {
      status = (int) fgets ( input_line, LINE_SIZE - 1, infp );

      if ( status == 0 )
        {
          return ( FI_SET_TEXT_ERROR );
        }

      line_num++;

      status = _FI_retrieve_keyword_value ( input_line, keyword, value,
					text_file_name, line_num );
      if ( status == FI_SET_TEXT_ERROR )
        {
          return ( FI_SET_TEXT_ERROR );
        }

      status = _FI_process_keyword_value ( form,
					form_name, keyword, value,
					text_file_name, line_num );

      if ( status == FI_SET_TEXT_ERROR )
        {
          return ( FI_SET_TEXT_ERROR );
        }

      /**************************************************************
      printf ( "%4d keyword 	'%s'\n", line_num, keyword );
      printf ( "%4d value 	'%s'\n", line_num, value );
      **************************************************************/

      if ( feof ( infp ) )
        {
	  break;
        }

	/**********************************/
	/*** skip comments, blanks, etc	***/
	/**********************************/
      _FI_skip_comments_blanks ( infp, & line_num );

      if ( feof ( infp ) )
        {
	  break;
        }
    }

	/**************************************************/
	/*** At this point, there still may be text	***/
	/*** that has been read from the file, that	***/
	/*** hasn't been put into the new form ( as	***/
	/*** in the case of a form with exactly one	***/
	/*** gadget that has text ).  So, output it	***/
	/*** here.		--JAJ:12/15/91		***/
	/**************************************************/

  if ( current_gadget_text_pending )
    {
      status = FIg_set_off_text ( form_ptr,
			current_gadget_label, current_gadget_text );

      if ( status != FI_SUCCESS )
	{
	  fprintf ( stderr,
	    "\nERROR %d during FIg_set_off_text ( form_ptr = 0x%x,\n",
	    status, form );
	  fprintf ( stderr,
	    "\t\tgadget_label = %d, text = '%s' ).\n",
	    current_gadget_label, current_gadget_text );
	}
      else
	{
	  FIg_activate ( form_ptr, current_gadget_label );
	}
    }

  if ( current_gadget_on_text_pending )
    {
      status = FIg_set_on_text ( form_ptr,
		current_gadget_label, current_gadget_on_text );

      if ( status != FI_SUCCESS )
        {
          fprintf ( stderr,
            "\nERROR %d during FIg_set_on_text ( form = 0x%x,\n",
            status, form );
          fprintf ( stderr,
            "\t\tgadget_label = %d, text = '%s' ).\n",
            current_gadget_label, current_gadget_on_text );
        }
      else
	{
          FIg_activate ( form_ptr, current_gadget_label );
	}
    }
	/****** end of fix --- JAJ:12/15/91	******/

  return ( FI_SUCCESS );
}
