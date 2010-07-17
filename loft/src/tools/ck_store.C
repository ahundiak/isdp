#include <stdio.h>
#include <math.h>
#include "igrtypedef.h"
#include "igr.h"
#include "igrdef.h"
#include "bserr.h"
#include "OMminimum.h"
#include "msdef.h"
#include "exmacros.h"

#define epsi 0.0001

/* ******************** FCT VLgetStandSize () ************************	*/
/*									*/
/*  Read the given table name XXX in $LOFT/config/XXX.t	and find for	*/
/*  the first standard values including the given list of expression	*/
/*									*/
/* IN	: table_name	name of table					*/
/*	  nb_exp	number of expression to check			*/
/*	  list_exp	list of expression to check			*/
/*	  tol		checking tolerance if NULL use epsi		*/
/* OUT	: list_st	list of standard expression			*/
/*									*/
/*	Return MSSUCC if standard values exist else return MSFAIL	*/
/*									*/
/* --------------------------------------------------------------------	*/

long VLgetStandSize( table_name, tol, nb_exp, list_exp, list_st )

char	*table_name;
double	*tol;
int	nb_exp;
double	*list_exp, *list_st;

{
FILE	*pmfile	;
char	line[1+BUFSIZ];
int	i, j=0, k;
char	tmp_name[512];
long	sts;
double	loc_tol;

	/* initialization */
	pmfile	= NULL;
	loc_tol	= epsi;
	if( tol ) loc_tol = *tol;

	// get product path
	for( i=0; ; i++ ) {
		sts = ex$get_path(	index	= i,
					path	= tmp_name,
					len	= 512,
					type	= EX_CONFIG_PATH );

		if( ! (sts&1))	return	MSFAIL;
		sprintf( tmp_name, "%sconfig/%s.t", tmp_name, table_name );
		
		pmfile = fopen( tmp_name, "r" );
		if(pmfile != NULL)	break;
	}

	if( pmfile == NULL )	return	MSFAIL;

	for(i=0;;i++){

		if( fgets( line, BUFSIZ, pmfile ) == NULL )	return MSFAIL;

		list_st[0] = atof( line );
		for( k=1; k<nb_exp; k++ ){

			for( j=0; line[j] != '\t' && line[j] != '\0'; j++ ) ;
			if( line[j] == '\0' )	break;
			list_st[k] = atof( &line[j+1] );
		}
		if( line[j] == '\0' )	continue;

		// test values
		for( k=0; k<nb_exp && list_exp[k] < (list_st[k] + loc_tol); 
			k++ );
		if( k == nb_exp )	break;
	}

return	MSSUCC;
}
