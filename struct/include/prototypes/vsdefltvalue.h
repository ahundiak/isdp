/*
	I/STRUCT
*/

#ifndef vsdefltvalue_include
#	define vsdefltvalue_include

#ifndef _STANDARDS_H_
#	include <standards.h>
#endif

#ifndef _STDIO_H_
#	include <stdio.h>
#endif
#define VS_K_DEFVAL_NM_SZ  32	/* Max size of an attribute name	*/
#define VS_K_DEFVAL_VL_SZ  64	/* Max size of an attribute value	*/
#define VS_K_MX_NB_OF_VLS  30	/* Max # of values per attribute	*/
typedef struct {
	char	attrName[VS_K_DEFVAL_NM_SZ] ;
	char	attrValues[VS_K_MX_NB_OF_VLS][VS_K_DEFVAL_VL_SZ] ;
/*
 * Index of current value of 'attrName' in array 'attrValues' or -1 if
 * 'attrName' has not been selected.
 */
	char	curVal ;
	short	count ;
} VSdefaultValues ;

extern int
VSreadDefaultValues	__(( FILE *f, const int max, VSdefaultValues d[] )) ;

#endif
