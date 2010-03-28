/*---- 
%GP%   CODE CLASSIFICATION


----
%HD%

     MODULE NAME -   DPtxunder

          Abstract:    This routine will actually display the character 
		     string on the screen.

----
%SC%

     VALUE = DPtxunder(msg,lbsys,txt_ele,dis_attr,win_no,os_tbl_ptr,type)
----
%EN%

      ON ENTRY:

        NAME              DATA TYPE                   DESCRIPTION
      ----------        --------------         -------------------------
      *lbsys		struct IGRlbsys		local bounded system

      *txt_ele		struct IGRestx		text element 
						specific data

      *dis_attr		struct IGRdisplay	display attributes

      *win_no	IGRlong			hardware window no

      *os_tbl_ptr	struct DPfnt_os_tbl	font object space 
						pointer
	
      *type		IGRshort		type of matrix

----
%EX%

        NAME            DATA TYPE                   DESCRIPTION
      ----------      -----------------      --------------------------
	*msg	      IGRlong		         return status
				  	     MSSUCC - successfully completed
				  	     MSFAIL - unsuccessfully completed

      VALUE() =    TRUE if successful
                   FALSE if something went wrong.

----
%MD%
 
     MODULES INVOKED:  


		   DPget_fnt_adr()
		   MAmulmx()
		   DPesc_handler()

----
%NB%

      NOTES:   None

----
%CH%

       AET   03/10/86   : Creation date
       AET   12/11/87	: Changed to use font server 
----
%PD%
------------------------------------------------------------------------------
               P R O G R A M    D E S C R I P T I O N
------------------------------------------------------------------------------

	This routine will return the points that are the underline of a 
	character or the left or right side of the character
---*/
/*EH*/

#include <FSTypes.h>
#include <FSOutl.h>
#include <math.h>
#include "grimport.h"
#include "igrtypedef.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igr.h"
#include "igrdp.h"
#include "igetypedef.h"
#include "fontdef.h"
#include "dpfont.h"
#include "dpdef.h"
#include "dppriv.h"
#include "msdef.h"

/* prototype files */
#include "dptxunder.h"
#include "dpeschdler.h"
#include "dpgetfntadr.h"

#include "maidmx.h"
#include "maptsxfor.h"
#include "mamulmx.h"


   DPtxunder(msg,lbsys,txt_ele,os_tbl_ptr,which_char,which_point,
	     horizontal,point1, point2)

	IGRlong			*msg;
	struct IGRlbsys		*lbsys;
	struct IGResintx	*txt_ele;
	struct DPfnt_os_tbl	*os_tbl_ptr;
	IGRint			which_char;
	IGRint			which_point;
	IGRint			horizontal;
	IGRdouble		*point1;
	IGRdouble		*point2;

     {	


	IGRint     value = TRUE;/* return value				*/
	IGRchar	   *txt_index; /* pointer to current character		*/
	IGRshort   four = 4;   /* value used in MAmulmx			*/
	IGRlong	   one = 1;
	IGRboolean status;
	IGRdouble  point[3];
	IGRdouble  trans_x_const;
	IGRdouble  trans_y_const;
	IGRdouble  trans_z_const;
	IGRint     i,j;      /* loop variables			*/
        IGRint	   font_id;
	IGRint	   font_flags;
	IGRdouble  bodysize;
	IGRdouble  decent;
	IGRdouble  txt_height;  /*  text height				*/
	IGRdouble  txt_width;	/*  text height				*/
	IGRdouble  fnt_to_local[16]; /* font to local matrix		*/
	IGRdouble  loc_to_world[16]; /* local to world matrix		*/
	IGRdouble  fnt_to_screen[16];/* font to screen matrix		*/
	IGRdouble  aspect_ratio;
struct  DPesc_args	esc_args;

	*msg = MSSUCC;

  /*  get font information   */

        if (!(value = DPget_fnt_adr(msg,0,os_tbl_ptr,txt_ele->font_id,
                    txt_ele->estx->font,0.0,0.0,&font_id,&bodysize,&decent,
		    &font_flags)))
        {
           *msg = MSFAIL;
           goto wrapup;
        }

  /*  compute the text width and the text height                */

        txt_width   = txt_ele->estx->width;

        txt_height  = txt_ele->estx->height;


   /*   set up font to local matrix   */

	MAidmx(msg,fnt_to_local);
        fnt_to_local[0] = txt_width / (bodysize - decent);
        fnt_to_local[5] = txt_height / (bodysize- decent);

	point[0] = 0.0;	
	point[1] = 0.0;
	point[2] = 0.0;
	
   /* set up the local to world matrix  */     

	for (i=0; i<16; i++)
	{
	   loc_to_world[i] = lbsys->matrix[i];
	}

	if ( !(status = MAmulmx(msg,&four,&four,&four,loc_to_world,
		fnt_to_local,fnt_to_screen)))
	{
	   goto wrapup;
	}

	trans_x_const = loc_to_world[3];
	trans_y_const = loc_to_world[7];
	trans_z_const = loc_to_world[11];

/* Since this escape sequence has to be justification moves, only send
   arguments  that are needed						*/

  /* the following three values are only use by the stroker  */

	aspect_ratio = 1.0;
	esc_args.scale_ratio = 1.0;
	esc_args.aspect_ratio = &aspect_ratio;
	esc_args.angle = 0.0;

	esc_args.text_index = (IGRuchar **)&txt_index;
	esc_args.use_bitmap = 0;
	esc_args.trans_x_const = &trans_x_const;
	esc_args.trans_y_const = &trans_y_const;
	esc_args.trans_z_const = &trans_z_const;
	esc_args.txt_height = &txt_height;
	esc_args.txt_width = &txt_width;
	esc_args.loc_to_screen = loc_to_world;
	esc_args.fnt_to_screen = fnt_to_screen;
	esc_args.fnt_to_local = fnt_to_local;
	esc_args.txt_ele = NULL;
	esc_args.os_tbl_ptr = NULL;
	esc_args.line_spacing = NULL;
	esc_args.intrchr_spc = NULL;
	esc_args.x_scale = NULL;
	esc_args.y_scale = NULL;
	esc_args.baseline = NULL;
	esc_args.font_id = NULL;
	esc_args.bodysize = NULL;
	esc_args.decent = NULL;
	esc_args.font_flags = NULL;
	esc_args.disp_flags = 0;
	esc_args.fill_text = NULL;
	esc_args.strk_buf = 0;
	esc_args.win_no = 0;
	esc_args.cur_font = NULL;
	esc_args.prev_font = NULL;

	if ( txt_ele->flags & 0x00000001 )
	{
	   txt_index = txt_ele->just_moves;
	   for ( j = 0 ; j < 2 ; j ++ )
	   {
	      txt_index ++ ;

              DPesc_handler ( msg , &esc_args);
	   }
	}


	/*  multiply all three matrices together  world_to_screen X	*/
	/*  local to world X font to local				*/



	if (!(status = MAptsxform(msg, &one,fnt_to_screen,point,
							point1)))
	{
 	   goto wrapup;
	}


	fnt_to_local[7] += txt_height;



	trans_x_const = (fnt_to_local[7] * loc_to_world[1]) + loc_to_world[3];

	trans_y_const = (fnt_to_local[7] * loc_to_world[5]) + loc_to_world[7];

	trans_z_const = (fnt_to_local[7] * loc_to_world[9]) + loc_to_world[11];

	fnt_to_screen[3] = (fnt_to_local[3] * loc_to_world[0]) + trans_x_const;

	fnt_to_screen[7] = (fnt_to_local[3] * loc_to_world[4]) + trans_y_const;

	fnt_to_screen[11] = (fnt_to_local[3] * loc_to_world[8]) + trans_z_const;


	if (!(status = MAptsxform(msg, &one,fnt_to_screen,point,point2)))
	{
	   goto wrapup;
	}
	
 

wrapup:

        return (value);
       
     } /* end DPtxstrk  */



