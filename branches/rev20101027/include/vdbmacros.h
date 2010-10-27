/* $Id: vdbmacros.h,v 1.1.1.1 2001/01/04 21:07:31 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/include / vdbmacros.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdbmacros.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:31  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.4  1997/11/20  14:57:16  pinnacle
 * Replaced: include/vdbmacros.h for:  by mdong for vds
 *
 * Revision 1.3  1997/11/20  14:19:16  pinnacle
 * prototype
 *
 * Revision 1.2  1997/11/18  14:44:16  pinnacle
 * Replaced: include/vdbmacros.h for:  by mdong for vds
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
 *	MM/DD/YY	AUTHOR	DESCRIPTION
 *	11/20/97	ah	A protype was changed to use IGRchar
 *				but not every file includes igrtypedef
 *				so I added an include
 *      11/20/97        M.Dong  I add a new macro vdb$RisSelectTable() 
 *				which can be used to select all or part of 
 *				table names in DB
 * -------------------------------------------------------------------*/


#ifndef vdbmacros_include
#define vdbmacros_include

#ifndef   igrtypedef_include
#include "igrtypedef.h"
#endif

/*
 * 	This file depends on the following files :
 */

/*---------------------------------------------------------------------------*/
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

extern int VdsRisSelect __((	char *select,
				char *table,
				char *where,
				char *order,
				char *group,
				char *having,
				int  nbatt,
				int  *p_nbocc,
				char ***p_buffer )); 

extern int VdsRisFreeBuffer __(( char **buffer,
				 int  size ));

extern int VdsRisExtractValue __((	int  nbrows,
					int  nbcolumns,
					char **buffer,
					int  row,
					int  column,
					char *value ));
extern int VdsRisDelete __((	char *table_name,
				char *where ));

extern int VdsRisInsert __((	char *table_name,
				char *columns,
				char *values,
				char *select ));

extern int VdsRisGetPartCount __((	char *table_name,
					char *where,
					int  *count ));

extern int VdsRetrieveAttribute __(( 	char *table_name,
					int  *p_num,
					char ***p_attr,
					char ***p_type ));
extern int VdsRisSelectTable __((    IGRchar *tabnam,
                                     char    *order,
                                     char    *group,
                                     int     *p_nbocc,
                                     char    ***p_buffer ));


#if defined(__cplusplus)
}
#endif

/*
 * the following return codes are expected for the macros
 * as described below.
 */
#define         SUCCESS         1
#define		FAILURE         0

/*---------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------
MACRO
	vdb$RisSelect(	select,
			table_name,
			where	= NULL,
			order	= NULL,
			group	= NULL,
			numselect,
			p_numrows,
			p_buffer )

ABSTRACT
	This macro lets you select a specified number of columns from a 
	specified table. 
	The where, order and group clauses may be specified or not.

ARGUMENTS
	data type	argument 	I/O description

	char 		*select		I : Select columns
	char 		*table_name	I : Table from which to select.
	char 		*where		I : where clause.
	char 		*order		I : order by clause.
	char 		*group		I : group by clause.
	int		numselect	I : number of columns in select stmt.
	int 		*p_numrows	O : number of rows retrieved.
	char 		***p_buffer	O : buffer containing the selected cols.

STATUS RETURNS
	SUCCESS   : 1
	FAILURE   : 0
-----------------------------------------------------------------------------*/
#omdef vdb$RisSelect( 	select,
			table_name,
			where	= NULL,
			order	= NULL,
			group	= NULL,
			numselect,
			p_numrows,
			p_buffer )
	VdsRisSelect( (select), (table_name), (where), (order), (group), NULL,
		  (numselect), (p_numrows), (p_buffer) );
#endomdef
/*---------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------
MACRO
	vdb$RisSelectTable(	tabnam,
				order	= NULL,
				group	= NULL,
				p_numrows,
				p_buffer )

ABSTRACT
	This macro lets you select a specified number of table names from  
        database.  The format of tabnam is like:
        1. If tabnam is "*", all the table names will be selected.
        2. If tabnam is like "abc*" or "abc", all the table names which
           starts with string "abc" will be selected.
        3. If tabnam is like "*abc*" or "*abc", all the table names which 
           have occurrence of string "abc" will be selected.
	The order and group clauses may be specified or not.
        User's responsibility to free p_buffer by calling vdb$RisFreeBuffer()
  Note: Do not use % in table name.

ARGUMENTS
	data type	argument 	I/O description

	IGRchar 	*tabnam		I : Table name.
	char 		*order		I : order by clause.
	char 		*group		I : group by clause.
	int 		*p_numrows	O : number of table names selected.
	char 		***p_buffer	O : buffer containing the selected
					    table names. 

STATUS RETURNS
	SUCCESS   : 1
	FAILURE   : 0
-----------------------------------------------------------------------------*/
#omdef vdb$RisSelectTable( 	tabnam,
			        order	= NULL,
				group	= NULL,
				p_numrows,
				p_buffer )
     VdsRisSelectTable( (tabnam), (order), (group), (p_numrows), (p_buffer) );
#endomdef
/*---------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------
MACRO
	vdb$RisFreeBuffer( buffer,
			  size )
ABSTRACT
	This macro lets you free the buffer allocated by vdb$RisSelect.

ARGUMENTS
	data_type	argument	I/O description

	char		**buffer	I : Buffer.
	int		size		I : Size of the buffer, (rows*columns).

STATUS RETURNS
	SUCCESS   : 1
	FAILURE   : 0
-----------------------------------------------------------------------------*/
#omdef vdb$RisFreeBuffer( buffer,
			 size )
	VdsRisFreeBuffer( (buffer), (size) );
#endomdef
/*---------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------
MACRO
	vdb$RisExtractValue (	nbrows,
				nbcolumns,
				buffer,
				row,
				column,
				value )
ABSTRACT
	This macro lets you extract the specified column from a specified row
	in the buffer.

ARGUMENTS
	data_type	argument	I/O description

	int		nbrows		I : Total number of rows in the buffer.
	int		nbcolumns	I : Total columns in the buffer.
	char		**buffer	I : Buffer from which to extract.
	int		row		I : Row to extract.
	int		column		I : Column to extract.
	char		*value		O : value of the extracted column.

STATUS RETURNS
	SUCCESS   : 1
	FAILURE   : 0
-----------------------------------------------------------------------------*/
#omdef vdb$RisExtractValue (	nbrows,
				nbcolumns,
				buffer,
				row,
				column,
				value )
	VdsRisExtractValue( (nbrows), (nbcolumns), (buffer), (row), (column),
			    (value));
#endomdef
/*---------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------
MACRO
	vdb$RisDelete(	table_name,
			where )
ABSTRACT
	This macro lets you delete rows from a table with an optional specified
	where clause.
	WARNING: If the where clause is not specified all the rows in the table
		 will be deleted.

ARGUMENTS
	data_type	argument	I/O description

	char		*table_name	I : Table to be affected.
	char		*where		I : where clause defining a specific
					    number of rows.

STATUS RETURNS
	SUCCESS   : 1
	FAILURE   : 0
-----------------------------------------------------------------------------*/
#omdef vdb$RisDelete (	table_name,
			where = NULL )
	VdsRisDelete ( (table_name), (where) );
#endomdef
/*---------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------
MACRO
	vdb$RisInsert(	table_name,
			columns,
			values,
			select )
ABSTRACT
	This macro lets you insert rows into the specified table. 
	The number of columns should match the number of values or the columns
	in the select statement.

ARGUMENTS 
	data_type	argument	I/O description

	char		*table_name	I : Table to be affected.
	char		*columns	I : The columns to be affected.
					    eg. "col1,col2,col3".
	char		*values		I : values of the colums.
					    eg. "'value1',value2,'value3'".
					    value1 and value3 are character 
					    values.
	char		*select		I : select statement for getting the
					    values.
				  eg., "select prj_number from vds_project"

STATUS RETURNS
	SUCCESS   : 1
	FAILURE   : 0
-----------------------------------------------------------------------------*/
#omdef vdb$RisInsert (	table_name,
			columns  = NULL,
			values=NULL ^ select=NULL )
	VdsRisInsert ( (table_name), (columns), (values), (select) );
#endomdef
/*---------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------
MACRO
	vdb$RisGetNumberOfParts (  table_name,
				  where,
				  count )
ABSTRACT
	This macro gets the number of parts ( or rows) in a catalog/table.

ARGUMENTS 
	data_type	argument	I/O description

	char		*table_name	I : Table to be affected.
	char		*where		I : Where condition.
	int		*count		O : Number of parts/rows found.

STATUS RETURNS
	SUCCESS   : 1
	FAILURE   : 0
-----------------------------------------------------------------------------*/
#omdef  vdb$RisGetNumberOfParts ( table_name,
				 where = NULL,
				 count )
	VdsRisGetPartCount( (table_name), (where), (count) );
#endomdef
/*---------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------
MACRO
	vdb$RetrieveAttributes ( table_name,
				p_num,
				p_attr,
				p_type )
ABSTRACT
	This macro retrieves all the attributes for a table and their data-
	types. The datatypes are defined in VDSris_def.h.

ARGUMENTS 
	data_type	argument	I/O description

	char		*table_name	I : Table to be affected.
	int		*p_num		O : number of columns.
	char		***p_attr	O : Names of columns.
	char		***p_type	O : Data types of the columns.

STATUS RETURNS
	SUCCESS   : 1
	FAILURE   : 0
-----------------------------------------------------------------------------*/
#omdef	vdb$RetrieveAttributes ( table_name,
				p_num,
				p_attr,
				p_type )
	VdsRetrieveAttribute ( (table_name), (p_num), (p_attr), (p_type) );
#endomdef

/*---------------------------------------------------------------------------*/

#endif
