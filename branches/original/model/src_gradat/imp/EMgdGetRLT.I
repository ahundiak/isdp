/* ###################   APOGEE COMPILED   ################## */
class implementation EMSgradata;

#include "EMS.h"
# ifndef OMmacros_include
# include "OMmacros.h"      /* OM_BLOCK_MOVE        */
# endif

# ifndef gocmacros_include
# include "gocmacros.h"     /* EMSalign_bdry        */
# endif

# ifndef EMSmsgdef_include
# include "EMSmsgdef.h"     /* EMS message codes    */
# endif

# ifndef EMSfrtdef_include
# include "EMSfrtdef.h"     /* EMGD_UPTODATE       */
# endif

# ifndef EMSlogic_include
# include "EMSlogic.h"      /* EMSmsgReport         */
# endif

# ifndef EMStypedef_include
# include "EMStypedef.h"    /* EMSmsgReport         */
# endif

# ifndef EMScmacros_include
# include "EMScmacros.h"    /* EMSmsgReport         */
# endif

# ifndef EMSommacros_include
# include "EMSommacros.h"   /* ems$get_memory       */
# endif

# define PADDING    20      /* Enough to pad for two int aligns */
                            /* and a double align plus a few to */
                            /* be safe                          */

method EMgetRLT(IGRlong *EMmsg; IGRchar *buffer;
                IGRint buffer_size; struct IGResqbs **rlt)
/*
Algorithm

    This method allocates a buffer, partiions it, then fills it
    from instance data.

    The formula for calculating the size of the buffer is:

    sizeof(struct IGResqbs) +
    ( (u_rules + v_rules) * (sizeofDouble + sizeof(IGRdouble *)) ) +
    ( (SUM(u_num_bound) + SUM(v_num_bound)) * sizeofDouble )

History

    AIC     28 Apr 88   Change EMFRT_UPTODATE to EMGD_UPTODATE.
    AIC     ??-???-??   Genesis
*/
{
  IGRlong   sts;
  IGRint    num_bytes,      /* Size of the buffer in bytes  */
            total_rules,    /* Total number of rule lines   */
            total_clip_pts, /* Total number of clip points  */
            sizeofDouble,   /* Size of IGRdouble            */
            i, j;           /* loop counters                */
  IGRint    *int_ptr;       /* Integer pointer              */
  IGRdouble **addr_ptr;     /* Address pointer              */
  IGRdouble *double_ptr;    /* Double pointer               */

  void      EFgetMemory();

  /*
   * Initialize
   */
  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
  sizeofDouble = sizeof(IGRdouble);

  if(me^^EMShelper.props & EMGD_UPTODATE)
  {
    total_rules = (IGRint) me^^EMSgradata.num_u_rules +
                           me^^EMSgradata.num_v_rules;
    total_clip_pts = 0;
    for(i = 0; i < me^^EMSgradata.num_u_rules; i ++)
      total_clip_pts += (IGRint) me^^EMSgradata.short_data[i];
    for(j = 0; j < me^^EMSgradata.num_v_rules; j ++, i ++)
      total_clip_pts += (IGRint) me^^EMSgradata.short_data[i];
    total_clip_pts *= 2;

    /*
     * Calculate the buffer size
     */
    num_bytes = sizeof(struct IGResqbs);
    num_bytes += total_rules * (sizeof(IGRdouble *) + sizeof(IGRint));
    num_bytes += (total_clip_pts + total_rules) * sizeofDouble;
    num_bytes += PADDING;

    /*
     * Allocate the buffer
     */
    ems$get_memory(rc = EMmsg, num_elements = num_bytes,
                   buffer = buffer, buffer_size = buffer_size,
                   ptr = (char **) rlt, clear = TRUE);
    if(!(1 & *EMmsg)) goto wrapup;

    /*
     * Set the rule line counters
     */
    (*rlt)->u_rules = (IGRint) me^^EMSgradata.num_u_rules;
    (*rlt)->v_rules = (IGRint) me^^EMSgradata.num_v_rules;

    if((*rlt)->u_rules || (*rlt)->v_rules)
    {
      /*
       * Partition for the clip point counters
       */
      int_ptr = (IGRint *) EMSalign_bdry(sizeof(IGRint), *rlt + 1);
      (*rlt)->u_num_bound = int_ptr;
      int_ptr += (*rlt)->u_rules;
      (*rlt)->v_num_bound = int_ptr;
      int_ptr += (*rlt)->v_rules;

      /*
       * Set the clip point counters
       */
      for(i = 0; i < (*rlt)->u_rules; i ++)
        (*rlt)->u_num_bound[i] = (IGRint) me^^EMSgradata.short_data[i];
      for(j = 0; j < (*rlt)->v_rules; j ++, i ++)
        (*rlt)->v_num_bound[j] = (IGRint) me^^EMSgradata.short_data[i];

      /*
       * Partition for the clip points array addresses
       */
      addr_ptr = (IGRdouble **) EMSalign_bdry(sizeof(IGRdouble *), int_ptr);
      (*rlt)->u_bdrys = addr_ptr;
      addr_ptr += (*rlt)->u_rules;
      (*rlt)->v_bdrys = addr_ptr;
      addr_ptr += (*rlt)->v_rules;

      /*
       * Partition for the rule values
       */
      double_ptr = (IGRdouble *) EMSalign_bdry(sizeofDouble, addr_ptr);
      (*rlt)->u_rule_values = double_ptr;
      double_ptr += (*rlt)->u_rules;
      (*rlt)->v_rule_values = double_ptr;
      double_ptr += (*rlt)->v_rules;

      /*
       * Partition for the clip points
       */
      for(i = 0; i < (*rlt)->u_rules; i ++)
      {
        (*rlt)->u_bdrys[i] = double_ptr;
        double_ptr += (*rlt)->u_num_bound[i] * 2;
      }
      for(i = 0; i < (*rlt)->v_rules; i ++)
      {
        (*rlt)->v_bdrys[i] = double_ptr;
        double_ptr += (*rlt)->v_num_bound[i] * 2;
      }

      /*
       * Set the rule values and clip points
       * (using double_ptr to point at my instance data and
       *  and num_bytes for the number of bytes to move)
       *
       * Because of the way the buffer is partioned, all the double
       * data can be moved in a single chunk.
       */
      double_ptr = me^^EMSgradata.double_data;
      num_bytes = (*rlt)->u_rules * sizeofDouble;
      num_bytes += (*rlt)->v_rules * sizeofDouble;
      for(i = 0; i < (*rlt)->u_rules; i ++)
        num_bytes += (*rlt)->u_num_bound[i] * sizeofDouble * 2;
      for(i = 0; i < (*rlt)->v_rules; i ++)
        num_bytes += (*rlt)->v_num_bound[i] * sizeofDouble * 2;
      OM_BLOCK_MOVE(double_ptr, (*rlt)->u_rule_values, num_bytes);
    }
  }
  else *EMmsg = EMS_W_NotUpToDate;

wrapup:
  EMSmsgReport(sts, "EMSgradata.EMgetRLT", FALSE);
  return(sts);
}

end implementation EMSgradata;
