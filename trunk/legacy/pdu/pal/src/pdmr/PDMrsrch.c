/*#include <stdio.h>
#include <malloc.h>
#include <string.h>
#include <MEMstruct.h>
#include <MEMerrordef.h>
#include <SQLerrordef.h>
#include <PDUstr.h>
#include "FIproto_pub.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "PALglbs.h"
#include "PDUfile_def.h"
*/

#include "PALpdmr.h"
#include "PALpdmrpro.h"
#include "PDUerror.h"

#define	PARAMETERS     22
#define SUB_TABLE      21	

/*------------------------------------------------------------------ */
/*  Globale variables */
extern char **AttrList ;	   /* common attribute list    */
extern char **AttrSynonym ;        /* synonyms of attributes   */
extern char **AttrTypes   ;        /* attribute types          */
extern int  NumAttribs    ;	   /* No. of common attributes */


extern char CatNameList[MAX_CATALOGS][TBL_LEN] ;        /* List of catalog names */
extern int  NumCatalogs, TblNos[MAX_CATALOGS];          /* no. of catalogs and corresponding 
                                                           table numbers 
                                                	*/
extern char *s_text  ;
extern int SQLCODE;
extern int  max_rows_rtvd ;
extern int   PDMdebug_on ;
extern char *PDU_part_sort_string ;
extern int  PDU_cat_selected     ;
extern int  PDU_ComputedID     ;
extern int  display_all ,row_num ;
extern short  PALis_sort_selected  ;
extern char   *PDU_srch_catalog;
extern struct PDUrefresh *refresh ;
/*------------------------------------------------------------------ */

static char ShortList[MAX_CATALOGS][TBL_LEN] ;   /* List of catalog names,  short listed */
static int  ShortListLen;			 /* no. of catalogs, short listed */
static int  *SlctdAttrList=NULL;			 /* List of selected attributes */
static int  SlctdAttrNum=0;		 /* Num of selected attributes */
static char *complete_list=NULL;

/* code for computed ID 
extern int PDU_computedID ;
*/

CleanUpSlctdAttribs ()
{
	if( SlctdAttrNum ) {
		MyFree (SlctdAttrList);
		SlctdAttrNum = 0;

		MyFree(complete_list );
	}

}

RebuildShortList (Form fp, int mcf )
{
	char	*pre_query, *query, *where, *output_str;
	int	i = 0, len = 0, max_rows, error_code, sts ;

	/* Check if all selected values still exist on the form 	      */
	/* i.e., user didn't erase any of the previously selected values      */

	
	_pdm_debug("Enter: RebuildShortList()\n",0);
	_pdm_debug("RebuildShortList() - NumCatalogs %d\n",NumCatalogs);
	_pdm_debug("SlctAttrNum %d", SlctdAttrNum);

 	for (i = 0; i < SlctdAttrNum; i++){
		if(!Get_text(fp, mcf, SlctdAttrList[i], DATA_COL)){
			/* Previously selected value is erased */
			break;
		}
	}
    
  if (i == SlctdAttrNum && i != 1) /* None of the values are erased 	*/
         {
_pdm_debug("Exit 1 - RebuildShortList() - NumCatalogs %d\n",NumCatalogs);
		return (1);	/* Use the present short list as it is */
          }

	/* Recreate ShortList */
	ShortListLen = 0;

	len = 	8 + 7 +			/* Select ... from 	*/
		20 * NumAttribs + 	/* Attributes 		*/
		(3 * NumAttribs - 1);	/* Commas 		*/
		
	pre_query  = (char *) malloc (len * (sizeof (char)));

	len = 0;
	strcpy (pre_query, "Select ");
      /*
 	for (i = 0; i < SlctdAttrNum; i++){

		if(!Get_text(fp, mcf, SlctdAttrList[i], DATA_COL)){
			 Selected value is erased 
			continue;
		}
		 Selected value exists, use it in query 
		if (len > 0)
			strcat (pre_query, ", ");
		strcat (pre_query, AttrList[SlctdAttrList[i]]);
		len++;
	}
        */
		strcat (pre_query, AttrList[SlctdAttrList[SlctdAttrNum]]);

	if( ! len ){                         /* All selected values deleted */
		ShortListLen = NumCatalogs;
		for( i = 0 ; i < NumCatalogs ; ++i )
			strcpy(ShortList[i],CatNameList[i]);
_pdm_debug("Exit 2 - RebuildShortList() - NumCatalogs %d\n",NumCatalogs);
	        _pdm_debug("Exit - in RebuildShortList()\n",0);
		return(1);
	}
		
	strcat (pre_query, " from ");

	_pdm_debug("pre_query: %s", pre_query );

	/* Build where clause */

	where = (char *) malloc ( 50 );

	len = 0;
	strcpy (where, " Where ");
 	for (i = 0; i < SlctdAttrNum; i++){
		if(!Get_text(fp, mcf, SlctdAttrList[i], DATA_COL)){
			/* Selected value is erased */
			continue;
		}
		/* Selected value exists, use it in query */
		if (len > 0)
			strcat (where, " and ");
		strcat (where, AttrList[SlctdAttrList[i]]);
		where = (char *) realloc (where, strlen (where) + strlen (s_text) + 50 );
/** Added for TR#139307305 */
		if( !strcmp( s_text, "NULL" ) )
			strcat( where," is NULL ");
		else
		{
			strcat (where, " = ");
			if( !strncmp (AttrTypes[SlctdAttrList[i]],"char",4)) {
				query = (char *) malloc(strlen(s_text) + 4 );
				strcpy(query,s_text);
				add_quotes(query);
				strcat (where, query);
				free( query);
			}
			else if(!strncmp (AttrTypes[SlctdAttrList[i]],"timestamp",9)) {
				pdutimestamp_to_ascii(s_text);
				query= (char *)malloc( strlen(s_text) + 15 );
				sprintf(query," TIMESTAMP '%s'",s_text);
				strcat(where,query);
				free(query);
			}
			else
				strcat(where,s_text);
		}

		len++ ;
	}

	_pdm_debug("where: %s", where );



	_pdm_debug("pre_query: %s", pre_query );

	len = 	strlen (pre_query) + 1 + strlen (where) + 1 +
		20 + 1;	/* table name */

	query = (char *) malloc (len * sizeof (char));

	for (i = 0; i < NumCatalogs; i++){
                memset(query, NULL, len);
		strcpy (query, pre_query);
		strcat (query, CatNameList[i]);
		strcat (query, where);

		_pdm_debug(" query: %s", query );

		/* Send RIS query */
		max_rows = 1;
		sts = RISquery (query, &max_rows, &output_str, &error_code);

		/*MyFree(query);*/
		MyFree (output_str);
		if (sts < 0){
			fprintf (stderr, "Error In RIS Operation - %d\n", error_code);
             _pdm_debug("Exit - RebuildShortList() with RIS error \n",0);
			goto cleanup;
		}
		if (max_rows > 0)	/* Add table to short list */
			strcpy (ShortList[ShortListLen++], CatNameList[i]);
	}

	_pdm_debug("Exit - RebuildShortList()\n",0);
cleanup:
	if(query) free(query);
	if(pre_query) free(pre_query);
	if(where) free(where);
_pdm_debug("Exit 3 - RebuildShortList() - NumCatalogs %d\n",NumCatalogs);
	return(1);
}

UpdateShortList (Form fp, int glabel, int row, int sel_flg)
{
	char	*selected, **values_list, *ptr1 , *ptr ;
	int	listlen , i=0, remove_table,j ;

	_pdm_debug("Enter: UpdateShortList()\n",0);
	_pdm_debug("ShortListlen %d\n",ShortListLen);
	if( !Get_text(fp, glabel, row, DATA_COL))
		return(0) ;

	if (!sel_flg)
		return(0);

	if(ShortListLen == 1 ){       /* Nothing to short list further */
		if(complete_list) free(complete_list); complete_list = NULL;
		return(1);
	}

	SlctdAttrList[SlctdAttrNum++] = row;
				
	selected = (char *) malloc (strlen (s_text) + 1);
	strcpy (selected, s_text);

	listlen  = ShortListLen;
	values_list = (char **) malloc ( (listlen) * sizeof (char *));
	ptr1 = strtok (complete_list, "\1");

		_pdm_debug("complete_list: %s", complete_list);
/* TR# 139422534. value_list to contain exactly as many as ShortListLen */
/*	while (ptr1 != NULL){ */
	while (ptr1 != NULL && i < ShortListLen){
		values_list[i] = (char *) malloc ((strlen (ptr1) + 1) * sizeof (char));
		strcpy(values_list[i],ptr1);
                 i++;
		ptr1 = strtok (NULL, "\1");

		_pdm_debug("value_list: %s", values_list[i-1]);
	}

	for (i = 0; i < listlen; i++){
		remove_table = TRUE;
                if(strcmp(values_list[i],"~"))
                 {
		ptr = strtok (values_list[i], "~");
		while (ptr != NULL){
			_pdm_debug("ptr: %s", ptr );

			if (!strcmp (selected, ptr)){
				remove_table = FALSE;
				break;
			}
			ptr = strtok (NULL, "~");
		    }
                 }
		if (remove_table){
			for (j = i ; j < ShortListLen - 1; j++){
				strcpy (ShortList[j], ShortList[j+1]);
			}
			ShortListLen--;
		}
	}

	MyFree (selected);
	/*FreeArrayPtr (values_list, listlen);*/
        /*
	for(i=0;i<listlen;i++)
		free((char *)values_list[i]);
	MyFree(values_list); */

	/* MyFree (complete_list);  */
	_pdm_debug("Exit: UpdateShortList()\n",0);
	return(1);
}


ParamSearchOnMultipleCtlgs(Form fp, int mcf, int row, int col)
{
	int	i, total_ent = 0;
	char	*output_str = NULL ;

	_pdm_debug("Entered ParamSearchOnMultipleCtlgs",0);
        complete_list = NULL;
	complete_list = (char *) malloc (2 * sizeof (char));
	complete_list[0] = '\0';

	_pdm_debug("SlctAttrNum %d", SlctdAttrNum);
	if( SlctdAttrNum )
               {
	        SlctdAttrList[SlctdAttrNum] = row;
		 RebuildShortList (fp,mcf);
               }

	_pdm_debug("SlctAttrNum %d", SlctdAttrNum);
	if (SlctdAttrNum == 0){
		/* No values selected yet, CatNameList == ShortList */
		SlctdAttrList = (int *) malloc (NumAttribs * sizeof (int));
		for (i = 0; i < NumCatalogs; i++)
			strcpy (ShortList[i], CatNameList[i]);
		ShortListLen = NumCatalogs;
	}

	_pdm_debug("ShortListLen %d",ShortListLen);
         total_ent = 0;
	for (i = 0; i < ShortListLen; i++){
		if (!do_search (fp, mcf, ShortList[i], row, col, &output_str,
		AttrList, AttrSynonym, AttrTypes, NumAttribs, &total_ent)){
                       if(complete_list) 
                  {
			complete_list = (char *) realloc (complete_list, (strlen (complete_list) + strlen ("NIL~") + 150) * sizeof (char));
		     output_str = NULL;
		strcat (complete_list, "~\1");
                  continue;
                   }
                        else
                        {
                        RIS_box(-3);
		 	return (0);
                        }
		}

		_pdm_debug("out_str: %s", output_str );

		if (output_str == NULL || !strcmp (output_str, "")){
			complete_list = (char *) realloc (complete_list, (strlen (complete_list) + strlen ("NIL~") + 150) * sizeof (char));
			strcat (complete_list, "nil~");
                        if(output_str) free(output_str);
                        output_str = NULL;
		}
		else {
			complete_list = (char *) realloc (complete_list, (strlen (complete_list) + strlen (output_str) + 150) * sizeof (char));
			strcat (complete_list, output_str);
		        MyFree( output_str );
		}

		strcat (complete_list, "\1");

		_pdm_debug("complete_list : %s", complete_list );

	}
	strcat (complete_list, "~");	
	_pdm_debug("Exited ParamSearchOnMultipleCtlgs",0);
	return(1);
}

do_search(Form fp, int mcf, char  *table_name, int row, int col,
	  char **output_str,
	  char **AttrList, char **AttrSynonym, char **AttrTypes,
	  int  NumAttribs,
          int  *total_ent)
{

	int sts, max_rows = 0, err_code , rows_to_retrv = 0, tbl_no;
	char l_table_name[21], *query_string = NULL, *outstr = NULL,*ch_val = NULL, ordering_type[8];
        char viewORtable[5];

	_pdm_debug("Entered do_search",0);
	ordering_type[0] = '\0';

	/* make search of a field given */
    
	if( NumAttribs == 0 ) 
             return(0) ;

	/* code for computed ID */
	/* if catalog type is CID avoid search on n_itemname */
/*	if( PDU_computedID && !strcmp(AttrList[row],"n_itemname") ){

		FIfld_set_text(fp,FI_MSG_FIELD,0,0,"Computable ID",0);
		return(0);
	}
*/

	if(!strcmp(AttrList[row],"p_altpartno") ){
      if(! GetCatTableNo(table_name, &tbl_no, viewORtable)) {
          _pdm_debug("Error getting table no. of catalog",0);
                        return(0);
                }
          _pdm_debug("catalog type %s", viewORtable);
             if(strcmp(viewORtable,"EID") && strcmp(viewORtable,"EXT") && strcmp(viewORtable,"PXT"))
              {
          _pdm_debug("Not a external. of catalog %s", table_name);
               return(1);
              }
	}
       /* changed by kumar for KK 061693 */
	max_rows = 0;

	query_string = (char *) malloc(1024);

	strcpy(query_string, "select DISTINCT ");
	strcat(query_string,AttrList[row]);

	strcat(query_string," from ");
        PDMconvert_to_lower (table_name, l_table_name);
	strcat(query_string,l_table_name ); 

	strcpy (ordering_type, " ASC");

	_pdm_debug("Before where condition query: %s", query_string);

	/* TR# 139420793. 08/Dec/94 - raj. Catch the ret code. */
	/*
	where_condition_line(	fp,mcf,&query_string,row, ordering_type, 
	*/
	sts = where_condition_line(	fp,mcf,&query_string,row, ordering_type, 
				&rows_to_retrv,	AttrList, AttrSynonym, 
				AttrTypes,NumAttribs);
	/* TR# 139420793. 08/Dec/94 - raj. */
	if (sts == -1)
	  return(sts);

	strcat(query_string, " order by  ");
	strcat(query_string, AttrList[row]);
	strcat(query_string, ordering_type);

	_pdm_debug("query in do_search(): %s", query_string);


	_pdm_debug("query string : %s", query_string );


	if( rows_to_retrv == 1 ) max_rows = 1 ;

	sts = RISquery(query_string,&max_rows, output_str,&err_code);

	free(query_string) ; query_string = NULL;

	_pdm_debug("query output: %s",  *output_str );

	if( sts < 0 ) {
        	add_to_puldwn_list(fp, "nil~",0);
                if(sts ==  -4) 
                    {
	        if(*output_str) free(*output_str); *output_str = NULL;
        	return(-4);
                    }
	        if(*output_str) free(*output_str); *output_str = NULL;
        	return(0);
	}


                _pdm_debug("max_rows %d", max_rows);
                *total_ent = *total_ent + max_rows;
	if( col != -77 && max_rows > 0  ) {
/* TR# 139422534. 20/Jul/95 - raj. Using local var instead of outstr. */
/*		outstr = (char *)malloc( strlen(*output_str) + 1); */
		char *loutstr = (char *)malloc( strlen(*output_str) + 1);
		strcpy(loutstr, (*output_str));
                _pdm_debug("Add to puldwnlist", 0);
        	add_to_puldwn_list(fp, loutstr,max_rows);
                _pdm_debug("After to Add to puldwnlist", 0);
                _pdm_debug("total_ent %d", *total_ent);
		/* if( outstr) free( outstr ); outstr = NULL; */
/* TR# 139422534.  20/Jul/95 - raj. Don't know why freeing of outstr was
   commented out above. Using local var and freeing it. */
		if( loutstr) free( loutstr ); loutstr = NULL;
	}
	else {
                if(*output_str && strcmp(*output_str,""))
                 {
        	ch_val = strtok(*output_str,"~");
		if( ch_val != NULL )
                	FIfld_set_text(fp, mcf,row,1,ch_val,1);
                 }
/* 2/25/94 MJG - Why are we doing this.  It makes all subsequent searches
   fail.  TR 139417579.
                else if(*total_ent == 0)
                  {
              	FIfld_set_text(fp, mcf,row,1,"NULL",1); 
                 PDUmessage(PDM_E_ATTR_LIST_EMPTY ,'s'); 
                  }
*/
	}
	_pdm_debug("Exited do_search",0);
	return(1);
}

where_condition_line(	Form fp,int mcf, char **query_string, int row, 
			char *ordering_type, int *rows_to_retrv,
			char **AttrList, char **AttrSynonym, char **AttrTypes,
			int  NumAttribs)
{   
	/* This function looking at each search field column, frames 
	the 'where' condition line for SQL before SEARCH is executed 
	*/

	char 	*cond_line  = NULL, *lptr  = NULL ;
	char 	*condition  = NULL;
	int 	j = 0,  r, len = 0;

	char *tmp = NULL;

	/* TR# 139420793. 08/Dec/94 - raj. */
	int	ret = 0;

	j = 0 ;

	*rows_to_retrv = 0 ;

	cond_line = (char *)malloc(strlen( " where ") + 1 );
	MemCheck( cond_line );
	strcpy(cond_line ," where ");

	for( r = 0 ; r < NumAttribs ; r = r + 1  ){
               /* Do not add the row on which the parameter search is to
                  done
               
               if( r == row )
                       continue;
		*/
        	/* If value exists in DATA_COL donot use condition */

		if( Get_text(fp,mcf,r,DATA_COL ) ){

			_pdm_debug("value in data col: %s", s_text);

/* Added on 04/20/93 - TR#139305245 */
			if( PDU_ComputedID  && (!strcmp(AttrList[r],"n_itemname") ||
						!strcmp(AttrList[r],"n_itemdesc")))
			{
				tmp = s_text;
				while ( *tmp ) if ( *tmp++ == '$' ) break;

				if ( *tmp != '\0' ) /* Formula present */
				{
					_pdm_debug("excluding formula from the query",0);
					continue;
				}
			}
/* End */
			condition = (char *)malloc ( strlen(s_text) + 20 );

			strcpy(condition,s_text);
/* 2/10/94 - added for search across catalogs union and format */

                        if( !strcmp( condition, "~" ) )
                                        continue;


			_pdm_debug( "condition: %s", condition );

			j = j + 1  ;

			len = strlen(condition) + 30 ;

			len = len + strlen(cond_line) 
				+ strlen( " and ") 
				+ strlen(AttrList[r]);

			cond_line = (char *) realloc (cond_line, len);
			MemCheck ( cond_line );

			if( j > 1 )
				strcat(cond_line, " and " );

			strcat(cond_line,AttrList[r]);

			/* When a column has NULL value in the table, 'NULL' is placed against */
			/* it on the form. Can't use it straight away in the query. 	   */
			/* Use 'is NULL' instead 						   */

			if (!strcmp (condition, "NULL"))	
				strcat(cond_line, " is NULL " );
			else {
				strcat(cond_line, " = " );

				_pdm_debug("cond_line 2: %s", cond_line );

				if( !strncmp(AttrTypes[r],"char",4)
				|| !strcmp(AttrTypes[r],"Expression text") ) 
					add_quotes(condition);
				else if(!strncmp(AttrTypes[r],"timestamp",9) ) {
					pdutimestamp_to_ascii(condition);
					lptr= (char *)malloc( strlen(condition) + 15 );

					sprintf(lptr," TIMESTAMP '%s'",condition);
					strcpy(condition,lptr);
					free(lptr);
				}

				strcat(cond_line,condition);
			}
			free( condition ); condition = NULL;
		}

		else {    /* No value inputted in column DATA_COL. So use condition if any exists in column SEARCH_COL */

			/* TR# 139420793. 08/Dec/94 - raj. Catch the ret code. */
			/*
			if (CnvtOperNCriteriaToCondition (fp, mcf, r, row, rows_to_retrv, &condition, ordering_type,
			*/
			ret = CnvtOperNCriteriaToCondition (fp, mcf, r, row, rows_to_retrv,
						&condition, ordering_type, AttrTypes,NumAttribs);
			if (ret == 0)
			  continue;
			else if (ret == -1)
			  return (ret);
			else if (ret){
				cond_line = (char *)realloc(cond_line, strlen(cond_line) + strlen( " and ")+
						    strlen(AttrList[r]) + strlen(condition) + 1);


				_pdm_debug("condition: %s",condition);

				j = j + 1  ;
				if( j > 1 )strcat(cond_line," and " );
				strcat(cond_line,AttrList[r]);
				strcat(cond_line,condition);
			if(condition) free (condition); condition = NULL;
			}
		}
	}   

	if( j != 0 ){
		*query_string = (char *)realloc((*query_string),
				 strlen((*query_string))+strlen(cond_line)+124);

		strcat(*query_string,cond_line);

		_pdm_debug("query in where: %s", *query_string);
	}

	if(cond_line) free( cond_line);
	return(1);
}

extern MEMptr PDUsearch_part_list ;

search_on_multiple_ctlgs(Form fp1, int mcf,Form fp2,int cat_field)
{

	int  i=0 ;
	MEMptr  lcl_bufr=NULL  ;
        int  status = 1;

	if( Get_text(fp1,cat_field,0,0)){

		NumCatalogs = 1 ;
		strcpy(CatNameList[0],s_text);
	}

        PDUmessage(PDS_M_SEARCH_ACROSS_CATS, 's');
if(IGEresetstop())
            {
        _pdm_debug("IGEreset stop for with union Attrib failed %d", 0);
             }
	max_rows_rtvd = 0 ;

	/* free PDUsearch_part_list buffer if not null */
	if( PDUsearch_part_list ){
		MEMclose(&PDUsearch_part_list);
		PDUsearch_part_list = NULL ;
	}

	FIf_reset (fp2);
        FIg_reset (fp2,PARAMETERS);
        FIg_reset (fp2,SUB_TABLE);

        if (PDU_srch_catalog)
          {
          free(PDU_srch_catalog);
          PDU_srch_catalog = NULL;
          }
         PDU_srch_catalog = (char *) malloc (21);
         PDU_srch_catalog[0] = '\0';

	for( i = 0 ; i < NumCatalogs ; ++i ) {

		_pdm_debug("select_mul_cat: cat name: %s", CatNameList[i]);
          if (PDU_srch_catalog)
          {
          free(PDU_srch_catalog);
          PDU_srch_catalog = NULL;
          }
         PDU_srch_catalog = (char *) malloc (21);
         PDU_srch_catalog[0] = '\0';
          strcpy(PDU_srch_catalog, CatNameList[i]);
          PDUmessage(PDM_I_SEARCHING_CATALOG, 's');

		lcl_bufr = NULL ;

		if( do_global_search(fp1,mcf,fp2,CatNameList[i],&lcl_bufr,
				AttrList, AttrSynonym, AttrTypes, NumAttribs)) {


		        _pdm_debug("do_global_search complete", 0 );
                        if( lcl_bufr && lcl_bufr->rows != 0)
                          {
                          if (PDU_srch_catalog)
                            {
                            free(PDU_srch_catalog);
                            PDU_srch_catalog = NULL;
                            }
                           PDU_srch_catalog = (char *) malloc (21);
                           PDU_srch_catalog[0] = '\0';
                        sprintf(PDU_srch_catalog, "%d", lcl_bufr->rows);
                        PDUmessage(PDM_I_NUM_ROWS_IN_CATALOG,'s');
                          }

			add_bufr_to_global_buffer( CatNameList[i],lcl_bufr );

			MEMclose(&lcl_bufr);
                       
                        if( IGEstop ())
                            {
        _pdm_debug("IGEstop for with union Attrib enabled %d", 0);
                              IGEresetstop();
               PDUmessage(PDM_E_CLEAR_FIELD, 's' );
	if( NumCatalogs == 1 )
                set_sub_form_params (fp2, PARAMETERS,AttrSynonym,AttrList,NumAttribs,0);   

	else
		set_sub_form_params (fp2, PARAMETERS,AttrSynonym,AttrList,NumAttribs,1);   
	
	if( max_rows_rtvd > 0 )
		FImcf_set_select(fp2, SUB_TABLE, (max_rows_rtvd - 1), 1);

	get_row_from_mcf (max_rows_rtvd, NumAttribs , fp2, 21);
                           if (PDU_srch_catalog) {
                           free(PDU_srch_catalog); PDU_srch_catalog = NULL; }
                              return(1);
                            }
		}
		else{
			display_all = 0 ;
                         if (PDU_srch_catalog) {
                         free(PDU_srch_catalog); PDU_srch_catalog = NULL; }
			return(0);
		}
	}			

              PDUmessage(PDM_E_CLEAR_FIELD, 's' );
	if( NumCatalogs == 1 )
		set_sub_form_params (fp2, PARAMETERS,AttrSynonym,AttrList,NumAttribs,0);   

	else
		set_sub_form_params (fp2, PARAMETERS,AttrSynonym,AttrList,NumAttribs,1);   
	
	if( max_rows_rtvd > 0 )
		FImcf_set_select(fp2, SUB_TABLE, (max_rows_rtvd - 1), 1);

	get_row_from_mcf (max_rows_rtvd, NumAttribs , fp2, 21);

        if (PDU_srch_catalog) {
        free(PDU_srch_catalog); PDU_srch_catalog = NULL; }

        /* display status message */
        if (!PDUsearch_part_list)
          {
          status =  PDM_E_NO_PARTS_FOUND;
          PDUmessage(status, 's');
          return(status);
          }
        else if (PDUsearch_part_list &&
                (PDUsearch_part_list->rows == 0))
          {
          status =  PDM_E_NO_PARTS_FOUND;
          PDUmessage(status, 's');
          return(status);
          }
        else
          PDUmessage(PDM_S_SUCCESS, 's');

	return(1);
}


do_global_search(	Form fp1, int mcf, Form fp2,char *table_name, 
			MEMptr *data_bufr,
			char **AttrList, char **AttrSynonym, char **AttrTypes,
			int  NumAttribs)
	
	/* Fetch parts with given criteria. Both for view and table */
{

	long sts  ;
	int max_rows , row_pos, alloc_size = 1024 ,col, tmpsts;
	char *query_string ;
    

	row_pos = 0;

	if( NumAttribs == 0 ) 
             return(0) ;


	query_string = malloc(1024);

	strcpy(query_string, "select ");

	for( col = 0 ; col < NumAttribs ; col = col + 1 ) {

		/* code for computed ID 
		if( PDU_computedID && !strcmp(AttrList[col],"n_itemname") )
			continue ;
		*/

		if( (strlen(query_string) + 30) > alloc_size ) {
			query_string = realloc(query_string,strlen(query_string) + 1024 ) ;
			alloc_size += 1024 ;
		}

		if( col < NumAttribs - 1 ) {
			strcat(query_string, AttrList[col]) ;
			strcat(query_string,",") ;
		}
        	else
			strcat(query_string, AttrList[col]);

	}

	strcat(query_string," from ");
	strcat(query_string,table_name ); 
	strcat(query_string," ");

	_pdm_debug("global_serach() query string: %s",query_string);

/* gen_condition_line will return 0 if the operator is #>< and if no value is found 
   closest to the given criteria
*/
/* changed on 06/01/1993 to fail search, if date format is wrong */
	tmpsts = gen_condition_line(fp1, mcf, &query_string, table_name,
			AttrList, AttrSynonym, AttrTypes, NumAttribs );

	if( !tmpsts )
		return(1); 
	else if( tmpsts == -1 )
	{
		if (PDU_cat_selected )display_all = 0 ;
		max_rows_rtvd = 0 ;
		MyFree(query_string);
		return(0);
	}

       /* changed by kumar for KK 061693 */
    	max_rows = 0;

	_pdm_debug("query: %s", query_string);

	*data_bufr = NULL ;

	/* Add order by clause here */

	if( PALis_sort_selected && (PDU_part_sort_string != NULL) ) {

		_pdm_debug("sort string: %s", PDU_part_sort_string);

		query_string = (char *)realloc(query_string,strlen(query_string)+
							strlen(PDU_part_sort_string ) + 10 );

		strcat(query_string,PDU_part_sort_string);
	}
        else
         {
	query_string = (char *)realloc(query_string,strlen(query_string)+
		strlen("order by n_itemname, n_itemrev" ) + 10 );

		strcat(query_string," order by n_itemname, n_itemrev ");
         } 		
	_pdm_debug("query: %s", query_string);
	sts = PDMSQLquery(query_string,data_bufr,512);

	free(query_string);

	if( sts == SQL_I_NO_ROWS_FOUND){
          PDUmessage(PDM_E_NO_PARTS_FOUND, 's');
       
		if( *data_bufr )
			MEMclose(data_bufr);
		return(1);
	}

	if( sts != SQL_S_SUCCESS ){
		MEMclose(data_bufr);
          PDUmessage(PDM_E_NO_PARTS_FOUND, 's');
		if (PDU_cat_selected )display_all = 0 ;
		max_rows_rtvd = 0 ;
		return(0);
	}


	/* set global var here to be used in form_notification() */

	MEMbuild_array(*data_bufr);

	if ( PDMdebug_on )
		MEMprint_buffers( "search list buffer..", (*data_bufr), PDU_DEBUG_FILE );

	_pdm_debug("query status: %d",sts);

	_pdm_debug("no. of rows retrieved: %d", (*data_bufr) -> rows );

	row_num = max_rows_rtvd ;	

	max_rows_rtvd  += (*data_bufr) -> rows ;

	set_table_field (fp2, table_name,SUB_TABLE, row_num,*data_bufr);

        PDUmessage(PDM_S_SUCCESS, 's');

	return(1);
}



gen_condition_line(	Form fp, int mcf, char **query_string, char *table_name,
			char **AttrList, char **AttrSynonym, char **AttrTypes,
			int  NumAttribs)

	/* This function looking at each search field column, frames 	*/
	/* the 'where' condition line for SQL before SEARCH is executed */
{   

	char *cond_line, *lptr   , ordering_type[10] ;
	char *condition , *condition1, operator_str[15] ;
	int  j = 0, r , alloc_size = 1024, len, total_ent = 0  ;

	char *tmp;

	/* TR# 139420793. 08/Dec/94 - raj.	*/
	int	ret = 0;

	_pdm_debug("query_string: %s", *query_string);
	_pdm_debug("NumAttribs : %d", (char *) NumAttribs);

	cond_line = (char *)malloc(1024) ;	
	condition = (char *)malloc(258 );

	strcpy(cond_line ," where ");

	for( r = 0 ; r < NumAttribs ; r = r + 1  )   {

        	_pdm_debug("Attrib : %s", (char *) AttrList[r]);

		/* code for computed ID 

		if( PDU_ComputedID && !strcmp(AttrList[r],"n_itemname") )
			continue ;
		*/

	        /* If value exists in column 2 donot use condition */

		if( Get_text(fp,mcf,r,DATA_COL)) {

/* Added on 04/20/93 - TR#139305245 */
			if( PDU_ComputedID  && (!strcmp(AttrList[r],"n_itemname") ||
						!strcmp(AttrList[r],"n_itemdesc")))
			{
				tmp = s_text;
				while ( *tmp ) if ( *tmp++ == '$' ) break;
				if ( *tmp != '\0' ) /* Formula present */
					continue;
			}
/* End */

			strcpy(condition,s_text);

/* 2/10/94 - added for search across catalogs union and format */

			if( !strcmp( condition, "~" ) )
					continue;

/** Added for TR#139307305 **/
			if( strcmp( condition, "NULL" ) )
			{
				if( !strncmp(AttrTypes[r],"char", 4) 
				|| !strcmp(AttrTypes[r],"Expression text") ) 
        		             add_quotes(condition);

				else if(!strncmp(AttrTypes[r],"timestamp",9) ) {
					pdutimestamp_to_ascii(condition);
					lptr= (char *)malloc( strlen(condition) + 15 );
					sprintf(lptr," TIMESTAMP '%s'",condition);
					strcpy(condition,lptr);					free(lptr);
				}
			}

			if( (len = strlen(cond_line) + strlen(condition) + strlen(" =  and ") +10 ) >
				alloc_size ) {

				alloc_size = len + 128 ;
				cond_line = (char *)realloc(cond_line, alloc_size );
			}

			
			++j  ;

			if( j > 1 )strcat(cond_line," and " );

			strcat(cond_line,AttrList[r]);
/** Added for TR#139307305 **/
			if( strcmp( condition, "NULL" ) )
			{
				strcat(cond_line, " = " );
				strcat(cond_line,condition);
			}
			else
				strcat(cond_line, " is NULL " );

			_pdm_debug("global_where: cond_line: %s",cond_line);
	         }

        	 else	if( Get_text(fp,mcf,r,SEARCH_COL)) {             
	         /* No value inputted in column 2 . So use condition if any exists in column 3 */

			strcpy(condition,s_text);

			if(!Get_text(fp,mcf,r,OPER_COL))
				strcpy(operator_str , " = ");

			else {
				strcpy(operator_str,s_text);
				define_Aoperator(operator_str,ordering_type);
			}

        	        _pdm_debug("serach criteria before parsing : %s ", condition);

			if(operator_str[0] != '#' ){
				int rtr_rows, tmpsts ;
/* changed on 06/01/1993 for TR#139307328, if date format is not proper search fails */
				tmpsts =  CnvtOperNCriteriaToCondition (fp, mcf,r, -1, &rtr_rows, &condition1, ordering_type,
							AttrTypes,NumAttribs);
				if( !tmpsts )
					continue ;
				else if( tmpsts == -1 )
					return( tmpsts );
				strcpy(condition, condition1);
	                }
        	        else {
				char *out_str = NULL;
			/* TR# 139420793. 08/Dec/94 - raj. Catch the ret code. */
			/*
			do_search(fp,mcf, table_name,r,-77,&out_str,
			*/
			ret = do_search(fp,mcf, table_name,r,-77,&out_str,
					AttrList, AttrSynonym, AttrTypes, NumAttribs, &total_ent);
				if (out_str)
				free(out_str);
				strcpy(condition,"=");

			/* TR# 139420793. 08/Dec/94 - raj.	*/
			if (ret == -1)
			  return (ret);

				if(Get_text(fp,mcf,r,DATA_COL)){
/* Added for TR#139307305 */
					if( strcmp( s_text, "NULL") ){
					if(!strncmp(AttrTypes[r],"timestamp",9) ) {
						char *lptr;
						strcpy( condition, s_text );
						pdutimestamp_to_ascii(condition);
						lptr= (char *)malloc( strlen(condition) + 15 );
						sprintf(lptr,"=TIMESTAMP '%s'",condition);
						strcpy(condition,lptr);
						free(lptr);
					}
					else	/* 26/Nov/93 - raj. TR # 139310384	*/
					if( strncmp( AttrTypes[r],"char",4 ) )
						strcat(condition,s_text);
					else { /* if the attr is of text type */
						strcat(condition,"'");
						strcat(condition,s_text);
						strcat(condition,"'");
					}			
					}
					else strcpy( condition," is NULL " );
				}
				else /* If no value closest is found */
					return(0);		
        	        }
                            
			_pdm_debug("formula: %s",condition);
	
	                j = j + 1  ;

			if( (len = strlen(cond_line) + strlen(operator_str) + strlen(" and ") +
				    strlen(AttrList[r]) + strlen(condition) + 1 ) > alloc_size) {

				alloc_size = len + 128 ;
				cond_line = (char *)realloc(cond_line,alloc_size);
			}

                	if( j > 1 )strcat(cond_line," and " );
	                strcat(cond_line,AttrList[r]);
        	        strcat(cond_line,condition);

		}
	}

	_pdm_debug("global where line : %s", cond_line);

	if( j != 0 ){
		(*query_string) = (char *)realloc((*query_string),
						strlen(*query_string) +
						strlen(cond_line) + 128 );

			strcat((*query_string),cond_line);
	}

	_pdm_debug("query_string: %s", *query_string);

	return(1);
}


validate_search_criteria_input(char *oper, char **str)
{

	int i;
	char *ptr[2],*lcrit;

	if(  strcmp(oper,"between") != 0 ) {
/*printf("before calling parse_exp_and_get\n");*/
		if(parse_exp_and_get_value(str))
			return(1);
		else
			return(0);
	}


	lcrit = malloc(strlen(*str) + 1 );

	strcpy(lcrit, *str);

	ptr[0] = strtok(lcrit,"&");
	ptr[1] = &lcrit[strlen(ptr[0])+1];

	if( ptr[1] == NULL ){
		free(lcrit);
		return(0);
	}
		
	for(i = 0 ; i < 2 ; ++i ){
		strcpy(*str,ptr[i]);

		if( !parse_exp_and_get_value(str)){
			free(lcrit);
			return(0);
		}
	}
	
	free(lcrit);
	return(1);
}

PDUgetDefPlcmntName(char **defname,char *catname)

{
	int sts , max_rows = 1, err_code ;
	char query[128], *output_str , *ptr=NULL;

	sprintf(query,"select n_catalogno from nfmcatalogs where n_catalogname='%s'",
					catname);

	_pdm_debug("get catalog no: query: %s",query);

	sts = RISquery(query,&max_rows,&output_str,&err_code);

	if( sts < 0 ) {
		free( output_str );
		RIS_box(err_code);
		return(0);	
	}
	
	_pdm_debug("query status: %d", sts);
	_pdm_debug("PDUgetDefPlcmntName () output_str  : %s", output_str);

	ptr = strtok(output_str,"~");

	if( ptr == NULL ) return(0);

	sprintf(query,"select p_defname from pdmcatalogs where n_catalogno=%s",
				ptr);
	
	free( output_str );

	_pdm_debug("Get default placement name query: %s", query);


	sts = RISquery(query,&max_rows,&output_str,&err_code);

	if( sts < 0 ) {
		free( output_str );
		RIS_box(err_code);
		return(0);	
	}
	ptr = NULL;

	ptr = strtok(output_str,"~");

	if( ptr == NULL || (strlen(output_str) < 1) ) return(0);

	*defname = (char *)malloc(strlen(ptr) + 1 );

	MemCheck(*defname);

	strcpy(*defname,ptr);

	free(output_str);

	return(1);
			
}

CnvtOperNCriteriaToCondition (Form fp, int glabel, int row, int rowfromout, int *rows_to_retrv, char **condition, char *ordering_type,
	  char **AttrTypes,
	  int  NumAttribs)
{

	char *criteria = NULL, operator_str[32];
	char *str = NULL;
        char *msg = NULL;
	int sts;

	/* Do this only if value exists in search column */
	if( Get_text(fp,glabel,row,SEARCH_COL)) {

		_pdm_debug("criteria in search col: %s", s_text);
		criteria = (char *) malloc(strlen(s_text) + 10 + 32);
		strcpy( criteria , s_text );

		/* If criteria is NULL, frame condition line different. */
		if (!strcmp (criteria, "NULL"))
		{
			*condition = (char *) malloc( (strlen(" is NULL ") + 1) * sizeof (char));
			strcpy (*condition, " is NULL ");
			MyFree (criteria);
			return (1);
		}

		/* If operator doesn't exists in OPER_COL use ' = ' */
		if( ! Get_text(fp,glabel,row,OPER_COL) )
			strcpy(operator_str," = ");
		else {  /* if operator exists, convert it (if necessary) and use it */
			strcpy(operator_str,s_text);
			/* the operator is "closer >" || "closer <"	      */
			/* are converted to "#>"      || "#<" for later use   */
			define_Aoperator(operator_str, ordering_type);
		}

		_pdm_debug("operator : %s", operator_str );

		if(!strcmp(operator_str,"between")){
			if(!build_and_cond(&criteria,row)){
				MyFree(criteria);
				return(0);
			}
		}
		/* If data type of attribute is NOT 'char', it might be an */
		/* equation of expressions so parse it.			   */
 		else if( strncmp(AttrTypes[row],"char",4) ){
/* added for TR#139300740 */
			if(!strncmp(AttrTypes[row],"timestamp",9) ) {
				if( !((strlen(criteria) > 2) && (criteria[2] == '/' )))
				get_text_exp_value(&criteria);
				str = (char *)malloc(strlen(criteria) + 1 );
				strcpy( str, criteria );
				sts = pdutimestamp_to_ascii( str );
				if( !sts )
				{
                                        msg = (char *)PDUtranslate_message(PDM_E_INVALID_DATE_FORMAT);
					FIfld_set_text(fp,FI_MSG_FIELD,0,0,msg,0);
					return(-1);
				}
				criteria = (char *)realloc(criteria, strlen("timestamp")+
							     strlen(str) + 4 );
				strcpy( criteria, "TIMESTAMP '");
				strcat( criteria, str );
				strcat( criteria, "'" );

			} /* end */
			else if(! parse_exp_and_get_value(&criteria)){
				MyFree( criteria );
 				return (0);
			}

			/* If the row being searched on (rowfromout) is same  */
			/* as the row ( row ) to which this criteria belongs  */
			/* AND 						      */
			/* the operator is "closer >" || "closer <"	      */
			/* The number of rows to be retrieved is just ONE     */
			if( rowfromout ==  row && operator_str[0] == '#') *rows_to_retrv = 1 ;

/*			from_work_to_cat_units(1,AttrUnits[row], criteria); */
		}
		else {  /* if text */
			_pdm_debug("text exp name: %s", criteria );
			get_text_exp_value(&criteria);
			_pdm_debug("text exp value: %s", criteria );
			add_quotes(criteria);
/*
			if( strncmp( operator_str, " like", 5 ) ) 
			strcpy(operator_str," = ");
*/
		}

		
		*condition = (char *) malloc( strlen(operator_str) + 1 + strlen (criteria) + 1);
                 
		if (operator_str[0] == '#')
			sprintf (*condition, "%s %s", &operator_str[1], criteria);
	        else if( !strcmp(operator_str,"between")  )
			strcpy (*condition, criteria);
		else
			sprintf (*condition, "%s %s", operator_str, criteria);

		_pdm_debug("parsed criteria: %s", *condition);
 
		MyFree (criteria);
	}
	else
		return(0);
	return (1);
}

build_and_cond(char **criteria, int row)

	/* if the operator is 'between' then the criteria input will be in the
           format a,b
	*/
{
	int  i = 0 ;
 	char *ptr[2], *str = NULL, *lcrit  = NULL;
	char atname[50];

	/* 27/Dec/93 - raj.	TR# 13931 0385.	*/
	int	ii, sts;
	char	*str_tmp = NULL;

	strcpy( atname, AttrList[row] );

	lcrit = malloc(strlen(*criteria)+1);
	strcpy(lcrit,*criteria);

	ptr[0] = strtok(lcrit , "&");
	ptr[1] = &lcrit[strlen(ptr[0])+1];

/* TR# 13941 5919.	*/
    {
	int	len;

	/* Remove leading blanks.	*/
	while(*(ptr[0]) == ' ')
		ptr[0]++;
	while(*(ptr[1]) == ' ')
		ptr[1]++;

	/* Remove trailing blanks.	*/
	len = strlen(ptr[0]);
	while(ptr[0][--len] == ' ')
		ptr[0][len] = '\0';

	len = strlen(ptr[1]);
	while(ptr[1][--len] == ' ')
		ptr[1][len] = '\0';
    }
/* TR# 13941 5919.	*/

	_pdm_debug(" between: %s", ptr[0]);
	_pdm_debug(" between: %s", ptr[1]);
	_pdm_debug("AttrType = <%s>", AttrTypes[row]);
	
	for( i = 0 ; i < 2 ; ++i ){
		
		str = malloc(strlen(ptr[i])+10);
		strcpy(str,ptr[i]);
		
		/*
		 **************************************************************
		 * 27/Dec/93 - raj. TR# 13931 0385. BEGIN.
		 * Treat TIMESTAMP fields seperately.
		 */
		if(!strncmp(AttrTypes[row],"timestamp",9) )
		{
		  /* removes leading blanks */
		  for(ii = 0 ; ptr[i][ii] != '\0' && ptr[i][ii] != '\n'; ii = ii + 1)
		  {
                    if(ptr[i][ii] != ' ')
                	break;
                  }
                  str_tmp = malloc(strlen(&ptr[i][ii])+10);
                  strcpy(str_tmp,&ptr[i][ii]);
                  if( !((strlen(str_tmp) > 2) && (str_tmp[2] == '/' )))
                    get_text_exp_value(&str_tmp);

                  sts = pdutimestamp_to_ascii( str_tmp );
                  if( !sts )
                  {
                    return(-1);
                  }
                  
                  str = (char *)realloc(str, strlen("timestamp")+strlen(str_tmp) + 10);
                  strcpy( str, "TIMESTAMP '");
                  strcat( str, str_tmp );
                  strcat( str, "'" );
                  MyFree(str_tmp);
                }
                else
                /*
                 * 27/Dec/93 - raj. TR# 13931 0385. END.
                 **************************************************************
                 */
 		if( strncmp(AttrTypes[row],"char",4) ){ /* if it is not text attr */
			if(!parse_exp_and_get_value(&str))
				break;
		}
		else { /* text attr */
			get_text_exp_value(&str);
			_pdm_debug("build&cond:text exp value: %s", str);
			add_quotes(str);
		}
	
		if( ! i) {
			*criteria = (char *)realloc(*criteria,strlen( "between ")+strlen(str) +  20 );

			sprintf(*criteria," between %s and ",str);

			_pdm_debug("criteria : %s", *criteria );

		}

		else {
			*criteria = (char *)realloc(*criteria,strlen(str) + strlen (*criteria) + 3 );

			strcat(*criteria,str);

			_pdm_debug("criteria : %s", *criteria );

			MyFree(str);   MyFree(lcrit);
			return(1);
		}

		MyFree(str);
	}

	MyFree(str);
	MyFree(lcrit);

	return(0);
}


GetTheseGivenThose (char *catalog, 
			 char **these,  char ***these_val,
			 int  no_these,
			 char **those, char **those_type, char **those_val, 
			 int  no_those)
{
	/* This routine retrieves the values of the catalog attributes	*/
	/* given the static template values and vice versa	        */
        /* It also needs the 'catalog' (table)                          */
	int	i, j = 0, maxrows = 1, err, sts;
	char	*ptr = NULL, *clause = NULL, *query = NULL, *out_put = NULL;

	_pdm_debug("Value In these_val   = %x\n", *these_val);
	_pdm_debug("Address of these_val = %x\n", these_val);

	/* Build where clause to retrieve values */
	clause = (char *) malloc (2);
	clause[0] = '\0';

	while (j < no_those){
		if( strlen( those_val[j] ) < 1 ){ /* Add only those with a value */
			j++;
			continue;
		}	
		if (j > 0){
			clause = (char *) realloc (clause, 
						   strlen (clause) + 
						   strlen (" and ") + 1 );
			MemCheck(clause);
			strcat (clause, " and ");
		}
		clause = (char *) realloc (clause, strlen (clause) + 
					   strlen (those[j]) + 
					   strlen (" = ") + 
					   strlen (those_val[j]) + 25 );

		MemCheck(clause);

		strcat (clause, those[j]);
		strcat (clause, " = ");
		if( !strcmp(those_type[j],"Expression text") || 
		    !strncmp(those_type[j],"char", 4))
		{
			strcat(clause,"'");
			strcat(clause,those_val[j++]);
			strcat(clause,"'");
		}
		else if( !strncmp(those_type[j],"timestamp",9)){
			pdutimestamp_to_ascii(those_val[j]);
			strcat(clause," TIMESTAMP '");
			strcat(clause,those_val[j++]);
			strcat(clause,"'");
		}			
		else
			strcat (clause, those_val[j++]);

		_pdm_debug("clause %s",clause);
	}

	_pdm_debug("Final clause %s", clause );

	query = (char *) malloc ((no_these * 32 + 132) * sizeof (char));
	MemCheck(query);

	/* Build PRE query */
	strcpy (query, "Select ");
	/* Catalog attributes list */
	for (i = 0; i < no_these; i++){
		if (i > 0)
			strcat (query, ", ");
		strcat (query, these[i]);
	}
	strcat (query, " From ");
	/* TABLE */
	strcat (query, catalog);
	strcat (query, " Where ");
	/* Add the where clause */
	query = (char *) realloc (query, strlen (query) + strlen (clause) + 1);
	MemCheck(query);

	strcat(query,clause);
	MyFree (clause);

	_pdm_debug("query is %s",query);

	/* Send RIS query */
	
	sts = RISquery (query, &maxrows, &out_put, &err);	
	MyFree (query);

	if (sts < 0){
		MyFree (out_put);
		fprintf (stderr, "Error In RIS Operation - %d\n", err);
		RIS_box(err);
		return (0);
	}

	_pdm_debug("output %s",out_put );

        *these_val = (char **) malloc ( sizeof (char *));
	MemCheck(*these_val);

	i = 0;
	ptr = strtok (out_put, "~");
	while (ptr != NULL){

        	*these_val = (char **) realloc (*these_val,(i+1) * sizeof (char *));

		(*these_val)[i] = (char *) malloc (strlen (ptr) + 1);
		MemCheck ((*these_val)[i]);
		
		if( !strcmp(ptr,"nil"))
			(*these_val)[i][0] = '\0' ;
		else
			strcpy ((*these_val)[i], ptr);
		ptr = strtok (NULL, "~");
		_pdm_debug("theseval = %s", (*these_val)[i]);
		i++;
	}

	_pdm_debug ("maxrows %d", maxrows);
	_pdm_debug ("i = %d", i);

	_pdm_debug("Value In these_val   = %x\n", *these_val);
	_pdm_debug("Address of these_val = %x\n", these_val);

	for (i = 0; i < maxrows; i++)
		_pdm_debug ("Address of theseval[] %x", (*these_val)[i]);

	MyFree (out_put);
	return (1);
}


format_searchlist_bufr(lcl_bufr)
MEMptr lcl_bufr ;
{
	int i, numcol, sts  ;

	char **format_ptr , **column_ptr;


	_pdm_debug("Format buffer", 0 );

	if( (sts = MEMopen(&PDUsearch_part_list,512) ) != MEM_S_SUCCESS ){
		_pdm_debug("Error opening PDUsearch_part_list buffer",0);
		return(0);
	}

	column_ptr = (char **)lcl_bufr -> column_ptr ;
	format_ptr = (char **)lcl_bufr -> format_ptr ;

	if(!format_column(&PDUsearch_part_list,"n_catalogname","char(20)"))
		goto cleanup;

	numcol = lcl_bufr -> columns ;

	_pdm_debug("numcol: %d", numcol );

	for( i = 0 ; i < numcol ; ++ i ) 

		if( !format_column(&PDUsearch_part_list,column_ptr[i],format_ptr[i]))
			goto cleanup;

	return(1);

cleanup:
	MEMclose(&PDUsearch_part_list );
	PDUsearch_part_list = NULL ;
	return(0);
}

add_bufr_to_global_buffer(char *catname, MEMptr lcl_bufr)
{

	int i, j, sts  ;

	char *str, ** data_ptr  ;

	_pdm_debug("In add_bufr_to_global_buffer: %s", catname );

	if( lcl_bufr == NULL )
		return(0);

	if( PDUsearch_part_list == NULL ) 
		if( !format_searchlist_bufr(lcl_bufr) )
			return(0);


	_pdm_debug("buffer row size: %d", lcl_bufr -> row_size );

	str = (char *)malloc( lcl_bufr -> row_size + 3*lcl_bufr -> columns + 1) ;


	data_ptr = (char **)lcl_bufr -> data_ptr ;

	_pdm_debug("cat name: %s", catname );

	for( i = 0 ; i < lcl_bufr -> rows ; ++i ) {

		strcpy(str,catname);
		strcat(str,"\1");
		
		for( j = 0 ; j < lcl_bufr -> columns ; ++j ) {

			if( data_ptr[j+i*lcl_bufr -> columns] &&
			    strlen(data_ptr[j+i*lcl_bufr -> columns]) > 0)
				strcat(str, data_ptr[j+i*lcl_bufr -> columns]);

			strcat(str,"\1");

		}

		_pdm_debug("str: %s", str );

		if( (sts = MEMwrite(PDUsearch_part_list,str)) != MEM_S_SUCCESS){

			MEMclose(&PDUsearch_part_list );
			PDUsearch_part_list = NULL;
			free( str );
			return(0);
		}
	}

	free( str );
	if ( PDMdebug_on )
		MEMprint_buffers( "search list buffer..", PDUsearch_part_list, PDU_DEBUG_FILE );

        _pdm_debug("exiting add_bufr_to_global_buffer", 0);

	return(1);
}

pdutimestamp_to_ascii(char *str)
{

	char *tmp,*m = NULL, *d = NULL , *y = NULL;
	char *h = NULL, *mi = NULL ,*s = NULL;
	int pdudate = TRUE;

	tmp = (char *)malloc(strlen(str) + 1);

	strcpy(tmp,str);

	m = strtok(tmp,"/");
	if ( m == NULL ) {	pdudate = FALSE;  goto end; }
	d = strtok(NULL,"/");
	if ( d == NULL ) {	pdudate = FALSE;  goto end; }
	y = strtok(NULL," ");
	if ( y == NULL ) {	pdudate = FALSE;  goto end; }
	h = strtok(NULL,":");
	if ( h == NULL ) {	pdudate = FALSE;  goto end; }
	mi = strtok(NULL,":");
	if ( mi == NULL ) {	pdudate = FALSE;  goto end; }
	s = strtok(NULL,":");
	if ( s == NULL ) {	pdudate = FALSE;  goto end; }

end:
	if( pdudate )
	{
		sprintf(str,"%s-%s-%s:%s:%s:%s",y,m,d,h,mi,s);
		_pdm_debug("str: %s", str);
		return(1);
	}
	return(0);
}
		
	

PALgetPartType(char *catalog,char *partid,char *revision, char **parttype )
{

	char query[256],  *outstr, *ptr   ;
	int max_rows = 1 , err_code , sts ;

	sprintf(query,"select p_parttype from %s where n_itemname = '%s' and n_itemrev = '%s' ",
				catalog, partid, revision );

	_pdm_debug("query: %s", query );

	sts = RISquery(query,&max_rows, &outstr,&err_code );

	if( sts < 0 ){
		RIS_box(err_code);
		free(outstr);
		return(0);
	}

	if( !max_rows ){
		return(0);
	}

	ptr = strtok(outstr,"~");

	free ( outstr );

	if( ptr ) {
		*parttype = (char *)malloc( strlen (ptr) + 1 );

		strcpy( *parttype, ptr );
		return(1);
	}
	else{
		return(0);
	}
}

	
