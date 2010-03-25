#include <malloc.h>
#include "../hfiles/EMDefines.h"
#include "../hfiles/EMTCB.h"
#include "../hfiles/EMChar.h"
#include "../hfiles/EMGlobals.h"
#include "../hfiles/EMError.h"


#define	 ESC_BRACKET	0x04

/* Function key sequence prefix */
#define	FUNCTION_CODE   0xFE

/* The following definitions give the code for the second byte of their */
/* respective key sequences  (e.g. HOME = 0xFC 0x0F)			*/
#define	CLEAR_SCREEN	0x08
#define	PRINT_SCREEN	0x09
#define	HOME		0x0F
#define	SET_UP		0x0E

#define	HOLD_SCREEN	0x82	/* keycode for the "hold screen" key	*/


void _EMPut8BitChar ();


/************************************************************************/
/*									*/
/*	FUNCTION NAME:  EMTranslateKeys					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int EMTranslateKeys (TCBD, in_buf, in_count, out_buf,		*/
/*			       out_count, break_key)			*/
/*									*/
/*	  int	TCBD;		-- TCB descriptor of active terminal	*/
/*				   instance				*/
/*									*/
/*	  Char8	*in_buf;	-- buffer of raw keyboard data		*/
/*									*/
/*	  int	in_count;	-- number of bytes of keyboard data	*/
/*									*/
/*	  Char8	**out_buf;	-- buffer of translated data		*/
/*									*/
/*	  int	*out_count;	-- number of bytes of translated data	*/
/*									*/
/*	  int	*break_key;	-- returned flag indicating whether or	*/
/*				   not the "break" keycode was present	*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function accepts a buffer of raw keyboard data and	*/
/*	  translates it into host-interpretable ASCII codes and		*/
/*	  escape sequences.  The output buffer is allocated using	*/
/*	  malloc().  The number of bytes in the output buffer		*/
/*	  is returned.  This function also checks the input buffer to	*/
/*	  see if any of the following keys have been pressed: "home,"	*/
/*	  "clear screen," "setup," or "break."  If the "break" key is	*/
/*	  sensed, a flag is set and returned to the caller.  If any	*/
/*	  of the other keys are sensed, the appropriate action is	*/
/*	  performed.							*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  A value of zero is always returned.				*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*		     R. Dan Webb					*/
/*									*/
/************************************************************************/

int EMTranslateKeys (TCBD, in_buf, in_count, out_buf, out_count, break_key)
int	TCBD;
Char8	*in_buf;
int	in_count;
Char8	**out_buf;
int	*out_count;
int	*break_key;
{
    int maxSize;	/* maximum size for translated character data	*/
    int	status;

    /* Allocate a translation buffer. The size must be big enough to	*/
    /* hold any macro key translations, but not too awfully big.  There	*/
    /* is no maximum size for a macro, so this is a little dangerous.	*/

    maxSize = MIN (in_count * 128, 8192);
    maxSize = MAX (maxSize, in_count * 2);
    *out_buf = (Char8 *) malloc (maxSize);

    /* Translate the keyboard data */
    status = EMTranslate (TCBD, in_buf, in_count, *out_buf,
				 out_count, break_key);

    /* Reallocate the translated buffer */
    *out_buf = (Char8 *) realloc (*out_buf, *out_count);

    return (status);
}



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  EMTranslate					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int EMTranslate (TCBD, in_buf, in_count, out_buf, out_count, 	*/
/*			   break_key)					*/
/*									*/
/*	  int   TCBD	     -- TCB descriptor of active terminal	*/
/*				instance				*/
/*									*/
/*	  Char8	*in_buf;    -- buffer of raw keyboard data		*/
/*									*/
/*	  int	in_count;    -- number of bytes of keyboard data	*/
/*									*/
/*	  Char8	*out_buf;   -- buffer of translated data		*/
/*									*/
/*	  int	*out_count;  -- number of bytes of translated data      */
/*									*/
/*	  int	*break_key;  -- returned flag indicating whether or	*/
/*				not the "break" keycode was present	*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function accepts a buffer of raw keyboard data and	*/
/*	  translates it into host-interpretable ASCII codes and		*/
/*	  escape sequences.  The number of bytes in the output buffer	*/
/*	  is returned.  This function also checks the input buffer to	*/
/*	  see if any of the following keys have been pressed: "home,"	*/
/*	  "clear screen," "setup," or "break."  If the "break" key is	*/
/*	  sensed, a flag is set and returned to the caller.  If any	*/
/*	  of the other keys are sensed, the appropriate action is	*/
/*	  performed.							*/
/*									*/
/*	NOTES								*/
/*	  The synopsis of this routine is made obsolete by		*/
/*	  EMTranslateKeys().						*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  A value of zero is always returned.				*/
/*									*/
/*	PROGRAMMER:  Ron Stewart					*/
/*		     R. Dan Webb					*/
/*									*/
/************************************************************************/

int EMTranslate (TCBD, in_buf, in_count, out_buf, out_count, break_key)
int	TCBD;
Char8	*in_buf;
int	in_count;
Char8	*out_buf;
int	*out_count;
int	*break_key;
{
    EM_TCB	*TCB;		/* pointer to the TCB for this		*/
				/*   terminal instance			*/
    int		found;		/* indicates that a particular		*/
				/*   function or editing key was	*/
				/*   found				*/
    Char8	*inBufEnd;	/* end of input buffer			*/
    Char8	currChar;	/* current character in the buffer	*/
    Char8	*outbuf;	/* pointer to current output buffer	*/
    Char8	local_buf[4096];	/* buffer for local mode	*/
    Char8	*local_ptr;
    Char8	macro[4096];	/* macro string				*/
    Char8	*unused1;	/* unused values returned by		*/
    int		unused2;	/*   "EMWrite"				*/
    int		pid;		/* returned by print screen fork	*/
    int		count;		/* size of macro			*/
    int		index;		/* UDK index				*/


    /* Miscellaneous Initializations. */
    TCB = EM_TCB_list[TCBD];
    local_ptr = &local_buf[0];
    *out_count = 0;
    *break_key = FALSE;

    /* Point to the proper output buffer. */
    if (TCB->term_settings.online)
	outbuf = out_buf;
    else
	outbuf = local_ptr;


    inBufEnd = &in_buf[in_count];
    while (in_buf < inBufEnd)
    {
	currChar = *in_buf++;

	if (TCB->within_func_key)
	{
	    /* The character is the second byte of a function key sequence */
	    TCB->within_func_key = FALSE;

	    /* Check to see if macro is mapped to this function key */
	    if (TCB->macroEnable &&
		EMGetMacro (TCBD, currChar + 256, macro, &count))
	    {
		int	transCount;

		/* Translate the macro keys to the appropriate keys */
		TCB->macroEnable = FALSE;	/* prevent recusive macros */
		EMTranslate (TCBD, macro, count, outbuf, &transCount);
		TCB->macroEnable = TRUE;

		(*out_count) += transCount;
		outbuf += transCount;
		continue;
	    }
	    else
	    {
		if (currChar == SET_UP)
		{
		    EMSetup (TCBD);
		}
		else if (currChar == CLEAR_SCREEN)
		{
		    _EMSetClipBox (TCB, 0, 0, -1, -1);
		    _EMGraphicsNormal (TCB);
		    hidecursor (TCB->window);
		    _EMClearScreenMatrix (TCB);
		    _EMClearScreen (TCB);
		    _EMDisplayScreen (TCB, 0, TCB->displayed_rows,
				      0, TCB->col_width, TRUE);

		    if (TCB->term_settings.cursorOrigin)
			_EMUpdatePosAbsolute (TCB, TCB->top_scroll, 0);
		    else
			_EMUpdatePosAbsolute (TCB, 0, 0);

		    _EMDrawCursor (TCB);
		    showcursor (TCB->window);
		    flushbuffer (TCB->window);
		    _EMRestoreClipBox (TCB);
		}
		else if (currChar == HOME)
		{
		    hidecursor (TCB->window);
		    _EMEraseCursor (TCB);

		    if (TCB->term_settings.cursorOrigin)
			_EMUpdatePosAbsolute (TCB, TCB->top_scroll, 0);
		    else
			_EMUpdatePosAbsolute (TCB, 0, 0);

		    _EMDrawCursor (TCB);
		    showcursor (TCB->window);
		    flushbuffer (TCB->window);
		}
		else if (currChar == PRINT_SCREEN)
		{
		    pid = fork ();
		    if (pid <= 0)
		    {
			_EMPrintScreen (TCB, 0, TCB->displayed_rows, LF);
			if (pid == 0)
			    exit ();
		    }
		}
		else if (TCB->term_settings.online && TCB->term_settings.vt200)
		{
		    int		oldOutCount;
		    Char8	*oldOutBuf;

		    /* Save outbuf & *out_count for later */
		    oldOutBuf = outbuf;
		    oldOutCount = *out_count;

		    _EMPut8BitChar (TCB, CSI, &outbuf, out_count);

		    found = TRUE;
		    switch (currChar)
		    {
			case 0x04: 
			case 0x0C: 
			    /* FIND key */
			    *outbuf++ = '1';
			    break;

			case 0x05: 
			case 0x0D: 
			    /* INSERT key */
			    *outbuf++ = '2';
			    break;

			case 0x06: 
			    /* REMOVE key */
			    *outbuf++ = '3';
			    break;

			case 0x01: 
			    /* SELECT key */
			    *outbuf++ = '4';
			    break;

			case 0x0A: 
			    /* BREAK key */
			    *break_key = TRUE;
			    outbuf -= 2;
			    (*out_count) -= 2;
			    continue;

			case 0x02: 
			case 0x0B: 
			    /* PREV SCREEN key */
			    *outbuf++ = '5';
			    break;

			case 0x03: 
			case 0x86: 
			    /* NEXT SCREEN key */
			    *outbuf++ = '6';
			    break;

			default: 
			    found = FALSE;
			    break;
		    }

		    if (found)
		    {
			/* Append a tilde to the host data */
			/* and update the output count.    */
			*outbuf++ = TILDE;
			(*out_count) += 2;
			continue;
		    }

		    /* Function key sequence was not an  */
		    /* editing key; check function keys. */
		    found = TRUE;

		    switch (currChar)
		    {
			case 0x4e: 	/* F6 */
			case 0x2e: 
			case 0x10: 
			    *outbuf++ = 0x31;
			    *outbuf++ = 0x37;
			    break;

			case 0x50: 	/* F7 */
			case 0x30: 
			case 0x12: 
			    *outbuf++ = 0x31;
			    *outbuf++ = 0x38;
			    break;

			case 0x52: 	/* F8 */
			case 0x32: 
			case 0x14: 
			    *outbuf++ = 0x31;
			    *outbuf++ = 0x39;
			    break;

			case 0x54: 	/* F9 */
			case 0x34: 
			case 0x16: 
			    *outbuf++ = 0x32;
			    *outbuf++ = 0x30;
			    break;

			case 0x56: 	/* F10 */
			case 0x36: 
			case 0x18: 
			    *outbuf++ = 0x32;
			    *outbuf++ = 0x31;
			    break;

			case 0x58: 	/* F11 */
			case 0x38: 
			case 0x1A: 
			    *outbuf++ = 0x32;
			    *outbuf++ = 0x33;
			    break;

			case 0x5A: 	/* F12 */
			case 0x3A: 
			case 0x1C: 
			    *outbuf++ = 0x32;
			    *outbuf++ = 0x34;
			    break;

			case 0x5C: 	/* F13 */
			case 0x3C: 
			case 0x1E: 
			    *outbuf++ = 0x32;
			    *outbuf++ = 0x35;
			    break;

			case 0x5E: 	/* F14 */
			case 0x3E: 
			case 0x20: 
			    *outbuf++ = 0x32;
			    *outbuf++ = 0x36;
			    break;

			case 0x60: 	/* F15 */
			case 0x40: 
			case 0x22: 
			case 0x07:	/* Help key */
			    *outbuf++ = 0x32;
			    *outbuf++ = 0x38;
			    break;

			case 0x62: 	/* F16 */
			case 0x42: 
			case 0x24: 
			    *outbuf++ = 0x32;
			    *outbuf++ = 0x39;
			    break;

			case 0x64: 	/* F17 */
			case 0x44: 
			case 0x26: 
			    *outbuf++ = 0x33;
			    *outbuf++ = 0x31;
			    break;

			case 0x66: 	/* F18 */
			case 0x46: 
			case 0x28: 
			    *outbuf++ = 0x33;
			    *outbuf++ = 0x32;
			    break;

			case 0x68: 	/* F19 */
			case 0x48: 
			case 0x2A: 
			    *outbuf++ = 0x33;
			    *outbuf++ = 0x33;
			    break;

			case 0x6A: 	/* F20 */
			case 0x4A: 
			case 0x2C: 
			    *outbuf++ = 0x33;
			    *outbuf++ = 0x34;
			    break;

			default: 
			    found = FALSE;
			    break;
		    }

		    if (found)
		    {
			*outbuf++ = TILDE;
			*out_count += 3;
			continue;
		    }
		    else
		    {
			outbuf = oldOutBuf;
			*out_count = oldOutCount;
		    }

		    /* Check for shifted function keys (UDKs) */
		    found = TRUE;

		    switch (currChar)
		    {
			case 0x4f:	/* shift F6 */
			case 0x2f:
			case 0x11:
			    index = 0;
			    break;

			case 0x51:	/* shift F7 */
			case 0x31:
			case 0x13:
			    index = 1;
			    break;

			case 0x53:	/* shift F8 */
			case 0x33:
			case 0x15:
			    index = 2;
			    break;

			case 0x55:	/* shift F9 */
			case 0x35:
			case 0x17:
			    index = 3;
			    break;

			case 0x57:	/* shift F10 */
			case 0x37:
			case 0x19:
			    index = 4;
			    break;

			case 0x59:	/* shift F11 */
			case 0x39:
			case 0x1B:
			    index = 5;
			    break;

			case 0x5B:	/* shift F12 */
			case 0x3B:
			case 0x1D:
			    index = 6;
			    break;

			case 0x5D:	/* shift F13 */
			case 0x3D:
			case 0x1F:
			    index = 7;
			    break;

			case 0x5F:	/* shift F14 */
			case 0x3F:
			case 0x21:
			    index = 8;
			    break;

			case 0x61:	/* shift F15 */
			case 0x41:
			case 0x23:
			    index = 9;
			    break;

			case 0x63:	/* shift F16 */
			case 0x43:
			case 0x25:
			    index = 10;
			    break;

			case 0x65:	/* shift F17 */
			case 0x45:
			case 0x27:
			    index = 11;
			    break;

			case 0x67:	/* shift F18 */
			case 0x47:
			case 0x29:
			    index = 12;
			    break;

			case 0x69:	/* shift F19 */
			case 0x49:
			case 0x2B:
			    index = 13;
			    break;

			case 0x6B:	/* shift F20 */
			case 0x4B:
			case 0x2D:
			    index = 14;
			    break;

			default:
			    found = FALSE;
			    break;
		    }

		    if (found)
		    {
			if (TCB->udk[index] != NULL)
			{
			    strcpy (outbuf, TCB->udk[index]);
			    outbuf += strlen (TCB->udk[index]);
			    (*out_count) += strlen (TCB->udk[index]);
			}
		    }
		}
		else if (!TCB->term_settings.vt200 && TCB->term_settings.online)
		{
		    switch (currChar)
		    {
			case 0x58:	/* F11 = ESC */
			case 0x59:
			case 0x38:
			case 0x39:
			case 0x1A:
			case 0x1B:
			    *outbuf++ = ESC;
			    (*out_count)++;
			    break;

			case 0x5A:	/* F12 = BS */
			case 0x5B:
			case 0x3A:
			case 0x3B:
			case 0x1C:
			case 0x1D:
			    *outbuf++ = BS;
			    (*out_count)++;
			    break;

			case 0x5C:	/* F13 = LF */
			case 0x5D:
			case 0x3C:
			case 0x3D:
			case 0x1E:
			case 0x1F:
			    *outbuf++ = LF;
			    (*out_count)++;
			    break;
		    }
		}
	    }
	}
	else if (TCB->withinCursorKey)
	{
	    TCB->withinCursorKey = FALSE;

	    /* Check to see if macro is mapped to this function key */
	    if (TCB->macroEnable &&
		EMGetMacro (TCBD, currChar + 384, macro, &count))
	    {
		int	transCount;

		/* Translate the macro keys to the appropriate keys */
		TCB->macroEnable = FALSE;	/* prevent recusive macros */
		EMTranslate (TCBD, macro, count, outbuf, &transCount);
		TCB->macroEnable = TRUE;

		(*out_count) += transCount;
		outbuf += transCount;
		continue;
	    }
	    else
	    {
		/* Table for converting keypad key sequences to the	*/
		/* necessary characters when in numeric keypad mode	*/
		static Char8	tableStart = 0x41;
		static Char8	keypadTable[] = {
		/* 41 */	0, 0, 0, 0, 0, 0, 0,
				0, 0, 0, 0, 0, 0x0D, 0, 0,
		/* 50 */	1, 1, 1, 1, 0, 0, 0, 0,
				0, 0, 0, 0, 0, 0, 0, 0,
		/* 60 */	0, 0, 0, 0, 0, 0, 0, 0,
				0, 0, 0, 0, ',', '-', '.', 0,
		/* 70 */	'0', '1', '2', '3', '4', '5', '6', '7',
				'8', '9',
		};
		Char8	tableKey;

		tableKey = keypadTable[currChar - tableStart];
		if (tableKey == 0)	/* cursor key? */
		{
		    _EMPut8BitChar (TCB,
			(TCB->term_settings.normalCursorKeys ? CSI : SS3),
			&outbuf, out_count);
		    *outbuf++ = currChar;
		    (*out_count)++;
		}
		else if (tableKey == 1)	/* keypad function key? (PF1, etc.) */
		{
		    _EMPut8BitChar (TCB, SS3, &outbuf, out_count);
		    *outbuf++ = currChar;
		    (*out_count)++;
		}
		else	/* numeric keypad key */
		{
		    if (TCB->term_settings.numericKeypad)
		    {
			*outbuf++ = tableKey;
			(*out_count)++;
		    }
		    else
		    {
			_EMPut8BitChar (TCB, SS3, &outbuf, out_count);
			*outbuf++ = currChar;
			(*out_count)++;
		    }
		}
	    }
	}
	else
	{
	    /* If the character is the first byte of a function	*/
	    /* key sequence, set a flag and continue.		*/
	    if (currChar == FUNCTION_CODE)
	    {
		TCB->within_func_key = 1;
		continue;
	    }

	    /* If the character is the first byte of a keypad/cursor	*/
	    /* key sequence, set a flag and continue.			*/
	    if (currChar == SS3)
	    {
		TCB->withinCursorKey = TRUE;
		continue;
	    }

	    /* Check to see if a macro is mapped to this character */
	    if (TCB->macroEnable &&
		EMGetMacro (TCBD, currChar, macro, &count))
	    {
		int	transCount;

		/* Translate the macro keys to the appropriate keys */
		TCB->macroEnable = FALSE;	/* prevent recusive macros */
		EMTranslate (TCBD, macro, count, outbuf, &transCount);
		TCB->macroEnable = TRUE;

		(*out_count) += transCount;
		outbuf += transCount;
		continue;
	    }
	    else
	    {
		if (currChar == HOLD_SCREEN)
		{
		    if (TCB->hold_status == XON)
		    {
			*outbuf++ = XOFF;
			TCB->hold_status = XOFF;

			/* Turn on "keyboard locked" LED. */
			Keybdled (0x1, 0x1);
		    }
		    else
		    {
			*outbuf++ = XON;
			TCB->hold_status = XON;

			/* Turn off "keyboard locked" LED. */
			Keybdled (0x0, 0x1);
		    }
		    (*out_count)++;
		}
		else
		{
		    _EMPut8BitChar (TCB, currChar, &outbuf, out_count);

		    /* If the current "hold status" is XOFF, any   */
		    /* keyboard input changes it to XON and turns  */
		    /* off the "keyboard locked LED.	       */
		    if (TCB->hold_status == XOFF)
		    {
			TCB->hold_status = XON;
			Keybdled (0x0, 0x1);
		    }
		}
	    }
	}
    }				/* end while */


    /* If the terminal is in local mode, send the data to the screen	*/
    /* and set the returned output count to zero so the caller does	*/
    /* not try to transmit anything to the host.			*/
    if (!TCB->term_settings.online)
    {
	EMWrite (TCBD, local_buf, *out_count, &unused1, &unused2);
	*out_count = 0;
    }
    else if (TCB->term_settings.localEcho)
	EMWrite (TCBD, out_buf, *out_count, &unused1, &unused2);

    /* Return to caller. */
    return (EM_NO_ERROR);
}



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMPut8BitChar					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  static void _EMPut8BitChar (TCB, chr, outbuf, out_count)	*/
/*									*/
/*	  EM_TCB	*TCB;		-- pointer to TCB		*/
/*									*/
/*	  Char8		chr;		-- 8-bit character		*/
/*									*/
/*	  Char8		**out_buf;	-- buffer of translated data	*/
/*									*/
/*	  int		*out_count;	-- number of chars of		*/
/*					   translated data		*/
/*									*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function handles 8-bit characters.  If the TCB is set to	*/
/*	  8-bit, it puts the character into the buffer.  If not, and	*/
/*	  the character is CSI or SS3, it puts the 7-bit equivalent	*/
/*	  into the buffer.  Otherwise, it discards the character.	*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  None.								*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

static void _EMPut8BitChar (TCB, chr, outbuf, out_count)

EM_TCB	*TCB;
Char8	chr;
Char8	**outbuf;
int	*out_count;
{
    int	C1Ctrl;		/* T => 8-bit ctrl char */

    if ((chr & 0x80) == 0)	/* 7-bit char? */
	goto OutChar;
    else
    {
	C1Ctrl = ((chr == SS3) || (chr == CSI));
	if (TCB->term_settings.bit8)
	{
	    if (TCB->translateC1 && C1Ctrl)
	    {
TransC1:	*(*outbuf)++ = ESC;
		*(*outbuf)++ = chr - 0x40;
		(*out_count) += 2;
	    }
	    else
	    {
OutChar:	*(*outbuf)++ = chr;
		(*out_count)++;
	    }
	}
	else if (C1Ctrl)
	    goto TransC1;
    }
}



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  EMGetMacro					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int EMGetMacro (TCBD, key, macro, size)			*/
/*									*/
/*	  int		TCBD;	-- TCB descriptor of terminal instance	*/
/*									*/
/*	  int		key;	-- keyboard key:			*/
/*				    normal key:		as is		*/
/*				    function key:	2nd char + 256	*/
/*				    keypad/arrow key:	2nd char + 384	*/
/*									*/
/*	  Char8		*macro;	-- returned 8-bit macro			*/
/*									*/
/*	  int		*size;	-- number of chars in the macro		*/
/*									*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function checks to see if the given keyboard character	*/
/*	  is mapped to a macro string.  If so, it is packed into 8-bit	*/
/*	  character and returned in *macro, its size (in 8-bit		*/
/*	  characters) is returned in *size, and TRUE is returned;	*/
/*	  otherwise, FALSE is returned.  If macro is NULL, no data is	*/
/*	  copied, but the size is still returned.			*/
/*									*/
/*	NOTE								*/
/*	  The returned macro IS automatically null-terminated, so	*/
/*	  (*size + 1) bytes must be allocated.				*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  TRUE iff key is mapped to a macro string.			*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

int EMGetMacro (TCBD, key, macro, size)

int	TCBD;
int	key;
Char8	*macro;
int	*size;
{
    int		size16;
    Char16	*macro16, *endMacro16, *ptr16, chr16;

    if (_EMGetMacro (TCBD, key, NULL, &size16))
    {
	/* Allocate space for the macro */
	macro16 = (Char16 *) malloc ((size16 + 1) * sizeof (Char16));
	_EMGetMacro (TCBD, key, macro16, &size16);

	/* Convert from 16-bit character to packed 8-bit */
	*size = 0;
	endMacro16 = &macro16[size16];
	for (ptr16 = macro16; ptr16 < endMacro16; ptr16++)
	{
	    chr16 = *ptr16;
	    if (chr16 >= 256)
	    {
		(*size) += 2;
		if (macro != NULL)
		{
		    *macro++ = (chr16 >= 384) ? SS3 : FUNCTION_CODE;
		    *macro++ = (Char8) (chr16 - ((chr16 >= 384) ? 384 : 256));
		}
	    }
	    else
	    {
		(*size)++;
		if (macro != NULL)
		    *macro++ = (Char8) *ptr16;
	    }
	}

	/** Null-terminate the macro **/
	if (macro != NULL)
	    *macro = '\0';

	free (macro16);
	return (TRUE);
    }
    else
	return (FALSE);
}




/************************************************************************/
/*									*/
/*	FUNCTION NAME:  EMSetMacro					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int EMSetMacro (TCB, key, macro)				*/
/*									*/
/*	  int		TCBD;	-- TCB descriptor of terminal instance	*/
/*									*/
/*	  int		key;	-- keyboard key:			*/
/*				    normal key:		as is		*/
/*				    function key:	2nd char + 256	*/
/*				    keypad/arrow key:	2nd char + 384	*/
/*									*/
/*	  Char8		*macro;	-- macro string (packed 8-bit chars)	*/
/*									*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function assigns the given macro string (8-bit) to the	*/
/*	  specified keyboard character.  From now on, typing the	*/
/*	  character is equivalent to typing the macro string.		*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  A non_zero value is returned if key is not a valid keyboard	*/
/*	  character.							*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

int EMSetMacro (TCBD, key, macro)

int	TCBD;
int	key;
Char8	*macro;
{
    int		len;
    Char8	chr, *ptr, *endMacro;
    Char16	*macro16, *ptr16;

    if (macro == NULL)
	_EMSetMacro (TCBD, key, NULL);
    else
    {
	len = strlen (macro);
	macro16 = (Char16 *) malloc ((len + 1) * sizeof (Char16));

	endMacro = &macro[len];
	for (ptr = macro, ptr16 = macro16; ptr < endMacro; ptr16++)
	{
	    chr = *ptr++;
	    if ((chr == 0xFE) || (chr == 0x8F))
		*ptr16 = ((chr == 0xFE) ? 256 : 384) + (Char16) *ptr++;
	    else
		*ptr16 = (Char16) chr;
	}
	*ptr16 = 0;

	_EMSetMacro (TCBD, key, macro16);
	free (macro16);
    }

    return (EM_NO_ERROR);
}



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMGetMacro					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int _EMGetMacro (TCBD, key, macro, size)			*/
/*									*/
/*	  int		TCBD;	-- TCB descriptor of terminal instance	*/
/*									*/
/*	  int		key;	-- keyboard key:			*/
/*				    normal key:		as is		*/
/*				    function key:	2nd char + 256	*/
/*				    keypad/arrow key:	2nd char + 384	*/
/*									*/
/*	  Char16	*macro;	-- returned macro (16-bit characters)	*/
/*									*/
/*	  int		*size;	-- number of 16-bit chars in macro	*/
/*									*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function checks to see if the given keyboard character	*/
/*	  is mapped to a macro string.  If so, it is returned in	*/
/*	  *macro, its size is returned in *size, and TRUE		*/
/*	  is returned; otherwise, FALSE is returned.  If macro is	*/
/*	  NULL, no data is copied, but the size is still returned.	*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  TRUE iff key is mapped to a macro string.			*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

int _EMGetMacro (TCBD, key, macro, size)

int	TCBD;
int	key;
Char16	*macro;
int	*size;
{
    EM_TCB	*TCB;

    TCB = EM_TCB_list[TCBD];

    if ((key < 0) || (key >= 512))
	return (FALSE);

    if (TCB->key_type[key] == NORMAL_CHAR)	/* no macro, so return */
	return (FALSE);

    if (TCB->key_type[key] == SINGLE_CHAR)	/* single char macro */
    {
	*size = 1;
	if (macro != NULL)
	{
	    macro[0] = (Char16) TCB->key_macro[key].chr;
	    macro[1] = 0;
	}
    }
    else	/* macro is a string */
    {
	*size = _EMStrLen16 (TCB->key_macro[key].ptr);
	if (macro != NULL)	/* multiple characters */
	{
	    memcpy (macro, TCB->key_macro[key].ptr,
		    (*size + 1) * sizeof (Char16));
	}
    }

    return (TRUE);
}



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMSetMacro					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int _EMSetMacro (TCB, key, macro)				*/
/*									*/
/*	  int		TCBD;	-- TCB descriptor of terminal instance	*/
/*									*/
/*	  int		key;	-- keyboard key:			*/
/*				    normal key:		as is		*/
/*				    function key:	2nd char + 256	*/
/*				    keypad/arrow key:	2nd char + 384	*/
/*									*/
/*	  Char16	*macro;	-- macro stirng (16-bit characters);	*/
/*				   NULL if key has no macro		*/
/*									*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function assigns the given macro string (16-bit) to the	*/
/*	  specified keyboard character.  From now on, typing the	*/
/*	  character is equivalent to typing the macro string.		*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  A non_zero value is returned if key is not a valid keyboard	*/
/*	  character.							*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

int _EMSetMacro (TCBD, key, macro)

int	TCBD;
int	key;
Char16	*macro;
{
    int		len;
    EM_TCB	*TCB;

    TCB = EM_TCB_list[TCBD];

    if ((key < 0) || (key >= 512))
	return (FALSE);

    len = 0;				/* length of macro string */
    if (macro != NULL)
	len = _EMStrLen16 (macro);

    if (TCB->key_type[key] == STRING_CHAR)	/* get rid of old macro */
	free (TCB->key_macro[key].ptr);
    TCB->key_type[key] = NORMAL_CHAR;

    if (len == 1)
    {
    	TCB->key_type[key] = SINGLE_CHAR;	/* single char macro */
	TCB->key_macro[key].chr = macro[0];
    }
    else if (len > 1)
    {
	TCB->key_type[key] = STRING_CHAR;	/* multiple char macro */
	TCB->key_macro[key].ptr =
			(Char16 *) malloc ((len + 1) * sizeof (Char16));
	memcpy (TCB->key_macro[key].ptr, macro, (len + 1) * sizeof (Char16));
    }

    return (EM_NO_ERROR);
}



/************************************************************************/
/*									*/
/*	FUNCTION NAME:  _EMStrLen16					*/
/*									*/
/*	SYNOPSIS:							*/
/*	  int _EMStrLen16 (string)					*/
/*									*/
/*	  Char16  *string;	-- 16-bit string			*/
/*									*/
/*									*/
/*	DESCRIPTION:							*/
/*	  This function returns the length of the null-terminated	*/
/*	  16-bit string.						*/
/*									*/
/*	RETURNED VALUE:							*/
/*	  Length of the string.						*/
/*									*/
/*	PROGRAMMER:  R. Dan Webb					*/
/*									*/
/************************************************************************/

int _EMStrLen16 (string)
Char16	*string;
{
	Char16	*ptr;

	ptr = string;
	while (*ptr != 0)
	    ptr++;
	return (ptr - string);
}
