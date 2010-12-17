#include "machine.h"
#include <string.h>
#include "NFMstruct.h"
#include "NFMerrordef.h"
#include "MSGstruct.h"

#define NULLCHAR (char *) 0

extern struct NFMitem_info *NFMitem_ptr;
extern MSGptr NFMmsg_ptr;


_NFMprint_global_item_ptr ()

{

  /***
  This function is used to print out the variable of the structure NFMitem_info,
  it is an internal function for debug purpose.

  ***/
  
  char *tokptr, *strptr;
  int  already_on=0;

  
  if (NFMmsg_ptr.debug_on)
    already_on = 1;
  else
  {
    NFMmsg_ptr.debug_on = 1;
    strcpy (NFMmsg_ptr.debug_file, "/usr/nfmadmin/dbg.out");
  }

  _NFM_str ("_NFMprint_global_item_ptr: enter ......");
  _NFM_num ("NFMitem_ptr->table_no = %d ", NFMitem_ptr->table_no);
  _NFM_num ("NFMitem_ptr->ftable_no = %d ", NFMitem_ptr->ftable_no); 


  if (strcmp (NFMitem_ptr->cat_item.n_itemno.attr_name, "\0"))
  {
    _NFM_num ("NFMitem_ptr->cat_item.n_itemno.attr_name = %s",
                           NFMitem_ptr->cat_item.n_itemno.attr_name);
    _NFM_num ("NFMitem_ptr->cat_item.n_itemno.attr_dtype = %s",
                           NFMitem_ptr->cat_item.n_itemno.attr_dtype);
    if (NFMitem_ptr->cat_item.n_itemno.data_count)
    {
      strptr = (char *) NFMitem_ptr->cat_item.n_itemno.data_value;

      while ( (tokptr = strtok (strptr, "\t")) != NULLCHAR)
      {
        _NFM_str("NFMitem_ptr->cat_item.n_itemno->data_value = %s\n", tokptr);
        strptr = NULLCHAR;
      }
    }
  }

  if (strcmp (NFMitem_ptr->cat_item.n_itemname.attr_name, "\0"))
  {
    _NFM_num ("NFMitem_ptr->cat_item.n_itemname.attr_name = %s",
                           NFMitem_ptr->cat_item.n_itemname.attr_name);
    _NFM_num ("NFMitem_ptr->cat_item.n_itemname.attr_dtype = %s",
                           NFMitem_ptr->cat_item.n_itemname.attr_dtype);
    if (NFMitem_ptr->cat_item.n_itemname.data_count)
    {
      strptr = (char *)NFMitem_ptr->cat_item.n_itemname.data_value;

      while ( (tokptr = strtok (strptr, "\t")) != NULLCHAR)
      {
        _NFM_str("NFMitem_ptr->cat_item.n_itemname->data_value = %s\n", 
                                                                       tokptr);
        strptr = NULLCHAR;
      }
    }
  }
  if (strcmp (NFMitem_ptr->cat_item.n_itemrev.attr_name, "\0"))
  {
    _NFM_num ("NFMitem_ptr->cat_item.n_itemrev.attr_name = %s",
                           NFMitem_ptr->cat_item.n_itemrev.attr_name);
    _NFM_num ("NFMitem_ptr->cat_item.n_itemrev.attr_dtype = %s",
                           NFMitem_ptr->cat_item.n_itemrev.attr_dtype);
    if (NFMitem_ptr->cat_item.n_itemrev.data_count)
    {
      strptr = (char *) NFMitem_ptr->cat_item.n_itemrev.data_value;

      while ( (tokptr = strtok (strptr, "\t")) != NULLCHAR)
      {
        _NFM_str("NFMitem_ptr->cat_item.n_itemrev->data_value = %s\n", tokptr);
        strptr = NULLCHAR;
      }
    }
  }

  if (strcmp (NFMitem_ptr->cat_item.n_archivestate.attr_name, "\0"))
  {
    _NFM_num ("NFMitem_ptr->cat_item.n_archivestate.attr_name = %s",
                           NFMitem_ptr->cat_item.n_archivestate.attr_name);
    _NFM_num ("NFMitem_ptr->cat_item.n_archivestate.attr_dtype = %s",
                           NFMitem_ptr->cat_item.n_archivestate.attr_dtype);
    if (NFMitem_ptr->cat_item.n_archivestate.data_count)
    {
      strptr = (char *) NFMitem_ptr->cat_item.n_archivestate.data_value;

      while ( (tokptr = strtok (strptr, "\t")) != NULLCHAR)
      {
        _NFM_str("NFMitem_ptr->cat_item.n_archivestate->data_value = %s\n", 
									tokptr);
        strptr = NULLCHAR;
      }
    }
  }
  if (strcmp (NFMitem_ptr->cat_item.n_coout.attr_name, "\0"))
  {
    _NFM_num ("NFMitem_ptr->cat_item.n_coout.attr_name = %s",
                           NFMitem_ptr->cat_item.n_coout.attr_name);
    _NFM_num ("NFMitem_ptr->cat_item.n_coout.attr_dtype = %s",
                           NFMitem_ptr->cat_item.n_coout.attr_dtype);
    if (NFMitem_ptr->cat_item.n_coout.data_count)
    {
      strptr = (char *) NFMitem_ptr->cat_item.n_coout.data_value;

      while ( (tokptr = strtok (strptr, "\t")) != NULLCHAR)
      {
        _NFM_str("NFMitem_ptr->cat_item.n_coout->data_value = %s\n", tokptr);
        strptr = NULLCHAR;
      }
    }
  }

  if (strcmp (NFMitem_ptr->cat_item.n_itemlock.attr_name, "\0"))
  {
    _NFM_num ("NFMitem_ptr->cat_item.n_itemlock.attr_name = %s",
                           NFMitem_ptr->cat_item.n_itemlock.attr_name);
    _NFM_num ("NFMitem_ptr->cat_item.n_itemlock.attr_dtype = %s",
                           NFMitem_ptr->cat_item.n_itemlock.attr_dtype);
    if (NFMitem_ptr->cat_item.n_itemlock.data_count)
    {
      strptr = (char *) NFMitem_ptr->cat_item.n_itemlock.data_value;

      while ( (tokptr = strtok (strptr, "\t")) != NULLCHAR)
      {
        _NFM_str("NFMitem_ptr->cat_item.n_itemlock->data_value = %s\n", tokptr);
        strptr = NULLCHAR;
      }
    }
  }

  if (strcmp (NFMitem_ptr->cat_item.n_versionlimit.attr_name, "\0"))
  {
    _NFM_num ("NFMitem_ptr->cat_item.n_versionlimit.attr_name = %s",
                           NFMitem_ptr->cat_item.n_versionlimit.attr_name);
    _NFM_num ("NFMitem_ptr->cat_item.n_versionlimit.attr_dtype = %s",
                           NFMitem_ptr->cat_item.n_versionlimit.attr_dtype);
    if (NFMitem_ptr->cat_item.n_versionlimit.data_count)
    {
      strptr = (char *) NFMitem_ptr->cat_item.n_versionlimit.data_value;

      while ( (tokptr = strtok (strptr, "\t")) != NULLCHAR)
      {
        _NFM_str("NFMitem_ptr->cat_item.n_versionlimit->data_value = %s\n", tokptr);
        strptr = NULLCHAR;
      }
    }
  }

  if (strcmp (NFMitem_ptr->fcat_item.n_itemnum.attr_name, "\0"))
  {
    _NFM_num ("NFMitem_ptr->fcat_item.n_itemnum.attr_name = %s",
                           NFMitem_ptr->fcat_item.n_itemnum.attr_name);
    _NFM_num ("NFMitem_ptr->fcat_item.n_itemnum.attr_dtype = %s",
                           NFMitem_ptr->fcat_item.n_itemnum.attr_dtype);
    if (NFMitem_ptr->fcat_item.n_itemnum.data_count)
    {
      strptr = (char *) NFMitem_ptr->fcat_item.n_itemnum.data_value;

      while ( (tokptr = strtok (strptr, "\t")) != NULLCHAR)
      {
        _NFM_str("NFMitem_ptr->fcat_item.n_itemnum->data_value = %s\n", tokptr);
        strptr = NULLCHAR;
      }
    }
  }
  if (strcmp (NFMitem_ptr->fcat_item.n_fileclass.attr_name, "\0"))
  {
    _NFM_num ("NFMitem_ptr->fcat_item.n_fileclass.attr_name = %s",
                           NFMitem_ptr->fcat_item.n_fileclass.attr_name);
    _NFM_num ("NFMitem_ptr->fcat_item.n_fileclass.attr_dtype = %s",
                           NFMitem_ptr->fcat_item.n_fileclass.attr_dtype);
    if (NFMitem_ptr->fcat_item.n_fileclass.data_count)
    {
      strptr = (char *) NFMitem_ptr->fcat_item.n_fileclass.data_value;

      while ( (tokptr = strtok (strptr, "\t")) != NULLCHAR)
      {
        _NFM_str("NFMitem_ptr->fcat_item.n_fileclass->data_value = %s\n", 
									tokptr);
        strptr = NULLCHAR;
      }
    }
  }
  if (strcmp (NFMitem_ptr->fcat_item.n_fileversion.attr_name, "\0"))
  {
    _NFM_num ("NFMitem_ptr->fcat_item.n_fileversion.attr_name = %s",
                           NFMitem_ptr->fcat_item.n_fileversion.attr_name);
    _NFM_num ("NFMitem_ptr->fcat_item.n_fileversion.attr_dtype = %s",
                           NFMitem_ptr->fcat_item.n_fileversion.attr_dtype);
    if (NFMitem_ptr->fcat_item.n_fileversion.data_count)
    {
      strptr = (char *) NFMitem_ptr->fcat_item.n_fileversion.data_value;

      while ( (tokptr = strtok (strptr, "\t")) != NULLCHAR)
      {
        _NFM_str("NFMitem_ptr->fcat_item.n_fileversion->data_value = %s\n", 
									tokptr);
        strptr = NULLCHAR;
      }
    }
  }
/***
  if (strcmp (NFMitem_ptr->fcat_item.n_pendingflag.attr_name, "\0"))
  {
    _NFM_num ("NFMitem_ptr->fcat_item.n_pendingflag.attr_name = %s",
                           NFMitem_ptr->fcat_item.n_pendingflag.attr_name);
    _NFM_num ("NFMitem_ptr->fcat_item.n_pendingflag.attr_dtype = %s",
                           NFMitem_ptr->fcat_item.n_pendingflag.attr_dtype);
    if (NFMitem_ptr->fcat_item.n_pendingflag.data_count)
    {
      strptr = (char *)NFMitem_ptr->fcat_item.n_pendingflag.data_value;

      while ( (tokptr = strtok (strptr, "\t")) != NULLCHAR)
      {
        _NFM_str("NFMitem_ptr->fcat_item.n_pendingflag->data_value = %s\n", 
									tokptr);
        strptr = NULLCHAR;
      }
    }
  }
***/

  if (strcmp (NFMitem_ptr->fcat_item.n_cifilename.attr_name, "\0"))
  {
    _NFM_num ("NFMitem_ptr->fcat_item.n_cifilename.attr_name = %s",
                           NFMitem_ptr->fcat_item.n_cifilename.attr_name);
    _NFM_num ("NFMitem_ptr->fcat_item.n_cifilename.attr_dtype = %s",
                           NFMitem_ptr->fcat_item.n_cifilename.attr_dtype);
    if (NFMitem_ptr->fcat_item.n_cifilename.data_count)
    {
      strptr = (char *)NFMitem_ptr->fcat_item.n_cifilename.data_value;

      while ( (tokptr = strtok (strptr, "\t")) != NULLCHAR)
      {
        _NFM_str("NFMitem_ptr->fcat_item.n_cifilename->data_value = %s\n", 
									tokptr);
        strptr = NULLCHAR;
      }
    }
  }

  _NFM_str ("_NFMprint_global_item_ptr: exit ......");
  if (! already_on)
    NFMmsg_ptr.debug_on = 0;
  return (NFM_S_SUCCESS);

}
