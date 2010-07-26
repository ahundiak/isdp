/*
Name
        csdef.h

Description
        This include contains #defines used for auxiliary coordinate systems.

Dependencies
        None

History
        mrm     08/05/87    creation
                11/02/87    added CoordSysMgrClass
                02/04/88    added construction flags
*/

#ifndef csdef_include

#define csdef_include

#define CoordSysMgr      "GRCS$manager" /* name stored in the IGE NOD        */
#define CoordSysMgrClass "GRcsmgr"      /* class of the coordinate sys mgr   */

#define Rectangular     "rectangular"   /* defines for coordinate sys types  */
#define Spherical       "spherical"     /*  recognized by GRgencs class      */
#define Cylindrical     "cylindrical"   /*  systems                          */

#define RECTANGULAR      0              /* defines for coordinate sys types  */
#define SPHERICAL        1              /*  recognized by GRgencs class      */
#define CYLINDRICAL      2              /*  systems                          */
#define UNKNOWN_CS_TYPE  4              /* for unrecognized type             */

#define ACTIVE_CS_WEIGHT 3              /* line weight for active cs         */

/*
 *  return codes from get GRget_cs_info method
 */

#define NAME_TRUNC       0X0000003      /* name too big for get_info buffer  */
#define DESC_TRUNC       0X0000005      /* description "                  "  */
#define BOTH_TRUNC       0X0000007      /* both name and description "    "  */

/*
 *  construction flags
 */

#define CS_CONNECT_TO_MGR       0x001   /* cs should ALWAYS be connected to  */
#define CS_NO_CONNECT_TO_MGR    0x000   /* the proper manager                */

#define CS_MAKE_ACTIVE          0x002   /* one and only one cs is active at  */
#define CS_NO_MAKE_ACTIVE       0x000   /* all times                         */

/*
 *  scale setting flags
 */

#define CS_ABSOLUTE             0x001   /* set scale absolutely              */
#define CS_RELATIVE             0x002   /* set scale relatively              */

#endif
