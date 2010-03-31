/* ###################   APOGEE COMPILED   ################## */
class implementation EMSxsplane;

%safe
#include <math.h>
%endsafe


#include "EMS.h"
# include "msdef.h" /* MS message codes */
# include "ma.h"
# include "OMmacros.h"
# include "emsdef.h"
# include "emsmacros.h"
# include "EMcp.h"
# include "EMSprop.h"
# include "EMSopt.h"
# include "gocmacros.h"
# include "EMSbnddef.h"
# include "EMSbnd.h"
# include "EMSxsection.h"

/*

 History     

        RC     11/14/88      Creation Date

 Description

        This method returns the matrix needed to transform the
        cross_section plane in aligning it with the model 
	    while creating/updating the cross_section.       
*/
 
method EMget_alignment_matrix(
        IGRlong           *EMmsg;
        struct   GRmd_env *md_env; 
        IGRmatrix         align_mat;
        IGRshort          *align_mattyp)

{
  struct    IGRbsp_surface  *my_gm;
  IGRdouble                 trans_vec[3], rot_ang, win_zvec[3];
  IGRlong                   OM_stat, rc;
  IGRint                    i, j;
  IGRboolean                status;
  extern IGRboolean         MAgrotmx(), MAidmx(), MAtypemx();
  IGRchar                   *cache_ptr = NULL;
  
  /* ***************************************************************** */

  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  switch (ME.EMSxsplane->alignment_info_fmt)
  {
    case EMS_FMT_TRANS_VEC_ROT_ANGLE:
     
     OM_BLOCK_MOVE (me->alignment_info, trans_vec, sizeof(IGRdouble) * 3);
     rot_ang = me->alignment_info[3];

     if (trans_vec[0] != 0. || trans_vec[1] != 0. ||
         trans_vec[2] != 0. || rot_ang != 0)
     {
       GRgetabsg (&rc, &md_env->md_env.matrix_type, md_env->md_env.matrix,
                  &cache_ptr, i);
       EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_SurfaceError, wrapup);

       my_gm = (struct IGRbsp_surface *) cache_ptr;

       if (rot_ang != 0.)
       {
         for (i = 0; i < 3; i++)
           win_zvec[i] = my_gm->poles[6+i] - my_gm->poles[i];

         MAgrotmx (&rc, win_zvec, my_gm->poles, &rot_ang, align_mat);
         EMerr_hndlr (!(1&rc),*EMmsg,EMS_E_Fail,wrapup);
       }
       else
        status = MAidmx (&rc, align_mat);

       for (i = 0, j = 3; i < 3; i++, j += 4)
         align_mat[j] += trans_vec[i];

       status = MAtypemx (&rc, align_mat, align_mattyp);
       EMerr_hndlr (!(1&rc),*EMmsg,EMS_E_Fail,wrapup);

     } /* if (trans_vec[0] != 0. || trans_vec[1] != 0. ||
              trans_vec[2] != 0. || rot_ang != 0) */
     else
     {
       status = MAidmx (&rc, align_mat);
       *align_mattyp = MAIDMX;
     }

     break;

    case EMS_FMT_MATRIX:

      OM_BLOCK_MOVE (me->alignment_info, align_mat, 
                     sizeof(IGRdouble) * 16);

      status = MAtypemx (&rc, align_mat, align_mattyp);
      EMerr_hndlr (!(1&rc),*EMmsg,EMS_E_Fail,wrapup);

      break;

    default:
      break;
    
  } /* switch (ME.EMSxsplane->alignment_info_fmt) */


  wrapup:
   EMWRAPUP (OM_stat, *EMmsg, "In EMSxsplane.EMget_alignment_matrix");
   if (cache_ptr) GRabsg_del(cache_ptr);
   return (OM_stat);
}

end implementation EMSxsplane;
