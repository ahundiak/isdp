/* $Id: VDbro.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdinclude/VDbro.h
 *
 * Description: Browser Prototypes
 * The forms stuff really should not be in here but I wanted
 * To give access to info and I deed to break out the form
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDbro.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:51  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/10/29  17:15:04  pinnacle
 * ah Creation
 *
 *
 * History:
 *      MM/DD/YY  AUTHOR  DESCRIPTION
 *      10/29/97  ah      added header
 ***************************************************************************/

#ifndef VDbro_include
#define VDbro_include

typedef struct {
  Form    form;
  IGRint  row;
  IGRint  indent;
} VDbroFrmInfo;

typedef struct {

  struct GRid id;
  IGRboolean  sts;

  GRclassid classId;
  IGRchar   className[32];

  IGRchar   objName[1024];
  IGRchar   macName[  32];
  IGRchar   downScan [32];
  IGRchar   expStr [1024];

  VDbroFrmInfo *frmInfo;

} VDbroObjInfo;

IGRstat VDbroGetObjDesc(VDbroObjInfo *objInfo, IGRchar *desc);

IGRstat VDbroGetObjInfo(struct GRid *id, VDbroObjInfo *objInfo);
IGRstat VDbroGetObjStr (struct GRid *id, IGRchar *str);
IGRstat VDbroPrintObj  (struct GRid *id);

#endif

