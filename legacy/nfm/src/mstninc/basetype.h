/*----------------------------------------------------------------------+
|									|
|   Current Revision:							|
|   $Workfile:   basetype.h  $
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
|   basetype.h -- Basic Type definitions for MicroStation/MDL  		|
|									|
+----------------------------------------------------------------------*/
#if !defined (__basetypeH__)
#define __basetypeH__

typedef unsigned long	ULong;
typedef unsigned short	UShort;
typedef unsigned int	UInt;
typedef unsigned char	UChar;
typedef int		ErrorCode;  /* 0 means no error, see also mdlerrs.h */

typedef struct versionnumber
    {
    UShort   release:8;
    UShort   major:8;
    UShort   minor:8;
    UShort   subMinor:8;
    } VersionNumber;
    
typedef struct point2d
    {
    long    x;
    long    y;
    } Point2d;

typedef struct point3d
    {
    long	x;
    long	y;
    long	z;
    } Point3d;

typedef struct dpoint2d
    {
    double	x;
    double	y;
    } Dpoint2d, DPoint2d;

typedef struct dpoint3d
    {
    double	x;
    double	y;
    double	z;
    } Dpoint3d, DPoint3d;

typedef struct spoint2d
    {
    short	x;
    short	y;
    } Spoint2d, SPoint2d;

typedef struct uspoint2d
    {
    unsigned short  x;
    unsigned short  y;
    } Uspoint2d;

typedef struct spoint3d
    {
    short	x;
    short	y;
    short	z;
    } Spoint3d, SPoint3d;

typedef struct uspoint3d
    {
    unsigned short  x;
    unsigned short  y;
    unsigned short  z;
    } Uspoint3d;

typedef struct upoint2d
    {
    unsigned long   x;
    unsigned long   y;
    } Upoint2d;

typedef struct upoint3d
    {
    unsigned long   x;
    unsigned long   y;
    unsigned long   z;
    } Upoint3d;

typedef struct vector2d
    {
    Point2d	org;
    Point2d	end;
    } Vector2d;

typedef struct vector3d
    {
    Point3d	org;
    Point3d	end;
    } Vector3d;

typedef struct svector2d
    {
    SPoint2d	org;
    SPoint2d	end;
    } Svector2d, SVector2d;

typedef struct svector3d
    {
    SPoint3d	org;
    SPoint3d	end;
    } Svector3d, SVector3d;

typedef struct dvector2d
    {
    DPoint2d	org;
    DPoint2d	end;
    } Dvector2d, DVector2d;

typedef struct dvector3d
    {
    DPoint3d	org;
    DPoint3d	end;
    } Dvector3d, DVector3d;

typedef struct extent
    {
    SPoint2d	origin;		/* upper left */
    short	width;
    short	height;
    } Sextent;
    
typedef struct rectangle
    {
    Point2d origin;
    Point2d corner;
    } Rectangle;

typedef struct srectangle
    {
    SPoint2d	origin;
    SPoint2d	corner;
    } Srectangle;

typedef struct drectangle
    {
    DPoint2d	origin;
    DPoint2d	corner;
    } Drectangle;

typedef struct urectangle
    {
    Uspoint2d	origin;
    Uspoint2d	corner;
    } Urectangle;

typedef struct transform3d
    {
    double	element[3][3];
    } Transform3d;

typedef struct transform2d
    {
    double	element[2][2];
    } Transform2d;

typedef struct assocpoint
    {
    ULong     	tagValue;
    long    	assoc[2];
    } AssocPoint;

#if !defined (resource)    
typedef union rotMatrix
    {
    double	form2d[2][2];
    double	form3d[3][3];
    } RotMatrix;

typedef union transform
    {
    double	form2d[2][3];
    double	form3d[3][4];
    } Transform;

typedef struct ritransform
    {
    Transform	trans;
    union
	{
	long	matrix2d[2][2];
	long	matrix3d[3][3];
	} rot;
    union
	{
	Point2d org2d;
	Point3d org3d;
	} view;
    union
	{
	Point2d org2d;
	Point3d org3d;
	} screen;
    } RITransform;
#endif

#if !defined (resource)
typedef union types_u
    {
    char	    c;
    unsigned char   uc;
    short	    s;
    unsigned short  us;
    long	    l;
    unsigned long   ul;
    int		    i;
    float	    f;
    double	    d;
    char	    *pc;
    }
Types_u;

#endif

/*----------------------------------------------------------------------+
|									|
|   Color Structures							|
|									|
+----------------------------------------------------------------------*/
typedef struct rgbColorDef
    {
    unsigned char   red;	   
    unsigned char   green;
    unsigned char   blue;
    } RGBColorDef;

typedef struct hsvcolor
    {
    int	    hue;	    /* red=0, yellow, green, cyan, blue, magenta */
			    /* 0 -> 360 */
    int	    saturation;	    /* 0=white, 100=no white, tints */
    int	    value;	    /* 0=black, 100=no black, shades */
    } HSVColor;
    
typedef struct RGBFACTOR	
    {
    double red;		    /* 0.0 < intensity < 1.0 */
    double green;	    /* 0.0 < intensity < 1.0 */
    double blue;	    /* 0.0 < intensity < 1.0 */
    } RGBFactor;

#endif	    /* __basetypeH__ */
