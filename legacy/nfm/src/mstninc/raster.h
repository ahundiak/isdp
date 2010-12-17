/*----------------------------------------------------------------------+
|									|
|   Current Revision:							|
|   $Workfile:   raster.h  $
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
|   raster.h --								|
|									|
+----------------------------------------------------------------------*/
#ifndef __rasterH__
#define __rasterH__

/* .h file dependencies */ 
#if !defined (__mselemsH__)
#   include    <mselems.h>
#endif

/*----------------------------------------------------------------------+
|									|
|   Flags structure							|
|									|
+----------------------------------------------------------------------*/
typedef union raster_flags
    {	     
    struct  
	{   
#ifndef mc68000
	unsigned    right:1;
	unsigned    lower:1;
	unsigned    horizontal:1;
	unsigned    format:5;
	unsigned    color:1;
 	unsigned    transparent:1;
	unsigned    positive:1;
	unsigned    unused:5;
#else
	unsigned    unused:5;
	unsigned    positive:1;
 	unsigned    transparent:1;
	unsigned    color:1;
	unsigned    format:5;
	unsigned    horizontal:1;
	unsigned    lower:1;
	unsigned    right:1;
#endif
	} b;
    short s;    
    } Raster_flags;   

/*----------------------------------------------------------------------+
|    									|
|   Raster header element (type 87)					|
|									|
+----------------------------------------------------------------------*/
typedef struct raster_hdr
    {
    Elm_hdr	    ehdr;	    /* element header */
    Disp_hdr	    dhdr;	    /* display header */
    ULong	    totlength;	    /* total length of cell */
    Raster_flags    flags;	    /* miscellaneous raster data */
    byte	    background;
    byte	    foreground;
    UShort	    xextent;
    UShort	    yextent;
    short	    reserved[2];
    double	    resolution;
    double	    scale;
    Point3d	    origin;	
    UShort	    numverts;
    union 
	{      		  
	Point2d	    vert2d[1];
	Point3d	    vert3d[1];
	} u;
    } Raster_hdr;

/*----------------------------------------------------------------------+
|									|
|   Raster component (type 88)						|
|									|
+----------------------------------------------------------------------*/
typedef struct raster_comp
    {
    Elm_hdr	    ehdr;	    /* element header */
    Disp_hdr	    dhdr;	    /* display header */
    Raster_flags    flags;	    /* flags */
    byte	    background;
    byte	    foreground;
    UShort	    xoffset;
    UShort	    yoffset;
    UShort	    numpixels;
    byte	    pixel[1];
    } Raster_comp;

#define BITMAP	    1
#define BYTE_DATA   2
#define BINARY_RLE  9
#define BYTE_RLE    24 
		    
#endif
