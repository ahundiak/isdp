
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:57 $
$Locker:  $
*/

#ifndef HSlvhl_include
#define HSlvhl_include 1

#include "ex.h"
#include "igetypedef.h"
#include "igrdp.h"
#include "gr.h"
#include "grdpbdef.h"
#include "grdpb.h"

/* plane structure */
struct HSVEplane
	{
	IGRdouble point[3];
	IGRdouble normal[3];
	};

struct HSlvhl_os_info
	{
	IGRchar			surface_count;
	IGRchar			curve_count;
	IGRshort		osnum;
	IGRchar			readonly;
	
	struct HSlvhl_os_info	*next;
	};
	
struct HSlvhl_info
	{
	double			t_matrix[4][4];
	double			i_matrix[4][4];
	
	int			*p_types;
	double			*p_parms;
	int			p_count;
	struct IGRdisplay	*p_attr;
	struct GRhesym		visible_symbology;
	struct GRhesym		hidden_symbology;
	struct GRmd_env		md_env;
	
	struct HSlvhl_os_info	*os_info;

	struct HSVEplane	clipping_planes[6];

	GRobjid			edge_id;
	GRspacenum		edge_os;
	
	short			text_layer;
	short			visible_layer;
	short			hidden_layer;
	
	char			output_2d;
	char			output_soos;
	char			resolution;
	char			delete_user_overrides;
	char			process_tangent;
	
	void			(*output_span)();
	};
	
extern struct HSlvhl_info	HSlvhl;
#endif
