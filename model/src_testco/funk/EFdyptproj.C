# include "emserr.h"
# include "bserr.h"
# include "EMS.h"
# include "OMminimum.h"
# include "OMmacros.h"
# include "msdef.h"
# include "igrtypedef.h"
# include "OMerrordef.h"
# include "igr.h"
# include "igrdp.h"
# include "igrdp.h"
# include "igetypedef.h"
# include "dpstruct.h"
# include "dp.h"
# include "godef.h"
# include "gr.h"
# include "go.h"
# include "ex.h"
# include "igrdef.h"
# include "dpmacros.h"
# include "bsparameters.h"
# include "EMSerrordef.h"
# include "bserr.h"
# include "madef.h"
# include "msdef.h"
#include "ma.h"
#include "maptlnpro.h"

/*
  HISTORY

Sudha  :  07/02/93  :  Modified for BSprototypes ansification

*/

extern IGRlong DY_proj_ln_dyn(); 

IGRint EFdyptproj( pnt, vector, nat_side, display)

IGRpoint             pnt;
IGRvector            vector;
IGRboolean           nat_side;
struct IGRdisplay    *display;

{
  struct         DPele_header header;
  struct         IGRpolyline  pline;
/*  struct         IGRgeometry  geometry; ### COMMENTED - THIS SHOULD BE union - Ashok */
  union         IGRgeometry  geometry;
  IGRpoint       points[3];

  if ( nat_side == FALSE )
  {
  points[0][0] = pnt[0] + vector[0];
  points[0][1] = pnt[1] + vector[1];
  points[0][2] = pnt[2] + vector[2];
  }
  else
  {
  points[0][0] = pnt[0] - vector[0];
  points[0][1] = pnt[1] - vector[1];
  points[0][2] = pnt[2] - vector[2];
  }

  points[1][0] = pnt[0];
  points[1][1] = pnt[1];
  points[1][2] = pnt[2];

  pline.num_points = 2;
  pline.points     = &points[1][0];

  dp$build_dis_buffer(
   buffer = &header,
   display_att = display,
   geometry = &pline,
   type   = IGRPY);

  dp$dynamics(
    dyn_fun = DY_proj_ln_dyn,
    information = &header);

  return(OM_S_SUCCESS);
}

static IGRlong DY_proj_ln_dyn(
  header,
  cursor_pt,
  matrix,
  objects,
  num_objects,
  buffer,
  num_buffers,
  dummy_in1,
  dummy_in2,
  dummy_in3,
  dummy_out1,
  dummy_out2,
  dummy_out3)

  struct   DPele_header  *header, **buffer;
  struct   GRid          **objects;
  struct   EX_button     *cursor_pt;
  IGRint                 *num_objects, *num_buffers;
  IGRdouble              *matrix;
  IGRchar                **dummy_in1, **dummy_in2, **dummy_in3;
  IGRchar                **dummy_out1, **dummy_out2, **dummy_out3;

  {
    IGRlong           msg;
    IGRpoint          crpt, line_pt;
    struct IGRline    line;
    IGRdouble         t;
    IGRpoint          *points;

    msg = MSSUCC;
    points = (IGRpoint *)header->geometry.polyline->points;
    points-- ;
    
    crpt[0] = cursor_pt->x;
    crpt[1] = cursor_pt->y;
    crpt[2] = cursor_pt->z;

    line.point1 = points[0];
    line.point2 = points[1];

    MAptlnproj(
          &msg,
          crpt,
          &line,
          line_pt,
          &t);

    if (t <= 0.0)
     {
     points[2][0] = points[1][0];
     points[2][1] = points[1][1];
     points[2][2] = points[1][2];
     }
    else
     {
     points[2][0] = line_pt[0];
     points[2][1] = line_pt[1];
     points[2][2] = line_pt[2];
     }

    *buffer = header;
    *num_buffers = 1;

    return( MSSUCC );
   }   
