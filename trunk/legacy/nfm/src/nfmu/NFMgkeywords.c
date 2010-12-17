#include "DEBUG.h"
#include "ERR.h"
#include "NFMerrordef.h"
#include "NFMitems.h"
#include "NFMitemfiles.h"
#include "MEMstruct.h"
#include "UTIerrordef.h"

extern struct NFMitem_entry *NFMitem_files;
extern freeNFMitem_files;

long NFMget_keywords_for_files (cat_name, item_name, item_rev, operation,
                               files, keywords)

char *cat_name, *item_name, *item_rev;
long operation;
MEMptr *files, *keywords;

{
  char *fname="NFMget_keywords_for_item";
  long status, query_item;
  long length, x;
  struct NFMitem_entry *cur_item;
  struct NFMfile_entry *cur_file;
  long _NFMget_info_4_keywords (),
       _NFMfind_the_length (),
       _NFMprepare_buffers ();

  _NFMdebug ((fname, "ENTER: cat_name %s item_name %s item_rev %s oper %d\n", 
                     cat_name, item_name, item_rev, operation));
 
  /** the following check is temporary
  if (operation != NFM_ITEM)
  {
    _NFMdebug ((fname, "Set implementation is not complete\n"));
    ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
           "document group/folder/drawing implementation is not complete");
    return (NFM_E_MESSAGE);
  }
  **/

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
    _NFMdebug ((fname, "Query item and all its files info\n"));
    status = _NFMget_info_4_keywords (cat_name, item_name, item_rev, operation);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "_NFMget_info_4_keywords 0x%.8x\n", status));
      return (status);
    }
  }
  else if (query_item && operation == NFM_SET)
  {
    _NFMdebug ((fname, "Calls NFMget_keywords_for_files w/out check-out \n\
               is not supported 3/15/94\n"));
    ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
          "checkout should be done first");
    return (NFM_E_MESSAGE);
  }

  if (_NFMdebug_st.NFMdebug_on)
  {
    NFMprint_item_file_information (NFMitem_files);
  }

  for (x = 0, cur_item = NFMitem_files, cur_file = NFMitem_files->next_file; 
       cur_item != (struct NFMitem_entry *) NULL; 
       )
  {
    _NFMdebug ((fname, "get keywords for  cat_no %d, item_no %d\n\
                        member type %s ; %d files association.\n",
                  cur_item->cat_no, cur_item->item_no,
                  cur_item->member_type, cur_item->files));

    if (strcmp (cur_item->member_type, "P") || !(cur_item->files))
    {
      _NFMdebug ((fname, "it is a secondary member or no file association\n"));
      cur_item = cur_item->next_item;
      cur_file = cur_item->next_file;
      x = 0;
      continue;
    }
    _NFMdebug ((fname, "file_no = [%d] words[%s]\n", cur_file->file_no,
                                       cur_file->words));
    status = NFT_get_keywords (cur_item->cat_no,
                               cur_item->item_no,
                               cur_file->file_no,
                               &(cur_file->words));
    if (status != UTI_S_SUCCESS)
    {
      /* 6/29/94 Spoke with Dave Till, he does not want any return 
         status from this function but NFM_S_SUCCESS. Filter out all
         error return and reset ERR structure. */

      _NFMdebug ((fname, "NFT_get_keywords (cat_no %d, item_no %d\n\
                  file_no %d words[%s] 0x%.8x\n",
                  cur_item->cat_no, cur_item->item_no,
                  cur_file->file_no, cur_file->words, status));
      /*return (status);*/
      ERRreset_struct ();
    }
    else if (strlen (cur_file->words))
    {
      _NFMdebug ((fname, "successfully get keywords [%s]\n",
                  cur_file->words));
    }
    else
    {
      _NFMdebug ((fname, 
       "NFT_get_keywords returned successful but NO KEYWORDS retrieved\n"));
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

  _NFMdebug ((fname, "find the max(length) of all keywords\n"));

  status = _NFMfind_the_length (&length, NFM_KEYWORDS);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "_NFMfind_the_length 0x%.8x\n", status));
    return (status);
  }

  _NFMdebug ((fname, "max length of the returned keywords == %d\n", 
              length));

  status = _NFMprepare_buffers (files, keywords, ++length);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "_NFMprepare_buffers 0x%.8x\n", status));
    return (status);
  }

  if (_NFMdebug_st.NFMdebug_on)
  {
    MEMprint_buffer ("files", *files, _NFMdebug_st.NFMdebug_file);
    MEMprint_buffer ("keywords", *keywords, _NFMdebug_st.NFMdebug_file);
  }

  if (freeNFMitem_files)
  {
      NFMfree_item_file_information (NFMitem_files);
  }
 
  _NFMdebug ((fname, "EXIT: successful\n"));
  return (NFM_S_SUCCESS);
}


long  _NFMget_info_4_keywords (cat_name, item_name, item_rev, operation)

char *cat_name, *item_name, *item_rev;
long operation;

{
  char *fname="_NFMget_info_keywords";
  char sql_str[1024];
  char dumb_str[1], **data;
  long status;
  long item_no, cat_no, dumb_value, x, index;
  MEMptr list=NULL;
  struct NFMfile_entry *cur_file, *new_file;
  
  _NFMdebug ((fname, "ENTER\n"));

  sprintf (sql_str, 
           "select n_catalogno from nfmcatalogs where n_catalogname = '%s'", 
           cat_name);

  status = NFMretrieve_values (sql_str, NFM_RETURN_VALUE, dumb_str,
                               &cat_no, &list);

  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "NFMretrieve_values 0x%.8x\n", status));
    return (status);
  }


  sprintf (sql_str, "%s %s %s '%s' %s '%s'",
           "select n_itemno from", cat_name, "where n_itemname = ",
           item_name, "and n_itemrev = ", item_rev); 

  status = NFMretrieve_values (sql_str, NFM_RETURN_VALUE, dumb_str,
                               &item_no, &list);

  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "NFMretrieve_values 0x%.8x\n", status));
    return (status);
  }

  sprintf (sql_str, "%s f_%s %s %d %s f_%s %s %d %s",
           "select n_fileno, n_cofilename from ", cat_name, 
           "where n_itemnum = ", item_no,
           "and n_fileversion = (select max(n_fileversion) from", cat_name,
           "where n_itemnum = ", item_no, ")");

  status = NFMretrieve_values (sql_str, NFM_RETURN_MEMPTR, dumb_str,
                               &dumb_value, &list);

  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "NFMretrieve_values 0x%.8x\n", status));
    return (status);
  }

  NFMitem_files = (struct NFMitem_entry *) calloc (1,
                          sizeof (struct NFMitem_entry));
  strcpy (NFMitem_files->cat_name, cat_name);
  strcpy (NFMitem_files->member_type, "P");
  NFMitem_files->cat_no = cat_no;
  NFMitem_files->item_no = item_no;
  NFMitem_files->files = list->rows;

  NFMitem_files->next_file = cur_file = (struct NFMfile_entry *) calloc (1,
                                      sizeof (struct NFMfile_entry));
  data = (char **) list->data_ptr;

  for (x=0; x<list->rows; x++)
  {
    index = list->columns * x;
    cur_file->file_no = atol(data[index]);   
    strcpy (cur_file->cofilename, data[index+1]);
    _NFMdebug ((fname, "row %d retrieved file no %s, cur_file->file_no %d\n",
                        x, data[index], cur_file->file_no));
    if (x+1 < list->rows)
    {
      _NFMdebug ((fname, "there is more data coming ...\n"));
      new_file = (struct NFMfile_entry *) calloc (1,
                                      sizeof (struct NFMfile_entry));
      cur_file->next_file = new_file;
      cur_file = cur_file->next_file;
    }
  } 

  if (operation == NFM_SET)
  {
    _NFMdebug ((fname, "set implementation is not complete\n"));
  }
 
  _NFMdebug ((fname, "EXIT\n"));

  return (status);
}

long _NFMfind_the_length (length, length_type)

long *length;
long length_type;

{
  char *fname="_NFMfind_the_length";
  char *tokptr, *str_ptr;
  struct NFMitem_entry *item_head;
  struct NFMfile_entry *file_head;

  _NFMdebug ((fname, "ENTER: \n"));
  *length = 0;
  for (item_head = NFMitem_files; item_head != (struct NFMitem_entry *) NULL; )
  {
    _NFMdebug ((fname, 
              "cat[%d] item[%d] [%d] files associated\n",
              item_head->cat_no,  
              item_head->item_no, item_head->files));
    for (file_head = item_head->next_file; 
                                file_head != (struct NFMfile_entry *) NULL; )
    {
      _NFMdebug ((fname, "fileno[%d] words[%s] positions [%s]\n",
                  file_head->file_no, file_head->words,
                  file_head->positions));
      if (( (length_type == NFM_KEYWORDS) && 
            (file_head->words == (char *) NULL || 
             !strcmp (file_head->words, " ")     ) ) ||
          ( (length_type == NFM_POSITIONS) &&
            (file_head->positions == (char *) NULL ||
             !strcmp (file_head->positions, " ")     )) )
      {
        _NFMdebug ((fname, "no word(s) or position(s)\n"));
        file_head = file_head->next_file;
        continue;
      }
      
      if (length_type == NFM_KEYWORDS)
      {
        str_ptr = (char *) calloc (strlen (file_head->words) + 1, 
                                   sizeof (char));
        strcpy (str_ptr, file_head->words);

        _NFMdebug ((fname, "str_ptr [%s]\n", str_ptr));
        while ((tokptr = (char *) strtok (str_ptr, " ")) != (char *) NULL)
        {
          _NFMdebug ((fname, "tokptr [%s] length %d\n", tokptr, strlen(tokptr)));
          if (*length < strlen (tokptr))
          {
            *length = strlen (tokptr);
            _NFMdebug ((fname, "new record, length = %d\n", *length));
          }
          str_ptr = (char *) NULL;
        }
      }
      else
      {
        str_ptr = (char *) calloc (strlen (file_head->positions) + 1, 
                                     sizeof (char));
        strcpy (str_ptr, file_head->positions);

        _NFMdebug ((fname, "str_ptr [%s]\n", str_ptr));
        while ((tokptr = (char *) strtok (str_ptr, "\n")) != (char *) NULL)
        {
          _NFMdebug ((fname, "tokptr [%s] length %d\n", tokptr, strlen(tokptr)));
          if (*length < strlen (tokptr))
          {
            *length = strlen (tokptr);
            _NFMdebug ((fname, "new record, length = %d\n", *length));
          }
          str_ptr = (char *) NULL;
        }
      }
      free (str_ptr); 
      file_head = file_head->next_file;
    }
    item_head = item_head->next_item;
  }

  _NFMdebug ((fname, "EXIT: length [%d] 0x%.8x\n", *length, NFM_S_SUCCESS));
  return (NFM_S_SUCCESS);
}

long _NFMprepare_buffers (files, keywords, length)

MEMptr *files, *keywords;
long length;

{
  char *fname="_NFMprepare_buffers";
  char *tokptr, *str_ptr;
  char row_str[1024];
  long status, keycount;
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
  else
  {
    _NFMdebug ((fname, "success\n"));
  }

  status = MEMopen (keywords, MEM_SIZE);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ((fname, "MEMopen(keywords) 0x%.8x\n", status));
    return (status);
  }
  else
  {
    _NFMdebug ((fname, "success\n"));
  }

  format = (struct NFMbuf_format *) calloc (4, sizeof (struct NFMbuf_format));
  if (!format)
  {
    _NFMdebug ((fname, "failed to calloc format\n"));
    return (NFM_E_MALLOC);
  }
  else
  {
    _NFMdebug ((fname, "success\n"));
  }

  strcpy ((format+0)->attr_name, "n_catno");
  strcpy ((format+0)->data_type, "integer");
  strcpy ((format+1)->attr_name, "n_itemno");
  strcpy ((format+1)->data_type, "integer");
  strcpy ((format+2)->attr_name, "n_filename");
  sprintf ((format+2)->data_type, "char(%d)", NFM_CIFILENAME);
  strcpy ((format+3)->attr_name, "count");
  strcpy ((format+3)->data_type, "integer");

  status = _NFMbuild_working_buffer_format (format, 4, *files);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "_NFMbuild_working_buffer_format 0x%.8x\n", status));
    return (status);
  }
  else
  {
    _NFMdebug ((fname, "success\n"));
  }

  free (format);

  format = (struct NFMbuf_format *) calloc (1, sizeof (struct NFMbuf_format));
  if (!format)
  {
    _NFMdebug ((fname, "failed to calloc format\n"));
    return (NFM_E_MALLOC);
  }
  else
  {
    _NFMdebug ((fname, "success\n"));
  }

  strcpy (format->attr_name, "keywords");
  sprintf (format->data_type, "char(%d)", length+1);

  status = _NFMbuild_working_buffer_format (format, 1, *keywords);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "_NFMbuild_working_buffer_format 0x%.8x\n", status));
    return (status);
  }
  else
  {
    _NFMdebug ((fname, "success\n"));
  }

  free (format);

  /* for each file entry in NFMitem_files, write a row to files and n rows
     of keywords */

  for (item_head = NFMitem_files, cur_item = NFMitem_files->item_no,
       cur_cat = NFMitem_files->cat_no; 
       item_head != (struct NFMitem_entry *) NULL; )
  {
    _NFMdebug ((fname, 
              "cat[%d] item[%d] [%d] files associated\n",
              item_head->cat_no,  
              item_head->item_no, item_head->files));
    if (strcmp (item_head->member_type, "P"))
    {
      _NFMdebug ((fname, "this is a secondary member, skip it\n"));
      item_head = item_head->next_item;
      continue;
    }

    for (file_head = item_head->next_file; 
                                file_head != (struct NFMfile_entry *) NULL; )
    {
      _NFMdebug ((fname, "fileno[%d] file_name [%s] words[%s]\n",
                  file_head->file_no, file_head->cofilename, 
                  file_head->words));
      
      if (strlen(file_head->words) == 0)
      {
        _NFMdebug ((fname, "NO KEYWORDS\n"));
        file_head = file_head->next_file;
        continue;
      }
      str_ptr = (char *) calloc (strlen (file_head->words) + 1, sizeof (char));
      strcpy (str_ptr, file_head->words);
      _NFMdebug ((fname, "str_ptr [%s]\n", str_ptr));
      keycount = 0;
      while ((tokptr = (char *) strtok (str_ptr, " ")) != (char *) NULL)
      {
        _NFMdebug ((fname, "tokptr [%s] \n", tokptr));
        sprintf (row_str, "%s\1", tokptr);
        _NFMdebug ((fname, "MEMwrite (%s) \n", row_str));
        status = MEMwrite (*keywords, row_str);
        if (status != MEM_S_SUCCESS)
        {
          _NFMdebug ((fname, "MEMwrite 0x%.8x\n", status));
          MEMclose (files);
          MEMclose (keywords);
          return (status);
        }
        else
        {
          _NFMdebug ((fname, "keywords, success\n"));
        }
        keycount ++;
        str_ptr = (char *) NULL;
      }
      free (str_ptr); 
      sprintf (row_str, "%d\1%d\1%s\1%d\1",
               item_head->cat_no, item_head->item_no,
               file_head->cofilename, keycount);
      _NFMdebug ((fname, "MEMwrite (%s)\n", row_str));
      status = MEMwrite (*files, row_str);
      if (status != MEM_S_SUCCESS)
      {
        _NFMdebug ((fname, "MEMwrite (files) 0x%.8x\n", status));
        MEMclose (files); MEMclose (keywords);
        return (status);
      }
      else
      {
        _NFMdebug ((fname, "files,  success\n"));
      }
      file_head = file_head->next_file;
    }
    item_head = item_head->next_item;
  }

  if (_NFMdebug_st.NFMdebug_on)
  {
    MEMprint_buffer ("files", *files, _NFMdebug_st.NFMdebug_file);
    MEMprint_buffer ("keywords", *keywords, _NFMdebug_st.NFMdebug_file);
  }

  _NFMdebug ((fname, "EXIT\n"));
  return (NFM_S_SUCCESS);
}
