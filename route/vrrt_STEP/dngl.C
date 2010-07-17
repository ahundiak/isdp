/* $Id:*/

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrrt/dngl.C
 *
 * Description:
 *      This is another copy of the vrrt/dngl.C file. This might've undergone
 *      some changes while compiling for MariSTEP. That's the reasin these
 *      files are placed in a different directory.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: dngl.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:08  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/11/06  19:22:52  pinnacle
 * initial revision
 *
 *
 * History:
 *       Date            Name     Description
 *      11/06/98        Alwin     Creation
 *
 *************************************************************************/

#include <math.h>
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igrdp.h"
#include "go.h"
#include "GMlist.h"
#include "GMdef.h"
#include "GMerrordef.h"
#include "ACrg_collect.h"
#include "ACattrib.h"
#include "vrdef.h"
#include "vrparameters.h"
#include "VRDbParamDef.h"
#include "vrmacros.h"
#include "VRsize.h"
#include "AS_status.h"
#include "msdef.h"
#include "VRattr_def.h"
#include "VRact_params.h"
#include "VRutildef.h"
#include "VRutilmacros.h"
#include "VRclsymb.h"
#include "msdef.h"
#include "msmacros.h"
#include "rtiges.h"
#include "bsdefs.h"
#include "bserr.h"
#include "bstypes.h"
#include "bsnorvec.h"

int RTorient_dangle( x1, y1, z1, x2, y2, z2, transform )
IGRdouble x1, y1, z1;
IGRdouble x2, y2, z2;
t_matrix  *transform;
{
  IGRdouble dx, dy, dz;
  IGRdouble xvector[3], yvector[3], zvector[3];
  BSrc      rc;
  IGRboolean status;

  dx = x1 - x2;
  dy = y1 - y2;
  dz = z1 - z2;

  xvector[0] = dx;
  xvector[1] = dy;
  xvector[2] = dz;

  status = BSnorvec( &rc,xvector );
  /*printf( "x - %lf  %lf  %lf\n", xvector[0], xvector[1], xvector[2] );*/

  yvector[0] = xvector[0] + 1;
  yvector[1] = xvector[1] + 1;
  yvector[2] = xvector[2];

  status = BSnorvec( &rc,yvector );
  /*printf( "y - %lf  %lf  %lf\n", yvector[0], yvector[1], yvector[2] );*/

  status = BScrossp( &rc, xvector, yvector, zvector );

  status = BSnorvec( &rc,zvector );
  /*printf( "z - %lf  %lf  %lf\n", zvector[0], zvector[1], zvector[2] );*/

  status = BScrossp( &rc, zvector, xvector, yvector );
  /*printf( "y - %lf  %lf  %lf\n", yvector[0], yvector[1], yvector[2] );*/

  transform->x[0] = xvector[0];
  transform->x[1] = xvector[1];
  transform->x[2] = xvector[2];

  transform->y[0] = yvector[0];
  transform->y[1] = yvector[1];
  transform->y[2] = yvector[2];

  transform->z[0] = zvector[0];
  transform->z[1] = zvector[1];
  transform->z[2] = zvector[2];

  return RTSUCC;
}

int RTorient_dangle2( x1, y1, z1, x2, y2, z2, transform )
IGRdouble x1, y1, z1;
IGRdouble x2, y2, z2;
t_matrix  *transform;
{
  IGRdouble dx, dy, dz;
  IGRdouble theeta;

  dx = x2 - x1;
  dy = y2 - y1;
  dz = z2 - z1;

  theeta = atan(dy/dx);
  printf( "theeta:%lf\n", theeta );

  transform->x[0] = cos(theeta);
  transform->x[1] = -sin(theeta);
  transform->x[2] = 0;

  transform->y[0] = sin(theeta);
  transform->y[1] = cos(theeta);
  transform->y[2] = 0;

  transform->z[0] = 0;
  transform->z[1] = 0;
  transform->z[2] = 1;

  return RTSUCC;
}

void vector()
{
  IGRdouble x1, y1, z1,
	    x2, y2, z2;
  t_matrix transform;
  IGRint status, ii;

  x1 = -28.216370;
  y1 = 13.580071;
  z1 = 0.0;

  x2 = -1.038434;
  y2 = 13.580071;
  z2 = 0.0;
  
  status = RTorient_dangle( x1, y1, z1, x2, y2, z2, &transform );

  for( ii=0; ii < 3; ++ii )
   printf( "x[%d]:%lf\n", ii, transform.x[ii] );

  for( ii=0; ii < 3; ++ii )
   printf( "y[%d]:%lf\n", ii, transform.y[ii] );

  for( ii=0; ii < 3; ++ii )
   printf( "z[%d]:%lf\n", ii, transform.z[ii] );
}
