#include <stdio.h>
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "NFMdef.h"
#include "ERR.h"
#include "PDUerror.h"
#include "PDMproto.h"
#include "PDMdebug.h"

extern PDMpart_ptr PDMpart;
extern PDMexec_ptr PDMexec;
extern int PDMdebug_on;

/*
Queries a given part's assembly structure
 - Kumar
long PDMquery_ass_struc (cat_name, item_name, item_rev, level, p_assind,
                            attr_list, place_flag)
*/

long PDMquery_ass_struc (cat_name, item_name, item_rev, level, p_assind,
                                  place_flag, attr_list)
char     *cat_name;
char     *item_name, *item_rev;
long     level;
char    *p_assind;
long    place_flag;
MEMptr   *attr_list;
{
     static char *fname = "PDMquery_ass_struc";
      long     status;
      long     catno;
      char     *sql_str;
      char     cit_str [1024];
      char     **column, **data;
      long     PDMassembly_attributes ();
      long     PDMload_ass_members (); 

/*
      place_flag[0] = '\0';
      strcpy (place_flag, "Y");
*/
      _PDMdebug (fname, 
       "Cat Name = <%s> :Item Name = <%s> :Item Rev = <%s> :Level = <%d> \n", 
          cat_name, item_name, item_rev, level);
      _PDMdebug (fname, "place_flag [%d]\n", place_flag);

      status = PDMris_get_catno(cat_name,&catno);


      status = PDMassembly_attributes (attr_list);
      if (status != PDM_S_SUCCESS)
       {
         MEMclose (attr_list);
         _PDMdebug (fname, "Query Set Attr Def : status = <0x%.8x>\n",
         status);
         return (status); 
       }

      status = MEMbuild_array (*attr_list);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (attr_list);
         _PDMdebug (fname, "MEM Build Array : status = <0x%.8x>\n",
		     status);
         return (NFM_E_MEM); 
       }

      column = (char **) (*attr_list) -> column_ptr;
      data   = (char **) (*attr_list) -> data_ptr;

      sql_str = (char *) malloc ((*attr_list) -> row_size);
      if (! sql_str)
       {
         MEMclose (attr_list);
         _PDMdebug (fname, "Malloc Failed : status = <0x%.8x>\n",
         NFM_E_MALLOC);
         return (NFM_E_MALLOC); 
       }
      sql_str [0] = '\0';

/*
     sprintf(sql_str,"%d\1%d\1%d\1%d\1%d\1%d\1%s\1%s\1%d\1%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1",n_citno,n_pcatalogno,n_pitemno,n_ccatalogno,n_citemno,n_setindicator,n_status,n_level,p_pchildno,p_childno,n_catalogname,n_itemname,n_itemrev,n_itemdesc,p_attached,p_usageid,n_cofilename);

*/
     sprintf(sql_str,"%d\1%d\1%d\1%d\1%d\1%d\1%s\1%s\1%d\1%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1\1\1\1\1%s\1\1\1\1\1",
0,catno,PDMpart.n_itemno,catno,PDMpart.n_itemno,0,"Y",PDMpart.n_status,0,0,cat_name,item_name,item_rev,"","","","",PDMpart.n_cofilename, PDMpart.p_parttype);

      status = MEMwrite (*attr_list, sql_str);
      if (status != MEM_S_SUCCESS)
       {
         free (sql_str);
         MEMclose (attr_list);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _PDMdebug (fname, "MEM Write Failed : status = <0x%.8x>\n",
		     status);
         return (NFM_E_MEM); 
       }

if (PDMdebug_on)
  MEMprint_buffer("attr_list", *attr_list, PDM_DEBUG_FILE);

      free (sql_str);
     _PDMdebug (fname, "p_assind = <%s>\n", p_assind);
    if(level != -1 && (!strcmp(p_assind,"Y") || (!strcmp(p_assind,"y"))) ||
                      (!strcmp(p_assind,"A") || (!strcmp(p_assind,"a"))))
   {
      cit_str[0]='\0';
       sprintf(cit_str,"NFMSETCIT.n_citno,NFMSETCIT.n_pcatalogno,NFMSETCIT.n_pitemno,NFMSETCIT.n_ccatalogno,NFMSETCIT.n_citemno,PDMCIT.p_childno,PDMCIT.p_attached,PDMCIT.p_quantity,PDMCIT.p_usageid,PDMCIT.n_cofilename,PDMCIT.n_catalogname,PDMCIT.n_itemname,PDMCIT.n_itemrev,PDMCIT.p_tagno, PDMCIT.p_alttagno,PDMCIT.p_explode,PDMCIT.p_incbom");

      status = PDMload_ass_members ((long)3, (long) 4, cit_str, level, (long) 1, (long) catno, PDMpart.n_itemno, *attr_list, 0, place_flag);
      if (status != NFM_S_SUCCESS)
       {
         MEMclose (attr_list);
         _PDMdebug (fname, "Load Child Level 0 : status = <0x%.8x>\n",
         status);
         return (status); 
       }

    }
    else if(level != -1 && (!strcmp(p_assind,"") || (!strcmp(p_assind,"N"))))
     {
   _PDMdebug (fname, "PART IS ATOMIC : status = %d\n", PDM_E_PART_NOT_ASSEMBLY);
      return (PDM_E_PART_NOT_ASSEMBLY); 
     }
    else if(level == -1 && (!strcmp(p_assind,"Y") || (!strcmp(p_assind,"y"))))
      {
 
   _PDMdebug (fname, "PART IS ASSEMBLY with p_explode as 'N' : status = %d\n", PDM_S_SUCCESS);
      return (PDM_S_SUCCESS); 
       }

 _PDMdebug (fname, "SUCCESSFUL : status = <0x%.8x>\n",
 PDM_S_SUCCESS);
 return (PDM_S_SUCCESS); 
}

/*
 Recursive function that queries it's children till it
 hits it's a condition of no more children. It's depth first
 recursion instead of a breadth first recursion. The breadth first
 recusion will create multiple OR or IN clause which some DBMS
 like INGRESS cannot handle. Sometimes mutiple ORs are slower than
 mutiple queries. That's the reason for the depth first - left to
 right algorithm instead of breadth first. One more side effect of this
 is that the tree structure is automatically built.
  - Kumar 10.8.93
*/

long PDMload_ass_members  (c_catoffset, c_itemoffset, 
                           cit_str, 
                           max_level, curr_level, 
                           cat_no, item_no,
                           attr_list, p_pchildno, place_flag)
long    c_catoffset, c_itemoffset;
char    *cit_str;
long    max_level, curr_level;
long    cat_no, item_no;
MEMptr  attr_list;
int     p_pchildno;
long    place_flag;
{
     static char *fname = "PDMload_ass_members" ;
      long      status, atol ();
      char      n_setindicator[2];
      char      n_itemdesc[241];
      char      p_parttype[2];
      char      p_incstr[2];
      char      *sql_str;
      MEMptr    list = NULL;
      char      **column;
      char      **column1, **data1;
      long      y = 0, count1 = 0;
      long      nxi;
      long      CutOffLevel;
      long      PDMload_ass_members  ();
      
/*
      _PDMdebug (fname, 
       "Cat Offset = <%d> : Item Offset = <%d> : Max Level = <%d> : Curr Level = <%d> :  Cat No = <%d> : Item No = <%d>\n",
		  c_catoffset,
		  c_itemoffset,  max_level,
		  curr_level, cat_no, item_no);
*/
      _PDMdebug (fname, "Curr Level = <%d> :  Cat No = <%d> : Item No = <%d>\n",
		  curr_level, cat_no, item_no);

c_catoffset = 3;
c_itemoffset = 4;
      _PDMdebug (fname, "place_flag [%d]\n", place_flag);
     
      _PDMdebug ("Getting children for", "[%d].[%d] at level [%d]\n",
                                  cat_no, item_no, curr_level);


      if ((curr_level > max_level) && (max_level >= 0))
       {
         _PDMdebug (fname, "CURR LVL %d > MAX LVL %d : status = <0x%.8x>\n",
		     curr_level, max_level, NFM_S_SUCCESS);
         return (NFM_S_SUCCESS);
       }

      sql_str = (char *) malloc (strlen (cit_str) + 2 * MEM_SIZE);
      if (! sql_str)
       {
         _PDMdebug (fname, "Malloc Failed : status = <0x%.8x>\n",
         NFM_E_MALLOC);
         return (NFM_E_MALLOC);
       }
      sql_str [0] = '\0';
      p_incstr [0] = '\0';
      
      sprintf (sql_str,
      "%s %s %s %s %s %s = %d %s %s = %d %s (%s = 'S' OR %s = 'P') %s %s ",
       " SELECT", cit_str, 
       " FROM", "NFMSETCIT,PDMCIT", "WHERE",
       " NFMSETCIT.n_pcatalogno", cat_no, 
       " AND", "NFMSETCIT.n_pitemno", item_no, 
       " AND", "NFMSETCIT.n_type", "NFMSETCIT.n_type", 
       " AND NFMSETCIT.n_citno = PDMCIT.p_citno ",
       " ORDER BY n_ccatalogno");
/*
       " AND ( PDMCIT.p_incbom in ('Y', 'A') )  ORDER BY n_ccatalogno");
*/



      status = SQLquery (sql_str, &list, MEM_SIZE);
      if ((status != SQL_S_SUCCESS) &&
          ((status) != SQL_I_NO_ROWS_FOUND))
       {
         free (sql_str);
         MEMclose (&list);
         _sql_error (status);
         ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
         _PDMdebug (fname, "status = <0x%.8x>\n", status);
         return ( PDM_E_SQL_QUERY); 
       }

      free (sql_str);

      if (status == SQL_I_NO_ROWS_FOUND)
	{
         _PDMdebug (fname, "NO CHILDREN");
       }
      else
	{
	  column = (char **) attr_list -> data_ptr;

         status = MEMbuild_array (list);
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (&list);
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
            _PDMdebug (fname, "MEM Build Array : status = <0x%.8x>\n",
			status);
            return (NFM_E_MEM);
          }

         column1 = (char **) list -> column_ptr;
         data1   = (char **) list -> data_ptr;
      sql_str = (char *) malloc (strlen (cit_str) + 2 * MEM_SIZE);
      /*   sql_str = (char *) malloc (attr_list->row_size + 512) ; */
         if (! sql_str)
          {
            free (sql_str);
            MEMclose (&list);
            _PDMdebug (fname, "Malloc Failed : status = <0x%.8x>\n",
            NFM_E_MALLOC);
            return (NFM_E_MALLOC);
          }
         sql_str [0] = '\0';

        for (y = 0; y < list->rows; ++y) {
            count1 = list -> columns * y;
            nxi = list -> columns * y;

          _PDMdebug ("Checking part", "[%s].[%s].[%s]...\n", data1[count1+10],
                                                             data1[count1+11],
                                                             data1[count1+12]);
  
/*
            status = PDMquery_assyind_parttype ( data1[count1+10], 
                                                  data1[count1+11],
                                                  data1[count1+12],
                                                  n_setindicator,
                                                  p_parttype);
*/
            n_setindicator[0] = '\0';
            p_parttype[0] = '\0';
            n_itemdesc[0] = '\0';
            status = PDMQueryAssyIndPTypePDesc ( data1[count1+10], 
                                                  data1[count1+11],
                                                  data1[count1+12],
                                                  n_setindicator,
                                                  p_parttype,
                                                  n_itemdesc);
             if (status != PDM_S_SUCCESS && status != PDM_E_PART_NOT_FOUND)
                {
                  free (sql_str);
                  MEMclose (&list);
                  _PDMdebug (fname, "Chk Set Ind : status = <0x%.8x>\n",
                  status);
                  return (status);
                }
_PDMdebug (fname, "Part %s.%s: assy[%s] type[%s] desc[%s]\n",
                                                  data1[count1+11],
                                                  data1[count1+12],
                                                  n_setindicator,
                                                  p_parttype,
                                                  n_itemdesc);

                if (status == SQL_I_NO_ROWS_FOUND) continue;

/* 10/23/95 - MJG - TR139424087 - DM Manager */
                 if(!strcmp(n_setindicator,"Y") || 
                    !strcmp(n_setindicator,"y") ||
                    !strcmp(n_setindicator,"A") || 
                    !strcmp(n_setindicator,"a"))
                    strcpy(n_setindicator,"Y");
                 else
                    strcpy(n_setindicator,"N");
_PDMdebug (fname, "Part %s.%s: p_incstr[%s]\n", 
                                             data1[count1+11],
                                              data1[count1+12],
                                              data1[nxi+16]);
                 if(!strcmp(data1[nxi+16],"Y")) strcpy(p_incstr,"Y");
                 else if(!strcmp(data1[nxi+16],"A")) strcpy(p_incstr,"Y");
                 else if(!strcmp(data1[nxi+16],"B")) strcpy(p_incstr,"N");
                 else if(!strcmp(data1[nxi+16],"N")) strcpy(p_incstr,"N");
                 else strcpy(p_incstr,"Y");

  CutOffLevel = 1;
  /*if (!strcmp (place_flag, "Y") )*/
  if (place_flag == 1 )
     CutOffLevel = 0;

  if ( (!strcmp (data1[nxi + 16], "")) ||
       (  (!strcmp(data1[nxi+16],"A"))  || (!strcmp(data1[nxi+16],"Y")) ) || 
       (  (strcmp(data1[nxi+16],"A"))  && (strcmp(data1[nxi+16],"Y"))  &&
                                             (curr_level == CutOffLevel  )) ) {
               sql_str [0] = '\0';
/*
  if ( (!strcmp (data1[nxi + 10], PDMexec->catalog)) &&
       (!strcmp(data1[nxi+11],PDMexec->part_num))  && 
       (!strcmp(data1[nxi+12],PDMexec->revision)) )  
        {
         _PDMdebug("Cyclic placement - Ignore to aviod infinite loop\n"); 
         continue;
        }
*/
      
     sprintf(sql_str,"%s\1%s\1%s\1%s\1%s\1%d\1%s\1%s\1%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1\1\1\1",
data1[nxi+0], data1[nxi+1], data1[nxi+2], data1[nxi+3], data1[nxi+4],
curr_level, n_setindicator, "", p_pchildno, data1[nxi+5], data1[nxi+10], 
data1[nxi+11], data1[nxi+12], n_itemdesc, data1[nxi+6], data1[nxi+7], 
data1[nxi+8], data1[nxi+9], data1[nxi+13], data1[nxi+14], 
data1[nxi+15], data1[nxi+16], p_incstr, p_parttype );
  _PDMdebug (fname, "Adding child [%s].[%s].[%s] at level [%d] \n",
                                       data1[nxi + 10],
                                       data1[nxi + 11],
                                       data1[nxi + 12],
                                       curr_level);
               status = MEMwrite (attr_list, sql_str);
               if (status != MEM_S_SUCCESS)
                {
                  free (sql_str);
                  MEMclose (&list);
                  _PDMdebug (fname, "MEM Write : status = <0x%.8x>\n",
			      status);
                  return (NFM_E_MEM);
                }

/* modification to support include in structure MaC 060193 */
/*               if  (!strcmp(n_setindicator,"Y")) */

/* Reverting to previous code... Change in support to include
        in structure functionality... Now we allow all the
        children of a sub-assy which(children) are placed
        with include structure set to Y.   Or in other words
        we look for the children of an assy placed with incstr
        false.......    MaC 042294 ...
               if ( (!strcmp(n_setindicator,"Y")) &&
                    ( (!strcmp (data1[nxi+16], ""))  ||
                      (!strcmp (data1[nxi+16], "A"))  ||
                        (!strcmp (data1[nxi+16], "Y")) ) )
                                     ...........*/
/* 10/23/95 - MJG - TR 139424087 DM Manager */
               if  (!strcmp(n_setindicator,"Y") ||
                    !strcmp(n_setindicator,"A"))
                {
                  status = PDMload_ass_members ((long) 3, (long) 4,
                                                 cit_str, 
                                                 max_level, 
                                                 curr_level + 1, 
                                                 atol(data1[nxi+3]),
                                                 atol(data1[nxi+4]),
                                                 attr_list,
                                                 atoi(data1[nxi+5]), 
                                                 place_flag);
                  if (status != NFM_S_SUCCESS)
                   {
                     free (sql_str);
                     MEMclose (&list);
                     _PDMdebug (fname, "Ld Mem : status = <0x%.8x>\n",
                     status);
                     return (status);
                   }
                }
               else
                  _PDMdebug (fname, "ITEM NOT A SET\n");
           } /* background part detour*/
          }

         free (sql_str);
       }

      status = MEMclose (&list);
      if (status != MEM_S_SUCCESS)
       {
         _PDMdebug (fname, "MEM Close : status = <0x%.8x>\n",
		     status);
         return (NFM_E_MEM);
       }

 _PDMdebug (fname, "SUCCESSFUL : status = <0x%.8x>\n",
 NFM_S_SUCCESS);
 return (NFM_S_SUCCESS); 
}   
    
long PDMassembly_attributes ( attr_list)
MEMptr   *attr_list;
{
      static char *fname = "PDMassembly_attributes" ;
      long     status;

       PDMdebug("ENTER: PDMassembly_attributes");

      status = MEMopen (attr_list, 1024);
      if (status != MEM_S_SUCCESS)
       {
         _PDMdebug (fname, "MEM Open : status = <0x%.8x>\n", status);
         return (NFM_E_MEM);
       }
         status = MEMwrite_format (*attr_list, "n_citno", "integer");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
         status = MEMwrite_format (*attr_list, "n_pcatalogno", "integer");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
         status = MEMwrite_format (*attr_list, "n_pitemno", "integer");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
         status = MEMwrite_format (*attr_list, "n_ccatalogno", "integer");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
         status = MEMwrite_format (*attr_list, "n_citemno", "integer");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
         status = MEMwrite_format (*attr_list, "p_level", "integer");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
         status = MEMwrite_format (*attr_list, "n_setindicator", "char(1)");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
         status = MEMwrite_format (*attr_list, "n_status", "char(2)");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
         status = MEMwrite_format (*attr_list, "p_pchildno", "integer");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
         status = MEMwrite_format (*attr_list, "p_childno", "integer");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
         status = MEMwrite_format (*attr_list, "n_catalogname", "char(40)");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
         status = MEMwrite_format (*attr_list, "n_itemname", "char(120)");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
         status = MEMwrite_format (*attr_list, "n_itemrev", "char(40)");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
         status = MEMwrite_format (*attr_list, "n_itemdesc", "char(120)");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
         status = MEMwrite_format (*attr_list, "p_attached", "char(2)");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
         status = MEMwrite_format (*attr_list, "p_quantity", "char(32)");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
         status = MEMwrite_format (*attr_list, "p_usageid", "char(25)");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
         status = MEMwrite_format (*attr_list, "n_cofilename", "char(14)");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
         status = MEMwrite_format (*attr_list, "p_tagno", "integer");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
         status = MEMwrite_format (*attr_list, "p_alttagno", "char(25)");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
         status = MEMwrite_format (*attr_list, "p_explode", "char(1)");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
         status = MEMwrite_format (*attr_list, "p_incbom", "char(1)");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
         status = MEMwrite_format (*attr_list, "p_incstr", "char(1)");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
         status = MEMwrite_format (*attr_list, "p_parttype", "char(1)");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
         status = MEMwrite_format (*attr_list, "p_move", "char(5)");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }

         status = MEMwrite_format (*attr_list, "p_refid", "char(20)");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }


         status = MEMwrite_format (*attr_list, "p_local", "char(5)");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }

         status = MEMwrite_format (*attr_list, "p_delete", "char(5)");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
            _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }


      _PDMdebug (fname, "SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS);
      return (PDM_S_SUCCESS); 
}


