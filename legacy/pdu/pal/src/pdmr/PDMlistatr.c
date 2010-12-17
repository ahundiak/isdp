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
/* 18/may/94 - raj. Re-definition of this variable. Commented out.
char 	**AttrValsRep_PPart;
*/
/*------------------------------------------------------------------ */

search_list_format_attribs(Form fp, char *format_name, MEMptr out_buffr)

	/***  
	    This routine gets the  list of distinct attributes for a given
            report format stored in the psurptopt and psurptlist tables
        ***/
{
	int i;
        char **catlist = NULL;
        int  status = PDM_S_SUCCESS;

	/* PDUmessage (PDS_M_GET_LIST_ATTR, 's'); */
	PDUmessage (PDS_M_GET_UNION_ATTR, 's');
if( IGEresetstop ()) {
        _pdm_debug("IGEstop for with union Attrib enabled %d", 0);
                 IGEresetstop();
                }


	/* Get the distinct attributes of report format  */
	status = SearchListAttribsAcrossCatalogs(format_name);
        _pdm_status("SearchListAttribsAcrossCatalogs", status);
        if (status != PDM_S_SUCCESS)
          {
          _pdm_debug("SearchListAttribsAcrossCatalogs failed status", 0);
	  NumCatalogs = 0 ;
	  FreeArrayPtr (AttrList,NumAttribs );
          PDUmessage(status, 's');
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

        /*
	FreeArrayPtr(catlist,2000);

	if( NumAttribs != 0 ){
		FreeArrayPtr(AttrList,NumAttribs);
		FreeArrayPtr(AttrSynonym,NumAttribs);
		FreeArrayPtr(AttrTypes,NumAttribs);
		NumAttribs = 0;
	}
        */

	PDUmessage(PDM_E_CLEAR_FIELD, 's' );
        _pdm_debug("Exit: Search_list_format_attribs", 0);
	return(1);
}

/*  --------------------  SearchListAttribsAcrossCatalogs()  ------------------ */

SearchListAttribsAcrossCatalogs(char *format_name)
	
	/* Having got list of catalogs prepares list of list_format attributes */
{

	int  num_attrs, i = 0;
        short found = FALSE;
        int status = PDM_S_SUCCESS;

	NumAttribs = 0 ;

	/* Get attribute list of first table */
	status = GetReportFormatAttribs(format_name,&AttrList,&AttrSynonym,&AttrTypes,&num_attrs);
        if (status != PDM_S_SUCCESS)
            {
              _pdm_debug("GetReportFormatAttribs failed status ", 0);
		return(status);
             }
	NumAttribs = num_attrs ;

        /*  MJG - check AttrSynonym for nil values */
        for (i = 0; i < num_attrs; ++i)
           if (strcmp(AttrSynonym[i], "nil") == 0)
             strcpy(AttrSynonym[i], NULL_STRING);

        _pdm_debug("num_attrs = %d", (char *)num_attrs);
        if (num_attrs > 0)
          {
          _pdm_debug("checking attr_list for n_itemname", 0);
          for (i = 0; i < num_attrs; ++i)
             {
             _pdm_debug("AttrList[i] = <%s>", AttrList[i]);
             if ((AttrList[i]) && (strcmp(AttrList[i], "n_itemname") == 0))
               {
               found = TRUE;
               break;
               }
             }
          if (!found)
            {
            _pdm_debug("attribute n_itemname not found", 0);
            PDUmessage(PDM_E_ITEMNAME_REQUIRED, 's');
            return(PDM_E_ITEMNAME_REQUIRED);
            }

          _pdm_debug("checking attr_list for n_itemrev", 0);
          found = FALSE;
          for (i = 0; i < num_attrs; ++i)
             {
             _pdm_debug("AttrList[i] = <%s>", AttrList[i]);
             if ((AttrList[i]) && (strcmp(AttrList[i], "n_itemrev") == 0))
               {
               found = TRUE;
               break;
               }
             }
          if (!found)
            {
            _pdm_debug("attribute n_itemrev not found", 0);
            PDUmessage(PDM_E_ITEMREV_REQUIRED, 's');
            return(PDM_E_ITEMREV_REQUIRED);
            }
          }
        _pdm_debug("Exit: SearchListAttribsAcrossCatalogs", 0);
	return(PDM_S_SUCCESS);
}



GetReportFormatAttribs(char *format_name, char ***list_of_attr1, 
                   char ***attr_desc1, char ***attr_type1, int *no_of_attrs)
{
        int  i, j, max_rows , max_rows1 = 0, sts , err_code ;
	char query[512],  *ptr = NULL,  *output = NULL, **tmp_data  = NULL;
        MEMptr tmp_bufr = NULL;
        MEMptr output1 = NULL;
        long status ;
        char **list_of_attr = NULL, **attr_desc = NULL, **attr_type = NULL;
        char **datatype = NULL, *tmp_out = NULL, *tmp_out1 = NULL;

    /*
    if( IGEresetstop ()) 
        _pdm_debug("IGEresetstop for with union Attrib enabled %d", 0);
    */
                        

/* 2/25/94 MJG - added templatetype to query for TR 139417605 */
     sprintf(query,"SELECT p_templateno FROM psurptopts where (p_templatename = '%s' AND p_templatetype = 'C')\n",format_name);
         status = SQLquery(query,&tmp_bufr,512);
           if(status != SQL_S_SUCCESS)
             {
              _pdm_debug("TEMPLATE has no info", 0);
                if(tmp_bufr) MEMclose(&tmp_bufr);
               return(status);
             }
            if( IGEstop ()) {
        _pdm_debug("IGEstop for with union Attrib enabled %d", 0);
                 IGEresetstop();
                if(tmp_bufr) MEMclose(&tmp_bufr);
                return(0);
                }

            status = MEMbuild_array(tmp_bufr);
            if(status != MEM_S_SUCCESS)
             {
              status = PDM_E_EMPTY_SEARCH_FORMAT;
              PDUmessage(status, 's');
              _pdm_debug("TEMPLATE has no info", 0);
                if(tmp_bufr) MEMclose(&tmp_bufr);
               return(status);
             }
             tmp_data  = (char**) tmp_bufr->data_ptr;

         max_rows = 0;
         output = NULL;

	/* Get list of attributes for the template */
      sprintf(query,"select DISTINCT p_name, p_header, p_start from psurptlist where p_templateno  = %s order by p_start", tmp_data[0]);

        _pdm_debug("query: %s", query);

	sts = RISquery(query,&max_rows, &output,&err_code);

        tmp_out = (char *) output;

	_pdm_debug("Get attributes query status = %d", (char *)&sts );	

	_pdm_debug("Get attributes output = %s", output );	

	if( sts < 0 ) {
                status = PDM_E_EMPTY_SEARCH_FORMAT;
                PDUmessage(status, 's');
		if(output) free(output);
		RIS_box(err_code);
		return(0);
	}

(list_of_attr) = (char **)malloc((max_rows + max_rows1)*sizeof(char *));
(attr_desc)    = (char **)malloc((max_rows + max_rows1) *sizeof(char *));
(attr_type)    = (char **)malloc((max_rows + max_rows1) *sizeof(char *));

	ptr = strtok(output,"~");

        j = 0;
	for( i = 0 ; (ptr != NULL) && (i < max_rows) ; i = i + 1 ) {
                
                     if( IGEstop ())
                       {
                        free(list_of_attr); *list_of_attr1 = NULL;
                        free(attr_desc);    *attr_desc1 = NULL;
                        free(attr_type);    *attr_type1 = NULL;
                      _pdm_debug("IGEstop for with union Attrib enabled %d", 0);
                          IGEresetstop();
		          if(output) free(output);
	                 *no_of_attrs = 0;
                         _pdm_debug("Exit Getcatattribs_for_list_format",0);
	                   return(0);
                        }
                sprintf(query,"SELECT max(n_datatype) from nfmattributes where n_name = '%s'", ptr);
        _pdm_debug("Query = %s", (char *)query );
         sts = SQLquery(query, &output1, 512);
        _pdm_debug("Get attributes query status = %d", sts );
        if( sts != SQL_S_SUCCESS ) {
                if (output1) MEMclose(&output1);
		ptr = strtok(NULL,"~");
		if (ptr == NULL ) {
			_pdm_debug("ptr is null ???", 0 );
		ptr = strtok(NULL,"~");
		if (ptr == NULL ) {
			_pdm_debug("ptr is null ???", 0 );
                         break;
                         }
                      continue;
		}
		attr_desc[j] = (char *)malloc(strlen(ptr)+1 );
		if( attr_desc[j] == NULL )
			break;
		attr_type[j] = (char *)malloc(2);
		strcpy(attr_type[j],"");
		ptr = strtok(NULL,"~");
		ptr = strtok(NULL,"~");
                continue;
        }
		list_of_attr[j] = (char *)malloc(strlen(ptr)+1 );
		if( list_of_attr[j] == NULL )
			break;
		strcpy(list_of_attr[j],ptr);

		ptr = strtok(NULL,"~");

		if (ptr == NULL ) {
			_pdm_debug("ptr is null ???", 0 );
			break;
		}


		attr_desc[j] = (char *)malloc(strlen(ptr)+1 );
		if( attr_desc[j] == NULL )
			break;
		strcpy(attr_desc[j],ptr);
                 if(output1) MEMbuild_array(output1);
                 if((output1 == NULL) || (output1->rows == 0))
                  {
		attr_type[j] = (char *)malloc(2);
		if( attr_type[j] == NULL )
			break;
		strcpy(attr_type[j],"");
                  }
                  else
                    {
                    datatype = (char **) output1->data_ptr;
	attr_type[j] = (char *)malloc(strlen((char *) datatype[0]) +1 );
		strcpy(attr_type[j],"" );
		if( attr_type[j] == NULL )
			break;
		strcpy(attr_type[j],(char *) datatype[0]);
                    }
                     if(output1) MEMclose(&output1);
                      output1 = NULL;
		ptr = strtok(NULL,"~");
		ptr = strtok(NULL,"~");
                j++;
	}

         *list_of_attr1 =  list_of_attr; 
         *attr_desc1 = attr_desc; 
         *attr_type1 = attr_type;

	*no_of_attrs = j ;
        if (*no_of_attrs == 0)
          {
          status = PDM_E_EMPTY_SEARCH_FORMAT;
          PDUmessage(status, 's');
          return(status);
          }

	 output = NULL;

     _pdm_debug("Exit GetReportFormatAttribs",0);
	return(PDM_S_SUCCESS);
}

PALgetcatlist_for_format_attributes(Form fp,  MEMptr out_bufr, int *numcat, char **catlist,int flag )
{
        int  i, j   ;
        char **data_ptr = NULL, *ptr = NULL ;
        char *msg = NULL;

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
