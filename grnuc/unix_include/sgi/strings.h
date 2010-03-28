#ifndef __STRINGS_H__
#define __STRINGS_H__
#ident "$Revision: 1.1.1.1 $"
/*
 * Copyright (C) 1989 Silicon Graphics, Inc. All rights reserved.
 */


#ifdef __cplusplus
extern "C" {
#endif

#include <string.h>

/*
 * 4.3BSD versions of strchr and strrchr.
 */

extern char *index();
extern char *rindex();

#ifdef __cplusplus
}
#endif


#endif /* !__STRINGS_H__ */
