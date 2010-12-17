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


long NFMftr_copy_item_n (cat_name, attr_cat, data_cat, attr_f_cat,
                         data_f_cat, files, keywords)

char *cat_name;
MEMptr attr_cat, data_cat, attr_f_cat, data_f_cat, files, keywords;


{
  char *fname="NFMftr_copy_item_n";
  long status;

  _NFMdebug ((fname, "ENTER cat_name [%s]\n", cat_name));
  if (_NFMdebug_st.NFMdebug_on)
  {
    MEMprint_buffer ("attr_cat", attr_cat, _NFMdebug_st.NFMdebug_file);
    MEMprint_buffer ("data_cat", data_cat, _NFMdebug_st.NFMdebug_file);
    MEMprint_buffer ("attr_f_cat", attr_f_cat, _NFMdebug_st.NFMdebug_file);
    MEMprint_buffer ("data_f_cat", data_f_cat, _NFMdebug_st.NFMdebug_file);
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

  status =  NFMcopy_item_n (cat_name, attr_cat, data_cat, attr_f_cat,
                         data_f_cat);

  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "NFMcheckin_item 0x%.8x\n", status));
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

