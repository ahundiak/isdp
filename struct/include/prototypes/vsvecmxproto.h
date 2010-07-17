/*
	I/STRUCT
*/

#ifndef vsvecmxproto_include
#	define vsvecmxproto_include

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
#ifndef vsdpb_include
#	include "vsdpb.h"
#endif

extern double
*VSscalvc		__((	double		scale,
				const double	*inVector,
				double		*scaledVector )) ;

extern double
*VSnegvc		__((	const double	*inVector,
				double		*negVector )) ;

extern double
*VSvccpy		__((	double		*toVector,
				const double	*fromVector )) ;

extern double
*VSzerovc		__((	double		*nullVector )) ;


extern double
*VSmxcpy		__((	double		*toMatrix,
				const double	*fromMatrix )) ;

extern double
*VSmxprodvc		__((	const double	*matrix,
				const double	*vectorToMultiply,
				double		*multipliedVector )) ;

extern double
*VSmxprodpt		__((	const double	*matrix,
				const double	*pointToMultiply,
				double		*multipliedPoint )) ;

extern double
*VSmidpoint		__((	const double	*firstPoint,
				const double	*secondPoint,
				double		*midPoint )) ;

extern double
*VSmxorigin		__((	const double	*matrix4x4,
				double		*origin )) ;

extern double
*VSrotatemx		__((	double		rotationAngle,
				const double	*matrixToRotate,
				double		*rotatedMatrix )) ;

extern double
*VSscalemx		__((	double		scale,
				const double	*matrixToScale,
				double		*scaledMatrix )) ;

extern double
*VStranslatemx		__((	const double	*translationVector,
				const double	*matrixToTranslate,
				double		*translatedMatrix )) ;

extern double
*VSmirrormx		__((	enum VSsymmetry		symmetryType,
				const double		*matrixToMirror,
				double			*mirroredMatrix )) ;

extern double
*VSmulmx		__((	const double		*firstMatrix,
				const double		*secondMatrix,
				double			*productMatrix,
				short			*productMatrixType )) ;

extern double
*VSmkmatrix		__((	const double		*origin,
				const double		*xVector,
				const double		*yVector,
				const double		*zVector,
				double			*matrix4x4 )) ;


extern double
*VSpjPtOnPlAlongVc	__((	const IGRpoint		M,
				const IGRvector		n,
				const IGRpoint		Q,
				const IGRvector		p,
				IGRpoint		P )) ;

extern double
*VSpjVcOnPlAlongVc	__((	const IGRvector		v,
				const IGRvector		n,
				const IGRvector		p,
				IGRvector		w )) ;

extern int
VSzeroDist		__((	double			d )) ;

extern int
VSeqPoints		__((	const IGRpoint		p1,
				const IGRpoint		p2 )) ;

extern int
VScolinearVectors	__((	const IGRvector		v1,
				const IGRvector		v2 )) ;

extern int
VSareaColinearVectors	__((	const IGRvector		v1,
				const IGRvector		v2,
				double			angle )) ;
extern int
VSorthoVectors		__((	const IGRvector		v1,
				const IGRvector		v2 )) ;

extern int
VSareaOrthoVectors	__((	const IGRvector		v1,
				const IGRvector		v2,
				double			angle )) ;

#endif /* vsvecmxproto_include */

