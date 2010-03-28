/* #######################    APOGEE COMPILED   ######################## */
class implementation Root;

#include <stdio.h>

#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "igrdp.h"
#include "dpstruct.h"
#include "gr.h"
#include "ex.h"
#include "dpmacros.h"
#include "codpdef.h"
#include "godef.h"
#include "msdef.h"
#include "msmacros.h"
#include "execmsg.h"
#include "grmessage.h"


struct dyn_pyrm_st
{
    struct DPele_header  elem[5];
    IGRint               state;
    IGRdouble            *eye_pt;
    IGRdouble            *coi_pt;
    IGRdouble            *vup_pt;
    IGRdouble            *angle_dist;
    IGRdouble            *near_distance;
    IGRdouble            *far_distance;
    IGRdouble            *vpn_pt;
    IGRdouble            *vrp_pt;
    IGRdouble            *plane_radius;
    IGRshort             num_buffers;
    IGRshort             *buf_index;
    IGRlong              error;
};


#define MAX_ANGLE 6.2832;

%safe
/* prototype files */
#include "DPdypyrm.h"
#include "dpalignper.h"
#include "DPdyplane.h"
#include "dpdynamics.h"

#include "masincos.h"
#include "mainvmx.h"
#include "malncbcli.h"
#include "maptln2di.h"
#include "masqrt.h"
#include "macrossvc.h"
#include "marang2vc.h"
#include "madotvc.h"
#include "maraddeg.h"
#include "maptlnpro.h"
#include "ma2ptdis.h"
#include "masin.h"
#include "maptsxfor.h"

%endsafe


IGRint DPbuildpyrm ( msg, state, coi_pt, eye_pt, vup_pt, view_angle,
                        near_distance, far_distance, polyline)

IGRlong             *msg;
IGRint              state;
IGRdouble           *eye_pt;
IGRdouble           *coi_pt;
IGRdouble           *vup_pt;
IGRdouble           *near_distance;
IGRdouble           *far_distance;
IGRdouble           *view_angle;
struct IGRpolyline  *polyline;

{

IGRdouble   ex_pt[3];
IGRdouble   sine, cosine;
IGRdouble   angle;
IGRdouble   near_radius;
IGRdouble   far_radius;
IGRdouble   *pt;
IGRdouble   design_min[3];
IGRdouble   design_max[3];
IGRdouble   extramx[16];
IGRdouble   outmat[16];
IGRdouble   near_dist = 50;
IGRdouble   far_dist = 50;
IGRdouble   normal[3];
IGRdouble   vup_vec[3];

struct IGRline org_line;
struct IGRline_seg ext_line;

IGRshort   four = 4;
IGRlong    status;

    status = TRUE;
    *msg = 1;
    pt = polyline->points;
    angle = *view_angle * 0.5;
    MAsincos ( msg, &angle, &sine, &cosine );
    if (cosine <= 0)
    {
        *msg = DPAng180;
        status = FALSE;
        goto fini;
    }
    else if (sine == 0)
    {
        *msg = DPAng0;
        status = FALSE;
        goto fini;
    }

    state &= ~ DYN_PYRAMID;
    
    if ( state & DYN_PY_TRUN_NEAR )
    {
        if (*near_distance != 0)
        {
            near_dist = *near_distance;
        }
    }

    /*
     *   Finding matrix to rotate the view vector to the negative z axis.
     */

    normal[0] = coi_pt[0] - eye_pt[0];
    normal[1] = coi_pt[1] - eye_pt[1];
    normal[2] = coi_pt[2] - eye_pt[2];

    vup_vec[0] = vup_pt[0] - coi_pt[0];
    vup_vec[1] = vup_pt[1] - coi_pt[1];
    vup_vec[2] = vup_pt[2] - coi_pt[2];

    status = DPalignper(msg,0,normal, vup_vec, eye_pt, extramx, outmat);

    if ( status & 1 )
    {
        status = MAinvmx ( msg, &four, outmat, extramx);
    }

    /* The array points for the truncated pyramid are the following:
                far clip plane:  0 - 14
                near clip plane: 15 - 26
                connections:     27 - 47

       If the pyramid does not have a near clipping plane or the far clipping
       plane has become the eye point, connections are 
       made from the other (usually far) clip plane to the eye point, 
       and the array points are as follows:
                    far clip plane:  0 - 14
                    connections:         15 - 35

       If a far clip plane is not specified, then a far clip plane is 
       calculated at the design file limits, and connections are made to 
       the eye point.
      */

    /* Loading the Near Clipping Plane */

    near_radius = sine / cosine * near_dist;
    near_dist = - near_dist; /* negating because rotating to the negative z axis */

    /* Loading the Far Clipping Plane */

    if (state & DYN_PY_TRUN_FAR)
    {
        far_radius = (sine / cosine) * (*far_distance);
        far_dist = - *far_distance;

        if (*far_distance == 0)
        {
            DPdyplane (msg,near_radius, near_dist,pt,extramx );                
        }
        else
        {
            DPdyplane (msg,far_radius, far_dist, pt,extramx );
            if ( state & DYN_PY_TRUN_NEAR )
            {
                 DPdyplane (msg,near_radius, near_dist,&pt[15],extramx );
            }
         }
    }
    else          /* Far Clipping Plane at Design file limits */
    {
         DPdyplane (msg,near_radius, near_dist,&pt[15],extramx );

         if ( status & 1 )
         {
              design_min[0] = design_min[1] = design_min[2] = GRDGNLIMITS_MIN_D;
              design_max[0] = design_max[1] = design_max[2] = GRDGNLIMITS_MAX_D;

              org_line.point1 = eye_pt;
              org_line.point2 = &pt[15];
              ext_line.beg_point = ex_pt;
              ext_line.end_point = &pt[0];

              status = MAlncbclip(msg,&org_line,design_min,design_max,&ext_line);
         }

         if (status & 1)
         {
              org_line.point2 = &pt[18];
              ext_line.end_point = &pt[3];

              status = MAlncbclip(msg,&org_line,design_min,design_max,&ext_line);
         }
 
         if (status & 1)
         {
              org_line.point2 = &pt[21];
              ext_line.end_point = &pt[6];

              status = MAlncbclip(msg,&org_line,design_min,design_max,&ext_line);
         }

         if (status & 1)
         {
              org_line.point2 = &pt[24];
              ext_line.end_point = &pt[9];
              status = MAlncbclip(msg,&org_line,design_min,design_max,&ext_line);    
         }

         pt[12] = pt[0];
         pt[13] = pt[1];
         pt[14] = pt[2];
    }

            /* Loading Connections */

    if ((!(state & DYN_PY_TRUN_NEAR)) || *near_distance == 0 || *far_distance == 0)
    {
         polyline->num_points = 12;

         pt[15] = eye_pt[0];
         pt[16] = eye_pt[1];
         pt[17] = eye_pt[2];

         pt[18] = pt[3];
         pt[19] = pt[4];
         pt[20] = pt[5];

         pt[21] = eye_pt[0];
         pt[22] = eye_pt[1];
         pt[23] = eye_pt[2];

         pt[24] = pt[6];
         pt[25] = pt[7];
         pt[26] = pt[8];

         pt[27] = eye_pt[0];
         pt[28] = eye_pt[1];
         pt[29] = eye_pt[2];

         pt[30] = pt[9];
         pt[31] = pt[10];
         pt[32] = pt[11];

         pt[33] = eye_pt[0];
         pt[34] = eye_pt[1];
         pt[35] = eye_pt[2];
    }
    else
    {
         polyline->num_points = 16;

         pt[30] = pt[18];
         pt[31] = pt[19];
         pt[32] = pt[20];

         pt[33] = pt[3];
         pt[34] = pt[4];
         pt[35] = pt[5];

         pt[36] = pt[6];
         pt[37] = pt[7];
         pt[38] = pt[8];

         pt[39] = pt[21];
         pt[40] = pt[22];
         pt[41] = pt[23];

         pt[42] = pt[24];
         pt[43] = pt[25];
         pt[44] = pt[26];

         pt[45] = pt[9];
         pt[46] = pt[10];
         pt[47] = pt[11];
    }
fini:
    return ( status );
}


IGRint DPbuildparall( msg, state, coi_pt, eye_pt, vup_pt, radius,
                        near_distance, far_distance, polyline)

IGRlong             *msg;
IGRint              state;
IGRdouble           *eye_pt;
IGRdouble           *coi_pt;
IGRdouble           *vup_pt;
IGRdouble           *near_distance;
IGRdouble           *far_distance;
IGRdouble           *radius;
struct IGRpolyline  *polyline;

{

IGRdouble  ex_pt[3];
IGRdouble  *pt;
IGRdouble  design_min[3];
IGRdouble  design_max[3];
IGRdouble  extramx[16];
IGRdouble  outmat[16];
IGRdouble  near_dist = 0;
IGRdouble  far_dist = 0;
IGRdouble  normal[3];
IGRdouble  vup_vec[3];

struct IGRline      org_line;
struct IGRline_seg  ext_line;

IGRshort   four = 4;
IGRlong    status;

    status = TRUE;
    *msg = 1;
    pt = polyline->points;
    state &= ~ DYN_PYRAMID;
    if ( state & DYN_PY_TRUN_NEAR )
    {
        near_dist = *near_distance;
    }

    /*
     *   Finding matrix to rotate the view vector to the negative z axis.
     */

    normal[0] = coi_pt[0] - eye_pt[0];
    normal[1] = coi_pt[1] - eye_pt[1];
    normal[2] = coi_pt[2] - eye_pt[2];

    vup_vec[0] = vup_pt[0] - coi_pt[0];
    vup_vec[1] = vup_pt[1] - coi_pt[1];
    vup_vec[2] = vup_pt[2] - coi_pt[2];

    status = DPalignper(msg, 0, normal, vup_vec, eye_pt, extramx, outmat);

    if ( status & 1 )
    {
         status = MAinvmx ( msg, &four, outmat, extramx);
    }

    /* The array points for the truncated pyramid are the following:
                far clip plane:  0 - 14
                near clip plane: 15 - 26
                connections:     27 - 47

       If the pyramid does not have a near clipping plane or the far clipping
       plane has become the eye point, connections are 
       made from the other (usually far) clip plane to the eye point,
       and the array points are as follows:
                far clip plane:  0 - 14
                connections:     15 - 35

       If a far clip plane is not specified, then a far clip plane is 
       calculated at the design file limits, and connections are made to 
       the eye point.
     */

    /* Loading the Near Clipping Plane */

    near_dist = - near_dist; /* negating because rotating to the negative z axis */

    /* Loading the Far Clipping Plane */

    if (state & DYN_PY_TRUN_FAR)
    {
         if (*far_distance != 0)
         {
              far_dist = - *far_distance;
         }

         DPdyplane (msg,*radius, far_dist, pt,extramx );
         DPdyplane (msg,*radius, near_dist,&pt[15],extramx );
    }
    else          /* Far Clipping Plane at Design file limits */
    {
         far_dist = near_dist + 10;
         DPdyplane (msg,*radius, near_dist,&pt[15],extramx );
         DPdyplane (msg,*radius, far_dist,&pt[30],extramx );

         if ( status & 1 )
         {
              design_min[0] = design_min[1] = design_min[2] = GRDGNLIMITS_MIN_D;
              design_max[0] = design_max[1] = design_max[2] = GRDGNLIMITS_MAX_D;

              org_line.point1 = &pt[30];
              org_line.point2 = &pt[15];
              ext_line.beg_point = ex_pt;
              ext_line.end_point = &pt[0];

              status = MAlncbclip(msg,&org_line,design_min,design_max,&ext_line);
         }

         if (status & 1)
         {
              org_line.point1 = &pt[33];
              org_line.point2 = &pt[18];
              ext_line.end_point = &pt[3];

              status = MAlncbclip(msg,&org_line,design_min,design_max,&ext_line);
         }

         if (status & 1)
         {
              org_line.point1 = &pt[36];
              org_line.point2 = &pt[21];
              ext_line.end_point = &pt[6];

              status = MAlncbclip(msg,&org_line,design_min,design_max,&ext_line);
         }

         if (status & 1)
         {
              org_line.point1 = &pt[39];
              org_line.point2 = &pt[24];
              ext_line.end_point = &pt[9];
              status = MAlncbclip(msg,&org_line,design_min,design_max,&ext_line);    
         }

         pt[12] = pt[0];
         pt[13] = pt[1];
         pt[14] = pt[2];
    }

            /* Loading Connections */

    polyline->num_points = 16;

    pt[30] = pt[18];
    pt[31] = pt[19];
    pt[32] = pt[20];

    pt[33] = pt[3];
    pt[34] = pt[4];
    pt[35] = pt[5];

    pt[36] = pt[6];
    pt[37] = pt[7];
    pt[38] = pt[8];

    pt[39] = pt[21];
    pt[40] = pt[22];
    pt[41] = pt[23];

    pt[42] = pt[24];
    pt[43] = pt[25];
    pt[44] = pt[26];

    pt[45] = pt[9];
    pt[46] = pt[10];
    pt[47] = pt[11];

    return ( status );
}

/*
 *   DPdypyrm - This functions generates a polyline which represents the
 *                viewing pyramid for a perspective view
 *
 */

IGRint DPdypyrm( py_info, pt2, mtx, objects, num_objects,
                 buffers, num_buffers,
                   dummy1,dummy2,dummy3,dummy4,dummy5,dummy6)

struct dyn_pyrm_st   *py_info;
struct EX_button     *pt2;
IGRdouble            *mtx;
struct GRid          **objects;
IGRint               *num_objects;
struct DPele_header  **buffers;
IGRint               *num_buffers;
IGRchar              *dummy1;
IGRchar              *dummy2;
IGRchar              *dummy3;
IGRchar              **dummy4;
IGRchar              **dummy5;
IGRchar              **dummy6;

{
    IGRlong         status;              /* return status */
    IGRlong         msg;                 /* return message */

    struct IGRline  line;
    struct IGRline  view_vec;
    IGRdouble       t=0;
    IGRdouble       pt[3];
    IGRdouble       proj_pt[3];
    IGRdouble       deg_angle;
    IGRdouble       angle;
    IGRdouble       vec1[3];
    IGRdouble       vec2[3];
    IGRdouble       cross_vec[3];
    IGRdouble       normal[3];
    IGRdouble       vup_vec[3];
    IGRdouble       vrp[3];
    IGRdouble       invmx[4][4];
    IGRdouble       rotate[4][4];
    IGRdouble       outmat[4][4];
    IGRdouble       dist;
    IGRdouble       dot_prod;
    IGRlong         num_pts;
    IGRint          state;
    IGRshort        four = 4;

    status = TRUE;
    state =  py_info->state & DYN_CLEAR_DISPLAY;

    switch ( state )
    {
        case DYN_COI_PNT:
             py_info->elem[py_info->buf_index[1]].geometry.polyline->points[3] = pt2->x;
             py_info->elem[py_info->buf_index[1]].geometry.polyline->points[4] = pt2->y;
             py_info->elem[py_info->buf_index[1]].geometry.polyline->points[5] = pt2->z;

             py_info->coi_pt[0] = pt2->x;
             py_info->coi_pt[1] = pt2->y;
             py_info->coi_pt[2] = pt2->z;

             break;

        case DYN_EYE_PNT:
             py_info->elem[py_info->buf_index[1]].geometry.polyline->points[0] = pt2->x;
             py_info->elem[py_info->buf_index[1]].geometry.polyline->points[1] = pt2->y;
             py_info->elem[py_info->buf_index[1]].geometry.polyline->points[2] = pt2->z;

             py_info->eye_pt[0] = pt2->x;
             py_info->eye_pt[1] = pt2->y;
             py_info->eye_pt[2] = pt2->z;
        
             break;

        case DYN_UP:
             py_info->elem[py_info->buf_index[2]].geometry.polyline->points[3] = pt2->x;
             py_info->elem[py_info->buf_index[2]].geometry.polyline->points[4] = pt2->y;
             py_info->elem[py_info->buf_index[2]].geometry.polyline->points[5] = pt2->z;

             py_info->vup_pt[0] = pt2->x;
             py_info->vup_pt[1] = pt2->y;
             py_info->vup_pt[2] = pt2->z;
        
             break;

        case DYN_RADIUS:
             pt[0] = pt2->x;
             pt[1] = pt2->y;
             pt[2] = pt2->z;

             view_vec.point1 = py_info->eye_pt;
             view_vec.point2 = py_info->coi_pt;

             status = MAptln2dis (&msg, pt, &view_vec,&dist);
             *py_info->angle_dist = MAsqrt(&msg,&dist);
             break;
                
        case DYN_ANGLE:
             pt[0] = pt2->x;
             pt[1] = pt2->y;
             pt[2] = pt2->z;
        
             vec1[0] = py_info->coi_pt[0] - py_info->eye_pt[0];
             vec1[1] = py_info->coi_pt[1] - py_info->eye_pt[1];
             vec1[2] = py_info->coi_pt[2] - py_info->eye_pt[2];

             vec2[0] = pt[0] - py_info->eye_pt[0];
             vec2[1] = pt[1] - py_info->eye_pt[1];
             vec2[2] = pt[2] - py_info->eye_pt[2];

             status = MAdotvc(&msg,vec1,vec2,&dot_prod); 
             if (status == FALSE)
             {
                  break;
             }

             status = MAcrossvc (&msg, vec1, vec2, cross_vec);
             if (status == FALSE)
             {
                  ex$message( msgnumb = GR_E_InvAng, field = ERROR_FIELD );
                  break;
             }

             status = MArang2vc (&msg, vec1, vec2, cross_vec, &angle);
             if (status == FALSE)
             {
                  ex$message( msgnumb = GR_E_InvAng, field = ERROR_FIELD );
                  break;
             }

             MAraddeg(&msg,&angle,&deg_angle);

             if (deg_angle == 0)
             {
                  if (!( py_info->error & DPAng0))
                  {
                        *py_info->angle_dist = 0.001;        
                        py_info->error = DPAng0;
                        ex$message( msgnumb = GR_E_AngGreatDeg, 
                                    field = ERROR_FIELD );
                  }
                  else
                  {
                        *py_info->angle_dist = 0.001;        
                        py_info->error |= DPErrPyrm;
                  }
             }
             else if ((deg_angle >= 90) || (dot_prod < 0))
             {
                  if (!(py_info->error & DPAng180))
                  {
                        *py_info->angle_dist = 3.141;        
                        py_info->error = DPAng180;
                        ex$message( msgnumb = GR_E_AngSmalDeg, 
                                    field = ERROR_FIELD );
                  }
                  else
                  {
                        *py_info->angle_dist = 3.141;        
                        py_info->error |= DPErrPyrm;
                  }
             }
             else if ( py_info->error != DPOK )
             {
                  ex$message (msgnumb = EX_S_Clear);
                  py_info->error = DPOK;
                  deg_angle = deg_angle * 2;
                  ex$message(msgnumb = GR_I_ActAng,type="%f",var=`deg_angle`);
                  *py_info->angle_dist = angle * 2;
             }
             else
             {
                  *py_info->angle_dist = angle * 2;
                  deg_angle = deg_angle * 2;
                  ex$message(msgnumb = GR_I_ActAng,type="%f",var=`deg_angle`);
             }
             break;

        case DYN_NEAR:
             pt[0] = pt2->x;
             pt[1] = pt2->y;
             pt[2] = pt2->z;
        
             line.point1 = py_info->eye_pt;
             line.point2 = py_info->coi_pt;
             status = MAptlnproj ( &msg, pt, &line, proj_pt, &t );
             if (py_info->state & DYN_PARALLEL_P || t > 0)        
             {
                  if ( py_info->error != DPOK)
                  {
                       ex$message (msgnumb = EX_S_Clear);
                       py_info->error = DPOK;
                  }

                  if ( status & 1 )
                  {
                       status = MA2ptdis ( &msg, py_info->eye_pt, proj_pt,
                                           py_info->near_distance );
                       if (t < 0)
                       {
                            *py_info->near_distance = - *py_info->near_distance;
                       }
                  }
             }
             else
             {
                  if (!( py_info->error & DPNBehIPt))
                  {
                       py_info->error = DPNBehIPt;
                       ex$message( msgnumb = GR_E_NoBehindEye, 
                                   field = ERROR_FIELD );
                       *py_info->near_distance = 0;
                  }
                  else
                  {
                       *py_info->near_distance = 0.0001;
                       py_info->error |=DPErrPyrm;
                  }
             }
             break;
        
        case DYN_FAR:
             pt[0] = pt2->x;
             pt[1] = pt2->y;
             pt[2] = pt2->z;

             line.point1 = py_info->eye_pt;
             line.point2 = py_info->coi_pt;
             status = MAptlnproj ( &msg, pt, &line, proj_pt, &t );
             if (py_info->state & DYN_PARALLEL_P || t > 0)
             {
                  if ( py_info->error != DPOK)
                  {
                       py_info->error = DPOK;
                       ex$message (msgnumb = EX_S_Clear);
                  }

                  if ( status & 1 )
                  {
                       status = MA2ptdis ( &msg, py_info->eye_pt, proj_pt, 
                                           py_info->far_distance );
                       if (t < 0)
                       {
                            *py_info->far_distance = - *py_info->far_distance;
                       }
                  }
             }
             else
             {
                  if (!( py_info->error & DPFBehIPt))
                  {
                       py_info->error = DPFBehIPt;
                       ex$message( msgnumb = GR_E_NoBehindEye, 
                                   field = ERROR_FIELD );
                       if ( *py_info->near_distance != 0 )
                       {
                            *py_info->far_distance = 0;
                       }
                       else
                       {
                            *py_info->far_distance = 0.0001;
                            py_info->error |=DPErrPyrm;
                       }
                  }
                  else
                  {
                       *py_info->far_distance = 0.0001;
                       py_info->error |=DPErrPyrm;
                  }
             }
             break;

        case DYN_VRP:
             py_info->elem[py_info->buf_index[4]].geometry.polyline->points[3] = pt2->x;
             py_info->elem[py_info->buf_index[4]].geometry.polyline->points[4] = pt2->y;
             py_info->elem[py_info->buf_index[4]].geometry.polyline->points[5] = pt2->z;

             py_info->vrp_pt[0] = pt2->x;
             py_info->vrp_pt[1] = pt2->y;
             py_info->vrp_pt[2] = pt2->z;
             break;

        case DYN_VPN:
             py_info->elem[py_info->buf_index[4]].geometry.polyline->points[0] = pt2->x;
             py_info->elem[py_info->buf_index[4]].geometry.polyline->points[1] = pt2->y;
             py_info->elem[py_info->buf_index[4]].geometry.polyline->points[2] = pt2->z;

             py_info->vpn_pt[0] = pt2->x;
             py_info->vpn_pt[1] = pt2->y;
             py_info->vpn_pt[2] = pt2->z;
             break;        
    } /* close for switch */
    if ( status & 1 )
    {
        if ( py_info->state & DYN_PYRAMID && (!(py_info->error & DPErrPyrm)))
        {
             if ( py_info->state & DYN_PARALLEL_P )
             {
                  status = DPbuildparall ( &msg, 
                                           py_info->state,
                                           py_info->coi_pt, 
                                           py_info->eye_pt,
                                           py_info->vup_pt,
                                           py_info->angle_dist, 
                                           py_info->near_distance,
                                           py_info->far_distance,
                                           py_info->elem[py_info->buf_index[0]].geometry.polyline);
            }
            else
            {
                  status = DPbuildpyrm ( &msg, py_info->state,
                                         py_info->coi_pt, 
                                         py_info->eye_pt,
                                         py_info->vup_pt,
                                         py_info->angle_dist, 
                                         py_info->near_distance,
                                         py_info->far_distance,
                                         py_info->elem[py_info->buf_index[0]].geometry.polyline);
            }
        }
        if ( py_info->state & DYN_PROJ_PLANE )
        {
            normal[0] = py_info->vrp_pt[0] - py_info->vpn_pt[0];
            normal[1] = py_info->vrp_pt[1] - py_info->vpn_pt[1];
            normal[2] = py_info->vrp_pt[2] - py_info->vpn_pt[2];

            vup_vec[0] = py_info->vup_pt[0] - py_info->coi_pt[0];
            vup_vec[1] = py_info->vup_pt[1] - py_info->coi_pt[1];
            vup_vec[2] = py_info->vup_pt[2] - py_info->coi_pt[2];

            status = DPalignper(&msg, 0, normal, vup_vec, py_info->vpn_pt, 
                                (IGRdouble *)rotate, (IGRdouble *)outmat);
            if ( status & 1 )
                {
                    status = MAinvmx ( &msg, &four, (IGRdouble *)outmat, 
                                       (IGRdouble *)invmx);
                }
            num_pts = 1;
            status = MAptsxform ( &msg, &num_pts, (IGRdouble *)outmat, 
                                  py_info->vrp_pt, vrp);
            status = DPdyplane ( &msg,
                                 *py_info->plane_radius,
                                 vrp[2],
                                 py_info->elem[py_info->buf_index[3]].geometry.polyline->points,
                                 (IGRdouble *)invmx);
        }
    }
    *buffers = py_info->elem;
    *num_buffers = py_info->num_buffers;

    return ( status );
}

/*
 *   Initialize buffers for dynamics
 */

#if defined(__STDC__) || defined(__cplusplus)
IGRint DPdypyrminit ( 	IGRshort           dyn_on_off,
			IGRint             state,
			struct IGRdisplay  *dis_attr[],
			IGRdouble          *coi_pt,
			IGRdouble          *eye_pt,
			IGRdouble          *vup_pt,
			IGRdouble          *angle_radius,
			IGRdouble          *near_distance,
			IGRdouble          *far_distance,
			IGRdouble          *vrp_pt,
			IGRdouble          *vpn_pt)
#else
IGRint DPdypyrminit ( dyn_on_off, state, dis_attr, coi_pt, eye_pt, vup_pt, angle_radius,
                        near_distance,far_distance, vrp_pt, vpn_pt)

IGRshort           dyn_on_off;
IGRint             state;
IGRdouble          *coi_pt;
IGRdouble          *eye_pt;
IGRdouble          *vup_pt;
IGRdouble          *angle_radius;
IGRdouble          *near_distance;
IGRdouble          *far_distance;
IGRdouble          *vrp_pt;
IGRdouble          *vpn_pt;
struct IGRdisplay  *dis_attr[];
#endif

{
    IGRlong  status;
    IGRint   ex_state;

    struct dyn_pyrm_st  py_info;
    struct IGRpolyline  vw_vec;
    struct IGRpolyline  vup;
    struct IGRpolyline  pyramid;
    struct IGRpolyline  vpn;
    struct IGRpolyline  plane;

    IGRdouble  vw_vec_pts[6];
    IGRdouble  vup_pts[6];
    IGRdouble  pyrm_pts[48];
    IGRdouble  plane_pts[15];
    IGRdouble  vpn_pts[9];

    IGRdouble  eye[3];
    IGRdouble  coi[3];
    IGRdouble  vrp[3];
    IGRdouble  loc_vpn[3];
    IGRdouble  near_clip;
    IGRdouble  far_clip;
    IGRdouble  ang_rad;
    IGRdouble  plane_rad;
    IGRdouble  loc_vup[3];
    IGRdouble  distance;
    IGRshort   buf_index[5];
    IGRlong    rc;


    if ( dyn_on_off )
    {
         py_info.error = DPOK;
         py_info.state= state;        

/*       
         py_info.eye_pt = eye_pt;
         py_info.coi_pt = coi_pt;
         py_info.vup_pt = vup_pt;
         py_info.view_angle = view_angle;
         py_info.near_distance = near_distance;
         py_info.far_distance = far_distance;
         py_info.vrp_pt = vrp_pt;
         py_info.vpn_pt = vpn_pt;
*/
         eye[0] = eye_pt[0];
         eye[1] = eye_pt[1];
         eye[2] = eye_pt[2];

         coi[0] = coi_pt[0];
         coi[1] = coi_pt[1];
         coi[2] = coi_pt[2];

         loc_vup[0] = vup_pt[0];
         loc_vup[1] = vup_pt[1];        
         loc_vup[2] = vup_pt[2];

         ang_rad = *angle_radius;

         near_clip = *near_distance;
         far_clip = *far_distance;

         vrp[0]=vrp_pt[0];
         vrp[1]=vrp_pt[1];
         vrp[2]=vrp_pt[2];

         loc_vpn[0] = vpn_pt[0];
         loc_vpn[1] = vpn_pt[1];        
         loc_vpn[2] = vpn_pt[2];

         py_info.buf_index = buf_index;        

         py_info.eye_pt = eye;
         py_info.coi_pt = coi;
         py_info.vup_pt = loc_vup;
         py_info.angle_dist = &ang_rad;
         py_info.near_distance = &near_clip;
         py_info.far_distance = &far_clip;
         py_info.vrp_pt = vrp;
         py_info.vpn_pt = loc_vpn;
         py_info.plane_radius = &plane_rad;
         py_info.num_buffers = 0;

         if (state & DYN_PYRAMID)
         {
              py_info.buf_index[0] = py_info.num_buffers;
              ex_state = DYN_PY_TRUN_NEAR & ~DYN_PYRAMID;
              pyramid.points = pyrm_pts;
              dp$build_dis_buffer ( type = IGRPY,
                                    buffer = &py_info.elem[py_info.num_buffers],
                                    display_att = dis_attr[0],
                                    geometry = &pyramid );
              py_info.num_buffers++;
         }
         if (state & DYN_VIEW_VECTOR)
         {
              py_info.buf_index[1] = py_info.num_buffers;
              vw_vec.num_points=2;
              vw_vec.points = vw_vec_pts;
              vw_vec_pts[0] = eye_pt[0];
              vw_vec_pts[1] = eye_pt[1];
              vw_vec_pts[2] = eye_pt[2];
              vw_vec_pts[3] = coi_pt[0];
              vw_vec_pts[4] = coi_pt[1];
              vw_vec_pts[5] = coi_pt[2];
              dp$build_dis_buffer ( type = IGRPY,
                                    buffer = &py_info.elem[py_info.num_buffers],
                                    display_att = dis_attr[1],
                                    geometry = &vw_vec);
              py_info.num_buffers++;
         }
         if (state & DYN_VUP)
         {
              py_info.buf_index[2] = py_info.num_buffers;
              vup.num_points=2;
              vup.points = vup_pts;
              vup_pts[0] = coi_pt[0];
              vup_pts[1] = coi_pt[1];
              vup_pts[2] = coi_pt[2];
              vup_pts[3] = vup_pt[0];
              vup_pts[4] = vup_pt[1];
              vup_pts[5] = vup_pt[2];
              dp$build_dis_buffer ( type = IGRPY,
                                    buffer = &py_info.elem[py_info.num_buffers],
                                    display_att = dis_attr[2],
                                    geometry = &vup );
              py_info.num_buffers++;
         }
         if (state & DYN_PROJ_PLANE)
         {
              MA2ptdis (&rc, py_info.eye_pt, py_info.coi_pt, &distance );

              *py_info.plane_radius = distance * 0.5 * (MAsin ( &rc, &ang_rad));
              py_info.buf_index[3] = py_info.num_buffers;
              plane.num_points = 5;
              plane.points = plane_pts;
              dp$build_dis_buffer ( type = IGRPY,
                                    buffer = &py_info.elem[py_info.num_buffers],
                                    display_att = dis_attr[3],
                                    geometry = &plane );
              py_info.num_buffers++;
         }
         if (state & DYN_NORMAL)
         {
              py_info.buf_index[4] = py_info.num_buffers;
              vpn.num_points=2;
              vpn.points = vpn_pts;
              vpn_pts[0] = vpn_pt[0];
              vpn_pts[1] = vpn_pt[1];
              vpn_pts[2] = vpn_pt[2];
              vpn_pts[3] = vrp_pt[0];
              vpn_pts[4] = vrp_pt[1];
              vpn_pts[5] = vrp_pt[2];
              dp$build_dis_buffer ( type = IGRPY,
                                    buffer = &py_info.elem[py_info.num_buffers],
                                    display_att = dis_attr[4],
                                    geometry = &vpn );
              py_info.num_buffers++;
         }
         if ( state & DYN_VRP || state & DYN_VPN)
         {
              if ( state & DYN_PYRAMID )
              {
                   py_info.state= state & ~DYN_PYRAMID;

                   status = DPbuildpyrm ( &rc, py_info.state,

                   py_info.coi_pt, 
                   py_info.eye_pt,
                   py_info.vup_pt,
                   py_info.angle_dist, 
                   py_info.near_distance,
                   py_info.far_distance,
                   py_info.elem[py_info.buf_index[0]].geometry.polyline);
              }
         }

         dp$dynamics ( dyn_fun = DPdypyrm,
                       information = (char *)&py_info );
    }
    return ( TRUE );
}

end implementation Root;
