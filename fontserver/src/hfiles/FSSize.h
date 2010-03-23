/* $RCSfile: fssize.h $$Revision: 1.1 $$Date: 1990/07/02 16:08:15 $ Copyright (c) 1990 Intergraph Corp. */

#ifndef _SIZE
#define _SIZE	0


#include "FSDef.h"
#include "FSBmap.h"
#include "FSOutl.h"


/******************
* Structure sizes *
******************/

#define BMAP_HDR_SIZE		LONGWORD(sizeof (BmapHeader))
#define BMAP_INFO_SIZE		LONGWORD(sizeof (BmapInfo))
#define BMAP_KERN_SIZE(pairs)	LONGWORD(sizeof (BmapKernPair) * pairs)
#define BMAP_LIG_SIZE(ligs)	LONGWORD(sizeof (BmapLigature) * ligs)
#define BMAP_DIR_SIZE(chars)	LONGWORD(sizeof (BmapCharInfo) * chars)
#define BMAP_BMAP_SIZE(size)	LONGWORD(size)

#define OUTL_HDR_SIZE		DOUBLE(sizeof (OutlHeader))
#define OUTL_INFO_SIZE		DOUBLE(sizeof (OutlInfo))
#define OUTL_KERN_SIZE(pairs)	DOUBLE(sizeof (OutlKernPair) * pairs)
#define OUTL_LIG_SIZE(ligs)	DOUBLE(sizeof (OutlLigature) * ligs)
#define OUTL_DIR_SIZE(chars)	DOUBLE(sizeof (OutlCharInfo) * chars)
#define OUTL_PSIZE_SIZE(polys)	DOUBLE(sizeof (OutlPolySize) * polys)
#define OUTL_VERT_SIZE(verts)	DOUBLE(sizeof (OutlVertex) * verts)
#define OUTL_VERT3D_SIZE(verts)	DOUBLE(sizeof (Outl3DVertex) * verts)


#endif
