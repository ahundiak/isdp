#include "EMS.h"
# include "OMprimitives.h"  /* om$malloc            */
# include "OMmacros.h"      /* OM_BLOCK_MOVE        */
# include "msdef.h"         /* MSSUCC               */
# include "EMSmsgdef.h"     /* EMS error codes      */
# include "EMSlogic.h"      /* EMSmsgReport         */
# include "EMStypedef.h"    /* EMSmsgReport         */
# include "EMScmacros.h"    /* EMSmsgReport         */
# include "igrtypedef.h"    /* IGR...               */
# include "igr.h"           /* IGR...               */
# include "igrdp.h"         /* IGResqbs             */
#include "bserr.h"
#include "bssfeval.h"

/*
  HISTORY

       Sudha   25-Jun-93       Modified for BSprototype ansification
*/


# define LOCAL_BUFFER_SIZE  800

void EFrltEndPts(EMmsg, surface, rlt, uvbuffer, xyzbuffer, buffer_size,
                 num_points, uv_points, xyz_points)

IGRlong                 *EMmsg;
struct IGRbsp_surface   *surface;
struct IGResqbs         *rlt;
IGRdouble               *uvbuffer;
IGRdouble               *xyzbuffer;
IGRint                  buffer_size;
IGRint                  *num_points;
IGRdouble               **uv_points;
IGRdouble               **xyz_points;
{
  IGRint            i;
  IGRint            sizeofIGRdouble;


  /*
   * Initialize
   */
  *EMmsg = MSSUCC;
  *num_points = 0;
  sizeofIGRdouble = sizeof(IGRdouble);

  /*
   * Calculate the number of endpoints
   */
  {
    IGRint      *num_bound, uv, rules;
    IGRdouble   **bdrys;

    /*
     * Set up to count endpoints for the u rule lines.
     */
    rules = rlt->u_rules;
    num_bound = rlt->u_num_bound;
    bdrys = rlt->u_bdrys;
    for(uv = U; uv <= V; uv ++)
    {
      for(i = 0; i < rules; i ++)
      {
        /*
         * If the rule line is clipped, the number of points
         * is equal to the number of boundaries with the
         * following adjustments:
         *  -1 if the first clip point is 0, else +1
         *  -1 if the last clip point is 1, else +1
         * If the rule line is unclipped, there are 2 points.
         */
        if(num_bound[i])
        {
          *num_points += (num_bound[i] + num_bound[i]);

          if(bdrys[i][0] IS 0.0) (*num_points) --;
          else (*num_points) ++;

          if(bdrys[i][num_bound[i] * 2 - 1] IS 1.0) (*num_points) --;
          else (*num_points) ++;
        }

        else *num_points += 2;

      } /* for i */

      /*
       * On the second pass, use the v rule lines.
       */
      rules = rlt->v_rules;
      num_bound = rlt->v_num_bound;
      bdrys = rlt->v_bdrys;
    } /* for uv */

  }

  /*
   * Get the endpts
   */
  if(uv_points)
  {
    /*
     * Get the memory for the uv points; If the buffer is too small
     * allocate memory.
     */
    if(buffer_size >= *num_points * 2) *uv_points = uvbuffer;
    else
    {
      *uv_points = (IGRdouble *)om$malloc
                    (size = *num_points * 2 * sizeofIGRdouble);
      if(! *uv_points) { *EMmsg = EMS_E_NoDynamicMemory; goto wrapup; }
    }

    /*
     * Find the endpoints in uv
     */
    {
      IGRint    uv, rules;
      IGRint    *num_bound;
      IGRdouble *uv_ptr, *rule_values, **bdrys;
      IGRdouble this_rule;

      /*
       * Set up to use the u rule lines
       */
      rules = rlt->u_rules;
      rule_values = rlt->u_rule_values;
      num_bound = rlt->u_num_bound;
      bdrys = rlt->u_bdrys;

      uv_ptr = *uv_points;
      for(uv = U; uv <= V; uv ++)
      {
        for(i = 0; i < rules; i ++)
        {
          IGRint    num_clips;
          IGRdouble *clip_ptr;

          this_rule = rule_values[i];
          if(num_bound[i])
          {
            IGRint      j;
            IGRboolean  add_end;

            add_end = FALSE;
            num_clips = num_bound[i] * 2;
            clip_ptr = bdrys[i];

            /*
             * If the last clip point is one, ignore it;
             * otherwise set the flag to add 1.0 of this rule line.
             */
            if(bdrys[i][num_clips - 1] IS 1.0) num_clips --;
            else add_end = TRUE;

            /*
             * If the fisrt clip point is zero, skip it;
             * otherwise add 0.0 of this rule line
             */
            if(bdrys[i][0] IS 0.0)
            {
              clip_ptr ++;
              num_clips --;
            }
            else
            {
              if(uv IS U) { *uv_ptr = this_rule; *(++ uv_ptr) = 0.0; }
              else { *uv_ptr = 0.0; *(++ uv_ptr) = this_rule; }
              uv_ptr ++;
            }

            /*
             * Get the internal points
             */
            for(j = 0; j < num_clips; j ++)
            {
              if(uv IS U) {*uv_ptr = this_rule; *(++ uv_ptr) = *clip_ptr;}
              else { *uv_ptr = *clip_ptr; *(++ uv_ptr) = this_rule; }
              uv_ptr ++; clip_ptr ++;
            }

            if(add_end)
            {
              /*
               * Add 1.0 of this rule line
               */
              if(uv IS U) {*uv_ptr = this_rule; *(++ uv_ptr) = 1.0; }
              else { *uv_ptr = 1.0; *(++ uv_ptr) = this_rule; }
              uv_ptr ++;
            }
          }
          else /* no clips */
          {
            /*
             * Add 0.0 and 1.0 of this rule line.
             */
            if(uv IS U)
            {
              *uv_ptr = this_rule; *(++ uv_ptr) = 0.0;
              *(++ uv_ptr) = this_rule; *(++ uv_ptr) = 1.0;
            }
            else /* uiv IS V */
            {
              *uv_ptr = 0.0; *(++ uv_ptr) = this_rule;
              *(++ uv_ptr) = 1.0; *(++ uv_ptr) = this_rule;
            }
            uv_ptr ++;

          } /* if num_clips else */

        } /* for i */

        /*
         * On the second pass, use the v rule lines.
         */
        rules = rlt->v_rules;
        rule_values = rlt->v_rule_values;
        num_bound = rlt->v_num_bound;
        bdrys = rlt->v_bdrys;

      } /* for UV */

    } /* block */

    if(xyz_points)
    {
      /*
       * Get the memory for the xyz points. If the buffer isn't
       * large enough, then allocate the memory.
       */
      if(buffer_size >= *num_points * 3) *xyz_points = xyzbuffer;
      else
      {
        *xyz_points = (IGRdouble *)om$malloc
                      (size = *num_points * 3 * sizeofIGRdouble);
        if(! *xyz_points){*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}
      }

      /*
       * Evaluate the points
       */
      {
        IGRdouble *u_ptr, *v_ptr, *xyz_ptr;

        u_ptr = *uv_points;
        xyz_ptr = *xyz_points;
        for(i = 0, u_ptr = *uv_points; i < *num_points; i ++)
        {
          IGRlong rc;

          v_ptr = u_ptr + 1;
          BSsfeval(surface, *u_ptr, *v_ptr, 0, (IGRpoint *)xyz_ptr, &rc);
          if(rc) { *EMmsg = EMS_E_Fail; goto wrapup; }
          u_ptr += 2;
          xyz_ptr += 3;
        }
      }
    } /* if xyz_points */

  } /* if uv_points */

wrapup:
  EMSmsgReport(*EMmsg, "EFfrtEndPts", FALSE);
}
