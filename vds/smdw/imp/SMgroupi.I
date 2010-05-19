/* $Id: SMgroupi.I,v 1.1.1.1 2001/01/04 21:07:34 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smdw/imp / SMgroupi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMgroupi.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:34  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1996/04/29  08:57:54  pinnacle
# Replaced: smdw/imp/SMgroupi.I for:  by ksundar for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.2  1994/11/11  22:16:02  pinnacle
# Replaced:  smdw/imp/*.I r#
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
/*  History :
/*	CH  : 1 June 92  creation date.
/*
/* */

class implementation SMgroup;

#include "OMmacros.h"
#include "OMprimitives.h"

#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "nddef.h"
#include "asbox.h"
#include "madef.h"

#include "ACrg_collect.h"

#include "grerr.h"
#include "vds.h"
#include "VDmsg.h"
#include "SMmsg.h"
#include "VDmem.h"

#include "AS_status.h"

#define AS_DEBUG

/* ******************* MSG  SMFillSfFile() ************************	*/

method SMFillSfFile(IGRlong *msg; FILE *p_file; IGRshort options; IGRboolean tag;
		    IGRshort out_units; struct GRmdenv_info *obj_env, *trans_env)

{
 IGRlong 		status, loc_msg;
 IGRchar		name[DI_PATH_MAX], desc[81];
 IGRint			i, k, /* ref_no, */ nb_sub_grp, nb_sub_info, found;
 /* IGRdouble		dpipo; */
 IGRchar		*sub_grp_list[SM_MAX_SUB_GRP], p_grp[DI_PATH_MAX*SM_MAX_SUB_GRP];
 struct GRid		my_grid;
 struct ACrg_coll	att[SM_MAX_SUB_GRP_ATT];
 *msg = MSFAIL;

 my_grid.objid = my_id;
 my_grid.osnum = OM_Gw_current_OS;

 if(tag == TRUE)
  {
   printf("Use a tagged method, not yet implemented\n");
   return OM_W_ABORT;
  }
   
 /* Get the sub group list */
 for(i=0;i<SM_MAX_SUB_GRP;i++) sub_grp_list[i] = &p_grp[i * DI_PATH_MAX];

 status = om$send(msg = message SMgroup.SMGetSbGrp(&loc_msg, SM_MAX_SUB_GRP,
                               &nb_sub_grp, sub_grp_list),
			targetid = my_id);
 if(!(status &1) || loc_msg != MSSUCC) return OM_W_ABORT;

 if(options & SM_PRT_SUB_GRP)
  {
   /* Printf the sub group */

   for(i=0;i<nb_sub_grp;i++) 
    {
     status = om$send(msg = message SMgroup.SMGetSbInfo(&loc_msg, sub_grp_list[i],
                       SM_MAX_SUB_GRP_ATT, &nb_sub_info, att, 0),
			targetid = my_id);
     if(!(status &1) || loc_msg != MSSUCC) return OM_W_ABORT;

     /* Get ref_number & description */
     found = 0;
     for(k=0;k<nb_sub_info;k++)
      {
       /* if(strncmp(att[k].name, "ref_number", 10) == 0) */
       /*  { */
	/*  if(att[k].desc.type != AC_ATTRIB_DOUBLE)  */
	 /*  { */
	 /*   printf("Bad ref number type for sub group: %s\n", sub_grp_list[i]);  */
	 /*   ref_no =  -1; */
	 /*  } */
	 /* else ref_no = (int) att[k].desc.value.att_exp; */
	 /* if(found==1) break; */
	 /* found++; */
	 /* continue; */
	/* } */
       if(strncmp(att[k].name, "description", 11) == 0) 
        {
	 if(att[k].desc.type != AC_ATTRIB_TEXT) 
	  {
	   printf("Bad ref number type for sub group: %s\n", sub_grp_list[i]);
	   strcpy(desc,"no description");
	  }
	 else strcpy(desc, att[k].desc.value.att_txt);
	 desc[16] = '\0';
	 break;
	 /* if(found==1) break; */
	 /* found++; */
	}
      }

     if(options & SM_ASCII_FILE)
      {
       /* Use an ascii file */
       if(options & SM_SF_SHORT_EXT)
        {
         /* Old object */
         fprintf(p_file, "SUB_GRP \"%s\"\n", sub_grp_list[i]);
         fprintf(p_file, "\n");
        }
       else
        {
         /* fprintf(p_file, "SUB_GRP \"%s\" %d \"%s\"\n", sub_grp_list[i], ref_no, desc); */
         fprintf(p_file, "SUB_GRP \"%s\" \"%s\"\n", sub_grp_list[i], desc);
         fprintf(p_file, "\n");
	}
      }
     else
      {
       /* It is a binary file */
       printf("Binary file not yet implemented\n");
       return 0;
      }
    }
  }
 else
  {
   /* Print the group */

   /* Get the name */
   status = om$send(msg = message SMmgr.SMGetShortName(&loc_msg, name),
                targetid = my_id);
   if(!(status &1) || loc_msg != MSSUCC)
    {
     /* No name !!! */
     return(OM_W_ABORT);
    }
   
   /* Get the interesting values */
   /* if(VDSGetAttDbl(&my_grid, "ref_number", &dpipo) == 0) */
   /* { */
   /*  printf("Error no reference number for dead weight: %s\n", name); */
   /*  return OM_W_ABORT; */
   /* } */
   /* ref_no = (int) dpipo; */

   if(VDSGetAttTxt(&my_grid, "description", desc) == 0)
    {
     desc[0] = '\0';
    }
   /* Seasafe description limited to 16 characteres */
   desc[16] = '\0';
   
   if(options & SM_ASCII_FILE)
    {
     /* Use an ascii file */
     if(options & SM_SF_SHORT_EXT)
      {
       fprintf(p_file, "GRP \"%s\"\n", name);
       fprintf(p_file, "\n");
      }
     else
      {
       /* fprintf(p_file, "GRP \"%s\" %d \"%s\"", name, ref_no, desc); */
       fprintf(p_file, "GRP \"%s\" \"%s\"", name, desc);
       for(i=0;i<nb_sub_grp;i++)  fprintf(p_file," \"%s\"",sub_grp_list[i]);
       fprintf(p_file, "\n");
       fprintf(p_file, "\n");
      }
    }
   else
    {
     /* It is a binary file */
     printf("Binary file not yet implemented\n");
     return 0;
    }
  }

 *msg = MSSUCC;
 return(OM_S_SUCCESS);
}

/* ******************* MSG  SMFillRpFile() ************************	*/

method SMFillRpFile(IGRlong *msg; IGRchar *DescFile; FILE *p_file;
                    IGRshort options; IGRboolean tag; IGRshort out_units;
                    struct GRmdenv_info *obj_env, *trans_env)
{
 printf("Not yet implemented\n");
 return(OM_W_ABORT);
}


/* ******************* MSG  SMGetAtt() ************************	*/

method SMGetAtt(IGRlong *msg; IGRint nb_att; struct ACrg_coll *att; IGRshort *type)
{
 IGRlong 	status, loc_msg;
 IGRint		i;

 *msg = MSFAIL;

 for(i=0; i<nb_att; i++)
  {
   status = om$send(msg = message ACrg_collect.ACget_named_attribute(&loc_msg, 
				&att[i]),
		targetid = my_id);
   as$status(action = RET_STATUS);
   if(!(loc_msg&1))
    {
     /* Attribute not found */
     return OM_S_SUCCESS;
    }

   if(type != NULL) type[i] = SM_SYST_ATT | SM_STATIC_ATT;
  }
 
 *msg   = MSSUCC;
 return OM_S_SUCCESS;
}

/* ******************* MSG  SMSetAtt() ************************	*/

method SMSetAtt(IGRlong *msg; IGRint nb_att; struct ACrg_coll *att; IGRshort *type)
{
 IGRlong 		status, loc_msg;
 
 *msg = MSFAIL;

 status = om$send(msg = message ACrg_collect.ACmod_list_attribute(&loc_msg, 
				nb_att, att),
		targetid = my_id);
 as$status(action = RET_STATUS);
 if(loc_msg != 1)
  {
   /* At least one attribute was not existing or with a wrong type */
   return OM_S_SUCCESS;
  }

 *msg = MSSUCC;
 return OM_S_SUCCESS;
}



/* ******************* MSG  SMGetAttType() ************************	*/

method SMGetAttType(IGRlong *msg; IGRshort type; IGRint *nb_att; struct ACrg_coll **att)
{
 IGRlong 		status, loc_msg;
 struct ACrg_coll 	*loc_att;
 IGRint			i, nb;

 *msg    = MSFAIL;
 *nb_att = 0;

 nb = 0;
 status = om$send(msg = message ACrg_collect.AClist_attribute(&loc_msg, 0, 
 				NULL, &nb),
		targetid = my_id);
 as$status(action = RET_STATUS);

 if(nb <=0) return OM_S_SUCCESS;

 loc_att = _MALLOC(nb, struct ACrg_coll);
 if(loc_att == NULL)
  {
   /* Bad allocation */
   return OM_W_ABORT;
  }
  
 status = om$send(msg = message ACrg_collect.AClist_attribute(&loc_msg, nb, 
 				loc_att, &nb),
		targetid = my_id);
 as$status(action = RET_STATUS);
 
 for(i=0; i<nb; i++) if(loc_att[i].desc.type & type) *nb_att++;

 if(*nb_att <= 0) return OM_S_SUCCESS;

 *att = _MALLOC( *nb_att, struct ACrg_coll);
 if(*att == NULL)
  {
   /* Bad allocation */
   *nb_att = 0;
   return OM_W_ABORT;
  }
 
 if(att != NULL)
  {
   *nb_att = 0;
   for(i=0; i<nb; i++) if(loc_att[i].desc.type & type) (*att)[*nb_att] = loc_att[i];
   *nb_att = *nb_att + 1;
  }

 _FREE(loc_att);
 
 *msg = MSSUCC;
 return OM_S_SUCCESS;
}


/* ******************* MSG  SMAddAtt() ************************	*/

method SMAddAtt(IGRlong *msg; IGRint nb_att; struct ACrg_coll *att; 
		IGRshort *type)
{
 IGRlong 	status, loc_msg;

 *msg = MSFAIL;

 status = om$send(msg = message ACrg_collect.ACadd_list_attribute(
						&loc_msg,
						nb_att,
						att),
			targetid = my_id);
 if(loc_msg&1) *msg = MSSUCC;
 return status;
}


/* ******************* MSG SMWhoAreYou() ************************	*/

method SMWhoAreYou(	IGRlong *msg; 	/* (O) completion code */
			IGRshort *type;  /* (O) type of the object */
			IGRshort *sub_type) /* (O) sub_type of the object */
{
 if(type != NULL) 	*type     = SM_GRP | SM_SUB_GRP;
 if(sub_type != NULL) 	*sub_type = 0xffff;

 *msg = MSSUCC;
 return OM_S_SUCCESS;
}

/* *********************** MSG GRgetobjinfo() ************************	*/

method GRgetobjinfo( IGRlong *rc; struct GRobj_info *info )

{
 strcpy(info->type, "Group");

 *rc = MSSUCC;
 return	OM_S_SUCCESS;
}


/* *********************** MSG GRGetSbGrp() ************************	*/

method SMGetSbGrp(IGRlong *msg; IGRint SizeList, *NbSubGroup; IGRchar *names[])
{
 IGRlong		loc_msg, status;
 struct ACrg_coll 	attrib;
 IGRint			index, i;

 *msg        = MSFAIL;
 *NbSubGroup = 0;
 index	     = 0;

 for(i=0;i<SM_MAX_SUB_GRP;i++)
  {
   sprintf(attrib.name,"%d_name",i+1);
   status = om$send(msg = message ACrg_collect.ACget_named_attribute(&loc_msg, &attrib),
			targetid = my_id);
   as$status(action = RET_STATUS);
   if(!(loc_msg&1)) break;

   /* A sub group is found */
   if(names != NULL && index < SizeList) strcpy(names[index++], attrib.desc.value.att_txt);
   (*NbSubGroup)++;
  } 

 *msg = MSSUCC;
 return	OM_S_SUCCESS;
}


/* *********************** MSG SMGetSbGrp() ************************	*/

method SMGetSbInfo(IGRlong *msg; IGRchar *SubGrpName; IGRint SizeList, *NbAtt;
		   struct ACrg_coll *att; IGRshort type)
{
 IGRlong		loc_msg, status;
 struct ACrg_coll 	attrib[SM_MAX_GRP_ATT];
 IGRint			nb_attr, len, i, k, index;
 IGRchar		*ptr, *strchr();

 *msg   = MSFAIL;
 *NbAtt = 0;
 index	= 0;


 /* This is made to take into account that some user attributes can be added */
 /* (I'm not sure that it is a good implementation) */

 /* Get all the attributes */
 status = om$send(msg = message ACrg_collect.AClist_attribute(&loc_msg, SM_MAX_GRP_ATT,
                                			attrib, &nb_attr),
			targetid = my_id);
 as$status(action = RET_STATUS);
 if(!(loc_msg&1)) return OM_W_ABORT;

 for(i=0;i<SM_MAX_GRP_ATT && i<nb_attr;i++)
  {
   if(strcmp(SubGrpName, attrib[i].desc.value.att_txt) == 0)
    {
     /* Sub group found, extract the prefix (1_name => 1_) */
     ptr = strchr(attrib[i].name,'_');
     if(ptr == NULL) return OM_W_ABORT;
     ptr[1] = '\0';
     len = strlen(attrib[i].name);

     for(k=i+1;k<SM_MAX_GRP_ATT && k<nb_attr;k++)
      {
       if(strncmp(attrib[k].name, attrib[i].name, len) == 0)
        {
	 /* Attribute found */
	 if(index < SizeList) 
	   {
	    /* Take off the prefix */
	    strcpy(att[index].name, &attrib[k].name[len]);
	    att[index++].desc = attrib[k].desc;
	   }
	 (*NbAtt)++;
	 continue;
	}
      }
     break;
    } 
  } 

 *msg = MSSUCC;
 return	OM_S_SUCCESS;
}

/* *********************** MSG (SMGetSgrpId) ************************	*/


method SMGetSgrpId(IGRlong *msg; IGRchar *SubGrpName; struct GRid *foot; 
	    IGRshort *mat_type; IGRdouble *mat)
{
 IGRlong 	sts, loc_msg;
 IGRint		nb_sgroups, i, j;
 IGRchar	tmp_char[81], sgroup_name[81];
 IGRshort	type, mat_type2;
 IGRdouble	mat2[16];
 struct GRid	tmp_id;

 *msg = MSFAIL;
 if(foot) foot->objid = NULL_OBJID;


 /* Retrieve the number of sub groups */
 sts = om$send(msg = message SMgroup.SMGetSbGrp(&loc_msg, 0, &nb_sgroups, NULL),
 				targetid = my_id);
 if(!(sts & loc_msg &1))
  {
   printf("Error Getting number of sub group\n");
   return OM_W_ABORT;
  }
  
 if(nb_sgroups == 0) return OM_S_SUCCESS;

 for(i=0;i<nb_sgroups;i=i+1)
  {
   sprintf(tmp_char,"%d_name",i+1);
   sts = om$send(msg = message SMgroup.SMGetAttTxt(&loc_msg, tmp_char, 
   						   sgroup_name, &type), 
 				targetid = my_id);
   if(!(sts & loc_msg &1))
    {
     printf("Error Getting sub group name (index: %d\n",i);
     continue;
    }

   if(strcmp(SubGrpName, sgroup_name) == 0)
    {
     /* Sub group found, make a pretend on the foot */
     sts = om$send(msg = message NDmacro.ACreturn_foot(&loc_msg, tmp_char, 
        					&tmp_id, &mat_type2, mat2),
 				targetid = my_id);
     if(!(sts & loc_msg &1))
      {
       printf("Error Getting sub group object (index: %d\n",i);
       return OM_W_ABORT;
      }
     /* We have all the info ... */
     if(foot) 			*foot     = tmp_id;
     if(mat_type) 		*mat_type = mat_type2;
     if(mat) for(j=0;j<16;j++) 	mat[j]    = mat2[j];
 
     *msg = MSSUCC;
     return OM_S_SUCCESS;
    }
  } 
 
 return OM_S_SUCCESS;
}
  

end implementation SMgroup;
 

