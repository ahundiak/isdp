#include "PDUerror.h"
#include "PDUcommand.h"
#include "PDUfile_def.h"
#include "PDUforms.h"
#include "PDUuser.h"
#include "PDUintdef.h"
#include "PDUstr.h"
#include "PDMmessage.h"
#include "SQLerrordef.h"
#include "PDMdbs_err.h"
#include "exdef.h"
#include "PDMstruct.h"

extern int bufr_flag;
extern int PDM_debug_on;
extern struct PDUrefresh *refresh;
static char s[1024];
int                             PDMalt_bom_on;
char                            PDM_ALT_PARENT_ATTR[45];


void PDMppl_query_for_parts(status, catalog, count, parts)
  int    *status;   /* Output - Return status */
  char   *catalog;  /* Input  - Catalog name */
  int    *count;    /* Output - Number of parts in the given catalog */
   PDMparts  *parts; /* Output - Parts - An array of structures */
{

  char   **parts_data;
  int    i = 0, nxi = 0;
  char   sql_str[512];
  MEMptr bufr = NULL;
  char   *fname = "PDMppl_query_for_parts";

  _pdm_debug("PDMppl_query_for_parts: Enter", 0);


  /* Robust check for catalog name. It should be either in catalog parameter or
    in refresh->rev_catalog global variable */

  if ((catalog) && (strcmp(catalog, "") == 0))
    {
      if ((refresh->rev_catalog) && (strcmp(refresh->rev_catalog, "")))
       {
         strcpy(catalog,refresh->rev_catalog);
        }
      else
        {
         *status = PDM_I_ENTER_CATALOG;
    PDUmessage(*status, 's');
    return;
         }
    }
  else if (!(catalog)) /* catalog = NULL */
    {
      if ((refresh->rev_catalog) && (strcmp(refresh->rev_catalog, "")))
       {
         strcpy(catalog,refresh->rev_catalog);
        }
      else
      {
    *status = PDM_I_ENTER_CATALOG;
    PDUmessage(*status, 's');
    return;
      }
    }

  /* Re-intialize the refresh structure again */

  PDUfill_in_string(&refresh->rev_catalog, catalog);

       /* Display Message */
       PDUmessage(PDS_M_SHOW_PARTS, 's');

       PDUmessage(PDS_M_SERVER_ACCESS, 's');
      sql_str[0] = '\0';
        sprintf(sql_str,"SELECT DISTINCT %s FROM %s ORDER BY n_itemname", "(n_itemname), n_itemrev,n_itemdesc,p_parttype  ",refresh->rev_catalog);
        *status = SQLquery(sql_str,&bufr,1024);
        if(*status != SQL_S_SUCCESS)
        {
                switch(*status)
                {
      case SQL_I_NO_ROWS_FOUND :
         _pdm_debug("No Parts found \n");
         _pdm_debug("PDMppl_query_for_parts: Exit", PDM_E_NO_PARTS_FOUND);
         _PDMdebug (fname, "No Parts found \n");
         _PDMdebug (fname, "PDMppl_query_for_parts: Exit", 
                                               PDM_E_NO_PARTS_FOUND);
          *status = PDM_E_NO_PARTS_FOUND;
               
      case PDMS_NO_SUCH_TABLE:
            MEMclose(&bufr);
            sprintf(s,"%s not found\n",refresh->rev_catalog);
            _pdm_debug(s);
            _pdm_debug("PDMppl_query_for_parts: Exit", PDM_E_CATALOG_NOT_FOUND);
            *status = PDM_E_CATALOG_NOT_FOUND;

      default:
            _pdm_debug("PDMppl_query_for_parts: Exit", PDM_E_SQL_QUERY);
             MEMclose(&bufr);
             *status = PDM_E_SQL_QUERY;
              return;
                    }
        } 

       PDUmessage(PDS_M_SERVER_DONE, 's');
    if (PDM_debug_on) MEMprint_buffer("parts  buffer", bufr, PDU_DEBUG_FILE);

       *status  = MEMbuild_array(bufr);
        if(*status != MEM_S_SUCCESS)
        {
                MEMclose(&bufr);
                sprintf (s, "%s %d", 
                "MEMbuild_array failed status ",status);
                _pdm_debug(s, 0);
                return;
        }
        if((bufr)->rows > 2000)
        {
          MEMclose(&bufr);
          _pdm_debug("PDMppl_query_for_parts: Exit", PDM_E_TOO_MANY_PARTS);
          _pdm_debug("EXIT:PDMshow_parts \n");
          *status = PDM_E_TOO_MANY_PARTS;
        return;
         }

       parts_data = (char **)bufr->data_ptr;

       /* The buffer is converted back to the structure because the
          structure datatype is known well to the ppl programmers
          than MEMptr data structure. A linked list is not implemented
          because, freeing of the linked list is painful for the ppl
          programmer */

    *count = bufr->rows;

    *parts = (PDMparts) calloc(bufr->rows,(bufr->rows * sizeof( PDMparts )));

    if(parts == NULL)
      {
        MEMclose(&bufr);
       *status = PDM_E_COULD_NOT_MALLOC;
          _pdm_debug("PDMppl_query_for_parts: Exit", PDM_E_COULD_NOT_MALLOC);
        return;
       }

                
   for (i=0 ; i < bufr->rows; i++)
    {
      nxi = bufr->columns * i;

    strcpy((*parts+i)->n_itemname, parts_data[nxi]); 
    strcpy((*parts+i)->n_itemrev, parts_data[nxi+1]); 
    strcpy((*parts+i)->n_itemdesc, parts_data[nxi+2]); 
    strcpy((*parts+i)->p_parttype, parts_data[nxi+3]); 

     }

     MEMclose(&bufr);

   *status = PDM_S_SUCCESS;
    PDUmessage(*status, 's');
          _pdm_debug("PDMppl_query_for_parts: Exit", PDM_S_SUCCESS);

}

void PDMppl_query_for_catalogs(status, count, catalogs)
  int    *status;   /* Output - Return status */
  int    *count;    /* Output - Number of catalogs in the given catalog */
  PDMcatalogs  *catalogs; /* Output - catalogs - An array of structures */
{

  char   **catalogs_data;
  int    i =0 , nxi = 0;
  char   sql_str[512];
  MEMptr bufr = NULL;

  _pdm_debug("PDMppl_query_for_catalogs: Enter", 0);


       /* Display Message */
       PDUmessage(PDS_M_SHOW_CATALOGS, 's');

      sql_str[0] = '\0';
        sprintf(sql_str,"SELECT DISTINCT %s FROM nfmcatalogs ORDER BY n_catalogname", "(n_catalogname), n_catalogdesc, n_type");
        *status = SQLquery(sql_str,&bufr,1024);
        if(*status != SQL_S_SUCCESS)
        {
                switch(*status)
                {
      case SQL_I_NO_ROWS_FOUND :
         _pdm_debug("No Parts found \n");
         _pdm_debug("PDMppl_query_for_catalogs: Exit", PDM_E_NO_PARTS_FOUND);
          *status = PDM_E_NO_CATALOGS_FOUND;
          return;
               
      default:
            _pdm_debug("PDMppl_query_for_catalogs: Exit", PDM_E_SQL_QUERY);
             MEMclose(&bufr);
             *status = PDM_E_SQL_QUERY;
             return;
                    }
        } 

    if (PDM_debug_on) MEMprint_buffer("catalogs  buffer", bufr, PDU_DEBUG_FILE);

       *status  = MEMbuild_array(bufr);
        if(*status != MEM_S_SUCCESS)
        {
                MEMclose(&bufr);
                sprintf (s, "%s %d", 
                "MEMbuild_array failed status ",*status);
                _pdm_debug(s, 0);
                return;
        }

       catalogs_data = (char **)bufr->data_ptr;

       /* The buffer is converted back to the structure because the
          structure datatype is known well to the ppl programmers
          than MEMptr data structure. A linked list is not implemented
          because, freeing of the linked list is painful for the ppl
          programmer */

    *count = bufr->rows;

    *catalogs = (PDMcatalogs) calloc(bufr->rows,(bufr->rows * sizeof(PDMcatalogs)));

    if(catalogs == NULL)
      {
        MEMclose(&bufr);
       *status = PDM_E_COULD_NOT_MALLOC;
          _pdm_debug("PDMppl_query_for_catalogs: Exit", PDM_E_COULD_NOT_MALLOC);
        return;
       }

                
   for (i=0 ; i < bufr->rows; i++)
    {
      nxi = bufr->columns * i;

    (*catalogs+i)->n_catalogname[0] = '\0'; 
    strcpy((*catalogs+i)->n_catalogname, catalogs_data[nxi]); 
    strcpy((*catalogs+i)->n_catalogdesc, catalogs_data[nxi+1]); 
    strcpy((*catalogs+i)->n_type, catalogs_data[nxi+2]); 
    _PDMdebug("cat","%s\n",(*catalogs+i)->n_catalogname);

     }

     MEMclose(&bufr);

   *status = PDM_S_SUCCESS;
    PDUmessage(*status, 's');
          _pdm_debug("PDMppl_query_for_catalogs: Exit", PDM_S_SUCCESS);

}

void PDMppl_ris_query(status,query, rows, output_buffer_stream, ris_err_code)
  int    *status;   /* Output - Return status */
  char   *query;
  int    *rows;
  char   **output_buffer_stream;
  int    *ris_err_code;   /* Output - RIS error code */
{

  _PDMdebug("PDMppl_ris_query"," Enter");

       /* Display Message 
       PDUmessage(PDS_M_ADHOC_QUERY, 's');
           */
    
       _PDMdebug("PDMppl_ris_query","%s\n",query);

/*
    *status = PDMris_query(query,rows, output_buffer_stream, ris_err_code);
*/
    *status = PDMquery(query,rows, output_buffer_stream, ris_err_code,'~');
        if(*status != SQL_S_SUCCESS)
        {
            _pdm_debug("PDMquery: Exit %d\n", *status);
             return;
        } 
    if (PDM_debug_on) 
       _pdm_debug("PDMris_query: Output \n%s\n", *output_buffer_stream);
    PDUmessage(PDM_S_SUCCESS, 's');
          _pdm_debug("PDMris_query: Exit", PDM_S_SUCCESS);
}

void PDMppl_ris_stmt(status,statement, ris_err_code)
  int    *status;   /* Output - Return status */
  char   *statement;
  int    *ris_err_code;   /* Output - RIS error code */
{
  _pdm_debug("PDMppl_ris_stmt: Enter", 0);
       /* Display Message */
       PDUmessage(PDS_M_ADHOC_STMT, 's');
    *status = PDMris_stmt(statement,ris_err_code);
        if(*status != SQL_S_SUCCESS)
        {
            _pdm_debug("PDMris_stmt: Exit %d\n", *status);
             return;
        } 
    PDUmessage(PDM_S_SUCCESS, 's');
          _pdm_debug("PDMris_query: Exit", PDM_S_SUCCESS);
}

void PDMppl_query_bom (status, count, boms)
  int    *status;   /* Output - Return status */
  int    *count;    /* Output - Number of boms in the given catalog */
  PDMboms  *boms; /* Output - boms - An array of structures */
{

  char   **boms_data;
  int    i =0 , nxi = 0;
  char   sql_str[512];
  MEMptr bufr = NULL;

  _pdm_debug("PDMppl_query_for_boms: Enter", 0);


       /* Display Message */
       PDUmessage(PDS_M_SHOW_BOMS, 's');

      sql_str[0] = '\0';
        sprintf(sql_str,
        "SELECT %s FROM pdmboms ORDER BY p_bomname", 
                          "n_catalogno, n_itemno, p_bomname");
        *status = SQLquery(sql_str,&bufr,1024);
        if(*status != SQL_S_SUCCESS) {
                switch(*status) {
      	case SQL_I_NO_ROWS_FOUND :
         	_pdm_debug("No BOMS found \n");
         	_pdm_debug("PDMppl_query_bom : Exit", 
                                           PDM_E_NO_BOMS);
          	*status = PDM_E_NO_BOMS;
          return;
               
      default:
            _pdm_debug(" PDMppl_query_bom : Exit", PDM_E_SQL_QUERY);
             MEMclose(&bufr);
             *status = PDM_E_SQL_QUERY;
             return;
                    }
        } 

    if (PDM_debug_on) MEMprint_buffer("boms  buffer", bufr, PDU_DEBUG_FILE);

       *status  = MEMbuild_array(bufr);
        if(*status != MEM_S_SUCCESS) {
          MEMclose(&bufr);
          sprintf (s, "%s %d", "MEMbuild_array failed status ",*status);
          _pdm_debug(s, 0);
          return;
        }

       boms_data = (char **)bufr->data_ptr;

       /* 
         See the same place in query cat list fn for expn
      */

    *count = bufr->rows;

    *boms = ( PDMboms) calloc((bufr->rows + 1 ), 
                                 ((bufr->rows + 1) * sizeof(PDMboms)));

    if(boms == NULL) {
        MEMclose(&bufr);
       *status = PDM_E_COULD_NOT_MALLOC;
        _pdm_debug("PDMppl_query_bom: Exit", PDM_E_COULD_NOT_MALLOC);
        return;
       }

                
   for (i=0 ; i < bufr->rows; i++) {
    nxi = bufr->columns * i;
    (*boms+i)->n_catalogno = atol ( boms_data[nxi]); 
    (*boms+i)->n_itemno = atol ( boms_data[nxi+1]); 
    strcpy((*boms+i)->p_bomname, boms_data[nxi+2]); 
    _PDMdebug("BOM","%s\n",(*boms+i)->p_bomname);
   }

   MEMclose(&bufr);

   *status = PDM_S_SUCCESS;
   PDUmessage(*status, 's');
          _pdm_debug("PDMppl_query_bom: Exit", PDM_S_SUCCESS);
}





void PDMppl_set_alt_bom_switch (  status, alt_parent_attr )
  int    *status;   /* Output - Return status */
  char   *alt_parent_attr;
{

  _PDMdebug("PDMppl_set_alt_bom_switch"," Enter");

       _PDMdebug("PDMppl_set_alt_bom_switch","alt_par[%s]\n",
                                      alt_parent_attr);
       PDMalt_bom_on = 1;
       PDM_ALT_PARENT_ATTR[0] = '\0';
       strcpy (PDM_ALT_PARENT_ATTR, alt_parent_attr);
    
       _PDMdebug("PDMppl_set_alt_bom_switch","alt_par[%s]\n",
                                      PDM_ALT_PARENT_ATTR);
    PDUmessage(PDM_S_SUCCESS, 's');
    *status = PDM_S_SUCCESS;
    _pdm_debug("PDMset_alt_bom_switch: Exit", PDM_S_SUCCESS);
}


void PDMppl_reset_alt_bom_switch (  status )
  int    *status;   /* Output - Return status */
{

  _PDMdebug("PDMppl_reset_alt_bom_switch"," Enter");

       PDMalt_bom_on = 0;
       PDM_ALT_PARENT_ATTR[0] = '\0';
    
       _PDMdebug("PDMppl_reset_alt_bom_switch","alt_par[%s]\n",
                                      PDM_ALT_PARENT_ATTR);
    PDUmessage(PDM_S_SUCCESS, 's');
    *status = PDM_S_SUCCESS;
    _pdm_debug("PDMreset_alt_bom_switch: Exit", PDM_S_SUCCESS);
}
