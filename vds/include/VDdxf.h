/* $Id: VDdxf.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDdxf.h
 *
 * Description:	DXF oriented stuff
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDdxf.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  2000/02/18  16:01:30  pinnacle
 * sms
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 01/13/00  ah      Creation
 ***************************************************************************/
#ifndef VDdxf_include
#define VDdxf_include

#ifndef   VDtypedef_include
#include "VDtypedef.h"
#endif

#ifndef   VDxml_include
#include "VDxml.h"
#endif

#ifndef   VDcvg_include
#include "VDcvg.h"
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ---------------------------------------------
 * Main file information 
 */
typedef struct {
  IGRchar  fileName[256];
  FILE    *file;

  // Handy to have global translate
  struct 
  {
    IGRdouble x,y,z;
  } trn;

} TVDdxfFileInfo;

typedef struct {
  IGRchar   layer[32];
  IGRint    level;
  IGRint    color;
  IGRint    style;
  IGRint    weight;
  struct 
  {
    IGRdouble height;
    IGRdouble angle;
    IGRint    justify;
  } text;
} TVDdxfSymb;

extern IGRstat VDdxfOpenOutputFile  
__((TVDdxfFileInfo *dxf,
    IGRchar        *fileName));

extern IGRstat VDdxfCloseOutputFile 
__((TVDdxfFileInfo *dxf));

extern IGRstat VDdxfWriteText 
__((TVDdxfFileInfo *dxf,
    TVDdxfSymb     *symb,
    IGRdouble      *pt,
    IGRchar        *text));

extern IGRstat VDdxfWritePoint    __((TVDdxfFileInfo *dxf,
				      TVDdxfSymb     *symb,
				      IGRdouble      *pt));


extern IGRstat VDdxfWriteCvgCurve __((TVDdxfFileInfo *dxf,
				      TVDdxfSymb     *symb,
				      IGRint          numVertexes,
				      TVDcvgVertex   *vertexes));

extern IGRstat VDdxfWriteCvgText  __((TVDdxfFileInfo *dxf,
				      TVDdxfSymb     *symb,
				      TVDcvgText     *text));

/* ---------------------------------------------
 * Some standard colors
 */
#define DXF_COLOR_NONE   -1
#define DXF_COLOR_WHITE   0
#define DXF_COLOR_RED     1
#define DXF_COLOR_YELLOW  2
#define DXF_COLOR_GREEN   3
#define DXF_COLOR_CYAN    4
#define DXF_COLOR_BLUE    5
#define DXF_COLOR_MAGENTA 6


/* ---------------------------------------------
 * Some standard text justifications
 */
#define DXF_JUSTIFY_LEFT   0
#define DXF_JUSTIFY_CENTER 1
#define DXF_JUSTIFY_RIGHT  2
#define DXF_JUSTIFY_MIDDLE 3

/* ----------------------------------------------------
 * Clean up
 */
#if defined(__cplusplus)
}
#endif

#endif
