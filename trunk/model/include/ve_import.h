/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:58 $
$Locker:  $
*/

#ifndef ve_import_include
#define ve_import_include 1

#include "OMminimum.h"
#include "igrtypedef.h"

extern IGRboolean	BSxtractpar();
extern IGRboolean	BSprintbsps();
extern IGRboolean	BSprintbspc();
extern short	BSchangepar();
extern IGRboolean	BSadd_ktr();
extern short	BSactivsplt();
extern IGRboolean	BSallocsf();
extern double	BSarclen();
extern IGRboolean	BScv_slfint();
extern short	BScv_copy();
extern short	BSchrdlkts();
extern IGRboolean	BSconstprcv();
extern short	BScollinmny();
extern short	BSfreecv();
extern short	BScvnormal();
extern IGRboolean	BSfreesf();
extern short	BSmerge_cv();
extern short	BSpl_cv_int();
extern IGRboolean	BSprptoncv();
extern IGRboolean	BSsf_copy();
extern IGRboolean	BSptsdlcv();
extern short	BSunwght_p();
extern IGRboolean	MAinvmx();
extern char	*cuserid();
extern double	acos();
extern char	*ctime();
extern double	fabs();
extern char	*malloc();
extern char	*getenv();
extern char	*realloc();
extern char	*memcpy();
extern char	*strcpy();
extern char	*strcat();
extern double	sqrt();
extern char	*strchr();
extern char	*strncpy();
extern double	tan();
extern IGRboolean	BSprptonsf();

#define	FI_confirm_box	HFI_confirm_box

#endif
