class specification COreviewele (1:0) of COtools, CEO_LOCATE;



#include "OMlimits.h"
#include "igrdp.h"
#include "grdpbdef.h"
#include "go.h"
#include "grio.h"
#include "igr.h"
#include "grcoordsys.h"
#include "FI.h"


instance COreviewele
{
    /*  variables needed for main form  */

	IGRchar			file_name[OM_K_MAXOSNAME_LEN];  
	IGRchar			color_name[24];
        IGRchar			element_name[MAXNAMSIZE];
	IGRchar			layer_name[40];
	struct GRobj_info	info;
	struct GRsymbology	symbology;
	variable IGRchar	form_names[][132];
        IGRint			form_index;

    /*  variables needed for active readout  */

	IGRchar			cs_type[MAX_CS_TYPE]; /* coordinate sys type */
	GRIOalias_name		distance_units[3];    /*active distance units*/
	GRIOalias_name		angle_units[3];       /* active angular units*/
 	struct GRIOreadout_spec readout_distance;     /*readout specification*/
 	struct GRIOreadout_spec readout_angle;	      /*readout specification*/
	GRname		        cs_name;
	struct GRid		act_cs_id;	      /* coordinate sys mgr  */
	struct GRcsquery_info   *cs_info_ptr;	      /* active cs readout   */
    IGRint            main_form;
    /*  global variables used in most methods  */

    IGRint   sub_form;
    IGRint display;
	struct GRid		element;	/*  selected object's objid  */
	struct GRmd_env		element_env;    /*  selected object's env    */
	struct GRmd_env		active_env;	/*  master file environment  */

    /*  variables needed to fill in subforms  */

	IGRchar			coor1_label[10];
	IGRchar			coor2_label[10];
	IGRchar			coor3_label[10];

	IGRchar			units_field1[40];
	IGRchar			units_field2[40];
	IGRchar			units_field3[40];
	struct GRIOreadout_spec spec_array[3];

};


message inquire_data_main_form ( long * sts );

override form_notification;

message update_subform (IGRint *msg);

message construct_subform (IGRint *msg;
                          IGRchar *form_name;
                          IGRint *index);

message display_data_main_form ( long * sts );

override sleep;

override wakeup;

end specification COreviewele;
