/*************************************************************************


Author	: HV

Creation: Sep. 22, 1993

   Constants needed for Connector object

Change History

	 Date	    |   name  | modification's description
        ------------+---------+------------------------------------------
        22 Sep   1993   HV      Initial creation

*************************************************************************/


#ifndef VRDfCn_include
#define VRDfCn_include

/* DATA ATTACHED TO CONNECT POINT */

#define         VRC_num_dbls      5   /*  number of doubles in communications
                                          block (coord + 2 angles)   */

/*    Connector addition algorithm types    */

#define         VRConn_CS     0x0001   /*  Static Connector      */
#define         VRConn_EQ     0x0002   /*  Dynamic Connector     */
#define         VRConn_VI     0x0004   /*  Virtual Connector     */
#define         VRConn_LG     0x0008   /*  Logical Connector     */

#define         VRConn_CB     0x0010   /*  Logical connector on cable  */

/* NOTE: Following type indicator was added to indicate to the placement  */
/*       method to not translate coordinates and angles but to set these  */
/*       to zero. It also frees the command object from having to determine */
/*       the location and orientation of the associated CS                */

#define         VRConn_EC     0x0020   /*  On CS, local coords/angles  */

#endif

