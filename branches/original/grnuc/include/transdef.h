/*
Name
        transdef.h

Description
        This file contains definitions used during the translation
        to and from IGDS.

History
        created 'way back when the earth was young
*/


#ifndef transdef_include

#define transdef_include

/*
    Buffer size specifications.
*/

#define GUBSBUF_SIZE 		5032
#define	GUELE_BUF_SIZ		2048
#define	GUDGN_BUF_SIZ		20480
#define GUBLOCK_SIZE		512
#define GUMAX_NESTING		6

/*
    File I/O protection definitions.
*/

#define GUACCESS_MODE		0777
#define	GUREAD_ONLY		0
#define	GUWRITE_ONLY		1
#define GUREAD_WRITE		2
#define GUWRITE			0
#define GUREWRITE		1
#define GUFLUSH			2
#define GUINCREASE		3
#define GUWRITE_INIT		4
#define GURESET_POINTERS	5

/*
    Definitions for database type translation.
*/

#define GU_2I		0
#define GU_3I		1
#define GU_3D		2

/*
    Definitions for converting 2D VAX design files to an IGE 3D object file.
*/

#define GUMINVV_Z_2D		-100000
#define GUMAXVV_Z_2D		 100000
#define GUACT_Z_2D	 	 0

/*
    Pixel coordinates for independent hardware windows
*/

#define GU_FULL_MIN_X		.004222973
#define GU_FULL_MIN_Y		.0848416
#define GU_FULL_MAX_X		.8319256
#define GU_FULL_MAX_Y		.9276018

#define GU_QUAD1_MIN_X		.422297
#define GU_QUAD1_MIN_Y		.0848416
#define GU_QUAD1_MAX_X		.8319256
#define GU_QUAD1_MAX_Y		.47512

#define GU_QUAD2_MIN_X		.004222973
#define GU_QUAD2_MIN_Y		.0848416
#define GU_QUAD2_MAX_X		.4131
#define GU_QUAD2_MAX_Y		.47512

#define GU_QUAD3_MIN_X		.004222973
#define GU_QUAD3_MIN_Y		.514706
#define GU_QUAD3_MAX_X		.4131
#define GU_QUAD3_MAX_Y		.9276018

#define GU_QUAD4_MIN_X		.422297
#define GU_QUAD4_MIN_Y		.514706
#define GU_QUAD4_MAX_X		.8319256
#define GU_QUAD4_MAX_Y		.9276018

/*
    Pixel coordinates for hardware windows.
*/
 
#define GU_V_MIN_X	   5.00
#define GU_V_MAX_X	 985.00
#define GU_V_SIZE_X	 475
#define GU_V_MIN_Y	  75.00
#define GU_V_MAX_Y	 820.00
#define GU_V_SIZE_Y	 355

/*
    IGDS element types.
*/

#define GU_CELL_LIB_HEADER		1
#define GU_SYMBOL			(-2)
#define GU_CELL				2
#define GU_LINE				3
#define GU_LINE_STRING			4
#define GU_GROUP_DATA			5
#define GU_REFERENCE_FILE               0x0504
#define GU_SHAPE			6
#define GU_TEXT_NODE			7
#define GU_DIGITIZER			8
#define GU_DGN_FILE_HEADER		9
#define GU_LEVEL_SYMBOLOGY		10
#define GU_CURVE			11
#define GU_CPX_STRING			12
#define GU_CONIC			13
#define GU_CPX_SHAPE			14
#define GU_ELLIPSE			15
#define GU_ARC				16
#define GU_TEXT				17
#define GU_SURFACE			18
#define GU_SOLID			19
#define GU_BS_POLE			21
#define GU_POINT_STRING			22
#define GU_CIRC_TRUNC_CONE		23
#define GU_BS_SURF_HEADER		24
#define GU_BS_SURF_BOUNDARY		25
#define GU_BS_KNOT			26
#define GU_BS_CURVE_HEADER		27
#define GU_BS_WEIGHT_FACTOR		28
#define GU_RASTER_HEADER		87
#define GU_RASTER_DATA			88
#define GU_RASTER_90			90

/*
    Text justifications for IGDS and IGE.
*/

#define	GUIGDS_L_TOP		0
#define	GUIGDS_L_CENTER		1
#define	GUIGDS_L_BOTTOM		2
#define	GUIGDS_L_M_TOP		3
#define	GUIGDS_L_M_CENTER	4
#define	GUIGDS_L_M_BOTTOM	5
#define	GUIGDS_C_TOP		6
#define	GUIGDS_C_CENTER		7
#define	GUIGDS_C_BOTTOM		8
#define	GUIGDS_R_M_TOP		9
#define	GUIGDS_R_M_CENTER	10
#define	GUIGDS_R_M_BOTTOM	11
#define	GUIGDS_R_TOP		12
#define	GUIGDS_R_CENTER		13
#define	GUIGDS_R_BOTTOM		14

/*
    Maximum words to follow for IGDS elements and attribute data
*/

#define	GU_MAX_ELE_LINK   255	/* max attribute link size -  1	*/
#define	GU_MAX_DGN_SIZE	  766	/* max dgn buf size - 2		*/

/* 
    User data linkage for IGDS element name hook, and the other
    user data linkages in the CGM files.
*/

#define GU_LINKAGE_ID	  7	/* user id for translator links */
#define GU_NAME_TYPE	  0	/* user type for element names 	*/
#define GU_FILLCOLOR_TYPE 8     /* user type for fill color     */ 
#define GU_ELECOLOR_TYPE  19    /* user type for element color, when
				   both element color and fill color
				   are specified, fill color takes 
				   precedence over element color */
#define GU_STYLE_TYPE     21    /* user type for line style      */
#define GU_AREAFILL_TYPE  22    /* user type for area fill on/off */
#define GU_WEIGHT_TYPE    24    /* user type for line weight     */
#define	GU_FONT_TYPE      25	/* user type for Font Server information */
#define	GU_FILLPOLY_TYPE  65	/* user id for filled polygons */
#define GU_LINKAGE_PROPS  0x10	/* props for user data links	*/
/*#define GU_ATTR_PROP	  0x800	/ * mask to get IGDS A-bit	*/

/*
    Attribute linkage user id for InterPlot linkages
*/

#define GU_INTERPLOT_ID     65

/*
    Definitions to indicate if the IGDS user linkage type exist in the file
*/

#define HAS_NAME_TYPE	  0x01
#define HAS_FILLED_TYPE   0X02
#define HAS_FONT_TYPE     0X04

/*
    Attribute linkage user id for I/VEC - interpreted for I/FRATEL
*/

#define GU_IVEC_USER_ID   66
#define HAS_IVEC_TYPE     0x08

/*
    Definitions for text translation.
*/
 
#define GUBLANK_TYPE	0
#define GUESCAPE_TYPE 	1
#define GUINVALID_TYPE  2
#define GULEVEL_SYMB_ON 3

/*
    Definitions for the properties word in the font user data linkage;
    04/17/91 - the four high order bits of the properties word are now
    being used as a version number for the data linkage
*/

#define GU_FILLED_FONT       0x1
#define GU_SIXTEEN_BIT_FONT  0x2
#define GU_FS_LINK_VERSION   0x1000
#define GU_FS_LINK_VER_ALL   0xf000  /* mask for all version number bits */

/*
    Return codes for the optional filter function used during the
    creation of a plotfile.
*/

#define GU_SKIP_ELEMENT     0x00 /* Do not place the element in the plotfile */
#define GU_PROCESS_ELEMENT  0x01 /* Place the element in the plotfile */
#define GU_TERMINATE_PLOT   0x02 /* Used to signal a fatal error that should
                                    result in the termination of the create
                                    plotfile process. */

/*
    Definitions for the IGDS element header properties indicator word
*/

#define IGDSHole                (0x8000)
#define IGDSInfiniteLine        (0x8000)
#define IGDSSnappable           (0x4000)
#define IGDSPlanar              (0x2000)
#define IGDSRelative            (0x1000)
#define IGDSAttributeData       (0x0800)
#define IGDSModified            (0x0400)
#define IGDSNew                 (0x0200)
#define IGDSLocked              (0x0100)
#define IGDSSetProperty(w,p)    (w |= p)
#define IGDSPrimary             0
#define IGDSPatternComponent    1
#define IGDSConstructionElement 2
#define IGDSDimensioningElement 3
#define IGDSPrimaryRuleElement  4
#define IGDSLinearPatterned     5
#define IGDSConstructionRule    6
#define IGDSGetClass(w)         (0x000f & w)
#define IGDSSetClass(w,c)       (w |= c)

/*
    Definitions to indicate the target type of file during conversion.
*/

#define GRNoConversionInProgress        0
#define GRPlottingMetafile              1
#define GRIGDS                          2
#define GRMicroStation                  3

/*
    Definitions for data conversion directions
*/

#define GRVaxToSparc    0
#define GRSparcToVax    1

#endif
