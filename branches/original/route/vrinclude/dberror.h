/**************************************************************************

Author   :      Madhukar Mandapati


Creation:       March 21st 1991

                
                This file defines all database access errors.

Change History :
                
                date  |  name | description of modification
               -------+-------+-----------------------------
               2/12/92|  Mkar | Added error code for nozzle
               2/12/92|  Mkar | Added error code for PDM fam 
               7/21/92|  Mkar | Added error code for PIPING_SCH_THK table
***************************************************************************/

#define  RIS_E_INITIAL			  1000

#define  ACC_S_SUCCESS                    1001

/* PIPING */

#define  ACC_E_PIPING_SPEC                1002
#define  ACC_E_PIPING_COMPS               1004
#define  ACC_E_PIPING_COMP_TYPE           1006
#define  ACC_E_PIPING_COMMOD_CODE         1008
#define  ACC_E_PIPING_ADPT_SELECT         1010
#define  ACC_E_PIPING_SPECIAL             1012
#define  ACC_E_PIPING_COD_SELECT          1014
#define  ACC_E_PIPING_DFLT_RED            1016
#define  ACC_E_PIPING_CODELIST            1018
#define  ACC_E_PIPING_LABEL_DESCR         1020
#define  ACC_E_PIPING_BR_SELECT           1022
#define  ACC_E_PIPING_CHG_SPEC            1024
#define  ACC_E_PIPING_COMP_INFO           1026
#define  ACC_E_PIPING_LABEL_DEFN          1028
#define  ACC_E_PIPING_UOM                 1030
#define  ACC_E_DFLT_PIPE                  1032
#define  ACC_E_FAM_UNDEFINED              1034
#define  ACC_E_NOZZLE                     1036
#define  ACC_E_PDM_FAMILY                 1038
#define  ACC_E_PIPING_SCH_THK             1040

/* HVAC */

#define  ACC_E_HVAC_SPEC                  1202
#define  ACC_E_HVAC_COMPS                 1204
#define  ACC_E_HVAC_COMP_TYPE             1206
#define  ACC_E_HVAC_BR_SELECT             1208
#define  ACC_E_HVAC_DFLT_DUCT             1210
#define  ACC_E_HVAC_COD_SELECT            1212
#define  ACC_E_HVAC_DFLT_RED              1214
#define  ACC_E_HVAC_CODELIST              1216
#define  ACC_E_HVAC_LABEL_DESCR           1218
#define  ACC_E_HVAC_TRANS_SELECT          1220
#define  ACC_E_HVAC_DEVICE                1222
#define  ACC_E_HVAC_CHG_SPEC              1224
#define  ACC_E_HVAC_COMP_INFO             1226
#define  ACC_E_HVAC_LABEL_DEFN            1228
#define  ACC_E_HVAC_UOM                   1230

/* RWAY */

#define  ACC_E_RWAY_SPEC                  1402
#define  ACC_E_RWAY_COMPS                 1404
#define  ACC_E_RWAY_COMP_TYPE             1406
#define  ACC_E_RWAY_BR_SELECT             1408
#define  ACC_E_RWAY_DFLT_RUN              1410
#define  ACC_E_RWAY_COD_SELECT            1412
#define  ACC_E_RWAY_DFLT_RED              1414
#define  ACC_E_RWAY_CODELIST              1416
#define  ACC_E_RWAY_LABEL_DESCR           1418
#define  ACC_E_RWAY_CHG_SPEC              1420
#define  ACC_E_RWAY_COMP_INFO             1422
#define  ACC_E_RWAY_LABEL_DEFN            1424
#define  ACC_E_RWAY_UOM                   1426

/* STRUCT */

#define  ACC_E_STRUCT_CODELIST            1602
#define  ACC_E_STRUCT_GRADE               1604
#define  ACC_E_STRUCT_LABEL_DESCR         1606
