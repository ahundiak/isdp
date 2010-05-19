/* $Id: vIdbgmacros.h,v 1.5 2002/04/25 21:40:39 anand Exp $  */
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/include/vIdbgmacros.h
 *
 * Description: Debug related macros.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vIdbgmacros.h,v $
 *      Revision 1.5  2002/04/25 21:40:39  anand
 *      Learning C (to write a proper boolean condition)!
 *
 *      Revision 1.4  2002/04/24 20:10:33  anand
 *      Made the header file C and PPL compliant.
 *
 *      Revision 1.3  2001/03/08 20:24:42  ramarao
 *      __CheckPtr has some problems.
 *
 *      Revision 1.2  2001/02/20 18:00:46  ramarao
 *      *** empty log message ***
 *
 *      Revision 1.1  2001/02/19 21:13:03  ramarao
 *      *** empty log message ***
 *
 *      Revision 1.10  2001/02/15 00:16:39  ramarao
 *      Removed all the Header files.
 *
 *      Revision 1.9  2001/02/14 23:49:43  ramarao
 *      Included Many Header files.
 *
 *      Revision 1.8  2001/02/14 23:03:01  ramarao
 *      Included stdio.h and growner.h files.
 *
 *      Revision 1.7  2001/02/14 22:22:03  ramarao
 *      Removed VDobj.h include file.
 *
 *      Revision 1.6  2001/02/14 17:20:02  ramarao
 *      Added braces for each macro.
 *
 *      Revision 1.5  2001/02/14 16:42:12  ramarao
 *      Removed __SetProc(), __Enter() and __Exit() macros.
 *
 *      Revision 1.4  2001/02/14 15:57:55  ramarao
 *      *** empty log message ***
 *
 *      Revision 1.3  2001/02/14 15:48:47  ramarao
 *      Externalized debugging functions.
 *
 *      Revision 1.2  2001/02/14 15:13:24  ramarao
 *      New macros.
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      02/14/01        Rama Rao        File Creation on Valentine's day.
 *	02/19/01	Rama Rao	Renamed the filename to vIdbgmacros.h
 *	Apr 2002	Anand		Removed OM macro definition (allows
 *					vIdbgmacros.h to be included by .c
 *					files) and replaced !Ptr checks with
 *					Ptr!=NULL (allows vIdbgmacros.h to be
 *					included by .u files).
 *	25 Apr 2002	Anand		(!Ptr) translates to (Ptr==NULL)
 * -------------------------------------------------------------------*/

#ifndef v_debug_include
#define v_debug_include

#include <stdio.h>	/* For FILE */

extern long 	DBG_Gb_dbg;
extern FILE 	*DBG_Gb_Fp;

extern		VDdbg_Gb_Set(), VDdbg_Gb_Unset();

#ifndef VDobj_include

extern IGRlong VDobjPrint ();

#endif

extern void
VD_report_error                 __((    long             sts,
                                        FILE             *file )) ;

#define SetProc( p ) char __PROC__[40] ; strcpy( __PROC__, #p )

#define Begin	{ \
	if( DBG_Gb_dbg & DBG_PROD ) \
		{ \
		    fprintf( DBG_Gb_Fp, "%s:%s:%d >> %s: BEGIN\n",\
			 DBG_PROD_NAME, __FILE__, __LINE__, __PROC__ ) ; \
		    fflush( DBG_Gb_Fp ); \
		} \
	}

#define End     { \
	if( DBG_Gb_dbg & DBG_PROD ) \
                { \
		     fprintf( DBG_Gb_Fp, "%s:%s:%d << %s: END\n",\
			DBG_PROD_NAME, __FILE__, __LINE__, __PROC__ ) ; \
                      fflush( DBG_Gb_Fp ); \
                } \
	}

#define CheckRC( OMrc, GRrc )  { \
	   if( DBG_Gb_dbg & DBG_PROD ) \
	   {	\
	      if( !( (OMrc) & 1 ) ) \
	      {\
		fprintf( DBG_Gb_Fp, \
		      "FILE %s LINE %d: \n", __FILE__, __LINE__ ) ;\
		VD_report_error( (OMrc), DBG_Gb_Fp ) ;\
	      } else if( !( (GRrc) & 1 ) ) {\
		fprintf( DBG_Gb_Fp, "FILE %s LINE %d: message failed\n",\
			__FILE__, __LINE__ ) ;\
	      } \
	   } \
        }

#define __CheckRC( OMrc, GRrc, _message_, label ) { \
	if( DBG_Gb_dbg & DBG_PROD ) \
	{ \
	    if( !( (OMrc) & 1 ) ) \
	    {\
		fprintf( DBG_Gb_Fp, "FILE %s, LINE %d, %s: \n",\
			__FILE__, __LINE__, (_message_) ) ;\
		VD_report_error( (OMrc), DBG_Gb_Fp ) ;\
		goto label ;\
	    } else if( !( (GRrc) & 1 ) ) { \
		fprintf( DBG_Gb_Fp, "FILE %s LINE %d: %s failed\n",\
			__FILE__, __LINE__, (_message_) ) ;\
		goto label ;\
	    } \
	} \
	else \
        { \
	    if( !( (OMrc) & 1 & (GRrc) ) ) goto label; \
	} \
     }

#define __CheckSTS( STS, _message_, label ) { \
	if( DBG_Gb_dbg & DBG_PROD ) \
	{ \
	    if( !( (STS) & 1 ) ) {\
		fprintf( DBG_Gb_Fp, "FILE %s, LINE %d, %s: \n",\
			__FILE__, __LINE__, (_message_) ) ;\
		goto label ;\
	     } \
	} \
        else \
        { \
            if( !( (STS) & 1 ) ) goto label; \
        } \
     }

#define __CheckBSRC( Bsrc,  _message_, label ) { \
	if( DBG_Gb_dbg & DBG_PROD ) \
	{ \
	    if(  ((Bsrc) != BSSUCC)  ) {\
		fprintf( DBG_Gb_Fp, "FILE %s, LINE %d, %s: \n",\
			__FILE__, __LINE__, (_message_) ) ;\
		__DBGpr_int("BS error", (Bsrc) ) ;\
		goto label ;\
	    } \
	} \
        else \
        { \
            if( (Bsrc) != BSSUCC ) goto label; \
        } \
     }

#define __CheckPtr( Ptr, _message_, label ) { \
	if( DBG_Gb_dbg & DBG_PROD ) \
	{ \
	   if( (Ptr) == NULL ) {\
		fprintf( DBG_Gb_Fp, "NULL Pointer, FILE %s, LINE %d, %s: \n",\
			__FILE__, __LINE__, (_message_) ) ;\
		goto label ;\
	    } \
	} \
        else \
        { \
            if( (Ptr) == NULL ) goto label; \
        } \
     }

#define __DBGpr_int( comment, integer ) { \
	if( DBG_Gb_dbg & DBG_PROD ) \
	{ \
	    fprintf( DBG_Gb_Fp, "\t%s: %d\n", (comment), (int) (integer) ); \
	} \
     }

#define __DBGpr_dbl( comment, real ) { \
	if( DBG_Gb_dbg & DBG_PROD ) \
	{ \
	   fprintf( DBG_Gb_Fp, "\t%s: %g\n", (comment), (double) (real) ); \
	} \
     }

#define __DBGpr_str( comment, string ) { \
	if( DBG_Gb_dbg & DBG_PROD ) \
	{ \
	   fprintf( DBG_Gb_Fp, "\t%s: <%s>\n", (comment), (string) ); \
	} \
     }

#define __DBGpr_vec( comment, vector ) { \
	if( DBG_Gb_dbg & DBG_PROD ) \
	{ \
	   fprintf( DBG_Gb_Fp, "\t%s: ( %g, %g, %g )\n", (comment),\
		(vector)[0], (vector)[1], (vector)[2] ); \
	} \
     }

#define __DBGpr_mat( comment, matrix ) { \
	if( DBG_Gb_dbg & DBG_PROD ) \
	{ \
	    int __i, ___i ;\
	    for( ___i = 0 ; ___i < 4 ; ___i++ ) {\
		__i = ___i * 4 ;\
		fprintf( DBG_Gb_Fp, "\t%s: | %7.2lf, %7.2lf, %7.2lf, %7.2lf |\n",\
			(comment),\
			(matrix)[0+__i], (matrix)[1+__i],\
			(matrix)[2+__i], (matrix)[3+__i] ) ;\
	    }\
	} \
     }

#define __DBGpr_obj( comment, object ) { \
	if( DBG_Gb_dbg & DBG_PROD ) \
	{ \
	    fprintf( DBG_Gb_Fp, "\t%s:", (comment) ); \
	    VDobjPrint( NULL, &(object), NULL, TRUE, TRUE, NULL, DBG_Gb_Fp, NULL );\
	} \
     }

#define __DBGpr_me() { \
	if( DBG_Gb_dbg & DBG_PROD ) \
        { \
	    fprintf( DBG_Gb_Fp, "\tmy_id: [%d,%d]\n", \
		OM_Gw_current_OS, my_id ); \
	} \
     }

#define __DBGpr_objlist( comment, count, list ) { \
	if( DBG_Gb_dbg & DBG_PROD ) \
	{ \
	   struct GRid *_o, *__max = (list) + (count) ;\
		for( _o = (list) ; _o < __max ; _o++ ) {\
		    fprintf( DBG_Gb_Fp, "\t%s #%2d: [%d,%4d]\n",\
			(comment), _o - (list), _o->osnum, _o->objid );\
		}\
	} \
     }

#define __DBGpr_com( comment ) { \
	if( DBG_Gb_dbg & DBG_PROD ) { \
		fprintf( DBG_Gb_Fp, "\t%s\n", (comment) ); \
	} \
     }

#define __DBGpr_ith_obj( comment, index, list ) { \
	  if( DBG_Gb_dbg & DBG_PROD ) { \
		fprintf( DBG_Gb_Fp, "\t%s: %d -> [%d,%4d]\n",\
			(comment), (index), (list)[(index)].osnum,\
			(list)[(index)].objid ); \
	  } \
       }
#endif
