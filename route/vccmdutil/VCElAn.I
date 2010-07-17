
/* $Id: VCElAn.I,v 1.1.1.1 2001/01/04 21:12:31 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vccmdutil/VCElAn.I
 *
 * Description:
 *      Electrical analysis functions
 *
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCElAn.I,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:31  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:17:36  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.2  1997/03/12  22:27:28  pinnacle
# Replaced: vccmdutil/VCElAn.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  22:03:46  pinnacle
# Created: vccmdutil/VCElAn.I by hverstee for cabling
#
 *
 * History:
 *        07/10/96        hv        Initial
 *
 *************************************************************************/

class implementation VCCmdAnal;

#include "VCproto.h"

/*
#define  MY_DEBUG
*/


/*****************************************************************************/

/*       Electrical analysis functions                */

/*****************************************************************************/

/*       dummy (unimplemented)     */

IGRint   VC_ElAnalyze   (IGRlong         *msg,
                         IGRshort         nTrac,
                  struct VC_contrace     *TracTab,
                         FILE            *OutFil,
                         IGRint           IFunc,
                  struct GRid            *Refid,
                  struct GRmd_env        *md_env)
{

  if (OutFil)
  {
    fprintf (OutFil," Unimplemented function  %d\n", IFunc);

    fprintf (OutFil,
        "-----------------------------------------------------------------\n");
  }

  return (0);
}

end implementation VCCmdAnal;
