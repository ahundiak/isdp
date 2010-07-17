/*********************************************************************

Author	:	B Demars

Creation:	October 24th, 1989


		This file contains the definition of all
		VRconstants.
		
	
Change History :


		  date	|  name	|	modification's description
		--------+-------+-----------------------------------
		12/12/89  VdM	 split file up
		22/12/89  VdM	 added defines for section_mask
		20/01/90  LLC	 modify define for section_mask add shape
		 9/04/90  LLC	 modify define for section_mask add color
		22/10/93  BD	 product are now defined in vrdef.h
		19/08/94  MM	 Added a new shape VR_TRAY for open tray.
                19/12/97  LAW    Added new shapes for RWAY, (CR179309874)
                Oct 1 99  Anand  Corrected shape code for Circ-Ellip to 66
*********************************************************************/

#ifndef	vr_privdef_include
#define vr_privdef_include

/* to avoid having to modify all sources */
#include "vrdef.h"
#define VR_CABLING	VR_RWAY

#define MAX_SHORT_INT   16348

/* defines for section_mask */

/* bit 0 to bit 3 */
#define		VR_SHAPE	0x000f	/* 0, 1, 2 and 3 bits of mask */
#define		VR_RECT		0x0000	/* */
#define		VR_OVAL		0x0001	/* */
#define		VR_CIRC		0x0002	/* */
#define		VR_CORNER	0x0003	/* */
#define		VR_ELLIPSE	0x0004	/* */
#define		VR_TRAY   	0x0004	/* Added by Kosta 1-24-98 for VRRDBi.I*/

/* define transition shape number */

#define	VR_RECT_OVAL	0x0010		/* rect	--> oval	16  */
#define	VR_RECT_CIRC	0x0020		/* rect	--> circular	32  */
#define	VR_RECT_CORN	0x0030		/* rect	--> corner	48  */
#define VR_RECT_ELLP	0x0040		/* rect --> ellipse         */
#define	VR_OVAL_CIRC	0x0021		/* oval --> circular	33  */
#define	VR_OVAL_CORN	0x0031		/* oval	--> corner	    */
#define VR_OVAL_ELLP	0x0041		/* oval --> ellipse         */
#define	VR_CIRC_CORN	0x0032		/* corn --> circular	50  */
#define	VR_ELLP_CORN	0x0034		/* corn --> ellipse	    */
#define VR_CIRC_ELLP	0x0042		/* circ --> ellipse     66  */

/*   Electrical/fiberoptic connectivity    */


#define       VRFODF_seqno     7    /*  # char in connectblock seqno    */
#define       VRFODF_posnam    12   /*  # char in Connect position name */
                                    /*    (contact name)                */
#define       VRFODF_fibdes    20   /*  # char in fiber description     */
                                    /*    (signal id)                   */


#define       VRFODF_eqdisp    (VRFODF_seqno + VRFODF_posnam)
#define       VRFODF_cbdisp     VRFODF_fibdes

#define       VRFODF_chnlist   20   /*  #char in connection id table entry  */

 enum   VRLn_connfunc { FB_Connect, FB_Disconnect, FB_ConForce,
                        FB_Disconnect_all, FB_Disconnect_complete};

#define       VRCONTYP_REG       0
#define       VRCONTYP_ICB       1
#define       VRCONTYP_ST        2

/*      communications (arrays of charstrings) for connectivity     */

#define   VRFODF_sngstr    20
#define   VRFODF_dblstr    40

typedef     IGRchar    VRConstring[VRFODF_sngstr];
typedef     IGRchar    VRCondblstr[VRFODF_dblstr];
typedef     IGRchar    VRConsigstr[VRFODF_fibdes];

#endif
