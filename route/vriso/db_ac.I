/********************************
/* MODIFICATION 20  2  1990
/* FOR THE NEW ATT_FILE
/*******************************/

class implementation Root;

#include <stdio.h>
#include <string.h>

#include "OMerrordef.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "msdef.h"

#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "griomacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"


#include "VDmem.h"
#include "VRdef.h"
#include "VRcompdef.h"
#include "VRdimdef.h"
#include "VRcsdef.h"
#include "VRstructs.h"
#include "VRDbParamDef.h"
#include "VRparamdef.h"
#include "ACrg_collect.h"
#include "ACattrib.h"

/*#include "plmacros.h" */

#include "big.h"
#include "dbs.h"
#include "attrdef.h"

#include "AS_status.h"

#define AS_DEBUG 1

from VRGeneric 		import VRGetTopo,VRGetModel,VRGetParams,VRGetCompDesc,VRGetSysType;
from ACrg_collect 	import AClist_attribute;
from NDmacro 		import ACgive_structure;

struct bg_info
{
	int   occ;
	short cp;
};

struct search_row
{
	char  search_crit[MAX_SEARCH][50];
	short row_nb[MAX_SEARCH];
	short nb_row;
	int bend_index[MAX_SEARCH];
};
extern  int  prj_units_set;


/************************************************************************
 *
 *   genentp:
 *
 *   This function for a particular objid, genere a row with that Bob
 *   wants.
 *   A dynamic allocation of the row is performed.
 *
 ************************************************************************/

genentp(msg,obj,buff_attr,cur_occ,red_cp,cmp_err)
long		 *msg;		/* return code		(O)		*/
struct GRid 	  obj;		/* object to read	(I)		*/
struct buff_attr *buff_attr;    /* struct to fill	(I/O)		*/
int		  cur_occ;      /* segment occ          (I/O)           */
char		  *red_cp;
struct GRid	  *cmp_err;
/*.genentp*/
{
	long			status;
	int			size, i,j,nb_time;
	int			index, ligne;
	short			nb_cp;
	short			first = 0,second = 0,third = 0,fourth = 0,fifth = 0;
	char			string[10];
	char			tmp[20];
	char			temp_unit[8];
	char			rating_unit[8],weight_unit[8];
	char			comp_code[7],detail_num[8],tag_num[8];
	int			design_code;
	int			suc,AC_index,supp_flag,pipe_flag,elbow_flag,bend_flag,err_flag;
	int			cp2 = 0, modifier;
	int			optcode, supp_type;

	struct ret_struct	compcode_st, optcode_st, pipe_st, bend_st,
				det_num_st, supp_type_st, tag_num_st;
	struct GRmd_env 	local_env;
	IGRlong  		NumberOfBytes, BytesReceived,rt;
	double			pipe_length,bend_angle;
	short 			cmp_type;
	struct ACrg_coll 	rg_coll, dyn_attr[MAX_DYN_ATTR];
	struct ACrg_coll	cache_attr[MAX_CACHE_ATTR];
	int			nb_dyn_attr, nb_cache_attr;
	struct GRid		model_id, sysparams_id, usrparams_id;
        IGRshort                nSysType;

	*msg = MSFAIL;

        /*   potentially uninitialized   */
        modifier  = 0;
        optcode   = 0;
        supp_type = 0;
        nb_cp     = 0;
        size      = 0;

	index = 0;
	ligne = buff_attr->nb_buff;
	nb_time = 0;
	strcpy(temp_unit , "degf");
	strcpy(rating_unit , "psig");
	strcpy(weight_unit,"lb");
	design_code = 0;
	supp_flag   = 0; pipe_flag   = 0; bend_flag  = 0; elbow_flag   = 0;
	err_flag    = 0;

	/*"nb lines: %d \n",buff_attr->nb_buff*/

	/* look for the criteria to access to the family catalog */
	if (cur_occ > 30000)
	{
		/*|cut pipe: do not need to be in att_file\n*/
		return 1;
	}


	/*|give_any_struc provides md_env */

	NumberOfBytes = sizeof( struct GRmd_env );

	gr$get_module_env(msg = &rt,
	    sizbuf = &NumberOfBytes,
	    buffer = &local_env,
	    nret   = &BytesReceived );


	/*| Get the component type */

	strcpy(rg_coll.name, VR_N_COMP_TYPE_IN);
	status = om$send(msg      = message VRGeneric.VRGetCompDesc(msg, &rg_coll, NULL),
	    senderid = NULL_OBJID,
	    targetid = obj.objid,
	    targetos = obj.osnum);
	if (!(status&1)){ 
		om$report_error(sts=status); 
		*cmp_err= obj;
		*msg = 6; 
		return(0);
	}


	/*"comp type: %d\n", (int)(rg_coll.desc.value.att_exp) */
	cmp_type = (int)(rg_coll.desc.value.att_exp);

/* Madhukar -
 
           Get the comp_type for a nozzle 
*/
        nSysType = 0;
	status = om$send(msg      = message VRGeneric.VRGetSysType(msg, &nSysType),
	    senderid = NULL_OBJID,
	    targetid = obj.objid,
	    targetos = obj.osnum);
	if (!(status&1)){ 
		om$report_error(sts=status); 
		*cmp_err= obj;
		*msg = 6; 
		return(0);
	}
        if(nSysType == VR_NOZZLE)
         cmp_type = VRP_V_NOZZLE_TYPE;

	switch(cmp_type) {
		case VRP_V_SUPPORT_TYPE: 
			/*|component is a support\n*/
			supp_flag=1;
			break;
		case VRP_V_PIPE_TYPE :
			/*|component is a pipe\n*/
			pipe_flag=1;
			break;
		case VRP_V_ELBOW_TYPE:
			/*|component is an elbow\n*/
			elbow_flag=1;
			break;
		case VRP_V_BEND_TYPE:
			/*|component is a bend\n*/
			bend_flag=1;
			break;
		case VRP_V_MAXIMUM_TYPE:
			/*|component is an error component\n*/
			err_flag=1;
			break;
		default: break;
	}

	/*| retrieve info inside the design file and construct the criterion */

	status = om$send(msg = message VRGeneric.VRGetParams(msg, &sysparams_id, 
	    &usrparams_id, NULL),
	    senderid = NULL_OBJID,
	    targetid = obj.objid,
	    targetos = obj.osnum);
	if (!(status&1)){ 
		om$report_error(sts=status); 
		*cmp_err = obj;
		*msg = 11;
		return(0);
	}

	status = om$send(msg = message ACrg_collect.AClist_attribute(msg, MAX_DYN_ATTR,
	    dyn_attr, &nb_dyn_attr),
	    senderid = NULL_OBJID,
	    targetid = sysparams_id.objid,
	    targetos = sysparams_id.osnum);
	if (!(status&1)){ 
		om$report_error(sts=status); 
		*cmp_err = obj;
		*msg = 11;
		return(0);
	}

        for ( i = 0; i < nb_dyn_attr; i++)
        {
                /*"dyn_attr[%d].name = %s\n",i,dyn_attr[i].name */
                /*if(dyn_attr[i].desc.type == AC_ATTRIB_DOUBLE) */
                        /* dyn_attr[%d].desc.value.att_txt = %s\n",i,dyn_attr[i].desc.value.att_txt */
                /* else if(dyn_attr[i].desc.type == AC_ATTRIB_DOUBLE) */
                        /* dyn_attr[%d].desc.value.att_exp = %f\n",i,dyn_attr[i].desc.value.att_exp */
	}

	/*********  For  retrievng the data from CACHE   *************/

	status = om$send(msg = message VRGeneric.VRGetModel(msg,&model_id, &local_env),
	    senderid = NULL_OBJID,
	    targetid = obj.objid,
	    targetos = obj.osnum);
	if (!(status&1)){ 
		om$report_error(sts=status); 
		*cmp_err = obj;
		*msg = 11;
		return(0);
	}

	/*"Model_id.id = %d, os_num = %d\n",model_id.objid,model_id.osnum */

	AC_index = 0;
	if(!supp_flag)
	{
		status = om$send(msg = message NDmacro.ACgive_structure(&suc,
				&AC_index,"comp_code",&compcode_st, &local_env),
				senderid = NULL_OBJID,
				targetid = obj.objid,
				targetos = obj.osnum);
            if (!(status&1))
	    {
                om$report_error(sts=status);
                *cmp_err = obj;
                *msg = 9;
                return(0);
	    }
		if(!(suc & 1)) {printf("give struct not success\n"); return 0;}
		strcpy( comp_code,compcode_st.var.text_st.text_string);
		/*"comp_code = %s\n",comp_code*/	

		status = om$send(msg = message NDmacro.ACgive_structure(&suc,
				&AC_index,"opt_code",&optcode_st, &local_env),
				senderid = NULL_OBJID,
				targetid = obj.objid,
				targetos = obj.osnum);
            if (!(status&1))
	    {
                om$report_error(sts=status);
                *cmp_err = obj;
                *msg = 9;
                return(0);
	    }
		if(!(suc & 1)) {printf("give struct not success\n"); return 0;}
		optcode = (int)optcode_st.var.root_pm_st.value;
		/*"opt_code = %d\n",optcode*/	
	}
	if(supp_flag)
	{
		status = om$send(msg = message NDmacro.ACgive_structure(&suc,
				&AC_index,VR_N_SUPP_TYPE_IN,&supp_type_st, &local_env),
				senderid = NULL_OBJID,
				targetid = obj.objid,
				targetos = obj.osnum);
            if (!(status&1))
	    {
                om$report_error(sts=status);
                *cmp_err = obj;
                *msg = 9;
                return(0);
	    }
		if(!(suc & 1)) {printf("give struct not success\n"); return 0;}
		supp_type = (int)supp_type_st.var.root_pm_st.value;
		/*"supp_type = %d\n",supp_type*/	

		status = om$send(msg = message NDmacro.ACgive_structure(&suc,
				&AC_index,VR_N_DETAIL_NUM_AN,&det_num_st, 
				&local_env),
				senderid = NULL_OBJID,
				targetid = obj.objid,
				targetos = obj.osnum);
            if (!(status&1))
	    {
                om$report_error(sts=status);
                *cmp_err = obj;
                *msg = 9;
                return(0);
	    }
		if(!(suc & 1)) {printf("give struct not success\n"); return 0;}
		strcpy( detail_num,det_num_st.var.text_st.text_string);
		/*"detail_num = %s\n",detail_num*/	

		status = om$send(msg = message NDmacro.ACgive_structure(&suc,
				&AC_index,VR_N_TAG_NUMBER_AN,&tag_num_st, 
				&local_env),
				senderid = NULL_OBJID,
				targetid = obj.objid,
				targetos = obj.osnum);
            if (!(status&1))
	    {
                om$report_error(sts=status);
                *cmp_err = obj;
                *msg = 9;
                return(0);
	    }
		if(!(suc & 1)) {printf("give struct not success\n"); return 0;}
		strcpy( tag_num,tag_num_st.var.text_st.text_string);
		/*"tag_num = %s\n",tag_num*/	
	}
	if(pipe_flag)
	{
		status = om$send(msg = message NDmacro.ACgive_structure(&suc,
				&AC_index,"pipe_length",&pipe_st, &local_env),
				senderid = NULL_OBJID,
				targetid = obj.objid,
				targetos = obj.osnum);
            if (!(status&1))
	    {
                om$report_error(sts=status);
                *cmp_err = obj;
                *msg = 9;
                return(0);
	    }
		if(!(suc & 1)) {printf("give struct not success\n"); return 0;}
		pipe_length = pipe_st.var.root_pm_st.value;
		/*"pipe_length = %f\n",pipe_length*/	
	}
	else pipe_length = 0.0;
	if(elbow_flag || bend_flag)
	{
		status = om$send(msg = message NDmacro.ACgive_structure(&suc,
				&AC_index,"bend_sweep",&bend_st, &local_env),
				senderid = NULL_OBJID,
				targetid = obj.objid,
				targetos = obj.osnum);
            if (!(status&1))
	    {
                om$report_error(sts=status);
                *cmp_err = obj;
                *msg = 9;
                return(0);
	    }
		if(!(suc & 1))
/*     waiting for bend sweep fix ........ force 90 deg anyway
 {printf("give struct not success\n"); return 0;}
*/
                bend_angle = 90.0;
                else
		bend_angle = bend_st.var.root_pm_st.value;
		/*"bend_angle = %f\n",bend_angle*/	
	}
	else bend_angle = 0.0;

	status = om$send(msg = message ACrg_collect.AClist_attribute(msg, MAX_CACHE_ATTR,
	    cache_attr, &nb_cache_attr),
	    senderid = NULL_OBJID,
	    targetid = model_id.objid,
	    targetos = model_id.osnum);
	if (!(status&1)){ 
		om$report_error(sts=status); 
		*cmp_err = obj;
		*msg = 11;
		return(0);
	}
	/*"nb_cache_att: %d ",nb_cache_attr*/
        for ( i = 0; i < nb_cache_attr; i++)
        {
                /*"cache_attr[%d].name = %s\n",i,cache_attr[i].name */ 
                /*if(cache_attr[i].desc.type == AC_ATTRIB_DOUBLE) */
                        /* cache_attr[%d].desc.value.att_txt = %s\n",i,cache_attr[i].desc.value.att_txt */
                /* else if(cache_attr[i].desc.type == AC_ATTRIB_DOUBLE) */
                        /* cache_attr[%d].desc.value.att_exp = %f\n",i,cache_attr[i].desc.value.att_exp */
	}

	/*  MALLIK  */

	/* 	Should some how identify whether it is for a 
        component or a pipe, or a nozzle, or a support
	Right now the logic is for a component. 
	 */

	j = 0;	
	while((strcmp(VR_N_COMP_NUMCP_IN,cache_attr[j].name)) && (j < nb_cache_attr ))
	{
		j++;
	}
	if( j < nb_cache_attr )
	{
		nb_cp =(int)(cache_attr[j].desc.value.att_exp); 
		/*"nb_cp = %f\0",cache_attr[j].desc.value.att_exp*/
		/*"nb_cp = %d\n",nb_cp*/
	}

	/*| Retrieving units_set */
/*

MALLIK  
	j = 0;	
	while((strcmp("units_set",cache_attr[j].name)) && (j < nb_cache_attr ))
	{
		j++;
	}
	if( j < nb_cache_attr )
	{
		units_set = (int)(cache_attr[j].desc.value.att_exp);
		printf("units_set = %d \n",units_set );
	}
*/

	/*| Checking for Comp_2nd_cp  */

	j = 0;	
	while((strcmp(VR_N_COMP_2ND_CP_IN,cache_attr[j].name)) && (j < nb_cache_attr ))
	{
		j++;
	}
	if( j < nb_cache_attr )
	{
		sprintf(tmp,"%d\0",(int)(cache_attr[j].desc.value.att_exp));
		cp2 = atoi(tmp);
		if(cp2 & 0x0001) first = 1;
		if(cp2 & 0x0002) second = 1;
		if(cp2 & 0x0004) third = 1;
		if(cp2 & 0x0008) fourth = 1;
		if(cp2 & 0x0010) fifth = 1;
	}

	if ( !supp_flag)
	{
	  /*| component is not a support */
	    for( i = 0; i < 61; i++ )
	    {
		/*"list_of_attr[%d] = : %s\n ",i, list_of_attr[i]*/
		/*"attr_from[%d] = : %d\n ",i, attr_from[i]*/
		/*"attr_type[%d] = : %d\n ",i, attr_type[i]*/

		if(attr_type[i] == IS_INT)
			strcpy(tmp,"0");
		else if (attr_type[i] == IS_REAL)
			strcpy(tmp,"0.000000");
		else if (attr_type[i] == IS_ASCI)
			strcpy(tmp,"");
		else if (attr_type[i] == IS_NPD)
			strcpy(tmp,"0");

		j = 0;
		switch (attr_from[i])
		{
		case  DYN:
			while((strcmp(list_of_attr[i],dyn_attr[j].name)) && 
			    (j < nb_dyn_attr ))
				j++;
			/*"list_of_attr[%d] = : %s\t ",i, list_of_attr[i]*/
			/*"dyn_attr[%d].name = %s\n", j, dyn_attr[j].name */

			if( j < nb_dyn_attr)
			{
				if(attr_type[i] == IS_ASCI)
					strcpy(tmp,dyn_attr[j].desc.value.att_txt);
				else if (attr_type[i] == IS_INT)
					sprintf(tmp,"%d\0",(int)(dyn_attr[j].desc.value.att_exp));
				else if(attr_type[i] == IS_REAL)
					sprintf(tmp,"%f\0",dyn_attr[j].desc.value.att_exp);
				else if(attr_type[i] == IS_NPD)
				      if(prj_units_set >=20 && prj_units_set < 30 )
					sprintf(tmp,"%d\0",(int)(dyn_attr[j].desc.value.att_exp));
				      else
					sprintf(tmp,"%d\0",(int)(5000 + dyn_attr[j].desc.value.att_exp * 32.));
			}
			if(!strcmp(list_of_attr[i],"pipe_length"))
				sprintf(tmp,"%f\0",pipe_length);
			if(!strcmp(list_of_attr[i],"bend_sweep"))
				sprintf(tmp,"%f\0",bend_angle);
			strcpy(&buff_attr->row_attr[ligne].attr[index],tmp);

			/*"attribute = %s \n",tmp*/
			/*"attribute = %s \n",&buff_attr->row_attr[ligne].attr[index] */
			size = strlen(tmp) + 1;
			buff_attr->row_attr[ligne].nb_attr = i+1;
			buff_attr->row_attr[ligne].type[i] = attr_type[i];
			buff_attr->row_attr[ligne].length[i] = size;
			index += size;
			break;

		case  CACHE:
			strcpy(string,list_of_attr[i]);
			if((!strcmp(string,"f1")) && pipe_flag)
				strcpy(string,"pod1");
			while((strcmp(string,cache_attr[j].name)) && 
			    (j < nb_cache_attr ))
				j++;
			if((string[0] == 'f') && (j >= nb_cache_attr) && (string[1] >= '0') && (string[1] <= '9'))
			{
				string[0] = 'b';
				j = 0;
				while((strcmp(string,cache_attr[j].name)) && (j < nb_cache_attr ))
				j++;
			}

			/*"list_of_attr[%d] = : %s\t ",i, list_of_attr[i]*/
			/*"cache_attr[%d].name = %s\n", j, cache_attr[j].name */

			if( j < nb_cache_attr )
			{
				if(attr_type[i] == IS_ASCI)
					strcpy(tmp,cache_attr[j].desc.value.att_txt);
				else if (attr_type[i] == IS_INT)
					sprintf(tmp,"%d\0",(int)(cache_attr[j].desc.value.att_exp));
				else if(attr_type[i] == IS_REAL)
					sprintf(tmp,"%f\0",(float)(cache_attr[j].desc.value.att_exp));
				else if(attr_type[i] == IS_NPD)
				      if(prj_units_set >=20 && prj_units_set < 30 )
					sprintf(tmp,"%d\0",(int)(cache_attr[j].desc.value.att_exp));
				      else
					sprintf(tmp,"%d\0",(int)(5000 + cache_attr[j].desc.value.att_exp * 32.));
			}
			if(!strcmp(string,"op_") && (cmp_type == VRP_V_VALVE_TYPE))
				sprintf(tmp,"%s%d\0","op_",modifier);
			if(!strcmp(string,"comp_code"))
				strcpy(tmp,comp_code);
			if(!strcmp(string,"opt_code"))
				sprintf(tmp,"%d\0",optcode);

			strcpy(&buff_attr->row_attr[ligne].attr[index],tmp);
			/*"attribute = %s \n",&buff_attr->row_attr[ligne].attr[index] */
			/*"attribute = %s \n",tmp */
			if(!strcmp(list_of_attr[i],"comp_code"))
				strcpy(red_cp,tmp);
			if(!strcmp(list_of_attr[i],VR_N_MODIFIER_DB))
			{
				modifier = (int)(cache_attr[j].desc.value.att_exp);
				/*"modifier = %d\n",modifier*/
			}

			size = strlen(tmp) + 1;
			buff_attr->row_attr[ligne].nb_attr = i+1;
			buff_attr->row_attr[ligne].type[i] = attr_type[i];
			buff_attr->row_attr[ligne].length[i] = size;
			index += size;

			break;
		case  HARDCODE:
			if(!strcmp(list_of_attr[i],"temp_unit"))
			{
				size = strlen(temp_unit) + 1;
				strcpy(&buff_attr->row_attr[ligne].attr[index],temp_unit);
			} else if(!strcmp(list_of_attr[i],"press_unit"))
			{
				size = strlen(rating_unit) + 1;
				strcpy(&buff_attr->row_attr[ligne].attr[index],rating_unit);
			} else if(!strcmp(list_of_attr[i],"weight_unit"))
			{
				size = strlen(weight_unit) + 1;
				strcpy(&buff_attr->row_attr[ligne].attr[index],weight_unit);
			} else if(!strcmp(list_of_attr[i],"design_code"))
			{
				sprintf(tmp,"%d\0",design_code);
				size = strlen(tmp) + 1;
				strcpy(&buff_attr->row_attr[ligne].attr[index],tmp);
			}
			/*"list_of_attr[%d] = : %s\t ",i, list_of_attr[i]*/
			/*"attribute = %s \n",&buff_attr->row_attr[ligne].attr[index] */

			buff_attr->row_attr[ligne].nb_attr = i+1;
			buff_attr->row_attr[ligne].type[i] = attr_type[i];
			buff_attr->row_attr[ligne].length[i] = size;
			index += size;

			break;
		case  INP:
			if(!strcmp(list_of_attr[i],"cur_occ"))
			{
				sprintf(tmp,"%d\0",cur_occ);
				size = strlen(tmp) + 1;
				strcpy(&buff_attr->row_attr[ligne].attr[index],tmp);
			}
			/*"list_of_attr[%d] = : %s\t ",i, list_of_attr[i]*/
			/*"attribute = %s \n",&buff_attr->row_attr[ligne].attr[index] */
			buff_attr->row_attr[ligne].nb_attr = i+1;
			buff_attr->row_attr[ligne].type[i] = attr_type[i];
			buff_attr->row_attr[ligne].length[i] = size;
			index += size;

			break;
		case  CP_DEP_C:
		case  CP_DEP_D:
			if(( i == 37 && nb_cp >= 2 && second == 1) ||
			    ( i == 43 && nb_cp >= 3 && third  == 1) ||
			    ( i == 49 && nb_cp >= 4 && fourth == 1) ||
			    ( i == 55 && nb_cp >= 5 && fifth  == 1))
			{
				/*|prep_r*/
				strcpy(string,VR_N_PREP_R_IN);
			}
			else
			if(( i == 37 && nb_cp >= 2 && second != 1) ||
			    ( i == 43 && nb_cp >= 3 && third  != 1) ||
			    ( i == 49 && nb_cp >= 4 && fourth != 1) ||
			    ( i == 55 && nb_cp >= 5 && fifth  != 1))
			{
			/*|prep_g*/
				strcpy(string,VR_N_PREP_G_IN);
			}
			else
			if(( i == 38 && nb_cp >= 2 && second == 1) ||
			    ( i == 44 && nb_cp >= 3 && third  == 1) ||
			    ( i == 50 && nb_cp >= 4 && fourth == 1) ||
			    ( i == 56 && nb_cp >= 5 && fifth  == 1))
			{
				strcpy(string,VR_N_RATING_R_DB);
			}
			else
			if(( i == 38 && nb_cp >= 2 && second != 1) ||
			    ( i == 44 && nb_cp >= 3 && third  != 1) ||
			    ( i == 50 && nb_cp >= 4 && fourth != 1) ||
			    ( i == 56 && nb_cp >= 5 && fifth  != 1))
			{
				strcpy(string,VR_N_RATING_G_DB);
			}
			else
			if(((( (i == 39) && (nb_cp >=2)) && (second==1)) ||
			    (( (i == 45) && (nb_cp >= 3)) && (third ==1))) ||
			    ((( (i == 51) && (nb_cp >= 4)) && (fourth==1)) ||
			    (( (i == 57) && (nb_cp >= 5)) && (fifth  ==1))))
			{
				strcpy(string,VR_N_RDIAMETER_DB);
			}
			else
			if(((( (i == 39) && (nb_cp >= 2)) && (second != 1)) ||
			    (( (i == 45) && (nb_cp >= 3)) && (third  != 1)))||
			    ((( (i == 51) && (nb_cp >= 4)) && (fourth != 1))||
			    (( (i == 57) && (nb_cp >= 5)) && (fifth  != 1))))
			{
				strcpy(string,VR_N_GDIAMETER_DB);
			}
			else
			if(( i == 41 && nb_cp >= 2 && second == 1) ||
			    ( i == 47 && nb_cp >= 3 && third  == 1) ||
			    ( i == 53 && nb_cp >= 4 && fourth == 1) ||
			    ( i == 59 && nb_cp >= 5 && fifth  == 1))
			{
				strcpy(string,VR_N_SCH_THK_R_AN);
			}
			else
			if(( i == 41 && nb_cp >= 2 && second != 1) ||
			    ( i == 47 && nb_cp >= 3 && third  != 1) ||
			    ( i == 53 && nb_cp >= 4 && fourth != 1) ||
			    ( i == 59 && nb_cp >= 5 && fifth  != 1))
			{
				strcpy(string,VR_N_SCH_THK_G_AN);
			}
			else
			if(( i == 42 && nb_cp >= 2 && second == 1) ||
			    ( i == 48 && nb_cp >= 3 && third  == 1) ||
			    ( i == 54 && nb_cp >= 4 && fourth == 1) ||
			    ( i == 60 && nb_cp >= 5 && fifth  == 1))
			{
				strcpy(string,VR_N_THK_R_DB);
			}
			else
				if(( i == 42 && nb_cp >= 2 && second != 1) ||
				    ( i == 48 && nb_cp >= 3 && third  != 1) ||
				    ( i == 54 && nb_cp >= 4 && fourth != 1) ||
				    ( i == 60 && nb_cp >= 5 && fifth  != 1))
				{
					strcpy(string,VR_N_THK_G_DB);
				}
				else
				{
					if(attr_type[i] == IS_ASCI)
						strcpy(tmp,"");
					else if(attr_type[i] == IS_INT)
						sprintf(tmp,"0\0");
					else if(attr_type[i] == IS_REAL)
						sprintf(tmp,"0.0000\0");
					else if(attr_type[i] == IS_NPD)
						sprintf(tmp,"0\0");

					strcpy(&buff_attr->row_attr[ligne].attr[index],tmp);

			/*| This is the ELSE case	*/
			/*"list_of_attr[%d] = : %s\t ",i,list_of_attr[i]*/
					/*"attribute = %s \n",&buff_attr->row_attr[ligne].attr[index] */

					size = strlen(tmp) + 1;
					buff_attr->row_attr[ligne].nb_attr = i+1;
					buff_attr->row_attr[ligne].type[i] = attr_type[i];
					buff_attr->row_attr[ligne].length[i] = size;
					index += size;

					break;
				}
			if( attr_from[i] == CP_DEP_C )
			{
			while((strcmp(string,cache_attr[j].name)) && (j < nb_cache_attr ))
				j++;
			    if( j < nb_cache_attr )
			    {
				if(attr_type[i] == IS_ASCI)
					strcpy(tmp,cache_attr[j].desc.value.att_txt);
				else if (attr_type[i] == IS_INT)
					sprintf(tmp,"%d\0",(int)(cache_attr[j].desc.value.att_exp));
				else if(attr_type[i] == IS_REAL)
					sprintf(tmp,"%f\0",cache_attr[j].desc.value.att_exp);
				else if(attr_type[i] == IS_NPD)
				      if(prj_units_set >=20 && prj_units_set < 30 )
					sprintf(tmp,"%d\0",(int)(cache_attr[j].desc.value.att_exp));
				      else
					sprintf(tmp,"%d\0",(int)(5000 + cache_attr[j].desc.value.att_exp * 32.));
			    }
			}
			if( attr_from[i] == CP_DEP_D )
			{
			while((strcmp(string,dyn_attr[j].name)) && (j < nb_dyn_attr ))
				j++;
			    if( j < nb_dyn_attr )
			    {
				if(attr_type[i] == IS_ASCI)
					strcpy(tmp,dyn_attr[j].desc.value.att_txt);
				else if (attr_type[i] == IS_INT)
					sprintf(tmp,"%d\0",(int)(dyn_attr[j].desc.value.att_exp));
				else if(attr_type[i] == IS_REAL)
					sprintf(tmp,"%f\0",dyn_attr[j].desc.value.att_exp);
				else if(attr_type[i] == IS_NPD)
				      if(prj_units_set >=20 && prj_units_set < 30 )
					sprintf(tmp,"%d\0",(int)(dyn_attr[j].desc.value.att_exp));
				      else
					sprintf(tmp,"%d\0",(int)(5000 + dyn_attr[j].desc.value.att_exp * 32.));
			    }
			}
			strcpy(&buff_attr->row_attr[ligne].attr[index],tmp);

			/*"list_of_attr[%d] = : %s\t ",i, string*/
			/*"attribute = %s \n",&buff_attr->row_attr[ligne].attr[index] */

			size = strlen(tmp) + 1;
			buff_attr->row_attr[ligne].nb_attr = i+1;
			buff_attr->row_attr[ligne].type[i] = attr_type[i];
			buff_attr->row_attr[ligne].length[i] = size;
			index += size;

			break;
		default: 
			break;
		}
	    }
	}
	if(supp_flag)
	{
	/*| Component is a support */
		for( i = 0; i < 27; i++ )
		{
			if(attr_type[i] == IS_INT)
				strcpy(tmp,"0");
			else if(attr_type[i] == IS_REAL)
				strcpy(tmp,"0.0000");
			else if(attr_type[i] == IS_ASCI)
				strcpy(tmp,"");
			else if(attr_type[i] == IS_NPD)
				strcpy(tmp,"0");

			j = 0;

			strcpy(string,list_of_attr[i]);

			while((strcmp(string,dyn_attr[j].name))&& (j < nb_dyn_attr))
				j++;
	
       		        if( j < nb_dyn_attr)
       		        {
       		        	if(attr_type[i] == IS_ASCI)
       	       		        	strcpy(tmp,dyn_attr[j].desc.value.att_txt);
               		         else if (attr_type[i] == IS_INT)
               		                sprintf(tmp,"%d\0",(int)(dyn_attr[j].desc.value.att_exp));
               		         else if(attr_type[i] == IS_REAL)
               	                 	sprintf(tmp,"%f\0",dyn_attr[j].desc.value.att_exp);
			}

			switch(i) {
			case	1: 	strcpy(tmp,"2");
					break; 
			case	2: 	strcpy(tmp,"1");
					break; 
			case	7: 	strcpy(tmp,temp_unit);
					break; 
			case	8: 	strcpy(tmp,rating_unit);
					break; 
			case	14:	strcpy(tmp,weight_unit);
					break;
			case	15:	sprintf(tmp,"%d\0",cur_occ);
					break;
			case	10: 	
			case	22:	strcpy(tmp,"0.000000");
					break; 
			case	11:
			case	13:
			case	16:
			case	17:
			case	18:
			case	21:	strcpy(tmp,"_ND");
					break;
			case	19:
			case	20:	strcpy(tmp,"0");
					break;
			case	23:	strcpy(tmp,tag_num);
					break;
			case	24:	strcpy(tmp,detail_num);
					break;
			case	25:	sprintf(tmp,"%d\0",supp_type);
					break;
			case	26:	strcpy(tmp,"SUPP");
					break;
			default:
					break;
			}

			size = strlen(tmp) + 1;
			strcpy(&buff_attr->row_attr[ligne].attr[index],tmp);
			buff_attr->row_attr[ligne].nb_attr = i+1;
			buff_attr->row_attr[ligne].type[i] = attr_type[i];
			buff_attr->row_attr[ligne].length[i] = size;
			index += size;
			/*"tmp = %s \n",tmp */
		}
		buff_attr->row_attr[ligne].nb_attr = -buff_attr->row_attr[ligne].nb_attr;
	}
	/*"nb lines: %d \n",buff_attr->nb_buff*/

	buff_attr->nb_buff +=1;
	*msg = MSSUCC;
	return 1;
}

/*********************************************************************
 *
 *  print the attributes in a output file 
 *
 * Modif to put @ as the separate character.
 *********************************************************************/

print_buff_attr(file_name, buff_attr)
char		 *file_name;
struct buff_attr *buff_attr;
/*.print_buff_attr*/
{
	FILE 	*pf;
	int 	 i, k, index, iptr;
	char   buffer[MAX_SIZE_LINE];

	pf = (FILE *) fopen(file_name,"w");   /* Warning at compile time !!!! */
	/*"file: %s ouvert, nb lines: %d \n",file_name,buff_attr->nb_buff*/
	for (i=0;i<buff_attr->nb_buff;i++)
	{
		index = 0;
		sprintf(buffer,"%d",buff_attr->row_attr[i].nb_attr);
		iptr = strlen(buffer);
		if (buff_attr->row_attr[i].nb_attr<0)
		{
			buff_attr->row_attr[i].nb_attr = -buff_attr->row_attr[i].nb_attr;
			/*"nb_attr>0: %d\n",buff_attr->row_attr[i].nb_attr*/
		}
		for(k=0;k<buff_attr->row_attr[i].nb_attr;k++)
		{
			sprintf(&buffer[iptr],"@%s",&buff_attr->row_attr[i].attr[index]);
			index = index + buff_attr->row_attr[i].length[k];
			iptr = iptr + strlen(&buffer[iptr]);
		}
		/*"i: %d, buffer: %s \n",i,buffer */
		fprintf(pf,"%s",buffer);
		fprintf(pf,"\n");
	}

	fflush(pf);
	fclose(pf);
	/*| exit print_attr */
	return 1;
}

/**********************************************************************
 *
 *  buff_attr_init:
 *
 **********************************************************************/

buff_attr_init( buff_attr, nb_lines)
struct buff_attr *buff_attr; 	/* structure to allocate 	*/
int		   nb_lines;	/* number of lines to allocate  */
/*.buff_attr_init*/
{
	buff_attr->row_attr = NULL;   /* used to test at deallocation time */
	buff_attr->nb_buff  = 0;
	if(nb_lines <= 0) return 1;

	/*"allocation de buff_attr of: %d\n", nb_lines*/

	buff_attr->row_attr = _MALLOC (nb_lines, struct row_attr);

	if(buff_attr->row_attr == NULL)
	{
		printf("Dynamique allocation failed\n");
		return 0;
	}
	/*|after allocation\n*/
	return 1;
}


/**********************************************************************
 *
 *  buff_attr_dealloc:
 *
 **********************************************************************/

buff_attr_dealloc(buff_attr)
struct buff_attr *buff_attr; 	/* structure to deallocate 	*/
/*.buff_attr_dealloc*/
{
	if( buff_attr->row_attr == NULL) return 1;

	_FREE (buff_attr->row_attr);

	return 1;
}

end implementation Root;
