class implementation GRlinear;

#include "EMS.h"
#include <stdio.h>
#include "OMminimum.h"
#include "igrtypedef.h"
#include "gocmacros.h"
#include "OMerrordef.h"
#include "msdef.h"
#include "emserr.h"
#include "emsdef.h"
#include "bserr.h"
#include "bsconic.h"
#include "ma2lnise.h"
#include "bsroto.h"
#include "bsptlngen.h"
#include "bsnorvec.h"
#include "bslenvec.h"
#include "bsfreecv.h"
#include "bsdotp.h"
#include "bsdistptpt.h"
#include "bscrossp.h"
#include "bsalloccv.h"

/*
  HISTORY

	Sudha  :  07/02/93  :  Modified for BSprototypes ansification

*/

extern OMuword OPP_GR3dlineseg_class_id;
extern OMuword OPP_GR3dlinestr_class_id;

IGRlong EMchamfer(msg, matrix_type, matrix, my_id, construct_list, ln2, 
                  setback_point1, setback_point2, isect_point, 
                  alpha, chamfer_id)

      IGRlong    *msg; 
      IGRshort   *matrix_type; 
      IGRmatrix   matrix;
      GRobjid	  my_id;
      struct GRvg_construct *construct_list; 
      struct GRlc_info   ln2; 
      IGRpoint setback_point1, setback_point2, isect_point;
      IGRdouble alpha; 
      GRobjid *chamfer_id;

{
	IGRlong          sts, status, msg_loc, size;
        IGRlong          number_of_points;
        IGRpoint         points[2], Q0, Q1, vec_pnt, R;
        struct IGRbsp_curve      *line1, *line2, *curve;
        IGRvector        V1, V2, out_vec;
        IGRboolean       Q0_to_Q1, EFplace_line_string();
        struct IGRline   line_1, line_2;
        IGRint           type;
        IGRdouble        tol, t1, t2, mag, result, theta;
        IGRdouble	 dist1, dist2;
        IGRchar		 errmsg[EMMAXERRMSG_LEN];
        extern IGRdouble   atan2();

        *msg = MSSUCC;
	status = OM_S_SUCCESS;
        strcpy (errmsg, "GRsubbc.EMchamfer");
        number_of_points = 2;
        type = BSCLINE;
        tol = .0001;
        line1 = NULL;
        line2 = NULL;
        curve = NULL;

        points[0][0] = setback_point1[0];
        points[0][1] = setback_point1[1];
        points[0][2] = setback_point1[2];

status = om$send(mode = OM_e_wrt_object,
		 msg = message GRvg.GRgetsize
				    (&msg_loc, matrix_type, matrix, &size),
	    senderid = NULL_OBJID,
	    targetid = my_id,
        targetos = construct_list->env_info->md_id.osnum);
EMomerr_hndlr (status, ret_end, errmsg);
EMerr_hndlr (EMis_error (msg_loc), *msg, MSFAIL, ret_end);

line1 = (struct IGRbsp_curve *) om$malloc (size = size);
EMerr_hndlr (!line1, *msg, MSNOMEM, ret_end);

status = om$send (mode = OM_e_wrt_object,
		  msg = message GRvg.GRgetgeom (&msg_loc,
			 matrix_type, matrix, (IGRchar *)line1), 
	     senderid = NULL_OBJID,
             targetid = my_id,
        targetos = construct_list->env_info->md_id.osnum);
EMomerr_hndlr (status, ret_end, errmsg);
EMerr_hndlr (EMis_error (msg_loc), *msg, MSFAIL, ret_end);

status = om$send(mode = OM_e_wrt_object,
		 msg = message GRvg.GRgetsize
				    (&msg_loc,
					&ln2.module_info.md_env.matrix_type,
					ln2.module_info.md_env.matrix, &size),
	    senderid = NULL_OBJID,
	    targetid = ln2.located_obj.objid, 
	    targetos = ln2.located_obj.osnum);
EMomerr_hndlr (status, ret_end, errmsg);
EMerr_hndlr (EMis_error (msg_loc), *msg, MSFAIL, ret_end);

line2 = (struct IGRbsp_curve *) om$malloc (size = size);
EMerr_hndlr (!line2, *msg, MSNOMEM, ret_end);

status = om$send (mode = OM_e_wrt_object,
		  msg = message GRvg.GRgetgeom (&msg_loc,
			 &ln2.module_info.md_env.matrix_type,
			ln2.module_info.md_env.matrix, (IGRchar *)line2), 
	     senderid = NULL_OBJID,
             targetid = ln2.located_obj.objid,
    	    targetos = ln2.located_obj.osnum);
EMomerr_hndlr (status, ret_end, errmsg);
EMerr_hndlr (EMis_error (msg_loc), *msg, MSFAIL, ret_end);

if (alpha)  /* set up the angle line */
{
   Q0[0] = setback_point1[0];
   Q0[1] = setback_point1[1];
   Q0[2] = setback_point1[2];

   /* get the distances to determine which end to make our vector from */

   dist1 = BSdistptpt(&msg_loc, isect_point, &line1->poles[0]);
   EMerr_hndlr(msg_loc != BSSUCC, *msg, MSFAIL, ret_end);

   dist2 = BSdistptpt(&msg_loc, isect_point,
                      &line1->poles[(line1->num_poles-1)*3]);
   EMerr_hndlr(msg_loc != BSSUCC, *msg, MSFAIL, ret_end);
 
   if (dist1 > dist2)
   {
      vec_pnt[0] = line1->poles[0];
      vec_pnt[1] = line1->poles[1];
      vec_pnt[2] = line1->poles[2];
   }
   else
   {
      vec_pnt[0] = line1->poles[((line1->num_poles-1)*3)];
      vec_pnt[1] = line1->poles[((line1->num_poles-1)*3)+1];
      vec_pnt[2] = line1->poles[((line1->num_poles-1)*3)+2];
   }

   V1[0] = vec_pnt[0] - isect_point[0];
   V1[1] = vec_pnt[1] - isect_point[1];
   V1[2] = vec_pnt[2] - isect_point[2];

   /* get the distances to determine which end to make our vector from */

   dist1 = BSdistptpt(&msg_loc, isect_point, &line2->poles[0]);
   EMerr_hndlr(msg_loc != BSSUCC, *msg, MSFAIL, ret_end);

   dist2 = BSdistptpt(&msg_loc, isect_point,
                      &line2->poles[(line2->num_poles-1)*3]);
   EMerr_hndlr(msg_loc != BSSUCC, *msg, MSFAIL, ret_end);
 
   if (dist1 > dist2)
   {
      vec_pnt[0] = line2->poles[0];
      vec_pnt[1] = line2->poles[1];
      vec_pnt[2] = line2->poles[2];
   }
   else
   {
      vec_pnt[0] = line2->poles[((line2->num_poles-1)*3)];
      vec_pnt[1] = line2->poles[((line2->num_poles-1)*3)+1];
      vec_pnt[2] = line2->poles[((line2->num_poles-1)*3)+2];
   }

   V2[0] = isect_point[0] - vec_pnt[0];
   V2[1] = isect_point[1] - vec_pnt[1];
   V2[2] = isect_point[2] - vec_pnt[2];

   /* normalize the vectors */
   sts = BSnorvec(&msg_loc, V1);
   EMerr_hndlr(!sts || msg_loc != BSSUCC, *msg, MSFAIL, ret_end);
 
   sts = BSnorvec(&msg_loc, V2);
   EMerr_hndlr(!sts || msg_loc != BSSUCC, *msg, MSFAIL, ret_end);

   /* get the cross product of the vectors and add it to Q0 to give Q1 */

   sts = BScrossp(&msg_loc, V1, V2, out_vec);
   EMerr_hndlr(!sts || msg_loc != BSSUCC, *msg, MSFAIL, ret_end);

   Q1[0] = out_vec[0] + Q0[0];
   Q1[1] = out_vec[1] + Q0[1];
   Q1[2] = out_vec[2] + Q0[2];

   /* check the validity of angle */

   mag = BSlenvec (&msg_loc, out_vec);
   EMerr_hndlr(msg_loc != BSSUCC, *msg, MSFAIL, ret_end);

   result = BSdotp (&msg_loc, V1, V2);
   EMerr_hndlr(msg_loc != BSSUCC, *msg, MSFAIL, ret_end);

   theta = atan2(mag, result);

   if (alpha >= theta)
   {
      *msg = MSINARG;
      goto ret_end;
   }

   /* rotate the isect point alpha degrees about axis Q0 to Q1 */

   Q0_to_Q1 = TRUE;
   sts = BSroto (&msg_loc, Q0, Q1, &Q0_to_Q1, &alpha, isect_point, R);
   EMerr_hndlr(!sts || msg_loc != BSSUCC, *msg, MSFAIL, ret_end);

   /* constructs line from setback_point1 to the rotated point */

   BSalloccv(line1->order, line1->num_poles, line1->rational, 
                line1->num_boundaries, &curve, &msg_loc);
   EMerr_hndlr(msg_loc != BSSUCC, *msg, MSNOMEM, ret_end);

   sts = BSptlngen(&msg_loc, Q0, R, curve, &type);
   EMerr_hndlr(!sts || msg_loc != BSSUCC, *msg, MSFAIL, ret_end);

   /* intersect new line with line2 */

   line_1.point1 = &curve->poles[0];
   line_1.point2 = &curve->poles[(curve->num_poles-1)*3];
   line_2.point1 = &line2->poles[0];
   line_2.point2 = &line2->poles[(line2->num_poles-1)*3];

   MA2lnisect(&msg_loc, &line_1, &line_2, &tol, &points[1][0], &t1, &t2);
   EMerr_hndlr (msg_loc != MSSUCC, *msg, MSFAIL, ret_end);
}  /* end if alpha */
else
{
   points[1][0] = setback_point2[0];
   points[1][1] = setback_point2[1];
   points[1][2] = setback_point2[2];
}  

/* construct the chamfer */

sts = EFplace_line_string(my_id, construct_list, number_of_points, points, 
                          chamfer_id, &msg_loc);
EMerr_hndlr(!sts || msg_loc != MSSUCC, *msg, MSFAIL, ret_end);

ret_end:
  if (line2)
   {
        om$dealloc (ptr = line2);
   }
  if (curve)
   {
        sts = BSfreecv(&msg_loc, curve);
        if (!sts || msg_loc != BSSUCC)
        {
            *msg = MSFAIL;
        }
   }  

   return(status);

}

end implementation GRlinear;
