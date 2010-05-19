/*
	I/VDS
*/

#ifndef vddefltvalue_include
#	define vddefltvalue_include

#ifndef _STANDARDS_H_
#	include <standards.h>
#endif

#ifndef _STDIO_H_
#	include <stdio.h>
#endif
#define VD_K_DEFVAL_NM_SZ  32	/* Max size of an attribute name	*/
#define VD_K_DEFVAL_VL_SZ  64	/* Max size of an attribute value	*/
#define VD_K_MX_NB_OF_VLS  30	/* Max # of values per attribute	*/
typedef struct {
	char	attrName[VD_K_DEFVAL_NM_SZ] ;
	char	attrValues[VD_K_MX_NB_OF_VLS][VD_K_DEFVAL_VL_SZ] ;
/*
 * Index of current value of 'attrName' in array 'attrValues' or -1 if
 * 'attrName' has not been selected.
 */
	char	curVal ;
	short	count ;
} VDdefaultValues ;

extern int
VDreadDefaultValues	__(( FILE *f, const int max, VDdefaultValues d[] )) ;

#endif
