
/* $Id: vc_param.h,v 1.2 2002/05/08 15:48:22 anand Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        include/vc_param.h
 *
 * Description:
 *
 *      Public Constants defined for VC cabling system runtime attributes
 *       (all alpha attribute definitions)
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vc_param.h,v $
 *      Revision 1.2  2002/05/08 15:48:22  anand
 *      Files added/modified for sub-cable functionality.
 *
 *      Revision 1.1.1.1  2001/01/04 21:12:10  cvs
 *      Initial import to CVS
 *
 * Revision 1.4  1999/02/08  19:12:02  pinnacle
 * Replaced: include/vc_param.h for:  by lawaddel for route
 *
 * Revision 1.3  1999/01/28  20:12:20  pinnacle
 * Replaced: include/vc_param.h for:  by lawaddel for route
 *
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.1  1997/10/30  04:56:40  pinnacle
 * Created: include/vc_param.h by impd for route
 *
 * Revision 1.3  1997/08/05  22:17:46  pinnacle
 * Replaced: include/vc_param.h for:  by hverstee for cabling
 *
 * Revision 1.2  1997/07/14  21:05:10  pinnacle
 * Replaced: include/vc_param.h for:  by hverstee for cabling
 *
 * Revision 1.1  1997/03/14  16:51:28  pinnacle
 * Created: include/vc_param.h by hverstee for cabling
 *
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *      05/31/96    hv          Initial
 *      12/01/98    law         CR179802404-temp angle store
 *      01/28/99    law         CR179802489-Add many values for leads
 *      02/04/99    law         CR179701619-Additions for jumpers
 *************************************************************************/

#ifndef	vc_param_include
#define vc_param_include

#include "VDDbtbldef.h"        /*    stay in sync with VDS ........    */
#include "vrparameters.h"      /*    stay in sync with ROUTE ......    */

/*************************************************************************/
/*                            N O T E                                    */
/*   To ensure conformity these parameternames are coupled here to       */
/*   the definitions imported from VDS.                                  */
/*   For flexibility the definition is isolated in this file             */
/*************************************************************************/

/*************************************************************************/
/*               Instance fields                                         */
/*   NOTE: compcode and macro name are stored in instance for speed      */
/*************************************************************************/

#define VC_N_TAG_NUMBER_AN	VD_N_TAG_NUMBER_AN

/*************************************************************************/
/*               System collection                                       */
/*************************************************************************/

#define VC_N_PART_NUM_AN	VD_N_PART_NUM_AN
#define VC_N_UNIT_AN		"unit_number"	         /*  VC only ?  */
#define	VC_N_SYST_NAME_AN	VD_N_SYSTEM_NAME_AN
#define VC_N_APPRV_STAT_AN	VD_N_APPRV_STAT_AN
#define	VC_N_CONSTR_STAT_AN	VD_N_CONST_STAT_AN
#define	VC_N_CHG_REQ_NUM_AN	VD_N_CHANGE_NO_IN
#define VC_N_COMP_NOTE_AN	VD_N_COMP_NOTE_AN
#define VC_N_NO_MTO_AN		VD_N_NO_MTO_FLAG_AN
#define VC_N_PID_ANGLE_DB       "temp_place_angle"
#define VC_N_ADD_LABEL_AN       "additional_label"        /*  VC only    */
#define VC_N_PID_SCALE_DB       VR_N_PID_SCALE_DB

/*************************************************************************/
/*               Calculated/indirect attributes                          */
/*************************************************************************/

#define VC_N_NB_CONNPT_IN	"nb_cpt"	/*  R  */
#define	VC_N_CAB_LENGTH_DB	"cable_length"	/* CABLING */
#define VC_N_SIGNAL_NAME_AN	"signal_name"	/* CABLING */

#define VC_N_EQP_ID_IN          "equipment_id"  /*  GRid   */
#define VC_N_REF_CS             "ref"           /*  GRid   */
#define VC_N_LOC_PT             "loc_pt"        /*  DBpoint  */

/*************************************************************************/
/*                  Dirty tricks department                              */
/*                 Stored in object expander                             */
/*************************************************************************/

#define VC_N_TAIL_LENGTH_DB     "tail_length"
#define VC_N_ESTIM_LENGTH_DB    "estim_length"

#define VC_EXIN_TAIL            0
#define VC_EXIN_ESTIM           1

/*************************************************************************/
/*          from equipment                                               */
/*************************************************************************/

#define VC_N_EQP_NUMBER_AN      VD_N_EQP_NUMBER_AN

#define VC_N_EQP_TYPE_AN        "nomenclature"
#define VC_N_EQP_COMPART_AN     "compt_no"
#define VC_N_EQP_UNIT_AN        "unit_no"

/*************************************************************************/
/*          possibly in user collection/ extend sys coll.                */
/*************************************************************************/

#define VC_N_SEQ_NUMBER_AN	"seq_number"	/*  R  */
#define	VC_N_LINE_ID_AN		"line_id"	/*  R  */
#define VC_N_DETAIL_NUM_AN	"detail_num"

#define VC_N_ZONE_AN		VD_N_ZONE_NUMBER_AN
#define VC_N_ERR_FLAG_AN	VD_N_ERR_CMP_FLAG_AN

#define	VC_N_CATEGORY_AN	"category"	/* CABLING */
#define	VC_N_GROUP_AN		"group"		/* CABLING */
#define	VC_N_COMPART_X_AN	"compart_x"	/* CABLING */
#define	VC_N_DECK_X_AN		"deck_x"	/* CABLING */
#define	VC_N_ATT_REF_IN		"att_ref"	/* CABLING */

#define	VC_N_THRUCONN_AN	"thruconnect" 		/* FIBEROPTIC */

/*************************************************************************/
/*                    MISCELLANEOUS  GENERAL                             */
/*         Dynamic attributes for connectivity tables                    */
/*  also uses tag_number, signal_name and conductor_seq (foptic_sec)     */
/*       name indicate from/to of equivalent attributes                  */
/*************************************************************************/

#define VC_N_F_EQP_NUMBER_AN	"f_eqp_number"
#define VC_N_F_TAG_NUMBER_AN	"f_tag_number"
#define VC_N_F_MOD_SEQ_AN	"f_mod_seq"
#define VC_N_F_POS_NAM_AN	"f_pos_nam"

#define VC_N_T_EQP_NUMBER_AN	"t_eqp_number"
#define VC_N_T_TAG_NUMBER_AN	"t_tag_number"
#define VC_N_T_MOD_SEQ_AN	"t_mod_seq"
#define VC_N_T_POS_NAM_AN	"t_pos_nam"

/*************************************************************************/
/*                  Database posting field names                         */
/*              Jumper, Backshell and Terminal Names                     */
/*************************************************************************/
#define VC_N_GENEQ_TAG_AN     "eqpt_tag"   /* Connected equipment part name */
#define VC_N_GENEQ_ID_IN      "eqpt_seqno" /* Connected equipment obj id */
#define VC_N_GENEQ_CAT_AN     "eqpt_cat"   /* Connected equip catalog name */
#define VC_N_GENEQ_NAM_AN     "eqpt_nam"   /* Connected equipment model name */
/**** changed BACK TO eqpt_ver FROM eqpt_rev for CR179701619 */
#define VC_N_GENEQ_REV_AN     "eqpt_ver"   /* Connected equip model version */

/*************************************************************************/
/*                  Database posting field names                         */
/*                   Jumper and Backshell Names                          */
/*************************************************************************/
#define VC_N_BKTERMTAG_AN     "term_tag"   /* Connected Terminal partname */
#define VC_N_BKTERMCAT_AN     "term_cat"   /* Connected Terminal Catalog name */
#define VC_N_BKTERMOBJ_IN     "term_seqno" /* Connected Terminal objid */
#define VC_N_BKTERMNAM_AN     "term_nam"   /* Connected Terminal Model name */
/**** changed BACK TO term_ver FROM term_rev for CR179701619 */
#define VC_N_BKTERMREV_AN     "term_ver" /* Connected Terminal Model version */ 

/******************* Added for CR179701619********************************/
/*************************************************************************/
/*                  Database posting field names                         */
/*                         Jumper Names                                  */
/*************************************************************************/
#define VC_N_JJUMPERID_IN     "jumperid"   /* jumper index                */
#define VC_N_JCOMPNOTE_AN     "comp_note"  /* component notes             */
#define VC_N_JCNTVSMAX_AN     "cnt_vs_max" /*   */
#define VC_N_JNOMTOFLG_AN     "no_mto_flag" /* Material takeoff flag      */
#define VC_N_JTERMMOD_AN      "term_mod"   /* terminal mod id */
#define VC_N_JTERMPOS_AN      "term_pos"   /* terminal position  */ 
/*************************************************************************/
/*                  Database posting field names                         */
/*                           Cable Names                                 */
/*************************************************************************/
#define VC_N_CBCOMPSEQNO_IN "comp_seqno"    /* object id */
#define VC_N_CBASSM_CAT_AN  "assembly_cat"  /* active catalog */
#define VC_N_CBASSM_NAM_AN  "assembly_nam"  /* assembly part name */
#define VC_N_CBASSM_VER_AN  "assembly_ver"  /* assembly version no */
#define VC_N_CBCOMPCODE_AN  "comp_code"     /* comp code */
#define VC_N_CBFRTERMID_IN  "fr_term_seqno" /*Connecting FROM terminal obj id */
#define VC_N_CBFRTERMTG_AN  "fr_term_tag"/*Connecting FROM terminal part name*/ 
#define VC_N_CBFRTERMCAT_AN "fr_term_cat" /*Connecting FROM terminal catalog */
#define VC_N_CBFRTERMNAM_AN "fr_term_nam"/*Connecting FROM term. model name*/ 
#define VC_N_CBFRTERMREV_AN "fr_term_ver"/*Connecting FROM term. model vers.*/ 
#define VC_N_CBTOTERMID_IN  "to_term_seqno" /*Connecting TO terminal obj id */
#define VC_N_CBTOTERMTG_AN  "to_term_tag"   /*Connecting TO terminal part name*/
#define VC_N_CBTOTERMCAT_AN "to_term_cat"  /*Connecting TO terminal catalog */
#define VC_N_CBTOTERMNAM_AN "to_term_nam"  /*Connecting TO terminal model name*/
#define VC_N_CBTOTERMREV_AN "to_term_ver"  /*Connecting TO term. model version*/
#define VC_N_CBFREQPID_IN  "fr_eqpt_seqno" /*Connecting FROM equipment obj id */
#define VC_N_CBFREQPTG_AN  "fr_eqpt_tag"/*Connecting FROM equipment part name*/ 
#define VC_N_CBFREQPCAT_AN "fr_eqpt_cat"/*Connecting FROM equipment catalog */
#define VC_N_CBFREQPNAM_AN "fr_eqpt_nam"/*Connecting FROM equip. model name*/ 
#define VC_N_CBFREQPREV_AN "fr_eqpt_ver" /*Connecting FROM equip. model vers.*/ 
#define VC_N_CBTOEQPID_IN  "to_eqpt_seqno" /*Connecting TO equipment object id*/
#define VC_N_CBTOEQPTG_AN  "to_eqpt_tag"   /*Connecting TO equipment part name*/
#define VC_N_CBTOEQPCAT_AN "to_eqpt_cat"  /*Connecting TO equipment catalog */
#define VC_N_CBTOEQPNAM_AN "to_eqpt_nam"  /*Connecting TO equipment model name*/
#define VC_N_CBTOEQPREV_AN "to_eqpt_ver"  /*Connecting TO equip. model version*/
/*************************************************************************/
/*                  Database posting field names                         */
/*                       Cable Lead Names                                */
/*************************************************************************/
#define VC_N_CB_CONNAME_AN "con_name"  /* lead id */
#define VC_N_CB_SIGNAL_AN  "signalname" /* signal code */
#define VC_N_CB_FRCONSPL_AN  "fr_con_spl" /* FROM connector/splice compcode*/
#define VC_N_CB_TOCONSPL_AN  "to_con_spl" /* TO connector/splice compcode*/
#define VC_N_CB_FRTERMMOD_AN     "fr_term_mod"
#define VC_N_CB_FRTERMPOS_AN     "fr_term_pos"
#define VC_N_CB_TOTERMMOD_AN     "to_term_mod"
#define VC_N_CB_TOTERMPOS_AN     "to_term_pos"
#define VC_N_CB_MARKER_AN	"marker" /* Marker information to support
					    cable running sheets */



#endif
