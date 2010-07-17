/*
   I/LOFT
   --------
		Debug help macros file.

*/
#ifndef vlppldebug_include
#define vlppldebug_include

#ifdef vsDEBUG
int	___i; 
struct GRid *_o, *__max;
#endif

#ifdef vsDEBUG
#	define __DBGpplpr_mat( comment, matrix )\
		for( ___i = 0 ; ___i < 4 ; ___i++ ) {\
			__i = ___i * 4 ;\
			printf( "\t%s: | %7.2lf, %7.2lf, %7.2lf, %7.2lf |\n",\
				(comment),\
				(matrix)[0+__i], (matrix)[1+__i],\
				(matrix)[2+__i], (matrix)[3+__i] ) ;\
	}
#else
#	define __DBGpplpr_mat( comment, matrix )
#endif

#ifdef vsDEBUG
#	define __DBGpplpr_objlist( comment, count, list )\
	 __max = (list) + (count) ;\
		for( _o = (list) ; _o < __max ; _o =_o+1 ) {\
			printf( "\t%s #%2d: [%d,%4d]\n",\
				(comment), _o - (list), _o->osnum, _o->objid );\
		}
#else
#	define __DBGpplpr_objlist( comment, count, list )
#endif


#endif
