#define CMD_UPDATE                              0x01000000  /* VIEWIMMEDIATE */ 
#define CMD_UPDATE_1                            0x01010000  /* VIEWIMMEDIATE */ 
#define CMD_UPDATE_2                            0x01020000  /* VIEWIMMEDIATE */ 
#define CMD_UPDATE_3                            0x01030000  /* VIEWIMMEDIATE */ 
#define CMD_UPDATE_4                            0x01040000  /* VIEWIMMEDIATE */ 
#define CMD_UPDATE_5                            0x01050000  /* VIEWIMMEDIATE */ 
#define CMD_UPDATE_6                            0x01060000  /* VIEWIMMEDIATE */ 
#define CMD_UPDATE_7                            0x01070000  /* VIEWIMMEDIATE */ 
#define CMD_UPDATE_8                            0x01080000  /* VIEWIMMEDIATE */ 
#define CMD_UPDATE_RIGHT                        0x01090000  /* VIEWIMMEDIATE */ 
#define CMD_UPDATE_LEFT                         0x010a0000  /* VIEWIMMEDIATE */ 
#define CMD_UPDATE_BOTH                         0x010b0000  /* VIEWIMMEDIATE */ 
#define CMD_UPDATE_ALL                          0x010b0000  /* VIEWIMMEDIATE */ 
#define CMD_UPDATE_VIEW                         0x010c0000  /* VIEWING */ 
#define CMD_UPDATE_GRID                         0x010d0000  /* VIEWIMMEDIATE */ 
#define CMD_UPDATE_FILE                         0x010e0000  /* VIEWING */ 
#define CMD_UPDATE_TUTORIAL                     0x010f0000  /* VIEWIMMEDIATE */ 
#define CMD_UPDATE_REFERENCE                    0x01100000  /* VIEWING */ 
#define CMD_UPDATE_FENCE                        0x01110000  /* VIEWIMMEDIATE */ 
#define CMD_UPDATE_FENCE_INSIDE                 0x01110100  /* VIEWIMMEDIATE */ 
#define CMD_UPDATE_FENCE_OUTSIDE                0x01110200  /* VIEWIMMEDIATE */ 
#define CMD_FIT                                 0x02000000  /* VIEWING */ 
#define CMD_FIT_ACTIVE                          0x02010000  /* VIEWING */ 
#define CMD_FIT_REFERENCE                       0x02020000  /* VIEWING */ 
#define CMD_FIT_ALL                             0x02030000  /* VIEWING */ 
#define CMD_WINDOW                              0x03000000  /* VIEWING */ 
#define CMD_WINDOW_AREA                         0x03010000  /* VIEWING */ 
#define CMD_WINDOW_CENTER                       0x03020000  /* VIEWING */ 
#define CMD_WINDOW_ORIGIN                       0x03030000  /* VIEWING */ 
#define CMD_WINDOW_VOLUME                       0x03040000  /* VIEWING */ 
#define CMD_WINDOW_BACK                         0x03050000  /* WINDOWMAN */ 
#define CMD_WINDOW_FRONT                        0x03060000  /* WINDOWMAN */ 
#define CMD_WINDOW_MOVE                         0x03070000  /* WINDOWMAN */ 
#define CMD_WINDOW_MOVE_TLCORNER                0x03070100  /* WINDOWMAN */ 
#define CMD_WINDOW_MOVE_TOPEDGE                 0x03070200  /* WINDOWMAN */ 
#define CMD_WINDOW_MOVE_TRCORNER                0x03070300  /* WINDOWMAN */ 
#define CMD_WINDOW_MOVE_RIGHTEDGE               0x03070400  /* WINDOWMAN */ 
#define CMD_WINDOW_MOVE_BRCORNER                0x03070500  /* WINDOWMAN */ 
#define CMD_WINDOW_MOVE_BTMEDGE                 0x03070600  /* WINDOWMAN */ 
#define CMD_WINDOW_MOVE_BLCORNER                0x03070700  /* WINDOWMAN */ 
#define CMD_WINDOW_MOVE_LEFTEDGE                0x03070800  /* WINDOWMAN */ 
#define CMD_WINDOW_MOVE_ALLCORNERS              0x03070900  /* WINDOWMAN */ 
#define CMD_WINDOW_CLOSE                        0x03080000  /* WINDOWMAN */ 
#define CMD_WINDOW_SINK                         0x03090000  /* WINDOWMAN */ 
#define CMD_WINDOW_CASCADE                      0x030a0000  /* WINDOWMAN */ 
#define CMD_WINDOW_TILE                         0x030b0000  /* WINDOWMAN */ 
#define CMD_WINDOW_BOTTOMTOTOP                  0x030c0000  /* WINDOWMAN */ 
#define CMD_WINDOW_RESTORE                      0x030d0000  /* WINDOWMAN */ 
#define CMD_WINDOW_MINIMIZE                     0x030e0000  /* WINDOWMAN */ 
#define CMD_WINDOW_MAXIMIZE                     0x030f0000  /* WINDOWMAN */ 
#define CMD_ZOOM                                0x04000000  /* VIEWING */ 
#define CMD_ZOOM_IN                             0x04010000  /* VIEWING */ 
#define CMD_ZOOM_IN_CENTER                      0x04010100  /* VIEWING */ 
#define CMD_ZOOM_OUT                            0x04020000  /* VIEWING */ 
#define CMD_ZOOM_OUT_CENTER                     0x04020100  /* VIEWING */ 
#define CMD_MOVE                                0x05000000  /* VIEWING */ 
#define CMD_MOVE_LEFT                           0x05010000  /* VIEWING */ 
#define CMD_MOVE_RIGHT                          0x05020000  /* VIEWING */ 
#define CMD_MOVE_UP                             0x05030000  /* VIEWING */ 
#define CMD_MOVE_DOWN                           0x05040000  /* VIEWING */ 
#define CMD_MOVE_ELEMENT                        0x05050000  /* MANIPULATION */ 
#define CMD_MOVE_FENCE                          0x05060000  /* FENCE */ 
#define CMD_MOVE_ACS                            0x05070000  /* VIEWING */ 
#define CMD_MOVE_PARALLEL                       0x05080000  /* MANIPULATION */ 
#define CMD_MOVE_PARALLEL_DISTANCE              0x05080100  /* MANIPULATION */ 
#define CMD_MOVE_PARALLEL_KEYIN                 0x05080200  /* MANIPULATION */ 
#define CMD_SET                                 0x06000000  /* PARAMETERS */ 
#define CMD_SET_LEVELS                          0x06010000  /* VIEWPARAM */ 
#define CMD_SET_LEVELS_ON                       0x06010100  /* VIEWPARAM */ 
#define CMD_SET_LEVELS_OFF                      0x06010200  /* VIEWPARAM */ 
#define CMD_SET_LEVELS_TOGGLE                   0x06010300  /* VIEWPARAM */ 
#define CMD_SET_TEXT                            0x06020000  /* VIEWPARAM */ 
#define CMD_SET_TEXT_ON                         0x06020100  /* VIEWPARAM */ 
#define CMD_SET_TEXT_OFF                        0x06020200  /* VIEWPARAM */ 
#define CMD_SET_TEXT_FAST                       0x06020300  /* VIEWPARAM */ 
#define CMD_SET_TEXT_SLOW                       0x06020400  /* VIEWPARAM */ 
#define CMD_SET_TEXT_TOGGLE                     0x06020500  /* VIEWPARAM */ 
#define CMD_SET_TEXT_MODE                       0x06020600  /* VIEWPARAM */ 
#define CMD_SET_TEXT_MODE_ON                    0x06020610  /* VIEWPARAM */ 
#define CMD_SET_TEXT_MODE_OFF                   0x06020620  /* VIEWPARAM */ 
#define CMD_SET_TEXT_MODE_TOGGLE                0x06020630  /* VIEWPARAM */ 
#define CMD_SET_ED                              0x06030000  /* VIEWPARAM */ 
#define CMD_SET_ED_ON                           0x06030100  /* VIEWPARAM */ 
#define CMD_SET_ED_OFF                          0x06030200  /* VIEWPARAM */ 
#define CMD_SET_ED_TOGGLE                       0x06030300  /* VIEWPARAM */ 
#define CMD_SET_GRID                            0x06050000  /* VIEWPARAM */ 
#define CMD_SET_GRID_ON                         0x06050100  /* VIEWPARAM */ 
#define CMD_SET_GRID_OFF                        0x06050200  /* VIEWPARAM */ 
#define CMD_SET_GRID_TOGGLE                     0x06050300  /* VIEWPARAM */ 
#define CMD_SET_CURVES                          0x06070000  /* VIEWPARAM */ 
#define CMD_SET_CURVES_ON                       0x06070100  /* VIEWPARAM */ 
#define CMD_SET_CURVES_OFF                      0x06070200  /* VIEWPARAM */ 
#define CMD_SET_CURVES_FAST                     0x06070300  /* VIEWPARAM */ 
#define CMD_SET_CURVES_SLOW                     0x06070400  /* VIEWPARAM */ 
#define CMD_SET_CURVES_TOGGLE                   0x06070500  /* VIEWPARAM */ 
#define CMD_SET_CURVES_MODE                     0x06070600  /* VIEWPARAM */ 
#define CMD_SET_CURVES_MODE_ON                  0x06070610  /* VIEWPARAM */ 
#define CMD_SET_CURVES_MODE_OFF                 0x06070620  /* VIEWPARAM */ 
#define CMD_SET_CURVES_MODE_TOGGLE              0x06070630  /* VIEWPARAM */ 
#define CMD_SET_PROMPT                          0x06080000  /* PARAMETERS */ 
#define CMD_SET_TPMODE                          0x06090000  /* PARAMETERS */ 
#define CMD_SET_TPMODE_LOCATE                   0x06090100  /* PARAMETERS */ 
#define CMD_SET_TPMODE_DELTA                    0x06090200  /* PARAMETERS */ 
#define CMD_SET_TPMODE_DISTANCE                 0x06090400  /* PARAMETERS */ 
#define CMD_SET_TPMODE_ANGLE2                   0x06090400  /* PARAMETERS */ 
#define CMD_SET_TPMODE_VDELTA                   0x06090500  /* PARAMETERS */ 
#define CMD_SET_TPMODE_ACSLOCATE                0x06090600  /* PARAMETERS */ 
#define CMD_SET_TPMODE_ACSDELTA                 0x06090700  /* PARAMETERS */ 
#define CMD_SET_FUNCTION                        0x060a0000  /* PARAMETERS */ 
#define CMD_SET_RANGE                           0x060b0000  /* PARAMETERS */ 
#define CMD_SET_RANGE_ON                        0x060b0100  /* PARAMETERS */ 
#define CMD_SET_RANGE_OFF                       0x060b0200  /* PARAMETERS */ 
#define CMD_SET_RANGE_TOGGLE                    0x060b0300  /* PARAMETERS */ 
#define CMD_SET_DDEPTH                          0x060c0000  /* VIEWPARAM */ 
#define CMD_SET_DDEPTH_ABSOLUTE                 0x060c0100  /* VIEWPARAM */ 
#define CMD_SET_DDEPTH_RELATIVE                 0x060c0200  /* VIEWPARAM */ 
#define CMD_SET_DYNAMIC                         0x060d0000  /* VIEWPARAM */ 
#define CMD_SET_DYNAMIC_ON                      0x060d0100  /* VIEWPARAM */ 
#define CMD_SET_DYNAMIC_OFF                     0x060d0200  /* VIEWPARAM */ 
#define CMD_SET_DYNAMIC_FAST                    0x060d0300  /* VIEWPARAM */ 
#define CMD_SET_DYNAMIC_SLOW                    0x060d0400  /* VIEWPARAM */ 
#define CMD_SET_DYNAMIC_TOGGLE                  0x060d0500  /* VIEWPARAM */ 
#define CMD_SET_DYNAMIC_MODE                    0x060d0600  /* VIEWPARAM */ 
#define CMD_SET_DYNAMIC_MODE_ON                 0x060d0610  /* VIEWPARAM */ 
#define CMD_SET_DYNAMIC_MODE_OFF                0x060d0620  /* VIEWPARAM */ 
#define CMD_SET_DYNAMIC_MODE_TOGGLE             0x060d0630  /* VIEWPARAM */ 
#define CMD_SET_PATTERN                         0x060e0000  /* VIEWPARAM */ 
#define CMD_SET_PATTERN_ON                      0x060e0100  /* VIEWPARAM */ 
#define CMD_SET_PATTERN_OFF                     0x060e0200  /* VIEWPARAM */ 
#define CMD_SET_PATTERN_TOGGLE                  0x060e0300  /* VIEWPARAM */ 
#define CMD_SET_CONSTRUCT                       0x060f0000  /* VIEWPARAM */ 
#define CMD_SET_CONSTRUCT_ON                    0x060f0100  /* VIEWPARAM */ 
#define CMD_SET_CONSTRUCT_OFF                   0x060f0200  /* VIEWPARAM */ 
#define CMD_SET_CONSTRUCT_TOGGLE                0x060f0300  /* VIEWPARAM */ 
#define CMD_SET_DIMENSION                       0x06100000  /* VIEWPARAM */ 
#define CMD_SET_DIMENSION_ON                    0x06100100  /* VIEWPARAM */ 
#define CMD_SET_DIMENSION_OFF                   0x06100200  /* VIEWPARAM */ 
#define CMD_SET_DIMENSION_TOGGLE                0x06100300  /* VIEWPARAM */ 
#define CMD_SET_WEIGHT                          0x06120000  /* VIEWPARAM */ 
#define CMD_SET_WEIGHT_ON                       0x06120100  /* VIEWPARAM */ 
#define CMD_SET_WEIGHT_OFF                      0x06120200  /* VIEWPARAM */ 
#define CMD_SET_WEIGHT_TOGGLE                   0x06120300  /* VIEWPARAM */ 
#define CMD_SET_NODES                           0x06130000  /* VIEWPARAM */ 
#define CMD_SET_NODES_ON                        0x06130100  /* VIEWPARAM */ 
#define CMD_SET_NODES_OFF                       0x06130200  /* VIEWPARAM */ 
#define CMD_SET_NODES_TOGGLE                    0x06130300  /* VIEWPARAM */ 
#define CMD_SET_HILITE                          0x06150000  /* PARAMETERS */ 
#define CMD_SET_HILITE_BLACK                    0x06150100  /* PARAMETERS */ 
#define CMD_SET_HILITE_BLUE                     0x06150200  /* PARAMETERS */ 
#define CMD_SET_HILITE_GREEN                    0x06150300  /* PARAMETERS */ 
#define CMD_SET_HILITE_CYAN                     0x06150400  /* PARAMETERS */ 
#define CMD_SET_HILITE_RED                      0x06150500  /* PARAMETERS */ 
#define CMD_SET_HILITE_MAGENTA                  0x06150600  /* PARAMETERS */ 
#define CMD_SET_HILITE_YELLOW                   0x06150700  /* PARAMETERS */ 
#define CMD_SET_HILITE_WHITE                    0x06150800  /* PARAMETERS */ 
#define CMD_SET_HILITE_LGREY                    0x06150900  /* PARAMETERS */ 
#define CMD_SET_HILITE_DGREY                    0x06150a00  /* PARAMETERS */ 
#define CMD_SET_FONT                            0x06160000  /* VIEWPARAM */ 
#define CMD_SET_FONT_ON                         0x06160100  /* VIEWPARAM */ 
#define CMD_SET_FONT_OFF                        0x06160200  /* VIEWPARAM */ 
#define CMD_SET_FONT_FAST                       0x06160300  /* VIEWPARAM */ 
#define CMD_SET_FONT_SLOW                       0x06160400  /* VIEWPARAM */ 
#define CMD_SET_FONT_TOGGLE                     0x06160500  /* VIEWPARAM */ 
#define CMD_SET_FONT_MODE                       0x06160600  /* VIEWPARAM */ 
#define CMD_SET_FONT_MODE_ON                    0x06160610  /* VIEWPARAM */ 
#define CMD_SET_FONT_MODE_OFF                   0x06160620  /* VIEWPARAM */ 
#define CMD_SET_FONT_MODE_TOGGLE                0x06160630  /* VIEWPARAM */ 
#define CMD_SET_MIRTEXT                         0x06170000  /* PARAMETERS */ 
#define CMD_SET_MIRTEXT_ON                      0x06170100  /* PARAMETERS */ 
#define CMD_SET_MIRTEXT_OFF                     0x06170200  /* PARAMETERS */ 
#define CMD_SET_MIRTEXT_TOGGLE                  0x06170300  /* PARAMETERS */ 
#define CMD_SET_DATABASE                        0x06180000  /* PARAMETERS */ 
#define CMD_SET_STREAM                          0x06190000  /* PARAMETERS */ 
#define CMD_SET_STREAM_ON                       0x06190100  /* PARAMETERS */ 
#define CMD_SET_STREAM_OFF                      0x06190200  /* PARAMETERS */ 
#define CMD_SET_STREAM_TOGGLE                   0x06190300  /* PARAMETERS */ 
#define CMD_SET_BUTTON                          0x061a0000  /* PARAMETERS */ 
#define CMD_SET_DELETE                          0x061b0000  /* PARAMETERS */ 
#define CMD_SET_DELETE_ON                       0x061b0100  /* PARAMETERS */ 
#define CMD_SET_DELETE_OFF                      0x061b0200  /* PARAMETERS */ 
#define CMD_SET_DELETE_TOGGLE                   0x061b0300  /* PARAMETERS */ 
#define CMD_SET_CONTROL                         0x061c0000  /* PARAMETERS */ 
#define CMD_SET_TASKSIZE                        0x061d0000  /* PARAMETERS */ 
#define CMD_SET_TASKSIZE_CONVENTIONAL           0x061d0100  /* PARAMETERS */ 
#define CMD_SET_TASKSIZE_EXTENDED               0x061d0200  /* PARAMETERS */ 
#define CMD_SET_STACKFRACTIONS                  0x061f0000  /* PARAMETERS */ 
#define CMD_SET_STACKFRACTIONS_ON               0x061f0100  /* PARAMETERS */ 
#define CMD_SET_STACKFRACTIONS_OFF              0x061f0200  /* PARAMETERS */ 
#define CMD_SET_STACKFRACTIONS_TOGGLE           0x061f0300  /* PARAMETERS */ 
#define CMD_SET_TUTVIEW                         0x06200000  /* VIEWPARAM */ 
#define CMD_SET_OVERVIEW                        0x06210000  /* PARAMETERS */ 
#define CMD_SET_OVERVIEW_ON                     0x06210100  /* PARAMETERS */ 
#define CMD_SET_OVERVIEW_OFF                    0x06210200  /* PARAMETERS */ 
#define CMD_SET_OVERVIEW_TOGGLE                 0x06210300  /* PARAMETERS */ 
#define CMD_SET_OVERVIEW_RIGHT                  0x06210400  /* PARAMETERS */ 
#define CMD_SET_OVERVIEW_LEFT                   0x06210500  /* PARAMETERS */ 
#define CMD_SET_LVLSYMB                         0x06220000  /* VIEWPARAM */ 
#define CMD_SET_LVLSYMB_ON                      0x06220100  /* VIEWPARAM */ 
#define CMD_SET_LVLSYMB_OFF                     0x06220200  /* VIEWPARAM */ 
#define CMD_SET_LVLSYMB_TOGGLE                  0x06220300  /* VIEWPARAM */ 
#define CMD_SET_LINEWIDTH                       0x06230000  /* PARAMETERS */ 
#define CMD_SET_LINEWIDTH_ON                    0x06230100  /* PARAMETERS */ 
#define CMD_SET_LINEWIDTH_OFF                   0x06230200  /* PARAMETERS */ 
#define CMD_SET_LINEWIDTH_TOGGLE                0x06230300  /* PARAMETERS */ 
#define CMD_SET_LINEFILL                        0x06240000  /* VIEWPARAM */ 
#define CMD_SET_LINEFILL_ON                     0x06240100  /* VIEWPARAM */ 
#define CMD_SET_LINEFILL_OFF                    0x06240200  /* VIEWPARAM */ 
#define CMD_SET_LINEFILL_TOGGLE                 0x06240300  /* VIEWPARAM */ 
#define CMD_SET_FILL                            0x06240000  /* VIEWPARAM */ 
#define CMD_SET_FILL_ON                         0x06240100  /* VIEWPARAM */ 
#define CMD_SET_FILL_OFF                        0x06240200  /* VIEWPARAM */ 
#define CMD_SET_FILL_TOGGLE                     0x06240300  /* VIEWPARAM */ 
#define CMD_SET_CURSOR                          0x06250000  /* PARAMETERS */ 
#define CMD_SET_CURSOR_SMALL                    0x06250100  /* PARAMETERS */ 
#define CMD_SET_CURSOR_FULL                     0x06250200  /* PARAMETERS */ 
#define CMD_SET_CURSOR_TOGGLE                   0x06250300  /* PARAMETERS */ 
#define CMD_SET_CURSOR_ORTHOGONAL               0x06250400  /* PARAMETERS */ 
#define CMD_SET_CURSOR_ISOMETRIC                0x06250500  /* PARAMETERS */ 
#define CMD_SET_UNDO                            0x06260000  /* PARAMETERS */ 
#define CMD_SET_UNDO_ON                         0x06260100  /* PARAMETERS */ 
#define CMD_SET_UNDO_OFF                        0x06260200  /* PARAMETERS */ 
#define CMD_SET_UNDO_TOGGLE                     0x06260300  /* PARAMETERS */ 
#define CMD_SET_AUXINPUT                        0x06270000  /* PARAMETERS */ 
#define CMD_SET_AUXINPUT_ON                     0x06270100  /* PARAMETERS */ 
#define CMD_SET_AUXINPUT_OFF                    0x06270200  /* PARAMETERS */ 
#define CMD_SET_AUXINPUT_TOGGLE                 0x06270300  /* PARAMETERS */ 
#define CMD_SET_COORDINATES                     0x06280000  /* PARAMETERS */ 
#define CMD_SET_COORDINATES_ON                  0x06280100  /* PARAMETERS */ 
#define CMD_SET_COORDINATES_OFF                 0x06280200  /* PARAMETERS */ 
#define CMD_SET_COORDINATES_TOGGLE              0x06280300  /* PARAMETERS */ 
#define CMD_SET_AUTOPAN                         0x06290000  /* PARAMETERS */ 
#define CMD_SET_AUTOPAN_ON                      0x06290100  /* PARAMETERS */ 
#define CMD_SET_AUTOPAN_OFF                     0x06290200  /* PARAMETERS */ 
#define CMD_SET_AUTOPAN_TOGGLE                  0x06290300  /* PARAMETERS */ 
#define CMD_SET_MAXGRID                         0x062a0000  /* PARAMETERS */ 
#define CMD_SET_EDCHAR                          0x062d0000  /* PARAMETERS */ 
#define CMD_SET_PLOTTER                         0x062e0000  /* PARAMETERS */ 
#define CMD_SET_LOCATE                          0x062f0000  /* PARAMETERS */ 
#define CMD_SET_ISOPLANE                        0x06300000  /* PARAMETERS */ 
#define CMD_SET_ISOPLANE_TOP                    0x06300100  /* PARAMETERS */ 
#define CMD_SET_ISOPLANE_LEFT                   0x06300200  /* PARAMETERS */ 
#define CMD_SET_ISOPLANE_RIGHT                  0x06300300  /* PARAMETERS */ 
#define CMD_SET_ISOPLANE_ALL                    0x06300400  /* PARAMETERS */ 
#define CMD_SET_DYNOSIZE                        0x06310000  /* PARAMETERS */ 
#define CMD_SET_XOR                             0x06320000  /* PARAMETERS */ 
#define CMD_SET_XOR_BLACK                       0x06320100  /* PARAMETERS */ 
#define CMD_SET_XOR_BLUE                        0x06320200  /* PARAMETERS */ 
#define CMD_SET_XOR_GREEN                       0x06320300  /* PARAMETERS */ 
#define CMD_SET_XOR_CYAN                        0x06320400  /* PARAMETERS */ 
#define CMD_SET_XOR_RED                         0x06320500  /* PARAMETERS */ 
#define CMD_SET_XOR_MAGENTA                     0x06320600  /* PARAMETERS */ 
#define CMD_SET_XOR_YELLOW                      0x06320700  /* PARAMETERS */ 
#define CMD_SET_XOR_WHITE                       0x06320800  /* PARAMETERS */ 
#define CMD_SET_XOR_LGREY                       0x06320900  /* PARAMETERS */ 
#define CMD_SET_XOR_DGREY                       0x06320a00  /* PARAMETERS */ 
#define CMD_SET_ACSDISPLAY                      0x06330000  /* VIEWPARAM */ 
#define CMD_SET_ACSDISPLAY_ON                   0x06330100  /* VIEWPARAM */ 
#define CMD_SET_ACSDISPLAY_OFF                  0x06330200  /* VIEWPARAM */ 
#define CMD_SET_ACSDISPLAY_TOGGLE               0x06330300  /* VIEWPARAM */ 
#define CMD_SET_RASTERTEXT                      0x06340000  /* VIEWPARAM */ 
#define CMD_SET_RASTERTEXT_ON                   0x06340100  /* VIEWPARAM */ 
#define CMD_SET_RASTERTEXT_OFF                  0x06340200  /* VIEWPARAM */ 
#define CMD_SET_RASTERTEXT_TOGGLE               0x06340300  /* VIEWPARAM */ 
#define CMD_SET_PARSEALL                        0x06350000  /* PARAMETERS */ 
#define CMD_SET_PARSEALL_ON                     0x06350100  /* PARAMETERS */ 
#define CMD_SET_PARSEALL_OFF                    0x06350200  /* PARAMETERS */ 
#define CMD_SET_PARSEALL_TOGGLE                 0x06350300  /* PARAMETERS */ 
#define CMD_SET_HELP                            0x06360000  /* PARAMETERS */ 
#define CMD_SET_HELP_ON                         0x06360100  /* PARAMETERS */ 
#define CMD_SET_HELP_OFF                        0x06360200  /* PARAMETERS */ 
#define CMD_SET_HELP_TOGGLE                     0x06360300  /* PARAMETERS */ 
#define CMD_SET_SMALLTEXT                       0x06370000  /* PARAMETERS */ 
#define CMD_SET_HELPTOPIC                       0x06380000  /* PARAMETERS */ 
#define CMD_SET_ORIENTATION                     0x06390000  /* PARAMETERS */ 
#define CMD_SET_ORIENTATION_ON                  0x06390100  /* PARAMETERS */ 
#define CMD_SET_ORIENTATION_OFF                 0x06390200  /* PARAMETERS */ 
#define CMD_SET_ORIENTATION_TOGGLE              0x06390300  /* PARAMETERS */ 
#define CMD_SET_DEBUG                           0x063a0000  /* PARAMETERS */ 
#define CMD_SET_SCANNER                         0x063e0000  /* PARAMETERS */ 
#define CMD_SET_SCANNER_OLD                     0x063e0100  /* PARAMETERS */ 
#define CMD_SET_SCANNER_NEW                     0x063e0200  /* PARAMETERS */ 
#define CMD_SET_CAMERA                          0x063f0000  /* PARAMETERS */ 
#define CMD_SET_CAMERA_DEFINITION               0x063f0100  /* PARAMETERS */ 
#define CMD_SET_CAMERA_POSITION                 0x063f0200  /* PARAMETERS */ 
#define CMD_SET_CAMERA_TARGET                   0x063f0300  /* PARAMETERS */ 
#define CMD_SET_CAMERA_LENS                     0x063f0400  /* PARAMETERS */ 
#define CMD_SET_CAMERA_LENS_FISHEYE             0x063f0410  /* PARAMETERS */ 
#define CMD_SET_CAMERA_LENS_EXTRAWIDE           0x063f0420  /* PARAMETERS */ 
#define CMD_SET_CAMERA_LENS_WIDE                0x063f0430  /* PARAMETERS */ 
#define CMD_SET_CAMERA_LENS_NORMAL              0x063f0440  /* PARAMETERS */ 
#define CMD_SET_CAMERA_LENS_PORTRAIT            0x063f0450  /* PARAMETERS */ 
#define CMD_SET_CAMERA_LENS_TELEPHOTO           0x063f0460  /* PARAMETERS */ 
#define CMD_SET_CAMERA_LENS_TELESCOPIC          0x063f0470  /* PARAMETERS */ 
#define CMD_SET_CAMERA_LENS_LENGTH              0x063f0480  /* PARAMETERS */ 
#define CMD_SET_CAMERA_LENS_ANGLE               0x063f0490  /* PARAMETERS */ 
#define CMD_SET_CAMERA_DISTANCE                 0x063f0500  /* PARAMETERS */ 
#define CMD_SET_CAMERA_ON                       0x063f0600  /* PARAMETERS */ 
#define CMD_SET_CAMERA_OFF                      0x063f0700  /* PARAMETERS */ 
#define CMD_SET_VIEW                            0x06410000  /* PARAMETERS */ 
#define CMD_SET_VIEW_WIREFRAME                  0x06410100  /* PARAMETERS */ 
#define CMD_SET_VIEW_SECTION                    0x06410200  /* PARAMETERS */ 
#define CMD_SET_VIEW_WIREMESH                   0x06410300  /* PARAMETERS */ 
#define CMD_SET_VIEW_HIDDEN                     0x06410400  /* PARAMETERS */ 
#define CMD_SET_VIEW_FILLED                     0x06410500  /* PARAMETERS */ 
#define CMD_SET_VIEW_CONSTANT                   0x06410600  /* PARAMETERS */ 
#define CMD_SET_VIEW_SMOOTH                     0x06410700  /* PARAMETERS */ 
#define CMD_SET_VIEW_PHONG                      0x06410800  /* PARAMETERS */ 
#define CMD_SET_INTTRANSFORM                    0x06420000  /* PARAMETERS */ 
#define CMD_SET_INTTRANSFORM_ON                 0x06420100  /* PARAMETERS */ 
#define CMD_SET_INTTRANSFORM_OFF                0x06420200  /* PARAMETERS */ 
#define CMD_SET_INTTRANSFORM_TOGGLE             0x06420300  /* PARAMETERS */ 
#define CMD_SET_SHARECELL                       0x06430000  /* PARAMETERS */ 
#define CMD_SET_SHARECELL_ON                    0x06430100  /* PARAMETERS */ 
#define CMD_SET_SHARECELL_OFF                   0x06430200  /* PARAMETERS */ 
#define CMD_SET_SHARECELL_TOGGLE                0x06430300  /* PARAMETERS */ 
#define CMD_SET_COMPATIBLE                      0x06440000  /* PARAMETERS */ 
#define CMD_SET_COMPATIBLE_OFF                  0x06440100  /* PARAMETERS */ 
#define CMD_SET_COMPATIBLE_ON                   0x06440200  /* PARAMETERS */ 
#define CMD_SET_COMPATIBLE_DIMENSION            0x06440300  /* PARAMETERS */ 
#define CMD_SET_COMPATIBLE_DIMENSION_ON         0x06440310  /* PARAMETERS */ 
#define CMD_SET_COMPATIBLE_DIMENSION_OFF        0x06440320  /* PARAMETERS */ 
#define CMD_SET_COMPATIBLE_DIMENSION_TOGGLE     0x06440330  /* PARAMETERS */ 
#define CMD_SET_COMPATIBLE_MLINE                0x06440400  /* PARAMETERS */ 
#define CMD_SET_COMPATIBLE_MLINE_ON             0x06440410  /* PARAMETERS */ 
#define CMD_SET_COMPATIBLE_MLINE_OFF            0x06440420  /* PARAMETERS */ 
#define CMD_SET_COMPATIBLE_MLINE_TOGGLE         0x06440430  /* PARAMETERS */ 
#define CMD_SET_REFBOUND                        0x06450000  /* PARAMETERS */ 
#define CMD_SET_REFBOUND_ON                     0x06450100  /* PARAMETERS */ 
#define CMD_SET_REFBOUND_OFF                    0x06450200  /* PARAMETERS */ 
#define CMD_SET_REFBOUND_TOGGLE                 0x06450300  /* PARAMETERS */ 
#define CMD_SET_REFCLIP                         0x06460000  /* PARAMETERS */ 
#define CMD_SET_REFCLIP_FAST                    0x06460100  /* PARAMETERS */ 
#define CMD_SET_REFCLIP_SLOW                    0x06460200  /* PARAMETERS */ 
#define CMD_SET_REFCLIP_TOGGLE                  0x06460300  /* PARAMETERS */ 
#define CMD_SET_BACKGROUND                      0x06470000  /* PARAMETERS */ 
#define CMD_SET_BACKGROUND_ON                   0x06470100  /* PARAMETERS */ 
#define CMD_SET_BACKGROUND_OFF                  0x06470200  /* PARAMETERS */ 
#define CMD_SET_BACKGROUND_TOGGLE               0x06470300  /* PARAMETERS */ 
#define CMD_SET_DEPTHCUE                        0x06480000  /* PARAMETERS */ 
#define CMD_SET_DEPTHCUE_ON                     0x06480100  /* PARAMETERS */ 
#define CMD_SET_DEPTHCUE_OFF                    0x06480200  /* PARAMETERS */ 
#define CMD_SET_DEPTHCUE_TOGGLE                 0x06480300  /* PARAMETERS */ 
#define CMD_SET_XORSLOT                         0x06490000  /* PARAMETERS */ 
#define CMD_SET_CONFIRM                         0x064a0000  /* DATABASE */ 
#define CMD_SET_CONFIRM_ON                      0x064a0100  /* DATABASE */ 
#define CMD_SET_CONFIRM_OFF                     0x064a0200  /* DATABASE */ 
#define CMD_SET_CONFIRM_TOGGLE                  0x064a0300  /* DATABASE */ 
#define CMD_SHOW                                0x07000000  /* SHOW */ 
#define CMD_SHOW_HEADER                         0x07020000  /* SHOW */ 
#define CMD_SHOW_PLOTTER                        0x07050000  /* SHOW */ 
#define CMD_SHOW_REFERENCE                      0x07060000  /* SHOW */ 
#define CMD_SHOW_LIBRARY                        0x07070000  /* SHOW */ 
#define CMD_SHOW_VIEWS                          0x07080000  /* SHOW */ 
#define CMD_SHOW_EOF                            0x07090000  /* SHOW */ 
#define CMD_SHOW_UORS                           0x070b0000  /* SHOW */ 
#define CMD_SHOW_AE                             0x070c0000  /* SHOW */ 
#define CMD_SHOW_FONT                           0x070d0000  /* SHOW */ 
#define CMD_SHOW_PATTERN                        0x070e0000  /* SHOW */ 
#define CMD_SHOW_ACS                            0x07100000  /* SHOW */ 
#define CMD_SHOW_DEPTH                          0x07120000  /* SHOW */ 
#define CMD_SHOW_DEPTH_DISPLAY                  0x07120100  /* SHOW */ 
#define CMD_SHOW_DEPTH_ACTIVE                   0x07120200  /* SHOW */ 
#define CMD_SHOW_HEAP                           0x07150000  /* SHOW */ 
#define CMD_SHOW_SCANNER                        0x07160000  /* SHOW */ 
#define CMD_SHOW_CAMERA                         0x07170000  /* SHOW */ 
#define CMD_SHOW_CAMERA_POSITION                0x07170100  /* SHOW */ 
#define CMD_SHOW_CAMERA_TARGET                  0x07170200  /* SHOW */ 
#define CMD_SHOW_CAMERA_LENS                    0x07170300  /* SHOW */ 
#define CMD_SWAP                                0x08000000  /* VIEWIMMEDIATE */ 
#define CMD_SWAP_SCREEN                         0x08010000  /* VIEWIMMEDIATE */ 
#define CMD_VIEW                                0x09000000  /* VIEWING */ 
#define CMD_VIEW_TOP                            0x09010000  /* VIEWING */ 
#define CMD_VIEW_BOTTOM                         0x09020000  /* VIEWING */ 
#define CMD_VIEW_LEFT                           0x09030000  /* VIEWING */ 
#define CMD_VIEW_RIGHT                          0x09040000  /* VIEWING */ 
#define CMD_VIEW_FRONT                          0x09050000  /* VIEWING */ 
#define CMD_VIEW_BACK                           0x09060000  /* VIEWING */ 
#define CMD_VIEW_ISO                            0x09070000  /* VIEWING */ 
#define CMD_VIEW_ON                             0x09640000  /* VIEWING */ 
#define CMD_VIEW_ON_1                           0x09640100  /* VIEWIMMEDIATE */ 
#define CMD_VIEW_ON_2                           0x09640200  /* VIEWIMMEDIATE */ 
#define CMD_VIEW_ON_3                           0x09640300  /* VIEWIMMEDIATE */ 
#define CMD_VIEW_ON_4                           0x09640400  /* VIEWIMMEDIATE */ 
#define CMD_VIEW_ON_5                           0x09640500  /* VIEWIMMEDIATE */ 
#define CMD_VIEW_ON_6                           0x09640600  /* VIEWIMMEDIATE */ 
#define CMD_VIEW_ON_7                           0x09640700  /* VIEWIMMEDIATE */ 
#define CMD_VIEW_ON_8                           0x09640800  /* VIEWIMMEDIATE */ 
#define CMD_VIEW_ON_RIGHT                       0x09640900  /* VIEWIMMEDIATE */ 
#define CMD_VIEW_ON_LEFT                        0x09640a00  /* VIEWIMMEDIATE */ 
#define CMD_VIEW_ON_ALL                         0x09640b00  /* VIEWIMMEDIATE */ 
#define CMD_VIEW_OFF                            0x09650000  /* VIEWING */ 
#define CMD_VIEW_OFF_1                          0x09650100  /* VIEWIMMEDIATE */ 
#define CMD_VIEW_OFF_2                          0x09650200  /* VIEWIMMEDIATE */ 
#define CMD_VIEW_OFF_3                          0x09650300  /* VIEWIMMEDIATE */ 
#define CMD_VIEW_OFF_4                          0x09650400  /* VIEWIMMEDIATE */ 
#define CMD_VIEW_OFF_5                          0x09650500  /* VIEWIMMEDIATE */ 
#define CMD_VIEW_OFF_6                          0x09650600  /* VIEWIMMEDIATE */ 
#define CMD_VIEW_OFF_7                          0x09650700  /* VIEWIMMEDIATE */ 
#define CMD_VIEW_OFF_8                          0x09650800  /* VIEWIMMEDIATE */ 
#define CMD_VIEW_OFF_RIGHT                      0x09650900  /* VIEWIMMEDIATE */ 
#define CMD_VIEW_OFF_LEFT                       0x09650a00  /* VIEWIMMEDIATE */ 
#define CMD_VIEW_OFF_ALL                        0x09650b00  /* VIEWIMMEDIATE */ 
#define CMD_VIEW_TOGGLE                         0x09660000  /* VIEWING */ 
#define CMD_VIEW_TOGGLE_1                       0x09660100  /* VIEWIMMEDIATE */ 
#define CMD_VIEW_TOGGLE_2                       0x09660200  /* VIEWIMMEDIATE */ 
#define CMD_VIEW_TOGGLE_3                       0x09660300  /* VIEWIMMEDIATE */ 
#define CMD_VIEW_TOGGLE_4                       0x09660400  /* VIEWIMMEDIATE */ 
#define CMD_VIEW_TOGGLE_5                       0x09660500  /* VIEWIMMEDIATE */ 
#define CMD_VIEW_TOGGLE_6                       0x09660600  /* VIEWIMMEDIATE */ 
#define CMD_VIEW_TOGGLE_7                       0x09660700  /* VIEWIMMEDIATE */ 
#define CMD_VIEW_TOGGLE_8                       0x09660800  /* VIEWIMMEDIATE */ 
#define CMD_VIEW_TOGGLE_RIGHT                   0x09660900  /* VIEWIMMEDIATE */ 
#define CMD_VIEW_TOGGLE_LEFT                    0x09660a00  /* VIEWIMMEDIATE */ 
#define CMD_VIEW_TOGGLE_ALL                     0x09660b00  /* VIEWIMMEDIATE */ 
#define CMD_VIEW_IMAGE                          0x09670000  /* VIEWING */ 
#define CMD_VIEW_CLEAR                          0x09680000  /* VIEWING */ 
#define CMD_TEXT                                0x0a000000  /* VIEWPARAM */ 
#define CMD_TEXT_ON                             0x0a010000  /* VIEWPARAM */ 
#define CMD_TEXT_OFF                            0x0a020000  /* VIEWPARAM */ 
#define CMD_TEXT_FAST                           0x0a030000  /* VIEWPARAM */ 
#define CMD_TEXT_SLOW                           0x0a040000  /* VIEWPARAM */ 
#define CMD_TEXT_TOGGLE                         0x0a050000  /* VIEWPARAM */ 
#define CMD_TEXT_MODE                           0x0a060000  /* VIEWPARAM */ 
#define CMD_TEXT_MODE_ON                        0x0a060100  /* VIEWPARAM */ 
#define CMD_TEXT_MODE_OFF                       0x0a060200  /* VIEWPARAM */ 
#define CMD_TEXT_MODE_TOGGLE                    0x0a060300  /* VIEWPARAM */ 
#define CMD_ATTACH                              0x0b000000  /* PARAMETERS */ 
#define CMD_ATTACH_MENU                         0x0b010000  /* PARAMETERS */ 
#define CMD_ATTACH_LIBRARY                      0x0b020000  /* PARAMETERS */ 
#define CMD_ATTACH_REFERENCE                    0x0b030000  /* PARAMETERS */ 
#define CMD_ATTACH_AE                           0x0b040000  /* PARAMETERS */ 
#define CMD_ATTACH_COLORTABLE                   0x0b050000  /* PARAMETERS */ 
#define CMD_ATTACH_COLORTABLE_RIGHT             0x0b050100  /* PARAMETERS */ 
#define CMD_ATTACH_COLORTABLE_LEFT              0x0b050200  /* PARAMETERS */ 
#define CMD_ATTACH_COLORTABLE_BOTH              0x0b050300  /* PARAMETERS */ 
#define CMD_ATTACH_COLORTABLE_CREATE            0x0b050400  /* PARAMETERS */ 
#define CMD_ATTACH_COLORTABLE_WRITE             0x0b050500  /* PARAMETERS */ 
#define CMD_ATTACH_ACS                          0x0b060000  /* PARAMETERS */ 
#define CMD_ATTACH_DA                           0x0b070000  /* PARAMETERS */ 
#define CMD_MC                                  0x0c000000  /* VIEWING */ 
#define CMD_ROTATE                              0x0d000000  /* VIEWING */ 
#define CMD_ROTATE_ORIGINAL                     0x0d010000  /* MANIPULATION */ 
#define CMD_ROTATE_COPY                         0x0d020000  /* MANIPULATION */ 
#define CMD_ROTATE_3PTS                         0x0d030000  /* VIEWING */ 
#define CMD_ROTATE_VMATRX                       0x0d040000  /* VIEWING */ 
#define CMD_ROTATE_VIEW                         0x0d050000  /* VIEWING */ 
#define CMD_ROTATE_VIEW_RELATIVE                0x0d050100  /* VIEWING */ 
#define CMD_ROTATE_VIEW_ABSOLUTE                0x0d050200  /* VIEWING */ 
#define CMD_ROTATE_VIEW_POINTS                  0x0d050300  /* VIEWING */ 
#define CMD_ROTATE_VIEW_ELEMENT                 0x0d050400  /* VIEWING */ 
#define CMD_ROTATE_ACS                          0x0d060000  /* VIEWING */ 
#define CMD_ROTATE_ACS_RELATIVE                 0x0d060100  /* VIEWING */ 
#define CMD_ROTATE_ACS_RELATIVE_DEFAULT         0x0d060110  /* VIEWING */ 
#define CMD_ROTATE_ACS_ABSOLUTE                 0x0d060200  /* VIEWING */ 
#define CMD_ROTATE_ACS_ABSOLUTE_DEFAULT         0x0d060210  /* VIEWING */ 
#define CMD_PLOT                                0x0e000000  /* PLOT */ 
#define CMD_NEWFILE                             0x0f000000  /* NEWFILE */ 
#define CMD_PLACE                               0x10000000  /* PLACEMENT */ 
#define CMD_PLACE_FENCE                         0x10010000  /* FENCE */ 
#define CMD_PLACE_FENCE_BLOCK                   0x10010100  /* FENCE */ 
#define CMD_PLACE_FENCE_SHAPE                   0x10010200  /* FENCE */ 
#define CMD_PLACE_LSTRING                       0x10020000  /* PLACEMENT */ 
#define CMD_PLACE_LSTRING_SPACE                 0x10020100  /* PLACEMENT */ 
#define CMD_PLACE_LSTRING_STREAM                0x10020200  /* PLACEMENT */ 
#define CMD_PLACE_LSTRING_POINT                 0x10020300  /* PLACEMENT */ 
#define CMD_PLACE_CIRCLE                        0x10030000  /* PLACEMENT */ 
#define CMD_PLACE_CIRCLE_CENTER                 0x10030100  /* PLACEMENT */ 
#define CMD_PLACE_CIRCLE_DIAMETER               0x10030200  /* PLACEMENT */ 
#define CMD_PLACE_CIRCLE_EDGE                   0x10030300  /* PLACEMENT */ 
#define CMD_PLACE_CIRCLE_RADIUS                 0x10030400  /* PLACEMENT */ 
#define CMD_PLACE_CIRCLE_ISOMETRIC              0x10030500  /* PLACEMENT */ 
#define CMD_PLACE_BLOCK                         0x10040000  /* PLACEMENT */ 
#define CMD_PLACE_BLOCK_ORTHOGONAL              0x10040100  /* PLACEMENT */ 
#define CMD_PLACE_BLOCK_ROTATED                 0x10040200  /* PLACEMENT */ 
#define CMD_PLACE_BLOCK_ISOMETRIC               0x10040300  /* PLACEMENT */ 
#define CMD_PLACE_CURVE                         0x10050000  /* PLACEMENT */ 
#define CMD_PLACE_CURVE_SPACE                   0x10050100  /* PLACEMENT */ 
#define CMD_PLACE_CURVE_STREAM                  0x10050200  /* PLACEMENT */ 
#define CMD_PLACE_CURVE_POINT                   0x10050300  /* PLACEMENT */ 
#define CMD_PLACE_LINE                          0x10060000  /* PLACEMENT */ 
#define CMD_PLACE_LINE_ANGLE                    0x10060100  /* PLACEMENT */ 
#define CMD_PLACE_ELLIPSE                       0x10070000  /* PLACEMENT */ 
#define CMD_PLACE_ELLIPSE_CENTER                0x10070100  /* PLACEMENT */ 
#define CMD_PLACE_ELLIPSE_EDGE                  0x10070200  /* PLACEMENT */ 
#define CMD_PLACE_ELLIPSE_HALF                  0x10070300  /* PLACEMENT */ 
#define CMD_PLACE_ELLIPSE_QUARTER               0x10070400  /* PLACEMENT */ 
#define CMD_PLACE_ELLIPSE_FOURTH                0x10070400  /* PLACEMENT */ 
#define CMD_PLACE_ARC                           0x10080000  /* PLACEMENT */ 
#define CMD_PLACE_ARC_CENTER                    0x10080100  /* PLACEMENT */ 
#define CMD_PLACE_ARC_EDGE                      0x10080200  /* PLACEMENT */ 
#define CMD_PLACE_ARC_RADIUS                    0x10080300  /* PLACEMENT */ 
#define CMD_PLACE_ARC_TANGENT                   0x10080400  /* PLACEMENT */ 
#define CMD_PLACE_SHAPE                         0x10090000  /* PLACEMENT */ 
#define CMD_PLACE_SHAPE_ORTHOGONAL              0x10090100  /* PLACEMENT */ 
#define CMD_PLACE_TEXT                          0x100a0000  /* PLACEMENT */ 
#define CMD_PLACE_TEXT_FITTED                   0x100a0100  /* PLACEMENT */ 
#define CMD_PLACE_TEXT_VI                       0x100a0200  /* PLACEMENT */ 
#define CMD_PLACE_TEXT_FVI                      0x100a0300  /* PLACEMENT */ 
#define CMD_PLACE_TEXT_ABOVE                    0x100a0400  /* PLACEMENT */ 
#define CMD_PLACE_TEXT_BELOW                    0x100a0500  /* PLACEMENT */ 
#define CMD_PLACE_TEXT_ON                       0x100a0600  /* PLACEMENT */ 
#define CMD_PLACE_TEXT_TMATRIX                  0x100a0700  /* PLACEMENT */ 
#define CMD_PLACE_TEXT_ALONG                    0x100a0800  /* PLACEMENT */ 
#define CMD_PLACE_CYLINDER                      0x100b0000  /* PLACEMENT */ 
#define CMD_PLACE_CYLINDER_RIGHT                0x100b0100  /* PLACEMENT */ 
#define CMD_PLACE_CYLINDER_RADIUS               0x100b0200  /* PLACEMENT */ 
#define CMD_PLACE_CYLINDER_CAPPED               0x100b0300  /* PLACEMENT */ 
#define CMD_PLACE_CYLINDER_UNCAPPED             0x100b0400  /* PLACEMENT */ 
#define CMD_PLACE_CYLINDER_SKEWED               0x100b0500  /* PLACEMENT */ 
#define CMD_PLACE_CONE                          0x100c0000  /* PLACEMENT */ 
#define CMD_PLACE_CONE_RIGHT                    0x100c0100  /* PLACEMENT */ 
#define CMD_PLACE_CONE_RADIUS                   0x100c0200  /* PLACEMENT */ 
#define CMD_PLACE_CONE_SKEWED                   0x100c0300  /* PLACEMENT */ 
#define CMD_PLACE_CELL                          0x100d0000  /* PLACEMENT */ 
#define CMD_PLACE_CELL_ABSOLUTE                 0x100d0100  /* PLACEMENT */ 
#define CMD_PLACE_CELL_ABSOLUTE_TMATRX          0x100d0110  /* PLACEMENT */ 
#define CMD_PLACE_CELL_RELATIVE                 0x100d0200  /* PLACEMENT */ 
#define CMD_PLACE_CELL_RELATIVE_TMATRX          0x100d0210  /* PLACEMENT */ 
#define CMD_PLACE_CELL_INTERACTIVE              0x100d0300  /* PLACEMENT */ 
#define CMD_PLACE_CELL_INTERACTIVE_ABSOLUTE     0x100d0310  /* PLACEMENT */ 
#define CMD_PLACE_CELL_INTERACTIVE_RELATIVE     0x100d0320  /* PLACEMENT */ 
#define CMD_PLACE_NODE                          0x100e0000  /* PLACEMENT */ 
#define CMD_PLACE_NODE_VIEW                     0x100e0100  /* PLACEMENT */ 
#define CMD_PLACE_NODE_TMATRIX                  0x100e0200  /* PLACEMENT */ 
#define CMD_PLACE_TERMINATOR                    0x100f0000  /* PLACEMENT */ 
#define CMD_PLACE_POINT                         0x10100000  /* PLACEMENT */ 
#define CMD_PLACE_POINT_STRING                  0x10100100  /* PLACEMENT */ 
#define CMD_PLACE_POINT_STRING_DISJOINT         0x10100110  /* PLACEMENT */ 
#define CMD_PLACE_POINT_STRING_CONTINUOUS       0x10100120  /* PLACEMENT */ 
#define CMD_PLACE_PARABOLA                      0x10110000  /* PLACEMENT */ 
#define CMD_PLACE_PARABOLA_NOMODIFY             0x10110100  /* PLACEMENT */ 
#define CMD_PLACE_PARABOLA_MODIFY               0x10110200  /* PLACEMENT */ 
#define CMD_PLACE_PARABOLA_HORIZONTAL           0x10110300  /* PLACEMENT */ 
#define CMD_PLACE_PARABOLA_HORIZONTAL_NOMODIFY  0x10110310  /* PLACEMENT */ 
#define CMD_PLACE_PARABOLA_HORIZONTAL_MODIFY    0x10110320  /* PLACEMENT */ 
#define CMD_PLACE_POLYGON                       0x10130000  /* PLACEMENT */ 
#define CMD_PLACE_POLYGON_INSCRIBED             0x10130100  /* PLACEMENT */ 
#define CMD_PLACE_POLYGON_CIRCUMSCRIBED         0x10130200  /* PLACEMENT */ 
#define CMD_PLACE_POLYGON_EDGE                  0x10130300  /* PLACEMENT */ 
#define CMD_PLACE_NOTE                          0x10140000  /* PLACEMENT */ 
#define CMD_PLACE_NOTE_DIALOG                   0x10140100  /* PLACEMENT */ 
#define CMD_PLACE_DIALOGTEXT                    0x10150000  /* PLACEMENT */ 
#define CMD_PLACE_DIALOGTEXT_FITTED             0x10150100  /* PLACEMENT */ 
#define CMD_PLACE_DIALOGTEXT_VI                 0x10150200  /* PLACEMENT */ 
#define CMD_PLACE_DIALOGTEXT_FVI                0x10150300  /* PLACEMENT */ 
#define CMD_PLACE_DIALOGTEXT_ABOVE              0x10150400  /* PLACEMENT */ 
#define CMD_PLACE_DIALOGTEXT_BELOW              0x10150500  /* PLACEMENT */ 
#define CMD_PLACE_DIALOGTEXT_ON                 0x10150600  /* PLACEMENT */ 
#define CMD_PLACE_DIALOGTEXT_TMATRIX            0x10150700  /* PLACEMENT */ 
#define CMD_PLACE_DIALOGTEXT_ALONG              0x10150800  /* PLACEMENT */ 
#define CMD_PLACE_SPHERE                        0x10160000  /* PLACEMENT */ 
#define CMD_PLACE_SLAB                          0x10170000  /* PLACEMENT */ 
#define CMD_PLACE_MLINE                         0x10180000  /* PLACEMENT */ 
#define CMD_ACTIVE                              0x11000000  /* PARAMETERS */ 
#define CMD_ACTIVE_COLOR                        0x11010000  /* PARAMETERS */ 
#define CMD_ACTIVE_COLOR_WHITE                  0x11010100  /* PARAMETERS */ 
#define CMD_ACTIVE_COLOR_BLUE                   0x11010200  /* PARAMETERS */ 
#define CMD_ACTIVE_COLOR_GREEN                  0x11010300  /* PARAMETERS */ 
#define CMD_ACTIVE_COLOR_RED                    0x11010400  /* PARAMETERS */ 
#define CMD_ACTIVE_COLOR_YELLOW                 0x11010500  /* PARAMETERS */ 
#define CMD_ACTIVE_COLOR_VIOLET                 0x11010600  /* PARAMETERS */ 
#define CMD_ACTIVE_COLOR_ORANGE                 0x11010700  /* PARAMETERS */ 
#define CMD_ACTIVE_COLOR_CSELECT                0x11010800  /* PARAMETERS */ 
#define CMD_ACTIVE_STYLE                        0x11020000  /* PARAMETERS */ 
#define CMD_ACTIVE_STYLE_CSELECT                0x11020100  /* PARAMETERS */ 
#define CMD_ACTIVE_WEIGHT                       0x11030000  /* PARAMETERS */ 
#define CMD_ACTIVE_WEIGHT_CSELECT               0x11030100  /* PARAMETERS */ 
#define CMD_ACTIVE_LEVEL                        0x11040000  /* PARAMETERS */ 
#define CMD_ACTIVE_ANGLE                        0x11050000  /* PARAMETERS */ 
#define CMD_ACTIVE_ANGLE_PT2                    0x11050100  /* VIEWPARAM */ 
#define CMD_ACTIVE_ANGLE_PT3                    0x11050200  /* VIEWPARAM */ 
#define CMD_ACTIVE_FONT                         0x11060000  /* PARAMETERS */ 
#define CMD_ACTIVE_ORIGIN                       0x11070000  /* VIEWPARAM */ 
#define CMD_ACTIVE_GRIDUNIT                     0x11080000  /* PARAMETERS */ 
#define CMD_ACTIVE_GRIDREF                      0x11090000  /* PARAMETERS */ 
#define CMD_ACTIVE_TXSIZE                       0x110a0000  /* PARAMETERS */ 
#define CMD_ACTIVE_TXHEIGHT                     0x110b0000  /* VIEWPARAM */ 
#define CMD_ACTIVE_TXHEIGHT_PT2                 0x110b0100  /* VIEWPARAM */ 
#define CMD_ACTIVE_TXWIDTH                      0x110c0000  /* VIEWPARAM */ 
#define CMD_ACTIVE_TXWIDTH_PT2                  0x110c0100  /* VIEWPARAM */ 
#define CMD_ACTIVE_SCALE                        0x110d0000  /* PARAMETERS */ 
#define CMD_ACTIVE_SCALE_DISTANCE               0x110d0100  /* PARAMETERS */ 
#define CMD_ACTIVE_XSCALE                       0x110e0000  /* PARAMETERS */ 
#define CMD_ACTIVE_YSCALE                       0x110f0000  /* PARAMETERS */ 
#define CMD_ACTIVE_ZSCALE                       0x11100000  /* PARAMETERS */ 
#define CMD_ACTIVE_UNITROUND                    0x11110000  /* PARAMETERS */ 
#define CMD_ACTIVE_TXJ                          0x11120000  /* PARAMETERS */ 
#define CMD_ACTIVE_TXJ_LT                       0x11120100  /* PARAMETERS */ 
#define CMD_ACTIVE_TXJ_LC                       0x11120200  /* PARAMETERS */ 
#define CMD_ACTIVE_TXJ_LB                       0x11120300  /* PARAMETERS */ 
#define CMD_ACTIVE_TXJ_CT                       0x11120700  /* PARAMETERS */ 
#define CMD_ACTIVE_TXJ_CC                       0x11120800  /* PARAMETERS */ 
#define CMD_ACTIVE_TXJ_CB                       0x11120900  /* PARAMETERS */ 
#define CMD_ACTIVE_TXJ_RT                       0x11120d00  /* PARAMETERS */ 
#define CMD_ACTIVE_TXJ_RC                       0x11120e00  /* PARAMETERS */ 
#define CMD_ACTIVE_TXJ_RB                       0x11120f00  /* PARAMETERS */ 
#define CMD_ACTIVE_TNJ                          0x11130000  /* PARAMETERS */ 
#define CMD_ACTIVE_TNJ_LT                       0x11130100  /* PARAMETERS */ 
#define CMD_ACTIVE_TNJ_LC                       0x11130200  /* PARAMETERS */ 
#define CMD_ACTIVE_TNJ_LB                       0x11130300  /* PARAMETERS */ 
#define CMD_ACTIVE_TNJ_LMT                      0x11130400  /* PARAMETERS */ 
#define CMD_ACTIVE_TNJ_LMC                      0x11130500  /* PARAMETERS */ 
#define CMD_ACTIVE_TNJ_LMB                      0x11130600  /* PARAMETERS */ 
#define CMD_ACTIVE_TNJ_CT                       0x11130700  /* PARAMETERS */ 
#define CMD_ACTIVE_TNJ_CC                       0x11130800  /* PARAMETERS */ 
#define CMD_ACTIVE_TNJ_CB                       0x11130900  /* PARAMETERS */ 
#define CMD_ACTIVE_TNJ_RMT                      0x11130a00  /* PARAMETERS */ 
#define CMD_ACTIVE_TNJ_RMC                      0x11130b00  /* PARAMETERS */ 
#define CMD_ACTIVE_TNJ_RMB                      0x11130c00  /* PARAMETERS */ 
#define CMD_ACTIVE_TNJ_RT                       0x11130d00  /* PARAMETERS */ 
#define CMD_ACTIVE_TNJ_RC                       0x11130e00  /* PARAMETERS */ 
#define CMD_ACTIVE_TNJ_RB                       0x11130f00  /* PARAMETERS */ 
#define CMD_ACTIVE_ZDEPTH                       0x11140000  /* VIEWPARAM */ 
#define CMD_ACTIVE_ZDEPTH_ABSOLUTE              0x11140100  /* VIEWPARAM */ 
#define CMD_ACTIVE_ZDEPTH_RELATIVE              0x11140200  /* VIEWPARAM */ 
#define CMD_ACTIVE_CELL                         0x11150000  /* PARAMETERS */ 
#define CMD_ACTIVE_LINE                         0x11160000  /* PARAMETERS */ 
#define CMD_ACTIVE_LINE_LENGTH                  0x11160100  /* PARAMETERS */ 
#define CMD_ACTIVE_LINE_SPACE                   0x11160200  /* PARAMETERS */ 
#define CMD_ACTIVE_TERMINATOR                   0x11170000  /* PARAMETERS */ 
#define CMD_ACTIVE_TSCALE                       0x11180000  /* PARAMETERS */ 
#define CMD_ACTIVE_NODE                         0x11190000  /* PARAMETERS */ 
#define CMD_ACTIVE_TAG                          0x111a0000  /* PARAMETERS */ 
#define CMD_ACTIVE_TAB                          0x111b0000  /* PARAMETERS */ 
#define CMD_ACTIVE_STREAM                       0x111c0000  /* PARAMETERS */ 
#define CMD_ACTIVE_STREAM_DELTA                 0x111c0100  /* PARAMETERS */ 
#define CMD_ACTIVE_STREAM_TOLERANCE             0x111c0200  /* PARAMETERS */ 
#define CMD_ACTIVE_STREAM_ANGLE                 0x111c0300  /* PARAMETERS */ 
#define CMD_ACTIVE_STREAM_AREA                  0x111c0400  /* PARAMETERS */ 
#define CMD_ACTIVE_POINT                        0x111d0000  /* PARAMETERS */ 
#define CMD_ACTIVE_INDEX                        0x111e0000  /* PARAMETERS */ 
#define CMD_ACTIVE_KEYPNT                       0x111f0000  /* PARAMETERS */ 
#define CMD_ACTIVE_PATTERN                      0x11200000  /* PARAMETERS */ 
#define CMD_ACTIVE_PATTERN_DELTA                0x11200100  /* PARAMETERS */ 
#define CMD_ACTIVE_PATTERN_ANGLE                0x11200200  /* PARAMETERS */ 
#define CMD_ACTIVE_PATTERN_SCALE                0x11200300  /* PARAMETERS */ 
#define CMD_ACTIVE_PATTERN_CELL                 0x11200400  /* PARAMETERS */ 
#define CMD_ACTIVE_PATTERN_MATCH                0x11200500  /* PARAMETERS */ 
#define CMD_ACTIVE_AREA                         0x11210000  /* PARAMETERS */ 
#define CMD_ACTIVE_AREA_SOLID                   0x11210100  /* PARAMETERS */ 
#define CMD_ACTIVE_AREA_HOLE                    0x11210200  /* PARAMETERS */ 
#define CMD_ACTIVE_AREA_TOGGLE                  0x11210300  /* PARAMETERS */ 
#define CMD_ACTIVE_LINKAGE                      0x11220000  /* PARAMETERS */ 
#define CMD_ACTIVE_AXIS                         0x11230000  /* PARAMETERS */ 
#define CMD_ACTIVE_CLASS                        0x11240000  /* PARAMETERS */ 
#define CMD_ACTIVE_CLASS_PRIMARY                0x11240100  /* PARAMETERS */ 
#define CMD_ACTIVE_CLASS_CONSTRUCTION           0x11240300  /* PARAMETERS */ 
#define CMD_ACTIVE_LINEWIDTH                    0x11250000  /* PARAMETERS */ 
#define CMD_ACTIVE_AXORIGIN                     0x11260000  /* PARAMETERS */ 
#define CMD_ACTIVE_REVIEW                       0x11270000  /* PARAMETERS */ 
#define CMD_ACTIVE_RCELL                        0x11280000  /* PARAMETERS */ 
#define CMD_ACTIVE_DATABASE                     0x11290000  /* PARAMETERS */ 
#define CMD_ACTIVE_REPORT                       0x112a0000  /* PARAMETERS */ 
#define CMD_ACTIVE_TEXT                         0x112b0000  /* PARAMETERS */ 
#define CMD_ACTIVE_CAPMODE                      0x112c0000  /* PARAMETERS */ 
#define CMD_ACTIVE_CAPMODE_ON                   0x112c0100  /* PARAMETERS */ 
#define CMD_ACTIVE_CAPMODE_OFF                  0x112c0200  /* PARAMETERS */ 
#define CMD_ACTIVE_CAPMODE_TOGGLE               0x112c0300  /* PARAMETERS */ 
#define CMD_ACTIVE_GRIDMODE                     0x112d0000  /* PARAMETERS */ 
#define CMD_ACTIVE_GRIDMODE_ORTHOGONAL          0x112d0100  /* PARAMETERS */ 
#define CMD_ACTIVE_GRIDMODE_OFFSET              0x112d0200  /* PARAMETERS */ 
#define CMD_ACTIVE_GRIDMODE_ISOMETRIC           0x112d0300  /* PARAMETERS */ 
#define CMD_ACTIVE_GRIDMODE_TOGGLE              0x112d0400  /* PARAMETERS */ 
#define CMD_ACTIVE_GRIDRATIO                    0x112e0000  /* PARAMETERS */ 
#define CMD_ACTIVE_DATYPE                       0x11300000  /* PARAMETERS */ 
#define CMD_ACTIVE_BACKGROUND                   0x11310000  /* PARAMETERS */ 
#define CMD_ACTIVE_FILL                         0x11320000  /* PARAMETERS */ 
#define CMD_ACTIVE_FILL_ON                      0x11320100  /* PARAMETERS */ 
#define CMD_ACTIVE_FILL_OFF                     0x11320200  /* PARAMETERS */ 
#define CMD_ACTIVE_FILL_TOGGLE                  0x11320300  /* PARAMETERS */ 
#define CMD_ACTIVE_ENTITY                       0x11330000  /* DATABASE */ 
#define CMD_DEPTH                               0x12000000  /* VIEWPARAM */ 
#define CMD_DEPTH_DISPLAY                       0x12010000  /* VIEWPARAM */ 
#define CMD_DEPTH_DISPLAY_PRIMITIVE             0x12010100  /* VIEWPARAM */ 
#define CMD_DEPTH_DISPLAY_INTERACTIVE           0x12010200  /* VIEWPARAM */ 
#define CMD_DEPTH_ACTIVE                        0x12020000  /* VIEWPARAM */ 
#define CMD_DEPTH_ACTIVE_PRIMITIVE              0x12020100  /* VIEWPARAM */ 
#define CMD_DEPTH_ACTIVE_INTERACTIVE            0x12020200  /* VIEWPARAM */ 
#define CMD_MEASURE                             0x13000000  /* MEASURE */ 
#define CMD_MEASURE_AREA                        0x13010000  /* MEASURE */ 
#define CMD_MEASURE_AREA_ELEMENT                0x13010100  /* MEASURE */ 
#define CMD_MEASURE_AREA_POINTS                 0x13010200  /* MEASURE */ 
#define CMD_MEASURE_DISTANCE                    0x13020000  /* MEASURE */ 
#define CMD_MEASURE_DISTANCE_MINIMUM            0x13020100  /* MEASURE */ 
#define CMD_MEASURE_DISTANCE_POINTS             0x13020200  /* MEASURE */ 
#define CMD_MEASURE_DISTANCE_PERPENDICULAR      0x13020300  /* MEASURE */ 
#define CMD_MEASURE_DISTANCE_ALONG              0x13020400  /* MEASURE */ 
#define CMD_MEASURE_RADIUS                      0x13030000  /* MEASURE */ 
#define CMD_MEASURE_ANGLE                       0x13040000  /* MEASURE */ 
#define CMD_DESIGN                              0x14000000  /* PARAMETERS */ 
#define CMD_SAVE                                0x15000000  /* PARAMETERS */ 
#define CMD_SAVE_FUNCTION_KEY                   0x15010000  /* PARAMETERS */ 
#define CMD_SAVE_VIEW                           0x15020000  /* VIEWPARAM */ 
#define CMD_SAVE_ACS                            0x15030000  /* PARAMETERS */ 
#define CMD_SAVE_IMAGE                          0x15040000  /* PARAMETERS */ 
#define CMD_COPY                                0x16000000  /* MANIPULATION */ 
#define CMD_COPY_VIEW                           0x16010000  /* VIEWING */ 
#define CMD_COPY_ELEMENT                        0x16020000  /* MANIPULATION */ 
#define CMD_COPY_PARALLEL                       0x16030000  /* MANIPULATION */ 
#define CMD_COPY_PARALLEL_DISTANCE              0x16030100  /* MANIPULATION */ 
#define CMD_COPY_PARALLEL_KEYIN                 0x16030200  /* MANIPULATION */ 
#define CMD_COPY_ED                             0x16040000  /* MANIPULATION */ 
#define CMD_ALIGN                               0x17000000  /* VIEWING */ 
#define CMD_POINT                               0x18000000  /* INPUT */ 
#define CMD_POINT_ABSOLUTE                      0x18010000  /* INPUT */ 
#define CMD_POINT_DISTANCE                      0x18020000  /* INPUT */ 
#define CMD_POINT_DELTA                         0x18030000  /* INPUT */ 
#define CMD_POINT_VDELTA                        0x18040000  /* INPUT */ 
#define CMD_POINT_ACSABSOLUTE                   0x18050000  /* INPUT */ 
#define CMD_POINT_ACSDELTA                      0x18060000  /* INPUT */ 
#define CMD_POINT_DEFAULT                       0x18070000  /* INPUT */ 
#define CMD_DELETE                              0x19000000  /* MANIPULATION */ 
#define CMD_DELETE_ELEMENT                      0x19010000  /* MANIPULATION */ 
#define CMD_DELETE_VERTEX                       0x19020000  /* MANIPULATION */ 
#define CMD_DELETE_PARTIAL                      0x19030000  /* MANIPULATION */ 
#define CMD_DELETE_VIEW                         0x19040000  /* VIEWING */ 
#define CMD_DELETE_CELL                         0x19050000  /* CELLLIB */ 
#define CMD_DELETE_66ELEMENTS                   0x19060000  /* MANIPULATION */ 
#define CMD_DELETE_66ELEMENTS_REFERENCE         0x19060100  /* MANIPULATION */ 
#define CMD_DELETE_66ELEMENTS_LEVELNAME         0x19060200  /* MANIPULATION */ 
#define CMD_DELETE_66ELEMENTS_VIEW              0x19060300  /* MANIPULATION */ 
#define CMD_DELETE_66ELEMENTS_MS                0x19060400  /* MANIPULATION */ 
#define CMD_DELETE_66ELEMENTS_ALL               0x19060500  /* MANIPULATION */ 
#define CMD_DELETE_66ELEMENTS_TCB               0x19060600  /* MANIPULATION */ 
#define CMD_DELETE_66ELEMENTS_START             0x19060700  /* MANIPULATION */ 
#define CMD_DELETE_ACS                          0x19070000  /* MANIPULATION */ 
#define CMD_LOCK                                0x1a000000  /* LOCKS */ 
#define CMD_LOCK_SNAP                           0x1a010000  /* LOCKS */ 
#define CMD_LOCK_SNAP_ON                        0x1a010100  /* LOCKS */ 
#define CMD_LOCK_SNAP_OFF                       0x1a010200  /* LOCKS */ 
#define CMD_LOCK_SNAP_PROJECT                   0x1a010300  /* LOCKS */ 
#define CMD_LOCK_SNAP_KEYPOINT                  0x1a010400  /* LOCKS */ 
#define CMD_LOCK_SNAP_CONSTRUCTION              0x1a010500  /* LOCKS */ 
#define CMD_LOCK_SNAP_CONSTRUCTION_ON           0x1a010510  /* LOCKS */ 
#define CMD_LOCK_SNAP_CONSTRUCTION_OFF          0x1a010520  /* LOCKS */ 
#define CMD_LOCK_SNAP_CONSTRUCTION_TOGGLE       0x1a010530  /* LOCKS */ 
#define CMD_LOCK_SNAP_ACS                       0x1a010500  /* LOCKS */ 
#define CMD_LOCK_SNAP_ACS_ON                    0x1a010510  /* LOCKS */ 
#define CMD_LOCK_SNAP_ACS_OFF                   0x1a010520  /* LOCKS */ 
#define CMD_LOCK_SNAP_ACS_TOGGLE                0x1a010530  /* LOCKS */ 
#define CMD_LOCK_SNAP_INTERSECTION              0x1a010600  /* LOCKS */ 
#define CMD_LOCK_SNAP_INTERSECTION_ON           0x1a010610  /* LOCKS */ 
#define CMD_LOCK_SNAP_INTERSECTION_OFF          0x1a010620  /* LOCKS */ 
#define CMD_LOCK_SNAP_INTERSECTION_TOGGLE       0x1a010630  /* LOCKS */ 
#define CMD_LOCK_GRID                           0x1a020000  /* LOCKS */ 
#define CMD_LOCK_GRID_ON                        0x1a020100  /* LOCKS */ 
#define CMD_LOCK_GRID_OFF                       0x1a020200  /* LOCKS */ 
#define CMD_LOCK_GRID_TOGGLE                    0x1a020300  /* LOCKS */ 
#define CMD_LOCK_UNIT                           0x1a030000  /* LOCKS */ 
#define CMD_LOCK_UNIT_ON                        0x1a030100  /* LOCKS */ 
#define CMD_LOCK_UNIT_OFF                       0x1a030200  /* LOCKS */ 
#define CMD_LOCK_UNIT_TOGGLE                    0x1a030300  /* LOCKS */ 
#define CMD_LOCK_BORESITE                       0x1a040000  /* LOCKS */ 
#define CMD_LOCK_BORESITE_ON                    0x1a040100  /* LOCKS */ 
#define CMD_LOCK_BORESITE_OFF                   0x1a040200  /* LOCKS */ 
#define CMD_LOCK_BORESITE_TOGGLE                0x1a040300  /* LOCKS */ 
#define CMD_LOCK_ANGLE                          0x1a050000  /* LOCKS */ 
#define CMD_LOCK_ANGLE_ON                       0x1a050100  /* LOCKS */ 
#define CMD_LOCK_ANGLE_OFF                      0x1a050200  /* LOCKS */ 
#define CMD_LOCK_ANGLE_TOGGLE                   0x1a050300  /* LOCKS */ 
#define CMD_LOCK_TEXTNODE                       0x1a060000  /* LOCKS */ 
#define CMD_LOCK_TEXTNODE_ON                    0x1a060100  /* LOCKS */ 
#define CMD_LOCK_TEXTNODE_OFF                   0x1a060200  /* LOCKS */ 
#define CMD_LOCK_TEXTNODE_TOGGLE                0x1a060300  /* LOCKS */ 
#define CMD_LOCK_AXIS                           0x1a070000  /* LOCKS */ 
#define CMD_LOCK_AXIS_ON                        0x1a070100  /* LOCKS */ 
#define CMD_LOCK_AXIS_OFF                       0x1a070200  /* LOCKS */ 
#define CMD_LOCK_AXIS_TOGGLE                    0x1a070300  /* LOCKS */ 
#define CMD_LOCK_SCALE                          0x1a080000  /* LOCKS */ 
#define CMD_LOCK_SCALE_ON                       0x1a080100  /* LOCKS */ 
#define CMD_LOCK_SCALE_OFF                      0x1a080200  /* LOCKS */ 
#define CMD_LOCK_SCALE_TOGGLE                   0x1a080300  /* LOCKS */ 
#define CMD_LOCK_GGROUP                         0x1a090000  /* LOCKS */ 
#define CMD_LOCK_GGROUP_ON                      0x1a090100  /* LOCKS */ 
#define CMD_LOCK_GGROUP_OFF                     0x1a090200  /* LOCKS */ 
#define CMD_LOCK_GGROUP_TOGGLE                  0x1a090300  /* LOCKS */ 
#define CMD_LOCK_LEVEL                          0x1a0a0000  /* LOCKS */ 
#define CMD_LOCK_LEVEL_ON                       0x1a0a0100  /* LOCKS */ 
#define CMD_LOCK_LEVEL_OFF                      0x1a0a0200  /* LOCKS */ 
#define CMD_LOCK_LEVEL_TOGGLE                   0x1a0a0300  /* LOCKS */ 
#define CMD_LOCK_FENCE                          0x1a0c0000  /* LOCKS */ 
#define CMD_LOCK_FENCE_OVERLAP                  0x1a0c0100  /* LOCKS */ 
#define CMD_LOCK_FENCE_INSIDE                   0x1a0c0200  /* LOCKS */ 
#define CMD_LOCK_FENCE_CLIP                     0x1a0c0300  /* LOCKS */ 
#define CMD_LOCK_FENCE_VOID                     0x1a0c0400  /* LOCKS */ 
#define CMD_LOCK_FENCE_VOID_OVERLAP             0x1a0c0410  /* LOCKS */ 
#define CMD_LOCK_FENCE_VOID_OUTSIDE             0x1a0c0420  /* LOCKS */ 
#define CMD_LOCK_FENCE_VOID_CLIP                0x1a0c0430  /* LOCKS */ 
#define CMD_LOCK_CELLSTRETCH                    0x1a0d0000  /* LOCKS */ 
#define CMD_LOCK_CELLSTRETCH_ON                 0x1a0d0100  /* LOCKS */ 
#define CMD_LOCK_CELLSTRETCH_OFF                0x1a0d0200  /* LOCKS */ 
#define CMD_LOCK_CELLSTRETCH_TOGGLE             0x1a0d0300  /* LOCKS */ 
#define CMD_LOCK_SELECTION                      0x1a0e0000  /* LOCKS */ 
#define CMD_LOCK_SELECTION_ON                   0x1a0e0100  /* LOCKS */ 
#define CMD_LOCK_SELECTION_OFF                  0x1a0e0200  /* LOCKS */ 
#define CMD_LOCK_SELECTION_TOGGLE               0x1a0e0300  /* LOCKS */ 
#define CMD_LOCK_ACS                            0x1a0f0000  /* LOCKS */ 
#define CMD_LOCK_ACS_ON                         0x1a0f0100  /* LOCKS */ 
#define CMD_LOCK_ACS_OFF                        0x1a0f0200  /* LOCKS */ 
#define CMD_LOCK_ACS_TOGGLE                     0x1a0f0300  /* LOCKS */ 
#define CMD_LOCK_CONSTRUCTION                   0x1a0f0000  /* LOCKS */ 
#define CMD_LOCK_CONSTRUCTION_ON                0x1a0f0100  /* LOCKS */ 
#define CMD_LOCK_CONSTRUCTION_OFF               0x1a0f0200  /* LOCKS */ 
#define CMD_LOCK_CONSTRUCTION_TOGGLE            0x1a0f0300  /* LOCKS */ 
#define CMD_LOCK_ISOMETRIC                      0x1a100000  /* LOCKS */ 
#define CMD_LOCK_ISOMETRIC_ON                   0x1a100100  /* LOCKS */ 
#define CMD_LOCK_ISOMETRIC_OFF                  0x1a100200  /* LOCKS */ 
#define CMD_LOCK_ISOMETRIC_TOGGLE               0x1a100300  /* LOCKS */ 
#define CMD_LOCK_ASSOCIATION                    0x1a110000  /* LOCKS */ 
#define CMD_LOCK_ASSOCIATION_ON                 0x1a110100  /* LOCKS */ 
#define CMD_LOCK_ASSOCIATION_OFF                0x1a110200  /* LOCKS */ 
#define CMD_LOCK_ASSOCIATION_TOGGLE             0x1a110300  /* LOCKS */ 
#define CMD_CHANGE                              0x1b000000  /* MANIPULATION */ 
#define CMD_CHANGE_COLOR                        0x1b010000  /* MANIPULATION */ 
#define CMD_CHANGE_STYLE                        0x1b020000  /* MANIPULATION */ 
#define CMD_CHANGE_WEIGHT                       0x1b030000  /* MANIPULATION */ 
#define CMD_CHANGE_SYMBOLOGY                    0x1b040000  /* MANIPULATION */ 
#define CMD_CHANGE_AREA                         0x1b050000  /* MANIPULATION */ 
#define CMD_CHANGE_FILL                         0x1b070000  /* MANIPULATION */ 
#define CMD_CHANGE_LEVEL                        0x1b080000  /* MANIPULATION */ 
#define CMD_CHANGE_CLASS                        0x1b090000  /* MANIPULATION */ 
#define CMD_CHANGE_LOCK                         0x1b0a0000  /* MANIPULATION */ 
#define CMD_CHANGE_UNLOCK                       0x1b0b0000  /* MANIPULATION */ 
#define CMD_CHANGE_DIMENSION                    0x1b0d0000  /* MANIPULATION */ 
#define CMD_CHANGE_DIMENSION_SYMBOLOGY          0x1b0d0100  /* MANIPULATION */ 
#define CMD_CHANGE_DIMENSION_SYMBOLOGY_ALTERNATE 0x1b0d0110  /* MANIPULATION */ 
#define CMD_CHANGE_DIMENSION_SYMBOLOGY_STANDARD 0x1b0d0120  /* MANIPULATION */ 
#define CMD_CHANGE_DIMENSION_VIEW               0x1b0d0200  /* MANIPULATION */ 
#define CMD_CHANGE_MLINE                        0x1b0e0000  /* MANIPULATION */ 
#define CMD_CONSTRUCT                           0x1c000000  /* PLACEMENT */ 
#define CMD_CONSTRUCT_BISECTOR                  0x1c010000  /* PLACEMENT */ 
#define CMD_CONSTRUCT_BISECTOR_ANGLE            0x1c010100  /* PLACEMENT */ 
#define CMD_CONSTRUCT_BISECTOR_LINE             0x1c010200  /* PLACEMENT */ 
#define CMD_CONSTRUCT_LINE                      0x1c020000  /* PLACEMENT */ 
#define CMD_CONSTRUCT_LINE_AA                   0x1c020100  /* PLACEMENT */ 
#define CMD_CONSTRUCT_LINE_AA_1                 0x1c020110  /* PLACEMENT */ 
#define CMD_CONSTRUCT_LINE_AA_2                 0x1c020120  /* PLACEMENT */ 
#define CMD_CONSTRUCT_LINE_AA_2_DEFAULT         0x1c020121  /* PLACEMENT */ 
#define CMD_CONSTRUCT_LINE_AA_3                 0x1c020130  /* PLACEMENT */ 
#define CMD_CONSTRUCT_LINE_AA_4                 0x1c020140  /* PLACEMENT */ 
#define CMD_CONSTRUCT_LINE_AA_4_DEFAULT         0x1c020141  /* PLACEMENT */ 
#define CMD_CONSTRUCT_LINE_MINIMUM              0x1c020200  /* PLACEMENT */ 
#define CMD_CONSTRUCT_TANGENT                   0x1c030000  /* PLACEMENT */ 
#define CMD_CONSTRUCT_TANGENT_FROM              0x1c030100  /* PLACEMENT */ 
#define CMD_CONSTRUCT_TANGENT_TO                0x1c030200  /* PLACEMENT */ 
#define CMD_CONSTRUCT_TANGENT_CIRCLE            0x1c030300  /* PLACEMENT */ 
#define CMD_CONSTRUCT_TANGENT_CIRCLE_1          0x1c030310  /* PLACEMENT */ 
#define CMD_CONSTRUCT_TANGENT_CIRCLE_3          0x1c030330  /* PLACEMENT */ 
#define CMD_CONSTRUCT_TANGENT_BETWEEN           0x1c030400  /* PLACEMENT */ 
#define CMD_CONSTRUCT_TANGENT_PERPENDICULAR     0x1c030500  /* PLACEMENT */ 
#define CMD_CONSTRUCT_TANGENT_ARC               0x1c030600  /* PLACEMENT */ 
#define CMD_CONSTRUCT_TANGENT_ARC_1             0x1c030610  /* PLACEMENT */ 
#define CMD_CONSTRUCT_TANGENT_ARC_3             0x1c030630  /* PLACEMENT */ 
#define CMD_CONSTRUCT_PERPENDICULAR             0x1c040000  /* PLACEMENT */ 
#define CMD_CONSTRUCT_PERPENDICULAR_FROM        0x1c040100  /* PLACEMENT */ 
#define CMD_CONSTRUCT_PERPENDICULAR_TO          0x1c040200  /* PLACEMENT */ 
#define CMD_CONSTRUCT_POINT                     0x1c050000  /* PLACEMENT */ 
#define CMD_CONSTRUCT_POINT_INTERSECTION        0x1c050100  /* PLACEMENT */ 
#define CMD_CONSTRUCT_POINT_PROJECT             0x1c050200  /* PLACEMENT */ 
#define CMD_CONSTRUCT_POINT_BETWEEN             0x1c050300  /* PLACEMENT */ 
#define CMD_CONSTRUCT_POINT_BETWEEN_DEFAULT     0x1c050310  /* PLACEMENT */ 
#define CMD_CONSTRUCT_POINT_ALONG               0x1c050400  /* PLACEMENT */ 
#define CMD_CONSTRUCT_POINT_ALONG_DEFAULT       0x1c050410  /* PLACEMENT */ 
#define CMD_CONSTRUCT_POINT_DISTANCE            0x1c050500  /* PLACEMENT */ 
#define CMD_CONSTRUCT_POINT_DISTANCE_DEFAULT    0x1c050510  /* PLACEMENT */ 
#define CMD_FILEDESIGN                          0x1d000000  /* FILEDESIGN */ 
#define CMD_MODIFY                              0x1e000000  /* MANIPULATION */ 
#define CMD_MODIFY_FENCE                        0x1e010000  /* FENCE */ 
#define CMD_MODIFY_ELEMENT                      0x1e020000  /* MANIPULATION */ 
#define CMD_MODIFY_ARC                          0x1e030000  /* MANIPULATION */ 
#define CMD_MODIFY_ARC_RADIUS                   0x1e030100  /* MANIPULATION */ 
#define CMD_MODIFY_ARC_ANGLE                    0x1e030200  /* MANIPULATION */ 
#define CMD_MODIFY_ARC_AXIS                     0x1e030300  /* MANIPULATION */ 
#define CMD_MODIFY_TEXT                         0x1e040000  /* MANIPULATION */ 
#define CMD_COMPRESS                            0x1f000000  /* COMPRESS */ 
#define CMD_COMPRESS_DESIGN                     0x1f010000  /* COMPRESS */ 
#define CMD_COMPRESS_DESIGN_CONFIRM             0x1f010100  /* COMPRESS */ 
#define CMD_COMPRESS_LIBRARY                    0x1f020000  /* CELLLIB */ 
#define CMD_FENCE                               0x20000000  /* FENCE */ 
#define CMD_FENCE_MOVE                          0x20010000  /* FENCE */ 
#define CMD_FENCE_COPY                          0x20020000  /* FENCE */ 
#define CMD_FENCE_DELETE                        0x20030000  /* FENCE */ 
#define CMD_FENCE_ROTATE                        0x20040000  /* FENCE */ 
#define CMD_FENCE_ROTATE_ORIGINAL               0x20040100  /* FENCE */ 
#define CMD_FENCE_ROTATE_COPY                   0x20040200  /* FENCE */ 
#define CMD_FENCE_SCALE                         0x20050000  /* FENCE */ 
#define CMD_FENCE_SCALE_ORIGINAL                0x20050100  /* FENCE */ 
#define CMD_FENCE_SCALE_COPY                    0x20050200  /* FENCE */ 
#define CMD_FENCE_CHANGE                        0x20060000  /* FENCE */ 
#define CMD_FENCE_CHANGE_COLOR                  0x20060100  /* FENCE */ 
#define CMD_FENCE_CHANGE_STYLE                  0x20060200  /* FENCE */ 
#define CMD_FENCE_CHANGE_WEIGHT                 0x20060300  /* FENCE */ 
#define CMD_FENCE_CHANGE_SYMBOLOGY              0x20060400  /* FENCE */ 
#define CMD_FENCE_CHANGE_LEVEL                  0x20060800  /* FENCE */ 
#define CMD_FENCE_CHANGE_CLASS                  0x20060900  /* FENCE */ 
#define CMD_FENCE_CHANGE_LOCK                   0x20060a00  /* FENCE */ 
#define CMD_FENCE_CHANGE_UNLOCK                 0x20060b00  /* FENCE */ 
#define CMD_FENCE_MIRROR                        0x20070000  /* FENCE */ 
#define CMD_FENCE_MIRROR_ORIGINAL               0x20070100  /* FENCE */ 
#define CMD_FENCE_MIRROR_ORIGINAL_HORIZONTAL    0x20070110  /* FENCE */ 
#define CMD_FENCE_MIRROR_ORIGINAL_VERTICAL      0x20070120  /* FENCE */ 
#define CMD_FENCE_MIRROR_ORIGINAL_LINE          0x20070130  /* FENCE */ 
#define CMD_FENCE_MIRROR_COPY                   0x20070200  /* FENCE */ 
#define CMD_FENCE_MIRROR_COPY_HORIZONTAL        0x20070210  /* FENCE */ 
#define CMD_FENCE_MIRROR_COPY_VERTICAL          0x20070220  /* FENCE */ 
#define CMD_FENCE_MIRROR_COPY_LINE              0x20070230  /* FENCE */ 
#define CMD_FENCE_REPORT                        0x20080000  /* FENCE */ 
#define CMD_FENCE_ATTACH                        0x20090000  /* FENCE */ 
#define CMD_FENCE_DETACH                        0x200a0000  /* FENCE */ 
#define CMD_FENCE_WSET                          0x200b0000  /* FENCE */ 
#define CMD_FENCE_WSET_ADD                      0x200b0100  /* FENCE */ 
#define CMD_FENCE_WSET_COPY                     0x200b0200  /* FENCE */ 
#define CMD_FENCE_FILE                          0x200c0000  /* FENCE */ 
#define CMD_FENCE_SEPARATE                      0x200d0000  /* FENCE */ 
#define CMD_FENCE_LOCATE                        0x200e0000  /* FENCE */ 
#define CMD_FENCE_TRANSFORM                     0x200f0000  /* FENCE */ 
#define CMD_FENCE_STRETCH                       0x20100000  /* FENCE */ 
#define CMD_FENCE_SPIN                          0x20110000  /* FENCE */ 
#define CMD_FENCE_SPIN_ORIGINAL                 0x20110100  /* FENCE */ 
#define CMD_FENCE_SPIN_COPY                     0x20110200  /* FENCE */ 
#define CMD_FENCE_ARRAY                         0x20120000  /* FENCE */ 
#define CMD_FENCE_ARRAY_RECTANGULAR             0x20120100  /* FENCE */ 
#define CMD_FENCE_ARRAY_RECTANGULAR_DEFAULT     0x20120110  /* FENCE */ 
#define CMD_FENCE_ARRAY_POLAR                   0x20120200  /* FENCE */ 
#define CMD_FENCE_ARRAY_POLAR_DEFAULT           0x20120210  /* FENCE */ 
#define CMD_FENCE_DROP                          0x20130000  /* FENCE */ 
#define CMD_FENCE_DROP_COMPLEX                  0x20130100  /* FENCE */ 
#define CMD_FENCE_DROP_MLINE                    0x20130200  /* FENCE */ 
#define CMD_FENCE_DROP_DIMENSION                0x20130300  /* FENCE */ 
#define CMD_FENCE_DROP_ASSOCIATION              0x20130400  /* FENCE */ 
#define CMD_FENCE_LOAD                          0x20140000  /* FENCE */ 
#define CMD_FENCE_SURFACE                       0x20150000  /* FENCE */ 
#define CMD_FENCE_SURFACE_PROJECTION            0x20150100  /* FENCE */ 
#define CMD_FENCE_SURFACE_REVOLUTION            0x20150200  /* FENCE */ 
#define CMD_FENCE_SURFACE_REVOLUTION_DEFAULT    0x20150210  /* FENCE */ 
#define CMD_FENCE_FREEZE                        0x20160000  /* FENCE */ 
#define CMD_FENCE_THAW                          0x20170000  /* FENCE */ 
#define CMD_SCALE                               0x21000000  /* MANIPULATION */ 
#define CMD_SCALE_ORIGINAL                      0x21010000  /* MANIPULATION */ 
#define CMD_SCALE_COPY                          0x21020000  /* MANIPULATION */ 
#define CMD_MIRROR                              0x22000000  /* MANIPULATION */ 
#define CMD_MIRROR_ORIGINAL                     0x22010000  /* MANIPULATION */ 
#define CMD_MIRROR_ORIGINAL_HORIZONTAL          0x22010100  /* MANIPULATION */ 
#define CMD_MIRROR_ORIGINAL_VERTICAL            0x22010200  /* MANIPULATION */ 
#define CMD_MIRROR_ORIGINAL_LINE                0x22010300  /* MANIPULATION */ 
#define CMD_MIRROR_COPY                         0x22020000  /* MANIPULATION */ 
#define CMD_MIRROR_COPY_HORIZONTAL              0x22020100  /* MANIPULATION */ 
#define CMD_MIRROR_COPY_VERTICAL                0x22020200  /* MANIPULATION */ 
#define CMD_MIRROR_COPY_LINE                    0x22020300  /* MANIPULATION */ 
#define CMD_PAUSE                               0x23000000  /* INPUT */ 
#define CMD_SELVIEW                             0x24000000  /* INPUT */ 
#define CMD_FILLET                              0x25000000  /* MANIPULATION */ 
#define CMD_FILLET_SINGLE                       0x25010000  /* MANIPULATION */ 
#define CMD_FILLET_MODIFY                       0x25020000  /* MANIPULATION */ 
#define CMD_FILLET_NOMODIFY                     0x25030000  /* PLACEMENT */ 
#define CMD_DROP                                0x26000000  /* MANIPULATION */ 
#define CMD_DROP_COMPLEX                        0x26010000  /* MANIPULATION */ 
#define CMD_DROP_STRING                         0x26020000  /* MANIPULATION */ 
#define CMD_DROP_TEXT                           0x26030000  /* MANIPULATION */ 
#define CMD_DROP_ASSOCIATION                    0x26040000  /* MANIPULATION */ 
#define CMD_DROP_SHARECELL                      0x26050000  /* MANIPULATION */ 
#define CMD_DROP_DIMENSION                      0x26060000  /* MANIPULATION */ 
#define CMD_DROP_MLINE                          0x26070000  /* MANIPULATION */ 
#define CMD_INSERT                              0x27000000  /* MANIPULATION */ 
#define CMD_INSERT_VERTEX                       0x27010000  /* MANIPULATION */ 
#define CMD_NOECHO                              0x28000000  /* PARAMETERS */ 
#define CMD_ECHO                                0x29000000  /* PARAMETERS */ 
#define CMD_INCLUDE                             0x2a000000  /* PLACEMENT */ 
#define CMD_EDIT                                0x2b000000  /* MANIPULATION */ 
#define CMD_EDIT_SINGLE                         0x2b010000  /* MANIPULATION */ 
#define CMD_EDIT_SINGLE_DIALOG                  0x2b010100  /* MANIPULATION */ 
#define CMD_EDIT_AUTO                           0x2b020000  /* MANIPULATION */ 
#define CMD_EDIT_AUTO_DIALOG                    0x2b020100  /* MANIPULATION */ 
#define CMD_EDIT_AE                             0x2b030000  /* MANIPULATION */ 
#define CMD_EDIT_TEXT                           0x2b040000  /* MANIPULATION */ 
#define CMD_REFERENCE                           0x2c000000  /* REFERENCE */ 
#define CMD_REFERENCE_ROTATE                    0x2c010000  /* REFERENCE */ 
#define CMD_REFERENCE_ROTATE_DEFAULT            0x2c010100  /* REFERENCE */ 
#define CMD_REFERENCE_SCALE                     0x2c020000  /* REFERENCE */ 
#define CMD_REFERENCE_SCALE_DEFAULT             0x2c020100  /* REFERENCE */ 
#define CMD_REFERENCE_MOVE                      0x2c030000  /* REFERENCE */ 
#define CMD_REFERENCE_DETACH                    0x2c040000  /* REFERENCE */ 
#define CMD_REFERENCE_LEVELS                    0x2c050000  /* REFERENCE */ 
#define CMD_REFERENCE_LEVELS_ON                 0x2c050100  /* REFERENCE */ 
#define CMD_REFERENCE_LEVELS_OFF                0x2c050200  /* REFERENCE */ 
#define CMD_REFERENCE_LEVELS_TOGGLE             0x2c050300  /* REFERENCE */ 
#define CMD_REFERENCE_SNAP                      0x2c060000  /* REFERENCE */ 
#define CMD_REFERENCE_SNAP_ON                   0x2c060100  /* REFERENCE */ 
#define CMD_REFERENCE_SNAP_OFF                  0x2c060200  /* REFERENCE */ 
#define CMD_REFERENCE_SNAP_TOGGLE               0x2c060300  /* REFERENCE */ 
#define CMD_REFERENCE_LOCATE                    0x2c070000  /* REFERENCE */ 
#define CMD_REFERENCE_LOCATE_ON                 0x2c070100  /* REFERENCE */ 
#define CMD_REFERENCE_LOCATE_OFF                0x2c070200  /* REFERENCE */ 
#define CMD_REFERENCE_LOCATE_TOGGLE             0x2c070300  /* REFERENCE */ 
#define CMD_REFERENCE_DISPLAY                   0x2c080000  /* REFERENCE */ 
#define CMD_REFERENCE_DISPLAY_ON                0x2c080100  /* REFERENCE */ 
#define CMD_REFERENCE_DISPLAY_OFF               0x2c080200  /* REFERENCE */ 
#define CMD_REFERENCE_DISPLAY_TOGGLE            0x2c080300  /* REFERENCE */ 
#define CMD_REFERENCE_CLIP                      0x2c090000  /* REFERENCE */ 
#define CMD_REFERENCE_CLIP_BOUNDARY             0x2c090100  /* REFERENCE */ 
#define CMD_REFERENCE_CLIP_FRONT                0x2c090200  /* REFERENCE */ 
#define CMD_REFERENCE_CLIP_BACK                 0x2c090300  /* REFERENCE */ 
#define CMD_REFERENCE_CLIP_MASK                 0x2c090400  /* REFERENCE */ 
#define CMD_REFERENCE_ATTACH                    0x2c0a0000  /* REFERENCE */ 
#define CMD_REFERENCE_ATTACH_DEFAULT            0x2c0a0100  /* REFERENCE */ 
#define CMD_REFERENCE_MIRROR                    0x2c0b0000  /* REFERENCE */ 
#define CMD_REFERENCE_MIRROR_HORIZONTAL         0x2c0b0100  /* REFERENCE */ 
#define CMD_REFERENCE_MIRROR_VERTICAL           0x2c0b0200  /* REFERENCE */ 
#define CMD_REFERENCE_RELOAD                    0x2c0c0000  /* REFERENCE */ 
#define CMD_REFERENCE_FIT                       0x2c0d0000  /* REFERENCE */ 
#define CMD_REFERENCE_UPDATE                    0x2c0e0000  /* REFERENCE */ 
#define CMD_BACKUP                              0x2d000000  /* FILEDESIGN */ 
#define CMD_FREE                                0x2e000000  /* SHOW */ 
#define CMD_EXTEND                              0x2f000000  /* MANIPULATION */ 
#define CMD_EXTEND_LINE                         0x2f010000  /* MANIPULATION */ 
#define CMD_EXTEND_LINE_KEYIN                   0x2f010100  /* MANIPULATION */ 
#define CMD_EXTEND_LINE_2                       0x2f010200  /* MANIPULATION */ 
#define CMD_EXTEND_LINE_INTERSECTION            0x2f010300  /* MANIPULATION */ 
#define CMD_EXTEND_LINE_DISTANCE                0x2f010400  /* MANIPULATION */ 
#define CMD_EXTEND_ELEMENT                      0x2f010000  /* MANIPULATION */ 
#define CMD_EXTEND_ELEMENT_2                    0x2f010200  /* MANIPULATION */ 
#define CMD_EXTEND_ELEMENT_INTERSECTION         0x2f010300  /* MANIPULATION */ 
#define CMD_TRESET                              0x30000000  /* INPUT */ 
#define CMD_JUSTIFY                             0x31000000  /* MANIPULATION */ 
#define CMD_JUSTIFY_LEFT                        0x31010000  /* MANIPULATION */ 
#define CMD_JUSTIFY_CENTER                      0x31020000  /* MANIPULATION */ 
#define CMD_JUSTIFY_RIGHT                       0x31030000  /* MANIPULATION */ 
#define CMD_IDENTIFY                            0x32000000  /* SHOW */ 
#define CMD_IDENTIFY_CELL                       0x32010000  /* SHOW */ 
#define CMD_IDENTIFY_TEXT                       0x32020000  /* SHOW */ 
#define CMD_SELECT                              0x33000000  /* PLACEMENT */ 
#define CMD_SELECT_CELL                         0x33010000  /* PLACEMENT */ 
#define CMD_SELECT_CELL_ABSOLUTE                0x33010100  /* PLACEMENT */ 
#define CMD_SELECT_CELL_ABSOLUTE_TMATRX         0x33010110  /* PLACEMENT */ 
#define CMD_SELECT_CELL_RELATIVE                0x33010200  /* PLACEMENT */ 
#define CMD_SELECT_CELL_RELATIVE_TMATRX         0x33010210  /* PLACEMENT */ 
#define CMD_DEFINE                              0x34000000  /* VIEWPARAM */ 
#define CMD_DEFINE_CELL                         0x34010000  /* VIEWPARAM */ 
#define CMD_DEFINE_CELL_ORIGIN                  0x34010100  /* VIEWPARAM */ 
#define CMD_DEFINE_CELL_ATTRIBUTES              0x34010200  /* VIEWPARAM */ 
#define CMD_DEFINE_AE                           0x34020000  /* DATABASE */ 
#define CMD_DEFINE_SEARCH                       0x34030000  /* DATABASE */ 
#define CMD_DEFINE_ACS                          0x34040000  /* VIEWING */ 
#define CMD_DEFINE_ACS_VIEW                     0x34040100  /* VIEWING */ 
#define CMD_DEFINE_ACS_VIEW_RECTANGULAR         0x34040110  /* VIEWING */ 
#define CMD_DEFINE_ACS_VIEW_CYLINDRICAL         0x34040120  /* VIEWING */ 
#define CMD_DEFINE_ACS_VIEW_SPHERICAL           0x34040130  /* VIEWING */ 
#define CMD_DEFINE_ACS_VIEW_DEFAULT             0x34040140  /* VIEWING */ 
#define CMD_DEFINE_ACS_ELEMENT                  0x34040200  /* VIEWING */ 
#define CMD_DEFINE_ACS_ELEMENT_RECTANGULAR      0x34040210  /* VIEWING */ 
#define CMD_DEFINE_ACS_ELEMENT_CYLINDRICAL      0x34040220  /* VIEWING */ 
#define CMD_DEFINE_ACS_ELEMENT_SPHERICAL        0x34040230  /* VIEWING */ 
#define CMD_DEFINE_ACS_ELEMENT_DEFAULT          0x34040240  /* VIEWING */ 
#define CMD_DEFINE_ACS_POINTS                   0x34040300  /* VIEWING */ 
#define CMD_DEFINE_ACS_POINTS_RECTANGULAR       0x34040310  /* VIEWING */ 
#define CMD_DEFINE_ACS_POINTS_CYLINDRICAL       0x34040320  /* VIEWING */ 
#define CMD_DEFINE_ACS_POINTS_SPHERICAL         0x34040330  /* VIEWING */ 
#define CMD_DEFINE_ACS_POINTS_DEFAULT           0x34040340  /* VIEWING */ 
#define CMD_DEFINE_NORTH                        0x34050000  /* VIEWING */ 
#define CMD_DEFINE_LIGHTS                       0x34060000  /* VIEWING */ 
#define CMD_DEFINE_MATERIALS                    0x34070000  /* VIEWING */ 
#define CMD_CREATE                              0x35000000  /* MANIPULATION */ 
#define CMD_CREATE_CELL                         0x35010000  /* CELLLIB */ 
#define CMD_CREATE_CHAIN                        0x35020000  /* MANIPULATION */ 
#define CMD_CREATE_CHAIN_EOF                    0x35020100  /* MANIPULATION */ 
#define CMD_CREATE_CHAIN_MANUAL                 0x35020200  /* MANIPULATION */ 
#define CMD_CREATE_CHAIN_AUTOMATIC              0x35020300  /* MANIPULATION */ 
#define CMD_CREATE_SHAPE                        0x35030000  /* MANIPULATION */ 
#define CMD_CREATE_SHAPE_EOF                    0x35030100  /* MANIPULATION */ 
#define CMD_CREATE_SHAPE_MANUAL                 0x35030200  /* MANIPULATION */ 
#define CMD_CREATE_SHAPE_AUTOMATIC              0x35030300  /* MANIPULATION */ 
#define CMD_CREATE_SHAPE_AUTOMATIC_DEFAULT      0x35030310  /* MANIPULATION */ 
#define CMD_CREATE_ENTITY                       0x35040000  /* DATABASE */ 
#define CMD_CREATE_LIBRARY                      0x35050000  /* CELLLIB */ 
#define CMD_CREATE_DRAWING                      0x35060000  /* NEWFILE */ 
#define CMD_RENAME                              0x36000000  /* CELLLIB */ 
#define CMD_RENAME_CELL                         0x36010000  /* CELLLIB */ 
#define CMD_RENAME_CELL_DEFAULT                 0x36010100  /* CELLLIB */ 
#define CMD_MATRIX                              0x37000000  /* PLACEMENT */ 
#define CMD_MATRIX_CELL                         0x37010000  /* PLACEMENT */ 
#define CMD_MATRIX_CELL_DEFAULT                 0x37010100  /* PLACEMENT */ 
#define CMD_LABEL                               0x38000000  /* DIMENSION */ 
#define CMD_LABEL_LINE                          0x38010000  /* DIMENSION */ 
#define CMD_DIMENSION                           0x39000000  /* DIMENSION */ 
#define CMD_DIMENSION_PLACEMENT                 0x39010000  /* DIMENSION */ 
#define CMD_DIMENSION_PLACEMENT_AUTO            0x39010100  /* DIMENSION */ 
#define CMD_DIMENSION_PLACEMENT_MANUAL          0x39010200  /* DIMENSION */ 
#define CMD_DIMENSION_PLACEMENT_SEMIAUTO        0x39010300  /* DIMENSION */ 
#define CMD_DIMENSION_WITNESS                   0x39020000  /* DIMENSION */ 
#define CMD_DIMENSION_WITNESS_OFF               0x39020100  /* DIMENSION */ 
#define CMD_DIMENSION_WITNESS_ON                0x39020200  /* DIMENSION */ 
#define CMD_DIMENSION_WITNESS_TOGGLE            0x39020300  /* DIMENSION */ 
#define CMD_DIMENSION_WITNESS_LEFT              0x39020400  /* DIMENSION */ 
#define CMD_DIMENSION_WITNESS_LEFT_ON           0x39020410  /* DIMENSION */ 
#define CMD_DIMENSION_WITNESS_LEFT_OFF          0x39020420  /* DIMENSION */ 
#define CMD_DIMENSION_WITNESS_LEFT_TOGGLE       0x39020430  /* DIMENSION */ 
#define CMD_DIMENSION_WITNESS_RIGHT             0x39020500  /* DIMENSION */ 
#define CMD_DIMENSION_WITNESS_RIGHT_ON          0x39020510  /* DIMENSION */ 
#define CMD_DIMENSION_WITNESS_RIGHT_OFF         0x39020520  /* DIMENSION */ 
#define CMD_DIMENSION_WITNESS_RIGHT_TOGGLE      0x39020530  /* DIMENSION */ 
#define CMD_DIMENSION_WITNESS_TOP               0x39020600  /* DIMENSION */ 
#define CMD_DIMENSION_WITNESS_TOP_ON            0x39020610  /* DIMENSION */ 
#define CMD_DIMENSION_WITNESS_TOP_OFF           0x39020620  /* DIMENSION */ 
#define CMD_DIMENSION_WITNESS_TOP_TOGGLE        0x39020630  /* DIMENSION */ 
#define CMD_DIMENSION_WITNESS_BOTTOM            0x39020700  /* DIMENSION */ 
#define CMD_DIMENSION_WITNESS_BOTTOM_ON         0x39020710  /* DIMENSION */ 
#define CMD_DIMENSION_WITNESS_BOTTOM_OFF        0x39020720  /* DIMENSION */ 
#define CMD_DIMENSION_WITNESS_BOTTOM_TOGGLE     0x39020730  /* DIMENSION */ 
#define CMD_DIMENSION_JUSTIFICATION             0x39030000  /* DIMENSION */ 
#define CMD_DIMENSION_JUSTIFICATION_LEFT        0x39030100  /* DIMENSION */ 
#define CMD_DIMENSION_JUSTIFICATION_CENTER      0x39030200  /* DIMENSION */ 
#define CMD_DIMENSION_JUSTIFICATION_RIGHT       0x39030300  /* DIMENSION */ 
#define CMD_DIMENSION_TERMINATOR                0x39040000  /* DIMENSION */ 
#define CMD_DIMENSION_TERMINATOR_FIRST          0x39040100  /* DIMENSION */ 
#define CMD_DIMENSION_TERMINATOR_FIRST_OFF      0x39040110  /* DIMENSION */ 
#define CMD_DIMENSION_TERMINATOR_FIRST_ARROW    0x39040120  /* DIMENSION */ 
#define CMD_DIMENSION_TERMINATOR_FIRST_STROKE   0x39040130  /* DIMENSION */ 
#define CMD_DIMENSION_TERMINATOR_FIRST_ORIGIN   0x39040140  /* DIMENSION */ 
#define CMD_DIMENSION_TERMINATOR_LEFT           0x39040200  /* DIMENSION */ 
#define CMD_DIMENSION_TERMINATOR_LEFT_OFF       0x39040210  /* DIMENSION */ 
#define CMD_DIMENSION_TERMINATOR_LEFT_ARROW     0x39040220  /* DIMENSION */ 
#define CMD_DIMENSION_TERMINATOR_LEFT_STROKE    0x39040230  /* DIMENSION */ 
#define CMD_DIMENSION_TERMINATOR_LEFT_ORIGIN    0x39040240  /* DIMENSION */ 
#define CMD_DIMENSION_TERMINATOR_RIGHT          0x39040300  /* DIMENSION */ 
#define CMD_DIMENSION_TERMINATOR_RIGHT_OFF      0x39040310  /* DIMENSION */ 
#define CMD_DIMENSION_TERMINATOR_RIGHT_ARROW    0x39040320  /* DIMENSION */ 
#define CMD_DIMENSION_TERMINATOR_RIGHT_STROKE   0x39040330  /* DIMENSION */ 
#define CMD_DIMENSION_TERMINATOR_RIGHT_ORIGIN   0x39040340  /* DIMENSION */ 
#define CMD_DIMENSION_AXIS                      0x39050000  /* DIMENSION */ 
#define CMD_DIMENSION_AXIS_VIEW                 0x39050100  /* DIMENSION */ 
#define CMD_DIMENSION_AXIS_DRAWING              0x39050200  /* DIMENSION */ 
#define CMD_DIMENSION_AXIS_TRUE                 0x39050300  /* DIMENSION */ 
#define CMD_DIMENSION_AXIS_ARBITRARY            0x39050400  /* DIMENSION */ 
#define CMD_DIMENSION_SIZE                      0x39060000  /* DIMENSION */ 
#define CMD_DIMENSION_SIZE_ARROW                0x39060100  /* DIMENSION */ 
#define CMD_DIMENSION_SIZE_STROKE               0x39060200  /* DIMENSION */ 
#define CMD_DIMENSION_LOCATION                  0x39070000  /* DIMENSION */ 
#define CMD_DIMENSION_LOCATION_SINGLE           0x39070100  /* DIMENSION */ 
#define CMD_DIMENSION_LOCATION_STACKED          0x39070200  /* DIMENSION */ 
#define CMD_DIMENSION_LEVEL                     0x39080000  /* DIMENSION */ 
#define CMD_DIMENSION_LEVEL_ACTIVE              0x39080100  /* DIMENSION */ 
#define CMD_DIMENSION_TOLERANCE                 0x39090000  /* DIMENSION */ 
#define CMD_DIMENSION_TOLERANCE_UPPER           0x39090100  /* DIMENSION */ 
#define CMD_DIMENSION_TOLERANCE_LOWER           0x39090200  /* DIMENSION */ 
#define CMD_DIMENSION_TOLERANCE_SCALE           0x39090300  /* DIMENSION */ 
#define CMD_DIMENSION_TUTORIAL                  0x390a0000  /* DIMENSION */ 
#define CMD_DIMENSION_SCALE                     0x390b0000  /* DIMENSION */ 
#define CMD_DIMENSION_SCALE_RESET               0x390b0100  /* DIMENSION */ 
#define CMD_DIMENSION_ANGLE                     0x390c0000  /* DIMENSION */ 
#define CMD_DIMENSION_ANGLE_SIZE                0x390c0100  /* DIMENSION */ 
#define CMD_DIMENSION_ANGLE_LOCATION            0x390c0200  /* DIMENSION */ 
#define CMD_DIMENSION_ANGLE_LINES               0x390c0300  /* DIMENSION */ 
#define CMD_DIMENSION_ANGLE_X                   0x390c0400  /* DIMENSION */ 
#define CMD_DIMENSION_ANGLE_Y                   0x390c0500  /* DIMENSION */ 
#define CMD_DIMENSION_ARC                       0x390d0000  /* DIMENSION */ 
#define CMD_DIMENSION_ARC_SIZE                  0x390d0100  /* DIMENSION */ 
#define CMD_DIMENSION_ARC_LOCATION              0x390d0200  /* DIMENSION */ 
#define CMD_DIMENSION_RADIUS                    0x390e0000  /* DIMENSION */ 
#define CMD_DIMENSION_RADIUS_POINT              0x390e0100  /* DIMENSION */ 
#define CMD_DIMENSION_RADIUS_EXTENDED           0x390e0200  /* DIMENSION */ 
#define CMD_DIMENSION_DIAMETER                  0x390f0000  /* DIMENSION */ 
#define CMD_DIMENSION_DIAMETER_POINT            0x390f0100  /* DIMENSION */ 
#define CMD_DIMENSION_DIAMETER_PARALLEL         0x390f0200  /* DIMENSION */ 
#define CMD_DIMENSION_DIAMETER_PERPENDICULAR    0x390f0300  /* DIMENSION */ 
#define CMD_DIMENSION_DIAMETER_EXTENDED         0x390f0400  /* DIMENSION */ 
#define CMD_DIMENSION_UNITS                     0x39100000  /* DIMENSION */ 
#define CMD_DIMENSION_UNITS_LENGTH              0x39100100  /* DIMENSION */ 
#define CMD_DIMENSION_UNITS_DEGREES             0x39100200  /* DIMENSION */ 
#define CMD_DIMENSION_FILE                      0x39110000  /* DIMENSION */ 
#define CMD_DIMENSION_FILE_ACTIVE               0x39110100  /* DIMENSION */ 
#define CMD_DIMENSION_FILE_REFERENCE            0x39110200  /* DIMENSION */ 
#define CMD_DIMENSION_ORDINATE                  0x39120000  /* DIMENSION */ 
#define CMD_DIMENSION_COLOR                     0x39130000  /* DIMENSION */ 
#define CMD_DIMENSION_COLOR_WHITE               0x39130100  /* DIMENSION */ 
#define CMD_DIMENSION_COLOR_BLUE                0x39130200  /* DIMENSION */ 
#define CMD_DIMENSION_COLOR_GREEN               0x39130300  /* DIMENSION */ 
#define CMD_DIMENSION_COLOR_RED                 0x39130400  /* DIMENSION */ 
#define CMD_DIMENSION_COLOR_YELLOW              0x39130500  /* DIMENSION */ 
#define CMD_DIMENSION_COLOR_VIOLET              0x39130600  /* DIMENSION */ 
#define CMD_DIMENSION_COLOR_ORANGE              0x39130700  /* DIMENSION */ 
#define CMD_DIMENSION_COLOR_CSELECT             0x39130800  /* DIMENSION */ 
#define CMD_DIMENSION_WEIGHT                    0x39140000  /* DIMENSION */ 
#define CMD_DIMENSION_WEIGHT_ACTIVE             0x39140100  /* DIMENSION */ 
#define CMD_DIMENSION_TEXT                      0x39150000  /* DIMENSION */ 
#define CMD_DIMENSION_TEXT_COLOR                0x39150100  /* DIMENSION */ 
#define CMD_DIMENSION_TEXT_COLOR_WHITE          0x39150110  /* DIMENSION */ 
#define CMD_DIMENSION_TEXT_COLOR_BLUE           0x39150120  /* DIMENSION */ 
#define CMD_DIMENSION_TEXT_COLOR_GREEN          0x39150130  /* DIMENSION */ 
#define CMD_DIMENSION_TEXT_COLOR_RED            0x39150140  /* DIMENSION */ 
#define CMD_DIMENSION_TEXT_COLOR_YELLOW         0x39150150  /* DIMENSION */ 
#define CMD_DIMENSION_TEXT_COLOR_VIOLET         0x39150160  /* DIMENSION */ 
#define CMD_DIMENSION_TEXT_COLOR_ORANGE         0x39150170  /* DIMENSION */ 
#define CMD_DIMENSION_TEXT_COLOR_CSELECT        0x39150180  /* DIMENSION */ 
#define CMD_DIMENSION_TEXT_WEIGHT               0x39150200  /* DIMENSION */ 
#define CMD_DIMENSION_TEXT_WEIGHT_ACTIVE        0x39150210  /* DIMENSION */ 
#define CMD_DIMENSION_TEXT_BOX                  0x39150300  /* DIMENSION */ 
#define CMD_DIMENSION_TEXT_BOX_ON               0x39150310  /* DIMENSION */ 
#define CMD_DIMENSION_TEXT_BOX_OFF              0x39150320  /* DIMENSION */ 
#define CMD_DIMENSION_TEXT_BOX_TOGGLE           0x39150330  /* DIMENSION */ 
#define CMD_DIMENSION_TEXT_CAPSULE              0x39150400  /* DIMENSION */ 
#define CMD_DIMENSION_TEXT_CAPSULE_ON           0x39150410  /* DIMENSION */ 
#define CMD_DIMENSION_TEXT_CAPSULE_OFF          0x39150420  /* DIMENSION */ 
#define CMD_DIMENSION_TEXT_CAPSULE_TOGGLE       0x39150430  /* DIMENSION */ 
#define CMD_DIMENSION_FONT                      0x39160000  /* DIMENSION */ 
#define CMD_DIMENSION_FONT_ACTIVE               0x39160100  /* DIMENSION */ 
#define CMD_DIMENSION_LINEAR                    0x39170000  /* DIMENSION */ 
#define CMD_DIMENSION_CENTER                    0x39180000  /* DIMENSION */ 
#define CMD_DIMENSION_CENTER_SIZE               0x39180100  /* DIMENSION */ 
#define CMD_DIMENSION_CENTER_MARK               0x39180200  /* DIMENSION */ 
#define CMD_DIMENSION_CENTER_OFF                0x39180300  /* DIMENSION */ 
#define CMD_DIMENSION_CENTER_ON                 0x39180400  /* DIMENSION */ 
#define CMD_DIMENSION_PRE                       0x39190000  /* DIMENSION */ 
#define CMD_DIMENSION_PRE_OFF                   0x39190100  /* DIMENSION */ 
#define CMD_DIMENSION_PRE_DIAMETER              0x39190200  /* DIMENSION */ 
#define CMD_DIMENSION_PRE_RADIUS                0x39190300  /* DIMENSION */ 
#define CMD_DIMENSION_PRE_SQUARE                0x39190400  /* DIMENSION */ 
#define CMD_DIMENSION_POST                      0x391a0000  /* DIMENSION */ 
#define CMD_DIMENSION_POST_OFF                  0x391a0100  /* DIMENSION */ 
#define CMD_DIMENSION_POST_DIAMETER             0x391a0200  /* DIMENSION */ 
#define CMD_DIMENSION_POST_RADIUS               0x391a0300  /* DIMENSION */ 
#define CMD_DIMENSION_POST_SQUARE               0x391a0400  /* DIMENSION */ 
#define CMD_DIMENSION_STACKED                   0x391b0000  /* DIMENSION */ 
#define CMD_DIMENSION_STACKED_ON                0x391b0100  /* DIMENSION */ 
#define CMD_DIMENSION_STACKED_OFF               0x391b0200  /* DIMENSION */ 
#define CMD_DIMENSION_STACKED_TOGGLE            0x391b0300  /* DIMENSION */ 
#define CMD_DIMENSION_ARCLENGTH                 0x391c0000  /* DIMENSION */ 
#define CMD_DIMENSION_ARCLENGTH_ON              0x391c0100  /* DIMENSION */ 
#define CMD_DIMENSION_ARCLENGTH_OFF             0x391c0200  /* DIMENSION */ 
#define CMD_DIMENSION_ARCLENGTH_TOGGLE          0x391c0300  /* DIMENSION */ 
#define CMD_DIMENSION_VERTICAL                  0x391d0000  /* DIMENSION */ 
#define CMD_DIMENSION_VERTICAL_OFF              0x391d0100  /* DIMENSION */ 
#define CMD_DIMENSION_VERTICAL_MIXED            0x391d0200  /* DIMENSION */ 
#define CMD_DIMENSION_VERTICAL_ON               0x391d0300  /* DIMENSION */ 
#define CMD_DIMENSION_UPDATE                    0x391e0000  /* DIMENSION */ 
#define CMD_DIMENSION_ELEMENT                   0x391f0000  /* DIMENSION */ 
#define CMD_REPLACE                             0x3a000000  /* MANIPULATION */ 
#define CMD_REPLACE_CELL                        0x3a010000  /* MANIPULATION */ 
#define CMD_REPLACE_CELL_DEFAULT                0x3a010100  /* MANIPULATION */ 
#define CMD_RESET                               0x3b000000  /* INPUT */ 
#define CMD_INCREMENT                           0x3c000000  /* MANIPULATION */ 
#define CMD_INCREMENT_TEXT                      0x3c010000  /* MANIPULATION */ 
#define CMD_INCREMENT_ED                        0x3c020000  /* MANIPULATION */ 
#define CMD_GROUP                               0x3d000000  /* MANIPULATION */ 
#define CMD_GROUP_ADD                           0x3d010000  /* MANIPULATION */ 
#define CMD_GROUP_DROP                          0x3d020000  /* MANIPULATION */ 
#define CMD_GROUP_SELECTION                     0x3d030000  /* MANIPULATION */ 
#define CMD_GROUP_HOLES                         0x3d040000  /* MANIPULATION */ 
#define CMD_SURFACE                             0x3e000000  /* PLACEMENT */ 
#define CMD_SURFACE_PROJECTION                  0x3e010000  /* PLACEMENT */ 
#define CMD_SURFACE_REVOLUTION                  0x3e020000  /* PLACEMENT */ 
#define CMD_USERCOMMAND                         0x3f000000  /* USERCOMMAND */ 
#define CMD_NULL                                0x40000000  /* class 0 */ 
#define CMD_LOCELE                              0x41000000  /* LOCATE */ 
#define CMD_DIGITIZER                           0x42000000  /* VIEWPARAM */ 
#define CMD_DIGITIZER_PARTITION                 0x42010000  /* VIEWPARAM */ 
#define CMD_DIGITIZER_SETUP                     0x42020000  /* VIEWPARAM */ 
#define CMD_DIGITIZER_BUTTONS                   0x42040000  /* VIEWPARAM */ 
#define CMD_DIGITIZER_DOWNLOAD                  0x42050000  /* VIEWPARAM */ 
#define CMD_FIND                                0x43000000  /* DATABASE */ 
#define CMD_REVIEW                              0x44000000  /* DATABASE */ 
#define CMD_DETACH                              0x45000000  /* DATABASE */ 
#define CMD_UCI                                 0x46000000  /* USERCOMMAND */ 
#define CMD_UCC                                 0x47000000  /* USERCOMMAND */ 
#define CMD_IUPDATE                             0x48000000  /* VIEWIMMEDIATE */ 
#define CMD_IUPDATE_1                           0x48010000  /* VIEWIMMEDIATE */ 
#define CMD_IUPDATE_2                           0x48020000  /* VIEWIMMEDIATE */ 
#define CMD_IUPDATE_3                           0x48030000  /* VIEWIMMEDIATE */ 
#define CMD_IUPDATE_4                           0x48040000  /* VIEWIMMEDIATE */ 
#define CMD_IUPDATE_5                           0x48050000  /* VIEWIMMEDIATE */ 
#define CMD_IUPDATE_6                           0x48060000  /* VIEWIMMEDIATE */ 
#define CMD_IUPDATE_7                           0x48070000  /* VIEWIMMEDIATE */ 
#define CMD_IUPDATE_8                           0x48080000  /* VIEWIMMEDIATE */ 
#define CMD_IUPDATE_RIGHT                       0x48090000  /* VIEWIMMEDIATE */ 
#define CMD_IUPDATE_LEFT                        0x480a0000  /* VIEWIMMEDIATE */ 
#define CMD_IUPDATE_BOTH                        0x480b0000  /* VIEWIMMEDIATE */ 
#define CMD_IUPDATE_ALL                         0x480b0000  /* VIEWIMMEDIATE */ 
#define CMD_IUPDATE_VIEW                        0x480c0000  /* VIEWING */ 
#define CMD_IUPDATE_GRID                        0x480d0000  /* VIEWIMMEDIATE */ 
#define CMD_IUPDATE_FILE                        0x480e0000  /* VIEWING */ 
#define CMD_IUPDATE_TUTORIAL                    0x480f0000  /* VIEWIMMEDIATE */ 
#define CMD_IUPDATE_REFERENCE                   0x48100000  /* VIEWING */ 
#define CMD_IUPDATE_FENCE                       0x48110000  /* VIEWIMMEDIATE */ 
#define CMD_IUPDATE_FENCE_INSIDE                0x48110100  /* VIEWIMMEDIATE */ 
#define CMD_IUPDATE_FENCE_OUTSIDE               0x48110200  /* VIEWIMMEDIATE */ 
#define CMD_VERSION                             0x49000000  /* INPUT */ 
#define CMD_WSET                                0x4a000000  /* WORKINGSET */ 
#define CMD_WSET_ADD                            0x4a010000  /* WORKINGSET */ 
#define CMD_WSET_COPY                           0x4a020000  /* WORKINGSET */ 
#define CMD_WSET_DROP                           0x4a030000  /* WORKINGSET */ 
#define CMD_ELEMENT                             0x4b000000  /* ELEMENTLIST */ 
#define CMD_ELEMENT_LIST                        0x4b010000  /* ELEMENTLIST */ 
#define CMD_HATCH                               0x4c000000  /* PLACEMENT */ 
#define CMD_CROSSHATCH                          0x4d000000  /* PLACEMENT */ 
#define CMD_TUTORIAL                            0x51000000  /* TUTORIAL */ 
#define CMD_TRANSFORM                           0x52000000  /* MANIPULATION */ 
#define CMD_DISPLAY                             0x53000000  /* SHOW */ 
#define CMD_DISPLAY_HILITE                      0x53010000  /* SHOW */ 
#define CMD_DISPLAY_ERASE                       0x53020000  /* SHOW */ 
#define CMD_DISPLAY_SET                         0x53030000  /* SHOW */ 
#define CMD_COLORTABLE                          0x54000000  /* PARAMETERS */ 
#define CMD_COLORTABLE_FILE                     0x54010000  /* PARAMETERS */ 
#define CMD_COLORTABLE_DEFAULT                  0x54020000  /* PARAMETERS */ 
#define CMD_FLUSH                               0x55000000  /* FILEDESIGN */ 
#define CMD_TYPE                                0x56000000  /* SHOW */ 
#define CMD_TYPE_WAIT                           0x56010000  /* SHOW */ 
#define CMD_INDEX                               0x57000000  /* CELLLIB */ 
#define CMD_SPIN                                0x59000000  /* MANIPULATION */ 
#define CMD_SPIN_ORIGINAL                       0x59010000  /* MANIPULATION */ 
#define CMD_SPIN_COPY                           0x59020000  /* MANIPULATION */ 
#define CMD_UNDO                                0x5a000000  /* UNDO */ 
#define CMD_UNDO_ALL                            0x5a010000  /* UNDO */ 
#define CMD_UNDO_ALL_NOCONFIRM                  0x5a010100  /* UNDO */ 
#define CMD_UNDO_MARK                           0x5a020000  /* UNDO */ 
#define CMD_REDO                                0x5b000000  /* UNDO */ 
#define CMD_MARK                                0x5c000000  /* UNDO */ 
#define CMD_ARRAY                               0x5d000000  /* PLACEMENT */ 
#define CMD_ARRAY_RECTANGULAR                   0x5d010000  /* PLACEMENT */ 
#define CMD_ARRAY_POLAR                         0x5d020000  /* PLACEMENT */ 
#define CMD_CHAMFER                             0x5e000000  /* MANIPULATION */ 
#define CMD_SUBMENU                             0x5f000000  /* INPUT */ 
#define CMD_POPMENU                             0x60000000  /* INPUT */ 
#define CMD_BEEP                                0x61000000  /* INPUT */ 
#define CMD_ANALYZE                             0x62000000  /* SHOW */ 
#define CMD_DOS                                 0x64000000  /* SUBPROCESS */ 
#define CMD_CHOOSE                              0x6b000000  /* MANIPULATION */ 
#define CMD_CHOOSE_ELEMENT                      0x6b010000  /* MANIPULATION */ 
#define CMD_CHOOSE_ALL                          0x6b020000  /* MANIPULATION */ 
#define CMD_HELP                                0x70000000  /* INPUT */ 
#define CMD_HELP_CONTEXT                        0x70010000  /* INPUT */ 
#define CMD_HELP_KEYS                           0x70020000  /* INPUT */ 
#define CMD_HELP_TOPICS                         0x70030000  /* INPUT */ 
#define CMD_HELP_HELP                           0x70040000  /* INPUT */ 
#define CMD_UNGROUP                             0x71000000  /* MANIPULATION */ 
#define CMD_LOAD                                0x72000000  /* DATABASE */ 
#define CMD_LOAD_DA                             0x72010000  /* DATABASE */ 
#define CMD_GENERATE                            0x73000000  /* DATABASE */ 
#define CMD_DUPLICATE                           0x74000000  /* MANIPULATION */ 
#define CMD_START                               0x75000000  /* SUBPROCESS */ 
#define CMD_PATTERN                             0x76000000  /* PLACEMENT */ 
#define CMD_PATTERN_AREA                        0x76010000  /* PLACEMENT */ 
#define CMD_PATTERN_AREA_ELEMENT                0x76010100  /* PLACEMENT */ 
#define CMD_PATTERN_AREA_FENCE                  0x76010200  /* PLACEMENT */ 
#define CMD_PATTERN_LINE                        0x76020000  /* PLACEMENT */ 
#define CMD_PATTERN_LINE_ELEMENT                0x76020100  /* PLACEMENT */ 
#define CMD_PATTERN_LINE_SCALE                  0x76020200  /* PLACEMENT */ 
#define CMD_PATTERN_LINE_SINGLE                 0x76020300  /* PLACEMENT */ 
#define CMD_PATTERN_LINE_MULTIPLE               0x76020400  /* PLACEMENT */ 
#define CMD_DIALOG                              0x77000000  /* class 0 */ 
#define CMD_DIALOG_LOCKS                        0x77010000  /* class 0 */ 
#define CMD_DIALOG_ATTRIBUTES                   0x77030000  /* class 0 */ 
#define CMD_DIALOG_READOUT                      0x77040000  /* class 0 */ 
#define CMD_DIALOG_COMMAND                      0x77050000  /* class 0 */ 
#define CMD_DIALOG_PALETTE                      0x77060000  /* class 0 */ 
#define CMD_DIALOG_PALETTE_LINE                 0x77060100  /* class 0 */ 
#define CMD_DIALOG_PALETTE_LINESTRING           0x77060200  /* class 0 */ 
#define CMD_DIALOG_PALETTE_POLYGON              0x77060300  /* class 0 */ 
#define CMD_DIALOG_PALETTE_FILLET               0x77060400  /* class 0 */ 
#define CMD_DIALOG_PALETTE_CIRCLE               0x77060500  /* class 0 */ 
#define CMD_DIALOG_PALETTE_ARC                  0x77060700  /* class 0 */ 
#define CMD_DIALOG_PALETTE_ENTERDATA            0x77060800  /* class 0 */ 
#define CMD_DIALOG_PALETTE_TEXT                 0x77060900  /* class 0 */ 
#define CMD_DIALOG_PALETTE_POINT                0x77060a00  /* class 0 */ 
#define CMD_DIALOG_PALETTE_CELL                 0x77060b00  /* class 0 */ 
#define CMD_DIALOG_PALETTE_CHANGE               0x77060c00  /* class 0 */ 
#define CMD_DIALOG_PALETTE_COPYELEMENT          0x77060d00  /* class 0 */ 
#define CMD_DIALOG_PALETTE_MIRRORELEMENT        0x77060e00  /* class 0 */ 
#define CMD_DIALOG_PALETTE_MODIFY               0x77060f00  /* class 0 */ 
#define CMD_DIALOG_PALETTE_CHAIN                0x77061000  /* class 0 */ 
#define CMD_DIALOG_PALETTE_DROP                 0x77061100  /* class 0 */ 
#define CMD_DIALOG_PALETTE_VIEWCONTROL          0x77061200  /* class 0 */ 
#define CMD_DIALOG_PALETTE_PLACEFENCE           0x77061300  /* class 0 */ 
#define CMD_DIALOG_PALETTE_FENCECOPY            0x77061400  /* class 0 */ 
#define CMD_DIALOG_PALETTE_FENCECHANGE          0x77061500  /* class 0 */ 
#define CMD_DIALOG_PALETTE_FENCEMIRROR          0x77061600  /* class 0 */ 
#define CMD_DIALOG_PALETTE_FENCEDELETE          0x77061700  /* class 0 */ 
#define CMD_DIALOG_PALETTE_THREED               0x77061800  /* class 0 */ 
#define CMD_DIALOG_PALETTE_ACS                  0x77061900  /* class 0 */ 
#define CMD_DIALOG_PALETTE_DATABASE             0x77061a00  /* class 0 */ 
#define CMD_DIALOG_PALETTE_PATTERNING           0x77061b00  /* class 0 */ 
#define CMD_DIALOG_PALETTE_REFERENCEFILE        0x77061c00  /* class 0 */ 
#define CMD_DIALOG_PALETTE_LINEARDIMEN          0x77061f00  /* class 0 */ 
#define CMD_DIALOG_PALETTE_ANGULARDIMEN         0x77062000  /* class 0 */ 
#define CMD_DIALOG_PALETTE_RADIALDIMEN          0x77062100  /* class 0 */ 
#define CMD_DIALOG_PALETTE_MISCDIMEN            0x77062200  /* class 0 */ 
#define CMD_DIALOG_PALETTE_MEASURE              0x77062300  /* class 0 */ 
#define CMD_DIALOG_REFERENCE                    0x77070000  /* class 0 */ 
#define CMD_DIALOG_RENDER                       0x77080000  /* class 0 */ 
#define CMD_DIALOG_NAMEDVIEWS                   0x77090000  /* class 0 */ 
#define CMD_DIALOG_COORDSYS                     0x770a0000  /* class 0 */ 
#define CMD_DIALOG_KEY                          0x770c0000  /* class 0 */ 
#define CMD_DIALOG_STANDARDALERT                0x770d0000  /* class 0 */ 
#define CMD_DIALOG_DIMATTRIB                    0x770f0000  /* class 0 */ 
#define CMD_DIALOG_DIMGEOM                      0x77100000  /* class 0 */ 
#define CMD_DIALOG_DIMPLACE                     0x77110000  /* class 0 */ 
#define CMD_DIALOG_DIMSYMBOL                    0x77120000  /* class 0 */ 
#define CMD_DIALOG_DIMTEMPLATE                  0x77130000  /* class 0 */ 
#define CMD_DIALOG_DIMTERMINATORS               0x77140000  /* class 0 */ 
#define CMD_DIALOG_DIMTEXT                      0x77150000  /* class 0 */ 
#define CMD_DIALOG_DIMTOLERANCE                 0x771d0000  /* class 0 */ 
#define CMD_DIALOG_MULTILINE                    0x771e0000  /* class 0 */ 
#define CMD_DIALOG_UNITS                        0x771f0000  /* class 0 */ 
#define CMD_DIALOG_NAMEDLEVELS                  0x77200000  /* class 0 */ 
#define CMD_DIALOG_TEXTEDIT                     0x77210000  /* class 0 */ 
#define CMD_DIALOG_DATABASE                     0x77220000  /* class 0 */ 
#define CMD_DIALOG_VIEWROTATION                 0x77230000  /* class 0 */ 
#define CMD_DIALOG_CELLMAINTENANCE              0x77240000  /* class 0 */ 
#define CMD_DIALOG_ACTIVEANGLE                  0x77280000  /* class 0 */ 
#define CMD_DIALOG_REFERENCEATTACH              0x77290000  /* class 0 */ 
#define CMD_DIALOG_PLOT                         0x772a0000  /* class 0 */ 
#define CMD_DIALOG_VIEWSETTINGS                 0x772e0000  /* class 0 */ 
#define CMD_DIALOG_VIEWLEVELS                   0x772f0000  /* class 0 */ 
#define CMD_DIALOG_CMDBROWSE                    0x77300000  /* class 0 */ 
#define CMD_DIALOG_ACTIVESCALE                  0x77310000  /* class 0 */ 
#define CMD_DIALOG_ROTATEACS                    0x77350000  /* class 0 */ 
#define CMD_DIALOG_FONT                         0x77360000  /* class 0 */ 
#define CMD_DIALOG_COLOR                        0x77370000  /* class 0 */ 
#define CMD_DIALOG_LEVELSYMB                    0x77380000  /* class 0 */ 
#define CMD_DIALOG_GRID                         0x77390000  /* class 0 */ 
#define CMD_DIALOG_DGNOPTS                      0x773a0000  /* class 0 */ 
#define CMD_DIALOG_PRECISION                    0x773b0000  /* class 0 */ 
#define CMD_DIALOG_CAMERA                       0x773c0000  /* class 0 */ 
#define CMD_DIALOG_FUNCKEYS                     0x773e0000  /* class 0 */ 
#define CMD_DIALOG_TEXTSETTINGS                 0x773f0000  /* class 0 */ 
#define CMD_DIALOG_ENVIRONMENT                  0x77400000  /* class 0 */ 
#define CMD_DIALOG_MDL                          0x77410000  /* class 0 */ 
#define CMD_DIALOG_OPENFILE                     0x77440000  /* class 0 */ 
#define CMD_DIALOG_DIGITIZING                   0x77460000  /* class 0 */ 
#define CMD_DIALOG_USERPREF                     0x774a0000  /* class 0 */ 
#define CMD_DIALOG_DISPLAY                      0x774b0000  /* class 0 */ 
#define CMD_DIALOG_MAINFRAME                    0x774c0000  /* class 0 */ 
#define CMD_DIALOG_FENCEFRAME                   0x774d0000  /* class 0 */ 
#define CMD_DIALOG_DIMENSIONINGFRAME            0x774e0000  /* class 0 */ 
#define CMD_DIALOG_TOOLSETTINGS                 0x774f0000  /* class 0 */ 
#define CMD_DIALOG_IMAGE                        0x77500000  /* class 0 */ 
#define CMD_DIALOG_REFERENCEROTATE              0x77510000  /* class 0 */ 
#define CMD_DIALOG_REFERENCESCALE               0x77520000  /* class 0 */ 
#define CMD_DIALOG_SAVEIMAGE                    0x77530000  /* class 0 */ 
#define CMD_DIALOG_ABOUTUSTN                    0x77550000  /* class 0 */ 
#define CMD_DIALOG_LOCKTOGGLES                  0x77570000  /* class 0 */ 
#define CMD_DIALOG_SAVEAS                       0x77580000  /* class 0 */ 
#define CMD_DIALOG_MOREPREF                     0x77600000  /* class 0 */ 
#define CMD_DIALOG_EDITUCI                      0x77620000  /* class 0 */ 
#define CMD_MDL                                 0x79000000  /* class 0 */ 
#define CMD_MDL_LOAD                            0x79010000  /* class 0 */ 
#define CMD_MDL_UNLOAD                          0x79020000  /* class 0 */ 
#define CMD_MDL_DEBUG                           0x79030000  /* class 0 */ 
#define CMD_MDL_COMMAND                         0x79040000  /* class 0 */ 
#define CMD_MDL_HEAP                            0x79050000  /* class 0 */ 
#define CMD_MDL_DLOGLOAD                        0x79060000  /* class 0 */ 
#define CMD_TAG                                 0x7a000000  /* MANIPULATION */ 
#define CMD_TAG_ELEMENT                         0x7a010000  /* MANIPULATION */ 
#define CMD_TAG_FIND                            0x7a020000  /* MANIPULATION */ 
#define CMD_RECORD                              0x7b000000  /* INPUT */ 
#define CMD_RECORD_ON                           0x7b010000  /* INPUT */ 
#define CMD_RECORD_OFF                          0x7b020000  /* INPUT */ 
#define CMD_LISTEN                              0x7c000000  /* INPUT */ 
#define CMD_FORMS                               0x7e000000  /* DATABASE */ 
#define CMD_FORMS_ON                            0x7e010000  /* DATABASE */ 
#define CMD_FORMS_OFF                           0x7e020000  /* DATABASE */ 
#define CMD_FORMS_DISPLAY                       0x7e030000  /* DATABASE */ 
#define CMD_FREEZE                              0x7f000000  /* MANIPULATION */ 
#define CMD_THAW                                0x80000000  /* MANIPULATION */ 
#define CMD_DMSG                                0x81000000  /*  */ 
#define CMD_DMSG_CLOSEDIALOG                    0x81010000  /*  */ 
#define CMD_DMSG_CANCEL                         0x81020000  /*  */ 
#define CMD_DMSG_CLOSESUBPALETTES               0x81030000  /*  */ 
#define CMD_DMSG_DIALOGDEBUG                    0x81040000  /*  */ 
#define CMD_DMSG_DIALOGDEBUG_ON                 0x81040100  /*  */ 
#define CMD_DMSG_DIALOGDEBUG_OFF                0x81040200  /*  */ 
#define CMD_DMSG_DIALOGDEBUG_TOGGLE             0x81040300  /*  */ 
#define CMD_DMSG_ITEMDEBUG                      0x81050000  /*  */ 
#define CMD_DMSG_ITEMDEBUG_ON                   0x81050100  /*  */ 
#define CMD_DMSG_ITEMDEBUG_OFF                  0x81050200  /*  */ 
#define CMD_DMSG_ITEMDEBUG_TOGGLE               0x81050300  /*  */ 
#define CMD_DMSG_HANDLERDEBUG                   0x81060000  /*  */ 
#define CMD_DMSG_HANDLERDEBUG_ON                0x81060100  /*  */ 
#define CMD_DMSG_HANDLERDEBUG_OFF               0x81060200  /*  */ 
#define CMD_DMSG_HANDLERDEBUG_TOGGLE            0x81060300  /*  */ 
#define CMD_DMSG_VERBOSEDEBUG                   0x81070000  /*  */ 
#define CMD_DMSG_VERBOSEDEBUG_ON                0x81070100  /*  */ 
#define CMD_DMSG_VERBOSEDEBUG_OFF               0x81070200  /*  */ 
#define CMD_DMSG_VERBOSEDEBUG_TOGGLE            0x81070300  /*  */ 
#define CMD_DMSG_AUXMSGDEBUG                    0x81080000  /*  */ 
#define CMD_DMSG_AUXMSGDEBUG_ON                 0x81080100  /*  */ 
#define CMD_DMSG_AUXMSGDEBUG_OFF                0x81080200  /*  */ 
#define CMD_DMSG_AUXMSGDEBUG_TOGGLE             0x81080300  /*  */ 
#define CMD_DMSG_CLEARDEBUG                     0x81090000  /*  */ 
#define CMD_DMSG_OPENMSGFILE                    0x810a0000  /*  */ 
#define CMD_DMSG_APPENDMSGFILE                  0x810b0000  /*  */ 
#define CMD_DMSG_CLOSEMSGFILE                   0x810c0000  /*  */ 
#define CMD_DMSG_CURSOR                         0x810d0000  /*  */ 
#define CMD_DMSG_CURSOR_BLINK                   0x810d0100  /*  */ 
#define CMD_DMSG_CURSOR_BLINK_ON                0x810d0110  /*  */ 
#define CMD_DMSG_CURSOR_BLINK_OFF               0x810d0120  /*  */ 
#define CMD_DMSG_CURSOR_BLINK_TOGGLE            0x810d0130  /*  */ 
#define CMD_DMSG_CURSOR_LEFT                    0x810d0200  /*  */ 
#define CMD_DMSG_CURSOR_RIGHT                   0x810d0300  /*  */ 
#define CMD_DMSG_CURSOR_UP                      0x810d0400  /*  */ 
#define CMD_DMSG_CURSOR_DOWN                    0x810d0500  /*  */ 
#define CMD_DMSG_CURSOR_WORDLEFT                0x810d0600  /*  */ 
#define CMD_DMSG_CURSOR_WORDRIGHT               0x810d0700  /*  */ 
#define CMD_DMSG_CURSOR_LINEBEGIN               0x810d0800  /*  */ 
#define CMD_DMSG_CURSOR_LINEEND                 0x810d0900  /*  */ 
#define CMD_DMSG_CURSOR_PAGEUP                  0x810d0a00  /*  */ 
#define CMD_DMSG_CURSOR_PAGEDOWN                0x810d0b00  /*  */ 
#define CMD_DMSG_CURSOR_DATABEGIN               0x810d0c00  /*  */ 
#define CMD_DMSG_CURSOR_DATAEND                 0x810d0d00  /*  */ 
#define CMD_DMSG_CURSOR_NEXTFIELD               0x810d0e00  /*  */ 
#define CMD_DMSG_CURSOR_PREVIOUSFIELD           0x810d0f00  /*  */ 
#define CMD_DMSG_CURSOR_DELETELEFT              0x810d1000  /*  */ 
#define CMD_DMSG_CURSOR_DELETERIGHT             0x810d1100  /*  */ 
#define CMD_DMSG_CURSOR_DELETELEFTWORD          0x810d1200  /*  */ 
#define CMD_DMSG_CURSOR_DELETERIGHTWORD         0x810d1300  /*  */ 
#define CMD_DMSG_CURSOR_DELETEDATABEGIN         0x810d1400  /*  */ 
#define CMD_DMSG_CURSOR_DELETEDATAEND           0x810d1500  /*  */ 
#define CMD_DMSG_CURSOR_SELECTALL               0x810d1600  /*  */ 
#define CMD_DMSG_CLIPBOARD                      0x810e0000  /*  */ 
#define CMD_DMSG_CLIPBOARD_CUT                  0x810e0100  /*  */ 
#define CMD_DMSG_CLIPBOARD_COPY                 0x810e0200  /*  */ 
#define CMD_DMSG_CLIPBOARD_PASTE                0x810e0300  /*  */ 
#define CMD_DMSG_CLIPBOARD_UNDO                 0x810e0400  /*  */ 
#define CMD_DMSG_CLIPBOARD_REDO                 0x810e0500  /*  */ 
#define CMD_DMSG_CLIPBOARD_CLEAR                0x810e0600  /*  */ 
#define CMD_DMSG_CLIPBOARD_DELETE               0x810e0700  /*  */ 
#define CMD_DMSG_CLIPBOARD_INSERTTEXT           0x810e0800  /*  */ 
#define CMD_DMSG_ACTION                         0x810f0000  /*  */ 
#define CMD_DMSG_ACTION_OKAY                    0x810f0100  /*  */ 
#define CMD_DMSG_ACTION_CANCEL                  0x810f0200  /*  */ 
#define CMD_DMSG_ACTION_PULLSYSTEMMENU          0x810f0300  /*  */ 
#define CMD_DMSG_ACTION_SHOWACCELERATORS        0x810f0400  /*  */ 
#define CMD_DMSG_SHOWVERSIONS                   0x81100000  /*  */ 
#define CMD_CLOSE                               0x82000000  /* PLACEMENT */ 
#define CMD_CLOSE_ELEMENT                       0x82010000  /* PLACEMENT */ 
#define CMD_CLOSE_DESIGN                        0x82020000  /* NEWFILE */ 
#define CMD_RENDER                              0x83000000  /* VIEWING */ 
#define CMD_RENDER_VIEW                         0x83010000  /* VIEWING */ 
#define CMD_RENDER_VIEW_SECTION                 0x83010200  /* VIEWING */ 
#define CMD_RENDER_VIEW_WIREMESH                0x83010300  /* VIEWING */ 
#define CMD_RENDER_VIEW_HIDDEN                  0x83010400  /* VIEWING */ 
#define CMD_RENDER_VIEW_FILLED                  0x83010500  /* VIEWING */ 
#define CMD_RENDER_VIEW_CONSTANT                0x83010600  /* VIEWING */ 
#define CMD_RENDER_VIEW_SMOOTH                  0x83010700  /* VIEWING */ 
#define CMD_RENDER_VIEW_PHONG                   0x83010800  /* VIEWING */ 
#define CMD_RENDER_VIEW_STEREO                  0x83010900  /* VIEWING */ 
#define CMD_RENDER_ALL                          0x83020000  /* VIEWING */ 
#define CMD_RENDER_ALL_SECTION                  0x83020200  /* VIEWING */ 
#define CMD_RENDER_ALL_WIREMESH                 0x83020300  /* VIEWING */ 
#define CMD_RENDER_ALL_HIDDEN                   0x83020400  /* VIEWING */ 
#define CMD_RENDER_ALL_FILLED                   0x83020500  /* VIEWING */ 
#define CMD_RENDER_ALL_CONSTANT                 0x83020600  /* VIEWING */ 
#define CMD_RENDER_ALL_SMOOTH                   0x83020700  /* VIEWING */ 
#define CMD_RENDER_ALL_PHONG                    0x83020800  /* VIEWING */ 
#define CMD_RENDER_ALL_STEREO                   0x83020900  /* VIEWING */ 
#define CMD_RENDER_FENCE                        0x83030000  /* VIEWING */ 
#define CMD_RENDER_FENCE_SECTION                0x83030200  /* VIEWING */ 
#define CMD_RENDER_FENCE_WIREMESH               0x83030300  /* VIEWING */ 
#define CMD_RENDER_FENCE_HIDDEN                 0x83030400  /* VIEWING */ 
#define CMD_RENDER_FENCE_FILLED                 0x83030500  /* VIEWING */ 
#define CMD_RENDER_FENCE_CONSTANT               0x83030600  /* VIEWING */ 
#define CMD_RENDER_FENCE_SMOOTH                 0x83030700  /* VIEWING */ 
#define CMD_RENDER_FENCE_PHONG                  0x83030800  /* VIEWING */ 
#define CMD_RENDER_FENCE_STEREO                 0x83030900  /* VIEWING */ 
#define CMD_EXCHANGEFILE                        0x84000000  /* NEWFILE */ 
#define CMD_DXF                                 0x85000000  /* class 0 */ 
#define CMD_DXF_IN                              0x85010000  /* class 0 */ 
#define CMD_DXF_OUT                             0x85020000  /* class 0 */ 
#define CMD_CACHE                               0x86000000  /* class 0 */ 
#define CMD_CACHE_RELOAD                        0x86010000  /* class 0 */ 
#define CMD_RESOURCEFILE                        0x87000000  /* class 0 */ 
#define CMD_RESOURCEFILE_OPEN                   0x87010000  /* class 0 */ 
#define CMD_EXIT                                0xc8000000  /* INPUT */ 
#define CMD_EXIT_NOCLEAR                        0xc8010000  /* INPUT */ 
#define CMD_EXIT_NOUC                           0xc8020000  /* INPUT */ 
#define CMD_QUIT                                0xc8000000  /* INPUT */ 
#define CMD_QUIT_NOCLEAR                        0xc8010000  /* INPUT */ 
#define CMD_QUIT_NOUC                           0xc8020000  /* INPUT */ 
#define CMD_GETCLR                              0xc9000000  /* INPUT */ 
#define CMD_DNLCLT                              0xca000000  /* INPUT */ 
#define CMD_DNLLVS                              0xcb000000  /* INPUT */ 
#define CMD_NOTRANS                             0x2b000000  /* INPUT */ 
#define CMD_EX                                  0xc8000000  /* class 0 */ 
#define CMD_QU                                  0xc8000000  /* class 0 */ 
#define CMD_NE                                  0x0f000000  /* class 0 */ 
#define CMD_Z                                   0x04000000  /* class 0 */ 
#define CMD_JU                                  0x31000000  /* class 0 */ 
#define CMD_ALI                                 0x17000000  /* class 0 */ 
