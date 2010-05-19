/* $Id: dim.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:        vds/vdinclude/dim.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: dim.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:51  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.1  1996/01/10  15:23:40  pinnacle
 * Created: vdinclude/dim.h by jwfrosch for vds.240
 *
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *	01/10/96     HF		This file is an extended version of the GRNUC file.
 *				Extensions are required by the NEW Item Balloon
 *				functionality in EMS as well as VDS.
 *				Until this new functionality has been integrated in
 *				EMS, this file has to remain in vdinclude.
 *
 *				NOTE:
 *				ANY SOURCE FILE that uses ANY of the NEW functionality
 *				HAS TO use THIS FILE in stead of the GRNUC version.
 *				This means that $VDS/vdinclude needs to preceed $GRNUC/include
 *				in the INCLUDE section of the <name>.m file
 *
 *************************************************************************/

#ifndef dim_include
#define dim_include

/*
    Using FI_STRLEN as a buffer size conflicts with the definition in
    /usr/include/FEI.h, which uses FI_STRLEN as a possible parameter to
    FI_modify_env.  Use the definition EXFI_STRLEN from $EXNUC/include/exfi.h
    instead; its value is also 132, to maintain compatibility with the old
    object-based form definition.
*/
/* #define FI_STRLEN 132 */

#define ENV_FUTURE_DBL_SIZE	3
#define ENV_FUTURE_CHR_SIZE	4
#define LOC_FUTURE_DBL_SIZE	2
#define LOC_FUTURE_CHR_SIZE	7
#define GAP_FUTURE_DBL_SIZE	7
#define MSC_FUTURE_DBL_SIZE	16
#define MSC_FUTURE_CHR_SIZE	31
#define SENV_FUTURE_DBL_SIZE	3
#define SENV_FUTURE_CHR_SIZE	3
#define WELD_FUTURE_CHR_SIZE	8

struct DMenv_param
{
	double future_double[ENV_FUTURE_DBL_SIZE];
	double stk_spacing;
	double txt_heig;
	double txt_widt;
	double ter_heig_r;
	double ter_widt_r;
	double txt_yoff_r;
	double pnt_exte_r;
	double tol_size_r;

	double lin_offs_r;
	double proj_angl;
	double sca_fact;
	double proj_offs_r;
	double proj_extn_r;

	IGRshort text_font;
	IGRshort frac_font;
	IGRshort dim_layr;

	char   dim_stan;		/* dimension standard */
	char   pri_unit;
	char   sec_unit;
	char   ang_unit;

  	char   dual_mode;		/* dual mode ON/OFF */
	char   dual_disp;		/* display type in dual mode */
	char   dim_colr;		/* dimension color */

	char   dim_weig;
	char   txt_weig;
	char   tol_weig;

	char   sym_posn;		/* BEFORE, AFTER, NONE */

	char   ter_type0;		/* origin terminator type */
	char   ter_type;		/* measure terminator type */
	char   comm_origin;		/* terminator type for comm origin */
	char   nts_uline;		/* NTS Underline - ON/OFF */
	char   det_colr;		/* Detached Dimension Colr. */

	char  stk_orie;
    char  stk_dir;
	char  attach_pt;
	char   future_char[ENV_FUTURE_CHR_SIZE];

	char   _end;
};

struct DMloc_param
{
	double future_double[LOC_FUTURE_DBL_SIZE];

	struct measure_unit
	{
		unsigned char decacc;
		unsigned char fraacc;
		unsigned char leading;
		unsigned char trailing;
		unsigned char label[9];
		unsigned char sub_label[9];
		unsigned char tole_low[9];
		unsigned char tole_up[9];
		char deci_char;
	} primary, secondary;

	struct angular_unit
	{
		unsigned char ang_roff_unit;
		unsigned char decacc;
		unsigned char fraacc;
	} angular;

	char ter_disp;
	char proj_disp;
	char lin_disp;
 	char txt_orie;
	char txt_posn;
	char ctxt_posn;	/* Coordinate text position */
  	char tole_mode;
	char deci_frac;
	char max_sub;

	char future_char[LOC_FUTURE_CHR_SIZE];

	char _end;
};

struct DMstd_param
{
	IGRdouble dm_car_spac;
	IGRdouble dm_lin_spac;
	IGRdouble dm_text_clear;
	IGRdouble dm_pre_suf_gap;
	IGRdouble dm_sym_gap;
	IGRdouble dm_dual_off;
	IGRdouble dm_tol_hor_gap;
	IGRdouble dm_tol_ver_gap;
	IGRdouble dm_lim_ver_gap;
	IGRdouble dm_box_hor_gap;
	IGRdouble dm_box_ver_gap;
	IGRdouble future_double[GAP_FUTURE_DBL_SIZE];
};

struct DMmisc_param
{
	double  future_double[MSC_FUTURE_DBL_SIZE];
	double	ter_limit_r;
	double  asp_rati_r;

	struct  DMstd_param std_param;

	IGRshort sixteen_bit_font;

	char	prefix[EXFI_STRLEN];
	char	suffix[EXFI_STRLEN];
	char	dim_override[EXFI_STRLEN];
	char	pri_tole_sym[8];
	char	sec_tole_sym[8];

	char	prefix_disp;
	char	suffix_disp;
	char	aut_cent;

	char	tog_term;
	char	unit_sel;
	char	tole_dsp;
	char	mod_comp;
	char	aut_dia;
	char    future_char[MSC_FUTURE_CHR_SIZE];

	char	_end;
};

struct DMsenv_param
{
	double future_double[SENV_FUTURE_DBL_SIZE];
	double stk_spacing;
	double txt_heig;
	double txt_widt;
	double ter_heig_r;
	double ter_widt_r;
	double car_spac;
	double lin_spac;
	double txt_yoff_r;
	double bln_size;

	IGRint	num_sides;

	IGRshort dim_layr;
	IGRshort text_font;
	IGRshort frac_font;

	char  dim_colr;
	char  dim_weig;
	char  txt_weig;
	char  ter_type;
	char  ter_disp;
	char  an_orie;
	char  an_posn;
	char  bln_type;
	char  datum_ter_type;
	char  dim_stan;
	char  value_type;
	char  stk_orie;
	char  stk_dir;
	char  attach_pt;
	char  future_char[SENV_FUTURE_CHR_SIZE];

	char  _end;
};

struct DMweld_param
{
	struct text_info
	{
		char ftext[32];
		char rtext[32];
		char ztext[32];
		char text1[32];
		char text2[32];
		char text3[32];
		char weld_symbol;
		char weld_type;
	} atext, btext;

	char tailtext[32];
	char tail;
	char above;
	char below;
	char center;
	char flag;
	char circle;
	char dash_line;
	char cross_section;
	char cen_symb;
	char z_symb;
	char ansi_weld;
	char proj_method;
	char future_char[8];
	char  _end;
};

struct DMglobal_param
{
	double view_angle;

	char dim_mode;
	char driving_color;
	char driven_color;
	char detached_color;
	char ref_type;
	char disp_type;
};

struct dim_param_attr
{
	int  type;
	int  size;
	char *data;
};

struct DMdim_line
{
	IGRdouble  line[6];
	IGRint     line_index;
	IGRboolean needed;
};

struct DMdim_arc
{
	IGRdouble startpt[3];
	IGRdouble endpt[3];
	IGRdouble centerpt[3];
	IGRint    line_index;
	IGRint    flag;
	IGRboolean needed;
};

struct dim_attr
{
	IGRpoint  orig, meas;

	IGRdouble brk_dist;
	IGRdouble lead_dist;
	IGRdouble trak_dist;
	IGRdouble offs_pt[2];
	IGRdouble prj_offs[2];
	IGRdouble jog_offs[4];

	IGRshort dim_type;
	IGRchar  dim_state;
	IGRchar  geom_type;
	IGRchar  display;
	IGRchar  jogged;

	IGRuchar  mea_trak;
	IGRuchar  brk_pos;
	IGRuchar  leader;
	IGRuchar  ter_loca;
};

struct cenline_attr
{
	IGRpoint   pnt_meas;
	IGRdouble  gap_r;
	IGRdouble  minor_len_r;
	IGRdouble  major_len_r;
	IGRshort   dim_type;
	IGRshort   dim_state;
	IGRboolean posn;
};

struct annot_attr
{
	IGRpoint   start_pt, end_pt;
	IGRuchar   *text_string;
	IGRdouble  *brkpt;

	IGRshort dim_type;
	IGRshort text_length;
	IGRshort num_brkpt;

	IGRchar  dim_state;
	IGRchar  geom_type;
	IGRchar  display;
	IGRchar	 leader;
	IGRchar  dual_mode;
	IGRchar  tol_symbol;
	IGRchar  bln_dir;
};

#endif
