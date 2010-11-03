/* This file is generated from an access database.  
 * Hence no pinnacle header
 */
#define   PDF_DT_TEXT                            2          
#define   PDF_DT_INT                             4          
#define   PDF_DT_INTS                            5          
#define   PDF_DT_REAL                            6          
#define   PDF_DT_REALS                           7          
#define   PDF_DT_2D_PT                           18         
#define   PDF_DT_2D_PTS                          19         
#define   PDF_DT_2D_LINE_ARC                     20         
#define   PDF_DT_2D_BSPLINE                      22         
#define   PDF_DT_2D_CIRCLE                       24         
#define   PDF_DT_2D_OVAL                         26         
#define   PDF_DT_2D_RECT                         28         
#define   PDF_DT_2D_RECT_RND                     29         
#define   PDF_DT_2D_ELLIPSE                      30         
#define   PDF_DT_3D_PT                           34         
#define   PDF_DT_3D_PTS                          35         
#define   PDF_OBJ_ROOT                           1001       
#define   PDF_ATR_OBJ_BEG                        1012       
#define   PDF_ATR_OBJ_END                        1013       
#define   PDF_ATR_OBJ_NAME                       1014       
#define   PDF_ATR_ATR_BEG                        1016       
#define   PDF_ATR_ATR_NAME                       1018       
#define   PDF_ATR_ATR_DATA                       1020       

#define   PDF_OBJ_SETUP                          1101       
#define   PDF_ATR_SETUP_INTERNAL_UNITS           1112       
#define   PDF_ATR_SETUP_DATE                     1114       
#define   PDF_ATR_SETUP_FILE_NAME                1116       
#define   PDF_ATR_SETUP_PDM_CAT                  1118       
#define   PDF_ATR_SETUP_PDM_PART                 1120       
#define   PDF_ATR_SETUP_PDM_REV                  1122       
#define   PDF_ATR_SETUP_PDM_STATUS               1124       
/* -----------------------------------------------
 * 15 Sep 2000 Add some data control
 */
#define   PDF_ATR_SETUP_PRE_TRANSLATE            1126
#define   PDF_ATR_SETUP_MODEL_REV                1128
#define   PDF_ATR_SETUP_HOLE_REV                 1130
#define   PDF_ATR_SETUP_TREE_REV                 1132
#define   PDF_ATR_SETUP_LOFT_REV                 1134


#define   PDF_OBJ_SHIP                           1201       
#define   PDF_ATR_SHIP_NAME                      1212       
#define   PDF_ATR_SHIP_OWNER                     1214       
#define   PDF_ATR_SHIP_HULL                      1216       
#define   PDF_ATR_SHIP_HULL_APP                  1218       
#define   PDF_ATR_SHIP_DIMENSIONS                1220       
#define   PDF_ATR_SHIP_GLOBAL_COORD_SYSTEM       1222       
#define   PDF_ATR_SHIP_FWD_PERPENDICULAR         1224
       
#define   PDF_OBJ_PIECES                         2000       
#define   PDF_OBJ_PIECE                          2001       
#define   PDF_ATR_PIECE_MAT_GRADE                2012       
#define   PDF_ATR_PIECE_MAT_TYPE                 2014       
#define   PDF_ATR_PIECE_FAMILY                   2016       
#define   PDF_ATR_PIECE_PART_NUM                 2018       
#define   PDF_ATR_PIECE_NAME                     2020       
#define   PDF_ATR_PIECE_PCMK                     2022       
#define   PDF_ATR_PIECE_UNIT                     2024       
#define   PDF_ATR_PIECE_UNIT_PCMK                2026       
#define   PDF_ATR_PIECE_3D_REF_PTS               2028       
#define   PDF_ATR_PIECE_3D_MATRIX                2030       
#define   PDF_ATR_PIECE_PROD_TYPE                2032       
#define   PDF_ATR_PIECE_FAB_DATA_NEST            2034       
#define   PDF_ATR_PIECE_FAB_DATA_SERVO           2036       
#define   PDF_ATR_PIECE_FAB_DATA_TEMP            2038       
#define   PDF_ATR_PIECE_FAB_DATA_NOTEMP          2040       
#define   PDF_ATR_PIECE_FAB_DATA_SKETCH          2042       
#define   PDF_ATR_PIECE_FAB_DATA_BEAMLINE        2044       
#define   PDF_ATR_PIECE_RANGE                    2046       
#define   PDF_ATR_PIECE_MATRIX                   2048       
#define   PDF_OBJ_PLATES                         2100       
#define   PDF_OBJ_PLATE                          2101       
#define   PDF_ATR_PLATE_THICKNESS                2112       
#define   PDF_ATR_PLATE_EXPAND_MAJOR             2114       
#define   PDF_ATR_PLATE_EXPAND_MINOR             2116       
#define   PDF_ATR_PLATE_PLANE                    2118       
#define   PDF_ATR_PLATE_MAT_DIR                  2120       
#define   PDF_ATR_PLATE_FLIP                     2122       
#define   PDF_OBJ_BEAMS                          2200       
#define   PDF_OBJ_BEAM                           2201       
#define   PDF_ATR_BEAM_WEB_3D                    2212       
#define   PDF_ATR_BEAM_CUT_LENGTH                2214       
#define   PDF_ATR_BEAM_INV_BENDING_CURVE         2216       
#define   PDF_ATR_BEAM_PRIMARY_PROCESS           2218       
#define   PDF_ATR_BEAM_ADDITIONAL_PROCESS        2220       
#define   PDF_ATR_BEAM_CLOSED                    2222       
#define   PDF_OBJ_PLATE_EDGE                     2301       
#define   PDF_ATR_PLATE_EDGE_CURVE               2312       
#define   PDF_ATR_PLATE_EDGE_STOCK               2314       
#define   PDF_ATR_PLATE_EDGE_GAP                 2316       
#define   PDF_OBJ_BEVEL                          2401       
#define   PDF_ATR_BEVEL_SPEC                     2412       
#define   PDF_ATR_BEVEL_EXTENT                   2414       
#define   PDF_ATR_BEVEL_THICKNESS                2416       
#define   PDF_ATR_BEVEL_DATA                     2418       
#define   PDF_ATR_BEVEL_CURVE                    2420       
#define   PDF_ATR_BEVEL_PROCESS                  2422       
#define   PDF_OBJ_BEAM_EDGE                      2501       
#define   PDF_OBJ_JOINT                          2601       
#define   PDF_OBJ_BEAM_ET                        2701       
#define   PDF_ATR_BEAM_ET_INFO                   2712       
#define   PDF_ATR_BEAM_ET_TYPE                   2714       
#define   PDF_ATR_BEAM_ET_WEB_ANGLE              2716       
#define   PDF_ATR_BEAM_ET_FLANGE_ANGLE           2718       
#define   PDF_ATR_BEAM_ET_STOCK                  2720       
#define   PDF_ATR_BEAM_ET_BENDING_STOCK          2722       
#define   PDF_ATR_BEAM_ET_WEB_CURVE              2724       
#define   PDF_ATR_BEAM_ET_WEB_FLANGE             2726       
#define   PDF_OBJ_HOLE                           2801       
#define   PDF_ATR_HOLE_ID                        2812       
#define   PDF_ATR_HOLE_TYPE                      2814       
#define   PDF_ATR_HOLE_CURVE                     2816       
#define   PDF_ATR_HOLE_TAB                       2818       
#define   PDF_ATR_HOLE_VECTOR                    2820       
#define   PDF_ATR_HOLE_NOTES                     2822       
#define   PDF_ATR_HOLE_FACE_BAR                  2824       
#define   PDF_ATR_HOLE_LOCATION                  2826       
#define   PDF_OBJ_MARKING_LINE                   2901       
#define   PDF_ATR_MARKING_LINE_TYPE              2912       
#define   PDF_ATR_MARKING_LINE_CURVE             2914       
#define   PDF_ATR_MARKING_LINE_MTL_POINT         2915       
#define   PDF_ATR_MARKING_LINE_MTL_SURFACE       2916       
#define   PDF_ATR_KNUCKLE_LINE                   2918       
#define   PDF_ATR_KNUCKLE_ANGLE                  2920       
#define   PDF_OBJ_LABEL                          3001       
#define   PDF_ATR_LABEL_TEXT                     3012       
#define   PDF_ATR_LABEL_TYPE                     3014       
#define   PDF_ATR_LABEL_LOCATION                 3016       
#define   PDF_ATR_LABEL_HEIGHT_WIDTH             3018       
#define   PDF_OBJ_CUTOUT                         3101       
#define   PDF_ATR_CUTOUT_TYPE                    3112       
#define   PDF_ATR_CUTOUT_DATA                    3114       
#define   PDF_ATR_CUTOUT_LOCATION                3116       
#define   PDF_ATR_CUTOUT_VECTOR_EXPANSION        3118   
    
#define   PDF_OBJ_TREE                           4001       
#define   PDF_ATR_TREE_NAME                      4012  

/* -----------------------------------------------
 * Tree Rev Control
 */     
#define   PDF_ATR_TREE_REV                       4014

#define   PDF_OBJ_TREE_NODE                      4101       
#define   PDF_ATR_TREE_NODE_TYPE                 4112       
#define   PDF_ATR_TREE_NODE_NAME                 4114       
#define   PDF_ATR_TREE_NODE_PATH                 4116       
#define   PDF_ATR_TREE_NODE_DESC                 4118       
#define   PDF_ATR_TREE_NODE_PARENT               4120       
#define   PDF_ATR_TREE_NODE_STAGE                4122       
#define   PDF_ATR_TREE_NODE_UNIT                 4124       
#define   PDF_ATR_TREE_NODE_PCMK                 4126       
#define   PDF_ATR_TREE_NODE_UNIT_PCMK            4128       
#define   PDF_ATR_TREE_NODE_PLATEN               4130       
#define   PDF_ATR_TREE_NODE_QTY                  4132       
#define   PDF_ATR_TREE_NODE_NOTES                4134       
#define   PDF_ATR_TREE_NODE_SEQUENCE             4136       
#define   PDF_ATR_TREE_NODE_DESTINATION          4138 
      
#define   PDF_ATR_TREE_NODE_NOTES2               4140       
#define   PDF_ATR_TREE_NODE_NOTES3               4142      
#define   PDF_ATR_TREE_NODE_NOTES4               4144      
#define   PDF_ATR_TREE_NODE_NOTES5               4146      