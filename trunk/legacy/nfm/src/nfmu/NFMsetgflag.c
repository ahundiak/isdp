#include "machine.h"
#include "NFMerrordef.h"
#include "NFMitems.h"
#include "NFMstruct.h"
#include "NFMitemfiles.h"
#include "ERR.h"
#include "DEBUG.h"

extern struct NFMglobal_st NFMglobal;

long NFMset_load_item_files (flag)

long flag; /* possible value: NFM_LOAD_ITEM_FILE,
                              NFM_NO_LOAD_ITEM_FILE */

/***
  This function will set the value of NFMglobal.load_item_file according the
  input flag.  (This function is written for PDM. If NFMglobal.load_item_file
  is == NFM_LOAD_ITEM_FILE, in all file tranfer code, items and files 
  information will be loaded into the global variable so PDM can access the
  information without query database. )


***/

{
  char *fname="NFMset_load_item_files";

  _NFMdebug ((fname, "ENTER: flag == %d\n", flag));
  if (flag != NFM_NO_LOAD_ITEM_FILE && flag != NFM_LOAD_ITEM_FILE)
  {
    _NFMdebug ((fname, "Invalid flag\n"));
    ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
      "Invalid flag");
    return (NFM_E_FAILURE);
  }

  NFMglobal.load_item_file = flag;

  _NFMdebug ((fname, "EXIT: 0x%.8x\n", NFM_S_SUCCESS));
  return (NFM_S_SUCCESS);
}
  
