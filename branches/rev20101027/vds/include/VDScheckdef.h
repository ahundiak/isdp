
/* $Id: VDScheckdef.h,v 1.2 2001/01/09 21:54:58 art Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/include / VDScheckdef.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDScheckdef.h,v $
 *	Revision 1.2  2001/01/09 21:54:58  art
 *	ah
 *	
 *	Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *	Initial import to CVS
 *
 * Revision 1.2  2000/07/10  19:47:20  pinnacle
 * Replaced: vds/include/VDScheckdef.h for:  by apazhani for Service Pack
 *
 * Revision 1.3  1999/02/08  19:10:04  pinnacle
 * Replaced: include/VDScheckdef.h for:  by lawaddel for vds
 *
 * Revision 1.2  1999/01/28  20:20:52  pinnacle
 * Replaced: include/VDScheckdef.h for:  by lawaddel for vds
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.3  1997/10/28  04:26:14  pinnacle
 * Replaced: include/VDScheckdef.h for:  by apazhani for vds
 *
 * Revision 1.2  1997/10/15  10:57:46  pinnacle
 * Replaced: include/VDScheckdef.h for:  by apazhani for vds
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.3  1997/03/13  10:20:40  pinnacle
 * Replaced: include/VDScheckdef.h for:  by rgade for vds.241
 *
 * Revision 1.2  1997/02/27  00:14:16  pinnacle
 * Replaced: include/VDScheckdef.h for:  by hverstee for vds.241
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *      10/15/97        Alwin           Added the table name definition for
 *                                      "vrsch_equip_dyn", i.e Route PID Equip
 *      10/28/97        Alwin           Added the table name definition for
 *                                      Connection Component( Backshell ).
 *      01/28/99        law             CR179802489-add new values for cable
 *                                      lead tables
 *      02/04/99        law             CR179701619-add new values for cable
 *                                      jumper tables.
 *      05/23/00        Alwin           CR179901521-added new table names for 
 *					PID PIPING & HVAC
 *      01/09/01        ah              sp merge
 * -------------------------------------------------------------------*/

#ifndef VDScheckdef_include
#define VDScheckdef_include

/*
 * this file contain the new list of elegible object for fast checkin
 */

/*    redefined some constants, copied from ACcheckin.h (SIC) and
      formalized                                                     */

/*********************************************************************/
/*    first part is legacy data, remove when no longer needed        */

#define	EQUIPMENT_OBJ		-50
#define	COMPARTMENT_OBJ		-60
#define INSTRUMENT_OBJ		-70
#define SURFACE_OBJ		-80

/*----------------------------------    REMOVED       HV    2/26/97
#define ELECTRIC_OBJ		-81
#define ELECONN_OBJ		-82
#define FIBRE_OPTIC_OBJ		-83
----------------------------------------------------------*/

/* Begin Schematics */

#define PID_PIPING_OBJ		-101
#define PID_EQUIP_OBJ		-102
#define PID_PIPENOZ_OBJ		-103
#define PID_INSTR_OBJ		-104

#define SCH_HVAC_OBJ		-105
#define SCH_HVNOZ_OBJ		-106

/*----------------------------------    REMOVED       HV    2/26/97
#define SCH_ELECT_OBJ		-107
#define SCH_ELECONN_OBJ		-108
#define SCH_FIBOPT_OBJ		-109
----------------------------------------------------------*/

#define LOGICAL_CONNECTION_OBJ  -999   /* This object cannot be posted */

/*********************************************************************/
/*            FORMALIZED NAMES                      */

/*    I/VDS                                         */
#define VD_CKIN_EQUIPMENT_OBJ         -50
#define VD_CKIN_COMPARTMENT_OBJ       -60
#define VD_CKIN_INSTRUMENT_OBJ        -70
#define VD_CKIN_SURFACE_OBJ           -80

/*    I/ROUTE                                       */

#define VD_CKIN_PIPING_OBJ             -1
#define VD_CKIN_PIPE_NOZZ_OBJ          -2
#define VD_CKIN_PIPE_SUPP_OBJ          -3
#define VD_CKIN_HVAC_OBJ              -10
#define VD_CKIN_HVAC_NOZZ_OBJ         -11
#define VD_CKIN_RWAY_NOZZ_OBJ         -12 /* added for Raceway Nozzle */
#define VD_CKIN_RWAY_OBJ              -20

#define VD_CKTB_PID_EQUIP         "vrsch_equip_dyn"

#define VD_CKIN_PID_PIPING_OBJ       -101
#define VD_CKIN_PID_EQUIP_OBJ        -102
#define VD_CKIN_PID_PIPENOZ_OBJ      -103
#define VD_CKIN_PID_INSTR_OBJ        -104

#define VD_CKIN_SCH_HVAC_OBJ         -105
#define VD_CKIN_SCH_HVNOZ_OBJ        -106

/*     I/STRUCT                                     */

#define VD_CKIN_STRUCT_BEAM_OBJ       -30
#define VD_CKIN_STRUCT_PLATE_OBJ      -40
#define VD_CKIN_STRUCT_JNT_OBJ        -45

/*     I/CABLE                                      */

#define VD_CKIN_CABMOD_GUIDE         -200

#define VD_CKIN_CABMOD_ELTERM        -201
#define VD_CKIN_CABMOD_ELCAB         -202

#define VD_CKIN_CABMOD_FOTERM        -211
#define VD_CKIN_CABMOD_FOCAB         -212

/* added this for Connection Component(Backshell) */
#define VD_CKIN_CABMOD_EBKSHELL      -213

/* added for cr179802489-generic posting to VCSCH_ELEAD table */
#define VD_CKIN_VRPOST_ELEAD         -214
/* added for cr179802489-generic posting to VCSCH_FLEAD table */
#define VD_CKIN_VRPOST_FLEAD         -215

/* added for cr179701619-generic posting to VCSCH_JUMP table */
#define VD_CKIN_VRPOST_JUMP          -216
/* added for cr179701619-generic posting to VCSCH_JMPLOC table */
#define VD_CKIN_VRPOST_JMPLOC        -217

#define VD_CKIN_CABSCH_GUIDE         -220

#define VD_CKIN_CABSCH_ELTERM        -221
#define VD_CKIN_CABSCH_ELCAB         -222

#define VD_CKIN_CABSCH_FOTERM        -231
#define VD_CKIN_CABSCH_FOCAB         -232

/* added this for Connection Component(Backshell) */
#define VD_CKIN_CABSCH_EBKSHELL      -241

/*********************************************************************/
/*         TABLE NAMES, move from inline..............    */
/*         MODEL checkin                                  */

#define VD_CKTB_PIPING            "piping_dynamic"
#define VD_CKTB_PIP_NOZ           "piping_noz_dynamic"
#define VD_CKTB_PIP_SUP           "piping_sup_dynamic"

#define VD_CKTB_PID_PIPING        "piping_pid_dyn"
#define VD_CKTB_PIP_PID_NOZ       "piping_pid_noz_dyn"

#define VD_CKTB_HVAC              "hvac_dynamic"
#define VD_CKTB_HV_NOZ            "hvac_noz_dynamic"
#define VD_CKTB_RWAY_NOZ          "rway_nozz_dynamic"
#define VD_CKTB_RWAY              "rway_dynamic"

#define VD_CKTB_PID_HVAC          "hvac_pid_dyn"
#define VD_CKTB_HV_PID_NOZ        "hvac_pid_noz_dyn"

#define VD_CKTB_SBEAM             "struct_bm_dynamic"
#define VD_CKTB_SPLATE            "struct_pl_dynamic"
#define VD_CKTB_JOINT             "struct_jn_dynamic"

#define VD_CKTB_EQUIP             "equip_dynamic"
#define VD_CKTB_COMPART           "compart_dynamic"
#define VD_CKTB_SURFACE           "surf_dynamic"

#define VD_CKTB_M_CBGUIDE         "vcdyn_guide"
#define VD_CKTB_M_CBETERM         "vcdyn_eterm"
#define VD_CKTB_M_CBECAB          "vcdyn_ecable"
#define VD_CKTB_M_CBFTERM         "vcdyn_fterm"
#define VD_CKTB_M_CBFCAB          "vcdyn_fcable"

/* added by alwin, for TR179701824 */
#define VD_CKTB_M_CBEBKSH         "vcdyn_ebkshell"
/* added by alwin, for TR179701824 */

#define VD_CKTB_S_CBGUIDE         "vcsch_guide"
#define VD_CKTB_S_CBETERM         "vcsch_eterm"
#define VD_CKTB_S_CBECAB          "vcsch_ecable"
#define VD_CKTB_S_CBFTERM         "vcsch_fterm"
#define VD_CKTB_S_CBFCAB          "vcsch_fcable"
#define VD_CKTB_S_CBFLEAD         "vcsch_flead"
#define VD_CKTB_S_CBELEAD         "vcsch_elead"
/** CR179701619 -add jumper tables */
#define VD_CKTB_S_CBJUMP          "vcsch_jump"
#define VD_CKTB_S_CBJMPLOC        "vcsch_jmploc"

/* added by alwin, for TR179701824 */
#define VD_CKTB_S_CBEBKSH         "vcsch_ebkshell"
/* added by alwin, for TR179701824 */

/*         DWG   checkin                                  */

#define VD_CKTB_BM_CIT            "struct_bm_cit"
#define VD_CKTB_PL_CIT            "struct_pl_cit"
#define VD_CKTB_CP_CIT            "compart_cit"

/*********************************************************************/
/*
 * This is used with the function VDSReadPartInfo()
 */

#define DYN 	0
#define STAT 	1
#define USER	2

#define MAX_PART_CHAR 81

struct VDpart_attr
{
 char GRpart_column[21];
 int  GRpart_type;      /* GR_DYNAMIC_ATTR,  GR_STATIC_ATTR */
 char part_name[21];   
 int  part_type;        /* Dyn/Stat/User  */
};


struct VDGRpart_attr
{
 char GRpart_column[21];
 int  GRpart_type;      /* Dyn/Stat       */
 int  user;		/* TRUE if USER   */	
 int  type;		/* DOUBLE or CHAR */
 union
  {
   char att_txt[MAX_PART_CHAR];
   double att_exp;
  } value;
};

/*
 * Structure used for the VDScheckin and place item
 */

struct table_attr
 {
  int 	type;
  int	delete;
  int 	nb_feet;
  char  **feet_list;
  char  **format_list;
  char  table_name[25];
 };

struct Newtable_attr
 {
   int		      delete;
   struct table_attr  tbl_attr;
 };

struct  VDConnEntity
{
        struct GRid     EntityNo;
        char            Cpt[10];
};

struct  vdscatalog
{
	char	catalog_name[20];
	char	dynamic_table[20];
	char	sch_dyn_table[20];
	char	cit_table[20];
	char	product[10];
};

#endif
