/*
	I/VDS	Copy.
*/

#ifndef v_vecmxproto_include
#	define v_vecmxproto_include

#ifndef _STANDARDS_H_
#	include <standards.h>
#endif

#ifndef OM_D_MINIMUM
#	include "OMminimum.h"
#endif
#ifndef igetypedef_include
#	include "igetypedef.h"
#endif
#ifndef igrtypedef_include
#	include "igrtypedef.h"
#endif

extern double
*VD_scalvc		__((	double		scale,
				const double	*inVector,
				double		*scaledVector )) ;

extern double
*VD_negvc		__((	const double	*inVector,
				double		*negVector )) ;

extern double
*VD_vccpy		__((	double		*toVector,
				const double	*fromVector )) ;

extern double
*VD_zerovc		__((	double		*nullVector )) ;


extern double
*VD_mxcpy		__((	double		*toMatrix,
				const double	*fromMatrix )) ;

extern double
*VD_mxprodvc		__((	const double	*matrix,
				const double	*vectorToMultiply,
				double		*multipliedVector )) ;

extern double
*VD_mxprodpt		__((	const double	*matrix,
				const double	*pointToMultiply,
				double		*multipliedPoint )) ;

extern double
*VD_midpoint		__((	const double	*firstPoint,
				const double	*secondPoint,
				double		*midPoint )) ;

extern double
*VD_mxorigin		__((	const double	*matrix4x4,
				double		*origin )) ;

extern double
*VD_rotatemx		__((	double		rotationAngle,
				const double	*matrixToRotate,
				double		*rotatedMatrix )) ;

extern double
*VD_scalemx		__((	double		scale,
				const double	*matrixToScale,
				double		*scaledMatrix )) ;

extern double
*VD_translatemx		__((	const double	*translationVector,
				const double	*matrixToTranslate,
				double		*translatedMatrix )) ;

extern double
*VD_mulmx		__((	const double		*firstMatrix,
				const double		*secondMatrix,
				double			*productMatrix,
				short			*productMatrixType )) ;

extern double
*VD_mkmatrix		__((	const double		*origin,
				const double		*xVector,
				const double		*yVector,
				const double		*zVector,
				double			*matrix4x4 )) ;


extern double
*VD_pjPtOnPlAlongVc	__((	const IGRpoint		M,
				const IGRvector		n,
				const IGRpoint		Q,
				const IGRvector		p,
				IGRpoint		P )) ;

extern double
*VD_pjVcOnPlAlongVc	__((	const IGRvector		v,
				const IGRvector		n,
				const IGRvector		p,
				IGRvector		w )) ;

extern int
VD_zeroDist		__((	double			d )) ;

extern int
VD_eqPoints		__((	const IGRpoint		p1,
				const IGRpoint		p2 )) ;

extern int
VD_colinearVectors	__((	const IGRvector		v1,
				const IGRvector		v2 )) ;

extern int
VD_areaColinearVectors	__((	const IGRvector		v1,
				const IGRvector		v2,
				double			angle )) ;
extern int
VD_orthoVectors		__((	const IGRvector		v1,
				const IGRvector		v2 )) ;

extern int
VD_areaOrthoVectors	__((	const IGRvector		v1,
				const IGRvector		v2,
				double			angle )) ;

#endif /* v_vecmxproto_include */

