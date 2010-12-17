/*******************************************************************************

Doc : _NFMmount_add_index (files, operation_type)

Description : This function will make (mount or transfer) files available to FTR
              engine on the environment machine, call NFT_add_file for each 
              file, and call NFT_index at the end.

Return Status :

*******************************************************************************/

#include "DEBUG.h"
#include "ERR.h"
#include "NFMerrordef.h"
#include "MEMstruct.h"
#include "NFMschema.h"
#include "NFMfto_buf.h"
#include "NFMitems.h"
#include "NFMitemfiles.h"
#include "NFTproto.h"
#include "NFTtypes.h"
#include "NFTftr.h"
#include "UTIerrordef.h"

long NFM_KEYWORD_SIZE=25;


MEMptr NFMfiles=NULL;
MEMptr NFMkeywords=NULL;

long _NFMmount_add_index (files, operation_type)
MEMptr files;
long operation_type; /* I: NFM_ITEM or NFM_SET */

{

  char *fname="_NFMmount_add_index";
  char **m_data, **data, *keywords=NULL;
  char row_str[1024], nfs_str[10], remove_mt_str[10];
  long type=0, status;
  long x, index, cur_cat;
  long _NFMprepare_keywords ();
  MEMptr m_files=NULL;
  struct NFMsto_info check_sto;
  long _DMbuild_ftr_buffer ();

  _NFMdebug ((fname, "ENTER: operation_type %d\n", operation_type));
  if (_NFMdebug_st.NFMdebug_on)
  {
    MEMprint_buffer ("files", files, _NFMdebug_st.NFMdebug_file);
  }

  status = _DMbuild_ftr_buffer (&m_files, 0);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "_DMbuild_ftr_buffer 0x%.8x\n", status));
    return (status);
  }
  
  /* retrieve storage area == 4 information, _NFMftr_make_files_local
     will make all files available to the FTR engine on environment/vault
     machine using path == /usr/tmp. */

  check_sto.saname[0] = '\0';
  check_sto.sano = 4;
  status = NFMget_storage_info (&(check_sto.saname), &(check_sto.sano),
           &(check_sto.nodename), &(check_sto.username), &(check_sto.passwd),
           &(check_sto.pathname), &(check_sto.devicetype),
           &(check_sto.plattername),
           &(check_sto.partition), &(check_sto.nfs), &(check_sto.compress),
           &(check_sto.machid), &(check_sto.opsys), &(check_sto.tcpip),
           &(check_sto.xns),
           &(check_sto.decnet), &(check_sto.netware));
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname,
       "failed to retrieve storage area 4 information,  skip FTR\n"));
    MEMclose (&m_files);
    return (status);
  }

  /* FTO_STATUS1 == NFM_FTR_MT_PT_REMOVE */
  sprintf (remove_mt_str, "%d", NFM_FTR_MT_PT_REMOVE);

  sprintf (row_str,
    "%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s%s%s",
    0, check_sto.nodename, check_sto.username, check_sto.passwd,
    "/usr/tmp", check_sto.devicetype, check_sto.plattername,
    check_sto.partition, check_sto.nfs, check_sto.compress,
    check_sto.machid, check_sto.opsys, check_sto.tcpip,
    check_sto.xns, check_sto.decnet, check_sto.netware,
    "\1\1\1\1\1\1", remove_mt_str, "\1\1\1\1\1\1\1\1\1");
  status = MEMwrite (m_files, row_str);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ((fname, "MEMwrite [%s] 0x%.8x\n", row_str, status));
    MEMclose (&m_files);
    return (status);
  }

  for (x = 1; x < files->rows; x ++)
  {
    _NFMdebug ((fname, "x = %d\n", x));
    status = MEMcopy_row(files, &m_files, x + 1);
    if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMcopy_row (%d) 0x%.8x\n", x));
      MEMclose (&m_files);
      return (status);
    }
    if (_NFMdebug_st.NFMdebug_on)
     MEMprint_buffer ("m_files", m_files, _NFMdebug_st.NFMdebug_file);
  }


  if (_NFMdebug_st.NFMdebug_on)
    MEMprint_buffer ("m_files", m_files, _NFMdebug_st.NFMdebug_file);

  status = MEMbuild_array (m_files);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ((fname, "MEMbuild_array 0x%.8x\n", status));
    MEMclose (&m_files);
    return (status);
  }

  m_data = (char **) m_files->data_ptr;
  sprintf (nfs_str, "%d", NFM_NFS_MOVE);

  for (x = 1; x < files->rows; x++)
  {
    index = x * m_files->columns;
    strcpy (row_str, m_data[index+FTO_CIFILENAME]);

    status = MEMwrite_data (m_files, row_str, x + 1, FTO_COFILENAME+1);
    if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMwrite_data (%d) 0x%.8x\n", x, status));
      MEMclose (&m_files);
      return (status);
    }   

    status = MEMwrite_data (m_files, nfs_str, x + 1 , FTO_STATUS1+1);
    if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMwrite_data (%d NFM_MOVE) 0x%.8x\n", x, status));
      MEMclose (&m_files);
      return (status);
    }   
  }

  if (_NFMdebug_st.NFMdebug_on)
    MEMprint_buffer ("after modify cofilename and status1 m_files", 
                     m_files, _NFMdebug_st.NFMdebug_file);

  /* make file available to FTR engine */
  status = _NFMftr_make_files_local (&m_files);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "_NFMftr_make_files_local 0x%.8x\n", status));
    MEMclose (&m_files);
    return (status);
  }

  /* 8/11/94 call NFT_start_group () for Rob's new FTR design */

  status = NFT_start_group ();
  if (status != UTI_S_SUCCESS)
  {
    _NFMdebug ((fname, "NFT_start_group 0x%.8x\n", status));
    _NFMftr_undo_make_files_local (&m_files);
    MEMclose (&m_files);
    return (status);
  }

  /* for each file call NFT_add_file */

  status = MEMbuild_array (m_files);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ((fname, "MEMbuild_array (m_files) 0x%.8x\n", status));
    _NFMftr_undo_make_files_local (&m_files);
    MEMclose (&m_files);
    return (status);
  }

  m_data = (char **) m_files->data_ptr;
  data = (char **) files->data_ptr;

  for (x = 1; x < m_files->rows; x++)
  {
    index = x * m_files->columns;

    if (strcmp (m_data[index+FTO_FILETYPE], "ASCII") == 0 ||
        strcmp (m_data[index+FTO_FILETYPE], "TXT") == 0 ||
        strcmp (m_data[index+FTO_FILETYPE], "TEXT") == 0    )
    {
       type = TEXT_TYPE;
    }
    else if (strcmp (m_data[index+FTO_FILETYPE], "IGDS") == 0 ||
        strcmp (m_data[index+FTO_FILETYPE], "DGN") == 0 ||
        strcmp (m_data[index+FTO_FILETYPE], "M") == 0    )
    {
       type = IGDS_TYPE;
    }
    else if (strcmp (m_data[index+FTO_FILETYPE], "DWG") == 0 ||
        strcmp (m_data[index+FTO_FILETYPE], "DXF") == 0 )
    {
       type = AUTOCAD_TYPE;
    }
    else if (strcmp (m_data[index+FTO_FILETYPE], "DOC") == 0 )
    {
       type = MSWORD_TYPE;
    }
    else if (strcmp (m_data[index+FTO_FILETYPE], "WP") == 0 )
    {
       type = WORDPERFECT_TYPE;
    }
    else if (strcmp (m_data[index+FTO_FILETYPE], "WSTAR") == 0 )
    {
       type = WORDSTAR_TYPE;
    }
    else if (strcmp (m_data[index+FTO_FILETYPE], "WMARC") == 0 )
    {
       type = WORDMARC_TYPE;
    }
    else if (strcmp (m_data[index+FTO_FILETYPE], "QONE") == 0 )
    {
       type = QONE_TYPE;
    }
    else 
    {
       type = NON_INDEXABLE;
    }

    _NFMdebug ((fname, "type = %d\n", type));

    /* concatenate the keywords */

    if (NFMfiles != (MEMptr) NULL)
    {
      /* the client gave the information of keywords */

      status = _NFMprepare_keywords (atol(m_data[index+FTO_CATNO]),
                                     atol(m_data[index+FTO_ITEMNO]),
                                     data[index+FTO_COFILENAME], &keywords,
                                     operation_type);
      if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "_NFMprepare_keywords 0x%.8x\n", status));
        _NFMftr_undo_make_files_local (&m_files);
        MEMclose (&m_files);
        return (status);
      }
    }
    else if (operation_type == NFM_ITEM_NO_KEYWORDS ||
             operation_type == NFM_SET_NO_KEYWORDS)
    {
      /* operation will ONLY == NFM_ITEM_NO_KEYWORDS OR NFM_SET_NO_KEYWORD
         if client == NFM. Since FTR is enabled, need to make sure
         no keywords information is lost */

      _NFMdebug ((fname, 
        "try to get keywords from collection since the client == NFM\n\
         cat %d item %d file no %d\n", atol(m_data[index+FTO_CATNO]),
                 atol(m_data[m_files->columns+FTO_ITEMNO]), 
                 atol(m_data[index+FTO_ITEMDESC])));

      /* client != DMM, old file no is stored in FTO_ITEMDESC field */

      status = NFT_get_keywords (atol(m_data[index+FTO_CATNO]),
                 atol(m_data[m_files->columns+FTO_ITEMNO]), 
                 atol(m_data[index+FTO_ITEMDESC]), &keywords);
      if (status == UTI_S_SUCCESS)
      {
        _NFMdebug ((fname, 
           "This item/document has been handled by DMM and NFM\n"));
      }
      else /* 4/20/94 if (status == UTI_W_NO_HITS)*/
      {
        _NFMdebug ((fname, "This item has never been indexed\n"));
      }
      /* 4/20/94
      else
      {
        _NFMdebug ((fname, "NFT_get_keywords 0x%.8x\n", status));
        _NFMftr_undo_make_files_local (&m_files);
        return (status);
      }
      */
    }
    else
    {
      /* there is no keywords given */
      keywords = (char *) calloc (1, sizeof(char));
    }

    /*
    if (type == 0 )
    {
      _NFMdebug ((fname, "file type [%s] not supported by FTR\n",
                  m_data[index+FTO_FILETYPE]));
      if (keywords == (char *) NULL ||
          strcmp (keywords, " ")== 0)
      {
        _NFMdebug ((fname, "No keywords given\n"));
        / *ERRload_struct (NFM, NFM_W_FTR_FTYPE, "%s%s%s%s",
          m_data[index+FTO_FILETYPE], data[index+FTO_COFILENAME],
          m_data[index+FTO_ITEMNAME], m_data[index+FTO_REV]); * /
      }
      else
      {
        _NFMdebug ((fname, "Warning for keywords loss\n"));
        / *ERRload_struct (NFM, NFM_W_FTR_FTYPE_KW, "%s%s%s%s",
          m_data[index+FTO_FILETYPE], data[index+FTO_COFILENAME],
          m_data[index+FTO_ITEMNAME], m_data[index+FTO_REV]); * /
      }
      continue;
    }
    */

    sprintf (row_str, "/usr/tmp/%s", m_data[index+FTO_CIFILENAME]);

    _NFMdebug ((fname, "catno %s itemno %s fileno %s \n\
                file %s type %d keywords[%s]\n", 
                m_data[index+FTO_CATNO], 
                m_data[index+FTO_ITEMNO], 
                m_data[index+FTO_FILENO], row_str, type,
                keywords));

    status = NFT_add_file (atol(m_data[index+FTO_CATNO]), 
                atol (m_data[index+FTO_ITEMNO]),
                atol(m_data[index+FTO_FILENO]), row_str,
                type, keywords);
    if (status != UTI_S_SUCCESS)
    {
       _NFMdebug ((fname, "NFT_add_file (cifilename %s fileno %s) 0x%.8x\n",
               m_data[index+FTO_CIFILENAME], m_data[index+FTO_FILENO],status));
       _NFMftr_undo_make_files_local (&m_files);
       MEMclose (&m_files);
       return (status);
    }
    else
    {
      _NFMdebug ((fname, "NFT_add_file successful\n"));
    }
    free (keywords);
  }

  if (operation_type == NFM_ITEM ||
      operation_type == NFM_ITEM_NO_KEYWORDS)
  {
    _NFMdebug ((fname, "FTR for an item at time\n"));
    status = NFT_index (atol(m_data[(m_files->columns)+FTO_CATNO]));
    if (status != UTI_S_SUCCESS)
    {
      _NFMdebug ((fname, "NFT_index 0x%.8x\n", status));
      _NFMftr_undo_make_files_local (&m_files);
      MEMclose (&m_files);
      return (status);
    }
    else 
    {
      _NFMdebug ((fname, "NFT_index successful\n"));
    }
  }
  else
  {
    _NFMdebug ((fname, "FTR for a set\n"));
    for (x = 1, cur_cat = 0; x < m_files->rows; x ++)
    {
      index = m_files->columns * x;
      _NFMdebug ((fname, "cat_no %s\n", m_data[index+FTO_CATNO]));
      if (cur_cat != atol (m_data[index+FTO_CATNO]))
      {
        _NFMdebug ((fname, "Index the catno %s\n", m_data[index+FTO_CATNO]));

        status = NFT_index (atol(m_data[index+FTO_CATNO]));
        if (status != UTI_S_SUCCESS)
        {
          _NFMdebug ((fname, "NFT_index cat_no %d 0x%.8x\n", 
                      m_data[index+FTO_CATNO], status));
          _NFMftr_undo_make_files_local (&m_files);
          MEMclose (&m_files);
          return (status);
        }
        else
        {
          _NFMdebug ((fname, "NFT_index %d successful\n", 
                             m_data[index+FTO_CATNO]));
        }
        cur_cat = atol (m_data[index+FTO_CATNO]);
      } 
    }
  }

  status = _NFMftr_undo_make_files_local (&m_files);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "_NFMftr_undo_make_files_local 0x%.8x\n\
               But... return successful because files are indexed\n", status));
    MEMclose (&m_files);
    return (NFM_S_SUCCESS);
  }

  _NFMdebug ((fname, "EXIT successful 0x%.8x\n", NFM_S_SUCCESS));
  return (NFM_S_SUCCESS);
}


long _NFMprepare_keywords (cat_no, item_no, filename, keywords, operation_type)

long cat_no, item_no;
char *filename;
char **keywords;
long operation_type;

{
  char *fname="_NFMprepare_keywords";
  char  **file_data, **key_data, **column;
  long x, y, z, index, k_index;
  long i_catno=-1, i_itemno=-1, i_filename=-1, i_keycount=-1;
  long found, status, handleIt;

  _NFMdebug ((fname, "ENTER: cat_no %d item_no %d \n\
                      filename = %s operation_type = %d\n", 
                     cat_no, item_no, filename, operation_type));

  if (_NFMdebug_st.NFMdebug_on)
  {
    MEMprint_buffer ("NFMfiles", NFMfiles, _NFMdebug_st.NFMdebug_file);
    MEMprint_buffer ("NFMkeywords", NFMkeywords, _NFMdebug_st.NFMdebug_file);
  }


  /* x is the row number into NFMfiles;
     y is the row number into NFMkeywords, */

  file_data = (char **) NFMfiles->data_ptr;
  key_data = (char **) NFMkeywords->data_ptr;

  column = (char **) NFMfiles->column_ptr;

  for (x = 0; x < NFMfiles->columns; x ++)
  {
    if (!strcmp (column[x], "n_catalogno"))
      i_catno = x;
    else if (!strcmp (column[x], "n_itemno"))
      i_itemno = x;
    else if (!strcmp (column[x], "n_filename"))
      i_filename = x;
    else if (!strcmp (column[x], "count"))
      i_keycount = x;
  }

  if (i_catno < 0 || i_itemno < 0 || i_filename < 0 || i_keycount < 0)
  {
    _NFMdebug ((fname, "NFMfiles buffer is corrupted\n"));
    return (NFM_E_FAILURE);
  }

  for (x = found = y = 0; x < NFMfiles->rows; x ++)
  {
    index = x * NFMfiles->columns;
    _NFMdebug ((fname, "%d row of NFMfiles %s, cat_no %s, item_no %s , \n\
                with  %s keywords\n\
                and %d row(s) of NFMkeywords\n",
                x, file_data[index+i_filename], 
                   file_data[index+i_catno],
                   file_data[index+i_itemno],
                   file_data[index+i_keycount], y));

    if ((operation_type == NFM_ITEM ) ||
        (cat_no == atol (file_data[index+i_catno]) &&
        item_no == atol (file_data[index+i_itemno])))
    {
      if (strcmp (file_data[index+i_filename], filename) == 0)
                 
      {
        _NFMdebug ((fname, "matched the file name in both buffers\n"));
        found = 1;
        *keywords = (char *) calloc 
                   (atol(file_data[index+i_keycount]) * NFM_KEYWORD_SIZE + 
                    atol(file_data[index+i_keycount]), sizeof (char));

        for (z = handleIt = 0; z < atol (file_data[index+i_keycount]); z ++)
        {
          if ((y+z) >= NFMkeywords->rows)
          {
            _NFMdebug ((fname, 
                "Info in NFMfiles and NFMkeywords do not match\n"));
            if (*keywords == (char *) NULL)
              handleIt = 1;
            break;
          }

          k_index = (y + z) * NFMkeywords->columns;

          _NFMdebug ((fname, "Concatenate keywords [%s]\n", 
                      key_data[k_index]));
          strncat (*keywords, key_data[k_index], strlen (key_data[k_index]));
          strcat (*keywords, " ");
        }
        _NFMdebug ((fname, "The entire keywords [%s] \n", *keywords));
        break;
      }
    }
    y += atol(file_data[index+i_keycount]);
  }
  if (! found || handleIt)
  {
    _NFMdebug ((fname, "no keywords given to the file \n"));
    *keywords = (char *) calloc (1, sizeof(char));
  }


  _NFMdebug ((fname, "EXIT keywords[%s] successful\n", *keywords));
  return (NFM_S_SUCCESS);
}

long _NFMexpand_buffer (buffer, cat_name, cat_no, item_no)

MEMptr *buffer;
char *cat_name;
long cat_no, item_no;

{
  char *fname="_NFMexpand_buffer";
  char **b_data;
  char row_str[1024], temp_str[20];
  long status;
  long x, y, index;
  MEMptr new_buffer=NULL;
  long _DMbuild_ftr_buffer ();

  _NFMdebug ((fname, "ENTER\n"));

  if (_NFMdebug_st.NFMdebug_on)
    MEMprint_buffer ("buffer", *buffer, _NFMdebug_st.NFMdebug_file);

  status = _DMbuild_ftr_buffer (&new_buffer, 0);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "_DMbuild_ftr_buffer 0x%.8x\n", status));
    return (status);
  }

  status =  MEMbuild_array (*buffer);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ((fname, "MEMbuild_array 0x%.8x\n", status));
    return (status);
  }

  b_data = (char **) (*buffer)->data_ptr;

  for (x = 0, row_str[0]='\0'; x < (*buffer)->rows; x ++)
  {
    _NFMdebug ((fname, "x = %d\n", x));
    index = x * (*buffer)->columns;
    for (y = 0; y < (*buffer)->columns; y ++)
    {
      _NFMdebug ((fname, "data %s\n", b_data[index+y]));
      strcat (row_str, b_data[index+y]);
      strcat (row_str, "\1");
    }
    strcat (row_str, cat_name);
    strcat (row_str, "\1");
    sprintf (temp_str, "%d", item_no);
    strcat (row_str, temp_str);
    strcat (row_str, "\1");
    strcat (row_str, "\1\1\1");
    sprintf (temp_str, "%d", cat_no);
    strcat (row_str, temp_str);
    strcat (row_str, "\1");
    _NFMdebug ((fname, "row_str [%s]\n", row_str));
    status = MEMwrite (new_buffer, row_str);
    if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMwrite 0x%.8x\n", status));
      return (status);
    }
    row_str[0] = '\0';
  }

  MEMclose (buffer);
  *buffer = new_buffer;

  status = MEMbuild_array (*buffer);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ((fname, "MEMbuild_array (*buffer) 0x%.8x\n", status));
    return (status);
  }

  _NFMdebug ((fname, "EXIT Successful\n"));
  return (NFM_S_SUCCESS);
}

long _NFMprepare_files_buffer (cat_name, cat_no, item_name, item_rev, 
       item_no, data_list, file_list)

char *cat_name, *item_name, *item_rev;
long cat_no, item_no;
MEMptr data_list, *file_list;

{
  char *fname="_NFMprepare_files_buffer";
  char **column, row_str[1024], **data, tmp_str[1024];
  char filename[NFM_CIFILENAME+1], file_type[NFM_FILETYPE+1];
  long x, index, dumb_value;
  long status;
  long i_fileno=-1, i_cifilename=-1, i_cofilename=-1, i_filetype=-1,
       i_cisano=-1;
  struct NFMsto_info sto;
  long _DMbuild_ftr_buffer ();
  MEMptr dumb_list=NULL;

  _NFMdebug ((fname, "ENTER cat [%s] cat_no [%d] item [%s.%s] item_no [%d]\n",
              cat_name, cat_no, item_name, item_rev, item_no));

  column = (char **) data_list->column_ptr;
  for (x = 0; x < data_list->columns; x++)
  {
    _NFMdebug ((fname, "column = %s\n", column[x]));
    if (strcmp (column [x], "n_fileno") == 0)           i_fileno = x;
    else if (strcmp (column [x], "n_cifilename") == 0)  i_cifilename = x ;
    else if (strcmp (column [x], "n_cofilename") == 0)  i_cofilename = x ;
    else if (strcmp (column [x], "n_cisano") == 0)      i_cisano = x ;
    else if (strcmp (column [x], "n_filetype") == 0)    i_filetype = x ;
  }
    
  status = _DMbuild_ftr_buffer (file_list, 0);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "MEMopen 0x%.8x\n", status));
    return (status);
  }
  
  /* first row contains nothing, because this row will be overwriten
     in another function later */

  strcpy (row_str, 
       "\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1");

  status = MEMwrite (*file_list, row_str);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ((fname, "MEMwrite (%s) 0x%.8x\n", row_str, status));
    return (status);
  }

  data = (char **) data_list->data_ptr;

  for (x = 0; x < data_list->rows; x ++)
  {
    /*for each file that is requested to roll forward, put it on the buffer */
    index = x * data_list->columns;
    sto.saname[0] = '\0';
    sto.sano = atol (data[index+i_cisano]);
    /* this could be more efficient */
    status = NFMget_storage_info (&(sto.saname), &(sto.sano),
           &(sto.nodename), &(sto.username), &(sto.passwd),
           &(sto.pathname), &(sto.devicetype),
           &(sto.plattername),
           &(sto.partition), &(sto.nfs), &(sto.compress),
           &(sto.machid), &(sto.opsys), &(sto.tcpip),
           &(sto.xns),
           &(sto.decnet), &(sto.netware));
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname,
         "failed to retrieve storage area %d information\n", sto.sano));
      MEMclose (file_list);
      return (status);
    }

    if (strlen (data[index+i_cifilename]))
    {
      strcpy (filename, data[index+i_cifilename]);
    }
    else
    {
      status = NFMget_file_name (0, cat_no, atol(data[index+i_fileno]),
                                 filename);
      if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "NFMget_file_name 0x%.8x\n", status));
        MEMclose (file_list);
        return (status);
      }
    }

    _NFMdebug ((fname, "n_cifilename = %s\n", filename));

    if (i_filetype == -1)
    {
      _NFMdebug ((fname, "file type is not given\n"));

      sprintf (tmp_str, "%s f_%s %s %s",
               "select n_filetype from", cat_name, "where n_fileno =",
               data[index+i_fileno]);

      status = NFMretrieve_values (tmp_str, NFM_RETURN_STR, &file_type,
                  &dumb_value, &dumb_list);
      if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "MEMwrite [%s] 0x%.8x\n", row_str, status));
        MEMclose (file_list);
        return (status);
      }
      _NFMdebug ((fname, "file_type = %s\n", file_type));
      sprintf (row_str,
      "%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1%s\1%s\1%s\1\1\1\1\1%s\1%d\1%s\1%s\1\1%d\1",
      sto.sano, sto.nodename, sto.username, sto.passwd, sto.pathname, 
      sto.devicetype, sto.plattername, sto.partition, sto.nfs, sto.compress,
      sto.machid, sto.opsys, sto.tcpip, sto.xns, sto.decnet, sto.netware,
      data[index+i_fileno],filename, data[index+i_cofilename], 
      file_type, cat_name, item_no, item_rev, item_name, cat_no); 
      
    }
    else
    {
    sprintf (row_str,
    "%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1%s\1%s\1%s\1\1\1\1\1%s\1%d\1%s\1%s\1\1%d\1",
    sto.sano, sto.nodename, sto.username, sto.passwd, sto.pathname, 
    sto.devicetype, sto.plattername, sto.partition, sto.nfs, sto.compress,
    sto.machid, sto.opsys, sto.tcpip, sto.xns, sto.decnet, sto.netware,
    data[index+i_fileno],filename, data[index+i_cofilename], 
    data[index+i_filetype], cat_name, item_no, item_rev, item_name, cat_no); 
    }

    _NFMdebug ((fname, "row_str [%s]\n", row_str));
    
    status = MEMwrite (*file_list, row_str);
    if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMwrite [%s] 0x%.8x\n", row_str, status));
      MEMclose (file_list);
      return (status);
    }
      
  }
  
  _NFMdebug ((fname, "EXIT: successful\n"));
  return (NFM_S_SUCCESS);
}


long _NFMbuild_and_mount (files, m_files)

MEMptr files, *m_files;

{
  char *fname="_NFMbuild_and_mount";
  char remove_mt_str[10], nfs_str[10], row_str[1024];
  char **m_data;
  long status, x, index;
  struct NFMsto_info check_sto;
  long _DMbuild_ftr_buffer ();

  _NFMdebug ((fname, "ENTER:\n"));

  if (_NFMdebug_st.NFMdebug_on)
  {
    MEMprint_buffer ("files", files, _NFMdebug_st.NFMdebug_file);
  }

  status = _DMbuild_ftr_buffer (m_files, 0);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "_DMbuild_ftr_buffer 0x%.8x\n", status));
    return (status);
  }
  
  /* retrieve storage area == 4 information, _NFMftr_make_files_local
     will make all files available to the FTR engine on environment/vault
     machine using path == /usr/tmp. */

  check_sto.saname[0] = '\0';
  check_sto.sano = 4;
  status = NFMget_storage_info (&(check_sto.saname), &(check_sto.sano),
           &(check_sto.nodename), &(check_sto.username), &(check_sto.passwd),
           &(check_sto.pathname), &(check_sto.devicetype),
           &(check_sto.plattername),
           &(check_sto.partition), &(check_sto.nfs), &(check_sto.compress),
           &(check_sto.machid), &(check_sto.opsys), &(check_sto.tcpip),
           &(check_sto.xns),
           &(check_sto.decnet), &(check_sto.netware));
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname,
       "failed to retrieve storage area 4 information,  skip FTR\n"));
    MEMclose (m_files);
    return (status);
  }

  /* FTO_STATUS1 == NFM_FTR_MT_PT_REMOVE */
  sprintf (remove_mt_str, "%d", NFM_FTR_MT_PT_REMOVE);

  sprintf (row_str,
    "%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s%s%s",
    0, check_sto.nodename, check_sto.username, check_sto.passwd,
    "/usr/tmp", check_sto.devicetype, check_sto.plattername,
    check_sto.partition, check_sto.nfs, check_sto.compress,
    check_sto.machid, check_sto.opsys, check_sto.tcpip,
    check_sto.xns, check_sto.decnet, check_sto.netware,
    "\1\1\1\1\1\1", remove_mt_str, "\1\1\1\1\1\1\1\1\1");
  status = MEMwrite (*m_files, row_str);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ((fname, "MEMwrite [%s] 0x%.8x\n", row_str, status));
    MEMclose (m_files);
    return (status);
  }

  for (x = 1; x < files->rows; x ++)
  {
    _NFMdebug ((fname, "x = %d\n", x));
    status = MEMcopy_row(files, m_files, x + 1);
    if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMcopy_row (%d) 0x%.8x\n", x));
      MEMclose (m_files);
      return (status);
    }
    if (_NFMdebug_st.NFMdebug_on)
     MEMprint_buffer ("m_files", *m_files, _NFMdebug_st.NFMdebug_file);
  }


  if (_NFMdebug_st.NFMdebug_on)
    MEMprint_buffer ("m_files", *m_files, _NFMdebug_st.NFMdebug_file);

  status = MEMbuild_array (*m_files);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ((fname, "MEMbuild_array 0x%.8x\n", status));
    MEMclose (m_files);
    return (status);
  }

  m_data = (char **) (*m_files)->data_ptr;
  sprintf (nfs_str, "%d", NFM_NFS_MOVE);

  for (x = 1; x < files->rows; x++)
  {
    index = x * (*m_files)->columns;
    strcpy (row_str, m_data[index+FTO_CIFILENAME]);

    status = MEMwrite_data (*m_files, row_str, x + 1, FTO_COFILENAME+1);
    if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMwrite_data (%d) 0x%.8x\n", x, status));
      MEMclose (m_files);
      return (status);
    }   

    status = MEMwrite_data (*m_files, nfs_str, x + 1 , FTO_STATUS1+1);
    if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMwrite_data (%d NFM_MOVE) 0x%.8x\n", x, status));
      MEMclose (m_files);
      return (status);
    }   
  }

  if (_NFMdebug_st.NFMdebug_on)
    MEMprint_buffer ("after modify cofilename and status1 m_files", 
                     *m_files, _NFMdebug_st.NFMdebug_file);

  /* make file available to FTR engine */
  status = _NFMftr_make_files_local (m_files);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "_NFMftr_make_files_local 0x%.8x\n", status));
    MEMclose (m_files);
    return (status);
  }

  _NFMdebug ((fname, "EXIT successful\n"));
  return (NFM_S_SUCCESS);
}

long _DMbuild_ftr_buffer (list, size)
MEMptr *list;
long size;

{
  char *fname="_DMbuild_ftr_buffer";
  char format[30], attribute[30];
  long status;

  _NFMdebug ((fname, "ENTER:\n"));

  status = _DMbuild_fto_buffer (list,size);

  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "_DMbuild_fto_buffer 0x%.8x\n", status));
    return (status);
  }
  
  sprintf(format,"char(%d)",NFM_CATALOGNO);
  strcpy(attribute,"n_catalogno");

  status = MEMwrite_format(*list,attribute,format);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ((fname, "MEMwrite_format 0x%.8x\n", status));
    MEMclose (list);
    return (status);
  }

  if (_NFMdebug_st.NFMdebug_on)
    MEMprint_buffer ("list", *list, _NFMdebug_st.NFMdebug_file);

  _NFMdebug ((fname, "EXIT\n"));
  return (NFM_S_SUCCESS);
}

