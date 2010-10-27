/* $Id: SMfrm_co2.I,v 1.1.1.1 2001/01/04 21:07:35 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
Mfrm_co2.I//
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMfrm_co2.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:35  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.4  1998/04/24  21:11:50  pinnacle
# Replaced: smframe/func for:  by yzhu for vds
#
# Revision 1.3  1997/12/02  09:28:24  pinnacle
# Replaced: smframe/func/SMfrm_co2.I for:  by ksundar for vds
#
# Revision 1.2  1997/06/23  06:12:40  pinnacle
# Replaced: smframe/func/SMfrm_co2.I for:  by ksundar for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.3  1996/03/22  14:22:26  pinnacle
# Replaced: vdlocate/cmd/VDS_LOCATE.sl for:  by ksundar for vds.240
#
# Revision 1.2  1996/03/21  09:35:48  pinnacle
# Replaced: smframe/func/SMfrm_co2.I for:  by rgade for vds.240
#
# Revision 1.1  1996/02/24  21:58:32  pinnacle
# Created: smframe/func/SMfrm_co2.I by v240_int for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	06/18/97	Sundar		Modified the functions conv_dist_to_num,
 *					SMSaveSections & SMselect_spacing_field
 *					for the CR179600824 to accept - spacing.
 *	06/19/97 	Sundar		Modified the functions conv_num_to_dist
 *					& conv_dist_to_num for CR:179528227
 *	12/02/97	Sundar		Added init_names for the CR:179309743.
 *
 * -------------------------------------------------------------------*/

/*               SMfrm_co2.I                    */
/*   Methods  and functions for SMCmdPlMdFr    */ 
/*   Methods concerning the section form        */
/*   Jean Jasinczuk                             */
/*   Creation : 26-12-91                        */

class implementation SMCmdPlMdFr;

#include <math.h>
#include "AS_status.h"

#define EPSILON 0.0001

/* Init the structure for sections */
/* Treatment is different for PLACE or  MODIFY */


/* Static functions */

/* Fill the Xa Xb n of the  sect_dist if fr to spacing is known */

static int conv_num_to_dist(form,sect_num,sect_dist,
			    is_def_num,is_def_dist,nb_sect)
Form   form;                  /* [I] Pointer to section form */
struct sect_info *sect_num;   /* [I] The section express in num  */ 
struct sect_dist *sect_dist;  /* [O] The section express in dist */
short  is_def_num[];          /* [I] The array of defined sections */
short  is_def_dist[];         /* [O] The array of defined sections */
int    nb_sect;               /* [I]   The number of section       */
{
  int   i;
  short num_sect0 = -1;
  char  my_msg[MY_MSG_LEN];
  
  if(nb_sect == 0)  /* No section, no conversion to made */
   {
     for(i= 0; i < NB_MAX_SECTION;i++)
       is_def_dist[i] = FALSE;
     goto endinit; 
   }
  
  /* Are all the section well defined */
  for(i = 0; i < nb_sect; i++)
    if(!is_def_num[i] || sect_num[i].fr == NO_NUMBER ||
       sect_num[i].to == NO_NUMBER || sect_num[i].spacing == NO_SPACING)
     {
       /* One section is not defined */
       ex$message(msgnumb = SM_E_FrNotDef, buff = my_msg,
		  type = "%d",var = `i`);
       FIg_set_text(form,FI_MSG_FIELD,my_msg);
       return 0;
     }
  
  /* Search section who contain the frame 0 */
  for(i = 0; i < nb_sect; i++)
    if(sect_num[i].fr <= 0 && sect_num[i].to >= 0)
     {
       sect_dist[i].Xa =  sect_num[i].fr * sect_num[i].spacing;
       sect_dist[i].Xb =  sect_num[i].to * sect_num[i].spacing;
       sect_dist[i].nb =  sect_num[i].to - sect_num[i].fr;
       num_sect0 = i;
       break;
     }
  /* Added by SUNDAR for CR:179528227 */
  /* if frame 0 not found then Setion 0 will be ref_frame section */
  if ( num_sect0 == -1 ){
	sect_dist[0].Xa =  sect_num[0].fr * sect_num[0].spacing;
	sect_dist[0].Xb =  sect_num[0].to * sect_num[0].spacing;
	sect_dist[0].nb =  sect_num[0].to - sect_num[0].fr;
	num_sect0 = 0;
  }
  
  if(num_sect0 < 0)
   {
     ex$message( msgnumb = SM_E_FrZeroDef , buff = my_msg);
     FIg_set_text(form,FI_MSG_FIELD,my_msg);
     return 0;
   }
  
  /* Set the positive frame */
  for(i = num_sect0+1; i < nb_sect; i++)
   {
     if(sect_num[i].fr != sect_num[i-1].to) 
      {
	ex$message( msgnumb = SM_E_FrAdjSect,buff = my_msg,
		   type = "%d %d",var = `i-1,i`);
	FIg_set_text(form,FI_MSG_FIELD,my_msg);
	return 0;
      }
     if(sect_num[i].fr >= sect_num[i].to)
      {
	ex$message( msgnumb = SM_E_FrSingFr,buff = my_msg);
	FIg_set_text(form,FI_MSG_FIELD,my_msg);
	return 0;
      }
     sect_dist[i].nb = sect_num[i].to - sect_num[i].fr;
     sect_dist[i].Xa = sect_dist[i-1].Xb;
     sect_dist[i].Xb =
       sect_dist[i].Xa + sect_num[i].spacing * (double)(sect_dist[i].nb);
   }
  
  /* Set the negative frame */
  for(i = num_sect0-1; i >= 0 ; i--)
   {
     
     if(sect_num[i].to != sect_num[i+1].fr) /* two sections not adjacent */
      {
	ex$message(msgnumb = SM_E_FrAdjSect , buff = my_msg,
		   type = "%d %d",var = `i,i+1`);
	FIg_set_text(form,FI_MSG_FIELD,my_msg);
	return 0;
      }
     
     if(sect_num[i].fr >= sect_num[i].to)
      {
	ex$message( msgnumb = SM_E_FrSingFr,buff = my_msg);
	FIg_set_text(form,FI_MSG_FIELD,my_msg);
	return 0;
      }
     
     sect_dist[i].nb = sect_num[i].to - sect_num[i].fr;
     sect_dist[i].Xb = sect_dist[i+1].Xa;
     sect_dist[i].Xa =
       sect_dist[i].Xb - sect_num[i].spacing * (double)(sect_dist[i].nb);
   }
  for(i= 0; i < NB_MAX_SECTION;i++)
    is_def_dist[i] = is_def_num[i];
  
 endinit:
  for(i = nb_sect ; i < NB_MAX_SECTION;i++)
   {
     sect_dist[i].nb = NO_NUMBER;
     sect_dist[i].Xa = NO_DIST;
     sect_dist[i].Xb = NO_DIST;
   }
  
  return 1; 
}  


/* Fill the  fr to spacing of the sect_num if  Xa Xb nb is known */

static int conv_dist_to_num(form,sect_dist,sect_num,
			    is_def_dist,is_def_num,nb_sect)
Form   form;                  /* [I] Pointer to section form */
struct sect_dist *sect_dist;  /* [I] The section express in dist */
struct sect_info *sect_num;   /* [O] The section express in num  */ 
short  is_def_dist[];         /* [I] The array of defined sections */
short  is_def_num[];          /* [O] The array of defined sections */
int    nb_sect;               /* [I]   The number of section       */
{
 int    i;
 short  num_sect0 = -1;
 double spacing;
 char   my_msg[MY_MSG_LEN]; 

 if(nb_sect == 0) return 1; /* No section, no conversion to made */

 
 /* Find section containing frame 0 */
 for(i = 0; i < nb_sect; i++)
  {
    if(sect_dist[i].Xa == NO_DIST || sect_dist[i].Xb == NO_DIST ||
       !is_def_dist[i])
     {
       ex$message( msgnumb = SM_E_FrNotDef, buff = my_msg,
		  type = "%d",var = `i`);
       FIg_set_text(form,FI_MSG_FIELD,my_msg);
       return 0;
     }
    
    /*if(sect_dist[i].Xa <= 0.0 && sect_dist[i].Xb >= 0.0) SUNDAR for CR:179600824*/
    /* Checking they are opposite sign or not */

    if( ((sect_dist[i].Xa)*(sect_dist[i].Xb)) <= 0.0 )
     {
       /* Section contains frame 0 : found from and to frame for this section */ 
       double  from1;  /* "From" frame in the section containing fr 0 */
       double  to;     /* "To" frame in the section containing fr 0   */
       double epsflto,epsceto,epsflfr,epscefr; /* Temporal value      */

       spacing = (sect_dist[i].Xb - sect_dist[i].Xa)/(double)sect_dist[i].nb;
      
       /* if(spacing <= 0.0) return 0;	SUNDAR for CR:179600824*/
       
       to   = sect_dist[i].Xb / spacing;
       from1 = sect_dist[i].Xa / spacing;
       
       /* Jean . 21 april 93 . Correct test to see if to and from1 are int   */
       /* Before test was made only on floor of value : it may cause problem */
       /* Test if to and from1 are integer : if not frame 0 is not at 0      */

       epsflto = to - floor(to);
       epsceto = ceil(to) - to;
       
       epsflfr = from1 - floor(from1);
       epscefr = ceil(from1) - from1;
      
       if((epsflto > EPSILON && epsceto > EPSILON) ||
	  (epsflfr > EPSILON && epscefr > EPSILON))
	{
	  ex$message( msgnumb = SM_E_FrZeroSect , buff = my_msg);
	  FIg_set_text(form,FI_MSG_FIELD,my_msg);
	  return 0;
	}
       
       /* For from and to, int value is the closest of floor or ceil */ 
       sect_num[i].fr = epsflfr < epscefr ? (int)floor(from1) : (int)ceil(from1);
       sect_num[i].to = epsflto < epsceto ? (int)floor(to)    : (int)ceil(to);
       sect_num[i].spacing = spacing;
       num_sect0 = i;
       break;
     }
  }
 
  /* Added by SUNDAR for CR:179528227 */
  /* if frame 0 not found then Setion 0 will be ref_frame section */ 
  if ( num_sect0 < 0)
  {
	{
	double  from1;
	double  to;
	double epsflto,epsceto,epsflfr,epscefr;
	spacing=(sect_dist[0].Xb-sect_dist[0].Xa)/(double)sect_dist[0].nb;

	if(spacing == 0.0 ) return 0;

	to   = sect_dist[0].Xb / spacing;
	from1 = sect_dist[0].Xa / spacing;
	
	epsflto = to - floor(to);
	epsceto = ceil(to) - to;
	
	epsflfr = from1 - floor(from1);
	epscefr = ceil(from1) - from1;

	if((epsflto > EPSILON && epsceto > EPSILON) ||
		(epsflfr > EPSILON && epscefr > EPSILON))
	  {
		ex$message( msgnumb = SM_E_FrZeroSect , buff = my_msg);
		FIg_set_text(form,FI_MSG_FIELD,my_msg);
		return 0;
	  }

	sect_num[0].fr = epsflfr<epscefr ? (int)floor(from1):(int)ceil(from1);
	sect_num[0].to = epsflto<epsceto ? (int)floor(to):(int)ceil(to);
	
	sect_num[0].spacing = spacing;
	num_sect0 = 0;
	}
   }
  /* End Added by SUNDAR for CR:179528227 */
		

 if(num_sect0 < 0)
  {
    ex$message( msgnumb = SM_E_FrZeroDef , buff = my_msg);
    FIg_set_text(form,FI_MSG_FIELD,my_msg);
    return 0;
  }

 /* Compute all "positives" sections */
 for(i = num_sect0+1; i < nb_sect; i++)
  {
    spacing = (sect_dist[i].Xb - sect_dist[i].Xa)/(double)sect_dist[i].nb;
      
    /* if(spacing <= 0.0) return 0;	SUNDAR for CR:179600824*/

    if(fabs(sect_dist[i].Xa - sect_dist[i-1].Xb) > EPSILON)
     {    
       ex$message( msgnumb = SM_E_FrAdjSect , buff = my_msg,
		  type = "%d %d",var = `i-1,i`);
       FIg_set_text(form,FI_MSG_FIELD,my_msg);
       return 0;
     }
    sect_num[i].fr = sect_num[i-1].to;
    sect_num[i].to = sect_num[i].fr + sect_dist[i].nb;
    sect_num[i].spacing = spacing;
  }
 
 /* Compute all "negatives" sections */
 for(i = num_sect0-1; i >= 0; i--)
  {
    spacing = (sect_dist[i].Xb - sect_dist[i].Xa)/(double)sect_dist[i].nb;
      
    /* if(spacing <= 0.0) return 0;	SUNDAR for CR:179600824*/

    if(fabs(sect_dist[i].Xb - sect_dist[i+1].Xa) > EPSILON)
     {
       ex$message( msgnumb = SM_E_FrAdjSect , buff = my_msg,
		  type = "%d %d",var = `i,i+1`);
       FIg_set_text(form,FI_MSG_FIELD,my_msg);
       return 0;
     }
    sect_num[i].to = sect_num[i+1].fr;
    sect_num[i].fr = sect_num[i].to - sect_dist[i].nb;
    sect_num[i].spacing = spacing;
  }

 for(i= 0; i < NB_MAX_SECTION;i++)
   is_def_num[i] = is_def_dist[i];

  for(i = nb_sect;  i < NB_MAX_SECTION;i++)
   {
      sect_num[i].to   = NO_NUMBER;
      sect_num[i].fr   = NO_NUMBER;
      sect_num[i].spacing = NO_SPACING;
      sect_num[i].offset  = NO_OFFSET;
    }
 return 1;
}

/* Compute the number of defined sections */
/* If sect_dist == NULL,compute with sect_num */
/* If sect_num == NULL compute with sect_dist */

static int compute_nb_sect(sect_num,is_def_num,sect_dist,is_def_dist,nb_sect)
struct sect_info sect_num[] ;    /* [I] Sect info to display */
short  is_def_num[]         ;    /* [I] Array of defined sections */ 
struct sect_dist sect_dist[] ;   /* [I] Sect info to display */
short  is_def_dist[]         ;   /* [I] Array of defined sections */
int *nb_sect;                    /* [O] Number of defined sections */
{
  int i = 0;

  if(sect_num != NULL && is_def_num != NULL)
    while(i < NB_MAX_SECTION &&
	  sect_num[i].fr != NO_NUMBER &&
	  sect_num[i].to != NO_NUMBER &&
	  sect_num[i].spacing != NO_SPACING &&
	  is_def_num[i])
      i++;
  else
    if(sect_dist != NULL && is_def_dist != NULL)
      while(i < NB_MAX_SECTION &&
	    sect_dist[i].Xa != NO_DIST &&
	    sect_dist[i].Xb != NO_DIST &&
	    sect_dist[i].nb != NO_NUMBER &&
	    is_def_dist[i])
	i++;
    else
      return 0;

  *nb_sect = i;
       return 1;
}
	

/* Refresh the FROM TO SPACING in SECTION_FIELD */
static void refresh_num_field(form,sect_num,nb_sect,is_def_num,sect_unit)
Form form;                       /* [I] Pointer to section form */
struct sect_info sect_num[] ;    /* [I] Sect info to display */
int nb_sect;                     /* [I] Number of defined sections */
short is_def_num[];              /* [I] The array of defined sections */
char *sect_unit;                 /* [I] The current unit for sections */
{
  int row;
  char msg_buf[80];
  IGRdouble ext_value;
  
  for(row = 0; row < nb_sect; row++)
   {
     if(is_def_num[row])
      {
	sprintf(msg_buf,"%d",sect_num[row].fr);
	FIfld_set_text(form,SECTION_FIELD,row,FROM,msg_buf,FALSE);
	sprintf(msg_buf,"%d",sect_num[row].to);
	FIfld_set_text(form,SECTION_FIELD,row,TO,msg_buf,FALSE);
	SMfr_convert_int_unit(sect_num[row].spacing,sect_unit,&ext_value);
	sprintf(msg_buf,"%g",ext_value);
	FIfld_set_text(form,SECTION_FIELD,row,SPACING,msg_buf,FALSE);
          
	/* In the following gadgets, the user doesn't want -99999 to
	   appear for default value  */
	FIfld_set_value(form,SECTION_FIELD,row,OFFSET,
			sect_num[row].offset == NO_OFFSET ? 0.0 : (double)sect_num[row].offset, FALSE); 
      }
   }
}

/* Refresh the X1,X2 and NUMBER in SECTION_FIELD */
static void refresh_dist_field(form,sect_dist,nb_sect,is_def_dist,sect_unit)
Form form;                       /* [I] Pointer to section form */
struct sect_dist sect_dist[];    /* [I] Sect_dist to display    */
int nb_sect;                     /* [I] Number of defined sections */
short is_def_dist[];             /* [I] The array of defined sections */
char *sect_unit;                 /* [I] The current unit for sections */
{
  int row;
  double ext_value;
  char msg_buf[80];

  for(row = 0; row < nb_sect; row++)
   {
     if(is_def_dist[row])
      {
	SMfr_convert_int_unit(sect_dist[row].Xa,sect_unit,&ext_value);
	sprintf(msg_buf,"%g",ext_value);
	FIfld_set_text(form,SECTION_FIELD,row,X1,msg_buf,FALSE);
	SMfr_convert_int_unit(sect_dist[row].Xb,sect_unit,&ext_value);
	sprintf(msg_buf,"%g",ext_value);
	FIfld_set_text(form,SECTION_FIELD,row,X2,msg_buf,FALSE);
	sprintf(msg_buf,"%d",sect_dist[row].nb);
	FIfld_set_text(form,SECTION_FIELD,row,NUMBER,msg_buf,FALSE);	    
      }
   }
}

/* Set the mode of the columm of the section FIELD */

static void set_mode_section_field(form,md_fr_to_sp,md_x1_x2_nb,md_off)
Form form;        /* [I] Pointer to section form */
int md_fr_to_sp;  /* [I] Mode of the from to spacing */
int md_x1_x2_nb;  /* [I] Mode of the X1,X2,Nb        */
int md_off;       /* [I] Mode of the offset          */ 
{
  FIfld_set_mode(form,SECTION_FIELD,X1,md_x1_x2_nb);
  FIfld_set_mode(form,SECTION_FIELD,X2,md_x1_x2_nb);
  FIfld_set_mode(form,SECTION_FIELD,NUMBER,md_x1_x2_nb);
  FIfld_set_mode(form,SECTION_FIELD,FROM,md_fr_to_sp);
  FIfld_set_mode(form,SECTION_FIELD,TO,md_fr_to_sp);
  FIfld_set_mode(form,SECTION_FIELD,SPACING,md_fr_to_sp);
  FIfld_set_mode(form,SECTION_FIELD,OFFSET,md_off);
}

static void set_single_select_mode(form,choose_button)
Form form;         /* [I] pointer to section form */
int choose_button; /* [I] The chose button (INSERT_BUTTON or DEL_BUTTON) */
{
 int i;
 long mask;
 int num_rows,row;

 FIg_disable(form,FI_EXECUTE);
 FIg_disable(form,FI_ACCEPT);
 FIg_disable(form,FI_RESET);
 FIg_disable(form,MODE_TOGGLE); 
 switch(choose_button)
  {
  case INSERT_BUTTON :
    FIg_disable(form,DEL_BUTTON);
    break;
  case DEL_BUTTON :
    FIg_disable(form,INSERT_BUTTON);
    break;
  }
 
 /* Now change the mode of field to permit the selection of single row */
 set_mode_section_field(form,FI_SINGLE_SELECT,FI_SINGLE_SELECT,FI_SINGLE_SELECT);
 FIfld_get_num_rows(form,SECTION_FIELD,&num_rows);    
 
 /* Deselect all what can have been previous select */
 for(row = 0; row < num_rows; row++)
  {
    for(i=0 ; i < NB_ROW_SECTION_FIELD ; i++)
      FIfld_set_select(form,SECTION_FIELD,row,i,FALSE);
  }
 FImcf_get_attr(form,SECTION_FIELD,&mask);
 FImcf_set_attr(form,SECTION_FIELD,mask ^ FI_ROW_SELECT);
 FIg_display(form,SECTION_FIELD);
}

method init_names( long *sts ; int type_init )
{
	int   i;
	int   low,high,nb_frame;
 
	FIfld_set_max_num_rows(me->forms[NAMES].form_ptr,DEFAULT_FR_NAME,1);
	FIfld_set_max_num_rows(me->forms[NAMES].form_ptr,FRAME_NO_NAME,
		NB_MAX_SECTION);

	switch(type_init)
	{
		case PLACE :

		FIg_disable(me->forms[MAIN].form_ptr,
                                        FRAME_NAMES_BUTTON);

		for(i = 0 ; i < NB_MAX_SECTION ; i++) {
        		me->is_def_name[i] =  FALSE;
          		me->new_nm_sect_info[i].fr = NO_NUMBER;
        		me->new_nm_sect_info[i].to = NO_NUMBER;
          		me->new_nm_sect_info[i].name[0] = '\0';
        		me->new_nm_sect_info[i].dorn = 2;

                	me->old_nm_sect_info[i].fr = NO_NUMBER;
                	me->old_nm_sect_info[i].to = NO_NUMBER;
                	me->old_nm_sect_info[i].name[0] = '\0';
                	me->old_nm_sect_info[i].dorn = 2;
        	}
 
     		me->new_nb_nm_sect =  0;
     		me->old_nb_nm_sect =  0;
 
     		break;

	case MODIFY :
 
		/* Receive the frame_def   */
		if((me->new_nb_nm_sect = me->first_frame.nb_nm_sect) > NB_MAX_SECTION)
      		{
        		/*|To much section\n*/
        		*sts = MY_ERROR;
        		goto quit;
      		}
 
     		me->old_nb_nm_sect = me->new_nb_nm_sect;
 
     		for(i = 0; i < me->old_nb_nm_sect; i++)
      		{
        		me->old_nm_sect_info[i] = me->new_nm_sect_info[i] = 
				me->first_frame.nm_sect_info[i];
        		me->is_def_name[i] = TRUE;
      		}
 
     		for(i = me->old_nb_nm_sect ; i < NB_MAX_SECTION ; i++)
      		{
        		me->is_def_name[i] = FALSE;
        		me->new_nm_sect_info[i].fr = me->first_frame.nm_sect_info[i].fr = me->old_nm_sect_info[i].fr = NO_NUMBER;
        		me->new_nm_sect_info[i].to = me->first_frame.nm_sect_info[i].to =
          		me->old_nm_sect_info[i].to = NO_NUMBER;
        		me->new_nm_sect_info[i].name[0] = me->first_frame.nm_sect_info[i].name[0] = me->old_nm_sect_info[i].name[0] = '\0';;
        		me->new_nm_sect_info[i].dorn = me->first_frame.nm_sect_info[i].dorn = me->old_nm_sect_info[i].dorn =2;
      		}
 
     		for(i = 0; i < me->new_nb_nm_sect; i++)
       			me->is_def_name[i] = TRUE;
     		for(i = me->new_nb_nm_sect ; i < NB_MAX_SECTION ; i++)
       			me->is_def_name[i] = FALSE;
 

     		break;
   	}
 
  *sts = SUCC;
 
 quit:
  return OM_S_SUCCESS;
}

method init_sections( long *sts ; int type_init )
{
  int   i;
  int   low,high,nb_frame; 
 

#if 0
  long  msg;
  short flag = 0, num_defaults = 1;

  /* Get default unit for distance */
  co$get_default_units(msg = &msg,
		       table_name = GRIO_DISTANCE,
		       osnum = me->ModuleInfo.md_id.osnum,
		       flag = &flag,
		       num_defaults = &num_defaults,
		       default_units = me->sect_unit);
#endif
  
  FIfld_set_max_num_rows(me->forms[SECTION].form_ptr,SECTION_FIELD,NB_MAX_SECTION);
  switch(type_init)
   {
   case PLACE :
     for(i = 0 ; i < NB_MAX_SECTION ; i++)
      {
	me->is_def_num[i] = me->is_def_dist[i] = FALSE;
	me->new_sect_info[i].fr = me->first_sect_info[i].fr =
	  me->old_sect_info[i].fr = NO_NUMBER;
	me->new_sect_info[i].to = me->first_sect_info[i].to =
	  me->old_sect_info[i].to = NO_NUMBER;
	me->new_sect_info[i].spacing = me->first_sect_info[i].spacing =
	  me->old_sect_info[i].spacing = DEFAULT_SPACING_VALUE;
	me->new_sect_info[i].reinf = me->first_sect_info[i].reinf =
	  me->old_sect_info[i].reinf = DEFAULT_REINF_VALUE;
	me->new_sect_info[i].offset = me->first_sect_info[i].offset =
	  me->old_sect_info[i].offset = DEFAULT_OFFSET_VALUE;  
	me->sect_dist[i].Xa = NO_DIST;
	me->sect_dist[i].Xb = NO_DIST;
	me->sect_dist[i].nb = NO_NUMBER;
      }
    
     me->old_nb_sect = me->new_nb_sect = me->first_nb_sect = 0;
     me->old_frame_str.reinf[0] = '\0';
     me->old_frame_str.rev[0] = '\0';
     
     break;
     
   case MODIFY :
     /* Receive the frame_def   */
     if((me->new_nb_sect = me->first_frame.nb_sect) > NB_MAX_SECTION)
      {
	/*|To much section\n*/
	*sts = MY_ERROR;
	goto quit;
      }
     
     me->first_nb_sect = me->old_nb_sect = me->new_nb_sect;
     
     for(i = 0; i < me->old_nb_sect; i++)
      {
	me->old_sect_info[i] = me->new_sect_info[i] = me->first_sect_info[i];
	me->is_def_num[i] = TRUE;
	me->is_def_dist[i] = FALSE;
      }
     
     for(i = me->old_nb_sect ; i < NB_MAX_SECTION ; i++)
      {
	me->is_def_num[i] = me->is_def_dist[i] = FALSE;
	me->new_sect_info[i].fr = me->first_sect_info[i].fr =
	  me->old_sect_info[i].fr = NO_NUMBER;
	me->new_sect_info[i].to = me->first_sect_info[i].to =
	  me->old_sect_info[i].to = NO_NUMBER;
	me->new_sect_info[i].spacing = me->first_sect_info[i].spacing =
	  me->old_sect_info[i].spacing = DEFAULT_SPACING_VALUE;
	me->new_sect_info[i].reinf = me->first_sect_info[i].reinf =
	  me->old_sect_info[i].reinf = DEFAULT_REINF_VALUE;
	me->new_sect_info[i].offset = me->first_sect_info[i].offset =
	  me->old_sect_info[i].offset = DEFAULT_OFFSET_VALUE;
	me->sect_dist[i].Xa = NO_DIST;
	me->sect_dist[i].Xb = NO_DIST;
	me->sect_dist[i].nb = NO_NUMBER;
      }
    
     search_low_high(&low,&high,&nb_frame,
		     me->new_nb_sect,me->first_frame.sect_info);
     refresh_low_high(me->forms[MAIN].form_ptr,low,high,nb_frame,me->new_nb_sect);
     me->first_nb_frame = nb_frame; 
     if(!conv_num_to_dist(me->forms[MAIN].form_ptr,
			  me->new_sect_info,me->sect_dist,
			  me->is_def_num,me->is_def_dist,me->new_nb_sect))
      {
	printf("Error conversion number to distance\n");
	*sts = MY_ERROR;
	goto quit;
      }
     
     for(i = 0; i < me->new_nb_sect; i++)
       me->is_def_num[i] = me->is_def_dist[i] = TRUE;
     for(i = me->new_nb_sect ; i < NB_MAX_SECTION ; i++)
       me->is_def_num[i] = me->is_def_dist[i] = FALSE;

     strcpy(me->old_frame_str.reinf,me->first_frame.main_info.reinfstr);
     strcpy(me->old_frame_str.rev,me->first_frame.main_info.revstr);

     break;
   }
  
  *sts = SUCC;
  
 quit:
  return OM_S_SUCCESS;
}

/* Place section gadgets default state */
static int SMReinitSectGadget(form)
Form form;             /* [I] Pointer to section form */     
{
  static gadget_list[] = {FI_CANCEL,FI_EXECUTE,FI_RESET,FI_ACCEPT,DEL_BUTTON,
			  INSERT_BUTTON,SECTION_FIELD,REINF_FIELD,
			  REVERSE_FIELD,MODE_TOGGLE,-1};
  int i;
  long mask;
  int mode;
 
 /* In fonction of the toggle set the mode of the columm in section field */
  FIg_get_state(form,MODE_TOGGLE,&mode);
  if(mode)
    set_mode_section_field(form,FI_REVIEW,FI_INSERT,FI_INSERT);
  else
    set_mode_section_field(form,FI_INSERT,FI_REVIEW,FI_INSERT);
    
  i = 0;
  while(gadget_list[i] != -1)
   {
     FIg_enable(form,gadget_list[i]);
     if(gadget_list[i] != SECTION_FIELD && gadget_list[i] != MODE_TOGGLE)
       FIg_set_state_off(form,gadget_list[i]);
     i++;
   }

  FImcf_get_attr(form,SECTION_FIELD,&mask);
  if(mask & FI_ROW_SELECT) 
    FImcf_set_attr(form,SECTION_FIELD,mask ^ FI_ROW_SELECT);    
  FIg_display(form,SECTION_FIELD); 
  return 1;
}

/* refresh the form as the corresponding buffer and display it */ 

SMRefreshSectionForm(form,form_main,sect_num,sect_dist,new_nb_sect,
		     frame_str,is_def_num,is_def_dist,xsec,ysec,sect_unit)
Form   form;                    /* [I] Pointer to section form */     
Form   form_main;               /* [I] Pointer to main form */
struct sect_info sect_num[] ;   /* [I] Sect info to display */
struct sect_dist sect_dist[];   /* [I] The sect distance section */
int    new_nb_sect;             /* [I] The number of sections defined */
struct frame_str *frame_str;    /* [I] Strings for reinf and reverse field */
short  is_def_num[];            /* [I] Table for defined sections */
short  is_def_dist[];           /* [I] Table for defined sections */
int    *xsec,*ysec;             /* [I/O] Position of form section  */
char   *sect_unit;              /* [I] The current unit for sections */
{
  /* if the form is call by the main form , place the form
     section relatively to the parent if possible */
  
  if(*xsec == -1 || *ysec == -1)
   {
     int xmain,ymain,hmain,wmain; /* Main form position */
         
     /* Where is the main form parameter */
     FIf_get_location(form_main,&xmain,&ymain);
     FIf_get_size(form_main,&hmain,&wmain);
     
     *xsec = xmain + wmain + 10 ;
     *ysec = ymain;      
     FIf_set_location(form,*xsec,*ysec);  
   }
  
  SMReinitSectGadget(form);

  FIg_set_text(form,REINF_FIELD,frame_str->reinf);
  FIg_set_text(form,REVERSE_FIELD,frame_str->rev);
  FIg_set_text(form,UNIT_FIELD,sect_unit);
  
  /* Refresh the SECTION_FIELD gadget */ 
  FIfld_set_num_rows(form,SECTION_FIELD,new_nb_sect);
  refresh_num_field(form,sect_num,new_nb_sect,is_def_num,sect_unit);
  refresh_dist_field(form,sect_dist,new_nb_sect,is_def_dist,sect_unit); 
  FIg_display(form,SECTION_FIELD);
  
  return 1;
}

/*****************************************************************/
/* The following functions treat an action for a specific button */

/* Reset the structure and the form as the corresponding old buffer */    
SMResetSectForm(
Form form,                      /* [I] Pointer to section form */     
Form form_main,                 /* [I] Pointer to main form */
struct sect_info new_info[] ,   /* [O] Sect info to be reset */
struct sect_info old_info[],    /* [I] Sect info to be copied*/
struct sect_dist sect_dist[],   /* [O] Section defined in distance */
int *new_nb_sect,               /* [O] the number of sections to be reset*/  
int old_nb_sect,                /* [I] the number of sections to be copied*/
struct frame_str *old_frame_str,/* [I] Strings for reinf and reverse field */
short is_def_num[],             /* [O] Table for defined sections */
short is_def_dist[],            /* [O] Table for defined sections */
char  *sect_unit,               /* [I] Unit of section to be reset  */
char  *old_sect_unit            /* [I] Unit of section to be copied */   
)
{
  int row;
  int low,high,nb_frame;

  /* Reset the unit */
  strcpy(sect_unit,old_sect_unit);

  for(row = 0; row < old_nb_sect ; row++)
   {
     new_info[row] =  old_info[row];
     is_def_num[row] = TRUE;
   }

  for(row = old_nb_sect; row < NB_MAX_SECTION; row++)
   {
     is_def_num[row] = FALSE;
     new_info[row].fr = new_info[row].to = NO_NUMBER;
     new_info[row].spacing = NO_SPACING;
   }
  if(!conv_num_to_dist(form,new_info,sect_dist,is_def_num,is_def_dist,old_nb_sect))
    return 0;

  *new_nb_sect = old_nb_sect;

  FIfld_set_num_rows(form,SECTION_FIELD,old_nb_sect);
  refresh_num_field(form,new_info,old_nb_sect,is_def_num,sect_unit);
  refresh_dist_field(form,sect_dist,old_nb_sect,is_def_dist,sect_unit);
  set_mode_section_field(form,FI_INSERT,FI_REVIEW,FI_INSERT);
  FIfld_set_max_num_rows(form,SECTION_FIELD,NB_MAX_SECTION);
  
  FIg_set_text(form,UNIT_FIELD,sect_unit);  
  FIg_set_text(form,REINF_FIELD,old_frame_str->reinf);
  FIg_set_text(form,REVERSE_FIELD,old_frame_str->rev);

  search_low_high(&low,&high,&nb_frame,*new_nb_sect,new_info);
  refresh_low_high(form_main,low,high,nb_frame,*new_nb_sect);
  FIg_display(form,SECTION_FIELD);

  return 1;
}


/* Save sections and the number in the new_info                */
/* Return FALSE if fail else TRUE                              */

SMSaveSections(
Form form,                        /* [I] Pointer to section form              */ 
struct sect_info new_info[],      /* [I] Sect info to verified                */
struct sect_info old_info[],      /* [O] Sect info to update                  */
struct sect_dist sect_dist[],     /* [I/O] If defined by Xa Xb and nb         */
int new_nb_sect,                  /* [I] The new number of section            */
int *old_nb_sect,                 /* [O] the old number of section to update  */ 
struct frame_str *old_frame_str,  /* [O] String for rev and reinf             */
short is_def_num[],               /* [O] Table for defined sections (fr to)   */
short is_def_dist[],              /* [O] Table for defined sections (in dist) */
IGRchar  *save_sect_unit,         /* [O] Current unit save to be saved        */
IGRchar  *sect_unit               /* [I] The current unit for sections        */
)
{
  int              i,mode;
  char             my_msg[MY_MSG_LEN];
  struct frame_str new_frame_str[NB_CUT_STR * ATTR_TXT]; 

  strcpy(save_sect_unit,sect_unit);

  if(new_nb_sect == 0)
   {
     ex$message( msgnumb = SM_I_FrNoSectDef,buff = my_msg);
     FIg_set_text(form,FI_MSG_FIELD,my_msg);
     return FALSE;
   }

  FIg_get_state(form,MODE_TOGGLE,&mode);
  if(mode)  /* The data have been enter by distance */
   {
    if(!conv_dist_to_num(form,sect_dist,new_info,is_def_dist,
			  is_def_num,new_nb_sect))
      {
	FIg_set_state(form,MODE_TOGGLE,TRUE);
	return 0;
      }
    refresh_num_field(form,new_info,new_nb_sect,is_def_num,sect_unit);
  }
  else
   {
     if(!conv_num_to_dist(form,new_info,sect_dist,
			  is_def_num,is_def_dist,new_nb_sect))
      {
	FIg_set_state(form,MODE_TOGGLE,FALSE);
	return 0;
      }
      refresh_dist_field(form,sect_dist,new_nb_sect,is_def_dist,sect_unit);
   }
  
  for(i = 0; i < new_nb_sect; i++)
   {
     if(!is_def_num[i])
      {
	ex$message( msgnumb = SM_E_FrNotDef, buff = my_msg,
		   type = "%d",var = `i`);
	FIg_set_text(form,FI_MSG_FIELD,my_msg);
	return FALSE;
      }  
     if(new_info[i].fr > new_info[i].to)
      {
	ex$message( msgnumb = SM_I_FrFrTo, buff = my_msg,
		   type = "%d",var = `i`); 
	FIg_set_text(form,FI_MSG_FIELD,my_msg);
	return FALSE;
      }
     
     /* Verify section and preceding are adjacent */
     if(i > 0 && new_info[i].fr != new_info[i-1].to)
      {
	ex$message( msgnumb = SM_E_FrAdjSect , buff = my_msg,
		   type = "%d %d",var = `i-1,i`);
	FIg_set_text(form,FI_MSG_FIELD,my_msg);
	return 0;
      }

	/*	SUNDAR for CR:179600824 
     if(new_info[i].spacing <= 0.0)
      { 
	ex$message( msgnumb = SM_I_FrBadSpacing, buff = my_msg,
		   type = "%d",var = `i`);
	FIg_set_text(form,FI_MSG_FIELD,my_msg);
	return FALSE;
      }
	*/
     
     if(new_info[i].offset < 0 && new_info[i].offset != NO_OFFSET)
      {
	ex$message( msgnumb = SM_I_FrBadOffset, buff = my_msg,
		   type = "%d",var = `i`);
	FIg_set_text(form,FI_MSG_FIELD,my_msg);
	return FALSE;
      } 
     if(new_info[i].offset == 0) new_info[i].offset = NO_OFFSET;

    /* For compatibility with old versions */
     new_info[i].reinf = NO_REINF;
   }

  /* Analyse reverse and reinforced string */
  if(!SMselect_reinf_field(form,new_frame_str->reinf))
    return FALSE;

  if(!SMselect_rev_field(form,new_frame_str->rev))
    return FALSE;
  
  /* Copy the new section to the old */ 
  for(i = 0; i < new_nb_sect; i++)
    old_info[i] = new_info[i];      
  *old_nb_sect = new_nb_sect;
  
  strcpy(old_frame_str->reinf,new_frame_str->reinf);
  strcpy(old_frame_str->rev,new_frame_str->rev);
    

#ifdef DEBUG
  printf("Nb section save: %d\n",new_nb_sect);
  for(i = 0; i < new_nb_sect; i++)
    printf("Sect %d : fr = %d to = %d spac = %2.3f, offset = %d\n\n", 
	   i,new_info[i].fr,new_info[i].to, new_info[i].spacing,
	   new_info[i].offset);    
#endif
  
  return TRUE;
}



/* The select button can be select in two different moment :
   At the first time, it simply indicate that the user want select
   a row. At the second tinme the user want delete the selected row */

SMselect_delete_section(form,form_main,sect_num,sect_dist,
			nb_sect,is_def_num,is_def_dist)
Form form;                    /* [I] Pointer to section form */     
Form form_main;               /* [I] Pointer to main form    */   
struct sect_info sect_num[];  /* [I/O] the sections definition (in fr to)*/
struct sect_dist sect_dist[]; /* [I/O] The sections definition (in dist)*/ 
int *nb_sect;                 /* [I/O] the number of section */
short is_def_num[];           /* [O] Table for defined sections (fr to)*/
short is_def_dist[];          /* [O] Table for defined sections (in dist)*/
{
  int mode,i;
  int row;
  int num_rows,sel_flag = FALSE;
  int low,high,nb_frame;
  char my_msg[MY_MSG_LEN];
  
  if( *nb_sect == 0)
   {
     ex$message( msgnumb = SM_I_FrNoSectDel, buff = my_msg);
     FIg_set_text(form,FI_MSG_FIELD,my_msg);
     FIg_set_state_off(form,DEL_BUTTON);
     return 0;
   }
  
  FIfld_get_mode(form,SECTION_FIELD,OFFSET,&mode);
  if(mode == FI_INSERT)
   {
     /* It is the first time delete button is selected */
     set_single_select_mode(form,DEL_BUTTON);
     ex$message( msgnumb = SM_I_FrSelDelRow, buff = my_msg);
     FIg_set_text(form,FI_MSG_FIELD,my_msg);
   } /* if FI_INSERT */
  
  if(mode == FI_SINGLE_SELECT)
    /* Second time delete button is selected */
   {
     /* Find select row if exist */	 
     FIfld_get_num_rows(form,SECTION_FIELD,&num_rows);
     for(row = 0; row < num_rows; row++)
      {
      	FIfld_get_select(form,SECTION_FIELD,row,0,&sel_flag);
        if(sel_flag) break;
        /* At most one select row because of FI_SINGLE_SELECT */ 
      }
     
     /* One row to delete */
     if(sel_flag)
      {
        FIfld_delete_rows(form,SECTION_FIELD,row,1);
	
	
        if(row < *nb_sect)
	 { 
	   ex$message( msgnumb = SM_I_FrIsDel, buff = my_msg,
		      type = "%d",var = `row`);     
	   FIg_set_text(form,FI_MSG_FIELD,my_msg);
	   if(*nb_sect > 0)
	    { 
	      (*nb_sect)--;
	      
	      for(i = row; i < *nb_sect  ; i++)
	       {
		 is_def_num[i] = is_def_num[i+1];
		 sect_num[i] = sect_num[i+1];
		 is_def_dist[i] = is_def_dist[i+1];
		 sect_dist[i]  = sect_dist[i+1];
	       }
	      
	      is_def_num[*nb_sect] = FALSE;
	      sect_num[*nb_sect].fr = sect_num[*nb_sect].to = NO_NUMBER;
	      sect_num[*nb_sect].spacing = DEFAULT_SPACING_VALUE;
	      sect_num[*nb_sect].offset = DEFAULT_OFFSET_VALUE;
	      is_def_dist[*nb_sect] = FALSE;
	      sect_dist[*nb_sect].Xa = sect_dist[*nb_sect].Xb = NO_DIST;
	      sect_dist[*nb_sect].nb = NO_NUMBER;
            }
	 }
	search_low_high(&low,&high,&nb_frame,*nb_sect,sect_num);
	refresh_low_high(form_main,low,high,nb_frame,*nb_sect);
      }
     SMReinitSectGadget(form);
     
   } /* If mode == FI_SINGLE_SELECT */
  return 1;
}       

/* The insert select button can be select in two different moment :
   At the first time, it simply indicate that the user want select
   a row. At the second time the user want delete the selected row */

SMselect_insert_section(form,sect_num,sect_dist,
			nb_sect,is_def_num,is_def_dist)
Form form;                    /* [I] Pointer to section form */     
struct sect_info sect_num[];  /* [I/O] the sections definition (in fr to)*/
struct sect_dist sect_dist[]; /* [I/O] The sections definition (in dist)*/ 
int *nb_sect;                 /* [I/O] the number of section */
short is_def_num[];           /* [O] Table for defined sections (fr to)*/
short is_def_dist[];          /* [O] Table for defined sections (in dist)*/
{
  int mode,i;
  int row;
  int num_rows,sel_flag = FALSE;
  char my_msg[MY_MSG_LEN];
  
  if( *nb_sect == 0)
   {
     ex$message( msgnumb = SM_I_FrNoSectIns, buff = my_msg);
     FIg_set_text(form,FI_MSG_FIELD,my_msg);
     FIg_set_state_off(form,INSERT_BUTTON);
     return 0;
   }
  
  FIfld_get_mode(form,SECTION_FIELD,OFFSET,&mode);
  if(mode == FI_INSERT)
   {
     /* It is the first time delete button is selected */
     set_single_select_mode(form,INSERT_BUTTON);
     ex$message( msgnumb = SM_I_FrSelInsRow, buff = my_msg);
     FIg_set_text(form,FI_MSG_FIELD,my_msg);
   } /* if FI_INSERT */
  
  if(mode == FI_SINGLE_SELECT)
    /* Second time delete button is selected */
   {
     /* Find select row if exist */	 
     FIfld_get_num_rows(form,SECTION_FIELD,&num_rows);
     for(row = 0; row < num_rows; row++)
      {
      	FIfld_get_select(form,SECTION_FIELD,row,0,&sel_flag);
        if(sel_flag) break;
        /* At most one select row because of FI_SINGLE_SELECT */ 
      }
     
     /* One row to insert */
     if(sel_flag)
      {
	if((row < *nb_sect) && (*nb_sect < NB_MAX_SECTION))
	 { 
	   FIfld_insert_blank_row(form,SECTION_FIELD,row);

	   for(i = *nb_sect ; i > row ; i--)
	    {
	      is_def_num[i]  =  is_def_num[i-1];
	      sect_num[i]    =  sect_num[i-1];
	      is_def_dist[i] =  is_def_dist[i-1];
	      sect_dist[i]   =  sect_dist[i-1];
	    }
	   (*nb_sect)++;
	   sect_num[row].fr = NO_NUMBER;
	   sect_num[row].to = NO_NUMBER;
	   sect_num[row].spacing = NO_SPACING;
	   sect_num[row].offset = NO_OFFSET;
	   sect_dist[row].Xa = NO_DIST;
	   sect_dist[row].Xb = NO_DIST;
	   sect_dist[row].nb = NO_NUMBER;
	   is_def_num[row]  = FALSE;
	   is_def_dist[row] = FALSE; 
	 }
      }
     SMReinitSectGadget(form);
     
   } /* If mode == FI_SINGLE_SELECT */
  return 1;
}       


SMselect_from_field(form,form_main,sect_num,nb_sect,row,is_def_num)
Form form;                      /* [I] Pointer to section form */     
Form form_main;                 /* [I] Pointer to main form */
struct sect_info sect_num[];    /* [I/O] Sect info to modified */
int *nb_sect;                   /* [O] the number of section */
int row;                        /* [I] The selected row */
short is_def_num[];             /* [O] Table for defined sections */
{
  int low,high,nb_frame;
  char my_msg[MY_MSG_LEN];
  int sel_flag,r_pos;
  int from1;
  char value[40];
 

  value[0] = '\0';
  FIfld_get_text(form,SECTION_FIELD,row,FROM,39,(unsigned char*)value,&sel_flag,&r_pos);
  value[39] = '\0';
  if(value[0] == '\0')
    sect_num[row].fr = NO_NUMBER;
  else
    if(sscanf(value,"%d",&from1) != 1)
     {
       ex$message( msgnumb = SM_I_FrBadFr, buff = my_msg);
       FIg_set_text(form,FI_MSG_FIELD,my_msg);
       if(sect_num[row].fr == NO_NUMBER  || !is_def_num[row])
	 my_msg[0] = '\0';
       else
	 sprintf(my_msg,"%d",sect_num[row].fr);
       FIfld_set_text(form,SECTION_FIELD,row,FROM,my_msg,FALSE); 
     }
    else
      sect_num[row].fr = from1;
  
  if(sect_num[row].fr == NO_NUMBER)
    is_def_num[row] = FALSE;
  if(sect_num[row].fr != NO_NUMBER && sect_num[row].to != NO_NUMBER 
     && sect_num[row].spacing != NO_SPACING)
   {
     if(!is_def_num[row])
      { 
	is_def_num[row] = TRUE;
	compute_nb_sect(sect_num,is_def_num,
			(struct sect_dist *)NULL,
			(short  *)NULL,
			nb_sect);
      }
   }

  if(is_def_num[row])
   {
     search_low_high(&low,&high,&nb_frame,*nb_sect,sect_num);
     refresh_low_high(form_main,low,high,nb_frame,*nb_sect);
   }
  return 1;
}


SMselect_to_field(form,form_main,sect_num,nb_sect,row,is_def_num)
Form form;                       /* [I] Pointer to section form */     
Form form_main;                  /* [I] The main form pointer    */
struct sect_info sect_num[];      /* [O] Sect info to modified */
int *nb_sect;                     /* [O] the number of section */
int row;                          /* [I] The selected row */
short is_def_num[];               /* [O] Table for defined sections */
{
  int low,high,nb_frame;   
  char my_msg[MY_MSG_LEN];
  int sel_flag,r_pos;
  char value[40];
  int to;

  value[0] = '\0';
  FIfld_get_text(form,SECTION_FIELD,row,TO,39,(unsigned char*)value,&sel_flag,&r_pos);
  value[39] = '\0';
  if(value[0] == '\0')
    sect_num[row].to = NO_NUMBER;
  else
    if((sscanf(value,"%d",&to) != 1) ||
       (to < sect_num[row].fr))
     {
       ex$message( msgnumb = SM_I_FrBadTo, buff = my_msg);
       FIg_set_text(form,FI_MSG_FIELD,my_msg);
       if(sect_num[row].to == NO_NUMBER  || !is_def_num[row])
	 my_msg[0] = '\0';
       else
	 sprintf(my_msg,"%d",sect_num[row].to);
       FIfld_set_text(form,SECTION_FIELD,row,TO,my_msg,FALSE); 
     }
    else
      sect_num[row].to = to;
  
  if(sect_num[row].to == NO_NUMBER)
    is_def_num[row] = FALSE;
  if(sect_num[row].fr != NO_NUMBER && sect_num[row].to != NO_NUMBER 
     && sect_num[row].spacing != NO_SPACING)
   {
     if(!is_def_num[row])
      {
	is_def_num[row] = TRUE;
	compute_nb_sect(sect_num,is_def_num,
			(struct sect_dist *)NULL,
			(short  *)NULL,
			nb_sect);
      }
   }
  
  if(is_def_num[row])
   {
     search_low_high(&low,&high,&nb_frame,*nb_sect,sect_num);
     refresh_low_high(form_main,low,high,nb_frame,*nb_sect);
   }
   return 1;
}

SMselect_spacing_field(form,form_main,sect_num,nb_sect,row,is_def_num,sect_unit)
Form form;                    /* [I] Pointer to section form */     
Form form_main;               /* [I] The main form pointer    */
struct sect_info sect_num[];  /* [O] Sect info to modified */
int *nb_sect;                 /* [O] the number of section */
int row;                      /* [I] The selected row */
short is_def_num[];           /* [I] Table of defined sections */
char  *sect_unit;               /* [I] The current unit for sections */
{
  char my_msg[MY_MSG_LEN];
  int low,high,nb_frame;
  int sel_flag,r_pos;
  char value[40];
  double spacing;
  IGRdouble ext_value;

  value[0] = '\0';
  FIfld_get_text(form,SECTION_FIELD,row,SPACING,39,(unsigned char*)value,&sel_flag,&r_pos);
  value[39] = '\0';
  if(value[0] == '\0')
    sect_num[row].spacing = NO_SPACING;
  else
    if((sscanf(value,"%lf",&spacing) != 1)) /* || (spacing < 0))  SUNDAR for CR:179600824*/
     {
       ex$message( msgnumb = SM_I_FrBadSpac, buff = my_msg);
       FIg_set_text(form,FI_MSG_FIELD,my_msg);
       if(sect_num[row].spacing == NO_SPACING  || !is_def_num[row])
	 my_msg[0] = '\0';
       else
	{
	  SMfr_convert_int_unit(sect_num[row].spacing,sect_unit,&ext_value);
	  sprintf(my_msg,"%f",ext_value);
	}
       FIfld_set_text(form,SECTION_FIELD,row,SPACING,my_msg,FALSE);	
     }  
    else
      SMfr_convert_unit_int(spacing,sect_unit,&sect_num[row].spacing);

  if(sect_num[row].spacing == NO_SPACING)
    is_def_num[row] = FALSE;
  if(sect_num[row].fr != NO_NUMBER && sect_num[row].to != NO_NUMBER 
     && sect_num[row].spacing != NO_SPACING)
   {
     if(!is_def_num[row])
      { 
	is_def_num[row] = TRUE;
	compute_nb_sect(sect_num,is_def_num,
			(struct sect_dist *)NULL,
			(short  *)NULL,
			nb_sect);
	search_low_high(&low,&high,&nb_frame,*nb_sect,sect_num);
	refresh_low_high(form_main,low,high,nb_frame,*nb_sect);
      }
   }
 
  if(is_def_num[row])        
   {
     FIfld_set_value(form,SECTION_FIELD,row,OFFSET,
		     sect_num[row].offset == NO_OFFSET ? 0.0 : (double)sect_num[row].offset,FALSE);
   }
   return 1;
}

SMselect_offset_field(form,sect_num,row)
Form             form;       /* [I] Pointer to section form */     
struct sect_info sect_num[]; /* [O] Sect info to modified */
int              row;        /* [I] The selected row */
{
  char my_msg[MY_MSG_LEN];
  int sel_flag,r_pos;
  double value;

  FIfld_get_value(form,SECTION_FIELD,row,OFFSET,&value,&sel_flag,&r_pos);
  if(value < 0.0)
   { 
     ex$message( msgnumb = SM_W_FrOffDef, buff = my_msg);
     FIg_set_text(form,FI_MSG_FIELD,my_msg);
     FIfld_set_value(form,SECTION_FIELD,row,OFFSET,
		     sect_num[row].offset == NO_OFFSET ? 0.0 : (double)sect_num[row].offset,
		     FALSE); 
   }
  else
    sect_num[row].offset = (short)value;
   return 1;
}


SMselect_X1_field(form,sect_dist,nb_sect,row,is_def_dist,sect_unit)
Form             form;            /* [I] The form pointer */
struct sect_dist sect_dist[];     /* [O] Sect info to modified */
int              *nb_sect;        /* [O] Number of sections */
int              row;             /* [I] The selected row */
short            is_def_dist[];   /* [I] Table of defined sections */
char             *sect_unit;      /* [I] The current unit for sections */
{
  char my_msg[MY_MSG_LEN];
  int sel_flag,r_pos;  
  char value[40];
  double Xa;
  IGRdouble ext_value;

  value[0] = '\0';
  FIfld_get_text(form,SECTION_FIELD,row,X1,39,(unsigned char*)value,&sel_flag,&r_pos);
  value[39] = '\0';
   if(value[0] == '\0')
   {
     sect_dist[row].Xa = NO_DIST;
     is_def_dist[row] = FALSE;
   }
   else
     if(sscanf(value,"%lf",&Xa) != 1)
      { 
	ex$message( msgnumb = SM_E_FrX1Def, buff = my_msg);
	FIg_set_text(form,FI_MSG_FIELD,my_msg);
	if(sect_dist[row].Xa == NO_DIST || !is_def_dist[row])
	  my_msg[0] = '\0';
	else
	 {
	   SMfr_convert_int_unit(sect_dist[row].Xa,sect_unit,&ext_value);
	   sprintf(my_msg,"%g",ext_value);
	 }
	FIfld_set_text(form,SECTION_FIELD,row,X1,my_msg,FALSE); 
      }
     else
      {
	SMfr_convert_unit_int(Xa,sect_unit,&sect_dist[row].Xa);
	if(!is_def_dist[row] && sect_dist[row].Xb != NO_DIST &&
	   sect_dist[row].nb != NO_NUMBER)
	   {
	     is_def_dist[row] = TRUE;
	     compute_nb_sect((struct sect_info *)NULL,
			     (short *)NULL,
			     sect_dist,is_def_dist,nb_sect);
	   } 
      }
  return 1;
}

SMselect_X2_field(form,sect_dist,nb_sect,row,is_def_dist,sect_unit)
Form form;                    /* [I] Pointer to section form */     
struct sect_dist sect_dist[]; /* [O] Sect info to modified */
int   *nb_sect;               /* [O] Number of sections */
int row;                      /* [I] The selected row */
short is_def_dist[];          /* [I] Table of defined sections */
char  *sect_unit;             /* [I] The current unit for sections */
{
  char my_msg[MY_MSG_LEN];
  int sel_flag,r_pos;  
  char value[40];
  double Xb;
  IGRdouble ext_value;

  value[0] = '\0';
  FIfld_get_text(form,SECTION_FIELD,row,X2,39,(unsigned char*)value,&sel_flag,&r_pos);
  value[39] = '\0';
  if(value[0] == '\0')
   {
     sect_dist[row].Xb = NO_DIST;
     is_def_dist[row] = FALSE;
   }
  else
    if(sscanf(value,"%lf",&Xb) != 1)
     { 
       ex$message( msgnumb = SM_E_FrX2Def, buff = my_msg);
       FIg_set_text(form,FI_MSG_FIELD,my_msg);
       if(sect_dist[row].Xb == NO_DIST || !is_def_dist[row])
	 my_msg[0] = '\0';
       else
	{
	  SMfr_convert_int_unit(sect_dist[row].Xb,sect_unit,&ext_value);
	  sprintf(my_msg,"%g",ext_value);
	}
       FIfld_set_text(form,SECTION_FIELD,row,X2,my_msg,FALSE); 
     }
    else
     {
       SMfr_convert_unit_int(Xb,sect_unit,&sect_dist[row].Xb);
       if(!is_def_dist[row] && sect_dist[row].Xa != NO_DIST &&
	  sect_dist[row].nb != NO_NUMBER)
	{
	  is_def_dist[row] = TRUE;
	  compute_nb_sect((struct sect_info *)NULL,
			  (short *)NULL,
			  sect_dist,is_def_dist,nb_sect);
	}
     }
  return 1;
}  

/* Control the value for the number of intervals when a section
/* is defined with X1 X2 nb */
   
SMselect_number_field(form,sect_dist,nb_sect,sect_num,row,is_def_dist)
Form form;                    /* [I] Pointer to section form */     
struct sect_dist sect_dist[]; /* [O] Sect info to modified */
int   *nb_sect;               /* [O] Number of sections */
struct sect_info sect_num[];  /* [I] To know the offset for default display */
int row;                      /* [I] The selected row */
short is_def_dist[];          /* [I] Table of defined sections */
{
  char my_msg[MY_MSG_LEN];
  int sel_flag,r_pos;  
  char value[40];
  int Nb;

  value[0] = '\0';
  FIfld_get_text(form,SECTION_FIELD,row,NUMBER,39,(unsigned char*)value,&sel_flag,&r_pos);
  value[39] = '\0';
  if(value[0] == '\0')
   {
     sect_dist[row].nb = NO_NUMBER;
     is_def_dist[row] = FALSE;
   }
  else
    if(sscanf(value,"%d",&Nb) != 1 || Nb <= 0)
     { 
       ex$message( msgnumb = SM_E_FrNbDef, buff = my_msg);
       FIg_set_text(form,FI_MSG_FIELD,my_msg);
       if(sect_dist[row].nb == NO_NUMBER)
	 my_msg[0] = '\0';
       else
	 sprintf(my_msg,"%d",sect_dist[row].nb);
       FIfld_set_text(form,SECTION_FIELD,row,NUMBER,my_msg,FALSE); 
     }
    else
     {
       sect_dist[row].nb = Nb;
       if(sect_dist[row].Xa != NO_DIST && sect_dist[row].Xb != NO_DIST)
	 is_def_dist[row] = TRUE;
       compute_nb_sect((struct sect_info *)NULL,
		       (short *)NULL,
		       sect_dist,is_def_dist,nb_sect);
       FIfld_set_value(form,SECTION_FIELD,row,OFFSET,
		       sect_num[row].offset == NO_OFFSET ? 0.0 : (double)sect_num[row].offset,FALSE); 
       
     }
   return 1;
}


/* The toggle determines  in what mode the user want enter  the data */
/* It converts and display all the section for the choose mode */

SMselect_mode_toggle(form,sect_num,sect_dist,is_def_num,is_def_dist,
		     nb_sect,sect_unit)
Form form;                    /* [I] Pointer to section form */     
struct sect_info sect_num[];  /* [I/O] Sect info to convert */
struct sect_dist sect_dist[]; /* [I/O] Sect dist to convert */
short is_def_num[];           /* [I] Array of section defined by fr to */
short is_def_dist[];          /* [I] Array of section defined by Xa X2 */
int nb_sect;                  /* [I] the number of sections defined */
IGRchar *sect_unit;           /* [I] The current unit for sections */
{
  int mode;

  FIg_get_state(form,MODE_TOGGLE,&mode);
  if(mode)  /* We were fr to definition and want a X1 X2 def */
   {
     if(!conv_num_to_dist(form,sect_num,sect_dist,
			  is_def_num,is_def_dist,nb_sect))
      {
	FIg_set_state(form,MODE_TOGGLE,FALSE);
	return 0;
      }
     refresh_dist_field(form,sect_dist,nb_sect,is_def_dist,sect_unit);
     set_mode_section_field(form,FI_REVIEW,FI_INSERT,FI_INSERT);
   }     
  else
   {
     if(!conv_dist_to_num(form,sect_dist,sect_num,
			  is_def_dist,is_def_num,nb_sect))
      {
	FIg_set_state(form,MODE_TOGGLE,TRUE);
	return 0;
      }
     refresh_num_field(form,sect_num,nb_sect,is_def_num,sect_unit);
     set_mode_section_field(form,FI_INSERT,FI_REVIEW,FI_INSERT);
   }
  FIg_display(form,SECTION_FIELD);
  return 1;
}
  
/* Get the expression in the reinf field , analyse it and return 1 if OK */

SMselect_reinf_field(form,exp)
Form form;                 /* [I] Pointer to section form */     
char exp[];                /* [O] The expression in the reinf_field */
{
  char my_msg[MY_MSG_LEN];
  int sel_flag,r_pos;  
  char syn_error[20];
  int *reinf_array = NULL;
  int nb_elem = 0;

  exp[0] = '\0';
  FIfld_get_text(form,REINF_FIELD,0,0,(ATTR_TXT * NB_CUT_STR) - 1,(unsigned char*)exp,&sel_flag,&r_pos);
  exp[(ATTR_TXT * NB_CUT_STR) - 1] = '\0';
  if(!SMFrmAnalyseExp(exp,&reinf_array,&nb_elem,syn_error))
   {
     ex$message( msgnumb = SM_E_FrReinfDef , buff = my_msg,
		type = "%s",var = `syn_error`);
     FIg_set_text(form,FI_MSG_FIELD,my_msg);
     if(reinf_array != NULL) free(reinf_array);
     return 0;
   }

#ifdef DEBUG
{
  int i;
	
  printf("Table of reinforced : ");
  for(i = 0; i < nb_elem; i++)
   {
     if(i%15 == 0) putchar('\n');
     printf("%d ",reinf_array[i]);
   }
  putchar('\n');
}
#endif

  if(reinf_array != NULL) free(reinf_array);
  return 1;
}                   

/* Convert a number in a specified unit to the internal value */
SMfr_convert_unit_int(
IGRdouble input,       /* [I] number of unit to convert */
IGRchar   *unit,        /* [I] name of unit */
IGRdouble *output     /* [O] internal value */
)
{
  IGRlong  msg,status;
  OMuword  mod_osnum;

  ex$get_cur_mod(osnum=&mod_osnum);
  
  status = co$cvt_exp_to_wrk(msg =  &msg,
			     unit_type = GRIO_DISTANCE,
			     units = input,
			     alias = unit,
			     result = output,
			     osnum  = mod_osnum);

  if(!(status & msg &1))
    return 0;
   else
     return 1;
}

/* When unit field selected, retrieve the value and verify it's a good unit */
/* Redisplay the field corresponding to current value */

int SMselect_unit(form,sect_num,sect_dist,nb_sect,
		  is_def_num,is_def_dist,sect_unit)
Form form;                     /* [I] Pointer to section form */
struct sect_info sect_num[];   /* [I] Sect num to display */
struct sect_dist sect_dist[];  /* [I] Sect dist to display  */
int   nb_sect;                 /* [O] Number of sections */
short is_def_num[];            /* [I] Array of section defined by fr to */
short is_def_dist[];           /* [I] Array of section defined by Xa X2 */
IGRchar *sect_unit;            /* [O] The current unit for sections */
{
  int sel_flag,r_pos;  
  char unit[ATTR_TXT];
  IGRdouble dummy;

  unit[0] = '\0';
  unit[ATTR_TXT - 1] = '\0';
  FIfld_get_text(form,UNIT_FIELD,0,0,ATTR_TXT - 1,(unsigned char*)unit,&sel_flag,&r_pos);
  if(!SMfr_convert_unit_int(1.0,unit,&dummy))
   {
     FIg_set_text(form,UNIT_FIELD,sect_unit);
     return 0;
   }
  
  strcpy(sect_unit,unit);
  refresh_num_field(form,sect_num,nb_sect,is_def_num,sect_unit);
  refresh_dist_field(form,sect_dist,nb_sect,is_def_dist,sect_unit);

  return 1;
}

/*  Get the expression in the reverse field , analyse it and return 1 if OK */

SMselect_rev_field(form,exp)
Form form;        /* [I] Pointer to section form */     
char exp[];       /* [O] The expression in the reverse_field*/
{
  char my_msg[MY_MSG_LEN];
  int sel_flag,r_pos;  
  char syn_error[20];
  int *rev_array = NULL;
  int nb_elem = 0;

  exp[0] = '\0';
  FIfld_get_text(form,REVERSE_FIELD,0,0,(ATTR_TXT * NB_CUT_STR) - 1,(unsigned char*)exp,&sel_flag,&r_pos);
  exp[(ATTR_TXT * NB_CUT_STR) - 1] = '\0';
  if(!SMFrmAnalyseExp(exp,&rev_array,&nb_elem,syn_error))
   {
     ex$message( msgnumb = SM_E_FrRevDef , buff = my_msg,
		type = "%s",var = `syn_error`);
     FIg_set_text(form,FI_MSG_FIELD,my_msg);
     if(rev_array != NULL) free(rev_array);
     return 0;
   }

#ifdef DEBUG
{
  int i;
  printf("Table of reverse : ");
  for(i = 0; i < nb_elem; i++)
   {
     if(i%15 == 0) putchar('\n');
     printf("%d ",rev_array[i]);
   }
  putchar('\n');
}
#endif  

  if(rev_array != NULL) free(rev_array);
  return 1;
} 

end implementation SMCmdPlMdFr;


