#ifndef	vlbook_include
#define	vlbook_include

/* User interface execute form data */
#define	VL_EXEC_BOOK_CHAP	101
#define	VL_EXEC_BOOK_ROW	 21

/* Headed of loftbook chapters */
#define	VL_BOOK_TIT_A	"Displacement Stations / Frames Table"
#define	VL_BOOK_TIT_B	"Frame Crossings with Waterlines"
#define	VL_BOOK_TIT_C	"Station Crossings with Waterlines"
#define	VL_BOOK_TIT_D	"Buttock Crossings with Waterlines"
#define	VL_BOOK_TIT_E	"Stem Profile Crossings with Frames"
#define	VL_BOOK_TIT_F	"Stern Profile Crossings with Frames"
#define	VL_BOOK_TIT_G	"Flat of Side Crossings with Waterlines"
#define	VL_BOOK_TIT_H	"Flat of Side Crossings with Frames"
#define	VL_BOOK_TIT_I	"Flat of Bottom Crossings with Frames"
#define	VL_BOOK_TIT_J	"Flat of Bottom Crossings with Buttocks"
#define	VL_BOOK_TIT_K	"Knuckle Crossings with Frames"
#define	VL_BOOK_TIT_L	"Knuckle Crossings with Waterlines"
#define	VL_BOOK_TIT_M	"Knuckle Crossings with Buttocks"
#define	VL_BOOK_TIT_N	"Tangent Crossings with Frames"
#define	VL_BOOK_TIT_O	"Tangent Crossings with Waterlines"
#define	VL_BOOK_TIT_P	"Tangent Crossings with Buttocks"
#define	VL_BOOK_TIT_Q	"Deck Crossings with Frames"
#define	VL_BOOK_TIT_R	"Deck Crossings with Waterlines"
#define	VL_BOOK_TIT_S	"Seam Crossings with Frames"
#define	VL_BOOK_TIT_T	"Butt Crossings with Waterlines"
#define	VL_BOOK_TIT_U	"Longitudinal Crossings with Frames"

/* Indices of loftbook chapters */
#define	VL_BOOK_IDX_A		 0
#define	VL_BOOK_IDX_B		 1
#define	VL_BOOK_IDX_C		 2
#define	VL_BOOK_IDX_D		 3
#define	VL_BOOK_IDX_E		 4
#define	VL_BOOK_IDX_F		 5
#define	VL_BOOK_IDX_G		 6
#define	VL_BOOK_IDX_H		 7
#define	VL_BOOK_IDX_I		 8
#define	VL_BOOK_IDX_J		 9
#define	VL_BOOK_IDX_K		10
#define	VL_BOOK_IDX_L		11
#define	VL_BOOK_IDX_M		12
#define	VL_BOOK_IDX_N		13
#define	VL_BOOK_IDX_O		14
#define	VL_BOOK_IDX_P		15
#define	VL_BOOK_IDX_Q		16
#define	VL_BOOK_IDX_R		17
#define	VL_BOOK_IDX_S		18
#define	VL_BOOK_IDX_T		19
#define	VL_BOOK_IDX_U		20

/* User interface prepare form data */
#define	VL_PREP_BOOK_TITLE	100
#define	VL_PREP_BOOK_DIR	101
#define	VL_PREP_BOOK_ROW	 21
#define	VL_PREP_BOOK_DATA	102
#define	VL_PREP_BOOK_ADD	103
#define	VL_PREP_BOOK_DEL	104
#define	VL_PREP_BOOK_MSG	105
#define	VL_PREP_BOOK_STA	106
#define	VL_PREP_BOOK_ALL	107
#define	VL_PREP_BOOK_PUT	 11

/* User interface prepare form messages */
#define	VLPB_NO_DATA	"Must select a element to display data"
#define	VLPB_NO_ADD	"Must select a element to add data"
#define	VLPB_NO_DEL	"Must select a element to delete data"
#define	VLPB_NO_PUT	"Must select a element to put in queue"
#define	VLPB_NO_SEL	"No a selectable field"
#define	VLPB_STATION1	"20 Linear  Main Stations"
#define	VLPB_STATION2	"23 Displacement Stations"

/* Preparation directory indices */
#define	VL_BOOK_IDX_AFT		 0
#define	VL_BOOK_IDX_BSL		 1
#define	VL_BOOK_IDX_CTL		 2
#define	VL_BOOK_IDX_FWD		 3
#define	VL_BOOK_IDX_HUL		 4
#define	VL_BOOK_IDX_MID		 5
#define	VL_BOOK_IDX_ORI		 6
#define	VL_BOOK_IDX_BUT		 7
#define	VL_BOOK_IDX_BTK		 8
#define	VL_BOOK_IDX_DCK		 9
#define	VL_BOOK_IDX_FOB		10
#define	VL_BOOK_IDX_FOS		11
#define	VL_BOOK_IDX_FRM		12
#define	VL_BOOK_IDX_KNK		13
#define	VL_BOOK_IDX_LON		14
#define	VL_BOOK_IDX_SEA		15
#define	VL_BOOK_IDX_STA		16
#define	VL_BOOK_IDX_STM		17
#define	VL_BOOK_IDX_STN		18
#define	VL_BOOK_IDX_TGT		19
#define	VL_BOOK_IDX_WTL		20

/* Preparation directory <GR_UNKNOWN_TYPE> */
#define VL_BOOK_SELECT		257

/* Preparation directory short names */
#define	VL_BOOK_DIR_AFT		"aft"
#define	VL_BOOK_DIR_BSL		"bsl"
#define	VL_BOOK_DIR_CTL		"ctl"
#define	VL_BOOK_DIR_FWD		"fwd"
#define	VL_BOOK_DIR_HUL		"hul"
#define	VL_BOOK_DIR_MID		"mid"
#define	VL_BOOK_DIR_ORI		"ori"
#define	VL_BOOK_DIR_BUT		"but"
#define	VL_BOOK_DIR_BTK		"btk"
#define	VL_BOOK_DIR_DCK		"dck"
#define	VL_BOOK_DIR_FOB		"fob"
#define	VL_BOOK_DIR_FOS		"fos"
#define	VL_BOOK_DIR_FRM		"frm"
#define	VL_BOOK_DIR_KNK		"knk"
#define	VL_BOOK_DIR_LON		"lon"
#define	VL_BOOK_DIR_SEA		"sea"
#define	VL_BOOK_DIR_STA		"sta"
#define	VL_BOOK_DIR_STM		"stm"
#define	VL_BOOK_DIR_STN		"stn"
#define	VL_BOOK_DIR_TGT		"tgt"
#define	VL_BOOK_DIR_WTL		"wtl"
#define	VL_BOOK_DIR_PLA		"pln"	/* For infinite planes of stations */

/* Preparation directory complete names */
#define	VL_BOOK_SYN_AFT		"Aft Perp."
#define	VL_BOOK_SYN_BSL		"Baseline"
#define	VL_BOOK_SYN_CTL		"Centerline"
#define	VL_BOOK_SYN_FWD		"Forward Perp."
#define	VL_BOOK_SYN_HUL		"Hull"
#define	VL_BOOK_SYN_MID		"Midships"
#define	VL_BOOK_SYN_ORI		"Origin"
#define	VL_BOOK_SYN_BUT		"Butt"
#define	VL_BOOK_SYN_BTK		"Buttock"
#define	VL_BOOK_SYN_DCK		"Deck"
#define	VL_BOOK_SYN_FOB		"Flat-of-Bottom"
#define	VL_BOOK_SYN_FOS		"Flat-of-Side"
#define	VL_BOOK_SYN_FRM		"Frame"
#define	VL_BOOK_SYN_KNK		"Knuckle"
#define	VL_BOOK_SYN_LON		"Longitudinal"
#define	VL_BOOK_SYN_SEA		"Seam"
#define	VL_BOOK_SYN_STA		"Station"
#define	VL_BOOK_SYN_STM		"Stem"
#define	VL_BOOK_SYN_STN		"Stern"
#define	VL_BOOK_SYN_TGT		"Tangent"
#define	VL_BOOK_SYN_WTL		"Waterline"

#endif
