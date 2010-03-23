/* 
 * File:   blkdebug.h
 * Author: impd
 *
 * Created on March 19, 2010, 3:44 PM
 */

#ifndef _BLKDEBUG_H
#define	_BLKDEBUG_H

#ifdef	__cplusplus
extern "C" {
#endif

#ifdef __STDC__
extern void blkdebug_check(BLOCK *, char  *, char  *, int);
#else
extern void blkdebug_check();
#endif

#ifdef	__cplusplus
}
#endif

#endif	/* _BLKDEBUG_H */

