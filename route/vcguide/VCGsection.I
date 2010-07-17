
/* $Id: VCGsection.I,v 1.2 2001/02/20 01:10:53 build Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcguide/VCGsection.I
 *
 * Description:
 *
 *      Methods to access individual string sections
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCGsection.I,v $
 *      Revision 1.2  2001/02/20 01:10:53  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.1.1.1  2001/01/04 21:12:33  cvs
 *      Initial import to CVS
 *
# Revision 1.1  2000/03/15  21:55:42  pinnacle
# Created: vcguide/VCGsection.I by lawaddel for route
#
# Created: vcguide/VCGsection.I by law for guides
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *      03/14/00    law          Initial Dummy stubs for cr179901086
 *************************************************************************/

class implementation VCGuide;

/*
#define vdsDEBUG      1
#define MY_DEBUG   1
*/

#include "nddef.h"
#include "ndmacros.h"

#include "VCsys.h"

#include "VDmem.h"
#include "vrdbgmacros.h"
#include "vdreporterr.h"

#include "bsdptseg2.h"
#include "bsdistptpt.h"

from    GRlinear   import    GRgetpolyline;
from    GRlinear   import    GRputpolyline;

from    VCP        import    VCP_addpt;
from    VCP        import    VCP_reorg;

/**********************************************************************

   Abstract: This file contains the methods to find and modify the
             string sections of a composite link

***********************************************************************/

/*      modify linestring section          */

method    VCGdModify (IGRlong        *msg;
                      IGRint          ModType;   /*  sendtype INS/MOV/DEL   */
                      IGRint          AdjType;   /*  adjustment type        */
                      IGRint          SecNum;    /*  section number         */
                      IGRint          VtxNum;    /*  vertex/segment number  */
                      IGRdouble      *dCoord;    /*  coordinates            */
              struct  GRmd_env       *md_env;
                      IGRchar        *modattr)
{
  IGRint         status;
  status = OM_S_SUCCESS ;

wrapup:

  return( status );
}


/*       find vertex/segment and section given coordinates    */

method    VCGdFind   (IGRlong        *msg;
                      IGRint          ModType;   /*  sendtype INS/MOV/DEL   */
                      IGRint         *AdjType;   /*  adjustment type        */
                      IGRint         *SecNum;    /*  section number         */
                      IGRint         *VtxNum;    /*  vertex/segment number  */
                      IGRdouble      *dCoord;    /*  coordinates            */
                      IGRint          IXloc;     /*  normal coord           */
                      IGRdouble      *dDyn;      /*  coords for dynamics    */
                      IGRint         *EndPos;    /*  end position           */
              struct  GRmd_env       *md_env;
                      IGRchar        *fndattr)
{
  IGRint         status;

  return (OM_S_SUCCESS);
}

method    VCGdLdLine (IGRlong     *msg;
                    IGRshort     strno;
             struct IGRpolyline *LineIn;
             struct GRmd_env    *md_env;
                    IGRchar     *linattr)

{
  IGRint         status;

wrapup:

  *msg     = MSSUCC;
  return (OM_S_SUCCESS);
}


/*       find coordinates given vertex and section    */

method    VCGdVertex (IGRlong        *msg;
                      IGRint          SecNum;    /*  section number         */
                      IGRint          VtxNum;    /*  vertex/segment number  */
                      IGRdouble      *dCoord;    /*  coordinates            */
              struct  GRmd_env       *md_env;
                      IGRchar        *vrtxattr)
{
  IGRint         status;

wrapup:

  *msg     = MSSUCC;
  return (OM_S_SUCCESS);
}

end implementation VCGuide;
