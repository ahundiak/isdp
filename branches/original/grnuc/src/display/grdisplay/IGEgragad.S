/*
Class
        IGEgragad (graphic gadget) of IGEgadget (gadget system)

Description
        This defines the graphic gadget class.

History
        MP      09/12/85    Design date.
        mrm     09/18/91    added data vla, to be initially used for
                            polar grid display
*/

class specification IGEgragad (1:0) of IGEgadget, IGEdisplay;

#include "gr.h"
#include "dpchan.h"
#include "dpdef.h"

/*      construct is IGEgragad_construct;*/

     /*   instance data for wn   */


               instance IGEgragad
               {
                   struct DPgra_gad                    gragad;
                   variable unsigned char              data[];
                   channel gra_gad_to_winsup           winsup;
                   channel gra_gad_to_all              all;
                   channel gra_gad_to_instance_support inst_support;
               };
           
           
  /* MESSAGES */
	
	override delete;
	
        /* activate window when old module was brought up and when a 
           window is constructed */
        
        override activate;       

        /* clear delete window(env 5 window) when close module  */

        override clear;
              
        override convert_pnt;    /* convert point */

        override movicon, delicon, covicon, clpicon;
   
        override debug;

	override change_process_to,change_process_from;
        /* display by objid          */

        override DPdisbyoid, DPdisbybuf, DPupdate, DPerase_hilite;

           
        message DPcal( IGRlong *msg);

        /* inquire rotation matrix   */
        message DPinrot (IGRlong *msg; IGRdouble *rotate);

        /* draw grid                 */
        message DPgriddraw (IGRlong *msg; struct DPdit_range *range);

        /* conversion routine used by grid method               */

        message DPuor2dit (IGRlong *msg; IGRdouble *xuor; IGRdouble *yuor;
        IGRdouble *zuor; IGRdouble *xdit; IGRdouble *ydit; IGRdouble *zdit);
           
        /* toggle grid on/off flag in instance data             */
        message DPgridonoff (IGRlong *msg); 

        /* toggle grid_lock flag in instance data             */

        message DPgridlock (IGRlong *msg);           

           
        /* inquire entries in instance data                      */
        message DPinquire (IGRlong *msg;IGRlong *which_error; struct var_list *var_list );

         /* set entries in instance data                      */
        message DPset (IGRlong *msg;IGRlong *which_error; struct var_list *var_list );

        message DPrngbox (IGRlong *msg; IGRdouble *x; IGRdouble *y;
                           IGRdouble *z; IGRdouble *dit_tol; IGRdouble *range);


        message DPcollect_win(IGRlong *msg; IGRint *num_windows;
				IGRint max_ids; struct GRid *win_ids; 
				IGRint flag);


        message gragad_cons(IGRlong *msg; IGRchar *name;IGRdouble min_x;
                            IGRdouble min_y; IGRdouble max_x; IGRdouble max_y);

	message DPfit(IGRlong *msg; IGRint fit_flag);
	
	message DPlevels(IGRlong *msg; IGRint *levels; IGRint num_of_entries;
			 IGRint *level_mask; IGRboolean on_off; 
			 IGRboolean update);

	message DPgen_update (IGRlong *msg; struct DPdit_range *range; 
                 IGRboolean *update_all; enum GRdpmode mode; IGRboolean erase);

	message DPupd_app_init(IGRlong *msg; struct DP_information *dp_info);

	message DPview_vol (IGRlong *msg; IGRshort flags; IGRshort *ret_flags;
	IGRdouble *origin; IGRdouble *rotation; IGRdouble *vw_vol;
	IGRdouble *display_depths; IGRdouble *active_z; IGRshort *defaults_vol;
	 IGRshort *def_dis_depths;
	 IGRdouble *new_vw_vol; IGRdouble *new_display_depths; 
	 IGRdouble *new_active_z; IGRdouble *new_coor_vol; IGRboolean update);


	message DPcenter (IGRlong *msg; IGRdouble *wld_point; 
			  IGRboolean update);

	message DPzoom (IGRlong *msg; IGRshort in_out_flag; IGRdouble *center_pnt; 
			IGRdouble factor; IGRboolean update);
	
	message DPscroll (IGRlong *msg; IGRdouble *wld_points;
			  IGRboolean update);
	
	message DProtate (IGRlong *msg; IGRshort flag; IGRdouble *origin; 
			  IGRdouble *mtx; IGRboolean update);
	
        message DPdelayonoff (IGRlong *msg); 	

	message DPwnarea (IGRlong *msg; IGRint in_flags; IGRdouble *wld_points;
			  IGRboolean update);

	message set_view_ind(IGRint type; IGRdouble *point; 
			     struct DPviewinfo *old);

	message reset_view_ind(struct DPviewinfo *old);


        /* inquire range box         */
        message DPinrgbox (IGRlong *msg; IGRdouble *wld_vwpt; IGRdouble
	        *vwpt_wld; IGRdouble *wcs_tol);
           
	message DPcal_persp (IGRlong *msg);
	
	message DPset_persp (IGRlong *msg; struct GRid *gg_id;
	IGRshort in_flags; IGRshort *ret_flags;
	IGRdouble *vrp; IGRdouble *vpn;	IGRdouble *vup; IGRdouble *eye_pt; 
	IGRdouble *coi; IGRdouble *vw_angle; IGRdouble *pnear; IGRdouble *pfar;
	IGRdouble *r_vrp; IGRdouble *r_vpn; IGRdouble *r_vup; 
	IGRdouble *r_eye_pt; IGRdouble *r_coi; IGRdouble *r_vw_angle; 
	IGRdouble *r_near; IGRdouble *r_far);

	message DPun_persp (IGRlong *msg);

	message DPcvt_persp (IGRlong *msg; IGRint in_flags);

	message dynamics(IGRlong *msg; IGRdouble zoom_factor; 
			 IGRdouble pan_factor; IGRdouble max_rotate_factor;
                         IGRdouble stroke_scale_factor);


	message start_frame(IGRlong *msg; IGRint display_frame;
			    IGRdouble **buffer; IGRint *buf_size;
			    IGRint *gpipe_fb; IGRdouble **gpipe_fb_buf;
			    IGRint *gpipe_fb_size; GRobjid *frame_id;
			    GRspacenum *frame_osnum);

	message display_frames(IGRlong *msg; IGRint start_frame; IGRint relative_frame;
		      IGRint number_of_frames; IGRint number_of_cycles;
		      IGRint direction; IGRint erase; IGRint rotation_allowed;
		      IGRint db_allowed; IGRdouble zoom_factor;
		      IGRdouble pan_factor;  IGRdouble max_rotate_factor;
		      IGRint (*func_ptr)(); IGRchar *func_parms );

	message display_frame(IGRdouble *frame; IGRint erase);

	/* flag is set to TRUE, if the gragad will allow its class to be */
	/* changed to support shading                                    */
	message DPshading_allowed( IGRboolean *flag );
	
	/* flag is set to TRUE, if the gragad will allow its class to be */
	/* changed to support hidden line                                */
	message DPhidden_line_allowed( IGRboolean *flag );

end specification IGEgragad;

