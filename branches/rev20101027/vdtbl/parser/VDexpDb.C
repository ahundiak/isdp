/* $Id: VDexpDb.C,v 1.1.1.1 2001/01/04 21:09:28 cvs Exp $ */

/*************************************************************************
 * I/VDS
 *
 * File:	vdtbl/parser / VDexpDb.C
 *
 * Description:
 *	Database access functions
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log
 * History:
 *	05/30/96   tlb  created from VDexpFunc.C functions
 *			Rename VD_expEval* to VD_expDb*
 *			Add syntax checking cases
 *			Add position argument to all functions
 *	06/10/96   tlb  DynSelect: check pdmid, dyn_table before calling query
 *			Add default value in both functions
 *      03/24/98   Ming TR179800778
 *      03/25/98   Ming Re-fix TR179800778
 *
 *************************************************************************/
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <float.h>

#include "PDUerror.h"			/* PDM_S_SUCCESS */
#include "VDScheckin.h"			/* REP_MODEL, REG_CHECKIN */
#include "VDBload.h"			/* VDB_MAX_CATALOG_LEN */
#include "v_drwproto.h"			/* VD_drwVerb* */
#include "v_strngproto.h"		/* VD_strncpy, VD_strncat, ..*/

#include "VDexpdef.h"
#include "VDmem.h"


/*=========== Private =======================================================*/
static int
VD_expDbQuery (	VD_tktxt	query,
		int		pos,
		VD_execRes	*res)
{

	int     	countOfColumns	= 0,
	          	countOfRows	= 0 ;
	char    	**results	= NULL ;
	int		trunc;
	int		flag 		= FALSE;

	/* initialize return value */
	res->type  = VD_null;

	/* verify user is connected to database */
	if ( VDSverify_login () != PDM_S_SUCCESS) {
		VD_expReportError ( pos, res, "No connection to database");
		UI_status ( "Database login required to evaluate expression");
		goto wrapup;
		}

	UI_status ("Accessing database...");
	if( !VDSsql_query ( query, &countOfColumns, &countOfRows,
			    				&results ) ) {
		VD_expReportError ( pos, res, "Query failed");
		goto wrapup;
		}

	/* Query succeeded */
	flag = TRUE;

	/* Query returned something */
	if( countOfColumns && countOfRows ) {
	      	/*
	       	 * We may have multiply equal entries in the items returned
	       	 * (because of the way the catalogs are made...). So trim down
	       	 * to one occurence per item.
	       	 */
	      	long	msg ;
	      	int	nbResults = countOfColumns * countOfRows ;
	      	int	arraySize ;
	      	char	**compressed ;

	      	VD_remove_dups_in_list( &msg, nbResults, results,
	      				   	&arraySize, &compressed ) ;

	      	if( !(msg & 1) ) {
			VD_expPrintWarn ("memory allocation failure") ;
			goto wrapup;
			}

		if (arraySize > 1 ) {
			VD_expPrintWarn ("query returns multiple values") ;
			flag = -1;
			goto wrapup;
			}

		/* return result */
	      	res->type	= VD_string ;
	      	VD_strncpy (res->_sval, compressed[0], VD_K_tokMAX_SIZE,&trunc);
		if (trunc){
			strcpy (&(res->_sval[VD_K_tokMAX_SIZE-6]), "\n ...");
                	VD_expPrintWarn ("query result was truncated");
			}

	        _FREE ( compressed ) ;
		VdsRisFreeBuffer( results, nbResults ) ;
		}

	/* No object in table */
	else
		flag = -2;	
		

wrapup:
	UI_status ("");
	return flag;
}
/*=========== Public =======================================================*/


/* ---------------------------------------------------------------*/
/* execute SQL select
 */
void
VD_expDbSelect ( const VD_drwArgLst		*list,
		 int				pos,
	    	 VD_execRes			*res)
{
	long		sts;
	VD_tktxt 	query ;
	int		trunc;


	/* default result */
	res->type = VD_null;

	/* empty  list */
	if (!list)  {
		VD_expReportError ( pos, res, "No query specified");
		return;
		}

	/* syntax check */
	if (!XFLAG) {
		res->type = VD_string;
		strcpy (res->_sval, "db_select_result");
		return;
		}

	/* construct query */
	query[0] = '\0';
        while( list ) {

		/* convert to string */
		if (!VD_expStrncat (query, list->arg, &trunc))
			goto wrapup;

		if (trunc) {
			VD_expReportError ( pos, res, "Query too long");
			goto wrapup;
			}
                list = list->next ;
	 	}

	/* execute query */
	sts = VD_expDbQuery (query, pos, res);
        if( !sts )
        {
          res->type = VD_null;
          STATUS_FLAG = VD_STATUS_OK;
        }

wrapup:
	return ;

}
/* ---------------------------------------------------------------*/
/* execute SQL select on dynamic table
 *	dyn_select (<attr> )
 *	dyn_select (<attr> , <dyanamic table name>)
 */
void
VD_expDbDynSelect (   const VD_drwArgLst		*list,
			int				pos,
			VD_execRes			*res)
{
	long		sts;
	VD_execRes	Str;
	VD_tktxt 	query, buf ;
	int		trunc;
	char		table_name[80];
	char		str[80];


	/* default result */
	res->type = VD_null;

	/* syntax check */
	if (!XFLAG) {
		res->type = VD_string;
		strcpy (res->_sval, "dyn_select_result");
		return;
		}

	/* construct query */
	strcpy (query, "select ");

	/*
 	 * Attr name
	 */
	if (!VD_expStrncat (query, list->arg, &trunc))
		goto wrapup;
	if (trunc) goto trunc;

	/*
 	 * Table name
	 */
	VD_strncat ( query,  " from ", VD_K_tokMAX_SIZE, &trunc);
	/* No table given */	
	if (!list->next) {
		VD_expObjDynTable (CUR_OBJ, pos, &Str);
		if (Str.type == VD_null) {
			goto wrapup;
			}
			
		if (!VD_expStrncat ( query, Str, &trunc))
			goto wrapup;
		strcpy (table_name, Str._sval);
		}
	/* table is given */	
	else {
    		list = list->next ;
		if (!VD_expStrncat ( query, list->arg, &trunc))
			goto wrapup;
		strcpy (table_name, list->arg._sval);
		}
	if (trunc) goto trunc;


	/*
 	 * Objid
	 */
	sprintf (buf, " where comp_seqno = %d and ", CUR_OBJ.obj_id.objid);
	VD_strncat ( query, buf, VD_K_tokMAX_SIZE, &trunc);
	if (trunc) goto trunc;

	/*
	 * Filename (Assembly name)
 	 */
	VD_expObjPdmId(CUR_OBJ, pos, &Str);
	if (Str._sval[0] == '\0') {
		res->type = VD_null;
		goto wrapup;
		}	
		
	VD_expStrncat (query, Str, &trunc);
	if (trunc) goto trunc;

	/* execute query */
	sts = VD_expDbQuery (query, pos, res);
        if( !sts )
        {
          res->type = VD_null;
          STATUS_FLAG = VD_STATUS_OK;
        }
	if (sts == -1 )
		VD_expPrintWarn (
			"Purge dynamic table to remove multiple values") ;
	else if (sts == -2) {
                sprintf (str, "object not posted to '%s'", table_name);
                VD_expPrintWarn (str);
		}
		
wrapup:
	return ;
trunc:
	/* query was truncated */
	VD_expReportError ( pos, res, "Query too long");
	goto wrapup;
}
