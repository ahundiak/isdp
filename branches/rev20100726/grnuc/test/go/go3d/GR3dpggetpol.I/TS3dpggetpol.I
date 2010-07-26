class implementation GR3dpolygon;

#include <stdio.h>
#include <memory.h>
#include <limits.h>
#include <sys/types.h>
#include <alloca.h>
#include "msdef.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "exdef.h"
#include "exmacros.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "DEso.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "madef.h"
#include "refdef.h"
#include "ref.h"
#include "gocmacros.h"


#define MAX 	4057
#define MIN_X   -100
#define MAX_X	100
#define MIN_Y   -100
#define MAX_Y	100

extern TSsetGraphicsATPflag();
extern DEcheck_display();

main ()
/*
   Create some 3d polygons, get their polylines and display them.
*/
{
  int                 i, j, l, status, count, nb_points, action;
  long                msg;
  GRspacenum          osnum;
  OM_S_OBJID          *objids, mod_id;
  double              *points;
  struct GRmd_env     md_env;
  struct IGRpolyline  polyline;
  struct GRabsg_hdr   absg_hdr;
  struct IGRbsp_curve *curve;
  struct IGRdisplay   symb;
    
  TSsetGraphicsATPflag ( 0 );
  
  points = (double *)alloca ( sizeof ( double ) * MAX * 6 );
  objids = (OM_S_OBJID *)alloca ( sizeof ( OM_S_OBJID ) * MAX );
  ex$get_cur_mod ( id = &mod_id, osnum = &osnum );
  symb.color = 1;
  symb.weight = 0;
  symb.style = 0;
  
  /* let's add some objects */
  for (count = 0, nb_points = 2; nb_points < MAX; nb_points *= 2, count++)
  {
    md_env.md_id.osnum = osnum;
    md_env.md_id.objid = mod_id;
    md_env.md_env.matrix_type = MAIDMX;
    for (i = 0, j = 0; i < nb_points; j += 6, i++)
    {
      points [j] = MIN_X + i * (MAX_X - MIN_X) / nb_points + count * 10;
      points [j + 1] = MIN_Y;
      points [j + 2] = count * 20;
      points [j + 3] = MIN_X + (i + 1) * (MAX_X - MIN_X) / nb_points + count * 10;
      points [j + 4] = MAX_Y;
      points [j + 5] = count * 20;
    }
    
    symb.color++;
    status = TSplace_polygon ( &msg, &(objids [count]), nb_points, points, &md_env, &symb );
    if (!(status & 1))
    {
      fprintf ( stderr, "%s at %d: error in GR3dpolygon construction\n", __FILE__, __LINE__ );
      om$report_error ( sts = status );
      continue;
    }  
    
    /* we send a getpolyline message */
    polyline.num_points = 101;
    GRbc_size ( 2, polyline.num_points, 0, 0, absg_hdr.geometry_size );
    absg_hdr.id.objid = objids [count];
    absg_hdr.id.osnum = OM_Gw_current_OS;
    absg_hdr.matrix_type = MAIDMX;

    for (l = 0; l < 16; l++)
      absg_hdr.matrix [l] = 0.0;
    absg_hdr.matrix [0] = 1.0;
    absg_hdr.matrix [5] = 1.0;
    absg_hdr.matrix [10] = 1.0;
    absg_hdr.matrix [15] = 1.0;

    curve = (struct IGRbsp_curve *) GRabsg_alloc ( &msg, &absg_hdr );

    GRbc_partition ( curve, 2, polyline.num_points, 0, 0 );
    polyline.points = curve->poles;

    status = om$send ( msg = message GRlinear.GRgetpolyline (
      &msg, &absg_hdr.matrix_type, absg_hdr.matrix, &action, &polyline ),
      senderid = NULL_OBJID,
      targetos = osnum,
      targetid = objids [count] );

    if (!(1 & status))
    {
      /* we might fail because we don't have enough memory */
      GRbc_size ( 2, polyline.num_points, 0, 0, absg_hdr.geometry_size );
      curve = (struct IGRbsp_curve *)GRabsg_alloc ( &msg, &absg_hdr );
      GRbc_partition ( curve, 2, polyline.num_points, 0, 0 );
      polyline.points = curve->poles;
      if (1 & msg)
      {
        action = 2;
        status = om$send ( msg = message GRlinear.GRgetpolyline (
            &msg, &absg_hdr.matrix_type, absg_hdr.matrix, &action, &polyline ),
            targetos = osnum,
            senderid = NULL_OBJID,
            targetid = objids [count] );
      }
      else
      {
        fprintf ( stderr, "Error in %s at line %d: unsuccessful alocation\n", __FILE__, __LINE__ );
        continue;
      }
    }
    
    if (status != OM_S_SUCCESS)
    {
      fprintf ( stderr, "Error in %s at line %d: unsuccessful get polyline\n", __FILE__, __LINE__ );
      continue;
    }
    else
      /* we compare the polylines */
      for (l = 0; l < nb_points; l++)
        if (points [l] != polyline.points [l])
        {
          fprintf ( stderr, "Error in %s at line %d: polylines are different\n", __FILE__, __LINE__ );
          break;
        }
  }

  /* we check the display */
  TSsetGraphicsATPflag ( 1 );
  DEcheck_display ();
  
  return OM_S_SUCCESS;
}


TSplace_polygon ( msg, p_objid, nb_points, points, md_env, alt_symb )
                  long              *msg;
                  GRobjid           *p_objid;
                  int               nb_points;
                  double            *points;
                  struct GRmd_env   *md_env;
                  struct IGRdisplay *alt_symb;
/*
   This routine places a 3d polygon.
*/
{
  long                  status;
  struct GRvg_construct ConstructList;
  struct IGRbsp_curve   curve;
  struct IGRdisplay     symb;

  status = OM_S_SUCCESS;
  *msg = MSSUCC;

   /* init. varables for construct */
  ConstructList.msg = msg;
  ConstructList.env_info = md_env;
  if (alt_symb)
  {
    symb.color = alt_symb->color;
    symb.style = alt_symb->style;
    symb.weight = alt_symb->weight;
  }
  else
  {
    symb.color = 1;
    symb.style = 0;
    symb.weight = 0;
  }
  ConstructList.display = &symb;
  curve.poles = &points [0];
  curve.num_poles = nb_points;
  ConstructList.geometry = (IGRchar *)&curve;
  ConstructList.newflag = FALSE;
  ConstructList.level = 0;
  ConstructList.class_attr = NULL;
  ConstructList.name = NULL;
  ConstructList.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE | GRIS_PLANAR;

  status = om$construct ( msg       = message GRgraphics.GRconstruct( &ConstructList ),
                          osnum     = md_env->md_id.osnum,
                          classname = "GR3dpolygon",
                          p_objid   = p_objid );

  return status;
}


end implementation GR3dpolygon;
