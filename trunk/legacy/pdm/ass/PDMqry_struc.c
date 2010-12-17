#include <stdio.h>
#include "NFMdef.h"
#include "ERR.h"
#include		"PDUerror.h"
#include		"MEMstruct.h"
#include		"MEMerrordef.h"
#include		"NFMerrordef.h"
#include		"SQLerrordef.h"
#include		"PDMdbs_err.h"
#include		"PDMproto.h"
#define   PDM_I_NO_CHILDREN 74486011
#define   PDM_I_SOMEONE_PROCESSING 74485931
#define   PDM_E_REBUILD_STRUCTURE 74485939

extern int      PDMdebug_on;
extern char     PDM_DEBUG_FILE[];
static long     status;

int PDMrecursive_structuring (n_acatalogno,n_aitemno,temp_table,old_struc,
                              new_struc)
   int      n_acatalogno,n_aitemno;
   char     *temp_table;
   MEMptr   old_struc, *new_struc;
   {
     static char *fname = "PDMrecursive_structuring";
      long     status;
      char     sql_str[1024];
      char     **old_data;
      short    level,i,nxi;
    

      _PDMdebug (fname, "Cat   No = <%d> : Item No = <%d>  \n", 
		  n_acatalogno,n_aitemno);
       sql_str[0] = '\0';
       sprintf(sql_str,"DELETE FROM %s",temp_table);
       SQLstmt(sql_str); 

        status = MEMbuild_array(old_struc);
         if(status != MEM_S_SUCCESS)
           {
           _PDMdebug (fname, "MEM Build Array : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
        old_data = (char **) old_struc->data_ptr;

              
      status = PDMrecur_load_tempcit ( n_acatalogno, n_aitemno, level, 1,
         atoi (old_data[nxi+8]), temp_table);
      if (status != PDM_S_SUCCESS)
       {
       _PDMdebug (fname, "Load Child Level 0 : status = <0x%.8x>\n", status);
         return (status); 
       }

/* Copy the  attachments from the old structure */

          for(i = 0; i < old_struc->rows; i++)
             {
                  nxi = i * old_struc->columns;
       /* Copy back the p_impattached  of the 1 level parts */
           if(!strcmp(old_data[nxi+10],"Y") || !(strcmp(old_data[nxi+10],"y"))) 
                 {
        sprintf(sql_str,"UPDATE %s SET p_expattached = 'Y' WHERE n_catalogname ='%s' AND n_itemname = '%s' AND n_itemrev = '%s'  AND p_level = %s AND p_citno =%s AND p_pchildno = %s AND p_childno = %s",temp_table,old_data[nxi+1],old_data[nxi+2],old_data[nxi+3],old_data[nxi+6],old_data[nxi],old_data[nxi+8],old_data[nxi+7]);
                
                      status = SQLstmt(sql_str);
      if (status != SQL_S_SUCCESS)
       {
       _PDMdebug (fname, "SQL failed  : status = <0x%.8x>\n", status);
         return (status); 
       }

                   
                  }
       /* Copy back the p_impattached  for all level parts */
           if(!strcmp(old_data[nxi+9],"Y") || !(strcmp(old_data[nxi+9],"y"))) 
                 {
        sprintf(sql_str,"UPDATE %s SET p_impattached = 'Y' WHERE n_catalogname ='%s' AND n_itemname = '%s' AND n_itemrev = '%s'  AND p_level = %s AND p_citno =%s AND p_pchildno = %s AND p_childno = %s",temp_table,old_data[nxi+1],old_data[nxi+2],old_data[nxi+3],old_data[nxi+6],old_data[nxi],old_data[nxi+8],old_data[nxi+7]);
                
                      status = SQLstmt(sql_str);
      if (status != SQL_S_SUCCESS)
       {
       _PDMdebug (fname, "SQL failed  : status = <0x%.8x>\n", status);
         return (status); 
       }
                   
                  }
      }
           sql_str[0] = '\0';
      sprintf(sql_str,"SELECT * FROM %s",temp_table);
      status = SQLquery(sql_str,new_struc,512);
      if (status != SQL_S_SUCCESS)
       {
           if(status == SQL_S_SUCCESS)
               {
                 MEMclose(new_struc);
                 return(PDM_I_NO_CHILDREN);
               }
       _PDMdebug (fname, "SQL failed  : status = <0x%.8x>\n", status);
         return (status); 
       }
              

      _PDMdebug (fname, "SUCCESSFUL : status = <0x%.8x>\n", PDM_S_SUCCESS);
      return (PDM_S_SUCCESS); 
}

void PDMrecur_load_tempcit (p_catno,p_itemno,max_level,curr_level, p_pchildno,temp_table)  
   int    p_catno, p_itemno;
   short    max_level, curr_level;
   int      p_pchildno;
   char     *temp_table;
   {
     static char *fname = "PDMrecur_load_tempcit" ;
      int       p_childno = 0,c_catno,c_itemno;
      long      status, atol ();
      char      sql_str[1024], sql_str1[512],sql_str2[512];
      MEMptr    list = NULL;
      char      **column1, **data1;
      short       y, nxi;
      extern long      PDMrecur_load_tempcit();
      
      _PDMdebug (fname, " Max Level = <%d> : Curr Level = <%d> :  : Cat No = <%d> : Item No = <%d>\n",max_level,curr_level, p_catno, p_itemno );

      if ((curr_level > max_level) && (max_level >= 0))
       {
         _PDMdebug (fname, "CURR LVL %d > MAX LVL %d : status = <0x%.8x>\n",
		     curr_level, max_level, PDM_S_SUCCESS);
         return (PDM_S_SUCCESS);
       }

      sql_str [0] = '\0';
 
      /* Get all the children at the first level */
      
      sprintf (sql_str, "SELECT * FROM PDMCIT WHERE n_acatalogno = '%d' AND n_aitemno = '%d' AND p_level = 1", p_catno, p_itemno);
      status = SQLquery (sql_str, &list, MEM_SIZE);
      if ((status != SQL_S_SUCCESS) &&
          ((status) != SQL_I_NO_ROWS_FOUND))
       {
         MEMclose (&list);
         _sql_error (status);
         _PDMdebug (fname, "status = <0x%.8x>\n", status);
         return ( PDM_E_SQL_QUERY); 
       }


      if (status == SQL_I_NO_ROWS_FOUND)
	{
         _PDMdebug (fname, "NO CHILDREN");
         MEMclose(&list);
         return ( PDM_I_NO_CHILDREN); 
       }
      else
	{
         status = MEMbuild_array (list);
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (&list);
            _PDMdebug (fname, "MEM Build Array : status = <0x%.8x>\n",
			status);
            return (NFM_E_MEM);
          }

         column1 = (char **) list -> column_ptr;
         data1   = (char **) list -> data_ptr;


sprintf(sql_str1, "INSERT INTO %s (p_citno,n_catalogname,n_itemname,n_itemrev,n_itemdesc,n_setindicator,p_level,p_childno,p_pchildno,p_impattached, p_expattached, p_history,p_orient,p_quantity,p_usageid,p_viewid,p_tagno,p_alttagno,p_incbom,p_explode,p_pdcno,n_acatalogno,n_aitemno,p_updated) VALUES ",temp_table);

         for (y = 0; y < list -> rows; ++y)
          {
            nxi = list -> columns * y;
               if(atoi(data1[nxi+7])) 
                   p_childno = atoi(data1[nxi+7]);
               else
                 {
                 status = PDMris_max_childno(p_catno,p_itemno,atoi(data1[nxi+6]), atoi( data1[nxi+8]),&p_childno);  
               p_childno++;
                  }

            /* Carry over the level no and nullify the p_updated column */

               sql_str2 [0] = '\0';
        sprintf(sql_str2, "(%s,'%s','%s','%s','%s','%s',%s,%d,%d,'%s','%s','%s', '%s',,%s,'%s','%s',%s,'%s','%s','%s',%s,%s,%s,'%s')", data1[nxi], data1[nxi + 1], data1[nxi + 2], data1[nxi + 3], data1[nxi+4],data1[ nxi+5],curr_level,p_childno,p_pchildno,data1[nxi+9],data1[nxi+10],data1[nxi+11],data1[nxi + 12], data1[nxi + 13], data1[nxi + 14], data1[nxi + 15], data1[nxi+16],data1[nxi + 17], data1[nxi + 18], data1[nxi + 19], data1[nxi+20],data1[nxi+21],data1[nxi+22],"");
 sql_str[0] = '\0';
                sprintf(sql_str, "%s %s", sql_str1, sql_str2);
                status = SQLstmt(sql_str);
                if (status != SQL_S_SUCCESS) {
                        switch (status) {
                        case PDMS_NO_SUCH_TABLE:
                                _PDMdebug(fname, "%s \n", "pdmcit not found");
                                break;
                        case PDMS_NO_SUCH_ATTRIBUTE:
                             _PDMdebug(fname, "%s \n",
                                     "Required column in pdmcit not found");
                                break;
                        default:
                                break;
                        }
                        return (PDM_E_SQL_STMT);
                }
 

               if (!strcmp(data1[nxi+5],"Y") || !strcmp(data1[nxi+5],"y"))
                {
                  status = PDMquery_catalog_partnos(data1[nxi+1],data1[nxi+2],
                              data1[nxi+3],&c_catno,&c_itemno);
                  if(status != PDM_S_SUCCESS)
                   {
                      _PDMdebug(fname,"PDMquery_partno failed %s\n",status);
                      continue;
                   }
                  status = PDMrecur_load_tempcit (c_catno, c_itemno, max_level, curr_level + 1, p_childno, temp_table);
                  if (status != PDM_S_SUCCESS)
                   {
                     MEMclose (&list);
                    _PDMdebug (fname, "Ld Mem : status = <0x%.8x>\n", status);
                     return (status);
                   }
                }
               else
                  _PDMdebug (fname, "PART NOT A ASSEMBLY\n");
             } /* Finish up with all first level parts */
          }
      status = MEMclose (&list);
      if (status != MEM_S_SUCCESS)
       {
         _PDMdebug (fname, "MEM Close : status = <0x%.8x>\n", status);
         return (NFM_E_MEM);
       }

      _PDMdebug (fname, "SUCCESSFUL : status = <0x%.8x>\n", PDM_S_SUCCESS);
      return (PDM_S_SUCCESS); 
   }   


int PDMdevelop_ass_struc_chkin (p_catno,p_itemno,child_bufr)  
   int    p_catno, p_itemno;
   MEMptr child_bufr;
   {
     static char *fname = "PDMdevelop_ass_struc_chkin" ;
      int       p_childno = 1, p_pchildno = 0,curr_level = 1;
      long      status, atol ();
      char      sql_str[2048], sql_str1[1024],sql_str2[1024],drop_table[100], delete_table[100];
      char       temp_table[20];
      MEMptr     old_struc = NULL;
      char      **child_columns, **data1;
      int       y, nxi, c_catno, c_itemno, max_level = 50;
      

        /* Create a temporary pdmcit table to do the processing */

            status = PDMcreate_temp_pdmcit(temp_table);
            if(status != PDM_S_SUCCESS)
              {
                _PDMdebug(fname,"SQLstmt failed status %d\n",status);
                        SQLstmt(delete_table);
                        SQLstmt(drop_table);
                return(status);
              }

            sprintf(drop_table,"DROP TABLE %s",temp_table);
            sprintf(delete_table,"DELETE TABLE %s",temp_table);


              status = MEMbuild_array(child_bufr);
              if(status != MEM_S_SUCCESS)
               {
                   MEMclose(&old_struc);
                _PDMdebug(fname,"MEMbuild_array failed status %d\n",status);
                        SQLstmt(delete_table);
                        SQLstmt(drop_table);
                   return(PDM_E_BUILD_ARRAY);
                 }

                child_columns = (char **) child_bufr->column_ptr;
                data1    = (char **) child_bufr->data_ptr;

      sql_str [0] = '\0';
 
      /* Insert  all the children at the first level */
      

sprintf(sql_str1, "INSERT INTO %s (p_citno,n_catalogname,n_itemname,n_itemrev,n_itemdesc,n_setindicator,p_level,p_childno,p_pchildno,p_impattached, p_expattached, p_history,p_orient,p_quantity,p_usageid,p_viewid,p_tagno,p_alttagno,p_incbom,p_explode,p_pdcno,n_acatalogno,n_aitemno,p_updated) VALUES ",temp_table);

         for (y = 0; y < child_bufr -> rows; ++y)
          {
            nxi = child_bufr -> columns * y;
               /* Carry over the child nos */
               if(atoi(data1[nxi+7])) 
                   p_childno = atoi(data1[nxi+7]);
               else
                 {
                 status = PDMris_max_tempchildno(p_catno,p_itemno,0,0,temp_table,&p_childno);  
               p_childno++;
                  }

            /* Carry over the level no and nullify the p_updated column */

               sql_str2 [0] = '\0';
        sprintf(sql_str2, "(%s,'%s','%s','%s','%s','%s',%s,%d,%d,'%s','%s','%s', '%s',,%s,'%s','%s',%s,'%s','%s','%s',%s,%s,%s,'%s')", data1[nxi], data1[nxi + 1], data1[nxi + 2], data1[nxi + 3], data1[nxi+4],data1[ nxi+5],curr_level,p_childno,p_pchildno,data1[nxi+9],data1[nxi+10],data1[nxi+11],data1[nxi + 12], data1[nxi + 13], data1[nxi + 14], data1[nxi + 15], data1[nxi+16],data1[nxi + 17], data1[nxi + 18], data1[nxi + 19], data1[nxi+20],data1[nxi+21],data1[nxi+22],"");
 sql_str[0] = '\0';
                sprintf(sql_str, "%s %s", sql_str1, sql_str2);
                status = SQLstmt(sql_str);
                if (status != SQL_S_SUCCESS) {
                        switch (status) {
                        case PDMS_NO_SUCH_TABLE:
                                _PDMdebug(fname, "%s \n", "pdmcit not found");
                                break;
                        case PDMS_NO_SUCH_ATTRIBUTE:
                             _PDMdebug(fname, "%s \n",
                                     "Required column in pdmcit not found");
                                break;
                        default:
                                break;
                        }
                        SQLstmt(delete_table);
                        SQLstmt(drop_table);
                        return (PDM_E_SQL_STMT);
                }
                  status = PDMquery_catalog_partnos(data1[nxi+1],data1[nxi+2],
                              data1[nxi+3],&c_catno,&c_itemno);
                  if(status != PDM_S_SUCCESS)
                   {
                      _PDMdebug(fname,"PDMquery_partno failed %s\n",status);
                      continue;
                   }
                  status = PDMrecur_load_tempcit (c_catno, c_itemno, max_level, curr_level + 1, p_childno, temp_table);
                  if (status != PDM_S_SUCCESS && status != PDM_I_NO_CHILDREN)
                   {
                    _PDMdebug (fname, "Ld Mem : status = <0x%.8x>\n", status);
                        SQLstmt(delete_table);
                        SQLstmt(drop_table);
                     return (status);
                   }
                  else if(status == PDM_I_NO_CHILDREN) continue;
                  else 
                    /* SET THE ASSEMBLY INDICATOR IF IT HAS CHILDREN */
                    {
                      sql_str[0] = '\0';
              sprintf(sql_str,"UPDATE %s SET n_setindicator = 'Y' WHERE \
              n_catalogname = '%s' AND n_itemname = '%s' AND n_itemrev = '%s' \
              AND n_acatalogno = %d AND n_aitemno = %d",temp_table,
              data1[nxi+1],data1[nxi+2],data1[nxi+3],p_catno,p_itemno);
                     status = SQLstmt(sql_str);
                     if(status != SQL_S_SUCCESS)
                      {
                    _PDMdebug (fname, "SQLstmt: status = <0x%.8x>\n", status);
                       continue;
                      }
                    }

             } /* Finish up with all first level parts */

       status = NFMstop_transaction (0);
        if (status != NFM_S_SUCCESS)
         {
    _PDMdebug(fname,":NFMstop_transaction = <0x%.8x>\n", status);
           SQLstmt(delete_table);
           SQLstmt(drop_table);
    return (status);
          }
/* Need to lock table to avoid multiuser,concurrent proccesing(inconsistencies) 
       in doing select, insert, update etc */

        /* Lock the pdmcit table */
            sql_str[0] = '\0';
            sprintf(sql_str,"LOCK TABLES  PDMCIT IN EXCLUSIVE MODE");
             status = SQLstmt(sql_str);
              if(status != SQL_S_SUCCESS)
              {
                _PDMdebug(fname,"SQLstmt failed status %d\n",status);
                 NFMrollback_transaction(0);
           SQLstmt(delete_table);
           SQLstmt(drop_table);
                return(PDM_E_SQL_STMT);
              }


        /* Remove the old strcuture if it is there, otherwise ignore*/

            sql_str[0] = '\0';
            sprintf(sql_str,"DELETE  FROM PDMCIT WHERE n_acatalogno = '%d' AND n_aitemno = '%d' AND p_level > 0 ",p_catno,p_itemno);
             status = SQLstmt(sql_str);
              if(status != SQL_S_SUCCESS)
              {
                _PDMdebug(fname,"SQLstmt failed status %d\n",status);
              }

        /* Insert the new structure */
        /* This is a nested insert which does both the select from the
            temp table and insert to the pdmcit in one query */
            sql_str[0] = '\0';
            sprintf(sql_str,"INSERT INTO PDMCIT SELECT * FROM %s",temp_table);
             status = SQLstmt(sql_str);
           if(status != SQL_S_SUCCESS)
              {
                 NFMrollback_transaction(0);
           SQLstmt(delete_table);
           SQLstmt(drop_table);
                _PDMdebug(fname,"SQLstmt failed status %d\n",status);
                return(PDM_E_SQL_STMT);
              }


        /* Unlock the pdmcit table */
            status = NFMstart_transaction (0);
             if (status != NFM_S_SUCCESS)
                {
        _PDMdebug(fname," NFMstart_transaction = <0x%.8x>\n", status);
                 NFMrollback_transaction(0);
           SQLstmt(delete_table);
           SQLstmt(drop_table);
         return (status);
                 }


            /* Temp table is of no use any more. Delete temp table */ 
                        SQLstmt(delete_table);
                        SQLstmt(drop_table);
      _PDMdebug (fname, "SUCCESSFUL : status = <0x%.8x>\n", PDM_S_SUCCESS);
      return (PDM_S_SUCCESS); 
   }   


int PDMquery_assembly_structure(PDMexec)
PDMexec_ptr PDMexec;

{

   char    sql_str[512], **update_data;
   int      n_catalogno,n_itemno;
   MEMptr  ass_bufr = NULL, update_bufr = NULL;
   short   update, i, process; 

   static char *fname = "PDMquery_assembly_structure";

     _PDMdebug(fname,"Enter: \n");
   
        status = PDMquery_catalog_partnos(PDMexec->catalog,PDMexec->part_num,
                         PDMexec->revision,&n_catalogno,&n_itemno);
        
           if(status != PDM_S_SUCCESS)
              {
                MEMclose(&PDMexec->ws_buffer);
                _PDMdebug(fname,"PDMquery_catalog_partnos failed %d\n",status);
               return(PDM_E_PART_NOT_FOUND);
               }
            sql_str[0] = '\0';
      sprintf(sql_str,"SELECT p_updated FROM pdmcit WHERE n_acatalogno = %d \
                       AND n_aitemno = %d");

              status = SQLquery(sql_str,&update_bufr,256);
               if(status != SQL_S_SUCCESS )
                {
                MEMclose(&PDMexec->ws_buffer);
                _PDMdebug(fname,"SQLquery failed %d\n",status);
               return(PDM_E_PART_NOT_FOUND);
               }
                  
       status = MEMbuild_array(update_bufr);
              if(status != MEM_S_SUCCESS)
               {
                   MEMclose(&update_bufr);
                _PDMdebug(fname,"MEMbuild_array failed status %d\n",status);
                   return(PDM_E_BUILD_ARRAY);
                 }

        update_data = (char **) update_bufr->data_ptr;
           update = 0;

           for (i = 0; i < update_bufr->rows; i++)
               {
                 if(!strcmp(update_data[i],"Y") || !strcmp(update_data[i],"y"))
                          {
                          update = 1;
                          break;
                          }
                 else
                 if(!strcmp(update_data[i],"Q") || !strcmp(update_data[i],"q"))
                          {
                          process = 1;
                         break;
                           }
                 }
   if (process == 1) 
                 {
                   MEMclose(&update_bufr);
                   _PDMdebug(fname,"Exit: Some one else processing\n");
                   return(PDM_I_SOMEONE_PROCESSING);
                  }
       if(update == 1)
                   {
                 /*status = PDMrebuild_assembly_structure(n_catalogno,n_itemno);*/
                  if(status != PDM_S_SUCCESS)
                   {
                   MEMclose(&update_bufr);
           /*_PDMdebug(fname,"PDMrebuild_assembly_structure failed %d\n", status);*/
                   return(PDM_E_REBUILD_STRUCTURE);
                  }
                   }
 
            sql_str[0] = '\0';
      sprintf(sql_str,"SELECT p_level,p_childno,p_pchildno,n_catalogname,n_itemname,n_itemrev,n_itemdesc,p_usageid,p_attached  FROM PDMCIT WHERE n_acatalogno = %d AND n_aitemno = %d",n_catalogno,n_itemno); 
              status = SQLquery(sql_str,&ass_bufr,1024);
               if(status != SQL_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND)
                {
                MEMclose(&update_bufr);
                MEMclose(&ass_bufr);
                _PDMdebug(fname,"SQLquery failed %d\n",status);
               return(PDM_E_SQL_QUERY);
               }
               if(status == SQL_I_NO_ROWS_FOUND)
                {
                MEMclose(&update_bufr);
                MEMclose(&ass_bufr);
                _PDMdebug(fname,"Selecting the children %d\n",status);
               return(PDM_I_NO_CHILDREN);
               }

            PDMexec->ws_buffer = ass_bufr;
        _PDMdebug(fname,"Exit: Successful \n");

         return(PDM_S_SUCCESS);

}
