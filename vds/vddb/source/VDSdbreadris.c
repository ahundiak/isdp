/* $Id: VDSdbreadris.c,v 1.1.1.1 2001/01/04 21:08:13 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vddb/source / VDSdbreadris.c
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSdbreadris.c,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:13  cvs
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
 * Revision 1.5  1996/05/20  05:06:02  pinnacle
 * Replaced: vddb/source/VDSdbreadris.c for:  by v240_int for vds.240
 *
 * Revision 1.4  1996/04/23  16:25:32  pinnacle
 * Replaced: vddb/source/VDSdbreadris.c for:  by v240_int for vds.240
 *
 * Revision 1.3  1996/04/22  15:14:44  pinnacle
 * Replaced: vddb/source/VDSdbreadris.c for:  by v240_int for vds.240
 *
 * Revision 1.2  1996/04/21  23:49:32  pinnacle
 * Replaced: vddb/source/VDSdbreadris.c for:  by v240_int for vds.240
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 * 	04/18/96  tlb	Modify error message, list tables as loaded
 *			Add prototypes
 *	    		Change to direct pointer manipulation - remove 
 *				sprintf/strcat 
 *	04/22/96     tlb	Fix log comment problem 
 *	04/23/96     tlb	Add delete message
 *	04/25/96     tlb	Fix delete message, 
 *				Add commit for safety 
 *				Return status
 *				Add check on file pointer after open 
 *
 * -------------------------------------------------------------------*/

#include 	<stdlib.h>
#include 	<stdio.h>
#include	<string.h>
#include        "SQLerrordef.h"
#include	"v_risproto.h"
#include	"v_dbloadprot.h"

/*------------------------------------------------------------------*/
/* This reads the input file of ris and executes the sql statements */

VDSreadrisfile( char	*file_name     /* Input DDL file name */)
{
	FILE	*fp;
	char	c,ch,prev;
	char	*ptr;	    /* ptr to current char in sqlstr */
	char	sqlstr[2048];
	char	cmd[50], type[50], name[50], name2[50];
	int	status, n, has_name;
	int	sts=TRUE;

#ifdef VDB_DEBUG
	char	string[10];
#endif

	fp = fopen(file_name,"r");
	if (!fp) {
		sprintf (name, "\tCannot open file: %s\n", file_name);
		puts (name);
		sts = FALSE;
	   	VDSdebug( name );
		goto quit;
		}

	sqlstr[0] = 0;
	ptr = sqlstr;
	prev = '\n';

	while ((c = fgetc(fp)) != EOF ) {
	    if ( c == '-') {
	    	if((ch = fgetc(fp)) == EOF) {
	    	    printf("Error in file\n");
	    	}
	    
	    /* Comment */
	    else if(ch == '-') {
	         while(((ch = fgetc(fp)) != '\n') && ch != EOF);

	    	    /* end of comment and file */
	    	    if (ch == EOF)
	    	    	break;
	    	    else {
	    	        if (prev != '\n')
	    	    	     *ptr++ = '\n';
	    	    }
	    	    prev = '\n';
	    	    continue;
	    	}

	    	/* Incomplete comment delimiter */
	    	else {
	    	    *ptr++ = '-';
	    	    c = ch;
	    	}	
	    }

	    /* Statment */
	    if ( c != ';' ){ 
	        *ptr++ = c;
	    }
	    else {
	    	*ptr++ = ';';
	    	*ptr++ = '\0';
	    	
	    	/*printf( "sqlstr = %s \n", sqlstr); */

	    	/* search for "create <type> <name>",
	         *	print type and name being created 
	         */
	    	has_name=0;
	    	n = sscanf (sqlstr, "%s%s%s%s", cmd, type, name, name2);
		if (n > 2) {
	    	    if (!strcasecmp(cmd, "create")) {
	    	    	if (!strcasecmp(type, "unique")) {
				strcpy (type, name);
				strcpy (name, name2);
				}
			VDSprintUsrMsg ("\t... creating %s %s\n", type, name);
	    	    	has_name=1;
			}
	    	    else if (!strcasecmp(cmd, "drop")) {
			VDSprintUsrMsg ("\t... dropping %s %s\n", type, name);
	    	    	has_name=1;
	    	    	}
		    }
	    	
	    	status = SQLstmt(sqlstr);
	    	if( status != SQL_S_SUCCESS ) {
		    sts = FALSE;
		    VDSprintErr ("\t\t", "%s\n", VDSgetSqlErrStr (status));
	    	    }
	    	sqlstr[0] = '\0';
	    	ptr = sqlstr;
	    }
	prev = c;
	}

	/* Ensure changes are committed */
	sprintf (sqlstr, "commit work;");
	status = SQLstmt(sqlstr);
	if( status != SQL_S_SUCCESS ) {
		sts = FALSE;
		VDSprintSqlErr ( "\t", "cannot commit work", sqlstr, status);
		}

	fclose(fp);
quit:
	return (sts);
}
