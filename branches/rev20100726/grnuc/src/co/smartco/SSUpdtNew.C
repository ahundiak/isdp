/*

Name
  SSUpdtNew.C

Description
  Code for updating the new element info on the fly (after setting it)

Notes

 */
#include <math.h>
#include "bsvalues.h"
#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "OMindex.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igrdp.h"
#include "gr.h"
#include "go.h"
#include "ex.h"
#include "exdef.h"
#include "msdef.h"
#include "madef.h"
#include "SSdef.h"
#include "SS.h"


/*

Name
  SSUpdateNewElement

Abstract
  This routine is used to modify the "new element" info used by the Smart 
  Sketch when a element is being constructed.  This all presumes that the
  "New Element" info has been set ( see SSSetNewElement ).  If an arg is
  passed as NULL, the coresponding New Element Parameter is not modified.

Synopsis
  int SSUpdateNewElement ( Point1, Point2, Point3, pNewFlag )
  IGRdouble *Point1        IN  Overrides first  new point (NULL if not modified)
  IGRdouble *Point1        IN  Overrides second new point (NULL if not modified)
  IGRdouble *Point1        IN  Overrides third  new point (NULL if not modified)
  int       *pNewFlag      IN  Overrides newflag

Description

Return Value
  OM_S_SUCCESS  success  always

Notes

Index

Keywords
  smart-sketch,dynamics

History
  09/25/93 : Shelley R. Heard : created.

 */
int SSUpdateNewElement ( Point1, Point2, Point3, pNewFlag )
  IGRdouble *Point1;
  IGRdouble *Point2;
  IGRdouble *Point3;
  int       *pNewFlag;
{

  if ( pNewFlag )
  {
    SSNewFlag = *pNewFlag;
  }

  if ( Point1 )
  {
    memcpy ( SSNewPoints [0], Point1, sizeof ( IGRpoint ) );
  }

  if ( Point2 )
  {
    memcpy ( SSNewPoints [1], Point2, sizeof ( IGRpoint ) );
  }

  if ( Point3 )
  {
    memcpy ( SSNewPoints [2], Point3, sizeof ( IGRpoint ) );
  }

  return OM_S_SUCCESS;
}

