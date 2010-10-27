/* $Id: VDtrim.C,v 1.1.1.1 2001/01/04 21:09:32 cvs Exp $  */
 
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdutil / VDtrim.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDtrim.C,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:32  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.1  1996/05/07  10:29:52  pinnacle
 * Created: vdutil/VDtrim.C by ksundar for vds.240
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *  	05/07/96	Sundar		Creation.
 *
 * -------------------------------------------------------------------*/

#include <stdio.h>
#include <string.h>

/* Desc: This function deletes the trailing space chars from given string. */
VDrtrim( char *str )
{
	int len;
	
	len = strlen( str );
   	while( isspace(str[len-1]) )
    		len--;
   	str[len] = '\0';
}

/* Desc: This function deletes the leading space chars from given string. */
VDltrim( char *str )
{
	int len, ii, nonspace;
 
    	len = strlen( str );
    	nonspace = 0;
    	while( isspace( str[nonspace] ) )
      		nonspace++;
    	for( ii=0; ii< len-nonspace; ii++)
     		str[ii] = str[nonspace+ii];
    	str[len-nonspace] = '\0';
}

/* Desc: This function return 1 if there is any space in the string 
	 else 0 */

VDspace( char *name )
{

	int ii, len;

	len=strlen(name);
	for( ii=0; ii < len; ii++)
		if ( isspace(name[ii]) )
			return 1;

	return 0;
}
