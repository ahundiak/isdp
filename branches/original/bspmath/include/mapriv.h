/* Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved. */

#ifndef mapriv_include
#define mapriv_include

/*
 *
 *  Private include file for Math (MA) package.
 *
 */

#define	MAX_BOUNDS 16		/* maximum number of boundaries allowed	*/
#define MAX_ORDER 16		/* maximum order allowed		*/
#define	MAX_POLES 101		/* maximum number of poles allowed	*/
#define	MAX_RULES 256		/* maximum number of rule lines in 	*/
				/* each direction allowed		*/
#define AR	7 		/* arc					*/
#define BC      8               /* B-spline curve			*/
#define BS	6   		/* B-Spline surface			*/
#define CN      4    		/* cone					*/
#define CP      10              /* conic primitive                      */
#define CS      11              /* cubic spline curve                   */
#define EL	5    		/* elipse				*/
#define LN	1    		/* line					*/
#define LP      9               /* linear primitive                     */
#define LS	2    		/* line segment				*/
#define PL	0      		/* plane				*/
#define PY	3    		/* poly line				*/

/*
 *
 *  Machine dependent constants (must be accurately (!!!) re-determined to 
 *  transport the Math Package to another machine)
 *
 *  MALARGEST -      approx. largest double floating number on machine
 *  MASMALLEST -     approx. "smallest" double floating number on machine
 *  MASQRTLARGEST -  squareroot of MALARGEST
 *  MABASEFLOAT -    exponent base of the machine's floating-point number 
 * 	 	     system
 *  MALOGBASE -      natural logarithm of MABASEFLOAT
 *  MAMAXEXP -       maximum exponent allowable (relative to MABASEFLOAT)
 *		     for a double value
 *  MAMINEXP -       minimum exponent allowable (relative to MABASEFLOAT)
 *		     for a double value
 *  MAEXPOVERFLOW -  approx. value of x such that exp(x) overflows on 
 *		     machine
 *  MAEXPUNDERFLOW - approx. value of x such that exp(x) underflows on 
 *		     machine (i.e., exp(x) is essentially zero)
 *  MAETA - 	     maximum relative representation error (smallest 
 *		     double floating number such that 1 + x > 1 in 
 *		     floating-point arithmetic)
 *
 */

#if vax || __vax || __vax__
#  define MALARGEST	    ((float)1.701411733192644299e+38)
#  define MAMINDOUBLE   (0.01 * 2.938735877055718770e-37)
#  define MASMALLEST    ((float)MAMINDOUBLE)
#  define MAETA 	    1.0e-16
#  define MAMAXEXP	    127
#  define MAMINEXP	    -127
#  define MASQRTLARGEST 1.304381743659671e+19
#endif

#if defined(CLIX) || defined(SUNOS)  || defined(SUNOS5) || defined(BOSX) || defined (HPUX) || defined(NT) || defined(LINUX)
#  define MALARGEST	((float)3.40282346638528860e+38)
#  define MASMALLEST 	((float)1.40129846432481707e-45)
#  define MAETA 	1.0e-15
#  define MAMAXEXP	1024
#  define MAMINEXP	-1024
#  define MASQRTLARGEST 1.844674352395373e+19
#endif

#if defined(IRIX)
#  define MALARGEST	((float)3.40282347e+38)
#  define MASMALLEST    ((float)1.17549435e-38)
#  define MAETA 	1.0e-15
#  define MAMAXEXP	1024
#  define MAMINEXP	-1024
#  define MASQRTLARGEST 1.844674352395373e+19
#endif

#define MABASEFLOAT 	2
#define MALOGBASE       0.693147180559945313982
#define MAEXPOVERFLOW	(MALOGBASE * (double)MAMAXEXP)
#define MAEXPUNDERFLOW	(MALOGBASE * (double)(MAMINEXP - 1))

/*
 *
 *  Machine dependent constants related to the format of double precision
 *  numbers on the machine (must be re-determined to transport the Math 
 *  Package to another machine).  The prefix MADE refers to constants 
 *  dealing with the exponent while MADF refers to constants dealing with
 *  the fraction of a double precision number.  Double precsion numbers 
 *  are of the form
 *
 *		x = (1 ** sign) * (MABASEFLOAT ** exponent) * fraction 
 *  
 *  MADENUMWORDS   -  number of words (IGRshort) in a double precision 
 *		      number
 *  MADEWORD       -  word number (subscript of 0,1,...,MADENUMWORDS) 
 *		      containing exponent
 *  MADEBITMASK    -  mask containing all 1's in the position of the 
 *		      exponent of the appropriate word 
 *  MANDEBITMASK   -  logical not of MADEBITMASK
 *  MADEZEROMASK   -  mask containing the bit pattern of a (biased)
 *		      exponent of 0 in a double precision number
 *  MADESHIFT      -  number of bits needed to shift exponent within
 *		      its word (to right justify)
 *  MADEBIAS       -  exponent bias (true exponent = stored exponent - bias)
 *  MADEEVENADJUST -  if true exponent is even, the amount which is needed
 *		      to add to the exponent to obtain a fraction in the 
 *		      range [0.25, 1)
 *  MADEODDADJUST  -  if true exponent is odd, the amount which is needed
 *		      to add to the exponent to obtain a fraction in the 
 *		      range [0.25, 1)
 *  MADFEVENFACT   -  factor to apply to fraction if exponent is even
 *  MADFODDFACT    -  factor to apply to fraction if exponent is odd
 *  MADFNORMFACT   -  factor which must be applied to a number which
 *		      has been formed with a particular exponent to 
 *		      obtain the true value of base ** exponent (i.e.,
 *		      this constant overcomes the hidden bit in a 
 *		      floating point representation)
 *
 */

#if vax || __vax || __vax__		/* VAX				*/
#define MADENUMWORDS   	4
#define MADEWORD       	0
#define MADEBITMASK    	0x7f80
#define MANDEBITMASK	0x0807f
#define MADEZEROMASK   	0x4000
#define MADESHIFT	7	
#define MADEBIAS	128
#define MADEEVENADJUST  0
#define MADEODDADJUST   1
#define MADFODDFACT	0.5		/* (1.0/MABASEFLOAT)	*/
#define MADFEVENFACT    1.0
#define MADFNORMFACT	MABASEFLOAT
#endif

#if defined(CLIX) || defined(SUNOS)  || defined(SUNOS5)|| defined(IRIX) || defined(BOSX) || defined (HPUX) || defined(NT)
#define MADENUMWORDS   	4
#define MADEWORD       	3
#define MADEBITMASK    	0x7ff0
#define MANDEBITMASK	0x0800f
#define MADEZEROMASK   	0x3ff0
#define MADESHIFT	4	
#define MADEBIAS	1023
#define MADEEVENADJUST  2
#define MADEODDADJUST   1
#define MADFODDFACT	0.5		/* (1.0/MABASEFLOAT) 	*/
#define MADFEVENFACT    0.25		/* (MADFODDFACT/MABASEFLOAT)	*/
#define MADFNORMFACT	1
#endif


/*** MACRO DEFINITIONS ***/

/* bit_set sets a bit specified by bit_no in variable source.
 * source can be any type of variable ( char,short,long,unsigned ),
 * but not the address. bit_no can be any value from 0 to 31 depending
 * on source type.
 */
#define   MAbit_set(source,bit_no)    source |= 1 << (bit_no)


/* bit_clear clears a bit specified by bit_no in variable source.
 * source can be any type of variable ( char,short,long,unsigned ),
 * but not the address. bit_no can be any value from 0 to 31 depending
 * on source type.
 */
#define	  MAbit_clear(source,bit_no)  source &= ~( 1 << (bit_no) )


/* bit_test tests a bit specified by bit_no in variable source.
 * source can be any type of variable ( char,short,long,unsigned ),
 * but not the address. bit_no can be any value from 0 to 31 depending
 * on source type.
 * bit_test returns a value of 1 if the specified bit is on, 
 * returns 0 otherwise.
 */
#define MAbit_test(source,bit_no)   (((source) & (1<<(bit_no))) >> bit_no)


#define	MAgen_bit_set(addr,bit_no)  *(((IGRchar *) (addr))+((bit_no)/8)) |= \
					 ( 1 << ((bit_no)%8))

#define	MAgen_bit_clear(addr,bit_no) *(((IGRchar *) (addr))+((bit_no)/8)) &= \
					~( 1 << ((bit_no)%8))

#define	MAgen_bit_test(addr,bit_no) (*(((IGRchar *) (addr))+((bit_no)/8)) &  \
					 ( 1 << ((bit_no)%8)))

/* abslt(x) returns the absolute value of x. The advantage of this
 * over abs function is, abslt doesn't care about the data type
 * of the variable, it returns the same type of result as x.
 */
#define    MAabslt(x) ( ((x) < 0 ) ? -(x) : (x) )


/* macro to convert message codes from other packages to MA message codes,
 * the macro does not modify generic (MS) message codes
 */

/* flatmtrx(m1,m2,n) copies m1 to m2 and flattens m2 (forces z to the zero 
 * plane).  n represents the size of the square matrices and must be a 
 * constant, while i is the index variable.  Both m1 and m2 must be the 
 * address of the beginning of the respective matrix
 */
#define MAflatmtrx(m1,m2,n,i) \
		       {      \
			 for (i=0;i <= ((4*(n)) - 1);++i) (m2)[i] = (m1)[i];\
			 for (i=0;i <= n - 1;++i) (m2)[i+(n*2)] = 0.0;\
		       }



/* move(s,d,n) copies n bytes from s, source, to d, destination. 
 * s and d are addresses. n can be a constant defined by #define, 
 * it can be a sizeof operator, it can be a variable or a constant.
 */
#define MAmove(s,d,n) {register IGRchar *sp=(IGRchar *)(s);\
                       register IGRchar *dp=(IGRchar *)(d);\
                       register IGRint  i=(n);\
                       while (i--) *dp++ = *sp++;\
                      }

/* copypts(s,d,n,i) copies n points from s to d. s and d are addresses.
 * n can be a constant defined by #define, a constant, or it can be a variable.
 * i is an index variable.
 */
#define MAcopypts(s,d,n,i) {register IGRdouble *sp=(IGRdouble *)(s);\
                            register IGRdouble *dp=(IGRdouble *)(d);\
                            i = (3 * (n));\
                            while (i--) *dp++ = *sp++;\
                           }

/* copy(a,b,n,copy_index) copies n points from b to a. copy_index is an 
 * index variable which is used by the macro.
 */
#define MAcopy(a,b,n,copy_index) for(copy_index = 0;copy_index < 3*(n);\
                                     ++copy_index)                     \
                                *((a) + copy_index) = *((b) + copy_index);

/* copymtx(s,d,n) copies n matrices from s to d. s and d are addresses.
 * n can be a constant defined by #define, a constant, or it can be a variable.
 */
#define MAcopymtx(s,d,n) {register IGRdouble *sp=(IGRdouble *)(s);\
                          register IGRdouble *dp=(IGRdouble *)(d);\
                          register IGRint  i=(16 * (n));\
                          while (i--) *dp++ = *sp++;\
                         }

/* cmpdata(a,b,n) compares two arbitrary type data structures
 * (structure,array,etc.) for equality. a and b are the addresses 
 * of the data structures. n is simultaneously the number of 
 * bytes in the data structure and the index of the for loop, 
 * thus it MUST be a variable. For instance if a constant or the 
 * SIZEOF() operator is used it would have to be assigned to the
 * variable n prior to executing the macro. On exit, if n = 0 
 * the data structures are equal, if n != 0 they are not equal, 
 * analogous to the 'strncmp' procedure. (This macro simulates
 * the MACRO-11 'CMPC3' instruction. )
 */
#define MAcmpdata(a,b,n) {register IGRchar *ap =(IGRchar *) (a);\
                          register IGRchar *bp =(IGRchar *) (b);\
                          do if (*ap++ != *bp++)break; while (--n);}


/* cmppts(a,b,n,tol) compares two points for difference within a
 * tolerance,  which is defined to be the Euclidean distance
 * between the points. a and b are the addresses of the 
 * two points to compare. n must be a variable. TOL is a 
 * tolerance specified by either a variable or a constant.
 * n is equal to 0 if the points are not different (i.e. equal),
 * and to 1 if different.
 */
#define MAcmppts(a,b,n,TOL) {register IGRdouble *ap=(a);\
                             register IGRdouble *bp=(b);\
                             IGRdouble tmp, accum;\
                             n = 3;accum = 0;\
                             do { tmp = *ap++ - *bp++;\
                                  tmp *= tmp;\
                                  accum += tmp;\
                                }\
                             while (--n);\
                             if (accum > ((TOL) * (TOL))) n = 1;\
                            }
/*
 *
 * MAnint returns nearest integer to a given IGRdouble value.
 *
 */
#define MAnint(val) ((val >= 0.0) ?\
	 ((IGRlong)( (val) + 0.5)) : ((IGRlong) ((val) - 0.5)));


/*
 *
 *  Pole weighting and unweighting macros.
 *
 */

#define MAbcunweight(msg,curve)						\
	TRUE;								\
	*(msg) = MSSUCC;						\
	if ((curve)->rational)						\
	{								\
	  IGRlong i__xx;						\
	  for (i__xx = 0; i__xx < (curve)->num_poles; i__xx++)		\
	  {								\
	    (curve)->poles[3*i__xx] /= (curve)->weights[i__xx];		\
	    (curve)->poles[3*i__xx+1] /= (curve)->weights[i__xx];		\
	    (curve)->poles[3*i__xx+2] /= (curve)->weights[i__xx];		\
	  }								\
	}

#define MAbcweight(msg,curve)						\
	TRUE;								\
	*(msg) = MSSUCC;						\
	if ((curve)->rational)						\
	{								\
	  IGRlong i__xx;						\
	  for (i__xx = 0; i__xx < (curve)->num_poles; i__xx++)		\
	  {								\
	    (curve)->poles[3*i__xx] *= (curve)->weights[i__xx];		\
	    (curve)->poles[3*i__xx+1] *= (curve)->weights[i__xx];		\
	    (curve)->poles[3*i__xx+2] *= (curve)->weights[i__xx];		\
	  }								\
	}

/*  
 *
 * The following macros align pointers (if necessary).
 *
 */

#define MAalign_bdry(bdry,ptr) ((IGRulong) (ptr) % (bdry)) ? 	\
				(bdry) - (IGRulong) (ptr) % 	\
				(bdry) + (IGRchar *) (ptr) : (IGRchar *) (ptr)

#if vax || __vax || __vax__		        /* vax		        */
#  define MAalign_double(ptr) (ptr)
#  define MAalign_quad(ptr)   (ptr)
#  define MAalign_long(ptr)   (ptr)
#  define MAalign_short(ptr)  (ptr)
#  define MAalign_char(ptr)   (ptr)
#endif

#if defined(CLIX) || defined(SUNOS)  || defined(SUNOS5)|| defined(IRIX) || defined(BOSX) || defined (HPUX) || defined(NT)
#  define MAalign_double(ptr) MAalign_bdry(8,ptr)
#  define MAalign_quad(ptr)   MAalign_bdry(8,ptr)
#  define MAalign_long(ptr)   MAalign_bdry(4,ptr)
#  define MAalign_short(ptr)  MAalign_bdry(2,ptr)
#  define MAalign_char(ptr)   (ptr)
#endif

#endif /* mapriv_include */
