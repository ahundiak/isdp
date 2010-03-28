/*

Name
  SSDispCnstr.I

Description

Notes


 */
class implementation Root;

#include <math.h>
#include <memory.h>

#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMindex.h"
#include "igrtypedef.h"
#include "igrdef.h"
#include "igetypedef.h"
#include "igrdp.h"
#include "dpdef.h"
#include "dpstruct.h"
#include "dp.h"
#include "dpmacros.h"
#include "dpezmac.h"
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
#include "bserr.h"
#include "EMSdatumdef.h"
#include "EMdtmacros.h"
#include "bsdistptpt.h"


#define ss_debug_disp_constr(DisplayMode, PButton, XCoordinate, YCoordinate) \
{                                                                            \
  printf ( "SSDisplayConstraint ( DisplayMode = %d,\n",    DisplayMode );    \
  printf ( "                      PButton     = 0x%x,\n",  PButton     );    \
  printf ( "                      XCoordinate = %d,\n",    XCoordinate );    \
  printf ( "                      YCoordinate = %d );\n", YCoordinate );    \
}


/*

Name
  SSDisplayConstraint

Abstract
 This function displays (erases) the last constraint. It is called when a 
 constraint is recognized.

Synopsis
  int SSDisplayConstraint ( DisplayMode, PButton, XCoordinate, YCoordinate )
  enum GRdpmode DisplayMode     IN  The mode to use for display
  struct EX_button *PButton     IN  The window, button, ...
  int              XCoordinate, IN  X screen coordinate
                   YCoordinate  IN  Y screen coordinate 

Description

Return Value
  OM_S_SUCCESS  always

Notes

Index

Keywords
  smart-sketch,dynamics

History
  ??/??/92 : Henri Bequet     : prototype written
  08/05/93 : Shelley R. Heard : header added; implementation for 2.4 GRNUC.

 */
int SSDisplayConstraint ( DisplayMode, PButton, XCoordinate, YCoordinate )
  enum GRdpmode DisplayMode;
  struct EX_button *PButton;
  int              XCoordinate, 
                   YCoordinate;
{
  double     Points [15];
  long       LocalStatus;
  int        BufferIndex;
  IGRlong    bufsize = sizeof( IGRboolean );
  IGRlong    nret;
  IGRboolean dynamics_all_windows;
  
  /* 
   * We must honor the dynamics_all_windows flag! 
   */
  gr$get_dynamics_all_windows( msg = &LocalStatus,
                               sizbuf = &bufsize,
                               buffer = &dynamics_all_windows,
                               nret = &nret );

  if (SSLastObject1)
  {
    for (BufferIndex = 0; BufferIndex < SSLastObject1->NbBuffers; BufferIndex++)
    {
      if ( !dynamics_all_windows )
      {
         dp$display ( msg = &LocalStatus, 
                      osnum = PButton->osnum,
                      objid = PButton->objid,
                      mode = DisplayMode, 
                      buffer = &SSLastObject1->buffers [BufferIndex] );
      }
      else
      {
         dp$display ( msg = &LocalStatus, 
                      mode = DisplayMode, 
                      buffer = &SSLastObject1->buffers [BufferIndex] );
      }
    }
  }
  if (SSLastObject2)
  {
    for (BufferIndex = 0; BufferIndex < SSLastObject2->NbBuffers; BufferIndex++)
    {
      if ( !dynamics_all_windows )
      {
        dp$display ( msg = &LocalStatus, 
                     osnum = PButton->osnum,
                     objid = PButton->objid,
                     mode = DisplayMode, 
                     buffer = &SSLastObject2->buffers [BufferIndex] );
      }
      else
      {
        dp$display ( msg = &LocalStatus, 
                     mode = DisplayMode, 
                     buffer = &SSLastObject2->buffers [BufferIndex] );
      }
    }
  }
  
  /*
   * Where do we display the constraint?
   * Note that horizontal/vertical constraints need two points.
   */
  memcpy ( Points, SSLastConstraintPoint, sizeof ( IGRpoint ) );
  if (   SSLastConstraintType == SSHORIZONTAL 
      || SSLastConstraintType == SSVERTICAL
      || SSLastConstraintType == SSVHORIZONTAL 
      || SSLastConstraintType == SSHVERTICAL )
  {
    memcpy ( &Points [3], SSLastKeypoint, sizeof ( IGRpoint ) );
  }
  else
  {
    if (SSLastConstraintType == SSPARALLEL || 
        SSLastConstraintType == SSPERPENDICULAR)
    {
      /*
       * We pass the coordinates of the extremities of the segments
       */
      memcpy ( &Points [0], SSLastObject1->KeyPoints [0], sizeof ( IGRpoint ) );
      memcpy ( &Points [3], SSLastObject1->KeyPoints [2], sizeof ( IGRpoint ) );
      memcpy ( &Points [6], SSNewPoints [0],              sizeof ( IGRpoint ) );
      memcpy ( &Points [9], SSNewPoints [1],              sizeof ( IGRpoint ) );
    }
    else if ( SSLastConstraintType == SSTANGENT || 
              SSLastConstraintType == SSXTANGENT )
    {
      memcpy ( Points, SSLastKeypoint, sizeof ( IGRpoint ) );
    }
    else if (SSLastConstraintType == SSONXELEMENT)
    {
      memcpy ( &Points[3],SSLastObject1->KeyPoints[0],sizeof( IGRpoint ) );
      memcpy ( &Points[6],SSLastObject1->KeyPoints[2],sizeof( IGRpoint ) );
    }
    else if (SSLastConstraintType == SSXINTERSECT)
    {
      double dist1, dist2;
      BSrc   Rc;

      /*
       * The two segments will go from the intersection point to the 
       * closest end point of line segments.  If element type is not
       * SSLINE, no additional buffers are used.
       */            
      memcpy ( &Points [3], SSLastConstraintPoint, sizeof (IGRpoint) );
      if ( SSLastObject1->type == SSLINE )
      {
        dist1 = BSdistptpt ( &Rc, 
                              SSLastConstraintPoint, 
                              SSLastObject1->KeyPoints [0]);
        dist2 = BSdistptpt ( &Rc, 
                              SSLastConstraintPoint, 
                              SSLastObject1->KeyPoints [2]);
        if (dist1 < dist2)
        {
          memcpy ( &Points [6], 
                    SSLastObject1->KeyPoints [0], 
                    sizeof ( IGRpoint ) );
        }
        else
        {
          memcpy ( &Points [6], 
                    SSLastObject1->KeyPoints [2], 
                    sizeof ( IGRpoint ) );
        }
      }
      else
      {
        memcpy ( &Points[6], SSLastConstraintPoint, sizeof (IGRpoint) );
      }

      memcpy ( &Points [9], SSLastConstraintPoint, sizeof (IGRpoint) );
      if ( SSLastObject2->type == SSLINE )
      {
        dist1 = BSdistptpt ( &Rc, 
                              SSLastConstraintPoint,
                              SSLastObject2->KeyPoints [0]);

        dist2 = BSdistptpt ( &Rc,
                              SSLastConstraintPoint,
                              SSLastObject2->KeyPoints [2]);
        if (dist1 < dist2)
        {
          memcpy ( &Points [12], 
                    SSLastObject2->KeyPoints [0], 
                    sizeof ( IGRpoint ) );
        }
        else
        {
          memcpy ( &Points [12], 
                    SSLastObject2->KeyPoints [2], 
                    sizeof ( IGRpoint ) );
        }
      }
      else
      {
        memcpy ( &Points [12], SSLastConstraintPoint, sizeof (IGRpoint) );
      }
    }
  }

  if ( SSLastConstraintType == SSHVERTICAL || 
       SSLastConstraintType == SSVHORIZONTAL )
  {
    int FirstType, SecondType;
    
    if (SSLastConstraintType == SSHVERTICAL)
    {
      FirstType = SSVERTICAL;
      SecondType = SSHORIZONTAL;
    }
    else
    {
      FirstType = SSHORIZONTAL;
      SecondType = SSVERTICAL;
    }
    
    SSDispIcon ( &LocalStatus, 
                  Points, 
                  FirstType, 
                  DisplayMode,
                  PButton, 
                  XCoordinate, 
                  FirstType == SSVERTICAL ? YCoordinate : YCoordinate + 15 );

    memcpy ( &Points [0], &SSLastConstraintPoint [3], sizeof ( IGRpoint ) );
    memcpy ( &Points [3], &SSLastKeypoint [3],        sizeof ( IGRpoint ) );

    SSDispIcon ( &LocalStatus, 
                  Points, 
                  SecondType, 
                  DisplayMode,
                  PButton, 
                  XCoordinate,
                  FirstType == SSHORIZONTAL ? YCoordinate : YCoordinate + 15 );
  }
  else
  {
    if ( SSLastConstraintType == SSONVERTICAL   || 
         SSLastConstraintType == SSONHORIZONTAL ||
         SSLastConstraintType == SSONXVERTICAL  || 
         SSLastConstraintType == SSONXHORIZONTAL  )
    {
      int ConstraintType;
      
      ConstraintType = (SSLastConstraintType == SSONVERTICAL || 
        SSLastConstraintType == SSONHORIZONTAL) ? SSONELEMENT : SSONXELEMENT;
      if (ConstraintType == SSONXELEMENT)
      {
        memcpy ( &Points [3], SSLastObject1->KeyPoints [0], sizeof (IGRpoint) );
        memcpy ( &Points [6], SSLastObject1->KeyPoints [2], sizeof (IGRpoint) );
      }
      SSDispIcon ( &LocalStatus, 
                    Points, 
                    ConstraintType,
                    DisplayMode,
                    PButton, 
                    XCoordinate, 
                    YCoordinate );

      memcpy ( &Points [3], SSLastKeypoint, sizeof ( IGRpoint ) );
      SSDispIcon ( &LocalStatus, Points, 
                  (SSLastConstraintType == SSONVERTICAL || SSLastConstraintType == SSONXVERTICAL ) ? SSVERTICAL : SSHORIZONTAL, 
                   DisplayMode, 
                   PButton, 
                   XCoordinate, 
                   YCoordinate + 15 );
    }
    else
    {
      SSDispIcon ( &LocalStatus, 
                    Points, 
                    SSLastConstraintType,
                    DisplayMode,
                    PButton,
                    XCoordinate,
                    YCoordinate );
    }
  }
  return OM_S_SUCCESS;
}

end implementation Root;
