/* 
 * File:   FSGetTF.h
 * Author: impd
 *
 * Created on March 24, 2010, 4:05 PM
 */

#ifndef _FSGETTF_H
#define	_FSGETTF_H

#include "../hfiles/FSTypes.h"

typedef struct _FSName
{
    char		*name;
    struct _FSName	*next;
} FSName;

extern  FILE    *_FSOpenTFFile (char *typeface);
extern  void    _FSDeallocName (FSName *tfNamePtr);

#endif	/* _FSGETTF_H */

