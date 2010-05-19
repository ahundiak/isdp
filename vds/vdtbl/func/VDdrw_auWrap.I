/* $Id: VDdrw_auWrap.I,v 1.1.1.1 2001/01/04 21:09:27 cvs Exp $  */

/* I/VDS
 * -------------------------------------------------------------------------
 *
 * File:        vdtbl/func / VDdrw_auWrap.I
 *
 * Description:
 *	Functions used by row ACconstruct_feet for auto wrapping lines
 *		VDdrw_getNbLines
 *		VDdrw_getNthLine
 *		VDdrw_processStr
 *
 * Dependencies:
 *
 * History:
 *
 *	06/14/95	R. Manem	Creation
 *	09/20/95	R. Manem	Omit first blanks at the beginning
 *					of autowrapped lines, to preserve
 *					left justification TR # 179527555.
 *
 * -------------------------------------------------------------------------
 */

class implementation Root;

/*
#define vdsDEBUG
#define vdserrDEBUG
*/

#include <stdio.h>
#include <string.h>

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "OMerrordef.h"
#include "OMtypes.h"
#include "OMminimum.h"

/*+fe
 -------------------------------------------------------------------------
  Function VDdrw_processStr

  Abstract
        This function processes an input string. The processed string will 
	contain a '\n' character, after every line, including the last line.

	A "\n" in the input string will automatically force a newline.  
	Newlines will occur only at word boundaries.  Exception : If not 
	a single word fits in a line, the word will be split across one or 
	more lines.  The input string will be processed and returned as 
	output. 

  Arguments

        IGRint       		maxLineLen     	I 	Max chars per line
        IGRchar       		*inpStr      	I	Input string
        IGRchar       		**procStr      	O	Output processed string

  Notes/Remarks
	Memory for procStr will be allocated by the function and must
	be freed by the caller. 

  Returns
        OM_S_SUCCESS    = if success
        OM_E_ABORT      = if error
 -------------------------------------------------------------------------
-fe*/

IGRlong VDdrw_processStr(	IGRint		maxLineLen,
				IGRchar		*inpStr,
				IGRchar		**procStr )
{
    IGRint		i, outInd,
			len,
			inpLen, outLen, 
			lineStart,
			lastSpace;
    IGRlong		status = OM_S_SUCCESS;
    
    SetProc( VDdrw_processStr ); Begin

    __DBGpr_int( "maxLineLen", maxLineLen );
    __DBGpr_str( "Input string", inpStr );

    /* validate inputs */

    if( !procStr || !inpStr || !maxLineLen )
    {
	__DBGpr_com( "\n\t\t\tInvalid arguments\n\n" );
	goto wrapup;
    }

    *procStr = NULL;
    lastSpace = 0;
    
    /*
     * allocate memory for output string 
     * Max extra characters needed will be when there are no white space
     * characters at all, in which case, words will be split, and '\n'
     * characters have to be inserted in the output string
     * If new lines are created at word boundaries, then the first white
     * space character will be replaced by a '\n' char, so there is no need
     * for extra memory in such cases
     */

    /*
     * calculate max length for output length 
     *  	outLen =  max. number of lines + inp str len + 1 for NULL char
     */

    inpLen = strlen( inpStr );
    __DBGpr_int( "Input string length", inpLen );

    outLen = ( (inpLen-1) / maxLineLen + 1 ) + inpLen + 1;
    __DBGpr_int( "Max Output string length", outLen );

    (*procStr) = _MALLOC( outLen, IGRchar );

    if( !( *procStr ) )
    {
	status = OM_E_NODYNMEM;
	goto wrapup;
    }

    outInd = lastSpace = lineStart = 0;
    
    for( i = 0 ; i < inpLen ; )
    {
	/* process forced new lines */

	if( inpStr[i] == '\\' && inpStr[i+1] == 'n' )
	{
	    __DBGpr_int( "Loop index i", i );

	    len = i - lineStart;
	    __DBGpr_int( "Length of str to be copied", len );

	    strncpy( &(*procStr)[outInd], &inpStr[lineStart], len );

	    lastSpace = lineStart = i + 2;
	    outInd += len;
	    (*procStr)[outInd++] = '\n';
	    i += 2;
	    continue;
	}

	/* force newlines if maxLineLen has been exceeded */

	if( (i - lineStart) >= maxLineLen )
	{
	    __DBGpr_int( "Loop index i", i );

	    /* maintain word boundaries */

	    if( inpStr[i] == ' ' || inpStr[i] == '\t' || lastSpace <= lineStart )
	    {
		len = i - lineStart;
	        __DBGpr_int( "Length of str to be copied", len );

	        strncpy( &(*procStr)[outInd], &inpStr[lineStart], len );

		if( inpStr[i] == ' ' || inpStr[i] == '\t' )
		{
		    /* 
		     * must skip the white space at the beginning of the next
		     * line
		     */

		    lastSpace = lineStart = i + 1;
		}
		else
	            lastSpace = lineStart = i;
	    }
	    else
	    {
		len = lastSpace - lineStart;
	        __DBGpr_int( "Length of str to be copied", len );

	        strncpy( &(*procStr)[outInd], &inpStr[lineStart], len );

		/* for the next line, omit the white space at the first char */
	        lastSpace = lineStart = lastSpace + 1;
	    }

	    outInd += len;
	    (*procStr)[outInd++] = '\n';

	    i++;
	    continue;
	}
	    
	/* check for white space */

	if( inpStr[i] == ' ' || inpStr[i] == '\t' )
	    lastSpace = i;
	    
	i++;
    }
	    
    /* copy the last string now */

    len = inpLen - lineStart;
    __DBGpr_int( "Length of str to be copied", len );

    if( len <= 0 )
    {
	__DBGpr_com( "Last string not copied" );
	(*procStr)[outInd] = '\0';
	goto wrapup;
    }

    strncpy( &(*procStr)[outInd], &inpStr[lineStart], len );
    outInd += len;
    (*procStr)[outInd++] = '\n';
    (*procStr)[outInd] = '\0';

    __DBGpr_str( "Final processed string", *procStr );

wrapup :
    End
    return status;
}
/*+fe
 -------------------------------------------------------------------------
  Function VDdrw_getNbLines

  Abstract
        This function returns the number of lines needed by the input string
	given the max number of characters per line. 
	The processed string returned as output should be used for retrieving 
	any nth line in the string, using VDdrw_getNthLine function.

  Arguments

        IGRint       		maxLineLen     	I 	Max chars per line
        IGRchar       		*inpStr      	I	Input string
	IGRint			*nbLines	O	Number of lines needed
        IGRchar       		**procStr      	O	Output processed string

  Notes/Remarks
	Memory for procStr will be allocated by the function and has to be
	freed later by the caller

  Returns
        OM_S_SUCCESS    = if success
        OM_E_ABORT      = if error
 -------------------------------------------------------------------------
-fe*/

IGRlong VDdrw_getNbLines(	IGRint		maxLineLen,
				IGRchar		*inpStr,
				IGRint		*nbLines,
				IGRchar		**procStr )
{
    IGRint		i, 
			len;
    IGRlong		status = OM_S_SUCCESS;
    
    SetProc( VDdrw_getNbLines ); Begin

    /* validate inputs */

    if( !procStr || !nbLines || !inpStr || !maxLineLen )
    {
	__DBGpr_com( "\n\t\t\tInvalid arguments\n\n" );
	goto wrapup;
    }

    /* process the input string */

    status = VDdrw_processStr( maxLineLen, inpStr, procStr );
    __CheckRC( status, 1, "VDdrw_processStr", wrapup );

    /* count the number of lines in processed string */

    *nbLines = 0;
    len = strlen( *procStr );
    __DBGpr_int( "Processed string length", len );

    for( i = 0 ; i < len ; i++ )
	if( (*procStr)[i] == '\n' )
	{
	    __DBGpr_int("Char that is newline ", i );
	    (*nbLines)++;
	}

    __DBGpr_int( "Number of lines", (*nbLines) );

wrapup :
    End
    return status;
}

/*+fe
 -------------------------------------------------------------------------
  Function VDdrw_getNthLine

  Abstract
        This function returns the Nth line in an input string processed
	by VDdrw_processStr function.

  Arguments

        IGRint       		n	     	I 	Line number of line 
        IGRchar       		*procStr      	I	Input processed string
        IGRchar       		*outStr      	O	Output string

  Notes/Remarks
	Memory for outStr must be allocated by the called.  The caller 
	usually knows the maximum size of the output string; if he 
	doesn't know the size, he can allocate a memory equal to strlen of
	procStr.
	n ranges from 1 to number of lines

  Returns
        OM_S_SUCCESS    = if success
        OM_E_ABORT      = if error
 -------------------------------------------------------------------------
-fe*/

IGRlong VDdrw_getNthLine(	IGRint		n,
				IGRchar		*procStr,
				IGRchar		*outStr )
{
    IGRint		i, 
			curLine,
			strStart,
			len;
    IGRlong		status = OM_S_SUCCESS;

    SetProc( VDdrw_getNthLine ); Begin

    __DBGpr_int( "Input line number requested", n );
    __DBGpr_str( "Input processed string", procStr );

    /* scan the processed string for '\n' characters */

    len = strlen( procStr );
    __DBGpr_int( "Processed string length", len );

    curLine = strStart = 0;
    for( i = 0 ; i < len ; i++ )
    {
	if( procStr[i] == '\n' )
	{
	    curLine++;
	    if( curLine == n )
		break;
	    strStart = i+1;
	}
    }
    __DBGpr_int( "Value of i", i );
    __DBGpr_int( "strStart", strStart );
    __DBGpr_int( "curLine", curLine );

    if( curLine != n )
    {
	__DBGpr_com( "Input line number is out of range" );
	status = OM_W_ABORT;
	goto wrapup;
    }

    len = i - strStart;
    __DBGpr_int( "Length of string to be copied", len );

    if( len < 0 )
    {
	__DBGpr_com( "String length to be copied, is invalid" );
	status = OM_E_ABORT;
	goto wrapup;
    }

    strncpy( outStr, &procStr[strStart], len );
    outStr[len] = '\0';
    __DBGpr_str( "Output string", outStr );

wrapup :
    End
    return status;
}

end implementation Root;
