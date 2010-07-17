/*       Communications structure for VRconnectionm    */
/*
 *
 *     8-SEP-93      Initial
 *
 */

#ifndef  VRconn_include

#define  VRconn_include

#define         VRC_num_dbls      5
#define         VRC_charlen      40

#define         VRConn_CS         1
#define         VRConn_EQ         2

struct     VRC_comm     {

		IGRdouble	rpars[VRC_num_dbls];     /* coords - angles  */
		IGRchar		macname[VRC_charlen];    /* macro name       */
		IGRchar		conname[VRC_charlen];    /* connection id    */
                IGRint          stattab;   /* join to static DB table        */
                IGRint          product;   /* product code (VR_PIPING,       */
                                           /* VR_HVAC ..... etc.             */
                IGRint          stat_dyn;  /* Indicator static/dynamic conn  */
                                           /*   static  -- on coordsys       */
                                           /*   dynamic -- on equip. contour */
			};
#endif
