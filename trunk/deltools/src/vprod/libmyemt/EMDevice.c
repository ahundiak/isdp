#include <ctype.h>
#include "../hfiles/EMDefines.h"
#include "../hfiles/EMTCB.h"
#include "../hfiles/EMError.h"


void	_EMExecControlChar ();
int	_EMEnterReGIS ();
int	_EMChooseUDK ();
int	_EMDefineUDK ();
int	_EMEscLevelOne ();




/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMDeviceControl				*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int _EMDeviceControl (TCB, character)				*/
/*									*/
/*	  EM_TCB  *TCB;		-- pointer to active TCB		*/
/*	  char	  character;    -- second byte of an escape sequence    */
/*									*/
/*	DESCRIPTION:							*/
/*	  This function executes the next character of an escape	*/
/*	  sequence starting with DCS (device control string), or ESC P.	*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  A zero value is always returned.				*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

int _EMDeviceControl (TCB, character)

EM_TCB	*TCB;
char	character;
{
    if (isdigit (character))
    {
	*(TCB->esc_buff_ptr) = (*(TCB->esc_buff_ptr) * 10) +
				(int) (character - '0');
    }
    else
    {
	switch (character)
	{
	    case ';':
		if (TCB->esc_buff_ptr < &TCB->esc_seq_buffer[30])
			TCB->esc_buff_ptr++;
		*(TCB->esc_buff_ptr) = 0;
		break;

	    case 'p':
		/* Enter ReGIS mode. */
		if (_EMGetColorMode (&TCB->state_table) != BILEVEL) 
		    _EMEnterReGIS (TCB);
		TCB->within_esc_seq = FALSE;
		break;

	    case '|':
		/* User definable function keys */
		_EMEnterUDK (TCB);
		break;

	   default:
		/* If the character is a C0 control character, execute it. */
		/* Otherwise, discard the entire sequence.		   */
		if ((character > 0x00) && (character <= 0x1F))
		     _EMExecControlChar (TCB, character);
		else
		     TCB->within_esc_seq = FALSE;
	}
    }

    /* Return to caller. */
    return(EM_NO_ERROR);
}


/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMEnterReGIS					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int _EMEnterReGIS (TCB)					*/
/*									*/
/*	  EM_TCB  *TCB;		-- pointer to active TCB		*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function executes an "<ESC>Pnp" sequence, which		*/
/*	  causes the terminal to enter ReGIS mode.  If "n" is		*/
/*	  between '0' and '3' inclusive, ReGIS mode is entered at	*/
/*	  level "n."  If "n" is omitted, the command level is set	*/
/*	  to its previous value.					*/
/*									*/
/*	RETURNED VALUE:	 						*/
/*	  A value of zero is always returned.				*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*		     R. Dan Webb					*/
/*									*/
/************************************************************************/

int _EMEnterReGIS (TCB)

EM_TCB	*TCB;
{
    TCB->ReGIS_mode = TRUE;
    TCB->within_esc_seq = FALSE;

    switch (TCB->esc_seq_buffer[0])
    {
	case 0:
	case 1:
	case 2:
	case 3:
	    /* Set the command level. */
	    TCB->ReGIS_com_level = TCB->esc_seq_buffer[0] - '0';
	    _EMSetCommandLevel (&TCB->state_table, TCB->ReGIS_com_level);
	    break;
    }	

    /* Return to caller. */
    return (EM_NO_ERROR);
}



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMEnterUDK					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int _EMEnterUDK (TCB)						*/
/*									*/
/*	  EM_TCB  *TCB;		-- pointer to active TCB		*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function executes an "<ESC>Pm;n|" sequence, which	*/
/*	  causes the terminal to define user-definable function keys.	*/
/*	  If "m" is '0' or absent, all UDKs are cleared.  If "m" is 1,	*/
/*	  only the specified UDKs are redefined.			*/
/*	  If "n" is '0' or absent, UDKs are locked.  If "n" is 1, UDKs	*/
/*	  are unlocked.							*/
/*									*/
/*	RETURNED VALUE:	 						*/
/*	  A value of zero is always returned.				*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

int _EMEnterUDK (TCB)

EM_TCB	*TCB;
{
    int i;

    if (TCB->term_settings.udkLock == 1)
	TCB->term_settings.udkLock = 2;

    switch (TCB->esc_seq_buffer[0])
    {
	case 0:
	    /* Clear all previous UDKs if not locked */
	    if (TCB->term_settings.udkLock != 2)
	    {
		for (i = 0; i < 15; i++)
		{
		    if (TCB->udk[i] != NULL)
		    {
			free (TCB->udk[i]);
			TCB->udk[i] = NULL;
		    }
		}
	    }
	    break;

	case 1:
	    /* Don't clear UDKs */
	    break;
    }	

    switch (TCB->esc_seq_buffer[1])
    {
	case 0:
	    /* I'll really lock it when all UDKs have been defined */
	    if (TCB->term_settings.udkLock != 2)	/* already locked? */
		TCB->term_settings.udkLock = 1;
	    break;

	case 1:
	    break;
    }	

    TCB->esc_seq_buffer[0] = 0;
    TCB->esc_func = _EMChooseUDK;

    /* Return to caller. */
    return (EM_NO_ERROR);
}



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMChooseUDK					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int _EMChooseUDK (TCB)					*/
/*									*/
/*	  EM_TCB  *TCB;		-- pointer to active TCB		*/
/*	  char    character;	-- next character			*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function executes the portion of an "<ESC>Pm;n|"		*/
/*	  sequence that specifies the UDK to be defined.		*/
/*									*/
/*	RETURNED VALUE:	 						*/
/*	  A value of zero is always returned.				*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

int _EMChooseUDK (TCB, character)

EM_TCB	*TCB;
char	character;
{
    static int udk_table[] = { 0, 1, 2, 3, 4, -1, 5, 6, 7, 8, -1, 9, 10, -1,
			       11, 12, 13, 14 };

    if (isdigit (character))
    {
	TCB->esc_seq_buffer[0] = (TCB->esc_seq_buffer[0] * 10) +
				(int) (character - '0');
    }
    else
    {
	switch (character)
	{
	    case '/':
		if ((TCB->esc_seq_buffer[0] < 17) ||
		    (TCB->esc_seq_buffer[0] > 34) ||
		    (udk_table[TCB->esc_seq_buffer[0] - 17] < 0))
		{
		    TCB->within_esc_seq = FALSE;
		    break;
		}

		if (TCB->term_settings.udkLock != 2)	/* are UDKs locked? */
		{
		    TCB->udk_index = udk_table[TCB->esc_seq_buffer[0] - 17];
		    TCB->udk_char_ptr = TCB->udk[TCB->udk_index] =
							(char *) malloc (512);
		    *TCB->udk_char_ptr = 0;
		}
		TCB->udk_digit = 2;

		TCB->esc_func = _EMDefineUDK;
		break;

	    default:
		TCB->within_esc_seq = FALSE;
	}
    }	

    /* Return to caller. */
    return (EM_NO_ERROR);
}


/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMDefineUDK					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int _EMDefineUDK (TCB, character)				*/
/*									*/
/*	  EM_TCB  *TCB;		-- pointer to active TCB		*/
/*	  char    character;	-- next character			*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function executes the portion of an "<ESC>Pm;n|"		*/
/*	  sequence that specifies the new UDK string.			*/
/*									*/
/*	RETURNED VALUE:	 						*/
/*	  A value of zero is always returned.				*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

int _EMDefineUDK (TCB, character)

EM_TCB	*TCB;
char	character;
{
    if (isxdigit (character))
    {
	if (TCB->term_settings.udkLock != 2)
	    *(TCB->udk_char_ptr) = *(TCB->udk_char_ptr) * 16 +
				(isdigit (character) ? (character - '0') :
				isupper (character) ? (character - 'A' + 10) :
				(character - 'a' + 10));

	if (--TCB->udk_digit == 0)
	{
	    if (TCB->term_settings.udkLock != 2)
	    {
		TCB->udk_char_ptr++;
		*TCB->udk_char_ptr = 0;
	    }
	    TCB->udk_digit = 2;
	}
    }
    else
    {
	switch (character)
	{
	    case ';':
		_EMCompleteUDK (TCB);
		TCB->esc_seq_buffer[0] = 0;
		TCB->esc_func = _EMChooseUDK;
		break;

	    case ' ':
		_EMCompleteUDK (TCB);

		TCB->within_esc_seq = FALSE;

		/* Lock the UDKs if necessary */
		if (TCB->term_settings.udkLock == 1)
		    TCB->term_settings.udkLock = 2;

		break;

	    default:
		if (TCB->term_settings.udkLock != 2)
		{
		    free (TCB->udk[TCB->udk_index]);
		    TCB->udk[TCB->udk_index] = NULL;
		}
		TCB->term_settings.udkLock = 2;
		TCB->within_esc_seq = FALSE;
		break;
	}
    }	

    /* Return to caller. */
    return (EM_NO_ERROR);
}



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMCompleteUDK					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int _EMCompleteUDK (TCB)					*/
/*									*/
/*	  EM_TCB  *TCB;		-- pointer to active TCB		*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function completes the definition of the UDK currently	*/
/*	  being defined.						*/
/*									*/
/*	RETURNED VALUE:	 						*/
/*	  A value of zero is always returned.				*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

int _EMCompleteUDK (TCB)

EM_TCB	*TCB;
{
    int index;

    index = TCB->udk_index;
    if (TCB->term_settings.udkLock != 2)
    {
	if (TCB->udk_char_ptr == &TCB->udk[index][0])
	{
	    free (TCB->udk[index]);
	    TCB->udk[index] = NULL;
	}
	else
	{
	    TCB->udk[index] = (char *) realloc (TCB->udk[index],
			TCB->udk_char_ptr - TCB->udk[index] + 1);
	    *TCB->udk_char_ptr = '\0';
	}
    }

    return (EM_NO_ERROR);
}
