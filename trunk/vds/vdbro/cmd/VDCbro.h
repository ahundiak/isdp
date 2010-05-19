/* $Id: VDCbro.h,v 1.1.1.1 2001/01/04 21:07:57 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdbro/cmd/VDCbro.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDCbro.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:57  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/10/29  17:21:32  pinnacle
 * ah creation
 *
 *
 * History:
 *      MM/DD/YY  AUTHOR  DESCRIPTION
 *      10/29/97  ah      added header
 ***************************************************************************/

#ifndef VDCbro_include
#define VDCbro_include

IGRstat VDCbroSetObjForm(VDbroObjInfo *objInfo, IGRboolean expandFlag);

IGRstat VDCbroListChnOne(
  TGRid        *id, 
  GRclassid     classId,
  IGRboolean    expandFlag, 
  IGRint        chnIndex,
  VDbroFrmInfo *frmInfo
);

IGRstat VDCbroListChn(
  TGRid        *id, 
  IGRboolean    expandFlag,
  VDbroFrmInfo *frmInfo
);

IGRstat VDbroGenClassIdList(GRclassid classId, GRclassid *classIdList);

/* --------------------------------
 * Form Stuff
 */
#define VDBRO_FRM_MAIN  250

#define VDBRO_FRM_L_OBJ    12

#define VDBRO_FRM_B_SAVE   13
#define VDBRO_FRM_B_OBJ    14
#define VDBRO_FRM_B_SPEC   19

#define VDBRO_FRM_F_SAVE      15
#define VDBRO_FRM_F_OSNUM     16
#define VDBRO_FRM_F_OBJID     17
#define VDBRO_FRM_F_CLASSNAME 18

#define VDBRO_FRM_B_ACCEPT  1
#define VDBRO_FRM_B_EXECUTE 2
#define VDBRO_FRM_B_CANCEL  4
#define VDBRO_FRM_F_STATUS 10
#define VDBRO_FRM_F_STAT    9

#endif

