#include <stdio.h>
#include "OMerrordef.h"
#include "OMversion.h"
#include "version.h"

extern int Model_compare_version();

INGR_S_PRODUCT_DEF MODEL_appl_version_id = {"I/MODEL 03.03.00.20 27-Jul-10",
 Model_compare_version};

int Model_compare_version( curr_ver, file_ver )

char *curr_ver, *file_ver;
{
  int c1,c2,c3,c4, cnt1, cnt2;
  int f1,f2,f3,f4;

  cnt1 = sscanf(curr_ver,"%*7s %d %*c %d %*c %d %*c %d", &c1,&c2,&c3,&c4);
  cnt2 = sscanf(file_ver,"%*7s %d %*c %d %*c %d %*c %d", &f1,&f2,&f3,&f4);

/*
 * If the filed version is corrupt for any reason then allow the file to
 * come up.
 */

  if (cnt2 != 4)
   return (OM_S_SUCCESS);

/*
 * If the first digit of the current version is not equal to the filed version
 * or
 * if the first digits match up but the second digit of the filed version
 * is greater than the current version then
 * do not allow the file to come up
 */

  if ((c1 != f1) || ((c1 == f1) && (c2 < f2)))
  {
    if ((c1 == 03) && (f1 == 02))
    {
      if (f2 == 04)
      {
        fprintf (stderr,
                 "Version  %s %s%s",
                 file_ver,
                 "was created with pre-release software\n",
                 "and is not supported.\n");
        return (OM_F_VERSION_MISMATCH);
      }
      else
      {
        return (OM_S_SUCCESS);
      }
    }
    else
    {
      fprintf (stderr,"Current Version %s \n", curr_ver);
      fprintf (stderr,"Filed Version   %s \n", file_ver);
      return (OM_F_VERSION_MISMATCH);
    }
  }
  else if ((f1 == 03) && (f2 == 00) && (f3 == 00) && (f4 < 28))
  {
    fprintf (stderr,
             "Version %s %s%s",
             file_ver,
             "was created with pre-release software\n",
             "and is not supported.\n");
    return (OM_F_VERSION_MISMATCH);
  }
  else
  {
    return( OM_S_SUCCESS);
  }
}
