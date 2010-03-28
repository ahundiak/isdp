/* 
 * File:   FSGetRec.h
 * Author: impd
 *
 * Created on March 24, 2010, 3:57 PM
 */

#ifndef _FSGETREC_H
#define	_FSGETREC_H

#include "../hfiles/FSTypes.h"

extern  int     _FSAccDigit(uInt16 digit);
extern  int     _FSInitAcc(void);
extern  void    _FSNextStep(uInt16 **record, uInt16 *dataOrigin, uInt16 n, Int16 wordCount);
extern  void    _FSGetRec(uInt16 n, uInt16 **record, uInt16 *dataOrigin, Int16 *type, Int32 *x, Int32 *y, Int32 *beta);

#endif	/* _FSGETREC_H */

