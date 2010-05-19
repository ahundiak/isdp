/* $Id: SMreportsi.I,v 1.1.1.1 2001/01/04 21:07:36 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smreports/imp / SMreportsi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMreportsi.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:36  cvs
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
# Revision 1.2  1996/04/29  09:02:32  pinnacle
# Replaced: smreports/imp/SMreportsi.I for:  by ksundar for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
/*  History :
/*	CH  : 09 Sept 92	  creation date.
/*
/* */

class implementation SMreports;

#include "OMmacros.h"
#include "OMprimitives.h"

#include "string.h"
#include "exmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "acrepdef.h"
#include "acrepmacros.h"
#include "asbox.h"
#include "emsmass.h"

#include "EC_I.h"
#include "EMSmsgdef.h"
#include "emssfintdef.h"

#include "VDSpathdef.h"
#include "VDSudp_mac.h"
#include "VDSutil_def.h" 
#include "vdsmacros.h"

#include "grerr.h"
#include "vds.h"
#include "VDmsg.h"
#include "SMmsg.h"

#include "SMcomp_def.h"
#include "SMReports.h"
#include "VDmem.h"

#include "AS_status.h"

from    expression      import  create,NDgive_value;
from    VDSpt           import VDsettext;  
          
extern GRclassid    OPP_expression_class_id, OPP_SMreports_class_id;
extern GRclassid    OPP_EMSsolid_class_id, OPP_EMSsurface_class_id;

#define AS_DEBUG

/* ******************* MSG SMWhoAreYou() ************************	*/
method SMWhoAreYou(IGRlong *msg; IGRshort *type, *sub_type)
{
 if(*sub_type != NULL) *sub_type = 0xFFFF;;
 if(type != NULL)      *type     = SM_RPT;

 *msg = MSSUCC;
 return OM_S_SUCCESS;
}

/* ****************** MSG ACmplace_from_def () ************************	*/

method ACmplace_from_def(int *rc, prop; 	char rep;char *macro_name;
		 int num_temp;	struct GRid *temp_list;
		 struct GRid *def_occ;
		 struct GRmd_env *md_env )

{
  IGRlong status;

  /* Put the properties to no protect:                              */
  /*	- Does not create source,                                    */
  /*	- Does not verify the number (variable number of templates)  */
  /*	- Does not verify the template types                         */

  prop = prop | AChdr_noprotect | ACcant_place_sym;
  status = om$send(msg = message ACncpx.ACmplace_from_def
		   (rc, prop, rep, 
		    macro_name, num_temp, temp_list, def_occ, md_env),
		   mode     = OM_e_wrt_message,
		   targetid = my_id );
  as$status(action = RET_STATUS);

  /* Create as a new one */
  status = om$send(msg = message SMmgr.SMSetState(SM_NEW),
		   targetid = my_id );
  as$status(action = RET_STATUS);

  return	OM_S_SUCCESS;
}


/* *********************** MSG GRgetobjinfo () ************************	*/

method GRgetobjinfo( IGRlong *rc; struct GRobj_info *info )
{
  strcpy(info->type, "REPORT");

  *rc = MSSUCC;
  return	OM_S_SUCCESS;
}

 /* ********************* MSG NDparent_deleted () *******************	*/

method NDparent_deleted( IGRlong *msg;
			IGRint count_deleted; struct GRid list_deleted [];
			struct GRid *new_obj;struct GRmd_env *md_env)
{
  IGRlong 	status;
  struct GRid  	my_grid;
  IGRint		i;
  IGRchar 	my_state;
  IGRint         cn_type;
  
  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;
  
  status = om$send(msg = message NDnode.NDget_state(&my_state),
		   targetid = my_id);
  if((status&1) && my_state&ND_DONT_MVRT)
   {
     /* Object to delete if no root */
     status = om$send(msg = message ACncpx.NDparent_deleted
		      (msg, count_deleted,list_deleted, new_obj, md_env),
		      targetid = my_id,
		      mode = OM_e_wrt_message);
     return(status);
   }
  
  
  /* Just disconnect the delited roots */
  /* SHOULD VERIFY THE NUMBER OF SURFACES */
  /* DELETE THE OBJECTS IF NO LONGER SURFACES */
  /* CLEAN OR REMOVE THE UNACESSARY EXPRESSION */
  
  for(i=0;i<count_deleted;i++)
   {
     /* Just disconnect the object and the Rg collection */
     status = om$send(msg = message NDnode.NDdisconnect(1,&list_deleted[i]),
		      targetid = my_id);
     as$status(action = RET_STATUS);
   }
  
  /* Put it in the bacth queue for recomputation */
  cn_type = ND_COMP;
  nd$wait_batch(  type 	    = GR_GEOM_POSTED,
		l_object   = &my_grid,
		l_obj_info = &cn_type,
		nb_obj     = 1);
  
  *msg = MSSUCC;
  return OM_S_SUCCESS;
}

 /* ********************* MSG SMRptClean() *******************	*/

method SMRptClean(IGRlong *msg)
{
  IGRlong                status;
  struct GRid 		*roots, *rts = NULL;
  IGRint		 nb_roots, i;
  struct SMrpt           *Info;
  IGRboolean              IsExpression;
  
  *msg = MSFAIL;
  
  /* Get the information for each surface/volume */
  status = om$send(msg = message NDnode.NDget_objects
		   (ND_ROOT|ND_IN_BUF, NULL, 0,
		    &roots, 1, OM_K_MAXINT, &nb_roots),
		   targetid = my_id);
  as$status(action = RET_STATUS);
  
  nb_roots -= 1; /* Start at one */
  if(nb_roots < 1) {*msg = MSSUCC; return OM_S_SUCCESS; } /* Nothing to clean*/
  
  /* must copy into a local structure and free afterwards (recursion) */
  rts = _MALLOC(nb_roots, struct GRid);
  if(rts == NULL) 
   {
     printf("SMFillRpFile, bad dynamic memory allocation\n");
     return OM_W_ABORT;
   }
  for(i=0;i<nb_roots;i++) rts[i] = roots[i];
  
  if(SMFillRpt(nb_roots, rts, SM_RPT_OBJ_LIGHT, &Info) != 1)
   {
     printf("SMRptClean: Error in SMFillRpt\n");
     goto wrapup;
   }
  
  /* Deconnect expression only when follow by another expression */
  IsExpression = FALSE;
  for(i=0;i<nb_roots;i++)
   {
     if(Info[i].type == SM_RP_SF || Info[i].type == SM_RP_SL ||
	Info[i].type == SM_RP_RP)
       {
	 IsExpression = FALSE;
	 continue;
       }
     else if(Info[i].type == SM_RP_VM)
      {
	/* Test if preceding was an expression : if so disconnect */
	/* preceding object */
	if(IsExpression)
	 {
	   status = om$send(msg = message NDnode.NDdisconnect(1, &rts[i - 1]),
		      targetid = my_id);
	   as$status(action = GOTO_VALUE,value = wrapup);
	 }
	/* If last template is an expression, disconnect it too because it's */
	/* not an expression for a density of a surface/volume */
	if(i == nb_roots - 1)
	 {
	   status = om$send(msg = message NDnode.NDdisconnect(1, &rts[i]),
			    targetid = my_id);
	   as$status(action = GOTO_VALUE,value = wrapup);
	 }
	IsExpression = TRUE;
      } 
   }
 
  _FREE(Info) ;
  _FREE(rts) ;
  *msg = MSSUCC;
  return OM_S_SUCCESS;


 wrapup:
  _FREE(Info) ;
  _FREE(rts) ;
  *msg = MSFAIL;
  return OM_S_SUCCESS;
}

/* ********************* MSG SMRptAddObj() *******************	*/

method SMRptAddObj(IGRlong *msg; IGRdouble VolMass;
		   IGRshort type; struct GRid *obj)
{
  IGRlong                 status;
  struct GRid 		*roots, *rts = NULL;
  struct GRid  	         original, ObjCon[3];
  IGRint			 nb_roots, i, k;
  struct SMrpt           *Info = NULL;
  IGRdouble               CurVolMass;
  IGRchar                 tmp[81];
  IGRshort                rc2;
  
  *msg = MSFAIL;
  original.objid = NULL_OBJID;
  
  if(type == SM_RP_RP)
   {
     /* Just add it */
     status = om$send(msg = message NDnode.NDconnect(1, obj, original, ND_ADD),
		      targetid = my_id);
     if(!(status & 1)) return OM_W_ABORT;
     *msg = MSSUCC;
     return OM_S_SUCCESS;
   }
  
  /* Look for the active expression */
  
  /* Get the information for each surface/volume */
  status = om$send(msg = message NDnode.NDget_objects
		   (ND_ROOT|ND_IN_BUF, NULL, 0,
		    &roots, 1, OM_K_MAXINT, &nb_roots),
		   targetid = my_id);
  as$status(action = RET_STATUS);
  
  CurVolMass   = -1;
  
  nb_roots -= 1; /* Start at one */
  
  /* Verify that the object to add is not already defined */
  for(i=0;i<nb_roots;i++) 
   {
     if(obj->objid == roots[i].objid && obj->osnum == roots[i].osnum)
      {
	/* Already a root */
	return OM_S_SUCCESS;
      }
   }
  
  if(nb_roots > 0)
   {
     /* must copy into a local structure and free afterwards (recursion) */
     rts = _MALLOC(nb_roots, struct GRid);
     if(rts == NULL) 
      {
	printf("SMFillRpFile, bad dynamic memory allocation\n");
	return OM_W_ABORT;
      }
     
     for(i=0;i<nb_roots;i++) rts[i] = roots[i];
     
     if(SMFillRpt(nb_roots, rts, SM_RPT_OBJ_LIGHT, &Info) != 1)
      {
	printf("SMRptClean: Error in SMFillRpt\n");
	return OM_W_ABORT;
      }
     
     for(i=0;i<nb_roots;i++)
      {
	if(Info[i].type == SM_RP_SF || Info[i].type == SM_RP_SL ||
	   Info[i].type == SM_RP_RP) continue;
	else if(Info[i].type == SM_RP_VM) CurVolMass   = Info[i].VolMass;
      }
     
     _FREE(Info) ;
     _FREE(rts) ;
     if(type == SM_RP_SF)
      {
	if(VolMass  != CurVolMass ) CurVolMass  = -1;/* Means must be created*/
      }  
     else if(type == SM_RP_SL)
      {
	if(VolMass != CurVolMass ) CurVolMass   = -1;/* Means must be created*/
      }  
   }
  
  k = 0;
  if(CurVolMass == -1)
   {
     /* Create VoLMass */
     
     tmp[0] = '\0';
     sprintf(tmp, "%g", VolMass); /* Negative value for dentity */
     
     ex$get_cur_mod(osnum = &ObjCon[k].osnum);
     
     status = om$construct(classid = OPP_expression_class_id,
			   osnum   = ObjCon[k].osnum,
			   p_objid = &ObjCon[k].objid);
     if(!(status&1)) return OM_W_ABORT;
     
     status = om$send(msg = message expression.create(NULL, tmp , &rc2 ),
		      targetid = ObjCon[k].objid,
		      targetos = ObjCon[k].osnum);
     if(!(status&1)) return OM_W_ABORT;
     
     status = om$send(msg = message NDnode.NDchg_state
		      (ND_DEL_NO_CH | ND_WAIT_DEL,
		       ND_DEL_NO_CH | ND_WAIT_DEL),
		      targetid = ObjCon[k].objid,
		      targetos = ObjCon[k].osnum);
     if(!(status&1))  return OM_W_ABORT;
     k++;
   }
  
  ObjCon[k++] = *obj;
  status = om$send(msg = message NDnode.NDconnect(k, ObjCon, original, ND_ADD),
		   targetid = my_id);
  if(!(status & 1)) return OM_W_ABORT;
  
  *msg = MSSUCC;
  return OM_S_SUCCESS;
}

/* ********************* MSG SMRptDelObj() *******************	*/

method SMRptDelObj(IGRlong *msg; struct GRid *obj)
{
  IGRlong 	status;
  
  *msg = MSFAIL;
  
  /* For now, just disconnect the object */
  status = om$send(msg = message NDnode.NDdisconnect(1, obj),
		   targetid = my_id);
  if(!(status & 1)) return OM_W_ABORT;
  
  *msg = MSSUCC;
  return OM_S_SUCCESS;
}


/* *********************** MS GRputname() ************************	*/


method GRputname(IGRlong *msg; IGRchar *name)
{
  IGRlong      status, loc_msg;
  IGRchar      *pt;
  IGRshort     type;
  struct GRid  cog;
  
  *msg = MSFAIL;

  status = om$send(msg = message ACncpx.GRputname(&loc_msg, name),
		   mode     = OM_e_wrt_message,
		   targetid = my_id );
  as$status(sts = (status & loc_msg),action = RET_STATUS);

  if(name[0] == ':')
   {
     /* Extract the short name */
     pt = strrchr(name,':');
     if(pt == NULL)
      {
	/* ??? */
	return OM_S_SUCCESS;
      }
     pt = &pt[1];
   }
  else pt = &name[0];
  
  type = SM_SYST_ATT | SM_DYNAMIC_ATT;
  status = om$send(msg = message SMmgr.SMSetAttTxt(&loc_msg, "name", pt, type),
		   targetid = my_id );
  as$status(sts = (status & loc_msg),action = RET_STATUS);

  status = om$send(msg = message NDmacro.ACreturn_foot
		   (&loc_msg,"cog", &cog, NULL, NULL),
		   targetid = my_id);
  as$status(sts = (status & loc_msg),action = RET_STATUS);
  
  status = om$send(msg = message VDSpt.VDsettext(pt),
		   targetid = cog.objid,targetos = cog.osnum);
  as$status(action = RET_STATUS);
  
  *msg = MSSUCC;
  return OM_S_SUCCESS;
}


/* *********************** MSG GRchgname() ************************	*/


method GRchgname(IGRlong *msg; struct GRmd_env *env; IGRchar *name)
{
  IGRlong     status, loc_msg;
  IGRchar     old_name[81], *pt, *strrchr();
  IGRshort    type;
  struct GRid cog;

  *msg = MSFAIL;
  
  status = om$send(msg = message ACncpx.GRchgname(&loc_msg, env, name),
		   mode     = OM_e_wrt_message,
		   targetid = my_id );
  as$status(sts = (status & loc_msg),action = RET_STATUS);
  
  /* Get the name stored in the rg collection, compare and modify or not */
  /* */
  status = om$send(msg = message SMmgr.SMGetAttTxt
		   (&loc_msg, "name", old_name , NULL),
		   targetid = my_id );
  if(!(status & loc_msg & 1)) old_name[0] = '\0';
  
  if(name[0] == ':')
   {
     /* Extract the short name */
     pt = strrchr(name,':');
     if(pt == NULL)
      {
	/* ??? */
	return OM_S_SUCCESS;
      }
     pt = &pt[1];
   }
  else pt = &name[0];
  
  if(strcmp(old_name, pt) == 0) return OM_S_SUCCESS;
  
  type = SM_SYST_ATT | SM_DYNAMIC_ATT;
  status = om$send(msg = message SMmgr.SMSetAttTxt(&loc_msg, "name", pt, type),
		   targetid = my_id );
  as$status(sts = (status & loc_msg),action = RET_STATUS);
  
  status = om$send(msg = message NDmacro.ACreturn_foot
		   (&loc_msg,"cog", &cog, NULL, NULL),
		   targetid = my_id);
  as$status(sts = (status & loc_msg),action = RET_STATUS);
  
  status = om$send(msg = message VDSpt.VDsettext(pt),
		   targetid = cog.objid,targetos = cog.osnum);
  as$status(action = RET_STATUS);

  *msg = MSSUCC;
  return OM_S_SUCCESS;
}

/* ******************* MSG SMFillRpFile() ************************	*/
method SMFillRpFile(IGRlong *msg; IGRchar *DescFile; FILE *p_file; 
                    IGRshort options; IGRboolean tag; IGRshort out_units; 
		    struct GRmdenv_info *obj_env, *trans_env)
{
  IGRlong                 status, loc_msg;
  struct GRid 		*roots, *rts;
  IGRint			 nb_roots, i, j;
  IGRchar                 desc[81];
  struct SMrpt           *Info;
  IGRshort                state;
  IGRdouble               cog[3], volume, area, mass;
  
  *msg = MSFAIL;
  
  /* MUST DO A GET STATE AND EXIT IF NOT GOOD */
  status = om$send(msg = message SMmgr.SMGetState(&state),
		   targetid = my_id);
  if(!(status &1)) return OM_W_ABORT;
  if(state & SM_CAL_ERR) return OM_S_SUCCESS;
  
  if(tag == TRUE)
   {
     printf("Use a tagged method, not implemented\n");
     return OM_W_ABORT;
   }
  
  if(DescFile != NULL)
   {
     printf("Reading the description in an ascii file no yet implemented\n");
     return OM_S_SUCCESS;
   }
  
  /* Get global info */
  status = om$send(msg = message SMmgr.SMGetAttTxt(&loc_msg, "description", 
						   desc, NULL),
		   targetid = my_id);
  if(!(status &1) || loc_msg != MSSUCC)
   {
     /* No description !!! */
     strcpy(desc, "No description");
   }
  
  /* Get the information for each surface/volume */
  status = om$send(msg = message NDnode.NDget_objects
		   (ND_ROOT|ND_IN_BUF, NULL, 0,
		    &roots, 1, OM_K_MAXINT, &nb_roots),
		   targetid = my_id);
  as$status(action = RET_STATUS);
  
  nb_roots -= 1;
  if(nb_roots < 1) return OM_S_SUCCESS;
  
  /* must copy into a local structure and free afterwards (recursion) */
  rts = _MALLOC(nb_roots, struct GRid);
  if(rts == NULL) 
   {
     printf("SMFillRpFile, bad dynamic memory allocation\n");
     return OM_W_ABORT;
   }
  for(i=0;i<nb_roots;i++) rts[i] = roots[i];
  
  if(SMFillRpt(nb_roots, rts, SM_RPT_OBJ_DETAIL, &Info) != 1)
   {
     printf("SMGetObjInfo: Error in SMFillRpt\n");
     return OM_W_ABORT;
   }
  
  if(!(options & SM_NO_HDR_RPT))
   {
     /* print the header */
     fprintf(p_file, "Report: %s\n", desc);
     fprintf(p_file, "\n");
     
     fprintf(p_file, "Surface            COG                                   area          weight\n");
     
     fprintf(p_file, " name                           \n");
     fprintf(p_file, "\n");
   }
  
  for(i=0;i<3;i++) cog[i] = 0;
  volume = 0;
  area   = 0;
  mass   = 0;
  
  for(i=0;i<nb_roots;i++)
   {
     if(Info[i].type == SM_RP_SF || Info[i].type == SM_RP_SL)
      {
	/* Convertion */
	for(j=0;j<3;j++)
	  SMConvDistIntUnit(Info[i].cog[j],out_units,
			    &Info[i].cog[j], OM_Gw_current_OS);
	SMConvVolIntUnit(Info[i].volume, out_units,
			 &Info[i].volume, OM_Gw_current_OS);
	SMConvSurfIntUnit(Info[i].area, out_units, &Info[i].area,
			  OM_Gw_current_OS);
	
	fprintf(p_file," %s \t %-7.2g \t %-7.2g \t %-7.2g \t %-7.2g \t %-7.2g\n",
		Info[i].short_name, 
		Info[i].cog[0], Info[i].cog[1], Info[i].cog[2], Info[i].area, 
		Info[i].mass);
	
	if(Info[i].mass == 0) continue;
	for(j=0;j<3;j++) cog[j] = (cog[j] * mass + Info[i].cog[j] * Info[i].mass) / (mass + Info[i].mass);
	volume += Info[i].volume;
	area   += Info[i].area;
	mass   += Info[i].mass;
      }
     if(Info[i].type == SM_RP_RP)
      {
	/* Send it to the report object */
	options = options | SM_NO_HDR_RPT; /* Don't print header */
	status = om$send(msg = message SMmgr.SMFillRpFile
			 (msg, DescFile, p_file,
			  options, tag, out_units, obj_env, trans_env),
			 targetid = rts[i].objid,
			 targetos = rts[i].osnum);
	as$status(action = RET_STATUS);
      }
   }
  
  if(!(options & SM_NO_HDR_RPT))
   {
     /* print the total */
     fprintf(p_file, "-------------------------------------------------------------------------------\n");
     fprintf(p_file, "Total:\t %-7.2g \t %-7.2g \t %-7.2g \t %-7.2g \t %-7.2g\n", 
	     cog[0], cog[1], cog[2], area, mass);
   }
  
  _FREE(Info);
  _FREE(rts);
  *msg = MSSUCC;
  return OM_S_SUCCESS;
}

/* 
/* SMFillRpt:
/*
/* Get/compute the info concerning the objects */
/*
/* */


SMFillRpt(nb_roots, roots, option, Info)
IGRint         nb_roots;  /* Number of roots          I */
struct GRid   *roots;     /* List of roots            I */
IGRint         option;    /* fill in detail or not    I */
struct SMrpt **Info;      /* Stucture gathering info  O */
{
 IGRlong                status, loc_msg;
 IGRint                 i, j;
 struct GRid            go, mod;
 struct GRmd_env        obj_env;
 GRclassid              obj_class;
 IGRdouble		density, val_db, props[NUMB_PROPS];
 IGRchar                short_desc[DI_PATH_MAX];

 /* Allocation of the structure */
 *Info = _MALLOC(nb_roots, struct SMrpt);
 if(*Info == NULL)
  {
   printf("SMGetObjInfo: Error, bad dynamic memory allocation\n");
   return OM_W_ABORT;
  }
  
 ex$get_cur_mod(id = &mod.objid, osnum = &mod.osnum);
 density = 0.;

 for(i=0;i<nb_roots;i++)
  {
   /* Get the short name */
   short_desc[0] = '\0';
   vd$get_name(name = short_desc, obj = &roots[i]);
   short_desc[31] = '\0';
   strcpy((*Info)[i].short_name, short_desc);
   (*Info)[i].valid = FALSE;


   if(SMIsKindOf(&roots[i],OPP_SMreports_class_id))
    {
       /* It is a reports */
     (*Info)[i].valid = TRUE;
     (*Info)[i].type  = SM_RP_RP;
     if(option == SM_RPT_OBJ_DETAIL)
      {
       IGRint               suc, index;
       struct ret_struct    ret;
       IGRshort             att_type;

       status = om$send(msg = message SMmgr.SMGetShortName(&loc_msg, short_desc),
                                senderid = NULL_OBJID,
				targetid = roots[i].objid,
				targetos = roots[i].osnum);
       if(!(status & loc_msg & 1)) return OM_W_ABORT;
       short_desc[31] = '\0';
       strcpy((*Info)[i].short_name, short_desc);

       status = om$send(msg = message SMmgr.SMGetAttDbl(&loc_msg, "area", 
                                                        &props[11], &att_type),
                                senderid = NULL_OBJID,
				targetid = roots[i].objid,
				targetos = roots[i].osnum);
       if(!(status & loc_msg & 1)) return OM_W_ABORT;

       status = om$send(msg = message SMmgr.SMGetAttDbl(&loc_msg, "volume", 
                                                        &props[0], &att_type),
                                senderid = NULL_OBJID,
				targetid = roots[i].objid,
				targetos = roots[i].osnum);
       if(!(status & loc_msg & 1)) return OM_W_ABORT;

       status = om$send(msg = message SMmgr.SMGetAttDbl(&loc_msg, "mass", 
                                                        &props[1], &att_type),
                                senderid = NULL_OBJID,
				targetid = roots[i].objid,
				targetos = roots[i].osnum);
       if(!(status & loc_msg & 1)) return OM_W_ABORT;

       index = -1;
       status = om$send(msg = message NDmacro.ACgive_structure(&suc, &index, 
                                                    "cog", &ret, &obj_env),
                                senderid = NULL_OBJID,
				targetid = roots[i].objid,
				targetos = roots[i].osnum);
       if(!(status & suc & 1)) return OM_W_ABORT;
       for(j=0;j<3;j++) props[j+2] = ret.var.point_st.pt[j];
      }
     goto other_parameters;
   }
  
   status = om$send(msg = message NDnode.ASreturn_go
		    (&go, &obj_env.md_env.matrix_type, obj_env.md_env.matrix),
		    senderid = NULL_OBJID,
		    targetid = roots[i].objid,
		    targetos = roots[i].osnum);
   if(!(status & 1)) continue;

   obj_env.md_id = mod;
   
   /* What kind of object is it ? */

   om$get_classid(osnum     = go.osnum,
		  objid     = go.objid,
		  p_classid = &obj_class);
   
 
   if(om$is_ancestry_valid(subclassid = obj_class,
      	   superclassid = OPP_expression_class_id) == OM_S_SUCCESS)
    {
      /* It is an expression density */
     status = om$send(msg = message expression.NDgive_value(&val_db),
		      senderid = NULL_OBJID,
		      targetid = go.objid,
		      targetos = go.osnum);
     if(!(status & 1)) continue;
     
     (*Info)[i].valid = TRUE;
    
     density            = val_db;
     (*Info)[i].VolMass = density;
     (*Info)[i].type    = SM_RP_VM;
     
     continue;
   }
   else if(om$is_ancestry_valid(subclassid = obj_class,
	      superclassid = OPP_EMSsolid_class_id) == OM_S_SUCCESS)
    {
      /* It is solid */
      (*Info)[i].type = SM_RP_SL;
      if(density < 0)
       {
	 /* No density defined */
	 continue;
       }
      
      (*Info)[i].VolMass = density;
      if(option == SM_RPT_OBJ_DETAIL)
       {
	 if(SMCompMassProp(&go, MASS_PROPERTIES, &obj_env,density,1.,props)!=1)
	   continue;
       
	 (*Info)[i].valid = TRUE;
       }
    }
   else if(om$is_ancestry_valid(subclassid = obj_class,
	      superclassid = OPP_EMSsurface_class_id) == OM_S_SUCCESS)
    {
      /* It is a surface */
      (*Info)[i].valid = FALSE;
      (*Info)[i].type  = SM_RP_SF;
      if(density < 0)
       {
	 /*"Error, No density defined */
       continue;
     }
      
      (*Info)[i].VolMass   = density;
      if(option == SM_RPT_OBJ_DETAIL)
       {
	 if(SMCompMassProp(&go, AREA_PROPERTIES, &obj_env, 1., 1., props) != 1)
	  {
	    continue;
	  }
	 /* get the volume and mass */
	 props[1] = props[11]  * density;
	 (*Info)[i].valid = TRUE;
       }
    } 
   else
    {
      printf("Error, unknown classid of root object %d %d\n",go.objid,go.osnum);
      continue;
    } 

 other_parameters:
   if(option == SM_RPT_OBJ_DETAIL)
    {
      for(j=0;j<3;j++) (*Info)[i].cog[j] = props[j+2];
      (*Info)[i].volume = props[0];
      (*Info)[i].area   = props[11];
      (*Info)[i].mass   = props[1];
    }
 } 
 return 1;
}

/*----------------------------------------------------------------------------*/
method VDgetObjDef( long *msg ; VDobjDef *myDef ) {

	long		sts ;	/* OM return code	*/

	/*
	 * name.
	 */
	myDef->info		= SM_I_ObjReports ;
	myDef->type		= 0 ;

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	return sts ;

} /* method VDgetObjdDef */
/*----------------------------------------------------------------------------*/

end implementation SMreports;

