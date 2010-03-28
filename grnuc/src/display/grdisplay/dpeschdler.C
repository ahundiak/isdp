
#include "grimport.h"
#include "igrtypedef.h"
#include "OMminimum.h"
#include "igr.h"
#include "igrdp.h"
#include "igetypedef.h"
#include "dpfont.h"
#include "fontdef.h"
#include "msdef.h"
#include "dpdef.h"
#include "OMmacros.h"
#include "dpgetfntadr.h"

#include "wl.h"

  int   DPesc_handler(msg,esc_arg1)

      IGRlong   		*msg;
      struct DPesc_args		*esc_arg1;
   {

     IGRdouble   	h_move,v_move,temp;
     IGRdouble		txt_ratio;
     IGRdouble		widthsize;
     IGRushort	 	font;
     IGRushort		weight;
     IGRlong		value;
     IGRint		in_flags = 0;
     IGRuchar		esc_char,chartemp;
register struct DPesc_args	*esc_arg;

	esc_arg = esc_arg1;

	esc_char = **esc_arg->text_index;

	switch (esc_char) 
	  {

/*  begin field   */

		case 'F':
		   *esc_arg->text_index += 3;
		   break;

/*  Field    */		
		case 't':
		case 'e':
		   *esc_arg->text_index += 2;
		   break;
	
/* end field     */	
		case 'E':
		   (*esc_arg->text_index)++;
		   break;

		case LINE_FEED:
		   (*esc_arg->text_index)++;
		
		   *esc_arg->baseline -= *esc_arg->line_spacing;


		   esc_arg->fnt_to_local[3] = 0;

		   esc_arg->fnt_to_local[7] = *esc_arg->baseline;

		   *esc_arg->trans_x_const = (esc_arg->fnt_to_local[7] *
					      esc_arg->loc_to_screen[1]) +
					      esc_arg->loc_to_screen[3];

		   *esc_arg->trans_y_const = (esc_arg->fnt_to_local[7] *
					      esc_arg->loc_to_screen[5]) +
					      esc_arg->loc_to_screen[7];

		   *esc_arg->trans_z_const = (esc_arg->fnt_to_local[7] *
					      esc_arg->loc_to_screen[9]) +
					      esc_arg->loc_to_screen[11];

		   esc_arg->fnt_to_screen[3] = (esc_arg->fnt_to_local[3] *
						esc_arg->loc_to_screen[0]) +
						*esc_arg->trans_x_const;

		   esc_arg->fnt_to_screen[7] = (esc_arg->fnt_to_local[3] *
						esc_arg->loc_to_screen[4]) +
						*esc_arg->trans_y_const;

		   esc_arg->fnt_to_screen[11] = (esc_arg->fnt_to_local[3] *
						esc_arg->loc_to_screen[8]) +
						*esc_arg->trans_z_const;


		   break;

/*  horizontal move   */	
		case 'H':
		case 'h':
/* horizontal justification move   */
		case 'J':
		   (*esc_arg->text_index)++;
		
		   OM_BLOCK_MOVE(*esc_arg->text_index, &temp,sizeof(IGRdouble));
		   h_move = temp * *esc_arg->txt_width;
		
                   esc_arg->fnt_to_local[3] += h_move;

		   esc_arg->fnt_to_screen[3] = (esc_arg->fnt_to_local[3] * 
						esc_arg->loc_to_screen[0]) + 
				   		*esc_arg->trans_x_const;

		   esc_arg->fnt_to_screen[7] = (esc_arg->fnt_to_local[3] * 
						esc_arg->loc_to_screen[4]) + 
				    		*esc_arg->trans_y_const;

		   esc_arg->fnt_to_screen[11] = (esc_arg->fnt_to_local[3] * 
						esc_arg->loc_to_screen[8]) + 
				    		*esc_arg->trans_z_const;


		   *esc_arg->text_index += 8;
		   break;

/* vertical justification move   */
		case 'j':
/*  vertical move   */
		case 'v':

		   (*esc_arg->text_index)++;
		   OM_BLOCK_MOVE(*esc_arg->text_index,&temp,sizeof(IGRdouble));

		   if (esc_char == 'j')
		   {
		       v_move =  (- temp) *  *esc_arg->txt_height;
		       *esc_arg->baseline + = v_move;
		   }
		   else
		   {
		       v_move =  (temp) *  *esc_arg->txt_height;
		   }

		   esc_arg->fnt_to_local[7] += v_move;



		   *esc_arg->trans_x_const = (esc_arg->fnt_to_local[7] *
					      esc_arg->loc_to_screen[1]) +
					      esc_arg->loc_to_screen[3];

		   *esc_arg->trans_y_const = (esc_arg->fnt_to_local[7] *
					      esc_arg->loc_to_screen[5]) +
					      esc_arg->loc_to_screen[7];

		   *esc_arg->trans_z_const = (esc_arg->fnt_to_local[7] *
					      esc_arg->loc_to_screen[9]) +
					      esc_arg->loc_to_screen[11];

		   esc_arg->fnt_to_screen[3] = (esc_arg->fnt_to_local[3] *
						esc_arg->loc_to_screen[0]) +
						*esc_arg->trans_x_const;

		   esc_arg->fnt_to_screen[7] = (esc_arg->fnt_to_local[3] *
						esc_arg->loc_to_screen[4]) +
						*esc_arg->trans_y_const;

		   esc_arg->fnt_to_screen[11] = (esc_arg->fnt_to_local[3] *
						esc_arg->loc_to_screen[8]) +
						*esc_arg->trans_z_const;


		   *esc_arg->text_index += 8;
		   break;

/*  change font  or pop font    		*/
		
		case 'f':
		case 'p':		
		   (*esc_arg->text_index)++;

		   if (esc_char == 'f')
		   {
		      OM_BLOCK_MOVE(*esc_arg->text_index,&font,sizeof(IGRshort));

		      *esc_arg->prev_font = *esc_arg->cur_font;
		      *esc_arg->cur_font = font;
		      *esc_arg->text_index += sizeof(IGRshort);		
		   }
		   else
		   {
		      *esc_arg->cur_font = *esc_arg->prev_font;
		      font = *esc_arg->prev_font;
		      (*esc_arg->text_index)++;
		   }

		   if (esc_arg->use_bitmap)
		   {
			
			*esc_arg->bodysize = *esc_arg->txt_height * esc_arg->vw_scale;

			widthsize = *esc_arg->txt_width * esc_arg->vw_scale * 
			            esc_arg->scale_ratio;

			if ((*esc_arg->bodysize > MIN_BITMAP_SIZE) && 
			    (*esc_arg->bodysize < MAX_BITMAP_SIZE) &&
			    (widthsize > MIN_BITMAP_SIZE) &&
			    (widthsize < MAX_BITMAP_SIZE))
			{
			    in_flags = BITMAP_FONT;
			}
		   }

		   if (!(value = DPget_fnt_adr(msg,in_flags,esc_arg->os_tbl_ptr,
			esc_arg->txt_ele->font_id,font,esc_arg->angle,
			*esc_arg->aspect_ratio,esc_arg->font_id,esc_arg->bodysize,esc_arg->decent,
			esc_arg->font_flags)))
		   {
	   	      *msg = MSFAIL;
	   	      goto wrapup;
		   }


		   if (esc_arg->disp_flags & DPPOLY_FILL)
		   {
		      if ((*esc_arg->font_flags & FILLABLE_FONT) && (!esc_arg->strk_buf))
		      {
			 *esc_arg->fill_text = TRUE;
		      }
		      else
		      {
			 *esc_arg->fill_text = FALSE;
		      }
		   }

  /*  get scale information					*/

		
		   *esc_arg->x_scale = (*esc_arg->txt_width / (*esc_arg->bodysize - *esc_arg->decent)) / *esc_arg->aspect_ratio;
		   *esc_arg->y_scale = *esc_arg->txt_height / (*esc_arg->bodysize - *esc_arg->decent);


		   *esc_arg->line_spacing = (*esc_arg->bodysize * *esc_arg->y_scale) * esc_arg->txt_ele->estx->line_spac;

		   esc_arg->fnt_to_local[0] = *esc_arg->x_scale;
	  	   esc_arg->fnt_to_local[5] = *esc_arg->y_scale;
				
		   esc_arg->fnt_to_screen[0] = 	esc_arg->fnt_to_local[0] *
						esc_arg->loc_to_screen[0];

		   esc_arg->fnt_to_screen[1] = 	esc_arg->fnt_to_local[5] *
						esc_arg->loc_to_screen[1];

		   esc_arg->fnt_to_screen[4] = 	esc_arg->fnt_to_local[0] *
						esc_arg->loc_to_screen[4];

		   esc_arg->fnt_to_screen[5] = 	esc_arg->fnt_to_local[5] *
						esc_arg->loc_to_screen[5];

		   esc_arg->fnt_to_screen[8] = 	esc_arg->fnt_to_local[0] *
						esc_arg->loc_to_screen[8];

		   esc_arg->fnt_to_screen[9] = 	esc_arg->fnt_to_local[5] *
						esc_arg->loc_to_screen[9];
						

		   break;

/*  scale in the x direction   */

		case 'x':
		   (*esc_arg->text_index)++;
		
		   OM_BLOCK_MOVE(*esc_arg->text_index,&temp,sizeof(IGRdouble));

		   *esc_arg->txt_width *= temp;

		   *esc_arg->intrchr_spc *= temp;


		   if (esc_arg->use_bitmap)
		   {
			*esc_arg->bodysize = *esc_arg->txt_height * esc_arg->vw_scale;

			widthsize = *esc_arg->txt_width * esc_arg->vw_scale * 
			            esc_arg->scale_ratio;

			if ((*esc_arg->bodysize > MIN_BITMAP_SIZE) && 
			    (*esc_arg->bodysize < MAX_BITMAP_SIZE) &&
			    (widthsize > MIN_BITMAP_SIZE) &&
			    (widthsize < MAX_BITMAP_SIZE))
			{
			    txt_ratio = *esc_arg->txt_width / *esc_arg->txt_height;
			    *esc_arg->aspect_ratio = esc_arg->scale_ratio * txt_ratio;
			    in_flags = BITMAP_FONT;
			}
			else
			{
			    *esc_arg->aspect_ratio = 1.0;
			}


                       if (!(value = DPget_fnt_adr(msg,in_flags,esc_arg->os_tbl_ptr,
                            esc_arg->txt_ele->font_id,*esc_arg->cur_font,
			    esc_arg->angle,*esc_arg->aspect_ratio,esc_arg->font_id,
			    esc_arg->bodysize,esc_arg->decent,
                            esc_arg->font_flags)))
                       {
                          *msg = MSFAIL;
                          goto wrapup;
                       }
                    
  /*  get scale information					*/

		
                       *esc_arg->x_scale = (*esc_arg->txt_width / (*esc_arg->bodysize - *esc_arg->decent))/ *esc_arg->aspect_ratio;
                       *esc_arg->y_scale = *esc_arg->txt_height / (*esc_arg->bodysize - *esc_arg->decent);


                       *esc_arg->line_spacing = (*esc_arg->bodysize * *esc_arg->y_scale) * esc_arg->txt_ele->estx->line_spac;

                       esc_arg->fnt_to_local[0] = *esc_arg->x_scale;
                       esc_arg->fnt_to_local[5] = *esc_arg->y_scale;
                                    
                       esc_arg->fnt_to_screen[0] =  esc_arg->fnt_to_local[0] *
                                                    esc_arg->loc_to_screen[0];

                       esc_arg->fnt_to_screen[1] =  esc_arg->fnt_to_local[5] *
                                                    esc_arg->loc_to_screen[1];

                       esc_arg->fnt_to_screen[4] =  esc_arg->fnt_to_local[0] *
                                                    esc_arg->loc_to_screen[4];

                       esc_arg->fnt_to_screen[5] =  esc_arg->fnt_to_local[5] *
                                                    esc_arg->loc_to_screen[5];

                       esc_arg->fnt_to_screen[8] =  esc_arg->fnt_to_local[0] *
                                                    esc_arg->loc_to_screen[8];

                       esc_arg->fnt_to_screen[9] =  esc_arg->fnt_to_local[5] *
                                                    esc_arg->loc_to_screen[9];
                                                    
                  
		   }
		   else
		   {

                       *esc_arg->x_scale = *esc_arg->txt_width / (*esc_arg->bodysize - *esc_arg->decent);
                    
                    
                       esc_arg->fnt_to_local[0] = *esc_arg->x_scale;
                                    
                       esc_arg->fnt_to_screen[0] =  esc_arg->fnt_to_local[0] *
                                                    esc_arg->loc_to_screen[0];

                       esc_arg->fnt_to_screen[4] =  esc_arg->fnt_to_local[0] *
                                                    esc_arg->loc_to_screen[4];

                       esc_arg->fnt_to_screen[8] =  esc_arg->fnt_to_local[0] *
                                                    esc_arg->loc_to_screen[8];

		   }                                    
		   *esc_arg->text_index += 8;
		   break;


/*  scale in the y direction    			*/
		
		case 'y':
		   (*esc_arg->text_index)++;
		
		   OM_BLOCK_MOVE(*esc_arg->text_index,&temp,sizeof(IGRdouble));

		   *esc_arg->txt_height *= temp;

		   if (esc_arg->use_bitmap)
		   {
			*esc_arg->bodysize = *esc_arg->txt_height * esc_arg->vw_scale;
		
			widthsize = *esc_arg->txt_width * esc_arg->vw_scale * 
			            esc_arg->scale_ratio;

			if ((*esc_arg->bodysize > MIN_BITMAP_SIZE) && 
			    (*esc_arg->bodysize < MAX_BITMAP_SIZE)  &&
			    (widthsize > MIN_BITMAP_SIZE) &&
			    (widthsize < MAX_BITMAP_SIZE))
			{
			    txt_ratio = *esc_arg->txt_width / *esc_arg->txt_height;
			    *esc_arg->aspect_ratio = esc_arg->scale_ratio * txt_ratio;
			    in_flags = BITMAP_FONT;
			}
			else
			{
			    *esc_arg->aspect_ratio = 1.0;
			}


                       if (!(value = DPget_fnt_adr(msg,in_flags,esc_arg->os_tbl_ptr,
                            esc_arg->txt_ele->font_id,*esc_arg->cur_font,
			    esc_arg->angle,*esc_arg->aspect_ratio,esc_arg->font_id,
			    esc_arg->bodysize,esc_arg->decent,esc_arg->font_flags)))
                       {
                          *msg = MSFAIL;
                          goto wrapup;
                       }
  /*  get scale information					*/

		
                       *esc_arg->x_scale = (*esc_arg->txt_width / (*esc_arg->bodysize - *esc_arg->decent))/ *esc_arg->aspect_ratio;
                       *esc_arg->y_scale = *esc_arg->txt_height / (*esc_arg->bodysize - *esc_arg->decent);


                       *esc_arg->line_spacing = (*esc_arg->bodysize * *esc_arg->y_scale) * esc_arg->txt_ele->estx->line_spac;

                       esc_arg->fnt_to_local[0] = *esc_arg->x_scale;
                       esc_arg->fnt_to_local[5] = *esc_arg->y_scale;
                                    
                       esc_arg->fnt_to_screen[0] =  esc_arg->fnt_to_local[0] *
                                                    esc_arg->loc_to_screen[0];

                       esc_arg->fnt_to_screen[1] =  esc_arg->fnt_to_local[5] *
                                                    esc_arg->loc_to_screen[1];

                       esc_arg->fnt_to_screen[4] =  esc_arg->fnt_to_local[0] *
                                                    esc_arg->loc_to_screen[4];

                       esc_arg->fnt_to_screen[5] =  esc_arg->fnt_to_local[5] *
                                                    esc_arg->loc_to_screen[5];

                       esc_arg->fnt_to_screen[8] =  esc_arg->fnt_to_local[0] *
                                                    esc_arg->loc_to_screen[8];

                       esc_arg->fnt_to_screen[9] =  esc_arg->fnt_to_local[5] *
                                                    esc_arg->loc_to_screen[9];
                                                    
                                          
		   }
		   else
		   {

                       *esc_arg->y_scale = *esc_arg->txt_height / (*esc_arg->bodysize - *esc_arg->decent);

                       esc_arg->fnt_to_local[5] = *esc_arg->y_scale;
                                    
                       esc_arg->fnt_to_screen[1] =  esc_arg->fnt_to_local[5] *
                                                    esc_arg->loc_to_screen[1];

                       esc_arg->fnt_to_screen[5] =  esc_arg->fnt_to_local[5] *
                                                    esc_arg->loc_to_screen[5];

                       esc_arg->fnt_to_screen[9] =  esc_arg->fnt_to_local[5] *
                                                    esc_arg->loc_to_screen[9];
                                                    

                       *esc_arg->line_spacing = (*esc_arg->bodysize * *esc_arg->y_scale) * esc_arg->txt_ele->estx->line_spac;
		   }                    
		   *esc_arg->text_index += 8;
		   break;

/*  scale in both x and y direction    */

		case 's':
		   (*esc_arg->text_index)++;
		
		   OM_BLOCK_MOVE(*esc_arg->text_index,&temp,sizeof(IGRdouble));

		   *esc_arg->txt_width  *= temp;
		   *esc_arg->txt_height *= temp;

		   *esc_arg->intrchr_spc *= temp;

		   if (esc_arg->use_bitmap)
		   {
			*esc_arg->bodysize = *esc_arg->txt_height * esc_arg->vw_scale;
		
			widthsize = *esc_arg->txt_width * esc_arg->vw_scale * 
			            esc_arg->scale_ratio;

			if ((*esc_arg->bodysize > MIN_BITMAP_SIZE) && 
			    (*esc_arg->bodysize < MAX_BITMAP_SIZE)  &&
			    (widthsize > MIN_BITMAP_SIZE) &&
			    (widthsize < MAX_BITMAP_SIZE))
			{
			    txt_ratio = *esc_arg->txt_width / *esc_arg->txt_height;
			    *esc_arg->aspect_ratio = esc_arg->scale_ratio * txt_ratio;
			    in_flags = BITMAP_FONT;
			}
			else
			{
			    *esc_arg->aspect_ratio = 1.0;
			}


                       if (!(value = DPget_fnt_adr(msg,in_flags,esc_arg->os_tbl_ptr,
                            esc_arg->txt_ele->font_id,*esc_arg->cur_font,
			    esc_arg->angle,*esc_arg->aspect_ratio,esc_arg->font_id,
			    esc_arg->bodysize,esc_arg->decent,esc_arg->font_flags)))
                       {
                          *msg = MSFAIL;
                          goto wrapup;
                       }
                                      
		   }

		   *esc_arg->x_scale = (*esc_arg->txt_width / (*esc_arg->bodysize - *esc_arg->decent))/ *esc_arg->aspect_ratio;
		   *esc_arg->y_scale = *esc_arg->txt_height / (*esc_arg->bodysize - *esc_arg->decent);

		   esc_arg->fnt_to_local[0] = *esc_arg->x_scale;
	  	   esc_arg->fnt_to_local[5] = *esc_arg->y_scale;
				
		   esc_arg->fnt_to_screen[0] = 	esc_arg->fnt_to_local[0] *
						esc_arg->loc_to_screen[0];

		   esc_arg->fnt_to_screen[1] = 	esc_arg->fnt_to_local[5] *
						esc_arg->loc_to_screen[1];

		   esc_arg->fnt_to_screen[4] = 	esc_arg->fnt_to_local[0] *
						esc_arg->loc_to_screen[4];

		   esc_arg->fnt_to_screen[5] = 	esc_arg->fnt_to_local[5] *
						esc_arg->loc_to_screen[5];

		   esc_arg->fnt_to_screen[8] = 	esc_arg->fnt_to_local[0] *
						esc_arg->loc_to_screen[8];

		   esc_arg->fnt_to_screen[9] = 	esc_arg->fnt_to_local[5] *
						esc_arg->loc_to_screen[9];
						

		   *esc_arg->line_spacing = (*esc_arg->bodysize * *esc_arg->y_scale) * esc_arg->txt_ele->estx->line_spac;

		  *esc_arg->text_index += 8;
		  break;

/*  field justification					*/

		case 'M':
		case 'm':
		   if (**esc_arg->text_index == 'M')
		   {
		      *esc_arg->text_index += 3;		
		   }
		   else
		   {
		      *esc_arg->text_index += 2;
		   }

		   OM_BLOCK_MOVE(*esc_arg->text_index,&temp,sizeof(IGRdouble));
		   h_move = temp * *esc_arg->txt_width;

		   *esc_arg->text_index += 8;

		   OM_BLOCK_MOVE(*esc_arg->text_index,&temp,sizeof(IGRdouble));
		   v_move =  (temp) *  *esc_arg->txt_height;

		   esc_arg->fnt_to_local[3] += h_move;

		   esc_arg->fnt_to_local[7] += v_move;

		   *esc_arg->trans_x_const = (esc_arg->fnt_to_local[7] *
					      esc_arg->loc_to_screen[1]) +
					      esc_arg->loc_to_screen[3];

		   *esc_arg->trans_y_const = (esc_arg->fnt_to_local[7] *
					      esc_arg->loc_to_screen[5]) +
					      esc_arg->loc_to_screen[7];

		   *esc_arg->trans_z_const = (esc_arg->fnt_to_local[7] *
					      esc_arg->loc_to_screen[9]) +
					      esc_arg->loc_to_screen[11];

		   esc_arg->fnt_to_screen[3] = (esc_arg->fnt_to_local[3] *
						esc_arg->loc_to_screen[0]) +
						*esc_arg->trans_x_const;

		   esc_arg->fnt_to_screen[7] = (esc_arg->fnt_to_local[3] *
						esc_arg->loc_to_screen[4]) +
						*esc_arg->trans_y_const;

		   esc_arg->fnt_to_screen[11] = (esc_arg->fnt_to_local[3] *
						esc_arg->loc_to_screen[8]) +
						*esc_arg->trans_z_const;


		   *esc_arg->text_index += 8;
		   break;
	
		case 'w':

		   (*esc_arg->text_index)++;
		
		   OM_BLOCK_MOVE(*esc_arg->text_index,&chartemp,sizeof(IGRuchar));

		   weight = chartemp;

		   if (esc_arg->win_no)
		   {
		      WLset_active_symbology( (WLuint32) *(esc_arg->win_no),
		                              0, 0, 0, weight, WL_SYMB_CHANGE_WEIGHT );
		   }
		   (*esc_arg->text_index)++;
		   break;

		case 'C':

		   (*esc_arg->text_index)++;

		   OM_BLOCK_MOVE(*esc_arg->text_index,&temp,sizeof(IGRdouble));

		   *esc_arg->intrchr_spc = (temp - 1) * *esc_arg->txt_width;

		   *esc_arg->text_index += 8;

		   break;
			
		default:
		  break;
	}
	
wrapup:

      return(1);
   }
