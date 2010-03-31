/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
#include "EMS.h"
/* 
 * DESCRIPTION
 *
 * The purpose of this routine is to remove all groups that have less than
 * two members.  The groups are generated by the surface/surface intersection
 * routine.
 *
 * RETURN VALUES
 *
 * status               if TRUE then no problems else failure
 * number_of_groups     resulting number of groups
 * points_per_group     resulting number of points per group
 * xyz_group            resulting model space points
 * uv1_group            resulting uv points in parametric space 1
 * uv2_group            resulting uv points in parametric space 2
 * msg                  MSSUCC if sucess (it is always MSSUCC)
 *
 * NOTES
 *
 * none
 *
 * HISTORY
 *
 * 01/05/87 : rlw : creation date
 * 01/29/87 : rlw : modified free to check for NULL pointers
 *
 */

/* igr.h replacement */


# ifndef msdef_include
# include "msdef.h" /* MS message codes */
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

/* end of igr.h replacement */
#include "bs.h"

IGRboolean EFcompress_groups(
            number_of_groups,           /* Number of sets of data */
            points_per_group,           /* Number of points in each set */
            xyz_group,                  /* Sets for model space */
            uv1_group,                  /* Sets for parametric space srf 1 */
            uv2_group,                  /* Sets for parametric space srf 2 */
            msg)                        /* Error return code */

IGRlong         *number_of_groups;
IGRlong         **points_per_group;
IGRpoint        ***xyz_group;
BSpair          ***uv1_group;
BSpair          ***uv2_group;
IGRlong         *msg;

{
 IGRlong        i, j, k;
/*
 * Initialize
 */
 *msg = MSSUCC;
/*
 * Loop around all the groups
 */
 i = 0;
 while (i < *number_of_groups)
  {
/*
 * If there are less than 2 members in any group then remove this group
 * by freeing the space for the linestrings and then compress the pointer
 * arrays.
 */
   if ((*points_per_group)[i] < 2)
    {
     (*number_of_groups)--;
     if ((*xyz_group)[i]) free((*xyz_group)[i]);
     if ((*uv1_group)[i]) free((*uv1_group)[i]);
     if (uv2_group && (*uv2_group)[i]) free((*uv2_group)[i]);
     for (j = i; j < *number_of_groups; j++)
      {
       k = j + 1;
       (*xyz_group)[j] = (*xyz_group)[k];
       (*uv1_group)[j] = (*uv1_group)[k];
       if (uv2_group) (*uv2_group)[j] = (*uv2_group)[k];
       (*points_per_group)[j] = (*points_per_group)[k];
      }
    }
   else
    i++;
  }
/*
 * End of routine
 */
 return(TRUE);
}
