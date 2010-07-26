/*

Name
  SSFindObject.I

Description

Notes


 */
class implementation Root;

#include <math.h>
#include <stdio.h>

#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMindex.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igrdp.h"
#include "igr.h"
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

/* prototypes */
#include "wl.h"
#include "maidmx.h"


from GRrtree      import pass;

static OMuword  ClassIds [SS_MAX_CLASS_IDS];

/*

Name
  SSFindObject

Abstract
 This routine hilites the relevant potential constraint that can
 be found using the current data point.

Synopsis
  int SSFindObject ( window, x, y, z, PConstraintType )
  OM_S_OBJID window            In   window we got the point from
  double     x, y, z           In   current data point (world coordinates)
  int        *PConstraintType  OUT  type of constraint we've recognized

Description

Return Value
  OM_S_SUCCESS always

Notes

Index

Keywords
  smart-sketch,dynamics

History
  ??/??/92 : Henri Bequet     : prototype written
  08/05/93 : Shelley R. Heard : header added; implementation for 2.4 GRNUC.

 */

%safe
static long status = OM_S_SUCCESS;
%endsafe

int SSFindObject ( window, x, y, z, PConstraintType )
OM_S_OBJID window;
double     x, y, z;
int        *PConstraintType;
{
  OM_S_KEY_DESC         key;
  DB_3D_DBL_BOX         rtrange;
  int                   RtreeStatus;
  double                Tolerance;

  static OM_S_MESSAGE   msg;
  static int            first = 1;
  static IGRpoint       FirstPoint; 
  static IGRpoint       SecondPoint;
  static OM_S_CLASSLIST ClassList;
  static struct GRid    tree;
  static struct IGRline boreline;
  static SSUserInfo     info;

  extern void DB_set_term_func();
  extern int  SSCursorHasMoved();

  static struct arglist
  {
    long *msg; 
    int  (*user_function)();
    char *UserInfo;
  } arglist;

  extern void SSGetClassList();

  if (first)
  {
    extern int SSAddObject ();

    first = 0;
    arglist.msg = &status;
    arglist.user_function = SSAddObject;
    arglist.UserInfo = (char *)&info;
    info.type = MAIDMX;
    MAidmx ( &status, info.matrix );

    om$make_message ( classname = "GRgraphics", 
                      methodname = "GRfunction",
                      p_arglist = &arglist, 
                      size = sizeof ( struct arglist ), 
                      p_msg = &msg );
    SSGetRtree ( &tree, &info.module );
    SSGetClassList( &ClassList );
    boreline.point1 = FirstPoint;
    boreline.point2 = SecondPoint;
  }
  
  /*
   * We traverse the R-tree for objects that are close to the data point. Note
   * that we have to get the window tolerance everytime (SSGetWindowTolerance
   * will remember the last window).
   */  
  key.type = KEY_3D_DBL;
  info.point [0] = x;
  info.point [1] = y;
  info.point [2] = z;
  SSGetWindowTolerance ( window, 
			 x, 
			 y,
			 z,
			&Tolerance,
			&rtrange, 
                         SSRefLock ? NULL : &boreline );
  info.PBoreLine = SSRefLock ? NULL : &boreline;
  key.key.p_3ddbl = &rtrange;
  info.tolerance = Tolerance;
  info.p_object = NULL;

  /*
   * Anytime we enter the SmartSketch we want the Rtree search to be 
   * canceled if the cursor is moving.  This is accomplished the setting
   * the "Rtree terminate function" to SSCursorHasMoved.  We reset it
   * to NULL when we are done.
   */
  DB_set_term_func(SSCursorHasMoved);

  om$send ( msg = message GRrtree.pass ( &msg, 
					 &key, 
					 &ClassList, 
                                          NULL, 
					  NULL, 
					 &RtreeStatus ), 
            senderid = NULL_OBJID, 
            targetid = tree.objid,
            targetos = tree.osnum );

  DB_set_term_func( NULL );

  *PConstraintType = info.p_object ? SSONELEMENT : SSNONE;

  return OM_S_SUCCESS;  
}

/*

Name
  SSGetClassList

Abstract

Synopsis
  void SSGetClassList( pClassList )
    OM_S_CLASSLIST *pClassList   OUT   pointer to list of eligible classes, 
				       which is stored in static memory.

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

void SSGetClassList( pClassList )
   OM_S_CLASSLIST *pClassList;
{
  OMuword loc_classid;
  int     next_classid;
  extern OMuword OPP_GR3dlineseg_class_id; 
  extern OMuword OPP_GR3dpoint_class_id; 
  extern OMuword OPP_GR3dcirarc_class_id; 
  extern OMuword OPP_GR3dcircle_class_id;

  pClassList->w_flags = OM_CLST_subclass;
  pClassList->p_classes = ClassIds;

  /* 
   * Locate classes known to GRNUC
   */
  ClassIds [0] = OPP_GR3dlineseg_class_id; 
  ClassIds [1] = OPP_GR3dpoint_class_id; 
  ClassIds [2] = OPP_GR3dcirarc_class_id; 
  ClassIds [3] = OPP_GR3dcircle_class_id;
  pClassList->w_count = 4;

  next_classid = pClassList->w_count;
  if ( om$get_classid( p_classid = &loc_classid, 
                       classname = "GRbcsubbc" ) == OM_S_SUCCESS )
  {
    ClassIds[next_classid] = loc_classid;
    pClassList->w_count++;
    next_classid ++;
  }
  /*
   *  In case this is a MODEL based application, locate surface/solids, too.
   */
  if ( om$get_classid( p_classid = &loc_classid, 
                       classname = "EMSsubbs" ) == OM_S_SUCCESS )
  {
    ClassIds[next_classid] = loc_classid;
    pClassList->w_count++;
  }
  /*  
   * Note: the most pClassList->w_count can be is SS_MAX_CLASS_IDS (see SS.h)
   * If more cases are added, be sure to increment SS_MAX_CLASS_IDS and the
   * next_classid variable accordingy.
   */
}

end implementation Root;
