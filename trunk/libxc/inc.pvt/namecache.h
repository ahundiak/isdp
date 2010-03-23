/* 
 * File:   namecache.h
 * Author: impd
 *
 * Created on March 22, 2010, 5:55 PM
 */

#ifndef _NAMECACHE_H
#define	_NAMECACHE_H
#include "hash.h"

#ifdef	__cplusplus
extern "C" {
#endif

typedef struct ncache NAMECACHE;
struct ncache {
    int        next;
    int        alloc;
    char      *cache;
    HASHTABLE *dups;
};

#ifdef	__cplusplus
}
#endif

#endif	/* _NAMECACHE_H */

