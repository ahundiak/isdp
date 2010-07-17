/* this file is used to define macros that apply to all Intergraph 
   include files */

#if !defined(_STANDARDS_H_)
#define _STANDARDS_H_

#if (defined(__STDC__) || defined(__cplusplus)) && !defined(_NO_POSIX)
#define _POSIX_SOURCE
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(p) p
#else
#define __(p) ()
#define const
#endif

#endif /* _STANDARDS_H_ */

