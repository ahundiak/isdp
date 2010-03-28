/* 
 * File:   FSKern.h
 * Author: impd
 *
 * Created on March 24, 2010, 5:57 PM
 */

#ifndef _FSKERN_H
#define	_FSKERN_H

#include "../hfiles/FSTypes.h"
#include "../hfiles/FSFontCach.h"
#include "../hfiles/FSTFCache.h"
#include "../hfiles/FSCharMap.h"

extern  Int     _FSDoKernTracks (FontNode *font, TFStruct *cmfont);
extern  Int     _FSDoKernPairs (FontNode *font, TFStruct *cmfont);
extern  Int     _FSReadCharMapBsNbrs (CharMapStruct *cPtr, Int8 *charList1, Char16 **charList2);
extern  Int     _FSTrackPix (TFStruct *cmfont, Real *track1, Real *track2, Real *track3, Real *track4);

#endif	/* _FSKERN_H */
