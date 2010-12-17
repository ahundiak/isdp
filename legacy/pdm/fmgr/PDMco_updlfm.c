#include		<stdio.h>
#include                "PDUerror.h"
#include		"MEMstruct.h"
#include		"MEMerrordef.h"
#include		"NFMerrordef.h"
#include		"SQLerrordef.h"
#include		"PDUris_incl.h"
#include		"NFMfile.h"
#include		"NFMschema.h"
#include		"NFMapi.h"
#include		"NFMitems.h"
#include		"NFMitemfiles.h"
#include		"PDMproto.h"

extern		int		PDMdebug_on;
extern		char	PDM_DEBUG_FILE[];
extern          PDMpart_ptr     PDMpart;
static 		long		status;
static		char		s[1024];


#define UPDMEM  7   /* fileversion in LFM is old; so move */
#define ATTCH   8   /* file attached but local */
#define MOVE    9   /* file attached and not local */
#define NOPE    10   /* file not attached */

/**********************************************************************
 This file contains code to update file manager table (NFMSAFILES)
 after a checkout command.

 Arun Madhwesh (021092)
**********************************************************************/

/*
 Algorithm:
  For Check_out:
   o get the list of parts of the assy from the database
   o get local file manager information for each of the parts
   o get the n_co, n_copy and n_ref for each of the  part
     and determine whether the file(s) need to be moved.
   if (parent) mark the file as to_be_moved
   else {
     if (n_co && n_ref > 0)
         mark the file  as !to_be_moved
     if (!n_co && n_ref > 0) {
         get the version of the file(s) in the LFM
         get the version of the file(s) in WS
         if (V(WS) > V(LFM)) mark the file as to_be_moved
         else mark the file as !to_be_moved
         }
     if (!n_co && n_ref <= 0)
        mark the file as to_be_moved
     if (sql_no_rows_found){
        mark the file as to_be_moved
        set a flag that a new entry has to be made in LFM
        }
      }
       INPUT: struct NFMitem_entry *NFMitem_files 
               Global variable containing info about processed files
                   and items
              struct NFMset_member *head, *end;
               head and tail of a linked list  containing info 
                  about all the items of a set/assembly  
               

	OUTPUT: <NULL>
	
*/
extern struct NFMitem_entry *NFMitem_files ;

/*
	Should be called after a successfull file transfer

*/

int  PDMco_update_filemanager(n_catalogname,n_itemname,n_itemrev, pcat_no, 
                              pitem_no, set_head, set_end, out_bufr, file_bufr)
char    *n_catalogname;
char    *n_itemname;
char    *n_itemrev;
MEMptr  out_bufr;
MEMptr  *file_bufr;
int	pcat_no, pitem_no;
struct	NFMset_member	*set_head, *set_end;
{
        char		*fn = "PDMco_update_filemanager";
	char	        **columns, **data;
	int		n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12;
	int		i, nxi, x, y, done;
        char    sql_str[300];
        int     new_ref_count;
        char	n_filename[40],n_co[2],n_copy[2], n_mountpoint[40], n_nfs[2];
        int	n_sano, n_filenum;
	int	n_fileversion,n_ref,n_cisano;
	int	item_no, cat_no;
        int     parent_already_updated;
        int	tmp_bufr_row_no;
	MEMptr  tmp_bufr = NULL;
        char    tmp_row[300];
	struct	NFMitem_entry	*aci;
	struct	NFMfile_entry	*cfi;
	struct	NFMset_member	*head;

  PDMdebug("ENTER:PDMco_update_filemanager\n");

/* ANSI */
   set_end = NULL;

   _PDMdebug (fn, "catalog[%s] part[%s] rev[%s]\n", 
                       n_catalogname, n_itemname, n_itemrev);

/* added to create buffer with all the filenames of the parent 
   to be sent to PDU for updating the object space - MaC 042192 */

      status = MEMopen (&tmp_bufr, 512);
       if (status != MEM_S_SUCCESS) {
      _PDMdebug (fn, "MEMopen failed: status %d\n", status);
       return (status);
      }

      status = MEMwrite_format (tmp_bufr, "n_cofilename", "char(30)");
         if (status != MEM_S_SUCCESS) {
         _PDMdebug (fn, "MEMwrite_format failed: status %d\n", status);
          return (status);
      }


   status = MEMbuild_array(tmp_bufr);
   if(status != MEM_S_SUCCESS) {
		sprintf(s,"MEMbuild_array failed status %d\n",status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
   }

  parent_already_updated = -1;
  if(out_bufr) {
   /* this means all the files have been moved and we need to add
      rows for each file moved ...*/
   _PDMdebug (fn, 
"All files have been moved, records for all the files have to be updated\n");
   
  if (PDMdebug_on) {
    MEMprint_buffer("out_bufr", out_bufr, PDM_DEBUG_FILE);
    }

   status = MEMbuild_array(out_bufr);
   if(status != MEM_S_SUCCESS) {
		sprintf(s,"MEMbuild_array failed status %d\n",status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
   }
   columns = (char **) out_bufr->column_ptr;
   data = (char **) out_bufr->data_ptr;
   n1 = -1; n2 = -1; n3 = -1; 
   n4 = -1; n5 = -1; n6 = -1; 
   n7 = -1; n8 = -1; n9 = -1;
   n10 = -1; n11 = -1; n12 = -1;
   for(i=0;i<out_bufr->columns;i++) {
		if(!strcmp(columns[i],"n_sano")) 		n1 = i;
		if(!strcmp(columns[i],"n_catalogno"))  		n2 = i;
		if(!strcmp(columns[i],"n_itemno"))		n3 = i;
		if(!strcmp(columns[i],"n_filename"))  		n4 = i;
		if(!strcmp(columns[i],"n_filenum"))    		n5 = i;
		if(!strcmp(columns[i],"n_fileversion")) 	n6 = i;
		if(!strcmp(columns[i],"n_co"))   	 	n7 = i;
		if(!strcmp(columns[i],"n_copy"))   	 	n8 = i;
		if(!strcmp(columns[i],"n_ref"))   	 	n9 = i;
		if(!strcmp(columns[i],"n_nfs"))   	 	n10 = i;
		if(!strcmp(columns[i],"n_cisano"))   	 	n11 = i;
		if(!strcmp(columns[i],"n_mountpoint"))   	n12 = i;
   }
   if(n1 == -1 || n2 == -1 || n3 == -1 || 
      n4 == -1 || n5 == -1 || n6 == -1 || 
      n7 == -1 || n8 == -1 || n9 == -1 ||
      n10 == -1 || n11 == -1 || n12 == -1) {
		PDMdebug("Could not find cols in <out_bufr>\n");
		return(PDM_E_BUFFER_FORMAT);
   }
/*
   status = PDMi_get_date(c_date,c_time);
   if(status != PDM_S_SUCCESS) {
		sprintf(s,"PDMi_get_date failed status %d\n",status);
		PDMdebug(s);
		return(status);
   }
*/

/* for each entry in the buffer, update n_co = Y and n_ref = n_ref + 1 */


for(i=0;i<out_bufr->rows;i++) {
   nxi = i * out_bufr->columns;

   new_ref_count = atol (data [nxi+n9]);

/* there is a scenario that if the parent assy of this subassy is already
   checked out, this subassy_file is already local. This means that 
   lfm_buffer has an entry for this part. Since this part is being
   checked out, the file *has* to be moved; and hence there is an 
   entry also in the linked list o/p of NFMcheckout. This means that
   lfm will be updated by both mechanism. 
   To avoid this, we set a flag parent_already_updated, which will be set to 
   1, if the lfmbuffer already has updated the lfm. MaC */

   if ( ( (atol (data[nxi + n2])) == pcat_no) &&
         ( (atol (data[nxi + n3])) == pitem_no) ){
         _PDMdebug (fn, "Parent being updated and flag set to true\n");
         parent_already_updated = 1;
     }
   sprintf(sql_str,
"UPDATE NFMSAFILES SET n_ref = %d, n_co = '%s'  WHERE n_sano = %s AND n_catalogno = %s AND n_itemno = %s AND n_filenum = %s AND n_fileversion = %s AND n_filename = '%s'", 
new_ref_count, data[nxi+n7], data[nxi+n1],  
    data[nxi+n2], data[nxi+n3], 
    data[nxi+n5], data[nxi+n6], 
    data[nxi+n4]);

    _PDMdebug ("sql_stmt", "\n%s\n", sql_str);
    
      status = SQLstmt (sql_str);
       if (status != SQL_S_SUCCESS) {
         if (status == SQL_E_MESSAGE)  {
           _PDMdebug ("Retrying", "%s\n",  sql_str);
           status = _PDMRetrySqlStmt (sql_str);
           if (status != PDM_S_SUCCESS) {
              _PDMdebug (fn, "SQLstmt Failed 0x%.8x\n", status);
              return(PDM_E_SQL_STMT);
              }
            }
            else {
              /* report a error */
        _PDMdebug (fn, "SQLstmt %d\n", status);
        _PDMdebug (fn, "Update failed for %s %s %s\n",
          data[nxi+n2], data[nxi+n3], data[nxi+n4]);
    status = _PDMget_db_error (status);
          return (status);
             }
         }
       }
   }


    /* If the out_bufr is empty; none of the files have any entry in LFM */

   /* extract the information from the global structure and 
      insert row/s into NFMSAFILES table */
     n_filename[0] = '\0'; n_co[0] = '\0';
     n_copy[0] = '\0'; n_nfs[0] = '\0'; n_mountpoint[0] = '\0';

	_PDMprint_itementry ("NFMitem_files", NFMitem_files);

     tmp_bufr_row_no = 1;
     for ( x = 0, aci = NFMitem_files;
                 aci != (struct NFMitem_entry *) NULL;
                                    aci = aci->next_item, ++x) {
	_PDMprint_itementry ("aci", aci);
          cat_no = aci->cat_no;
          item_no = aci->item_no;
          n_ref = 1;
          strcpy(n_co, "Y");
          done = 0;
          /* now copy file related information */
     for ( y = 0, cfi = aci->next_file;
                  cfi != (struct NFMfile_entry *) NULL;
                                    cfi = cfi->next_file, ++y) {
	_PDMprint_fileentry ("cfi", cfi);
          strcpy(n_filename, cfi->cofilename);
	  n_sano = cfi->cosano;
        /*	  n_filenum = cfi->fileno; */

/* modified 022692 - MaC. using n_filenum instead of n_fileno */

          status = PDMget_filenum (item_no, aci->cat_name, 
                                    n_filename, &n_filenum );
          if (status != PDM_S_SUCCESS) {
		_PDMdebug (fn, "PDMget_filenum failed status %d\n",status);
		return(status);
                }
          _PDMdebug (fn, "cfi->filenum[%d], n_filenum[%d]\n",
                                       cfi->filenum, n_filenum); 
	  n_fileversion = cfi->fileversion;
	  n_cisano = cfi->cisano;
             
	     /* Now insert this row into the table */

       /* check to see if n_co or n_copy should be set */
_PDMdebug (fn, "parent_already_updated = %d\n", parent_already_updated);
     
        if ( !strcmp (aci->cat_name, n_catalogname) &&
                        !strcmp (aci->item_name, n_itemname) &&
                        !strcmp (aci->item_rev, n_itemrev)) {
         /* found the parent */
        if (parent_already_updated != 1) {
          _PDMdebug (fn, "parent[%s] not updated\n", aci->item_name);
sprintf(sql_str,
"INSERT INTO NFMSAFILES (n_sano,n_filename,n_catalogno, n_itemno,n_filenum,\
  n_fileversion,n_ref,n_co, n_copy, n_cisano) \
  VALUES(%d,'%s',%d,%d,%d,%d,%d,'%s', '%s', %d)", 
n_sano,n_filename,cat_no, item_no,n_filenum,
                       n_fileversion,0,n_co, "N", n_cisano);
                             }

         tmp_row [0] = '\0';
         sprintf (tmp_row, "%s\1", cfi->cofilename);
         _PDMdebug ("tmp_row", "%s\n", tmp_row);
         /*status = MEMwrite_data (tmp_bufr, cfi->cofilename, 
                                             tmp_bufr_row_no, 1);*/
         status = MEMwrite (tmp_bufr, tmp_row);
         if (status != MEM_S_SUCCESS) {
              _PDMdebug (fn, "MEMwrite_data failed %d\n", status );
              return (status);
         }
         tmp_bufr_row_no++;

       }
       else {
        /* this part was added to stop inserting a row if
         a child_file was moved due to outdated fileversion..*/

        for (head = set_head; head != (struct NFMset_member *) NULL;
                                            head = head->next )  {
        if ( (aci->cat_no == head->cat_no ) &&
                ( aci->item_no == head->item_no ) &&
                ( !strcmp (cfi->cofilename, head->co_filename)) ){
                if (head->move == UPDMEM )
                done = 1;
                break;
               }
           }
           if (done) {
           _PDMdebug (fn, "file already updated..\n");
           _PDMdebug (fn, "catname[%s], itemname[%s], filename[%s]\n",
               aci->cat_name, aci->item_name, cfi->cofilename);
            break;
            }
sprintf(sql_str,
"INSERT INTO NFMSAFILES (n_sano,n_filename,n_catalogno, n_itemno,n_filenum,\
  n_fileversion,n_ref, n_co, n_copy, n_cisano) \
  VALUES(%d,'%s',%d,%d,%d,%d,%d,'%s', '%s', %d)", 
n_sano,n_filename,cat_no, item_no,n_filenum,
                       n_fileversion,1, "N", "N", n_cisano);
                             }
    _PDMdebug ("sql_stmt", "\n%s\n", sql_str);
    
      status = SQLstmt (sql_str);
       if (status != SQL_S_SUCCESS) {
         if (status == SQL_E_MESSAGE)  {
           _PDMdebug ("Retrying", "%s\n",  sql_str);
           status = _PDMRetrySqlStmt (sql_str);
           if (status != PDM_S_SUCCESS) {
              _PDMdebug (fn, "SQLstmt Failed 0x%.8x\n", status);
              return(PDM_E_SQL_STMT);
              }
            }
            else {
        _PDMdebug (fn, "SQLstmt %d\n", status);
        _PDMdebug (fn, "Update failed for %s %s %s\n",
	  aci->cat_name, aci->item_name, cfi->cofilename);
    status = _PDMget_db_error (status);
          return (status);
             }
         }
     done = 0;
     }

     /* next item */
  }

  if (PDMdebug_on) {
    MEMprint_buffer("file_bufr", tmp_bufr, PDM_DEBUG_FILE);
    }

  *file_bufr = tmp_bufr;
  PDMdebug("EXIT:PDMco_update_filemanager\n");
  return(PDM_S_SUCCESS);
}

int  PDMco_item_update_filemanager(n_catalogname,n_itemname,n_itemrev,
                                     cat_no, part_no, sano, file_bufr)
char    *n_catalogname;
char    *n_itemname;
char    *n_itemrev;
int     cat_no, part_no, sano;
MEMptr	*file_bufr;
{
        char		*fn = "PDMco_item_update_filemanager";
	char	        **columns, **data, **list_data;
	int		n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12;
	int		i, nxi;
        char    	sql_str[300];
        int     	index;
        MEMptr		list = NULL, list1 = NULL;
        MEMptr		tmp_bufr = NULL;
        char		tmp_row[300];


  PDMdebug("ENTER:PDMco_item_update_filemanager\n");

   _PDMdebug (fn, "catalog[%s] part[%s] rev[%s] cat_no[%d] part_no[%d]\n", 
                       n_catalogname, n_itemname, n_itemrev, cat_no, part_no);

/* added support for creating a buffer which contains all the filenames
   for this part. This is for PDU to update the object space -MaC 042192*/

      status = MEMopen (&tmp_bufr, 512);
       if (status != MEM_S_SUCCESS) {
      _PDMdebug (fn, "MEMopen failed: status %d\n", status);
       return (status);
      }

      status = MEMwrite_format (tmp_bufr, "n_cofilename", "char(30)");
         if (status != MEM_S_SUCCESS) {
         _PDMdebug (fn, "MEMwrite_format failed: status %d\n", status);
          return (status);
      }


       status = MEMbuild_array(tmp_bufr);
       if(status != MEM_S_SUCCESS) {
	sprintf(s,"MEMbuild_array failed status %d\n",status);
	PDMdebug(s);
	return(PDM_E_BUILD_ARRAY);
       }


/* 031892: added sano support: if the item/part has been copied to some
           other sano, we are not interested... -MaC */

  sql_str[0] = '\0';
  sprintf (sql_str,
  "SELECT n_sano, n_catalogno, n_itemno, n_filename, n_filenum, n_fileversion,\
    n_co, n_copy, n_ref, n_nfs, n_cisano, n_mountpoint FROM NFMSAFILES WHERE\
    n_sano = %d AND ( n_itemno = %d AND n_catalogno = %d ) ", sano, part_no, cat_no);

    _PDMdebug ("sql_qry", "\n%s\n",sql_str);

  status = SQLquery (sql_str, &list, MEM_SIZE);
  if ( status != SQL_S_SUCCESS &&
           status != SQL_I_NO_ROWS_FOUND) {
    MEMclose (&list);
    _PDMdebug  (fn, "SQLquery Failed %d\n", status) ;
    status = _PDMget_db_error (status);
    return (status);
   }
 /* if no_rows_found; all things being equal, all the files have to
    be moved */
    if ( status == SQL_I_NO_ROWS_FOUND ) {
   _PDMdebug (fn, "There are NO entries in LFM\n");
/* old query ..
  sprintf (sql_str,
  "SELECT n_cosano, n_cofilename, n_filenum, n_fileversion, n_cisano\
       FROM f_%s WHERE n_itemnum = %d ", n_catalogname, part_no);
 .....*/
  sprintf (sql_str,
  "SELECT n_cosano, n_cofilename, n_filenum, n_fileversion, n_cisano\
       FROM f_%s WHERE n_itemnum = %d AND n_fileversion = \
       ( SELECT MAX(n_fileversion) FROM f_%s WHERE n_itemnum = %d )", 
       n_catalogname, part_no, n_catalogname, part_no);

    _PDMdebug ("sql_qry", "\n%s\n",sql_str);

       status = SQLquery (sql_str, &list1, MEM_SIZE);
         if ( status != SQL_S_SUCCESS ) {
              MEMclose (&list);
              _PDMdebug  (fn, "SQLquery Failed %d\n", status) ;
    status = _PDMget_db_error (status);
              return (status);
             }
             status = MEMbuild_array(list1);
             if(status != MEM_S_SUCCESS) {
		sprintf(s,"MEMbuild_array failed status %d\n",status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
             }
  if (PDMdebug_on) {
    MEMprint_buffer("list1", list1, PDM_DEBUG_FILE);
    }
           list_data = (char **) list1->data_ptr;


/* for each entry in the buffer, update n_co = Y and n_ref = 0 */

        for (i=0; i<list1->rows; i++) {
           index = i * list1->columns;
           sql_str[0] = '\0';
           sprintf(sql_str,
           "INSERT INTO NFMSAFILES (n_sano,n_filename,n_catalogno, \
           n_itemno,n_filenum, n_fileversion,n_ref,n_co, n_copy, n_cisano) \
           VALUES(%s,'%s',%d,%d,%s,%s,%d,'%s', '%s', %s)", 
         list_data [index + 0], list_data [index + 1], cat_no, part_no,
         list_data [index + 2], list_data [index + 3], 0,
         "Y", "N", list_data [index + 4]);
    
             status = SQLstmt (sql_str);
              if (status != SQL_S_SUCCESS) {
         if (status == SQL_E_MESSAGE)  {
           _PDMdebug ("Retrying", "%s\n",  sql_str);
           status = _PDMRetrySqlStmt (sql_str);
           if (status != PDM_S_SUCCESS) {
              _PDMdebug (fn, "SQLstmt Failed 0x%.8x\n", status);
              return(PDM_E_SQL_STMT);
              }
            }
            else {
               _PDMdebug (fn, "SQLstmt %d\n", status);
               _PDMdebug (fn, "Update failed for %s %s %s\n",
                 n_catalogname, n_itemname, list_data[index+1]);
    status = _PDMget_db_error (status);
                 return (status);
            }
         }
         tmp_row [0] = '\0';
         sprintf (tmp_row, "%s\1", list_data[index + 1]);
         _PDMdebug ("tmp_row", "%s\n", tmp_row);
         /*status = MEMwrite_data (tmp_bufr, list_data[index+1], i+1, 1);*/
         status = MEMwrite (tmp_bufr, tmp_row);
         if (status != MEM_S_SUCCESS) {
              _PDMdebug (fn, "MEMwrite_data failed %d\n", status );
              return (status);
         }
        }
/*
  PDMdebug("EXIT:PDMco_item_update_filemanager\n");
  return(PDM_S_SUCCESS);
*/
      
      }
    
    if ( status == SQL_S_SUCCESS ){

   /* there are entries in LFM */

   status = MEMbuild_array(list);
   if(status != MEM_S_SUCCESS) {
		sprintf(s,"MEMbuild_array failed status %d\n",status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
   }
  if (PDMdebug_on) {
    MEMprint_buffer("list", list, PDM_DEBUG_FILE);
    }
   columns = (char **) list->column_ptr;
   data = (char **) list->data_ptr;
   n1 = -1; n2 = -1; n3 = -1; n4 = -1; n5 = -1; n6 = -1; 
   n7 = -1; n8 = -1; n9 = -1; n10 = -1; n11 = -1; n12 = -1;
   for(i=0;i<list->columns;i++) {
		if(!strcmp(columns[i],"n_sano")) 		n1 = i;
		if(!strcmp(columns[i],"n_catalogno"))  		n2 = i;
		if(!strcmp(columns[i],"n_itemno"))		n3 = i;
		if(!strcmp(columns[i],"n_filename"))  		n4 = i;
		if(!strcmp(columns[i],"n_filenum"))    		n5 = i;
		if(!strcmp(columns[i],"n_fileversion")) 	n6 = i;
		if(!strcmp(columns[i],"n_co"))   	 	n7 = i;
		if(!strcmp(columns[i],"n_copy"))   	 	n8 = i;
		if(!strcmp(columns[i],"n_ref"))   	 	n9 = i;
		if(!strcmp(columns[i],"n_nfs"))   	 	n10 = i;
		if(!strcmp(columns[i],"n_cisano"))   	 	n11 = i;
		if(!strcmp(columns[i],"n_mountpoint"))   	n12 = i;
   }
   if(n1 == -1 || n2 == -1 || n3 == -1 || n4 == -1 || n5 == -1 || n6 == -1 || 
      n7 == -1 || n8 == -1 || n9 == -1 || n10 == -1 || n11 == -1 || n12 == -1) {
		PDMdebug("Could not find cols in <list>\n");
		return(PDM_E_BUFFER_FORMAT);
   }

/* for each entry in the buffer, update n_co = Y and n_ref = n_ref + 1 */


for(i=0;i<list->rows;i++) {
   nxi = i * list->columns;
           sql_str[0] = '\0';
   sprintf(sql_str,
"UPDATE NFMSAFILES SET n_ref = %d, n_co = '%s'  WHERE n_sano = %s AND n_catalogno = %s AND n_itemno = %s AND n_filenum = %s AND n_fileversion = %s AND n_filename = '%s'", 
atol (data[nxi+n9]), "Y", data[nxi+n1],  
    data[nxi+n2], data[nxi+n3], 
    data[nxi+n5], data[nxi+n6], 
    data[nxi+n4]);

    _PDMdebug ("sql_stmt", "\n%s\n", sql_str);
    
      status = SQLstmt (sql_str);
       if (status != SQL_S_SUCCESS) {
         if (status == SQL_E_MESSAGE)  {
           _PDMdebug ("Retrying", "%s\n",  sql_str);
           status = _PDMRetrySqlStmt (sql_str);
           if (status != PDM_S_SUCCESS) {
              _PDMdebug (fn, "SQLstmt Failed 0x%.8x\n", status);
              return(PDM_E_SQL_STMT);
              }
            }
            else {
        _PDMdebug (fn, "SQLstmt %d\n", status);
        _PDMdebug (fn, "Update failed for %s %s %s\n",
          data[nxi+n2], data[nxi+n3], data[nxi+n4]);
    status = _PDMget_db_error (status);
          return (status);
           }
         }
    tmp_row [0] = '\0';
    sprintf (tmp_row, "%s\1", data[nxi + n4]);
    _PDMdebug ("tmp_row", "%s\n", tmp_row);
    /*status = MEMwrite_data (tmp_bufr, list_data[index+1], i+1, 1);*/
    status = MEMwrite (tmp_bufr, tmp_row);
    if (status != MEM_S_SUCCESS) {
         _PDMdebug (fn, "MEMwrite_data failed %d\n", status );
         return (status);
         }
     }
   }


  if (PDMdebug_on) {
    MEMprint_buffer("file_bufr", tmp_bufr, PDM_DEBUG_FILE);
    }

  *file_bufr = tmp_bufr;

  PDMdebug("EXIT:PDMco_item_update_filemanager\n");
  return(PDM_S_SUCCESS);
}


int  PDMcancel_co_update_filemanager (cat_no, part_no, catalog, part, rev,
                                      sano,
                                      head, end, nchildren, delete_list,
					                  attach_bufr) 
int cat_no, part_no, nchildren, sano;
char *catalog, *part, *rev;
struct NFMset_member    *head;
struct NFMset_member    *end;
MEMptr *delete_list;
MEMptr                 attach_bufr;
{
	char		*fn = "PDMcancel_co_update_filemanager";
	char		sql_str[5120]; /* may need to be reduced -MaC*/
	char	 	del_str[130];
	char		**data;
	MEMptr          out_bufr;
	void		_PDMprint_setmember ();
	char	        **columns;
	int		nxi, i;
	int		n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12;
        int     	new_ref_count;
        int     	ref_count;

/*	struct NFMset_member    *cur_mem = (struct NFMset_member *) NULL;*/

   _PDMdebug ("ENTER", "%s\n", fn);
   _PDMdebug (fn, 
   "catalog[%s] part[%s] rev[%s]\ncat_no[%d], part_no[%d], nchildren [%d]\n",
      catalog, part, rev, cat_no, part_no, nchildren);

/* allocing delete_list 
    Not anymore. delete_list will be created while 
    rolling back part changes... MaC 031793 ...

 status = MEMopen (&tmp_del_list, 512);
      if (status != MEM_S_SUCCESS) {
         _PDMdebug (fn, "MEM Open : failed status : %lx\n", status);
         return (NFM_E_MEM);
       }
   status = MEMwrite_format (tmp_del_list, "n_cofilename", "char(128)");
         if (status != MEM_S_SUCCESS) {
            MEMclose (delete_list);
            _PDMdebug (fn, "MEM Wr For : failed status %lx\n", status);
            return (NFM_E_MEM);
          }
 */

   status = MEMbuild_array(*delete_list);
   if(status != MEM_S_SUCCESS) {
		_PDMdebug (fn, "MEMbuild_array failed status %d\n",status);
		return(PDM_E_BUILD_ARRAY);
   }

/* get the fmgr entries for the children..*/
   if (nchildren == -1) nchildren = 1;

/* 10/23/95 - MJG - TR 139424087 DM Manager */
/*
   if ( ( !strcmp (PDMpart.n_setindicator, "Y") ) ||
           (!strcmp (PDMpart.n_setindicator, "y") ) )
*/
   if ( ( !strcmp (PDMpart.n_setindicator, "Y") ) ||
           (!strcmp (PDMpart.n_setindicator, "y") ) ||
           (!strcmp (PDMpart.n_setindicator, "A") ) ||
           (!strcmp (PDMpart.n_setindicator, "a") ) ) {
   _PDMdebug (fn, "head->item_no[%d] and head->item_name[%s]\n",
                                        head->item_no, head->item_name);
       }

/* also pass attach_bufr to this function to get the local files..*/

/*
   status = PDMget_children_fmgr_entries (cat_no, part_no, catalog, part, rev,
                                      head, end, nchildren, &out_bufr);
*/
   status = PDMget_children_fmgr_entries_for_cancelco (cat_no, part_no, 
                                                       catalog, part, rev,
                                                       sano,
                                                       head, end, 
                                                       nchildren, attach_bufr,
                                                       &out_bufr);
   if(status != PDM_S_SUCCESS) {
	_PDMdebug (fn,"PDMget_children_fmgr_entries failed status %d\n",status);
	return(status);
   }

  if (PDMdebug_on) {
    MEMprint_buffer("out_bufr", out_bufr, PDM_DEBUG_FILE);
    }

   status = MEMbuild_array(out_bufr);
   if(status != MEM_S_SUCCESS) {
		_PDMdebug (fn, "MEMbuild_array failed status %d\n",status);
		return(PDM_E_BUILD_ARRAY);
   }
   columns = (char **) out_bufr->column_ptr;
   data = (char **) out_bufr->data_ptr;
   n1 = -1; n2 = -1; n3 = -1; 
   n4 = -1; n5 = -1; n6 = -1; 
   n7 = -1; n8 = -1; n9 = -1;
   n10 = -1; n11 = -1; n12 = -1;
   for(i=0;i<out_bufr->columns;i++) {
		if(!strcmp(columns[i],"n_sano")) 		n1 = i;
		if(!strcmp(columns[i],"n_catalogno"))  		n2 = i;
		if(!strcmp(columns[i],"n_itemno"))		n3 = i;
		if(!strcmp(columns[i],"n_filename"))  		n4 = i;
		if(!strcmp(columns[i],"n_filenum"))    		n5 = i;
		if(!strcmp(columns[i],"n_fileversion")) 	n6 = i;
		if(!strcmp(columns[i],"n_co"))   	 	n7 = i;
		if(!strcmp(columns[i],"n_copy"))   	 	n8 = i;
		if(!strcmp(columns[i],"n_ref"))   	 	n9 = i;
		if(!strcmp(columns[i],"n_nfs"))   	 	n10 = i;
		if(!strcmp(columns[i],"n_cisano"))   	 	n11 = i;
		if(!strcmp(columns[i],"n_mountpoint"))   	n12 = i;
   }
   if(n1 == -1 || n2 == -1 || n3 == -1 || 
      n4 == -1 || n5 == -1 || n6 == -1 || 
      n7 == -1 || n8 == -1 || n9 == -1 ||
      n10 == -1 || n11 == -1 || n12 == -1) {
		PDMdebug("Could not find cols in <out_bufr>\n");
		return(PDM_E_BUFFER_FORMAT);
   }

/* for each child entry in the buffer, 

       n_co	n_copy	n_ref	action taken
	y	XX	>1	n_ref -= 1
	n	y	>1	n_ref -= 1
	y	XX	0	delete the row
	n	y	0 	delete the row
	n	n	=1	delete the row
	
*/

for(i=0;i<out_bufr->rows;i++) {
   nxi = i * out_bufr->columns;
   ref_count = atol (data [nxi+n9]);
   new_ref_count = ref_count - 1;
   del_str[0]= '\0';
    if ( (atol (data [nxi + n2]) == cat_no ) && 
         (atol (data [nxi + n3]) == part_no )) {
    /* parent row or atomic part row...*/

_PDMdebug ("*** It is the parent or atomic","n_co[%s], n_copy[%s] n_ref[%d]\n", 
                 data[nxi + n7], data[nxi + n8], ref_count);
      if ( (!strcmp (data[nxi + n8], "Y")) || ( ref_count > 0) )  {
_PDMdebug (fn, "bufr.cat_no[%s], part_no[%s]\n", 
                 data[nxi + n2], data[nxi + n3]);
sprintf(sql_str,
"UPDATE NFMSAFILES SET n_ref = %d, n_co = '%s'  WHERE n_sano = %s AND n_catalogno = %s AND n_itemno = %s AND n_filenum = %s AND n_fileversion = %s AND n_filename = '%s'", 
ref_count, "N", data[nxi+n1],  
    data[nxi+n2], data[nxi+n3], 
    data[nxi+n5], data[nxi+n6], 
    data[nxi+n4]);
} else { 
sprintf(sql_str,
"DELETE FROM  NFMSAFILES  WHERE n_sano = %d \
AND n_catalogno = %s AND n_itemno = %s AND n_filenum = %s \
AND n_fileversion = %s AND n_filename = '%s'", 
atol (data[nxi + n1]), data[nxi+n2], data[nxi+n3], data[nxi+n5],
data[nxi+n6],data[nxi+n4]);
/* added support to include the parent/atomic part file also in 
   the delete list... MaC042793 */
_PDMdebug (fn, "adding %s to delete_list\n", data[nxi + n4]);
      sprintf(del_str,"%s\1", data[nxi + n4]);
      _PDMdebug("del_str", "%s\n", del_str);
      status = MEMwrite((*delete_list), del_str);
         if (status != MEM_S_SUCCESS) {
           _PDMdebug (fn, "MEM error  %lx\n", status);
           return (NFM_E_MEM);
                   }
  }
}
else {
/* it is children row...*/
_PDMdebug (fn, "It is a child part \n n_co[%s], n_copy[%s] n_ref[%d]\n", 
                 data[nxi + n7], data[nxi + n8], ref_count);
_PDMdebug (fn, "bufr.cat_no[%s], part_no[%s]\n", 
                 data[nxi + n2], data[nxi + n3]);
     if ( ( !strcmp (data [nxi + n7], "Y" )) ||
          (( !strcmp (data [nxi + n7], "N" )) && 
            ( !strcmp (data [nxi + n8], "Y" )) ) ||
          (( !strcmp (data [nxi + n7], "N" )) && 
            ( !strcmp (data [nxi + n8], "N" )) &&
                 (ref_count > 1) ) )
{
sprintf(sql_str,
"UPDATE NFMSAFILES SET n_ref = %d, n_co = '%s'  WHERE n_sano = %s AND n_catalogno = %s AND n_itemno = %s AND n_filenum = %s AND n_fileversion = %s AND n_filename = '%s'", 
new_ref_count, data[nxi+n7], data[nxi+n1],  
    data[nxi+n2], data[nxi+n3], 
    data[nxi+n5], data[nxi+n6], 
    data[nxi+n4]);
}
else {
/*if ( (( !strcmp (data [nxi + n7], "Y" )) && ref_count <= 1 ) ||
(( !strcmp (data [nxi + n8], "Y" )) && ref_count <= 1 ) ||
(( !strcmp (data [nxi + n7], "N" )) && ( !strcmp (data [nxi + n8], "N" )) && ref_count <= 1 ))
*/
sprintf(sql_str,
"DELETE FROM  NFMSAFILES  WHERE n_sano = %d \
AND n_catalogno = %s AND n_itemno = %s AND n_filenum = %s \
AND n_fileversion = %s AND n_filename = '%s'", 
atol (data[nxi + n1]), data[nxi+n2], data[nxi+n3], data[nxi+n5],
data[nxi+n6],data[nxi+n4]);
/* adding support for delete_list*/
_PDMdebug (fn, "adding %s to delete_list\n", data[nxi + n4]);
      sprintf(del_str,"%s\1", data[nxi + n4]);
      _PDMdebug("del_str", "%s\n", del_str);
      status = MEMwrite((*delete_list), del_str);
         if (status != MEM_S_SUCCESS) {
           _PDMdebug (fn, "MEM error  %lx\n", status);
           return (NFM_E_MEM);
                   }

}

     }
    _PDMdebug ("sql_stmt", "\n%s\n", sql_str);
    
      status = SQLstmt (sql_str);
       if (status != SQL_S_SUCCESS) {
         if (status == SQL_E_MESSAGE)  {
           _PDMdebug ("Retrying", "%s\n",  sql_str);
           status = _PDMRetrySqlStmt (sql_str);
           if (status != PDM_S_SUCCESS) {
              _PDMdebug (fn, "SQLstmt Failed 0x%.8x\n", status);
              return(PDM_E_SQL_STMT);
              }
            }
            else {
        _PDMdebug (fn, "SQLstmt %d\n", status);
        _PDMdebug (fn, "Update failed for %s %s %s\n",
          data[nxi+n2], data[nxi+n3], data[nxi+n4]);
    status = _PDMget_db_error (status);
          return (status);
            }
         }
 }
  if (PDMdebug_on) {
    MEMprint_buffer("delete_list in PDMcancel_co_update_fmgr", 
					(*delete_list), PDM_DEBUG_FILE);
    }
  PDMdebug("EXIT:PDMcancel_co_update_fmgr\n");
  return(PDM_S_SUCCESS);
}




int  PDMCoUpdateFilemgrForPart (n_catalogname,n_itemname,n_itemrev,
                                     cat_no, part_no, sano, file_bufr)
char    *n_catalogname;
char    *n_itemname;
char    *n_itemrev;
int     cat_no, part_no, sano;
MEMptr	*file_bufr;
{
        char		*fn = "PDMCoUpdateFilemgrForPart";
	char	        **columns, **data, **list_data;
	int		n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12;
	int		index, i, j, nxi;
        char    	sql_str[300];
        int     	nxj, updated;
        MEMptr		list = NULL, list1 = NULL;
        MEMptr		tmp_bufr = NULL;
        char		tmp_row[300];


  PDMdebug("ENTER:PDMCoUpdateFilemgrForPart\n");

   _PDMdebug (fn, "catalog[%s] part[%s] rev[%s] cat_no[%d] part_no[%d]\n", 
                       n_catalogname, n_itemname, n_itemrev, cat_no, part_no);

/* added support for creating a buffer which contains all the filenames
   for this part. This is for PDU to update the object space -MaC 042192*/

      status = MEMopen (&tmp_bufr, 512);
       if (status != MEM_S_SUCCESS) {
      _PDMdebug (fn, "MEMopen failed: status %d\n", status);
       return (status);
      }

      status = MEMwrite_format (tmp_bufr, "n_cofilename", "char(30)");
         if (status != MEM_S_SUCCESS) {
         _PDMdebug (fn, "MEMwrite_format failed: status %d\n", status);
          return (status);
      }


       status = MEMbuild_array(tmp_bufr);
       if(status != MEM_S_SUCCESS) {
	sprintf(s,"MEMbuild_array failed status %d\n",status);
	PDMdebug(s);
	return(PDM_E_BUILD_ARRAY);
       }


  sprintf (sql_str,
  "SELECT n_cosano, n_cofilename, n_filenum, n_fileversion, n_cisano\
       FROM f_%s WHERE n_itemnum = %d AND n_fileversion = \
       ( SELECT MAX(n_fileversion) FROM f_%s WHERE n_itemnum = %d )", 
       n_catalogname, part_no, n_catalogname, part_no);

    _PDMdebug ("sql_qry", "\n%s\n",sql_str);

       status = SQLquery (sql_str, &list1, MEM_SIZE);
         if ( status != SQL_S_SUCCESS ) {
              MEMclose (&list);
              _PDMdebug  (fn, "SQLquery Failed %d\n", status) ;
    status = _PDMget_db_error (status);
              return (status);
             }
             status = MEMbuild_array(list1);
             if(status != MEM_S_SUCCESS) {
		sprintf(s,"MEMbuild_array failed status %d\n",status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
             }
  if (PDMdebug_on) {
    MEMprint_buffer("list1", list1, PDM_DEBUG_FILE);
    }
           list_data = (char **) list1->data_ptr;


/* 031892: added sano support: if the item/part has been copied to some
           other sano, we are not interested... -MaC */

  sql_str[0] = '\0';
  sprintf (sql_str,
  "SELECT n_sano, n_catalogno, n_itemno, n_filename, n_filenum, n_fileversion,\
    n_co, n_copy, n_ref, n_nfs, n_cisano, n_mountpoint FROM NFMSAFILES WHERE\
    n_sano = %d AND ( n_itemno = %d AND n_catalogno = %d ) ", sano, part_no, cat_no);

    _PDMdebug ("sql_qry", "\n%s\n",sql_str);

  status = SQLquery (sql_str, &list, MEM_SIZE);
  if ( status != SQL_S_SUCCESS &&
           status != SQL_I_NO_ROWS_FOUND) {
    MEMclose (&list);
    _PDMdebug  (fn, "SQLquery Failed %d\n", status) ;
    status = _PDMget_db_error (status);
    return (status);
   }

 /* if no_rows_found; all things being equal, all the files have to
    be moved */

    if ( status == SQL_I_NO_ROWS_FOUND ) {
   _PDMdebug (fn, "There are NO entries in LFM\n");

/* Already done...
  sprintf (sql_str,
  "SELECT n_cosano, n_cofilename, n_filenum, n_fileversion, n_cisano\
       FROM f_%s WHERE n_itemnum = %d AND n_fileversion = \
       ( SELECT MAX(n_fileversion) FROM f_%s WHERE n_itemnum = %d )", 
       n_catalogname, part_no, n_catalogname, part_no);

    _PDMdebug ("sql_qry", "\n%s\n",sql_str);

       status = SQLquery (sql_str, &list1, MEM_SIZE);
         if ( status != SQL_S_SUCCESS ) {
              MEMclose (&list);
              _PDMdebug  (fn, "SQLquery Failed %d\n", status) ;
    status = _PDMget_db_error (status);
              return (status);
             }
             status = MEMbuild_array(list1);
             if(status != MEM_S_SUCCESS) {
		sprintf(s,"MEMbuild_array failed status %d\n",status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
             }
  if (PDMdebug_on) {
    MEMprint_buffer("list1", list1, PDM_DEBUG_FILE);
    }

*/
           list_data = (char **) list1->data_ptr;

/* for each entry in the buffer, update n_co = Y and n_ref = 0 */

        for (i=0; i<list1->rows; i++) {
           index = i * list1->columns;
           sql_str[0] = '\0';
           sprintf(sql_str,
           "INSERT INTO NFMSAFILES (n_sano,n_filename,n_catalogno, \
           n_itemno,n_filenum, n_fileversion,n_ref,n_co, n_copy, n_cisano) \
           VALUES(%s,'%s',%d,%d,%s,%s,%d,'%s', '%s', %s)", 
         list_data [index + 0], list_data [index + 1], cat_no, part_no,
         list_data [index + 2], list_data [index + 3], 0,
         "Y", "N", list_data [index + 4]);
    
             status = SQLstmt (sql_str);
              if (status != SQL_S_SUCCESS) {
         if (status == SQL_E_MESSAGE)  {
           _PDMdebug ("Retrying", "%s\n",  sql_str);
           status = _PDMRetrySqlStmt (sql_str);
           if (status != PDM_S_SUCCESS) {
              _PDMdebug (fn, "SQLstmt Failed 0x%.8x\n", status);
              return(PDM_E_SQL_STMT);
              }
            }
            else {

               _PDMdebug (fn, "SQLstmt %d\n", status);
               _PDMdebug (fn, "Update failed for %s %s %s\n",
                 n_catalogname, n_itemname, list_data[index+1]);
    status = _PDMget_db_error (status);
                 return (status);
                 }
         }
         tmp_row [0] = '\0';
         sprintf (tmp_row, "%s\1", list_data[index + 1]);
         _PDMdebug ("tmp_row", "%s\n", tmp_row);
         /*status = MEMwrite_data (tmp_bufr, list_data[index+1], i+1, 1);*/
         status = MEMwrite (tmp_bufr, tmp_row);
         if (status != MEM_S_SUCCESS) {
              _PDMdebug (fn, "MEMwrite_data failed %d\n", status );
              return (status);
         }
        }
/*
  PDMdebug("EXIT:PDMco_item_update_filemanager\n");
  return(PDM_S_SUCCESS);
*/
      
      }
    
    if ( status == SQL_S_SUCCESS ){

   /* there are entries in LFM */

   status = MEMbuild_array(list);
   if(status != MEM_S_SUCCESS) {
		sprintf(s,"MEMbuild_array failed status %d\n",status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
   }
  if (PDMdebug_on) {
    MEMprint_buffer("list", list, PDM_DEBUG_FILE);
    }
   columns = (char **) list->column_ptr;
   data = (char **) list->data_ptr;
   list_data = (char **) list1->data_ptr;
   n1 = -1; n2 = -1; n3 = -1; n4 = -1; n5 = -1; n6 = -1; 
   n7 = -1; n8 = -1; n9 = -1; n10 = -1; n11 = -1; n12 = -1;
   for(i=0;i<list->columns;i++) {
		if(!strcmp(columns[i],"n_sano")) 		n1 = i;
		if(!strcmp(columns[i],"n_catalogno"))  		n2 = i;
		if(!strcmp(columns[i],"n_itemno"))		n3 = i;
		if(!strcmp(columns[i],"n_filename"))  		n4 = i;
		if(!strcmp(columns[i],"n_filenum"))    		n5 = i;
		if(!strcmp(columns[i],"n_fileversion")) 	n6 = i;
		if(!strcmp(columns[i],"n_co"))   	 	n7 = i;
		if(!strcmp(columns[i],"n_copy"))   	 	n8 = i;
		if(!strcmp(columns[i],"n_ref"))   	 	n9 = i;
		if(!strcmp(columns[i],"n_nfs"))   	 	n10 = i;
		if(!strcmp(columns[i],"n_cisano"))   	 	n11 = i;
		if(!strcmp(columns[i],"n_mountpoint"))   	n12 = i;
   }
   if(n1 == -1 || n2 == -1 || n3 == -1 || n4 == -1 || n5 == -1 || n6 == -1 || 
      n7 == -1 || n8 == -1 || n9 == -1 || n10 == -1 || n11 == -1 || n12 == -1) {
		PDMdebug("Could not find cols in <list>\n");
		return(PDM_E_BUFFER_FORMAT);
   }

/* We have 2 buffers here: list , which contains entries in LFM
                           list1, which contains all files for this part.

   The Alg:
     for each entry in list1
          if there exists ||| part in list
                  update the row with n_co as Y
          else
                  insert a row with n_co as Y

                           - MaC 042894  */
/* for each entry in the buffer, update n_co = Y and n_ref = n_ref + 1 */

    for (i = 0; i < list1->rows; i++) {
      nxi = i * list1->columns;
      _PDMdebug (fn, "Checking part file [%s]\n", list_data[nxi+1]);
      updated = 0;
      for (j = 0; j < list->rows; j++) {
        nxj = j * list->columns;
        if (!strcmp  (data[nxj+3], list_data[nxi+1])) {
          updated = 1;
         _PDMdebug (fn, "Found an entry for the part file [%s] in LFM\n",
                              list_data[nxi+1]);
         sql_str[0] = '\0';
          sprintf(sql_str,
"UPDATE NFMSAFILES SET n_ref = %d, n_co = '%s'  WHERE n_sano = %s AND n_catalogno = %s AND n_itemno = %s AND n_filenum = %s AND n_fileversion = %s AND n_filename = '%s'", 
atol (data[nxj+n9]), "Y", data[nxj+n1],  
           data[nxj+n2], data[nxj+n3], 
           data[nxj+n5], data[nxj+n6], 
           data[nxj+n4]);
       
           _PDMdebug ("sql_stmt", "\n%s\n", sql_str);
           
            status = SQLstmt (sql_str);
            if (status != SQL_S_SUCCESS) {
              if (status == SQL_E_MESSAGE)  {
                _PDMdebug ("Retrying", "%s\n",  sql_str);
                status = _PDMRetrySqlStmt (sql_str);
                if (status != PDM_S_SUCCESS) {
                   _PDMdebug (fn, "SQLstmt Failed 0x%.8x\n", status);
                   return(PDM_E_SQL_STMT);
                   }
                 }
                 else {
             _PDMdebug (fn, "SQLstmt %d\n", status);
             _PDMdebug (fn, "Update failed for %s %s %s\n",
               data[nxj+n2], data[nxj+n3], data[nxj+n4]);
         status = _PDMget_db_error (status);
               return (status);
              }
              }
         tmp_row [0] = '\0';
         sprintf (tmp_row, "%s\1", data[nxj + n4]);
         _PDMdebug ("tmp_row", "%s\n", tmp_row);
         status = MEMwrite (tmp_bufr, tmp_row);
         if (status != MEM_S_SUCCESS) {
              _PDMdebug (fn, "MEMwrite_data failed %d\n", status );
              return (status);
              }
          /* No need to check other entries */ 
            break;
            }
       } /*for ends for fmgr_bufr (list) */
      if (updated == 0)  {

        _PDMdebug (fn, "No entry found for file [%s]\n", list_data[nxi+1]);
        sql_str[0] = '\0';
        sprintf(sql_str,
           "INSERT INTO NFMSAFILES (n_sano,n_filename,n_catalogno, \
           n_itemno,n_filenum, n_fileversion,n_ref,n_co, n_copy, n_cisano) \
           VALUES(%s,'%s',%d,%d,%s,%s,%d,'%s', '%s', %s)", 
        list_data [nxi + 0], list_data [nxi + 1], cat_no, part_no,
        list_data [nxi + 2], list_data [nxi + 3], 0,
        "Y", "N", list_data [nxi + 4]);
    
        status = SQLstmt (sql_str);
        if (status != SQL_S_SUCCESS) {
         if (status == SQL_E_MESSAGE)  {
           _PDMdebug ("Retrying", "%s\n",  sql_str);
           status = _PDMRetrySqlStmt (sql_str);
           if (status != PDM_S_SUCCESS) {
              _PDMdebug (fn, "SQLstmt Failed 0x%.8x\n", status);
              return(PDM_E_SQL_STMT);
              }
            }
          else {

               _PDMdebug (fn, "SQLstmt %d\n", status);
               _PDMdebug (fn, "Update failed for %s %s %s\n",
                 n_catalogname, n_itemname, list_data[nxi+1]);
                 status = _PDMget_db_error (status);
                 return (status);
                 }
         }
         tmp_row [0] = '\0';
         sprintf (tmp_row, "%s\1", list_data[nxi + 1]);
         _PDMdebug ("tmp_row", "%s\n", tmp_row);
         /*status = MEMwrite_data (tmp_bufr, list_data[nxi+1], i+1, 1);*/
         status = MEMwrite (tmp_bufr, tmp_row);
         if (status != MEM_S_SUCCESS) {
              _PDMdebug (fn, "MEMwrite_data failed %d\n", status );
              return (status);
         }
      }
     } /*for ends for file_bufr (list1) */
     
     
/*
for(i=0;i<list->rows;i++) {
   nxi = i * list->columns;
           sql_str[0] = '\0';
   sprintf(sql_str,
"UPDATE NFMSAFILES SET n_ref = %d, n_co = '%s'  WHERE n_sano = %s AND n_catalogno = %s AND n_itemno = %s AND n_filenum = %s AND n_fileversion = %s AND n_filename = '%s'", 
atol (data[nxi+n9]), "Y", data[nxi+n1],  
    data[nxi+n2], data[nxi+n3], 
    data[nxi+n5], data[nxi+n6], 
    data[nxi+n4]);

    _PDMdebug ("sql_stmt", "\n%s\n", sql_str);
    
      status = SQLstmt (sql_str);
       if (status != SQL_S_SUCCESS) {
         if (status == SQL_E_MESSAGE)  {
           _PDMdebug ("Retrying", "%s\n",  sql_str);
           status = _PDMRetrySqlStmt (sql_str);
           if (status != PDM_S_SUCCESS) {
              _PDMdebug (fn, "SQLstmt Failed 0x%.8x\n", status);
              return(PDM_E_SQL_STMT);
              }
            }
            else {
        _PDMdebug (fn, "SQLstmt %d\n", status);
        _PDMdebug (fn, "Update failed for %s %s %s\n",
          data[nxi+n2], data[nxi+n3], data[nxi+n4]);
    status = _PDMget_db_error (status);
          return (status);
              }
         }
    tmp_row [0] = '\0';
    sprintf (tmp_row, "%s\1", data[nxi + n4]);
    _PDMdebug ("tmp_row", "%s\n", tmp_row);
    status = MEMwrite (tmp_bufr, tmp_row);
    if (status != MEM_S_SUCCESS) {
         _PDMdebug (fn, "MEMwrite_data failed %d\n", status );
         return (status);
         }
     }
*/
   MEMclose (&list);
   }

   if (list1) MEMclose (&list1);

  if (PDMdebug_on) {
    MEMprint_buffer("file_bufr", tmp_bufr, PDM_DEBUG_FILE);
    }

  *file_bufr = tmp_bufr;

  PDMdebug("EXIT:PDMCoUpdateFilemgrForPart\n");
  return(PDM_S_SUCCESS);
}




int  PDMCancelCoUpdateFilemgrForPart (n_catalogname,n_itemname,n_itemrev,
                                        cat_no, part_no, sano, file_bufr)
char    *n_catalogname;
char    *n_itemname;
char    *n_itemrev;
int     cat_no, part_no, sano;
MEMptr	*file_bufr;
{
        char		*fn = "PDMCoUpdateFilemgrForPart";
	char	        **data;
	int		i, nxi;
        char    	sql_str[300];
        MEMptr		list = NULL;
        MEMptr		tmp_bufr = NULL;
        char		tmp_row[300];


  PDMdebug("ENTER:PDMCancelCoUpdateFilemgrForPart\n");

   _PDMdebug (fn, "catalog[%s] part[%s] rev[%s] cat_no[%d] part_no[%d]\n", 
                       n_catalogname, n_itemname, n_itemrev, cat_no, part_no);

/* added support for creating a buffer which contains all the filenames
   for this part. This is for PDU to update the object space -MaC 042192*/

/* We assume that this is already created
      status = MEMopen (&tmp_bufr, 512);
       if (status != MEM_S_SUCCESS) {
      _PDMdebug (fn, "MEMopen failed: status %d\n", status);
       return (status);
      }

      status = MEMwrite_format (tmp_bufr, "n_cofilename", "char(30)");
         if (status != MEM_S_SUCCESS) {
         _PDMdebug (fn, "MEMwrite_format failed: status %d\n", status);
          return (status);
      }


       status = MEMbuild_array(tmp_bufr);
       if(status != MEM_S_SUCCESS) {
	sprintf(s,"MEMbuild_array failed status %d\n",status);
	PDMdebug(s);
	return(PDM_E_BUILD_ARRAY);
       }
*/

       status = MEMbuild_array(*file_bufr);
       if(status != MEM_S_SUCCESS) {
	_PDMdebug (fn, "MEMbuild_array failed status 0x%.8x\n", status);
	return(status);
       }


/* 031892: added sano support: if the item/part has been copied to some
           other sano, we are not interested... -MaC */

  sql_str[0] = '\0';
  sprintf (sql_str,
  "SELECT n_sano, n_catalogno, n_itemno, n_filename, n_filenum, n_fileversion,\
    n_co, n_copy, n_ref, n_nfs, n_cisano, n_mountpoint FROM NFMSAFILES WHERE\
    n_sano = %d AND ( n_itemno = %d AND n_catalogno = %d ) ", sano, part_no, cat_no);

    _PDMdebug ("sql_qry", "\n%s\n",sql_str);

  status = SQLquery (sql_str, &list, MEM_SIZE);
  if ( status != SQL_S_SUCCESS ) {
    MEMclose (&list);
    _PDMdebug  (fn, "SQLquery Failed %d\n", status) ;
    status = _PDMget_db_error (status);
    return (status);
   }

   status = MEMbuild_array(list);
   if(status != MEM_S_SUCCESS) {
	_PDMdebug (fn, "MEMbuild_array failed status %d\n",status);
	return(PDM_E_BUILD_ARRAY);
   }

  if (PDMdebug_on) {
    MEMprint_buffer("list", list, PDM_DEBUG_FILE);
    }

   data = (char **) list->data_ptr;

/* for each entry in the buffer, update n_co = Y and n_ref = n_ref + 1 */


  for (i = 0; i < list->rows ; i++)   {
   nxi = i * list->columns;
           sql_str[0] = '\0';

  /* if n_ref > 0 or n_copy = Y then update the record ... MaC112993*/

    /*if ((atol (data[nxi + 8]) > 0) && (!strcmp (data[nxi + 7], "Y")) ) */

    if ((atol (data[nxi + 8]) > 0) || (!strcmp (data[nxi + 7], "Y")) ) {
     sprintf(sql_str,
"UPDATE NFMSAFILES SET  n_co = 'N'  WHERE n_sano = %s AND n_catalogno = %s AND n_itemno = %s AND n_filenum = %s AND n_fileversion = %s AND n_filename = '%s'", 
  data[nxi+0],  data[nxi+1], data[nxi+2], data[nxi+4], data[nxi+5], 
    data[nxi+3]);

    _PDMdebug ("sql_stmt", "\n%s\n", sql_str);
    
    status = SQLstmt (sql_str);
    if (status != SQL_S_SUCCESS) {
         if (status == SQL_E_MESSAGE)  {
           _PDMdebug ("Retrying", "%s\n",  sql_str);
           status = _PDMRetrySqlStmt (sql_str);
           if (status != PDM_S_SUCCESS) {
              _PDMdebug (fn, "SQLstmt Failed 0x%.8x\n", status);
              return(PDM_E_SQL_STMT);
              }
            }
            else {

        _PDMdebug (fn, "SQLstmt %d\n", status);
        _PDMdebug (fn, "Update failed for %s %s %s\n",
          data[nxi+1], data[nxi+2], data[nxi+3]);
          status = _PDMget_db_error (status);
          return (status);
              }
         }
      }
     else {
      sprintf (sql_str, 
          "DELETE FROM  NFMSAFILES  WHERE n_sano = %s \
          AND n_catalogno = %s AND n_itemno = %s AND n_filenum = %s \
          AND n_fileversion = %s AND n_filename = '%s'", 
          data[nxi+0],  data[nxi+1], data[nxi+2], data[nxi+4], 
          data[nxi+5], data[nxi+3]);

      _PDMdebug ("sql_stmt", "\n%s\n", sql_str);
    
      status = SQLstmt (sql_str);
      if (status != SQL_S_SUCCESS) {
         if (status == SQL_E_MESSAGE)  {
           _PDMdebug ("Retrying", "%s\n",  sql_str);
           status = _PDMRetrySqlStmt (sql_str);
           if (status != PDM_S_SUCCESS) {
              _PDMdebug (fn, "SQLstmt Failed 0x%.8x\n", status);
              return(PDM_E_SQL_STMT);
              }
            }
            else {

        _PDMdebug (fn, "SQLstmt %d\n", status);
        _PDMdebug (fn, "Update failed for %s %s %s\n",
          data[nxi+1], data[nxi+2], data[nxi+3]);
          status = _PDMget_db_error (status);
          return (status);
            }
         }
      

      tmp_row [0] = '\0';
      sprintf (tmp_row, "%s\1", data[nxi + 3]);
      _PDMdebug ("tmp_row", "%s\n", tmp_row);
      /*status = MEMwrite_data (*file_bufr, list_data[index+1], i+1, 1);*/
      status = MEMwrite (*file_bufr, tmp_row);
      if (status != MEM_S_SUCCESS) {
           _PDMdebug (fn, "MEMwrite_data failed %d\n", status );
           return (status);
           }
      }
   }
   


  if (PDMdebug_on) {
    MEMprint_buffer("file_bufr", *file_bufr, PDM_DEBUG_FILE);
    }

  PDMdebug("EXIT:PDMco_item_update_filemanager\n");
  return(PDM_S_SUCCESS);
}




int  PDMCancelCoUpdateFilemgrForAssy (n_catalogname,n_itemname,n_itemrev,
                                        cat_no, part_no, sano, attach_list, 
                                        file_bufr)
char    *n_catalogname;
char    *n_itemname;
char    *n_itemrev;
int     cat_no, part_no, sano;
MEMptr	attach_list;
MEMptr	*file_bufr;
{
        char		*fn = "PDMCancelCoUpdateFilemgrForAssy ";
	char	        **data;
	char	        **columns;
	int		i, nxi, x, or;
        char    	*sql_str;
        char    	*where_clause;
        MEMptr		list = NULL;
        char		tmp_row[300];
        int             n2 = -1, n3 = -1, n4 = -1;


  PDMdebug("ENTER:PDMCancelCoUpdateFilemgrForAssy\n");

   _PDMdebug (fn, "catalog[%s] part[%s] rev[%s] cat_no[%d] part_no[%d]\n", 
                       n_catalogname, n_itemname, n_itemrev, cat_no, part_no);

   status = MEMbuild_array (*file_bufr);
   if(status != MEM_S_SUCCESS) {
      _PDMdebug (fn, "MEMbuild_array failed status %d\n",status);
      return(PDM_E_BUILD_ARRAY);
   }

/* added support for creating a buffer which contains all the filenames
   for this part. This is for PDU to update the object space -MaC 042192*/


   status = MEMbuild_array(attach_list);
   if(status != MEM_S_SUCCESS) {
                sprintf(s,"MEMbuild_array failed status %d\n",status);
                PDMdebug(s);
                return(PDM_E_BUILD_ARRAY);
   }

  if (PDMdebug_on) {
    MEMprint_buffer("attach_list", attach_list, PDM_DEBUG_FILE);
    }

   columns = (char **) attach_list->column_ptr;
   data = (char **) attach_list->data_ptr;
   n2 = -1; n3 = -1; n4 = -1;
/*
   n1 = -1; n2 = -1; n3 = -1; n4 = -1; n5 = -1; n6 = -1;
   n7 = -1; n8 = -1; n9 = -1; n10 = -1; n11 = -1; n12 = -1;
*/
   for(i=0;i<attach_list->columns;i++) {
                if(!strcmp(columns[i],"n_catalogno"))           n2 = i;
                if(!strcmp(columns[i],"n_itemno"))              n3 = i;
                if(!strcmp(columns[i],"n_cofilename"))            n4 = i;
   }
/*
   if(n1 == -1 || n2 == -1 || n3 == -1 || n4 == -1 || n5 == -1 || n6 == -1 ||
      n7 == -1 || n8 == -1 || n9 == -1 || n10 == -1 || n11 == -1 || n12 == -1) 
*/
   if (n2 == -1 || n3 == -1 || n4 == -1 ) {
     PDMdebug("Could not find cols in <attach_list>\n");
     return(PDM_E_BUFFER_FORMAT);
     }

    where_clause = (char *) malloc ((attach_list->row_size * 100) + 512);
    if (! where_clause) {
       _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n", NFM_E_MALLOC);
       return (NFM_E_MALLOC);
       }
    where_clause[0] = '\0';


    sql_str = (char *) malloc ((attach_list->row_size * 100) + 512);
    if (! sql_str) {
       _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n", NFM_E_MALLOC);
       return (NFM_E_MALLOC);
       }
    sql_str[0] = '\0';


  or = 0;
  for (x = 0; x < attach_list->rows; x++) {
    nxi = attach_list->columns * x;
    if (or) {
      strcat (where_clause, "OR ((n_catalogno = ");
      strcat (where_clause, data[nxi + n2]);
      strcat (where_clause, ") AND (n_itemno = ");
      strcat (where_clause, data[nxi + n3]);
      strcat (where_clause, ") AND (n_filename = '");
      strcat (where_clause, data[nxi + n4]);
      strcat (where_clause, "'))");
    }
    else
    {
      strcat (where_clause, "((n_catalogno = ");
      strcat (where_clause, data[nxi + n2]);
      strcat (where_clause, ") AND (n_itemno = ");
      strcat (where_clause, data[nxi + n3]);
      strcat (where_clause, ") AND (n_filename = '");
      strcat (where_clause, data[nxi + n4]);
      strcat (where_clause, "'))");
      or = 1;
    }
  }

  
/* 031892: added sano support: if the item/part has been copied to some
           other sano, we are not interested... -MaC */

  sql_str[0] = '\0';
  sprintf (sql_str,
  "SELECT n_sano, n_catalogno, n_itemno, n_filename, n_filenum, n_fileversion,\
    n_co, n_copy, n_ref, n_nfs, n_cisano, n_mountpoint FROM NFMSAFILES WHERE\
    n_sano = %d AND ( %s ) ", sano, where_clause);

    _PDMdebug ("sql_qry", "\n%s\n",sql_str);

  free (where_clause);

  status = SQLquery (sql_str, &list, MEM_SIZE);
  if ( status != SQL_S_SUCCESS ) {
    MEMclose (&list);
    free (sql_str);
    _PDMdebug  (fn, "SQLquery Failed %d\n", status) ;
    status = _PDMget_db_error (status);
    return (status);
   }

   status = MEMbuild_array(list);
   if(status != MEM_S_SUCCESS) {
    free (sql_str);
	_PDMdebug (fn, "MEMbuild_array failed status %d\n",status);
	return(PDM_E_BUILD_ARRAY);
   }

  if (PDMdebug_on) {
    MEMprint_buffer("list", list, PDM_DEBUG_FILE);
    }

   data = (char **) list->data_ptr;

/* for each entry in the buffer, update n_co = Y and n_ref = n_ref + 1 */


  for (i = 0; i < list->rows ; i++)   {
   nxi = i * list->columns;
           sql_str[0] = '\0';

    if (atol (data[nxi + 8]) > 1) {
     sprintf(sql_str,
"UPDATE NFMSAFILES SET  n_ref = %d  WHERE n_sano = %s AND n_catalogno = %s AND n_itemno = %s AND n_filenum = %s AND n_fileversion = %s AND n_filename = '%s'", 
  (atol (data[nxi+8]) -1), data[nxi+0],  data[nxi+1], data[nxi+2], 
   data[nxi+4], data[nxi+5], data[nxi+3]);

    _PDMdebug ("sql_stmt", "\n%s\n", sql_str);
    
    status = SQLstmt (sql_str);
    if (status != SQL_S_SUCCESS) {
         if (status == SQL_E_MESSAGE)  {
           _PDMdebug ("Retrying", "%s\n",  sql_str);
           status = _PDMRetrySqlStmt (sql_str);
           if (status != PDM_S_SUCCESS) {
              _PDMdebug (fn, "SQLstmt Failed 0x%.8x\n", status);
              return(PDM_E_SQL_STMT);
              }
            }
            else {
    free (sql_str);
        _PDMdebug (fn, "SQLstmt %d\n", status);
        _PDMdebug (fn, "Update failed for %s %s %s\n",
          data[nxi+1], data[nxi+2], data[nxi+3]);
          status = _PDMget_db_error (status);
          return (status);
         }
        }
     }

    else if ((atol (data[nxi + 8]) == 1) && 
       ((!strcmp (data[nxi + 7], "Y")) || (!strcmp (data[nxi + 6], "Y")))) {
     sprintf(sql_str,
"UPDATE NFMSAFILES SET  n_ref = %d  WHERE n_sano = %s AND n_catalogno = %s AND n_itemno = %s AND n_filenum = %s AND n_fileversion = %s AND n_filename = '%s'", 
  (atol (data[nxi+8]) -1), data[nxi+0],  data[nxi+1], data[nxi+2], 
   data[nxi+4], data[nxi+5], data[nxi+3]);

    _PDMdebug ("sql_stmt", "\n%s\n", sql_str);
    
    status = SQLstmt (sql_str);
    if (status != SQL_S_SUCCESS) {
         if (status == SQL_E_MESSAGE)  {
           _PDMdebug ("Retrying", "%s\n",  sql_str);
           status = _PDMRetrySqlStmt (sql_str);
           if (status != PDM_S_SUCCESS) {
              _PDMdebug (fn, "SQLstmt Failed 0x%.8x\n", status);
              return(PDM_E_SQL_STMT);
              }
            }
            else {

    free (sql_str);
        _PDMdebug (fn, "SQLstmt %d\n", status);
        _PDMdebug (fn, "Update failed for %s %s %s\n",
          data[nxi+1], data[nxi+2], data[nxi+3]);
          status = _PDMget_db_error (status);
          return (status);
         }
        }
      }
     else {
      sprintf (sql_str, 
          "DELETE FROM  NFMSAFILES  WHERE n_sano = %s \
          AND n_catalogno = %s AND n_itemno = %s AND n_filenum = %s \
          AND n_fileversion = %s AND n_filename = '%s'", 
          data[nxi+0],  data[nxi+1], data[nxi+2], data[nxi+4], 
          data[nxi+5], data[nxi+3]);

      _PDMdebug ("sql_stmt", "\n%s\n", sql_str);
    
      status = SQLstmt (sql_str);
      if (status != SQL_S_SUCCESS) {
         if (status == SQL_E_MESSAGE)  {
           _PDMdebug ("Retrying", "%s\n",  sql_str);
           status = _PDMRetrySqlStmt (sql_str);
           if (status != PDM_S_SUCCESS) {
              _PDMdebug (fn, "SQLstmt Failed 0x%.8x\n", status);
              return(PDM_E_SQL_STMT);
              }
            }
            else {

    free (sql_str);
        _PDMdebug (fn, "SQLstmt %d\n", status);
        _PDMdebug (fn, "Delete failed for %s %s %s\n",
          data[nxi+1], data[nxi+2], data[nxi+3]);
          status = _PDMget_db_error (status);
          return (status);
         }
       }
      

      tmp_row [0] = '\0';
      sprintf (tmp_row, "%s\1", data[nxi + 3]);
      _PDMdebug ("tmp_row", "%s\n", tmp_row);
      status = MEMwrite (*file_bufr, tmp_row);
      if (status != MEM_S_SUCCESS) {
           _PDMdebug (fn, "MEMwrite_data failed %d\n", status );
           return (status);
           }
      }
   }
   


  free (sql_str);
  if (PDMdebug_on) {
    MEMprint_buffer("file_bufr", *file_bufr, PDM_DEBUG_FILE);
    }


  PDMdebug("EXIT:PDMco_item_update_filemanager\n");
  return(PDM_S_SUCCESS);
}

