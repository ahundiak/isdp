/* $Id: OldRisSql.C,v 1.1.1.1 2001/01/04 21:09:12 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdris/imp / OldRisSql.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: OldRisSql.C,v $
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
/*#include	"common.h" */
#include	"igrtypedef.h"
#include	"VDSris_siz.h"
#include	"VDSris_def.h"

#include        "math.h"
#include        "stdlib.h"

/*#include	"VDScheckin.h" */
#include	"VDSserver.h"

#define		AS_DEBUG	1

extern	char 	*Ris_SchemaName;
extern	char    *Ris_SchemaPwd;

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

	char		select[];		/* selected attributes	  (I) */
	char		table[];		/* table name		  (I) */
	char		where[];		/* where clause		  (I) */
	char		order[];		/* order by clause	  (I) */
	char		group[];		/* group by clause	  (I) */
	char		having[];		/* having clause	  (I) */
	int		nbatt;			/* no attr of select str. (I) */
	int		*p_nbocc;		/* number of rows	  (O) */
	char		**p_buffer[];		/* result buffer	  (O) */

	/*
		SELECT <select>	FROM <table>	[WHERE <where>]
		  				[ORDER BY <order>]
		  				[GROUP BY <group>]
		discarded			[HAVING <having>]
	*/

/*.VdsRisSelect*/
{

	char		*query;			/* complete select string   */
	int		status;			/* RIS status		    */
        int		ncols;			/* Number of columns found in
                                                   select statement */
	int		nrows;			/* Number of rows found */

	int		i;
        char		**buf;
        int             len_having ; /* 92/11/18 */

	status = SUCCESS;
        query = NULL;
	*p_nbocc = 0;
	*p_buffer = NULL;

	/*|Open the RIS schema */
        if (VdsRisAttach() != SUCCESS)
	  { printf("Error in VdsRisAttach\n"); return FAILURE; }

	/*|Set null string ( <""> ) to NULL */

	/*|Discard NULL table */
	if (table == NULL)
	   {
	    printf("Error : table name is null\n");
	    return FAILURE;
	   }

	/*|Discard NULL select */
	if (select == NULL)
	  {
	   printf("Error : selected attributes list is null\n"); 
	   return FAILURE;
	  }
        /* Allocate memory for query statement */
/*
        query = (char *) malloc ((strlen(select)
                                 +strlen(table)
                                 +strlen(order)
                                 +strlen(group)
                                 +strlen(having)+80) * sizeof (char));
*/
        /* -> 92/11/18 fix (because optional arguments are set to NULL) */

        if (having != NULL)     len_having = strlen(having) ;
        else                    len_having = 0 ;


        query = (char *) malloc ((strlen(select)
                                 + strlen(table)
				 + (where ? strlen(where) : 0)
                                 + (order ? strlen(order) : 0)
                                 + (group ? strlen(group) : 0)
                                 + len_having+80) * sizeof (char));

        if (query == NULL)
          {
           printf ("VdsRisSelect Error : Cannot allocate memory for query buffer\n");
           return (FAILURE);
          }

	/*|Compose select query */
	sprintf ( query, "select %s from %s", select, table);
	if (where != NULL)
	  {
	   sprintf ( query,  "%s where %s", query, where);
	   if (order != NULL) sprintf ( query,  "%s order by %s", query, order);
	   if (group != NULL) sprintf ( query,  "%s group by %s", query, group);
	   /* RIS dont admit this clause 
	   if (having != NULL) sprintf ( query,  "%s having %s", query, having);
	   */
	  }

	/*|Send select query via RIS */
	status = VDSsql_query( query, &ncols, &nrows, &buf );

	if (status != SUCCESS)
          {
           status = FAILURE;
           goto quit;
          }

        if ( ncols != nbatt )
          {
	   printf("VdsRisSelect Error: Number of attributes found = %d, input value = %d\n",ncols,nbatt);
           status = FAILURE;
           goto wrapup;
          }

	*p_nbocc = nrows;

	/*|Malloc output buffer */

        *p_buffer = (char **) malloc ( nrows * ncols * sizeof (char*) );
        if (*p_buffer == NULL)
          {
            printf ("VdsRisSelect : cannot malloc (char **)\n");
	    status = FAILURE;
            goto wrapup;
          }

	for (i=0;i< nrows*ncols; i=i+1)
          {
	    /*|Malloc buffer's string */
            (*p_buffer)[i] = (char *) malloc (strlen(buf[i]) + sizeof(char));
            if ((*p_buffer)[i] == NULL)
             {
               printf ("VdsRisSelect : cannot malloc (char *)\n");
  	       status = FAILURE;
               goto wrapup;
	     }
           strcpy ( (*p_buffer)[i], buf[i]);
          }
wrapup:
        VdsRisFreeBuffer ( buf, nrows * ncols);
quit:
        if (query != NULL) free(query);

	return status;
}
/******************************************************************************/

/******************************************************************************/
int VdsRisFreeBuffer ( buffer, n)

	char	**buffer;	/* buffer result of query 		(I) */
	int	n;		/* size of the buffer = occ * att	(I) */

/*.VdsRisFreeBuffer*/
{
	int	i;
	
	for ( i=0; i<n; i++) if (buffer[i] != NULL) free(buffer[i]);
        if (buffer != NULL) free(buffer);

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

	if (att >= nbatt)
	  { printf("%dth attribute don't exists\n", att); return FAILURE; }

	if (occ >= nbocc)
	  { printf("%dth occurence don't exists\n", occ); return FAILURE; }

	if (buffer == NULL)
	  { printf("buffer is null\n", occ); return FAILURE; }

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
	int	sts;

        query = NULL;
	sts = SUCCESS;

	/*|Open the RIS schema */
        if (VdsRisAttach() != SUCCESS) return FAILURE;

	/*|Set null string ( <""> ) to NULL */
	if (table[0] == 0)	table = NULL;
	if (where[0] == 0)	where = NULL;

	/*|Discard NULL table */
	if (table == NULL)
	   {
	    printf("Error : table name is null\n");
	    return FAILURE;
	   }

        /* Allocate memory for statement */
        query = (char *) malloc ((strlen(table)
                                 +strlen(where)+80) * sizeof (char));
        if (query == NULL)
          {
           printf ("VdsRisDelete Error : Cannot allocate memory for statement buffer\n");
           return (FAILURE);
          }

	/*|Build delete query */
	sprintf ( query, "delete from %s", table);
	if (where != NULL) sprintf ( query, "%s where %s", query, where);

	/*|Send delete query via RIS */
	sts = VDSexecute_sql_stmt ( query );
        if (query != NULL) free(query);

	return sts;
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

        query = NULL;
	sts = SUCCESS;

	/*|Open the RIS schema */
        if (VdsRisAttach() != SUCCESS) return FAILURE;

	/*|Set null string ( <""> ) to NULL */
	if (table[0]   == 0)	table   = NULL;
	if (columns[0] == 0)	columns = NULL;
	if (values[0]  == 0)	values  = NULL;
	if (select[0]  == 0)	select  = NULL;

        /* Allocate memory for statement */
        query = (char *) malloc ((strlen(table)
                                 +strlen(columns)
                                 +strlen(select)
                                 +strlen(values)+80) * sizeof (char));
        if (query == NULL)
          {
           printf ("VdsRisInsert Error : Cannot allocate memory for statement buffer\n");
           return (FAILURE);
          }


	/*|Discard NULL table */
	if (table == NULL)
	   {
	    printf("Error : table name is null\n");
	    sts = FAILURE;
            goto quit;
	   }
	else sprintf ( query, "insert into %s", table);

	/*|Discard NULL columns */
	if (columns != NULL) sprintf ( query, "%s (%s)", query, columns);

	/*|Discard NULL values */
	if (values == NULL)
	   {
	    if (select== NULL)
	      {
	       printf("Error : no values to insert nor select criteria\n");
	       sts = FAILURE;
               goto quit;
	      }
	    else sprintf ( query, "%s select %s", query, select);
	   }

	/*|Discard NULL select */
	if (select == NULL)
	   {
	    if (values == NULL)
	      {
	       printf("Error : no values to insert nor select criteria\n");
	       sts = FAILURE;
               goto quit;
	      }
	    else sprintf ( query, "%s values (%s)", query, values);
	   }

	/*|Send insert query via RIS */
	sts = VDSexecute_sql_stmt ( query );
quit:
	if (query != NULL) free(query);

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

        query = NULL;
	sts = SUCCESS;


	/*|Open the RIS schema */
        if (VdsRisAttach() != SUCCESS) return FAILURE;

	/*|Set null string ( <""> ) to NULL */
	if (table[0] == 0)	table = NULL;
	if (set[0]   == 0)	set   = NULL;
	if (where[0] == 0)	where = NULL;

	/*|Discard NULL table */
	if (table == NULL)
	   {
	    printf("Error : table name is null\n");
	    return FAILURE;
	   }

	/*|Discard NULL set */
	if (set == NULL)
	   {
	    printf("Error : nothing to update\n");
	    return FAILURE;
	   }

        /* Allocate memory for statement */
        query = (char *) malloc ((strlen(table)
                                 +strlen(set)
                                 +strlen(where)+80) * sizeof (char));
        if (query == NULL)
          {
           printf ("VdsRisUpdate Error : Cannot allocate memory for statement buffer\n");
           return (FAILURE);
          }

	/*|Build update query */
	sprintf ( query, "update %s set %s", table, set);
	if (where != NULL) sprintf ( query, "%s where %s", query, where);

	/*|Send update query via RIS */
	sts = VDSexecute_sql_stmt ( query );
        if (query != NULL) free(query);

	return sts;
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
 	int 		status;

 /* Retrieve the schema name and password (If the connection to the database
 /* is done. */

 /* If no connection to the database and no active RIS schema attached then
 /* */

	if ( VdsExtractDecodedString ( TITLE_RIS_NAM,
                                       schema_nam) == 0) return FAILURE;
	if ( VdsExtractDecodedString ( TITLE_RIS_PWD,
                                       schema_pwd) == 0) return FAILURE;

 	if( (strcmp(Ris_SchemaName, schema_nam) == 0)
	&&  (strcmp(Ris_SchemaPwd,  schema_pwd) == 0) )
  	  {
   	   /*|The schema is alredy open */
   	   return SUCCESS;
  	  }
 	if(Ris_SchemaName[0] != '\0')
  	  {
   	   /*|Another schema is currently open, detach it first */
   	   /* VdsRisDetach(); */
  	  }

 	/*|Attach RIS schema */
 	if (schema_pwd[0] == '\0') strcpy (schema_log, schema_nam);
 	else sprintf (schema_log, "%s.%s", schema_nam, schema_pwd);
	status = VDSopen_ris_schema (schema_log);
 	if (status == SUCCESS) 
  	  { 
	  if (VDSexecute_sql_stmt ("set mode blank strip off") != SUCCESS)
            { printf("Error in executing, set mode blank strip off\n");
              return FAILURE; }

   	   strcpy ( Ris_SchemaName, schema_nam);
   	   strcpy ( Ris_SchemaPwd,  schema_pwd);
   	   return SUCCESS;
  	  }

 	return FAILURE;
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
 	int 		status;

 	/*|Detach RIS schema */
 	if (Ris_SchemaName[0] == '\0') 
  	  {
   	   /*|No RIS schema active */
   	   return SUCCESS;
  	  }

 	/*|Detach even if it is not the active ..... */
 	status = VDSclose_ris_schema (Ris_SchemaName);

 	if (status == SUCCESS) 
  	  { 
	   /*|Reset the global */
 	   Ris_SchemaName[0] = '\0';
 	   Ris_SchemaPwd[0]  = '\0';

	   VDSenvir_name[0] = '\0' ;

   	   return SUCCESS;
  	  }

 	return FAILURE;
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

        query = NULL;
	sts = SUCCESS;

	/*|Open the RIS schema */
        if (VdsRisAttach() != SUCCESS) return FAILURE;

	/*|Discard NULL table */
	if (tab_nam == NULL || tab_nam[0] == 0)
	   {
	    printf("VdsSqlInsert Error : table name is null\n");
	    return FAILURE;
	   }

	/*|Discard 0 col_num */
	if (col_num <= 0)
	   {
	    printf("VdsSqlInsert Error : Number of columns = %d\n",col_num);
	    return FAILURE;
	   }

        /* Allocate memory for statement */
	alloc_len = strlen(tab_nam);
        for (i=0;i<col_num;i=i+1) alloc_len = alloc_len + strlen(col_val[i]) +5;

        query = (char *) malloc ((alloc_len+80) * sizeof (char));
        if (query == NULL)
          {
           printf ("VdsRisUpdate Error : Cannot allocate memory for statement buffer\n");
           return (FAILURE);
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
       if (query != NULL) free(query);
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
	int	status=SUCCESS;

	*count = 0;
	if( where == NULL )
          sprintf(query, "SELECT count(*) FROM %s ", table);
	else
          sprintf(query, "SELECT count(*) FROM %s WHERE %s ", table, where);

        status = VDSsql_query ( query, &ncols, &nrows, &buf );
        if ( status != SUCCESS )
        {
           status = FAILURE;
           goto quit;
        }
        *count = nrows;
	sscanf( buf[0], "%d", count );

	VdsRisFreeBuffer ( buf, nrows * ncols );
quit:
	return status;

}


int VdsRetrieveAttribute ( dyn_tabname, p_num, p_attr, p_type)

char               dyn_tabname[];
int                *p_num;
char               **p_attr[];
char               **p_type[];

 {
        int                status;
        char               where[MAXBUFF];
        char               select[MAXBUFF];
        char               **buffer1;
        int                i=0;
        char               coltype[MAXWORD];

        /*|Open the RIS schema */
        if (VdsRisAttach() != SUCCESS)
        { printf("Error in VdsRisAttach\n"); return FAILURE; }
	while( dyn_tabname[i] != '\0')
	{
	   dyn_tabname[i] = tolower(dyn_tabname[i]);
	   i++;
	}

        /*|Build <select> and <where> strings*/
        sprintf ( select, "%s,%s,%s",RIS_COL_NAM,RIS_TYP_NAM,RIS_COL_POS);
        sprintf ( where, "%s=\'%s\'", RIS_TAB_NAM, dyn_tabname);

        /*|RIS select*/
        status = VdsRisSelect ( select,
                                RIS_COLUMNS,
                                where,
                                RIS_COL_POS,
                                (char *)NULL,
                                (char *)NULL,
                                3,
                                p_num,
                                &buffer1 );
        if (status == FAILURE) { printf("Error in VdsRisSelect\n"); goto quit; }

        if (*p_num == 0)
        {
           printf("null response\n");
           return FAILURE;
        }
        else
        {
           /* Malloc attributes' values buffer */
           *p_attr = (char **) malloc ( (*p_num)*sizeof(char*) );
           if ( (*p_attr) == NULL)
           {
              printf( "Error malloc values buffer\n");
              status = FAILURE;
              goto quit;
           }

           /* Malloc attributes' datatypes buffer */
           *p_type = (char **) malloc ( (*p_num)*sizeof(char*) );
           if ( (*p_type) == NULL)
           {
              printf( "Error malloc datatypes buffer\n");
              status = FAILURE;
              goto quit;
           }

           for ( i=0; i<*p_num; i++)
           {
              /* Malloc attributes' value line */
              (*p_attr)[i] = (char *) malloc (MAXWORD * sizeof(char));
              if ( (*p_attr)[i] == NULL)
              {
                 printf( "Error malloc value line\n");
                 status = FAILURE;
                 goto quit;
              }

              /* Retrieve attributes' value */
              status = VdsRisExtractValue ( *p_num,
                                            3,
                                            buffer1,
                                            i,
                                            0,
                                            (*p_attr)[i] );
              if (status != SUCCESS)
              {
                 printf("VdsRisExtractValue failed to fetch p_attr[%d]\n",i);
                 goto quit;
              }

              /* Malloc attributes' datatype line */
              (*p_type)[i] = (char *) malloc (MAXWORD * sizeof(char));
              if ( (*p_type)[i] == NULL)
              {
                 printf( "Error malloc value line\n");
                 status = FAILURE;
                 goto quit;
              }

              /* Retrieve attributes' type */
              status = VdsRisExtractValue ( *p_num,
                                            3,
                                            buffer1,
                                            i,
                                            1,
                                            coltype );
              if (status != SUCCESS)
              {
                 printf("VdsRisExtractValue failed to fetch coltype\n");
                 goto quit;
              }
              if (status != SUCCESS) goto quit;

              sprintf ( (*p_type)[i], "%d", VdsEvaluateDatatype(coltype) );
           }
        }

quit:
        VdsRisFreeBuffer ( buffer1, *p_num * 3);
        return status;
 }

