/* 
 * File:   FSReadFont.h
 * Author: impd
 *
 * Created on March 25, 2010, 10:28 AM
 */

#ifndef _FSREADFONT_H
#define	_FSREADFONT_H

#include "../hfiles/FSTypes.h"

extern  int     _FSReadFontFile (char *fileName, char **fontPtr, int *type);
extern  int     _FSReadBmapFile (FILE *file, char **fontPtr);
extern  int     _FSReadOutlFile (FILE *file, char **fontPtr);

#endif	/* _FSREADFONT_H */

