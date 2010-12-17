#include "stdio.h"
#include "NFMerrordef.h"
#include "ERR.h"
#include "DEBUG.h"
#include "MEMstruct.h"
#include "NFMschema.h"
#include "NFMitems.h"
#include "NFMitemfiles.h"
#include "PDMproto.h"
#include "PDUerror.h"
#include "PDMbom_strct.h"

/* #include "NFMmfb.h" */

extern int      PDMdebug_on;
extern char     PDM_DEBUG_FILE[];
extern PDMpart_ptr PDMpart;
extern PDMexec_ptr PDMexec;
static long     status;

/* This function loads the dynamic table name and number into
   the linked list MaC */

int PDMload_dyn_catname_no (set_head, set_end, num_members)

struct PDMbom_member *set_head, *set_end;
int num_members;
{
  /***
    CHANGE HISTORY:
      01/04/93 MaC creation.
  ***/


  char *fn="PDMload_dyn_catname_no";
  struct PDMbom_member *cur_mem;
  struct PDMbom_member *search_mem = NULL;
/*  char alt_parent[40];*/
  char val[40];
  char dyn_tabname[40];
  char   sql_str[1024];
  char	*cat_list;
  MEMptr	bufr = NULL;
  char		**attr;
  int		dyn_tabno = -1;
  int		duplicate, x, y, attr_index;


  _PDMdebug (fn, "ENTER\n");

   _PDMdebug (fn, "num_members = %d\n", num_members);

    cat_list = (char *) malloc ((num_members * 20) + 512);
    if (! cat_list) {
       _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n", NFM_E_MALLOC);
       return (NFM_E_MALLOC);
       }
    cat_list[0] = '\0';

     /* Preparing catalognos list...*/

 sprintf (cat_list, " %d", set_head->cat_no);
/* junk added to remove warnings*/
 cur_mem = set_end;
 cur_mem = NULL;

/* remove the duplicate catnos */

 duplicate = -1;
 for (x=0, cur_mem = set_head->next; cur_mem != NULL; 
                     x++, cur_mem = cur_mem->next) {
   _PDMdebug ("Checking catno ", "%d: x = %d\n", cur_mem->cat_no, x);
   duplicate = 0;
   for (y=0, search_mem = set_head->next; y <  x;
             y++, search_mem = search_mem->next) {
       if (cur_mem->cat_no == search_mem->cat_no) {
            _PDMdebug ("catno already added", "%d\n", search_mem->cat_no);
            duplicate = 1;
            break;
          }
       }
   if ( (duplicate != 1) || (x == 0) ) {
   sprintf (val, ", %d ", cur_mem->cat_no);
   strcat (cat_list, val);
       }
   _PDMdebug ("cat_list", "%s\n", cat_list);
      }
   _PDMdebug ("cat_list", "%s\n", cat_list);
    
/* get a list of dynamic table names and nos */

/* Since the dyn tab names in the pdmcatalogs table can be
   in upper case and those in nfmtables can be in lower case, 
   This query cannot be used any more. We first need to
   get dyn tab name and convert it to lower case and
   then query the nfmtables for the tableno. MaC 071293*/
/*
   sprintf (sql_str, "%s %s %s %s ( %s )" , 
              "SELECT p_dyntable, n_catalogno, n_tableno ", 
              "FROM  pdmcatalogs, nfmtables ", 
              "WHERE nfmtables.n_tablename = pdmcatalogs.p_dyntable AND ", 
              " n_catalogno in ", cat_list);
*/

   sprintf (sql_str, "%s %s ( %s )" , 
              "SELECT p_dyntable, n_catalogno FROM  pdmcatalogs ", 
              "WHERE n_catalogno in ", cat_list);

   status = SQLquery (sql_str, &bufr, MEM_SIZE);
   if ( (status != SQL_S_SUCCESS ) &&
            (status != SQL_I_NO_ROWS_FOUND ) ) {
    free (cat_list);
    _PDMdebug ( fn, "SQLquery 0x%.8x\n", status) ;
    return (status);
    }
    
    if (status == SQL_S_SUCCESS) {
    status = MEMbuild_array (bufr);
    if (status != MEM_S_SUCCESS) {
      MEMclose (&bufr);
      free (cat_list);
      _PDMdebug ( fn, "MEMbuild_query (bufr) 0x%.8x\n", NFM_E_MEM );
      return (NFM_E_MEM);
      }

   if (PDMdebug_on) {
      MEMprint_buffer("list of dyn cats from query", bufr, PDM_DEBUG_FILE);
       }

   attr = (char **) (bufr)->data_ptr;

     /* Preparing dyn_catalognos list...*/

/*
   dyn_cat_list [0] = '\0';
   
   sprintf (dyn_cat_list, " %s ", attr[2]);
   for (x = 1; x < bufr->rows; x++) {
      attr_index = x * bufr->columns;
      strcat (dyn_cat_list, ", ");
      strcat (dyn_cat_list, attr[attr_index + 2]);
    }
   _PDMdebug ("dyn_cat_list", "%s\n", dyn_cat_list);
*/

/* loading dyn_catname and dyn_catno into the linked list */

    for (cur_mem = set_head; cur_mem != NULL; cur_mem = cur_mem->next) {
     for (x = 0; x < bufr->rows; x++) {
      attr_index = x * bufr->columns;
      if (atol (attr[attr_index + 1]) == cur_mem->cat_no) {
         strcat (cur_mem->dyn_cat_name, attr[attr_index]);
/* fix added to query the tabno independently */
         dyn_tabname [0] = '\0'; 
         PDMconvert_to_lower (attr[attr_index], dyn_tabname);
         _PDMdebug (fn, "cat_name [%s] --> dyn_tabname[%s]\n", 
                     cur_mem->cat_name, dyn_tabname);
         status = PDMquery_table_no (dyn_tabname, &dyn_tabno);
         if (status != PDM_S_SUCCESS) {
           MEMclose (&bufr);
           free (cat_list);
           _PDMdebug ( fn, "PDMquery_tableno 0x%.8x\n", status );
           return (status);
           }
         /*cur_mem->dyn_cat_no = atol (attr[attr_index + 2]);*/
         cur_mem->dyn_cat_no = dyn_tabno;
         }
        }
      }


  MEMclose (&bufr);
   } 
   else {
   _PDMdebug (fn, 
"fatal error: cannot generate altboms for catalogs with no alt parents...\n");
     return (status);
    }
  if (cat_list) free (cat_list);
  _PDMdebug ( fn, "EXIT: 0x%.8x\n", PDM_S_SUCCESS );
  return (PDM_S_SUCCESS);
}


int _PDMget_alternate_parentname (row_no, dyn_cat_name, 
                                                alt_attr, alt_parent)
char           *dyn_cat_name;
int             row_no;
char           *alt_parent;
char           *alt_attr;
{
        char            *fn = "_PDMget_alternate_parentname";
        char            sql_str[1024];
        MEMptr          bufr = NULL;
        char          **data;

  _PDMdebug("ENTER", "%s\n", fn);
  _PDMdebug (fn, "dyn_cat[%s], row_no[%d], alt_attr[%s]\n", 
                                  dyn_cat_name, row_no, alt_attr);
  sprintf(sql_str, "SELECT %s FROM %s WHERE p_pdcno = %d", 
                             alt_attr, dyn_cat_name, row_no);
  status = SQLquery(sql_str, &bufr, 512);
  if (status != SQL_S_SUCCESS) {
     if (bufr) MEMclose(&bufr);
     _PDMdebug (fn, "SQLquery failed status %d\n", status);
     return (PDM_E_SQL_QUERY);
     }
  status = MEMbuild_array(bufr);
  if (status != MEM_S_SUCCESS) {
     MEMclose(&bufr);
     _PDMdebug (fn, "MEMbuild_array failed status %d\n", status);
     return (PDM_E_BUILD_ARRAY);
        }
  data = (char **) bufr->data_ptr;
  strcpy(alt_parent, data[0]);
  _PDMdebug (fn, "alt_parent[%s]\n", alt_parent);


  MEMclose(&bufr);
  _PDMdebug("EXIT", "%s\n", fn);
  return (PDM_S_SUCCESS);
}


  /***
long PDMcreate_par_struct_list (set_head, set_end, num_members, alt_parent, 
                                  alt_head, alt_end)

    This function creates an alt struct list
    from the members of the original structure list.
    for the purpose of creating BOM.

    Note: The caller does not have to make sure the passed in 
          structures are freed. This fn will free 'em.

    CHANGE HISTORY:
      1/4/93 MaC creation.
  ***/


long PDMdfs_retrieve_alt_bom_struct (set_head, set_end, alt_parent, level, 
                                       curr_level, alt_head, alt_end)

struct PDMbom_member *set_head, *set_end;
struct PDMbom_member *alt_head, *alt_end;
char *alt_parent;
int level, curr_level;
{
  /***
    This recursive function retrieve the members of the given assembly
    for the purpose of creating BOM.
    The members retrieved will be checked for in PDMCIT table
    to see if they are attached or to be included in BOM or 
    need to be exploded.

    This function returns SQL_I_NO_ROWS_FOUND or PDM_S_SUCCESS
    for successful statii.

    Note: The caller does not have to make sure the passed in item_nos are sets

    CHANGE HISTORY:
      11/19/92 MaC creation.
  ***/


  char *fn="PDMdfs_retrieve_alt_bom_struct";
  int duplicate, x;
  int new_member_found;
  struct PDMbom_member *cat_head, *new_node, *cur_mem;

  _PDMdebug (fn, "ENTER\n");
  _PDMdebug (fn, "alt_parent [%s]: curr_level[%d]\n", alt_parent, curr_level);

  new_member_found = 0;
  /*for (x = 0, cat_head = set_head->next; x < list->rows; x++) */
  for (x = 0, cat_head = set_head->next; cat_head != NULL; 
                                 x++, cat_head = cat_head->next) {
  _PDMdebug (fn, "x[%d]: cat_head[itmname] = %s:citno[%d]\n", 
                                x, cat_head->item_name, cat_head->citno);
   if ( (!strcmp (cat_head->alt_parent_attr, alt_parent ) )
          && (cat_head -> mark != 1) ) {
  _PDMdebug (fn, "cat_head[itmname] = %s:citno[%d]\n", 
                                cat_head->item_name, cat_head->citno);
  duplicate = 0;
      status = _PDMcheck_duplicate_parent (cat_head, cat_head->citno, 
                                   &duplicate) ;
      if (status != PDM_S_SUCCESS) {
        _PDMdebug ( fn, "_PDMcheck_duplicate_parent failed for %s 0x%.8x\n", 
                                             alt_parent, status );
        return (status);
          } 
     _PDMdebug (fn, "Duplicate[%d]\n", duplicate);
     if (duplicate != 1 ) {
      new_member_found = 1;
      new_node = (struct PDMbom_member *) NULL; 
      new_node = (struct PDMbom_member *)calloc (1, 
                         sizeof (struct PDMbom_member));
      if (new_node == (struct PDMbom_member *) NULL) {
        _PDMdebug (fn, "Allocate %d  failed\n", 
                        sizeof (struct PDMbom_member));
        return (NFM_E_MALLOC);
      }
      new_node->level = curr_level;
      status = _PDMcopy_bom_llist (cat_head, new_node);
      if (status != PDM_S_SUCCESS) {
        _PDMdebug ( fn, "_PDMcopy_bom_llist failed for %s 0x%.8x\n", 
                                             alt_parent, status );
        return (status);
          } 
      
       /* mark this item as copied */
       
       cat_head->mark = 1;
     
      /* strcpy (alt_parent, cat_head->item_name);*/
      _PDMdebug ("alt_end", "[%lx]<>alt_end->next[%lx]\n", 
                                       (alt_end), (alt_end)->next);
      _PDMdebug ("alt_end", "[%lx]\n", alt_end);
      for ( cur_mem = alt_end; 
              cur_mem->next != (struct PDMbom_member * ) NULL; 
                       cur_mem = cur_mem->next){
      _PDMdebug ("alt_end", "[%lx]<>alt_end->next[%lx]\n", 
                                       cur_mem, cur_mem->next);
      }
      _PDMdebug ("alt_end", "[%lx]\n", alt_end);
      _PDMdebug ("cur_mem", "[%lx]\n", cur_mem);
      _PDMdebug ("new_node", "[%lx]\n", new_node);
      alt_end = cur_mem;
      alt_end->next = new_node;
      alt_end = new_node;
      _PDMdebug ("set_end", "[%lx]\n", set_end);
      _PDMdebug ("printing addresses", "\n");
      for ( cur_mem = alt_head; 
              cur_mem != (struct PDMbom_member * ) NULL; 
                       cur_mem = cur_mem->next){
      _PDMdebug ("cur_mem", "[%lx]<>cur_mem->next[%lx]\n", 
                                       cur_mem, cur_mem->next);
      }
      _PDMdebug ("printing values", "\n");
      for ( cur_mem = alt_head; 
              cur_mem != (struct PDMbom_member * ) NULL; 
                       cur_mem = cur_mem->next){
      _PDMprint_bommember_info ("cur_mem", cur_mem);
      }
/*      (*num_members) ++; */
    /* added recursion for each member...*/
    if ((curr_level + 1) > level) {
    _PDMdebug (fn, "Entering Recursion...\n");
     status = PDMdfs_retrieve_alt_bom_struct (set_head, set_end, 
                                 cat_head->item_name, 
                                 level, (curr_level + 1), alt_head, alt_end);
        if ( (status != PDM_S_SUCCESS) && 
               (status != SQL_I_NO_ROWS_FOUND) ) {
              _PDMdebug (fn, "PDMdfs_retrieve_bom_members 0x%.8x\n", status);
              return (status);
                }
        if (status == SQL_I_NO_ROWS_FOUND ) {
          _PDMdebug (fn, "*** Leaf found for this branch..\n");
           }
        }
     /* if duplicate == 0 */ }
   } /* checking if this member is an alt_child */
   _PDMdebug ("Alt_parent for this cycle is", " %s\n", alt_parent);
   _PDMdebug ("Curr_level for this cycle is", " %d\n", curr_level);
   if (cat_head) {
      _PDMprint_bommember_info ("cat_head", cat_head);
     }
   else _PDMdebug (fn, "cat_head is NULL\n");
   }
     if (new_member_found == 1) {
         _PDMdebug (fn, "Found children: marking this child as added\n");
         _PDMdebug ("new_member_found", "%d\n", new_member_found);
       }
     else { _PDMdebug (fn, "**** LEAF found for this branch..\n"); }
      _PDMdebug ("printing alt values", "\n");
      for ( cur_mem = alt_head; 
              cur_mem != (struct PDMbom_member * ) NULL; 
                       cur_mem = cur_mem->next){
      _PDMprint_bommember_info ("cur_mem", cur_mem);
      }

  _PDMdebug ( fn, "EXIT: 0x%.8x\n", PDM_S_SUCCESS );
  return (PDM_S_SUCCESS);
}

 
int _PDMcopy_bom_llist (set_mem, alt_mem)
struct PDMbom_member *set_mem, *alt_mem;
{
	char		*fn = "PDMcopy_bom_llist";

 _PDMdebug ( fn, "ENTER\n");

 _PDMdebug (fn, "copying member %s.%s.%s\n", 
              set_mem->cat_name, set_mem->item_name, set_mem->item_rev);

/*  alt_mem-> level = set_mem->level;*/
  alt_mem-> citno = set_mem->citno;
  alt_mem-> pcat_no = set_mem->pcat_no;
  alt_mem-> pitem_no = set_mem->pitem_no;
  strcpy (alt_mem->type, set_mem-> type);
  alt_mem-> cat_no = set_mem->cat_no;
  strcpy (alt_mem->cat_name, set_mem-> cat_name);
  alt_mem-> item_no = set_mem->item_no;
  strcpy (alt_mem->file_status, set_mem-> file_status);
  strcpy (alt_mem->archive_state, set_mem-> archive_state);
  strcpy (alt_mem->item_name, set_mem-> item_name);
  strcpy (alt_mem->item_rev, set_mem-> item_rev);
  strcpy (alt_mem->lock, set_mem-> lock);
  alt_mem-> version_limit = set_mem->version_limit;
  strcpy (alt_mem->set_indicator, set_mem-> set_indicator);
  strcpy (alt_mem->file_class, set_mem-> file_class);
  strcpy (alt_mem->file_type, set_mem-> file_type);
  strcpy (alt_mem->file_co, set_mem-> file_co);
  alt_mem-> file_version = set_mem->file_version;
  strcpy (alt_mem->pending_flag, set_mem-> pending_flag);
  alt_mem-> file_size = set_mem->file_size;
  strcpy (alt_mem->ci_filename, set_mem-> ci_filename);
  alt_mem-> ci_sano = set_mem->ci_sano;
  alt_mem-> co_sano = set_mem->co_sano;
  strcpy (alt_mem->co_filename, set_mem-> co_filename);
  alt_mem-> filenum = set_mem->filenum;
  alt_mem-> mark = set_mem->mark;
  alt_mem-> mark = set_mem->mark;
  alt_mem-> flag = set_mem->flag;
 /* added for pdm bom*/
 strcpy (alt_mem->attached, set_mem-> attached);
 strcpy (alt_mem->history, set_mem-> history);
 strcpy (alt_mem->orient, set_mem-> orient);
 strcpy (alt_mem-> quantity, set_mem->quantity);
 alt_mem-> childno = set_mem->childno;
 strcpy (alt_mem->usageid, set_mem-> usageid);
 strcpy (alt_mem->viewid, set_mem-> viewid );
 alt_mem-> tagno  = set_mem->tagno;
 strcpy (alt_mem->alttagno, set_mem-> alttagno);
 strcpy (alt_mem->incbom, set_mem-> incbom );
 strcpy (alt_mem->explode, set_mem-> explode);
 alt_mem-> pdcno = set_mem->pdcno;
 alt_mem-> dyn_cat_no = set_mem->dyn_cat_no;
 strcpy (alt_mem->dyn_cat_name, set_mem-> dyn_cat_name);
  strcpy (alt_mem->alt_parent_attr, set_mem-> alt_parent_attr);

 _PDMdebug (fn, "copied member %s.%s.%s\n", 
              alt_mem->cat_name, alt_mem->item_name, alt_mem->item_rev);

 _PDMdebug ( fn, "EXIT: 0x%.8x\n", PDM_S_SUCCESS );
 return (PDM_S_SUCCESS);
}


int  _PDMcheck_duplicate_parent (cat_head, citno, duplicate) 
struct PDMbom_member *cat_head;
int	citno, *duplicate;
{
	char	*fn = "_PDMcheck_duplicate_parent";
	struct PDMbom_member *cur_mem = NULL;

  _PDMdebug (fn, "ENTER\n");
  _PDMdebug (fn, "cur_mem[itmname] = %s:citno[%d]\n", 
                                cat_head->item_name, citno);

   for (cur_mem = cat_head->next; cur_mem != NULL; cur_mem = cur_mem->next) {
       _PDMdebug ("Testing", "cur_mem->item_name[%s]: citno[%d]\n", 
              cur_mem->item_name, cur_mem->citno);
       if ( (cur_mem->citno == citno) && (cur_mem->mark == 0) ) {
           _PDMdebug (fn, "found a duplicate citno [%d]\n", citno);
           *duplicate = 1;
           break;
           }
       }
  if (*duplicate != 1) *duplicate = 0;
   _PDMdebug (fn, "EXIT\n");
   return (PDM_S_SUCCESS);
}




int PDMget_alt_bom_members (catno, partno, level, 
                                     set_head, set_end, nch, alt_parent_attr)
int	catno, partno;
int	level, *nch;
char	*alt_parent_attr;
struct	PDMbom_member **set_head, **set_end;
{
  char		*fn = "PDMget_alt_bom_members";
  /*char		sql_str[300];*/
  char		alt_parent[300];
  long		status;
  int		nchildren;
  struct	NFMmembers	*parent_struct;
  struct	PDMbom_member *cur_mem, *mem, *temp_mem;
  struct	PDMbom_member *head, *end;
  struct	PDMbom_member *alt_head, *alt_end;
  struct	PDMbom_member *cat_head;

    _PDMdebug ("ENTER", "%s\n", fn);
    _PDMdebug (fn, "catno = %d, partno = %d, level = %d, nchildren = %d\n", 
    catno, partno, level, nchildren);


  /* load the struct with 1st level children_info */

  head = end = (struct PDMbom_member *) calloc (1, 
                               sizeof (struct PDMbom_member));

  alt_head = alt_end = (struct PDMbom_member *) calloc (1, 
                               sizeof (struct PDMbom_member));

  parent_struct = (struct NFMmembers *) calloc (1, 
                                   sizeof (struct NFMmembers));
  if (head == (struct PDMbom_member *) NULL ||
      alt_head == (struct PDMbom_member *) NULL ||
      parent_struct == (struct NFMmembers *) NULL) {
    NFMrollback_transaction (0);
    return (NFM_E_MALLOC);
  }


  head->level = 0; 
  head->flag = 1; 
  head->cat_no = catno; 
  head->item_no = partno; 
  strcpy (head->type, "P"); 
  strcpy (head->cat_name, PDMexec->catalog); 
  strcpy (head->item_name, PDMexec->part_num); 
  strcpy (head->item_rev, PDMexec->revision); 
  /*strcpy (head->cat_name, catalog_name);*/


  nchildren = 1;

     _PDMprint_bommember ("head", head);

    _PDMdebug (fn, "Loading Parent structure ...\n");
       /*load parent_struct */
        parent_struct->cat_no = catno;
        parent_struct->item_no = partno;
        strcpy (parent_struct->type, "P");

    /* algorithm for level is:
       Info re. all the children for an assembly below the specified 
       level no will be retrieved. If the level specified is 3 and
       the assy has 5 levels, leaves of the last 2 level will be retrieved.
    */
        level = 0;

    _PDMdebug (fn, "Parent struct loaded ..\n \
                    before PDMretrieve_bom_members;\n\
                    nchildren = %d\n", nchildren); 


        status = PDMdfs_retrieve_members_for_bom (catno, partno, level, 1, 
                                                    head, end, &nchildren);

          if ( (status != PDM_S_SUCCESS) && 
               (status != SQL_I_NO_ROWS_FOUND) ) {
            _PDMdebug (fn, 
              "PDMdfs_retrieve_members_for_bom  failed status %d\n", status);
            return (status);
        }



   /* loading dynamic tabname and no into the orig linked list */

    status =  PDMload_dyn_catname_no (head, end, nchildren);
    if (status != PDM_S_SUCCESS) {
     _PDMdebug ( fn, "PDMload_dyn_catname_no  Failed: 0x%.8x\n", status) ;
     return (status);
      }

    /* loading alternate parent into the orig linked list */

    for (cat_head = head->next; cat_head != NULL; cat_head=cat_head->next) {
     status = _PDMget_alternate_parentname (cat_head->pdcno,  
                                              cat_head->dyn_cat_name, 
                                                alt_parent_attr, alt_parent);
     if (status != PDM_S_SUCCESS) {
     _PDMdebug ( fn, "_PDMget_alternate_parentname  Failed: 0x%.8x\n", status) ;
     return (status);
       }
      _PDMdebug (fn, "alt_parent[%s]\n", alt_parent);
      strcpy (cat_head->alt_parent_attr, alt_parent);
      _PDMdebug (fn, "llentry.alt_parent[%s]\n", cat_head->alt_parent_attr);
       }


    _PDMdebug (fn, "list from PDMdfs_retrieve_bom_members\n");
    for ( mem = head; 
              mem != (struct PDMbom_member * ) NULL; 
                       mem = mem->next){
     _PDMprint_bommember ("mem", mem);
      }
     alt_parent[0] = '\0';
     strcpy (alt_parent, head->item_name);
     strcpy (head->alt_parent_attr, alt_parent);
     _PDMdebug (fn, "alt_parent[%s]\n", alt_parent);

     status = _PDMcopy_bom_llist (head, alt_head);
     if (status != PDM_S_SUCCESS) {
        _PDMdebug ( fn, "_PDMcopy_bom_llist failed for %s 0x%.8x\n", 
                                             alt_parent, status );
        return (status);
          } 
      
     _PDMdebug (fn, "Calling PDMdfs_retrieve_alt_bom_struct...\n");
      status = PDMdfs_retrieve_alt_bom_struct (head, end, 
                                                  alt_parent, level, 
                                                  1, alt_head, alt_end);
      if ( (status != PDM_S_SUCCESS) && 
               (status != SQL_I_NO_ROWS_FOUND) ) {
         _PDMdebug (fn, 
              "PDMdfs_retrieve_members_for_bom  failed status %d\n", status);
         return (status);
        }

    /* printing the linked list */

    _PDMdebug (fn, "list from PDMdfs_retrieve_alt_bom_struct\n");
    for ( mem = alt_head; 
              mem != (struct PDMbom_member * ) NULL; 
                       mem = mem->next){
     _PDMprint_bommember ("mem", mem);
      }


    *nch = nchildren;
    *set_head = alt_head;
    *set_end = alt_end;


     _PDMdebug (fn, "Freeing regular bom member linked lists...\n");
     
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

       
   return (PDM_S_SUCCESS);
}

