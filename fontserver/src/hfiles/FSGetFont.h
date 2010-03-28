/* 
 * File:   FSGetFont.h
 * Author: impd
 *
 * Created on March 24, 2010, 3:06 PM
 */

#ifndef _FSGETFONT_H
#define	_FSGETFONT_H

#include "FSTypes.h"
#include "FSFont.h"
#include "FSFontCach.h"

extern  int     _FSGetFontLigTable (FontNode **font, FontLigature **ligTable, int *numLigs);
extern  int     _FSGetFontKernTable (FontNode **font, FontKernPair **kernTable, int *numKerns);
extern  int     _FSGetFontInfo (FontNode **font, FontInfo *info);

#endif	/* _FSGETFONT_H */

