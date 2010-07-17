
/* $Id: VCdbaccess.h,v 1.1.1.1 2001/01/04 21:12:34 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcinclude/VCdbaccess.h
 *
 * Description:
 *
 *      Structures defined for VC cabling system (database cache)
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCdbaccess.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:12:34  cvs
 *      Initial import to CVS
 *
 * Revision 1.2  1999/01/19  08:19:04  pinnacle
 * Replaced: vcinclude/VCdbaccess.h for: CR179701619 by aharihar for route
 *
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.1  1997/10/30  05:21:40  pinnacle
 * Integ into Route 02040304
 *
 * Revision 1.7  1997/07/21  21:12:36  pinnacle
 * Replaced: vcinclude/VCdbaccess.h for:  by hverstee for cabling
 *
 * Revision 1.6  1997/07/14  21:18:08  pinnacle
 * Replaced: vcinclude/*.h for:  by hverstee for cabling
 *
 * Revision 1.5  1997/03/05  14:38:44  pinnacle
 * Replaced: vcinclude/VCdbaccess.h for:  by hverstee for cabling
 *
 * Revision 1.4  1997/01/20  20:08:48  pinnacle
 * Replaced: vcinclude/VCdbaccess.h for:  by hverstee for cabling
 *
 * Revision 1.3  1997/01/03  14:09:34  pinnacle
 * Replaced: vcinclude/VCdbaccess.h for:  by hverstee for cabling
 *
 * Revision 1.2  1996/10/29  22:04:24  pinnacle
 * Replaced: vcinclude/VCdbaccess.h for:  by hverstee for cabling
 *
 * Revision 1.1  1996/08/28  20:46:16  pinnacle
 * Created: vcinclude/VCdbaccess.h by hverstee for cabling
 *
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *      05/27/96    hv          Initial
 *     19 Jan 1999  Anand       Added entries for jumper
 *
 *************************************************************************/

#ifndef VCdbaccess_include
#define VCdbaccess_include

/*     directory names      */

#define VC_DIR_TAG        "cabling"
#define VC_DIR_MAIN       "cablingdb"
#define VC_DIR_ATT        "cablingatt"
#define VC_DIR_ELEC       "electrical"
#define VC_DIR_FO         "fiberoptic"
#define VC_DIR_TERM       "terminals"
#define VC_DIR_CAB        "cables"
#define VC_DIR_GD         "guides"
#define VC_DIR_BK         "backshells"
#define VC_DIR_MISC       "misc"
#define VC_DIR_JUNK       "junk"

#define VC_DIR_JUMPER	  "jumpers" // added for CR179701619

#define VC_DIR_SYS        "vc_sysatt"
#define VC_DIR_USER       "vc_usratt"

/*     Standard VC macro library       */

#define VC_MACROLIB       NULL         /*   no library yet     */

/*     DB table names       */

#define VC_DBT_GD         "vct_guide"
#define VC_DBT_BK         "vct_bkshell"

#define VC_DBT_ELCAB      "vct_ecable"
#define VC_DBT_ELMAP      "vct_ecmap"
#define VC_DBT_ELCND      "vct_econd"

#define VC_DBT_ELTERM     "vct_eterm"
#define VC_DBT_ELMOD      "vct_emod"
#define VC_DBT_ELPIN      "vct_epin"

#define VC_DBT_FOCAB      "vct_fcable"
#define VC_DBT_FOMAP      "vct_fcmap"
#define VC_DBT_FOCND      "vct_fcond"

#define VC_DBT_FOTERM     "vct_fterm"
#define VC_DBT_FOMOD      "vct_fmod"
#define VC_DBT_FOPIN      "vct_fpin"
#define VC_DBT_FOSEL      "vct_fsel"
#define VC_DBT_FOCON      "vct_fcon"

#define VC_DBT_JUMPER     "vct_jump" // added for CR179701619

/*    DB keyfields          */

#define VC_DBK_CODE       "comp_code"
#define VC_DBK_MATCH      "con_match"
#define VC_DBK_SELECT     "con_spl_def"
#define VC_DBK_SWITCH     "cntype"

/*    DB column numbers      */

#define VC_DBN_INDEX      2
#define VC_DBN_GD         20
#define VC_DBN_BK         17

#define VC_DBN_FOCAB      23
#define VC_DBN_FOMAP       3
#define VC_DBN_FOCND      16

#define VC_DBN_ELCAB      23
#define VC_DBN_ELMAP       3
#define VC_DBN_ELCND      18

#define VC_DBN_FOTERM     17
#define VC_DBN_FOMOD      8
#define VC_DBN_FOPIN      15
#define VC_DBN_FOSEL      2
#define VC_DBN_FOCON      28

#define VC_DBN_ELTERM     17
#define VC_DBN_ELMOD      7
#define VC_DBN_ELPIN      16

/*    DB select clauses     */

#define VC_DBS_INDEX      "comp_code,short_desc"

#define VC_DBS_GD         \
"owner_id,timest,short_desc,standard,environment,fire_resist,security,full_desc,vendor,catalog,stock_no,weight,unit_cost,gn_data_1,gn_data_2,lcunit,insul_type,insul_thk,diameter,bend_rad"

#define VC_DBS_BK         \
"owner_id,timest,macro_name,short_desc,standard,environment,fire_resist,security,full_desc,vendor,catalog,stock_no,weight,unit_cost,gn_data_1,gn_data_2,lcunit"

#define VC_DBS_FOCAB      \
"owner_id,timest,short_desc,standard,environment,fire_resist,security,full_desc,vendor,catalog,stock_no,ins_block,tube_size,lug_size,weight,unit_cost,gn_data_1,gn_data_2,lcunit,insul_type,insul_thk,diameter,bend_rad"
#define VC_DBS_FOMAP      "con_num,con_name,def_signal"
#define VC_DBS_FOCND      \
"con_name,con_match,diameter,clad_diam,modal_bw,numeric_aperture,chrom_disp_slope,zero_disp_slope,attenuation,atten_measure_wl,lmt_ph_space_att,h_order_mod_loss,len_scale_factor,sensitiv,dt_data_1,dt_data_2"

#define VC_DBS_ELCAB      \
"owner_id,timest,short_desc,standard,environment,fire_resist,security,full_desc,vendor,catalog,stock_no,ins_block,tube_size,lug_size,weight,unit_cost,gn_data_1,gn_data_2,lcunit,insul_type,insul_thk,diameter,bend_rad"
#define VC_DBS_ELMAP      "con_num,con_name,def_signal"
#define VC_DBS_ELCND      \
"con_name,con_material,diameter,clad_diam,sect_conduct,voltage,maxcurrent,resistance,modal_bw,len_scale_factor,resis_measure_wl,sensitiv,amp_60_40,amp_60_50,amp_400_40,amp_400_50,dt_data_1,dt_data_2"

#define VC_DBS_FOTERM     \
"owner_id,timest,macro_name,short_desc,standard,environment,fire_resist,security,full_desc,vendor,catalog,stock_no,weight,unit_cost,gn_data_1,gn_data_2,lcunit"
#define VC_DBS_FOMOD      \
"mod_code,mod_name,connectype,pos_name1,iotype1,pos_name2,iotype2,def_signal"
#define VC_DBS_FOPIN      \
"mod_code,pos_name,con_match,bandwidth,spectral_w,lambda_c,ang_distrib,sensitiv,power_mean,power_max,power_std_dev,sensi_std_dev,rise_time,dt_data_1,dt_data_2"

#define VC_DBS_FOSEL      \
"con_match,con_spl_def"
#define VC_DBS_FOCON      \
"cntype,short_desc,standard,environment,fire_resist,security,full_desc,vendor,catalog,stock_no,weight,unit_cost,gn_data_1,gn_data_2,lcunit,modal_bw,numeric_aperture,chrom_disp_slope,zero_disp_slope,attenuation,atten_measure_wl,lmt_ph_space_att,h_order_mod_loss,len_scale_factor,sensitiv,dt_data_1,dt_data_2"

#define VC_DBS_ELTERM     \
"owner_id,timest,macro_name,short_desc,standard,environment,fire_resist,security,full_desc,vendor,catalog,stock_no,weight,unit_cost,gn_data_1,gn_data_2,lcunit"
#define VC_DBS_ELMOD      \
"mod_code,mod_name,pos_name1,iotype1,pos_name2,iotype2,def_signal"
#define VC_DBS_ELPIN      \
"mod_code,pos_name,alt_direct,max_connect,work_volt,peak_volt,frequency,sensitiv,power_mean,power_max,power_std_dev,sensi_std_dev,rise_time,precision_code,dt_data_1,dt_data_2"


#define VC_DBS_JUMPER         \
"owner_id,timest,short_desc,standard,environment,fire_resist,security,full_desc,vendor,catalog,stock_no,max_position,weight,unit_cost,gn_data_1,gn_data_2,lcunit" // added for CR179701619
#endif
