/* $Id: VDSError.I,v 1.1.1.1 2001/01/04 21:09:31 cvs Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:	vdtools / VDSError.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSError.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:31  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/11/18  16:53:14  pinnacle
# Created: vdtools/VDSError.I by kddinov for vds
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	11-97		kdd	creation
 *
 *************************************************************************/
class implementation Root;

/*------------------------------------------------------------------------------
* VDS Report Error utility.
* KDD 10-97 
*
* API is vd$report_error.
*
*----------------------------
*  PARAMETERS:
*
* I: 	int	mode	- Specifies where and how to report the error.
*			  Default = 2; UI_status and Unix window;
*			  If mode < 0 prints filename and line also. 
*		   	1 Unix Window only
*			2 UI_status + 1. 
*
* I:	char	*text	- error message to address to the user. 
*
* I:	char	*filename - filename where the error occurs. 
*			  Macro API uses __FILE__.
*
* I: 	int	line	- line number.  Macro API uses __LINE__.
*
*----------------------------
*   RETURN STATUS:
* 1 	- always.
*
------------------------------------------------------------------------------*/
int VDSreport_error(	char	*text,
			int	mode, 
			char	*filename, 
			int	line)
{
   char		*p_text, dummy[1]={""};

   if ( text )  p_text = text;
   else		p_text = dummy;

   if ( mode < 0 ) {
   	if (filename) printf( "Error: File <%s> line %d\n", filename, line);
	mode = - mode; 
   }

   switch ( mode ) {

   default:
   case 2:
	UI_status( p_text); 

   case 1:
	printf( "%s\n", p_text);
	break;
   }


wrpaup:
return (1);
}
				
end implementation Root;
