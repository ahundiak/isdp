/* $Id$  */

/***************************************************************************
 * I/AIM (ISDP)
 *
 * File:        include/vadbgmacros.h
 *
 * Description: Debug/trace macros
 *
 * Revision History:
 *      $Log: vadbgmacros.h,v $
 *      Revision 1.2  2002/02/08 20:06:12  tlstalli
 *      TLS - AMDC Enhancement and Fix for TR 5996
 *
 *      Revision 1.1.1.1  2001/06/01 20:06:26  tlstalli
 *      Creating aim module
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 ***************************************************************************/
#ifndef vedebug_include
#define vedebug_include

/*
#define	vaimDEBUG	1
#define	vaimerrDEBUG	1
 */

#ifdef vaimDEBUG

#define __SetProc(p) char __PROC__[40] ; strcpy(__PROC__, #p);
#define __Enter(p)   char __PROC__[40] ; strcpy(__PROC__, #p); printf(">>> Enter %s\n", #p);       fflush(stdout); 
#define __Exit()                                               printf("<<< Exit  %s\n", __PROC__); fflush(stdout);

#define SetProc( p ) char __PROC__[40] ; strcpy( __PROC__, #p )
#define Begin	printf( ">> %s: BEGIN\n", __PROC__ ) ; fflush( stdout );
#define End	printf( "<< %s: END\n"  , __PROC__ ) ; fflush( stdout );

#ifndef vaimerrDEBUG
#define vaimerrDEBUG
#endif

#else
#       define __Enter(p)
#       define __Exit()
#       define __SetProc(p)

#	define SetProc( p )
#	define Begin
#	define End
#endif 

#ifdef vaimerrDEBUG
#	define CheckRC( OMrc, GRrc ) \
		if( !( (OMrc) & 1 ) ) {\
			printf( "FILE %s LINE %d: \n", __FILE__, __LINE__ ) ;\
			om$report_error( sts = (OMrc) ) ;\
		} else if( !( (GRrc) & 1 ) ) {\
			printf( "FILE %s LINE %d: message failed\n",\
				__FILE__, __LINE__ ) ;\
		}
#else
#	define CheckRC( OMrc, GRrc )
#endif

#ifdef vaimerrDEBUG
#	define __CheckRC( OMrc, GRrc, _message_, label ) \
	if( !( (OMrc) & 1 ) ) {\
		printf( "FILE %s, LINE %d, %s: \n",\
			__FILE__, __LINE__, (_message_) ) ;\
		om$report_error( sts = (OMrc) ) ;\
		goto label ;\
	} else if( !( (GRrc) & 1 ) ) {\
		printf( "FILE %s LINE %d: %s failed\n",\
			__FILE__, __LINE__, (_message_) ) ;\
		goto label ;\
	}
#else
#	define  __CheckRC( OMrc, GRrc, _message_, label )\
	if( !( (OMrc) & 1 & (GRrc) ) ) goto label
#endif

#ifdef vaimerrDEBUG
#	define __CheckSTS( STS, _message_, label ) \
	if( !( (STS) & 1 ) ) {\
		printf( "FILE %s, LINE %d, %s: \n",\
			__FILE__, __LINE__, (_message_) ) ;\
		goto label ;\
	}
#else
#	define  __CheckSTS( STS, _message_, label )\
	if( !( (STS) & 1 ) ) goto label
#endif

#ifdef vaimerrDEBUG
#	define __CheckBSRC( Bsrc,  _message_, label ) \
	if(  ((Bsrc) != BSSUCC)  ) {\
		printf( "FILE %s, LINE %d, %s: \n",\
			__FILE__, __LINE__, (_message_) ) ;\
		__DBGpr_int("BS error", (Bsrc) ) ;\
		goto label ;\
	}
#else
#	define  __CheckBSRC( Bsrc,  _message_, label )\
	if( ( ( (Bsrc) != BSSUCC ) ) ) goto label 
#endif

#ifdef vaimerrDEBUG
#	define __CheckPtr( Ptr, _message_, label ) \
	if( !(Ptr) ) {\
		printf( "NULL Pointer, FILE %s, LINE %d, %s: \n",\
			__FILE__, __LINE__, (_message_) ) ;\
		goto label ;\
	}
#else
#	define __CheckPtr( Ptr , _message_, label )\
	if( (!(Ptr)) ) goto label 
#endif

#ifdef vaimDEBUG
#	define __DBGpr_int( comment, integer )\
	printf( "\t%s: %d\n", (comment), (int) (integer) )
#else
#	define __DBGpr_int( comment, integer )
#endif

#ifdef vaimDEBUG
#	define __DBGpr_dbl( comment, real )\
	printf( "\t%s: %g\n", (comment), (double) (real) )
#else
#	define __DBGpr_dbl( comment, real )
#endif

#ifdef vaimDEBUG
#	define __DBGpr_str( comment, string )\
	printf( "\t%s: <%s>\n", (comment), (string) )
#else
#	define __DBGpr_str( comment, string )
#endif

#ifdef vaimDEBUG
#	define __DBGpr_vec( comment, vector )\
	printf( "\t%s: ( %g, %g, %g )\n", (comment),\
		(vector)[0], (vector)[1], (vector)[2] )
#else
#	define __DBGpr_vec( comment, vector )
#endif

#ifdef vaimDEBUG
#	define __DBGpr_mat( comment, matrix )\
	{ int __i, ___i ;\
		for( ___i = 0 ; ___i < 4 ; ___i++ ) {\
			__i = ___i * 4 ;\
			printf( "\t%s: | %7.2lf, %7.2lf, %7.2lf, %7.2lf |\n",\
				(comment),\
				(matrix)[0+__i], (matrix)[1+__i],\
				(matrix)[2+__i], (matrix)[3+__i] ) ;\
	}\
	}
#else
#	define __DBGpr_mat( comment, matrix )
#endif

#ifdef vaimDEBUG
#	define __DBGpr_obj( comment, object )\
	printf( "\t%s: [%d,%d]\n", (comment), (object).osnum, (object).objid )
#else
#	define __DBGpr_obj( comment, object )
#endif

#ifdef vaimDEBUG
#	define __DBGpr_me()\
	printf( "\tmy_id: [%d,%d]\n", OM_Gw_current_OS, my_id )
#else
#	define __DBGpr_me()
#endif

#ifdef vaimDEBUG
#	define __DBGpr_objlist( comment, count, list )\
	{ struct GRid *_o, *__max = (list) + (count) ;\
		for( _o = (list) ; _o < __max ; _o++ ) {\
			printf( "\t%s #%2d: [%d,%4d]\n",\
				(comment), _o - (list), _o->osnum, _o->objid );\
		}\
	}
#else
#	define __DBGpr_objlist( comment, count, list )
#endif


#ifdef vaimDEBUG
#	define __DBGpr_com( comment )\
		printf( "\t%s\n", (comment) )
#else
#	define __DBGpr_com( comment )
#endif

#ifdef vaimDEBUG
#	define __DBGpr_ith_obj( comment, index, list )\
		printf( "\t%s: %d -> [%d,%4d]\n",\
			(comment), (index), (list)[(index)].osnum,\
			(list)[(index)].objid )
#else
#	define __DBGpr_ith_obj( comment, index, list )
#endif

#endif
