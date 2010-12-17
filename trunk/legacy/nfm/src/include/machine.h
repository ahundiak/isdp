/*---------------------------------------------------------------------+\
|
|	machine.h  --  machine specific definitions
|
|	Author:	 John Griswold
|
\+---------------------------------------------------------------------*/
/*---------------------------------------------------------------------+\
|	$Header: /usr3/nfm_spc/spc/nfm/include/machine.h,v 1.5 1995/09/06 07:09:50 nfm_spc Exp $
\+---------------------------------------------------------------------*/
/*---------------------------------------------------------------------+\
|
|	Modification History:
|
	22-Sep-1993
		forgot the line continuation character on some macros.
	02-Aug-1993
		Add BITFIELDS_ASCEND and BITFIELDS_DESCEND
	01-Aug-1993
		Add the definitions for rs6000
|
\+---------------------------------------------------------------------*/
#ifndef _H_machine
#define _H_machine


/*
//	Define the machine and operating system identification constants
//	that can be used to provide code dependencies.
//
//	The operating system OS_xxxx and processor CPU_xxxx are identified
//	in this section.
*/

/*
//	setup a alternate defines based on predefined compiler definitions
*/
#if defined( THINK_C )				\
		||  defined( THINK_Rez )	\
		||  defined( THINK_CPLUS )
#	ifndef		macintosh
#		define	macintosh	1
#	endif
#endif


#if defined( macintosh )
#	define OS_MACINTOSH	1
#endif




#if !defined( mdl )					\
		&&	!defined( resource )	\
		&&	!defined( type_resource_generator )


/*	Added defined sparc MVR 23 Dec 1993 */
#	if defined( __sparc ) || defined( __sparc__ ) || defined( sparc )
#		ifndef		CPU_SPARC
#			define	CPU_SPARC	1
#		endif
		/* Added MVR 23 Dec 1993 */
		/*HERE YOU NEED TO GIVE -Dsolaris for ver. compld on SOLARIS*/
#		if defined(solaris) && !defined(OS_SOLARIS) 
#			define	OS_SOLARIS
#		else
#			ifndef OS_SUNOS 
#				define OS_SUNOS
#			endif
#		endif
/* End of addition MVR */
				
		/*
		//	we need to add the OS_xxx variables
		//		OS_SUNOS
		//		OS_SOLARIS
		//		OS_UNIX
		*/


#	elif defined( winNT )


#		ifdef		msdos
#			undef	msdos
#		endif
#		ifdef		MSDOS
#			undef	MSDOS
#		endif
#		ifndef		OS_WINNT
#			define	OS_WINNT	1
#		endif


#	elif defined( pm386 )  ||  defined( MSDOS )


#		ifndef		OS_MSDOS
#			define	OS_MSDOS	1
#		endif


#	elif defined( __clipper )  ||  defined( __clipper__ )


#		ifndef		OS_UNIX
#			define	OS_UNIX		1
#		endif
#		ifndef		OS_CLIX
#			define	OS_CLIX		1
#		endif
#		ifndef		CPU_CLIPPER
#			define	CPU_CLIPPER	1
#		endif


#	elif defined( M_I386 )  &&  defined( __unix__ )


#		define	OS_UNIX			1
#		define	OS_PC_UNIX		1
#		define	OS_SCO_UNIX		1
#		define	CPU_INTEL386		1
		/* In SCO-RISDP 'sco' is used as the definition for SCO system.
		   This definition is added to make this work. 
      		   SSRS 31 Jan 94
   		*/
#		define  sco			1

#       elif defined( i386 ) && defined( solaris )
#                define OS_INTELSOL		1
#                define OS_SOLARIS		1		
#                define OS_UNIX			1

#	endif


#	if defined( __unix )  &&  !defined( OS_UNIX )
#		define	OS_UNIX	1
	/*	Added MVR 23 Dec 1993 */
#		ifdef M_I386
#			define OS_SCO_UNIX	1
#			define CPU_INTEL386	1
		/* In SCO-RISDP 'sco' is used as the definition for SCO system.
		   This definition is added to make this work. 
      		   SSRS 31 Jan 94
   		*/
#ifndef sco
#			define sco		1
#endif
#		endif
	/*	End of addition  MVR */
#	endif

#	if defined( __hp9000s700 )
#		define	CPU_HP700	1
#	endif
#       if defined( __hp9000s700 ) || defined( __hp9000s800 )
#               define  OS_HPUX         1  /* HP PORT - IGI 10 May 94 */
#       endif

#	if defined( __mips )  &&  !defined( CPU_MIPS )
#		define  CPU_MIPS	1
#	endif

#	if defined( __XLC121__ )
#		define	CPU_RS6000	1
#		define	OS_UNIX		1
#	endif

#endif  /* raw compiler stuff */



/*
//  defines for operating systems
*/
#if defined( msdos )  &&  !defined( OS_MSDOS )
#	define	OS_MSDOS	1
#elif defined( winNT )  &&  !defined( OS_WINNT )
#	define	OS_WINNT	1
#elif defined( unix )  &&  !defined( OS_UNIX )
#	define	OS_UNIX		1
#elif defined( macintosh )  &&  !defined( OS_MACINTOSH )
#	define	OS_MACINTOSH	1
#elif defined( vms )  &&  !defined( OS_VMS )
#	define	OS_VMS		1
#endif



/*
//  defines for hardware
*/
#if defined( vax )  &&  !defined( CPU_VAX )
#	define	CPU_VAX			1
#elif defined( mips )  &&  !defined( CPU_MIPS )
#	define	CPU_MIPS		1
#elif defined( OS_MSDOS )  &&  !defined( CPU_INTELx86 )
#	define	CPU_INTELx86	1
#elif defined( rs6000 )  &&  !defined( CPU_RS6000 )
#	define	CPU_RS6000		1
#endif



#if defined( OS_MACINTOSH )
#	ifndef		CPU_MC68000
#		define	CPU_MC68000		1
#	endif
	/*
	//	need to handle the CPU_POWERPC
	*/
#endif
/*----------------------------------------------------------------------+
|																		|
|	 End of defining the machine identification constants.				|
|																		|
+----------------------------------------------------------------------*/


/*----------------------------------------------------------------------+
|																		|
|	Platform specific capabilities										|
|																		|
+----------------------------------------------------------------------*/
#if defined( CPU_CLIPPER )			\
		||	defined( CPU_SPARC )	\
		||	defined( CPU_MIPS )		\
		||	defined( CPU_HP700 )	\
		||	defined( CPU_RS6000 )
#	define ALIGNMENT_FORCED	1
#endif

#if defined( ALIGNMENT_FORCED )  ||  defined( OS_SCO_UNIX )
/* ----------------------------------------------------------------------
   Note: on some systems, we may want to align members on 8-byte boundaries
   even though we are not "forced" to do so by processor limitations.  We do
   this in the case where the compiler pads structure members.
   ---------------------------------------------------------------------- */
#	define	ALIGN_MEMBERS_8BYTE		1
#endif


#if defined( CPU_SPARC )			\
		||	defined( CPU_MC68000 )	\
		||	defined( CPU_HP700 )	\
		|| 	defined( CPU_MIPS )	\
		||	defined( CPU_RS6000 )
#	define	BIG_ENDIAN
#	define	ENDIAN_BIG			1
#	define	BITFIELDS_DESCEND	1
#	define	BITFIELDS_REVERSED
#endif
#if !defined( BITFIELDS_DESCEND )
#	define BITFIELDS_ASCEND		1
#endif



#if !defined (ALIGN_CHAR)  &&  !defined (ALIGN_FLOAT)

#if defined( OS_MACINTOSH )

#	define ALIGN_CHAR			1L
#	define ALIGN_SHORT			2L
#	define ALIGN_LONG			2L
#	define ALIGN_FLOAT			2L

#	define ALIGN_DOUBLE			2L
#	define ALIGN_PTR			2L

#elif defined( OS_SCO_UNIX ) || defined( CPU_RS6000 )

#	define ALIGN_CHAR			1L
#	define ALIGN_SHORT			2L
#	define ALIGN_LONG			4L
#	define ALIGN_FLOAT			4L

#	define ALIGN_DOUBLE			4L
#	define ALIGN_PTR			4L

#elif defined (ALIGNMENT_FORCED)

#	define ALIGN_CHAR			1L
#	define ALIGN_SHORT			2L
#	define ALIGN_LONG			4L
#	if defined (mdl)
#		define ALIGN_FLOAT		8L
#	else
#		define ALIGN_FLOAT		4L
#	endif
#	define ALIGN_DOUBLE			8L
#	define ALIGN_PTR			4L

#elif defined ( OS_WINNT )

#	define ALIGN_CHAR			1L
#	define ALIGN_SHORT			2L
#	define ALIGN_LONG			4L
#	define ALIGN_FLOAT			4L
#	define ALIGN_DOUBLE			8L
#	define ALIGN_PTR			4L

#elif defined( OS_MSDOS ) || defined( CPU_VAX )

#	define ALIGN_CHAR			1L
#	define ALIGN_SHORT			1L
#	define ALIGN_LONG			1L
#	define ALIGN_FLOAT			1L
#	define ALIGN_DOUBLE			1L
#	define ALIGN_PTR			1L

#else
/* Following line commented by MVR 23 Dec 1993 */
/*	error Data Alignment must be defined in machine.h */
#endif
#endif


/* define constants for windowing system used */
#if defined( OS_CLIX )  &&  !defined( XWindow )
#	define		WIN_ENV5
#elif defined( CPU_SPARC )			\
		|| defined( CPU_VAX )		\
		|| defined( CPU_HP700 )		\
		|| defined( OS_PC_UNIX )	\
		|| defined( CPU_RS6000 )	\
		|| defined( CPU_MIPS )
#	define		WIN_X
#elif defined( OS_MACINTOSH )
#	define		WIN_MACINTOSH
#elif defined( OS_WINNT )
#	define		WIN_WINNT
#endif


#endif  /* _H_machine */
