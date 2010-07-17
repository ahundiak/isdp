/* $Id: VRhvacdb.c,v 1.1.1.1 2001/01/04 21:13:02 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrpdu / VRhvacdb.c
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRhvacdb.c,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:02  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.2  1997/08/15  19:34:34  pinnacle
 * Replaced: vrpdu for:  by hverstee for route
 *
 * Revision 1.1  1996/07/25  18:25:44  pinnacle
 * Creation of Route 241 project
 *
 * Revision 1.6  1996/04/22  13:57:54  pinnacle
 * Replaced: vrpdu/VRhvacdb.c for:  by hverstee for route240
 *
 * Revision 1.5  1996/01/17  17:31:14  pinnacle
 * Replaced: vrpdu/VRhvacdb.c for:  by r240_int for route240
 *
 *
 * History:
 *	01/17/96   tlb	Add prototypes
 *
 *************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "OMminimum.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "VRdef.h"
#include "VRDbStruct.h"
#include "dberror.h"
#include "VRmsg.h"
/*   #include "sql.h" This is for RIS 4.0 */
#include "ris.h" 
#include "VRDbTbl.h"
#include "vrpdu_pto.h"

#define VRSEPARATOR	','
#define VRRANGECHAR	'R'

#if 0

/**************************************************************/
/*   these static externals to be initialized at DB change    */
static int    curr_hvselcod_tab_size = 0;
static int    hvselcodslot_num = 0;
static struct hvselcodtable hvselcod_tab[VR_MAX_HVSELCOD_TABLE_SIZE];
/**************************************************************/
/*    clear cache function                                    */

void VR_DbC_Clhvc ()
{
  int      i;

  for (i=0; i<VR_MAX_HVSELCOD_TABLE_SIZE; i++)
  {
    hvselcod_tab[i].code_num      = 0;
    hvselcod_tab[i].param_type    = 0;
    hvselcod_tab[i].param_name[0] = '\0';
  }

  curr_hvselcod_tab_size = 0;
  hvselcodslot_num       = 0;

  return;
}
/**************************************************************/

int VRDbParseSel (char         *crit_str,  /* Criteria string           (I) */
           struct VRSelectAttr  seldata[], /* Select Criteria structure (O) */
                  short        *crit_no)   /* No of select criteria     (O) */

{
   /*********************************************************************/
   /*                                                                   */
   /* This routine parses the select criteria string, extracts the      */
   /* code_nums, determine range dependencies and returns the number    */
   /* of select criteria                                                */
   /*                                                                   */
   /*********************************************************************/

  short         nEnd=0;
  short         nIndexAttr = 0;
  char          *p_cSep=NULL, *p_cAttr;
  char          *strchr();

  *crit_no = 0;
  if ( !crit_str ) return 1;

  /* point on first attribute */
  p_cAttr = crit_str;

  /* look for separator */

  while (!nEnd)
  {
        /* restore separator */
        if (p_cSep)     *p_cSep = VRSEPARATOR;


        if ( ! (p_cSep = strchr(p_cAttr,VRSEPARATOR)))
        {
                nEnd=1;
                /* Points on the end */
                p_cSep = &p_cAttr[strlen(p_cAttr)];
        }

        /* isolate attribute */
        *p_cSep = '\0';

        /* look for range character */
        if ( *(p_cSep-1) == VRRANGECHAR && *(p_cSep-2) == ' ')
        {
                seldata[nIndexAttr].range = 1;
                *(p_cSep-2) = '\0';
                /* store attribute name */
                strcpy(seldata[nIndexAttr].sel.name, p_cAttr);
                /* restore criteria string */
                *(p_cSep-2) = ' ';
                *(p_cSep-1) = VRRANGECHAR;
        }
        else
        {
            seldata[nIndexAttr].range = 0;
            /* store attribute number */
            strcpy(seldata[nIndexAttr].sel.name, p_cAttr);
        }

        /* point on next attribute */
        nIndexAttr++;
        p_cAttr = p_cSep+1;

  }/* end while */

  *crit_no = nIndexAttr;
  return (1);
}

int VRdbget_hvac_select_codes ( code_num, param_name, param_type, 
                                   type, err_ptr)
    short   code_num;     /* Code number                      (I) */
    char    *param_name;  /* Parameter name                   (O) */
    short   *param_type;  /* Parameter data type              (O) */
    short   *type;        /* Parameter data type for ACrg_coll(O) */
    char    *err_ptr;     /* Error message  buffer            (O) */
{

   /*********************************************************************/
   /*                                                                   */
   /* This routine extracts the parameter name and parameter type of    */
   /* a given code_num from the HVAC_SELECT_CODES table                 */
   /*                                                                   */
   /*********************************************************************/

  int		sts, i;
  struct VRrisdat       outdata[50];
  int           rows;
  int           cols;
  int           par_cnt;
  char		*table=NULL;		/* table name */
  char		*select=NULL;    	/* select list */
  char		search[MAX_WHERE_SIZE];		/* where clause of a select */
  char          ris_str[MAX_RIS_STR_SIZE];
  char          disp_err[100];     


     /* IF IN CACHE */
     /*-------------*/
     for(i = 0; i < curr_hvselcod_tab_size; ++i)
     {
        if(code_num == hvselcod_tab[i].code_num)
        {
#ifdef DEBUG
printf(" Retrieving from cache\n");
#endif
          strcpy(param_name, hvselcod_tab[i].param_name);
          *param_type = hvselcod_tab[i].param_type;
          if(*param_type == VR_RISDB_TEXT)
            *type = AC_ATTRIB_TEXT;
          else if (*param_type == VR_RISDB_INT ||
                   *param_type == VR_RISDB_DOUBLE)
            *type = AC_ATTRIB_DOUBLE;

          return (1);
        }
     }
     /* ACCESS HVAC SELECT CODES TABLE */
     /*--------------------------------*/
#ifdef DEBUG
printf(" Accessing hvac select codes table\n");
#endif
     table = "hvac_select_codes";
     select =  "*";
     sprintf( search, "WHERE code_num = %d", code_num );
     sprintf( ris_str,"SELECT %s FROM %s %s", select, table, search );

     sts = RISexecute_query( ris_str, outdata,&rows,&cols,&par_cnt);
     if (sts != 1 || rows == 0)
     {
        if(err_ptr == NULL)
        {
          printf("Failed accessing %s.\n", table);
          printf("SELECT <%s>\nFROM <%s>\n%s\n ", select, table, search);
        }
        sprintf(disp_err,"code_num %d",code_num);
        VRdb_err_msg(VR_E_DbLongErrMsg,err_ptr,table,"Row",disp_err);
        return(0);
     }

     /* CACHE THE EXTRACTED ROW */
     /*-------------------------*/
#ifdef DEBUG
printf(" Current hvselcod tab size:%d\n",curr_hvselcod_tab_size);
#endif
     if(curr_hvselcod_tab_size <= VR_MAX_HVSELCOD_TABLE_SIZE - 1)
     {
       hvselcod_tab[curr_hvselcod_tab_size].code_num = code_num;
       strcpy (hvselcod_tab[curr_hvselcod_tab_size].param_name, outdata[1].data.val.attr_c);
       hvselcod_tab[curr_hvselcod_tab_size].param_type = (short)outdata[2].data.val.attr_int;
       if(outdata[2].data.val.attr_int == VR_HVSELCOD_TEXT)
         hvselcod_tab[curr_hvselcod_tab_size].param_type = VR_RISDB_TEXT;
       else if(outdata[2].data.val.attr_int == VR_HVSELCOD_INT)
         hvselcod_tab[curr_hvselcod_tab_size].param_type = VR_RISDB_INT;
       else if(outdata[2].data.val.attr_int == VR_HVSELCOD_DOUBLE)
         hvselcod_tab[curr_hvselcod_tab_size].param_type = VR_RISDB_DOUBLE;
       curr_hvselcod_tab_size++;
     }
     else
     {
       if( hvselcodslot_num> VR_MAX_HVSELCOD_TABLE_SIZE - 1)
       {
         hvselcodslot_num = 0;
       }
#ifdef DEBUG
printf(" Current hvselcodslot_num:%d\n",hvselcodslot_num);
#endif
       hvselcod_tab[hvselcodslot_num].code_num = code_num;
       strcpy(hvselcod_tab[hvselcodslot_num].param_name, outdata[1].data.val.attr_c);  
       hvselcod_tab[hvselcodslot_num].param_type = (short)outdata[2].data.val.attr_int;
       if(outdata[2].data.val.attr_int == VR_HVSELCOD_TEXT)
         hvselcod_tab[hvselcodslot_num].param_type = VR_RISDB_TEXT;
       else if(outdata[2].data.val.attr_int == VR_HVSELCOD_INT)
         hvselcod_tab[hvselcodslot_num].param_type = VR_RISDB_INT;
       else if(outdata[2].data.val.attr_int == VR_HVSELCOD_DOUBLE)
         hvselcod_tab[hvselcodslot_num].param_type = VR_RISDB_DOUBLE;
       hvselcodslot_num++;
     } 
     strcpy(param_name, outdata[1].data.val.attr_c);
     *param_type = (short)outdata[2].data.val.attr_int;
     if(*param_type == VR_HVSELCOD_TEXT)
        *param_type = VR_RISDB_TEXT;     
     else if(*param_type == VR_HVSELCOD_INT)
        *param_type = VR_RISDB_INT;     
     if(*param_type == VR_HVSELCOD_DOUBLE)
        *param_type = VR_RISDB_DOUBLE;     

     if(*param_type == VR_RISDB_TEXT)
         *type = AC_ATTRIB_TEXT;
     else if (*param_type == VR_RISDB_INT ||
              *param_type == VR_RISDB_DOUBLE)
         *type = AC_ATTRIB_DOUBLE;
     return(1);
}



int VRdbform_hvac_dyn_search_str ( seldata, crit_no, search )

   struct VRSelectAttr  seldata[]; /* Select criteria structure  (I) */
   short                 *crit_no;  /* No. of select criteria     (I) */
   char                  *search;   /* Search string              (O) */
{
     /*****************************************************************/
     /*                                                               */
     /* This routine forms the dynamic search string for accessing    */
     /* HVAC catalog                                                  */
     /*                                                               */
     /*****************************************************************/
   
     int        i,flag;
     char       tmp_str[100];

  
     strcpy(search, "where");
     flag = 0;
     for (i=0; i<*crit_no; i++)
     {
         if(seldata[i].type == VR_RISDB_TEXT)
         {
            if(flag)
               strcat(search, " and ");
            else
               strcat(search, " ");               
            sprintf(tmp_str, "%s = '%s'", seldata[i].sel.name, seldata[i].sel.desc.value.att_txt);
            strcat(search, tmp_str);
            flag = 1;
         }
         else if(seldata[i].type == VR_RISDB_INT)
         {
            if(flag)
            {
               strcat(search, " and ");
            }
            else
               strcat(search, " ");               
            if(seldata[i].range)
            {
              sprintf(tmp_str, "%d between %s_min and %s_max",
                      (int)seldata[i].sel.desc.value.att_exp, 
                       seldata[i].sel.name, 
                       seldata[i].sel.name );
            }
            else
            {
              sprintf(tmp_str, "%s = %d", seldata[i].sel.name, 
                      (int)seldata[i].sel.desc.value.att_exp);    
            }
            strcat(search, tmp_str);
            flag = 1;
         }
         else if(seldata[i].type == VR_RISDB_DOUBLE)
         {
            if(flag)
            {
               strcat(search, " and ");
            }
            else
               strcat(search, " ");               
            if(seldata[i].range)
            {
              sprintf(tmp_str, "%lf between %s_min and %s_max",
                      seldata[i].sel.desc.value.att_exp, 
                      seldata[i].sel.name, 
                      seldata[i].sel.name );
            }
            else
            {
              sprintf(tmp_str, "%s = %lf", seldata[i].sel.name, 
                      seldata[i].sel.desc.value.att_exp);    
            }
            strcat(search, tmp_str);
            flag = 1;
         }
      }
      return (1);

}
 

int VRdbacc_hvac_catalog ( catalog, search, macro_name,mac_pm, 
                              pm_no, err_ptr ) 

   char     *catalog;             /* hvac catalog name             (I)   */
   char     *search;              /* search string "where .."      (I)   */
   char     *macro_name;          /* Macro name                    (O)   */
   struct ACrg_coll mac_pm[];     /* macro parameters              (O)   */
   int      *pm_no;               /* No. of params in mac_pm       (I/O) */
   char     *err_ptr;             /* Error message buffer          (O)   */
{
  char          dum;
  int		sts;
  struct VRrisdat 	outdata[MAX_RIS_QUERY_PAR];
  int           rows;
  int           cols;
  int           par_cnt;
  char		table[MAX_ATTR_LEN];		/* table name */
  char		*select=NULL;    	/* select list */
  char          ris_str[MAX_RIS_STR_SIZE];
  int           currcol;

/* Load catalog part */
#ifdef DEBUG 
printf("  Accessing HVAC catalog\n");
#endif

    dum = macro_name[0];

UI_status("Processing.         ");

    sprintf( table , "%s",catalog);
    select = "*";
    sprintf( ris_str,"SELECT %s FROM %s %s", select, table, search );

    sts = RISexecute_query( ris_str, outdata, &rows, &cols, &par_cnt);
    if (sts != 1 || rows == 0)
    {
        if(err_ptr == NULL)
        {
           printf("Error locating part in HVAC catalog\n");
           printf("Catalog name: <%s>\n", catalog);
           printf("Select: <%s>\n",select);
           printf("Search criteria: <%s>\n", search);
        }
        VRdb_err_msg(VR_E_DbLongErrMsg,err_ptr,table,"Row",search);
        return (0);
    }

UI_status("Processing..        ");


/* Load parameters into mac_pm */

#ifdef DEBUG
printf("  Loading collection\n");
#endif
        currcol = 0;
        while(currcol < par_cnt)
        {
           /* skip all PDM, NFM columns if any */

           if(strncmp(outdata[currcol].name, "p_", 2) == NULL ||
              strncmp(outdata[currcol].name,"n_", 2) == NULL   )
           {
              currcol++;
              continue;
           }
           strcpy(mac_pm[*pm_no].name, outdata[currcol].name);

           if(outdata[currcol].data.type == VR_RISDB_TEXT)
           {
             strcpy(mac_pm[*pm_no].desc.value.att_txt, outdata[currcol].data.val.attr_c);
             mac_pm[*pm_no].desc.type = AC_ATTRIB_TEXT;
             *pm_no += 1;
           }
           else if (outdata[currcol].data.type == VR_RISDB_INT)
           {
             mac_pm[*pm_no].desc.value.att_exp = (double)outdata[currcol].data.val.attr_int;
             mac_pm[*pm_no].desc.type = AC_ATTRIB_DOUBLE;
             *pm_no += 1;
           }
           else if (outdata[currcol].data.type == VR_RISDB_DOUBLE)
           {
             mac_pm[*pm_no].desc.value.att_exp = outdata[currcol].data.val.attr_dbl;
             mac_pm[*pm_no].desc.type = AC_ATTRIB_DOUBLE;
             *pm_no += 1;
           }
           currcol += 1;
        }

UI_status(" ");

	return (1);
}

int VRdbGetRisColType ( table_name, param_name, range, param_type, type, err_ptr)

    char    *table_name;  /* table name                       (I) */
    char    *param_name;  /* Parameter name                   (I) */
    short   *range;       /* Range flag                       (I) */
    short   *param_type;  /* Parameter data type              (O) */
    short   *type;        /* Parameter data type for ACrg_coll(O) */
    char    *err_ptr;     /* Error message  buffer            (O) */
{

  int		sts;
  struct VRrisdat       outdata[10];
  int           rows;
  int           cols;
  int           par_cnt;
  char		*table=NULL;		/* table name */
  char		*select=NULL;    	/* select list */
  char		search[MAX_WHERE_SIZE];		/* where clause of a select */
  char          ris_str[MAX_RIS_STR_SIZE];
  char          disp_err[100];     
  char          column_name[200];
 
     /* FORM THE COLUMN NAME  */

     if(*range == 1)
      sprintf(column_name, "%s_min", param_name);
     else
      sprintf(column_name, "%s", param_name);
 

     /* ACCESS RISCOLUMNS TABLE */
     /*-------------------------*/


     table = VRDB_RISCOLUMNS;
     select =  "ris_type";
     sprintf( search, "WHERE  table_name = '%s' and column_name = '%s'", 
                      table_name, column_name );
     sprintf( ris_str,"SELECT %s FROM %s %s", select, table, search );

     sts = RISexecute_query( ris_str, outdata,&rows,&cols,&par_cnt);
     if (sts != 1 )
     {
        if(err_ptr == NULL)
        {
         printf("Failed accessing %s.\n", table);
         printf("SELECT <%s>\nFROM <%s>\n%s\n ", select, table, search);
        }
        sprintf(disp_err,"table_name %s,column_name, %s",table_name, column_name);
        VRdb_err_msg(VR_E_DbLongErrMsg,err_ptr,table,"Row",disp_err);
        return(0);
     }
     else if(rows == 0 )
     {
         if(err_ptr == NULL)
         {
          printf("Column %s undefined in catalog %s\n", column_name, table_name);
         }
         VRdb_err_msg(VR_E_CatColNotFound, err_ptr,column_name, table_name, NULL); 
         return (0);
     }
     *param_type = (short)outdata[0].data.val.attr_int;
     if(outdata[0].data.val.attr_int == CHARACTER)
     {
       *param_type = VR_RISDB_TEXT;
       *type = AC_ATTRIB_TEXT;
     }
     else if(outdata[0].data.val.attr_int == INTEGER   ||
             outdata[0].data.val.attr_int == SMALLINT )
     {
       *param_type = VR_RISDB_INT;
       *type = AC_ATTRIB_DOUBLE;
     }
     else if(outdata[0].data.val.attr_int == FLOAT   ||
             outdata[0].data.val.attr_int == REAL    ||
             outdata[0].data.val.attr_int == DOUBLE_PRECISION    ||
             outdata[0].data.val.attr_int == DOUBLE )
     {
       *param_type = VR_RISDB_DOUBLE;
       *type = AC_ATTRIB_DOUBLE;
     }

     return(1);
}


int VRdbChkRisTblExists ( table_name, err_ptr)

    char    *table_name;  /* table name                       (I) */
    char    *err_ptr;     /* Error message  buffer            (O) */
{

  int		sts;
  struct VRrisdat       outdata[10];
  int           rows;
  int           cols;
  int           par_cnt;
  char		*table=NULL;		/* table name */
  char		*select=NULL;    	/* select list */
  char		search[MAX_WHERE_SIZE];		/* where clause of a select */
  char          ris_str[MAX_RIS_STR_SIZE];
  char          disp_err[100];     
 
 

     /* ACCESS RISTABLES TABLE */
     /*------------------------*/


     table = VRDB_RISTABLES;
     select =  "*";
     sprintf( search, "WHERE  table_name = '%s'", 
                      table_name );
     sprintf( ris_str,"SELECT %s FROM %s %s", select, table, search );

     sts = RISexecute_query( ris_str, outdata,&rows,&cols,&par_cnt);
     if (sts != 1)
     {
        if(err_ptr == NULL)
        {
         printf("Failed accessing %s.\n", table);
         printf("SELECT <%s>\nFROM <%s>\n%s\n ", select, table, search);
        }
        sprintf(disp_err,"table_name %s",table_name);
        VRdb_err_msg(VR_E_DbLongErrMsg,err_ptr,table,"Row",disp_err);
        return(0);
     }
     else if(rows == 0 )
     {
         if(err_ptr == NULL)
         {
          printf("Catalog %s not defined\n", table_name);
         }
         VRdb_err_msg(VR_E_HvCatNotFound, err_ptr, table_name, NULL, NULL); 
         return (0);
     }
     return(1);
}

#endif
