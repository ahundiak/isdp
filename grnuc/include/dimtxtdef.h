
#ifndef dimtxtdef_include 
#define dimtxtdef_include

#include "dimdef.h"
#include "dim.h"
#include "dimtxt.h"
#include "dimglobal.h"

#define FNUM_DIM_START			1
#define FNUM_DIM_ALT_START		5
#define FNUM_PREFIX_START 		10
#define FNUM_DIM_FIELD			15
#define FNUM_SYMBOL_BEFORE		20
#define FNUM_SINGLE_START		50
#define FNUM_SINGLE_END			90
#define FNUM_DUAL_START			100
#define FNUM_DUAL_MIDDLE		140
#define FNUM_DUAL_END			180
#define FNUM_SYMBOL_AFTER		200
#define FNUM_SUFFIX_START 		220
#define FNUM_DIM_END			230

#define FNUM_BEGIN_PAREN_SINGLE		30
#define FNUM_CLOSE_PAREN_SINGLE		80
#define FNUM_BEGIN_PAREN_ABOVE		95
#define FNUM_CLOSE_PAREN_ABOVE		130

#define FNUM_BEGIN_PAREN_BELOW		135
#define FNUM_CLOSE_PAREN_BELOW		175

#define FNUM_REF_SUFFIX_SUBFIX		210

#define ATTR_EDITABLE			0
#define ATTR_NON_EDITABLE		1
#define ATTR_DIM_TYPE			5

#define LABEL_FIELD			1
#define LABEL_SUB_FIELD			2

#define PRIMARY_UNIT			0
#define SECONDARY_UNIT			1

#define DM_DIM_OFFSET			10
#define DM_TOL_OFFSET			5
#define DM_UNKNOWN_NUM			-1

#define DM_REF_MODE			25

#omdef dm$return_field_no(dim_mode=DM_UNKNOWN_NUM ^ dim_type=DM_UNKNOWN_NUM,
                           tole_mode = TOLE_MODE_OFF,unit_mode=DM_UNKNOWN_NUM,
                           field_no)
{
        DMreturn_dim_field(dim_mode,dim_type,tole_mode,unit_mode,field_no);
}
#endomdef

#define L_START         4
#define L_END           2
#define L_h_MOVE        10
#define L_m_MOVE        19
#define L_M_MOVE        20
#define L_s_MOVE        10
#define L_x_MOVE        10
#define L_y_MOVE        10
#define L_v_MOVE        10
#define L_s_MOVE        10
#define L_f_FONT        4
#define L_w_WEIG        3

#endif
