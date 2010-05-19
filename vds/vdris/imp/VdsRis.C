/* $Id: VdsRis.C,v 1.1.1.1 2001/01/04 21:09:12 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdris/imp / VdsRis.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VdsRis.C,v $
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
 * Revision 1.4  1996/05/03  19:04:22  pinnacle
 * Replaced: vdris/imp/VdsRis.C for:  by v240_int for vds.240
 *
 * Revision 1.3  1996/04/21  23:39:26  pinnacle
 * Replaced: vdris/imp/VdsRis.C for:  by v240_int for vds.240
 *
 * Revision 1.2  1996/04/21  23:27:24  pinnacle
 * Replaced: vdris/imp/*.C for:  by v240_int for vds.240
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	11/26/91   Marc Fournier	creation
 *	04/10/96   tlb			Use VDS memory allocation checking
 *					Add prototypes
 *	04/21/96   tlb			Change load message on screen
 *	04/25/95   tlb			Fix malloc error messages, format
 *
 * -------------------------------------------------------------------*/

#include	<stdio.h>
#include	<string.h>

#include	"VDSris_siz.h"
#include	"VDSris_def.h"
#include	"VDScheckin.h"
#include	"vdbmacros.h"
#include	"VDmem.h"

#define		AS_DEBUG	1

/******************************************************************************/

/******************************************************************************/
int VdsDeleteRows ( key, table_name, catalog, partnum, partrev)

	char		*key;
	char		*table_name;
	char		*catalog;
	char		*partnum;
	char		*partrev;

/*.VdsDeleteRows*/
{
	int		status;
	char		string[MAXBUFF];

	/*|Build delete string */
	if      (strcmp ( key, REG_CHECKIN) == 0)
	  {
	   sprintf ( string,
		     "%s=\'%s\' and %s=\'%s\' and %s=\'%s\'",
		     REG_CATALOG, catalog,
		     REG_PARTNUM, partnum,
		     REG_PARTREV, partrev );
	  }
	else if (strcmp ( key, DWG_CHECKIN) == 0)
	  {
	   sprintf ( string,
		     "%s=\'%s\' and %s=\'%s\' and %s=\'%s\'",
		     DWG_CATALOG, catalog,
		     DWG_PARTNUM, partnum,
		     DWG_PARTREV, partrev );
	  }
	else return FAILURE;

	/*|RIS delete */
        status = vdb$RisDelete ( table_name  =   table_name,
                                 where       =   string);

	return status;
}
/******************************************************************************/

/******************************************************************************/
int VdsInsertRows ( table_name, number, chartype, inttype, row,
		    p_delete, p_print, to_sql, sqlfile )

	char		table_name[];	/* (I) : database table name	      */
	int		number;		/* (I) : number of RIS types	      */
	char		*chartype[];	/* (I) : array of RIS types (char)    */
	int		inttype[];	/* (I) : array of RIS types (int)     */
	char		row[];		/* (I) : row of data		      */
	int		*p_delete;	/* (I/O) : clear table before insert  */
	int		*p_print;	/* (I/O) : print table loaded	      */
        int             to_sql;         /* (I) : Post to DB/write to SQLfile  */
        FILE            *sqlfile;       /* (I) : File pointer to ASCII file   */


/*.VdsInsertRows*/
{
	int		n=0;
	int		i;
	int		len;
	char		risbuf[MAXBUFF];
	int		status;
	char		**charvalue;
	int		last;
	int		curr;
	int		mall;
	int		datatype[MAXATTR];


	charvalue = (char **) NULL;

      	if( to_sql != 1) {
		if (*p_print == PRINT_Y) {
	   		printf("\t... loading %s\n", table_name);
			fflush(stdout);
	   		*p_print = PRINT_N;
	  	}

		if (*p_delete == DELETE_Y) {
	   		/*|RIS delete */
           		status = vdb$RisDelete (  table_name =  table_name,
                                     		  where      =  NULL);
           		if (status != SUCCESS) status = RISFAIL;
	   		*p_delete = DELETE_N;
	  		}
       		}


	/*|Initialize values for the new string */
        len = VdsCleanString(row);
	if (len == FAILURE) { 
		status = RISFAIL; 
		goto quit; 
		}

        len = VdsNormalize(row);
	if (len == FAILURE) { 
		status = RISFAIL; 
		goto quit; 
		}

	last      = 0;
	curr      = 0;
	n         = 0;
	risbuf[0] = 0;
	charvalue = NULL;
	
	charvalue = _MALLOC ( number,  char * );
        _CheckAlloc ( charvalue, "charvalue array", status, FAILURE, quit);

	/*|Search separator in row */
	for (i=0;i<len;i++) {
	   if ( ( (i == 0) && (row[i] == SEP_CHAR) )
	   ||   ( (row[i] == SEP_CHAR) && (row[i-1] != BACK_SLASH) ) )
	     {
	      curr = i;
	      mall = 1 + curr - last;
	      if (mall <= 2) mall = 2;
	      charvalue[n] = NULL;
	      charvalue[n] = _MALLOC (mall, char);
              _CheckAlloc ( charvalue[n], "charvalue line", status, 
								FAILURE, quit);
			
	      /*|Fill array line */
	      for (i=last;i<curr;i++) charvalue[n][i-last] = row[i];
	      charvalue[n][curr-last] = 0;
	      last = curr + 1;
	      n++;
	     }
	  }

        /*|Convert RIS datatypes */
        if (inttype == NULL)
          { for (i=0;i<n;i++) datatype[i] = atoi(chartype[i]); }
        else
	  { for (i=0;i<n;i++) datatype[i] = inttype[i]; }


	if( to_sql != 1) {
	   /*|Embeded SQL insert & prepare (perhaps) */
	   status = VdsSqlInsert ( table_name, number, datatype, charvalue);
           if (status != SUCCESS) 
		goto quit;
	   }
	else {
           status = VdsSqlAscii ( table_name, number, datatype, 
							charvalue, sqlfile);
           if (status != SUCCESS) 
		goto quit;
           }


quit:
	/*|Free charvalue array */
	_LOOPFREE(charvalue, n);

        /*|Close ASCII file */
	return status;
}
/******************************************************************************/

/******************************************************************************/
int VdsReadCompNo (p_comp_no)

	int		*p_comp_no;

/*.VdsReadCompNo*/
{
	int		status;
	char		set[MAXBUFF];
	int		nbocc;
	char		**buffer;
	char		value[MAXWORD];
	char		cmd[MAXWORD];

	buffer = NULL;

	/*|Set transaction on */
        status = VDSexecute_sql_stmt ( "set transaction autocommit off" );
	if (status != SUCCESS ) goto quit;

	/*|Lock table COMP_NO_TABLE */
	sprintf (cmd,"lock tables %s in share mode",COMP_NO_TABLE);
        status = VDSexecute_sql_stmt ( cmd );
	if (status != SUCCESS ) goto quit;

	/*|RIS select */
	status = vdb$RisSelect (  select       =   NEW_COMP_NO,
			          table_name   =   COMP_NO_TABLE,
			          where        =   NULL,
			          order        =   NULL,
			          group        =   NULL,
			          numselect    =   1,
			          p_numrows    =   &nbocc,
			          p_buffer     =   &buffer );

	if ( (status == FAILURE) || (nbocc != 1) )
        {
/*          status = FAILURE;	/* In order to return FAILURE if nbocc != 1 */
          goto quit;
        }

	/*|Extract value from buffer */
        status = 
        vdb$RisExtractValue (   nbrows      =    nbocc,
                                nbcolumns   =    1,
                                buffer      =    buffer,
                                row         =    0,
                                column      =    0,
                                value       =    value );
	if (status == FAILURE) goto quit;
	*p_comp_no = atoi (value);

	/*|RIS update */
	sprintf ( set, "%s=%d", OLD_COMP_NO, *p_comp_no);
	status = VdsRisUpdate ( COMP_NO_TABLE, set, NULL);
        if (status != SUCCESS) goto quit;

quit:
	/*|Free buffer */
	vdb$RisFreeBuffer (  buffer  =    buffer,
                             size    =    nbocc * 1);

/*        if (status != RISFAIL) return SUCCESS;
	else		       return FAILURE;
*/
	return status;
}
/******************************************************************************/

/******************************************************************************/
int VdsWriteCompNo (comp_no)

	int		comp_no;

/*.VdsWriteCompNo*/
{
	int		status;
	char		set[MAXBUFF];

	/*|Next avalaible comp_no */
	comp_no++;

	/*|RIS update */
	sprintf ( set, "%s=%d", NEW_COMP_NO, comp_no);
	status = VdsRisUpdate ( COMP_NO_TABLE, set, NULL);
        if (status != SUCCESS) goto quit;

	/*|Unlock table COMP_NO_TABLE */
        status = VDSexecute_sql_stmt ( "commit" );
	if (status != SUCCESS ) goto quit;

	/*|Set transaction of */
        status = VDSexecute_sql_stmt ( "set transaction autocommit on" );
	if (status != SUCCESS ) goto quit;

quit:
        return status;
}
/******************************************************************************/

/******************************************************************************/
int VdsGetCatId (catalog, p_catalog_id)

	char		catalog[];
	int		*p_catalog_id;

/*.VdsGetCatId*/
{
	int		status;
	char		where[MAXWORD];
	int		nbocc;
	char		**buffer;
	char		value[MAXWORD];

	/*|Build where string */
	sprintf ( where, "%s = \'%s\'", CATALOG_NAM,  catalog);

	/*|RIS select */
	status = vdb$RisSelect ( select       =    CATALOG_NUM,
			         table_name   =    CATALOG_TAB,
			         where        =    where,
			         order        =    NULL,
			         group        =    NULL,
			         numselect    =    1,
			         p_numrows    =    &nbocc,
			         p_buffer     =    &buffer );

	if ( (status == FAILURE) || (nbocc != 1) ) goto quit;

	/*|Extract value from buffer */
	status = vdb$RisExtractValue ( nbrows     =    nbocc,
                                       nbcolumns  =    1, 
                                       buffer     =    buffer,
                                       row        =    0,
                                       column     =    0,
                                       value      =    value);

	if (status == FAILURE) goto quit;
	*p_catalog_id = atoi (value);

quit:
	/*|Free buffer */
	vdb$RisFreeBuffer ( buffer =  buffer, 
                            size   =  nbocc * 1);
	return status;
}
/******************************************************************************/

/******************************************************************************/
int VdsGetPartId ( catalog, partnum, revision, p_part_id)

	char		catalog[];
	char		partnum[];
	char		revision[];
	int		*p_part_id;

/*.VdsGetPartId*/
{
	int		status;
	char		where[MAXWORD];
	int		nbocc;
	char		**buffer;
	char		value[MAXWORD];

	/*|Build where string */
	sprintf ( where,
		  "%s = \'%s\' and %s = \'%s\'",
		  PART_NAM,
		  partnum,
		  PART_REV,
		  revision );

	/*|RIS select */
	status = vdb$RisSelect (  select      =   ITEM_NUM,
			          table_name  =   catalog,
			          where       =   where,
			          order       =   NULL,
			          group       =   NULL,
			          numselect   =   1,
			          p_numrows   =   &nbocc,
			          p_buffer    =   &buffer );

	if ( (status == FAILURE) || (nbocc != 1) ) goto quit;

	/*|Extract value from buffer */
	status = vdb$RisExtractValue ( nbrows     =       nbocc,
                                       nbcolumns  =       1, 
                                       buffer     =       buffer,
                                       row        =       0,
                                       column     =       0, 
                                       value      =       value );

	if (status == FAILURE) goto quit;
	*p_part_id = atoi (value);

quit:
	/*|Free buffer */
	vdb$RisFreeBuffer (  buffer   =      buffer, 
                             size     =      nbocc * 1);
	return status;
}
/******************************************************************************/

/******************************************************************************/
int VdsGetIdentifier ( catalog, partnum, revision,
                       p_catalog_id, p_part_id )

	char		catalog[];
	char		partnum[];
	char		revision[];
	int		*p_catalog_id;
	int		*p_part_id;

/*.VdsGetIdentifier*/
{
	int		status;
        
	*p_catalog_id = 0;
	*p_part_id    = 0;

	/*|Retrieve catalog ID */
	status = VdsGetCatId (catalog, p_catalog_id);
        if (status != SUCCESS) goto quit;

	/*|Retrieve part/revision ID */
        status = VdsGetPartId (catalog, partnum, revision, p_part_id);
        if (status != SUCCESS) goto quit;

quit:

/*	if (status != RISFAIL) status = SUCCESS; */
        return status;
}
/******************************************************************************/

/******************************************************************************/

/* This function post to the database the information contained in row.
/* The table name to post is concatenated with DYNAMIC. */


/*

int VdsPostDb ( key, catalog, partnum, partrev, table,
	        number, datatype, row, p_delete, to_sql, sqlfile)

	char		*key;	
	char		*catalog;
	char		*partnum;
	char		*partrev;
	char		*table;	
	int		number;	
	char		**datatype;
	char		*row;	
	int		*p_delete;
        int             to_sql; 
                                 
        FILE            *sqlfile;


{
 	int		status = SUCCESS;
 	char		table_name[MAXWORD];
	int		delete = DELETE_N;
	int		print = PRINT_N;

       if( to_sql != 1)
       {
        if (VdsRisAttach() != SUCCESS) return FAILURE;
       }

	sprintf ( table_name, "%s%s", table, key);
       if( to_sql != 1)
       {
	if ((*p_delete) == DELETE_Y)
	  {
 	   status = VdsDeleteRows ( key, table_name, catalog, partnum, partrev);
 	   if (status != SUCCESS)
  	     {
   	      printf ( "VdsDeleteRows returns %d\n", status);
   	      goto quit;
  	     }
	   *p_delete = DELETE_N;
  	  }
        }

 	status = VdsInsertRows ( table_name,
				 number,
				 datatype,
				 (int *) NULL,
				 row,
				 &delete,
				 &print,
				 to_sql,
				 sqlfile );
 	if (status != SUCCESS)
  	  {
   	   printf ( "VdsInsertRows returns %d\n", status);
   	   goto quit;
  	  }

quit:
	return status;
}
*/
/******************************************************************************/

