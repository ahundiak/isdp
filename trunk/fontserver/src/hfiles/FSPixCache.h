/* 
 * File:   FSPixCache.h
 * Author: impd
 *
 * Created on March 24, 2010, 6:02 PM
 */

#ifndef _FSPIXCACHE_H
#define	_FSPIXCACHE_H

#include "../hfiles/FSTypes.h"

extern  void    _FSDeleteCache (void);
extern  void    _FSInitCache (Real pixemX, Real pixemY);
extern  void    _FSNewCache (int numChars);
extern  void    _FSOpenPutCacheData (void);
extern  void    _FSClearXCache (void);
extern  void    _FSClearYCache (void);
extern  void    _FSClearScaledXCache (void);
extern  void    _FSClearScaledYCache (void);
extern  void    _FSClosePutCacheData(void);
extern  void    _FSGetCacheNoZones(uInt16 charNum, Int16 dimension, Int16 *pnoZones);
extern  void    _FSGetCacheData(uInt16 charNum, Int16 dimension, Int16 zoneNum, Int32 *pfrom, Int32 *pto, uInt16 *pflags, uInt16 **ppfunct);
extern  void    _FSCacheFPixels(uInt16 charNum, Int16 dimension, Int16 zoneNum, Real fpixels, Real scale);
extern  void    _FSCachePixels(uInt16 charNum, Int16 dimension, Int16 zoneNum, Int16 pixels, Real scale);
extern  void    _FSPutCacheData(uInt16 charNum, Int16 dimension, Int32 from, Int32 to, uInt16 flags, uInt16 *pfunct);

#endif	/* _FSPIXCACHE_H */

