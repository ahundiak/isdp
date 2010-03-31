/* ###################   APOGEE COMPILED   ################## */
class implementation EMSgradata;

#include "EMS.h"
# ifndef OMmacros_include
# include "OMmacros.h"      /* OM_BLOCK_MOVE        */
# endif

# ifndef gocmacros_include
# include "gocmacros.h"     /* EMSalign_bdry        */
# endif

# ifndef EMSerrordef_include
# include "EMSerrordef.h"
# endif

# ifndef emserr_include
# include "emserr.h"
# endif

# ifndef EMSmsgdef_include
# include "EMSmsgdef.h"
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

method EMputRLT(IGRlong *EMmsg; struct IGResqbs *rlt)

/*
History

   Jack 07 Apr 92       if me->num_[uv]_rules gets set to something
                        greater than 255, set it to zero and send warning. 
    RC      10/18/88    Creation date
*/
{
  IGRlong           OM_stat;
  IGRint            num_clip_pts = 0, i, sht_inx = 0;
  IGRdouble         *dbl_ptr;
  

  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
 
  if(rlt->u_rules > 255)
   {
    me->num_u_rules = 0;
    if(OM_Gf_verbose_warning)
      fprintf (stderr, "me->num_u_rules overflow  EMSgradata.EMputRLT\n");
   }
  else
    me->num_u_rules = (IGRuchar) rlt->u_rules;

  if(rlt->v_rules > 255)
   {
    me->num_v_rules = 0;
    if(OM_Gf_verbose_warning)
      fprintf (stderr, "me->num_v_rules overflow  EMSgradata.EMputRLT\n");
   }
  else
    me->num_v_rules = (IGRuchar) rlt->v_rules;

  for (i = 0; i < rlt->u_rules; i++)
    num_clip_pts += rlt->u_num_bound[i];
  for (i = 0; i < rlt->v_rules; i++)
    num_clip_pts += rlt->v_num_bound[i];

  num_clip_pts *= 2;

  OM_stat = om$vla_set_dimension (varray = me->short_data, 
               size = rlt->u_rules + rlt->v_rules);
  EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

  if (rlt->u_rules)
  {
    for (i = 0; i < rlt->u_rules; i++, sht_inx++)
     me->short_data[sht_inx] = (IGRushort) rlt->u_num_bound[i];
  } 

  if (rlt->v_rules)
  {
    for (i = 0; i < rlt->v_rules; i++, sht_inx++)
     me->short_data[sht_inx] = (IGRushort) rlt->v_num_bound[i];
  }

  OM_stat = om$vla_set_dimension (varray = me->double_data,
               size = rlt->u_rules + rlt->v_rules + num_clip_pts);
  EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

  dbl_ptr = me->double_data;

  if (rlt->u_rules)
  {
    OM_BLOCK_MOVE (rlt->u_rule_values, dbl_ptr, 
                   sizeof(IGRdouble) * rlt->u_rules);
    dbl_ptr += rlt->u_rules;
  }
              
  if (rlt->v_rules)
  {
    OM_BLOCK_MOVE (rlt->v_rule_values, dbl_ptr, 
                   sizeof(IGRdouble) * rlt->v_rules);
    dbl_ptr += rlt->v_rules;
  }
   
  if (rlt->u_rules)
  {
    for (i = 0; i < rlt->u_rules; i++)
    {
      OM_BLOCK_MOVE (rlt->u_bdrys[i], dbl_ptr, 
                     sizeof(IGRdouble) * rlt->u_num_bound[i] * 2);
      dbl_ptr += (rlt->u_num_bound[i] * 2);
    }
  }           

  if (rlt->v_rules)
  {
    for (i = 0; i < rlt->v_rules; i++)
    {
      OM_BLOCK_MOVE (rlt->v_bdrys[i], dbl_ptr, 
                     sizeof(IGRdouble) * rlt->v_num_bound[i] * 2);
      dbl_ptr += (rlt->v_num_bound[i] * 2);
    }
  }

wrapup:
  EMWRAPUP (*EMmsg, OM_stat, "In EMSgradata.EMputRLT");
  return(OM_stat);
}

end implementation EMSgradata;
