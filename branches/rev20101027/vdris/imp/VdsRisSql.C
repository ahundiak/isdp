/* $Id: VdsRisSql.C,v 1.3 2002/02/26 15:42:00 ahundiak Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdris/imp / VdsRisSql.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VdsRisSql.C,v $
 *	Revision 1.3  2002/02/26 15:42:00  ahundiak
 *	ah
 *	
 *	Revision 1.2  2001/01/19 21:23:55  jdsauby
 *	SP Merge
 *	
 *	Revision 1.1.1.1  2001/01/04 21:09:12  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  2000/10/06  13:34:28  pinnacle
 * Created: vds/vdris/imp/VdsRisSql.C by lawaddel for Service Pack
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.5  1998/04/09  21:19:50  pinnacle
 * Replaced: vdris/imp/VdsRisSql.C for:  by azuurhou for vds
 *
 * Revision 1.4  1998/01/15  14:47:34  pinnacle
 * UI_status
 *
 * Revision 1.3  1997/11/25  20:22:42  pinnacle
 * Replaced: vdris/imp/VdsRisSql.C for:  by mdong for vds
 *
 * Revision 1.2  1997/06/10  19:08:56  pinnacle
 * Replaced: vdris/imp/VdsRisSql.C for:  by v250_int for vds
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.9  1996/06/07  13:30:08  pinnacle
 * Replaced: vdris/imp/VdsRisSql.C for:  by sljenks for vds.240
 *
 * Revision 1.8  1996/05/30  14:51:28  pinnacle
 * Replaced: vdris/imp/VdsRisSql.C for:  by sljenks for vds.240
 *
 * Revision 1.7  1996/05/29  01:01:42  pinnacle
 * Replaced: vdris/imp/VdsRisSql.C for:  by sljenks for vds.240
 *
 * Revision 1.6  1996/04/26  20:44:24  pinnacle
 * Replaced: vdris/imp/VdsRisSql.C for:  by svkadamb for vds.240
 *
 * Revision 1.5  1996/04/21  23:27:24  pinnacle
 * Replaced: vdris/imp/*.C for:  by v240_int for vds.240
 *
 * Revision 1.4  1995/12/20  19:46:58  pinnacle
 * Replaced: vdris/imp/VdsRisSql.C for:  by jwfrosch for vds.240
 *
 * Revision 1.3  1995/10/10  21:48:58  pinnacle
 * Replaced: vdris/imp/VdsRisSql.C for:  by jwfrosch for vds.240
 *
 * Revision 1.2  1995/10/09  19:47:56  pinnacle
 * Replaced: vdris/imp/VdsRisSql.C for:  by jwfrosch for vds.240
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
 *	12/20/95	HF	Added VDdebug.h & __<fnc. calls>
 *					(Intel Solaris database problem)
 *	04/09/96	tlb	Fix 'where' clause crash in RisDelete
 *				Change to VDS memory allocation
 *				Add prototypes
 *				Ensure functions single exit/wrapup
 *				Ensure all input string checked for null
 *				VdsRisSelect - add 1 to strlen
 *			Memory scratch for (*p_buffer)[i] in VdsRisSelect
 *
 *	05/28/96	slj	Added call to VDSris_get_count() in delete
 *
 *	06/07/96	slj	Added /n to WARNING message.
 *	01/15/98	ah	Comment out UI_status call
 *				VDSloaddata has no such routine
 *	04/09/98	adz	TR179800924 No warning for non-existing tables.
 *      10/02/00        law	TR179901546 Optimized callocs, strcpy, frees
 * -------------------------------------------------------------------*/

#include	<stdio.h>
#include	<string.h>
/*#include	"common.h" */
#include	"igrtypedef.h"
#include	"VDSris_siz.h"
#include	"VDSris_def.h"

#include        "math.h"
#include        "stdlib.h"

/*#include	"VDScheckin.h" */
#include	"VDSserver.h"
#include	"VDdebug.h"
#include	"VDmem.h"
/* #include	"v_risproto.h" */
#include	"VDDbDef.h"

//#define		VD_DEBUG	1

#define		AS_DEBUG	1

#ifdef	VD_DEBUG
	#define 	ERR( f, s)	printf ("Error in %s: %s\n", f, s )
#else
	#define		ERR( f, s)
#endif

/*
 * For Testing & Dynamic Load ==>> CHANGE to following :
 */

#if ISDP_MAKE_SP
extern char	Ris_SchemaName[];
extern char	Ris_SchemaPwd [];
#else
char	Ris_SchemaName[20] = "";
char	Ris_SchemaPwd [20] = "";
#endif


extern char VDSenvir_name[] ;

/******************************************************************************/
/*
	Author : Marc FOURNIER (ISDC)
	date   : 10-Jan-1992
		 21-Jan-1992

	1) RIS SQL queries basic functions : select, delete, insert, update
	2) Management of buffer result of a select query : extract value, free
	3) Management of RIS schema attachement : attach, detach

***	4) RIS SQL insertion with prepare : insert, clear
	*** RM 920626 prepare not needed; Functions kept with same args

	These functions return SUCCESS or FAILURE if an error is detected.
	SUCCESS and FAILURE are defined in the include file <VDSris_def.h>.
*/
/******************************************************************************/

/******************************************************************************/
int VdsRisSelect ( select, table, where, order, group, having, nbatt,
		   p_nbocc, p_buffer)

	char	select[];	/* selected attributes	  	(I) */
	char	table[];	/* table name		  	(I) */
	char	where[];	/* where clause		  	(I) */
	char	order[];	/* order by clause	  	(I) */
	char	group[];	/* group by clause	  	(I) */
	char	having[];	/* having clause - not supported (I) */
	int	nbatt;		/* no attr of select str. 	(I) */
	int	*p_nbocc;	/* number of rows	  	(O) */
	char	**(p_buffer[]);	/* result buffer	  	(O) */

	/*
		SELECT <select>	FROM <table>	[WHERE <where>]
		  				[ORDER BY <order>]
		  				[GROUP BY <group>]
		not supported			[HAVING <having>]
	*/

/*.VdsRisSelect*/
{
	char		*query;			/* complete select string   */
	int		sts;			/* RIS sts		    */
        int		ncols = 0;		/* Number of columns found in
                                                   select statement */
	int		nrows = 0;		/* Number of rows found */

	int		i;
        char		**buf = NULL;
        char		**locptrara = NULL;
        char		*locptr = NULL;


  	__enterFunction ( name = "VdsRisSelect" );

	sts = SUCCESS;
        query = NULL;
	*p_nbocc = 0;
	*p_buffer = NULL;

	/*|Open the RIS schema */
        if (VdsRisAttach() != SUCCESS) {
	  ERR ("VdsRisSelect", "Cannot open Ris Schema");
	  sts = FAILURE;
	  goto wrapup;
	}

	/*|Discard NULL table */
	if (table == NULL || table[0] == '\0') {
	    ERR ("VdsRisSelect", "table name is null");
	    sts = FAILURE;
	    goto wrapup;
	   }

	/*|Discard NULL select */
	if (select == NULL || select[0] == '\0') {
	    ERR ("VdsRisSelect", "list of selected attribute is null");
	    sts = FAILURE;
	    goto wrapup;
	  }

	/* Treat empty string as NULL pointer */
	if (where == NULL || where[0] == '\0')		where = NULL;
	if (order == NULL || order[0] == '\0')		order = NULL;
	if (group == NULL || group[0] == '\0')		group = NULL;

        /* Allocate memory for query statement */
	query = _MALLOC ( strlen(select) + strlen(table)
			  + (where ? strlen(where) : 0)
                          + (order ? strlen(order) : 0)
                          + (group ? strlen(group) : 0)
                          + 80, char);

        if (query == NULL) {
            ERR ("VdsRisSelect", "Cannot allocate memory for query buffer");
	    sts = FAILURE;
	    goto wrapup;
          }

	/*|Compose select query */
	sprintf ( query, "select %s from %s", select, table);
	if (where != NULL)
	  {
	   sprintf ( query,  "%s where %s", query, where);
	   if (order != NULL) sprintf ( query,  "%s order by %s", query, order);
	   if (group != NULL) sprintf ( query,  "%s group by %s", query, group);

	   /* RIS doesn't support this clause
	   if (having != NULL) sprintf ( query,  "%s having %s", query, having);
	   */
	  }

	/*|Send select query via RIS */
	sts = VDSsql_query( query, &ncols, &nrows, &buf );

	if (sts != SUCCESS) {
           sts = FAILURE;
           goto wrapup;
          }

        if ( ncols != nbatt ) {
	   printf("VdsRisSelect Error: Number of attributes found = %d, input value = %d\n",ncols,nbatt);
           sts = FAILURE;
           goto wrapup;
          }

	*p_nbocc = nrows;

         locptrara = NULL;
         *p_buffer = locptrara; /****** IN CASE OF BAD EXIT ***10/02/00******/
	/*Malloc output buffer */
	if ( nrows * ncols ) {
          /* Original pointer buffer too large  10/02/00 ***/
          int numdbptrs;
          numdbptrs = nrows*ncols;
          locptrara = _CALLOC(numdbptrs,char*);
          *p_buffer = locptrara;
/* ****** DELETED AS UNNECESSARY ********10/02/00***********************
          if (locptrara == NULL) {
              ERR ("VdsRisSelect", "Cannot allocate memory for ouput buffer");
	      sts = FAILURE;
              goto wrapup;
          }
*******************************************************************/
        }
        else {
	    goto wrapup;	/* sts still = SUCCESS */
        }
	/* Copy out attributes */
	for (i=0;i< nrows*ncols; i=i+1) {
            locptrara[i] = buf[i]; /* copy to new ptr array 10/02/00 */
            if (locptrara[i] == NULL) {
               ERR ("VdsRisSelect", "Cannot allocate memory for attributes");
  	       sts = FAILURE;
               goto wrapup;
	     }
          }
          _FREE(buf); /****** Free original pointer buffer 10/02/00  *****/


wrapup:
/* Deleted as unnecessary ***************10/02/00***************
        VdsRisFreeBuffer ( buf, nrows * ncols);
*/
	_FREE (query);

  	__exitFunction ( name = "VdsRisSelect" );
	return sts;
}
/******************************************************************************/

/******************************************************************************/
int VdsRisFreeBuffer ( buffer, n)

	char	**buffer;	/* buffer result of query 		(I) */
	int	n;		/* size of the buffer = occ * att	(I) */

/*.VdsRisFreeBuffer*/
{
	int	i;
	if( buffer == NULL )	return SUCCESS;
	for ( i=0; i<n; i++)
		_FREE(buffer[i]);
	_FREE(buffer);

	return SUCCESS;
}
/******************************************************************************/

/******************************************************************************/
int VdsRisExtractValue ( nbocc, nbatt,  buffer, occ, att, value)

	int	nbocc;		/* max number of occurences 	(I) */
	int	nbatt;		/* max number of attributes	(I) */
	char	**buffer;	/* buffer of data		(I) */
	int	occ;		/* occurence to be extracted	(I) */
	int	att;		/* attribute to be extracted	(I) */
	char	value[];	/* value extracted		(O) */

/*.VdsRisExtractValue*/
{

	if (att >= nbatt) { 
	    printf("VdsRisExtractValue: %dth attribute doesn't exist\n",att); 
	    return FAILURE; }

	if (occ >= nbocc) { 
	    printf("VdsRisExtractValue: %dth occurence does't exist\n", occ); 
	    return FAILURE; }

	if (buffer == NULL) { 
	    ERR ("VdsRisExtractValue", "buffer is null"); 
	    return FAILURE; }

	strcpy ( value, buffer[occ*nbatt + att]);
	return SUCCESS;
}
/******************************************************************************/

/******************************************************************************/
int VdsRisDelete ( table, where)

	char	table[];	/* table where rows will be deleted (I)	*/
	char	where[];	/* where criteria		    (I)	*/

	/*	DELETE FROM <table>	[WHERE <where>]			*/

/*.VdsRisDelete*/
{
	char	*query;		/* SQL query string	*/
        char	err_msg[200];
	int	sts;
	int	len = 0;
	int	num_records = 0;

  	__enterFunction ( name = "VdsRisDelete" );

        query = NULL;
	sts = SUCCESS;

	/*|Open the RIS schema */
        if (VdsRisAttach() != SUCCESS) {
	    ERR ("VdsRisDelete", "Cannot open Ris Schema");
	    sts = FAILURE;
	    goto wrapup;
	   }

	/*|Discard NULL table */
	if (table == NULL || table[0] == '\0' ) {
	    ERR ("VdsRisDelete", "table name is null");
	    sts = FAILURE;
	    goto wrapup;
	   }

        /*
        ** Check wether or not the table exists.
        */
        if( VdsVerifyRisTable( table ) != VDS_DBTABLE_FOUND )
        {
          // sprintf( err_msg, "The table %s is not found", table );
          // ERR( "VdsRisDelete", err_msg );
          // UI_status( err_msg ); 
          sts = FAILURE;
          goto wrapup;
        }

	/* Treat empty string as NULL pointer */
	if (where == NULL || where[0] == '\0')		where = NULL;

	/* Check for the number of rows */
	sts = VDSris_get_count(&num_records, table, where);
	if (sts != SUCCESS)
          { 
	     ERR("VdsRisDelete", "Cannot get number of rows in table");
	     sts = FAILURE;
	     goto wrapup;
	  }
	if (num_records == 0)
	  {
	     sprintf (err_msg, "\tWARNING: No rows in %s match delete criteria.\n", table );
	     VDSprintDbgMsg(err_msg);
	     sts = SUCCESS;
	     goto wrapup;
	  }

        /* Allocate memory for statement */
	len = 80 + strlen(table);
        if (where) len = len + strlen(where);
        query = _MALLOC (len, char); 
        if (query == NULL) {
            ERR ("VdsRisDelete", "Cannot allocate memory for query");
	    sts = FAILURE;
	    goto wrapup;
          }

	/*|Build delete query */
	sprintf ( query, "delete from %s", table);
	if (where != NULL)
		sprintf ( query, "%s where %s", query, where);


	/*|Send delete query via RIS */
	sts = VDSexecute_sql_stmt ( query );

wrapup:
	_FREE (query);

  	__exitFunction ( name = "VdsRisDelete" );
       	return (sts);
}
/******************************************************************************/

/******************************************************************************/
int VdsRisInsert ( table, columns, values, select)

	char	table[];	/* table where rows will be inserted (I) */
	char	columns[];	/* attribute names affected 	     (I) */
	char	values[];	/* where criteria		     (I) */
	char	select[];	/* select criteria		     (I) */

	/*	INSERT INTO <table>	[(<columns>)]	VALUES <values>  */
	/*				OR				 */
	/*	INSERT INTO <table>	[(<columns>)]	SELECT <select>  */

/*.VdsRisInsert*/
{
	char	*query;	/* SQL query string	*/
	int	sts;

  	__enterFunction ( name = "VdsRisInsert" );

        query = NULL;
	sts = SUCCESS;

	/*|Open the RIS schema */
        if (VdsRisAttach() != SUCCESS) {
	    ERR ("VdsRisInsert", "Cannot open Ris Schema");
	    sts = FAILURE;
	    goto wrapup;
          }

	/*|Discard NULL table */
	if (table == NULL || table[0] == '\0' ) {
	    ERR ("VdsRisInsert", "table name is null");
	    sts = FAILURE;
	    goto wrapup;
	   }

	/*|Set null string ( <""> ) to NULL */
	if (columns == NULL || columns[0] == '\0')	columns = NULL;
	if (values == NULL || values[0] == '\0')	values = NULL;
	if (select == NULL || select[0] == '\0')	select = NULL;

        /* Allocate memory for statement */
        query = _MALLOC ((strlen(table) 
				+ (columns ? strlen(columns) : 0)
				+ (select ? strlen(select) : 0)
				+ (values ? strlen(values) : 0) 
				+ 80), char );
        if (query == NULL) {
            ERR ("VdsRisInsert", "Cannot allocate memory for query buffer");
	    sts = FAILURE;
	    goto wrapup;
          }


	 sprintf ( query, "insert into %s", table);

	/*Ignore NULL columns */
	if (columns != NULL)
		sprintf ( query, "%s (%s)", query, columns);

	/*|Discard NULL values */
	if (values == NULL) {
	    if (select== NULL)
	      {
	       ERR ("VdsRisInsert", "no values to insert nor select criteria");
	       sts = FAILURE;
               goto wrapup;
	      }
	    else
		sprintf ( query, "%s select %s", query, select);
	   }

	/*|Discard NULL select */
	if (select == NULL) {
	    if (values == NULL)
	      {
	       ERR ("VdsRisInsert" , "no values to insert nor select criteria");
	       sts = FAILURE;
               goto wrapup;
	      }
	    else
		sprintf ( query, "%s values (%s)", query, values);
	   }

	/*|Send insert query via RIS */
	sts = VDSexecute_sql_stmt ( query );

wrapup:
	_FREE (query);

  	__exitFunction ( name = "VdsRisInsert" );
       	return (sts);
}
/******************************************************************************/

/******************************************************************************/
int VdsRisUpdate ( table, set, where)

	char	table[];	/* table where rows will be updated (I) */
	char	set[];		/* update criteria		    (I) */
	char	where[];	/* where criteria		    (I) */

	/*	UPDATE <table>	SET <set>	[WHERE <where>]		*/

/*.VdsRisUpdate*/
{
	char	*query;	/* SQL query string	*/
	int	sts;

  	__enterFunction ( name = "VdsRisUpdate" );

        query = NULL;
	sts = SUCCESS;


	/*|Open the RIS schema */
        if (VdsRisAttach() != SUCCESS) {
	    ERR ("VdsRisUpdate", "Cannot open Ris Schema");
	    sts = FAILURE;
	    goto wrapup;
	   }

	/*|Discard NULL table */
	if (table == NULL || table[0] == '\0' ) {
	    ERR ("VdsRisUpdate", "table name is null");
	    sts = FAILURE;
	    goto wrapup;
	   }

	/*|Discard NULL set */
	if (set == NULL || set[0] == '\0') {
	    ERR ("VdsRisUpdate", "nothing to update");
	    sts = FAILURE;
	    goto wrapup;
	   }

	/* Treat empty string as NULL pointer */
	if (where == NULL || where[0] == '\0')		where = NULL;

        /* Allocate memory for statement */
        query = _MALLOC ((1+strlen(table) +strlen(set)
				+ (where ? strlen(where) : 0)), char ); 
        if (query == NULL) {
            ERR ("VdsRisUpdate", "Cannot allocate memory for query buffer");
	    sts = FAILURE;
	    goto wrapup;
          }

	/*|Build update query */
	sprintf ( query, "update %s set %s", table, set);
	if (where != NULL)
		sprintf ( query, "%s where %s", query, where);

	/*|Send update query via RIS */
	sts = VDSexecute_sql_stmt ( query );

wrapup:
	_FREE (query);

  	__exitFunction ( name = "VdsRisUpdate" );
       	return (sts);
}
/******************************************************************************/

/******************************************************************************/
/*
/* VdsRisAttach:
/*
/* This function open the RIS schema. It verifies if the corresponding
/* schema is already open and if another schema was opened dettach it
/* before attaching a new one.
/*
/* The RIS schema name and password is automatically retrieved.
/* */

int VdsRisAttach ()

/*.VdsRisAttach*/
{
 	char 		schema_nam[MAXWORD];
 	char 		schema_pwd[MAXWORD];
 	char		schema_log[MAXWORD];
 	int 		sts = 0;

  	__enterFunction ( name = "VdsRisAttach" );

 	/* Retrieve the schema name and password (If the connection to
	 * the database is done.
	 */

 	/* If no connection to the database and no active RIS schema
	 * attached then
 	 */
  	schema_nam[0] = '\0';
  	schema_pwd[0] = '\0';
  	schema_log[0] = '\0';

  	__printf ( ">>>>> VdsExtractDecodedString: TITLE_RIS_NAM = <%s>",
								TITLE_RIS_NAM );

  	sts = VdsExtractDecodedString ( TITLE_RIS_NAM, schema_nam );

  	__printf ( "<<<<< VdsExtractDecodedString: sts = %#x", `sts` );

	if ( sts == 0 ) {
	    sts = FAILURE;
	    goto wrapup;
	}

  	__printf ( ">>>>> VdsExtractDecodedString: TITLE_RIS_PWD = <%s>, schema_nam = <%s>", `TITLE_RIS_PWD, schema_nam` );

  	sts = VdsExtractDecodedString ( TITLE_RIS_PWD, schema_pwd );

  	__printf ( "<<<<< VdsExtractDecodedString: sts = %#x", `sts` );
	if ( sts == 0 ) {
	    sts = FAILURE;
	    goto wrapup;
	}

  	__printf ( "<<<<< VdsExtractDecodedString: sts = %#x, schema_pwd = <%s>", `sts, schema_pwd` );

 	if(     (strcmp(Ris_SchemaName, schema_nam) == 0)
	    &&  (strcmp(Ris_SchemaPwd,  schema_pwd) == 0) ) {
   	   /*The schema is alredy open */
	    sts = SUCCESS;
	    goto wrapup;
  	}

 	if(Ris_SchemaName[0] != '\0') {
   	   /*|Another schema is currently open, detach it first */

/*C	Commented this because if you open another schema RIS automatically
/*	closes the first one before opening this one. So there is no need to
/*	explicityly close it. The problem arises because when you log out of
/*	PDU the connection is already closed, when you try to attach the next
/*	time to a different machine the SchemaName is no longer the same, and
/*	cannot be detached.
 */

   	/*C  VdsRisDetach(); */
  	}

 	/*|Attach RIS schema */
 	if (schema_pwd[0] == '\0')
		strcpy (schema_log, schema_nam);
 	else
		sprintf (schema_log, "%s.%s", schema_nam, schema_pwd);

	sts = VDSopen_ris_schema (schema_log);
 	if (sts == SUCCESS) {
	  if (VDSexecute_sql_stmt ("set mode blank strip off") != SUCCESS) {
              ERR ("VdsRisAttach", "set mode blank strip off");
	    sts = FAILURE;
	    goto wrapup;
	    }

   	   strcpy ( Ris_SchemaName, schema_nam);
   	   strcpy ( Ris_SchemaPwd,  schema_pwd);
	}

wrapup:
  	__exitFunction ( name = "VdsRisAttach" );
       	return (sts);
}
/******************************************************************************/

/******************************************************************************/

/*
/*  VdsRisDetach:
/*
/*  Detach if the attached current RIS schema exists. */


int VdsRisDetach ()

/*.VdsRisDetach*/
{
 	int 		sts;

  	__enterFunction ( name = "VdsRisDetach" );

 	sts = FAILURE;

 	/*|Detach RIS schema */
 	if (Ris_SchemaName[0] == '\0') {
   	   /*|No RIS schema active */
	    sts = SUCCESS;
	    goto wrapup;
  	  }

 	/*|Detach even if it is not the active ..... */
 	sts = VDSclose_ris_schema (Ris_SchemaName);

 	if (sts == SUCCESS) {
	   /*Reset the globals */
 	   Ris_SchemaName[0] = '\0';
 	   Ris_SchemaPwd[0]  = '\0';
	   VDSenvir_name[0] = '\0' ;
  	  }

wrapup:
  	__exitFunction ( name = "VdsRisDetach" );
       	return (sts);
}
/******************************************************************************/

/******************************************************************************/
int VdsSqlInsert ( tab_nam, col_num, col_typ, col_val )

	char		*tab_nam;	/*	I	*/
	int		col_num;	/*	I	*/
	int		*col_typ;	/*	I	*/
	char		**col_val;	/*	I	*/

{

	char		*query;
	int		i,j,dig_found;
        int		alloc_len;
	int		sts;

  	__enterFunction ( name = "VdsSqlInsert" );

        query = NULL;
	sts = SUCCESS;

	/*|Open the RIS schema */
        if (VdsRisAttach() != SUCCESS) {
	    ERR ("VdsSqlInsert", "Cannot open Ris Schema");
	    sts = FAILURE;
	    goto wrapup;
	   }

	/*|Discard NULL table */
	if (tab_nam == NULL || tab_nam[0] == '\0') {
	    ERR ("VdsSqlInsert", "table name is null");
	    sts = FAILURE;
	    goto wrapup;
	   }

	/*|Discard 0 col_num */
	if (col_num <= 0) {
	    printf("Error in VdsSqlInsert: Number of columns = %d\n",col_num);
	    sts = FAILURE;
	    goto wrapup;

	   }

        /* Allocate memory for statement */
	alloc_len = strlen(tab_nam);
        for (i=0;i<col_num;i=i+1)
		alloc_len = alloc_len + 5 +
				+ (col_val[i] ? strlen(col_val[i]) : 0) ;

        query = _MALLOC ((alloc_len+80),  char);
        if (query == NULL) {
            ERR ("VdsSqlInsert", "Cannot allocate memory for query buffer");
	    sts = FAILURE;
	    goto wrapup;
          }

       sprintf ( query, "insert into %s values (", tab_nam);

       for (i=0;i<col_num;i=i+1)
       {
         if (   col_typ[i] == CHAR )
              sprintf(query,"%s '%s'",query,col_val[i]);
	 else if (col_typ[i] == DATE)
	      sprintf( query,"%s timestamp '%s'",query,col_val[i]);
         else
         {
            /* Check if col_val[i] contains at least 1 digit */
            dig_found = FALSE;
	    for (j=0;j<strlen(col_val[i]);j=j+1)
            {
              if (isdigit(col_val[i][j]))
              {
                 dig_found = TRUE;
                 break;
              }
            }

              if (dig_found)    sprintf(query,"%s %s",query,col_val[i]);
              else              sprintf(query,"%s NULL",query);
         }
         if ( i < col_num -1)        sprintf(query,"%s,",query);
       }
       sprintf(query,"%s)",query);

       sts = VDSexecute_sql_stmt ( query );

wrapup:
	_FREE (query);

  	__exitFunction ( name = "VdsSqlInsert" );
       	return (sts);
}
/******************************************************************************/

/******************************************************************************/
int VdsClearStmt ()


{
/* This function is not used any more, kept just for old time sake
/*    RM  920626
/*
/*	/* Clear indexed statement */
/*	if (SgDsqlClearStmt (stmt_number) == RISFAIL) return FAILURE;
/*
/*	return FAILURE;
*/
	return SUCCESS;
}
/******************************************************************************/

int VdsRisEnquireOpenSchema( )
{
 /*
        char            schema_nam[MAXWORD];
        char            schema_pwd[MAXWORD];  Not used	*/

 /* Retrieve the schema name and password (If the connection to the database
 /* is done. */

 /* If no connection to the database and no active RIS schema attached then
 /* */


/*
/*        if ( VdsExtractDecodedString ( TITLE_RIS_NAM,
/*                                      schema_nam) == 0) return FALSE;
/*
/*        if ( VdsExtractDecodedString ( TITLE_RIS_PWD,
/*                                       schema_pwd) == 0) return FALSE;
/*
/*        if( (strcmp(Ris_SchemaName, schema_nam) == 0)
/*        &&  (strcmp(Ris_SchemaPwd,  schema_pwd) == 0) )
/*          {
/*           /*|The schema is already open */
/*           	return TRUE;
/*          }
/*
/*        if(Ris_SchemaName[0] == '\0')
/*          {
/*                return FALSE;
/*          }
/*
/* ... */
        if( Ris_SchemaName[0] == '\0' ||
	    Ris_SchemaPwd[0]  == '\0' )         return FALSE;
         else                                   return TRUE;
}
/*****************************************************************************/

int VdsRisGetPartCount( table, where, count )
char	*table;
char	*where;
int	*count;
{
	char	query[600];
	int	ncols = 0;
	int	nrows = 0;
	char	**buf;
	int	sts=SUCCESS;

	*count = 0;

	/*Discard NULL table */
	if (table == NULL || table[0] == '\0') {
	    ERR ("VdsRisGetPartCount",  "table name is null");
	    sts = FAILURE;
	    goto wrapup;
	   }

	if( where == NULL || where[0] == '\0' )
          sprintf(query, "SELECT count(*) FROM %s ", table);
	else
          sprintf(query, "SELECT count(*) FROM %s WHERE %s ", table, where);

        sts = VDSsql_query ( query, &ncols, &nrows, &buf );
        if ( sts != SUCCESS ) {
           sts = FAILURE;
           goto wrapup;
        }
        *count = nrows;
	sscanf( buf[0], "%d", count );

wrapup:
	VdsRisFreeBuffer ( buf, nrows * ncols );
	return sts;
}

/*****************************************************************************/

int VdsRetrieveAttribute ( dyn_tabname, p_num, p_attr, p_type)

char               dyn_tabname[];
int                *p_num;
char               **p_attr[];
char               **p_type[];

 {
        int                sts;
        char               where[MAXBUFF];
        char               select[MAXBUFF];
        char               **buffer1;
        int                i=0;
        char               coltype[MAXWORD];

  	__enterFunction ( name = "VdsRetrieveAttribute" );

        /*|Open the RIS schema */
        if (VdsRisAttach() != SUCCESS) {
	  ERR ("VdsRetrieveAttribute", "Cannot open Ris Schema");
	  sts = FAILURE;
	  goto wrapup;
	}

	while( dyn_tabname[i] != '\0')
	{
	   dyn_tabname[i] = tolower(dyn_tabname[i]);
	   i++;
	}

        /*|Build <select> and <where> strings*/
        sprintf ( select, "%s,%s,%s",RIS_COL_NAM,RIS_TYP_NAM,RIS_COL_POS);
        sprintf ( where, "%s=\'%s\'", RIS_TAB_NAM, dyn_tabname);

        /*|RIS select*/
        sts = VdsRisSelect ( select,
                                RIS_COLUMNS,
                                where,
                                RIS_COL_POS,
                                (char *)NULL,
                                (char *)NULL,
                                3,
                                p_num,
                                &buffer1 );
        if (sts == FAILURE) {
		ERR ("VdsRetrieveAttribute", "Error in VdsRisSelect");
		goto wrapup;
	}

        if (*p_num == 0) {
           ERR ("VdsRetrieveAttribute", "null response");
	   sts = FAILURE;
	   goto wrapup;
        }
        else {
           /* Malloc attributes' values buffer */
           *p_attr = _MALLOC ( (*p_num), char* );
           if ( (*p_attr) == NULL) {
              ERR ("VdsRetrieveAttribute", "Cannot allocate memory for values buffer");
              sts = FAILURE;
              goto wrapup;
           }

           /* Malloc attributes' datatypes buffer */
           *p_type = _MALLOC ( (*p_num), char* );
           if ( (*p_type) == NULL) {
              ERR ("VdsRetrieveAttribute", "Cannot allocate memory for datatypes buffer");
              sts = FAILURE;
              goto wrapup;
           }

           for ( i=0; i<*p_num; i++)
           {
              /* Malloc attributes' value line */
              (*p_attr)[i] = _MALLOC (MAXWORD, char);
              if ( (*p_attr)[i] == NULL) {
                ERR ("VdsRetrieveAttribute", "Cannot allocate memory for attribute value buffer");
                 sts = FAILURE;
                 goto wrapup;
              }

              /* Retrieve attributes' value */
              sts = VdsRisExtractValue ( *p_num,
                                            3,
                                            buffer1,
                                            i,
                                            0,
                                            (*p_attr)[i] );
              if (sts != SUCCESS) {
                 printf("VdsRisExtractValue failed to fetch p_attr[%d]\n",i);
                 goto wrapup;
              }

              /* Malloc attributes' datatype line */
              (*p_type)[i] = _MALLOC (MAXWORD, char);
              if ( (*p_type)[i] == NULL) {
                ERR ("VdsRetrieveAttribute", "Cannot allocate memory for attribute datatype buffer");
                 sts = FAILURE;
                 goto wrapup;
              }

              /* Retrieve attributes' type */
              sts = VdsRisExtractValue ( *p_num,
                                            3,
                                            buffer1,
                                            i,
                                            1,
                                            coltype );
              if (sts != SUCCESS){
                 printf("VdsRisExtractValue failed to fetch coltype\n");
                 goto wrapup;
              }
              if (sts != SUCCESS) goto wrapup;

              sprintf ( (*p_type)[i], "%d", VdsEvaluateDatatype(coltype) );
           }
        }

wrapup:
        VdsRisFreeBuffer ( buffer1, *p_num * 3);

  	__exitFunction ( name = "VdsRetrieveAttribute" );
        return sts;
}


