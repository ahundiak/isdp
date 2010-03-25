#include <string.h>
#include <malloc.h>
#include "../hfiles/EMDefines.h"
#include "../hfiles/EMTCB.h"
#include "../hfiles/EMChar.h"
#include "../hfiles/EMError.h"


/************************************************************************/
/*									*/
/*	Report Strings							*/
/*									*/
/*	The first character is always the ESCape character; it is	*/
/*	not included here.  The cursor position report is built		*/
/*	dynamically and is also not included.				*/
/*									*/
/************************************************************************/

static char  primary_report_regis[]	= "[?62;1;2;3;6;8c";
static char  primary_report_no_regis[]	= "[?62;1;2;6;8c";
static char  secondary_report[]		= "[>1;10;0c";
static char  terminal_status[]		= "[0n";
static char  printer_status_no[]	= "[?13n";
static char  printer_status_yes[]	= "[?10n";


/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMDAReport					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMDAReport (TCB)					*/
/*									*/
/*	  EM_TCB  *TCB;		-- pointer to active TCB		*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function processes "<ESC>[nc," "<ESC>[>nc," and 		*/
/*	  "<ESC>[Z" sequences, which cause a device attributes		*/
/*	  report to be returned.					*/
/*									*/
/*	RETURNED VALUE:	 none						*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

void _EMDAReport (TCB)

EM_TCB	*TCB;
{
	char	parameter;		/* escape sequence parameter	*/
	char	*report_ptr;		/* pointer into report buffer	*/
	char	*report;		/* pointer to the beginning of	*/
					/*  report to be returned	*/
	int	report_length;		/* length of report in bytes	*/


	/* Determine the type of report to be sent. */
	parameter = TCB->esc_seq_buffer[0];

	if (parameter == '>') 
	{
	    parameter = TCB->esc_seq_buffer[1];

	    if (parameter == 0)
		report = secondary_report;
	    else
		report = NULL;
	}
	else
	{
	    if (parameter == 0)
	    {
		if (_EMGetColorMode (&TCB->state_table) == BILEVEL)
		    report = primary_report_no_regis;
		else
		    report = primary_report_regis;
	    }
	    else	  
		report = NULL;
	}


	if (report)
	{
	    /* Find the report length. */
	    report_length = strlen (report) + 1;

	    /* Allocate storage for the report. */
	    if (TCB->report_count)
		TCB->report_buffer = (char *) realloc (TCB->report_buffer, 
					TCB->report_count + report_length);
	    else
		TCB->report_buffer = (char *) malloc (report_length);	


	    /* Copy the report to the report buffer. */
	    if (TCB->report_buffer)
	    {
		report_ptr = TCB->report_buffer + TCB->report_count;
		*report_ptr++ = ESC;
		strncpy (report_ptr, report, report_length - 1);
		TCB->report_count += report_length;
	    }
	    else
		printf ("ERROR:  could not allocate memory for DA report\n");
	}
}



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMDSRReport					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMDSRReport (TCB)					*/
/*									*/
/*	  EM_TCB  *TCB;		-- pointer to active TCB		*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function processes "<ESC>[nn" and  "<ESC>[?nn"  		*/
/*	  sequences, which cause a device status report (DSR) to be	*/
/*	  returned.  The currently supported sequences and the reports  */
/*	  they cause to be generated are given below.			*/
/*									*/
/*	       Sequence		Report					*/
/*	       --------		------					*/
/*	        ESC[5n		ESC[0n   (no malfunction)		*/
/*		ESC[6n		ESC[r;cR (cursor at row "r", 		*/
/*				            column "c")			*/
/*		ESC[?15n	ESC[?13n (no printer is connected)	*/
/*				   or					*/
/*				ESC[?10n (printer is ready)		*/
/*									*/
/*	RETURNED VALUE:	 none						*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

void _EMDSRReport (TCB)

EM_TCB	*TCB;
{
	char	parameter;		/* escape sequence parameter	*/
	char	cursor_position[9];	/* cursor position report:	*/
					/*  maximum of 9 characters	*/
					/*  minus ESC plus null char.	*/
	char	num_string[4];		/* string representing the row	*/
					/*  or column: maximum of 3 	*/
					/*  digits plus null char.	*/
	char	*report_ptr;		/* pointer into report buffer	*/
	char	*report;		/* pointer to the beginning of	*/
					/*  report to be returned	*/
	int	report_length;		/* length of report in bytes	*/


	/* Determine the type of report to be sent. */
	parameter = TCB->esc_seq_buffer[0];

	if (parameter == '?') 
	{
	    parameter = TCB->esc_seq_buffer[1];
	    switch (parameter)
	    {
		case 15:
		    /* Printer Status Report */
		    if (TCB->term_settings.printerMode == NO_PRINTER)
			report = printer_status_no;
		    else
			report = printer_status_yes;
		    break;

		default:
		    report = NULL;
	    }
	}
	else
	{
	    switch (parameter)
	    {
		case 5:
		    /* Terminal Status Report */
		    report = terminal_status;
		    break;

		case 6:
		    /* Build the cursor position report.  The initial	*/
		    /* ESCape character is not included. 		*/
		    report = cursor_position;
		    report_ptr = cursor_position;
		    *report_ptr++ = '[';

		    sprintf (num_string, "%d", TCB->current_line + 1);
		    strncpy (report_ptr, num_string, strlen (num_string));
		    report_ptr += strlen (num_string);
		    *report_ptr++ = ';';

		    sprintf (num_string, "%d", TCB->current_col + 1);
		    strncpy (report_ptr, num_string, strlen (num_string));
		    report_ptr += strlen (num_string);

		    *report_ptr++ = 'R';
		    *report_ptr = '\0';
		    break;

		default:
		    report = NULL;
	    }
	}


	if (report)
	{
	    /* Find the report length. */
	    report_length = strlen (report) + 1;

	    /* Allocate storage for the report. */
	    if (TCB->report_count)
		TCB->report_buffer = (char *) realloc (TCB->report_buffer, 
					TCB->report_count + report_length);
	    else
		TCB->report_buffer = (char *) malloc (report_length);	


	    /* Copy the report to the report buffer. */
	    if (TCB->report_buffer)
	    {
		report_ptr = TCB->report_buffer + TCB->report_count;
		*report_ptr++ = ESC;
		strncpy (report_ptr, report, report_length - 1);
		TCB->report_count += report_length;
	    }
	    else
		printf ("ERROR: could not allocate memory for DSR report\n");
	}
}	
