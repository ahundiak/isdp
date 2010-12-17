/*
 * Include file for Raster Graphics Objects (#defines only)
 */

#ifndef igrrasterdef_include

#define igrrasterdef_include

#define MAX_NUM_PLANES 6
/* #define IGRRG IGRLB	*/		/* temporary			*/

#define RSBUFSIZE	51200


/*
 *  Raster file application type codes.
 */

#define RSAPP_TYPE	8
#define RSIIMAGE	8

/*
 *  Raster file data type codes.
 */

#define	RS84007_PACKEDBINARY	1
#define	RS84007_BYTE		2
#define	RS84007_WORD		3
#define	RS84007_INTEGER		4
#define	RS84007_REAL4		5
#define	RS84007_REAL8		6
#define	RS84007_COMPLEX		7
#define	RS84007_DP_COMPLEX	8
#define	RS84007_RLE_BINARY	9
#define	RS84007_RLE_VV		10
#define	RS84007_FOM		11
#define	RS84007_DTM		12
#define	RS84007_RLE_VV_W_Z	13
#define	RS84007_RLE_BINARY_W_ET	14
#define	RS84007_RLE_VV_W_ET	15
#define	RS84007_RLE_VV_W_Z_W_ET	16
#define	RS84007_RLE_VV_W_C_A_S	17
#define	RS84007_RLE_VV_W_NORMS	18
#define	RS84007_QUADTREE_VV	19
#define RS84007_CCITT_G4	24
#define RS84007_RLE_RGB         25
#define RS84007_RLE_VAR         26
#define RS84007_MODEL_VIEW	27
#define RS84007_RGB		28
#define RS84007_COMPRESSED_COT 29
#define RS84007_COMPOSITE	64
#define RS84007_TILED		65
#define RSMULTI_DATA_FILE	66
#define RS84007_CMYK_RLE        67
#define RS84007_GEN_RLE		68
#define RS84007_MULTI		70

/*
 *  Raster file properties which specify the
 *  manner in which the file is to be read/written.
 *  These bit fields are structured to take advantage
 *  of the scan line orientation/scannable word of the
 *  SDN84-007 raster header.
 */

#define RSLOWERLEFT     0x0002
#define RSHORIZONTAL	0x0004
#define RSGEOMETRY	0x0008
#define RSCOMPOSITE	0x0010
#define RSSCANNABLE	0x0100
#define RSNOUPDATEOVS   0x0200

/*
 *  Defines for I/IMAGE data packets.
 */
 
#define RSPTC_IIMAGE		1
#define RSPTC_IMAGER		2

#define RSSTC_ATTRIBUTES	1
#define RSSTC_COLORMAP		2
#define RSSTC_COLORTABLE	3
#define RSSTC_HISTOGRAM		4
#define RSSTC_DISPLOT		5
#define RSSTC_MAPASSOC		6
#define RSSTC_TILEINFO		7
#define RSSTC_FILEDATA		8
#define RSSTC_CALIBTABLE	9
#define RSSTC_OVINFO            10
#define RSSTC_DPB               11
#define RSSTC_MASKID            12
#define RSSTC_DISPMASK		13
#define RSSTC_VIRTCOLTABLE	14
#define RSSTC_PROPERTIES	15
#define RSSTC_CMYKTABLE         20

#define	RSDIRECT_MAP		0
#define	RSDITHER_MAP		1
#define RSPRE_MAP		2
#define RSPREG_MAP		3
#define RSPREB_MAP		4
#define RSPOST_MAP		5
#define RSPOSTG_MAP		6
#define RSPOSTB_MAP		7
#define RSNO_MAP		-1

/*
 *  Defines for CCITT Group 4 expansion.
 */
 
#define RSBPASS      	0
#define RSBVERT_M3   	1
#define RSBVERT_M2   	2
#define RSBVERT_M1   	3
#define RSBVERT_0    	4
#define RSBVERT_P1   	5
#define RSBVERT_P2   	6
#define RSBVERT_P3   	7
#define RSBHORIZ     	8
#define RSBRL1_M     	9
#define RSBRL1_T    	10
#define RSBRL2_M    	13
#define RSBRL2_T    	14
#define RSWPASS     	15
#define RSWVERT_M3  	16
#define RSWVERT_M2  	17
#define RSWVERT_M1  	18
#define RSWVERT_0   	19
#define RSWVERT_P1  	20
#define RSWVERT_P2  	21
#define RSWVERT_P3  	22
#define RSWHORIZ    	23
#define RSWRL1_M    	24
#define RSWRL1_T    	25
#define RSWRL2_M    	26
#define RSWRL2_T    	27
#define RSEOFF      	28
#define RSEXT	    	29
#define RSERRL	  	30
#define RSERRH	  	31

/*
 *  Defines for CCITT Group 4 compression.
 */
 
#define RSHOR_CODE	0x0004
#define RSHOR_SHIFT	3

#define RSPASS_CODE	0x0008
#define RSPASS_SHIFT	4

#define RSVL3_CODE	0x0020
#define RSVL3_SHIFT	7
#define RSVL2_CODE	0x0010
#define RSVL2_SHIFT	6
#define RSVL1_CODE	0x0002
#define RSVL1_SHIFT	3
#define RSV0_CODE	0x0001
#define RSV0_SHIFT	1
#define RSVR1_CODE	0x0006
#define RSVR1_SHIFT	3
#define RSVR2_CODE	0x0030
#define RSVR2_SHIFT	6
#define RSVR3_CODE	0x0060
#define RSVR3_SHIFT	7

#define RSEOFF_CODE	0x0800
#define RSEOFF_SHIFT	12

/*
 *  Defines common to compression and expansion.
 */
 
#define RSCOMMAND  0
#define RSDATA	   1
#define RSWHITE	   0
#define RSBLACK	   1
#define RSFIRST	   0
#define RSSECOND   1

#define RSA0	   0
#define RSA1	   1
#define RSA2	   2
#define RSB1	   1
#define RSB2	   2

/*
 *
 *  Raster display flags.
 *
 */

#define IGR_DYN_IN_PROGRESS	0x1
#define IGR_DRAW_BACK 	 	0x2
#define IGR_FILL_OUTLINE	0x4
#define IGR_CLEAR_BACK 		0x8
#define IGR_TRANS_BACK 		0x10
#define IGR_NO_BUFFER		0x20
#define IGR_CLEAR_HILIGHT	0x40
#define IGR_DRAW_HILIGHT        0x80
#define IGR_RLE_HILIGHT		0x100

/*
 *   Defines tiled file property word
 */

#define RS_TILES_UNORDERED      0x0001
#define RS_OVERVIEW_EXIST       0x0002

#define RS_POLYGON_MODE         0x0
#define RS_BLOCK_MODE           0x1
#define RS_ELEMENT_MODE         0x2
#define RS_BRUSH_MODE           0x3

#define RSENABLE_MASKING    0x1
#define RSINSIDE_MASK       0x2
#define RSOVERRIDE_MASKING  0x4
#define RSNOMASKONSOURCE    0x8               /* Used to override masking */
#define RSNOMASKTARGET      0x10              /* during copy/paste ops    */
#define RSDONOTCLIPSCAN     0x20              /* Do not clip scan to canvas */
                                              /* when calling RSgetscan     */

/*
 *  #defines for DISPMASK data packets flags field
 */

#define RSDISPMASK_ENABLED	0x00000001

/*
 *  #defines for PROPERTIES data packes
 */

#define RSGRAYSCALE		0x00000001

/* 
 *  #defines for struct fastrastdis_ext flags word
 */

#define RSUSE_SCAN		0x1
#define RSUSE_DRAW_FUNCTION	0x2
#define RSDISPLAY_MASK		0x4
#define RSDISPLAY_EDIT_MASK	0x8

/*
 *  #define for pattern_mode properties word in raster dpb
 */

#define IGR_SLOW_TEXT	      	0x0001
#define IGR_TRK_CURSOR	      	0x0002
#define IGR_NOT_EDIT_INSIDE_MASK 0x0004
#define IGR_EDIT_OUTSIDE_MASK 	0x0008
#define IGR_GRAYSCALE_COMPRESS 	0x0010
#define IGR_COLOR_CLOSEST_MATCH	0x0020
#define IGR_PERCEPTUAL_LUMINANCE 0x0040

#endif
