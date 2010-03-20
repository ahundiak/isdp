#include "FImin.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"


int FI_load_FSfont (char  *fontname,
                    int    bodysize,
                    int   *actual_bodysize,
                    int   *font_id)
{
   int x;
   int loop = 0;
   int status;

   for (;;)
   {
	  if (bodysize <= 0)
		 break;

	  for (x = 0; x < _FI_num_FSfont_dirs; x++)
	  {
		 sprintf (FI_data, "%s/%s.%d", _FI_FSfont_path[x], fontname, bodysize);

		 if (access (FI_data, 0) == 0)
			break;
	  }

      /* dmb:03/13/91:FontServer has not been moved to X-world yet. */
      /*	  status = FSReadFontFile(FI_data, font_id); */
	  status = FI_LOAD_FONT_ERROR;

	  if (! status)
		 break;

      /* Loop 10 times only */

	  if (loop++ == 10)
	  {
		 *font_id = -1;
		 *actual_bodysize = -1;

		 return (FI_LOAD_FONT_ERROR);
	  }

	  bodysize -= 1;
   }

   *actual_bodysize = bodysize;

   return (FI_SUCCESS);
}


