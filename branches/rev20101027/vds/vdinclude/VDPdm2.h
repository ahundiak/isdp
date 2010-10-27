/* I/VDS
 *
 * File:        vdpinclude/VDPdm2.h
 *
 * Description:  
 *
 * Dependencies:
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *       9/95           MSM             Creation
 */

#ifndef VDPdm2_include
#define VDPdm2_include

/* Codes that precede the DM2 call */

#define  VDP_QUERY_CTXTYST		1
#define  VDP_QUERY_PLCTX		2
#define	 VDP_QUERY_BWTCTX		3
#define	 VDP_QUERY_ESWBS		4
#define	 VDP_QUERY_FILEID		5
#define	 VDP_QUERY_OCC_TEMPLATE		6
#define	 VDP_POST_OCCURRENCE		7	/* Post Occurrences to PME */
#define	 VDP_RESERVE_OCC		8	/* Reserve Equipments */
#define  VDP_QUERY_PLLIST		9	/* Query Eqp placement list */
#define  VDP_QUERY_WRKPKG		10	/* Query PMR work packages */
#define  VDP_QUERY_ZONES		11	/* Query unplaced Zones */
#define	 VDP_PLACE_ZONE			12	/* Place Zone */
#define	 VDP_POST_ZONERELN		13	/* Post Zone-Item relation */
#define	 VDP_QUERY_CMPTS		14	/* Query unplaced Comparts */
#define	 VDP_PLACE_CMPT			15	/* Place Compartment */
#define	 VDP_POST_COMPRELN		16	/* Post Compart-Item relation */
#define	 VDP_QUERY_CMPT_ATTR		17	/* Query Compartment attribs */
#define	 VDP_POST_CPMT_ATTR		18	/* Post Compartment Attr */
#define	 VDP_QUERY_SHIPS		19	/* Query all active ships */
#define	 VDP_IS_FILE_REVISED		20	/* Verify if the file is revised */
#define	 VDP_UPDATE_FILEID		21	/* Update the file Id with
						   new cat, part & rev  */
#define  VDP_IS_EQUIP_RESERVED		22	/* Is Eqp reserved for plmnt?*/
#define  VDP_CREATE_PLLIST_FILE_RELN	23	/* Create PlList File relation*/
#define  VDP_MDEL_CMPMNT		24	/* Mark Delete Compartment */
#define  VDP_SUBMIT_BATCH_POST          26      /* indicates batch job submited
*/
#define  VDP_VERIFY_PREV_POST           30      /* Verify previous batch posting
*/


/* File state */

#define VDP_FILE_ACTIVE			10
#define VDP_FILE_FROZEN			20
#define VDP_FILE_REVISED		30
#define VDP_PARENT_FILE_HAS_SUCCESSOR	40 	/* Parent file has already been revised */
#define VDP_UPDATE_FILEDATA		50 	/* file has already been revised
						   in PME it needs to be updated
						   in the design file */

#define VDP_FILE_NEEDS_REVISED		700     /* mfail code for file to be revised */
#define VDP_SUCCESSOR_EXISTS		900	/* mfail code from PME */

#endif  /* VDPdm2_include */

