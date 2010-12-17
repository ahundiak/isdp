#include <stdio.h>
#include <malloc.h>
#include <string.h>

#include "PALglbs.h"
#include                "SQLerrordef.h"
#include                "MEMerrordef.h"
#include                "NFMerrordef.h"
#include                "NFMapi.h"
#include                "NFMschema.h"
#include                "MEMstruct.h"
#include                "PDMdbs_err.h"
#include                "PDUerror.h"
#include                "PDMproto.h"

#include                "PDMbom_strct.h"

static long             status;
extern          int             PDMdebug_on;
extern          char    PDM_DEBUG_FILE[];
extern PDMexec_ptr PDMexec;


#define FALSE 0
#define TRUE  1

#define MAX_PARAM_IN_FORMULA 45

#define DEL1 "$"
#define DEL2 "!"

/**********************   Extern Globale Variables ***********************/

/* Indicates whether 'partno' is Computable */
/*extern int	PDU_ComputedID = FALSE;*/

/* Contains the columns in the Computable ID 	*/
extern char	*attribs_in_ID;	

/* Contains the values of columns in the Computable ID 	*/
extern char	*vals_of_attribs_in_ID;

extern int	col_indxs[MAX_PARAM_IN_FORMULA];
extern int	NoColsInID;

extern	char *s_text;

extern	struct	PDUrefresh *refresh;

extern char **AttrList;
extern int NumAttribs ;
/************************************************************************/

/* This function gets the values for a CID part from both
   catalog and e_catalog to insert it into the bom. MaC 061193
   The alg is as follows:
   1. Get the attributes and values for the view part by
      reverse transforming the computed ID.
   2. Construct and execute a query to the view cat with a where clause like
      "where attr1=val1 and attr2=val2...etc"  
      This should give atleast one row satisfying all the
      criteria. This row will be the one with the values
      for the part to be inserted.
   3. Construct stat_attr_str and stat_val_str from these values
      and pass them back to the main code in PDMgen_bom.c.
  2a. Once we have the attr and vals, we have to pass them
      to another function which computes the n_itemdesc for
      the part to insert into e_catalog.
       */
 

int _PDMget_cat_bom_vals_for_CID_part (catno, catalog, partnum, revision, 
                                        item_no, qry_list, 
                                        pdcno, dyncat, 
                                        stat_data_str, stat_attr_str, 
                                        bom_attr_bufr, Itemdesc, 
                                        Altpartno)
int	catno, item_no, pdcno;
char	*partnum, *revision, *dyncat;
char	*catalog, *qry_list;
char	**stat_data_str, **stat_attr_str;
MEMptr	bom_attr_bufr;
char	**Altpartno, *Itemdesc;
{
	char		*fn = "_PDMget_cat_bom_vals_for_CID_part";
	char		**data, **attr, **bom_attr;
	int		bom_index, i, j;
        MEMptr		out_bufr = NULL;
	char		*altpartno;
	char		*atr_str;
	char		*val_str;
/*	char		*where_str = NULL;*/
	char		val[240];
	char		l_catalog[80];
	char		sql_str[1024];
        int		part_is_formula = 0;
	


   _PDMdebug (fn, "ENTER\n");
   _PDMdebug ("catno", "[%d] catalog[%s] item#[%d]\nqrylist[%s]\n", 
                       catno, catalog, item_no, qry_list);

   _PDMdebug (fn, "partnum[%s]revision[%s]\n", partnum, revision);
    
    status = MEMbuild_array (bom_attr_bufr);
    if (status != MEM_S_SUCCESS) {
      _PDMdebug ( fn, "MEMbuild_query (bom_attr_bufr) 0x%.8x\n", NFM_E_MEM );
      return (NFM_E_MEM);
      }

    part_is_formula = 0;
    for (i=0; i < (strlen (partnum)); i++) {
        if ((partnum[i] == '$') || (partnum[i] == '!') ) {
          part_is_formula = 1;
         }
      }
   _PDMdebug (fn, "part_is_formula[%d]\n", part_is_formula);
  if (!part_is_formula) {
   sprintf (sql_str, "SELECT %s FROM %s WHERE n_itemname = '%s' ", 
                             qry_list, catalog, partnum);

   status = SQLquery (sql_str, &out_bufr, 1024);
   if (status != SQL_S_SUCCESS ) {
    _PDMdebug ( fn, "SQLquery 0x%.8x\n", status) ;
    return (status);
    }
   status = PDMbom_calc_itemdesc_n_insert_for_dinpart  (catalog, catno, 
                                                        partnum, item_no, 
                                                        pdcno, dyncat, 
                                                         &altpartno, Itemdesc);
    if (status != PDM_S_SUCCESS) {
      _PDMdebug ( fn, "PDMbom_calc_itemdesc_n_insert_for_dinpart 0x%.8x\n", 
                                                                  status );
      return (status);
      }
   }
     
  else {
     
     l_catalog[0] = '\0';
     strcpy (l_catalog, catalog);
     /*PDMconvert_to_lower (catalog, l_catalog);*/
    /* it is a formula */
    /*if ( ! GetattrsGivenID  (partnum, l_catalog, 0)) */
    if ( ! GetattrsGivenID  (partnum, l_catalog)) {
       _PDMdebug (fn, "GetattrsGivenID Failed \n");
       return(0);
       }

   
   _PDMdebug (fn, "attribsinID=%s", attribs_in_ID);
   _PDMdebug (fn, "valsofattribsinID=%s", vals_of_attribs_in_ID);

  /* stub for inserting n_itemdesc in the e_catalog */

    status =  PDMbom_calc_itemdesc_n_insert  (l_catalog, catno, 
                                              item_no, &altpartno, Itemdesc);
    if (status != PDM_S_SUCCESS) {
      _PDMdebug ( fn, "PDMbom_calc_itemdesc_n_insert 0x%.8x\n", status );
      return (status);
      }

   _PDMdebug (fn, "Itemdesc[%s]\n", Itemdesc);

   _PDMdebug (fn, "Altpartno[%s]\n", altpartno);
   *Altpartno = altpartno;
   _PDMdebug (fn, "Altpartno[%s]\n", Altpartno);

    status =  PDMbom_get_view_data  (l_catalog, qry_list, 
                                          Altpartno, &out_bufr);
    if (status != PDM_S_SUCCESS) {
      _PDMdebug ( fn, "PDMbom_get_view_data 0x%.8x\n", NFM_E_MEM );
      return (status);
      }

   } /* it is a formula */
    
   status = MEMbuild_array (out_bufr);
   if (status != MEM_S_SUCCESS) {
      MEMclose (&out_bufr);
      _PDMdebug ( fn, "MEMbuild_query (out_bufr) 0x%.8x\n", NFM_E_MEM );
      return (NFM_E_MEM);
      }

   NFMRtic_it (out_bufr);

   if (PDMdebug_on) {
      MEMprint_buffer("list of dyn cats from query", out_bufr, PDM_DEBUG_FILE);
       }

   attr = (char **) (out_bufr)->column_ptr;
   data = (char **) (out_bufr)->data_ptr;
   bom_attr = (char **) (bom_attr_bufr)->data_ptr;
   

   atr_str = (char *) malloc (((out_bufr) -> rows * 10) *10 + 512);
   if (! atr_str) {
       _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n", 
                        NFM_E_MALLOC);
       return (NFM_E_MALLOC);
       }
   atr_str[0] ='\0';

   val_str = (char *) malloc (((out_bufr) -> rows * 10) *10 + 512);
   if (! val_str) {
       _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n", 
                        NFM_E_MALLOC);
       return (NFM_E_MALLOC);
       }
   val_str[0] = '\0';

  for (j=0;j<out_bufr->columns;j++) {
   for (i=0;i<bom_attr_bufr->rows;i++) {
     bom_index = bom_attr_bufr->columns * i;
     if (catno = atol (bom_attr[bom_index+2])) {
        if ( !strcmp (attr[j], bom_attr[bom_index+4])) {
         _PDMdebug ("Found attr", "%s\n", attr[j]);
         if (strcmp (data[j], "")) {
         status = _PDMget_data_type (bom_attr[bom_index+6], data[j], val);
         if (status != PDM_S_SUCCESS) {
           MEMclose (&out_bufr);
           if (atr_str) free (atr_str);
           if (val_str) free (val_str);
           _PDMdebug ( fn, "_PDMget_data_type 0x%.8x\n", status );
           return (status);
             }
          _PDMdebug (fn, "attr[%s] data[%s]\n", attr[j], data[j]);
       /*   if ( (atr_str[0] != '\0') && (val_str[0] != '\0') ) {*/
           strcat (atr_str, ", ");
           strcat (val_str, ", ");
            /*}*/
           strcat (atr_str, attr[j]);
           strcat (val_str, val);
           _PDMdebug  ("atr_str", "%s\n", atr_str);
           _PDMdebug  ("val_str", "%s\n", val_str);
           break;
           }
          }
         }
       }
      }
    
    strcat (*stat_attr_str, atr_str);
    strcat (*stat_data_str, val_str);
    _PDMdebug  ("stat_attr_str", "%s\n", *stat_attr_str);
    _PDMdebug  ("stat_data_str", "%s\n", *stat_data_str);

   if (out_bufr) MEMclose (&out_bufr);
   if (atr_str) free (atr_str);
   if (val_str) free (val_str);

   if (PDMdebug_on) {
      MEMprint_buffer("bom_attr_bufr at exit", bom_attr_bufr, PDM_DEBUG_FILE);
       }

   _PDMdebug (fn, "EXIT\n");
   return (PDM_S_SUCCESS);
}


int PDMbom_get_view_data  ( char *catalog, char *qry_list, 
                                    char **where_cls, MEMptr *out_bufr)
{
	char	*fn = "PDMbom_get_view_data";
/*
	char	*ptr , *clause, **selected_attribs;
	int	i = 0, j ;
	char    *temp;
*/
	char    *query;
	int	no_attributes;
	MEMptr	qry_bufr = NULL;

	_PDMdebug (fn, "Enter: \n");

        _PDMdebug (fn, "qry_list[%s], catalog[%s]\n", 
                                  catalog, qry_list);

        no_attributes = NoColsInID;

		/** Get the attributes in the Computable ID **/
		/* Build where clause to retrieve values */
		_PDMdebug (fn, "attribsinID=%s\n", attribs_in_ID);
		_PDMdebug (fn, "valsofattribsinID=%s\n", vals_of_attribs_in_ID);

	query = (char *) malloc ((no_attributes * 122 + 512) * sizeof (char));

	/* Build PRE query */
        query[0] = '\0';
	strcpy (query, "Select ");
	/* Attribute list */
	strcat (query, qry_list);
	strcat (query, " From ");
	/* TABLE */
	strcat (query, catalog);
	strcat (query, " Where ");


	/* Add the where clause */
	strcat (query, (*where_cls));

	_PDMdebug (fn, "GetStatAddToRg: Query: %s\n", query );

   status = SQLquery (query, &qry_bufr, 1024);
   MyFree (query);
   if ( (status != SQL_S_SUCCESS ) &&
            (status != SQL_I_NO_ROWS_FOUND ) ) {
    _PDMdebug ( fn, "SQLquery 0x%.8x\n", status) ;
    return (status);
    }
    
    if (status == SQL_S_SUCCESS) {
    status = MEMbuild_array (qry_bufr);
    if (status != MEM_S_SUCCESS) {
      MEMclose (&qry_bufr);
      _PDMdebug ( fn, "MEMbuild_query (qry_bufr) 0x%.8x\n", NFM_E_MEM );
      return (NFM_E_MEM);
      }

   if (PDMdebug_on) {
      MEMprint_buffer("list of dyn cats from query", qry_bufr, PDM_DEBUG_FILE);
       }

   *out_bufr = qry_bufr;
     }
    else
     {
      return (status);
      }

 _PDMdebug (fn, "Exit\n");
	return (PDM_S_SUCCESS);
}

int  PDMbom_calc_itemdesc_n_insert  (catalog, catno, 
                                     itemno, where_str, Itemdesc)
char	*catalog;
char	**where_str;
int	catno, itemno;
char	*Itemdesc;
{
	char	*fn = "PDMbom_calc_itemdesc_n_insert";
	char	*ptr, *ptr1;
	char	 **attrs = NULL;
	char	 **vals = NULL;
	char	 **types = NULL;
/*	char	*where_str = NULL; */
        /*char	*itemdesc;*/
        char	**data;
	char	sql_str[1024];
	char	val[240];
	char	*itemdesc;
	char	partnum[240];
	char	revision[20];
        int	numattr;
        int	numattr1;
        int	desc_is_formula;
        int	i, j, index;
        int	x, chr;
	MEMptr	datatype_bufr = NULL;


     _PDMdebug (fn, "Enter\n");

     _PDMdebug (fn, "catalog[%s]cat#[%d], item#[%d]\n", 
                        catalog, catno, itemno);

     numattr = 0;
     ptr = strtok(attribs_in_ID, "~");
     while( ptr ) {
        if( numattr == 0 ) {
           attrs = (char **)malloc(sizeof(char *));
        }
        else
        {
           attrs = (char **)realloc(attrs, sizeof(char *)*(numattr+1));
        }
        attrs[numattr] = (char *) malloc (strlen(ptr) + 1 );
        strcpy(attrs[numattr], ptr);
	_PDMdebug ("attrs", "%s\n", attrs[numattr]);

        ptr = strtok(NULL, "~");
        numattr++;
      }
     numattr1 = 0;
     ptr1 = strtok(vals_of_attribs_in_ID, "~");
     while( ptr1 ) {
        if( numattr1 == 0 ) {
           vals = (char **)malloc(sizeof(char *));
        }
        else
        {
           vals = (char **)realloc(vals, sizeof(char *)*(numattr1+1));
        }
        vals[numattr1] = (char *) malloc (strlen(ptr1) + 1 );
        strcpy(vals[numattr1], ptr1);
	_PDMdebug ("vals", "%s\n", vals[numattr1]);

        ptr1 = strtok(NULL, "~");
        numattr1++;
      }
      _PDMdebug (fn, "Numattr = %d\n", numattr1);

      sql_str[0] = '\0';
      sprintf (sql_str, "%s %s %d ", 
               "SELECT n_name, n_datatype FROM nfmattributes WHERE ", 
               " n_tableno = ", 
               catno);

       status = SQLquery (sql_str, &datatype_bufr, 1024);
       if (status != SQL_S_SUCCESS ){
        _PDMdebug ( fn, "SQLquery 0x%.8x\n", status) ;
        return (status);
        }
        
        status = MEMbuild_array (datatype_bufr);
        if (status != MEM_S_SUCCESS) {
          MEMclose (&datatype_bufr);
          _PDMdebug ( fn, "MEMbuild_query (qry_bufr) 0x%.8x\n", NFM_E_MEM );
          return (NFM_E_MEM);
          }
    
       if (PDMdebug_on) {
          MEMprint_buffer("list of datatypes from query", datatype_bufr, 
                                                           PDM_DEBUG_FILE);
           }

      data = (char **) (datatype_bufr)->data_ptr;

_PDMdebug (fn, "bef malloc\n");
      (*where_str) = (char *) malloc (((numattr+1) * 128) + 512);
_PDMdebug (fn, "aft malloc\n");
      (*where_str)[0] = '\0';
_PDMdebug (fn, "aft init\n");

      types = (char **) malloc ((numattr+1) * sizeof (char*));

      for (i = 0; i < numattr; i++ ) {
       for (j = 0; j < datatype_bufr->rows; j++) {
        index = datatype_bufr->columns * j;
        if (!strcmp (attrs[i], data[index])) {
           types[i] = (char *) malloc (strlen(data[index+1]) + 1 );
           strcpy(types[i], data[index+1]);
           /* also create the select str for view */
           val[0] = '\0';
           status = _PDMget_data_type (types[i], vals[i], val);
           if (status != PDM_S_SUCCESS) {
                 MEMclose (&datatype_bufr);
                 _PDMdebug ( fn, "_PDMget_data_type 0x%.8x\n", status );
                 return (status);
                   }
           if (i>0) {
_PDMdebug (fn, "bef strcator\n");
            strcat ((*where_str), " OR ");
                  }
_PDMdebug (fn, "bef strcatdata\n");
           strcat ((*where_str), attrs[i]);
           strcat ((*where_str), " = ");
           strcat ((*where_str), vals[i]);
           _PDMdebug ("(*where_str)", "%s\n", (*where_str));
            }
           }
          }

_PDMdebug (fn, "bef strcatmlc\n");

/*
      (*where_cls) = (char *) malloc (((numattr+1) * 128) + 512);
      strcpy ((*where_cls), where_str);
*/

      /*(**where_cls) = *where_str;*/

_PDMdebug (fn, "aft strcatdata\n");

      MEMclose (&datatype_bufr);

_PDMdebug (fn, "aft memcls\n");

     /* Support to add n_itemdesc */

    partnum[0] = '\0';
    revision[0] = '\0';
    Itemdesc[0] = '\0';
    val[0] = '\0';
    sprintf (val, "e_%s", catalog);
    
    status = PDMi_get_partnum_rev_desc (val, -1, 
                                   partnum, revision, Itemdesc);

    desc_is_formula = 0;
    for (i=0; i < (strlen (Itemdesc)); i++) {
        if ((partnum[i] == '$') || (partnum[i] == '!') ) {
          desc_is_formula = 1;
         }
      }
   _PDMdebug (fn, "desc_is_formula[%d]\n", desc_is_formula);
   if (desc_is_formula) {
    Itemdesc[0] = '\0';
    itemdesc = NULL;
    
   if( ! GetID_N_Compute (catalog, attrs, vals, types, 
                                            numattr, &itemdesc, 1)) {
      _PDMdebug (fn, "GetID_N_Compute Failed\n");
      return(0);
      }

    _PDMdebug (fn, "Itemdesc[%s]\n", itemdesc);

     /* cleaning the Itemdesc string to remove $, ! and ' */

    for (x=0, chr=0; chr < (strlen (itemdesc)); chr++) {
      if ((itemdesc[chr] != '!')
            && (itemdesc[chr] != '$')
                  && (itemdesc[chr] != '\'') ) {
          Itemdesc[x] = itemdesc[chr];
          x++;
          _PDMdebug (fn, "cleaning %c\n", Itemdesc[x]);
         }
       }
   Itemdesc[x] = '\0';
   /*strcpy (Itemdesc, temp); */
   _PDMdebug (fn, "cleand Itemdesc[%s]\n", Itemdesc);

    /*strcpy (Itemdesc, itemdesc);*/
    if (itemdesc) free (itemdesc);
    }

    sprintf (sql_str, "UPDATE %s SET n_itemdesc = '%s' WHERE n_itemno = %d", 
                   val, Itemdesc, itemno);
    SQLstmt (sql_str);
    
    

  for (i=0 ; i < numattr; i++){
     free (attrs[i]);
     free (vals[i]);
     free (types[i]);
      }
  
 _PDMdebug (fn, "Exit\n");
 return (PDM_S_SUCCESS);
}
    

int  PDMbom_calc_itemdesc_n_insert_for_dinpart  (catalog, catno, part_num, 
                                                 itemno, pdcno, dyncat, 
                                                  where_str, Itemdesc)
char	*catalog, *dyncat;
char	**where_str;
int	catno, itemno, pdcno;
char	*Itemdesc;
char    *part_num;
{
	char	*fn = "PDMbom_calc_itemdesc_n_insert_for_dinpart";
	char	 **attrs = NULL;
	char	 **vals = NULL;
	char	 **types = NULL;
	char	 **data=NULL, **cols = NULL, **format = NULL;
/*	char	*where_str = NULL; */
        /*char	*itemdesc;*/
	char	sql_str[1024];
	char	val[240];
	char	*itemdesc;
        int	numattr;
        int	numattr1;
        int	numattr2;
        int	desc_is_formula;
	MEMptr	where_bufr = NULL;
        int	i;
        int	x, chr;


     _PDMdebug (fn, "Enter\n");

     _PDMdebug (fn, "catalog[%s]cat#[%d], part[%s]item#[%d]\n", 
                        catalog, catno, part_num, itemno);

        
   sprintf (sql_str, "SELECT * FROM %s WHERE n_itemname = '%s' ", 
                                                      catalog, part_num);

   status = SQLquery (sql_str, &where_bufr, 1024);
   if (status != SQL_S_SUCCESS ) {
    _PDMdebug ( fn, "SQLquery 0x%.8x\n", status) ;
    return (status);
    }

    status = MEMbuild_array (where_bufr);
    if (status != MEM_S_SUCCESS) {
          _PDMdebug ( fn, "MEMbuild_query (qry_bufr) 0x%.8x\n", NFM_E_MEM );
          return (NFM_E_MEM);
    }
   
    NFMRtic_it (where_bufr);

   if (PDMdebug_on) {
      MEMprint_buffer("where clause buffer", where_bufr, PDM_DEBUG_FILE);
       }

    data = (char **) (where_bufr)->data_ptr;
    cols = (char **) (where_bufr)->column_ptr;
    format = (char **) (where_bufr)->format_ptr;
    
    numattr = 0;

    for (numattr=0, x=0; x < where_bufr->columns; x++) {
/* The attribute for the compute may not have values...MaC 101793 */
      /*if (strcmp (data[x], "")) {*/
         _PDMdebug ("Found attr", "%s\n", cols[x]);
        if( numattr == 0 ) {
           attrs = (char **)malloc(sizeof(char *));
        }
        else {
           attrs = (char **)realloc(attrs, sizeof(char *)*(numattr+1));
        }
        attrs[numattr] = (char *) malloc (strlen(cols[x]) + 1 );
        attrs[numattr][0] = '\0';
        strcpy(attrs[numattr], cols[x]);
	_PDMdebug ("attrs", "%s\n", attrs[numattr]);
        if (!strcmp (cols[x], "n_itemdesc") ) {
           Itemdesc[0] = '\0';
           strcpy (Itemdesc, data[x]);
           _PDMdebug ("Itemdesc", "%s\n", Itemdesc);
          }
        numattr++;
        /*}*/
      }

    for (numattr1=0, x=0; x < where_bufr->columns; x++) {
      /*if (strcmp (data[x], "")) { */
         _PDMdebug ("Found val", "%s\n", data[x]);
         val[0] = '\0';
         status = _PDMget_data_type (format[x], data[x], val);
         if (status != PDM_S_SUCCESS) {
           _PDMdebug ( fn, "_PDMget_data_type 0x%.8x\n", status );
           return (status);
           }

      if( numattr1 == 0 ) {
           vals = (char **)malloc(sizeof(char *));
        }
      else {
           vals = (char **)realloc(vals, sizeof(char *)*(numattr1+1));
        }
      vals[numattr1] = (char *) malloc (strlen(data[x]) + 25 );
      vals[numattr1][0] = '\0';
      strcpy(vals[numattr1], val);
      _PDMdebug ("vals", "%s\n", vals[numattr1]);
      numattr1++;
      /*} */
    }

    for (numattr1=0, x=0; x < where_bufr->columns; x++) {
      /*if (strcmp (data[x], "")) { */
         _PDMdebug ("Found type", "%s\n", format[x]);

      if( numattr1 == 0 ) {
           types = (char **)malloc(sizeof(char *));
        }
      else {
           types = (char **)realloc(types, sizeof(char *)*(numattr1+1));
        }
      types[numattr1] = (char *) malloc (strlen(format[x]) + 1 );
      types[numattr1][0] = '\0';
      strcpy(types[numattr1], format[x]);
      _PDMdebug ("types", "%s\n", types[numattr1]);
      numattr1++;
      /*} */
    }


    _PDMdebug (fn, "Numattr = %d\n", numattr1);

    (*where_str) = (char *) malloc (((numattr+1) * 128) + 512);
    (*where_str)[0] = '\0';

    for (i = 0; i < numattr; i++ ) {
       if (i>0) {
_PDMdebug (fn, "bef strcator\n");
            strcat ((*where_str), " OR ");
                  }
_PDMdebug (fn, "bef strcatdata\n");
           strcat ((*where_str), attrs[i]);
           strcat ((*where_str), " = ");
           strcat ((*where_str), vals[i]);
           _PDMdebug ("(*where_str)", "%s\n", (*where_str));
          }

     /* support added for dynamic table attributes */
        
   _PDMdebug (fn, "dyncat[%s] pdcno[%d]\n", dyncat, pdcno);

   if ( (pdcno > 0) && (dyncat)) {

   MEMclose (&where_bufr); where_bufr = NULL;

    /* Getting dynamic attrs, vals and types */
   _PDMdebug (fn, "pdcno[%d], dyncat[%s]\n", pdcno, dyncat);

   sprintf (sql_str, "SELECT * FROM %s WHERE p_pdcno = %d ", 
                                                      dyncat, pdcno);

   status = SQLquery (sql_str, &where_bufr, 1024);
   if (status != SQL_S_SUCCESS ) {
    _PDMdebug ( fn, "SQLquery 0x%.8x\n", status) ;
    return (status);
    }

    status = MEMbuild_array (where_bufr);
    if (status != MEM_S_SUCCESS) {
          _PDMdebug ( fn, "MEMbuild_query (qry_bufr) 0x%.8x\n", NFM_E_MEM );
          return (NFM_E_MEM);
    }
   
    NFMRtic_it (where_bufr);

   if (PDMdebug_on) {
      MEMprint_buffer("where clause buffer", where_bufr, PDM_DEBUG_FILE);
       }

    data = (char **) (where_bufr)->data_ptr;
    cols = (char **) (where_bufr)->column_ptr;
    format = (char **) (where_bufr)->format_ptr;

    _PDMdebug (fn, "numattr[%d]\n", numattr);

    numattr2 = numattr1;

    for (x=0; x < where_bufr->columns; x++) {
      /*if (strcmp (data[x], "")) {*/
         _PDMdebug ("Found attr", "%s\n", cols[x]);
        if( numattr == 0 ) {
           attrs = (char **)malloc(sizeof(char *));
        }
        else {
           attrs = (char **)realloc(attrs, sizeof(char *)*(numattr+1));
        }
        attrs[numattr] = (char *) malloc (strlen(cols[x]) + 1 );
        attrs[numattr][0] = '\0';
        strcpy(attrs[numattr], cols[x]);
	_PDMdebug ("attrs", "%s\n", attrs[numattr]);
        numattr++;
        /*}*/
      }

    for (x=0; x < where_bufr->columns; x++) {
      /*if (strcmp (data[x], "")) {*/
         _PDMdebug ("Found val", "%s\n", data[x]);
         val[0] = '\0';
         status = _PDMget_data_type (format[x], data[x], val);
         if (status != PDM_S_SUCCESS) {
           _PDMdebug ( fn, "_PDMget_data_type 0x%.8x\n", status );
           return (status);
           }

      if( numattr1 == 0 ) {
           vals = (char **)malloc(sizeof(char *));
        }
      else {
           vals = (char **)realloc(vals, sizeof(char *)*(numattr1+1));
        }
      vals[numattr1] = (char *) malloc (strlen(data[x]) + 25 );
      vals[numattr1][0] = '\0';
      strcpy(vals[numattr1], val);
      _PDMdebug ("vals", "%s\n", vals[numattr1]);
      numattr1++;
        /*}*/
      }

    numattr1 = numattr2;
    for (x=0; x < where_bufr->columns; x++) {
      /*if (strcmp (data[x], "")) {*/
         _PDMdebug ("Found type", "%s\n", format[x]);
      if( numattr1 == 0 ) {
           types = (char **)malloc(sizeof(char *));
        }
      else {
           types = (char **)realloc(types, sizeof(char *)*(numattr1+1));
        }
      types[numattr1] = (char *) malloc (strlen(data[x]) + 25 );
      types[numattr1][0] = '\0';
      strcpy(types[numattr1], format[x]);
      _PDMdebug ("types", "%s\n", types[numattr1]);
      numattr1++;
        /*}*/
      }
    }

     /* Support to add n_itemdesc */

    desc_is_formula = 0;
    for (i=0; i < (strlen (Itemdesc)); i++) {
        if ((Itemdesc[i] == '$') || (Itemdesc[i] == '!') ) {
          desc_is_formula = 1;
         }
      }
   _PDMdebug (fn, "desc_is_formula[%d]\n", desc_is_formula);
   if (desc_is_formula) {
    Itemdesc[0] = '\0';
    itemdesc = NULL;
    
   if( ! GetID_N_Compute (catalog, attrs, vals, types, 
                                            numattr, &itemdesc, 1)) {
      _PDMdebug (fn, "GetID_N_Compute Failed\n");
      return(0);
      }

    _PDMdebug (fn, "Itemdesc[%s]\n", itemdesc);

     /* cleaning the Itemdesc string to remove $, ! and ' */

    for (x=0, chr=0; chr < (strlen (itemdesc)); chr++) {
      if ((itemdesc[chr] != '!')
            && (itemdesc[chr] != '$')
                  && (itemdesc[chr] != '\'') ) {
          Itemdesc[x] = itemdesc[chr];
          x++;
          _PDMdebug (fn, "cleaning %c\n", Itemdesc[x]);
         }
       }
   Itemdesc[x] = '\0';
   _PDMdebug (fn, "cleand Itemdesc[%s]\n", Itemdesc);

    if (itemdesc) free (itemdesc);
    }

    sprintf (sql_str, "UPDATE %s SET n_itemdesc = '%s' WHERE n_itemno = %d", 
                   val, Itemdesc, itemno);
    SQLstmt (sql_str);
    
    

  for (i=0 ; i < numattr; i++){
     free (attrs[i]);
     free (vals[i]);
     free (types[i]);
      }
  MEMclose (&where_bufr); where_bufr = NULL;
  
 _PDMdebug (fn, "Exit\n");
 return (PDM_S_SUCCESS);
}
    
