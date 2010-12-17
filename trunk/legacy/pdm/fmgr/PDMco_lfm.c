#include		<stdio.h>
#include		"PDUerror.h"
#include		"MEMstruct.h"
#include		"MEMerrordef.h"
#include		"NFMerrordef.h"
#include		"SQLerrordef.h"
#include		"PDUris_incl.h"
#include		"NFMfile.h"
#include		"NFMitems.h"
#include		"PDMproto.h"

extern		int		PDMdebug_on;
extern      	PDMpart_ptr 	PDMpart;
extern		char		PDM_DEBUG_FILE[];
static 		long		status;
static		char		s[1024];

extern	struct NFMitem_entry	*NFMitem_file;

#define	UPDMEM	7   /* fileversion in LFM is old; so move */
#define	ATTCH	8   /* file attached but local */
#define	MOVE	9   /* file attached and not local */
#define	NOPE	10   /* file not attached */

/* Algorithm :
  *** Completely modified ***
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
  For Check_In:
   o get the list of files from child_buffer and attach buffer
   o get local file manager information for each of the parts
   o get the n_co, n_copy and n_ref for each of the  part
     and determine whether the file(s) need to be moved.
     if (parent)
	 mark the file as to_be_moved
     else {
      if ( n_ref > 0 )
	  mark the file  as !to_be_deleted
      else
	 mark the file as to_be_deleted
      }
      if (sql_no_rows_found)
	 mark the file as to_be_moved 
	 set a flag that a new entry has to be made in LFM
	}
*/


int PDMget_fmgr_values (catalog, part, rev, 
		cat_no, part_no, sano, nchildren, link_head, link_end, out_bufr)
char *catalog, *part, *rev;
int cat_no, part_no, sano, nchildren;
struct NFMset_member	*link_head;
struct NFMset_member	*link_end;
MEMptr		*out_bufr;
{
char	*fn = "PDMget_fmgr_values ";
/*char	sql_str[5120]; may need to be reduced -MaC*/
char	*sql_str;
char	 itm_val[25], cat_val[25];
MEMptr	list = NULL;
void	_PDMprint_setmember ();
int	x, y, z, duplicate;
int	no_child;
struct NFMset_member    *cur_mem = (struct NFMset_member *) NULL;
struct NFMset_member	*head = (struct NFMset_member *) NULL;
struct NFMset_member	*end = (struct NFMset_member *) NULL;
struct NFMmembers	*chl = (struct NFMmembers *) NULL;

   _PDMdebug ("ENTER", "%s\n", fn);
   _PDMdebug (fn, 
   "catalog[%s] part[%s] rev[%s]\ncat_no[%d], part_no[%d], nchildren [%d]\n",
      catalog, part, rev, cat_no, part_no, nchildren);


/* sql_str will be dynamically allocated MaC 012793 */

    sql_str = (char *) malloc ((nchildren * 100) + 512);
    if (! sql_str) {
       _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n", NFM_E_MALLOC);
       return (NFM_E_MALLOC);
         }
    sql_str[0] = '\0';

       head = link_head;
       end = link_end;

       _PDMdebug (fn, "head->item_no[%d] and head->item_name[%s]\n",
                                        head->item_no, head->item_name);
 chl = (struct NFMmembers *) calloc ((nchildren + 1),
                              (nchildren + 1) * sizeof (struct NFMmembers));

  if (!chl) {
      _PDMdebug (fn, "calloc chl failed...");
       if (sql_str) free (sql_str);
       return (PDM_E_COULD_NOT_MALLOC);
     }

  sprintf (sql_str, 
  "SELECT n_sano, n_catalogno, n_itemno, n_filename, n_filenum, n_fileversion,\
    n_co, n_copy, n_ref, n_nfs, n_cisano, n_mountpoint FROM NFMSAFILES WHERE\
    n_sano = %d AND ( ( n_itemno = %d AND n_catalogno = %d )", 
    sano, part_no, cat_no); 

    PDMdebug (sql_str);
    PDMdebug ("\n");
/* since the parent has already been accounted for,
     # members is nchildren - 1 */
  no_child = nchildren - 1;

for (cur_mem = head->next, x = 0, y = 0; 
           x < no_child ; 
                 ++x, cur_mem = cur_mem->next) {
/* code to remove duplicates...*/
  
    duplicate = 0;
    for (z = 0; z <= y ; ++z) {
      if ( ((chl+z)->cat_no == cur_mem->cat_no ) &&
              ((chl+z)->item_no == cur_mem->item_no) )  { 
            duplicate = 1;
_PDMdebug (fn,
"*** Aha! Found a duplicate!!  ===>> cat_no[%d] item[%d] \n",
                cur_mem->cat_no, cur_mem->item_no);
            break;
            }
        }
  _PDMdebug (fn, "after z-loop; x[%d], y[%d], z[%d]\n", x, y, z);
    _PDMdebug (fn, "duplicate [%d]\n", duplicate);

   _PDMprint_setmember ("cur_mem", cur_mem );

  /* create the sql string */
  if (duplicate == 0 ) {
  (chl+y)->cat_no = cur_mem->cat_no;
  (chl+y)->item_no = cur_mem->item_no;
  strcat (sql_str, " OR (n_itemno = ");
  sprintf (cat_val, "%d", cur_mem->cat_no);
  sprintf (itm_val, "%d", cur_mem->item_no);
  strcat (sql_str, itm_val);
  strcat (sql_str, " AND n_catalogno = ");
  strcat (sql_str, cat_val);
  strcat (sql_str, ") ");

/*
  _PDMdebug ("sql_str is\n", "%s\n", sql_str );
  _PDMdebug (fn, "x[%d], y[%d]\n", x, y);
*/
   ++y;
   }
}

strcat (sql_str, ") ORDER BY n_catalogno");

   sprintf (s, "first query is :\n%s\n", sql_str);
   PDMdebug (s);

  status = SQLquery (sql_str, &list, MEM_SIZE);
  if ( status != SQL_S_SUCCESS ) {
    if ( status != SQL_I_NO_ROWS_FOUND ) {
    free (chl); 
    if (sql_str) free (sql_str); 
    MEMclose (&list);
    _PDMdebug  (fn, "SQLquery 0x%.8x\n", status) ;
    status = _PDMget_db_error (status);
    return (status);
   }

 /* if no_rows_found; all things being equal, all the files have to 
    be moved */

    if ( status == SQL_I_NO_ROWS_FOUND ) {
   _PDMdebug (fn, "There are NO entries in LFM\n");
    status = PDMall_files_moved (head, end);
      if ( status == PDM_S_SUCCESS ) {
              free (chl); 
              if (sql_str) free (sql_str); 
             _PDMdebug ("EXIT", "%s\n", fn);
              return (status);
         } else {
              free (chl); 
              if (sql_str) free (sql_str); 
          _PDMdebug  (fn, "PDMupdate_co_lfm  failed: status = %d\n", status) ;
         return (status);
      }
     }
    }
   else {
  
/* if there are rows in the lfm, mark the files in the buffer as
    *not_to_be_moved*  and rest as to be moved */

   _PDMdebug (fn, "There are entries in LFM\n");
 
  status = MEMbuild_array (list);
  if (status != MEM_S_SUCCESS) {
    MEMclose (&list);
    free (chl); 
    if (sql_str) free (sql_str); 
    _PDMdebug  (fn, "MEMbuild_query (list) 0x%.8x\n", NFM_E_MEM) ;
    return (NFM_E_MEM);
  }
if (PDMdebug_on) {
   MEMprint_buffer ("LFM returned buffer ", list, PDM_DEBUG_FILE);
     }
   
   status = PDMmark_files_to_be_moved (cat_no, part_no, list, head, end); 
  if (status != PDM_S_SUCCESS) {
    MEMclose (&list);
    free (chl); 
    if (sql_str) free (sql_str); 
    _PDMdebug  (fn, "PDMmark_files_to_be_moved failed  %d\n", status) ;
    return (NFM_E_MEM);
  }
    }
if (PDMdebug_on) {
   MEMprint_buffer ("LFM buffer after move files marked", list, PDM_DEBUG_FILE);
     }
    *out_bufr = list;
/*
    link_head = head;
    link_end = end;
*/

    if (sql_str) free (sql_str); 
    free (chl); 
   _PDMdebug ("EXIT", "%s\n", fn);
 return (PDM_S_SUCCESS);
}



int PDMall_files_moved (head, end)
struct NFMset_member	*head, *end;
{
 char		*fn = "PDMall_files_moved";
 void		_PDMprint_setmember ();
struct NFMset_member	*cur_mem;

   _PDMdebug ("ENTER", "%s\n", fn);

/* ANSI */
   end = NULL;
   
            /*cur_mem != (struct NFMset_member *) NULL ; */
   for (cur_mem = head; 
            cur_mem != NULL ; 
                 cur_mem = cur_mem->next) {
             cur_mem->move = MOVE;
     _PDMdebug (fn, "marked %s.%s.%s for MOVE\n", cur_mem->cat_name,
                  cur_mem->item_name, cur_mem->item_rev);
/*    _PDMprint_setmember ("cur_mem", cur_mem); */
     }
   _PDMdebug ("EXIT", "%s\n", fn);
  return (PDM_S_SUCCESS);
}


int PDMmark_files_to_be_moved (cat_no, item_no, list, head, end)
int	cat_no, item_no;
MEMptr	list;
struct NFMset_member	*head, *end;
{
 char		*fn = "PDMmark_files_to_be_moved";
 int		x, i, index, n_ref;
 int		fver, sa_fver;
 int             n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12;
 char		**data, **columns;
 char		n_refval[10];
 int            update_n_ref = -1; 
 void		_PDMprint_setmember ();
struct NFMset_member	*cur_mem;

   _PDMdebug ("ENTER", "%s\n", fn);

/* ANSI */
   end = NULL;

  status = MEMbuild_array (list);
  if (status != MEM_S_SUCCESS) {
    MEMclose (&list);
    _PDMdebug  (fn, "MEMbuild_query (list) 0x%.8x\n", NFM_E_MEM) ;
    return (NFM_E_MEM);
  }
  
   columns = (char **) list->column_ptr;
   data = (char **) list->data_ptr;
   n1 = -1; n2 = -1; n3 = -1;
   n4 = -1; n5 = -1; n6 = -1;
   n7 = -1; n8 = -1; n9 = -1;
   n10 = -1; n11 = -1; n12 = -1;
   for(i=0;i<list->columns;i++) {
                if(!strcmp(columns[i],"n_sano"))                n1 = i;
                if(!strcmp(columns[i],"n_catalogno"))           n2 = i;
                if(!strcmp(columns[i],"n_itemno"))              n3 = i;
                if(!strcmp(columns[i],"n_filename"))            n4 = i;
                if(!strcmp(columns[i],"n_filenum"))             n5 = i;
                if(!strcmp(columns[i],"n_fileversion"))         n6 = i;
                if(!strcmp(columns[i],"n_co"))                  n7 = i;
                if(!strcmp(columns[i],"n_copy"))                n8 = i;
                if(!strcmp(columns[i],"n_ref"))                 n9 = i;
                if(!strcmp(columns[i],"n_nfs"))                 n10 = i;
                if(!strcmp(columns[i],"n_cisano"))              n11 = i;
                if(!strcmp(columns[i],"n_mountpoint"))          n12 = i;
   }
   if(n1 == -1 || n2 == -1 || n3 == -1 ||
      n4 == -1 || n5 == -1 || n6 == -1 ||
      n7 == -1 || n8 == -1 || n9 == -1 ||
      n10 == -1 || n11 == -1 || n12 == -1) {
                PDMdebug("Could not find cols in <list>\n");
                return(PDM_E_BUFFER_FORMAT);
                 }
   


  n_refval[0] = '\0';
  for (cur_mem = head; cur_mem != NULL ; cur_mem = cur_mem->next) {
  update_n_ref = 0;
  for (x=0 ; x < list->rows; ++x) {
  index = x * list->columns;
      if ( ( atol (data[index + n2]) ==  cur_mem->cat_no) &&  
              ( atol (data[index + n3]) == cur_mem->item_no) ) {
 _PDMdebug (fn, "considering cat[%s] part[%s] file[%s]\n",
                    cur_mem->cat_name, cur_mem->item_name, data[index+n4]);

         /*found an item already local; mark it as not to be moved*/
          if ( (atol (data[index+n2]) == cat_no )  &&
                 ( atol (data[index+n3]) == item_no) ) {

            /* this is the parent row in the buffer;
                  set n_co to Y  and move to movits */

                 status = MEMwrite_data (list, "Y", x+1, n7+1);
                 if (status != MEM_S_SUCCESS) {
                    _PDMdebug (fn, "MEMwrite_data failed %d\n", status );
                    return (status);
                  }
     _PDMdebug (fn, "marked %s.%s.%s %s for MOVE\n", cur_mem->cat_name,
                  cur_mem->item_name, cur_mem->item_rev, data[index+n4]);
          cur_mem->move = MOVE;
          /*break;*/
                 }
          else {
          /* one of the children */
          _PDMdebug (fn, "updating cat[%s] part[%s] file[%s]\n",
                    cur_mem->cat_name, cur_mem->item_name, data[index+n4]);

         /*added filenum also to accomodate mul_files/item */
          status = PDMget_max_filever_fname (cur_mem->item_no, 
                                             cur_mem->cat_name, 
                                             atol(data[index+n5]),
                                             &fver);
           if (status != PDM_S_SUCCESS) {
                _PDMdebug (fn, "PDMget_max_filever_fname failed status %d\n",
                                status);
                sprintf(s, "fver = %d\n", fver);
                        PDMdebug(s);
                }
/* commented out since retrieve_set_members weeds out placed parts..
status = PDMquery_cit_attachment(cur_mem->citno, &attached);
if (status != PDM_S_SUCCESS) {
_PDMdebug (fn, "PDMquery_cit_attachment failed status %d\n", status);
sprintf(s, "p_citno = %d\n", cur_mem->citno); PDMdebug(s); }
          if ( (!strcmp (attached, "Y"))  || (!strcmp (attached, "y")) )
 ...........*/

          sa_fver = atol (data[index + n6]);
          if ( fver > sa_fver ){
/* there is a problem here:
   - since there is an entry in the LFM, there is a row in the out_bufr
   - since the file is moved; there is going to be an entry in the 
     output global structure from NFMcheckout_set
   One way of doing this is adding a status to cur_mem->move called
   UPDMEM. If the move = UPDMEM, do not insert a row in LFM
   But update it as needed.
   */
            cur_mem->move = UPDMEM;
            update_n_ref = 1; 
          } 
          else { 
            cur_mem->move = NOPE;
            update_n_ref = 1; 
             }
       /*  break;*/
             }
           }
/*    _PDMprint_setmember ("cur_mem", cur_mem);*/
     _PDMdebug ("cur_mem", 
        "cat_no[%d] item_no[%d] --->  buf: cat_no[%s] itemno[%s]\n", 
        cur_mem->cat_no, cur_mem->item_no, data[index+n2], data[index + n3]);
     if (update_n_ref == 1) {
     n_ref = atol (data[ index + n9] );
     n_ref += 1;
     sprintf (n_refval, "%d", n_ref);
     _PDMdebug (fn, "n_refval[%s] n_ref[%d]\n", n_refval, n_ref);
     status = MEMwrite_data (list, n_refval, x+1, n9+1);
     if (status != MEM_S_SUCCESS) {
              _PDMdebug (fn, "MEMwrite_data failed %d\n", status );
              return (status);
       }
     update_n_ref = 0;
      }
     }
    }
   for (cur_mem = head; cur_mem != NULL ; cur_mem = cur_mem->next) {
       if ( (cur_mem->move != NOPE) && 
                   ( cur_mem->move != ATTCH ) &&
                        ( cur_mem->move != UPDMEM ) ) {
     _PDMdebug (fn, "marked %s.%s.%s for MOVE\n", cur_mem->cat_name,
                  cur_mem->item_name, cur_mem->item_rev);
          cur_mem->move = MOVE;
           }
      }
     if (PDMdebug_on) {
        MEMprint_buffer ("LFM returned buffer ", list, PDM_DEBUG_FILE);
          }
   _PDMdebug ("EXIT", "%s\n", fn);
  return (PDM_S_SUCCESS);
}


int  PDMget_children_fmgr_entries (cat_no, part_no, sano, catalog, part, rev,
                                      head, end, nchildren, out_bufr)
int cat_no, part_no, nchildren;
char *catalog, *part, *rev;
struct NFMset_member    *head;
struct NFMset_member    *end;
MEMptr          *out_bufr;
{
	char		*fn = "PDMget_children_fmgr_entries";
/*	char		sql_str[5120]; may need to be reduced -MaC*/
	char		*sql_str;
	char	 	itm_val[25], cat_val[25];
	MEMptr		list = NULL;
	void		_PDMprint_setmember ();
	int		x;
	int		no_child;

	struct NFMset_member    *cur_mem = (struct NFMset_member *) NULL;

/* ANSI */
   end = NULL;

   _PDMdebug ("ENTER", "%s\n", fn);
   _PDMdebug (fn, 
   "catalog[%s] part[%s] rev[%s]\ncat_no[%d], part_no[%d], nchildren [%d]\n",
      catalog, part, rev, cat_no, part_no, nchildren);


/* sql_str will be dynamically allocated MaC 012793 */

    sql_str = (char *) malloc ((nchildren * 100) + 512);
    if (! sql_str) {
       _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n", NFM_E_MALLOC);
       return (NFM_E_MALLOC);
       }
    sql_str[0] = '\0';
    
/* where clause added to check for sano. prob found in NAVSEA */
  sprintf (sql_str, 
  "SELECT n_sano, n_catalogno, n_itemno, n_filename, n_filenum, n_fileversion,\
    n_co, n_copy, n_ref, n_nfs, n_cisano, n_mountpoint FROM NFMSAFILES WHERE\
    n_sano = %d AND ( ( n_itemno = %d AND n_catalogno = %d )", 
    sano, part_no, cat_no); 

   _PDMdebug ("sql_str", "\n %s \n", sql_str);
 
/* since the parent has already been accounted for,
     # members is nchildren - 1 */
 
/* fix to skip link-list processing for atomic part:
     found the prob in MEM-EMS. MaC 120292 */
/* 10/23/95 - MJG - TR 139424087 DM Manager */
/*
 if ( ( !strcmp (PDMpart.n_setindicator, "Y") ) ||
           (!strcmp (PDMpart.n_setindicator, "y") ) )
*/
 if ( ( !strcmp (PDMpart.n_setindicator, "Y") ) ||
           (!strcmp (PDMpart.n_setindicator, "y") ) ||
           (!strcmp (PDMpart.n_setindicator, "A") ) ||
           (!strcmp (PDMpart.n_setindicator, "a") )) {

      no_child = nchildren - 1;

     _PDMdebug (fn, "head->item_no[%d] and head->item_name[%s]\n",
                                        head->item_no, head->item_name);
        for (cur_mem = head->next, x = 0; 
                   x < no_child ; 
                         ++x, cur_mem = cur_mem->next) {

/*   _PDMprint_setmember ("cur_mem", cur_mem ); */

          /* create the sql string */

        _PDMdebug (fn, "next catno[%d] itemno[%d]\n", 
               cur_mem->cat_no, cur_mem->item_no);
          strcat (sql_str, " OR (n_itemno = ");
          sprintf (cat_val, "%d", cur_mem->cat_no);
          sprintf (itm_val, "%d", cur_mem->item_no);
          strcat (sql_str, itm_val);
          strcat (sql_str, " AND n_catalogno = ");
          strcat (sql_str, cat_val);
          strcat (sql_str, ") ");
        
          _PDMdebug ("sql_str is\n", "%s\n", sql_str );
        }

        strcat (sql_str, " ) ORDER BY n_catalogno");
      }

   sprintf (s, "first query is :\n%s\n", sql_str);
   PDMdebug (s);

  status = SQLquery (sql_str, &list, MEM_SIZE);
  if ( status != SQL_S_SUCCESS ) {
    MEMclose (&list);
    _PDMdebug  (fn, "SQLquery 0x%.8x\n", status) ;
     if (sql_str) free (sql_str);
    status = _PDMget_db_error (status);
    return (status);
   }
   _PDMdebug (fn, "There are entries in LFM\n");
 
       status = MEMbuild_array (list);
            if (status != MEM_S_SUCCESS) {
              MEMclose (&list);
              if (sql_str) free (sql_str);
              _PDMdebug  (fn, "MEMbuild_query (list) 0x%.8x\n", NFM_E_MEM) ;
              return (NFM_E_MEM);
            }
         if (PDMdebug_on) {
            MEMprint_buffer ("LFM returned buffer ", list, PDM_DEBUG_FILE);
              }
   
    if (sql_str) free (sql_str);
    *out_bufr = list;

   _PDMdebug ("EXIT", "%s\n", fn);
 return (PDM_S_SUCCESS);
 
}


int  PDMget_children_fmgr_entries_for_cancelco (cat_no, part_no, catalog, 
                                                part, rev, sano,
                                                head, end, nchildren, 
                                                local_bufr, out_bufr)
int cat_no, part_no, nchildren, sano;
char *catalog, *part, *rev;
struct NFMset_member    *head;
struct NFMset_member    *end;
MEMptr          *out_bufr;
MEMptr          local_bufr;
{
	char		*fn = "PDMget_children_fmgr_entries_for_cancelco";
/*	char		sql_str[5120]; may need to be reduced -MaC*/
	char		*sql_str;
	char	 	itm_val[25], cat_val[25];
	char		*local_list = NULL;
	MEMptr		list = NULL;
	void		_PDMprint_setmember ();
	int		x;
	int		no_child;

	struct NFMset_member    *cur_mem = (struct NFMset_member *) NULL;

/* ANSI */
   end = NULL;

   _PDMdebug ("ENTER", "%s\n", fn);
   _PDMdebug (fn, 
   "catalog[%s] part[%s] rev[%s]\ncat_no[%d], part_no[%d], nchildren [%d]\n",
      catalog, part, rev, cat_no, part_no, nchildren);


/* sql_str will be dynamically allocated MaC 012793 */

    sql_str = (char *) malloc ((nchildren * 100) + 2096);
    if (! sql_str) {
       _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n", NFM_E_MALLOC);
       return (NFM_E_MALLOC);
       }
    sql_str[0] = '\0';
    
/* where clause added to check for sano. prob found in NAVSEA */

  sprintf (sql_str, 
  "SELECT n_sano, n_catalogno, n_itemno, n_filename, n_filenum, n_fileversion,\
    n_co, n_copy, n_ref, n_nfs, n_cisano, n_mountpoint FROM NFMSAFILES WHERE\
    n_sano = %d AND ( ( n_itemno = %d AND n_catalogno = %d )", 
    sano, part_no, cat_no); 

   _PDMdebug ("sql_str", "\n %s \n", sql_str);
 
/* Added local_bufr processing:
    This buffer contains the list of files which are local
    They may no longer belong to this assy according to
    PDM assy defn. but have been brought local during 
    CO session. They also need to be cleaned up along with
    existing children files. MaC 031293 */

/*
 
   status = MEMbuild_array (local_bufr);
   if ((status != MEM_S_SUCCESS) && (status != MEM_E_NULL_BUFFER ) ) {
      if (sql_str) free (sql_str);
      _PDMdebug  (fn, "MEMbuild_query (list) 0x%.8x\n", NFM_E_MEM) ;
      return (NFM_E_MEM);
      }
   if (PDMdebug_on) {
      MEMprint_buffer ("Child buffer ", local_bufr, PDM_DEBUG_FILE);
   }
   
   if (status == MEM_S_SUCCESS) {

    local_list = (char *) malloc ((local_bufr->rows * 100) + 512);
    if (! local_list) {
       _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n", NFM_E_MALLOC);
       return (NFM_E_MALLOC);
       }
    local_list[0] = '\0';
    
   columns = (char **) local_bufr->column_ptr;
   data = (char **) local_bufr->data_ptr;
   i_catno = -1;
   i_itemno = -1;
   i_cat = -1;
   i_item = -1;
   i_rev = -1;

   for (x=0 ; x < local_bufr->columns; ++x) {
      if (!strcmp (columns[x], "n_catalogno")) i_catno = x;
      else if (!strcmp (columns[x], "n_itemno")) i_itemno = x;
      else if (!strcmp (columns[x], "n_catalogname")) i_cat = x;
      else if (!strcmp (columns[x], "n_itemname")) i_item = x;
      else if (!strcmp (columns[x], "n_itemrev")) i_rev = x;
      }

   local_list[0] = '\0';
   for (x=0 ; x < local_bufr->rows; ++x) {
    index = local_bufr->columns * x;
    status = PDMquery_catalog_partnos( data[index + i_cat], 
                                       data[index + i_item], 
                                       data[index + i_rev],
                                       &catalogno, 
                                       &itemno);
    if (status != PDM_S_SUCCESS) {
       MEMclose (&list);
       if (sql_str) free (sql_str);
       _PDMdebug  (fn, "PDMquery_catalog_partnos  0x%.8x\n", status) ;
       return (status);
       }

   cat_val[0] = '\0';
   itm_val[0] = '\0';
   strcat (local_list, " OR (n_itemno = ");
   sprintf (cat_val, "%d", catalogno);
   sprintf (itm_val, "%d", itemno);
   strcat (local_list, itm_val);
   strcat (local_list, " AND n_catalogno = ");
   strcat (local_list, ") ");
   }
   _PDMdebug (fn, "local_list[%s]\n", local_list);
  }
*/
     
 
/* fix to skip link-list processing for atomic part:
     found the prob in MEM-EMS. MaC 120292 */
/* 10/23/95 - MJG - TR 139424087 DM Manager */
/*
 if  ( (local_bufr != NULL ) || ( ( !strcmp (PDMpart.n_setindicator, "Y") ) ||
           (!strcmp (PDMpart.n_setindicator, "y") ) ))
*/
 if  ( (local_bufr != NULL ) || 
     ( ( !strcmp (PDMpart.n_setindicator, "Y") ) ||
        (!strcmp (PDMpart.n_setindicator, "y") ) ||
        (!strcmp (PDMpart.n_setindicator, "A") ) ||
        (!strcmp (PDMpart.n_setindicator, "a") ) )) {

      no_child = nchildren - 1;

     _PDMdebug (fn, "head->item_no[%d] and head->item_name[%s]\n",
                                        head->item_no, head->item_name);
        for (cur_mem = head->next, x = 0; 
                   ((x < no_child ) || ( cur_mem != NULL) ); 
                         ++x, cur_mem = cur_mem->next) {

/*   _PDMprint_setmember ("cur_mem", cur_mem ); */

          /* create the sql string */

        _PDMdebug (fn, "next catno[%d] itemno[%d]\n", 
               cur_mem->cat_no, cur_mem->item_no);
          strcat (sql_str, " OR (n_itemno = ");
          sprintf (cat_val, "%d", cur_mem->cat_no);
          sprintf (itm_val, "%d", cur_mem->item_no);
          strcat (sql_str, itm_val);
          strcat (sql_str, " AND n_catalogno = ");
          strcat (sql_str, cat_val);
          strcat (sql_str, ") ");
        
          _PDMdebug ("sql_str is\n", "%s\n", sql_str );
        }

   /*     if (local_list) strcat (sql_str, local_list);*/
      }

   strcat (sql_str, " ) ORDER BY n_catalogno");

   sprintf (s, "first query is :\n%s\n", sql_str);
   PDMdebug (s);

  status = SQLquery (sql_str, &list, MEM_SIZE);
  if ( status != SQL_S_SUCCESS ) {
    MEMclose (&list);
    _PDMdebug  (fn, "SQLquery 0x%.8x\n", status) ;
     if (sql_str) free (sql_str);
     if (local_list) free (local_list);
    status = _PDMget_db_error (status);
    return (status);
   }
   _PDMdebug (fn, "There are entries in LFM\n");
 
       status = MEMbuild_array (list);
            if (status != MEM_S_SUCCESS) {
              MEMclose (&list);
              if (sql_str) free (sql_str);
              _PDMdebug  (fn, "MEMbuild_query (list) 0x%.8x\n", NFM_E_MEM) ;
              return (NFM_E_MEM);
            }
         if (PDMdebug_on) {
            MEMprint_buffer ("LFM returned buffer ", list, PDM_DEBUG_FILE);
              }
   
    if (sql_str) free (sql_str);
    *out_bufr = list;

   _PDMdebug ("EXIT", "%s\n", fn);
 return (PDM_S_SUCCESS);
 
}

