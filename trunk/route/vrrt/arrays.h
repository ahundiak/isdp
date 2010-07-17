/* $Id: */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrrt/arrays.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: arrays.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:06  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.1  1998/01/16  05:22:22  pinnacle
 * Created: vrrt/arrays.h by r250_int for route
 *
 *
 *
 * History:
 *	01/15/98	Onay	Integration date.
 *
 *************************************************************************/

#ifndef _ARRAYS_
#define _ARRAYS_

#define aalloc(type,n) ((type* )diag_calloc(DIAG_FATAL,n,sizeof(type)))

#define DEFINE_AFUNCS(type) \
type* self(type)a_init(a,n,value) type* a; int n; type value; { int i; \
	For (i,n) a[i] = value; return a; } \
type* self(type)a_alloc(n,value) int n; type value; { \
	return self(type)a_init(aalloc(type,n),n,value); } \
type* self(type)a_new(n) int n; { return self(type)a_alloc(n,(type)0); } \
void self(type)a_free(a) type* a; { diag0_free(a); } \
void self(type)a_freef(a,n,freefunc) type* a; int n; funcp freefunc; { int i; \
	if (freefunc) For (i,n) (freefunc)(a[i]); self(type)a_free(a); } \
type* self(type)a_copy(a,n) type* a; int n; { \
	return (type* )memcopy(a,n*sizeof(type)); }

#define DECLARE_AFUNCS(type) \
extern type* self(type)a_init(); \
extern type* self(type)a_alloc(); \
extern type* self(type)a_new(); \
extern void self(type)a_free(); \
extern void self(type)a_freef(); \
extern type* self(type)a_copy();

#define DEFINE_AIOFUNCS(type) \
void self(type)a_write (a ,n,file) type*  a ; int n; FILE* file; { int i; \
	For (i,n) self(type)_write(a[i],file); } \
void self(type)a_read  (a ,n,file) type*  a ; int n; FILE* file; { int i; \
	For (i,n) self(type)_read(&a[i],file); } \
void self(type)a_aread (ap,n,file) type** ap; int n; FILE* file; { \
	self(type)a_read(*ap = aalloc(type,n),n,file); }

#define DECLARE_AIOFUNCS(type) \
extern void self(type)a_write(); \
extern void self(type)a_read(); \
extern void self(type)a_aread();

#define DEFINE_ANUMFUNCS(type) \
type self(type)a_max(a,n) type* a; int n; { int i; type m = 0; \
	For (i,n) MAX_(m,a[i]); return m; } \
type self(type)a_min(a,n) type* a; int n; { int i; type m = 0; int first = T; \
	For (i,n) if (first && a[i] != 0) m = a[i], first = F; \
	          else MIN_(m,a[i]); \
	return m; } \
type self(type)a_sum(a,n) type* a; int n; { int i; type sum = 0; \
	For (i,n) sum += a[i]; return sum; }

#define DECLARE_ANUMFUNCS(type) \
extern type self(type)a_max(); \
extern type self(type)a_min(); \
extern type self(type)a_sum();

#endif
