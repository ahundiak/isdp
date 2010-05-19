/* I/VDS
 *
 * File:        vdpinclude/VDPzone.h
 *
 * Description:
 *
 * Dependencies:
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *       12/95          MSM             Creation
 */

#ifndef VDPzone_include
#define VDPzone_include

#define		VDP_0D_ZONE		0
#define		VDP_1D_ZONE		1
#define		VDP_2D_ZONE		2
#define		VDP_3D_ZONE		3
#define		VDP_MDLVW_ZONE		4
#define		ZONE_TYPE_NOTDEF 	-1

struct VDPzone
{
    int			ZoneType; /* ModelView/3d/2d/1d/0d */
    struct GRid		ZoneId;
    struct VDPCtxInfo	ZoneCtx;
};

struct VDPcomp
{
    IGRchar		CompObid[VDPOBID_LEN];
    IGRchar		Name[81];
    IGRchar		SSCSnum[16];
    IGRchar		Description[81];
};

#endif  /* VDPzone_include */
