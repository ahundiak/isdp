/*

Name
  SSGetWinTol.I

Description

Notes


 */
class implementation Root;

#include <math.h>
#include <bsvalues.h>

#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMindex.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "dpdef.h"
#include "dpstruct.h"
#include "dp.h"
#include "dpmacros.h"
#include "gr.h"
#include "go.h"
#include "ex.h"
#include "exdef.h"
#include "exmacros.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "EMdtmacros.h"
#include "msdef.h"
#include "madef.h"
#include "SSdef.h"
#include "SS.h"
#include "bstypes.h"   /* for the BSrc typedef */

/* prototypes */
#include "bscrossp.h"
#include "mainvmx.h"
#include "maptsxfor.h"
#include "marotmx.h"


/*

Name
  SSGetWindowTolerance

Abstract
 Returns the tolerance and the range associated with it of a specific window.
 
Synopsis
  void SSGetWindowTolerance ( window, x, y, z, pTolerance, pRange, pBoreLine )
  GRobjid        window       IN   the window objid
  double         x, y, z      IN   current position of the mouse (world coords)
  double         *pTolerance  OUT  pointer to the tolerance for that window
  DB_3D_DBL_BOX  *pRange      OUT  the range for locate in that window
  struct IGRline *pBoreLine   OUT  a pointer to the bore line

Description

Return Value
  none

Notes

Index

Keywords
  smart-sketch,dynamics

History
  ??/??/92 : Henri Bequet     : prototype written
  08/05/93 : Shelley R. Heard : header added; implementation for 2.4 GRNUC.

 */

void SSGetWindowTolerance ( window, x, y, z, pTolerance, pRange, pBoreLine )
  GRobjid         window;
  IGRdouble       x, y, z;
  IGRdouble      *pTolerance;
  DB_3D_DBL_BOX  *pRange;
  struct IGRline *pBoreLine;
{
  if (window == SSLastWindow.objid)
  {
    *pTolerance = SSLastTolerance;
  }
  else
  {
    double                 DitTol, viewscale, angle;
    long                   Dummy;
    struct var_list        VariableList [3];
    GRspacenum             Osnum;
    long                   LocalStatus;
    short                  dimension = 4;
    long                   window_flag = 0x0;
    int                    which_matrix;
    /*
     * We compute the tolerance
     */
    
    gr$get_dit_tolerance ( buffer = &DitTol );
    ex$get_cur_mod ( osnum = &Osnum );

    VariableList [0].var            = GRAGAD_FLAGS;
    VariableList [0].var_ptr        = (char*) &window_flag;
    VariableList [0].num_bytes      = sizeof ( int );
    VariableList [0].bytes_returned = &Dummy;
    
    VariableList [1].var            = END_PARAM;
    VariableList [1].var_ptr        = NULL;
    VariableList [1].num_bytes      = 0;
    VariableList [1].bytes_returned = NULL;

    dp$inq_set_gragad ( msg = &LocalStatus, 
                        osnum = Osnum,
                        gragad_objid = window, 
                        which_error = &Dummy, 
                        var_list = VariableList );

    if ( window_flag & IS_PERSP )
    {
      which_matrix = WLD_TO_VIEWPORT;
    }
    else
    {
      which_matrix = WLD_TO_VIEW;
    }

    VariableList [0].var = VVOL_VIEWPORT_SCALE;
    VariableList [0].var_ptr = (char *) &viewscale;
    VariableList [0].num_bytes = sizeof ( double );
    VariableList [0].bytes_returned = &Dummy;
  
    VariableList [1].var = which_matrix;
    VariableList [1].var_ptr = (char*)SSWorldToView;
    VariableList [1].num_bytes = sizeof ( double ) * 16;
    VariableList [1].bytes_returned = &Dummy;

    VariableList [2].var = END_PARAM;
    VariableList [2].var_ptr = NULL;
    VariableList [2].num_bytes = 0;
    VariableList [2].bytes_returned = NULL;

    dp$inq_set_gragad ( msg = &LocalStatus, 
                        osnum = Osnum,
                        gragad_objid = window, 
                        which_error = &Dummy, 
                        var_list = VariableList );
    *pTolerance = SSLastTolerance = DitTol / viewscale;
    MAinvmx ( &LocalStatus, &dimension, SSWorldToView, SSViewToWorld );


    if (!SSRefLock)
    {
      SSRefXaxis [0] = SSWorldToView [0];
      SSRefXaxis [1] = SSWorldToView [1];
      SSRefXaxis [2] = SSWorldToView [2];
      SSRefYaxis [0] = SSWorldToView [4];
      SSRefYaxis [1] = SSWorldToView [5];
      SSRefYaxis [2] = SSWorldToView [6];
      BScrossp ( &LocalStatus, SSRefXaxis, SSRefYaxis, SSRefPlane.normal );
    }

    /*
     * rotation matrix (60 degrees) for the parallel icon
     */
    angle = M_PI / 3.0;
    MArotmx ( &LocalStatus, SSRefPlane.normal, &angle, SSRotMat60 );

    SSLastWindow.objid = window;
    SSLastWindow.osnum = Osnum;
  }
    
  /*
   * We compute the range: small cube if ref lock is on, long boreline
   * box if ref lock is off
   */
  if (SSRefLock)
  {
    if (pRange)
    {
      pRange->xmin = x - *pTolerance;
      pRange->ymin = y - *pTolerance;
      pRange->zmin = z - *pTolerance;
      pRange->xmax = x + *pTolerance;
      pRange->ymax = y + *pTolerance;
      pRange->zmax = z + *pTolerance;
    }

    if (pBoreLine)
    {
      pBoreLine->point1 [0] = x;
      pBoreLine->point1 [1] = y;
      pBoreLine->point1 [2] = z;
      pBoreLine->point2 = NULL;
    }

  }
  else
  {
    double         points [6], BoxPoints [24], *pDouble, point [3];
    struct IGRline BoreLine;
    long           NumberOfPoints = 2, LocalStatus;
    GRspacenum     Osnum;
    int            index;
    
    /*
     * Get the boreline
     */
    point [0] = x; 
    point [1] = y; 
    point [2] = z;
    BoreLine.point1 = &points [0];
    BoreLine.point2 = &points [3];
    ex$get_cur_mod ( osnum = &Osnum );
    DPlocbrln ( &LocalStatus, point, window, Osnum, &BoreLine );
    
    /*
     * Build a box around it: the face closest to the user is on the view plane
     * and the size of the face is given by the dit tolerance.
     */
    if (pBoreLine)
    {
      memcpy ( pBoreLine->point1, BoreLine.point1, sizeof ( IGRpoint ) );
      memcpy ( pBoreLine->point2, BoreLine.point2, sizeof ( IGRpoint ) );
    }

    memcpy ( SSBoreLine.point1, BoreLine.point1, sizeof ( IGRpoint ) );
    memcpy ( SSBoreLine.point2, BoreLine.point2, sizeof ( IGRpoint ) );

    if (pRange)
    {  
      /*
       *  Take points to view coordinate system
       */
      MAptsxform ( &LocalStatus, &NumberOfPoints, SSWorldToView, points, points );
  
      /*
       *   Build the cubes around the endpoints of the line.
       *          8 points. (in view coordinate system)
       */
  
      pDouble = BoxPoints;
      *pDouble++ = points [0] + *pTolerance;
      *pDouble++ = points [1] + *pTolerance;
      *pDouble++ = points [2];
  
      *pDouble++ = points [0] - *pTolerance;
      *pDouble++ = points [1] + *pTolerance;
      *pDouble++ = points [2];

      *pDouble++ = points [0] - *pTolerance;
      *pDouble++ = points [1] - *pTolerance;
      *pDouble++ = points [2];
  
      *pDouble++ = points [0] + *pTolerance;
      *pDouble++ = points [1] - *pTolerance;
      *pDouble++ = points [2];
  
      *pDouble++ = points [3] + *pTolerance;
      *pDouble++ = points [4] + *pTolerance;
      *pDouble++ = points [5];
  
      *pDouble++ = points [3] - *pTolerance;
      *pDouble++ = points [4] + *pTolerance;
      *pDouble++ = points [5];
  
      *pDouble++ = points [3] - *pTolerance;
      *pDouble++ = points [4] - *pTolerance;
      *pDouble++ = points [5];
  
      *pDouble++ = points [3] + *pTolerance;
      *pDouble++ = points [4] - *pTolerance;
      *pDouble = points [5];
  
      /*
       *  Find matrix to go from view coordinate system to world woordinate
       *  Transform boreline box from view to world
       */
      NumberOfPoints = 8;
      MAptsxform ( &LocalStatus, 
		   &NumberOfPoints, 
		    SSViewToWorld, 
		    BoxPoints, 
		    BoxPoints );
  
      /*
       *  Compute box (lower left and upper right).
       */
      pRange->xmin = pRange->ymin = pRange->zmin = MAXFLOAT;
      pRange->xmax = pRange->ymax = pRange->zmax = -MAXFLOAT;
      for (index = 0; index < 24; index += 3)
      {
        if (pRange->xmin > BoxPoints [index]) 
	   pRange->xmin = BoxPoints [index];
        if (pRange->ymin > BoxPoints [index + 1]) 
	  pRange->ymin = BoxPoints [index + 1];
        if (pRange->zmin > BoxPoints [index + 2])
	  pRange->zmin = BoxPoints [index + 2];
        if (pRange->xmax < BoxPoints [index])
	  pRange->xmax = BoxPoints [index];
        if (pRange->ymax < BoxPoints [index + 1])
	  pRange->ymax = BoxPoints [index + 1];
        if (pRange->zmax < BoxPoints [index + 2])
	  pRange->zmax = BoxPoints [index + 2];
      }
    }
  }
}

end implementation Root;
