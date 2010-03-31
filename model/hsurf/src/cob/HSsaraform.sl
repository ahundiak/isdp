/*                                      
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:33 $
$Locker:  $

HISTORY:
	05/??/89   Created "Change Active Shading Style" form	A.M. Thomas

	05/25/89   Converted to cbase forms.		  	Trevor Mink	

	06/19/89   Converted to "Set Active Shading Paramters" 	Trevor Mink	

   	12/27/90   Created "Set Surface Texture" form		Shridar
								Subramanian

	05/28/91   Converted to "Set Active Rendering Attributes"
		   Added sphere and toggle for finish.		Yvonne Chu	

	??/??/92   Converted to "Set Active Shading Attributes"
		   All user references to rendering removed.  	Yvonne Chu
*/

class              HSsaraform
super_class        CEO_GSLOCATE
command_string     HSM_M_SetActRenAttr,0,HSStAcRnAt
form               "HSRenderAttr",0,0,"-1","-1"
form               "HSSetSurfTex",1,0,590,105
product_name       "$MODEL"
start_state        start

specification

#include "wl.h"
#include "igecolor.h"
#include "FI.h"

#define RGB_XMAX 128
#define RGB_YMAX 128

instance
	{
	IGRint		finish;			/* Phong shading parameters */
	IGRdouble	spec_refl, diff_refl, transparency;
	IGRint		switch1;
	IGRint		texture_active;			
	IGRint		linear_rng;			
	unsigned short  *sph_fin000;  
	unsigned short  *sph_fin100; 
	unsigned short  *sph_fin050;
	unsigned short  *sph_dif;
	unsigned short  *sph_trn;  
	unsigned short  *sph_texture;  
        IGRchar         textfname[16];  	/* filename of the texture */
        IGRchar         curr_dname[256],temp_dir[256]; /* current directory */
        int     	SR_active;
        int     	selected;		/* texture file is selected */
  	IGRuchar orient;			
	int		no_texture, no_transparency;
 	int 		no_fin0, no_fin1;	
	unsigned short  textindex;
	IGRchar 	textname[100];
	unsigned short  sph_index;
	int 		color_plane;
	double		exp_save;
	int		slider_reset;
	int 		trans_active_msg;
	int 		from_active, update_color;
        WLhwin_no	hwin_no;
        WLuint16	lscreen_no;
        WLuint32	context_no;
        WLuint32	lwin_no;
	short           init_rgb_called;
#ifdef X11
	int 		allocated_window;
	unsigned long   planemask;
#endif
	}

implementation

#define DISPLAY_COLOR   4008
#define DISPLAY_TEXTURE 4006 
#define DRAW_COMPOSITE  4007 
#define RESET_COMPOSITE 4009 
#define EXIT    	4005
#define FINISH_MAX	 128

#define MAIN_FORM	   0 
#define TEXTURE_FORM	   1	

#include "dpgraphics.h"

#ifdef X11
#define MAX_WINDOW 40
#include <limits.h>
#endif

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <fcntl.h>

#include <FI.h>

#include <sys/types.h>
#if defined (SUNOS5)
#include <dirent.h>
#else
#include <sys/dir.h>
#include <sys/dirent.h>
#endif

#include "HSsara.h"
#include "igrdp.h"

#include "hsmsg.h"
#include "msmacros.h"
#include "msdef.h"
#include "HSsaraform.h"
#include "exmacros.h"
#include "exdef.h"
#include "hsurf.h"
#include "hsdef.h"
#include "hsmacdef.h"
#include "hsmacros.h"
#include "hstex_table.h"
#include "hstexmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "OMminimum.h"			 
#include "OMmacros.h"
#include "dpmacros.h"
#include "gr.h"
#include "growner.h"
#include "igewindef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igecolordef.h"
#include "igecolmacros.h"
#include "grgs.h"
#include "grgsmacros.h"
#include "HSrle.h"
#include "hsanimate.h"
#include "hsmachine.h"
#include "igewindow.h"
#include "igewinmacros.h"
#include "HSpr_co_func.h"

extern OMuword OPP_EMScomposite_class_id;

#ifdef X11

/*--- HSwindow_event_routine ------------------------------------------------*/

static void HSwindow_event_routine(label, event, fp)
	int label;
	int event;
	Form fp;
/*
NAME
	HSwindow_event_routine

DESCRIPTION
	Redisplays sphere if form is updated.

PARAMETERS
	label (IN) - gadget label
	event (IN) - form event
	fp (IN)	   - form pointer

GLOBALS USED
	none

HISTORY
	??/??/92    Yvonne Chu 
	   Created
*/
    {
    unsigned int   cmd_oid;
    unsigned short cmd_os;
    long           msg;

    if (event == FI_DISPLAY)
        {
        FIf_get_cmd_oid_os ( fp, &cmd_oid, &cmd_os );

        om$send ( senderid = cmd_oid, 
                  targetid = cmd_oid, 
                  targetos = cmd_os,
                       msg = message HSsaraform.display_sphere_init(&msg)  );

        om$send ( senderid = cmd_oid, 
                  targetid = cmd_oid, 
                  targetos = cmd_os,
                       msg = message HSsaraform.display_sphere(&msg)  );
        }
    }
#endif


/*--- HSget_dir -------------------------------------------------------------*/

static void HSget_dir(filename, textfname, curr_dname, STD_DIR)

   char filename[100];
   char textfname[16];
   char curr_dname[256];
   int  *STD_DIR;
/*
NAME
	HSget_dir

DESCRIPTION
	Checks if texture file is in the standard texture directory 
	$MODEL/config/textures and sets STD_DIR to TRUE if it is.  

PARAMETERS
	filename (IN)    - texture file name (includes directory path)
	textfname (OUT)  - texture file name (excludes directory path
	curr_dname (OUT) - texture directory
	STD_DIR (OUT)    - TRUE if texture file is in standard directory 

GLOBALS USED
	none

HISTORY
	??/??/??    Yvonne Chu
	   Created
*/
{
   char s1[100], s2[10];
   char *cur_tok, *prev_tok;
   int  counter = 0;

   *STD_DIR = 0;
   strcpy(s1, filename); strcpy(s2, "/");

   cur_tok = strtok(s1, s2);
   prev_tok = NULL; 
   curr_dname[0] = NULL;

   while (cur_tok != NULL) 
   {
	if ((counter == 0) && ((strcmp(cur_tok, "model")==0)
		|| (strcmp(cur_tok, "modeldp")==0))) 
	   counter++; 
	if ((counter==1)&&(strcmp(cur_tok, "config")==0)) counter++; 
	if ((counter==2)&&(strcmp(cur_tok, "textures")==0)) *STD_DIR=1; 

	if (prev_tok != NULL)
	{
	   strcat(curr_dname, "/");
	   strcat(curr_dname, prev_tok);
	}

	prev_tok = cur_tok;
	cur_tok = strtok(NULL, s2);
   }

   if (prev_tok)
   	strcpy(textfname, prev_tok);
   else
	textfname[0] = '\0';
}


state_table

#include "hsmsg.h"
#include "exdef.h"

#define DISPLAY_TEXTURE 4006 
#define DISPLAY_COLOR   4008
#define DRAW_COMPOSITE  4007 
#define RESET_COMPOSITE 4009 
#define EXIT    	4005

at init
	do set_form_defaults 

at wakeup
  	do HS_wakeup

at sleep
	do restore_color_table  /* do this here in case of command stacking  */

at delete
	do free_buffers

state *        /* default transitions for all states */
  on EX_DATA       state .
  on EX_BACK_UP    state .
  on EX_RJT_MOVEON or MOVE_ON state .
  on EX_RESTART    state .

state start
  message_key	        HSM_M_SetActRenAttr	
  display_form          0	
  on ELSE
     do read_spheres 
     do display_sphere_init
     do display_sphere
     state process_main_form 

state process_main_form
  filter	wfi	

  on FORM_FINISHED   
     state terminate

  on MOVE_ON	
     do which_state
	on RETURN_CODE=DISPLAY_COLOR
	   do process_color_form
	   state . 
	on RETURN_CODE=DRAW_COMPOSITE
     	   do display_sphere 
     	   state . 
	on RETURN_CODE=RESET_COMPOSITE
	   do display_sphere_init 
     	   do display_sphere 
     	   state . 
	on RETURN_CODE=DISPLAY_TEXTURE
	   state texture_form
	on ELSE
	   state . 
     state .

state texture_form
  display_form 1 
  filter  wfi 
  on MOVE_ON
     do erase_form 1
     do display_sphere 
     state process_main_form


/*-- which_state ------------------------------------------------------------*/

action  which_state
/*
NAME
	HSsaraform.which_state

DESCRIPTION
	Sets sts to the next state. 

PARAMETERS
	Instance data

GLOBALS USED
	none

HISTORY
	??/??/91    Yvonne Chu
	   Created
*/
    {
    *sts = me->switch1;
    me->switch1 = 0;
    }


/*--- set_form_defaults -----------------------------------------------------*/

action set_form_defaults
/*
NAME
 	HSsaraform.set_form_defaults	

DESCRIPTION
	This routine gets the active values for the finish, specular
	reflectance, diffuse reflectance and transparency sends updates the
	form.

PARAMETERS
	Instance data

GLOBALS USED
	none

HISTORY
	??/??/92    Yvonne Chu
	   Created
*/
    {
    long       msg;
    Form       form_ptr;
    double     percentage;
    IGRuint    flags;
    GRspacenum mod_os;
    GRobjid    mod_id;
         

    /* Initializing main form */

    form_ptr = me -> forms[MAIN_FORM].form_ptr;

    status = om$send( targetid = my_id,
                           msg = message HSsaraform.adjust_form_buttons( &msg ));

    hs$get_shading_flags( rend_attr_flags = &flags );

    me->SR_active  = TRUE;
    me->slider_reset = TRUE;
    me->trans_active_msg = FALSE;
    me->from_active = TRUE;
    me->update_color = FALSE;

#   ifdef X11
    me->allocated_window = FALSE;
#   endif

    hs$get_active_shading_symb( finish = &me->finish,
                             spec_refl = &me->spec_refl,
                             diff_refl = &me->diff_refl,
                          transparency = &me->transparency,
                            tex_orient = &me->orient,
                             tex_index = &me->textindex );

    me->spec_refl *= 100.0;
    me->diff_refl *= 100.0;
    me->transparency *= 100.0;
    me->no_transparency = TRUE;
    me->no_texture = TRUE;
    me->hwin_no = 65535;

    percentage = (double)(HSexp_to_lin(me->finish));
    if (percentage < 100/2.0)
        {
        me->no_fin0 = FALSE; 
        me->no_fin1 = TRUE;
        }
    else
        {
        me->no_fin0 = TRUE; 
        me->no_fin1 = FALSE;
        }

    /* --- Modified to get rid of rendering --- */
    /*
    FIg_set_value( form_ptr, TRANS_SLIDER, me->transparency );
    */
    
    if (me->transparency > 0.0)
         FIg_set_state_off( form_ptr, TRANS_SLIDER );
    else
         FIg_set_state_on( form_ptr, TRANS_SLIDER );

    /* ---------------------------------------- */
    FIg_set_value( form_ptr, DIFFUSE_SLIDER, me->diff_refl );
    FIg_set_value( form_ptr, SPECULAR_SLIDER, me->spec_refl );

    me->linear_rng = flags & HS_REND_ATTR_FINISH_RANGE ? FALSE : TRUE;

    if (me->linear_rng)
        {
        FIg_erase( form_ptr, EXP_MIN);
        FIg_erase( form_ptr, EXP_MAX);
        FIg_display( form_ptr, LINEAR_MIN);
        FIg_display( form_ptr, LINEAR_MAX);

        FIg_set_low_value( form_ptr, FINISH_SLIDER, 0.0 );
        FIg_set_high_value( form_ptr, FINISH_SLIDER, 100.0 );
        FIg_set_value( form_ptr, FINISH_SLIDER, percentage );

        FIg_set_state_off( me->forms[MAIN_FORM].form_ptr, RANGE_TOGGLE );
        }
    else
        {
        FIg_erase( form_ptr, LINEAR_MIN);
        FIg_erase( form_ptr, LINEAR_MAX);
        FIg_display( form_ptr, EXP_MIN);
        FIg_display( form_ptr, EXP_MAX);

        FIg_set_low_value( form_ptr, FINISH_SLIDER, 1.0 );
        FIg_set_high_value( form_ptr, FINISH_SLIDER, 128.0 );
        FIg_set_value( form_ptr, FINISH_SLIDER, (double)me->finish );

        FIg_set_state_on( me->forms[MAIN_FORM].form_ptr, RANGE_TOGGLE );
        }

    FIg_activate( form_ptr, FINISH_SLIDER );
    FIg_display( form_ptr, FINISH_SLIDER );
    
    ex$get_cur_mod(id = &mod_id,osnum = &mod_os);
    status = om$send( targetid = my_id,
                           msg = message HSsaraform.texture_form_defaults((int *)&msg, mod_os));

#   ifdef X11
    FIf_set_window_event_routine(form_ptr, HSwindow_event_routine);
#   endif

    }  /* set_form_defaults */


/*--- adjust_form_buttons ---------------------------------------------------*/

action adjust_form_buttons
/*
NAME
	HSsaraform.adjust_form_buttons

DESCRIPTION
	Updates the form with current gadget values.

PARAMETERS
	Instance data.

GLOBALS USED
	none

HISTORY
	??/??/92    Yvonne
	   Created
*/
{
	Form form_ptr;

	form_ptr = me -> forms[MAIN_FORM].form_ptr;

	FIg_erase( form_ptr, CRA_TITLE );
	FIg_display( form_ptr, SARA_TITLE );

	FIg_erase( form_ptr, COPY_OPTIONS_TEXT);
	FIg_erase( form_ptr, TO_ORIGINAL_BOX );
	FIg_erase( form_ptr, TO_OTHERS_BOX );
	FIg_erase( form_ptr, TO_ACTIVE_BOX );

	FIg_erase( form_ptr, TRANS_TOGGLE );
	FIg_erase( form_ptr, DIFFUSE_TOGGLE );
	FIg_erase( form_ptr, SPECULAR_TOGGLE );
	FIg_erase( form_ptr, FINISH_TOGGLE );

	FIg_erase( form_ptr, COLOR_TOGGLE );
	FIg_erase( form_ptr, TEXTURE_TOGGLE );

	FIg_display( form_ptr, RANGE_TOGGLE );

} /* adjust_form_buttons */


/*--- form_notification -----------------------------------------------------*/

action form_notification
/*
NAME
        HSsaraform.form_notification

DESCRIPTION
        This routine is where the Forms Interface sends back data from
        the user hitting a data point on an object on the form.  The
        gadget number is returned in the form_data structure.
        Note: gadget labels are stored in the include file HSsaraform.h

PARAMETERS
        form_label (IN)   - s.e.
        gadget_label (IN) - s.e.
        value (IN)        - value of gadget selected
        form_pointer (IN) - s.e.

GLOBALS USED
        none

HISTORY
        ??/??/92    Yvonne Chu
           Created
*/
    {
    IGRlong		msg;
    IGRint		VERT;
    Form		texture_form_ptr;
    char		msgbuf[60], filname[300];
    struct HEADER_BLOCK	hdr;
    FILE		*fp;

#   ifdef X11
        XGCValues	values;
        int		mywindow;
#   else
        struct scr_info	screen_info[100];
#   endif

    int			fd;
    char		modelpath[256];
    int			vs_num, window, CMsts;
    double		percentage, exponent;
    IGRuint		flags;
    OMuword		mod_os;

    texture_form_ptr = me->forms[TEXTURE_FORM].form_ptr;

    switch  (form_label)
        {
        case MAIN_FORM:
            switch (gadget_label)
                {
                case CVRT_TO_WINDOW:
                    me->SR_active = FALSE;

		    /*
		     *  Remove the old SR form from WL and add the new window form
		     */
		     
                    CMsts = CMremove_form_from_wl (me->lscreen_no, me->lwin_no, me->context_no);

                    FIf_get_window (form_ptr, &window);

                    me->hwin_no = (WLhwin_no) (window);
                    me->init_rgb_called = TRUE;

                    ex$get_cur_mod (osnum = &mod_os);
                    CMsts = CMadd_form_to_wl (me->hwin_no,
                                              TRUE,     /* Share */
                                              NULL_OBJID,
                                              mod_os,
                                              (int) me->SR_active,
                                              &me->lscreen_no,
                                              &me->context_no,
                                              &me->lwin_no);

                    WLget_context_depth( me->context_no, &me->color_plane );
                    
                    status = om$send (targetid = my_id,
                                           msg = message HSsaraform.display_sphere (&msg));

                    break;

                case TRANS_SLIDER:

                    /*--- Modified to get rid of rendering ---*/
                    /*
                    me->transparency = value;
                    */
                    me->transparency = value > 0.0 ? 0.0 : 50.0;
                    /*----------------------------------------*/

                    if (me->no_transparency)
                        {
                        me->no_transparency = FALSE;

                        get_modtype_data ("Model", NULL, NULL, NULL, NULL,
                                          modelpath);
                        sprintf (filname, "%s/%s", modelpath,
                                 "config/spheres/sphtrn.rgb");

                        hdr.app_type_code = -1;
                        hdr.data_type_code = -1;

                        if ((fd = open (filname, O_RDONLY, 0)) != -1)
                            {
                            HSread_rasterfile_header(
                                                  &fd,
                                                  (short *)&hdr.data_type_code,
                                                  (short *)&hdr.app_type_code,
                                                  (long *)&hdr.num_cols,
                                                  (long *)&hdr.num_rows,
                                                  NULL,
                                                  NULL);

                            close (fd);

                            if (hdr.app_type_code == 9)
                                VERT = 0;
                            else
                                VERT = 1;

                            if (hdr.data_type_code == TYPE_27)
                                {
                                fp = (FILE *) fopen (filname, "r");
                                fseek (fp, 1024, 0);

                                HSsphmem_man (&me->sph_trn, SPH_TRN, MEM_GET);

                                HSread_type27 (fp, hdr.num_rows, hdr.num_cols,
                                     SPH_XMIN, SPH_YMIN, SPH_XMAX, SPH_YMAX,
                                               VERT, me->sph_trn);

                                fclose (fp);
                                }
                            else
                                {
                                ex$message (msgnumb = HS_E_NotType27,
                                            buff = msgbuf);
                                FIfld_set_text (form_ptr, STATUS1, 0, 0, msgbuf, FALSE);
                                }
                            }
                        else
                            {
                            ex$message (msgnumb = HS_E_FindSphTrn,
                                        buff = msgbuf);
                            FIfld_set_text (form_ptr, STATUS1, 0, 0, msgbuf, FALSE);
                            }

                        }

                    me->trans_active_msg = TRUE;
                    me->switch1 = DRAW_COMPOSITE;
                    _move_on

                    break;

                case DIFFUSE_SLIDER:

                    me->diff_refl = value;

                    me->switch1 = DRAW_COMPOSITE;
                    _move_on

                    break;

                case SPECULAR_SLIDER:

                    me->spec_refl = value;

                    me->switch1 = DRAW_COMPOSITE;
                    _move_on

                    break;

                case FINISH_SLIDER:

                    me->slider_reset = TRUE;

                    if (me->linear_rng) /* linear finish range */
                        {
                        percentage = value;
                        exponent = HSlin_to_exp ((int) percentage);
                        me->finish = exponent;
                        }
                    else
                        {       /* exponential finish range */
                        me->finish = (int) value;
                        }

                    if (me->no_fin0 || me->no_fin1)
                        {
                        percentage = HSexp_to_lin (me->finish);

                        if (percentage < 100 / 2.0)
                            {
                            if (me->no_fin0)
                                {
                                me->no_fin0 = FALSE;

                                get_modtype_data ("Model", NULL, NULL, NULL, NULL,
                                                  modelpath);
                                sprintf (filname, "%s/%s", modelpath,
                                         "config/spheres/sphfin000.rgb");

                                hdr.app_type_code = -1;
                                hdr.data_type_code = -1;

                                if ((fd = open (filname, O_RDONLY, 0)) != -1)
                                    {
                                    HSread_rasterfile_header(
                                                  &fd,
                                                  (short *)&hdr.data_type_code,
                                                  (short *)&hdr.app_type_code,
                                                  (long *)&hdr.num_cols,
                                                  (long *)&hdr.num_rows,
                                                   NULL,
                                                   NULL );

                                    close (fd);

                                    if (hdr.app_type_code == 9)
                                        VERT = 0;
                                    else
                                        VERT = 1;

                                    if (hdr.data_type_code == TYPE_27)
                                        {
                                        fp = (FILE *) fopen (filname, "r");
                                        fseek (fp, 1024, 0);

                                        HSsphmem_man (&me->sph_fin000, SPH_FIN000, MEM_GET);

                                        HSread_type27 (fp, hdr.num_rows, hdr.num_cols,
                                                       SPH_XMIN, SPH_YMIN, SPH_XMAX, SPH_YMAX, VERT,
                                                       me->sph_fin000);

                                        fclose (fp);
                                        }
                                    else
                                        {
                                        ex$message (msgnumb = HS_E_NotType27,
                                                    buff = msgbuf);
                                        FIfld_set_text (form_ptr, STATUS1, 0, 0, msgbuf,
                                                        FALSE);
                                        }
                                    }
                                else
                                    {
                                    ex$message (msgnumb = HS_E_FindSphFin00,
                                                buff = msgbuf);
                                    FIfld_set_text (form_ptr, STATUS1, 0, 0, msgbuf, FALSE);
                                    }
                                }
                            }
                        else
                            {
                            if (me->no_fin1)
                                {
                                me->no_fin1 = FALSE;

                                get_modtype_data ("Model", NULL, NULL, NULL, NULL,
                                                  modelpath);
                                sprintf (filname, "%s/%s", modelpath,
                                         "config/spheres/sphfin100.rgb");

                                hdr.app_type_code = -1;
                                hdr.data_type_code = -1;

                                if ((fd = open (filname, O_RDONLY, 0)) != -1)
                                    {
                                    HSread_rasterfile_header (
                                                   &fd,
                                                   (short *)&hdr.data_type_code,
                                                   (short *)&hdr.app_type_code,
                                                   (long *)&hdr.num_cols,
                                                   (long *)&hdr.num_rows,
                                                   NULL,
                                                   NULL);

                                    close (fd);

                                    if (hdr.app_type_code == 9)
                                        VERT = 0;
                                    else
                                        VERT = 1;

                                    if (hdr.data_type_code == TYPE_27)
                                        {
                                        fp = (FILE *) fopen (filname, "r");
                                        fseek (fp, 1024, 0);

                                        HSsphmem_man (&me->sph_fin100, SPH_FIN100,
                                                      MEM_GET);

                                        HSread_type27 (fp, hdr.num_rows, hdr.num_cols,
                                                       SPH_XMIN, SPH_YMIN, SPH_XMAX, SPH_YMAX,
                                                       VERT, me->sph_fin100);

                                        fclose (fp);
                                        }
                                    else
                                        {
                                        ex$message (msgnumb = HS_E_NotType27,
                                                    buff = msgbuf);
                                        FIfld_set_text (form_ptr, STATUS1, 0, 0, msgbuf,
                                                        FALSE);
                                        }
                                    }
                                else
                                    {
                                    ex$message (msgnumb = HS_E_FindSphFin10,
                                                buff = msgbuf);
                                    FIfld_set_text (form_ptr, STATUS1, 0, 0, msgbuf, FALSE);
                                    }

                                }

                            }
                        }

                    me->switch1 = DRAW_COMPOSITE;
                    _move_on

                    break;

                case RANGE_TOGGLE:

                    me->linear_rng = !me->linear_rng;

                    if (me->linear_rng)
                        {
                        FIg_get_value (form_ptr, FINISH_SLIDER, &exponent);
                        me->exp_save = exponent;
                        me->slider_reset = FALSE;
                        percentage = (double) (HSexp_to_lin ((int) exponent));

                        FIg_erase (form_ptr, FINISH_SLIDER);
                        FIg_set_low_value (form_ptr, FINISH_SLIDER, 0.0);
                        FIg_set_high_value (form_ptr, FINISH_SLIDER, 100.0);
                        FIg_activate (form_ptr, FINISH_SLIDER);

                        FIg_set_value (form_ptr, FINISH_SLIDER, percentage);
                        FIg_display (form_ptr, FINISH_SLIDER);

                        FIg_erase (form_ptr, EXP_MIN);
                        FIg_erase (form_ptr, EXP_MAX);
                        FIg_display (form_ptr, LINEAR_MIN);
                        FIg_display (form_ptr, LINEAR_MAX);
                        }
                    else
                        {
                        if (!me->slider_reset)
                            exponent = me->exp_save;
                        else
                            {
                            FIg_get_value (form_ptr, FINISH_SLIDER, &percentage);
                            exponent = (double) (HSlin_to_exp ((int) percentage));
                            }

                        FIg_erase (form_ptr, FINISH_SLIDER);

                        FIg_set_low_value (form_ptr, FINISH_SLIDER, 1.0);
                        FIg_set_high_value (form_ptr, FINISH_SLIDER,
                                            (double) FINISH_MAX);
                        FIg_activate (form_ptr, FINISH_SLIDER);

                        FIg_set_value (form_ptr, FINISH_SLIDER, exponent);
                        FIg_display (form_ptr, FINISH_SLIDER);

                        FIg_erase (form_ptr, LINEAR_MIN);
                        FIg_erase (form_ptr, LINEAR_MAX);
                        FIg_display (form_ptr, EXP_MIN);
                        FIg_display (form_ptr, EXP_MAX);
                        }

                    break;

                case TEXTURE:

                    me->switch1 = DISPLAY_TEXTURE;
                    _move_on

                        break;

                case COLOR:

                    me->switch1 = DISPLAY_COLOR;
                    _move_on

                    break;

                case CANCEL:

                    /*
                    om$send (msg = message HSsaraform.restore_color_table (&msg),
                             targetid = my_id);
                    */
                    
                    _put_response (resp = EX_FORM_FINISHED);

                    break;

                case SAVE:

                    me->transparency /= 100.0;
                    me->spec_refl /= 100.0;
                    me->diff_refl /= 100.0;

                    if (me->texture_active)
                        {
                        if (me->textfname[0] != NULL)
                            {
                            sprintf (filname, "%s/%s", me->curr_dname,
                                     me->textfname);
                            hs$add_texture_file (filename = filname,
                                                 active = 1,
                                                 index = &me->textindex,
                                    mod_osnum = me->ModuleInfo.md_id.osnum);
                            }
                        }
                    else
                        {
                        me->textindex = 0;
                        }

                    hs$get_shading_flags (rend_attr_flags = &flags);
                    flags &= ~HS_REND_ATTR_FINISH_RANGE;
                    flags |= me->linear_rng ? 0 : HS_REND_ATTR_FINISH_RANGE;

                    hs$put_shading_flags (rend_attr_flags = &flags);

                    hs$set_active_shading_symb (finish = &me->finish,
                                                spec_refl = &me->spec_refl,
                                                diff_refl = &me->diff_refl,
                                                transparency =
                                                &me->transparency,
                                                tex_orient = &me->orient,
                                                tex_index = &me->textindex);

                    /*
                    om$send (msg = message HSsaraform.restore_color_table (&msg),
                             targetid = my_id);
                    */
                    
                    me->switch1 = EXIT;
                    _put_response (resp = EX_FORM_FINISHED);

                    break;

                }   /* end: switch */

            break;

        case TEXTURE_FORM:

            status = om$send (targetid = my_id,
                              msg = message
                           HSsaraform.texture_form_notification (form_label,
                                            gadget_label, value, form_ptr));

            break;

        }   /* switch (form_label) */

    }   /* form_notification */

/*--- HS_wakeup -------------------------------------------------------------*/

action HS_wakeup
/*
NAME
	HSsaraform.HSwakeup

DESCRIPTION
	Puts a reset flag for the next state when command wakes up so that
	sphere display is initialize.

PARAMETERS
	Instance data.

GLOBALS USED
	non

HISTORY
	??/??/91    Yvonne Chu
	   Created
*/

    {
    char     dummy;
    int      rsp;
    IGRlong  siz,msg;

#   ifndef X11
    dummy = 'a';
    me->switch1 = RESET_COMPOSITE;
    rsp = MOVE_ON;
    siz = 1;

    ex$putque(msg = &msg,
              response = &rsp,
              byte = &siz,
              buffer = &dummy);
#   endif
    me->hwin_no = 65535;

    }


/*--- display_sphere_init ---------------------------------------------------*/

action display_sphere_init 
/*
NAME
 	HSsaraform.display_sphere_init	

DESCRIPTION
	Initializes display parameters for the sphere.		

PARAMETERS
	Instance data

GLOBALS USED
	none

HISTORY
	??/??/91    Yvonne Chu 
	   Created
*/
{
  Form   form_ptr;

  /* Get the attributes of the portion of the form where the pattern is
     to be displayed */

  form_ptr = me->forms[MAIN_FORM].form_ptr;
  FIg_set_state_off( me->forms[MAIN_FORM].form_ptr, COLOR );

}

/*--- read_spheres ----------------------------------------------------------*/

action read_spheres 
/*
NAME
	HSsaraform.read_spheres

DESCRIPTION
	Reads the sphere raster files which are combined to form the
	sphere display on the form. 

PARAMETERS
	Instance data.

GLOBALS USED
	none

HISTORY
	??/??/92    Yvonne Chu
	   Created
*/

    {
    int			i, VERT;
    FILE		*fp;
    struct HEADER_BLOCK	hdr;
    char		filname[6][256], modelpath[256], spherepath[256];
    char		msgbuf[40];
    char		*form_ptr;
    int			fd;			

    get_modtype_data("Model",NULL,NULL,NULL,NULL,modelpath);
    if (modelpath[0] != NULL)
        {
        sprintf(spherepath,"%sconfig/spheres",modelpath);

        sprintf( filname[0], "%s/%s", spherepath, "sphfin000.rgb");
        sprintf( filname[1], "%s/%s", spherepath, "sphfin100.rgb");
        sprintf( filname[2], "%s/%s", spherepath, "sphfin050.rgb");
        sprintf( filname[3], "%s/%s", spherepath, "sphdif.rgb");
        sprintf( filname[4], "%s/%s", spherepath, "sphtrn.rgb");

        if ((me->textindex != 0) && (me->selected))
            strcpy(filname[5], me->textname);

        form_ptr = me->forms[MAIN_FORM].form_ptr;

        for (i=0; i<6; i++)
            {
            if( (i!=5) || ((me->textindex != 0) && (me->selected)) )
                {
                hdr.app_type_code = -1;
                hdr.data_type_code = -1;

                if ((fd = open(filname[i], O_RDONLY, 0)) == -1)
                    {
                    switch (i)
                        {
                        case 0:
                            if (!me->no_fin0) 
                                {
                                ex$message( msgnumb = HS_E_FindSphFin00, buff = msgbuf ); 
                                FIfld_set_text(form_ptr,STATUS1,0,0,msgbuf,FALSE);
                                }
                                
                            break;

                        case 1:
                            if (!me->no_fin1) 
                                {
                                ex$message( msgnumb = HS_E_FindSphFin10, buff = msgbuf ); 
                                FIfld_set_text(form_ptr,STATUS1,0,0,msgbuf,FALSE);
                                }
                            break;

                        case 2:
                            ex$message( msgnumb = HS_E_FindSphFin05, buff = msgbuf ); 
                            FIfld_set_text(form_ptr,STATUS1,0,0,msgbuf,FALSE);
                            break;

                        case 3:
                            ex$message( msgnumb = HS_E_FindSphDif, buff = msgbuf ); 
                            FIfld_set_text(form_ptr,STATUS1,0,0,msgbuf,FALSE);
                            break;

                        case 4:
                            if (me->transparency > 0.0) 
                                {
                                ex$message( msgnumb = HS_E_FindSphTrn, buff = msgbuf ); 
                                FIfld_set_text(form_ptr,STATUS1,0,0,msgbuf,FALSE);
                                }
                            break;
                        }
                    }
                else
                    {
                    HSread_rasterfile_header( &fd, 
                                              (short *)&hdr.data_type_code, 
                                              (short *)&hdr.app_type_code, 
                                              (long *)&hdr.num_cols, 
                                              (long *)&hdr.num_rows,
                                              NULL,
                                              NULL );

                    close(fd);

                    if(hdr.app_type_code == 9)
                        VERT = 0;
                    else
                        VERT=1;

                    if(!((hdr.data_type_code == TYPE_27) || ((hdr.data_type_code == 25) && (i==5))))
                        {
                        ex$message( msgnumb = HS_E_FindSphTrn, buff = msgbuf ); 
                        FIfld_set_text(form_ptr,STATUS1,0,0,msgbuf,FALSE);
                        }
                    else
                        { 
                        switch (i)        
                            {
                            case 0:
                                if (!me->no_fin0)
                                    {
                                    fp = (FILE*) fopen(filname[i], "r");
                                    fseek(fp, 1024, 0);

                                    HSsphmem_man(&me->sph_fin000, SPH_FIN000, MEM_GET);

                                    HSread_type27( fp,
                                                   hdr.num_rows,
                                                   hdr.num_cols,
                                                   SPH_XMIN,
                                                   SPH_YMIN,
                                                   SPH_XMAX,
                                                   SPH_YMAX,
                                                   VERT, 
                                                   me->sph_fin000);

                                    fclose(fp);
                                    }
                                break;

                            case 1:
                                if (!me->no_fin1) 
                                    {
                                    fp = (FILE*) fopen(filname[i], "r");
                                    fseek(fp, 1024, 0);

                                    HSsphmem_man(&me->sph_fin100, SPH_FIN100, MEM_GET);

                                    HSread_type27( fp,
                                                   hdr.num_rows,
                                                   hdr.num_cols,
                                                   SPH_XMIN,
                                                   SPH_YMIN,
                                                   SPH_XMAX,
                                                   SPH_YMAX,
                                                   VERT, 
                                                   me->sph_fin100);

                                    fclose(fp);
                                    }
                                break;

                            case 2:
                                fp = (FILE*) fopen(filname[i], "r");
                                fseek(fp, 1024, 0);

                                HSsphmem_man(&me->sph_fin050, SPH_FIN050, MEM_GET);

                                HSread_type27( fp,
                                               hdr.num_rows,
                                               hdr.num_cols,
                                               SPH_XMIN,
                                               SPH_YMIN,
                                               SPH_XMAX,
                                               SPH_YMAX,
                                               VERT, 
                                               me->sph_fin050);

                                fclose(fp);

                                break;

                            case 3:
                                fp = (FILE*) fopen(filname[i], "r");
                                fseek(fp, 1024, 0);

                                HSsphmem_man(&me->sph_dif, SPH_DIF, MEM_GET);

                                HSread_type27( fp,
                                               hdr.num_rows,
                                               hdr.num_cols,
                                               SPH_XMIN,
                                               SPH_YMIN,
                                               SPH_XMAX,
                                               SPH_YMAX,
                                               VERT, 
                                               me->sph_dif);

                                fclose(fp);
                                break;

                            case 4:
                                if (me->transparency > 0.0) 
                                    {
                                    fp = (FILE*) fopen(filname[i], "r");
                                    fseek(fp, 1024, 0);

                                    HSsphmem_man(&me->sph_trn, SPH_TRN, MEM_GET); 
 
                                    HSread_type27( fp,
                                                   hdr.num_rows,
                                                   hdr.num_cols,
                                                   SPH_XMIN,
                                                   SPH_YMIN,
                                                   SPH_XMAX,
                                                   SPH_YMAX,
                                                   VERT, 
                                                   me->sph_trn);

                                    me->no_transparency = FALSE;

                                    fclose(fp);

                                    }
                                break;

                            case 5:
                                if ((me->textindex != 0)  && (me->selected))
                                    {
                                    if (me->no_texture)
                                        HSsphmem_man(&me->sph_texture, SPH_TEXT, MEM_GET);
                                
                                    if(hdr.data_type_code == TYPE_27)  
                                        {
                                        fp = (FILE*) fopen(filname[i], "r");
                                        fseek(fp, 1024, 0);

                                        HSreadtexture_type27( fp,
                                                              hdr.num_rows,
                                                              hdr.num_cols, 
                                                              VERT, 
                                                              me->sph_texture);
                                        me->no_texture = FALSE;

                                        fclose(fp);
                                        }
                                    else         
                                        {        
                                        if(hdr.data_type_code == 25)  
                                            {
                                            if ((fd = open(filname[i],O_RDONLY,0))!=-1)
                                                { 
                                                lseek(fd, 1024, 0);        
                                                HSreadtexture_type25( &fd,
                                                                      hdr.num_rows,
                                                                      hdr.num_cols, 
                                                                      VERT, 
                                                                      me->sph_texture);

                                                me->no_texture = FALSE;

                                                close(fd);
                                                }
                                            }
                                        }
                                    }
                                break;
                            }
                        }
                    }
                }
            }
        }
    }

/*--- display_sphere -------------------------------------------------------*/

action display_sphere 

/*
NAME
	HSsaraform.display_sphere

DESCRIPTION
	Creates the raster sphere image using a weighted sum of 5 raster 
	images and displays it on the form. 

PARAMETERS
	Instance data

GLOBALS USED
	none

ALGORITHM
    	The sphere, used to show the effects of changing various phong 
	shading parameters, is a composite of 5 raster images: 
 
      	sphdif.rgb  -  for defining boundary and diffuse reflection 
 	sphtrn.rgb -  for transparency 
 	sphfin0.rgb -
 	sphfinh.rgb -  for specular reflection & finish
 	sphfin0.rgb -
 
    	The steps for creating the sphere is as follows: 
 
    	1) Let the size of the bounding box of the sphere be (i_max, j_max).
 
    	2) Let sphdif.red(i,j) be the red component of sphdif.rgb at 
           position(i,j), 0 <= i < i_max,  0 <= j < j_max.  Let 
	   sphdif.green(i,j) be the green component etc., and for the other 
	   5 raster images and the active color as well.
 
        3) The intensity of the resulting sphere at (i,j) is given by:
 
     	   final.red =  sphdif.red * diffuse * color.red
 	              +	sphtrn.red * transparency * color.red
 		      + sphfinx * specular  
 		      + sphfiny * specular    		
 
       	   where sphfinx, sphfiny are obtained as follows:
 
 	   a) if (finish > 1.0) finish = 1.0;
 
 	   b) if ( (finish * 2) < 1 ) 
  	      {
 	         sphfinx = sphfin0 * (1 - (finish * 2));
 	         sphfiny = sphfinh * (finish * 2);
 	      }
 	      else
 	      {
 	         sphfinx = sphfinh * (1 - (finish * 2));
 	         sphfiny = sphfin1 * ((finish * 2) - 1);
 	      }   
 
 
              Note: If texture is active, the above equation would be 
 
    	      final.red =  sphdif.red * diffuse * texture.red
 		        + sphfinx * specular  
 		        + sphfiny * specular    		
 
  	      Transparency is turned off when texture is displayed. 
 
 
    	4) If any of the final rgb intensities are > 1, it is set to 1.
 	  
HISTORY
	??/??/91    Yvonne
	   Created
*/

    {
    int			i, j, msg;
    int			red, grn, blu;
    unsigned short	*r0, *r1, *rf, *rt;
    double		my_r, my_g, my_b, my_spec, my_diff,  my_finish, my_trans;
    unsigned short	wt_fin0[256], wt_fin1[256], wt_flatr[256], wt_flatg[256],
			wt_flatb[256], wt_tranr[256], wt_trang[256], wt_tranb[256];
    double		wfin0, wfin1, wflatr, wflatg, wflatb, wtranr, wtrang, wtranb;
    struct IGEvlt	colvlt;
    char		*form_ptr;
    char		msgbuf[100];
    long		sizbuf, nret;
    struct IGRdisplay	disbuf;
    double		percentage;
    int			length_i, length_j, area_k;
    unsigned short	sph_comp[3][RGB_YMAX];
    int			bufsiz = 513;
    char		*buffer;
    WLcolorref		WhiteIndex;
    int			xloc, yloc, xsize, ysize, center_x, center_y;
    int                 bit_size;
    struct WLcontext_info context_info;    
    struct WLrect	rect;
    int			wno, WLsts;
    OMuword		mod_os;

    if( ( me->sph_dif    !=NULL)                           && 
        ((me->sph_trn    !=NULL) || (me->no_transparency)) &&
        ((me->sph_fin000 !=NULL) || (me->no_fin0))         && 
        ( me->sph_fin050 !=NULL)                           &&
        ((me->sph_fin100 !=NULL) || (me->no_fin1)) )
        {
        form_ptr = me->forms[MAIN_FORM].form_ptr;

        /*
         *  Get the hardware window number of the form, and add it to WL, if
         *  not already active.  If the active window is not the same, then
         *  dispose of it first
         */
   
        FIf_get_window(form_ptr, &wno);
        if( (WLhwin_no)wno != me->hwin_no )
            {
            if( me->hwin_no != 65535 )
                CMremove_form_from_wl( me->lscreen_no, me->lwin_no, me->context_no );
                
            me->hwin_no = (WLhwin_no)wno;
            ex$get_cur_mod( osnum = &mod_os );
            CMadd_form_to_wl( me->hwin_no,
                              TRUE, /* Share */
                              NULL_OBJID,
                              mod_os,
                              me->SR_active,
                              &me->lscreen_no,
                              &me->context_no,
                              &me->lwin_no );
                              
            WLget_context_depth( me->context_no, &me->color_plane );                    
            }
            
        WLpack_index_colorref( IGErgb_to_index( me->context_no, 2, 1, (int)255, (int)255, (int)255 ), &WhiteIndex, TRUE );
        WLsts = WLset_active_symbology( me->lwin_no, WhiteIndex, 0, 0, 0, WL_SYMB_CHANGE_COLOR ); 

        FIg_get_location( form_ptr, SPH_WIN, &xloc, &yloc );
        FIg_get_size( form_ptr, SPH_WIN, &xsize, &ysize );

        WLhide_cursor( me->lwin_no, 0 ); 

        rect.x = xloc+1;
        rect.y = yloc+1;
        rect.width  = xsize-2;
        rect.height = ysize-2;
        
        WLdraw_rectangle( me->lwin_no, &rect, WL_FILL );

        WLshow_cursor( me->lwin_no );

         WLget_context_info( me->context_no, &context_info );
         if( context_info.base_depth > 8 ) bufsiz *= 2;
         buffer = (char *)malloc( bufsiz );

        if( me->texture_active ) 
            {
            if( me->update_color )
                {
                ex$message( msgnumb = HS_E_TextNoColor, 
                               buff = msgbuf );
                               
                FIfld_set_text( form_ptr, STATUS1, 0, 0, msgbuf, FALSE );
                sleep(3);
                me->update_color = FALSE;
                }

            my_r = 1.0; 
            my_g = 1.0; 
            my_b = 1.0;

            if( (me->transparency > 0.0) && me->trans_active_msg )
                {
                ex$message( msgnumb = HS_E_TextNoTrans, 
                               buff = msgbuf );
                               
                FIfld_set_text( form_ptr, STATUS1, 0, 0, msgbuf, FALSE );
                me->trans_active_msg = FALSE;
                }
            else
                FIfld_set_text( form_ptr, STATUS1, 0, 0, "", FALSE );

            }
        else
            { 
            if( me->from_active || me->update_color )
                { 
                sizbuf = sizeof( struct IGRdisplay );
                gr$get_active_display( msg = &msg,
                                    sizbuf = &sizbuf,
                                    buffer = &disbuf,
                                      nret = &nret );

                me->sph_index = disbuf.color;

                me->update_color = FALSE;
                }

            ige$get_rgb_value( log_color = me->sph_index, 
                               rgb_value = (char *)(&colvlt),
                                   flags = FALSE );

            my_r = (double)colvlt.red/65535.0; 
            my_g = (double)colvlt.green/65535.0; 
            my_b = (double)colvlt.blue/65535.0; 
            }

        my_spec = me->spec_refl / 100.0; 
        my_diff = me->diff_refl / 100.0; 
        percentage = (double)(HSexp_to_lin(me->finish));
        my_finish = percentage/100.0; 
        my_trans = me->transparency /100.0;

        /* compute weights based on material characteristics */

        if( my_finish > 1.0 ) my_finish = 1.0;
        if( (my_finish * 2) < 1 ) 
            {
            wfin0 = (1 - (my_finish * 2)) * my_spec; 
            wfin1 = (my_finish * 2) * my_spec;
            }
        else
            {
            wfin0 = (2 - (my_finish * 2)) * my_spec; 
            wfin1 = ((my_finish * 2) - 1) * my_spec;
            }
  
        wflatr = my_diff * my_r * (1.0 - my_trans * (!me->texture_active));
        wflatg = my_diff * my_g * (1.0 - my_trans * (!me->texture_active));
        wflatb = my_diff * my_b * (1.0 - my_trans * (!me->texture_active));

        wtranr = my_trans * my_r;
        wtrang = my_trans * my_g;
        wtranb = my_trans * my_b;

        /*---------------------------------------------------------------*/
        /* Create multiplication lookup tables to save computation time. */
        /* There are 256 light intensities, so calculate each material	  */
        /* characteristics contribution for all 256 possible intensities */
        /*---------------------------------------------------------------*/

        for( i=0; i < 256; i++ )
            {
            wt_fin0[i]  = (unsigned short)(i * wfin0);
            wt_fin1[i]  = (unsigned short)(i * wfin1);
            wt_flatr[i] = (unsigned short)(i * wflatr);
            wt_flatg[i] = (unsigned short)(i * wflatg);
            wt_flatb[i] = (unsigned short)(i * wflatb);
            wt_tranr[i] = (unsigned short)(i * wtranr);
            wt_trang[i] = (unsigned short)(i * wtrang);
            wt_tranb[i] = (unsigned short)(i * wtranb);
            }

        /* Keep track of pointers to rgb data */

        if( (my_finish * 2) < 1 )
            {
            r0 = me->sph_fin000;
            r1 = me->sph_fin050;
            }
        else
            {
            r0 = me->sph_fin050;
            r1 = me->sph_fin100;
            }

        rf = me->sph_dif;

        if( me->no_transparency )
            rt = me->sph_dif;
        else
            rt = me->sph_trn;

        /* Add in intensity contributions from all sources */

        length_i = SPH_XMAX - SPH_XMIN + 1;
        length_j = SPH_YMAX - SPH_YMIN + 1;
        area_k = length_i * length_j;

        WLhide_cursor( me->lwin_no, 0 );

        for( i=SPH_XMIN; i<=SPH_XMAX; i++ )
            {
            for( j=SPH_YMIN; j<=SPH_YMAX; j++ )
                {
                if( (!rf[MY_RED*area_k + i*length_j + j] ) && 
                    (!rf[MY_GRN*area_k + i*length_j + j] ) && 
                    (!rf[MY_BLU*area_k + i*length_j + j]) ) 
                    {
                    red = 255; 
                    grn = 255; 
                    blu = 255;
                    }
                else
                    {
                    if( !me->texture_active )
                        {
                        red = wt_fin0 [r0[MY_RED*area_k + i*length_j + j]] + 
                              wt_fin1 [r1[MY_RED*area_k + i*length_j + j]] + 
                              wt_tranr[rt[MY_RED*area_k + i*length_j + j]] * (!me->no_transparency) + 
                              wt_flatr[rf[MY_RED*area_k + i*length_j + j]]; 

                        grn = wt_fin0 [r0[MY_GRN*area_k + i*length_j + j]] + 
                              wt_fin1 [r1[MY_GRN*area_k + i*length_j + j]] + 
                              wt_trang[rt[MY_GRN*area_k + i*length_j + j]] * (!me->no_transparency) + 
                              wt_flatg[rf[MY_GRN*area_k + i*length_j + j]]; 

                        blu = wt_fin0 [r0[MY_BLU*area_k + i*length_j + j]] + 
                              wt_fin1 [r1[MY_BLU*area_k + i*length_j + j]] + 
                              wt_tranb[rt[MY_BLU*area_k + i*length_j + j]] * (!me->no_transparency) + 
                              wt_flatb[rf[MY_BLU*area_k + i*length_j + j]]; 
                        }
                    else
                        {
                        red = wt_fin0 [r0[MY_RED*area_k + i*length_j + j]] + 
                              wt_fin1 [r1[MY_RED*area_k + i*length_j + j]] + 
                              wt_flatr[rf[MY_RED*area_k + i*length_j + j]] * 
                              (me->sph_texture[MY_RED*area_k + i*length_j + j])/255; 

                        grn = wt_fin0 [r0[MY_GRN*area_k + i*length_j + j]] + 
                              wt_fin1 [r1[MY_GRN*area_k + i*length_j + j]] + 
                              wt_flatg[rf[MY_GRN*area_k + i*length_j + j]] * 
                              (me->sph_texture[MY_GRN*area_k + i*length_j + j])/255;

                        blu = wt_fin0 [r0[MY_BLU*area_k + i*length_j + j]] + 
                              wt_fin1 [r1[MY_BLU*area_k + i*length_j + j]] + 
                              wt_flatb[rf[MY_BLU*area_k + i*length_j + j]] * 
                              (me->sph_texture[MY_BLU*area_k + i*length_j + j])/255;
                        }
                    }

                if( red > 255 ) red = 255;
                if( grn > 255 ) grn = 255;
                if( blu > 255 ) blu = 255;

                sph_comp[MY_RED][j] = (unsigned short)red;
                sph_comp[MY_GRN][j] = (unsigned short)grn;
                sph_comp[MY_BLU][j] = (unsigned short)blu;
                }

            center_x = xloc + xsize/2;
            center_y = yloc + ysize/2;

            if( context_info.base_depth <= 8 )
            {
               bit_size = 8 ;
            }
            else
            {
               bit_size = 9 ;
            }

            HSwrite_type27( me->lwin_no,
                            me->context_no,
                            bit_size,
                            buffer,
                            i,
                            SPH_XMIN,
                            SPH_YMIN,
                            SPH_XMAX,
                            SPH_YMAX,
                            sph_comp,
                            center_x, 
                            center_y );
            }
        if (buffer)
        {
           HScleanup_putline();
           free(buffer);
           buffer = NULL;
        }

        WLshow_cursor( me->lwin_no );
        WLflush( me->lwin_no );
        }
    }


/*--- print_file_name --------------------------------------------------*/

action print_file_name
/*
NAME
	HSsaraform.print_file_name

DESCRIPTION
	List all the texture files in the texture sub-form.

PARAMETERS
	Instance data

GLOBALS USED
	none

HISTORY
	??/??/91    Yvonne Chu
	   Created
*/
{
    Form form_ptr;
    IGRint j,num_rows;
    char *ptr,msgbuf[40];
    DIR *dirp;
    struct dirent *dp;
  
    form_ptr=me->forms[TEXTURE_FORM].form_ptr;
    FIfld_get_num_rows(form_ptr,HS_F_FNAME,&num_rows);
    FIfld_delete_rows(form_ptr,HS_F_FNAME,0,num_rows);
    j=0;
    if ((dirp=(DIR *)opendir(me->curr_dname))==NULL)
    {
      ex$message(msgnumb=HS_E_InvDir,buff=msgbuf);
      FIfld_set_text(form_ptr,HS_F_MESSAGE,0,0,msgbuf,FALSE);
      sleep(3);
      FIfld_set_text(form_ptr,HS_F_MESSAGE,0,0,"",FALSE);
      strcpy(me->curr_dname,me->temp_dir);
      FIfld_set_text(form_ptr,HS_F_DNAME,0,0,me->curr_dname,FALSE);
      if (dirp=(DIR *)opendir(me->curr_dname))
      {
        while((dp=(struct dirent *)readdir(dirp))!=NULL)
        {
        ptr=strchr(dp->d_name,'.');
        if (ptr)  
        {
		if(strcmp(ptr+1,"rgb")==0)
		{
		  if (strcmp(dp->d_name,me->textfname)==0)
		  {
		    FIfld_set_text(form_ptr,HS_F_FNAME,j,0,dp->d_name,TRUE);
		    FIfld_set_select(form_ptr,HS_F_FNAME,j,0,TRUE);
		    FIfld_set_active_row(form_ptr,HS_F_FNAME,j,0);
		    FIg_call_notification_routine(form_ptr,HS_F_FNAME);
		  }
		  else
		    FIfld_set_text(form_ptr,HS_F_FNAME,j,0,dp->d_name,FALSE);
		  j++;
		}
        }
        }     
        closedir(dirp);
      }     
     }
    else
    {
      while((dp=(struct dirent *)readdir(dirp))!=NULL)
      {
       ptr=strchr(dp->d_name,'.');
       if (ptr)
       {
	       if(strcmp(ptr+1,"rgb")==0)
	       {
		 FIfld_set_text(form_ptr,HS_F_FNAME,j,0,dp->d_name,FALSE);
		 j++;
	       }
       }
     }     
     closedir(dirp);
   }
} /* End print_file */


/*--- process_color_form -----------------------------------------------*/

action process_color_form 
/*
NAME
	HSsaraform.process_color_form

DESCRIPTION
	Invokes the "Create Color Table" command if the Color button is
	pressed.

PARAMETERS
	Instance data

GLOBALS USED
	none

HISTORY
	??/??/91    Yvonne Chu
	   Created
*/
{
  int  response;
  IGRlong msg, size;
  IGRchar command_key[30];
  
  strcpy (command_key, "GRCrClTb");
  size = strlen( command_key ) + 1;
  response = EX_CMD_KEY;
  me->update_color = TRUE;
  
  ex$putque( msg = &msg,
	     response = &response,
	     byte = &size,
	     buffer = command_key );
}


/*--- texture_form_defaults --------------------------------------------*/

action texture_form_defaults (int *sts; GRspacenum osnum)
/*
NAME
	HSsaraform.texture_form_defaults

DESCRIPTION
	Initializes the gadget values in the texture sub-form and updates 
     	the form

PARAMETERS
	Instance data

GLOBALS USED
	none

HISTORY
	??/??/90    Shridar Subramanian
	   Created for "Set Surface Texture"
	??/??/91    Yvonne Chu
	   Modified for "Set Active Shading Parameters" 
*/
{
	long    msg;
	Form   form_ptr, main_form_ptr;
	char   modelpath[256];
        IGRint index, std_dir;
        int    sel_flag, i, num_rows, r_pos;
        char   filename[16], filna[256];
        FILE   *fp;
        char   msgbuf[40];
        DIR    *dirp;

	/* Initializing texture sub-form */

	main_form_ptr = me -> forms[MAIN_FORM].form_ptr;
	form_ptr = me -> forms[TEXTURE_FORM].form_ptr;

	me->textfname[0] = me->curr_dname[0] = modelpath[0] = NULL;

        /* Set the default directory and filename */
 
	if (me->textindex != 0)
	{ 
 	  hs$retrieve_texture_file( index = me->textindex, 
				    filename = me->textname,
                                    mod_osnum = osnum );

	  HSget_dir(me->textname, me->textfname, me->curr_dname, &std_dir);

	  if (std_dir)
     	  {
            	get_modtype_data("Model",NULL,NULL,NULL,NULL,modelpath);
        	if (modelpath[0] != NULL)
            	   sprintf(me->curr_dname,"%sconfig/textures",modelpath);
	  }

	  sprintf(me->textname, "%s/%s", me->curr_dname, me->textfname);

          if((fp = (FILE *)fopen(me->textname,"r")) != NULL)
   	  {
            me->selected = TRUE;
	    me->texture_active = TRUE;
	    FIg_set_state_off(form_ptr, HS_TEXT_TOG);
	  }
          else
	  {
            if ((dirp=(DIR *)opendir(me->curr_dname))==NULL)
	    {
               ex$message(msgnumb=HS_E_InvDir,buff=msgbuf);
               FIfld_set_text(main_form_ptr,STATUS1,0,0,msgbuf,FALSE);
	    }
	    else
	    {
               ex$message(msgnumb=HS_E_FindTextFile, type= "%s", 
				var=`me->textname`,  buff=msgbuf);
               FIfld_set_text(main_form_ptr,STATUS1,0,0,msgbuf,FALSE);
	    }

            me->selected = FALSE;
	    me->texture_active = FALSE;
	    FIg_set_state_on(form_ptr, HS_TEXT_TOG);

            sleep(3);
            FIfld_set_text(form_ptr,HS_F_MESSAGE,0,0,"",FALSE);
	  }

          fclose(fp);
	}
	else 
	{
	  me->texture_active = FALSE;
	  FIg_set_state_on(form_ptr, HS_TEXT_TOG);

          get_modtype_data("Model",NULL,NULL,NULL,NULL,modelpath);
          if (modelpath[0] != NULL)
               sprintf(me->curr_dname,"%sconfig/textures",modelpath);
	}

	FIfld_set_text(form_ptr,HS_F_DNAME,0,0,me->curr_dname,FALSE);
	status = om$send( targetid = my_id,
			  msg = message HSsaraform.print_file_name(&msg));
	FIfld_get_num_rows(form_ptr,HS_F_FNAME,&num_rows);
         
        /* Set the default directory to active */

        if ((me->textindex != 0) && (me->selected))
	{
           for(i=0; i<num_rows; i++)
           {
              FIfld_get_text(form_ptr,HS_F_FNAME,i,0,16,filename,&sel_flag,
		 &r_pos);

	      sprintf(filna, "%s/%s", me->curr_dname, filename);

              if (strcmp(filna,me->textname) == 0)
              {
                 FIfld_set_select(form_ptr,HS_F_FNAME,i,0,TRUE);
                 FIfld_set_active_row(form_ptr,HS_F_FNAME,i,0);
              }
           }
	}

        FIg_get_off_symbol_index(form_ptr,HS_ORIENT,&index);

        if (index == 0)
        {
	   switch ((int)me->orient)
	   {
	      case HS_UP:
                 FIg_set_symbol_index(form_ptr,HS_ORIENT,HS_UP_INDEX);
		 break;

	      case HS_DOWN:
                 FIg_set_symbol_index(form_ptr,HS_ORIENT,HS_DOWN_INDEX);
		 break;

	      case HS_LEFT:
                 FIg_set_symbol_index(form_ptr,HS_ORIENT,HS_LEFT_INDEX);
		 break;

	      case HS_RIGHT:
                 FIg_set_symbol_index(form_ptr,HS_ORIENT,HS_RIGHT_INDEX);
		 break;

	      case HS_RUP:
                 FIg_set_symbol_index(form_ptr,HS_ORIENT,HS_RUP_INDEX);
		 break;

	      case HS_RDOWN:
                 FIg_set_symbol_index(form_ptr,HS_ORIENT,HS_RDOWN_INDEX);
		 break;

	      case HS_RLEFT:
                 FIg_set_symbol_index(form_ptr,HS_ORIENT,HS_RLEFT_INDEX);
		 break;

	      case HS_RRIGHT:
                 FIg_set_symbol_index(form_ptr,HS_ORIENT,HS_RRIGHT_INDEX);
		 break;

	      default: 
 		 FIg_set_symbol_index(form_ptr,HS_ORIENT,HS_UP_INDEX);
		 break;
	   }

           FIg_erase(form_ptr,HS_F_GROUP);
           FIg_activate(form_ptr,HS_ORIENT);
           FIg_display(form_ptr,HS_ORIENT);
           FIg_set_state_off(form_ptr,HS_ORIENT);
        }
}


/*--- texture_form_notification ----------------------------------------*/

action texture_form_notification ( int form_label; int gadget_label; 
				   double value; Form form_ptr ) 
/*
NAME
 	HSsaraform.texture_form_notification	

DESCRIPTION
	Form notification routine for texture sub-form.	

PARAMETERS
	form_label (IN)   - s.e.
	gadget_label (IN) - s.e.
	value (IN)        - value of gadget selected
	form_ptr (IN)     - s.e.

GLOBALS USED
	none

HISTORY
	??/??/90    Shridar Subramanian
	   Created for "Set Surface Texture"
	??/??/91    Yvonne Chu
	   Modified for "Set Active Shading Attributes" 
*/
{
     IGRint               sel_flag, row, position,VERT, state;
     IGRlong              msg;
     Form                 main_form_ptr, texture_form_ptr;
     char                 msgbuf[40], filname[300];
     struct HEADER_BLOCK  hdr;
     FILE                 *fp;
     int                  textspace;
     int                  fd;

     main_form_ptr=me->forms[MAIN_FORM].form_ptr;
     texture_form_ptr=me->forms[TEXTURE_FORM].form_ptr;

     switch (gadget_label)
     {
	   case HS_F_PERMWIN:

	      break;	
	   
    	   case HS_F_UP:

       	      me->orient=HS_UP;
       	      FIg_set_symbol_index(form_ptr,HS_ORIENT,HS_UP_INDEX);
       	      FIg_erase(form_ptr,HS_F_GROUP);
       	      FIg_activate(form_ptr,HS_ORIENT);
       	      FIg_display(form_ptr,HS_ORIENT);
       	      FIg_set_state_off(form_ptr,HS_ORIENT);

       	      break;

     	   case HS_F_DOWN:
	
       	      me->orient=HS_DOWN;
       	      FIg_set_symbol_index(form_ptr,HS_ORIENT,HS_DOWN_INDEX);
       	      FIg_erase(form_ptr,HS_F_GROUP);
       	      FIg_activate(form_ptr,HS_ORIENT);
       	      FIg_display(form_ptr,HS_ORIENT);
       	      FIg_set_state_off(form_ptr,HS_ORIENT);

       	      break;

     	   case HS_F_LEFT:

       	      me->orient=HS_LEFT;
       	      FIg_set_symbol_index(form_ptr,HS_ORIENT,HS_LEFT_INDEX);
       	      FIg_erase(form_ptr,HS_F_GROUP);
       	      FIg_activate(form_ptr,HS_ORIENT);
       	      FIg_display(form_ptr,HS_ORIENT);
       	      FIg_set_state_off(form_ptr,HS_ORIENT);

       	      break;

     	   case HS_F_RIGHT:

       	      me->orient=HS_RIGHT;
       	      FIg_set_symbol_index(form_ptr,HS_ORIENT,HS_RIGHT_INDEX);
       	      FIg_erase(form_ptr,HS_F_GROUP);
       	      FIg_activate(form_ptr,HS_ORIENT);
       	      FIg_display(form_ptr,HS_ORIENT);
       	      FIg_set_state_off(form_ptr,HS_ORIENT);

       	      break;

     	   case HS_F_RUP:

       	      me->orient=HS_RUP;
       	      FIg_set_symbol_index(form_ptr,HS_ORIENT,HS_RUP_INDEX);
       	      FIg_erase(form_ptr,HS_F_GROUP);
       	      FIg_activate(form_ptr,HS_ORIENT);
       	      FIg_display(form_ptr,HS_ORIENT);
       	      FIg_set_state_off(form_ptr,HS_ORIENT);

       	      break;

     	   case HS_F_RDOWN:

       	      me->orient=HS_RDOWN;
       	      FIg_set_symbol_index(form_ptr,HS_ORIENT,HS_RDOWN_INDEX);
       	      FIg_erase(form_ptr,HS_F_GROUP);
       	      FIg_activate(form_ptr,HS_ORIENT);
       	      FIg_display(form_ptr,HS_ORIENT);
       	      FIg_set_state_off(form_ptr,HS_ORIENT);

       	      break;

           case HS_F_RLEFT:

       	      me->orient=HS_RLEFT;
       	      FIg_set_symbol_index(form_ptr,HS_ORIENT,HS_RLEFT_INDEX);
       	      FIg_erase(form_ptr,HS_F_GROUP);
       	      FIg_activate(form_ptr,HS_ORIENT);
       	      FIg_display(form_ptr,HS_ORIENT);
       	      FIg_set_state_off(form_ptr,HS_ORIENT);

       	      break;

	   case HS_F_RRIGHT:

       	      me->orient=HS_RRIGHT;
       	      FIg_set_symbol_index(form_ptr,HS_ORIENT,HS_RRIGHT_INDEX);
       	      FIg_erase(form_ptr,HS_F_GROUP);
       	      FIg_activate(form_ptr,HS_ORIENT);
       	      FIg_display(form_ptr,HS_ORIENT);
              FIg_set_state_off(form_ptr,HS_ORIENT);

       	      break;

     	   case HS_F_DNAME:

       	      strcpy(me->temp_dir,me->curr_dname);
       	      me->selected=FALSE;
       	      FIfld_get_text(form_ptr,HS_F_DNAME,0,0,HS_D_LEN,
   			me->curr_dname, &sel_flag,&position);
       	      status=om$send(targetid=my_id,
				msg= message HSsaraform.print_file_name(&msg));

         	      break;

     		   case HS_F_FNAME:

         	      FIfld_set_text(form_ptr,HS_F_MESSAGE,0,0,"",FALSE); 
         	      FIfld_get_active_row(form_ptr,HS_F_FNAME,&row,&position); 
         	      FIfld_get_text(form_ptr,HS_F_FNAME,row,0,FILE_LEN,
				me->textfname,&sel_flag,&position);

                      sprintf(filname, "%s/%s", me->curr_dname, me->textfname); 
		      hs$inquire_texture_file(	filename = filname, 
						status = &textspace );	
		      if (textspace != NO_ENTRY)
		      {
         	         me->selected = TRUE;
	 	         FIg_set_state_off(form_ptr, HS_TEXT_TOG);
 	 	         me->texture_active = TRUE;	
		      }
		      else
		      {
         	         FIfld_get_active_row(form_ptr,HS_F_FNAME,&row,
								&position); 
            		 FIfld_set_select(form_ptr,HS_F_FNAME,row,0,FALSE);
		      }

         	      break;

		   case HS_TEXT_TOG:

	 	      FIg_get_state(form_ptr, HS_TEXT_TOG, &state);
 	 	      me->texture_active = !state;	

		      if (me->texture_active)
		      {
			 if (!me->selected)
			 {
           		    ex$message(msgnumb=HS_W_SelTex,buff=msgbuf);
           		    FIfld_set_text(form_ptr, HS_F_MESSAGE, 0, 0,
							msgbuf, FALSE);
	 	            FIg_set_state_on(form_ptr, HS_TEXT_TOG);
 	 	            me->texture_active = FALSE;	
			 }	
		      }
		      else
		      {
         	         FIfld_get_active_row(form_ptr,HS_F_FNAME,&row,
								&position); 
            		 FIfld_set_select(form_ptr,HS_F_FNAME,row,0,FALSE);
			 me->selected = FALSE;
	    	      }	

		      break;

     		   case HS_CHECK:

		      if (me->texture_active)
		      {
		          sprintf(filname,"%s/%s",me->curr_dname,me->textfname);
 		          hdr.app_type_code = -1;
 		          hdr.data_type_code = -1;

			  if ((fd = open(filname, O_RDONLY, 0)) != -1);
		          {
			    HSread_rasterfile_header(
                                                  &fd,
                                                  (short *)&hdr.data_type_code, 
			                          (short *)&hdr.app_type_code,
                                                  (long *)&hdr.num_cols, 
				                  (long *)&hdr.num_rows,
                                                  NULL,
                                                  NULL);

			    close(fd);

    	    		    if(hdr.app_type_code==9)
        		       VERT = 0;
    	    		    else
        	               VERT = 1;

	    		    if ((hdr.data_type_code == TYPE_27) ||
			       (hdr.data_type_code == TYPE_25))
			    {
			       if (me->no_texture)
                                  HSsphmem_man(&me->sph_texture, SPH_TEXT, 
					MEM_GET);

			       if (hdr.data_type_code == TYPE_27)	
			       {
			          fp = (FILE*) fopen(filname, "r");
			          fseek(fp, 1024, 0);

			          HSreadtexture_type27(fp,hdr.num_rows,
				     hdr.num_cols, VERT, me->sph_texture);
			          me->no_texture = FALSE;
			          fclose(fp);	
		               }
			       else
			       {
			         if (hdr.data_type_code == 25)	
			         {
			  	    if ((fd = 
					open(filname, O_RDONLY, 0)) != -1)
				    {
				      lseek(fd, 1024, 0);	
			              HSreadtexture_type25(&fd,hdr.num_rows,
				         hdr.num_cols, VERT, me->sph_texture);
			              me->no_texture = FALSE;

				      close(fd);
				    }
		                 }
		               }
			    }
	    		    else	
			    {
			       ex$message( msgnumb = HS_E_NotType27, 
				 	   buff = msgbuf ); 
                               FIfld_set_text(form_ptr,STATUS1,0,0,msgbuf,
					FALSE);
			    }
		          }
                          me->trans_active_msg = TRUE;
		      }

          	      FIg_set_state_off(form_ptr,HS_CHECK);
          	      FIf_erase(form_ptr);
          	      FIg_set_state_off(main_form_ptr,TEXTURE);

          	      _move_on;

          	      break;

     	 	   case HS_ORIENT:

          	      FIg_display(form_ptr,HS_F_GROUP);

          	      break;

     		   case HS_CANCEL:

          	      FIg_set_state_off(form_ptr,HS_CANCEL);
          	      FIf_erase(form_ptr);
          	      FIg_set_state_off(main_form_ptr,TEXTURE);

          	      _move_on;

          	      break;
   
  		 }
    }


/*---restore_color_table----------------------------------------------------*/

action restore_color_table

/*
NAME
	HSsaraform.restore_color_table

DESCRIPTION
	Restores the original color table before this command is called.

PARAMETERS
	Instance data

GLOBALS USED
	none

HISTORY
	??/??/92    Steve Rogers
	   Created
*/

    {
    int		vs_num;

    if( me->init_rgb_called )
        {
        HRfinish_rgb( me->context_no, me->color_plane);
	me->init_rgb_called = FALSE;

        ige$configure_color_table( context_no = me->context_no );
        }

    if (me->hwin_no != 65535)
    {
       CMremove_form_from_wl (me->lscreen_no, me->lwin_no, me->context_no);
       me->hwin_no = 65535;
    }
    }  /* restore_color_table */


action free_buffers 
/*
NAME
	HSsaraform.free_buffers

DESCRIPTION
	Frees the buffers allocated for the sphere raster images.

PARAMETERS
	Instance data

GLOBALS USED
	none

HISTORY
        05/28/93    M. Lanier
           Added call to remove the form from WL
           
	??/??/91    Yvonne Chu
	   Created
*/
    {
    HSsphmem_man(NULL, SPH_DIF, MEM_FREE); 

    if (!me->no_fin0) 
        HSsphmem_man(NULL, SPH_FIN000, MEM_FREE); 

    HSsphmem_man(NULL, SPH_FIN050, MEM_FREE); 

    if (!me->no_fin1) 
        HSsphmem_man(NULL, SPH_FIN100, MEM_FREE); 

    if (!me->no_transparency) 
        HSsphmem_man(NULL, SPH_TRN, MEM_FREE); 

    if (!me->no_texture) 
        HSsphmem_man(NULL, SPH_TEXT, MEM_FREE); 

    /*        
    CMremove_form_from_wl (me->lscreen_no, me->lwin_no, me->context_no);
    me->hwin_no = 65535;
    */
    }

