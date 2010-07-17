/* $Id: VSfeProcAttr.I,v 1.1.1.1 2001/01/04 21:10:36 cvs Exp $  */
 
/***************************************************************************
 * I/STRUCT
 *
 * File:        struct/vsfeature/VSfeProcAttr.I
 *
 * Description: override of VDSroot.VDprocAttr
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSfeProcAttr.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:36  cvs
 *      Initial import to CVS
 *
# Revision 1.2  1998/10/11  13:47:34  pinnacle
# Staging Tree range and cog
#
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1997/12/19  18:16:20  pinnacle
# AssyTree
#
# Revision 1.1  1997/12/15  22:25:26  pinnacle
# VDprocAttr
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/14/97  ah      Creation
 * 10/02/98  ah      Added cog and range for staging tree
 *                   Still not quite the same as the VDSroot version
 ***************************************************************************/

class implementation VSfeature ;

#include "VDmaster.h"
#include "vsdbgmacros.h"

method VDprocAttr(
  long      *msg; 
  TGRmd_env *md_env; 
  int        flag;  
  VDprcAttr *prcAttr
)
{
  VSintegral info;
  IGRint sts;

  IGRboolean world = 1;

  // Clear it
  memset(&info,  0,sizeof(info));
  memset(prcAttr,0,sizeof(VDprcAttr));
  prcAttr->density = 1.0;

  sts = om$send(
    msg = message VSpart.VSgetMassProperties(msg,md_env,&info),
    targetid = my_id
  );
  if (!(sts & 1)) goto wrapup;

  prcAttr->mass   = info.mass;
  prcAttr->area   = info.area;
  prcAttr->volume = info.volume;

  prcAttr->cog[0] = info.centroid[0];
  prcAttr->cog[1] = info.centroid[1];
  prcAttr->cog[2] = info.centroid[2];

  // Also want range
  om$send( msg = message 
	   GRgraphics.GRgetrang(msg,
				&md_env->md_env.matrix_type,
				md_env->md_env.matrix,
				&world,
				 prcAttr->range),
	   targetid = my_id);
    
wrapup:
  return sts;
}

end implementation VSfeature ;


