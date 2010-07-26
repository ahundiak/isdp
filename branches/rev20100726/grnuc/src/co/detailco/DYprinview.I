/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   DYprinview_init

Description
   This function will display a principal view based upon where the cursor
   is in relation to the existing principal view.

Arguments
   *mod_env          struct GRmd_env   module environment
   origin            IGRpoint          origin for drawing view
   *model_lbsys      struct IGRlbsys   the model local bounded system
   *proj_angle       IGRint            projection angle
                                          -  GR_DS_FIRST_ANGLE
                                          -  GR_DS_THIRD_ANGLE
   *caller_id        struct GRid       Commands osnum and objid   
   chansel           OM_p_CHANSELECT   Commands chansel

History 
   Gray Winn         03/05/88    Creation Date
   Gray Winn         06/03/88    Updated to include cross dynamics
   Jay Wallingford   04/14/89    Fixed problems in folding off prinviews
                                 Modified GRprinview_build_rot_matrix and
                                 GRprinview_build_lines routines.
   Jay Wallingford   04/16/89    Fixed dynamics display problems when folding
                                 off a prinview with a large z depth.
   scott walters     06/23/92    Added static ANSI C prototypes
   scott walters     07/08/92    ANSI source conversion
                                 
\*/

class implementation Root;

#include "coimport.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "lcdef.h"
#include "griodef.h"
#include "ex.h"
#include "grio.h"
#include "lc.h"
#include "msdef.h"
#include "msdef.h"
#include "madef.h"
#include "growner.h"
#include "grgs.h"
#include "dpmacros.h"
#include "detaildef.h"
#include "OMerrordef.h"
#include "igrdef.h"
#include "dpstruct.h"

#define MAETA                    1.0e-15
#define MAETA_BIG                1.0e-13
extern IGRboolean DPdlist_in_fold_dynamics;

struct dyn_args
{
   IGRint               proj_angle;
   IGRpoint             origin;
   struct IGRlbsys      model_lbsys;
   struct GRid          obj_id;
   struct GRmdenv_info  env;
   struct IGRdisplay    display;
   IGRpoint             tpts[4][2];
   IGRpoint             pts[4][2];
   struct DPele_header  element[4];
   struct IGRpolyline   polyline[4];
   struct IGRline       tlines[4];
   struct IGRline       infinite_lines[4];
};

%safe
/*
 *  ANSI static prototype
 */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif
#if defined(__cplusplus)
extern "C" {
#endif

static int check_face __((IGRlong *msg, IGRpoint pts[], IGRpoint view, 
                          IGRint index1, IGRint index2, IGRint index3, 
                          IGRint index4, struct IGRline *line1, 
                          struct IGRline *line2, struct IGRline lines[], 
                          IGRint *num_lines));

#if defined(__cplusplus)
}
#endif
#undef __
%endsafe



IGRint DYprinview_init (mod_env, origin, model_lbsys, proj_angle, 
                        caller_id, chansel)
struct GRmd_env   *mod_env;
IGRpoint          origin;
struct IGRlbsys   *model_lbsys;
IGRint            *proj_angle;
struct GRid       *caller_id;
OM_p_CHANSELECT   chansel;
{
IGRlong           om_msg;
IGRlong           msg;
IGRint            i;          
IGRboolean        dyn_on;       /* is dynamics on?             */
IGRboolean        inquire = 1;  /* inquire from DPdynflags     */
struct GRobj_env  obj_info;     /* object being cloned         */
struct dyn_args   data;         /* arguments                   */

IGRint   DYprinview();

   /*
    *  if dynamics is off then exit
    */

   DPdynflags (&msg, &inquire, &dyn_on, NULL);
   if (!dyn_on)
   {
      return (MSSUCC);
   }

   /*
    *  if the channel contains a graphics set then exit, otherwise
    *  use the object information returned for the clone
    */

   om_msg = GRgsget_simple_object (&msg, caller_id, chansel, &obj_info);

   if (!(om_msg & msg & 1))
   {
      return (MSSUCC);
   }

   /*
    *  Build dynamics information.
    */

   data.model_lbsys = *model_lbsys;
   for (i=0; i < 3; ++i) data.origin[i] = origin[i];
   data.obj_id.osnum = mod_env->md_id.osnum;
   data.obj_id.objid = obj_info.obj_id.objid;
   data.proj_angle = *proj_angle;

   /*
    *  Build dynamics information to display cross.
    */

   data.display.color = 2;
   data.display.weight = 0;
   data.display.style = 1;
   for (i=0; i < 4; ++i)
   {
      data.polyline[i].num_points = 2;
      data.polyline[i].points = (IGRdouble *)data.pts[i];
      data.infinite_lines[i].point1 = data.pts[i][0];
      data.infinite_lines[i].point2 = data.pts[i][1];
      data.tlines[i].point1 = data.tpts[i][0];
      data.tlines[i].point2 = data.tpts[i][1];
      dp$build_dis_buffer( buffer = &data.element[i], type = IGRPY,
         display_att = &data.display, geometry = &data.polyline[i]);
   }

   DPdlist_in_fold_dynamics = 1;
   dp$dynamics (dyn_fun = DYprinview, information = &data);
   DPdlist_in_fold_dynamics = 0;

   return (MSSUCC);
}


#argsused
IGRint DYprinview (dptr, point, mtx, objects, num_objects, buffers,
                  num_buffers, in_dummy1, in_dummy2, in_dummy3, out_dummy1,
                  out_dummy2, out_dummy3)
struct dyn_args       *dptr;
struct EX_button      *point;
IGRdouble             *mtx;
struct GRid          **objects;
IGRint                *num_objects;
struct DPele_header  **buffers;
IGRint                *num_buffers;
IGRchar               *in_dummy1;
IGRchar               *in_dummy2;
IGRchar               *in_dummy3;
IGRchar              **out_dummy1;
struct GRmdenv_info  **out_dummy2;
IGRchar              **out_dummy3;
{
IGRlong              om_msg;
IGRlong              msg;
IGRint               num_lines;
IGRint               i;
IGRshort             four = 4;
IGRdouble            t1;
IGRdouble            t2;
IGRpoint             tpoint;
IGRpoint             vector;
IGRpoint             diag1;
IGRpoint             diag2;
IGRpoint             pts[2];
IGRmatrix            inv_window;
struct IGRline       line;

   tpoint[0] = point->x;
   tpoint[1] = point->y;
   tpoint[2] = point->z;

   /*
    *  Generate the rotation matrix.
    */

   om_msg = GRprinview_build_rot_matrix (&msg, &dptr->proj_angle, mtx, 
            dptr->origin, &dptr->model_lbsys, tpoint, vector, 
            dptr->env.matrix, dptr->tlines, &num_lines);

   if (om_msg & msg & 1)
   {

      /*
       *  Transfrom the lines to world coordinates and extend them to 
       *  the edge of the design cube.
       */
      MAtypemx (&msg, dptr->env.matrix, &dptr->env.matrix_type);
      MAtrnmx (&msg, &four, mtx, inv_window);
      diag1[0] = diag1[1] = diag1[2] = GRDGNLIMITS_MIN_D;
      diag2[0] = diag2[1] = diag2[2] = GRDGNLIMITS_MAX_D;
      line.point1 = pts[0];
      line.point2 = pts[1];
      for (i=0; i < num_lines; ++i)
      {
         MAlnxform(&msg, &dptr->tlines[i], inv_window, &line);
         MAtlncbclip (&msg, &line, diag1, diag2, &t1, &t2, 
            &dptr->infinite_lines[i]);

      }

      /*
       *  set up the buffer pointer
       */

      *num_buffers = num_lines;
      *buffers = dptr->element;
      *objects = &dptr->obj_id;
      *num_objects = 1;
      *out_dummy2 = &dptr->env;
   }
   return (om_msg);
}

IGRint GRprinview_build_rot_matrix (msg, proj_angle, window_matrix, origin,
                                    model_lbsys, point, vector, 
                                    result_matrix, lines, num_lines)
IGRlong              *msg;
IGRint               *proj_angle;
IGRmatrix            window_matrix;
IGRpoint             origin;
struct IGRlbsys      *model_lbsys;
IGRpoint             point;
IGRpoint             vector;
IGRmatrix            result_matrix;
struct IGRline       lines[];
IGRint               *num_lines;   
{
IGRlong              om_msg;
IGRint               i,j;
IGRshort             four = 4;
IGRlong              one = 1;
IGRint               above1;
IGRint               above2;
IGRshort             matrix_type;
IGRdouble            radians;
IGRdouble            t;
IGRdouble            angle[3];
IGRpoint             vector1;
IGRpoint             pt;
IGRpoint             prjpt;
IGRpoint             rot_direction;
IGRpoint             direction;
IGRpoint             tpoint;
IGRpoint             prj_point;
IGRpoint             line_points[4];
IGRpoint             view;
IGRmatrix            tmatrix;
IGRmatrix            matrix;
struct IGRplane      plane;
struct IGRline       line;
struct IGRline       line1;
struct IGRline       line2;

   *msg = MSSUCC;

   line1.point1 = &line_points[0][0];
   line1.point2 = &line_points[1][0];
   line2.point1 = &line_points[2][0];
   line2.point2 = &line_points[3][0];

#ifdef NOT_INCLUDED
   printf("Model's lbsys \n");
   printf("    . matrix\n");
   printf("%f %f %f %f\n",model_lbsys->matrix[0],model_lbsys->matrix[1],model_lbsys->matrix[2],model_lbsys->matrix[3]);
   printf("%f %f %f %f\n",model_lbsys->matrix[4],model_lbsys->matrix[5],model_lbsys->matrix[6],model_lbsys->matrix[7]);
   printf("%f %f %f %f\n",model_lbsys->matrix[8],model_lbsys->matrix[9],model_lbsys->matrix[10],model_lbsys->matrix[11]);
   printf("%f %f %f %f\n",model_lbsys->matrix[12],model_lbsys->matrix[13],model_lbsys->matrix[14],model_lbsys->matrix[15]);
   printf("    . range\n");
   printf("%f %f %f\n",model_lbsys->diag_pt1[0],model_lbsys->diag_pt1[1],model_lbsys->diag_pt1[2]);
   printf("%f %f %f\n\n",model_lbsys->diag_pt2[0],model_lbsys->diag_pt2[1],model_lbsys->diag_pt2[2]);
#endif

   om_msg = GRprinview_build_lines (msg, window_matrix, model_lbsys, 
            &line1, &line2, lines, num_lines);

   if (om_msg & *msg & 1)
   {
      /* 
       *  Transform the cursor point to the window.
       */

      MAtypemx(msg, window_matrix, &matrix_type);
      MAoptsxform (msg, &one, &matrix_type, window_matrix, point, pt);

      view[0] = 0.0;
      view[1] = 0.0;
      view[2] = 1.0;
      plane.normal = view;
      plane.point = line1.point1;
      MAptplproj(msg, pt, &plane, prjpt);

      /*
       * If a model has been specified (num_lines == 4) adjusts the dynamic
       * lines' z depth to be that of the transformed cursor point. This keeps
       * the dynamic display visible.
       */

      if ( num_lines && *num_lines == 4 )
      {
         for (i=0; i<3; ++i)
         {
            lines[i].point1[2] = pt[2];
            lines[i].point2[2] = pt[2];
         }
      }

      /*
       *  Get the angle between the point and the first line.
       */

      for (i=0; i < 3; ++i)
      {
         vector1[i] = line1.point2[i] - line1.point1[i];
         if ((vector1[i] < MAETA_BIG) && (vector1[i] > - MAETA_BIG))
         {
            vector1[i] = 0.0;
         }

         tpoint[i] = prjpt[i] - line1.point1[i];
         if ((tpoint[i] < MAETA_BIG) && (tpoint[i] > - MAETA_BIG))
         {
            tpoint[i] = 0.0;
         }
      }
      
      /*
       * Make sure the vector's y value is positive.
       */
      if (vector1[1] < 0.0) vector1[1] = -vector1[1];

      MAang2vc(msg, vector1, tpoint, angle);
#ifdef NOTHING
   printf("Vector for line1 : ");
   for (i=0; i<3; i++) printf("%f ",vector1[i]);
   printf("\n"); 
   printf("Vector for project point : ");
   for (i=0; i<3; i++) printf("%f ",tpoint[i]);
   printf("\n"); 
   printf("Angle : %f\n",angle[0]);
#endif
      if (angle[0] <= PI)
      {
         above1 = 1;
      }else
      {
         above1 = 0;
      }

      /*
       *  Get the angle between the point and the second line.
       */

      for (i=0; i < 3; ++i)
      {
         vector1[i] = line2.point2[i] - line2.point1[i];
         if ((vector1[i] < MAETA_BIG) && (vector1[i] > - MAETA_BIG))
         {
            vector1[i] = 0.0;
         }

         tpoint[i] = prjpt[i] - line2.point1[i];
         if ((tpoint[i] < MAETA_BIG) && (tpoint[i] > - MAETA_BIG))
         {
            tpoint[i] = 0.0;
         }
      }

      /*
       * Make sure the vector's y value is positive.
       */
      if (vector1[1] < 0.0) vector1[1] = -vector1[1];

      MAang2vc(msg, vector1, tpoint, angle);
#ifdef NOTHING
   printf("Vector for line1 : ");
   for (i=0; i<3; i++) printf("%f ",vector1[i]);
   printf("\n"); 
   printf("Vector for project point : ");
   for (i=0; i<3; i++) printf("%f ",tpoint[i]);
   printf("\n"); 
   printf("Angle : %f\n",angle[0]);
#endif

      if (angle[0] > PI)
      {
         above2 = 1;
      }else
      {
         above2 = 0;
      }

      /*
       *  Determine rotation information based upon the relationship
       *  between the cursor point the drawing view.
       */

      switch (above1 | (above2 << 1))
      {
         case 0:  /* DOWN */
         {
#ifdef NOTHING
   printf("Folding Down\n");
#endif 
            rot_direction[0] = window_matrix[0];
            rot_direction[1] = window_matrix[1];
            rot_direction[2] = window_matrix[2];
            direction[0] = window_matrix[4];
            direction[1] = window_matrix[5];
            direction[2] = window_matrix[6];
            if (*proj_angle == GR_DS_THIRD_ANGLE)
            {
               radians = -(PI/2);
            }else
            {
               radians = PI/2;
            }            
         }
         break;

         case 1:  /* LEFT */
         {  
#ifdef NOTHING
   printf("Folding Left\n");
#endif 
            rot_direction[0] = window_matrix[4];
            rot_direction[1] = window_matrix[5];
            rot_direction[2] = window_matrix[6];
            direction[0] = window_matrix[0];
            direction[1] = window_matrix[1];
            direction[2] = window_matrix[2];
            if (*proj_angle == GR_DS_THIRD_ANGLE)
            {
               radians = PI/2;
            }else
            {
               radians = -(PI/2);
            }            
         }
         break;

         case 2:  /* RIGHT */
         {
#ifdef NOTHING
   printf("Folding Right\n");
#endif 
            rot_direction[0] = window_matrix[4];
            rot_direction[1] = window_matrix[5];
            rot_direction[2] = window_matrix[6];
            direction[0] = window_matrix[0];
            direction[1] = window_matrix[1];
            direction[2] = window_matrix[2];
            if (*proj_angle == GR_DS_THIRD_ANGLE)
            {
               radians = -(PI/2);
            }else
            {
               radians = PI/2;
            }            
         }
         break;

         case 3:  /* UP */
         {
#ifdef NOTHING
   printf("Folding Up\n");
#endif 
            rot_direction[0] = window_matrix[0];
            rot_direction[1] = window_matrix[1];
            rot_direction[2] = window_matrix[2];
            direction[0] = window_matrix[4];
            direction[1] = window_matrix[5];
            direction[2] = window_matrix[6];
            if (*proj_angle == GR_DS_THIRD_ANGLE)
            {
               radians = PI/2;
            }else
            {
               radians = -(PI/2);
            }            
         }
         break;
      }

      /*
       *  Form the rotation matrix.
       */

      MAgrotmx (msg, rot_direction, origin, &radians, matrix);
   
      /*
       *  Form the translation matrix.
       */

      MAidmx(msg, tmatrix);
      tpoint[0] = origin[0] + direction[0];
      tpoint[1] = origin[1] + direction[1];
      tpoint[2] = origin[2] + direction[2];
      line.point1 = origin;
      line.point2 = tpoint;
      MAptlnproj (msg, point, &line, prj_point, &t);

      for (i=0, j=3; i < 3; ++i, j += 4)
      {
         if (((prj_point[i] - origin[i]) > MAETA) ||
             ((prj_point[i] - origin[i]) < - MAETA))
         {
            tmatrix[j] = prj_point[i] - origin[i];
         }
      }

      vector[0] = direction[0];
      vector[1] = direction[1];
      vector[2] = direction[2];
      MAmulmx (msg, &four, &four, &four, tmatrix, matrix, result_matrix);
   }
   return(om_msg);
}

IGRint GRprinview_build_lines (msg, window_matrix, lb, line1, line2,
                               lines, num_lines)
IGRlong           *msg;
IGRmatrix         window_matrix;
struct IGRlbsys   *lb;
struct IGRline    *line1;
struct IGRline    *line2;
struct IGRline    lines[];
IGRint            *num_lines;
{
IGRint               i;
IGRpoint             pts[10];
IGRpoint             view;
struct IGRpolyline   py;
struct IGRlbsys      tlb;

   /*
    *  Transform the local bounded system to the view.
    */

   *msg = MSSUCC;
   MAlbxform(msg, lb, window_matrix, &tlb);

   /*
    *  If the local bounded system is degenerate, form lines that
    *  from an X crossing at the center of the local bounded system.
    */

   if ((tlb.diag_pt1[0] == tlb.diag_pt2[0]) &&
       (tlb.diag_pt1[1] == tlb.diag_pt2[1]) &&
       (tlb.diag_pt1[2] == tlb.diag_pt2[2]))
   {
      line1->point1[0] = tlb.matrix[3];
      line1->point1[1] = tlb.matrix[7];
      line1->point1[2] = tlb.matrix[11];

      line1->point2[0] = tlb.matrix[3] + 1.0;
      line1->point2[1] = tlb.matrix[7] + 1.0;
      line1->point2[2] = tlb.matrix[11];

      line2->point1[0] = tlb.matrix[3];
      line2->point1[1] = tlb.matrix[7];
      line2->point1[2] = tlb.matrix[11];

      line2->point2[0] = tlb.matrix[3] - 1.0;
      line2->point2[1] = tlb.matrix[7] + 1.0;
      line2->point2[2] = tlb.matrix[11];

      if (num_lines && lines)
      {
         *num_lines = 2;
         for (i=0; i < 3; ++i)
         {
            lines[0].point1[i] = line1->point1[i];
            lines[0].point2[i] = line1->point2[i];
            lines[1].point1[i] = line2->point1[i];
            lines[1].point2[i] = line2->point2[i];
         }
      }
      return(OM_S_SUCCESS);
   }

   /*
    *  Generate a cube from the local bounded system.
    */
   py.num_points = 10;
   py.points = (IGRdouble *)pts;
   MApyfrlb(msg, &tlb, &py);

#ifdef NOTHING
   printf("CUBE FROM LOCAL BOUNDED GEOM\n");
   printf("   FACE 1:\n");
   for (i = 0; i < 5; i++) {
      for (j = 0; j <3; j++) {
         printf("%f  ", py.points[(i*3)+j]);
      }
      printf("\n");
   }
   printf("   FACE 2:\n");
   for (i = 5; i < 10; i++) {
      for (j = 0; j <3; j++) {
         printf("%f  ", py.points[(i*3)+j]);
      }
      printf("\n");
   }
   printf("\n");
#endif

   view[0] = 0.0;
   view[1] = 0.0;
   view[2] = 1.0;

   /* 
    *  Check each face of the cube to determine if it is aligned with
    *  the view.  If it is return two lines that run from diagonal
    *  to diagonal.  
    *
    *             TOP FACE 
    * point 6  _________________ point 7
    *          |               |
    *          |               |
    *          |               |
    *          |               |
    *          |               |
    *  point 5 _________________ point 8
    *
    *             BOTTOM FACE 
    * point 1  _________________ point 2
    *          |               |
    *          |               |
    *          |               |
    *          |               |
    *          |               |
    *  point 0 _________________ point 3
    *
    * 
    * 
    */

   /* TOP FACE */
   if (!check_face (msg, pts, view, 5, 7, 8, 6, line1, line2, lines, 
            num_lines))
   {
      /* RIGHT FACE */
      if (!check_face (msg, pts, view, 3, 7, 2, 8, line1, line2, lines,
                   num_lines))
      {
         /* BOTTOM FACE */
         if (!check_face (msg, pts, view, 1, 3, 2, 0, line1, line2, lines,
                  num_lines))
         {
            /* LEFT FACE */
            if (!check_face (msg, pts, view, 1, 5, 0, 6, line1, line2, 
                     lines, num_lines))
            {
               /* FRONT FACE */
               if (!check_face (msg, pts, view, 0, 8, 3, 5, line1, line2,
                        lines, num_lines))
               {
                  /* BACK FACE */
                  if (!check_face (msg, pts, view, 2, 6, 1, 7, line1, 
                           line2, lines, num_lines))
                  {
                     /* No faces are aligned */
                     *msg = MSFAIL;
                     return(OM_E_ABORT);
                  }
#ifdef NOTHING
                  else printf("Back Face \n");
#endif                  
               }
#ifdef NOTHING
               else printf("Front Face \n");
#endif                  
            }
#ifdef NOTHING
            else printf("Left Face \n");
#endif                  
         }
#ifdef NOTHING
         else printf("Bottom Face \n");
#endif                  
      }
#ifdef NOTHING
      else printf("Right Face \n");
#endif                  
   }
#ifdef NOTHING
   else printf("Top Face \n");
#endif               
   
   return (OM_S_SUCCESS);
}

static check_face (msg, pts, view, index1, index2, index3, index4, line1,
                   line2, lines, num_lines)
IGRlong     *msg;
IGRpoint       pts[];
IGRpoint       view;
IGRint         index1;
IGRint         index2;
IGRint         index3;
IGRint         index4;
struct IGRline *line1;
struct IGRline *line2;
struct IGRline lines[];
IGRint         *num_lines;
{

IGRint         i;
IGRpoint       vc1;
IGRpoint       vc2;
IGRpoint       normal;
IGRpoint       result;

   /*
    *  Form vectors in the x and y direction.
    */

   for (i=0; i < 3; ++i)
   {
      vc1[i] = pts[index3][i] - pts[index1][i];
      vc2[i] = pts[index4][i] - pts[index1][i];
      if ((vc1[i] < MAETA_BIG) && (vc1[i] > - MAETA_BIG))
      {
         vc1[i] = 0.0;
      }
      if ((vc2[i] < MAETA_BIG) && (vc2[i] > - MAETA_BIG))
      {
         vc2[i] = 0.0;
      }
   }

   /* 
    *  Cross the vectors to get the normal to that face.
    */

   MAcrossvc(msg, vc1, vc2, normal);

   /*
    *  Cross the normal and view normal to see if they are parallel.
    *  If they are parallel then the result will be zero.
    */

   MAcrossvc(msg, view, normal, result);

#ifdef NOT_INCLUDED 
   printf("x vector for poly %f %f %f\n",vc1[0],vc1[1], vc1[2]);
   printf("y vector for poly %f %f %f\n",vc2[0],vc2[1], vc2[2]);
   printf("normal for poly %f %f %f\n",normal[0],normal[1], normal[2]);
   printf("normal for view %f %f %f\n",view[0], view[1], view[2]);
   printf("cross of poly and view norm %f %f %f\n\n", result[0], result[1], result[2]);
#endif

   if ((result[0] == 0.0) &&
       (result[1] == 0.0) &&
       (result[2] == 0.0))
   {
MAdotvc(msg, view, normal, result);

#ifdef NOT_INCLUDED
   printf("dot product of poly and view norm %f\n\n\n",result[0]);
#endif

if(result[0] >= 0.0){
      for (i=0; i < 3; ++i)
      {
         /*
          *  Form lines that are the diagonal of the cube face.  Insure 
          *  that face The first point x is less than the second point x.
          */

         if (pts[index1][0] <= pts[index2][0])
         {
            line1->point1[i] = pts[index1][i];
            line1->point2[i] = pts[index2][i];
         }else
         {
            line1->point1[i] = pts[index2][i];
            line1->point2[i] = pts[index1][i];
         }


         if (pts[index3][0] >= pts[index4][0])
         {
            line2->point1[i] = pts[index3][i];
            line2->point2[i] = pts[index4][i];
         }else
         {
            line2->point1[i] = pts[index4][i];
            line2->point2[i] = pts[index3][i];
         }
      }
#ifdef NOTHING
   printf("LINE 1 :\n");
   printf("   point1 : ");
   for(i=0; i<3; i++) printf("%f ",line1->point1[i]);
   printf("\n");
   printf("   point2 : ");
   for(i=0; i<3; i++) printf("%f ",line1->point2[i]);
   printf("\n");

   printf("LINE 2 :\n");
   printf("   point1 : ");
   for(i=0; i<3; i++) printf("%f ",line2->point1[i]);
   printf("\n");
   printf("   point2 : ");
   for(i=0; i<3; i++) printf("%f ",line2->point2[i]);
   printf("\n");
#endif

      /*
       *  Form lines that represent the cube face.
       */

      if (num_lines && lines)
      {
         *num_lines = 4;
         for (i=0; i < 3; ++i)
         {
            lines[0].point1[i] = line1->point1[i];   
            lines[0].point2[i] = line2->point1[i];   
            lines[1].point1[i] = line2->point2[i];   
            lines[1].point2[i] = line1->point2[i];   
            lines[2].point1[i] = line1->point1[i];   
            lines[2].point2[i] = line2->point2[i];   
            lines[3].point1[i] = line2->point1[i];   
            lines[3].point2[i] = line1->point2[i];   
         }
      }
      return(1);
}
   }
   return(0);
}
end implementation Root;
