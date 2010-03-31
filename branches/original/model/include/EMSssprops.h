/*
Abstract

    This file contains definitions for simple surface properties.

History

    07/26/88         DLB  Added EMSIS_INACTIVE in ss_props.
    10 June 88       SAM  Added EMSIS_RTREE_RANGE_MODIFIED and
                          EMSIS_RANGE_MODIFIED bits in ss_props.
    30 October 87    AIC  Creation Date
*/

# ifndef EMSssprops_include
# define EMSssprops_include

/*
 * EMSsubbs properties word
 */
# define EMSformat              0x03    /* Foramt identification mask   */
# define EMSIS_NRML_REVERSED    0x04    /* Normal reversed bit          */
# define EMSIS_POLYDIS          0x08    /* Is the polygon displayed     */
# define EMSIS_SURFDIS          0x10    /* Is the surface displayed     */
# define EMSIS_RTREE_RANGE_GOOD 0x20    /* Rtree range is better than
                                            BSbx2() on poles.           */
# define EMSIS_RANGE_MODIFIED   0x40    /* Surf rng could be modified   */
# define EMSIS_INACTIVE         0x80    /* Is the surface inactive      */

/*
 * Surface format values
 */
# define EMSbsplineFormat       0x0     /* Bspline format               */
# define EMSprojectedFormat     0x1     /* Projected format             */
# define EMSrevolvedFormat      0x2     /* Revolved format              */
# define EMScanonicalFormat     0x3     /* Canonical format             */

/*
 * Bspline properties for bspline format
 */
# define EMSIS_U_PERIODIC       0x01    /* is periodic in U             */
# define EMSIS_V_PERIODIC       0x02    /* is periodic in V             */
# define EMSIS_U_NONUNIFORM     0x04    /* is non uniform in U          */
# define EMSIS_V_NONUNIFORM     0x08    /* is non uniform in V          */
# define EMSIS_U_PHYCLOSED      0x10    /* is physically closed in U    */
# define EMSIS_V_PHYCLOSED      0x20    /* is physically closed in V    */
# define EMSIS_RATIONAL         0x40    /* is rational                  */
# define EMSIS_UNUSED           0x80    /* unused                       */


/*
 * bspline properties for projected format
 */
# define EMS_PJ_SUBTYPE         0x03    /* mask for subtype bits        */
# define EMSIS_PJ_UNUSED        0x04    /* unused bit                   */
# define EMSIS_PJ_PERIODIC      0x08    /* curve is periodic            */
# define EMSIS_PJ_NONUNIFORM    0x10    /* curve is non uniform         */
# define EMSIS_PJ_PHYCLOSED     0x20    /* curve is physically closed   */
# define EMSIS_PJ_RATIONAL      0x40    /* is rational                  */
# define EMSIS_PJ_PLANAR        0x80    /* curve is planar              */

/*
 * Subtype values for projected format 
 */
# define EMSIS_PJ_UNUSEDST      0x00    /* unused subtype               */
# define EMSIS_PJ_ORTHO         0x01    /* orthagonal subtype           */
# define EMSIS_PJ_VECTOR        0x02    /* vector subtype               */
# define EMSIS_PJ_SCALED        0x03    /* scaled subtype               */

/*
 * bspline properties for revolved format
 */
# define EMSIS_RV_360           0x01    /* Revolution is 360 degrees    */
# define EMSIS_RV_PERIODIC      0x02    /* curve is periodic            */
# define EMSIS_RV_NONUNIFORM    0x04    /* curve is non uniform         */
# define EMSIS_RV_PHYCLOSED     0x08    /* curve is physically closed   */
# define EMSIS_RV_RATIONAL      0x10    /* is rational                  */
# define EMSIS_RV_PLANAR        0x20    /* curve is planar              */
# define EMSIS_RV_AXISPLANAR    0x40    /* curve and axis coplanar      */
# define EMSIS_RV_UNUSED        0x80    /* unused                       */

/*
 * canonical sphere's properties
 */
# define EMSIS_SP_ORIENTED      EMSSS_FREE_BIT_0
                                /* Is the sphere rotationally oriented? */
# define EMSIS_SP_REVERSED      EMSSS_FREE_BIT_1
                                /* Is the oriented sphere rotated in    */
                                /* the opposite direction as indicated  */
                                /* by the axis?                         */
                                
/*
 * canonical cylinder's properties
 */
# define EMSIS_CL_ORIENTED      EMSSS_FREE_BIT_0
                                /* Is the cylinder oriented?            */
# define EMSIS_CL_REVERSED      EMSSS_FREE_BIT_1
                                /* Is the oriented cylinder rotated in  */
                                /* the opposite direction as indicated  */
                                /* by the axis?                         */
                                
# endif
