/* $Id: VDXf_tools.C,v 1.1.1.1 2001/01/04 21:08:43 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vds/vdextr/func/VDXf_tools.C
 *
 * Description:
 *		Support function for extract for review command.
 *		VDXcenter_message 
 *		VDXget_text 
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDXf_tools.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:43  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1999/04/19  13:58:34  pinnacle
 * for dynapipe
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *      04/16/99        ylong           created
 *
 ***************************************************************************/


#include <stdio.h>
#include <string.h>

#include "OMtypes.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "OMerrordef.h"
#include "msdef.h"

#include "dpdef.h"
#include "VDXforms.h"
#include "VDX4struct.h"

#ifndef FALSE
#define FALSE  0
#define TRUE   (!FALSE)
#endif

int VDXcenter_message (form, g_label, msg_str)
   Form  form;
   int   g_label;
   char  *msg_str;
 {
   int i;
   int msg_length;
   int num_chars;
   int msg_offset;
   int status;
   char center_str[256];

   num_chars = 0; 
   msg_length = strlen (msg_str);

   status = FIfld_get_num_vis_chars (form, g_label, 0, &num_chars); 
   if (status != FI_SUCCESS)
      return (-1);

   if ( msg_length >= (num_chars - 1) )
       FIfld_set_text (form, g_label, 0, 0, msg_str, FALSE);
   else 
    {
       msg_offset = (num_chars - msg_length) / 2;

       if ( (msg_length + msg_offset) >= 256 )
        {
           FIfld_set_text (form, g_label, 0, 0, msg_str, FALSE);
           return (0);
        }

       /** Center the text **/

       for (i = 0; i < msg_offset; i = i + 1)
           center_str[i] = ' '; 
       center_str[msg_offset] = '\0'; 
       strcat (center_str, msg_str); 
       FIfld_set_text (form, g_label, 0, 0, center_str, FALSE);
    }

   return (0);
 }


int VDXget_text (form, gadget_label, row, col, text, text_size)
     Form form; 
     int  gadget_label;	  /* The label of the gadget */
     int  row;
     int  col;
     char *text;  	  /* I/O - The text contained in the field */
     int  *text_size;	  /* I/O - The space allocated for the text */
{
  int status;
  int text_len;
  int sel_flag;
  int r_pos;

  if (*text_size <= 0)
    return (FI_INVALID_ROW);

  status = FIfld_get_text_length (form, gadget_label, row, col, &text_len);
  if (status != FI_SUCCESS)
    return (status);

  if (text_len <= 0)
    return (FI_INVALID_ROW);

  if ( text_len > (*text_size) )
     text_len = *text_size;
  else
     *text_size = text_len;

  /* Increment text_len because of NULL */

  status = FIfld_get_text (form, gadget_label, row, col, text_len + 1,
			   text, &sel_flag, &r_pos);
  return (status);
}



int VDXconvert_lev_array( msg, levels, buffer )
IGRint	*msg; 
IGRint	*levels;
IGRchar	*buffer;
{
short	start, level, next, residual;
char	tmp[VDX_GET_TEXT_MAX];

  *msg = MSSUCC;
  buffer[0] = '\0';

  if( levels == NULL ){
    strcpy( buffer, VDX_GET_DEF_LAYER );
    *msg = MSFAIL;
    return( FALSE );
  } 

  /*** DP_NUM_OF_LEVELS == 1024 ***/

  residual = 0;
  level = 0;
  next = 0;
  start = 0;
  while( level < DP_NUM_OF_LEVELS )
   {
     if(!( 0x00000001 & (levels[level/32] >> (level % 32))))
      {
         level++;
         continue;
      }

   next = level;

   if (strcmp (buffer, "") == 0)
    {
       sprintf (buffer, "%d", next);
    }
   else
    {
       if ( (next - start) == 1)
        {
           if (!residual)
            {
               strcpy( tmp, "-" );
               strcat( buffer, tmp );
            }
           residual = 1;
        }
       else 
        {
           if (residual) 
            {
               sprintf( tmp, "%d,%d", start, next);
               strcat( buffer, tmp );
               residual = 0;
            }
           else
            {
               sprintf( tmp, ",%d", next);
               strcat( buffer, tmp );
            }
        }
     }
    start = next;
    ++level;
  }

  /*** print residual ***/

  if (residual)
   {
      sprintf( tmp, "%d", start);
      strcat( buffer, tmp);
   }

  *msg = MSSUCC;
  return(OM_S_SUCCESS );
}


int VDXconvert_lev_string ( msg, buffer, levels )
IGRint	*msg; 
IGRchar	*buffer;
IGRint	*levels;
{
int	status;
int	exit, is_dash, had_dash;
int	cur, i,j,k, num_char;
char	tmpbuf[256];
int	tmplev1, tmplev2;

  *msg     = MSSUCC;
  status   = TRUE;
  tmplev1  = tmplev2 = 0;

  for( i=0; i<32; i++) levels[i] = 0x0;

  num_char = strlen ( buffer );
  exit     = FALSE;	/*exit on ; or # chars */
  is_dash  = FALSE;	/*assume no dash */
  had_dash = FALSE;	/*assume no dash */
  i        = 0;		/*counter thru tmpbuf*/
        
  for(cur=0 ; cur<=num_char; cur++){

    /*** look for ending delimeter ***/

    if( exit ) goto wrapup; /*if had ; before num chars*/
    if( (buffer[cur] == '-') || (buffer[cur] == ',') ||
	(buffer[cur] == ';') || (cur == num_char)){

      /* start if delimeter found end delimeter */
      if( buffer[cur] == ';' ) exit = TRUE;
      is_dash = FALSE; /* assume not a dash */
      if( buffer[cur] == '-' ){
	/* is dash must remember for next number */
	is_dash = TRUE;
      }
      if( i == 0 ) goto error;
      else{
	/* have something in tmpbuf-convert it */
	tmpbuf[i] = 0;
        for( k=0; k<i; k++ ){
          status = !(isalpha(tmpbuf[k]));
          if (!status ) break;
	}

        if(status){
	  /* convert this string to a number */
	  status = sscanf ( tmpbuf,"%d",&tmplev2);
	}
	if( !status ){
	  /* start not converted see if it is in table */
          if( is_dash || had_dash ){
	    /* if you had dash and would not translate error */
            goto error;
          }
	}
	else{
	  /* start of did translate from scanf */
	  if( is_dash ){
	    tmplev1 = tmplev2; /* save this number */
	    had_dash = TRUE;
	    goto next;
	  }
	  else{
	    /* not a dash but did you have one earlier */
	    if( !had_dash ) tmplev1 = tmplev2;		      		
	    if( tmplev1 > tmplev2  || tmplev1 < 0 || tmplev2 >1023 )
	      goto error;

            had_dash = FALSE;
	    is_dash = FALSE;

	    for( j=tmplev1; j<=tmplev2; j++ ){
	      levels[j/32] |= (1 << (j % 32));
	    }
	  }
	}
next:
	i = 0;
      }
    }
    else{
      /* not a delimeter */
      tmpbuf[i] = buffer[cur];
      i++;
      if( i > 255 ) goto error;
    }
  }
wrapup:
 return ( OM_S_SUCCESS );
   
error:
 /*| error detected in syntax */
 for( i=0; i<32; i++) levels[i] = 0xffffffff;
 *msg = DPINVINP;
 return ( OM_S_SUCCESS );
}



int VDXget_on_off_lev ( msg, levels, on_levels, num_on_levels,
                        off_levels, num_off_levels)
IGRint	*msg; 
IGRint	*levels;
IGRshort on_levels[]; 
IGRshort *num_on_levels; 
IGRshort off_levels[]; 
IGRshort *num_off_levels; 
{
  IGRshort level; 
  short    i, j;
  *msg = MSSUCC;

  if( levels == NULL ){
    *msg = MSFAIL;
    return( FALSE );
  } 

  *num_on_levels = 0;
  *num_off_levels = 0;
  level = 0;
  i = 0;
  j = 0;

  /*** DP_NUM_OF_LEVELS == 1024 ***/

  while( level < DP_NUM_OF_LEVELS )
   {
     if(!( 0x00000001 & (levels[level/32] >> (level % 32))))
      {
         off_levels[i] = level;
         ++i; 
      }
     else
      {
         on_levels[j] = level;
         ++j; 
      }

     ++level;
   }

  *num_off_levels = i;
  *num_on_levels = j;
  *msg = MSSUCC;
  return(OM_S_SUCCESS );
}


