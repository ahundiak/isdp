/*

Name
  SSHiCnstr.I

Description

Notes


 */
class implementation Root;

#include <math.h>

#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMindex.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igrdp.h"
#include "dpdef.h"
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


/*

Name
  SSHiliteConstraint

Abstract
 This functions hilites whatever constraint we can recognize for the
 element.  This implementation is basically a stub!

Synopsis
  int SSHiliteConstraint (p_type, matrix, p_module, p_object, point, tolerance)
  short       *p_type	  IN  The matrix type
  IGRmatrix   matrix	  IN  The matrix
  struct GRid *p_module   IN  The current module
  struct GRid *p_object	  IN  The constraint to be hilited
  IGRpoint    point	  IN  The data point
  double      tolerance   IN  The tolerance

Description
  Stub.

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

#argsused
int SSHiliteConstraint ( p_type, matrix, p_module, p_object, point, tolerance )
short       *p_type	     /* The matrix type				IN  */;
IGRmatrix    matrix	     /* The matrix					IN  */;
struct GRid *p_module    /* The current module				IN  */;
struct GRid *p_object	   /* The constraint to be hilited			IN  */;
IGRpoint     point	     /* The data point				IN  */;
IGRdouble    tolerance   /* The tolerance				IN  */;
{
  return OM_S_SUCCESS;
}

end implementation Root;
