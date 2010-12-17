/*----------------------------------------------------------------------+
|									|
|   Current Revision:							|
|   $Workfile:   mdlbspln.h  $
|   $Revision: 1.1 $  $Date: 1995/10/17 23:24:04 $
|									|
+----------------------------------------------------------------------*/
/*----------------------------------------------------------------------+
|									|
| Copyright (C) 1986-90   Bentley Systems, Inc., All rights reserved.	|
|									|
| "MicroStation", "MDL", and "MicroCSL" are trademarks of Bentley	|
|  Systems, Inc.							|
|									|
| Limited permission is hereby granted to reproduce and modify this	|
| copyrighted material provided that the resulting code is used only in	|
| conjunction with Bentley Systems products under the terms of the	|
| license agreement provided therein, and that this notice is retained	|
| in its entirety in any such reproduction or modification.		|
|									|
+----------------------------------------------------------------------*/
/*----------------------------------------------------------------------+
|									|
|   mdlbspln.h -- Include file for MDL applications using		|
|		  B-splines. Defines constants and strucutes.		|
|									|
+----------------------------------------------------------------------*/
#if !defined (__mdlbsplnH__)
#define __mdlbsplnH__

/*----------------------------------------------------------------------+
|									|
|   Immediate Defines							|
|									|
+----------------------------------------------------------------------*/
/* B-Spline curve types */
#define	    BSCURVE_GENERAL		0
#define	    BSCURVE_LINE		1
#define	    BSCURVE_CIRCULAR_ARC	2
#define	    BSCURVE_CIRCLE		3
#define	    BSCURVE_ELLIPTICAL_ARC	4
#define	    BSCURVE_ELLIPSE		5
#define	    BSCURVE_PARABOLIC_ARC	6
#define	    BSCURVE_HYPERBOLIC_ARC	7

/* B-Spline surface types */
#define	    BSSURF_GENERAL		0
#define	    BSSURF_PLANE		1
#define	    BSSURF_RIGHT_CYLINDER	2
#define	    BSSURF_CONE			3
#define	    BSSURF_SPHERE		4
#define	    BSSURF_TORUS		5
#define	    BSSURF_REVOLUTION		6
#define	    BSSURF_TAB_CYLINDER		7
#define	    BSSURF_RULED_SURFACE	8
		
/* Constants */
#define BSSURF_U 0
#define BSSURF_V 1

/* Miscellaneous Maxima */
#define MAX_POLES	101
#define MAX_ORDER	15
#define MAX_KNOTS	(MAX_POLES + 2*MAX_ORDER - 1)
#define MAX_DATA_PTS	250

/* Tolerances */
#define KNOT_TOLERANCE_BASIS	1E-5

/* Fit modes */
#define FIT_POLES    	    0
#define FIT_POINTS	    1
#define FIT_LEASTSQUARES    2

/*----------------------------------------------------------------------+
|									|
|   Structure Definitions						|
|									|
+----------------------------------------------------------------------*/
typedef struct bSplineParam
    {
    int		order;
    int		closed;
    int		numPoles;	       
    int		numKnots;
    int		numRules;
    } BsplineParam;

typedef struct bsplineDisplay
    {
    int		polygonDisplay;
    int		curveDisplay;
    int		rulesByLength;
    } BsplineDisplay;

typedef struct bsurfBoundary
    {
    int		numPoints;
    Dpoint2d	*points;
    } BsurfBoundary;

typedef struct msbsplinecurve
    {
    int			type;
    int			rational;
    BsplineDisplay	display;
    BsplineParam	params;
    Dpoint3d		*poles;		/* In homogenous coordinates */
    double		*knots;		/* Full knot vector */
    double		*weights;	/* Weights only if rational */
    } MSBsplineCurve;
    

typedef struct msbsplinesurface
    {
    int			type;
    int			rational;
    BsplineDisplay	display;
    BsplineParam	uParams;
    BsplineParam	vParams;
    Dpoint3d		*poles;
    double		*uKnots;
    double		*vKnots;
    double		*weights;
    int			holeOrigin;
    int			numBounds;
    BsurfBoundary	*boundaries;
    } MSBsplineSurface;
    
/*----------------------------------------------------------------------+
|									|
|   Published B-spline Data Structure Definition			|
|   	This structure is available whenever the			|
|    	splines.ma application is active.				|
|									|
+----------------------------------------------------------------------*/
typedef struct bsplineprefs
    {
    double		activeBsplineTolerance;
    BsplineDisplay	activeBsplineDisplay;
    BsplineParam	activeCurveParams;
    BsplineParam	activeUSurfParams;
    BsplineParam	activeVSurfParams;
    struct
    	{
    	double	initRad;
    	double	finalRad;
    	double	length;
    	double	sweepAng;
    	double	orientAng;
    	}    	    	activeSpiralData;
    struct
	{
	double	pitchHeight;
	int    	threadDir;
	}		activeHelixData;
    } BsplinePrefs;
    
#endif
