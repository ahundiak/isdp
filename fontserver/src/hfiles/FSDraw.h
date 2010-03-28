/* 
 * File:   FSDraw.h
 * Author: impd
 *
 * Created on March 25, 2010, 3:01 PM
 */

#ifndef _FSDRAW_H
#define	_FSDRAW_H

#include "../hfiles/FSDef.h"
#include "../hfiles/FSBmap.h"
#include "../hfiles/FSOutl.h"

extern  int     _FSDrawBmapChar (int window, BmapCharInfo *charInfo, BmapBitmap *bitmap, Real64 bx, Real64 by, void (*drawFunc)());
extern  int     _FSDrawOutlChar (int window, OutlCharInfo *charInfo, OutlPolySize *pSize, OutlVertex *vert, Real64 x, Real64 y, void (*drawFunc)());

#endif	/* _FSDRAW_H */

