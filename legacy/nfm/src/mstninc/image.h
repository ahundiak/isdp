/*----------------------------------------------------------------------+
|									|
|   Current Revision:							|
|   $Header: /usr2/pinnacle/division/nfmspc/nfm/mstninc/RCS/image.h 1.1 1995/10/17 23:24:04 pinnacle Exp $	|
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
|   image.h -- Image file definitions used by				|
|		  MicroStation/MDL					|
|									|
+----------------------------------------------------------------------*/
#ifndef __imageH__
#define __imageH__


#ifndef __msrgbfil__
typedef void RGBFile;    /* Type used for creation/use of image files */
#endif

/*----------------------------------------------------------------------+
|									|
|   Image File Message Constants					|
|									|
+----------------------------------------------------------------------*/
#define IMAGEFILE_RGB	    1
#define IMAGEFILE_TARGA	    2
#define IMAGEFILE_TIFF	    3
#define IMAGEFILE_PICT	    4
#define IMAGEFILE_PCX	    5	    /* Not supported */
#endif  
