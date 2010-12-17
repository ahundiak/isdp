/***************************************************************************/
/*                                                                         */
/*   This file contains routines for search of common attributes across    */
/*   catalogs                                                              */
/*                Date Created : 16/06/82       MMS (IGI)                  */
/*                                                                         */
/***************************************************************************/
/*
#include <stdio.h>
#include <string.h>
#include "FIproto_pub.h"
#include "PALglbs.h"
#include "PDUstr.h"
*/

#include "PDUerror.h"
#include "PDMmessage.h"
#include "PALpdmr.h"
#include "PALpdmrpro.h"

/*
extern char *malloc();
extern char *realloc();
*/

/*------------------------------------------------------------------ */
/*  External variables */
extern char  *s_text;
extern struct PDUrefresh *refresh ;
/*	TR # 139308062.	03/aug/93.	*/
extern int	PDU_ComputedID          ;
extern int	PDU_command          ;
/*------------------------------------------------------------------ */


/*------------------------------------------------------------------ */
/*  Globale variables */
char **AttrList 	 ;    	/* common attribute list    */
char **AttrSynonym 	 ;	/* synonyms of attributes   */
char **AttrTypes   	 ;      /* attribute types          */
int  NumAttribs          ;	/* No. of common attributes */

char  ViewOrTblList[MAX_CATALOGS][6];     		/* view(PV) or table (PT) */
char  CatNameList[MAX_CATALOGS][TBL_LEN];	      	/* List of catalog names  */
int  NumCatalogs , TblNos[MAX_CATALOGS];   		/* no. of catalogs and corresponding 
                                              		   table numbers 
                                             		*/
/*	TR # 139308062.		03/aug/93 - raj.	*/
char 	**AttrValsRep_PPart;
/*------------------------------------------------------------------ */

search_common_attribs(Form fp , MEMptr out_buffr)

	/***  
	    This routine gets the list of catalogs under current classification
            level , and the list of attributes common to these catalogs
        ***/
{
	int i;

	char **catlist;

        _pdm_debug("in the function search_common_attribs", 0);

	PDUmessage (PDS_M_GET_COMM_ATTR, 's');

if( IGEresetstop ()) {
        _pdm_debug("IGEresetstop for with union Attrib failed %d", 0);
                }

	catlist = (char **)malloc(MAX_CATALOGS * sizeof(char *));

	for( i = 0 ; i < MAX_CATALOGS ; ++i )
		catlist[i] = (char *)malloc(TBL_LEN);
	
	if( ! PALgetcatlist (fp, out_buffr, &NumCatalogs, catlist,1 ))
	{
		PDUmessage(PDM_E_CLEAR_FIELD, 's' );
		return(0);
	}

	for( i = 0 ; i < NumCatalogs ; ++i )
		strcpy(CatNameList[i], catlist[i]);

	FreeArrayPtr(catlist,MAX_CATALOGS);

	if( NumAttribs != 0 ){
		FreeArrayPtr(AttrList,NumAttribs);
		FreeArrayPtr(AttrSynonym,NumAttribs);
		FreeArrayPtr(AttrTypes,NumAttribs);
		NumAttribs = 0;
	}

	/* Having gotten table nos, get the attributes common to them */
	if( ! SearchAttribsAcrossCatalogs() ){

		NumCatalogs = 0 ;
		FreeArrayPtr (AttrList,NumAttribs );
		PDUmessage(PDM_E_CLEAR_FIELD, 's' );	
		return(0);
	}
        if(NumAttribs == 0)
	PDUmessage(PDM_E_NO_COMMON_ATTRIB, 's' );
        else
	PDUmessage(PDM_E_CLEAR_FIELD, 's' );
	return(1);
}

PALgetcatlist(Form fp, MEMptr out_bufr, int *numcat, char **catlist,int flag )
{
	int  i, j   ;
	char **data_ptr, *ptr  ;
        char *msg;

	*numcat = 0 ;

	data_ptr = (char **)out_bufr -> data_ptr ;

	_pdm_debug("PALgetcatlist(): No .of catalogs: %d", (out_bufr->rows));
	/* TR # 13931 3587. 30/Nov/93 - raj. Check catalog limit here.	*/
        /* MJG - ignore catalog limit for search format and union atrs 1/4/93 */
	if( (out_bufr -> rows) >  MAX_CATALOGS  && 
             PDU_command != PDS_M_GET_UNION_ATTR &&
             PDU_command != PDS_M_GET_LIST_ATTR )
	{
 		*numcat = 0 ;
                msg = (char *)PDUtranslate_message(PDM_E_TOO_MANY_CATALOGS);
		FIfld_set_text(fp,FI_MSG_FIELD,0,0,msg,FALSE);
		return(0) ;
	}

	for ( i = 0 ; i < out_bufr -> rows ; i = i + 1 ){
		
		ptr = data_ptr [i*out_bufr -> columns + 4] ;
		if( !strcmp( ptr,"C") ){

			ptr = data_ptr [i*out_bufr -> columns + 1] ;	
			if( !ptr || strlen(ptr) < 1 )
				ptr = data_ptr [i*out_bufr -> columns + 2] ;

			strcpy(catlist[*numcat],ptr);
			(*numcat) ++;

			_pdm_debug("catalog in SAC: %s", catlist[(*numcat)-1] );
			if( flag && ((*numcat) == MAX_CATALOGS) )
				break;
		}
	}


 	if( *numcat < 1 ){
                msg = (char *)PDUtranslate_message(PDM_E_CATALOG_NOT_FOUND);
		FIfld_set_text(fp,FI_MSG_FIELD,0,0,msg,FALSE);
		return(0) ;
	}

	if( ! flag )
		return(1);

	/* TR # 13931 3587. 30/Nov/93 - raj. This check is redundant, since */
	/* we make sure that *numcat == MAX_CATALOGS in the loop above.	    */
        /* MJG - ignore catalog limit for search format and union atrs 1/4/93 */
	if( *numcat >  MAX_CATALOGS &&
            PDU_command != PDS_M_GET_UNION_ATTR &&
            PDU_command != PDS_M_GET_LIST_ATTR ) {
		*numcat = 0 ;
                msg = (char *)PDUtranslate_message(PDM_E_TOO_MANY_CATALOGS);
		FIfld_set_text(fp,FI_MSG_FIELD,0,0,msg,FALSE);
		return(0) ;
	}

 	if( *numcat == 1 ){
		*numcat = 0 ;
                msg = (char *)PDUtranslate_message(PDM_E_ONE_CATALOG_IN_LEVEL);
		FIfld_set_text(fp,FI_MSG_FIELD,0,0,msg,FALSE);
		return(0) ;
	}

	/* Get 'n_tableno' for each catalog table name from nfmtables */
	for( i = 0 ; i < *numcat ; i = i + 1 ){

		if( ! GetCatTableNo(catlist[i],&TblNos[i],ViewOrTblList[i]) ){
			_pdm_debug("Error getting table no. of catalog",0);
			*numcat = 0 ;
			return(0);
		}

                if( IGEstop ()) {
        _pdm_debug("IGEstop for with union Attrib enabled %d", 0);
                 IGEresetstop();
		*numcat = 0 ;
                return(0);
                }

		/* Avoid Views from search across common attributes */
		if( !strcmp(ViewOrTblList[i],"CID") ) {
			for( j = i ; j < (*numcat) -1 ; ++j ) 
				strcpy(catlist[j],catlist[j+1]);

			*numcat = *numcat - 1 ;
			--i;
		}
	}

	return(1);
}

/*    --------------------------  GetCatTableNo ()  --------------------- */

GetCatTableNo(char *cat_name, int *tbl_no, char *viewORtable)

	/* Given a catalog name, get the corresponding table number from      */
	/* nfmtables. Also the catalog identifier - PT (table) or PV (view)   */
	/* from nfmcatalogs 						      */
{

	int  max_rows , err_code , sts ;
	char query_string[1024] , *output_string = NULL, *ptr = NULL;

	if( strlen(cat_name) < 1 )
		return(0);

	sprintf(query_string,"select n_tableno from nfmtables where n_tablename='%s'",
				cat_name);

	_pdm_debug("Get Catalog Table No query = %s", query_string );	

	max_rows =1  ;
	sts = RISquery(query_string,&max_rows,&output_string,&err_code); 

	_pdm_debug(" output: %s", output_string);

	if( sts < 0 ) {
               if(output_string)free(output_string);
                output_string = NULL; 
		RIS_box(err_code);
		return(0);
	}

	if (max_rows == 0) {
			sprintf (query_string, "Catalog '%s' does not exist in nfmtables", cat_name);
			warn_box (query_string);
			_pdm_debug ("Catalog '%s' does not exist in nfmtables", cat_name);
			return (0);
	}

	sscanf(output_string,"%d",tbl_no);


	free(output_string); output_string = NULL;


	sprintf(query_string,"select n_type from nfmcatalogs where n_catalogname='%s'",
					cat_name);

	sts = RISquery(query_string,&max_rows,&output_string,&err_code); 

	_pdm_debug(" output: %s", output_string);

	if( sts < 0 ) {
		free(output_string);
		RIS_box(err_code);
		return(0);
	}

        ptr = (char *) NULL;
	
	ptr = strtok(output_string,"~");

	if( !strcmp(ptr,"P") || !strcmp(ptr,"CID") || !strcmp (ptr, "EID") || !strcmp(ptr, "EXT") || !strcmp(ptr, "PXT"))
	{
		/* TR# 1393 05848 ??? 	*/
		strncpy(viewORtable,ptr,3);
		viewORtable[3] = '\0';
	}
	else
		viewORtable[0] = '\0' ;


	/* if (output_string) free( output_string ); */
         output_string = NULL;
        
	_pdm_debug("Exit = %d",0 );	

	return(1);
}



/*  --------------------  SearchAttribsAcrossCatalogs()  ------------------ */

SearchAttribsAcrossCatalogs()
	
	/* Having got list of catalogs prepares list of common attributes */
{

	int  i, j,sts, err_code , max_tablenos , num_attrs;
	char query[138] , *output , *where, *qry, tmp[200]  ;

        char *ptr, tstr[156];

	NumAttribs = 0 ;

	/* Get attribute list of first table */
	if( ! GetCatAttribs(TblNos[0],&AttrList,&AttrSynonym,&AttrTypes,&num_attrs))
		return(0);

        /*  MJG - check AttrSynonym for nil values */
        for (i = 0; i < num_attrs; ++i)
           if (strcmp(AttrSynonym[i], "nil") == 0)
             strcpy(AttrSynonym[i], NULL_STRING);

        /* Now check whether this attribute appears in all catalogs under current
           level
	*/

	NumAttribs = 0 ;

	strcpy(query," select DISTINCT n_tableno from nfmattributes where n_name = '");

	_pdm_debug("query: %s", query);
	/* Build where clause for n_tableno first */
        where = (char *) malloc (NumCatalogs * 20 + 100);
	strcpy(where, "and ( ");


	for( i = 0 ; i < NumCatalogs ; i = i + 1 ) {

		sprintf(tmp,"n_tableno = %d ",TblNos[i]);
		strcat(where,tmp);
		if( i < NumCatalogs -1 )
			strcat(where, " or ");
	
	}

	strcat(where," )");

	_pdm_debug( " where: %s", where );
 /*
if(IGEresetstop())
            {
        _pdm_debug("IGEreset stop for with union Attrib failed %d", 0);
             }
*/

	/* Now query whether each attribute can be found in all tables */
	for( i = 0 ; i < num_attrs ; i = i + 1 ) {

		/* TR#1393 07291 */
		ptr = NULL;
		strcpy( tstr, AttrSynonym[i] );
		ptr = strchr( AttrSynonym[i], '\'' );
		if( ptr != NULL ) /* Found a single quote */
		{
		    _pdm_debug("Found single quote in attr synonym %s",ptr);
		    tstr[strlen(AttrSynonym[i])-strlen(ptr)] = 0;
                    strcat( tstr, "'");
		    strcat( tstr, ptr );
                }

       /* sprintf(tmp,"%s' and n_synonym = '%s' ",AttrList[i],tstr); */
		sprintf(tmp,"%s' ",AttrList[i]);

		qry=(char *)malloc(strlen(query) + strlen(where) + strlen(tmp) + 1 );

		strcpy(qry,query);
		strcat(qry,tmp);
		strcat(qry,where);

		max_tablenos = 0 ;		

		_pdm_debug("Get table_no given attr_name query: %s",qry);

		sts = RISquery(qry,&max_tablenos ,&output,&err_code); 

		_pdm_debug("RISquery status: %d ", sts );
		_pdm_debug(" max_rows: %d",max_tablenos );
		
	 	free(qry);
		free(output);

		if( sts < 0 ){
			RIS_box(sts);
			return(0);
		}
		
		/* If this attribute is not found in all tables, remove it from the lsit */
                 
		if( max_tablenos != NumCatalogs ) {

			for( j = i ; j < num_attrs -1 ; j = j + 1 ){
	
				AttrList[j] = (char *)realloc(AttrList[j], strlen(AttrList[j+1])+1);
				strcpy(AttrList[j] ,AttrList[j+1] );
				AttrSynonym[j] = (char *)realloc(AttrSynonym[j], strlen(AttrSynonym[j+1])+1);
				strcpy(AttrSynonym[j],AttrSynonym[j+1]);
				AttrTypes[j] = (char *)realloc(AttrTypes[j], strlen(AttrTypes[j+1])+1);
				strcpy(AttrTypes[j], AttrTypes[j+1]  );
			}

			--i ;

			--num_attrs  ;

			_pdm_debug("num_attrs: %d", num_attrs );


			free( (char *) AttrList[num_attrs] );
			free( (char *) AttrSynonym[num_attrs]);
			free( (char *) AttrTypes[num_attrs] );
		}
                
                        if( IGEstop ())
                            {
        _pdm_debug("Stop for  Attrib enabled %d", 0);
                              IGEresetstop();
                               break;
                             }
	}
         free(where);

	NumAttribs = num_attrs ;
	return(1);
}



GetCatAttribs(int table_no, char ***list_of_attr, char ***attr_desc,
 char ***attr_type, int *no_of_attrs)
{
	int  i, max_rows , sts , err_code ;
	char query[256], *ptr, *output ;

	/* Get list of attributes of one catalog first */
	sprintf(query,"select n_name, n_synonym, n_datatype, n_seqno from nfmattributes where n_tableno = %d ", table_no );

	strcat(query," and n_read='Y' order by n_seqno ");
	
	_pdm_debug("Get attributes query = %s", query );	

	max_rows = 0 ;
	sts = RISquery(query,&max_rows, &output,&err_code);

	_pdm_debug("Get attributes query status = %d", (char *)&sts );	

	_pdm_debug("Get attributes output = %s", output );	

	if( sts < 0 ) {
		free(output);
		RIS_box(err_code);
		return(0);
	}


	(*list_of_attr) = (char **)malloc(max_rows*sizeof(char *));
	(*attr_desc)    = (char **)malloc(max_rows*sizeof(char *));
	(*attr_type)    = (char **)malloc(max_rows*sizeof(char *));

	ptr = strtok(output,"~");

	for( i = 0 ; (ptr != NULL) && (i < max_rows) ; i = i + 1 ) {

		(*list_of_attr)[i] = (char *)malloc(strlen(ptr)+1 );
		if( (*list_of_attr)[i] == NULL )
			break;

		strcpy((*list_of_attr)[i],ptr);

		ptr = strtok(NULL,"~");

		if (ptr == NULL ) {
			_pdm_debug("ptr is null ???", 0 );
			break;
		}


		(*attr_desc)[i] = (char *)malloc(strlen(ptr)+1 );
		if( (*attr_desc)[i] == NULL )
			break;
		strcpy((*attr_desc)[i],ptr);

		ptr = strtok(NULL,"~");

		if (ptr == NULL ) {
			_pdm_debug("ptr is null ???", 0 );
			break;
		}


		(*attr_type)[i] = (char *)malloc(strlen(ptr)+1 );
		if( (*attr_type)[i] == NULL )
			break;
		strcpy((*attr_type)[i],ptr);


		ptr = strtok(NULL,"~");  /* n_seqno */
		
		ptr = strtok(NULL,"~");
	}

	free(output);

	if ( i < max_rows )
	{
		_pdm_debug("Getcatattribs:Some problem in reading all rows",0);
		return( 0 );
	} 

	*no_of_attrs = i ;


	return(1);
}


GetCatalogDesc(char *catalog_name, char **catalog_desc)
{

	int  max_rows, err_code , sts;
	char query[128] , *output_string, *ptr ;

	sprintf(query,"select n_catalogdesc from nfmcatalogs where n_catalogname = '%s'",
			catalog_name );

	max_rows = 1 ;
	sts = RISquery(query, &max_rows, &output_string, &err_code);

	if( sts < 0 ) {
		free(output_string);
		RIS_box(err_code);
		return(0);
	}

	ptr = strtok(output_string,"~");

	*catalog_desc = (char *)malloc(strlen(ptr) + 1 );
	
	if(strcmp(ptr, "nil") != 0)
		strcpy(*catalog_desc,ptr);
	else
		strcpy(*catalog_desc,"");

	free(output_string);

	return(1);
}


get_macro_name(char *macname,char *catname, Form fp, int glabel, int col)

	/* see if the catalog has an attribute by name 'macro' . If yes
           read the value. Else get macro attached to the catalog from
           pdmparamloc table
	*/
{

	int i, max_rows =1, sts, err_code ;
	char query[512] , *output_str, *ptr ;

	/*	TR # 13938062.	03/aug/93 - raj.	*/
#define	GET_flag	0
#define	SET_flag	1
#define	THROUGH_PLACE_PART	0
#define	THROUGH_REPLACE_PART	1

	int	command_flag;

	SetOrGet_command_flag (&command_flag, GET_flag);
	/************************************************/

	_pdm_debug ("Enter get_macro_name ()", 0);

	macname[0] = '\0' ;

	query[0] = '\0' ;

	/* if option is search across common attributes, then attribute
	   'macro' may not be common to all catalogs. So get attributes
	   of selected catalog and then see if it has an attribute by
	   name 'macro'  -- GBTYL
	*/

	if( fp != NULL )
	{
		for( i = 0 ; i < NumAttribs ; ++i )
			if(!strcmp(AttrList[i],"p_macro"))
				break;

		if( i < NumAttribs )
		{
			/*	TR # 13938062.	03/aug/93 - raj.	*/
			if (command_flag == THROUGH_REPLACE_PART)
			{	/* Get value form the array filled earlier. */
				if (!strcmp (AttrValsRep_PPart[i], ""))
				{	/* If values is NULL, it was not on form.	*/
					/* Get it from catalog.	*/
					if( refresh -> rev_partid != NULL )
					{
						if (!BuildAQuery (command_flag, fp, glabel, query))
							return (0);

						if (PDU_ComputedID != TRUE)
						{	/* If it is a computed id, we need the same array later in InstanceMacro () (PDMselprt.c).	*/
							command_flag = THROUGH_PLACE_PART;
							SetOrGet_command_flag (&command_flag, SET_flag);
							/* Free AttrValsRep_PPart[].	*/
							{
								int	i;
								for (i = 0; i < NumAttribs; i++)
									free ((char *) AttrValsRep_PPart[i]);
								free ((char *) AttrValsRep_PPart);
							}
						}
					}
				}
				else
				{
					strcpy(macname,AttrValsRep_PPart[i]);

					if (PDU_ComputedID != TRUE)
					{	/* If it is a computed id, we need the same array later in InstanceMacro () (PDMselprt.c).	*/
						command_flag = THROUGH_PLACE_PART;
						SetOrGet_command_flag (&command_flag, SET_flag);

						/* Free AttrValsRep_PPart[].	*/
						{
							int	i;
							for (i = 0; i < NumAttribs; i++)
								free ((char *) AttrValsRep_PPart[i]);
							free ((char *) AttrValsRep_PPart);
						}
					}

					_pdm_debug ("Found macro name from array", 0);
					return(1);
				}
			}	
			else if (command_flag == THROUGH_PLACE_PART)
			{	/* Form is still alive, get value from it. */
				if( Get_text(fp,glabel,i,col)) { /* If value selected on form */
					strcpy(macname,s_text);
					_pdm_debug ("Found macro name on Form", 0);
					return(1);
				}
				else if( refresh -> rev_partid != NULL )
				{
					/* Get it from catalog.	*/

					if (!BuildAQuery (command_flag, fp, glabel, query))
						return (0);
				}
			}
			/*************************************************/

		}
	}

	_pdm_debug("query: %s", query );

	if(strlen(query) < 1 ) {	

		/* Catalog does not have attribute by name 'macro'. So get
                   macro name from pdmparamloc table known catalog name
		*/

		sprintf(query,"select p_macroname from pdmparamloc where n_catalogname='%s'",
					catname);

	}

	_pdm_debug("query: %s", query );

	sts = RISquery(query,&max_rows,&output_str,&err_code);

	if( sts < 0 ){
		free(output_str);
		RIS_box(err_code);
		return(0);
	}

	ptr = strtok(output_str,"~");

	if( ptr != NULL ){
		strcpy(macname,ptr);
		_pdm_debug("macro name : %s", macname );
	}

	free(output_str);

	/* p_macro attribute might not have a value, in which case it is "nil"	*/
	/* or "NULL". TR# 139418986. Second set of debugs show that macro name	*/
	/* is coming in as "NULL". 17/may/94 - raj.				*/
/*	if (!strcmp(macname, "nil"))	*/
	if (!strcmp(macname, "nil") || !strcmp(macname, "NULL"))
	{
	  /* Catalog does not have attribute by name 'macro'. So get
	  macro name from pdmparamloc table known catalog name. */
	  
	  sprintf(query,"select p_macroname from pdmparamloc where n_catalogname='%s'",
	  		catname);
	  _pdm_debug("query: %s", query );
	  
	  sts = RISquery(query,&max_rows,&output_str,&err_code);
	  
	  if( sts < 0 )
	  {
	    free(output_str);
	    RIS_box(err_code);
	    return(0);
	  }
	  
	  ptr = strtok(output_str,"~");
	  
	  if( ptr != NULL )
	  {
	    strcpy(macname,ptr);
	    _pdm_debug("macro name : %s", macname );
	  }
	  
	  free(output_str);
        }

	if( strlen(macname) > 0 )
		return(1);

	return(0);
}
	
	
GetMacroName (	Form fp, int glabel, int attr_col, int val_col, 
		char *cat_name, char *mac_name)
{
	int 	sts, err_code,
		j = 0, max_rows =1;
	char 	query[512] , *output_str, *ptr ;

	mac_name[0] = '\0' ;
	query[0] = '\0' ;

	while (1){
		if (!Get_text (fp, glabel, j, attr_col)){
			if (!strcmp (s_text, "p_macro")){
				Get_text (fp, glabel, j, val_col);
				strcpy (mac_name, s_text);
				return (1);
			}
		}
		else
			break;

		j++;
	}

	/* Catalog does not have attribute by name 'macro'. So get	*/
        /* macro name from pdmparamloc table known catalog name		*/
	sprintf(query,"select p_macroname from pdmparamloc where n_catalogname='%s'",
					cat_name);
	sts = RISquery(query,&max_rows,&output_str,&err_code);

	if( sts < 0 ){
		free(output_str);
		RIS_box(err_code);
		return(0);
	}

	ptr = strtok(output_str,"~");
	if( ptr != NULL )
		strcpy(mac_name,ptr);

	free(output_str);

	if( strlen(mac_name) > 0 )
		return(1);

	return(0);
}

/*	TR # 139308062.		03/aug/93 - raj.			*/
/*	Function to set the flag 'Rep_PPart_Flag' to indicate whether	*/
/*	place part is invoked directly ot through replace part.		*/

SetOrGet_command_flag (int *place_or_replace, int action)
{

#define	GET_flag	0
#define	SET_flag	1
#define	THROUGH_PLACE_PART	0
#define	THROUGH_REPLACE_PART	1

	static	int	command_flag = THROUGH_PLACE_PART;

	if (action == GET_flag)
		*place_or_replace = command_flag;
	if (action == SET_flag)
		command_flag = *place_or_replace;

	return (1);
}

BuildAQuery (int command_flag, Form fp, int glabel, char *query)
{
	_pdm_debug ("Enter BuildAQuery", 0);

	if (!strcmp (refresh->rev_partid, "computable"))
	{
		char	*clause;
		if (!UseAttrListInQuery (command_flag, fp, glabel, &clause))
			return (0);
		sprintf(query,"select p_macro from %s where %s ",
				refresh -> rev_catalog, clause);
	}
	else
	{	
		sprintf(query,"select p_macro from %s where n_itemname = '%s' and n_itemrev='%s'",
			refresh -> rev_catalog,refresh -> rev_partid, refresh -> rev_revision);
	}

	_pdm_debug ("Exit BuildAQuery", 0);

	return (1);
}

UseAttrListInQuery (int command_flag, Form fp, int glabel, char **clause)
{
	/* If PDUcomputedID == TRUE, n_itemname has vlaue 'computable'.	*/
	/* Since we can not use n_itemname in the query, use all the 	*/
	/* other attributes.						*/

	int	i, ind;
	char	tmpstr[100], val_str[132];
	char	*to_lower();

	_pdm_debug ("Enter UseAttrListInQuery ()", 0);

	if (((*clause) = (char *) malloc (3 * sizeof (char))) == NULL)
	{
		_pdm_debug ("UseAttrListInQuery () : Unable To Allocate Memory", 0);
		return (0);
	}

	(*clause)[0] = '\0';

	for (i = 0; i < NumAttribs; i++)
	{
		if (!strcmp (AttrList[i], "n_itemname"))
			continue;
		strcpy (tmpstr, AttrList[i]);
		ind = GetAttribindx(to_lower(tmpstr));
		if (ind != -1)
		{
			if (command_flag == THROUGH_REPLACE_PART)
			{
				if (!strcmp (AttrValsRep_PPart[i], ""))
					continue;
				if (strlen (AttrValsRep_PPart[i]) >= 132)
				{
					_pdm_debug ("String too long", 0);
					return (0);
				}
				strcpy (val_str, AttrValsRep_PPart[i]);
			}

			if (command_flag == THROUGH_PLACE_PART)
			{
				if (!Get_text(fp,glabel,ind,1) )
					continue;
				if (strlen (s_text) >= 132)
				{
					_pdm_debug ("String too long", 0);
					return (0);
				}
				strcpy (val_str, s_text);
			}

		
			(*clause) = (char *) realloc 
						((*clause),
						(strlen ((*clause))
						+ strlen (AttrList[i])
						+ strlen (" = ")
						+ strlen (val_str)
						+ strlen (" and ")
						+ 16
						) * sizeof (char)
						);

			if ((*clause) == NULL)
			{
				_pdm_debug ("UseAttrListInQuery () : Unable To Allocate Memory", 0);
				return (0);
			}

			if (i > 0)
				strcat ((*clause), " and ");

			strcat ((*clause), AttrList[i]);
			strcat ((*clause), " = ");

			if( !strncmp(AttrTypes[i],"char",4) ||
  				!strcmp(AttrTypes[i],"Expression text"))
			{
				strcat((*clause),"'");
				strcat((*clause), val_str);
				strcat((*clause),"'");
			}
			else
				strcat((*clause), val_str);
		}
	}

	_pdm_debug ("Exit UseAttrListInQuery ()", 0);

	return (1);
}


search_list_attribs(Form fp , MEMptr out_buffr)
{
	int i;
	char **catlist;

        _pdm_debug("in the function search_list_attribs", 0);

	PDUmessage (PDS_M_GET_LIST_ATTR, 's');

	catlist = (char **)malloc(MAX_CATALOGS * sizeof(char *));

	for( i = 0 ; i < MAX_CATALOGS ; ++i )
		catlist[i] = (char *)malloc(TBL_LEN);
	
	if( ! PALgetcatlist (fp, out_buffr, &NumCatalogs, catlist,1 ))
	{
		PDUmessage(PDM_E_CLEAR_FIELD, 's' );
		return(0);
	}

	for( i = 0 ; i < NumCatalogs ; ++i )
		strcpy(CatNameList[i], catlist[i]);

	FreeArrayPtr(catlist,MAX_CATALOGS);

	if( NumAttribs != 0 ){
		FreeArrayPtr(AttrList,NumAttribs);
		FreeArrayPtr(AttrSynonym,NumAttribs);
		FreeArrayPtr(AttrTypes,NumAttribs);
		NumAttribs = 0;
	}

	/* Having gotten table nos, get the attributes common to them */
	if( ! SearchAttribsAcrossCatalogs() ){

		NumCatalogs = 0 ;
		FreeArrayPtr (AttrList,NumAttribs );
		PDUmessage(PDM_E_CLEAR_FIELD, 's' );	
		return(0);
	}
	PDUmessage(PDM_E_CLEAR_FIELD, 's' );
	return(1);
}
