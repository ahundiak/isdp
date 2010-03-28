/*
Name
        GRlist

Description
        These functions relate to the list of writable files maintained in the
        reference file manager object.
*/

class implementation Super_rfmgr;

#include <sys/param.h>
#include "grimport.h"
#include "igetypedef.h"
#include "igr.h"
#include "madef.h"
#include "godef.h"
#include "exdef.h"
#include "gr.h"
#include "grerr.h"
#include "exmacros.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "ex.h"
#include "OMmacros.h"
#include "msdef.h"
#include "refpriv.h"
#include "grdpbmacros.h"
#include "grgsdef.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIprims.h"
#include "DIglob.h"
#include "DImacros.h"
#include "refdef.h"

%safe
char *force_tag = ":fw";
%endsafe

method add ( long *msg; char *file_name )
{
  int status = OM_S_SUCCESS;
  
  /* make sure it's not already there */
  om$send ( msg = message Super_rfmgr.translate ( msg, file_name ),
            targetid = my_id );
  if (*msg != MSSUCC)
  {
    /* put it in */
    int len = strlen ( file_name ) + 1,
        size = om$dimension_of ( varray = me->names );
    
    status = om$vla_set_dimension ( size = size + len, varray = me->names );
    if (status == OM_S_SUCCESS)
    {
      strcpy ( &me->names [size], file_name );
      *msg = MSSUCC;
    }
  }

  return status;
}


method translate(long *msg; char *file_name)
{
    int i, size = om$dimension_of(varray = me->names), status = OM_S_SUCCESS;
    char full_name[DI_PATH_MAX], tmp_full_name[DI_PATH_MAX], *tag;
  
    strcpy(full_name, file_name);
    module_build_path(full_name);
    for (i = 0, *msg = MSFAIL; i < size;)
    {
        strcpy(tmp_full_name, &me->names[i]);
        module_build_path(tmp_full_name);
        if (tag = strstr(tmp_full_name, force_tag))
            *tag = NULL;
        if (!strcmp(full_name, tmp_full_name))
        {
            *msg = MSSUCC;
            break;
        }
        else
            i += strlen(&me->names[i]) + 1;
    }

    return status;
}

method debug ()
{
  int i, size = om$dimension_of ( varray = me->names );
  
  if (!size)
    printf ( "no file names\n" );
  else
    for (i = 0; i < size; )
    {
      printf ( "file name [%2d]: '%s'\n", i, &me->names [i] );
      i += strlen ( &me->names [i] ) + 1;
    }

  return OM_S_SUCCESS;
}


method remove_file_name ( long *msg; char *file_name )
{
  int i, size = om$dimension_of ( varray = me->names ), status = OM_S_SUCCESS;
  char *c, tagged_name[MAXPATHLEN];

  for (i = 0, *msg = MSFAIL; i < size; )
  {
      if (c = strstr(&me->names[i], force_tag))
      {
          strcpy(tagged_name, &me->names[i]);
          tagged_name[(int)(c - &me->names[i])] = NULL;
          c = tagged_name;
      }
      else
          c = &me->names[i];
      if (!strcmp(file_name, c))
      {
          /* we found it, let's remove it */
          int len = strlen(&me->names[i]) + 1;
          memcpy(&me->names [i], &me->names [i + len], size - i);
          status = om$vla_set_dimension(size = size - len, varray = me->names);
          if (status & 1)
              *msg = MSSUCC;
          if (size == len)
              /* we are done */
              break;
      }
      else
          i += strlen(&me->names [i]) + 1;
  }

  return status;
}

/*
Name
        force_add

Description
        This method adds the file name to the list.  The name is marked with a
        tag to indicate that it was forced into the list.  This is used by PDU
        through the function GRforce_writable.  See that function for more
        explanation.

Notes
        If the name is already present in the list, then the force write tag
        is added to the entry.  This is in place so that the write state of a
        reference file attachment is easily predictable.  The rule is that
        once a force write has been added to an attachment, whether new or
        existing, then that attachment will always behave as a force write
        attachment.  In other words, once PDU touches it, the attachment
        always behaves like a PDU attachment.

History
        mrm     10/29/92     creation
*/

method force_add (long *msg; char *file_name)
{
    int status = OM_S_SUCCESS;
    int need_to_add = TRUE;

    /* check whether the name is already in the list */
    om$send(msg = message Super_rfmgr.translate(msg, file_name),
            targetid = my_id);
    if (*msg & 1)
    {
        /* ok, it's there - does it have the force mark? */
        om$send(msg = message Super_rfmgr.force_translate(msg, file_name),
                targetid = my_id);
        if (*msg & 1)
            /* already there, happy as a clam */
            need_to_add = FALSE;
        else
            /* it doesn't have the mark, so delete it (& add it back below) */
            om$send(msg = message Super_rfmgr.remove_file_name(msg, file_name),
                    targetid = my_id);
    }

    if (need_to_add)
    {
        int len, size;
        char tagged_name[MAXPATHLEN];

        /* add the tag for future reference */
        strcpy(tagged_name, file_name);
        strcat(tagged_name, force_tag);

        /* put it in */
        len = strlen(tagged_name) + 1,
        size = om$dimension_of(varray = me->names);
        status = om$vla_set_dimension(size = size + len, varray = me->names);
        if (status == OM_S_SUCCESS)
        {
            strcpy(&me->names[size], tagged_name);
            *msg = MSSUCC;
        }
    }

    return status;
}

/*
Name
        force_translate

Description
        This method checks whether the file name was added to the list through
        the force_add method.

History
        mrm     10/29/92     creation
*/

method force_translate(long *msg; char *file_name)
{
    int i, size = om$dimension_of(varray = me->names), status = OM_S_SUCCESS;
    char full_name[DI_PATH_MAX], tmp_full_name[DI_PATH_MAX];
  
    strcpy(full_name, file_name);
    strcat(full_name, force_tag);
    module_build_path(full_name);
    for (i = 0, *msg = MSFAIL; i < size;)
    {
        strcpy(tmp_full_name, &me->names[i]);
        module_build_path(tmp_full_name);
        if (!strcmp(full_name, tmp_full_name))
        {
            *msg = MSSUCC;
            break;
        }
        else
            i += strlen(&me->names[i]) + 1;
    }

    return status;
}

end implementation Super_rfmgr;
