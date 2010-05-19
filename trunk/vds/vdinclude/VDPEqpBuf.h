/* I/VDS
 *
 * File:        vdpinclude/VDPEqpBuf.h
 *
 * Description:  Default data selection form
 *
 * Dependencies:
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *       10/95            MSM             Creation
 */

#ifndef VDPEqpBufDf_include
#define VDPEqpBufDf_include

#ifndef igrtypedef_include
#include <igrtypedef.h>
#endif

#ifndef VDPdef_include
#include "VDPdef.h"
#endif

#define VDP_CATALOG_LEN		19	/* 18+1 */
#define	VDP_PARTNUM_LEN		33	/* 32+1 */
#define VDP_PARTREV_LEN		16	/* 15+1 */

struct VDPpre_ld_eqp
{
   IGRchar	PMobid[VDPOBID_LEN];
   IGRchar	Catalog[VDP_CATALOG_LEN];
   IGRchar	PartNumber[VDP_PARTNUM_LEN];
   IGRchar	PartRev[VDP_PARTREV_LEN];
   IGRchar	Desc[VDPDESC_LEN];
   IGRchar	PlacedFlag;
};

#endif
