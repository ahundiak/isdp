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
extern int  PDU_ComputedID     ;
extern int  display_all ,row_num ;
extern short  PALis_sort_selected  ;
extern struct PDUrefresh *refresh ;
/*------------------------------------------------------------------ */

extern MEMptr PDUsearch_part_list ;

search_on_multiple_ctlgs_with_union(Form fp1, int mcf,Form fp2,int cat_field)
{

	int  i=0 ;
	MEMptr  cat_bufr=NULL  ;
        int   num_cats = 0;
        int   index = 0;
        int   status = PDM_S_SUCCESS;
        char  **cat_list;

        _pdm_debug("in the function search_on_multiple_ctlgs_with_union", 0);

	if( Get_text(fp1,cat_field,0,0)){

		NumCatalogs = 1 ;
		strcpy(CatNameList[0],s_text);
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
       for( i = 0 ; i < NumAttribs ; i = i + 1  )   

        _pdm_debug("Search with union Attrib : %s", (char *) AttrList[i]);
       
                     
                _pdm_debug("calling do_incremental_search_with_union", 0);
                status = do_incremental_search_with_union(fp1, mcf, fp2,
                          &cat_list, cat_bufr, AttrList, AttrSynonym,
                          AttrTypes, NumAttribs, &num_cats);
                _pdm_status("do_incremental_search_with_union", status);
                if (status != 1)
                  {
                  status =  PDM_E_ERROR_SEARCHING_4_PARTS;
                  PDUmessage(status, 's');
                  return(status);
                  }

                _pdm_debug("num_cats = %d", (char *)num_cats);
                for (index = 0; index < num_cats; ++index)
                   _pdm_debug("catalog entry = <%s>", cat_list[index]);

	        if( NumCatalogs == 1 )
		 set_sub_form_params_for_union (fp2, PARAMETERS,PDUsearch_part_list,0);
	        else
		 set_sub_form_params_for_union (fp2, PARAMETERS,PDUsearch_part_list,1);   

                        if( IGEstop ())
                            {
                              IGEresetstop();
                              return(0);
                            }

        max_rows_rtvd = PDUsearch_part_list->rows;

	if( max_rows_rtvd > 0 )
		FImcf_set_select(fp2, SUB_TABLE, (max_rows_rtvd - 1), 1);

	get_row_from_mcf (max_rows_rtvd, NumAttribs , fp2, 21);

	return(1);
}


gen_valid_list_of_catalogs(Form fp, int mcf, char **AttrList, char **AttrSynonym, char **AttrTypes, int  NumAttribs, MEMptr *cat_bufr)

        /* This function looking at each search field column   */
        /* and gets the list of tables which have these attributes */
{

        char *cond_line , *query_string, **catno = NULL;
        int  j = 0, found1 = 0, i = 0, r , alloc_size = 1024, len  ;
        long status = 0;
        char *tmp, tmp1[50];
        MEMptr catno_bufr = NULL;

        _pdm_debug("Inside gen_valid_list_of_catalogs", 0);

        cond_line = (char *)malloc(1024) ;

        if(NumAttribs > 0)
        {
        strcpy(cond_line ," where (");

        found1 = 0;
        for( r = 0 ; r < NumAttribs ; r ++  )   {
                /* If value exists in column 2 donot use condition */
                if( Get_text(fp,mcf,r,DATA_COL)) 
                {
          if( PDU_ComputedID  && (!strcmp(AttrList[r],"n_itemname") ||
                             !strcmp(AttrList[r],"n_itemdesc")))
                        {
                              tmp = s_text;
                                while ( *tmp ) if ( *tmp++ == '$' ) break;
                                if ( *tmp != '\0' ) /* Formula present */
                                        continue;
                        }

         if( (len = strlen(cond_line) + strlen("n_name  =") +20 ) > alloc_size ) 
                         {
                         alloc_size = len + 128 ;
                         cond_line = (char *)realloc(cond_line, alloc_size);
                         }
                        ++j  ;

                        tmp1[0] = '\0';
                        if( r < NumAttribs -1)
                         {
                         if (found1 == 1) found1 = 2; 
                        sprintf(tmp1,"n_name = '%s' ", AttrList[r]);
                         if (found1 ) strcat(tmp1, " AND ");
                        strcat(cond_line,tmp1);
                            found1 = 1;
                         }
                         else
                          {
                        sprintf(tmp1,"n_name = '%s' ) ", AttrList[r]);
                        strcat(cond_line,tmp1);
                           }
                        _pdm_debug("global_where: cond_line: %s",cond_line);
                 }
                 else   if( Get_text(fp,mcf,r,SEARCH_COL)) {
                        j = j + 1  ;
       if( (len = strlen(cond_line) + strlen("n_name  =") +20 ) > alloc_size ) 
                {
                  alloc_size = len + 128 ;
                  cond_line = (char *)realloc(cond_line,alloc_size);
                }
                        tmp1[0] = '\0';
                        if( r < NumAttribs -1)
                         {
                         if (found1 == 1) found1 = 2; 
                        sprintf(tmp1,"n_name = '%s' ", AttrList[r]);
                         if (found1 ) strcat(tmp1, " AND ");
                        strcat(cond_line,tmp1);
                            found1 = 1;
                         }
                         else
                          {
                        sprintf(tmp1,"n_name = '%s' ) ", AttrList[r]);
                        strcat(cond_line,tmp1);
                           }
                }
        }
          if(found1 == 1) strcat(cond_line, " )");
        _pdm_debug("global where line : %s", cond_line);
           query_string = (char *)malloc( strlen(cond_line) + 128 );
           query_string[0] = '\0';
           sprintf(query_string,"SELECT n_tableno from nfmattributes %s", cond_line);
        }
        else
            {
   sprintf(query_string,"SELECT n_tableno from nfmtables where n_type = 'catalog'");
             
            }
           status = SQLquery(query_string, &catno_bufr, 512);
            if(status != SQL_S_SUCCESS)
              {
              _pdm_debug("No catalogs satify this condition : %s", cond_line);
               return(0);
               }
           status = MEMbuild_array(catno_bufr);
            if(status != MEM_S_SUCCESS)
               {
               MEMclose(&catno_bufr);
              _pdm_debug("No catalogs satify this condition : %s", cond_line);
               return(status);
               }
            catno = (char **) catno_bufr->data_ptr;
       if(query_string)    free(query_string);

       if(cond_line) free(cond_line);

       cond_line = (char *) malloc (catno_bufr->rows * 30 + 30);

            cond_line[0] = '\0';
            
             for(i = 0; i < catno_bufr->rows; i++)
              {
              if(i == 0)
              {
              strcpy(cond_line, "WHERE n_tableno in (");
              strcat(cond_line, catno[i]);
               if(catno_bufr->rows == 1) strcat(cond_line, " ) and n_tabletype ='catalog'");
              else strcat(cond_line, ",");
              }
              else if(i < (catno_bufr->rows -1))
              {
              strcat(cond_line, catno[i]);
              strcat(cond_line, ",");
               }
                else
                {
              strcat(cond_line, catno[i]);
              strcat(cond_line, ") and n_tabletype = 'catalog'");
                }
              }

       query_string = (char *) malloc (strlen(cond_line)  + 300);
           query_string[0] = '\0';
         sprintf(query_string,"SELECT n_tablename from nfmtables ");
            strcat(query_string, cond_line);
              
           status = SQLquery(query_string, cat_bufr, 512);
            if(status != SQL_S_SUCCESS)
              {
              _pdm_debug("No catalogs satify this condition : %s", cond_line);
               return(0);
               }
        _pdm_debug("End of gen_valid_list_of_catalogs", 0);
         free(query_string);
         free(cond_line);
        return(1);
}

add_bufr_to_global_buffer_for_union(MEMptr lcl_bufr)
{
        int status  ;

        _pdm_debug("In add_bufr_to_global_buffer_for_union:", 0 );

        if( lcl_bufr == NULL )
                return(0);

        if( PDUsearch_part_list == NULL )
             {
              PDUsearch_part_list = lcl_bufr;
              return(1);
              }
         else
             {
              status = MEMappend(lcl_bufr, PDUsearch_part_list);
              if(status != MEM_S_SUCCESS)
               {
                _pdm_debug("MEMappend failed status : %d",status );
                 return(status);
               }
              }
 
        if ( PDMdebug_on )
          MEMprint_buffers( "search list buffer..", PDUsearch_part_list, PDU_DEBUG_FILE );

        return(1);
}



do_incremental_search_with_union(Form fp1, int mcf, Form fp2,char ***table_names, 
			MEMptr data_bufr, char **AttrList, char **AttrSynonym, char **AttrTypes, int  NumAttribs, int *data_catalogs)
	
	/* Fetch parts with given criteria. Both for view and table */
{

	long sts, status  ;
	int  cat, col, tmpsts;
	char *query_string, *query_string1 ;
        char **cat_names = NULL;
        char **tab_names = NULL;
        MEMptr cat_bufr = NULL;
    
         _pdm_debug("Enter: do_incremental_search_with_union", 0);

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
           tab_names = (char **) malloc (sizeof(char *) * data_bufr->rows);
	   query_string = malloc(24);
	   strcpy(query_string, "  ");
	   _pdm_debug("Incremental search() query string: %s",query_string);

      /* gen_condition_line will return 0 if the operator is #>< and if no value is found closest to the given criteria */
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

       if(PDU_part_sort_string)
        query_string1 = (char *)malloc(strlen(query_string)+ strlen(PDU_part_sort_string ) + 100 );
       else 
        query_string1 = (char *)malloc(strlen(query_string)+ 100 );

	for( col = 0 ; col < data_bufr->rows; col++ ) {

         query_string1[0] = '\0';
         cat_bufr = NULL;
  sprintf(query_string1, "SELECT *  FROM %s %s ", cat_names[col], query_string); 
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

        tab_names[cat] = (char *) malloc (20);
        strcpy(tab_names[cat], cat_names[col]);
        cat++;

        _pdm_debug("calling add_bufr_to_global_buffer_for_union", 0);
        add_bufr_to_global_buffer_for_format (cat_names[col], cat_bufr);

         if(cat_bufr) MEMclose(&cat_bufr); 
        }



	if ( PDMdebug_on )
	MEMprint_buffers( "search list buffer..", PDUsearch_part_list, PDU_DEBUG_FILE );

        _pdm_debug("no. of rows retrieved: %d", (PDUsearch_part_list) -> rows );

        max_rows_rtvd = 0;
        row_num = max_rows_rtvd ;

        max_rows_rtvd  += (PDUsearch_part_list) -> rows ;

	*data_catalogs = cat-1;
        *table_names = tab_names;

        free(query_string);
        free(query_string1);

        set_table_field_for_union_or_format(fp2,table_names,SUB_TABLE,
                                            row_num,PDUsearch_part_list);

        PDUmessage(PDM_S_SUCCESS, 's');

         _pdm_debug("Exit: do_incremental_search_with_union", 0);
	return(1);
}
