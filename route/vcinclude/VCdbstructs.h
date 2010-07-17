
/* $Id: VCdbstructs.h,v 1.1.1.1 2001/01/04 21:12:34 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcinclude/VCdbstructs.h
 *
 * Description:
 *
 *      Structures defined for VC cabling system (database cache)
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCdbstructs.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:12:34  cvs
 *      Initial import to CVS
 *
 * Revision 1.2  1999/01/19  08:07:28  pinnacle
 * Replaced: vcinclude/VCdbstructs.h for: CR179701619 by aharihar for route
 *
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.1  1997/10/30  05:21:40  pinnacle
 * Integ into Route 02040304
 *
 * Revision 1.4  1997/07/14  21:18:08  pinnacle
 * Replaced: vcinclude/*.h for:  by hverstee for cabling
 *
 * Revision 1.3  1997/01/20  20:08:32  pinnacle
 * Replaced: vcinclude/VCdbstructs.h for:  by hverstee for cabling
 *
 * Revision 1.2  1996/10/29  22:04:42  pinnacle
 * Replaced: vcinclude/VCdbstructs.h for:  by hverstee for cabling
 *
 * Revision 1.1  1996/08/28  20:46:38  pinnacle
 * Created: vcinclude/VCdbstructs.h by hverstee for cabling
 *
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *      05/27/96    hv          Initial
 *     18 Jan 1999  Anand       Defined struct VCdbjumper for jumper
 *				implementation (CR 179701619).
 *
 *************************************************************************/

#ifndef VCdbstructs_include
#define VCdbstructs_include

struct  VCdbmain
{
  IGRchar     Compcode[VC_MAX_CCODE];

  IGRchar     OwnerId[VC_MAX_ID];
  IGRchar     Timest[VC_MAX_TIMEST];

  IGRchar     Short_desc[VC_MAX_SDESC];
  IGRchar     Standard[VC_MAX_MISC];
  IGRchar     Environment[VC_MAX_ID];
  IGRchar     Fire_resist[VC_MAX_ID];
  IGRchar     Security[VC_MAX_ID];
  IGRchar     Desc[VC_MAX_LDESC];
  IGRchar     Vendor[VC_MAX_MISC];
  IGRchar     Catalog[VC_MAX_CATAL];
  IGRchar     Stockno[VC_MAX_STOCK];
  IGRchar     Insertblk[VC_MAX_ID];
  IGRchar     Tubecode[VC_MAX_TUBEC];
  IGRdouble   Lug_size;
  IGRdouble   Weight;
  IGRdouble   Unit_Cost;
  IGRdouble   Gn_data_1;
  IGRdouble   Gn_data_2;
  IGRshort    LcUnit;

  IGRboolean  Local;

  /*    only present for terminals and backshells  */
  IGRchar     Macro_name[VC_MAX_ID];

  /*    only present for cables and guides  */
  IGRchar     Insul_type[VC_MAX_ID];
  IGRdouble   Insul_thk;
  IGRdouble   Diameter;
  IGRdouble   Bendrad;
};

struct VCdbmap
{
  IGRshort  Con_number;
  IGRchar   Con_name[VC_MAX_ID];
  IGRchar   Def_signal[VC_MAX_SIG_ID];
};

struct VCdbelcond
{
  IGRchar   Con_name[VC_MAX_ID];
  IGRchar   Con_matl[VC_MAX_ID];

  IGRdouble Diameter;
  IGRdouble Clad_dia;
  IGRdouble Sect_con;
  IGRdouble Voltage;
  IGRdouble Current;
  IGRdouble Resistance;
  IGRdouble Modal_bw;
  IGRdouble Res_meas_wl;

  IGRdouble Len_sc_fac;
  IGRdouble Sensitivity;

  IGRdouble Amp_60_40;
  IGRdouble Amp_60_50;
  IGRdouble Amp_400_40;
  IGRdouble Amp_400_50;

  IGRdouble Dt_data_1;
  IGRdouble Dt_data_2;
};

struct VCdbfocond
{
  IGRchar   Con_name[VC_MAX_ID];
  IGRchar   Con_match[VC_MAX_ID];

  IGRdouble Diameter;
  IGRdouble Clad_dia;
  IGRdouble Modal_bw;

  IGRdouble Num_aper;
  IGRdouble Chrom_disp;
  IGRdouble Zero_disp;
  IGRdouble Attenuation;
  IGRdouble Att_meas_wl;
  IGRdouble Lim_space_att;
  IGRdouble High_order_loss;

  IGRdouble Len_sc_fac;
  IGRdouble Sensitivity;
  IGRdouble Dt_data_1;
  IGRdouble Dt_data_2;
};

struct VCdbmod
{
  IGRchar     Mod_id[VC_MAX_MOD_ID];
  IGRchar     Mod_desc[VC_MAX_SDESC];
  IGRshort    ConnecPAR;
  IGRchar     Pos_id1[VC_MAX_MOD_ID];
  IGRshort    Iotype1;
  IGRchar     Pos_id2[VC_MAX_MOD_ID];
  IGRshort    Iotype2;
  IGRchar     Def_signal[VC_MAX_SIG_ID];
};

struct VCdbelpin
{
  IGRchar     Mod_id[VC_MAX_MOD_ID];
  IGRchar     Pos_id[VC_MAX_MOD_ID];
  IGRchar     Altdir[VC_MAX_ID];

  IGRshort    Maxconnect;
  IGRdouble   Work_volt;
  IGRdouble   Peak_volt;
  IGRdouble   Frequency;
  IGRdouble   Sensitivity;
  IGRdouble   Power_mean;
  IGRdouble   Power_max;
  IGRdouble   Power_stddev;
  IGRdouble   Sensi_stddev;
  IGRdouble   Rise_time;
  IGRdouble   Precision;
  IGRdouble   Dt_data_1;
  IGRdouble   Dt_data_2;
};

struct VCdbfopin
{
  IGRchar     Mod_id[VC_MAX_MOD_ID];
  IGRchar     Pos_id[VC_MAX_MOD_ID];
  IGRchar     Con_match[VC_MAX_ID];

  IGRdouble   Bandwidth;
  IGRdouble   Spectral_w;
  IGRdouble   Lambda_c;
  IGRdouble   Ang_dist;
  IGRdouble   Sensitivity;
  IGRdouble   Power_mean;
  IGRdouble   Power_max;
  IGRdouble   Power_stddev;
  IGRdouble   Sensi_stddev;
  IGRdouble   Rise_time ;
  IGRdouble   Dt_data_1;
  IGRdouble   Dt_data_2;
};

union VCdbdatarec
{
  struct VCdbelcond     EC;
  struct VCdbfocond     FC;
  struct VCdbelpin      EP;
  struct VCdbfopin      FP;
};

struct VCdbconsel
{
  IGRchar     Con_match[VC_MAX_ID];
  IGRchar     Con_Spl_Def[VC_MAX_ID];
};

struct VDdbfoconn
{
  IGRchar     Con_Spl_Def[VC_MAX_ID];
  IGRshort    CnType;

  IGRchar     OwnerId[VC_MAX_ID];
  IGRchar     Timest[VC_MAX_TIMEST];

  IGRchar     Short_desc[VC_MAX_SDESC];
  IGRchar     Standard[VC_MAX_MISC];
  IGRchar     Environment[VC_MAX_ID];
  IGRchar     Fire_resist[VC_MAX_ID];
  IGRchar     Security[VC_MAX_ID];
  IGRchar     Desc[VC_MAX_LDESC];
  IGRchar     Vendor[VC_MAX_MISC];
  IGRdouble   Weight;
  IGRdouble   Unit_Cost;
  IGRdouble   Gn_data_1;
  IGRdouble   Gn_data_2;
  IGRshort    LcUnit;

  IGRboolean  Local;

  IGRdouble   Modal_bw;

  IGRdouble   Num_aper;
  IGRdouble   Chrom_disp;
  IGRdouble   Zero_disp;
  IGRdouble   Attenuation;
  IGRdouble   Att_meas_wl;
  IGRdouble   Lim_space_att;
  IGRdouble   High_order_loss;

  IGRdouble   Len_sc_fac;
  IGRdouble   Sensitivity;
  IGRdouble   Dt_data_1;
  IGRdouble   Dt_data_2;
};

struct VCDB_index_ent
{
  IGRchar     Tabnam[VC_MAX_CCODE];
  IGRchar     Desc[VC_MAX_SDESC];
  struct GRid LocId;
  IGRboolean  bInDB;
};

typedef
struct VCDB_index
{
  struct  VCDB_index_ent *Ent;
          IGRshort        nIndex;
          IGRshort        nTotix;
}VCDB_index, *VCDB_indexptr;


/*added by alwin for CR179701619 */
struct VCdbjumper
{
  IGRshort	max_position;

  /* These are added to extend in case if the spec changes at the later
  stages 
  IGRchar	Extend1[0];
  IGRchar	Extend2[0];
  **/
};
/*added by alwin for CR179701619 */

#endif

