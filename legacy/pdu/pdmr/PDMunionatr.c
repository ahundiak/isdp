/***************************************************************************/
/*                                                                         */
/*   This file contains routines for search of distinct union attributes   */
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
char **AttrList 	 ;    	/* union attribute list     */
char **AttrSynonym 	 ;	/* synonyms of attributes   */
char **AttrTypes   	 ;      /* attribute types          */
int  NumAttribs          ;	/* No. of union attributes */

char  ViewOrTblList[2000][6];       /* view(PV) or table (PT) */
char  CatNameList[2000][TBL_LEN];  /* List of catalog names  */
int  NumCatalogs , TblNos[2000];  /* no. of catalogs and corresponding 
                                            table numbers */
char 	**AttrValsRep_PPart;
/*------------------------------------------------------------------ */

search_union_attribs(Form fp , MEMptr out_buffr)

	/***  
	    This routine gets the list of catalogs under current classification
            level , and the list of distinct attributes union to these catalogs
        ***/
{
	int i;

	char **catlist;

        _pdm_debug("in the function search_union_attribs", 0);

	PDUmessage (PDS_M_GET_UNION_ATTR, 's');

	catlist = (char **)malloc(2000 * sizeof(char *));

	for( i = 0 ; i < 2000 ; ++i )
		catlist[i] = (char *)malloc(TBL_LEN);
	
        _pdm_debug("calling PALgetcatlist", 0);
	if( ! PALgetcatlist (fp, out_buffr, &NumCatalogs, catlist,1 ))
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

	/* Having gotten table nos, get the distinct attributes union to them */
        _pdm_debug("calling SearchUnionAttribsAcrossCatalogs", 0);
	if( ! SearchUnionAttribsAcrossCatalogs() ){

        _pdm_debug("SearchUnionAttribsAcrossCatalogs failed status", 0);
		NumCatalogs = 0 ;
		FreeArrayPtr (AttrList,NumAttribs );
		PDUmessage(PDM_E_CLEAR_FIELD, 's' );	
		return(0);
	}
	PDUmessage(PDM_E_CLEAR_FIELD, 's' );
        _pdm_debug("Exit: Search_union_attribs", 0);
	return(1);
}

/*  --------------------  SearchUnionAttribsAcrossCatalogs()  ------------------ */

SearchUnionAttribsAcrossCatalogs()
	
	/* Having got list of catalogs prepares list of union attributes */
{

	int  i, j,sts, err_code , max_tablenos , num_attrs;
	char query[138] , *output , where[1024], *qry, tmp[200]  ;

        _pdm_debug("in the function SearchUnionAttribsAcrossCatalogs", 0);

	NumAttribs = 0 ;

	/* Get attribute list of first table */
        _pdm_debug("calling GetUnionCatAttribs", 0);
	if( ! GetUnionCatAttribs(&AttrList,&AttrSynonym,&AttrTypes,&num_attrs))
            {
              _pdm_debug("GetUnionCatAttribs failed status ", 0);
		return(0);
             }
	NumAttribs = num_attrs ;
        _pdm_debug("Exit: SearchUnionAttribsAcrossCatalogs", 0);
	return(1);
}



GetUnionCatAttribs(char ***list_of_attr, char ***attr_desc,
 char ***attr_type, int *no_of_attrs)
{
	int  i, j, k, max_rows , max_rows1 = 0, sts , err_code ;
	char *query = NULL, *query1 = NULL, *ptr, *output, *output1 ;
        char *where, tmp[200];

        _pdm_debug("in the function GetUnionCatAttribs", 0);

        query = (char *) malloc (512 + (NumCatalogs * 50));
        where = (char *) malloc ((NumCatalogs * 50));
        tmp[0] = '\0';

	/* Get list of attributes of one catalog first */
       strcpy(query,"select DISTINCT n_name, n_synonym, n_datatype, n_seqno from nfmattributes where n_tableno in ");

        _pdm_debug("query: %s", query);
        /* Build where clause for n_tableno first */
        strcpy(where, " ( ");


        for( i = 0 ; i < NumCatalogs ; i = i + 1 ) {

                if( i < NumCatalogs -1 )
                   {
                sprintf(tmp,"%d, ",TblNos[i]);
                strcat(where,tmp);
                   }
                else
                  {
                sprintf(tmp,"%d )",TblNos[i]);
                strcat(where,tmp);
                   }

        }


        _pdm_debug( " where: %s", where );
        query1 = (char *) malloc (strlen (query) + strlen(where) + 100);

        strcpy(query1,query);
         strcat(query1, where);

    strcat(where," and n_read='Y' and n_name like 'n_%' order by n_seqno ");
        strcat(query, where);


 strcat(query1," and n_read='Y' and n_name not like 'n_%' order by n_synonym ");
       
        

	max_rows = 0 ;
	sts = RISquery(query,&max_rows, &output,&err_code);

	_pdm_debug("Get attributes query status = %d", (char *)&sts );	

	_pdm_debug("Get attributes output = %s", output );	

	if( sts < 0 ) {
		free(output);
		RIS_box(err_code);
		return(0);
	}

	max_rows1 = 0 ;
	sts = RISquery(query1,&max_rows1, &output1,&err_code);

	_pdm_debug("Get attributes query status = %d", (char *)&sts );	

	_pdm_debug("Get attributes output = %s", output );	

	if( sts < 0 ) {
		free(output);
		RIS_box(err_code);
		return(0);
	}

(*list_of_attr) = (char **)malloc((max_rows + max_rows1 +2)*sizeof(char *));
(*attr_desc)    = (char **)malloc((max_rows + max_rows1 +2) *sizeof(char *));
(*attr_type)    = (char **)malloc((max_rows + max_rows1 +2) *sizeof(char *));

	_pdm_debug("max_rows + max_rows1 +2 = %d", (char *)(max_rows+max_rows1+2) );	

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

		ptr = strtok(NULL,"~");
		ptr = strtok(NULL,"~");
	}

	free(output);
	*no_of_attrs = i ;

        ptr = (char *) NULL;

	ptr = strtok(output1,"~");

     for( j = i , k = 0; (ptr != NULL) && (k < max_rows1) ; k = k + 1 , j++) {

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

		ptr = strtok(NULL,"~");

		if (ptr == NULL ) {
			_pdm_debug("ptr is null ???", 0 );
			break;
		}


		(*attr_type)[j] = (char *)malloc(strlen(ptr)+1 );
		if( (*attr_type)[j] == NULL )
			break;
		strcpy((*attr_type)[j],ptr);

		ptr = strtok(NULL,"~");
		ptr = strtok(NULL,"~");
	}

	free(output1);
	free(query);
	free(query1);
	free(where);

     _pdm_debug("No of attrs 1 %d", (char *)*no_of_attrs);
     _pdm_debug("No of attrs i %d", (char *)j);
	*no_of_attrs = (k + *no_of_attrs);

     _pdm_debug("No of attrs %d", (char *)*no_of_attrs);
	for( i = 0 ; (i < *no_of_attrs) ; i = i + 1 ) {
            _pdm_debug("Attribute %s", (*list_of_attr)[i]);
             }
     _pdm_debug("Exit Getcatattribs_for_union",0);
	return(1);
}


/*

GetUnionCatAttribs_mem(char ***list_of_attr, char ***attr_desc,
 char ***attr_type, int *no_of_attrs)
{
	int  i, j, max_rows , max_rows1 = 0, sts , err_code ;
	char *query = NULL, *query1 = NULL, *ptr, *output, *output1 ;
        char *where, tmp[200];
        MEMptr attr_bufr = NULL, attr_bufr1 = NULL;


        query = (char *) malloc (512 + (NumCatalogs * 50));
        where = (char *) malloc ((NumCatalogs * 50));
        tmp[0] = '\0';

       strcpy(query,"select DISTINCT n_name, n_synonym, n_datatype, n_seqno from nfmattributes where n_tableno in ");

        _pdm_debug("query: %s", query);
        strcpy(where, " ( ");


        for( i = 0 ; i < NumCatalogs ; i = i + 1 ) {

                if( i < NumCatalogs -1 )
                   {
                sprintf(tmp,"%d, ",TblNos[i]);
                strcat(where,tmp);
                   }
                else
                  {
                sprintf(tmp,"%d )",TblNos[i]);
                strcat(where,tmp);
                   }

        }


        _pdm_debug( " where: %s", where );
        query1 = (char *) malloc (strlen (query) + strlen(where) + 100);

        strcpy(query1,query);
         strcat(query1, where);

    strcat(where," and n_read='Y' and n_name like 'n_%' order by n_seqno ");
        strcat(query, where);


 strcat(query1," and n_read='Y' and n_name not like 'n_%' order by n_synonym ");
       
	sts = SQLquery(query, &attr_bufr,512);
	if( sts != SQL_S_SUCCESS ) {
                _pdm_debug("SQLquery failed status ", 0);
		return(0);
	}

	sts = SQLquery(query1,&attr_bufr1,512);
	if( sts != SQL_S_SUCCESS ) {
                _pdm_debug("SQLquery 2failed status ", 0);
		return(0);
	}

        sts = MEMbuild_array(attr_bufr);
        if(sts != MEM_S_SUCCESS)
          {
                _pdm_debug("MEMbuild_array failed status ", 0);
		return(0);
          } 

        sts = MEMbuild_array(attr_bufr1);
        if(sts != MEM_S_SUCCESS)
          {
                _pdm_debug("MEMbuild_array 2 failed status ", 0);
		return(0);
          } 

(*list_of_attr) = (char **)malloc((attr_bufr->rows + attr_bufr1->rows +2)*sizeof(char *));
(*attr_desc)    = (char **)malloc((attr_bufr->rows + attr_bufr1->rows +2) *sizeof(char *));
(*attr_type)    = (char **)malloc((attr_bufr->rows + attr_bufr1->rows +2) *sizeof(char *));

	ptr =  (char **) attr_bufr->data_ptr;
	ptr1 =  (char **) attr_bufr1->data_ptr;

	for( i = 0 ; (ptr != NULL) && (i < max_rows) ; i = i + 1 ) {

                 nxi = i * attr_bufr->columns;

		(*list_of_attr)[i] = (char *)malloc(strlen(ptr[nxi])+1 );
		if( (*list_of_attr)[i] == NULL )
			break;

		strcpy((*list_of_attr)[i],ptr[nxi]);

		(*attr_desc)[i] = (char *)malloc(strlen(ptr[nxi+1])+1 );
		if( (*attr_desc)[i] == NULL )
			break;
		strcpy((*attr_desc)[i],ptr[nxi+1]);
		(*attr_type)[i] = (char *)malloc(strlen(ptr[nxi+2])+1 );
		if( (*attr_type)[i] == NULL )
			break;
		strcpy((*attr_type)[i],ptr[nxi+2]);
	}

	*no_of_attrs = attr_bufr->rows + attr_bufr1->rows ;

      for( j = i, k=0 ; (ptr1 != NULL) && (j < attr_bufr1->rows) ; j = j + 1 ) {
               nxj = j * attr_bufr1->columns;
	       (*list_of_attr)[j] = (char *)malloc(strlen(ptr1[nxj])+1 );
		if( (*list_of_attr)[j] == NULL )
			break;

		strcpy((*list_of_attr)[j],ptr1[nxj]);
		(*attr_desc)[j] = (char *)malloc(strlen(ptr[nxj+1])+1 );
		if( (*attr_desc)[j] == NULL )
			break;
		strcpy((*attr_desc)[j],ptr[nxj+1]);
		(*attr_type)[j] = (char *)malloc(strlen(ptr)+1 );
		if( (*attr_type)[j] == NULL )
			break;
		strcpy((*attr_type)[j],ptr);

		ptr = strtok(NULL,"~");
		ptr = strtok(NULL,"~");
	}

	free(output1);
	free(query);
	free(query1);
	free(where);

     _pdm_debug("No of attrs 1 %d", (char *)*no_of_attrs);
     _pdm_debug("No of attrs i %d", (char *)j);
	*no_of_attrs = (j + *no_of_attrs);

     _pdm_debug("No of attrs %d", (char *)*no_of_attrs);
	for( i = 0 ; (i < *no_of_attrs) ; i = i + 1 ) {
            _pdm_debug("Attribute %s", (*list_of_attr)[i]);
             }
     _pdm_debug("Exit Getcatattribs_for_union",0);
	return(1);
}

*/

