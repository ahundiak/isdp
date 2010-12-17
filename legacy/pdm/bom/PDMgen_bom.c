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
#include        	"dbadev.h"
#include        	"rMRPstr.h"
#include        	"MRPmessage.h"
#include                "PDMproto.h"


#include                	"PDMbom_strct.h"
static long             	status;
/*static char			s[1024];*/
extern int             		PDMdebug_on;
extern char    			PDM_DEBUG_FILE[];
extern PDMexec_ptr 		PDMexec;
extern PDMpart_ptr 		PDMpart;
extern struct NFMglobal_st 	NFMglobal;
extern int             		PDMalt_bom_on;
extern char    			PDM_ALT_PARENT_ATTR[];

    
int   PDMupdate_exist_bom (exist1_bom)
char          		*exist1_bom;
{
        char				*fn = "PDMupdate_exist_bom";
        char				**attr, **attr1;
        int				a_index, attribute;
        int				level, nch, cat_no, row_no;
	int				comma, comma1;
	int				status1;
	char				*insert_attr_str = NULL;
	char				*insert_data_str = NULL, *qry_list;
	char				*stat_attr_str = NULL;
	char				*stat_data_str = NULL;
	char				*dyn_attr_str = NULL;
	char				*dyn_data_str = NULL;
        char				*sql_str = NULL;
        char				exist_bom[128];
        char				e_cat[128];
        char				drop_str[1024];
        char				alt_parent_attr[128];
        char				value[240];
        char				*Altpartno = NULL;
        char				part_num[241];
        char				part_rev[241];
        char				Itemdesc[240];
        char				rollback_str[1024];
        char				*attr_str = NULL;
        char				*cat_list = NULL;
	MEMptr          		attr1_bufr = NULL;
	MEMptr          		cattr_bufr = NULL;
	MEMptr          		attr_bufr = NULL;
	MEMptr          		data_bufr = NULL;
	MEMptr          		map_bufr = NULL;
	struct PDMbom_member		*head, *end;
	struct PDMbom_member		*cur_mem, *temp_mem;

    /* query whether the bom exists...*/


    status = PDMquery_catalogno (PDMexec->catalog, &cat_no);
     if (status != PDM_S_SUCCESS) {
        _PDMdebug (fn, "%s %s %d \n",
                        "PDMris_get_catno failed : status", status);
        return (status);
        }
   
    _PDMdebug (fn, "cat_no = %d\n", cat_no);
        
    status = PDMload_part_info(PDMexec->catalog, PDMexec->part_num,
                                                         PDMexec->revision);
     if (status != PDM_S_SUCCESS) {
        _PDMdebug (fn, "PDMload_part_info failed status %d\n", status);
        return (status);
        }
/* 10/23/95 - MJG - TR 139424087 DM Manager */
/*
    if ( strcmp (PDMpart.n_setindicator, "Y") && 
          strcmp (PDMpart.n_setindicator, "y")) 
*/
    if ( strcmp (PDMpart.n_setindicator, "Y") && 
          strcmp (PDMpart.n_setindicator, "y") &&
          strcmp (PDMpart.n_setindicator, "A") &&
          strcmp (PDMpart.n_setindicator, "a")) {
        _PDMdebug (fn, "%s %d \n", "Part is not an assembly : status", 
                                                 PDM_E_PART_NOT_ASSEMBLY);
        _PDMdebug ("EXIT", "%s\n", fn);
         return (PDM_E_PART_NOT_ASSEMBLY);
     }
     
     /* Check for non-graphic parttype BOM generation - Kumar 
    if ((!strcmp (PDMpart.n_parttype, "N")) ||
                    (!strcmp (PDMpart.n_parttype, "n")) )  {
       status = PDM_E_PART_NONGRAPHIC;
       _PDMdebug (fn, "%s %d \n", "Part is Non-Graphic : status", status);
       _PDMdebug ("EXIT", "%s\n", fn);
       return (status);
     }
     */

     /* To support non-graphic assembly's BOM generation - Kumar 
    if (strcmp (PDMpart.n_status, "I"))  {
       _PDMdebug (fn, "%s %d \n", "Part is not Checked in : status", 
                                                 PDM_E_PART_NOT_CHECKEDIN);
       _PDMdebug ("EXIT", "%s\n", fn);
       return (PDM_E_PART_NOT_CHECKEDIN);
     }
      */   
          
    _PDMdebug (fn, "This part is a checked in assy\n");
   exist_bom[0] = '\0';
  sprintf (exist_bom, "Arun");
  _PDMdebug (fn, "exist_bom[%s]\n", exist_bom);

   status = PDMquery_bom_name(PDMexec->catalog, PDMexec->part_num, 
                                        PDMexec->revision, exist_bom);
   if (status != PDM_S_SUCCESS &&
      status != PDM_E_BOM_NOT_FOUND) {
        _PDMdebug (fn, "%s %d \n", "PDMquery_bom_name failed : status", status);
         return (status);
     }


   if (status == PDM_S_SUCCESS) {

    status = _PDMrollback_pdmboms (cat_no, PDMpart.n_itemno, exist_bom);
    if (status != PDM_S_SUCCESS) {
       _PDMdebug (fn, "delete_bom_entry failed : status : %d\n", status );
        return (status);
      }

    status = PDMstart_transaction(0);
    if (status != PDM_S_SUCCESS) {
        _PDMdebug (fn, "PDMstart_transaction failed status %d\n", status);
         goto cleanup;
    }

    SQLstmt ("COMMIT WORK");
    sprintf (drop_str, "DROP TABLE %s", exist_bom); 
    status = SQLstmt (drop_str);
    if (status != SQL_S_SUCCESS) {
       _PDMdebug (fn, "DROP table failed : status : %d\n", status );
        return (PDM_E_DROP_BOM_TABLE);
      }
    }

   if (status == PDM_E_BOM_NOT_FOUND) {
   /* generate BOM name */
        status = PDMgen_bomtable_name(exist_bom);
        if (status != PDM_S_SUCCESS) {
                _PDMdebug (fn, "%s %s %d \n",
                        "PDMgen_bomtable_name failed : status", status);
                return (PDM_E_GEN_BOM_TABLE_NAME);
        }
     }

  /* check whether locked; lock if it is not */

        status = PDMverify_bomlock(PDMexec->catalog,
                                 PDMexec->part_num, PDMexec->revision);
        if (status == PDM_E_BOM_LOCKED) {
           _PDMdebug (fn, "%s %s %d \n",
                        "PDMverify_bom_lock  status", status);
           return (status);
        } else if (status != PDM_S_SUCCESS) {
           _PDMdebug (fn, "%s %s %d \n",
                        "PDMverify_bom_lock failed : status", status);
           return (status);
        }


/* get assy children */

       level = 0;

/* Fix for alt_bom */
      _PDMdebug (fn, "altbom: flag[%d], value[%s]\n",
               PDMalt_bom_on, PDM_ALT_PARENT_ATTR);
      if (PDMalt_bom_on == 1) {
      alt_parent_attr [0] = '\0';
      strcpy (alt_parent_attr , PDM_ALT_PARENT_ATTR);
      status = PDMget_alt_bom_members (cat_no, PDMpart.n_itemno, 
			level, &head, &end, &nch, PDM_ALT_PARENT_ATTR);
      } else {
      status = PDMget_bom_members (cat_no, PDMpart.n_itemno, 
					level, &head, &end, &nch);
            }
        if (status != PDM_S_SUCCESS) {
                _PDMdebug (fn, "%s %s %d \n",
                        "PDMget_bom_members failed : status", status);
               goto cleanup;
                /*return (status);*/
        }

      if (nch < 2) {
     /*  Fix for TR#139307992 - Kumar 092793 */
    sprintf(drop_str, "SELECT * from nfmsetcit where n_pcatalogno = %d and n_pitemno = %d", cat_no, PDMpart.n_itemno);
        status = SQLquery(drop_str, &cattr_bufr, 512);  
         if(status == SQL_I_NO_ROWS_FOUND)
          {
           MEMclose(&cattr_bufr);
    sprintf(drop_str, "Update %s SET n_setindicator = 'N' where and n_itemno = %d", PDMexec->catalog, PDMpart.n_itemno);
            SQLstmt(drop_str);  
       _PDMdebug (fn, "no  children for this part- restting Assembly indicator\n");
          status = PDM_E_PART_NOT_ASSEMBLY;
          }
         else
         {
           MEMclose(&cattr_bufr);
       _PDMdebug (fn, "no assy children included in the BOM\n");
        status = PDM_E_BOM_NO_CHILD_LIST;
          }
        goto cleanup;
        }

      status =  _PDMupdate_catnos_in_llist (&head, &end, nch);
        if (status != PDM_S_SUCCESS) {
                _PDMdebug (fn, "%s %s %d \n",
                        "_PDMupdate_catnos_in_llist failed : status", status);
        goto cleanup;
                /*return (status);*/
        }

/* get bom attributes */


        status = PDMget_bom_attrs(&attr_bufr, &data_bufr);
        if (status != PDM_S_SUCCESS) {
           _PDMdebug (fn, "%s %s %d \n",
                        "PDMget_bom_attrs failed : status", status);
            goto cleanup;
           /*return (status);*/
        }



/* get mapping */
/*
int PDMget_bom_map_attrs (cat_list, attr_bufr, data_bufr,
                                 link_head, link_end, map_bufr, cattr_bufr)
*/

   status = PDMget_bom_map_attrs (cat_list, &attr_bufr, &data_bufr, 
			                 &head, &end, &map_bufr, &cattr_bufr);
   if ( (status != PDM_S_SUCCESS)  &&
             ( status != PDM_I_NO_ROWS_FOUND) ) {
                _PDMdebug (fn, "%s %s %d \n",
                        "PDMget_bom_map_attrs  failed : status", status);
            goto cleanup;
           /*return (status);*/
   }

   if (status == PDM_S_SUCCESS) {
   _PDMdebug (fn, "found mapped attributes\n");

  status = PDMget_new_map_bom_attr_bufr (map_bufr, &attr_bufr, &data_bufr, 
                                         cattr_bufr, &head, &end, &attr1_bufr);
   if (status != PDM_S_SUCCESS) {
      _PDMdebug (fn, "PDMget_new_map_bom_attr_bufr failed: %d \n", status);
      /*XX*/
      goto cleanup;
      /*return (status);*/
   }

  status = MEMbuild_array (attr_bufr);
  if (status != MEM_S_SUCCESS) {
    _PDMdebug ( fn, "MEMbuild_query (attr_bufr) 0x%.8x\n", status );
      goto cleanup;
      /*return (status);*/
  }

  status = MEMbuild_array (data_bufr);
  if (status != MEM_S_SUCCESS) {
    _PDMdebug ( fn, "MEMbuild_query (data_bufr) 0x%.8x\n", status );
      goto cleanup;
      /*return (status);*/
  }

  status = MEMbuild_array (attr1_bufr);
  if (status != MEM_S_SUCCESS) {
    _PDMdebug ( fn, "MEMbuild_query (attr1_bufr) 0x%.8x\n", status );
      goto cleanup;
      /*return (status);*/
  }
 }
   else if (status == PDM_I_NO_ROWS_FOUND) {
    _PDMdebug (fn, "No mapped attributes found \n");

/*
int PDMget_new_bom_attr_bufr (attr_bufr, data_bufr, 
                                 link_head, link_end, attr1_bufr)
*/
    status = PDMget_new_bom_attr_bufr (&attr_bufr, &data_bufr, cattr_bufr,
                                          &head, &end, &attr1_bufr);
  if (status != PDM_S_SUCCESS) {
      _PDMdebug (fn, "PDMget_new_bom_attr_bufr failed: %d \n", status);
      /*XX*/
      goto cleanup;
   }


  status = MEMbuild_array (attr_bufr);
  if (status != MEM_S_SUCCESS) {
    _PDMdebug ( fn, "MEMbuild_query (attr_bufr) 0x%.8x\n", status );
      goto cleanup;
      /*return (status);*/
  }

  status = MEMbuild_array (data_bufr);
  if (status != MEM_S_SUCCESS) {
    _PDMdebug ( fn, "MEMbuild_query (data_bufr) 0x%.8x\n", status );
      goto cleanup;
      /*return (status);*/
  }

  status = MEMbuild_array (attr1_bufr);
  if (status != MEM_S_SUCCESS) {
    _PDMdebug ( fn, "MEMbuild_query (attr1_bufr) 0x%.8x\n", status );
      goto cleanup;
      /*return (status);*/
  }
 }
 
   for (cur_mem = head; 
           cur_mem != NULL; cur_mem = cur_mem->next) {
      _PDMprint_bommember ("cur_mem", cur_mem);    
      _PDMdebug ("select_str", "%s\n", cur_mem->select_str);
      _PDMdebug ("insert_str", "%s\n", cur_mem->insert_str);
      _PDMdebug ("dyn_select_str", "%s\n", cur_mem->dyn_select_str);
      _PDMdebug ("dyn_insert_str", "%s\n", cur_mem->dyn_insert_str);
       }
/* create bom table */

    attr1 = (char **) (attr1_bufr)->data_ptr;
    attr = (char **) (attr_bufr)->data_ptr;


    sql_str = (char *) malloc ( ((attr1_bufr->row_size + 1) * 
                                 (attr1_bufr->rows + 5)) + 512);
    if (! sql_str) {
       _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n",
                        NFM_E_MALLOC);
       return (NFM_E_MALLOC);
     }
    sql_str[0] = '\0';
    _PDMdebug (fn, "mallocd sql_str size = %ld\n",  
         ( ((attr1_bufr->row_size + 1) * (attr1_bufr->rows + 5)) + 512));
    _PDMdebug (fn, "mallocd sql_str strlen = %ld\n",  (strlen (sql_str)));

    attr_str = (char *) malloc ((attr1_bufr->row_size) * 10 + 512);
        if (! attr_str) {
            _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n",
                        NFM_E_MALLOC);
           goto cleanup;
            /*return (NFM_E_MALLOC);*/
          }
    /* Arun, I changed the allocation size from 100 to row_size- Kumar */
    insert_attr_str = (char *) malloc ((attr1_bufr->rows) * attr1_bufr->row_size + 512);
        if (! insert_attr_str) {
            _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n",
                        NFM_E_MALLOC);
           goto cleanup;
            /*return (NFM_E_MALLOC);*/
          }

    insert_data_str = (char *) malloc ((attr1_bufr->rows) * attr1_bufr->row_size + 512);
        if (! insert_data_str) {
            _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n",
                        NFM_E_MALLOC);
           goto cleanup;
            /*return (NFM_E_MALLOC);*/
          }

    qry_list = (char *) malloc ((attr1_bufr->rows) * 10 + 512);
        if (! qry_list) {
            _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n",
                        NFM_E_MALLOC);
           goto cleanup;
            /*return (NFM_E_MALLOC);*/
          }

    attr_str[0] = '\0';
    insert_attr_str[0] = '\0';
    insert_data_str[0] = '\0';
    qry_list[0] = '\0';
    /* building the create string */
    comma = -1;
    for (attribute = 0; attribute < (attr_bufr)->rows; attribute++) {
      a_index = attribute * (attr_bufr->columns);
      if (comma == 1) {
       strcat (attr_str, ", ");
         }
      strcat (attr_str, attr[a_index + 1]);
      strcat (attr_str, " ");
      strcat (attr_str, attr[a_index + 4]);
      if (comma != 1) {
      comma = 1;
       }
      }
    _PDMdebug ("attr_str", "%s\n", attr_str);


/*
    status = PDMstart_transaction(1200);
    if (status != PDM_S_SUCCESS) {
        _PDMdebug (fn, "PDMstop_transaction failed status %d\n", status);
         goto cleanup;
    }
    
*/   
    
    insert_attr_str[0] = '\0';
     sprintf (sql_str, "CREATE TABLE %s ( %s ) ", exist_bom, attr_str);
     sprintf (rollback_str, "DROP TABLE %s ", exist_bom);
     
    status = SQLstmt (sql_str);
    if (status != SQL_S_SUCCESS) {
       _PDMdebug (fn, "Create BOM table failed : status : %d\n", status );
        SQLstmt (rollback_str);
        status = PDM_E_CREATE_BOM_TABLE;
        goto cleanup;
      }

    status = PDMstop_transaction(1200);
    if (status != PDM_S_SUCCESS) {
        _PDMdebug (fn, "PDMstop_transaction failed status %d\n", status);
         goto cleanup;
      }

/* insert a row into pdmboms table */
     
    status = _PDMupdate_pdmboms (cat_no, PDMpart.n_itemno, exist_bom);
    if (status != PDM_S_SUCCESS) {
       _PDMdebug (fn, "_PDMupdate_pdmboms : status : %d\n", status );
        SQLstmt (rollback_str);
       _PDMrollback_pdmboms (cat_no, PDMpart.n_itemno, exist_bom);
        goto cleanup;
      }
    

/* for each entry in the linked list, use sel_str to query the values
   and insert_str to insert it into the bom */

    _PDMdebug (fn, "Creating Insert String .... \n");
    row_no = 0;
    for (cur_mem = head->next; cur_mem != NULL; cur_mem = cur_mem->next) {
    row_no++;
    comma = -1;
    comma1 = -1;
    _PDMdebug (fn, "current_entry:[%s].[%s].[%s]\n",
                  cur_mem->cat_name, cur_mem->item_name, cur_mem->item_rev);
     sprintf (insert_attr_str, 
"p_citno, p_rowno, p_tagno, p_alttagno, n_catalogname,\
p_attached, p_history, p_quantity, p_childno, n_pcatalogno, n_pitemno, \
n_catalogno, n_itemno, p_explode, n_level, p_viewid, p_usageid");

      sprintf (insert_data_str,
"%d,%d,%d,'%s','%s', '%s', '%s', %s, %d, %d, %d, %d, %d, '%s', %d, '%s', '%s'",
      cur_mem->citno, row_no, cur_mem->tagno, cur_mem->alttagno, 
      cur_mem->cat_name,
      cur_mem->attached, cur_mem->history, cur_mem->quantity,
      cur_mem->childno, cur_mem->pcat_no, cur_mem->pitem_no,  cur_mem->cat_no,
      cur_mem->item_no, cur_mem->explode, cur_mem->level, cur_mem->viewid,
      cur_mem->usageid);

   _PDMdebug ("insert_data_str", "%s\n", insert_data_str);
   _PDMdebug ("insert_attr_str", "%s\n", insert_attr_str);

    /* get the values for other catalogs...*/

   _PDMdebug ("select_str", "%s\n", cur_mem->select_str);
   _PDMdebug ("dyn_select_str", "%s\n", cur_mem->dyn_select_str);
     
    dyn_attr_str = (char *) malloc ( 
                               ((strlen (cur_mem->dyn_select_str) + 1) * 10) 
                                        + 512);
    if (! dyn_attr_str) {
       _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n",
                        NFM_E_MALLOC);
       return (NFM_E_MALLOC);
     }
    dyn_attr_str[0] = '\0';
     
    stat_attr_str = (char *) malloc ( 
                               ((strlen (cur_mem->select_str) + 1) * 10) 
                                        + 512);
    if (! stat_attr_str) {
       _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n",
                        NFM_E_MALLOC);
       return (NFM_E_MALLOC);
     }
    stat_attr_str[0] = '\0';

    dyn_data_str = (char *) malloc ( 
                               ((strlen (cur_mem->dyn_select_str) + 1) * 10) 
                                        + 512);
    if (! dyn_data_str) {
       _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n",
                        NFM_E_MALLOC);
       return (NFM_E_MALLOC);
     }
   dyn_data_str[0] = '\0';
     
   stat_data_str = (char *) malloc ( 
                               ((strlen (cur_mem->select_str) + 1) * 10) 
                                        + 512);
   if (! stat_data_str) {
       _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n",
                        NFM_E_MALLOC);
       return (NFM_E_MALLOC);
     }
   stat_data_str[0] = '\0';

   Itemdesc[0] = '\0';

   status = _PDMget_cat_bom_vals (
                                   cur_mem->cat_no, cur_mem->cat_name, 
                                   cur_mem->file_class,
                                   cur_mem->dyn_cat_no, cur_mem->dyn_cat_name,
                                   cur_mem->item_name, cur_mem->item_rev,
                                   cur_mem->item_no, cur_mem->pdcno,
                                   cur_mem->select_str, 
                                   cur_mem->dyn_select_str,
                                   &stat_data_str, &stat_attr_str,
                                   &dyn_data_str, &dyn_attr_str,
                                   attr1_bufr, Itemdesc, &Altpartno);
    if (status != PDM_S_SUCCESS) {
       _PDMdebug (fn, " _PDMget_cat_bom_vals : status : %d\n", status );
        SQLstmt (rollback_str);
       _PDMrollback_pdmboms (cat_no, PDMpart.n_itemno, exist_bom);
        goto cleanup;
      }

/*
   if (PDMdebug_on) {
       MEMprint_buffer ("attr1_bufr after vals", attr1_bufr, PDM_DEBUG_FILE);
       }
*/
    
    if (strlen (stat_attr_str) > 0 ) {
       /*strcat (insert_attr_str, ", ");*/
       strcat (insert_attr_str, stat_attr_str);
       /*strcat (insert_data_str, ", ");*/
       strcat (insert_data_str, stat_data_str);
         }


   /* Inserting Dynamic attr values */
    /* fix added to check if pdcno > 0. This should not
        normally happen; but... MaC 010993 */
    if ( (strlen (dyn_data_str) > 0  ) &&
                                        (cur_mem->pdcno > 0) ) {
       strcat (insert_data_str, dyn_data_str);
         }
    if ( (strlen (dyn_attr_str) > 0  ) &&
                                        (cur_mem->pdcno > 0) ) {
       strcat (insert_attr_str, dyn_attr_str);
         }

    _PDMdebug ("insert_data_str", "%s\n", insert_data_str);
    _PDMdebug ("insert_attr_str", "%s\n", insert_attr_str);
    
     sql_str[0] = '\0';
     sprintf (sql_str, "INSERT INTO %s ( %s ) VALUES ( %s )", 
                               exist_bom, insert_attr_str, insert_data_str);
    _PDMdebug ("sql_str", "%s\n", sql_str);
     
    status = SQLstmt (sql_str);
    if (status != SQL_S_SUCCESS) {
       _PDMdebug (fn, "INSERT BOM table failed : status : %d\n", status );
        SQLstmt (rollback_str);
       _PDMrollback_pdmboms (cat_no, PDMpart.n_itemno, exist_bom);
        goto cleanup;
      }

/* added support for EID/CID catalogs to get n_itemname from
     e_catalog tables and not from pdmcit - Kumar 070593 */
     if ((!strcmp (cur_mem->file_class, "CID"))
          || (!strcmp (cur_mem->file_class, "EID")) ) {
          status = PDMget_partnum_rev_CID(cur_mem->cat_name, 
                                           cur_mem->item_no, 
                                           part_num, part_rev);
         }
     strcpy(part_num,cur_mem->item_name);
     strcpy(part_rev,cur_mem->item_rev);


/* added support for EXT catalogs and p_altpartno MaC 061593 */
     if ((!strcmp (cur_mem->file_class, "EXT"))
          || (!strcmp (cur_mem->file_class, "PXT"))
          || (!strcmp (cur_mem->file_class, "EID")) ){
      value[0] = '\0';
      e_cat[0] = '\0';
      _PDMdebug (fn, "itemdesc[%s]\n", Itemdesc);
       status = _PDMget_altpartno_from_tab_dyntab ( cur_mem->cat_name,
                                                    cur_mem->file_class, 
                                                    cur_mem->item_no, 
                                                    cur_mem->dyn_cat_name, 
                                                    cur_mem->pdcno, 
                                                    Altpartno,
                                                    value);
        if (status != PDM_S_SUCCESS) {
          _PDMdebug (fn, "_PDMget_altpartno_from_tab_dyntab failed 0x%.8x\n",
                                                                      status);
          }
         else 
          if (strcmp (value, "") ) {
            _PDMdebug (fn, "altpartno [%s]\n", value);
          strcpy (part_num, value);
             }
        if (Altpartno) free (Altpartno);
        }

    if (strcmp (Itemdesc, "")) {

     /* cleaning the Itemdesc string to remove $, ! and ' */

   _PDMdebug (fn, "cleand Itemdesc[%s]\n", Itemdesc);
       sprintf (sql_str, 
"UPDATE %s SET %s = '%s', %s = '%s', %s = '%s' %s %d %s %d %s %d %s %d", 
                       exist_bom,
                       "n_itemname", part_num,
                       "n_itemrev", part_rev,
                       "n_itemdesc", Itemdesc,
                       "WHERE n_catalogno = ", cur_mem->cat_no,
                       "AND n_itemno = ", cur_mem->item_no,
                       "AND p_childno = ", cur_mem->childno,
                       "AND n_level = ", cur_mem->level
);
           }
     else {
       sprintf (sql_str, 
"UPDATE %s SET %s = '%s', %s = '%s' %s %d %s %d %s %d %s %d", 
                       exist_bom,
                       "n_itemname", part_num,
                       "n_itemrev", part_rev,
                       "WHERE n_catalogno = ", cur_mem->cat_no,
                       "AND n_itemno = ", cur_mem->item_no,
                       "AND p_childno = ", cur_mem->childno,
                       "AND n_level = ", cur_mem->level
);
           }

    _PDMdebug ("sql_str", "%s\n", sql_str);
     
    status = SQLstmt (sql_str);
    if (status != SQL_S_SUCCESS) {
       _PDMdebug (fn, "INSERT BOM table failed : status : %d\n", status );
        PDMrollback_transaction(1200);
        SQLstmt (rollback_str);
       _PDMrollback_pdmboms (cat_no, PDMpart.n_itemno, exist_bom);
        goto cleanup;
      }

    sql_str[0] = '\0';
    insert_data_str[0] = '\0';
    insert_attr_str[0] = '\0';
    qry_list[0] = '\0';
    if (dyn_attr_str) free (dyn_attr_str);
    if (dyn_data_str) free (dyn_data_str);
    if (stat_data_str) free (stat_data_str);
    if (stat_attr_str) free (stat_attr_str);
  }


    status = PDMstart_transaction(1200);
    if (status != PDM_S_SUCCESS) {
        _PDMdebug (fn, "PDMstart_transaction failed status %d\n", status);
         return (status);
    }

/*
    status = PDMstop_transaction(1200);
    if (status != PDM_S_SUCCESS) {
        _PDMdebug (fn, "PDMstop_transaction failed status %d\n", status);
         return (status);
    }
*/
    goto wrapup;

cleanup:
  _PDMdebug (fn, "Cleaning up..\n");
  if ( sql_str) free (sql_str);
  if ( attr_str) free (attr_str);
  if ( insert_attr_str) free (insert_attr_str);
  if (insert_data_str) free (insert_data_str);
/*
  if (dyn_data_str) free (dyn_data_str);
  if (stat_data_str) free (stat_data_str);
*/
  if (attr1_bufr) MEMclose (&attr1_bufr);
  if (attr_bufr) MEMclose (&attr_bufr);
  if (data_bufr) MEMclose (&data_bufr);
  if (cattr_bufr) MEMclose (&cattr_bufr);
  if (map_bufr) MEMclose (&map_bufr);
  status1 = PDMrollback_transaction(1200);
  if (status1 != PDM_S_SUCCESS) {
        _PDMdebug (fn,  "PDMrollback_transaction failed status %d\n", status1);
        }
  _PDMdebug (fn, "freeing PDMbom_member struct ...\n");
  for (cur_mem = head; cur_mem != (struct PDMbom_member *) NULL; ) {
      temp_mem = cur_mem;
      cur_mem = cur_mem->next;
      _PDMdebug (fn, "freeing cat[%s] item[%s] ...\n",
                            temp_mem->cat_name, temp_mem->item_name);
      if (temp_mem->select_str) free (temp_mem->select_str);
      if (temp_mem->insert_str) free (temp_mem->insert_str);
      if (temp_mem->dyn_select_str) free (temp_mem->dyn_select_str);
      if (temp_mem->dyn_insert_str) free (temp_mem->dyn_insert_str);
      if (temp_mem) free ( temp_mem );
  }
  _PDMdebug (fn, "done freeing ...\n");
  _PDMdebug (fn, "failed: status: %d \n", status1);
  return (status);


wrapup:
  _PDMdebug (fn, "Wrapping up..\n");
  if ( sql_str) free (sql_str);
  if ( attr_str) free (attr_str);
  if ( insert_attr_str) free (insert_attr_str);
  if (insert_data_str) free (insert_data_str);
/*
  if (dyn_data_str) free (dyn_data_str);
  if (stat_data_str) free (stat_data_str);
*/
  if (attr1_bufr) MEMclose (&attr1_bufr);
  if (attr_bufr) MEMclose (&attr_bufr);
  if (data_bufr) MEMclose (&data_bufr);
  if (cattr_bufr) MEMclose (&cattr_bufr);
  if (map_bufr) MEMclose (&map_bufr);
  _PDMdebug (fn, "freeing PDMbom_member struct ...\n");
  for (cur_mem = head; cur_mem != (struct PDMbom_member *) NULL; ) {
       temp_mem = cur_mem;
       cur_mem = cur_mem->next;
       _PDMdebug (fn, "freeing cat[%s] item[%s] ...\n",
                            temp_mem->cat_name, temp_mem->item_name);
      if (temp_mem->select_str) free (temp_mem->select_str);
      if (temp_mem->insert_str) free (temp_mem->insert_str);
      if (temp_mem->dyn_select_str) free (temp_mem->dyn_select_str);
      if (temp_mem->dyn_insert_str) free (temp_mem->dyn_insert_str);
      if (temp_mem) free ( temp_mem );
   }
  _PDMdebug (fn, "done freeing ...\n");
  _PDMdebug (fn, "copying bomname to op...\n");
  /*exist1_bom[0] = '\0';*/
  strcpy (exist1_bom, exist_bom);
 _PDMdebug ("EXIT", "%s\n", fn);
 return (PDM_S_SUCCESS);
}

/* This function gets values for the attributes from the
   given catalog...*/

int _PDMget_cat_bom_vals (catno, catalog, cattype,
                          dyn_catno, dyn_catname,
                          partnum, revision,
                          item_no, pdcno,
                          qry_list, dyn_qry_list,
                          stat_data_str, stat_attr_str,
                          dyn_data_str, dyn_attr_str,
                          bom_attr_bufr, Itemdesc, Altpartno)
int	item_no, catno, pdcno, dyn_catno;
char	*catalog, *cattype;
char	*partnum, *revision;
char	*dyn_qry_list, *qry_list;
char	*dyn_catname;
char	**stat_data_str, **stat_attr_str;
char	**dyn_data_str, **dyn_attr_str;
MEMptr	bom_attr_bufr;
char	*Itemdesc, **Altpartno;
{
        char				*fn = "_PDMget_cat_bom_vals";
        char				**q_col;
        char				**q_data;
        char				**q_type;
        char				**bom_data;
        int				i, j, dyn_index;
	int				cat_cid = 0;
        MEMptr				qry_bufr = NULL;
        MEMptr				dqry_bufr = NULL;
        char				*sql_str;
        char				cid_partnum[240], cid_revision[240];
	char				val[241];
	char				ecatalog[241];

  _PDMdebug ("ENTER", "%s\n", fn);
  
  _PDMdebug (fn, 
    "\ncat[%s], itm#[%d], d_catnm[%s], \ncat#[%d], d_cat#[%d], pdc#[%d]\n",
                       catalog, item_no, dyn_catname, catno, dyn_catno, pdcno);
  _PDMdebug (fn, "catalog[%s]type[%s]\n", catalog, cattype);

    if (PDMdebug_on) {
       MEMprint_buffer ("bom_attr_bufr ", bom_attr_bufr, PDM_DEBUG_FILE);
       }

     status = MEMbuild_array (bom_attr_bufr);
        if (status != MEM_S_SUCCESS) {
          _PDMdebug ( fn, "MEMbuild_query (bom_attr_bufr) 0x%.8x\n", status );
          return (status);
           }

   
    i = (strlen (qry_list) + strlen (dyn_qry_list));
    _PDMdebug (fn, "qry_str size[%d]\n", i);

    sql_str = (char *) malloc ( (i * 10) + 512);
        if (! sql_str) {
            _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n",
                        NFM_E_MALLOC);
            return (NFM_E_MALLOC);
          }

    sql_str[0] = '\0';
    i = 0;

    if ( (strlen (dyn_qry_list) > 0) && (pdcno > 0) ) {
     sprintf (sql_str,
     "SELECT %s FROM %s WHERE %s = %d",
      dyn_qry_list, dyn_catname,
      "p_pdcno", pdcno);


     status = SQLquery (sql_str, &dqry_bufr, MEM_SIZE);
     if ( (status != SQL_S_SUCCESS) && 
             ( status != SQL_I_NO_ROWS_FOUND ) ){
       MEMclose (&dqry_bufr);
       _PDMdebug ( fn, "SQLquery 0x%.8x\n", status) ;
        free (sql_str);
       return (status);
     }
   
     if (status == SQL_S_SUCCESS ) {
     status = MEMbuild_array (dqry_bufr);
        if (status != MEM_S_SUCCESS) {
             MEMclose (&dqry_bufr);
          free (sql_str);
          _PDMdebug ( fn, "MEMbuild_query (dqry_bufr) 0x%.8x\n", status );
          return (status);
           }
   
       if (PDMdebug_on) {
          MEMprint_buffer("dynamic values from query", 
					dqry_bufr, PDM_DEBUG_FILE);
          }

     NFMRtic_it (dqry_bufr);
   
     bom_data = (char **) bom_attr_bufr->data_ptr;
     q_col = (char **) dqry_bufr->column_ptr;
     q_data = (char **) dqry_bufr->data_ptr;
     q_type = (char **) dqry_bufr->format_ptr;
     *dyn_data_str[0] = '\0';
     *dyn_attr_str[0] = '\0';
   
    for (j=0; j<bom_attr_bufr->rows; j++) {
     dyn_index = bom_attr_bufr->columns * j;
     for (i=0; i<dqry_bufr->columns; i++) {
/*   _PDMdebug ("columns", "[%s]<>[%s]\n", q_col[i], bom_data[dyn_index+4]); */
      if ((!strcmp (q_col[i], bom_data[dyn_index+4])) && 
                (atol (bom_data[dyn_index+2]) == dyn_catno) ) {
     if (strcmp (q_data[i], "")) {
     status = _PDMget_data_type (bom_data[dyn_index+6], q_data[i], val);
     if (status != PDM_S_SUCCESS) {
       MEMclose (&dqry_bufr);
       free (sql_str);
       _PDMdebug ( fn, "_PDMget_data_type 0x%.8x\n", status );
       return (status);
     }
     strcat ((*dyn_attr_str), ",");
     strcat ((*dyn_attr_str), bom_data[dyn_index+5]);
     strcat ((*dyn_data_str), ", ");
     strcat ((*dyn_data_str), val);
     _PDMdebug ("dyn_data_str", "%s\n", *dyn_data_str);
     _PDMdebug ("(*dyn_attr_str)", "%s\n", (*dyn_attr_str));
      break;
          }
        }
       }
     }
    }
  MEMclose (&dqry_bufr);
  }

   /* for the regular attributes ...*/

  ecatalog [0] = '\0';
  if ((!strcmp (cattype, "CID")) || (!strcmp(cattype, "EID")) ) {
     sprintf (ecatalog, "e_%s", catalog);
     cat_cid = 1;
     }
    else 
      {
       cat_cid = 0;
       strcpy (ecatalog, catalog);
     }

  if (!cat_cid) { /* we need to qry the cat and not e_cat for cidparts*/
  sprintf (sql_str,
     "SELECT %s FROM %s WHERE %s = %d",
                         qry_list, ecatalog, "n_itemno", item_no);

  _PDMdebug ("sql_str", "%s\n", sql_str);

  status = SQLquery (sql_str, &qry_bufr, MEM_SIZE);
  if ((status != SQL_S_SUCCESS) &&
        (status != SQL_I_NO_ROWS_FOUND)) {
    MEMclose (&qry_bufr);
    _PDMdebug ( fn, "SQLquery 0x%.8x\n", status) ;
     free (sql_str);
    return (status);
  }

  if( status == SQL_S_SUCCESS) {
  status = MEMbuild_array (qry_bufr);
  if (status != MEM_S_SUCCESS) {
    MEMclose (&qry_bufr);
    free (sql_str);
    _PDMdebug ( fn, "MEMbuild_query (qry_bufr) 0x%.8x\n", status );
    return (status);
  }

  NFMRtic_it (qry_bufr);

 if (PDMdebug_on) {
    MEMprint_buffer("qry_bufr from query", qry_bufr, PDM_DEBUG_FILE);
 }

  bom_data = (char **) bom_attr_bufr->data_ptr;
  q_col = (char **) qry_bufr->column_ptr;
  q_data = (char **) qry_bufr->data_ptr;
  q_type = (char **) qry_bufr->format_ptr;
  *stat_data_str[0] = '\0';
  *stat_attr_str[0] = '\0';
   
  for (j=0; j<bom_attr_bufr->rows; j++) {
    dyn_index = bom_attr_bufr->columns * j;
    for (i=0; i<qry_bufr->columns; i++) {
/*   _PDMdebug ("columns", "[%s]<>[%s]\n", q_col[i], bom_data[dyn_index+4]); */
     if ((!strcmp (q_col[i], bom_data[dyn_index+4])) && 
                (atol (bom_data[dyn_index+2]) == catno) ) {
     if (strcmp (q_data[i], "")) {
     status = _PDMget_data_type (bom_data[dyn_index+6], q_data[i], val);
     if (status != PDM_S_SUCCESS) {
       MEMclose (&dqry_bufr);
       free (sql_str);
       _PDMdebug ( fn, "_PDMget_data_type 0x%.8x\n", status );
       return (status);
     }
     strcat ((*stat_attr_str), ",");
     strcat ((*stat_attr_str), bom_data[dyn_index+5]);
     strcat ((*stat_data_str), ", ");
     strcat ((*stat_data_str), val);
     _PDMdebug ("stat_data_str", "%s\n", *stat_data_str);
     _PDMdebug ("(*stat_attr_str)", "%s\n", (*stat_attr_str));
      break;
         }
        }
       }
     }
   }
  }
   else {
     _PDMdebug (fn, "This part is a COMPUTED ID PART \n");
  
     /* get the partnum, rev since the char len for itemname
        in pdmcit is 40 and cid/eid parts can be longer. */

     cid_partnum[0] = '\0';
     cid_revision[0] = '\0';

     status = PDMi_get_partnum_rev(ecatalog, item_no, 
                                               cid_partnum, cid_revision);
     if (status != PDM_S_SUCCESS) {
        _PDMdebug (fn, "_PDMget_cat_bom_vals_for_CID_part Failed 0x%.8x\n", 
                                                                    status);
       (*stat_data_str)[0] = '\0';
       (*stat_attr_str)[0] = '\0';
        }

     status = _PDMget_cat_bom_vals_for_CID_part (catno, catalog, 
                                                 cid_partnum, cid_revision,
                                                 item_no, qry_list,
                                                 pdcno, dyn_catname,
                                                 stat_data_str, stat_attr_str,
                                                 bom_attr_bufr, Itemdesc, 
                                                 Altpartno);
     if (status != PDM_S_SUCCESS) {
        _PDMdebug (fn, "_PDMget_cat_bom_vals_for_CID_part Failed 0x%.8x\n", 
                                                                    status);
       (*stat_data_str)[0] = '\0';
       (*stat_attr_str)[0] = '\0';
       
  
        }
 
    }
   _PDMdebug (fn, "Itemdesc[%s]\n", Itemdesc);
   if (sql_str) free (sql_str);
  _PDMdebug ("EXIT", "%s\n", fn);
  return (PDM_S_SUCCESS);
}

int _PDMrollback_pdmboms (cat_no, item_no, exist_bom)
char		*exist_bom;
int		cat_no, item_no;
{
	char		*fn = "_PDMrollback_pdmboms";
	char		sql_str [512];
        int             status;

   _PDMdebug ("ENTER", "%s\n", fn);
   
   _PDMdebug (fn, "Deleting pdmboms for %d.%d.%s\n", 
                                    cat_no, item_no, exist_bom);


     sprintf (sql_str, 
       "DELETE FROM pdmboms WHERE %s = %d AND %s = %d AND %s = '%s'",
       "n_catalogno", cat_no,
       "n_itemno", item_no, 
       "p_bomname", exist_bom);
     
    status = SQLstmt (sql_str);
    if (status != SQL_S_SUCCESS) {
       _PDMdebug (fn, "SQLstatement : status : %d\n", status );
        return (status);
      }



   _PDMdebug ("EXIT", "%s\n", fn);
   return (PDM_S_SUCCESS);

}







int PDMadd_rows_to_bom (attr_bufr, data_bufr, head)
MEMptr          *attr_bufr;
MEMptr          *data_bufr;
struct PDMbom_member		*head;
{
        char				*fn = "PDMadd_rows_to_bom";
        char				**data, **attr;
        char				sql_str[1024];
	struct PDMbom_member		*cur_mem;

        PDMdebug("ENTER PDMretreive_bom_content \n");

  cur_mem = head;

  status = MEMbuild_array (*attr_bufr);
  if (status != MEM_S_SUCCESS) {
    _PDMdebug ( fn, "MEMbuild_query (qry_bufr) 0x%.8x\n", status );
    return (status);
  }

  status = MEMbuild_array (*attr_bufr);
  if (status != MEM_S_SUCCESS) {
    _PDMdebug ( fn, "MEMbuild_query (qry_bufr) 0x%.8x\n", status );
    return (status);
  }

 if (PDMdebug_on) {
    MEMprint_buffer("data_bufr", *data_bufr, PDM_DEBUG_FILE);
    MEMprint_buffer("attr_bufr", *attr_bufr, PDM_DEBUG_FILE);
 }


  attr = (char **) (*attr_bufr)->data_ptr;
  data = (char **) (*data_bufr)->data_ptr;


        sql_str[0] = '\0';

        status = PDMload_part_info(PDMexec->catalog, PDMexec->part_num,
            PDMexec->revision);
        if (status != PDM_S_SUCCESS) {
                _PDMdebug (fn, "PDMload_part_info failed status %d\n", status);
                return (status);
        }

        _PDMdebug (fn, "catno = %d, partno = %d, parttype = %s,n_status = %s\n",
            PDMpart.n_catalogno,PDMpart.n_itemno,PDMpart.p_parttype,
            PDMpart.n_status);



 _PDMdebug ("EXIT", "%s\n", fn);
 return (PDM_S_SUCCESS);
}
    
int _PDMorig_get_cat_bom_vals (dyn_val_str, insert_attr_str, stat_val_str,
                          qry_list, dyn_qry_list,
                          item_no, pdcno,
                          catno, catalog,
                          dyn_catname)
char	**dyn_val_str, **insert_attr_str, **stat_val_str;
char	*dyn_qry_list, *qry_list;
char	*catalog;
char	*dyn_catname;
int	item_no, catno, pdcno;
{
        char				*fn = "_PDMget_cat_bom_vals";
        char				**q_data;
        char				**q_type;
        int				i;
        MEMptr				qry_bufr = NULL;
        MEMptr				dqry_bufr = NULL;
        char				*sql_str;
	char				val[30];

  _PDMdebug ("ENTER", "%s\n", fn);
  
  _PDMdebug (fn, 
    "\ncatalog[%s], item_no[%d], dyn_catname[%s], \ncatno[%d], pdcno[%d]\n",
                                catalog, item_no, dyn_catname, catno, pdcno);

    sql_str = (char *) malloc ((strlen (qry_list)) * 10 + 512);
        if (! sql_str) {
            _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n",
                        NFM_E_MALLOC);
            return (NFM_E_MALLOC);
          }

    sql_str[0] = '\0';

    if ( (strlen (dyn_qry_list) > 0) && (pdcno > 0) ) {
     sprintf (sql_str,
     "SELECT %s FROM %s WHERE %s = %d",
      dyn_qry_list, dyn_catname,
      "p_pdcno", pdcno);


     status = SQLquery (sql_str, &dqry_bufr, MEM_SIZE);
     if ( (status != SQL_S_SUCCESS) && 
             ( status != SQL_I_NO_ROWS_FOUND ) ){
       MEMclose (&dqry_bufr);
       _PDMdebug ( fn, "SQLquery 0x%.8x\n", status) ;
        free (sql_str);
       return (status);
     }
   
     if (status == SQL_S_SUCCESS ) {
     status = MEMbuild_array (dqry_bufr);
        if (status != MEM_S_SUCCESS) {
             MEMclose (&dqry_bufr);
          free (sql_str);
          _PDMdebug ( fn, "MEMbuild_query (dqry_bufr) 0x%.8x\n", status );
          return (status);
           }
   
       if (PDMdebug_on) {
          MEMprint_buffer("dynamic values from query", 
					dqry_bufr, PDM_DEBUG_FILE);
          }

     NFMRtic_it (dqry_bufr);
   
     q_data = (char **) dqry_bufr->data_ptr;
     q_type = (char **) dqry_bufr->format_ptr;
   
   
     for (i=0; i<dqry_bufr->columns; i++) {
     status = _PDMget_data_type (q_type[i], q_data[i], val);
     if (status != PDM_S_SUCCESS) {
       MEMclose (&dqry_bufr);
       free (sql_str);
       _PDMdebug ( fn, "_PDMget_data_type 0x%.8x\n", status );
       return (status);
     }
     strcat ((*dyn_val_str), ", ");
     strcat ((*dyn_val_str), val);
     _PDMdebug ("dyn_val_str", "%s\n", *dyn_val_str);
      }
   
/*
     strcat ((*insert_attr_str), ", ");
     strcat ((*insert_attr_str), dyn_qry_list);
*/
   
     _PDMdebug ("insert_attr_str", "%s\n", *insert_attr_str);
    }
  MEMclose (&dqry_bufr);
  }



     sprintf (sql_str,
     "SELECT %s FROM %s WHERE %s = %d",
                         qry_list, catalog, "n_itemno", item_no);

   _PDMdebug ("sql_str", "%s\n", sql_str);

  status = SQLquery (sql_str, &qry_bufr, MEM_SIZE);
  if (status != SQL_S_SUCCESS) {
    MEMclose (&qry_bufr);
    _PDMdebug ( fn, "SQLquery 0x%.8x\n", status) ;
     free (sql_str);
    return (status);
  }


  status = MEMbuild_array (qry_bufr);
  if (status != MEM_S_SUCCESS) {
    MEMclose (&qry_bufr);
    free (sql_str);
    _PDMdebug ( fn, "MEMbuild_query (qry_bufr) 0x%.8x\n", status );
    return (status);
  }

  NFMRtic_it (qry_bufr);

 if (PDMdebug_on) {
    MEMprint_buffer("qry_bufr from query", qry_bufr, PDM_DEBUG_FILE);
 }


  q_data = (char **) qry_bufr->data_ptr;
  q_type = (char **) qry_bufr->format_ptr;


  for (i=0; i<qry_bufr->columns; i++) {
  status = _PDMget_data_type (q_type[i], q_data[i], val);
  if (status != PDM_S_SUCCESS) {
    MEMclose (&qry_bufr);
    free (sql_str);
    _PDMdebug ( fn, "_PDMget_data_type 0x%.8x\n", status );
    return (status);
  }
  strcat ((*stat_val_str), ", ");
  strcat ((*stat_val_str), val);
  _PDMdebug ("stat_val_str", "%s\n", *stat_val_str);
   }

/*
  strcat ((*insert_attr_str), ", ");
  strcat ((*insert_attr_str), qry_list);
*/

  _PDMdebug ("insert_attr_str", "%s\n", *insert_attr_str);



   MEMclose (&qry_bufr);
   free (sql_str);
  _PDMdebug ("EXIT", "%s\n", fn);
  return (PDM_S_SUCCESS);
}




    
int _PDMget_altpartno_from_tab_dyntab ( catalog, type, itemno, 
                                          dyn_catname, pdcno, 
                                          where_cls, altpartno)
int	 pdcno, itemno;
char	*dyn_catname, *catalog;
char	*where_cls;
char	*altpartno;
{
        char			*fn = "_PDMget_altpartno_from_tab_dyntab";
        char			**q_data;
        MEMptr			qry_bufr = NULL;
        MEMptr			dqry_bufr = NULL;
        char			sql_str [1024];
        char			ecat [24];

  _PDMdebug ("ENTER", "%s\n", fn);
  
  _PDMdebug (fn, 
    "\ncatalog[%s], type[%s],item_no[%d], dyn_catname[%s], pdcno[%d]\n",
                                catalog, type, itemno, dyn_catname, pdcno);

     
    ecat[0] = '\0';
    if (!strcmp (type, "EID") )
       sprintf (ecat, "e_%s", catalog);
    else
       strcpy (ecat, catalog);

     sprintf (sql_str,
     "SELECT p_altpartno FROM %s WHERE %s = %d",
      ecat, "n_itemno", itemno);

     _PDMdebug (fn, "Trying to get p_altpartno from e_cat [%s]\n", ecat);

     status = SQLquery (sql_str, &qry_bufr, MEM_SIZE);
     if (status == SQL_S_SUCCESS ) {
     _PDMdebug (fn, "Found p_altpartno in [%s]\n", ecat);
     status = MEMbuild_array (qry_bufr);
        if (status != MEM_S_SUCCESS) {
           MEMclose (&qry_bufr);
          _PDMdebug ( fn, "MEMbuild_query (qry_bufr) 0x%.8x\n", status );
          return (status);
           }
   
     NFMRtic_it (dqry_bufr);
   
     q_data = (char **) qry_bufr->data_ptr;
   
     altpartno[0] = '\0';
     strcpy (altpartno, q_data[0]);
     MEMclose (&qry_bufr);
     _PDMdebug (fn, "Altpartno = %s\n", altpartno);
     _PDMdebug (fn, "EXIT from ecat tab\n");
     return (PDM_S_SUCCESS);
     }

    /* sql qry1 was not success */

    if ((!strcmp (type, "EID")) && (where_cls)) {

     _PDMdebug (fn, "Trying to get p_altpartno from view [%s]\n", catalog);

     sprintf (sql_str,
     "SELECT p_altpartno FROM %s WHERE %s",
      catalog, where_cls);

     if (qry_bufr) free (qry_bufr);
     status = SQLquery (sql_str, &qry_bufr, MEM_SIZE);
     if (status == SQL_S_SUCCESS ) {
     _PDMdebug (fn, "Found p_altpartno in [%s]\n", catalog);
     status = MEMbuild_array (qry_bufr);
        if (status != MEM_S_SUCCESS) {
           MEMclose (&qry_bufr);
          _PDMdebug ( fn, "MEMbuild_query (qry_bufr) 0x%.8x\n", status );
          return (status);
           }
   
     NFMRtic_it (dqry_bufr);
   
     q_data = (char **) qry_bufr->data_ptr;
   
     altpartno[0] = '\0';
     strcpy (altpartno, q_data[0]);
     MEMclose (&qry_bufr);
     _PDMdebug (fn, "Altpartno = %s\n", altpartno);
     _PDMdebug (fn, "EXIT from view tab\n");
     return (PDM_S_SUCCESS);
       }
     }

   /* This means that the e_tab or view do not have the 
      altpartno columns */

     _PDMdebug (fn, "Trying to get p_altpartno from dyn tab [%s]\n", 
                                                     dyn_catname);
     sprintf (sql_str, "SELECT %s FROM %s WHERE %s = %d",
      "p_altpartno", dyn_catname,
      "p_pdcno", pdcno);

     status = SQLquery (sql_str, &dqry_bufr, MEM_SIZE);
     if (status != SQL_S_SUCCESS) { 
       MEMclose (&dqry_bufr);
       _PDMdebug ( fn, "SQLquery 0x%.8x\n", status) ;
       return (status);
     }
   
     if (status == SQL_S_SUCCESS ) {
     _PDMdebug (fn, "Found p_altpartno in [%s]\n", dyn_catname);
     status = MEMbuild_array (dqry_bufr);
        if (status != MEM_S_SUCCESS) {
             MEMclose (&dqry_bufr);
          free (sql_str);
          _PDMdebug ( fn, "MEMbuild_query (dqry_bufr) 0x%.8x\n", status );
          return (status);
           }
   
     NFMRtic_it (dqry_bufr);
   
     q_data = (char **) dqry_bufr->data_ptr;
   
     altpartno[0] = '\0';
     strcpy (altpartno, q_data[0]);
     _PDMdebug (fn, "Altpartno = %s\n", altpartno);
     _PDMdebug (fn, "EXIT from dyn tab\n");
      MEMclose (&dqry_bufr);
     return (PDM_S_SUCCESS);
        }
     
  _PDMdebug ("EXIT", "%s\n", fn);
  return (status);
}

