class implementation DMroot;

/*
	This files contains all the Global variables defined
	and used by dimensions,
*/

#define AS_DEBUG 1

%safe
#include "math.h"
%endsafe

#include "dimfont.h"
#include "FI.h"

#include "FEI.h"
#include "CIforms.h"

#include "dimformdef.h"
#include "dimform.h"
#include "dimsurf.h"

#include "form_env.h"
#include "form_loc.h"

#include "msdef.h"
#include "msmacros.h"
#include "DMmessages.h"

%safe

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif
#if defined(__cplusplus)
extern "C" {
#endif

static int init_dm_sizes __((void));

#if defined(__cplusplus)
}
#endif
#undef __

struct DMglobal DM_global;
int DMsizes[6];
struct DMenv_param frm_env;
struct DMloc_param frm_loc;
struct DMmisc_param frm_misc;
struct DMsenv_param frm_senv;
struct DMglobal_param frm_glob;
struct DMweld_param frm_weld;
struct DMsurf_param frm_surf;
struct DMgadget_stack edit_stack;
int    frm_state, Imp_count, Dim_count, Disp_count;
int    GL_sgl_type = SINGLE_ARC_LENGTH;
IGRboolean display_invisible_dims = FALSE;
IGRboolean display_reffile_dims = FALSE;
IGRboolean display_different_dims = FALSE;
IGRboolean display_ref_diff_dims = FALSE;
IGRboolean Dim_rad_jog = FALSE;
IGRboolean Dim_coord_jog = FALSE;
struct GRid Dim_grid;
%endsafe;

from GRfm import GRmake_entry, GRduplicate_font;

static init_dm_sizes ()
{
	struct DMenv_param par_env;
	struct DMloc_param par_loc;
	struct DMmisc_param par_misc;
	struct DMsenv_param par_senv;
	struct DMweld_param par_weld;

	DMsizes[DM_ENV_PARAM] = (int)&par_env._end - (int)&par_env;
	DMsizes[DM_LOC_PARAM] = (int)&par_loc._end - (int)&par_loc;
	DMsizes[DM_MISC_PARAM] = (int)&par_misc._end - (int)&par_misc;
	DMsizes[DM_SENV_PARAM] = (int)&par_senv._end - (int)&par_senv;
	DMsizes[DM_WELD_PARAM] = (int)&par_weld._end - (int)&par_weld;
}

DMinit_glob ()
/*.DMinit_glob*/
{
	IGRint status;
	struct DMsymbol_info *symbol_info;
	struct DMterm_info *term_info;
	IGRint index;
	double *conv_factor;

	init_dm_sizes();

	term_info = DM_global.term_info;

	term_info[TER_TYPE_HOLLOW_ARROW].font_num =
	term_info[TER_TYPE_FILLED_ARROW].font_num =
	term_info[TER_TYPE_OPEN_ARROW].font_num =
	term_info[TER_TYPE_DOT].font_num =
	term_info[TER_TYPE_CIRCLE].font_num = FONT_102;

	term_info[TER_TYPE_SLASH].font_num =
	term_info[TER_TYPE_BACK_SLASH].font_num =
	term_info[TER_TYPE_BLANK].font_num = FONT_DEFAULT;

	term_info[TER_TYPE_HOLLOW_ARROW].font_char = 'C';
	term_info[TER_TYPE_FILLED_ARROW].font_char = 'Z';
	term_info[TER_TYPE_OPEN_ARROW].font_char = 'A';
	term_info[TER_TYPE_DOT].font_char = 'P';
	term_info[TER_TYPE_CIRCLE].font_char = 'O';
	term_info[TER_TYPE_SLASH].font_char = '/';
	term_info[TER_TYPE_BACK_SLASH].font_char = '\\';
	term_info[TER_TYPE_BLANK].font_char = ' ';

	term_info[TER_TYPE_HOLLOW_ARROW].center_just =
	term_info[TER_TYPE_FILLED_ARROW].center_just =
	term_info[TER_TYPE_OPEN_ARROW].center_just = FALSE;

	term_info[TER_TYPE_DOT].center_just =
	term_info[TER_TYPE_CIRCLE].center_just =
	term_info[TER_TYPE_SLASH].center_just =
	term_info[TER_TYPE_BACK_SLASH].center_just =
	term_info[TER_TYPE_BLANK].center_just = TRUE;

	DM_global.symbol_info[DIM_STAN_ANS] =
	DM_global.symbol_info[DIM_STAN_BSI] =
	symbol_info = DM_global.ansi_sym_info;

	symbol_info[SYM_TYPE_DIAMETER].font_num =
	symbol_info[SYM_TYPE_ANGULAR].font_num =
	symbol_info[SYM_TYPE_PLUS_MINUS].font_num = FONT_100;

	symbol_info[SYM_TYPE_DIAMETER].font_char = 'n';
	symbol_info[SYM_TYPE_ANGULAR].font_char = '^';
	symbol_info[SYM_TYPE_PLUS_MINUS].font_char = '~';

	DM_global.symbol_info[DIM_STAN_ISO] =
	DM_global.symbol_info[DIM_STAN_DIN] =
	DM_global.symbol_info[DIM_STAN_JIS] =
	symbol_info = DM_global.misc_sym_info;

	symbol_info[SYM_TYPE_DIAMETER].font_num =
	symbol_info[SYM_TYPE_ANGULAR].font_num = FONT_31;
	symbol_info[SYM_TYPE_PLUS_MINUS].font_num = FONT_30;

	symbol_info[SYM_TYPE_DIAMETER].font_char = '`';
	symbol_info[SYM_TYPE_ANGULAR].font_char = '^';
	symbol_info[SYM_TYPE_PLUS_MINUS].font_char = '~';

	conv_factor = DM_global.conv_factor;
	for (index=0; index<MAX_MEA_UNIT; index++)
	{
		status =
		DMget_cnv_factor(index, &conv_factor[index]);
		dm$status(action = RET_STATUS);

		/*"mea_unit=%d, conv_factor=%lf\n", index, conv_factor[index]*/
	}

	/*- Initialise Surface Symbol Global Structure */

	frm_surf.sym_posn = SURF_ABOVE;
	frm_surf.basic_sym = SURF_ANGLE;
	frm_surf.line_on = FALSE;
	frm_surf.dir_sym = SURF_DIR_NONE;
	frm_surf.text_a[0] = '\0';
	frm_surf.text_b[0] = '\0';
	frm_surf.text_c[0] = '\0';
	frm_surf.text_d[0] = '\0';
	frm_surf.text_e[0] = '\0';
	frm_surf.text_f[0] = '\0';

	return(TRUE);
}

IGRint DMmap_font ( osnum,
                    font_index)
/*(
	 OMuword  osnum,
	 IGRshort  font_index
	)
*/
OMuword osnum;
IGRshort font_index;
/*.DMmap_font*/
{
	static char *font_name[MAX_DIM_FONTS] = {	"default",
							"30",
							"31",
							"100",
							"102"
						};
	IGRint rc;
	char   stsmsg[64];
	IGRshort font_num;

	DMretrieve_font(&rc, osnum, (IGRuchar *)font_name[font_index], &font_num);
	if (rc != DIM_S_SUCCESS)
	{
                ex$message(msgnumb = DM_I_ErrRetFont,
                           type = "%s",
                           var = `font_name[font_index]`);
		font_num = 0;
	}

	return((IGRint)font_num);
}

DMretrieve_font (msg,
                 osnum,
		 font_name,
		 font_num)
		 /*(
	 IGRint  *msg,
	 OMuword  osnum,
	 IGRuchar  *font_name,
	 IGRshort  *font_num
	)
	*/
IGRint *msg;
OMuword osnum;
IGRuchar *font_name;
IGRshort *font_num;
/*.DMretrieve_font*/
{
        IGRint status;
	IGRlong long_rc;
	OM_S_OBJID fontmgr_id, cur_mod_id;
	GRspacenum cur_mod_osnum;
	
	*msg = DIM_E_FONT_RETR;

	/*"os=%d, font=%s\n", osnum, font_name*/

	*font_num = -1;

	ex$get_modid(mod_osnum = osnum,
		     mod_id = &cur_mod_id);

	cur_mod_osnum = osnum;
        ex$get_super(mod_id = cur_mod_id,
                      mod_osnum = cur_mod_osnum,
                      super_name = FONTMGR_NO_NAME,
                      create = TRUE,
                      super_class = "GRfm",
                      super_id = &fontmgr_id,
                      super_osnum = &osnum);

	*font_num = -1;

	status =
	om$send(msg = message GRfm.GRduplicate_font(
					&long_rc,
					font_name,
					font_num),
		senderid = NULL_OBJID,
		targetos = osnum,
		targetid = fontmgr_id);
	dm$status(action = RET_STATUS);

	if (*font_num == -1)
	{
		/*|GRmake_entry*/

		status =
		om$send(msg = message GRfm.GRmake_entry(
						&long_rc,
						font_name,
						font_name,
						TEXT_FONT,
						font_num),
			senderid = NULL_OBJID,
			targetos = osnum,
			targetid = fontmgr_id);
		dm$status();
		if(long_rc != MSSUCC)
		{
                	ex$message(msgnumb = DM_I_ErrRetFont,
                           type = "%s",
                           var = `font_name`);
			*font_num = 0;
		}
	}

	if (*font_num != -1)
		*msg = DIM_S_SUCCESS;

	return(TRUE);
}

end implementation DMroot;


