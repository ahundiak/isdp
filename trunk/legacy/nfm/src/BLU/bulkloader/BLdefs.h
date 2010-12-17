/* BLdefs.h
  
   Purpose:
        This module defines the constants used by the bulkload program.

   History:
     Date   Programmer          Change
   ---------------------------------------------------------------------------
   06/10/91    WRW         Initial Release
   06/28/91    WRW         Added definitions for NFM copy operation.
   08/21/91    WRW         Added definitions for NFM add set operation.
   08/23/91    WRW         Added definitions for NFM add to project operation.
	06/14/92    wrw         added def for operation ftr_index
   09/02/94    wrw         added support for set check in and out.

*/

#define VERSION                                "3.0.0.0"
#define MAX_ASCII_LINE_LEN                     300
#define MAX_ATTRIBUTE_LEN                      300
#define MAX_ATTR_NAME_LEN                       21
#define MAX_CAT_NAME_LEN                        50
#define MAX_SA_LEN                              60
#define MAX_ITEM_NAME_LEN                      100
#define MAX_ITEM_REV_LEN                       100
#define MAX_SET_NAME_LEN                       100
#define MAX_SET_MODE_LEN                        10
#define MAX_PROJ_TYPE_LEN                       15
#define ATTR_CHUNKS                             15  /* # atts in data strct */
#define DATA_CHUNKS                              3  /* # data per attr */
#define DEFAULT_DATA_LENGTH                     30
#define RIS_CAT                                 32
#define NFM_CAT                                 42
#define CASH_SLOTS                               5  /* # cat names cashed */
#define FTR_ITEM_NUM                            66
#define FTR_FILE_NUM                            67
#define FTR_UNKNOWN                             -1
#define COMMENT_DELIMIT                        "#"
#define SECTION_DELIMIT                        "$"
#define RECORD_DELIMIT                         "$"
#define DIVISION_DELIMIT                       "%"
#define RR_KEY                                 '~'
#define RL_KEY                                 '*'
#define FTR_KEY                                '!'
#define RR_INDIC                               "\1"
#define RL_INDIC                               "\2"
#define FTR_INDIC                              "\3"
#define OP_CATALOG                             "catalog"
#define OP_PROJECT                             "project"
#define OP_ADD                                 "add"
#define OP_DELETE                              "delete"
#define OP_MODIFY                              "modify"
#define OP_CHECKIN                             "checkin"
#define OP_CHECKOUT                            "checkout"
#define OP_COPY                                "copy"
#define OP_SET                                 "set"
#define OP_CREATE_SET                          "create_set"
#define OP_SETIN                               "set_in"
#define OP_SETOUT                              "set_out"
#define OP_RISINSERT                           "RISinsert"
#define OP_RISDELETE                           "RISdelete"
#define OP_FTR_INDEX                           "ftr_index"
#define OP_RL_CHECKIN                          "redline checkin"
#define PRIMARY                                "primary"
#define SECONDARY                              "secondary"
#define OWNED                                  "owned"
#define REFERENCED                             "referenced"
#define P_SET_CATALOG                          "set_catalog"
#define P_SET_NAME                             "set_name"
#define P_SET_MODE                             "set_mode"
#define P_SET_REV                              "set_revision"
#define P_CATALOG                              "n_catalogname"
#define P_PROJECT                              "n_projectname"
#define P_ITEM_NAME                            "n_itemname"
#define P_ITEM_REV                             "n_itemrev"
#define P_ITEM_NO                              "n_itemno"
#define P_ITEM_NUM                             "n_itemnum"
#define P_FILE_NO                              "n_fileno"
#define P_FILE_VER                             "n_fileversion"
#define P_ACL_NO                               "n_aclno"
#define P_CO_SA                                "n_cosano"
#define P_CI_SA                                "n_cisano"
#define P_CO_FILE                              "n_cofilename"
#define P_CI_FILE                              "n_cifilename"
#define P_FILE_TYPE                            "n_filetype"
#define P_CO_COMM                              "n_cocomment"
#define P_CO_OUT                               "n_coout"
#define P_STATUS                               "n_status"
#define P_TYPE                                 "n_type"
#define P_UPDATE                               "n_update"
#define D_ITEM_NO                              "item_no"
#define D_FILE_NO                              "file_no"
#define D_FILE_VER                             "file_version"
#define D_MULT_PAGE                            "multi_page_no"
#define D_REDUCED                              "reduced_exist"
#define D_MIRROR                               "mirror_archive"
#define D_DESC                                 "description"
#define MAIL_FILE                              "/usr/tmp/.blk.mail"
