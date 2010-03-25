#include <fcntl.h>
#include <ctype.h>
#include "../hfiles/EMDefines.h"
#include "../hfiles/EMTCB.h"
#include "../hfiles/EMGlobals.h"
#include "../hfiles/EMChar.h"
#include "../hfiles/EMError.h"


int	_EMFilteredSequence ();


/************************************************************************/
/*									*/
/*	FUNCTION NAME:  EMSetPrinterPort				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int EMSetPrinterPort (TCBD, port)				*/
/*									*/
/*	  int  TCBD;	    -- TCB descriptor of terminal instance to	*/
/*			       whose parameter table is to be returned	*/
/*									*/
/*	  int  port;	    -- number of the auxilliary port to which   */
/*			       the printer is connected (0 - 2)		*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function associates the auxilliary port number "port"	*/
/*	  with all subsequent printing activities.  The printer mode	*/
/*	  of the indicated terminal instance is set to normal print	*/
/*	  mode.								*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  Upon successful completion, a value of zero is returned.	*/
/*	  Otherwise, a non-zero error code is returned.  Possible	*/
/*	  errors are:							*/
/*									*/
/*	  	1.  the auxilliary port number is out of range,		*/
/*									*/
/*		2.  the auxilliary port is not open.			*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

int EMSetPrinterPort (TCBD, port)

int     TCBD;
int     port;
{
    char	device[11];	/* device path to open			*/
    int		return_code;	/* status code returned to caller	*/
    int		fildes;		/* printer port file descriptor		*/

    return_code = 0;

    /* Check if the auxilliary port number is in range. */
    if ((port >= 0) && (port <= 2))
    {
	/* Check if the port is open. */
	sprintf (device, "/dev/tty0%d", port);
	if ((fildes = open (device, O_WRONLY)) != -1)
	{
	    /* Assign the port number and printer mode. */
	    EM_TCB_list[TCBD]->printer_port = fildes;
	    EM_TCB_list[TCBD]->term_settings.printerMode = NORMAL_MODE;
	}
	else
	{
	    /* The auxilliary port was not open. */
	    return_code = EM_PRINTER_PORT_NOT_OPEN;
	}
    }
    else			/* The auxilliary port number is out of
				   range. */
	return_code = EM_INVALID_PRINTER_PORT;

    /* Return to caller. */
    return (return_code);
}


/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMPrintScreen					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMPrintScreen (TCB, row, row_count, terminator)		*/
/*									*/
/*	  EM_TCB  *TCB;		-- pointer to active TCB		*/
/*	  int	  row;		-- pointer into the "row_order" array   */
/*				     to the first row to print		*/
/*	  int     row_count;	-- number of rows to print		*/
/*	  char	  terminator;   -- end of line terminator; lines end	*/
/*				     with carriage return and this	*/
/*				     terminator				*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function sends the specified number of rows to the	*/
/*	  printer port.							*/
/*									*/
/*	RETURNED VALUE:	 none						*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

void _EMPrintScreen (TCB, start_row, row_count, terminator)

EM_TCB	*TCB;
int	start_row;
int	row_count;
char	terminator;
{
    EMscreen_row *row_ptr;		/* ptr to current row being displayed */
    char	line_terminator[2];	/* end-of-line terminator	*/
    int		row;			/* index of row being displayed */
    int		last_row;		/* index of last row to display */


    line_terminator[0] = CR;
    line_terminator[1] = terminator;

    if (TCB->term_settings.printerMode != NO_PRINTER)
    {
	last_row = start_row + row_count - 1;

	for (row = start_row; row <= last_row; row++)
	{
	    /* Print the next line of text. */
	    row_ptr = &TCB->screen[TCB->row_order[row]];
	    write (TCB->printer_port, &row_ptr->character[0], TCB->col_width);

	    /* Transmit a carriage return and line feed. */
	    write (TCB->printer_port, line_terminator, 2);
	}

	/* If the entire screen was printed, check if a terminating	*/
	/* form feed was specified.					*/
	if ((row_count == TCB->displayed_rows) &&
	    (TCB->term_settings.printTerminator))
	    write (TCB->printer_port, "\f", 1);
    }
}



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMChangePrinterMode				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMChangePrinterMode (TCB)				*/
/*									*/
/*	  EM_TCB  *TCB;		-- pointer to active TCB		*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function processes "<ESC>[ni" and "<ESC>[?ni" sequences. */
/*	  These sequences change the printer mode or cause a portion	*/
/*	  or the screen matrix to be transmitted to the printer.	*/
/*	  Actions performed for permissible sequences are given below:  */
/*									*/
/*	       Sequence		Action					*/
/*	       --------		------					*/
/*	       ESC[i		prints the entire screen matrix		*/
/*	       ESC[?1i		prints the current line			*/
/*	       ESC[4i		turns off printer controller mode	*/
/*	       ESC[5i		turns on printer controller mode	*/
/*	       ESC[?4i		turns off auto print mode		*/
/*	       ESC[?5i		turns on auto print mode		*/
/*									*/
/*	  If "n" is ommited, the action for n = 0 is taken.  		*/
/*									*/
/*	  If the printer mode is NO_PRINTER, these sequences are	*/
/*	  ignored.							*/
/*									*/
/*	RETURNED VALUE:	 none						*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*									*/
/************************************************************************/

void _EMChangePrinterMode (TCB)

EM_TCB	*TCB;
{
    int pid;	/* returned by print screen fork */

    if (TCB->term_settings.printerMode != NO_PRINTER)
    {
	if (*TCB->esc_buff_ptr == '?')
	{
	    TCB->esc_buff_ptr++;

	    switch (*TCB->esc_buff_ptr)
	    {
		case 1:		/* Print the current line. */
		    _EMPrintScreen (TCB, TCB->current_line, 1, LF);
		    break;

		case 4: 	/* Turn off auto print mode. */
		    if (TCB->term_settings.printerMode == AUTO_MODE)
			TCB->term_settings.printerMode = NORMAL_MODE;
		    break;

		case 5: 	/* Turn on auto print mode. */
		    TCB->term_settings.printerMode = AUTO_MODE;
		    break;
	    }
	}
	else
	{
	    switch (*TCB->esc_buff_ptr)
	    {
		case 0: 	/* Print the entire screen matrix. */
		    if ((pid = fork()) <= 0)	/* spool it */
		    {
			_EMPrintScreen (TCB, 0, TCB->displayed_rows, LF);
			if (pid == 0)
			    exit();
		    }
		    break;

		case 5: 	/* Turn on printer controller mode. */
		    TCB->term_settings.printerMode = PRINTER_CONTROLLER_MODE;
		    break;
	    }
	}
    }
}



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMDataToPrinter				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  void _EMDataToPrinter (TCB, buffer, count)			*/
/*									*/
/*	  EM_TCB  *TCB;		-- pointer to active TCB		*/
/*	  char    **buffer;	-- pointer to pointer to buffer of	*/
/*				   data to be sent to printer		*/
/*	  int	 *count;	-- pointer to number of characters	*/
/*				   in buffer				*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function sends a buffer of data to the printer.  The	*/
/*	  XON,  XOFF, and NUL characters and ESC[5i and ESC[4i escape	*/
/*	  sequences are filtered out and are not sent.   		*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  none								*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*		     R. Dan Webb					*/
/*									*/
/************************************************************************/

void _EMDataToPrinter (TCB, buffer, count)

EM_TCB		*TCB;
unsigned char	**buffer;
int		*count;
{
    int			chars_processed, done;
    unsigned char	*next_char, *string_start;

    next_char = *buffer;
    chars_processed = 0;
    string_start = *buffer;
    done = FALSE;

    while (*count && !done)
    {
	if (TCB->within_esc_seq)
	{
	    /* Check for an escape sequence terminator. */
	    if (_EMSequenceTerminated (TCB, *next_char))
	    {
		*TCB->esc_buff_ptr = *next_char;
		TCB->within_esc_seq = FALSE;

		if (_EMFilteredSequence (TCB))
		{
		    if (TCB->esc_seq_buffer[2] == '4')
		    {
			TCB->term_settings.printerMode = NORMAL_MODE;
			done = TRUE;
		    }
		}
		else
		{
		    write (TCB->printer_port, TCB->esc_seq_buffer,
			   TCB->esc_buff_ptr - TCB->esc_seq_buffer + 1);
		    string_start = next_char + 1;
		    chars_processed = 0;
		}
	    }
	    else
		*(TCB->esc_buff_ptr++) = *next_char;
	}
	else
	{
	    if ((*next_char == XON) || (*next_char == XOFF) ||
		(*next_char == NUL) || (*next_char == ESC) ||
		(*next_char == CSI))
	    {
		write (TCB->printer_port, string_start, chars_processed);
		chars_processed = 0;
		string_start = next_char + 1;

		if ((*next_char == ESC) || (*next_char == CSI))
		{
		    TCB->within_esc_seq = TRUE;
		    TCB->esc_buff_ptr = TCB->esc_seq_buffer;
		    *(TCB->esc_buff_ptr++) = ESC;

		    if (*next_char == CSI)
			*(TCB->esc_buff_ptr++) = '[';
		}
	    }
	    else
		chars_processed++;
	}

	/* Point to the next character. */
	next_char++;

	(*count)--;
    }

    if (chars_processed)
	write (TCB->printer_port, string_start, chars_processed);

    *buffer = next_char;
}



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMFilteredSequence				*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function return true if the escape sequence buffer	*/
/*	  an ESC[4i or ESC[5i sequence.  These sequences are not	*/
/*	  sent to the printer.						*/
/*									*/
/************************************************************************/

int _EMFilteredSequence (TCB)

EM_TCB	*TCB;
{
    int	return_code;

/****
	int	i;
	int	n;
	n = TCB->esc_buff_ptr - TCB->esc_seq_buffer + 1;
	printf ("<ESC>");
	for (i = 1; i < n; i++)
	    printf ("%c", TCB->esc_seq_buffer[i]);	
	printf ("\n");
****/

    if (TCB->esc_seq_buffer[1] == '[')
	if ((TCB->esc_seq_buffer[2] == '4') || (TCB->esc_seq_buffer[2] == '5'))
	    if (TCB->esc_seq_buffer[3] == 'i')
		return_code = 1;
	    else
		return_code = 0;
	else
	    return_code = 0;
    else
	return_code = 0;

    return (return_code);
}


/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMSequenceTerminated				*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function return true if the received character is a	*/
/*	  valid escape sequence terminator.				*/
/*									*/
/************************************************************************/

int _EMSequenceTerminated (TCB, character)

EM_TCB	*TCB;
char	character;
{
    if (isalpha (character) || (character == '@') || (character == '<') ||
	(character == '=') || (character == '>') || (character == '~') ||
	(*(TCB->esc_buff_ptr - 1) == '#') ||
	((*(TCB->esc_buff_ptr - 1) == ESC) && ((character == '7') ||
	 (character == '8'))))
	return (TRUE);
    else
	return (FALSE);
}
