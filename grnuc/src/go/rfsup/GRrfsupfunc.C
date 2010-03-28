#include "igrtypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "igrdp.h"
#include "grimport.h"
#include "godef.h"
#include "msdef.h"
#include "dpdef.h"
#include "referr.h"
#include "refdef.h"
#include "refpriv.h"
#include "exdef.h"
#include "exmacros.h"
#include "dpmacros.h"
#include "dpsavevw.h"
#include "OMmacros.h"
#include "grerr.h"
#include "go.h"
#include "grdpb.h"
#include "grdpbmacros.h"


/*

  Name

   GRrfaddshwr

  Abstract

   This function will fill the reference file GRids list to be 
   shrink/wrapped after the display was sent to the reference file.

  Arguments

   struct GRid  *ref_id;

  Return Values

    -OM_S_SUCCESS if successful
    -OM_E_ABORT if failure

  History

   Gang  07/08/93   Creation.

*/

/* ref_list contains the GRids of the reference file attachments which are
   to be shrink/wrapped.
 */

#define GR_DEF_MEM_SIZE 100

static struct GRid *ref_list = NULL;
static IGRlong ref_count = 0;
static IGRlong malloc_size = 0;

IGRint GRrfaddshwr(ref_id)
struct GRid *ref_id; /* I GRid of the reference file */
{
   IGRlong OMmsg;
    
   OMmsg = OM_S_SUCCESS;

   if(malloc_size == 0)
     {
        malloc_size = GR_DEF_MEM_SIZE;
        ref_list = (struct GRid *) malloc(sizeof(struct GRid) * malloc_size);

        if(ref_list == NULL)
         {
           OMmsg = OM_E_ABORT;
           goto wrapup;
         }
     }

   if(ref_count >= malloc_size)
    {
        malloc_size += GR_DEF_MEM_SIZE;
        ref_list = (struct GRid *)realloc(ref_list,
                                         sizeof(struct GRid) * malloc_size);
        if(ref_list == NULL)
         {
           OMmsg = OM_E_ABORT;
           goto wrapup;
         }
    }

   ref_list[ref_count].objid = ref_id->objid;
   ref_list[ref_count].osnum = ref_id->osnum;
   ref_count += 1;

wrapup:
   return OMmsg;
}

/*

  Name

    GRupdshwrclip

  Abstract

    This function will do the shrink/wrap clipping polygon of the
    referencve files in the static array ref_list. This function will
    be called by the wfi after the display was sent to the reference file.
    And this function will delete itself from the wfi.


  Return Values

    -MSSUCC if successful
    -MSFAIL if failure

  History

   Gang  07/08/93   Creation.
   WBC   08/19/93   Checking to make sure ref_list is not NULL before trying
                    to free it, then setting it to NULL after it's been freed.
*/


IGRint GRupdshwrclip()
{
  IGRlong  OMmsg,i;
  IGRint msg;

  OMmsg = OM_S_SUCCESS;
  msg = MSSUCC;

  for(i= 0; i < ref_count; i++)
    {
      OMmsg = GRrfshwrclip(&msg,&ref_list[i]);
    }

  ex$del_function(fun = GRupdshwrclip, mode = EX_START_FUNC);

  if (ref_list)
  {
    free(ref_list);
    ref_list = NULL;
  }
  ref_count = 0;
  malloc_size = 0;
  return OMmsg;

}


IGRint GRfindrefpath(filename,
                     reffilename)
IGRchar *filename;
IGRchar *reffilename;
{
      char *RefPath, *getenv ();

      /*
       * Find the guy. If REFPATH is defined then it defines a search
       * path for the reference files else we try the osname (full name)
       * and then the file name (whatever the guy keyed in). If nothing
       * works then we forget it.
       * Note that REFPATH follows the usual UNIX search path syntax (like
       * PATH, CDPATH, ...): <path1>:<path2>:...:<pathn>.
       * Also, we ALWAYS look in the current directory (even if path name
       * doesn't contain it).
       */
      if (RefPath = getenv ( "REFPATH" ))
      {
        char *pString1, *pString2, PathName [DI_PATH_MAX];
        int  Stop, Found;

        for (pString1 = pString2 = RefPath, Found = Stop = 0; !Stop;)
        {
          /*
           * Look for the next ':' or end of string
           */
          for (; *pString2 && *pString2 != ':'; pString2++);

          /*
           * Replace the ':' by a '\0' for string operations
           */
          if (*pString2 == ':')
            *pString2 = '\0';
          else
            Stop = 1;

          if (!*PathName)
            strcpy ( PathName, "." );

          strcat ( strcat ( strcpy ( PathName, pString1 ), "/" ), filename );
          if (!Stop)
          {
            *pString2 = ':';
            pString1 = ++pString2;
          }

          /*
           * We must stop if we've found the file
           */
          if (Found = !access ( PathName, 0 ))
            Stop = 1;
        }

        strcpy ( reffilename, Found ? PathName : filename );
      }
      else
        strcpy ( reffilename, filename );

  return(1);
}
