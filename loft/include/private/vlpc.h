/*
		I/LOFT profile card
*/

#ifndef vlpc_include
#define	vlpc_include

struct	VL_s_MacInfo
{
	struct	GRobj_env	*mac;
	short			set;
	double			xpos;
	double			ypos;
	double			alpha;
	double			range[6];
	short			side;
};
typedef	struct	VL_s_MacInfo	VLmacInfo;

struct	VL_s_VaS_Cs
{
	double	mat[16];
	short	type;
	double	xSca;
	double	ySca;
	double	xView;
	double	yView;
};
typedef	struct	VL_s_VaS_Cs	VLvasCs;

struct	VL_s_Stiff_Info_For_Mac
{
	struct	GRobj_env	webLeft;
	struct	GRid		nf;
	struct	GRid		iso0;
	struct	GRid		origin;
};
typedef struct 	VL_s_Stiff_Info_For_Mac VLsInfoForMc;

struct	VL_s_PcContext
{
	int		nbMac;
	int		curMac;
	VLmacInfo	*macInfoList;
	VLvasCs		vasCs;
	int		nbLabel;
	int		curLabel;
	struct	GRid	label[10];
	VLsInfoForMc    *stiffInfo;
};
typedef struct	VL_s_PcContext	VLpcContext;

/* ************************************************************************** */
#endif

