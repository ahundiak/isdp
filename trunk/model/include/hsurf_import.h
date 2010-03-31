
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:58 $
$Locker:  $
*/

#ifndef hsurf_import_include
#define hsurf_import_include 1

#include "OMminimum.h"
#include "igrtypedef.h"
#include "sys/types.h"
#if defined (sun)
#include <dirent.h>
#else
#include <sys/dirent.h>
#endif



extern IGRboolean	BSprintbsps();
extern IGRboolean	BSprintbspc();
extern IGRboolean	BSfreesf();
extern IGRboolean	BSallocsf();
extern short	BSactivsplt();
extern short	BSchrdlkts();
extern short	BSchangepar();
extern short	BSfreecv();
extern short	BSsf_rev();
extern IGRboolean	BSprptoncv();
extern IGRboolean	BSxtractpar();
extern short	BSunwght_p();
extern IGRlong	COexpreval();
extern IGRlong	COgetevent();
extern IGRlong	EFsspbtol_by_geom();
extern OMuword	EMSloopset$EMgetrange_method_index;
extern IGRboolean	MAtypemx();
extern IGRboolean	MAoptsxform();
extern IGRboolean	MA2ptdis();
extern IGRboolean	MAcrossvc();
extern IGRdouble	MAatan2();
extern IGRboolean	MAdotvc();
extern IGRboolean	MAinvmx();
extern IGRboolean	MAidmx();
extern IGRboolean	MAptalln();
extern IGRboolean	MAraddeg();
extern IGRboolean	MAptsxform();
extern double	atof();
extern double	acos();
extern double	cos();
extern char	*cuserid();
extern double	fabs();
extern char	*fgets();
extern long	ftell();
extern char	*malloc();
extern char	*getenv();
extern long	lseek();
extern char	*memset();
extern char	*memcpy();
extern double	pow();
extern char	*realloc();
extern char	*sbrk();
extern char	*strcpy();
extern double	sin();
extern char	*strcat();
extern double	sqrt();
extern char	*strchr();
extern char	*strncpy();
extern char	*strrchr();
extern char*	strtok();
extern char	*tmpnam();
extern DIR      *opendir();
extern struct dirent *readdir();
extern IGRchar	*AA_config_path();

#define	FI_confirm_box	HFI_confirm_box

#endif
