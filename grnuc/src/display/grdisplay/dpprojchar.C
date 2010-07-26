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

#include "grimport.h"
#include "igrtypedef.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "igr.h"
#include "igrdp.h"
#include "igetypedef.h"
#include "fontdef.h"
#include "dpfont.h"
#include "dpdef.h"
#include "dppriv.h"
#include "msdef.h"
#include <FSTypes.h>
#include <FSOutl.h>
#include <math.h>

/* prototype files */
#include "GRfndescchar.h"
#include "dpprojchar.h"
#include "dpeschdler.h"
#include "dpgetfntadr.h"

#include "maidmx.h"
#include "maptsxfor.h"
#include "mamulmx.h"
#include "ma2pt2di.h"

extern void FSGetTextVect( int, char *, int, double, double, double *, double * );


#define	MAX_DIST	99999999999.0
#define MAX_TMP_BUF	2*1024

DPprojchar(msg,lbsys,txt_ele,os_tbl_ptr,point,which_char)


	IGRlong			*msg;
	struct IGRlbsys		*lbsys;
	struct IGResintx	*txt_ele;
	struct DPfnt_os_tbl	*os_tbl_ptr;
	IGRdouble		*point;
	IGRint			*which_char;

     {	


	IGRdouble  cur_x_off = 0; /* current x offset from the stroking */
				  /* origin 				*/
	IGRdouble  cur_y_off = 0; /* current y offset from the stroking */
				  /* origin				*/
	IGRint     value = TRUE;/* return value				*/
	IGRshort   txt_inc; /* character code resolution 1 = byte,	*/
			    /* 2 = word, and 4 = long			*/
	IGRchar	   *txt_index; /* pointer to current character		*/
        IGRchar    *txt_ptr = NULL; /* pointer to character          */
	IGRchar    *malloced_txt_ptr = NULL;
	IGRushort  txt_buf[MAX_TMP_BUF/2];
	IGRchar    *old_txt_index;
	IGRshort   four = 4;   /* value used in MAmulmx			*/
	IGRshort   num_char;
	IGRlong	   one = 1;
	IGRint	   char_num;
	IGRdouble  tmp_point[3];
	IGRdouble  point1[3];
	IGRdouble  x,y;
	IGRint     i,j;      /* loop variables			*/
        IGRint	   font_id;
	IGRint	   font_flags;
	IGRint	   fill_text = FALSE;
	IGRshort   cur_font;
	IGRshort   prev_font;
	IGRdouble  intrchr_spc;	/* space between characters (percentage */
				/* of text width			*/
	IGRdouble  line_spacing;/* vertical spacing used to calculate 	*/
				/* new baseline				*/
	IGRdouble  baseline = 0;/* current baseline			*/
	IGRdouble  bodysize;
	IGRdouble  decent;
	IGRboolean done = FALSE;
	IGRdouble  txt_height;  /*  text height				*/
	IGRdouble  txt_width;	/*  text height				*/
	IGRdouble  fnt_half_height;
 	IGRdouble  fnt_half_width;
	IGRdouble  x_scale;
	IGRdouble  y_scale;
	IGRdouble  fnt_to_local[16]; /* font to local matrix		*/
	IGRdouble  loc_to_world[16]; /* local to world matrix		*/
	IGRdouble  fnt_to_screen[16];/* font to screen matrix		*/
	IGRdouble  shortest_dist = MAX_DIST;
	IGRdouble  distance;
 	IGRdouble  trans_x_const;
	IGRdouble  trans_y_const;
	IGRdouble  trans_z_const;
	IGRdouble  aspect_ratio;

struct  DPesc_args	esc_args;



	*msg = MSSUCC;

 /* save old text stroking routine and set stroking routine to 
    the routine that calculates the underline				*/

	cur_font = txt_ele->estx->font;
	prev_font = txt_ele->prev_font;

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

  /* calculate inter character spacing (% of text width)	*/

        intrchr_spc = (txt_ele->estx->char_spac - 1) * txt_width;

	fnt_half_height = (bodysize - decent) / 2.0;
	
	fnt_half_width = fnt_half_height;

  /*  get scale information                                     */

	x_scale = txt_width / (bodysize - decent);

	y_scale = txt_height / (bodysize- decent);

        line_spacing = (bodysize * y_scale) * txt_ele->estx->line_spac;


   /*   set up font to local matrix   */

	MAidmx(msg,fnt_to_local);
        fnt_to_local[0] = x_scale;
        fnt_to_local[5] = y_scale;
	
   /* set up the local to world matrix  */     

	OM_BLOCK_MOVE(lbsys->matrix,loc_to_world,sizeof(IGRdouble) * 16);




	MAmulmx(msg,&four,&four,&four,loc_to_world,
		fnt_to_local,fnt_to_screen);


	trans_x_const = loc_to_world[3];
	trans_y_const = loc_to_world[7];
	trans_z_const = loc_to_world[11];

  /* the following two values are only use by the stroker  */

	esc_args.scale_ratio = 1.0;

	esc_args.angle = 0.0;

	aspect_ratio = 1.0;
	esc_args.aspect_ratio = &aspect_ratio;
	esc_args.text_index = (IGRuchar **)&txt_index;
	esc_args.use_bitmap = 0;
	esc_args.trans_x_const = &trans_x_const;
	esc_args.trans_y_const = &trans_y_const;
	esc_args.trans_z_const = &trans_z_const;
	esc_args.txt_height = &txt_height;
	esc_args.txt_width = &txt_width;
	esc_args.loc_to_screen  = loc_to_world;
	esc_args.fnt_to_screen  = fnt_to_screen;
	esc_args.txt_ele = txt_ele;
	esc_args.os_tbl_ptr = os_tbl_ptr;
	esc_args.line_spacing = &line_spacing;
	esc_args.intrchr_spc = &intrchr_spc;
	esc_args.x_scale = &x_scale;
	esc_args.y_scale = &y_scale;
	esc_args.fnt_to_local = fnt_to_local;
	esc_args.baseline = &baseline;
	esc_args.font_id = &font_id;
	esc_args.bodysize = &bodysize;
	esc_args.decent = &decent;
	esc_args.font_flags = &font_flags;
	esc_args.disp_flags = 0;
	esc_args.fill_text = &fill_text;
	esc_args.strk_buf = 0;
	esc_args.win_no = 0;
	esc_args.cur_font = &cur_font;
	esc_args.prev_font = &prev_font;

	txt_index = txt_ele->text_string;
	i=0;

  /* set up fixed portion of tmp_point  */

	tmp_point[1] = fnt_half_height;
	tmp_point[2] = 0.0;


	while (i < txt_ele->estx->text_length && !done)
	{

	   old_txt_index = txt_index;
	   
	   char_num = i;
	
   /*   get next character					*/

           cur_y_off = 0;

	   GRfind_esc_char(msg, (IGRuchar *)txt_index,
				(IGRshort)(txt_ele->estx->text_length - i),
			   	font_flags, &num_char);

	   if (num_char == 0)
	   {
	      txt_index++;
	      i++;
              old_txt_index = txt_index;

  /*  call the escape handler						*/

	     if (*txt_index == LINE_FEED)
	     {
	        tmp_point[0] = fnt_half_width;	

	        MAptsxform(msg, &one,fnt_to_screen,tmp_point,
							point1);

	         MA2pt2dis(msg,point1,point,&distance);

	         if (distance < shortest_dist)
	         {
	            shortest_dist = distance;
	 	    *which_char = char_num;
	         }

	      } /* end of if ((*txt_index == 'J' ... 	*/

	      old_txt_index = txt_index;
              DPesc_handler(msg,&esc_args);


	      fnt_half_height = (bodysize - decent) / 2.0;
	      fnt_half_width = fnt_half_height;

              i += ( txt_index - old_txt_index);


	   }
	   else
	   {
	      if (font_flags & SIXTEEN_BIT)
	      {
		 txt_inc = 2;

		 if (txt_ele->estx->text_length > MAX_TMP_BUF)
		 {
		    if (!malloced_txt_ptr)
		    {
		       malloced_txt_ptr = om$malloc(size = txt_ele->estx->text_length);
		       if (!malloced_txt_ptr)
		       {
		          *msg=MSFAIL;
		          goto wrapup;
		       }
		    }
		    txt_ptr = malloced_txt_ptr;
		 }
		 else
		 {
		    txt_ptr = (IGRchar *)txt_buf;
		 }

		 for (j = 0; j < (num_char << 1); j += 2)
		 {
		    txt_ptr[j] = txt_index[j + 1];
		    txt_ptr[j+1] = txt_index[j];
		 }
		 
	      }
	      else
	      {
		 txt_inc = 1;
		 txt_ptr = txt_index;
	      }

	      for (j = 0; j < num_char; j++)
	      {
		 FSGetTextVect(font_id,txt_ptr,1,0.0,0.0,&x,&y);
		 tmp_point[0] = x / 2.0;	

		 MAptsxform(msg, &one,fnt_to_screen,tmp_point,point1);

	         MA2pt2dis(msg,point1,point,&distance);

	         if (distance < shortest_dist)
	         {
	            shortest_dist = distance;
	 	    *which_char = char_num;
	         }



   /*  get next position to begin stroking                      */

		 cur_x_off = (x * x_scale)  + intrchr_spc;



  /* modify the matrix by the next position to place the next character */
                 fnt_to_local[3] += cur_x_off;

		 fnt_to_screen[3] = (fnt_to_local[3] * loc_to_world[0]) + 
				    trans_x_const;

		 fnt_to_screen[7] = (fnt_to_local[3] * loc_to_world[4]) + 
				    trans_y_const;

		 fnt_to_screen[11] = (fnt_to_local[3] * loc_to_world[8]) + 
				    trans_z_const;

	         txt_ptr += txt_inc;
		 char_num += txt_inc;
	      }

	      if (font_flags & SIXTEEN_BIT)
	      {
		 num_char <<= 1;
	      }

	      txt_index += num_char;
	      i += num_char;


/*  if the msg from GRfind_esc_char is ESCAPE_TYPE then an escape-escape
    character has been found and we need to skip the second escape         */

	      if (*msg == ESCAPE_TYPE)
	      {
		 i++;
		 txt_index++;
	      }


	   }  /* end of else part of if (num_char == 0)  */

        }  /* end of while ( i < txt_ele->estx->text_length  */

 

wrapup:

	if (malloced_txt_ptr)
	{
	   om$dealloc(ptr = malloced_txt_ptr);
	}

        return (value);
       
     } /* end DPtxstrk  */



