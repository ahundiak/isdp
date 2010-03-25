#include <string.h>
#include <ctype.h>
#include "../hfiles/EMDefines.h"
#include "../hfiles/EMTCB.h"
#include "../hfiles/EMRegis.h"
#include "../hfiles/EMState.h"
#include "../hfiles/EMError.h"


#define ERROR	1


/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMParseHLSValues				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int _EMParseHLSValues (buffer, buffer_end, H, L, S)		*/
/*									*/
/*	  char  *buffer     -- pointer to null terminated string 	*/
/*				 which contains the HLS specifier	*/
/*	  char  *buffer_end -- pointer to end of buffer			*/
/*	  float *H	    -- returned settings scanned from the	*/
/*              *L		 specifier				*/
/*	        *S							*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  The value EM_NO_ERROR is returned if the HLS specifier is	*/
/*	  valid. Otherwise, ERROR is returned.				*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function scans the buffer for hue, lightness, and 	*/
/*	  saturation values.  If only a lightness value is found, 	*/
/*	  the hue and saturation are returned as zero. An ERROR		*/
/*	  condition is raised if the lightness specifier is not 	*/
/*	  present or is invalid.					*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

static int _EMParseHLSValues (buffer, buffer_end, H, L, S)

char	*buffer, *buffer_end;
float	*H, *L, *S;
{
	char	*value_ptr;	/* pointer to next string of digits	*/
	int	value;		/* integral value of string of digits	*/
	int	scan_status;	/* status returned by "sscanf" --	*/
				/*  indicates number of values read or	*/
				/*  EOF (if null character found)	*/
	int	return_status;	/* status returned to caller		*/

	/* Set H, L, and S to zero for return in case of ERROR condition. */
	*H = 0.0;
	*L = 0.0;
	*S = 0.0;

	/* Find the hue specifier. */
	value_ptr = buffer + strcspn (buffer, "Hh") + 1;

	if (value_ptr < buffer_end)
	{
	    /* The hue specifier was found.  Read the hue value. */
	    scan_status = sscanf (value_ptr, "%d", &value);
	    if ((scan_status != EOF) && (scan_status != 0) && (value <= 360))
		*H = (float) value;
	}


	/* Find the lightness specifier. */
	value_ptr = buffer + strcspn (buffer, "Ll") + 1;

	if (value_ptr < buffer_end)
	{
	    /* The lightness specifier was found.  Read the value. */
	    scan_status = sscanf (value_ptr, "%d", &value);
	    if ((scan_status != EOF) && (scan_status != 0) && (value <= 100))
	    {
		*L = ((float) value) / 100.0;
		return_status = EM_NO_ERROR;
	    }		  
	    else
		return_status = ERROR;	/* invalid lightness specifier */
	}
	else
	    return_status = ERROR;	/* missing lightness specifier */


	/* Find the saturation specifier. */
	value_ptr = buffer + strcspn (buffer, "Ss") + 1;
	if (value_ptr < buffer_end)
	{
	    /* The saturation specifier was found.  Read the value. */
	    scan_status = sscanf (value_ptr, "%d", &value);
	    if ((scan_status != EOF) && (scan_status != 0) && (value <= 100))
		*S = ((float) value) / 100.0;
	}

	return (return_status);
}	

/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMParseColors					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int _EMParseColors (buffer, buffer_end, H, L, S, color_only)	*/
/*									*/
/*	  char   *buffer     -- buffer containing a color specifier	*/
/*			          (must be null terminated)		*/
/*	  char   *buffer_end -- pointer to the last char. in the buffer */
/*	  float  *H	     -- hue, lightness, and saturation values   */
/*	  float  *L	          returned:  H in range [0.0, 360.0],	*/
/*	  float  *S          --   L, S in range [0.0, 1.0]		*/
/*	  int    *color_only -- specifies whether the user/host wants   */
/*			          to change only color settings or to	*/
/*				  change both color and mono settings   */
/*				  (TRUE or FALSE)			*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  A status of either ERROR or EM_NO_ERROR is returned.		*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function receives a buffer containing a color specifier  */
/*	  (in either RGB or HLS format) and returns the hue, lightness, */
/*	  and saturation values representing that color.  An invalid	*/
/*	  color specifier will cause an ERROR status code to be		*/
/*	  returned.							*/
/*									*/
/*	  If only a lightess value is specified, that value is 		*/
/*	  returned, and hue and saturation values of zero are returned. */
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

static int _EMParseColors (buffer, buffer_end, H, L, S, color_only)

char	*buffer, *buffer_end;
float	*H, *L, *S;
int	*color_only;
{
	char	*next_char;	/* next alphabetic char in buffer */

	static char	alphabet[] =
			"abcdefghijklmopqrstuvwxzyABCDEFGHIJKLMNOPQRSTUVWXYZ";

	int	error_status;	/* status code returned to caller */


	error_status = EM_NO_ERROR;

	/* Find the first alphabetic character and convert to uppercase. */
	next_char = buffer + strcspn (buffer, alphabet);
	*next_char = toupper (*next_char);

	if (next_char <= buffer_end)
	{
	    if (*next_char == 'A')
	    {
		*color_only = TRUE;
		buffer = next_char + 1;
		next_char = buffer + strcspn (buffer, alphabet);
		*next_char = toupper (*next_char);
	    }
	    else
		*color_only = FALSE;

	    if (next_char <= buffer_end)
	    {
		*L = 0.5;			/* RGB settings		*/
		*S = 1.0;

		switch (*next_char)
		{
		    case 'B':
			*H = 0.0;	/* blue settings 	*/
			break;

		    case 'M':
			*H = 60.0;	/* magenta settings	*/
			break;

		    case 'R':
			*H = 120.0;	/* red settings		*/
			break;

		    case 'Y':
			*H = 180.0;	/* yellow settings	*/
			break;

		    case 'G':
			*H = 240.0;	/* green settings	*/
			break;

		    case 'C':
			*H = 300.0;	/* cyan settings	*/
			break;

		    case 'D':
			*H = 0.0;	/* black settings	*/
			*L = 0.0;
			*S = 0.0;
			break;

		    case 'W':
			*H = 0.0;	/* white settings	*/
			*L = 1.0;
			*S = 0.0;
			break;

		    default:
			error_status = _EMParseHLSValues (buffer, buffer_end,
							  H, L, S);
		}
	    }
	    else 
		error_status = ERROR;		/* no color specifier	*/
	}
	else
	    error_status = ERROR;		/* no alphabetic char.	*/

	return (error_status);
}


/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMMappingOption				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMMappingOption (state_table, buffer, end_of_buffer)	*/
/*									*/
/*	  ReGIS_state *state_table   -- state table for this process    */
/*	  char	      *buffer        -- buffer containing ReGIS command */
/*	  char        *end_of_buffer -- last character in buffer	*/
/*									*/
/*	RETURNED VALUE:	 none						*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function scans the buffer for <table index, color spec.> */
/*	  pairs and places the specified color in the specified index   */
/*	  of the color table.						*/
/*									*/
/*	CALLED BY:							*/
/*	  _EMExecScreenCommand (file regis.c)				*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

static void _EMMappingOption (state_table, buffer, end_of_buffer)

ReGIS_state	*state_table;
char		*buffer;
char		*end_of_buffer;

{
	static char	digits[] = "0123456789";

	char	*digit_ptr;
	int	color_index;		/* index of color table entry	*/
					/*  to reset			*/
	float	H, L, S;		/* HLS values for color 	*/
	int	color_only;		/* leave mono settings alone?	*/
	char	*spec_begin;		/* pointer to first and last	*/
	char	*spec_end;		/*  characters of color		*/
					/*  specifier			*/
	int	status;			/* returned from _EMParseColors	*/
	int	finished;		


	finished = FALSE;

	while (!finished)
	{
	    /* Look for a color table index. */
	    digit_ptr = buffer + strcspn (buffer, digits);

	    if (digit_ptr <= end_of_buffer)
	    {
		/* Convert digit specifying table index to integer. */
		color_index = *digit_ptr - 0x30;

		/* Find beginning and end of color specifier. */
		spec_begin = buffer + strcspn (buffer, "(");
		spec_end   = buffer + strcspn (buffer, ")");

		if ((spec_begin <= end_of_buffer) &&
		    (spec_end <= end_of_buffer) && (spec_begin < spec_end))
		{
		    /* Parse and set screen colors. */
		    *spec_end = '\0';
		    status = _EMParseColors (spec_begin, spec_end, 
					     &H, &L, &S, &color_only);
		    if (status == EM_NO_ERROR)
		    {
			if (color_only)
			    _EMSetColorTable (state_table, color_index, 
					      H, L, S, COLOR_ONLY);
			else
			    _EMSetColorTable (state_table, color_index, 
					      H, L, S, MONO_AND_COLOR);
			_EMColorTableToVLT (state_table);
		    }

		    buffer = ++spec_end;
		}
		else
		    finished = TRUE;	/* no color specifier found */
	    }
	    else
		finished = TRUE;	/* no table index found */
	}
}



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMIntensityIndex				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int _EMIntensityIndex (buffer, end_of_buffer)			*/
/*									*/
/*	  char  *buffer        -- pointer to start of buffer containing */
/*				    intensity specifier		        */
/*	  char  *end_of_buffer -- pointer to last character in buffer   */
/*									*/
/*	RETURNED VALUE:							*/
/*	  The specified index is returned.  If an invalid intensity	*/
/*	  specifier is encountered, ERROR is returned.			*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function scans the buffer for an index specifier (either */
/*	  an ascii digit, an RGB specifier, or an HLS specifier).	*/
/*	  If an ascii digit is found, that digit is converted to an	*/
/*	  integer and returned.  If a color specifier is found, the	*/
/*	  index of the color table location containing the "closest"    */
/*	  color is returned.						*/
/*									*/
/*	  *** NOTE:  only the ascii digit case is yet implemented ***   */
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

static int _EMIntensityIndex (buffer, end_of_buffer)

char	*buffer, *end_of_buffer;
{
	char	*char_ptr;	/* pointer to a letter or digit		*/
	int	index;		/* index (or error status) returned 	*/


	/* Find the first alphanumeric character. */
	char_ptr = buffer;

	while ((!isalnum (*char_ptr)) && (char_ptr <= end_of_buffer))
	    char_ptr++;

	buffer = char_ptr + 1;


	/* If a letter or digit was found, determine which color table	*/
	/* index was specified.						*/
	if (char_ptr <= end_of_buffer)
	{
	    if (isdigit (*char_ptr))
	    {
		index = *char_ptr - 0x30;
	    }
	    else 
	    {
		index = ERROR;
	    }
	}
	else
	    index = ERROR;

	return (index);
}

/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMExecScreenCommand				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMExecScreenCommand (state_table, command_buffer,	*/
/*	  			       end_of_buffer)			*/
/*									*/
/*	  ReGIS_state *state_table     --  state table for this process */
/*	  char	      *command_buffer  --  buffer containing ReGIS	*/
/*					       command 			*/
/*	  char        *end_of_buffer   --  last character in buffer	*/
/*									*/
/*	RETURNED VALUE:  none						*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function executes the screen command in the buffer.	*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

static void _EMExecScreenCommand (state_table, command_buffer, end_of_buffer)

ReGIS_state	*state_table;
char		*command_buffer;
char		*end_of_buffer;

{
	char	*option;	/* char. representing command option	*/
	int	bg_index;	/* color table location holding new 	*/
				/*  background color			*/

	/* Find the first alphabetic character (option specifier). */
	option = command_buffer;

	while ((!isalpha (*option)) && (option <= end_of_buffer))
	    option++;	

	command_buffer = option + 1;	/* point past option specifier */

	/* If an option specifier was found, determine which option was	*/
	/* chosen and act accordingly. (option specifier uppercase)	*/
	if (option <= end_of_buffer)  
	{
	    *option = toupper (*option);

	    switch (*option)
	    {
		case 'M':
		    _EMMappingOption (state_table, command_buffer, 
				      end_of_buffer);
		    break;

		case 'I':
		    bg_index = _EMIntensityIndex (command_buffer,
						  end_of_buffer);
		    _EMSetColorIndex (state_table, BACKGROUND, bg_index);
		    break;

		default:
		    break;
	    }
	}
}



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMExecWriteCommand				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMExecWriteCommand (state_table, command_buffer,	*/
/*	  			    end_of_buffer)			*/
/*									*/
/*	  ReGIS_state *state_table     --  state table for this process */
/*	  char	      *command_buffer  --  buffer containing ReGIS	*/
/*					       command 			*/
/*	  char        *end_of_buffer   --  last character in buffer	*/
/*									*/
/*	RETURNED VALUE:  none						*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function executes the write command in the buffer.	*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

static void _EMExecWriteCommand (state_table, command_buffer, end_of_buffer)

ReGIS_state	*state_table;
char		*command_buffer;
char		*end_of_buffer;
{
	char	*option;	/* char. representing command option	*/
	int	fg_index;	/* color table location holding new	*/
				/*  foreground color			*/

	/* Find the first alphabetic character (option specifier). */
	option = command_buffer;

	while ((!isalpha (*option)) && (option <= end_of_buffer))
	    option++;	

	command_buffer = option + 1;	/* point past option specifier */

	/* If an option specifier was found, determine which option was	*/
	/* chosen and act accordingly. (option specifier uppercase)	*/
	if (option <= end_of_buffer)  
	{
	    *option = toupper (*option);

	    switch (*option)
	    {
		case 'I':
		    fg_index = _EMIntensityIndex (command_buffer,
						  end_of_buffer);
		    _EMSetColorIndex (state_table, FOREGROUND, fg_index);
		    break;

		default:
		    break;
	    }
	}
}





/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMReGISCommand					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMReGISCommand (state_table, command_buffer, 		*/
/*				end_of_buffer)				*/
/*									*/
/*	  ReGIS_state *state_table     --  state table for this process */
/*	  char	      *command_buffer  --  buffer containing ReGIS	*/
/*					       command 			*/
/*	  char        *end_of_buffer   --  last character in buffer	*/
/*									*/
/*	RETURNED VALUE:  none						*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function executes the ReGIS command in the buffer.	*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

void _EMReGISCommand (state_table, command_buffer, end_of_buffer)

ReGIS_state	*state_table;
char		*command_buffer;
char		*end_of_buffer;
{
	char		*next_char;	/* points to next char		*/
	int		command;	/* command code			*/
	static int	last_command;	/* previously executed command	*/

	/* The following is a string of chars which are to be treated	*/
	/* as whitespace (ignored) when parsing a command string.	*/
	static char	ignored_chars [] =
			" !#$%&*,./:;<=>?[\\]^_{|}~\n\t\v\b\r\f";


	/* Terminate the command string with a null character. */
	*(end_of_buffer + 1) = '\0';

	/* Set a pointer to the first valid character. */
	next_char = command_buffer + strspn (command_buffer, ignored_chars);

	/* Convert character to uppercase. */
	*next_char = toupper (*next_char);

	if (next_char <= end_of_buffer)	/* command character found */
	{
	    /* Determine which command is to be executed. */
	    switch (*next_char)
	    {
		case 'S':
		    command = SCREEN_COMMAND;
		    break;

		case 'W':
		    command = WRITE_COMMAND;
		    break;

		case '(':
		    command = last_command;
		    break;

		default:
		    command = COMMAND_ERROR;
		    break;
	    }


	    /* Execute the command. */
	    command_buffer = next_char + 1;

	    switch (command)
	    {
		case SCREEN_COMMAND:
		    _EMExecScreenCommand (state_table, command_buffer,
					  end_of_buffer);
		    break;

		case WRITE_COMMAND:
		    _EMExecWriteCommand (state_table, command_buffer, 
					 end_of_buffer);
		    break;

		case COMMAND_ERROR:
		    break;
	    }

	    last_command = command;
	}
}
