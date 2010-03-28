#ifndef REFERENCE_DEFS

#define REFERENCE_DEFS 1

/*
 * The following defines are for the GRinquireref method.
 * They are used in the variable length array input to the 
 * GRinquireref method to generate the valid options a 
 * command can request from a reference file attachment.
 */

#define SAVED_VIEW_NAME 	    1
#define REFERENCE_FILE_NAME 	    2
#define REFERENCE_INSTANCE_DATA     3
#define FILE_ACCESS_PROTECTION 	    4
#define FILE_PROPERTIES 	    5
#define ENVIRONMENT_INFO	    6
#define REFERENCE_ID                7
#define REFERENCE_NAME              8
#define REFERENCE_FILE_FOUND        9
#define REFERENCE_FILE_DUPOSNAME    10
#define REFERENCE_TYPE              11
#define END_REPORT_REQUEST 	    -1

/*
 * The following defines are for the GRreffile_report function.
 */

#define GR_saved_view_name          0x00000001
#define GR_reference_file_name      0x00000002
#define GR_reference_instance_data  0x00000004
#define GR_file_access_protection   0x00000008
#define GR_file_properties          0x00000010
#define GR_environment_info         0x00000020
#define GR_reference_id             0x00000040
#define GR_reference_name           0x00000080
#define GR_reference_file_found     0x00000100
#define GR_reference_file_duposname 0x00000200
#define GR_reference_type           0x00000400

/*
 * The following defines are for the output functions 
 * sent to the GRreffile_report function.
 */
#define PROCESS_LEVEL       0
#define BEGIN_TRANSITION    1
#define END_TRANSITION      2
#define END_FUNCTION       -1

/*
 * The following defines are used to set the bit masks for
 * the reference file properties.  These properties are
 * unique to the reference file object.
 */

#define GRRF_IS_READ_ONLY 	    0X00000001	/* file is read only		*/
#define GRRF_CLIP_POLY_USED	    0X00000002	/* clipping polygon used with the
                                               attachment. 			*/
#define GRRF_SAVED_VIEW_GONE 	0X00000004	/* saved view has been deleted 	*/
#define GRRF_SAVED_VIEW_USED 	0X00000008	

#define GRIS_SKEW		        0X00000010	/* attachment is skew		*/
#define GRIS_MODEL_ATTACHMENT	0X00000020 	/* type of attachment flag	*/
#define GRIS_TEMPORARY		    0X00000040  /* attachment is not  permanent	*/
#define GR_CAN_BE_ACTIVE 	    0X00000080	/* eligibility flag		*/
#define GROVERRIDE_SYMBOLOGY	0X00000100  /* attachment has an overriding
                                               symbology			*/
#define GRHIDDEN_OFF		    0x00000200	/* hidden symbology is off in
                                               the attachment		*/
#define GRRF_BACKGROUND         0x00000400  /* attachment to be activated
                                               only at the first level */
#define GRRF_UNLOADED           0x00000800  /* attachement not in memory */
#define GRRF_SHRINK_WRAP         0x00001000  /* clippoly shrunk to design file
                                               extents */

#define REFERENCE_FILE_MANAGER "Ref Mgr"


#define GRMASTER_CONTEXT	    0X1
#define	GREMPTY_CONTEXT		    0X2
#define	GRCYCLIC_ATTACHMENT	    0X4
#define GRACTIVATED_CONTEXT     0X8

#define GRLOC_ATTACHMENT 	    0X1
#define GRLOC_OBJECTS		    0X2

/* Following are the definitions for form gadgets */

#define UPDATE         11
#define CLIPPING       12
#define BACKGROUND     13
#define ATTACHNAME     14
#define DISPLAY        20
#define FILENAME       16

/* Following are colors defined for activation and deactivation */
#define ACTIVE_COLOR 43
#define DEACTIVE_COLOR 17

#endif
