
int VDpdfGetRecDesc(int recNum, char *recDesc)
{
  int retFlag = 1;
  *recDesc = 0;
  recNum &= 0x3FFF;
  switch(recNum) {
  case 1001: strcpy(recDesc,"PDF_OBJ_ROOT"); break;
  case 1012: strcpy(recDesc,"PDF_ATR_OBJ_BEG"); break;
  case 1013: strcpy(recDesc,"PDF_ATR_OBJ_END"); break;
  case 1014: strcpy(recDesc,"PDF_ATR_OBJ_NAME"); break;
  case 1016: strcpy(recDesc,"PDF_ATR_ATR_BEG"); break;
  case 1018: strcpy(recDesc,"PDF_ATR_ATR_NAME"); break;
  case 1020: strcpy(recDesc,"PDF_ATR_ATR_DATA"); break;
  case 1101: strcpy(recDesc,"PDF_OBJ_SETUP"); break;
  case 1112: strcpy(recDesc,"PDF_ATR_SETUP_INTERNAL_UNITS"); break;
  case 1114: strcpy(recDesc,"PDF_ATR_SETUP_DATE"); break;
  case 1116: strcpy(recDesc,"PDF_ATR_SETUP_FILE_NAME"); break;
  case 1118: strcpy(recDesc,"PDF_ATR_SETUP_PDM_CAT"); break;
  case 1120: strcpy(recDesc,"PDF_ATR_SETUP_PDM_PART"); break;
  case 1122: strcpy(recDesc,"PDF_ATR_SETUP_PDM_REV"); break;
  case 1124: strcpy(recDesc,"PDF_ATR_SETUP_PDM_STATUS"); break;

  case 1126: strcpy(recDesc,"PDF_ATR_SETUP_PRE_TRANSLATE"); break;
   
  case 1201: strcpy(recDesc,"PDF_OBJ_SHIP"); break;
  case 1212: strcpy(recDesc,"PDF_ATR_SHIP_NAME"); break;
  case 1214: strcpy(recDesc,"PDF_ATR_SHIP_OWNER"); break;
  case 1216: strcpy(recDesc,"PDF_ATR_SHIP_HULL"); break;
  case 1218: strcpy(recDesc,"PDF_ATR_SHIP_HULL_APP"); break;
  case 1220: strcpy(recDesc,"PDF_ATR_SHIP_DIMENSIONS"); break;
  case 1222: strcpy(recDesc,"PDF_ATR_SHIP_GLOBAL_COORD_SYSTEM"); break;
  case 1224: strcpy(recDesc,"PDF_ATR_SHIP_FWD_PERPENDICULAR"); break;
  case 2000: strcpy(recDesc,"PDF_OBJ_PIECES"); break;
  case 2001: strcpy(recDesc,"PDF_OBJ_PIECE"); break;
  case 2012: strcpy(recDesc,"PDF_ATR_PIECE_MAT_GRADE"); break;
  case 2014: strcpy(recDesc,"PDF_ATR_PIECE_MAT_TYPE"); break;
  case 2016: strcpy(recDesc,"PDF_ATR_PIECE_FAMILY"); break;
  case 2018: strcpy(recDesc,"PDF_ATR_PIECE_PART_NUM"); break;
  case 2020: strcpy(recDesc,"PDF_ATR_PIECE_NAME"); break;
  case 2022: strcpy(recDesc,"PDF_ATR_PIECE_PCMK"); break;
  case 2024: strcpy(recDesc,"PDF_ATR_PIECE_UNIT"); break;
  case 2026: strcpy(recDesc,"PDF_ATR_PIECE_UNIT_PCMK"); break;
  case 2028: strcpy(recDesc,"PDF_ATR_PIECE_3D_REF_PTS"); break;
  case 2030: strcpy(recDesc,"PDF_ATR_PIECE_3D_MATRIX"); break;

  case 2046: strcpy(recDesc,"PDF_ATR_PIECE_RANGE");  break;
  case 2048: strcpy(recDesc,"PDF_ATR_PIECE_MATRIX"); break;

    // 09 Feb 2000, type = collar
  case 2032: strcpy(recDesc,"PDF_ATR_PIECE_PROD_TYPE"); break;

  case 2100: strcpy(recDesc,"PDF_OBJ_PLATES"); break;
  case 2101: strcpy(recDesc,"PDF_OBJ_PLATE"); break;
  case 2112: strcpy(recDesc,"PDF_ATR_PLATE_THICKNESS"); break;
  case 2114: strcpy(recDesc,"PDF_ATR_PLATE_EXPAND_MAJOR"); break;
  case 2116: strcpy(recDesc,"PDF_ATR_PLATE_EXPAND_MINOR"); break;
  case 2118: strcpy(recDesc,"PDF_ATR_PLATE_PLANE"); break;
  case 2120: strcpy(recDesc,"PDF_ATR_PLATE_MAT_DIR"); break;
  case 2122: strcpy(recDesc,"PDF_ATR_PLATE_FLIP"); break;
  case 2200: strcpy(recDesc,"PDF_OBJ_BEAMS"); break;
  case 2201: strcpy(recDesc,"PDF_OBJ_BEAM"); break;
  case 2212: strcpy(recDesc,"PDF_ATR_BEAM_WEB_3D"); break;
  case 2214: strcpy(recDesc,"PDF_ATR_BEAM_CUT_LENGTH"); break;
  case 2216: strcpy(recDesc,"PDF_ATR_BEAM_INV_BENDING_CURVE"); break;
  case 2218: strcpy(recDesc,"PDF_ATR_PIECE_PRIMARY_PROCESS"); break;
  case 2220: strcpy(recDesc,"PDF_ATR_PIECE_ADDITIONAL_PROCESS"); break;
  case 2222: strcpy(recDesc,"PDF_ATR_BEAM_CLOSED"); break;
  case 2301: strcpy(recDesc,"PDF_OBJ_PLATE_EDGE"); break;
  case 2312: strcpy(recDesc,"PDF_ATR_PLATE_EDGE_CURVE"); break;
  case 2314: strcpy(recDesc,"PDF_ATR_PLATE_EDGE_STOCK"); break;
  case 2316: strcpy(recDesc,"PDF_ATR_PLATE_EDGE_GAP"); break;
  case 2401: strcpy(recDesc,"PDF_OBJ_BEVEL"); break;
  case 2412: strcpy(recDesc,"PDF_ATR_BEVEL_SPEC"); break;
  case 2414: strcpy(recDesc,"PDF_ATR_BEVEL_EXTENT"); break;
  case 2416: strcpy(recDesc,"PDF_ATR_BEVEL_THICKNESS"); break;
  case 2418: strcpy(recDesc,"PDF_ATR_BEVEL_DATA"); break;
  case 2420: strcpy(recDesc,"PDF_ATR_BEVEL_CURVE"); break;
  case 2422: strcpy(recDesc,"PDF_ATR_BEVEL_PROCESS"); break;
  case 2501: strcpy(recDesc,"PDF_OBJ_BEAM_EDGE"); break;
  case 2601: strcpy(recDesc,"PDF_OBJ_JOINT"); break;
  case 2701: strcpy(recDesc,"PDF_OBJ_BEAM_ET"); break;
  case 2712: strcpy(recDesc,"PDF_ATR_BEAM_ET_INFO"); break;
  case 2714: strcpy(recDesc,"PDF_ATR_BEAM_ET_TYPE"); break;
  case 2716: strcpy(recDesc,"PDF_ATR_BEAM_ET_WEB_ANGLE"); break;
  case 2718: strcpy(recDesc,"PDF_ATR_BEAM_ET_FLANGE_ANGLE"); break;
  case 2720: strcpy(recDesc,"PDF_ATR_BEAM_ET_STOCK"); break;
  case 2722: strcpy(recDesc,"PDF_ATR_BEAM_ET_BENDING_STOCK"); break;
  case 2724: strcpy(recDesc,"PDF_ATR_BEAM_ET_WEB_CURVE"); break;
  case 2726: strcpy(recDesc,"PDF_ATR_BEAM_ET_FLANGE_CURVE"); break;
  case 2801: strcpy(recDesc,"PDF_OBJ_HOLE"); break;
  case 2812: strcpy(recDesc,"PDF_ATR_HOLE_ID"); break;
  case 2814: strcpy(recDesc,"PDF_ATR_HOLE_TYPE"); break;
  case 2816: strcpy(recDesc,"PDF_ATR_HOLE_CURVE"); break;
  case 2818: strcpy(recDesc,"PDF_ATR_HOLE_TAB"); break;
  case 2820: strcpy(recDesc,"PDF_ATR_HOLE_VECTOR"); break;
  case 2822: strcpy(recDesc,"PDF_ATR_HOLE_NOTES"); break;
  case 2824: strcpy(recDesc,"PDF_ATR_HOLE_FACE_BAR"); break;
  case 2826: strcpy(recDesc,"PDF_ATR_HOLE_LOCATION"); break;
  case 2901: strcpy(recDesc,"PDF_OBJ_MARKING_LINE"); break;
  case 2912: strcpy(recDesc,"PDF_ATR_MARKING_LINE_TYPE"); break;
  case 2914: strcpy(recDesc,"PDF_ATR_MARKING_LINE_CURVE"); break;
  case 2915: strcpy(recDesc,"PDF_ATR_MARKING_LINE_MTL_POINT"); break;
  case 2916: strcpy(recDesc,"PDF_ATR_MARKING_LINE_MTL_SURFACE"); break;
  case 2918: strcpy(recDesc,"PDF_ATR_KNUCKLE_LINE"); break;
  case 2920: strcpy(recDesc,"PDF_ATR_KNUCKLE_ANGLE"); break;
  case 3001: strcpy(recDesc,"PDF_OBJ_LABEL"); break;
  case 3012: strcpy(recDesc,"PDF_ATR_LABEL_TEXT"); break;
  case 3014: strcpy(recDesc,"PDF_ATR_LABEL_TYPE"); break;
  case 3016: strcpy(recDesc,"PDF_ATR_LABEL_LOCATION"); break;
  case 3018: strcpy(recDesc,"PDF_ATR_LABEL_HEIGHT_WIDTH"); break;
  case 3101: strcpy(recDesc,"PDF_OBJ_CUTOUT"); break;
  case 3112: strcpy(recDesc,"PDF_ATR_CUTOUT_TYPE"); break;
  case 3114: strcpy(recDesc,"PDF_ATR_CUTOUT_DATA"); break;
  case 3116: strcpy(recDesc,"PDF_ATR_CUTOUT_LOCATION"); break;
  case 3118: strcpy(recDesc,"PDF_ATR_CUTOUT_VECTOR_EXPANSION"); break;
  case 4001: strcpy(recDesc,"PDF_OBJ_TREE"); break;

  case 4012: strcpy(recDesc,"PDF_ATR_TREE_NAME"); break;
  case 4014: strcpy(recDesc,"PDF_ATR_TREE_REV");  break;

  case 4101: strcpy(recDesc,"PDF_OBJ_TREE_NODE"); break;
  case 4112: strcpy(recDesc,"PDF_ATR_TREE_NODE_TYPE"); break;
  case 4114: strcpy(recDesc,"PDF_ATR_TREE_NODE_NAME"); break;
  case 4116: strcpy(recDesc,"PDF_ATR_TREE_NODE_PATH"); break;
  case 4118: strcpy(recDesc,"PDF_ATR_TREE_NODE_DESC"); break;
  case 4120: strcpy(recDesc,"PDF_ATR_TREE_NODE_PARENT"); break;
  case 4122: strcpy(recDesc,"PDF_ATR_TREE_NODE_STAGE"); break;
  case 4124: strcpy(recDesc,"PDF_ATR_TREE_NODE_UNIT"); break;
  case 4126: strcpy(recDesc,"PDF_ATR_TREE_NODE_PCMK"); break;
  case 4128: strcpy(recDesc,"PDF_ATR_TREE_NODE_UNIT_PCMK"); break;
  case 4130: strcpy(recDesc,"PDF_ATR_TREE_NODE_PLATEN"); break;
  case 4132: strcpy(recDesc,"PDF_ATR_TREE_NODE_QTY"); break;
  case 4134: strcpy(recDesc,"PDF_ATR_TREE_NODE_NOTES"); break;
  case 4136: strcpy(recDesc,"PDF_ATR_TREE_NODE_SEQUENCE"); break;
  case 4138: strcpy(recDesc,"PDF_ATR_TREE_NODE_DESTINATION"); break;
  case 4140: strcpy(recDesc,"PDF_ATR_TREE_NODE_NOTES2"); break;
  case 4142: strcpy(recDesc,"PDF_ATR_TREE_NODE_NOTES3"); break;
  case 4144: strcpy(recDesc,"PDF_ATR_TREE_NODE_NOTES4"); break;
  case 4146: strcpy(recDesc,"PDF_ATR_TREE_NODE_NOTES5"); break;
  default: retFlag = 0;
  }
wrapup:
  return retFlag;
}


