#include "machine.h"
#include "DEBUG.h"
#include "ERR.h"
#include "NFMerrordef.h"
#include "NFMitems.h"
#include "NFMitemfiles.h"
#include "MEMstruct.h"
#include "NFMfto_buf.h"

struct NFMitem_entry *NFMitem_files;
long freeNFMitem_files=1;


/***
  This file contains the following functions:

  NFMfree_item_file_information (item_file_list);
     This function will free the variable of type NFMitem_entry.

  NFMprint_item_file_information (item_file_list);
     This function will print out the item_file_list of type NFMitem_entry.

  NFMload_item_file_information (type, list, file_list, item_entry,
                                 set_members)
     This function will load the item and file information into the global
     variable.
***/

long NFMload_item_file_information (type, list, file_list,
                                    item_entry, set_members)
long type;   /* I: NFM_SET/NFM_ITEM */
MEMptr list; /* I: file(s) information from f_<catalog> */
MEMptr file_list; /* I: */
struct NFMitem_entry *item_entry; /* I: item information from <catalog> */
struct NFMset_member *set_members;/* I: set/member information from
                                        <catalog> */

{
  char *fname="NFMload_item_file_information";
  char **data, **data1, **column;
  int index, index1;
  int x, y;
  int i_cisano=-1, i_cosano=-1, i_fileno=-1, i_filenum=-1, i_cidate=-1, 
      i_codate=-1, i_cofilename=-1,
      i_cifilename=-1, i_fileversion=-1, i_catno=-1, i_itemno=-1, i_fileco=-1;
  long cur_item_no, cur_cat_no;
  struct NFMitem_entry *new_item, *cur_item;
  struct NFMfile_entry *new_file, *cur_file;
  struct NFMset_member *cur_set;
  long NFMprint_item_file_information ();

  _NFMdebug ((fname, "ENTER\n"));
  if (_NFMdebug_st.NFMdebug_on)
  {
    MEMprint_buffer ("list", list, _NFMdebug_st.NFMdebug_file);
    MEMprint_buffer ("file_list", file_list, _NFMdebug_st.NFMdebug_file);
  }

  column = (char **) list->column_ptr;

  /* find indexes */
  for (x = 0; x < list->columns; x ++)
  {
    if (!strcmp (column[x], "n_cisano"))
      i_cisano = x;
    else if (!strcmp (column[x], "n_cosano"))
      i_cosano = x;
    else if (!strcmp (column[x], "n_fileno"))
      i_fileno = x;
    else if (!strcmp (column[x], "n_filenum"))
      i_filenum = x;
    else if (!strcmp (column[x], "n_cidate"))
      i_cidate = x;
    else if (!strcmp (column[x], "n_codate"))
      i_codate = x;
    else if (!strcmp (column[x], "n_cofilename"))
      i_cofilename = x;
    else if (!strcmp (column[x], "n_cifilename"))
      i_cifilename = x;
    else if (!strcmp (column[x], "n_fileversion"))
      i_fileversion = x;
    else if (!strcmp (column[x], "n_catno"))
      i_catno = x;
    else if (!strcmp (column[x], "n_itemnum"))
      i_itemno = x;
    else if (!strcmp (column[x], "n_fileco"))
      i_fileco = x;
  }
  
  _NFMdebug ((fname, "i_cisano = %d, i_cosano =%d\n\
             i_fileno = %d, i_filenum = %d \n\
             i_cidate = %d, i_codate = %d \n\
             i_cofilename = %d, i_cifilename = %d \n\
             i_fileversion = %d, i_catno = %d \n\
             i_itemno = %d, i_fileco = %d \n",
             i_cisano, i_cosano, i_fileno, i_filenum, i_cidate, i_codate, 
             i_cofilename, i_cifilename, i_fileversion, i_catno, 
             i_itemno, i_fileco));

  if (type == NFM_ITEM)
  {
    _NFMdebug ((fname, "this is item operation\n"));
    /* item information */
    NFMitem_files = (struct NFMitem_entry *) calloc (1, 
                                     sizeof (struct NFMitem_entry));
    strcpy (NFMitem_files->cat_name, item_entry->cat_name);
    NFMitem_files->cat_no = item_entry->cat_no;
    strcpy (NFMitem_files->item_name, item_entry->item_name);
    strcpy (NFMitem_files->item_rev, item_entry->item_rev);
    NFMitem_files->item_no = item_entry->item_no; 
    strcpy (NFMitem_files->status, item_entry->status);
    strcpy (NFMitem_files->member_type, "P");
    NFMitem_files->files = list->rows;

    /* 1st file information */
    NFMitem_files->next_file = cur_file = (struct NFMfile_entry *) calloc (1,
                                  sizeof (struct NFMfile_entry));
    data = (char **) list->data_ptr;
    if (file_list != (MEMptr) NULL)
      data1 = (char **) file_list->data_ptr;
    else
      data1 = (char **) NULL;

    if (i_cisano > -1)
      cur_file->cisano = atol (data[i_cisano]);
    else
      cur_file->cisano = 0;

    if ((i_cosano > -1) && strlen (data[i_cosano]))
      cur_file->cosano = atol (data[i_cosano]);
    else
      cur_file->cosano = atol (data1[FTO_SANO]);

/* 12/8/92 - KT - changed 'fileno' to 'file_no'
    cur_file->fileno = atol (data[i_fileno]);
*/
    cur_file->file_no = atol (data[i_fileno]);
    cur_file->filenum = atol (data[i_filenum]);
    strcpy (cur_file->cidate, data[i_cidate]);
    strcpy (cur_file->codate, data[i_codate]);
    strcpy (cur_file->cofilename, data[i_cofilename]);
    if (strlen (data[i_cifilename]))
    {
      strcpy (cur_file->cifilename, data[i_cifilename]);
    }
    else
    {
      if (data1)
        strcpy (cur_file->cifilename, data1[file_list->columns+FTO_CIFILENAME]);
      else
        strcpy (cur_file->cifilename, "");
    }
    cur_file->fileversion = atol (data[i_fileversion]);

    /* REMEMBER to skip 1st one. */

    if (data1)
      strcpy (cur_file->nfs, data1[file_list->columns + FTO_NFS]);
    else
      strcpy (cur_file->nfs, "");
      
    if (data1)
      cur_file->transfer_status = atol(data1[file_list->columns + FTO_STATUS1]);
    else
      cur_file->transfer_status = 0;

    /* rest of files information */
    for (x = 1; x < list->rows; x ++)
    {
      index = x * list->columns;
      index1 = (x+1) * file_list->columns;

      new_file = (struct NFMfile_entry *) calloc (1,
                                  sizeof (struct NFMfile_entry));
      new_file->cisano = atol (data[index+i_cisano]);
      if ((i_cosano > -1) && strlen (data[index+i_cosano]))
      {
        new_file->cosano = atol (data[index+i_cosano]);
      }
      else
      {
        if (data1)
          new_file->cosano = atol (data1[FTO_SANO]);
        else
          new_file->cosano = 0;
      }

/* 12/8/92 - KT - changed 'fileno' to 'file_no'
      new_file->fileno = atol (data[index+i_fileno]);
*/
      new_file->file_no = atol (data[index+i_fileno]);
      new_file->filenum = atol (data[index+i_filenum]);
      strcpy (new_file->cidate, data[index+i_cidate]);
      strcpy (new_file->codate, data[index+i_codate]);
      strcpy (new_file->cofilename, data[index+i_cofilename]);
      if (strlen (data[index+i_cifilename]))
      {
        strcpy (new_file->cifilename, data[index+i_cifilename]);
      }
      else
      {
        if (data1)
          strcpy (new_file->cifilename, data1[index1+FTO_CIFILENAME]);
        else
          strcpy (new_file->cifilename, "");
      }
      new_file->fileversion = atol (data[index+i_fileversion]);
  
      if (data1)
      {
        strcpy (new_file->nfs, data1[index1+FTO_NFS]);
        new_file->transfer_status = atol (data1[index1+FTO_STATUS1]);
      }
      else
      {
        strcpy (new_file->nfs, "");
        new_file->transfer_status = 0;
      }
  
      cur_file->next_file = new_file;
      cur_file = cur_file->next_file;
    }   
  }
  else if (type == NFM_SET)
  {
    _NFMdebug ((fname, "this is set operation\n"));
    cur_set = set_members;
    /* item information */
    cur_item = NFMitem_files = (struct NFMitem_entry *) calloc (1, 
                                     sizeof (struct NFMitem_entry));
    strcpy (NFMitem_files->cat_name, cur_set->cat_name);
    cur_cat_no = NFMitem_files->cat_no = cur_set->cat_no;
    strcpy (NFMitem_files->item_name, cur_set->item_name);
    strcpy (NFMitem_files->item_rev, cur_set->item_rev);
    cur_item_no = NFMitem_files->item_no = cur_set->item_no; 
    strcpy (NFMitem_files->status, cur_set->file_status);
    strcpy (NFMitem_files->member_type, cur_set->type);
    NFMitem_files->files = 0;

    data = (char **) list->data_ptr;
    data1 = (char **) file_list->data_ptr;

    /* items and files information */
    for (x = 0, y = 1; (x < list->rows) && (y < file_list->rows);)
    {
      index = x * list->columns;
      index1 = y * file_list->columns;

      _NFMdebug ((fname, "May 14 , 1993\n"));

      if (cur_cat_no == atol(data[index+i_catno]) &&
          cur_item_no == atol(data[index+i_itemno]) )
      {

        new_file = (struct NFMfile_entry *) calloc (1,
                                  sizeof (struct NFMfile_entry));
        new_file->cisano = atol (data[index+i_cisano]);
        if ((i_cosano > -1) && strlen (data[index+i_cosano]))
        {
          new_file->cosano = atol (data[index+i_cosano]);
        }
        else
        {
          new_file->cosano = atol (data1[FTO_SANO]);
        }

/* 12/8/92 - KT - changed 'fileno' to 'file_no'
        new_file->fileno = atol (data[index+i_fileno]);
*/
        new_file->file_no = atol (data[index+i_fileno]);
        new_file->filenum = atol (data[index+i_filenum]);
        strcpy (new_file->cidate, data[index+i_cidate]);
        strcpy (new_file->codate, data[index+i_codate]);
        strcpy (new_file->cofilename, data[index+i_cofilename]);
        if (strlen (data[index+i_cifilename]))
        {
          strcpy (new_file->cifilename, data[index+i_cifilename]);
        }
        else
        {
          strcpy (new_file->cifilename, data1[index1+FTO_CIFILENAME]);
        }
        new_file->fileversion = atol (data[index+i_fileversion]);
        cur_item->files ++;
  
        if (strlen (data[index+i_fileco]))
        {
          strcpy (new_file->nfs, data1[index1+FTO_NFS]);
          new_file->transfer_status = atol (data1[index1+FTO_STATUS1]);
          y++;
        }
        if (cur_item->next_file == (struct NFMfile_entry *) NULL)
        {
          cur_item->next_file = cur_file = new_file;
        }
        else
        {
          cur_file->next_file = new_file;
          cur_file = cur_file->next_file;
        }
        x++;
      }
      else
      {
        cur_set = cur_set->next;
        new_item = (struct NFMitem_entry *) calloc (1, 
                                     sizeof (struct NFMitem_entry));
        strcpy (new_item->cat_name, cur_set->cat_name);
        cur_cat_no = new_item->cat_no = cur_set->cat_no;
        strcpy (new_item->item_name, cur_set->item_name);
        strcpy (new_item->item_rev, cur_set->item_rev);
        cur_item_no = new_item->item_no = cur_set->item_no; 
        strcpy (new_item->status, cur_set->file_status);
        strcpy (new_item->member_type, cur_set->type);
        new_item->files = 0;
   
        cur_item->next_item = new_item;
        cur_item = cur_item->next_item;  
      }
    }   
  }

  if (_NFMdebug_st.NFMdebug_on)
    NFMprint_item_file_information (NFMitem_files);

  _NFMdebug ((fname, "EXIT: successful 0x%.8x\n", NFM_S_SUCCESS));
  return (NFM_S_SUCCESS);
}


long NFMfree_item_file_information (item_file_list)

struct NFMitem_entry *item_file_list;

{

  char *fname="NFMfree_item_file_information";
  struct NFMitem_entry *item_head, *remove_item;
  struct NFMfile_entry *file_head, *remove_file;

  _NFMdebug ((fname, "ENTER: \n"));

  for (item_head = item_file_list; item_head != (struct NFMitem_entry *) NULL; )
  {
    _NFMdebug ((fname, "free cat[%s] item[%s.%s]\n",
               item_head->cat_name, item_head->item_name, item_head->item_rev));
    for (file_head = item_head->next_file; 
                                     file_head != (struct NFMfile_entry *) NULL; )
    {
/* 12/8/92 - KT - changed 'fileno' to 'file_no' */
      _NFMdebug ((fname, "free file information cofilename[%s] fileno[%d]..\n",
                  file_head->cofilename, file_head->file_no));
      remove_file = file_head;
      file_head = file_head->next_file;
      free (remove_file); 
    }

    remove_item = item_head;
    item_head = item_head->next_item;
    free (remove_item);
  }

  NFMitem_files = (struct NFMitem_entry *) NULL;

  _NFMdebug ((fname, "EXIT: 0x%.8x\n", NFM_S_SUCCESS));
  return (NFM_S_SUCCESS);
}

long NFMprint_item_file_information (item_file_list)

struct NFMitem_entry *item_file_list;

{

  char *fname="NFMprint_item_file_information";
  struct NFMitem_entry *item_head;
  struct NFMfile_entry *file_head;

  _NFMdebug ((fname, "ENTER: \n"));

  for (item_head = item_file_list; item_head != (struct NFMitem_entry *) NULL; )
  {
    _NFMdebug ((fname, 
              "cat[%s no %d] item[%s.%s no %d] [%d] files associated\n\
               member_type %s\n",
              item_head->cat_name, item_head->cat_no, item_head->item_name, 
              item_head->item_rev, item_head->item_no, item_head->files,
              item_head->member_type));
    for (file_head = item_head->next_file; 
                                     file_head != (struct NFMfile_entry *) NULL; )
    {
/* 12/8/92 - KT - changed 'fileno' to 'file_no' */
      _NFMdebug ((fname, "cisano[%d] cosano[%d] cidate [%s] codate[%s]\n\
                   cofilename[%s] cifilename[%s] fileno[%d] filenum[%d]\n\
                   fileversion [%d] nfs[%s] transfer_status[%d]\n",
                  file_head->cisano, file_head->cosano, file_head->cidate,
                  file_head->codate, file_head->cofilename, 
                  file_head->cifilename, file_head->file_no, file_head->filenum,
                  file_head->fileversion, file_head->nfs, 
                  file_head->transfer_status));
      file_head = file_head->next_file;
    }
    item_head = item_head->next_item;
  }

  _NFMdebug ((fname, "EXIT: 0x%.8x\n", NFM_S_SUCCESS));
  return (NFM_S_SUCCESS);
}
