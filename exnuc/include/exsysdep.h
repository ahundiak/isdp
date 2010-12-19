/*
**	exsysdep.h
**		
**	Abstract:
**		Define symbols that resolve architectural differences between
**		suppported machines.  Should be the first included file.
**
**	File dependencies:
**		none
*/

#if !defined(__exsysdep_H_file__)
#define __exsysdep_H_file__

#if defined(BIG_ENDIAN)
#   undef BIG_ENDIAN
#endif
#if defined(LITTLE_ENDIAN)
#   undef LITTLE_ENDIAN
#endif
#if defined(BIT_FIELDS_REVERSED)
#   undef BIT_FIELDS_REVERSED
#endif

#if defined(clipper) || defined(__clipper__) || defined(M_IX86) || defined(_M_IX86)
#   define	LITTLE_ENDIAN	1
#endif

#if defined(sparc) || defined(__sparc__) || defined(__sparc) || defined(mips) || defined(__mips__) || defined(__mips)
#   define	BIG_ENDIAN		1
#   define	BIT_FIELDS_REVERSED	1
#endif

#if defined(INTEL)
#   define	LITTLE_ENDIAN		1
#   undef	BIG_ENDIAN
#   undef	BIT_FIELDS_REVERSED
#endif

#endif	/* ifdef __exsysdep_H_file__ */
