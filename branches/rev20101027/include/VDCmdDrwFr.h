/* $Id: VDCmdDrwFr.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/include / VDCmdDrwFr.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDCmdDrwFr.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *      Initial import to CVS
 *
 * Revision 1.6  1999/12/10  23:18:04  pinnacle
 * CR179900942
 *
 * Revision 1.5  1999/12/10  15:33:02  pinnacle
 * CR179900941
 *
 * Revision 1.4  1999/02/12  18:46:52  pinnacle
 * Replaced: include/VDCmdDrwFr.h for:  by mdong for vds
 *
 * Revision 1.3  1998/12/03  14:24:44  pinnacle
 * Replaced: include/VDCmdDrwFr.h for:  by mdong for vds
 *
 * Revision 1.2  1998/10/23  13:33:56  pinnacle
 * Replaced: include/VDCmdDrwFr.h for:  by mdong for vds
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/10/07  14:50:22  pinnacle
 * Created: include/VDCmdDrwFr.h by yzhu for vds
 *
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      09/10/97	yzhu		create
 *      10/10/99	ylong		CR179900941
 *      10/10/99	ylong		CR179900942
 * -------------------------------------------------------------------*/

#ifndef VDCmdDrwFr_include
#define VDCmdDrwFr_include

/*
 *      This file contains constants values for command VDCmdDrwFr.
 */
#define         VD_FRM_MAIN_FORM_LABEL  0
#define         VD_FRM_SUB_FORM_LABEL   1
#define         VD_DrwFr_Mdfy_tx        11
#define         VD_DrwFr_Extr_tx        12
#define         VD_DrwFr_FrSy_tg        13
#define         VD_DrwFr_FrSy_fd        20
#define         VD_DrwFr_FrNm_fd        21
#define         VD_DrwFr_FrPs_fd        22
#define         VD_DrwFr_FrPs_bt        15
#define         VD_DrwFr_PrIn_fd        23
#define         VD_DrwFr_PrFc_fd        24
#define         VD_DrwFr_TxIn_fd        25
#define         VD_DrwFr_TxPs_fd        26
#define         VD_DrwFr_FrSh_tg        28
#define         VD_DrwFr_FrSym_tg       29
#define         VD_DrwFr_Msg_fd         10
#define         VD_DrwFr_ShCk_Vert      31
#define         VD_DrwFr_ShCk_Hori      35
#define         VD_DrwFr_Label_tg       39
#define         VD_DrwFr_Prefix_fd      40
#define         VD_DrwFr_Prefix_text    41
/* added All Caps radio button for CR179900941, by ylong  */
#define         VD_DrwFr_AllCaps_chck   38

/* for sub form */
#define 	VD_DrwFr_LO_Ps          0   /* low position */
#define 	VD_DrwFr_HI_Ps          1   /* hight positio  */
#define         VD_DrwFr_SubFrPs_sl     14
#define         VD_DrwFr_SubSlPs_fd     13


/* state bit: first 8 bits have been used */
#define drw_clear_state         65535   /* 1111 1111 xxxx xxxx */
#define drw_scale_incr          32768   /* 1000 0000 xxxx xxxx */

#define drw_scale_two           512     /* 0000 0010 xxxx xxxx */
#define drw_scale_three         1024    /* 0000 0100 xxxx xxxx */
#define drw_scale_four          2048    /* 0000 1000 xxxx xxxx */

/* No text display.  */
#define drw_without_text        4096    /* 0001 0000 xxxx xxxx */

/* Text on top of line.  */
#define drw_just_top            8192    /* 0010 0000 xxxx xxxx */

#define TEXT_SIZE   80

/* struct for drawing frame */
struct VDdrwFrmPar {
 IGRchar         frsys[20];       /* frame system name */
 IGRchar         frname[20];      /* frame name */
 IGRdouble       frpos;           /* frame position */
 IGRint          txpos;           /* = 0, bottom/left =1, T/R */
 IGRint          prfact;          /* primary factor */
 IGRint          pr_flag;         /* = 1 is primary =0 is not primary */
 IGRint          tx_flag;         /* = 1 with text, =0 without text */ 
 IGRint          md_flag;         /* = 1 modify, = 0 no modify */ 
 IGRint          symb_flag;       /* = 0 default, = 1 from layout form */
 IGRdouble       range_p1[3];	  /* first point of range */
 IGRdouble       range_p2[3];	  /* first point of range */
 IGRint		 labelText;       /* flag for label text: 1 - extract label */
				  /* as distance; 0 - extract label as name */
 IGRint		 nameCase;        /* upper case flag  for extract label as  */
			          /* name, 1 for upper case, 0 for lower case*/
 IGRchar	 prefix[6];       /* prefix for label when extracting it */
			 	  /* as distance			 */
 IGRboolean      iso_flag;	  /* flag for extracting frames on ISO */
 struct GRid     drawingview;     /* selected drawing view object */
 struct GRid     elementobj;      /* selected object to place frame */
 struct GRmd_env element_env;
 IGRint		 ori_flag;
 IGRint		 single_flag;
 IGRint		 centerline_flag;
 IGRint		 frmp_flag;
 IGRdouble	 offset;
 IGRdouble	 text_off;

};

/*
** structures for extracting frame systems and single frame on iso.
*/
#define MAX_FEET 200

struct VDfrsys
{
  struct GRid             grid;
  char                    name[20];
};

struct VDfrsys_oniso
{
  struct GRid             fr_system;
  struct GRid             ref[20];
  struct GRid             geom_macro;
  IGRboolean              iso_flag;
  int                     Nb_Max_Ref;
  int                     Nb_Max_Fra;
  int                     Nb_Max_Obj;
  IGRboolean              form_displayed;
  int                     nb_framesys;
  int                     nb_singleframe;
  char                    frsys[20];
  char                    frname[20];
  int                     act_prfact;     /* selected primary factor */
  int                     act_printe;     /* selected primary interval */
  int                     act_txinte;     /* selected text interval */
  int                     tx_flag;        /* 1 with text; 0 without text */
  int                     pr_flag;        /* 1 -> primary; 0 -> not primary */
  struct GRid             drawingview;    /* selected drawing view object */
  struct GRid             elementobj;     /* selected object to place frame */
  struct GRid             display_window;
  struct GRmd_env         ModuleInfo;
  struct GRmd_env         element_env;
  int                     md_flag;
  int                     orientation_flag;
  int                     singleframe_flag;
  int                     frmposition_flag;
  int                     centerline_flag;
  int                     labeltype;
  int	 		  nameCase; /* upper case flag  for extract label as */
			  /* name, 1 - upper case, 0 - lower case, by ylong  */
  char                    labelprefix[6];
  double                  offset;
  double                  text_offset;
};

/*
** constants for extracting frame systems and single frame on iso.
*/
#define         VD_DrwIsoFr_Extr_tx        12
#define         VD_DrwIsoFr_FrSy_fd        20
#define         VD_DrwIsoFr_SiFr_fd        29
#define         VD_DrwIsoFr_PrIn_fd        23
#define         VD_DrwIsoFr_PrFc_fd        24
#define         VD_DrwIsoFr_TxIn_fd        25
#define         VD_DrwIsoFr_TxPs_fd        26
#define         VD_DrwIsoFr_FrOff_fd       35
#define         VD_DrwIsoFr_TxOff_fd       19
#define         VD_DrwIsoFr_Msg_fd         10
#define         VD_DrwIsoFr_Label_tg       39
#define         VD_DrwIsoFr_Prefix_fd      40
#define         VD_DrwIsoFr_Prefix_text    41
#define         VD_DrwIsoFr_TxtOri_tg      14
#define         VD_DrwIsoFr_Single_tg      15
#define         VD_DrwIsoFr_Center_tg      150
#define         VD_DrwIsoFr_FrPos_tg       22
#define         VD_DrwIsoFr_Caps_chck      38  /* CR179900942 by ylong */


#endif
