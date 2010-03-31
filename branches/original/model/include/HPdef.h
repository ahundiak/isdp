#include "HSplot_def.h"

/*
 * operation flags
 */
 
#define	HPflag_PlotSize			0x00000001
#define	HPflag_PlotRes			0x00000002
#define	HPflag_InMeters			0x00000004
#define	HPflag_DeviceDriver		0x00000008
#define	HPflag_DevicePort		0x00000010
#define	HPflag_PlotFileName		0x00000020
#define	HPflag_RasterFileName		0x00000040
#define	HPflag_LogFileName		0x00000080
#define HPflag_SavedRasterFile		0x00000100
#define HPflag_DontPlot			0x00000200
#define	HPflag_Black_And_White		0x00000400
#define	HPflag_UseBackgroundColor	0x00000800
#define	HPflag_Black_Background		0x00001000
#define	HPflag_TextFileName		0x00002000
#define	HPflag_Exclude_Wireframe	0x00004000

/*
 *  return flags
 */
 
#define	HSplot_success	0
#define	HSplot_error	1
#define HSplot_info	2
#define HSplot_EOF	3


#define	HS14		0

/*
 *  General OLD_LIGHT source types.
 */

#define		HS_OLD_LIGHT_AMBIENT	0
#define		HS_OLD_LIGHT_PARALLEL	1
#define		HS_OLD_LIGHT_POINT	2
#define		HS_OLD_LIGHT_SPOT	3
#define		HS_OLD_LIGHT_PENCIL	4

/*
 *  Message Flags
 */

#define		HPmessage_PREFIX_PRODNAME	0x0001
#define		HPmessage_CONSOLE_WRITE		0x0002


/*
 *  HSplot processing flags
 */

#define	HPpflag_FEEDBACK_OBJID		0x0001
