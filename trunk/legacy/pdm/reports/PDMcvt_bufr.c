#include	<stdio.h>
#include                "dbadev.h"
#include	"rMRPstr.h"
#include 	"MRPmessage.h"
#include                "PDUerror.h"
#include                "MEMstruct.h"
#include                "MEMerrordef.h"
#include                "NFMerrordef.h"
#include                "SQLerrordef.h"
#include                "PDMproto.h"




/* Kumar - data structure conversion for
   communicating in to PSU routines  1/30/92 */

int PDMcvt_bufr_struct (def_op, def_list, list_total, 
                         process, template_type, templib , where, psurpt)

MEMptr  def_op;
MEMptr  def_list;
int  list_total;
int  process;
char *template_type;
char *templib;
char *where;
struct PSUrpt	*psurpt;
{
  int	i, nxi;
  static char *fname = "PDMcvt_bufr_struct";
  char   **op_data, **list_data;
  long	status = PDM_S_SUCCESS;

_PDMdebug(fname, "ENTER: \n");
  status = MEMbuild_array(def_op);
        if(status != MEM_S_SUCCESS)
        {
       MEMclose(&def_op);
       MEMclose(&def_list);
       _PDMdebug(fname, "MEMbuild_array failed : status %d\n", status);
        return(PDM_E_BUILD_ARRAY);
        } 
   op_data = (char **) def_op->data_ptr;
  status = MEMbuild_array(def_list);
        if(status != MEM_S_SUCCESS)
        {
       MEMclose(&def_op);
       MEMclose(&def_list);
       _PDMdebug(fname, "MEMbuild_array failed : status %d\n", status);
        return(PDM_E_BUILD_ARRAY);
        } 
   list_data = (char **) def_list->data_ptr;

    psurpt->list = (struct dba_default_list *) calloc(list_total, (list_total+1 * sizeof(struct dba_default_list)));

_PDMdebug(fname, "Loading options: \n");
        
  /* update format values in database */
 if(strcmp(op_data[0], "") && op_data[0] != NULL) strcpy(psurpt->options.table , op_data[0]);
 else strcpy(psurpt->options.table , "");
 if(strcmp(op_data[1], "") && op_data[1] != NULL)  strcpy(psurpt->options.template_name, op_data[1]);
 else  return(PDM_E_REPORT_NAME_NULL);
 if(strcmp(op_data[2], "") && op_data[2] != NULL)strcpy(psurpt->options.description, op_data[2]);
 else strcpy(psurpt->options.description , "");
 if(strcmp(op_data[3], "") && op_data[3] != NULL) strcpy(psurpt->options.output, op_data[3]);
 else strcpy(psurpt->options.output , "");
 if(strcmp(op_data[4], "") && op_data[4] != NULL) strcpy(psurpt->options.title, op_data[4]);
 else strcpy(psurpt->options.title , "");
psurpt->options.subtotals = atoi(op_data[5]);
psurpt->options.totals = atoi( op_data[6]);
psurpt->options.width = atoi(op_data[7]);
psurpt->options.lines = atoi(op_data[8]);

psurpt->list_total = list_total;
 if (process != 0) psurpt->process = process;
   psurpt->where = (char *) malloc (strlen(where) +1 );
   psurpt->templib = (char *) malloc (strlen(templib) +1 );
strcpy(psurpt->where, where);
strcpy(psurpt->templib, templib);
strcpy(psurpt->templatetype , template_type);
   psurpt->justification = (int *) malloc ( sizeof(int) * 200 );
     memset(psurpt->justification, NULL, (sizeof(int) *200));
    /*
  for(i= 0; i < list_total ; i++)
    {
   psurpt->justification[i] = op_data[9][i] - '0';
    }
     */
       

_PDMdebug(fname, "Loading list: \n");

for ( i = 0; i < def_list->rows; ++i )
   {
       nxi = i * def_list->columns;

strcpy(psurpt->list[i].name, list_data[nxi]);
strcpy(psurpt->list[i].header, list_data[nxi+1]);
psurpt->list[i].type = atoi(list_data[nxi+2]);
psurpt->list[i].start = atoi(list_data[nxi+3]);
psurpt->list[i].length = atoi(list_data[nxi+4]);
psurpt->list[i].decimal = atoi(list_data[nxi+5]);
psurpt->list[i].sort = atoi(list_data[nxi+6]);
psurpt->list[i].subtotal = atoi(list_data[nxi+7]);
psurpt->list[i].total = atoi(list_data[nxi+8]);
   psurpt->justification[i] = atoi(list_data[nxi+9]);

    }

/*      MEMclose(&def_op);*/
/*      MEMclose(&def_list);*/

_PDMdebug(fname, "EXIT: \n");
  return (PDM_S_SUCCESS);
}



int PDMcvt_struct_bufr (def_op, def_list, list_total, 
                         process, template_type, templib, where, psurpt)
MEMptr  *def_op;
MEMptr  *def_list;
int  *list_total;
int  *process;
char *template_type;
char *templib;
char *where;
struct PSUrpt	psurpt;
{
  int	i;
  static char *fname = "PDMcvt_struct_bufr";
  char   mem_str[1024];
  long	status = PDM_S_SUCCESS;

_PDMdebug(fname, "ENTER: \n");

/* ANSI */
template_type = NULL;
templib = NULL;
where = NULL;

        status = PDMcreate_dba_op(def_op);
        if(status != PDM_S_SUCCESS)
        {
       MEMclose(&def_op);
       _PDMdebug(fname, "MEMopen failed : status %d\n", status);
        return(NFM_E_MEM);
        } 
        status = PDMcreate_dba_list(def_list);
        if(status != PDM_S_SUCCESS)
        {
       MEMclose(&def_op);
       _PDMdebug(fname, "MEMopen failed : status %d\n", status);
        return(NFM_E_MEM);
        } 

    

 *list_total = psurpt.list_total;
 *process = psurpt.process;
   if (psurpt.where != NULL)
      {
       /* *where = (char *) malloc (strlen(psurpt.where) + 1); 
        strcpy(where, psurpt.where); */
       }
   if (psurpt.templatetype != NULL)
      {
      /*  *template_type = (char *) malloc (strlen(psurpt.templatetype) + 1); 
        strcpy(template_type , psurpt.templatetype); */
       }
   if (psurpt.templib != NULL )
      {
   /*  *templib = (char *) malloc (strlen(psurpt.templib) + 1); 
        strcpy(templib , psurpt.templib); */
       }

   mem_str[0] = '\0';
   sprintf(mem_str, "%s\1%s\1%s\1%s\1%s\1%d\1%d\1%d\1%d\1", psurpt.options.table, \
                    psurpt.options.template_name, psurpt.options.description, \
                    psurpt.options.output, psurpt.options.title, \
                    psurpt.options.subtotals, psurpt.options.totals, \
                    psurpt.options.width, psurpt.options.lines);
       status = MEMwrite(*def_op, mem_str);
        if(status != MEM_S_SUCCESS)
        {
       MEMclose(&def_op);
       MEMclose(&def_list);
       _PDMdebug(fname, "MEMwrite1 failed : status %d\n", status);
        return(NFM_E_MEM);
        } 

for ( i = 0; i < psurpt.list_total; ++i )
   {

   mem_str[0] = '\0';
   sprintf(mem_str, "%s\1%s\1%d\1%d\1%d\1%d\1%d\1%d\1%d\1%d\1", psurpt.list[i].name, psurpt.list[i].header, psurpt.list[i].type, psurpt.list[i].start, psurpt.list[i].length , psurpt.list[i].decimal , psurpt.list[i].sort , psurpt.list[i].subtotal , psurpt.list[i].total , psurpt.justification[i]);

       status = MEMwrite(*def_list, mem_str);
        if(status != MEM_S_SUCCESS)
        {
       MEMclose(&def_op);
       MEMclose(&def_list);
       _PDMdebug(fname, "MEMwrite1 failed : status %d\n", status);
        return(NFM_E_MEM);
        } 
    }


_PDMdebug(fname, "EXIT: \n");
  return (PDM_S_SUCCESS);

}


int PDMcreate_dba_op ( attr_list)
MEMptr   *attr_list;
{
      static char *fname = "PDMcreate_dba_op" ;
      long     status;

       PDMdebug("ENTER: PDMcreate_dba_op\n");

      status = MEMopen (attr_list, 1024);

      if (status != MEM_S_SUCCESS)
       {
         _PDMdebug (fname, "MEM Open : status = <0x%.8x>\n", status);
         return (NFM_E_MEM);
       }
         status = MEMwrite_format (*attr_list, "table", "char(31)");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
         status = MEMwrite_format (*attr_list, "template_name", "char(21)");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
         status = MEMwrite_format (*attr_list, "description", "char(51)");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
         status = MEMwrite_format (*attr_list, "output", "char(51)");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
         status = MEMwrite_format (*attr_list, "title", "char(51)");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
        return (NFM_E_MEM);
          }
         status = MEMwrite_format (*attr_list, "subtotals", "integer");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
         status = MEMwrite_format (*attr_list, "totals", "integer");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
         status = MEMwrite_format (*attr_list, "width", "integer");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
         status = MEMwrite_format (*attr_list, "lines", "integer");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }

      _PDMdebug (fname, "SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS);
      return (PDM_S_SUCCESS);
   }


int PDMcreate_dba_list ( attr_list)
MEMptr   *attr_list;
{
      static char *fname = "PDMcreate_dba_list" ;
      long     status;

       PDMdebug("ENTER: PDMcreate_dba_list\n");

      status = MEMopen (attr_list, 1024);

      if (status != MEM_S_SUCCESS)
       {
         _PDMdebug (fname, "MEM Open : status = <0x%.8x>\n", status);
         return (NFM_E_MEM);
       }
         status = MEMwrite_format (*attr_list, "name", "char(19)");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
         status = MEMwrite_format (*attr_list, "header", "char(31)");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
         status = MEMwrite_format (*attr_list, "type", "integer");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
         status = MEMwrite_format (*attr_list, "start", "integer");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
         status = MEMwrite_format (*attr_list, "length", "integer");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
        return (NFM_E_MEM);
          }
         status = MEMwrite_format (*attr_list, "decimal", "integer");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
         status = MEMwrite_format (*attr_list, "sort", "integer");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
         status = MEMwrite_format (*attr_list, "subtotal", "integer");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
         status = MEMwrite_format (*attr_list, "total", "integer");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
         status = MEMwrite_format (*attr_list, "p_justification", "integer");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }


      _PDMdebug (fname, "SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS);
      return (PDM_S_SUCCESS);
}

int PDMinit_psurpt(psurpt)
struct PSUrpt *psurpt ;
 {
        PDMdebug("ENTER:PDMinit_psurpt\n");
   strcpy(psurpt->options.table, "");
   psurpt->options.template_name[0] = '\0';
   strcpy(psurpt->options.description, "");
   strcpy(psurpt->options.output, "");
   strcpy(psurpt->options.title, "");
   strcpy(psurpt->templatetype, "");
   psurpt->options.subtotals = 0;
   psurpt->options.totals = 0;
   psurpt->options.width = 0;
   psurpt->options.lines = 0;
   psurpt->list = NULL;
   psurpt->list_total = 0;
   psurpt->where = NULL;
   psurpt->templib = NULL;
        PDMdebug("EXIT:PDMinit_psurpt\n");
   return(1);
 }

