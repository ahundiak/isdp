/* $Id: VDCbro.S,v 1.1.1.1 2001/01/04 21:07:57 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdbro/VDCbro.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDCbro.S,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:57  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/10/29  17:21:46  pinnacle
# ah creation
#
 *
 * History:
 *      MM/DD/YY  AUTHOR  DESCRIPTION
 *      10/29/97  ah      added header
 ***************************************************************************/

class specification VDCbro (1:0) of VDS_LOCATE;

#include "VDmaster.h"

#include "VDbro.h"
#include "VDCbro.h"

instance VDCbro
{
  VDbroFrmInfo frmInfo;
};

message VDCbroLocObj(int *msg);

override init;
override delete;
override form_notification;

end specification VDCbro;
