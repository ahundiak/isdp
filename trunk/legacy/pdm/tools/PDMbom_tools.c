#include                <stdio.h>
#include                "SQLerrordef.h"
#include                "MEMerrordef.h"
#include                "NFMerrordef.h"
#include                "NFMapi.h"
#include                "NFMschema.h"
#include                "MEMstruct.h"
#include                "NFMstruct.h"
#include                "PDMdbs_err.h"
#include                "PDUerror.h"
#include                "dbadev.h"
#include                "rMRPstr.h"
#include                "MRPmessage.h"
#include                "PDMproto.h"


#include                        "PDMbom_strct.h"
static long                     status;
/*static char                   s[1024];*/
extern int                      PDMdebug_on;
extern char                     PDM_DEBUG_FILE[];
extern PDMexec_ptr              PDMexec;
extern PDMpart_ptr              PDMpart;
extern struct NFMglobal_st      NFMglobal;
extern int                      PDMalt_bom_on;
extern char                     PDM_ALT_PARENT_ATTR[];
  
int PDMadd_buffer_string(buff_string, position, char_string)
  char			*buff_string;
  int			*position;
  char			*char_string;
  {
    strcpy((buff_string + (*position)), char_string);
    (*position) += strlen(char_string);

    buff_string[(*position)++] = NULL;
    return(NFM_S_SUCCESS);
  }



void _PDMprint_bommember (name, mem)
char    *name;
struct PDMbom_member    *mem;
{
  char		s[2096];
  sprintf (s, 
" %s->level[%d], %s->citno[%d],  %s->type[%s], \n\
      %s->cat_no[%d], %s->cat_name[%s], \n\
      %s->item_no[%d], %s->item_name[%s], %s->item_rev[%s], \n\
      %s->pcat_no[%d], %s->pitem_no[%d], \n\
      %s->set_indicator[%s], %s->file_co[%s], \n\
      %s->ci_filename  [%s], %s->ci_sano[%d], %s->co_sano[%d], \n\
      %s->co_filename  [%s], %s->move[%d], %s->next[%lx]\n\
      %s-> quantity[%s], %s-> tagno [%d], %s-> pdcno[%d], \n\
      %s-> childno[%d], %s->attached[%s], %s->history[%s], \n\
      %s->orient[%s], %s->cattype[%s]\n\
      %s->usageid[%s], %s->viewid [%s], %s->alttagno[%s], \n\
      %s->incbom [%s], %s->explode[%s], \n\
      %s->dyn_cat_no [%d], %s->dyn_cat_name[%s]\n  ", 

  name, mem->level, 
  name, mem->citno, 
  name, mem->type, 
  name, mem->cat_no, 
  name, mem->cat_name, 
  name, mem->item_no, 
  name, mem->item_name, 
  name, mem->item_rev, 
  name, mem->pcat_no, 
  name, mem->pitem_no, 
  name, mem->set_indicator, 
  name, mem->file_co, 
  name, mem->ci_filename, 
  name, mem->ci_sano, 
  name, mem->co_sano, 
  name, mem->co_filename, 
  name, mem->move, 
  name, mem->next, 
  name, mem->quantity, 
  name, mem->tagno , 
  name, mem->pdcno, 
  name, mem->childno, 
  name, mem->attached, 
  name, mem->history, 
  name, mem->orient, 
  name, mem->file_class, 
  name, mem->usageid, 
  name, mem->viewid , 
  name, mem->alttagno, 
  name, mem->incbom , 
  name, mem->explode, 
  name, mem->dyn_cat_no, 
  name, mem->dyn_cat_name);
PDMdebug (s);
}


void _PDMprint_bommember_info (name, mem)
char    *name;
struct PDMbom_member    *mem;
{
  char		s[2096];
  sprintf (s, 
"%s->level[%d], %s->type[%s], \n\
      %s->catno[%d], %s->catnm[%s], \n\
      %s->itmno[%d], %s->itmnm[%s], %s->itmrv[%s], \n\
      %s->pcat[%d], %s->pitm[%d], %s->ci_fname[%s] \n\
      %s->move[%d], %s->citno[%d], %s->next[%lx], \n", 

  name, mem->level, 
  name, mem->type, 
  name, mem->cat_no, 
  name, mem->cat_name, 
  name, mem->item_no, 
  name, mem->item_name, 
  name, mem->item_rev, 
  name, mem->pcat_no, 
  name, mem->pitem_no, 
  name, mem->ci_filename, 
  name, mem->move, 
  name, mem->citno, 
  name, mem->next);
PDMdebug (s);
/*
  sprintf (s, 
"%s->level[%d], %s->type[%s], \n\
      %s->catno[%d], %s->catnm[%s], \n\
      %s->itmno[%d], %s->itmnm[%s], %s->itmrv[%s], \n\
      %s->pcat[%d] %s->pitm[%d]\
 %s->inbm[%s] %s->expl[%s] %s->att[%s], \n\
      %s->next[%lx], \n", 

  name, mem->level, 
  name, mem->type, 
  name, mem->cat_no, 
  name, mem->cat_name, 
  name, mem->item_no, 
  name, mem->item_name, 
  name, mem->item_rev, 
  name, mem->pcat_no, 
  name, mem->pitem_no, 
  name, mem->incbom , 
  name, mem->explode, 
  name, mem->attached, 
  name, mem->next);
PDMdebug (s);
*/
}



void _PDMget_double_from_buf_val (str, in_doub)
char	*str;
double	*in_doub;
{
   char		*fn = "_PDMget_double_from_buf_val";
   double	doub;
   int		i;
   char		str1[128];

  _PDMdebug ( fn, "ENTER\n" );
   for (i=0;i<127;i++) str1[i] = '\0';

   _PDMdebug (fn, "str[%s]\n", str);
       for (i=0; i< (strlen (str)); i++) {
         _PDMdebug ("opstr", "str[i] = %c \n", str[i]);
         if (isdigit (str[i]))
            str1[i] = str[i];
          else if (str[i] == '.') 
            str1[i] = str[i];
          }
        
       _PDMdebug (fn, " %s <=> %s\n", str, str1);

       doub = strtod (str, (char **)0);
       doub = atof (str1);
       *in_doub = doub;

       _PDMdebug  (fn, "doub [%f]\n", doub);

  _PDMdebug ( fn, "EXIT\n" );
}

int _PDMasc_to_doub (str, doub_str)
char	*str;
double	*doub_str;
{
   char		*fn = "_PDMasc_to_doub";
   double	doub;
   int		i, len;
   char		str1[128];
   char crhs[128];
   char clhs[128];
   long    lhs, rhs, pw;
   int          x, dec_pos;


  _PDMdebug ( fn, "ENTER\n" );
   for (i=0;i<127;i++) {
       str1[i] = '\0';
       clhs[i] = '\0';
       crhs[i] = '\0';
      }

/* first clean the str and remove any non digit chr */

   dec_pos = 0;
   for (i=0; i< (strlen (str)); i++) {
   /*   _PDMdebug ("opstr", "str[i] = %c \n", str[i]);*/
      if (isdigit (str[i]))
            str1[i] = str[i];
      else if (str[i] == '.') {
            str1[i] = str[i];
            dec_pos = i + 1;
         }
      }

   _PDMdebug ("cleaned str", "%s\n", str1);

   len = strlen (str1);

   _PDMdebug ("len", "%d: dec_pos: %d\n", len, dec_pos);
    doub = 0.0;
    x = 0;
    for (i = dec_pos; i < len; i++) {
         crhs[x] = str1[i];
         x++;
         }
    for (i = 0; i < dec_pos; i++) {
         clhs[i] = str1[i];
         }
       lhs = atol(clhs);
       rhs = atol(crhs);
      _PDMdebug (fn, "lhs[%d], rhs[%d]\n", lhs, rhs);

/*       lhs =  (lhs) * (pow (10, (len - dec_pos)));*/
/*      _PDMdebug  (fn, "lhs[%d], rhs[%d]\n", lhs, rhs);*/
      pw = 1;
      for (i=dec_pos;i<len;i++) pw = pw *10;

      _PDMdebug  (fn, "div_factor[%d]\n", pw );

       doub = (double) (rhs) / pw;

       _PDMdebug  (fn, "mantissa[%f]\n", doub);

       doub = lhs + doub;

        _PDMdebug (fn, "doub[%f]\n", doub);

       *doub_str = doub;

/*
    for (i = len; i > dec_pos; i--) {
        doub = doub + (double) (str1[i])/(pow (10, (i - dec_pos)));
        _PDMdebug (fn, "i[%d]:doub[%f]\n", i, doub);
        }

    for (i = 0; i < dec_pos; i++) {
        doub = doub + (double) (str1[i]) * (pow (10, (dec_pos - i)));
        _PDMdebug (fn, "i[%d]:doub[%f]\n", i, doub);
        }
    
        _PDMdebug (fn, "doub[%f]\n", doub);
*/



  _PDMdebug ( fn, "EXIT\n" );
  return (PDM_S_SUCCESS);
}


/* 
   if *bufr = NULL bufr1 is copied 
   if not the contents of bufr1 are appended to *bufr
   Note that the format of the buffers has to be the same 
*/

PDMappend(bufr, bufr1)
MEMptr		*bufr;
MEMptr		bufr1;
{
	char		**data;
	char		*s1;
	int			i, j;
	char		s[2096];

	PDMdebug("ENTER PDMappend \n");

        s[0] = '\0';

	if(*bufr == NULL)  
	{
	    status = MEMbuild_array(bufr1);
		if(status != MEM_S_SUCCESS)
		{
			sprintf(s, "%s %d %s", 
			"PDMappend :MEMbuild_array failed - status ", 
			status, "\n");
			PDMdebug(s);
			return(PDM_E_BUILD_ARRAY);
		}
		if(bufr1->rows)
		{
	 	   status = MEMsplit_copy_buffer(bufr1, bufr, 0);	
			if(status != MEM_S_SUCCESS)
			{
				sprintf(s, "%s %d %s", 
				"PDMappend :MEMsplit_copy_buffer failed - status ", 
				status, "\n");
				PDMdebug(s);
				return(PDM_E_COPY_BUFFER);
			}
		}
    }
    else
    {
		status = MEMbuild_array(bufr1);
		if(status != MEM_S_SUCCESS)
		{
			sprintf(s, "%s %d %s", 
			"PDMappend :MEMbuild_array failed - status ", 
			status, "\n");
			PDMdebug(s);
			return(PDM_E_BUILD_ARRAY);
		}
		data = (char **) bufr1->data_ptr;
		s1 = (char *) malloc(bufr1->row_size + 100);
		if(s1 == NULL)
		{
			PDMdebug("PDMappend : Failed to malloc \n");
			return(PDM_E_COULD_NOT_MALLOC);
		}
		for(i=0;i<bufr1->rows;i++)
		{
			s1[0] = '\0';
			for(j=0;j<bufr1->columns;j++)
			{
				strcat(s1, data[i*bufr1->columns+j]);	
				strcat(s1, "\1");
			}
		    status = MEMwrite(*bufr, s1);
			if(status != MEM_S_SUCCESS)
			{
				free(s1);
				sprintf(s, "%s %d \n", 
				"PDMappend : MEMwrite failed status ", 
				status);
				PDMdebug(s);
				return(PDM_E_WRITE_ROW);
			}
		}   /* for all rows */
		free(s1);
     }
	 PDMdebug("EXIT PDMappend\n");
	 return(PDM_S_SUCCESS);
}


int _PDMupdate_pdmboms (cat_no, item_no, exist_bom)
char		*exist_bom;
int		cat_no, item_no;
{
	char		*fn = "_PDMupdate_pdmboms";
	char		date[128];
	char		in_date[128];
	char		sql_str [512];

   _PDMdebug ("ENTER", "%s\n", fn);
   
    _PDMdebug (fn, "Updating pdmboms for %d.%d.%s\n", 
                                    cat_no, item_no, exist_bom);


     date [0] ='\0';
     in_date [0] ='\0';
     status = NFMget_datetime (date) ;
     if (status != NFM_S_SUCCESS) {
      _PDMdebug (fn, "NFMget_datetime failed : status = <0x%x.8>\n", status) ;
       return (status) ;
       }

     _PDMdebug (fn, "in_date [%s]\n", in_date);

     status = NFMascii_to_timestamp_format (date, in_date) ;
     if (status != NFM_S_SUCCESS) {
              _PDMdebug (fn, "ascii to timestamp:status = <0x%.8x>\n", status);
              return (status) ;
        }

     _PDMdebug (fn, "in_date [%s]\n", in_date);

     sprintf (sql_str, 
     "INSERT INTO pdmboms ( %s ) VALUES (%d, %d, TIMESTAMP '%s', '%s', '%s' )",
     "n_catalogno, n_itemno, p_createdate, p_bomname, p_locked",
       cat_no, item_no, in_date, exist_bom, "N"); 
     
      status = SQLstmt (sql_str);
      if (status != SQL_S_SUCCESS) {
         _PDMdebug (fn, "SQLstatement : status : %d\n", status );
          return (status);
        }

   _PDMdebug ("EXIT", "%s\n", fn);
   return (PDM_S_SUCCESS);
}
    

long PDMget_dyntable_for_catalog(char *catalog, char * dyn_table)
{
MEMptr dyn_bufr = NULL;
char   **dyn_data = NULL;
char   del_str[512];
char   *fname = "PDMget_dyntable_for_catalog";
      
       _PDMdebug(fname,"Enter:\n");
/*
sprintf(del_str,"SELECT t2.p_dyntable FROM nfmcatalogs t1,pdmcatalogs t2 where t1.n_catalogno = t2.n_catalogno AND t1.n_catalogname = '%s'", catalog);
*/
        sprintf(del_str,
        "SELECT %s FROM %s where %s AND %s '%s' AND %s ", 
        " t2.p_dyntable ",
        " nfmcatalogs t1,pdmcatalogs t2 ",
        " t1.n_catalogno = t2.n_catalogno ",
        " t1.n_catalogname = ",
        catalog, " NOT (t2.p_dyntable is NULL) ");

        status = SQLquery(del_str,&dyn_bufr,512);
         if(status == SQL_S_SUCCESS) {
           status = MEMbuild_array (dyn_bufr);
            if(status != MEM_S_SUCCESS) {
        _PDMdebug (fname, "MEMbuild_array : status = <0x%.8x>\n", status);
        return (status);
             }
             dyn_data = (char **) dyn_bufr->data_ptr;
             dyn_table[0] = '\0';
              strcpy(dyn_table, dyn_data[0]);
           }
            else dyn_table [0] = '\0';
       _PDMdebug(fname,"Exit:\n");
   return(PDM_S_SUCCESS);
}
  

int _PDMi_get_dyn_catname(catno, y_catname)
int	catno;
char	*y_catname;
{
	char		*fn = "PDMi_get_dyn_catname";
	char		**q_data;
	MEMptr		qry_bufr = NULL;
	char		sql_str[1024];

 _PDMdebug ("ENTER", "%s\n", fn);
  sprintf (sql_str, 
            "SELECT p_dyntable FROM pdmcatalogs WHERE n_catalogno = %d",
                                                              catno);
  status = SQLquery (sql_str, &qry_bufr, MEM_SIZE);
  if (status != SQL_S_SUCCESS) {
    MEMclose (&qry_bufr);
    _PDMdebug ( fn, "SQLquery 0x%.8x\n", status) ;
    return (status);
  }


  status = MEMbuild_array (qry_bufr);
  if (status != MEM_S_SUCCESS) {
    MEMclose (&qry_bufr);
    _PDMdebug ( fn, "MEMbuild_query (qry_bufr) 0x%.8x\n", status );
    return (status);
  }

 if (PDMdebug_on) {
    MEMprint_buffer("qry_bufr from query", qry_bufr, PDM_DEBUG_FILE);
 }

  q_data = (char **) qry_bufr->data_ptr;
  strcpy (y_catname, q_data[0]);
  _PDMdebug (fn, "y_catname[%s]\n", y_catname);
  MEMclose (&qry_bufr);
 _PDMdebug ("EXIT", "%s\n", fn);
 return (PDM_S_SUCCESS);
}


