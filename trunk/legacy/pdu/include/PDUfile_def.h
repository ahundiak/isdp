/* ALR   There were some #defines for PDU_DEBUG_FILE and
   PDU_ATP_DEBUG that needed to be defined for the
   ATP's. These #defines were moved to PDMdebug.h
   and defined there with a path.
*/
extern char PDM_DEBUG_FILE[80];
extern char PDU_DEBUG_FILE[80];
extern int PDMdebug_on;
  
#define    CHECKIN           10
#define    CHECKOUT          20
#define    DELETE_LOCAL      30
#define    COPY_LOCAL        40
#define    CANCEL_CHECKOUT   50
#define    POST_DATABASE     80
#define    FLAG_PART         90

/* definitions for file commands */
#define    REFRESH_PART      60
#define    LIST_PART	     70

/* definitions for GRpull_down_list */
#define          MAX_ROWS              200
#define          VIS_ROWS                8

/* definitions for buffer setup types */
#define        ROW            21
#define        COL            31
#define        FORMAT         41

/* definitions for new error messages */
#define  PDM_E_LIST_ENVS          201
#define  PDM_E_INVALID_SERVER     202
#define  PDM_E_INVALID_ENV        203
#define  PDM_E_INVALID_STRING     204
#define  PDM_E_NULL_LINKLIST      205

/* definitions for searching */
#define  CATALOG_LIST             401
#define  FILES                    402
#define  PARTS                    404

/* definitions for buffer formats */
#define PDU_LIST_LOCAL_FILES      501
#define PDU_LIST_PARTS            502
#define PDU_IN_ATTR               503  /* search buffers */
#define PDU_SEARCH_SORT           504
#define PDU_FILE_BUFFER           506
#define PDU_ASSY_PARTS            508  /* assembly structure buffers */
#define PDU_ASSY_STRUCT           509
#define PDU_CHILD_BUFR            510
#define PDU_CAT_ATTR              513
#define PDU_SAVE_CRITERIA         514
#define PDU_PART_FILE_BUFFER      515
#define PDU_PARTS_LIST_BUFFER     516
#define PDU_ADD_FILE_BUFFER       517
#define PDU_PARTS_MCF_BUFFER      518
#define PDU_STATES_BUFFER         519
#define PDU_ASSY_BUFR             520

/* definitions for checking out and activating a part */
#define ACT      601
#define NONACT   602

/* definitions for updating the assembly structure */
#define  ASSY_ATTACH  701
#define  ASSY_REPLACE 702
#define  ASSY_PLACE   703
#define  ASSY_DETACH  704

#define  NULL_STRING  ""
