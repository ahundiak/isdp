/****************************************************************************/
/*                                                                          */
/*     This file contains routines to retreive given list of attributes     */
/*     with partno. and part revision number as key. If part no. is a       */
/*     formula, gets the individual parameters involved and from the        */
/*     computed part no, gets value for these parameters and gets the       */
/*     unique record for the attributes of interest.                        */
/*                                                                          */
/*                    Creation Date: 24/Jun/92    MMS (IGI)                 */
/*                                                                          */
/****************************************************************************/
/*
#include <stdio.h>
#include <malloc.h>
#include <string.h>
#if defined (__sgi) || defined (__Sol2__) || defined (sparc)
#include <XFIproto_pub.h>
#else
#include <FIproto_pub.h>
#endif
#include <PALglbs.h>
#include <PDUstr.h>
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
*/

#include "PALpdmr.h"
#include "PALpdmrpro.h"

#define FALSE 0
#define TRUE  1

#define MAX_PARAM_IN_FORMULA 45

#define DEL1 "$"
#define DEL2 "!"


extern int PDU_ComputedID;	/* Indicates whether 'partno' is Computable */
extern char *attribs_in_ID;	/* Contains the columns in the Computable ID */
extern char *vals_of_attribs_in_ID;	/* Contains the values of */
		         	/*	columns in the Computable ID 	*/
extern int col_indxs[MAX_PARAM_IN_FORMULA];
extern int NoColsInID;

/**********************   Extern Globale Variables ***********************/
extern	char *s_text;

extern	struct	PDUrefresh *refresh;

extern char **AttrList;
extern int NumAttribs ;
/************************************************************************/

GetUniqRecord (	char *catalog, char *partid, char *revision, 
		char *attributes[], int no_attributes, 
		char **output)
{
	char	*ptr , *clause, *query, **selected_attribs;
	int	i = 0, sts, maxrows = 1, err, j ;
	char    *temp;

	_pdm_debug("Enter: GetUniqRecord",0);
	if( no_attributes == 0 )
		return( 1 );

	if (PDU_ComputedID){	/* 'partno'  is of Computable type */

		_pdm_debug(" GetUniqRecord: PDU_computeID TRUE",0);
		
		/** Get the attributes in the Computable ID **/
		/* Build where clause to retrieve values */
		_pdm_debug("attribsinID=%s",attribs_in_ID);
		_pdm_debug("valsofattribsinID=%s",vals_of_attribs_in_ID);

		temp = (char *)malloc(strlen(attribs_in_ID)+1);
		strcpy(temp, attribs_in_ID);
		ptr = strtok (temp, "~");
		selected_attribs = (char **)malloc(NoColsInID * sizeof(char *));
		while( ptr != NULL ) {
			_pdm_debug("ptr=%s",ptr);
			selected_attribs[i] = (char *)malloc(strlen(ptr)+1);
			strcpy(selected_attribs[i++],ptr);
			ptr = strtok(NULL,"~");
		}
			
		clause = (char *) malloc (2);
		clause[0] = '\0'; j = 0;
		temp = (char *)realloc(temp,strlen(vals_of_attribs_in_ID)+1);
		strcpy(temp, vals_of_attribs_in_ID);

		ptr = strtok (temp, "~");
		
		while (ptr != NULL ){
			if (j > 0)
				strcat (clause, " and ");

			_pdm_debug("ptr=%s",ptr);
			clause = (char *) realloc (clause, strlen (clause) +
							   strlen (selected_attribs[j])+
							   strlen (" = ") + strlen (ptr)
							    + 15 );

			_pdm_debug("attrib=%s",selected_attribs[j]);
			strcat (clause, selected_attribs[j++]);
			strcat (clause, " = ");
			strcat (clause, ptr);
			ptr = strtok (NULL, "~");
			_pdm_debug("clause = %s",clause);
		}

		FreeArrayPtr (selected_attribs, i);

	}
	else	{		/* 'partno' is plain type */ 
		_pdm_debug(" GetUniqRecord: PDU_computeID FALSE",0);

		/* Build where clause to retrieve values */
		/* Add 'partno' and 'revision number' to the where clause */
		clause = (char *) malloc (512);
		sprintf  (clause, " n_itemname = '%s' and n_itemrev = '%s' ",
				partid, revision);
	}

	query = (char *) malloc ((no_attributes * 20 + 132) * sizeof (char));

	/* Build PRE query */
	strcpy (query, "Select ");
	/* Attribute list */
	for (i = 0; i < no_attributes; i++){
		if (i > 0)
			strcat (query, ", ");
		strcat (query, attributes[i]);
	}
	strcat (query, " From ");
	/* TABLE */
	strcat (query, catalog);
	strcat (query, " Where ");


	/* Add the where clause */
	query = (char *) realloc (query, strlen (query) + strlen (clause) + 1);

	strcat (query, clause );

	MyFree (clause);

	_pdm_debug("GetStatAddToRg: Query: %s", query );

	/* Send RIS query */
	sts = RISquery (query, &maxrows, output, &err);	
	MyFree (query);

	if (sts < 0){
		free (*output);
		fprintf (stderr, "Error In RIS Operation - %d\n", err);
		return (0);
	}

	_pdm_debug("output: %s", *output );
	return (1);
}

GetStaticAttribsAddToRgObj( struct GRid *hdr, char **attribslist, char **attr_types,char **attunits, int no_attributes, struct GRid *rg_grids )
{
	int  i=0, coll ;
	char *output_str, *ptr , tmpstr[100] ;
	struct stemp *temp_desc;
	int num_org, num_loc, num_coll;

	_pdm_debug("Enter: GetStaticAttribsAddToRgObj",0);


	if( no_attributes == 0 )
		return( 1 );

	GetOriginalMacroInfo( hdr, &temp_desc, &num_org, &num_loc, &num_coll);

	if( ! GetUniqRecord (refresh->rev_catalog, 
			     refresh->rev_partid, 
			     refresh->rev_revision, 
			     attribslist , no_attributes, &output_str))
		return(0);

	ptr = strtok (output_str, "~");

	while(ptr != NULL ){

		_pdm_debug("ptr: %s", ptr );

		/* convert to design units */
		if( !strncmp(attunits[i],"inch",4) || 
			!strncmp(attunits[i],"mm",2) ){

			strcpy(tmpstr,ptr);
			from_cat_to_work_units(1,attunits[i],tmpstr);
			ptr = tmpstr ;

		}

		_pdm_debug("temp type: %s", attr_types[i]);

		if( GetDyncolIndx( temp_desc, attribslist[i], num_org, num_loc,
                                                      &coll ) == -1 )
		{
			/* attrib not mapped to any collection 
			free( output_str );
			return( 0 ); */
			/* CHANGED behaviour for the sake of PDMNORM, Vdaps 
                           CIMacro, which has unmapped attributes - 03/02/93 */
			coll = 0;
		}

		if(! strcmp(attr_types[i],"Expression double") )
		        add_attribute( &rg_grids[coll], ptr, attribslist[i],
						AC_ATTRIB_DOUBLE);
		else
		        add_attribute( &rg_grids[coll], ptr, attribslist[i],
						AC_ATTRIB_TEXT);
		++i ;
		ptr = strtok(NULL,"~");
	}
	free( output_str );

	return(1);
}

ComputeIDAddToDynCol(char *catname, struct GRid *rggrid)
{

	int sts , num;
	char  *computed_id = NULL ;
	char **attrs, **types, **vals ;

	_pdm_debug ("Enter ComputeIDAddToDynCol()", 0);

/************************************************************
	if(! PDU_ComputedID )
		return(1);

	for( i = 0 ; i < num ; i ++ )
		if( !strcmp( "n_itemname", attrs[i] ) )
			break;

	if( i == num )
	{
		_pdm_debug("No n_itemname in collection???",0);
		return(0);
	}
	strcpy( itname, vals[i] );

	_pdm_debug("ComputedID found in collection is %s",itname);

	ptr = itname;
	while( *ptr )
		if( *ptr++ == '$' )
			break;
	if( *ptr == '\0')
	{
		PDU_ComputedID = FALSE;
		return(1);
	}
***************************************************************/

	if( !ReadAtrsFromCols(rggrid , &attrs, &types, &vals, &num))
		return(0);

	if( !GetID_N_Compute(catname, attrs, vals, types, num, &computed_id, 0)){
		sts = 0;
		goto CleanUp;
	}
	
        add_attribute(rggrid, computed_id, "n_itemname",AC_ATTRIB_TEXT);	
	
	MyFree(computed_id);
	
	sts = 1 ;

CleanUp:
	FreeArrayPtr(attrs,num);
	FreeArrayPtr(vals,num);
	FreeArrayPtr(types,num);

	_pdm_debug ("Exit ComputeIDAddToDynCol() : sts = %d", sts);

	return(sts);
}

getattrs( Tablename, string, /*num,attrs, attrtype,*/ computed_id )
char *Tablename;     /* I */
char *string;        /* I */
char *computed_id ;  /* I */
/*char **attrs;      * I *
char **attrtype;     * I *
int  num;            * I */
{
int  i=0 , num_vals, maxlen = 0 , j  ;
char *ptr;
char **sel_vals = NULL;

char *output, query[256];
char dyn_table[41];
char l_tablename[41];
char tablename[41];
int  maxrows, sts, errcode;
char **attrs = NULL, **attrtype = NULL;
int  numattr;
char **tables, **columns;
int numtbls, numcols;
char val[41], tab_str[2096];

	_pdm_debug( "Entered getattrs with CID=%s", computed_id );
	_pdm_debug( "string is %s", string );

        /* Do a RIS query and obtain the static catalog attributes and types */

        l_tablename [0] = '\0';
        tablename [0] = '\0';
        strcpy (tablename, Tablename);

    /* first get the dyn table associated with this cat */

       sts = PDMget_dyntable_for_catalog (tablename, dyn_table);

       _PDMdebug ("getattr", "dynamic table[%s]\n", dyn_table);

    /* Fix added to make sure that catnames are all lower case */
        tablename [0] = '\0';
        strcpy (tablename, Tablename);
        l_tablename [0] = '\0';
        PDMconvert_to_lower (tablename, l_tablename);
        _pdm_debug ("l_tablename  : %s", l_tablename);

       /* Now get all the tables associated with the view */
        
     if(SVSGetTablesAndColumnsInView(tablename, &tables,&numtbls,
                                          &columns,&numcols)) {

       tab_str [0] = '\0';
       val [0] = '\0';
       _PDMdebug ("getattr", "numtbls[%d]numcols[%d]\n", numtbls, numcols);
       
       for (i = 0; i < numtbls; i++ ){
           val [0] = '\0';
           sprintf (val, ", '%s' \0", tables[i]);
           _PDMdebug ("getattr", "val[%s]\n", val);
           strcat (tab_str, val);
         }

       SVSFreeTablesAndColumns (&tables, numtbls, &columns, numcols);

       _PDMdebug ("getattr", "tab_str[%s]\n", tab_str);
 
       val [0] = '\0';
       if (strcmp (dyn_table, "")) {
          sprintf (val, ", '%s' ", dyn_table);  
          strcat (tab_str, val);
               }
 
       _PDMdebug ("getattr", "tab_str[%s]\n", tab_str);

/* RIS dictionary tables in V5 named different. 26/apr/95 - raj. */
 
#if defined ( RISV4 )

	sprintf(query," SELECT column_name, ris_type_string from riscolumns where table_name in ( '%s' %s ) ", l_tablename, tab_str);

#elif defined ( RISV5 )

	sprintf(query," SELECT column_name, ris_type_string from ris5columns where table_name in ( '%s' %s ) ", l_tablename, tab_str);

#else
#error "RIS version must be defined"
#endif

        }
      else {
        _PDMdebug ("getattr", "ERROR: VIEW PARSER FAILED\n") ;

/* RIS dictionary tables in V5 named different. 26/apr/95 - raj. */
 
#if defined ( RISV4 )

	sprintf(query," SELECT column_name, ris_type_string from riscolumns where table_name = '%s'", l_tablename);

#elif defined ( RISV5 )

	sprintf(query," SELECT column_name, ris_type_string from ris5columns where table_name = '%s'", l_tablename);

#else
#error "RIS version must be defined"
#endif

        }

/*
	sprintf(query," SELECT column_name, ris_type_string from riscolumns where table_name = '%s'", l_tablename);
*/

	_pdm_debug("query:%s",query);

	maxrows = 0;
	sts = RISquery(query, &maxrows, &output, &errcode);

	_pdm_debug("query output: %s",  output);

	if( sts < 0 ) {
        	RIS_box(errcode);
	        free(output);
        	return(0);
	}
	numattr = 0;
	ptr = strtok( output, "~");
	while( ptr )
	{
		if( numattr == 0 )
		{
			attrs = (char **)malloc(sizeof(char *));
			attrtype = (char **)malloc(sizeof(char *));
		}
		else
		{
			attrs = (char **)realloc(attrs,sizeof(char *)*(numattr+1));
			attrtype = (char **)realloc(attrtype,sizeof(char *)*(numattr+1));
		}
		attrs[numattr] = (char *)malloc(strlen(ptr) + 1 );
		strcpy(attrs[numattr],ptr);
                _PDMdebug ("getattr", "attrs[%d] = %s\n", numattr, attrs[numattr]);
      

		ptr = strtok(NULL,"~"); /* type */
		attrtype[numattr] = (char *)malloc(strlen(ptr) + 1 );
		strcpy(attrtype[numattr],ptr);
                _PDMdebug ("getattr", "attrtype[%d] = %s\n", numattr, attrtype[numattr]);

		ptr = strtok(NULL,"~");
		numattr++;
	}
	_pdm_debug("Numattr = %d",numattr);

	MyFree(output);

	ptr = strtok(computed_id, DEL1);

        i = 0;
	while(ptr != NULL ) {
		if( i == 0 )
			sel_vals = (char **)malloc( sizeof(char *));	
		else
			sel_vals = (char **)realloc( sel_vals, (i+1) * sizeof(char *));	

		ptr = strtok(NULL,DEL2);			
		sel_vals[i] = (char *)malloc(strlen(ptr)+1);

		if( strlen(ptr) > maxlen )
			maxlen = strlen(ptr);

               _PDMdebug ("getattr", "sel_vals[%d] = %s\n", i, ptr);
		strcpy(sel_vals[i++],ptr);
             
	
		ptr = strtok (NULL,DEL1);
	}

	num_vals = i ;
	_pdm_debug("Number of Values = %d", num_vals );
	_pdm_debug("Maxlen = %d",maxlen);

	/* Start parsing */

	ptr = NULL;
	ptr = strtok (string, DEL1); /* text */
	if (ptr == NULL) 
	{
		printf ( "Invalid string for Compute:%s:\n", string );
		return (0);
	}

	MyFree(attribs_in_ID);
	MyFree(vals_of_attribs_in_ID);

	attribs_in_ID = (char *) malloc (num_vals * 22 * sizeof (char));

	attribs_in_ID[0] = '\0';

	vals_of_attribs_in_ID = (char *) malloc (num_vals * (maxlen+3) * sizeof (char));
	vals_of_attribs_in_ID[0] = '\0' ;

	j = 0 ;
	while (ptr != NULL)
	{
		ptr = strtok (NULL, DEL2);   /* col name */
		_pdm_debug("column name = %s", ptr );
		for( i = 0 ; i < numattr ; ++i ) 
		 if(!strcmp (attrs[i] ,ptr)){	/* Column is static attribute */
                  _PDMdebug ("getattr", "attrs[%d] = %s\n", i, attrs[i]);
		 	strcat(attribs_in_ID,ptr);
		 	strcat(attribs_in_ID,"~");

		 	if( !strncmp(attrtype[i],"char",4) ||
		 	    !strcmp(attrtype[i],"Expression text")){
		 		strcat(vals_of_attribs_in_ID,"'");
		 		strcat(vals_of_attribs_in_ID,sel_vals[j]);
		 		strcat(vals_of_attribs_in_ID,"'");
		 	}
		 	else						
		 		strcat(vals_of_attribs_in_ID,sel_vals[j]);
		 	strcat(vals_of_attribs_in_ID,"~");
		 	j++;						
 	_pdm_debug("attribsinID = %s",attribs_in_ID );				
 	_pdm_debug("valsofattribsinID = %s",vals_of_attribs_in_ID );	
		 	break;
		 } 
		 if( j == num_vals )
		 	break;

 	_pdm_debug("attribsinID = %s",attribs_in_ID );				
 	_pdm_debug("valsofattribsinID = %s",vals_of_attribs_in_ID );	
 	ptr = strtok (NULL, DEL1); /* Skip the text */
	}

	for( i = 0 ; i < num_vals ; ++i )
		MyFree(sel_vals[i]);
	for( i = 0 ; i < numattr ; ++i )
	{
		MyFree(attrs[i]);
		MyFree(attrtype[i]);
	}
	MyFree(sel_vals);
	MyFree(attrs);
	MyFree(attrtype);

	if( j != num_vals ) /* Did not find some attributes in catalog that are in CID */
		return(0);

	NoColsInID = num_vals;
	_pdm_debug(" attribs_in_ID = %s", attribs_in_ID );
	_pdm_debug(" vals_of_attribs_in_ID = %s", vals_of_attribs_in_ID );
	_pdm_debug(" number of colums in ID = %d", NoColsInID );

	return( 1 );

}

check_CID(catalogname,  acdyncolobj)
char *catalogname;
struct GRid *acdyncolobj;
{
	int tblno;
	char view[6], *tmp;
/*
	struct ACrg_coll *list_attr;
	int nb_attr;
	char **attrs, **attrtypes, **vals;
*/	

	PDU_ComputedID = FALSE;

	if(!GetCatTableNo(catalogname,&tblno,view))
		return(0);
		
	if(strcmp(view,"CID") && strcmp (view, "EID")) /*  not view catalog */
	{
		_pdm_debug("Not a view catalog %s",view);
		return(1);
	}

	tmp = refresh->rev_partid;

	while ( *tmp )
	{
		if( *tmp == '$' )
			break;
		*tmp++;		
	}

	if( *tmp == '\0' ) /* No Formula string in n_itemname */
	{
		/* Use the "Ansicht" value if found in the collection, This is required
                   for getting a unique record for PDMNORM catalogs
		*/
		if( !CheckACrgAttribVal(acdyncolobj, "v_A", &tmp ))
			return(0);

		MyFree(attribs_in_ID);
		MyFree(vals_of_attribs_in_ID);
		attribs_in_ID = (char *) malloc ( strlen("n_itemname") +
						  strlen("n_itemrev") + 15);
		MemCheck(attribs_in_ID);
		attribs_in_ID[0] = '\0';
		vals_of_attribs_in_ID = (char *) malloc ( strlen(refresh->rev_partid) +
						  strlen(refresh->rev_revision) + 20 );
		MemCheck(attribs_in_ID);
		vals_of_attribs_in_ID[0] = '\0' ;

		strcat(attribs_in_ID,"n_itemname~n_itemrev~v_a~");
		strcat(vals_of_attribs_in_ID,"'");
		strcat(vals_of_attribs_in_ID,refresh->rev_partid);
		strcat(vals_of_attribs_in_ID,"'~'");
		strcat(vals_of_attribs_in_ID,refresh->rev_revision);
		strcat(vals_of_attribs_in_ID,"'~'");
		strcat(vals_of_attribs_in_ID,tmp);
		strcat(vals_of_attribs_in_ID,"'~");

		NoColsInID = 3;
		PDU_ComputedID = TRUE;
		return(1);
	}	
/*
	if (!GetACrgAttribList ( acdyncolobj, &list_attr, &nb_attr))
		return (0);

	attrs = (char **)malloc( nb_attr * sizeof(char *));
	MemCheck(attrs);
	attrtypes = (char **)malloc( nb_attr * sizeof(char *));
	MemCheck(attrtypes);
	vals = (char **)malloc( nb_attr * sizeof(char *));
	MemCheck(vals);

	for( i = 0; i < nb_attr; i++ )
	{
		(attrs)[i] = (char *)malloc(strlen(list_attr[i].name) + 1);
		MemCheck((attrs)[i]);
		strcpy( (attrs)[i], list_attr[i].name);

		_pdm_debug("copied attib = %s",(attrs)[i]);

		(attrtypes)[i] = (char *)malloc(strlen("double") + 1);
		MemCheck((attrtypes)[i]);

		if( list_attr[i].desc.type == AC_ATTRIB_TEXT )
		{
			strcpy( (attrtypes)[i], "char");
			vals[i] = (char *)malloc(strlen(list_attr[i].desc.value.att_txt)+1);
			strcpy( vals[i], list_attr[i].desc.value.att_txt);
		}
		else
		{
			strcpy( (attrtypes)[i], "double");
			vals[i] = (char *)malloc(80);
			sprintf(vals[i],"%g",list_attr[i].desc.value.att_exp);
		}

		_pdm_debug("copied attib type = %s",(attrtypes)[i]);
		_pdm_debug("copied attib val = %s",vals[i]);
	}
*/

	if( !GetattrsGivenID( refresh->rev_partid, catalogname )) 
					/*, nb_attr, attrs, attrtypes, vals ))*/
		return(0);

	PDU_ComputedID = TRUE ;
	return(1);
}

AddStatAttrsToQuery( struct GRid *statcol )
{
char **attrs, **types, **vals;
int  i, num;

	if( !ReadAtrsFromCols( statcol , &attrs, &types, &vals, &num))
		return(0);

	/* Add the static attributes, except n_catalogname,n_itemname,revision */

	for( i = 0; i < num; i++ )
	{
		if( !strcmp( attrs[i], "n_catalogname" ) || 
		    !strcmp( attrs[i], "n_itemname" )    || 
		    !strcmp( attrs[i], "n_itemrev" ) )
			continue;

		if( !strcmp( types[i], "Expression text"))
		{
			attribs_in_ID = (char *)realloc( attribs_in_ID, strlen(attribs_in_ID) +
						strlen( attrs[i] ) + 5 );

			vals_of_attribs_in_ID = (char *)realloc( vals_of_attribs_in_ID,
					 strlen( vals_of_attribs_in_ID ) +
					 strlen( vals[i] ) + 5 );

			strcat( attribs_in_ID, attrs[i] );
			strcat( attribs_in_ID, "~" );

			strcat( vals_of_attribs_in_ID,"'");
			strcat( vals_of_attribs_in_ID, vals[i]);
			strcat( vals_of_attribs_in_ID,"'");
			strcat( vals_of_attribs_in_ID, "~");
			NoColsInID += 1;
		}
	}
	_pdm_debug(" attribs_in_ID = %s", attribs_in_ID );
	_pdm_debug(" vals_of_attribs_in_ID = %s", vals_of_attribs_in_ID );
	_pdm_debug(" number of colums in ID = %d", NoColsInID );

	return(1);
}

