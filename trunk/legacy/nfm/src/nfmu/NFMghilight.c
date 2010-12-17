#include "DEBUG.h"
#include "ERR.h"
#include "NFMerrordef.h"
#include "NFMitems.h"
#include "NFMitemfiles.h"
#include "MEMstruct.h"
#include "NFMapi.h"
#include "UTIerrordef.h"

extern struct NFMitem_entry *NFMitem_files;
extern long freeNFMitem_files;
extern DMhighlight_files;

long NFMget_highlighting_for_files (cat_name, item_name, item_rev, operation,
                               ftr_search, files, positions)

char *cat_name, *item_name, *item_rev;
long operation;
char *ftr_search;
MEMptr *files, *positions;

{
  char *fname="NFMget_highlight_for_files";
  long status, query_item;
  long length, x, at_least_1=0;
  struct NFMitem_entry *cur_item;
  struct NFMfile_entry *cur_file;
  long _NFMprepare_positions ();
  struct NFMquery_ftr_info query_info;
  MEMptr m_files=NULL;

  _NFMdebug ((fname, "ENTER: cat_name %s item_name %s item_rev %s oper %d\n\
                     search %s\n", 
                     cat_name, item_name, item_rev, operation, ftr_search));
 
  /* does NFMitem_files (global variable) have any information stored?
     yes - does it contain the information of requested item?
           yes - no need to query
           no - set a flag to indicate queries need to be done
     no - set a flag to indicate queries need to be done
  */

  if (NFMitem_files != (struct NFMitem_entry *) NULL)
  {
    _NFMdebug ((fname, 
      "There is something in global info, is it == requested item?\n")); 
    if (strcmp (cat_name, NFMitem_files->cat_name) == 0 &&
        strcmp (item_name, NFMitem_files->item_name) == 0 &&
        strcmp (item_rev, NFMitem_files->item_rev) == 0)
    {
      _NFMdebug ((fname, "valid info about requested item in global var\n"));
      query_item = 0;
    }
    else
    {
      _NFMdebug ((fname, "Info in global var is not useful\n"));
      NFMfree_item_file_information (NFMitem_files);
      query_item = 1;
    }
  }
  else
  {
    _NFMdebug ((fname, "No info in global variable, retrieve everything\n"));
    query_item = 1;
  }

  /* if the flag is TRUE
     yes - retrieve info from dbase
     no - nothing to query
  */

  if (query_item && operation == NFM_ITEM)
  {
    _NFMdebug ((fname, "Calls NFMget_highlight_for_files w/out copy-out \n\
               is not supported 3/15/94\n"));
    ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
          "copy_out should be done first");
    return (NFM_E_MESSAGE);
    /*
    _NFMdebug ((fname, "Query item and all its files info\n"));
    status = _NFMget_info_4_keywords (cat_name, item_name, item_rev, operation);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "_NFMget_info_4_keywords 0x%.8x\n", status));
      return (status);
    }
    */
  }
  else if (query_item && operation == NFM_SET)
  {
    _NFMdebug ((fname, "Calls NFMget_highlight_for_files w/out copy-out \n\
               is not supported 3/15/94\n"));
    ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
          "copy_out should be done first");
    return (NFM_E_MESSAGE);
  }

  if (! query_item)
  {
    status = _NFMbuild_and_mount (DMhighlight_files, &m_files);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "_NFMbuild_and_mount 0x%.8x\n", status));
      return (NFM_E_FAILURE);
    }
  }

  if (_NFMdebug_st.NFMdebug_on)
  {
    NFMprint_item_file_information (NFMitem_files);
  }
  if (ftr_search[0] != ' ')
  {
    status = _NFMretrieve_ftr_query (ftr_search, "F", &query_info);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "_NFMretrieve_ftr_query 0x%.8x\n", status));
      return (status);
    }
    _NFMdebug ((fname, "retrieved ftr string [%s]\n", query_info.ftr));
  }
  else
  {
    query_info.ftr = (char *) calloc (strlen (ftr_search), sizeof (char));
    for (x = 1; x < strlen (ftr_search); x ++)
    {
      query_info.ftr[x-1] = ftr_search[x];
    }
    query_info.ftr[x-1] = '\0';
    _NFMdebug ((fname, "assigned ftr string [%s]\n", query_info.ftr));
  }

  for (x = at_least_1 = 0, cur_item = NFMitem_files, 
       cur_file = NFMitem_files->next_file; 
       cur_item != (struct NFMitem_entry *) NULL; 
       )
  {
    if (cur_item->files > 0)
    {
      _NFMdebug ((fname, "get highlight for  (cat_no %d, item_no %d\n\
                    file_no %d ftr %s\n",
                    cur_item->cat_no, cur_item->item_no,
                    cur_file->file_no, query_info.ftr));

      status = NFT_gen_highlight (cur_item->cat_no,
                                 query_info.ftr,
                                 cur_item->item_no,
                                 cur_file->file_no,
                                 &(cur_file->positions));
      if (status != UTI_S_SUCCESS)
      {
        _NFMdebug ((fname, "NFT_gen_highlight (cat_no %d, item_no %d\n\
                    file_no %d 0x%.8x\n",
                    cur_item->cat_no, cur_item->item_no,
                    cur_file->file_no, status));
        /*return (status);*/
      }
      else
      {
        _NFMdebug ((fname, "successfully get highlight info [%s]\n",
                    cur_file->positions));
        at_least_1++;
      }
    }
    else
    {
      _NFMdebug ((fname, "cannot get highlight for  (cat_no %d, item_no %d\n\
                    ftr %s) because file association = %d\n",
                    cur_item->cat_no, cur_item->item_no,
                    query_info.ftr, cur_item->files));
    }
    if (x < cur_item->files - 1)
    {
      _NFMdebug ((fname, "more file for this item\n"));
      x++;
      cur_file = cur_file->next_file;
    }
    else
    {
      _NFMdebug ((fname, "done with the item, go to the next \n"));
      cur_item = cur_item->next_item;
      cur_file = cur_item->next_file;
      x = 0;
    } 
  }

  if (!at_least_1)
  {
    ERRload_struct (NFM, UTI_W_NO_HITS, "", NULL);
    _NFMdebug ((fname, "no highlight hit\n"));
    return (UTI_W_NO_HITS);
  }

  _NFMdebug ((fname, "find the max(length) of all positions\n"));

  status = _NFMfind_the_length (&length, NFM_POSITIONS);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "_NFMfind_the_length 0x%.8x\n", status));
    return (status);
  }

  _NFMdebug ((fname, "max length of the returned positions == %d\n", length));

  status = _NFMprepare_positions (files, positions, length);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "_NFMprepare_buffers 0x%.8x\n", status));
    return (status);
  }

  if (_NFMdebug_st.NFMdebug_on)
  {
    MEMprint_buffer ("files", *files, _NFMdebug_st.NFMdebug_file);
    MEMprint_buffer ("positions", *positions, _NFMdebug_st.NFMdebug_file);
  }

  if (freeNFMitem_files)
  {
     NFMfree_item_file_information (NFMitem_files);
  }

  status = _NFMftr_undo_make_files_local (&m_files);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "_NFMftr_undo_make_files_local 0x%.8x\n", status));
  }
  MEMclose (&DMhighlight_files);
  MEMclose (&m_files);
 
  _NFMdebug ((fname, "EXIT: successful\n"));
  return (NFM_S_SUCCESS);
}


long _NFMprepare_positions (files, positions, length)

MEMptr *files, *positions;
long length;

{
  char *fname="_NFMprepare_positions";
  char *tokptr, *str_ptr;
  char row_str[1024];
  long status, position_count;
  long cur_item, cur_cat;
  struct NFMbuf_format *format=NULL;
  struct NFMitem_entry *item_head;
  struct NFMfile_entry *file_head;
  

  _NFMdebug ((fname, "ENTER max length = %d \n", length));

  status = MEMopen (files, MEM_SIZE);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ((fname, "MEMopen(files) 0x%.8x\n", status));
    return (status);
  }

  status = MEMopen (positions, MEM_SIZE);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ((fname, "MEMopen(positions) 0x%.8x\n", status));
    return (status);
  }

  format = (struct NFMbuf_format *) calloc (4, sizeof (struct NFMbuf_format));
  if (!format)
  {
    _NFMdebug ((fname, "failed to calloc format\n"));
    return (NFM_E_MALLOC);
  }

  strcpy ((format+0)->attr_name, "n_catno");
  strcpy ((format+0)->data_type, "integer");
  strcpy ((format+1)->attr_name, "n_itemno");
  strcpy ((format+1)->data_type, "integer");
  strcpy ((format+2)->attr_name, "n_filename");
  sprintf ((format+2)->data_type, "char(%d)", NFM_COFILENAME);
  strcpy ((format+3)->attr_name, "count");
  strcpy ((format+3)->data_type, "integer");

  status = _NFMbuild_working_buffer_format (format, 4, *files);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "_NFMbuild_working_buffer_format 0x%.8x\n", status));
    return (status);
  }

  free (format);

  format = (struct NFMbuf_format *) calloc (1, sizeof (struct NFMbuf_format));
  if (!format)
  {
    _NFMdebug ((fname, "failed to calloc format\n"));
    return (NFM_E_MALLOC);
  }

  strcpy (format->attr_name, "positions");
  sprintf (format->data_type, "char(%d)", length+1);

  status = _NFMbuild_working_buffer_format (format, 1, *positions);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "_NFMbuild_working_buffer_format 0x%.8x\n", status));
    return (status);
  }

  free (format);

  /* for each file entry in NFMitem_files, write a row to files and n rows
     of positions */

  for (item_head = NFMitem_files, cur_item = NFMitem_files->item_no,
       cur_cat = NFMitem_files->cat_no; 
       item_head != (struct NFMitem_entry *) NULL; )
  {
    _NFMdebug ((fname, 
              "cat[%d] item[%d] [%d] files associated\n",
              item_head->cat_no,  
              item_head->item_no, item_head->files));

    for (file_head = item_head->next_file; 
                                file_head != (struct NFMfile_entry *) NULL; )
    {
      _NFMdebug ((fname, "fileno[%d] file_name [%s] positions[%s]\n",
                  file_head->file_no, file_head->cofilename, 
                  file_head->positions));
      if (file_head->positions == (char *) NULL ||
          ! strcmp (file_head->positions, " "))
      {
        _NFMdebug ((fname, "no positions for the file\n"));
        file_head = file_head->next_file;
        continue;
      }
      
      str_ptr = (char *) calloc (strlen (file_head->positions) + 1, 
                                 sizeof (char));
      strcpy (str_ptr, file_head->positions);
      _NFMdebug ((fname, "str_ptr [%s]\n", str_ptr));
      position_count = 0;
      while ((tokptr = (char *) strtok (str_ptr, "\n")) != (char *) NULL)
      {
        _NFMdebug ((fname, "tokptr [%s] \n", tokptr));
        sprintf (row_str, "%s\1", tokptr);
        _NFMdebug ((fname, "MEMwrite (%s) \n", row_str));
        status = MEMwrite (*positions, row_str);
        if (status != MEM_S_SUCCESS)
        {
          _NFMdebug ((fname, "MEMwrite 0x%.8x\n", status));
          MEMclose (files);
          MEMclose (positions);
          return (status);
        }
        position_count ++;
        str_ptr = (char *) NULL;
      }
      free (str_ptr); 
      sprintf (row_str, "%d\1%d\1%s\1%d\1",
               item_head->cat_no, item_head->item_no,
               file_head->cofilename, position_count);
      _NFMdebug ((fname, "MEMwrite (%s)\n", row_str));
      status = MEMwrite (*files, row_str);
      if (status != MEM_S_SUCCESS)
      {
        _NFMdebug ((fname, "MEMwrite (files) 0x%.8x\n", status));
        MEMclose (files); MEMclose (positions);
        return (status);
      }
      file_head = file_head->next_file;
    }
    item_head = item_head->next_item;
  }

  if (_NFMdebug_st.NFMdebug_on)
  {
    MEMprint_buffer ("files", *files, _NFMdebug_st.NFMdebug_file);
    MEMprint_buffer ("positions", *positions, _NFMdebug_st.NFMdebug_file);
  }

  _NFMdebug ((fname, "EXIT\n"));
  return (NFM_S_SUCCESS);
}
