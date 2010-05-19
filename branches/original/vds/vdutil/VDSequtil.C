/* $Id: VDSequtil.C,v 1.1.1.1 2001/01/04 21:09:31 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdutil / VDSequtil.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSequtil.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:31  cvs
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
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

#include	<stdio.h>

#include       "vdbmacros.h"

#define		SUCCESS		1
#define		FAILURE		0

int VDSret_fr_equiplist( eqp_no, eqp_name, num)
int	*eqp_no;
char	*eqp_name[];
int	*num;
{
	char	query[200];
	int	ncols = 0;
	int	nrows = 0;
	char	**buf;
	char	temp[20];
	int	i;
	int	status;

	*num = 0;
	sprintf(query,"%s", "SELECT eqp_no, eqp_name FROM equip_list");

	status = VDSsql_query ( query, &ncols, &nrows, &buf );
	if ( status != SUCCESS )
	{
	   status = FAILURE;
	   goto quit;
	}
	*num = nrows;

	for ( i = 0; i < nrows; i++ )
	{
	    sscanf( buf[i*ncols], "%d", &eqp_no[i] );
	    strcpy( temp,buf[ i*ncols + 1] ); 
	    if(eqp_name[i] == NULL)
	       eqp_name[i] = (char *) malloc ( sizeof (strlen(temp) + 1));
	    strcpy( eqp_name[i], temp);
	    printf(" eqp_no = %d, eqp_name = %s\n", eqp_no[i], eqp_name[i] );
	}

wrapup:
	vdb$RisFreeBuffer (  buffer    =       buf,
                             size      =       nrows * ncols );
quit:
	return status;
}


int VDSget_from_eqplist( eqp_no, macro_2d, macro_3d, macro_lib, occ_no ) 
int	eqp_no;
char	*macro_2d;
char	*macro_3d;
char	*macro_lib;
int	*occ_no;
{
	char	query[400];
	int	ncols = 0;
	int	nrows = 0;
	char	**buf = NULL;
	int	i;
	int	status;

	*occ_no = 0;

	sprintf(query,"SELECT %s FROM %s WHERE eqp_no = %d","macro_2d, macro_3d, macro_lib, occ_no", "equip_list", eqp_no);

	status = VDSsql_query ( query, &ncols, &nrows, &buf );
	if ( status != SUCCESS )
	{
	   status = FAILURE;
	   goto quit;
	}

	for ( i = 0; i < nrows; i++ )
	{
	    strcpy( macro_2d, buf[ i*ncols] ); 
	    strcpy( macro_3d, buf[ i*ncols + 1] ); 
	    strcpy( macro_lib, buf[ i*ncols + 2] ); 
	    sscanf( buf[i*ncols + 3], "%d", occ_no );
	}

wrapup:
	vdb$RisFreeBuffer (  buffer   =      buf,
                             size     =      nrows * ncols );
quit:
	return status;
}

/*
int	VDSget_eqp_catalog ( catalog_name )
char	*catalog_name;
{
	char	query[200];
	int	ncols = 0;
	int	nrows = 0;
	char	**buf;
	char	**columns;
	int	*coltype;
	int	i;
	int	status;

	sprintf( query,"%s '%s'", "SELECT * from ", catalog_name );
	status = VDSsql_query1 (query, &ncols, &nrows, &buf, &columns, &coltype );
	if ( status != SUCCESS )
	{
	   status = FAILURE;
	   goto quit;
	}
wrapup:
	vdb$RisFreeBuffer ( buffer    =       buf,
                            size      =       nrows * ncols );
quit:
	return status;
}
*/

int VDSget_eqp_library ( macro_name, macro_lib )
char    *macro_name;
char    *macro_lib;
{
        char    query[200];
        int     ncols = 0;
        int     nrows = 0;
        char    **buf;
        int     i;
        int     status;

        sprintf(query,"SELECT %s FROM %s WHERE p_macroname = '%s'","p_macropartno","pdmparamloc",macro_name);

        status = VDSsql_query ( query, &ncols, &nrows, &buf );
        if ( status != SUCCESS )
        {
           status = FAILURE;
           goto quit;
        }

	for ( i = 0; i < nrows; i++ )
	    strcpy( macro_lib, buf[i*ncols] ); 

wrapup:
	vdb$RisFreeBuffer (   buffer     =        buf,
                              size       =        nrows * ncols );
quit:
	return status;
}
