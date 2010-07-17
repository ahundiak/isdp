/* $Id: */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrrt/struct.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: struct.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:07  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.1  1998/01/16  05:25:42  pinnacle
 * Created: vrrt/struct.h by r250_int for route
 *
 *
 *
 * History:
 *	01/15/98	Onay	Integration date.
 *
 *************************************************************************/

#ifndef _STRUCT_
#define _STRUCT_

#define structalloc(type,tag) \
	((type)diag_malloc(DIAG_FATAL,sizeof(struct self(tag)_struct)))
#define structalloc_0(type,tag) \
	((type)memset(structalloc(type,tag),0,sizeof(struct self(tag)_struct)))
#define structcpy(s1,s2,type,tag) \
	((type)membcpy(s1,s2,sizeof(struct self(tag)_struct)))
#define structcopy(s,type,tag) \
	structcpy(structalloc(type,tag),s,type,tag)
#define structvar(type,tag,var) \
	struct self(tag)_struct self(var)st; type var = &self(var)st;
#define newstructvar(zizi,tag) \
	zizi tag = structalloc(zizi,tag);

#define STRUCT_DEFINE_COPYFUNC(type,tag) \
type self(tag)_copy(tag) type tag;
#define STRUCT_DEFINE_CMPFUNC(type,tag) \
int self(tag)cmp(self(tag)1,self(tag)2) type self(tag)1, self(tag)2;
#define STRUCT_DEFINE_WRITEFUNC(type,tag) \
void self(tag)_write (tag,file) type tag; FILE* file;
#define STRUCT_DEFINE_READFUNC(type,tag) \
void self(tag)_read  (tag,file) type tag; FILE* file;
#define STRUCT_DEFINE_AREADFUNC(type,tag) \
void self(tag)_aread (self(tag)p,file) type* self(tag)p; FILE* file;

#endif
