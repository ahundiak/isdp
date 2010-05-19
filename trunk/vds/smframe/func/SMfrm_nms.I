/* $Id: SMfrm_nms.I,v 1.2 2001/02/14 19:59:38 ramarao Exp $ 1.2 1996/09/27 15:39:34 pinnacle Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smframe/func/SMfrm_nms.I
 *
 * Description: It has methods/functions to handle "Frame Names" form.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMfrm_nms.I,v $
 *	Revision 1.2  2001/02/14 19:59:38  ramarao
 *	Modification related to SetProc() macro.
 *	
 *	Revision 1.1.1.1  2001/01/04 21:07:35  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.4  1998/02/09  17:43:22  pinnacle
# Replaced: smframe/func/SMfrm_nms.I for:  by azuurhou for vds
#
# Revision 1.3  1998/01/19  21:32:08  pinnacle
# Replaced: smframe/func/SMfrm_nms.I for:  by v250_int for vds
#
# Revision 1.2  1997/12/10  14:23:18  pinnacle
# Route
#
# Revision 1.1  1997/12/02  09:18:40  pinnacle
# Created: smframe/func/SMfrm_nms.I by ksundar for vds
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	12/02/97	Sundar		Creation Date
 *	12/10/97	ah		string.h added
 * -------------------------------------------------------------------*/

class implementation SMCmdPlMdFr;
 
#define AS_DEBUG	1

#include "string.h"

#include "AS_status.h"
#include "vdsmacros.h"
#include "v_dbgmacros.h"
#include "VDmem.h"

from SMfrm_syst import SMfind_all_frame;

#define MAX_VALUE_FROM_FIELD 999999
#define MIN_VALUE_FROM_FIELD -999999

method SMSetNmFrm( Form form )
{

	IGRint i;
	
	SetProc( SMCmdPlMdFr.SMSetNmFrm ) ; Begin

	for(i = 0 ; i < me->old_nb_nm_sect ; i++) {
 
                        IGRchar vaule[40];
 
                        if ( me->old_nm_sect_info[i].fr ==
                                        me->old_nm_sect_info[i].to){
                                sprintf(vaule,"%d", me->old_nm_sect_info[i].fr);
                        } else {
                                sprintf(vaule,"%d-%d",
                                                me->old_nm_sect_info[i].fr,
                                                me->old_nm_sect_info[i].to);
                        }
 
                        FIfld_set_text(form,FRAME_NO_NAME,i,FR_NO,
                                        vaule,FALSE);
                        FIfld_set_text(form,FRAME_NO_NAME,i,FR_NAME,
                                        me->old_nm_sect_info[i].name,FALSE);
 
                        if ( me->old_nm_sect_info[i].dorn == 1){
                                FIfld_set_text(form,FRAME_NO_NAME,i,FR_DISPLAY,
                                        "Distance",FALSE);
                        } else if ( me->old_nm_sect_info[i].dorn == 0){
                                FIfld_set_text(form,FRAME_NO_NAME,i,FR_DISPLAY,
                                        "Number",FALSE);
                        }
 
                }
 
                for(i = me->old_nb_nm_sect; i<NB_MAX_SECTION; i++){
 
                        FIfld_set_text(form,FRAME_NO_NAME,i,FR_NO,"",FALSE);
                        FIfld_set_text(form,FRAME_NO_NAME,i,FR_NAME,"",FALSE);
                        FIfld_set_text(form,FRAME_NO_NAME,i,FR_DISPLAY,
                                                                "",FALSE);
                }

	End
	return OM_S_SUCCESS;
}
method SMReSetNmFrm( Form form; IGRint button)
{
	IGRint i;

	SetProc( SMCmdPlMdFr.SMReSetNmFrm ) ; Begin

	if ( button == FI_CANCEL || button == FI_RESET ){
		for(i = 0 ; i < NB_MAX_SECTION ; i++) {
                	me->new_nm_sect_info[i].fr = me->old_nm_sect_info[i].fr;
                	me->new_nm_sect_info[i].to = me->old_nm_sect_info[i].to;
                	strcpy(me->new_nm_sect_info[i].name,
				me->old_nm_sect_info[i].name);
                	me->new_nm_sect_info[i].dorn = me->old_nm_sect_info[i].dorn;
			me->is_def_name[i] = TRUE;
		}

		for(i = me->old_nb_nm_sect; i<NB_MAX_SECTION; i++) 
			me->is_def_name[i] =  FALSE;
		me->new_nb_nm_sect=me->old_nb_nm_sect;

	}else if ( button == FI_EXECUTE || button == FI_ACCEPT){

		for(i = 0 ; i < me->new_nb_nm_sect ; i++) {
                	me->old_nm_sect_info[i].fr = me->new_nm_sect_info[i].fr;
                	me->old_nm_sect_info[i].to = me->new_nm_sect_info[i].to;
                	strcpy(me->old_nm_sect_info[i].name,
				me->new_nm_sect_info[i].name);
                	me->old_nm_sect_info[i].dorn = me->new_nm_sect_info[i].dorn;
        	}

        	for(i = me->new_nb_nm_sect; i<NB_MAX_SECTION; i++) 
                	me->is_def_name[i] =  FALSE;
		me->old_nb_nm_sect=me->new_nb_nm_sect;

	}

	if ( button == FI_RESET ){

		for(i = 0 ; i < me->old_nb_nm_sect ; i++) {

			IGRchar vaule[40];

			if ( me->old_nm_sect_info[i].fr == 
					me->old_nm_sect_info[i].to){ 
				sprintf(vaule,"%d", me->old_nm_sect_info[i].fr);
			} else {
				sprintf(vaule,"%d-%d", 
						me->old_nm_sect_info[i].fr,
						me->old_nm_sect_info[i].to);
			}

			FIfld_set_text(form,FRAME_NO_NAME,i,FR_NO,
					vaule,FALSE);
			FIfld_set_text(form,FRAME_NO_NAME,i,FR_NAME,
					me->old_nm_sect_info[i].name,FALSE);

			if ( me->old_nm_sect_info[i].dorn == 1){
				FIfld_set_text(form,FRAME_NO_NAME,i,FR_DISPLAY,
					"Distance",FALSE);
			} else if ( me->old_nm_sect_info[i].dorn == 0){
				FIfld_set_text(form,FRAME_NO_NAME,i,FR_DISPLAY,
					"Number",FALSE);
			}

                }

		for(i = me->old_nb_nm_sect; i<NB_MAX_SECTION; i++){

			FIfld_set_text(form,FRAME_NO_NAME,i,FR_NO,"",FALSE);
			FIfld_set_text(form,FRAME_NO_NAME,i,FR_NAME,"",FALSE);
			FIfld_set_text(form,FRAME_NO_NAME,i,FR_DISPLAY,
								"",FALSE);	
		}
		
		if ( me->param_buf.name_toggle ){
                	FIfld_set_text(form, DEFAULT_FR_NAME,
                                0, 2, "Distance", FALSE);
        	} else {
                	FIfld_set_text(form, DEFAULT_FR_NAME, 
				0, 2, "Number", FALSE);
        	}
        	FIfld_set_text(form, DEFAULT_FR_NAME,
                                0, 1, me->param_buf.annotation_field, FALSE);

	}
	
	End
	return OM_S_SUCCESS;
}

method SMProcFrmNmFld( Form form_ptr )
{
	int	row,pos,col;
	int	low,high,nb_frame;

	SetProc( SMCmdPlMdFr.SMProcFrmNmFld ) ; Begin

	FIg_set_text(form_ptr,MESSAGE_NAME,"");
	FIfld_get_active_row(form_ptr,FRAME_NO_NAME, &row,&pos);
	FImcf_get_active_col(form_ptr,FRAME_NO_NAME,&col,&pos);
	search_low_high(&low,&high,&nb_frame,me->new_nb_sect,me->new_sect_info);
 
        switch(col)
        {
            case FR_NO :
              SMselect_frno_field(form_ptr, me->new_nm_sect_info,
			&me->new_nb_nm_sect,row,me->is_def_name,
			low,high);
              break;
 
            case FR_NAME:
              SMselect_frname_field(form_ptr, me->new_nm_sect_info,
			&me->new_nb_nm_sect,row,me->is_def_name);
              break;
            case FR_DISPLAY:
              SMselect_frdisplay_field(form_ptr,me->new_nm_sect_info,
			&me->new_nb_nm_sect,row,me->is_def_name);
              break;
        }

// wrapup :
	End
        return OM_S_SUCCESS;
}


compute_nb_nm_sect(sect_name,is_def_name,nb_nm_sect)
struct nm_sect_info sect_name[] ;    	/* [I] Name sect info to display */
short  is_def_name[]         ;    	/* [I] Array of defined name sections */
int *nb_nm_sect;                    	/* [O] Number of defined sections */
{
  int i;
 
  SetProc( SMCmdPlMdFr.compute_nb_nm_sect ) ; Begin

  i=0;
  if(sect_name != NULL && is_def_name != NULL){

    while(i < NB_MAX_SECTION &&
          sect_name[i].fr != NO_NUMBER &&
          sect_name[i].to != NO_NUMBER &&
          sect_name[i].name[0] != '\0' &&
          is_def_name[i]){
      i++;

      #ifdef vdsDEBUG
      		printf ("%d-%d %s %d\n",
                        sect_name[i].fr,
                        sect_name[i].to,
                        sect_name[i].name,
                        sect_name[i].dorn);
     #endif
    }
  }
 
  *nb_nm_sect = i;
	
  End
  return 1;
}

SMselect_frno_field(form,sect_name,nb_nm_sect,row,is_def_name,low,high)
Form form;                      	/* [I] Pointer to section form */
struct nm_sect_info sect_name[];    	/* [I/O] Sect info to modified */
int *nb_nm_sect;                   	/* [O] the number of section */
int row;                        	/* [I] The selected row */
short is_def_name[];             	/* [O] Table for defined sections */
int low;				/* [I] Lower frame number	*/
int high;				/* [I] Higher frame number	*/
{
	char my_msg[MY_MSG_LEN];
	int sel_flag,r_pos;
	int from1, to1=NO_NUMBER;
	char value[12];
 
	SetProc( SMCmdPlMdFr.SMselect_frno_field ) ; Begin

	value[0] = '\0';
	FIfld_get_text(form,FRAME_NO_NAME,row,FR_NO,11,
			(unsigned char*)value, &sel_flag, &r_pos);
	value[10] = '\0';
	if(value[0] == '\0'){
		sect_name[row].fr = NO_NUMBER;
		sect_name[row].to = NO_NUMBER;
	} else if(sscanf(value,"%d-%d",&from1, &to1) == 0) {
		ex$message( msgnumb = SM_I_FrBadFr, buff = my_msg);
		FIg_set_text(form,MESSAGE_NAME,my_msg);
		if(sect_name[row].fr == NO_NUMBER || !is_def_name[row])
         		my_msg[0] = '\0';
		else{
			if ( to1 == NO_NUMBER ){
				sprintf(my_msg,"%d",
					sect_name[row].fr);
			} else {
				sect_name[row].to=sect_name[row].fr=from1;
				sprintf(my_msg,"%d-%d",
					sect_name[row].fr,sect_name[row].to);
			}
		}
		FIfld_set_text(form,FRAME_NO_NAME,row,FR_NO,my_msg,FALSE);
	} else{
		sect_name[row].fr = from1;
		if ( to1 == NO_NUMBER )
			sect_name[row].to = from1;
		else
			sect_name[row].to = to1;
		if ( sect_name[row].fr < low || sect_name[row].to > high ||
			sect_name[row].fr > sect_name[row].to ){

			FIfld_set_text(form,FRAME_NO_NAME,row,FR_NO,
                                        "",FALSE);
			sprintf (my_msg, "Invalid range [%d-%d]",
				sect_name[row].fr, sect_name[row].to);
			FIg_set_text(form,MESSAGE_NAME,my_msg);
			sect_name[row].fr = NO_NUMBER;
			sect_name[row].to = NO_NUMBER;
		}
		if ( row > 0 ){

			if ( sect_name[row].fr <= sect_name[row-1].to ){
 
                        	FIfld_set_text(form,FRAME_NO_NAME,row,FR_NO,
                                        "",FALSE);
                        	sprintf (my_msg, "Invalid range [%d-%d]",
                                	sect_name[row].fr, sect_name[row].to);
                        	FIg_set_text(form,MESSAGE_NAME,my_msg);
                        	sect_name[row].fr = NO_NUMBER;
                        	sect_name[row].to = NO_NUMBER;
                	}

		}
	}
 
	if(sect_name[row].fr == NO_NUMBER )
		is_def_name[row] = FALSE;
	if(sect_name[row].fr != NO_NUMBER && sect_name[row].to != NO_NUMBER
		&& sect_name[row].name[0] != '\0' && sect_name[row].dorn != 2) {
		if(!is_def_name[row]) {
			is_def_name[row] = TRUE;
			compute_nb_nm_sect(sect_name, is_def_name, nb_nm_sect);
		}
	}
 
	End
	return 1;
}

SMselect_frname_field(form,sect_name,nb_nm_sect,row,is_def_name)
Form form;                              /* [I] Pointer to section form */
struct nm_sect_info sect_name[];        /* [I/O] Sect info to modified */
int *nb_nm_sect;                        /* [O] the number of section */
int row;                                /* [I] The selected row */
short is_def_name[];                    /* [O] Table for defined sections */
{
        int sel_flag,r_pos,len;
	char my_msg[MY_MSG_LEN];
        char value[12];
 
	SetProc( SMCmdPlMdFr.SMselect_frname_field ) ; Begin

	sect_name[row].name[0] = '\0';
        value[0] = '\0';
        FIfld_get_text(form,FRAME_NO_NAME,row,FR_NAME,11,
                        (unsigned char*)value, &sel_flag, &r_pos);
        value[10] = '\0';
        if(value[0] == '\0'){
                sect_name[row].name[0] = '\0';
        } else {
                strcpy(sect_name[row].name,value);
		FIfld_set_text(form,FRAME_NO_NAME,row,FR_NAME,value,FALSE);
        }
 
	len=strlen(sect_name[row].name);
	if ( len != 0) {
		if ( sect_name[row].name[0] != '%' && 
				sect_name[row].name[len-1] != '%' ){
			if ( sect_name[row].fr != sect_name[row].to ){
				FIfld_set_text(form,FRAME_NO_NAME,row,FR_NAME,
					"",FALSE);
				sprintf(my_msg,"Invalid string '%s'",
					sect_name[row].name);
				FIg_set_text(form,MESSAGE_NAME,my_msg);
				sect_name[row].name[0]='\0';
			}
		}			
	}
        if(sect_name[row].name[0] == '\0' )
                is_def_name[row] = FALSE;
        if(sect_name[row].fr != NO_NUMBER && sect_name[row].to != NO_NUMBER 
		&& sect_name[row].name[0] != '\0' && sect_name[row].dorn != 2) {
                if(!is_def_name[row]) {
                        is_def_name[row] = TRUE;
                        compute_nb_nm_sect(sect_name, is_def_name, nb_nm_sect);
                }
        }
 
	End
        return 1;
}

SMselect_frdisplay_field(form,sect_name,nb_nm_sect,row,is_def_name)
Form form;                              /* [I] Pointer to section form */
struct nm_sect_info sect_name[];        /* [I/O] Sect info to modified */
int *nb_nm_sect;                        /* [O] the number of section */
int row;                                /* [I] The selected row */
short is_def_name[];                    /* [O] Table for defined sections */
{
        char my_msg[MY_MSG_LEN];
        int sel_flag,r_pos;
        int from1, to1;
        int test, len;
        char value[12];

	SetProc( SMCmdPlMdFr.SMselect_frdisplay_field ) ; Begin
 
	test=0;
	from1 = to1 = NO_NUMBER;

        value[0] = '\0';
        FIfld_get_text(form,FRAME_NO_NAME,row,FR_DISPLAY,11,
                        (unsigned char*)value, &sel_flag, &r_pos);
        value[10] = '\0';
        if(value[0] == '\0'){
                sect_name[row].dorn = 2;
		len=strlen(sect_name[row].name);
                if ( len != 0) {
                        if ( sect_name[row].name[0]!= '%' &&
                                sect_name[row].name[len-1] != '%' ){
                                sect_name[row].dorn = 2;
                                FIfld_set_text(form,FRAME_NO_NAME,row,
                                        FR_DISPLAY,"",FALSE);
 
                                is_def_name[row] = TRUE;
                                return 0;
                        }
                }

        } else { 

		len=strlen(sect_name[row].name);
		if ( len != 0) {
			if ( sect_name[row].name[0]!= '%' &&
                                sect_name[row].name[len-1] != '%' ){
				sect_name[row].dorn = 2;
                		FIfld_set_text(form,FRAME_NO_NAME,row,
					FR_DISPLAY,"",FALSE);

				is_def_name[row] = TRUE;
				return 0;
			}
		}

		if ( strcmp(value,"D") && strcmp(value,"N") &&
			strcmp(value,"d") && strcmp(value,"n") &&
			strcmp(value,"Distance") && strcmp(value,"Number") ){
			sprintf(my_msg,
			    "Invalid input '%s' , Number or Distance",value);
                	FIfld_set_text(form,FRAME_NO_NAME,row,FR_DISPLAY,					"",FALSE);
			/*
			test = FIfld_pos_cursor(form,FRAME_NO_NAME,row ,0,
					FR_DISPLAY, 0, 0, 0);
  			if(test != FI_SUCCESS) return ERRO;
			*/
                	FIg_set_text(form,MESSAGE_NAME,my_msg);
			sect_name[row].dorn = 2;
			return 0;
		}
		if ( !strcmp(value,"D") || !strcmp(value,"d") ||
			!strcmp(value,"Distance") ){
			FIfld_set_text(form,FRAME_NO_NAME,row,FR_DISPLAY,
					"Distance", FALSE);
			sect_name[row].dorn = 1;
		}else{
			sect_name[row].dorn = 0;
                	FIfld_set_text(form,FRAME_NO_NAME,row,FR_DISPLAY,
					"Number",FALSE);
		}
        } 
 
        if(sect_name[row].dorn == 2 )
                is_def_name[row] = FALSE;
        if(sect_name[row].fr != NO_NUMBER && sect_name[row].to != NO_NUMBER
                && sect_name[row].name[0] != '\0' && sect_name[row].dorn != 2) {
                if(!is_def_name[row]) {
                        is_def_name[row] = TRUE;
                        compute_nb_nm_sect(sect_name, is_def_name, nb_nm_sect);
                }
        }
 
	End
        return 1;
}

SMSetFrmName( nm_sect_info, nb_nm_sect, offset, frame_number, 
			units, main_dsp_type, annot, name)
struct nm_sect_info 	*nm_sect_info;
IGRint 			nb_nm_sect;
IGRdouble 		offset;
IGRint			frame_number;
IGRchar  		*units;
IGRint  		main_dsp_type;
IGRchar  		*annot;
IGRchar  		*name;
{
	IGRint index;
	IGRint i;
		
	SetProc( SMCmdPlMdFr.SMSetFrmName ) ; Begin

		 
	i=0;
#ifdef vdsDEBUG
	printf ("nb_nm_sect=%d\n", nb_nm_sect);
	printf ("offset=%f\n", offset);
	printf ("frame_number=%d\n", frame_number);
	printf ("units=%s\n", units);
	printf ("main_dsp_type=%d\n", main_dsp_type);
	printf ("annot=%s\n", annot);
	for(i=0; i<nb_nm_sect; i++){
		printf ("%d-%d %s %d\n",
			nm_sect_info[i].fr,
			nm_sect_info[i].to,
			nm_sect_info[i].name,
			nm_sect_info[i].dorn);
	}
#endif

	name[0]='\0' ;

	if ( SMIsInNmSect(nm_sect_info, nb_nm_sect, frame_number, &index)){
		IGRint len=0;
                IGRchar befstr[12], aftstr[12];
                IGRchar *bef=NULL, *aft=NULL;
 
		len=strlen(nm_sect_info[index].name);
		if ( len != 0) {
			if ( nm_sect_info[index].name[0] != '%' &&
                                nm_sect_info[index].name[len-1] != '%' ){
				strcpy(name,nm_sect_info[index].name);

				return 1;
                	}
        	}
	
	
                strcpy(befstr,nm_sect_info[index].name);
                strcpy(aftstr,nm_sect_info[index].name);
 
                if (befstr[0] != '%' ){
                	bef=strtok(befstr,"%");
                   	len=strlen(bef);
                   	bef[len]='\0' ;
                   	if(nm_sect_info[index].dorn == 1){
				// IGRdouble cvt_pos;
				// SMfr_cvt_pos_int( offset,units,&cvt_pos); 
                         	sprintf(name, "%s%g", 
					bef,offset+frame_number);
                   	} else if ( nm_sect_info[index].dorn == 0){
                                sprintf(name, "%s%d", bef, frame_number);
                   	} else
				printf ("Wrong type\n");
                } else{
                   	aft=strstr(aftstr,"%");
                   	len=strlen(aft);
                   	aft[len]='\0' ;
			if(nm_sect_info[index].dorn == 1){
				// IGRdouble cvt_pos;
                                // SMfr_cvt_pos_int( offset,units,&cvt_pos);
                                sprintf(name, "%g%s", 
					offset+frame_number,&aft[1]);
                   	} else if ( nm_sect_info[index].dorn == 0){
                                sprintf(name, "%d%s", frame_number, &aft[1]);
                   	} else
                                printf ("Wrong type\n");
                }
 
		// printf ("SMSetFrmName 0 name=%s\n", name);
		/*
                if ( bef )
                        free(bef);
                if ( aft )
                        free(aft);
		*/
 
        } else {

		End
        	return 0;
#if 0
		if ( main_dsp_type == NAME_BY_DIST ){
			IGRdouble cvt_pos=0.0;

			/*
			if ( offset )
                        	SMfr_cvt_pos_int( offset,units,&cvt_pos);
			else
				cvt_pos=0.0;
			printf ("cvt_pos=%f\n", cvt_pos);
			printf ("cvt_pos=%d\n", (int)cvt_pos);
			*/
			sprintf(name,"%s%g", 
				annot,offset+frame_number );
		} else {
			sprintf(name,"%s%d", 
				annot,frame_number );

		}
		
		// printf ("SMSetFrmName 1 name=%s\n", name);
#endif
	}

	End
	return 1;
}

SMIsInNmSect(nm_sect_info, nb_nm_sect, fn, index)
struct nm_sect_info 	*nm_sect_info;
IGRint 			nb_nm_sect;
IGRint 			fn;
IGRint 			*index;
{
	IGRint i;

	SetProc( SMCmdPlMdFr.SMIsInNmSect ) ; Begin

	if ( nb_nm_sect == 0){
		End
		return 0;
	}

	for (i=0; i<nb_nm_sect; i++)
		if ( (nm_sect_info[i].fr <= fn)&&(fn <= nm_sect_info[i].to) ){
			*index=i;
			End
			return 1;
		}

	End
	return 0;
}

SMfr_cvt_pos_int(
IGRdouble    dist,               /* [I] Distance of frame to the CS  */
IGRchar        *unit,		 /* [I] Units			     */
IGRdouble     *cvt_pos             /* [O] Converted position           */
)
{

  SetProc( SMCmdPlMdFr.SMfr_cvt_pos_int ) ; Begin

  if(!SMfr_convert_int_unit(dist,unit,cvt_pos))
    *cvt_pos = dist;
  *cvt_pos *= 100;
  *cvt_pos = ceil(*cvt_pos);
  *cvt_pos /= 100;
 
  End
  return 1;
}
end implementation SMCmdPlMdFr;
