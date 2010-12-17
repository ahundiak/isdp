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
/* 18/may/94 - raj. Re-definition of this variable. Commented out.
char 	**AttrValsRep_PPart;
*/
/*------------------------------------------------------------------ */

search_union_attribs(Form fp , MEMptr out_buffr)

	/***  
	    This routine gets the list of catalogs under current classification
            level , and the list of distinct attributes union to these catalogs
        ***/
{
	int i;

	char **catlist = NULL;

        _pdm_debug("in the function search_union_attribs", 0);

	PDUmessage (PDS_M_GET_UNION_ATTR, 's');

         if(IGEresetstop())
            {
        _pdm_debug("IGEreset stop for with union Attrib failed %d", 0);
         IGEresetstop();
             }
	catlist = (char **)malloc(2000 * sizeof(char *));

	for( i = 0 ; i < 2000 ; ++i )
		catlist[i] = (char *)malloc(TBL_LEN);
	
        _pdm_debug("calling PALgetcatlist", 0);
	if( ! PALgetcatlist (fp, out_buffr, &NumCatalogs, catlist,1 ))
	{
		PDUmessage(PDM_E_CLEAR_FIELD, 's' );
		return(0);
	}
        if( IGEstop ()) {
        _pdm_debug("IGEstop for with union Attrib enabled %d", 0);
                 IGEresetstop();
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

	int  i, num_attrs;

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

        /*  MJG - check AttrSynonym for nil values */
        for (i = 0; i < num_attrs; ++i)
           if (strcmp(AttrSynonym[i], "nil") == 0)
             strcpy(AttrSynonym[i], NULL_STRING);
            
        _pdm_debug("Exit: SearchUnionAttribsAcrossCatalogs", 0);
	return(1);
}



GetUnionCatAttribs(char ***list_of_attr1, char ***attr_desc1,
 char ***attr_type1, int *no_of_attrs)
{
     int  i, j, k, m, found_dup = 0, max_rows , max_rows1 = 0, sts , err_code ;
     char *query = NULL, *query1 = NULL, *ptr = NULL, *output = NULL, *output1 = NULL ;
     char *where = NULL, tmp[200];
     char **list_of_attr = NULL, **attr_desc = NULL, **attr_type = NULL;

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
		if(output) free(output);
		RIS_box(err_code);
		return(0);
	}

if( IGEstop ()) {
        _pdm_debug("IGEstop for with union Attrib enabled %d", 0);
                 IGEresetstop();
		if(output) free(output);
		return(0);
                }

	max_rows1 = 0 ;
	sts = RISquery(query1,&max_rows1, &output1,&err_code);

	_pdm_debug("Get attributes query status = %d", (char *)&sts );	

	_pdm_debug("Get attributes output = %s", output );	

	if( sts < 0 ) {
		if(output1) free(output1);
		RIS_box(err_code);
		return(0);
	}

if( IGEstop ()) {
        _pdm_debug("IGEstop for with union Attrib enabled %d", 0);
                 IGEresetstop();
		if(output1) free(output1);
		return(0);
                }
list_of_attr = (char **)malloc((max_rows + max_rows1 +2)*sizeof(char *));
attr_desc    = (char **)malloc((max_rows + max_rows1 +2) *sizeof(char *));
attr_type    = (char **)malloc((max_rows + max_rows1 +2) *sizeof(char *));


	_pdm_debug("max_rows + max_rows1 +2 = %d", (char *)(max_rows+max_rows1+2) );	

	ptr = strtok(output,"~");

	for( i = 0, k = 0 ; (ptr != NULL) && (i < max_rows) ; i = i + 1 ) {

            /* filter the attributes if needed */
             found_dup = 0;
             for(m = 0; m < k; m++)
               {
                 if(!strcmp(list_of_attr[m], ptr))
                  {
                    /* Found a duplicate, grab the max dataype */
                    /* Skip the desciption */
		    ptr = strtok(NULL,"~");
		    if(ptr == NULL) 
                     {
                      found_dup = 1;
                      break;
                      }
		    ptr = strtok(NULL,"~");
		    if(ptr == NULL) 
                     {
                      found_dup = 1;
                      break;
                      }
		    if(!strncmp(attr_type[m],"char",4))
                      {
                       if(atoi(attr_type[m]) < atoi(ptr))
                         {
                  attr_type[m] = (char *)realloc(attr_type[m], strlen(ptr)+1 );
                         strcpy(attr_type[m], ptr);
		         ptr = strtok(NULL,"~");
		         ptr = strtok(NULL,"~");
                         found_dup = 1; 
                        break;
                          }
                      }
		         ptr = strtok(NULL,"~");
		    if(ptr == NULL) 
                     {
                      found_dup = 1;
                      break;
                     }
		         ptr = strtok(NULL,"~");
		    if(ptr == NULL) 
                     {
                      found_dup = 1;
                      break;
                     }
                      found_dup = 1;
                      break;
                  }
               }
           if (found_dup) 
                {
                 continue;
                 }
		list_of_attr[k] = (char *)malloc(strlen(ptr)+1 );
		if( list_of_attr[k] == NULL )
			break;

		strcpy(list_of_attr[k],ptr);

                _pdm_debug("Attribute %s",list_of_attr[k]);
		ptr = strtok(NULL,"~");

		if (ptr == NULL ) {
			_pdm_debug("ptr is null ???", 0 );
			break;
		}


		attr_desc[k] = (char *)malloc(strlen(ptr)+1 );
		if( attr_desc[k] == NULL )
			break;
		strcpy(attr_desc[k],ptr);
                _pdm_debug("Attribute synonym %s",attr_desc[k]);

		ptr = strtok(NULL,"~");

		if (ptr == NULL ) {
			_pdm_debug("ptr is null ???", 0 );
			break;
		}


		attr_type[k] = (char *)malloc(strlen(ptr)+1 );
		if( attr_type[k] == NULL )
			break;
		strcpy(attr_type[k],ptr);
                _pdm_debug("Attribute type %s",attr_type[k]);
		ptr = strtok(NULL,"~");
		ptr = strtok(NULL,"~");
             k++;
	}
          i = k;

_pdm_debug("no_of_system_attrs %d", i );	
	if(output) free(output);
	*no_of_attrs = i ;

        ptr = (char *) NULL;

	ptr = strtok(output1,"~");

     for( j = i , k = 0; (ptr != NULL) && (k < max_rows1) ; k ++ ) {

            /* filter the attributes if needed */
             found_dup = 0;
             /* for(m = i; m < (k+i); m++) */
             for(m = i; m < j ; m++)
               {
                 if(!strcmp(list_of_attr[m], ptr))
                  {
                    /* Found a duplicate, grab the max dataype */
                    /* Skip the desciption */
		    ptr = strtok(NULL,"~");
		    if(ptr == NULL) 
                     {
                      found_dup = 1;
                      break;
                      }
		    ptr = strtok(NULL,"~");
		    if(ptr == NULL) 
                     {
                      found_dup = 1;
                      break;
                      }
		    if(!strncmp(attr_type[m],"char",4))
                      {
                       if(atoi(attr_type[m]) < atoi(ptr))
                         {
                  attr_type[m] = (char *)realloc(attr_type[m], strlen(ptr)+1 );
                         strcpy(attr_type[m], ptr);
		         ptr = strtok(NULL,"~");
		         ptr = strtok(NULL,"~");
                         found_dup = 1; 
                        break;
                          }
                      }
		         ptr = strtok(NULL,"~");
		    if(ptr == NULL) 
                     {
                      found_dup = 1;
                      break;
                     }
		         ptr = strtok(NULL,"~");
		    if(ptr == NULL) 
                     {
                      found_dup = 1;
                      break;
                     }
                      found_dup = 1;
                      break;
                  }
               }
               if(found_dup) continue;

		list_of_attr[j] = (char *)malloc(strlen(ptr)+1 );
		if( list_of_attr[j] == NULL )
			break;

		strcpy(list_of_attr[j],ptr);
                _pdm_debug("Attribute %s",list_of_attr[j]);

		ptr = strtok(NULL,"~");

		if (ptr == NULL ) {
			_pdm_debug("ptr is null ???", 0 );
			break;
		}


		attr_desc[j] = (char *)malloc(strlen(ptr)+1 );
		if( attr_desc[j] == NULL )
			break;
		strcpy(attr_desc[j],ptr);
                _pdm_debug("Attribute synonym %s",attr_desc[j]);

		ptr = strtok(NULL,"~");

		if (ptr == NULL ) {
			_pdm_debug("ptr is null ???", 0 );
			break;
		}


		attr_type[j] = (char *)malloc(strlen(ptr)+1 );
		if( attr_type[j] == NULL )
			break;
		strcpy(attr_type[j],ptr);
                _pdm_debug("Attribute type %s",attr_type[j]);
		ptr = strtok(NULL,"~");
		ptr = strtok(NULL,"~");
                j++;
	}

      if(output1)	free(output1);
      if(query)	free(query);
      if(query1)	free(query1);
      if(where)	free(where);

     _pdm_debug("No of attrs 1 %d", (char *)*no_of_attrs);
     _pdm_debug("No of attrs i %d", (char *)j);
	/* Why is this needed? MaC 052494 
           *no_of_attrs =  j - 1 ;
                                 */
	   *no_of_attrs =  j ;

     _pdm_debug("No of attrs %d", (char *)*no_of_attrs);
	for( i = 0 ; (i < *no_of_attrs) ; i = i + 1 ) {
            _pdm_debug("Attribute %s", list_of_attr[i]);
             }
*list_of_attr1 = (char **) list_of_attr;
*attr_desc1    = (char **) attr_desc;
*attr_type1    = (char **) attr_type;
     _pdm_debug("Exit Getcatattribs_for_union",0);
        IGEresetstop();
	return(1);
}


/*

GetUnionCatAttribs_mem(char ***list_of_attr, char ***attr_desc,
 char ***attr_type, int *no_of_attrs)
{
	int  i, j, max_rows , max_rows1 = 0, sts , err_code ;
	char *query = NULL, *query1 = NULL, *ptr = NULL, *output = NULL, *output1  = NULL;
        char *where = NULL, tmp[200];
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

