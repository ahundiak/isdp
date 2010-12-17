/*----------------------------------------------------------------------+
|									|
|   Current Revision:							|
|   $Header: /usr2/pinnacle/division/nfmspc/nfm/mstninc/RCS/plotter.h 1.1 1995/10/17 23:24:04 pinnacle Exp $
|									|
+----------------------------------------------------------------------*/
/*----------------------------------------------------------------------+
|									|
|   plotter.h -- Plotting Dialog Related Definitions			|
|									|
+----------------------------------------------------------------------*/
#ifndef __plotterH__
#define __plotterH__

/*----------------------------------------------------------------------+
|									|
|   Local Defines							|
|									|
+----------------------------------------------------------------------*/
#define	    FMT_EXT_LF	    "%-.3lf"
#define	    FMT_INT_LF	    "%lf"
#define	    PLOT_MIN_VALUE  "0.0001"
#define	    PLOT_MAX_VALUE  "99999.0"

#define	    CHANGE_PLTCFG		1
	
#define PLOT_ConfigNameIndex		1
#define PLOT_WidthIndex			5
#define PLOT_WidthDimsIndex		6
#define PLOT_HeightIndex		7
#define PLOT_HeightDimsIndex		8
#define PLOT_PageNameIndex		9
#define PLOT_DrawWidthDimsIndex		13
#define PLOT_DrawHeightDimsIndex	15
#define PLOT_DrawScaleNumDimsIndex	17
#define PLOT_DrawScaleDenDimsIndex	19
#define PLOT_OriginWidthDimsIndex	22
#define PLOT_OriginHeightDimsIndex	24
#define PLOT_StatusLabelIndex		32
#define PLOTPGSZ_UnitsIndex		2
#define PLOTPGSZ_WidthDotsIndex		4
#define PLOTPGSZ_HeightDotsIndex	5
#define PLOTPGSZ_WidthIndex		7
#define PLOTPGSZ_HeightIndex		8
#define PLOTPGSZ_WidthOffsetIndex	9
#define PLOTPGSZ_HeightOffsetIndex	10

#endif  
