/* $Id: VDCmdDrwFr.S,v 1.1.1.1 2001/01/04 21:08:41 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vddrawing/cmd / VDCmdDrwFr.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdDrwFr.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:41  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/10/07  14:32:20  pinnacle
# Replaced: vddrawing/cmd/VDCmdDrwFr.S for:  by yzhu for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	09/03/97	yzhu		add place_form
 * -------------------------------------------------------------------*/

class specification VDCmdDrwFr (0:1) of VDm_drawing;
#include "FI.h"
#include "FEI.h"

struct SMdraxis{
	struct GRid obj;
        double abs;
        char name[20];
};

struct SMdrframe{
	struct SMdraxis *frame;
        int axis;
        int size_frame;
        int nb_frame;
        struct GRmd_env md_env;
};

struct VDfrsys{
	struct GRid 		grid;
	char	 		name[20];
};

instance VDCmdDrwFr{
	struct GRid 		fr_system;
	variable struct GRid 	ref[20];
	variable struct GRid 	frame[100];
	int 			first,Nb_Max_Ref,Nb_Max_Fra;
	struct SMdrframe 	axis;
	int 			last_ifr;
	Form			form;  		/* form ptr */
	Form			subform;  	/* sub form */
	IGRboolean		form_displayed;	/* flag */
        int			select_axis;    /* flag =1, select axis 
                                                        =0,select frame sys*/
        int			select_all;     /* flag =1, select allframes 
                                                        =0,select frame name*/
	variable struct VDfrsys	vdfrsys[0];	/* store frame system */
	char			act_frsys[20];  /* selected frsys name*/
	char			act_frname[20]; /* selected frame name*/
        char			act_frpos[20];  /* selected frame position */
        char			act_txpos[20];  /* selected text position */
        char			act_prfact[10]; /* selected primary factor */
        int			act_printe;     /* selected primary interval */
        int			act_txinte;     /* selected text interval */
        struct GRid		located_obj; 	/* selected object */
	variable struct GRobj_env drwlist[0]; 
        int			modify_flag;
        int			symb_flag;
        IGRdouble       	range_p1[3];     /* first point of range */
 	IGRdouble       	range_p2[3];     /* first point of range */
        struct GRid	  	line_obj;	
        struct GRid	  	poly_obj;	
};

message realloc_ref(int nb_ref);
message realloc_frame(int nb_frame);
message place_form ( long * sts );  	 	
message display_form ( );  	
message create_form (  int  form_label; char *form_name; Form *form );  
message notify_form (  int form_label; int label; double value; Form form ); 
message get_frsys_list( ); 	
message store_frsys_by_axis(char *input_text); 
message store_frsys_by_name(char *input_text); 	
message store_frame_by_name(char *response_data);
message store_frame_by_all( );  	
message process_object( ); 			
message VDset_drwFramePara(int fr_number;struct VDdrwFrmPar *drwFrmPar); 	
message recompute_object(int index); 		
message get_frame_name_from_frsys(long *loc_msg; int index);
message set_form_by_frsys_or_frame(long *loc_msg; struct GRid inputVDdrawing;
						 int class_flag);
message set_form_pos( ); 			
message save_form_pos( ); 		
message get_VDdrawing_by_frame_name(long *loc_msg; char *input_name);

override 
  init,
  wakeup,
  execute,				 /* modify by yzhu */
  delete;

end specification VDCmdDrwFr;
