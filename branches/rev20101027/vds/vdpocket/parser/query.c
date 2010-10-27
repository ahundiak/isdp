/* $Id: query.c,v 1.1.1.1 2001/01/04 21:09:01 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vdpocket/parser / query.c
 *
 * Description:
 *  	Standalone interactive testing program for query grammer
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: query.c,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:01  cvs
 *	Initial import to CVS
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
 * Revision 1.1  1995/01/23  15:22:30  pinnacle
 * Created: vdpocket/parser/query.c by tlbriggs r#
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	01/16/95	tlb		created file
 * --------------------------------------------------------------------*/
#include <stdio.h>

#define BUF_LEN		256

char buffer [BUF_LEN] ; 
extern char * qy_ptr;

/* main test routine */
main () {
	int	status;
	char 	*str;

	printf ("Interactive Query Test\t(type ^d to end)\n\n");

	/* read 1st query */
	printf ("query>");
	str = gets (buffer);

	while (str != NULL ) {
		printf ("\"%s\"\n", buffer); 

		if (buffer[0] != '#') {
			qy_ptr = buffer;
			status = qy_yyparse ();
			printf ("  returns: %d\n\n", status);
			}

		printf ("query>");
		str = gets (buffer);
		}

}
/* -------- stubs --------- */
static int	status;

/* Query processing - just print query */
VDquery ( char * expr1, 
	  int op,  
	  char * expr2)
{
	int 	i, size;
	char 	* class_list;

	printf ("\t   VDquery: \t class:");

	/* print class names */
	VDQYgive_class_list ( &size , &class_list );
  	for (i = 0; i < size; ) {
		printf (" %c %s", (!i) ? ' ' : '-' , &(class_list[i]));
      		i += strlen ( &(class_list[i])) + 1;
  		};

	/* print query body */
	printf ("\tbody: %s %d %s", expr1, op, expr2);

	/* print status */
	status = status ? 0 : 1;
	printf ("\tstatus: %d\n", status);
	return status;
}


VDQYis_subclas( char * class_name, char * name )

{
}
