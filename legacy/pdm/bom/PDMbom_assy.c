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
/*
struct PDMbom_member
*/

long PDMretrieve_members_for_bom (members_list, count, level, curr_level, 
                                 set_head, set_end, num_members)

struct NFMmembers *members_list;
int  count, level, curr_level;
struct PDMbom_member *set_head, *set_end;
int *num_members;

{
  /***
    This recursive function retrieve the members if there is any.
    (based on the passed in item numbers and catalog numbers.) 
    The members retrieved will be checked for in PDMCIT table
    to see if they are attached. The returning list will have
    only those member/s which are attached.
    Further, this functions returns only unique child members.
    The list output will have only non-duplicate members.
    Note, that the tree structure of the assy is not preserved, 
    the list only contains those members whose entries in the LFM
    have to be modified.

    This function returns SQL_I_NO_ROWS_FOUND or PDM_S_SUCCESS
    for successful statii.
    Note: The caller does not have to make sure the passed in item_nos are sets

    CHANGE HISTORY:
      09/01/91 mfb creation.
      02/12/92 MaC added support of checking attach flag.
      03/02/92  MaC added support of removing duplicate members.
      04/09/92  MaC added support of checking p_explode flag.
      09/12/92  MaC added support of checking p_incbom flag
                and changed the nfmstruct to pdmbom struct
                this facilitates us to get all the columns of 
                pdmcit table.
  ***/


  char *fn="PDMretrieve_members_for_bom";
  char *sql_str;
  char value[50];
  char **data;
  int x, or, index;
  int duplicate, cat_no, item_no;
  int count2;
  MEMptr list=NULL;
  struct NFMmembers *members_list2;
  struct PDMbom_member *cat_head, *new_node;
  double	doub;

  _PDMdebug (fn, "ENTER: get members for [%d] items on level %d\n\
                      total members retrieved so far %d\n", 
               count, level, *num_members);

/* sql_str will be dynamically allocated MaC 012793 */

    sql_str = (char *) malloc ((*num_members * 100) + 512);
    if (! sql_str) {
       _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n", NFM_E_MALLOC);
       return (NFM_E_MALLOC);
       }
    sql_str[0] = '\0';



  sprintf (sql_str, "%s %s %s %s %s %s", 
"SELECT nfmsetcit.n_citno, nfmsetcit.n_pcatalogno, nfmsetcit.n_pitemno, " , 
"nfmsetcit.n_ccatalogno, nfmsetcit.n_citemno, nfmsetcit.n_type, ", 
"pdmcit.p_attached, pdmcit.p_explode, p_orient, p_quantity, p_childno, ", 
"p_viewid, p_usageid, p_tagno, p_alttagno, p_incbom, n_catalogname, ", 
"n_itemname, n_itemrev, p_history, p_pdcno, n_cofilename FROM nfmsetcit, pdmcit ", 
"where pdmcit.p_citno = nfmsetcit.n_citno and (");

  for (x = or = 0; x < count; x++)
  {
    _PDMdebug ( fn, "retrieve member for cat [%d], item [%d]\n", 
                 (members_list+x)->cat_no, (members_list+x)->item_no); 
    if (or)
    {
      strcat (sql_str, " or ((nfmsetcit.n_pcatalogno = ");
      sprintf(value, "%d", (members_list+x)->cat_no);
      strcat (sql_str, value);
      strcat (sql_str, ") and (nfmsetcit.n_pitemno = ");
      sprintf (value, "%d", (members_list+x)->item_no);
      strcat (sql_str, value);
      strcat (sql_str, "))");
    }
    else
    {
      strcat (sql_str, "((nfmsetcit.n_pcatalogno = ");
      sprintf(value, "%d", (members_list+x)->cat_no);
      strcat (sql_str, value);
      strcat (sql_str, ") and (nfmsetcit.n_pitemno = ");
      sprintf (value, "%d", (members_list+x)->item_no);
      strcat (sql_str, value);
      strcat (sql_str, "))");
      or = 1;
    }
  } 
  
  strcat (sql_str, " ) ");
/*
  strcat (sql_str, " ) ORDER BY n_ccatalogno");
*/

  _PDMdebug (fn, "exec qry: %s\n", sql_str);

  status = SQLquery (sql_str, &list, MEM_SIZE);
  if (status != SQL_S_SUCCESS) {
    MEMclose (&list);
    _PDMdebug ( fn, "SQLquery 0x%.8x\n", status) ;
    return (status);
  }

        if (PDMdebug_on) {
                MEMprint_buffer("list from query", list, PDM_DEBUG_FILE);
        }


  status = MEMbuild_array (list);
  if (status != MEM_S_SUCCESS) {
    MEMclose (&list);
    _PDMdebug ( fn, "MEMbuild_query (list) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
  } 

  members_list2 = (struct NFMmembers *) calloc (list->rows, 
                     list->rows * sizeof (struct NFMmembers));
  if (members_list2 == (struct NFMmembers *) NULL) {
    _PDMdebug (fn, "Allocate %d  failed\n", 
                       list->rows * sizeof (struct NFMmembers));
    return (NFM_E_MALLOC);
  }
  count2 = 0;

  duplicate = 0;
  data = (char **) list->data_ptr;
  for (x = 0, cat_head = set_head; x < list->rows; x++) {
    index = x * list->columns;
     cat_no = atol (data[index+3]);
     item_no = atol (data[index+4]);
    _PDMdebug ( fn, "index %d, row %d: %s %s %s %s %s %s %s\n", 
               index, x, data[index],  data[index+1], data[index+2], 
                data[index+3], data[index+4], data[index+5], data[index+6]);
/* if p_attached is Y then add the member to the list */
/*      if (! strcmp (data[index+6], "Y")) {*/
/* added support for removing duplicates.
      duplicate = 0;
      for (cur_mem = set_head; 
                        cur_mem != (struct PDMbom_member *) NULL; 
                             cur_mem = cur_mem->next) {
_PDMdebug (fn, 
"Checking ==>> cat_no[%d] item[%d] \n", cat_no, item_no);
        if ( (cur_mem->cat_no == cat_no) &&
                (cur_mem->item_no == item_no) ) {
_PDMdebug (fn, 
"***Aha! Found a duplicate!! ==>> cat_no[%d] item[%d] \n", cat_no, item_no);

               duplicate = 1;
               break;
               }
        }
    _PDMdebug (fn, "duplicate [%d]\n", duplicate);
*/
/* added support for checking p_explode flag...
    if set to N or n then do not look for its children...*/
      if ((duplicate == 0) && 
          ( (strcmp (data[index+7], "N")) || (strcmp (data[index+7], "n")))) {
/* added support for checking p_incbom flag...
    if set to Y or y then include it in the bomlist...*/
      if ( (!strcmp (data[index+15], "Y")) 
               || (!strcmp (data[index+15], "y"))
               || (!strcmp (data[index+15], "B")) 
               || (!strcmp (data[index+15], "b"))  ) {
      new_node = (struct PDMbom_member *) NULL; 
      new_node = (struct PDMbom_member *)calloc (1, 
                         sizeof (struct PDMbom_member));
      if (new_node == (struct PDMbom_member *) NULL)
      {
        _PDMdebug (fn, "Allocate %d  failed\n", 
                        sizeof (struct PDMbom_member));
        return (NFM_E_MALLOC);
      }
      new_node->level = curr_level;
      new_node->flag = 4;
      new_node->citno = atol(data[index]);
      new_node->item_no = atol (data[index+4]);
      new_node->cat_no = atol (data[index+3]);
        strncpy (new_node->type, data[index+5], 2);
      _PDMdebug (fn, "new_node->type's strlen = %d\n", strlen (new_node->type));
/* stuff to be added ...*/
      
      _PDMget_double_from_buf_val (data[index+9], &doub);
      _PDMdebug (fn, "doub[%f]\n", doub);
/*      new_node-> quantity = doub;*/
      /*new_node-> quantity = atol (data[index+9]) ;*/
      new_node-> tagno  = atol (data[index+13]);
      new_node-> pdcno = atol (data[index+20]);
      new_node-> childno = atol (data[index+10]);
      strcpy (new_node->attached, data[index+6]);
      strcpy (new_node->history, data[index+19]);
      strcpy (new_node->orient, data[index+8]);
      strcpy (new_node->usageid, data[index+12]);
      strcpy (new_node->viewid , data[index+11]);
      strcpy (new_node->alttagno, data[index+14]);
      strcpy (new_node->incbom , data[index+15]);
      strcpy (new_node->explode, data[index+7]);;
      strcpy (new_node->cat_name, data[index+16]);
      strcpy (new_node->item_name, data[index+17]);
      strcpy (new_node->item_rev, data[index+18]);
      strcpy (new_node->co_filename , data[index+21]);
      new_node->pcat_no = atol (data[index+1]);
      new_node->pitem_no = atol (data[index+2]);
      set_end->next = new_node;
      set_end = new_node;
      (*num_members) ++; 
      (members_list2+count2)->cat_no = new_node->cat_no;
      (members_list2+count2)->item_no = new_node->item_no;
      strncpy ((members_list2+count2)->type, new_node->type, 2);
      /* strncpy ((members_list+count2)->type, new_node->type, 2);*/
      count2 ++;
   _PDMprint_bommember ("new_node", new_node);
      }
    else _PDMdebug (fn, "Did not include mem[%s][%s] (p_incbom = %s)\n", 
                             data[index+16], data[index+17], data[index+15]);
     }
/*    }*/
  }

  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    _PDMdebug (fn, "MEMclose (list of members from nfmsetcit) 0x%.8x\n", 
                status);
    return (status);
  }
  curr_level++;
/* start recursion */
  if (count2 && curr_level > level) {
    status = PDMretrieve_members_for_bom (members_list2, count2, level+1, 
                            curr_level, set_head, set_end, num_members);
    if (status != PDM_S_SUCCESS)
    {
      free (members_list2);
      _PDMdebug (fn, "PDMretrieve_bom_members 0x%.8x\n", status);
      return (status);
    }
  }

  free (members_list2);
  _PDMdebug ( fn, "EXIT: 0x%.8x\n", PDM_S_SUCCESS );
  return (PDM_S_SUCCESS);
}




int PDMget_bom_members (catno, partno, level, 
                                       set_head, set_end, nch)
int	catno, partno;
int	level, *nch;
struct	PDMbom_member **set_head, **set_end;
{
  char		*fn = "PDMget_bom_members";
  MEMptr	list = NULL;
  long		status;
  int		nchildren;
  struct	NFMmembers	*parent_struct;
  struct	PDMbom_member *mem;
  struct	PDMbom_member *head, *end;
  extern        long PDMdfs_retrieve_members_for_bom();

    _PDMdebug ("ENTER", "%s\n", fn);
    _PDMdebug (fn, "catno = %d, partno = %d, level = %d, nchildren = %d\n", 
    catno, partno, level, nchildren);


  /* load the struct with 1st level children_info */

  head = end = (struct PDMbom_member *) calloc (1, 
                               sizeof (struct PDMbom_member));

  parent_struct = (struct NFMmembers *) calloc (1, 
                                   sizeof (struct NFMmembers));
  if (head == (struct PDMbom_member *) NULL ||
      parent_struct == (struct NFMmembers *) NULL) {
    MEMclose (&list);
    NFMrollback_transaction (0);
    _PDMdebug (fn, "Allocating %d failed \n", head?
                (list->rows *sizeof(struct NFMmembers)):
                sizeof (struct PDMbom_member));
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


/*
        status = PDMretrieve_members_for_bom (parent_struct, 1, level, 1, 
                                       head, end, &nchildren);

          if ( (status != PDM_S_SUCCESS) && 
               (status != SQL_I_NO_ROWS_FOUND) ) {
            _PDMdebug (fn, 
              "PDMdfs_retrieve_members_for_bom  failed status %d\n", status);
            return (status);
        }
*/

    /* printing the linked list */

    _PDMdebug (fn, "list from PDMdfs_retrieve_bom_members\n");
    for ( mem = head; 
              mem != (struct PDMbom_member * ) NULL; 
                       mem = mem->next){
     _PDMprint_bommember ("mem", mem);
      }

    *nch = nchildren;
    *set_head = head;
    *set_end = end;
       
   MEMclose (&list);
   return (PDM_S_SUCCESS);
}



long PDMdfs_retrieve_members_for_bom (pcat_no, pitem_no, level, curr_level, 
                                            set_head, set_end, num_members)

int  level, curr_level, pcat_no, pitem_no;
struct PDMbom_member *set_head, *set_end;
int *num_members;
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


  char *fn="PDMdfs_retrieve_members_for_bom";
  char sql_str[2096]; /* reconsider this one later */
  char sql_str1[150];
  char **data;
  int x, index;
  int cat_no, item_no;
  int cyclic_attachment_in_bg_found;    
  MEMptr list=NULL;
  struct PDMbom_member *cat_head, *new_node, *cur_mem;
  extern long PDMdfs_retrieve_members_for_bom();
  long PDMbom_check_assy_cycle ();
/*  double  doub;*/

  _PDMdebug (fn, "ENTER\n");
  _PDMdebug (fn, "get children for cat[%d].item[%d] on level %d\n\
                  total members retrieved so far %d\n", 
                  pcat_no, pitem_no, level, *num_members);

  sprintf (sql_str, "%s %s %s %s %s %s", 
"SELECT nfmsetcit.n_citno, nfmsetcit.n_pcatalogno, nfmsetcit.n_pitemno, " , 
"nfmsetcit.n_ccatalogno, nfmsetcit.n_citemno, nfmsetcit.n_type, ", 
"pdmcit.p_attached, pdmcit.p_explode, p_orient, p_quantity, p_childno, ", 
"p_viewid, p_usageid, p_tagno, p_alttagno, p_incbom, n_catalogname, ", 
"n_itemname, n_itemrev, p_history, p_pdcno, n_cofilename FROM nfmsetcit, pdmcit ", 
"where pdmcit.p_citno = nfmsetcit.n_citno ");
 
 sprintf (sql_str1, 
    " and ( nfmsetcit.n_pcatalogno = %d and nfmsetcit.n_pitemno = %d ) ", 
                  pcat_no, pitem_no);

 strcat (sql_str, sql_str1);

  _PDMdebug ("exec qry", " %s\n", sql_str1);

  status = SQLquery (sql_str, &list, MEM_SIZE);
  if (status != SQL_S_SUCCESS) {
    MEMclose (&list);
    _PDMdebug (fn, "SQLquery 0x%.8x\n", status) ;
    _PDMdebug ("Could not find children", "[%s].[%s] on level %d\n", 
                  set_end->cat_name, set_end->item_name, level);
      _PDMdebug ("set_end", "[%lx]<>set_end->next[%lx]\n", 
                                       set_end, set_end->next);
    return (status);
    }

/*
        if (PDMdebug_on) {
                MEMprint_buffer("list from query", list, PDM_DEBUG_FILE);
        }
*/


  status = MEMbuild_array (list);
  if (status != MEM_S_SUCCESS) {
    MEMclose (&list);
    _PDMdebug ( fn, "MEMbuild_query (list) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
  } 

  _PDMdebug (fn, "# of rows retrieved by query --> %d\n", list->rows);

  cyclic_attachment_in_bg_found = 0;     
  data = (char **) list->data_ptr;
  for (x = 0, cat_head = set_head; x < list->rows; x++) {
  index = x * list->columns;
  cat_no = atol (data[index+3]);
  item_no = atol (data[index+4]);
  _PDMdebug ( fn, "index %d, row %d: %s %s %s %s %s %s %s\n", 
               index, x, data[index],  data[index+1], data[index+2], 
                data[index+3], data[index+4], data[index+5], data[index+6]);
/* if p_attached is Y then add the member to the list */
/* added support for checking p_incbom flag...
    if set to Y or y then include it in the bomlist...*/
      if ( (!strcmp (data[index+15], "Y")) 
               || (!strcmp (data[index+15], "y"))
               || (!strcmp (data[index+15], "B")) 
               || (!strcmp (data[index+15], "b"))  ) {
/* fix added to check whether each child with incstr set to no
   contains a potential cycle. MaC 060193 */
      if ( (!strcmp (data[index+15], "B")) 
               || (!strcmp (data[index+15], "b")) ) {
        cyclic_attachment_in_bg_found = 0;    
        _PDMdebug (fn, "Incstr is set to N so we need to check cyclic att.\n");
          status =  PDMbom_check_assy_cycle (atol (data[index+1]), 
                                             atol (data[index+2]), 
                                             atol (data[index+3]), 
                                             atol (data[index+4]));
          if (status != PDM_S_SUCCESS && 
                 status != NFM_E_SET_IN_LOOP ) {
              _PDMdebug (fn, "PDMbom_check_assy_cycle : status = <0x%.8x>\n", 
                                                                      status);
              _PDMdebug (fn, "ERROR a cyclic placement \n ");
              return (status);
            }
           else {
               if (status == NFM_E_SET_IN_LOOP) { 
                   cyclic_attachment_in_bg_found = 1;    
                   _PDMdebug (fn, "Cyclic attachment in bg part found\n");}
                   }
         }
   
      new_node = (struct PDMbom_member *) NULL; 
      new_node = (struct PDMbom_member *)calloc (1, 
                         sizeof (struct PDMbom_member));
      if (new_node == (struct PDMbom_member *) NULL)
      {
        _PDMdebug (fn, "Allocate %d  failed\n", 
                        sizeof (struct PDMbom_member));
        return (NFM_E_MALLOC);
      }
      new_node->level = curr_level;
      new_node->flag = 4;
      new_node->citno = atol(data[index]);
      new_node->item_no = atol (data[index+4]);
      new_node->cat_no = atol (data[index+3]);
        strncpy (new_node->type, data[index+5], 2);
/* stuff to be added ...*/
/*
      _PDMget_double_from_buf_val (data[index+9], &doub);
      _PDMdebug (fn, "doub[%f]\n", doub);
      new_node-> quantity = doub;
*/
      /*new_node-> quantity = atol (data[index+9]) ;*/
      strcpy (new_node-> quantity, data[index+9]);
      new_node-> tagno  = atol (data[index+13]);
      new_node-> pdcno = atol (data[index+20]);
      new_node-> childno = atol (data[index+10]);
      strcpy (new_node->attached, data[index+6]);
      strcpy (new_node->history, data[index+19]);
      strcpy (new_node->orient, data[index+8]);
      strcpy (new_node->usageid, data[index+12]);
      strcpy (new_node->viewid , data[index+11]);
      strcpy (new_node->alttagno, data[index+14]);
      strcpy (new_node->incbom , data[index+15]);
      strcpy (new_node->explode, data[index+7]);;
      strcpy (new_node->cat_name, data[index+16]);
      strcpy (new_node->item_name, data[index+17]);
      strcpy (new_node->item_rev, data[index+18]);
      strcpy (new_node->co_filename , data[index+21]);
      new_node->pcat_no = atol (data[index+1]);
      new_node->pitem_no = atol (data[index+2]);
      _PDMdebug ("set_end", "[%lx]<>set_end->next[%lx]\n", 
                                       (set_end), (set_end)->next);
      _PDMdebug ("set_end", "[%lx]\n", set_end);
      for ( cur_mem = set_end; 
              cur_mem->next != (struct PDMbom_member * ) NULL; 
                       cur_mem = cur_mem->next){
/*
      _PDMdebug ("set_end", "[%lx]<>set_end->next[%lx]\n", 
                                       cur_mem, cur_mem->next);
*/
      }
/*
      _PDMdebug ("set_end", "[%lx]\n", set_end);
      _PDMdebug ("cur_mem", "[%lx]\n", cur_mem);
      _PDMdebug ("new_node", "[%lx]\n", new_node);
*/
      set_end = cur_mem;
      set_end->next = new_node;
      set_end = new_node;
      _PDMdebug ("set_end", "[%lx]\n", set_end);
      _PDMdebug ("printing addresses", "\n");
      for ( cur_mem = set_head; 
              cur_mem != (struct PDMbom_member * ) NULL; 
                       cur_mem = cur_mem->next){
/*      _PDMdebug ("cur_mem", "[%lx]<>cur_mem->next[%lx]\n", 
                                       cur_mem, cur_mem->next);*/
      }
      _PDMdebug ("printing values", "\n");
      for ( cur_mem = set_head; 
              cur_mem != (struct PDMbom_member * ) NULL; 
                       cur_mem = cur_mem->next){
      /*_PDMprint_bommember_info ("cur_mem", cur_mem);*/
      }
      (*num_members) ++; 
    /* added recursion for each member...*/
    if ((curr_level > level) && (curr_level < 50)){
/* added support for checking p_explode flag...
    if set to N or n then do not look for its children...*/
   if ( (!((!strcmp (data[index+7], "N")) || (!strcmp (data[index+7], "n"))))
         && (cyclic_attachment_in_bg_found == 0)) {
    _PDMdebug (fn, "Entering Recursion...\n");
        cyclic_attachment_in_bg_found = 0;
        status = PDMdfs_retrieve_members_for_bom (new_node->cat_no, 
                                              new_node->item_no, 
                                              level+1, 
                                              curr_level+1, 
                                              set_head, 
                                              set_end, 
                                              num_members);
        if ( (status != PDM_S_SUCCESS) && 
               (status != SQL_I_NO_ROWS_FOUND) ) {
              _PDMdebug (fn, "PDMdfs_retrieve_bom_members 0x%.8x\n", status);
              return (status);
                }
        if (status == SQL_I_NO_ROWS_FOUND ) {
          _PDMdebug (fn, "*** Leaf found for this branch..\n");
           }
        }
      }
     }
  }

  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS) {
    _PDMdebug (fn, "MEMclose (list of members from nfmsetcit) 0x%.8x\n", 
                status);
    return (status);
  }

  _PDMdebug ( fn, "EXIT: 0x%.8x\n", PDM_S_SUCCESS );
  return (PDM_S_SUCCESS);
}



long PDMbom_check_assy_cycle (p_cat_no, p_item_no, 
                                        c_cat_no, c_item_no)
long     p_cat_no, p_item_no;
long     c_cat_no, c_item_no;
{
      static char *fn = "PDMbom_check_assy_cycle" ;
      MEMptr   list = NULL, p_list = NULL;
      char     *sql_str;
      char     **data;
 /*     char     value [100];*/
      long     x, count;
      long PDMbom_check_ancestor_loop ();

      _PDMdebug (fn, "ENTER\n");
      _PDMdebug (fn, 
         "PC No = <%d> : PI No = <%d> : CC No = <%d> : CI No = <%d> \n", 
		  p_cat_no, p_item_no, c_cat_no, c_item_no);

      if ((p_cat_no == c_cat_no) && (p_item_no == c_item_no))
       {
         _PDMdebug (fn, "Set in Loop : status = <0x%.8x>\n", 
		     NFM_E_SET_IN_LOOP);
         return (NFM_E_SET_IN_LOOP);
       }

      status = MEMopen (&list, 2 * MEM_SIZE);
      if (status != MEM_S_SUCCESS)
       {
         _PDMdebug (fn, "MEM Open : status = <0x%.8x>\n", status);
         return (NFM_E_MEM);
       }

      status = MEMwrite_format (list, "cat_no", "integer");
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&list);
         _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", 
		     status);
         return (NFM_E_MEM);
       }

      status = MEMwrite_format (list, "item_no", "integer");
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&list);
         _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", 
		     status);
         return (NFM_E_MEM);
       }

      status = MEMwrite_format (list, "flag", "char(1)");
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&list);
         _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", 
		     status);
         return (NFM_E_MEM);
       }

      sql_str = (char *) malloc (2 * MEM_SIZE);
      if (! sql_str)
       {
         MEMclose (&list);
         _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n", 
		     NFM_E_MALLOC);
         return (NFM_E_MALLOC);
       }
      sql_str[0] = '\0';
      
      sprintf (sql_str, "%d\1%d\1\1", c_cat_no, c_item_no);

      status = MEMwrite (list, sql_str);
      if (status != MEM_S_SUCCESS)
       {
         free (sql_str);
         MEMclose (&list);
         _PDMdebug (fn, "MEM Write : status = <0x%.8x>\n", status);
         return (NFM_E_MEM);
       }

      sql_str[0] = '\0';
      sprintf (sql_str, "%d\1%d\1\1", p_cat_no, p_item_no);

      status = MEMwrite (list, sql_str);
      if (status != MEM_S_SUCCESS)
       {
         free (sql_str);
         MEMclose (&list);
         _PDMdebug (fn, "MEM Write : status = <0x%.8x>\n", status);
         return (NFM_E_MEM);
       }

     /* modified to hard code "n_pcatalogno and n_pitemno" instead of 
        getting it from the buffer */
     /* query is 
         select n_pcatalogno, n_pitemno from nfmsetcit, pdmcit where
         n_ccatalogno = p_cat_no and n_citemno = p_item_no and
         pdmcit.n_citno = nfmsetcit.n_citno and (p_incbom = 'Y' or
         p_incbom = 'A' "  */

      sql_str[0] = '\0';

/*
      sprintf (sql_str, "%s %s %s (%s %d AND %s %d ) ", 
       " SELECT n_pcatalogno, n_pitemno FROM nfmsetcit, pdmcit WHERE", 
       " pdmcit.p_citno = nfmsetcit.n_citno AND ", 
       " ( p_incbom = 'Y' OR p_incbom = 'A' ) AND ", 
       " n_ccatalogno = ", p_cat_no, 
       " n_citemno = ", p_item_no);

*/
      sprintf (sql_str, "%s %s (%s %d AND %s %d ) ", 
       " SELECT n_pcatalogno, n_pitemno FROM nfmsetcit, pdmcit WHERE", 
       " pdmcit.p_citno = nfmsetcit.n_citno AND ", 
       " n_ccatalogno = ", p_cat_no, 
       " n_citemno = ", p_item_no);


      status = SQLquery (sql_str, &p_list, MEM_SIZE);
      if ((status != SQL_S_SUCCESS) && 
          ((status) != SQL_I_NO_ROWS_FOUND))
       {
         free (sql_str);
         MEMclose (&list);
         MEMclose (&p_list);
         _PDMdebug (fn, "SQL Stmt Failed : status = <0x%.8x>\n", 
		     status);
         return ( NFM_E_SQL_QUERY);
       }

      free (sql_str);

      status = MEMbuild_array (p_list);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&list);
         MEMclose (&p_list);
         _PDMdebug (fn, "MEM Build Array : status = <0x%.8x>\n", 
		     status);
         return (NFM_E_MEM);
       }

      data = (char **) p_list -> data_ptr;

      for (x = 0; x < p_list -> rows; ++x)
       {
         count = p_list -> columns * x;
/*
         if ((!strcmp (data[count + 2], "Y") 
                     || (!strcmp (data[count + 2], "A")) ) {
*/

         status = PDMbom_check_ancestor_loop  (list, 
                  atol (data [count]), atol (data [count + 1]));
         if (status != NFM_S_SUCCESS)
          {
            MEMclose (&list);
            MEMclose (&p_list);
            _PDMdebug (fn, "Chk Par In Loop : status = <0x%.8x>\n", 
            status);
            return (status);
          }
/*
         }
*/
       }

      status = MEMclose (&p_list);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&p_list);
         _PDMdebug (fn, "MEM CLose : status = <0x%.8x>\n", status);
         return (NFM_E_MEM);
       }

      status = MEMclose (&list);
      if (status != MEM_S_SUCCESS)
       {
         _PDMdebug (fn, "MEM CLose : status = <0x%.8x>\n", status);
         return (NFM_E_MEM);
       }
 
      _PDMdebug (fn, "SUCCESSFUL : status = <0x%.8x>\n", 
      NFM_S_SUCCESS);
      return (PDM_S_SUCCESS); 
}

long PDMbom_check_ancestor_loop (par_list, cat_no, item_no)
MEMptr  par_list;
int    cat_no, item_no;
{
     static char *fn = "PDMbom_check_ancestor_loop " ;
      char     **data;
      long     x, count, row_no;
      char     *sql_str;
 /*     char     value [100];*/
      MEMptr   list = NULL;

      _PDMdebug (fn, "ENTER\n");
      _PDMdebug ("Checking", "Cat No = <%d> : Part No = <%d>\n", 
                                                      cat_no, item_no);

      status = MEMbuild_array (par_list);
      if (status != MEM_S_SUCCESS)
       {
         _PDMdebug (fn, "MEM Build Array : status = <0x%.8x>\n", 
		     status);
         return (NFM_E_MEM);            
       }

   if (PDMdebug_on)
      MEMprint_buffer ("par_list in bom check par loop", par_list, 
                                               PDM_DEBUG_FILE);
 
      data = (char **) par_list -> data_ptr;

      for (x = 0; x < par_list -> rows; ++x)
       {
         count = par_list -> columns * x;

         if (strcmp (data [count + 2], "N"))
          {
           _PDMdebug ("Checking", "[%s].[%s]...\n", data[count], data[count+1]);
            if ((atol (data [count]) == cat_no) &&
                (atol (data [count + 1]) == item_no))
             {
               _PDMdebug (fn, "Set In Loop : status = <0x%.8x>\n", 
			   NFM_E_SET_IN_LOOP);
               return (NFM_E_SET_IN_LOOP);            
               }
          }
       }

      sql_str = (char *) malloc (2 * MEM_SIZE);
      if (! sql_str)
       {
         _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n", 
		     NFM_E_MALLOC);
         return (NFM_E_MALLOC);            
       }
      sql_str[0] = '\0';

      sprintf (sql_str, "%d\1%d\1", cat_no, item_no);
 
      status = MEMwrite (par_list, sql_str);
      if (status != MEM_S_SUCCESS)
       {
         free (sql_str);
         _PDMdebug (fn, "MEM Write : status = <0x%.8x>\n", status);
         return (NFM_E_MEM);            
       }

      row_no = par_list -> rows;

      sql_str[0] = '\0';
/*
      sprintf (sql_str, "%s %s %s (%s %d AND %s %d ) ", 
       " SELECT n_pcatalogno, n_pitemno FROM nfmsetcit, pdmcit WHERE", 
       " pdmcit.p_citno = nfmsetcit.n_citno AND ", 
       " ( p_incbom = 'Y' OR p_incbom = 'A' ) AND ", 
       " n_ccatalogno = ", cat_no, 
       " n_citemno = ", item_no);
*/
      sprintf (sql_str, "%s %s (%s %d AND %s %d ) ", 
       " SELECT n_pcatalogno, n_pitemno FROM nfmsetcit, pdmcit WHERE", 
       " pdmcit.p_citno = nfmsetcit.n_citno AND ", 
       " n_ccatalogno = ", cat_no, 
       " n_citemno = ", item_no);

      status = SQLquery (sql_str, &list, MEM_SIZE);
      if ((status != SQL_S_SUCCESS) && 
          ((status) != SQL_I_NO_ROWS_FOUND))
       {
         free (sql_str);
         MEMclose (&list);
         _PDMdebug (fn, "SQL Stmt Failed : status = <0x%.8x>\n", 
		     status);
         return ( NFM_E_SQL_QUERY);
       }

      free (sql_str);

    if (status == SQL_S_SUCCESS) {
      status = MEMbuild_array (list);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&list);
         _PDMdebug (fn, "MEM Build Array : status = <0x%.8x>\n", 
		     status);
         return (NFM_E_MEM);
       }

     if (PDMdebug_on) {
      MEMprint_buffer ("list in bom check par loop", list, 
                                               PDM_DEBUG_FILE);
      }
 

      data = (char **) list -> data_ptr;

      for (x = 0; x < list -> rows; ++x)
       {
         count = list -> columns * x;

         status = PDMbom_check_ancestor_loop  (par_list, 
                         atol (data [count]), atol (data [count + 1]));
         if (status != NFM_S_SUCCESS)
          {
            MEMclose (&list);
            _PDMdebug (fn, "Chk Par In Loop : status = <0x%.8x>\n", 
            status);
            return (status);
          }
       }
     }

      status = MEMbuild_array (par_list);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&list);
         _PDMdebug (fn, "MEM Build Array : status = <0x%.8x>\n", 
		     status);
         return (NFM_E_MEM);
       }

if (PDMdebug_on) {
      MEMprint_buffer ("par_list after qry", par_list, 
                                               PDM_DEBUG_FILE);
        }
      row_no = par_list->rows;
      status = MEMwrite_data (par_list, "N", row_no, 3);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&list);
         _PDMdebug (fn, "MEM Wr Data : status = <0x%.8x>\n", 
		     status);
         return (NFM_E_MEM);            
       }

      status = MEMclose (&list);
      if (status != MEM_S_SUCCESS)
       {
         _PDMdebug (fn, "MEM Close : status = <0x%.8x>\n", 
		     status);
         return (NFM_E_MEM);            
       }
      
      _PDMdebug (fn, "SUCCESSFUL : status = <0x%.8x>\n", 
		  PDM_S_SUCCESS);
      return (PDM_S_SUCCESS); 
}





long PDMGetAssyStrForSummBom (pcat_no, pitem_no, level, curr_level, 
                                            set_head, set_end, num_members)

int  level, curr_level, pcat_no, pitem_no;
struct PDMbom_member *set_head, *set_end;
int *num_members;
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
      02/10/94 MaC Added code to remove duplicate CITnos to 
                   help generate Eng BOM Report
  ***/


  char *fn="PDMGetAssyStrForSummBom";
  char sql_str[2096]; /* reconsider this one later */
  char sql_str1[150];
  char **data;
  int x, index;
  int xindex, y, yindex;
  int cat_no, item_no;
  int cyclic_attachment_in_bg_found;    
  MEMptr list=NULL;
  struct PDMbom_member *cat_head, *new_node, *cur_mem;
  extern long PDMdfs_retrieve_members_for_bom();
  long PDMbom_check_assy_cycle ();

  _PDMdebug (fn, "ENTER\n");
  _PDMdebug (fn, "get children for cat[%d].item[%d] on level %d\n\
                  total members retrieved so far %d\n", 
                  pcat_no, pitem_no, level, *num_members);

  sprintf (sql_str, "%s %s %s %s %s %s", 
   "SELECT nfmsetcit.n_citno, nfmsetcit.n_pcatalogno, nfmsetcit.n_pitemno, " , 
   "nfmsetcit.n_ccatalogno, nfmsetcit.n_citemno, nfmsetcit.n_type, ", 
   "pdmcit.p_attached, pdmcit.p_explode, p_orient, p_quantity, p_childno, ", 
   "p_viewid, p_usageid, p_tagno, p_alttagno, p_incbom, n_catalogname, ", 
   "n_itemname, n_itemrev, p_history, p_pdcno, n_cofilename FROM nfmsetcit, pdmcit ", 
   "where pdmcit.p_citno = nfmsetcit.n_citno ");
 
 sprintf (sql_str1, 
    " and ( nfmsetcit.n_pcatalogno = %d and nfmsetcit.n_pitemno = %d ) ", 
                  pcat_no, pitem_no);

 strcat (sql_str, sql_str1);

  _PDMdebug ("exec qry", " %s\n", sql_str1);

  status = SQLquery (sql_str, &list, MEM_SIZE);
  if (status != SQL_S_SUCCESS) {
    MEMclose (&list);
    _PDMdebug (fn, "SQLquery 0x%.8x\n", status) ;
    _PDMdebug ("Could not find children", "[%s].[%s] on level %d\n", 
                  set_end->cat_name, set_end->item_name, level);
      _PDMdebug ("set_end", "[%lx]<>set_end->next[%lx]\n", 
                                       set_end, set_end->next);
    return (status);
    }

/*
        if (PDMdebug_on) {
                MEMprint_buffer("list from query", list, PDM_DEBUG_FILE);
        }
*/


  status = MEMbuild_array (list);
  if (status != MEM_S_SUCCESS) {
    MEMclose (&list);
    _PDMdebug ( fn, "MEMbuild_query (list) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
  } 

  data = (char **) list->data_ptr;

  _PDMdebug (fn, "# of rows retrieved by query --> %d\n", list->rows);

/*****************************************************************/
    /* Added to eliminate duplicates in the buffer..*/

  for (x = 0; x < list->rows; x++) {
    xindex = x * list->columns;
    _PDMdebug (fn, "Checking Cit# [%s] on row [%d] \n", data[xindex], x);
    if (atol (data[xindex]) != 0) {
      for (y = x+1; y < list->rows; y++) {
        yindex = y * list->columns;
        if (!strcmp (data[xindex],  data[yindex])) {
          _PDMdebug (fn, "Cit# [%s] on row [%d] is Duplicate\n", 
                                                     data[yindex], y);
          status = MEMwrite_data (list, "0", y + 1, 1);
          if (status != MEM_S_SUCCESS) {
            MEMclose (&list);
            _PDMdebug ( fn, "MEMwrite_data (list) 0x%.8x\n", NFM_E_MEM );
            return (NFM_E_MEM);
           } 
         }
       }
     }
   }

  if (PDMdebug_on) {
                MEMprint_buffer("list from query", list, PDM_DEBUG_FILE);
  }

  data = (char **) list->data_ptr;
/*****************************************************************/

  cyclic_attachment_in_bg_found = 0;     
  data = (char **) list->data_ptr;
  for (x = 0, cat_head = set_head; x < list->rows; x++) {
  index = x * list->columns;
  if (atol (data[index]) != 0) {
  cat_no = atol (data[index+3]);
  item_no = atol (data[index+4]);
  _PDMdebug ( fn, "index %d, row %d: %s %s %s %s %s %s %s\n", 
               index, x, data[index],  data[index+1], data[index+2], 
                data[index+3], data[index+4], data[index+5], data[index+6]);
/* if p_attached is Y then add the member to the list */
/* added support for checking p_incbom flag...
    if set to Y or y then include it in the bomlist...*/
      if ( (!strcmp (data[index+15], "Y")) 
               || (!strcmp (data[index+15], "y"))
               || (!strcmp (data[index+15], "B")) 
               || (!strcmp (data[index+15], "b"))  ) {
/* fix added to check whether each child with incstr set to no
   contains a potential cycle. MaC 060193 */
      if ( (!strcmp (data[index+15], "B")) 
               || (!strcmp (data[index+15], "b")) ) {
        cyclic_attachment_in_bg_found = 0;    
        _PDMdebug (fn, "Incstr is set to N so we need to check cyclic att.\n");
          status =  PDMbom_check_assy_cycle (atol (data[index+1]), 
                                             atol (data[index+2]), 
                                             atol (data[index+3]), 
                                             atol (data[index+4]));
          if (status != PDM_S_SUCCESS && 
                 status != NFM_E_SET_IN_LOOP ) {
              _PDMdebug (fn, "PDMbom_check_assy_cycle : status = <0x%.8x>\n", 
                                                                      status);
              _PDMdebug (fn, "ERROR a cyclic placement \n ");
              return (status);
            }
           else {
               if (status == NFM_E_SET_IN_LOOP) { 
                   cyclic_attachment_in_bg_found = 1;    
                   _PDMdebug (fn, "Cyclic attachment in bg part found\n");}
                   }
         }
   
      new_node = (struct PDMbom_member *) NULL; 
      new_node = (struct PDMbom_member *)calloc (1, 
                         sizeof (struct PDMbom_member));
      if (new_node == (struct PDMbom_member *) NULL)
      {
        _PDMdebug (fn, "Allocate %d  failed\n", 
                        sizeof (struct PDMbom_member));
        return (NFM_E_MALLOC);
      }
      new_node->level = curr_level;
      new_node->flag = 4;
      new_node->citno = atol(data[index]);
      new_node->item_no = atol (data[index+4]);
      new_node->cat_no = atol (data[index+3]);
        strncpy (new_node->type, data[index+5], 2);
      strcpy (new_node-> quantity, data[index+9]);
      new_node-> tagno  = atol (data[index+13]);
      new_node-> pdcno = atol (data[index+20]);
      new_node-> childno = atol (data[index+10]);
      strcpy (new_node->attached, data[index+6]);
      strcpy (new_node->history, data[index+19]);
      strcpy (new_node->orient, data[index+8]);
      strcpy (new_node->usageid, data[index+12]);
      strcpy (new_node->viewid , data[index+11]);
      strcpy (new_node->alttagno, data[index+14]);
      strcpy (new_node->incbom , data[index+15]);
      strcpy (new_node->explode, data[index+7]);;
      strcpy (new_node->cat_name, data[index+16]);
      strcpy (new_node->item_name, data[index+17]);
      strcpy (new_node->item_rev, data[index+18]);
      strcpy (new_node->co_filename , data[index+21]);
      new_node->pcat_no = atol (data[index+1]);
      new_node->pitem_no = atol (data[index+2]);
      _PDMdebug ("set_end", "[%lx]<>set_end->next[%lx]\n", 
                                       (set_end), (set_end)->next);
      _PDMdebug ("set_end", "[%lx]\n", set_end);
      for ( cur_mem = set_end; 
              cur_mem->next != (struct PDMbom_member * ) NULL; 
                       cur_mem = cur_mem->next){
      }
      set_end = cur_mem;
      set_end->next = new_node;
      set_end = new_node;
      _PDMdebug ("set_end", "[%lx]\n", set_end);
      _PDMdebug ("printing addresses", "\n");
      for ( cur_mem = set_head; 
              cur_mem != (struct PDMbom_member * ) NULL; 
                       cur_mem = cur_mem->next){
      }
      _PDMdebug ("printing values", "\n");
      for ( cur_mem = set_head; 
              cur_mem != (struct PDMbom_member * ) NULL; 
                       cur_mem = cur_mem->next){
      }
      (*num_members) ++; 
    /* added recursion for each member...*/
    if ((curr_level > level) && (curr_level < 50)){
/* added support for checking p_explode flag...
    if set to N or n then do not look for its children...*/
   if ( (!((!strcmp (data[index+7], "N")) || (!strcmp (data[index+7], "n"))))
         && (cyclic_attachment_in_bg_found == 0)) {
    _PDMdebug (fn, "Entering Recursion...\n");
        cyclic_attachment_in_bg_found = 0;
/*
        status = PDMdfs_retrieve_members_for_bom (new_node->cat_no, 
                                              new_node->item_no, 
                                              level+1, 
                                              curr_level+1, 
                                              set_head, 
                                              set_end, 
                                              num_members);
*/
        status = PDMGetAssyStrForSummBom ( (int) new_node->cat_no, 
                                           (int) new_node->item_no, 
                                                 level+1, 
                                                 curr_level+1, 
                                                 set_head, 
                                                 set_end, 
                                                 num_members);
        if ( (status != PDM_S_SUCCESS) && 
               (status != SQL_I_NO_ROWS_FOUND) ) {
              _PDMdebug (fn, "PDMdfs_retrieve_bom_members 0x%.8x\n", status);
              return (status);
                }
        if (status == SQL_I_NO_ROWS_FOUND ) {
          _PDMdebug (fn, "*** Leaf found for this branch..\n");
           }
        }
      }
     }
    }
  }

  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS) {
    _PDMdebug (fn, "MEMclose (list of members from nfmsetcit) 0x%.8x\n", 
                status);
    return (status);
  }

  _PDMdebug ( fn, "EXIT: 0x%.8x\n", PDM_S_SUCCESS );
  return (PDM_S_SUCCESS);
}



int PDMGetAssyForEngBom (catno, partno, level, 
                                       set_head, set_end, nch)
int	catno, partno;
int	level, *nch;
struct	PDMbom_member **set_head, **set_end;
{
  char		*fn = "PDMGetAssyForEngBom";
  MEMptr	list = NULL;
  long		status;
  int		nchildren;
  struct	NFMmembers	*parent_struct;
  struct	PDMbom_member *head, *end;
  extern        long PDMdfs_retrieve_members_for_bom();

    _PDMdebug ("ENTER", "%s\n", fn);
    _PDMdebug (fn, "catno = %d, partno = %d, level = %d, nchildren = %d\n", 
    catno, partno, level, nchildren);


  /* load the struct with 1st level children_info */

  head = end = (struct PDMbom_member *) calloc (1, 
                               sizeof (struct PDMbom_member));

  parent_struct = (struct NFMmembers *) calloc (1, 
                                   sizeof (struct NFMmembers));
  if (head == (struct PDMbom_member *) NULL ||
      parent_struct == (struct NFMmembers *) NULL) {
    MEMclose (&list);
    NFMrollback_transaction (0);
    _PDMdebug (fn, "Allocating %d failed \n", head?
                (list->rows *sizeof(struct NFMmembers)):
                sizeof (struct PDMbom_member));
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

        status = PDMGetAssyStrForSummBom  (catno, partno, level, 1, 
                                                    head, end, &nchildren);

          if ( (status != PDM_S_SUCCESS) && 
               (status != SQL_I_NO_ROWS_FOUND) ) {
            _PDMdebug (fn, 
              "PDMdfs_retrieve_members_for_bom  failed status %d\n", status);
            return (status);
        }

    /* printing the linked list */

/*
    _PDMdebug (fn, "list from PDMdfs_retrieve_bom_members\n");
    for ( mem = head; 
              mem != (struct PDMbom_member * ) NULL; 
                       mem = mem->next){
     _PDMprint_bommember ("mem", mem);
      }
*/

    *nch = nchildren;
    *set_head = head;
    *set_end = end;
       
   MEMclose (&list);
   return (PDM_S_SUCCESS);
}


