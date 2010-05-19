/* $Id: VDahFrm.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDahFrm.h
 *
 * Description: my forms toolkit
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDahFrm.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.6  1998/03/02  20:40:46  pinnacle
 * AssyTree
 *
 * Revision 1.4  1998/02/25  16:03:50  pinnacle
 * ah
 *
 * Revision 1.3  1998/02/20  23:51:44  pinnacle
 * AssyTree
 *
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/25/97  ah      Creation
 * 02/20/98  ah      Link in VI wrappers
 * 02/25/98  ah      PPL Friendly
 ***************************************************************************/

#ifndef   VDahFrm_include
#define   VDahFrm_include

#ifndef   VDfrmProto_include
#include "VDfrmProto.h"
#endif

#ifndef VD_PPL
#include "CIforms.h"
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif


#if defined(__cplusplus)
extern "C" {
#endif

extern IGRstat VDahFrmSetStatus __((Form form, IGRchar *text));

extern IGRstat VDahFrmGRidToString __((
  TGRid   *objID, 
  IGRchar *str
));

extern IGRstat VDahFrmStringToGRid __((
  IGRchar *str, 
  TGRid   *objID
));

extern IGRstat VDahFrmSetGRid __((
  Form   form, 
  IGRint gadget, 
  IGRint row, 
  IGRint col, 
  TGRid *objID
));

extern IGRstat VDahFrmGetGRid __((
  Form   form, 
  IGRint gadget, 
  IGRint row, 
  IGRint col, 
  TGRid *objID
));

extern IGRstat VDahFrmGetIDvla __((
  Form      form,
  IGRint    gadget,
  IGRint    col,
  TVDvlaID *objVLA
));

extern IGRstat VDahFrmSetTextRC __((
  Form     form, 
  IGRint   gadget, 
  IGRint   row,
  IGRint   col,
  IGRchar *text
));

extern IGRstat VDahFrmGetTextRC __((
  Form     form, 
  IGRint   gadget, 
  IGRint   row,
  IGRint   col,
  IGRchar *text
));

extern IGRstat VDahFrmSavePositionInFile   __((Form form));
extern IGRstat VDahFrmLoadPositionFromFile __((Form form));

#if defined(__cplusplus)
}
#endif

#endif






