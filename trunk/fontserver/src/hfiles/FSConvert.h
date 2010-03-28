/* 
 * File:   FSConvert.h
 * Author: impd
 *
 * Created on March 24, 2010, 11:42 AM
 */

#ifndef _FSCONVERT_H
#define	_FSCONVERT_H
#include "FSTypes.h"
#include "../hfiles/FSBmap.h"

extern  int     _FSPlaceRun (Int16 start, Int16 length, uInt8 *place);
extern  int     _FSFindRuns (uInt8 *start, int length, Int16 *place);
extern  int     _FSConvertRLE8 (uInt8 *source, BmapBitmap *dest, int width, int height);
extern  int     _FSUnconvertRLE8 (BmapBitmap *source, uInt8 *dest, int width, int height);
extern  int     _FSConvertRLE16 (Int16 *source, BmapBitmap *dest, int width, int height);
extern  int     _FSUnconvertRLE16 (BmapBitmap *source, Int16 *dest, int width, int height);

#endif	/* _FSCONVERT_H */

