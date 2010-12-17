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
#include "PDMmessage.h"

#define	PARAMETERS     22
#define SUB_TABLE      21	

/*------------------------------------------------------------------ */
/*  Globale variables */
extern char **AttrList ;	   /* common attribute list    */
extern char **AttrSynonym ;        /* synonyms of attributes   */
extern char **AttrTypes   ;        /* attribute types          */
extern int  NumAttribs    ;	   /* No. of common attributes */


extern char CatNameList[2000][TBL_LEN] ;     /* List of catalog names */
extern int  NumCatalogs, TblNos[2000];      /* no. of catalogs and corresponding table numbers */
extern char *s_text  ;
extern int  max_rows_rtvd ;
extern int   PDMdebug_on ;
extern char *PDU_part_sort_string ;
extern int  PDU_cat_selected     ;
extern char *PDU_srch_catalog;
extern int  PDU_ComputedID     ;
extern int  display_all ,row_num ;
extern short  PALis_sort_selected  ;
extern struct PDUrefresh *refresh ;
/*------------------------------------------------------------------ */

extern MEMptr PDUsearch_part_list ;

search_on_multiple_ctlgs_for_format(Form fp1, int mcf,Form fp2,int cat_field)
{

	int  i=0 ;
	MEMptr  cat_bufr=NULL  ;
        int   num_cats = 0;
        int   index = 0;
        int   status = PDM_S_SUCCESS;
        char  **cat_list = NULL;

        _pdm_debug("in the function search_on_multiple_ctlgs_for_format", 0);

        PDUmessage(PDS_M_SEARCH_ACROSS_CATS, 's');

        if(IGEresetstop())
            {
        _pdm_debug("IGEreset stop for with format Attrib failed %d", 0);
             }
	if( Get_text(fp1,cat_field,0,0)){

		NumCatalogs = 1 ;
		strcpy(CatNameList[0],s_text);
	}

	max_rows_rtvd = 0 ;

        _pdm_debug("freeing PDUsearch_part_list", 0);
	if( PDUsearch_part_list ){
		MEMclose(&PDUsearch_part_list);
		PDUsearch_part_list = NULL ;
	}

      if(fp2)	FIf_reset (fp2);
      if(fp2)  FIg_reset (fp2,PARAMETERS);
      if(fp2) FIg_reset (fp2,SUB_TABLE);

        i = 0;

           _pdm_debug("calling gen_valid_list_of_catalogs", 0);
           status = gen_valid_list_of_catalogs(fp1, mcf, AttrList, 
                    AttrSynonym, AttrTypes, NumAttribs, &cat_bufr);
                _pdm_status("gen_valid_list_of_catalogs", status);
                if (status != 1)
                  {
                  status =  PDM_E_ERROR_SEARCHING_4_PARTS;
                  PDUmessage(status, 's');
                  return(status);
                  }

		if (PDMdebug_on)
                  MEMprint_buffer("cat_bufr", cat_bufr, PDU_DEBUG_FILE);

                if (PDUsearch_part_list)
                  {
                  MEMclose(&PDUsearch_part_list);
                  PDUsearch_part_list = NULL;
                  }
                     
                _pdm_debug("calling do_incremental_search_for_format", 0);
                status = do_incremental_search_for_format(fp1, mcf, fp2,
                          &cat_list, cat_bufr, AttrList, AttrSynonym,
                          AttrTypes, NumAttribs, &num_cats);
                _pdm_status("do_incremental_search_for_format", status);
                if (status == PDM_E_NO_PARTS_FOUND)
                  { 
                  PDUmessage(status, 's');
                  return(status);
                  }
                else if (status != 1)
                  {
                  status =  PDM_E_ERROR_SEARCHING_4_PARTS;
                  PDUmessage(status, 's');
                  return(status);
                  }
                 PDUmessage(PDM_E_CLEAR_FIELD, 's' );
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

                _pdm_debug("num_cats = %d", (char *)num_cats);
                for (index = 0; index < num_cats; ++index)
                   _pdm_debug("catalog entry = <%s>", cat_list[index]);

	        if( NumCatalogs == 1 )
		 set_sub_form_params_for_union (fp2, PARAMETERS,PDUsearch_part_list,0);
	        else
		 set_sub_form_params_for_union (fp2, PARAMETERS,PDUsearch_part_list,1);   

        max_rows_rtvd = PDUsearch_part_list->rows;

	if( max_rows_rtvd > 0 )
		FImcf_set_select(fp2, SUB_TABLE, (max_rows_rtvd - 1), 1);

	get_row_from_mcf (max_rows_rtvd, NumAttribs , fp2, 21);
	return(1);
}


int add_bufr_to_global_buffer_for_format(char *cat_name, MEMptr lcl_bufr)
{
   int status = 0, sts = 0, i = 0, k = 0, j = 0, nxi = 0 , found = 0, index = 0;
   char *str = NULL, **data_ptr = NULL, **col_ptr = NULL, **global_col = NULL;
       static MEMptr part_list;

        _pdm_debug("In add_bufr_to_global_buffer_for_format:", 0 );

        if( lcl_bufr == NULL )
                return(0);

        if( PDUsearch_part_list == NULL )
             {
           status = MEMopen(&PDUsearch_part_list,1024);
          if(status != MEM_S_SUCCESS)
              {
                _pdm_debug("MEMopen of PDUsearch_part_list failed:", 0 );
                return(PDM_E_OPEN_BUFFER);
               }
       status = MEMwrite_format(PDUsearch_part_list,"n_catalogname","char(20)");
       _pdm_status("MEMwrite_format", status);
                if(status != MEM_S_SUCCESS)
                {
               _pdm_debug("MEMwrite_fprmat <n_catalogname> of PDUsearch_part_list failed:", 0 );
                return(PDM_E_WRITE_FORMAT);
                }
               for(i=0;i< NumAttribs;i++)
                {
                _pdm_debug("AttrList[i] = <%s>", AttrList[i]);
                _pdm_debug("AttrTypes[i] = <%s>", AttrTypes[i]);
        status = MEMwrite_format(PDUsearch_part_list,AttrList[i],AttrTypes[i]);
       _pdm_status("MEMwrite_format", status);
                if(status != MEM_S_SUCCESS)
                {
               _pdm_debug("MEMwrite_fprmat of <%s> PDUsearch_part_list failed:", AttrList[i] );
                return(PDM_E_WRITE_FORMAT);
                }
                }
             status = MEMsplit_copy_buffer(PDUsearch_part_list, &part_list, 0);
             _pdm_status("MEMsplit_copy_buffer", status);
                if(status != MEM_S_SUCCESS)
                {
       _pdm_debug("MEMsplit_copy_buffer of PDUsearch_part_list failed:", 0 );
                return(PDM_E_WRITE_FORMAT);
                }
             }
if (PDMdebug_on) {
  MEMprint_buffer("PDUsearch_part_list", PDUsearch_part_list, PDU_DEBUG_FILE);
 }
                status = MEMbuild_array(part_list);
                if(status != MEM_S_SUCCESS)
                {
               _pdm_debug("MEMwrite_fprmat of PDUsearch_part_list failed:", 0 );
                return(PDM_E_WRITE_FORMAT);
                }
                status = MEMbuild_array(lcl_bufr);
                if(status != MEM_S_SUCCESS)
                {
               _pdm_debug("MEMwrite_fprmat of PDUsearch_part_list failed:", 0 );
                return(PDM_E_WRITE_FORMAT);
                }
              global_col = (char **) part_list->column_ptr;

         _pdm_debug("buffer row size: %d", lcl_bufr -> row_size );
   str = (char *)malloc( part_list -> row_size + 3*lcl_bufr -> columns + 1);
        data_ptr = (char **)lcl_bufr -> data_ptr ;
        col_ptr = (char **)lcl_bufr -> column_ptr ;

         str[0] = '\0';

        for( i = 0 ; i < lcl_bufr -> rows ; ++i ) 
        {
         nxi = i * lcl_bufr->columns;
         strcpy(str, cat_name);
         strcat(str,"\1");
        for(j = 1; j <  part_list->columns; j++)
          {
             found = 0; index = 0;
            for(k = 0; k < lcl_bufr->columns; k++)
              {
               if(!strcmp(global_col[j], col_ptr[k]))
                 {
                  index = k;
                  found = 1; break;
                 }
                 else continue;
               } 
               if(found) 
                {
                 if(strlen(data_ptr[nxi + index]))
                strcat(str, data_ptr[nxi + index]);
                 }
                 else
                strcat(str,"~");
                strcat(str,"\1");
             }

           _pdm_debug("str: %s", str );
            if( (sts = MEMwrite(PDUsearch_part_list,str)) != MEM_S_SUCCESS)
             {
                _pdm_debug("MEMwrite failed : %s", str );
		if (PDMdebug_on)
            MEMprint_buffer("PDUsearch_part_list", PDUsearch_part_list, PDU_DEBUG_FILE);
                        MEMclose(&PDUsearch_part_list );
                        PDUsearch_part_list = NULL;
                        if(str) free( str );
                        return(0);
             }
         }

        if(str) free( str );
        if ( PDMdebug_on )
          MEMprint_buffer( "search list buffer..", PDUsearch_part_list, PDU_DEBUG_FILE );
        return(PDM_S_SUCCESS);
}



do_incremental_search_for_format(Form fp1, int mcf, Form fp2,
                        char ***table_names1, MEMptr data_bufr, char **AttrList, char **AttrSynonym, char **AttrTypes, int  NumAttribs, int *data_catalogs)
	
	/* Fetch parts with given criteria. Both for view and table */
{

	long sts, status  ;
	int  cat, col, tmpsts;
	char *query_string = NULL, *query_string1 = NULL;
        char **cat_names = NULL, **table_names = NULL;
        MEMptr cat_bufr = NULL;
    
         _pdm_debug("Enter: do_incremental_search_for_format", 0);

	*data_catalogs = 0;
        cat = 0;
	if( NumAttribs == 0 ) 
             return(0) ;

         status = MEMbuild_array(data_bufr);
          if(status != MEM_S_SUCCESS)
           {
            _pdm_debug("MEMbuild_array of data_bufr failed status %d", 0);
             return(status);
           }

           if(data_bufr->rows == 0) return(0) ;
           cat_names = (char **) data_bufr->data_ptr;
      table_names = (char **) malloc ((sizeof(char *) * data_bufr->rows) + 1);
	   query_string = malloc(24);
	   strcpy(query_string, "  ");
	   _pdm_debug("Incremental search() query string: %s",query_string);

      /* gen_condition_line will return 0 if the operator is #>< and if no value is found closest to the given criteria */
         
	_pdm_debug("AttrList[0]: %s",AttrList[0]);
	_pdm_debug("AttrList[NumAttribs]: %s",AttrList[NumAttribs-1]);
	tmpsts = gen_condition_line(fp1, mcf, &query_string, cat_names[0],
			AttrList, AttrSynonym, AttrTypes, NumAttribs );
	if( !tmpsts ) return(1); 
	else if( tmpsts == -1 )
	{
		if (PDU_cat_selected )display_all = 0 ;
		max_rows_rtvd = 0 ;
		MyFree(query_string);
		return(0);
	}

	_pdm_debug("Incremental search() query string: %s",query_string);

	/* Add order by clause here */

	if( PALis_sort_selected && (PDU_part_sort_string != NULL) ) {
           _pdm_debug("sort string: %s", PDU_part_sort_string);
           query_string = (char *)realloc(query_string,strlen(query_string)+
		strlen(PDU_part_sort_string ) + 10 );
		strcat(query_string,PDU_part_sort_string);
	}

        
	if( PALis_sort_selected && (PDU_part_sort_string != NULL) ) 
        query_string1 = (char *)malloc(strlen(query_string)+ strlen(PDU_part_sort_string ) + 100 );
        else
        query_string1 = (char *)malloc(strlen(query_string) + 100 );
        
         if (PDU_srch_catalog)
          {
          free(PDU_srch_catalog);
          PDU_srch_catalog = NULL;
          }
         PDU_srch_catalog = (char *) malloc (21);
         PDU_srch_catalog[0] = '\0';

	for( col = 0 ; col < data_bufr->rows; col++ ) {

         query_string1[0] = '\0';
         cat_bufr = NULL;
    _pdm_debug("searching catalog : %s",cat_names[col]);
         if (PDU_srch_catalog)
          {
          free(PDU_srch_catalog);
          PDU_srch_catalog = NULL;
          }
         PDU_srch_catalog = (char *) malloc (21);
          PDU_srch_catalog[0] = '\0';
          strcpy(PDU_srch_catalog, cat_names[col]);
          PDUmessage(PDM_I_SEARCHING_CATALOG, 's');
	if( PALis_sort_selected && (PDU_part_sort_string != NULL) ) 
  sprintf(query_string1, "SELECT *  FROM %s %s ", cat_names[col], query_string); 
       else
  sprintf(query_string1, "SELECT *  FROM %s %s ORDER BY n_itemname, n_itemrev", cat_names[col], query_string); 
           
	sts = SQLquery(query_string1,&cat_bufr,512);
	if( sts == SQL_I_NO_ROWS_FOUND)
           {
		if( cat_bufr ) MEMclose(&cat_bufr);
                _pdm_debug("No parts in this catalog %s: ", cat_names[col]);
                continue;
	    }
	else if( sts != SQL_S_SUCCESS )
            {
		MEMclose(&cat_bufr);
               _pdm_debug("Error in this catalog %s: ", cat_names[col]);
                continue;
	     }

        table_names[cat] = (char *) malloc (20);
        strcpy(table_names[cat], cat_names[col]);
        cat++;

        if(  cat_bufr && cat_bufr->rows != 0)
         {
         if (PDU_srch_catalog)
          {
          free(PDU_srch_catalog);
          PDU_srch_catalog = NULL;
          }
         PDU_srch_catalog = (char *) malloc (21);
         PDU_srch_catalog[0] = '\0';
         sprintf(PDU_srch_catalog, "%d", cat_bufr->rows);
         PDUmessage(PDM_I_NUM_ROWS_IN_CATALOG,'s');
         }
        status = add_bufr_to_global_buffer_for_format ( cat_names[col], cat_bufr);
        _pdm_status("add_bufr_to_global_buffer_for_format", status);
        if (status != PDM_S_SUCCESS)
          {
          PDUmessage(status, 's');
          return(status);
          }

         if(cat_bufr) MEMclose(&cat_bufr); 
           if( IGEstop ())
                            {
        _pdm_debug("IGEstop for with union Attrib enabled %d", 0);
                            PDUmessage(PDM_E_CLEAR_FIELD, 's' );
                              IGEresetstop(); break;
                            }

        }


        if (!PDUsearch_part_list)
          {
          PDUmessage(PDM_E_NO_PARTS_FOUND, 's');
          return(PDM_E_NO_PARTS_FOUND);
          }

          PDUmessage(PDM_E_CLEAR_FIELD, 's' );
	if ( PDMdebug_on )
	MEMprint_buffer( "search list buffer..", PDUsearch_part_list, PDU_DEBUG_FILE );

              if (!PDUsearch_part_list)
                  {
                  status =  PDM_E_NO_PARTS_FOUND;
                  PDUmessage(status, 's');
                  return(status);
                  }
        _pdm_debug("no. of rows retrieved: %d", (PDUsearch_part_list) -> rows );

        max_rows_rtvd = 0;
        row_num = max_rows_rtvd ;

        max_rows_rtvd  += (PDUsearch_part_list) -> rows ;

	*data_catalogs = cat;
        *table_names1 = table_names;

       if(query_string)       free(query_string);
       if(query_string1) free(query_string1);

        set_table_field_for_union_or_format(fp2,table_names,SUB_TABLE, 
                                            row_num,PDUsearch_part_list);

        PDUmessage(PDM_S_SUCCESS, 's');

         _pdm_debug("Exit: do_incremental_search_for_format", 0);
	return(1);
}
