/* $Id: VDSdbrisload.C,v 1.1.1.1 2001/01/04 21:08:13 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vddb/source / VDSdbrisload.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSdbrisload.C,v $
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
 * Revision 1.3  1996/05/20  05:06:34  pinnacle
 * Replaced: vddb/source/VDSdbrisload.C for:  by v240_int for vds.240
 *
 * Revision 1.2  1996/04/21  23:49:20  pinnacle
 * Replaced: vddb/source/*.C for:  by v240_int for vds.240
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *				changed from .c to .C for omcpp for compilation.
 * 				due to macros included from vdbmacros.h
 *
 *   	04/03/93    Mallik	Changed the reference to vds.ddl while loading
 *				the tables Read the riscolumns table directly
 *				for the datatypes
 *
 *	04/18/96    tlb		Memory scratch, Add trace info
 *				Add prototypes
 *				Change RIS* functions to VDBris
 *	04/25/96    tlb		Change TRACE message to use VDSdebug
 *				Add row indicator for load
 *				Pointer initialization
 *
 * -------------------------------------------------------------------*/

#include	<stdio.h>
#include	<string.h>
#include        "VDSris_siz.h"
#include        "VDSris_def.h"
#include        "vdbmacros.h"
#include        "VDSload.h"
#include	"v_risproto.h"
#include	"v_dbloadprot.h"

/* #define TRACE */

/*-----------------------------------------------------------------------*/
/* This loads data from ascii files, the input of which is obtained from */
/* the file like vdsld.ris.						 */
/* Load path is /usr/ip32/vds/data/vds.					 */
/* Delete option whether the user wants to delete the existing data      */

VDBris_load( ascii_file, load_path, del_option )
   char	*ascii_file;
   char	*load_path;
   char	*del_option;
{
	int		status;
	char		current_file[MAXWORD];
	struct	MFload	load;
	int		delete;
	int		i;

	/* create absolute file name */
	if ( (strcmp( load_path, "") != 0)
	&&   (load_path[strlen(load_path)-1] != '/') )
	   strcat (load_path, "/");
	sprintf ( current_file, "%s%s", load_path, ascii_file);

	/* Retrieve tables and load files name */

#	ifdef TRACE
		VDsdebug("VdsRetrieveLoadData on <%s>\n", current_file);
#	endif

	status = VdsRetrieveLoadData ( current_file, &load);

#	ifdef TRACE
		VDSdebug("VdsRetrieveLoadData returns %d\n", status);
#	endif
	if (status != SUCCESS) return status;


	/* Load data */
	for (i=0;i<load.num;i++) {
	   if( del_option[0] == 'y' || del_option[0] == 'Y' )
		delete = DELETE_Y;
	   else
		delete = DELETE_N;

#	   ifdef TRACE
	   	VDSdebug ( "table : <%s>\tfile : <%s>\n",
		    			load.data[i].table, load.data[i].file);
#	   endif
	   fflush(stdout);

	   status = VDBris_insert_data ( load.data[i].table,
				     load_path,
				     load.data[i].file,
				     &delete );
	    }

        return status;
}


/*-----------------------------------------------------------------*/
int VDBris_insert_data ( table_name, load_path, file_name, delete )
char		*table_name;
char		*load_path;
char		*file_name;
int		*delete;
{
	FILE		*p_file;
	char		ascii_file[MAXWORD];
	int		typ[MAXWORD];
	int		n_typ;
	int		status;
	char		row[MAXBUFF];
	int		i, row_num;

	int		print  = PRINT_N;
	char 		**p_attr = NULL;
	char		**p_type = NULL;

	/* Retrieve datatypes */
        status =
        vdb$RetrieveAttributes ( table_name   =      table_name,
                                p_num         =      &n_typ,
                                p_attr        =      &p_attr,
                                p_type        =      &p_type );

	if (status != SUCCESS) {
	  VDSprintErr ("\t", "Table <%s> does not exist or has 0 attributes\n",
								table_name);
	  VDSprintVdsErr( "\t", "VdsRetrieveAttribute", status);
	  goto quit;
	}

	if ((status = VdsRisAttach()) != SUCCESS) { 
	    VDSprintVdsErr( "\t", "VdsRisAttach", status);
	     return FAILURE; 
	     }

	for (i=0; i < n_typ; i++)
	   typ[i] = atoi(p_type[i]);

#	ifdef TRACE
		Vdsdebug("RISinsert_data. %d static_datatypes for %s : \n",
							n_typ, table_name);
		for(i=0;i<n_typ;i++)  {
			VDsdebug("\t\t\t\t\tdatatype[%d] = %d\n", i, typ[i]);
			}
#	endif

	/* Construct absolute data file */
	sprintf ( ascii_file, "%s%s", load_path, file_name);

	/* Open data file */
	p_file = fopen ( ascii_file, "r");
	if (p_file == NULL) {
	   VDSprintErr( "\t", "Cannot open file <%s>\n", ascii_file );
	   status = FAILURE;
	   goto quit;
	  }

#	ifdef TRACE
		VDsdebug("RISinsert_data reads <%s>\n", ascii_file);
#	endif

	/* Print name of table being loaded */
	if (strlen(table_name) < 4)
		VDSprintUsrMsg ("\t... loading %s\t\t\t", table_name);
	else if (strlen(table_name) < 12)
		VDSprintUsrMsg ("\t... loading %s\t\t", table_name);
	else if (strlen(table_name) < 20)
		VDSprintUsrMsg ("\t... loading %s\t", table_name);
	fflush(stdout);

	/* Read and load each line in the file */
	row_num=1;
	while ( fgets ( row, MAXBUFF, p_file) != 0) {
	      	/* RIS insert  */
#	   	ifdef TRACE
	   		VDsdebug("RISinsert_data. VdsInsertRows in <%s>\n",
								table_name);
			VDSdebug("\trow %d = %s\n", row_num, row );
#	    	endif

	       	status = VdsInsertRows ( table_name,
				       n_typ,
				       NULL,
				       typ,
				       row,
				       delete,
				       &print,
				       0,
				       0 );
#		ifdef TRACE
			VDSdebug("VdsInsertRows returns %d\n", status);
#		endif

	        if (status != SUCCESS) {
	  		VDSprintVdsErr( "\t", "VdsInsertRows", status);
	        	break;
	      		}

		/* Output row indicator */
		if (row_num % 500 == 0) {
			printf("%d\n\t\t\t\t\t", row_num); fflush(stdout);
			}
		else if (row_num % 100 == 0) {
			printf("%d", row_num); fflush(stdout);
			}
		else if (row_num % 20 == 0)  {
			putchar('.'); fflush(stdout);
			}
		row_num++;
	        }
	putchar ('\n');
	fclose(p_file);

quit:
	vdb$RisFreeBuffer (  buffer    =     p_attr,
                             size      =     n_typ );
	vdb$RisFreeBuffer (  buffer    =     p_type,
                             size      =     n_typ );
	VdsClearStmt ();
	return status;
}
