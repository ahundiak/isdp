/*  Types of operations and entities
    for PDMget_table_attributes and PDMget_table_data  */

#define ADD_TABLE     101
#define QUERY_TABLE   102
#define MODIFY_TABLE  103
#define DYNAMIC_TABLE 104
#define MODIFY_DYNAMIC_TABLE 105
#define COPY_DYNAMIC_TABLE 106

#define ADD_DATA      201
#define QUERY_DATA    202
#define MODIFY_DATA   203
#define QUERY_INFO    204

#define PDM_USER       301
#define PDM_PROJECT    302
#define PDM_LOC        303
#define PDM_CATALOG    304
#define PDM_DYNAMIC    312
#define PDM_CIT        305
#define PDM_BOMCONTENT 306
#define PDM_VIEWS      307
#define PDM_BOMS       308
#define PDM_LOGIN      309
#define PDM_PART       310
#define PDM_TRANSITION 311
/* added for drawing sheet support 1/29/92, MaC */
#define PDM_DRAW_CATALOG    313
#define PDM_DRAWING         314
/* added for parametric add part support 8/30/92, MaC */
#define PDM_PARAMETRIC_PART       315
#define PDM_REVIEW_PART_INFORMATION       316
