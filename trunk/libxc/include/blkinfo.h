/* 
 * File:   blkinfo.h
 * Author: impd
 *
 * Created on March 19, 2010, 3:30 PM
 */

#ifndef _BLKINFO_H
#define	_BLKINFO_H

#ifdef	__cplusplus
extern "C" {
#endif

#ifdef __STDC__
extern int blkinfo(BLOCK *);
#else
extern int blkinfo();
#endif

#ifdef	__cplusplus
}
#endif

#endif	/* _BLKINFO_H */

