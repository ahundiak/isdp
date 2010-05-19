/* $Id: VdsRisTbl.C,v 1.1.1.1 2001/01/04 21:09:12 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdris/imp / VdsRisTbl.C
 *
 * Description:
 *	This file contains functions for manipulating	
 *	Tables. ie., Creating, modifying, dropping 	
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VdsRisTbl.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:12  cvs
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
 * Revision 1.4  1996/04/21  23:27:24  pinnacle
 * Replaced: vdris/imp/*.C for:  by v240_int for vds.240
 *
 * Revision 1.3  1996/04/01  12:49:42  pinnacle
 * Replaced: vdris/imp/VdsRisTbl.C for:  by msbraju for vds.240
 *
 * Revision 1.2  1996/02/29  17:42:00  pinnacle
 * Replaced: vdris/imp/VdsRisTbl.C for:  by v240_int for vds.240
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR	DESCRIPTION
 *	02/29/96	adz	Change ristables -> ris5tables.
 *	04/10/96	tlb	Use VDS memory allocation checking
 *				Add prototypes
 *
 * -------------------------------------------------------------------*/

#include	<stdio.h>
#include	<string.h>
#include	"VDDbDef.h"
#include	"vdbmacros.h"
#include	"VDSris_def.h"
#include	"VDmem.h"
#include	"v_risproto.h"

/*--------------------------------------------------------------------------
  Doc :  VdsDelTrailBlanks

  Desc : Deletes trailing spaces from the given string. For strings which
  consisit of only blanks, retains the first blank and removes the rest.
  --------------------------------------------------------------------------*/
void VdsDelTrailBlanks( str )
char *str;
{
 int len;

 len = strlen( str );

 while( isspace(str[len-1]) )
 {
   if( len > 1 )
    len--;
   else
   {
    len = 1;
    break;
   }
 }

 str[len] = '\0';
}

int VdsManipTables( vds_table_name, operation, nbcols, columns, coltypes )
char	*vds_table_name;	/*  I	Table name affected		*/
int	operation;		/*  I	Operation - Create/Modify/Drop  */
int	nbcols;			/*  I   Number of Columns.		*/
char	**columns;		/*  I   Columns.			*/
char	**coltypes;		/*  I   Columns types			*/
{
	char    *SqlStmt = NULL;
	int     size, curlen, addlen;
	char    tmpstr[50];
	int	i;

	size = 500;
	SqlStmt = _MALLOC( size, char);
	if (SqlStmt == NULL) {
		printf ("VdsManipTables: cannot allocate query buffer\n");
		goto wrapup;
		}

	switch ( operation ) {
	case VDS_CREATE_TABLE:
		if (nbcols == 0 ) return 0;
		tmpstr[0] = '\0';
		sprintf( SqlStmt," create table %s ( ", vds_table_name ); 
		curlen = strlen ( SqlStmt );
		for ( i = 0; i < nbcols; i++ )
		{
		   sprintf( tmpstr," %s %s \0", columns[i], coltypes[i] );
		   addlen = strlen( tmpstr );
		   if ( curlen + addlen + 1 > size )
		   {
		     size += 500;
		     SqlStmt = _REALLOC( SqlStmt, size, char);
		     if (SqlStmt == NULL) {
			printf ("VdsManipTables: cannot realloc query \n");
			goto wrapup;
			}
		   }

		   strcat( SqlStmt, tmpstr );
		   if( i < (nbcols-1)) strcat (SqlStmt, "," );
		   else strcat (SqlStmt,")");
	           curlen += addlen + 1;                /* 1 for comma */
		}
		VDSexecute_sql_stmt( SqlStmt );
		break;
	case VDS_MODIFY_TABLE:
		if (nbcols == 0 ) return 0;
		for ( i=0; i<nbcols; i++ )
		{
		   sprintf( SqlStmt,"alter table %s add %s %s \0",
				vds_table_name, columns[i], coltypes[i] ); 
		   VDSexecute_sql_stmt( SqlStmt );
		}
		break;
	case VDS_DROP_TABLE:
		sprintf(SqlStmt,"drop table %s ", vds_table_name );
		VDSexecute_sql_stmt( SqlStmt );
		break;
	default:
		break;
	}

wrapup:
	_FREE(SqlStmt);
	return 1;
}


int VdsInsertRowsinTable( vds_table_name, nbcols, columns, coltypes, colvalues )
char	*vds_table_name;	/*  I	Table name affected		*/
int	nbcols;			/*  I   Number of Columns.		*/
char	**columns;		/*  I   Columns.			*/
int	*coltypes;		/*  I   Columns types			*/
char	**colvalues;		/*  I   Columns values			*/
{
	int	i,sts;
	char	column_names[1024];
	char	column_values[1536];
	char	select[5];

	fprintf( stdout, "VdsInsertRowsinTable\n" );
	column_names[0]='\0';
	column_values[0]='\0';
	select[0] = '\0';
	for ( i = 0; i < nbcols; i++ )
	{
		strcat(column_names,columns[i]);
		if( i < (nbcols-1) ) strcat (column_names,",");
	}

	for ( i = 0; i < nbcols; i++ )
	{

		VdsDelTrailBlanks( colvalues[i] );

		if(coltypes[i] == CHAR || coltypes[i] == DATE ) 
		{  
		   /* Put it in Quotes */
		   strcat(column_values,"'"); 
		   strcat(column_values,colvalues[i]);
		   strcat(column_values,"'"); 
		}
		else
		   strcat(column_values,colvalues[i]);

		if( i < (nbcols-1) ) strcat (column_values,",");
	}

	sts = VdsRisInsert(vds_table_name,column_names,column_values,select );
	return sts;
}

int  VdsVerifyRisTable( table_name )
char	*table_name;
{
	char	*ristables="ris5tables";
	char	where[200];
	int	count=0;

	sprintf(where,"table_name = '%s' ",table_name );

	vdb$RisGetNumberOfParts ( table_name = ristables,
				  where = where,
				  count = &count );

	if ( count > 0 ) return VDS_DBTABLE_FOUND; 
	else return VDS_DBTABLE_NOT_FOUND;

}

