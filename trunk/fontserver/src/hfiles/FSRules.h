/* 
 * File:   FSRules.h
 * Author: impd
 *
 * Created on March 25, 2010, 10:55 AM
 */

#ifndef _FSRULES_H
#define	_FSRULES_H

#include "../hfiles/FSDef.h"

extern  void    _FSSetupXXYTrans(void);
extern  void    _FSSetupYXYTrans(void);
extern  void    _FSSetupXXTrans(Int16 direction);
extern  void    _FSSetupYYTrans(Int16 direction);
extern  void    _FSSetupXYTrans(Int16 direction);
extern  void    _FSSetupYXTrans(Int16 direction);
extern  void    _FSMakeEdgeList(uInt16 charNum, Int16 dimension, Real scale, Int16 *pn);
extern  void    _FSMakeXTransList(Int16 n, Int16 direction, Real a[], Int16 b[]);
extern  void    _FSMakeTransTable (Real pixelsPerEm, Real scale, Real pos, Int16 direction, Real orusTbl[],
                                   Int16 pixelsTbl[], Int16 n, Real multTbl[], Real offsetTbl[], Int16 *pnoTransforms);
extern  void    _FSMakePathMask (uInt16 charNum, Int16 dimension, Int16 zoneNo, Boolean mask[]);
extern  void    _FSMakeYTransList(Int16 n, Int16 direction, Real a[], Int16 b[]);

#endif	/* _FSRULES_H */

