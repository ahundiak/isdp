//  Name                 : Jan Wilhelmson EHQ
//  Date		 : Jan 9, 1990
//  Filename             : cell.h
//  File description     : Include file for placement of cells & attachment of
//			   of cell-libraries
//  Input data
//		double cell_origin	origin of cell
//		double angle		angle of placement
//		double scale[3]	        scale of cell
//		char   name[20]	        name in active library
//  Ouput Data
//		struct GRid	*PART_ID object id of created cell
//			
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "lcdef.h"
#include "griodef.h"
#include "ex.h"
#include "exdef.h"
#include "grio.h"
#include "lc.h"
#include "grsymdef.h"
#include "grsym.h"
#include "grsymmacros.h"


extern	GRsd_locate_in_asl();
extern	GRclplace();
extern	GRfindmod();
extern	GRretrieve_cell_library();
extern	GRclose_cell_library();
extern	GRlslmgr_fun();

cell_placement(cell_origin,name,draw_cell_angle,draw_cell_scale,PART_ID)
double cell_origin[3];
char   name[20];
IGRdouble  draw_cell_angle;
IGRdouble  draw_cell_scale[3];
struct GRid *PART_ID;
{
struct GRmd_env	mod_env;
struct GRmd_env asl_lib_env;
struct GRid	symbol_id; 
struct GRid	new_obj[1];
struct	GRid	display_info;
int	   	GRdpmode;
int		msg;
int		sts;
	ci$get_module_info(md_env=&mod_env);
	gr$symsd_locate_in_asl(msg =&msg,
				sd_name=name,
				sl_env =&asl_lib_env,
				sd_id =&symbol_id);
	//write("return code for message =",msg,"\n");
	//write("Object id for block symbol=",symbol_id.objid,"\n");
	
	
	gr$sym_cl_place(msg = &msg,
			num_cells = 1,
			origin	= cell_origin,
			angle 	= &draw_cell_angle,
			scale	= draw_cell_scale,
			rot_matrix= mod_env.md_env.matrix,
			name	= NULL,
			properties = GRIS_NEW | GRIS_DISPLAYABLE |
				     GRIS_LOCATABLE,
			display =NULL,
			class_attr= NULL,
			level= NULL,
			symbol_env = &asl_lib_env,
			target_env = &mod_env,
			classname  ="GRclhdr",
			sdh_id 	   = &symbol_id,
			cl_id	   = new_obj);	
//	write("\n ");
//	write("return code for message =",msg,"\n");
//	write("Created object id =",new_obj[0].objid,"\n");
	PART_ID->objid=new_obj[0].objid;
	PART_ID->osnum=new_obj[0].osnum;

GRfindmod(&display_info);
GRdpmode = 0;

ci$send(msg  = message GRgraphics.GRdisplay(&sts,&mod_env.md_env.matrix_type,
						&mod_env.md_env.matrix,
						&GRdpmode,
						&display_info),
					targetid = new_obj[0].objid,
					targetos=mod_env.md_id.osnum);
}

// This function creates problem don't use it
// gives wrong index on the invisible cell-lfile the second
// time
cell_attachment(lib_name)
char	lib_name[MAX_SYMBOL_LIB_NAME];
{
struct GRsymbol_lib_file libstr;
int		sts_ret;
IGRint		fil_no;	
	sts_ret=gr$symretrieve_cell_library(filename=lib_name,
				    file_no =&fil_no,
				    fstat   = EX_default,
				    flag    = EX_read_only);
	if ( sts_ret != EX_succ)
	{
	write("status",sts_ret,"\n");
	exit;
	}
	strcpy(libstr.file_name,lib_name);
	libstr.file_access=GR_SL_READ_ACCESS;
	libstr.file_no=fil_no;
	write("file number",fil_no,"\n");
	gr$symput_asl(msg =&sts_ret,file=&libstr);
	write("return code for cell-lib attachement =",sts_ret,"\n");
	sts_ret=gr$symclose_cell_library(file_no=fil_no,flag=0);	
	if ( sts_ret != OM_S_SUCCESS)
	{
	write("status",sts_ret,"\n");
	exit;
	}
}

