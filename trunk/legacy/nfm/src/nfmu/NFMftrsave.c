#include <stdio.h>
#include "DEBUG.h"
#include "ERR.h"
#include "NFMerrordef.h"
#include "MEMstruct.h"
#include "NFMapi.h"

extern long NFM_FTR_INITED;
extern long DM_MANAGER;

extern MEMptr NFMfiles;
extern MEMptr NFMkeywords;


long NFMftr_save_item_files (catalog_name, item_name, item_revision,
                           files, keywords)

char *catalog_name; /* item's catalog */
char *item_name; /* item's name */
char *item_revision; /* item's revision */
MEMptr files, keywords;

{
  char *fname="NFMftr_save_item_files";
  long status;

  _NFMdebug ((fname, "ENTER\n"));
  if (_NFMdebug_st.NFMdebug_on)
  {
    MEMprint_buffer ("files", files, _NFMdebug_st.NFMdebug_file);
    MEMprint_buffer ("keywords", keywords, _NFMdebug_st.NFMdebug_file);
  }

  /* is FTR engine enable?
     yes - load into the global variable;
     no - ignore the keywords */
 

  if (NFM_FTR_INITED)
  {
    _NFMdebug ((fname, 
      "FTR engine is available, assign into global variable\n"));

    /* Make sure files and keywords have values in them and MEMbuild_array
       both of them successfully before assign to the global variables */

    if ((files != (MEMptr) NULL) && (keywords != (MEMptr) NULL))
    {
      _NFMdebug ((fname, "files != keywords != NULL\n"));
      status = MEMbuild_array (files);
      if (status != MEM_S_SUCCESS)
      {
        _NFMdebug ((fname, "MEMbuild_array (files) 0x%.8x\n", status));
      }
      else
      {
        status = MEMbuild_array (keywords);
        if (status != MEM_S_SUCCESS)
        {
          _NFMdebug ((fname, "MEMbuild_array (keywords) 0x%.8x\n", status));
        }
        else
        {
          NFMfiles = files;
          NFMkeywords = keywords;          
        }
      } 
    }
  }
  else
  {
    /* no, ignore the keywords input */
    _NFMdebug ((fname, 
      "FTR engine is not available, ignore the keywords\n"));
  }

  if (NFM_FTR_INITED && _NFMdebug_st.NFMdebug_on)
  {
    MEMprint_buffer ("NFMfiles", NFMfiles, _NFMdebug_st.NFMdebug_file);
    MEMprint_buffer ("NFMkeywords", NFMkeywords, _NFMdebug_st.NFMdebug_file);
  }


  /* call existing checkin code */

  status = NFMsave_item_files (catalog_name, item_name, item_revision);

  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "NFMsave_item 0x%.8x\n", status));
    NFMfiles = (MEMptr) NULL;
    NFMkeywords = (MEMptr) NULL;
    return (status);
  }

  /* assign global variable to NULL; input parameter (files and keywords)
     will be MEMclosed in NFMS layer */

  NFMfiles = (MEMptr) NULL;
  NFMkeywords = (MEMptr) NULL;

  _NFMdebug ((fname, "EXIT: successful\n"));
  return (NFM_S_SUCCESS);
}

long NFMftr_save_set_files (catalog_name, set_name, set_revision,
                           files, keywords)

char *catalog_name; /* item's catalog */
char *set_name; /* item's name */
char *set_revision; /* item's revision */
MEMptr files, keywords;

{
  char *fname="NFMftr_save_set_files";
  long status;

  _NFMdebug ((fname, "ENTER\n"));
  if (_NFMdebug_st.NFMdebug_on)
  {
    MEMprint_buffer ("files", files, _NFMdebug_st.NFMdebug_file);
    MEMprint_buffer ("keywords", keywords, _NFMdebug_st.NFMdebug_file);
  }

  /* is FTR engine enable?
     yes - load into the global variable;
     no - ignore the keywords */
 

  if (NFM_FTR_INITED)
  {
    _NFMdebug ((fname, 
      "FTR engine is available, assign into global variable\n"));

    /* Make sure files and keywords have values in them and MEMbuild_array
       both of them successfully before assign to the global variables */

    if ((files != (MEMptr) NULL) && (keywords != (MEMptr) NULL))
    {
      _NFMdebug ((fname, "files != keywords != NULL\n"));
      status = MEMbuild_array (files);
      if (status != MEM_S_SUCCESS)
      {
        _NFMdebug ((fname, "MEMbuild_array (files) 0x%.8x\n", status));
      }
      else
      {
        status = MEMbuild_array (keywords);
        if (status != MEM_S_SUCCESS)
        {
          _NFMdebug ((fname, "MEMbuild_array (keywords) 0x%.8x\n", status));
        }
        else
        {
          NFMfiles = files;
          NFMkeywords = keywords;          
        }
      } 
    }
  }
  else
  {
    /* no, ignore the keywords input */
    _NFMdebug ((fname, 
      "FTR engine is not available, ignore the keywords\n"));
  }

  if (NFM_FTR_INITED && _NFMdebug_st.NFMdebug_on)
  {
    MEMprint_buffer ("NFMfiles", NFMfiles, _NFMdebug_st.NFMdebug_file);
    MEMprint_buffer ("NFMkeywords", NFMkeywords, _NFMdebug_st.NFMdebug_file);
  }


  /* call existing checkin code */

  status = NFMsave_set_files (catalog_name, set_name, set_revision);

  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "NFMsave_set 0x%.8x\n", status));
    NFMfiles = (MEMptr) NULL;
    NFMkeywords = (MEMptr) NULL;
    return (status);
  }

  /* assign global variable to NULL; input parameter (files and keywords)
     will be MEMclosed in NFMS layer */

  NFMfiles = (MEMptr) NULL;
  NFMkeywords = (MEMptr) NULL;

  _NFMdebug ((fname, "EXIT: successful\n"));
  return (NFM_S_SUCCESS);
}


