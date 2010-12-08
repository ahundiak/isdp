/***************************************************************************/
/*                                                                         */
/*   This file contains routines for search of distinct list_format attributes   */
/*   across  catalogs                                                      */
/*                Date Created : 12/13/93       Kumar Narayanan            */
/*                                                                         */
/***************************************************************************/

#include "PDUerror.h"
#include "PDMmessage.h"
#include "PALpdmr.h"
#include "PALpdmrpro.h"


/*------------------------------------------------------------------ */
/*  External variables */
extern char  *s_text;
extern struct PDUrefresh *refresh ;
extern int	PDU_ComputedID          ;
/*------------------------------------------------------------------ */


/*------------------------------------------------------------------ */
/*  Globale variables */
char **AttrList 	 ;    	/* list_format attribute list     */
char **AttrSynonym 	 ;	/* synonyms of attributes   */
char **AttrTypes   	 ;      /* attribute types          */
int  NumAttribs          ;	/* No. of list_format attributes */

char  ViewOrTblList[2000][6];       /* view(PV) or table (PT) */
char  CatNameList[2000][TBL_LEN];  /* List of catalog names  */
int  NumCatalogs , TblNos[2000];  /* no. of catalogs and corresponding 
                                            table numbers */
char 	**AttrValsRep_PPart;
/*------------------------------------------------------------------ */

search_list_format_attribs(Form fp, char *format_name, MEMptr out_buffr)

	/***  
	    This routine gets the  list of distinct attributes for a given
            report format stored in the psurptopt and psurptlist tables
        ***/
{
	int i;
        char **catlist = NULL;

	/* PDUmessage (PDS_M_GET_LIST_ATTR, 's'); */
	PDUmessage (PDS_M_GET_UNION_ATTR, 's');

	/* Get the distinct attributes of report format  */
	if( ! SearchListAttribsAcrossCatalogs(format_name) ){

        _pdm_debug("SearchListAttribsAcrossCatalogs failed status", 0);
		NumCatalogs = 0 ;
		FreeArrayPtr (AttrList,NumAttribs );
		PDUmessage(PDM_E_CLEAR_FIELD, 's' );	
		return(0);

            }
	catlist = (char **)malloc(2000 * sizeof(char *));

	for( i = 0 ; i < 2000 ; ++i )
		catlist[i] = (char *)malloc(TBL_LEN);
	
	if( ! PALgetcatlist_for_format_attributes (fp, out_buffr, &NumCatalogs, catlist,1 ))
	{
		PDUmessage(PDM_E_CLEAR_FIELD, 's' );
		return(0);
	}

	for( i = 0 ; i < NumCatalogs ; ++i )
		strcpy(CatNameList[i], catlist[i]);

	FreeArrayPtr(catlist,2000);

	if( NumAttribs != 0 ){
		FreeArrayPtr(AttrList,NumAttribs);
		FreeArrayPtr(AttrSynonym,NumAttribs);
		FreeArrayPtr(AttrTypes,NumAttribs);
		NumAttribs = 0;
	}

	PDUmessage(PDM_E_CLEAR_FIELD, 's' );
        _pdm_debug("Exit: Search_list_format_attribs", 0);
	return(1);
}

/*  --------------------  SearchListAttribsAcrossCatalogs()  ------------------ */

SearchListAttribsAcrossCatalogs(char *format_name)
	
	/* Having got list of catalogs prepares list of list_format attributes */
{

	int  num_attrs;

	NumAttribs = 0 ;

	/* Get attribute list of first table */
	if( ! GetReportFormatAttribs(format_name,&AttrList,&AttrSynonym,&AttrTypes,&num_attrs))
            {
              _pdm_debug("GetReportFormatAttribs failed status ", 0);
		return(0);
             }
	NumAttribs = num_attrs ;
        _pdm_debug("Exit: SearchListAttribsAcrossCatalogs", 0);
	return(1);
}



GetReportFormatAttribs(char *format_name, char ***list_of_attr, 
                      char ***attr_desc, char ***attr_type, int *no_of_attrs)
{
	int  i, j, max_rows , max_rows1 = 0, sts , err_code ;
	char query[512],  *ptr, *ptr1, *output, *output1, **tmp_data ;
        MEMptr tmp_bufr = NULL;
        long status ;



     sprintf(query,"SELECT p_templateno FROM psurptopts where p_templatename = '%s' \n",format_name);
         status = SQLquery(query,&tmp_bufr,512);
           if(status != SQL_S_SUCCESS)
             {
              _pdm_debug("TEMPLATE has no info", 0);
               return(status);
             }
            status = MEMbuild_array(tmp_bufr);
            if(status != MEM_S_SUCCESS)
             {
              _pdm_debug("TEMPLATE has no info", 0);
               return(status);
             }
             tmp_data  = (char**) tmp_bufr->data_ptr;

	/* Get list of attributes for the template */
      sprintf(query,"select DISTINCT p_name, p_header from psurptlist where p_templateno  = %s", tmp_data[0]);

        _pdm_debug("query: %s", query);

	sts = RISquery(query,&max_rows, &output,&err_code);

	_pdm_debug("Get attributes query status = %d", (char *)&sts );	

	_pdm_debug("Get attributes output = %s", output );	

	if( sts < 0 ) {
		free(output);
		RIS_box(err_code);
		return(0);
	}

(*list_of_attr) = (char **)malloc((max_rows + max_rows1)*sizeof(char *));
(*attr_desc)    = (char **)malloc((max_rows + max_rows1) *sizeof(char *));
(*attr_type)    = (char **)malloc((max_rows + max_rows1) *sizeof(char *));

	ptr = strtok(output,"~");

        j = 0;
	for( i = 0 ; (ptr != NULL) && (i < max_rows) ; i = i + 1 ) {
                sprintf(query,"SELECT n_datatype from nfmattributes where n_name = '%s'", ptr);
         sts = RISquery(query,&max_rows1, &output1,&err_code);
        _pdm_debug("Get attributes query status = %d", (char *)&sts );
        _pdm_debug("Get attributes output = %s", output );
        if( sts < 0 ) {
                free(output1);
		ptr = strtok(NULL,"~");
                continue;
        }
		(*list_of_attr)[j] = (char *)malloc(strlen(ptr)+1 );
		if( (*list_of_attr)[j] == NULL )
			break;
		strcpy((*list_of_attr)[j],ptr);

		ptr = strtok(NULL,"~");

		if (ptr == NULL ) {
			_pdm_debug("ptr is null ???", 0 );
			break;
		}


		(*attr_desc)[j] = (char *)malloc(strlen(ptr)+1 );
		if( (*attr_desc)[j] == NULL )
			break;
		strcpy((*attr_desc)[j],ptr);

	         ptr1 = strtok(output1,"~");
                 if(ptr1 == NULL)
                  {
		(*attr_type)[j] = (char *)malloc(strlen(output1)+1 );
		if( (*attr_type)[j] == NULL )
			break;
		strcpy((*attr_type)[j],output1);
                  }
                  else
                    {
		(*attr_type)[j] = (char *)malloc(strlen(ptr1)+1 );
		if( (*attr_type)[j] == NULL )
			break;
		strcpy((*attr_type)[j],ptr1);
                    }
                 if(output1) free(output1); output1 = NULL;
                j++;
	}

	*no_of_attrs = j ;
	free(output);
	free(query);

     _pdm_debug("Exit Getcatattribs_for_list_format",0);
	return(1);
}

PALgetcatlist_for_format_attributes(Form fp,  int *numcat, char **catlist,int flag )
{
        int  i, j   ;
        char **data_ptr, *ptr  ;
        MEMptr out_bufr = NULL;
        char *msg;

        *numcat = 0 ;

        data_ptr = (char **)out_bufr -> data_ptr ;

        for ( i = 0 ; i < out_bufr -> rows ; i = i + 1 ){

                ptr = data_ptr [i*out_bufr -> columns + 4] ;
                if( !strcmp( ptr,"C") ){

                        ptr = data_ptr [i*out_bufr -> columns + 1] ;
                        if( !ptr || strlen(ptr) < 1 )
                                ptr = data_ptr [i*out_bufr -> columns + 2] ;

                        strcpy(catlist[*numcat],ptr);
          (*numcat) ++;

                        if( flag && ((*numcat) == MAX_CATALOGS) )
                                break;

                        _pdm_debug("catalog in SAC: %s", catlist[(*numcat)-1] );
                }
        }


        if( *numcat < 1 ){
                msg = (char *)PDUtranslate_message(PDM_E_CATALOG_NOT_FOUND);
                FIfld_set_text(fp,FI_MSG_FIELD,0,0,msg,FALSE);
                return(0) ;
        }

        if( ! flag )
                return(1);

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
