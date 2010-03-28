/*\
Description
   This include file represents #defines used in the owner package.
\*/

#ifndef grownerdef_include
#define grownerdef_include

#  define   GR_RIGID             0     /* Rigid channel type            */
#  define   GR_FLEXIBLE          1     /* Flexible channel type         */
#  define   GR_NO_OVERRIDE       0     /* No override when connecting   */
                                       /* using GRflexconn              */
#  define   GR_OVERRIDE          1     /* Override when connecting      */
                                       /* using GRflexconn              */

#  define   GR_LC_CMP_READ       0x01  /* Locate comp for read          */
#  define   GR_LC_CMP_WRITE      0x02  /* Locate comp for write         */
#  define   GR_LC_CMP_PRM_READ   0x04  /* Locate comp for prism read    */
#  define   GR_LC_CMP_PRM_WRITE  0x08  /* Locate comp for prism write   */
#  define   GR_LC_OWN_READ       0x10  /* Locate owner for read         */
#  define   GR_LC_OWN_WRITE      0x20  /* Locate owenr for write        */
#  define   GR_LC_OWN_PRM_READ   0x40  /* Locate owner for prism read   */
#  define   GR_LC_OWN_PRM_WRITE  0x80  /* Locate owner for prism write  */
#  define   GR_LC_RIGID          0x100 /* Rigid relationship            */
#  define   GR_LC_FLEXIBLE       0x200 /* Flexible relationship         */
#  define   GR_LC_NO_PRM_COMP    0x400 /* Prism components are not      */
                                       /* needed when doing a prism     */
                                       /* locate                        */
#  define   GR_LC_CHECK_PLANAR   0x800 /* KLUDGE for 1.1                */

#  define   GR_ORPHAN            0x1   /* Set if an orphan group        */
#  define   GR_SPATIAL           0x2   /* Spatial entity                */

#endif
