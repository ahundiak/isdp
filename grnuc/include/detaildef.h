#ifndef detaildef_include
#define detaildef_include 1
/*
 * flag settings for GRdv_coord_sys_display
 */
#define GR_DV_CS_RESTORE  0x1


#define  GR_DV_REFFILE           0x01
#define  GR_DV_TEXTNAME          0x02
#define  GR_DV_TEXTSCALE         0x04
#define  GR_DV_CS                0x08
#define  GR_DV_ACTIVE_GRAPHICS   0x10

/* 
 *  Drawing sheet properties.
 */

#define  GR_DS_THIRD_ANGLE       0x0
#define  GR_DS_FIRST_ANGLE       0x10

#define  GR_DSMGR                "gr$dsmgr"

/*
 *  The following defines are for the drawing view orientation if a
 *  reference file was not specified.
 */

#define  GR_DV_RIGHT             0x1
#define  GR_DV_LEFT              0x2
#define  GR_DV_TOP               0x4
#define  GR_DV_BOTTOM            0x8
#define  GR_DV_FRONT             0x10
#define  GR_DV_BACK              0x20
#define  GR_DV_ISO               0x40
#define  GR_DV_VIEW_MASK         0xff

#define  GR_DV_TAN_ED_DIS_OFF_AFTER_PDD 0x1000 
                                        /* This bit is used to specify if
                                         *  tangent edges will be displayed
                                         *  in this drawing view after process.
                                         *  detail display is run.  Display
                                         *  off/1. Display on/0.  This has
                                         *  nothing to do with orientation,
                                         *  but I needed a bit and couldn't
                                         *  add instance data. Jack 6/12/92.
                                         */  
#define  GR_DV_TAN_ED_DIS_OFF_CURRENT      0x2000
                                        /* When process detail display is run
                                         * this bit will get the value of the
                                         * above bit.  This bit will also 
                                         * control the current display of
                                         * tangent edges before PDD is run.
                                         * Jack 7/10/92
                                         */  

/*
 *  The following defines are used by the drawing view alignment object.
 */

#define  DV1_TRANSLATED       0x1   /* Drawing view one was translated  */
#define  DV2_TRANSLATED       0x2   /* Drawing view two was translated  */
#define  DV1_PASSED           0x4   /* Drawing view one was passed a    */
                                    /* message                          */
#define  DV2_PASSED           0x8   /* Drawing view two was passed a    */
                                    /* message                          */
                                          
#endif /* detaildef_include */
