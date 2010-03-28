/* 
 * File:   FSNewFont.h
 * Author: impd
 *
 * Created on March 24, 2010, 2:21 PM
 */

#ifndef _FSNEWFONT_H
#define	_FSNEWFONT_H

#include "../hfiles/FSTypes.h"
#include "../hfiles/FSFontCach.h"
#include "../hfiles/FSMakeFont.h"

extern  int     _FSEnterNF (uInt32 flags);
extern  int     _FSExitNF (void);
extern  int     _FSUpdateCharTime (FontNode **fontNode, FontCharNode **charNode);
extern  int     _FSAppendChar (FontNode **fontNode, CharId character);
extern  int     _FSSharedFont (FontNode **fontNode);
extern  void    _FSShExit (void);
extern  void    _FSAddUnsharedFont (FontNode **fontNode);
extern  void    _FSLinkSharedFont (FontNode **fontNode);
extern  int     _FSFontMatch (FontNode **fontNode, FontSpec *fontSpec, SubsetList *subset, FileRef *tfRef, FileRef *cmRef, int *genChars);
extern  int     _FSInitGlobals (FileRef *tfRef, char *tfName, Real64 bodySize,
                Real64 resFactor, Real64 aspect, Real64 rotation, Real64 slant,
                FileRef *cmRef, char *cmName, Int32 flags);
extern  int     _FSMakeSubset (RangeSpec *rangeSpec, SubsetList *subset);
extern  int     FSDeleteFont (FontNode **fontNode);
extern  int     _FSShEnter (void);

#endif	/* _FSNEWFONT_H */

