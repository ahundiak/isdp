/* $Id: VDProjNb.I,v 1.1.1.1 2001/01/04 21:09:05 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdproject/func / VDProjNb.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VDProjNb.I,v $
 *        Revision 1.1.1.1  2001/01/04 21:09:05  cvs
 *        Initial import to CVS
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
# Revision 1.5  1996/05/27  05:59:38  pinnacle
# Replaced: vdproject/func/VDProjNb.I for:  by apazhani for vds.240
#
# Revision 1.4  1996/05/08  21:57:30  pinnacle
# Replaced: vdproject/func/VDProjNb.I for:  by sljenks for vds.240
#
# Revision 1.2  1995/12/15  23:29:04  pinnacle
# Replaced: vdproject/func/VDProjNb.I for:  by hverstee for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *        MM/DD/YY        AUTHOR                DESCRIPTION
 *	  05/08/96	  slj			replaced free, malloc with
 *						_FREE, _MALLOC
 *	  05/09/96	  slj			Fixed allocation of 0 bytes
 *	  05/09/96	  slj			Fixed allocation of 0 bytes
 *						at line 174, changed FREE to	 *						loopfree
 *

/****************************************************
/*
/* Date                : 16-feb-93
/* Author        : Pascale Lacroix (ISDC)
/*
/*        
/****************************************************/

class implementation Root;

#include <stdio.h>
#include <ctype.h>
#include <string.h>

#include  "OMminimum.h"
#include  "OMerrordef.h"
#include  "OMprimitives.h"

#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "godef.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "refdef.h"

#include   "ms.h"
#include   "msdef.h"
#include   "msmacros.h"

#include   "exdef.h"
#include   "exmacros.h"

#include "AS_status.h"

#include "VDprojdef.h"
#include "VDmsg.h"
#include "VDmem.h"

extern        GRclassid        OPP_text_exp_class_id;

from NDnode         import        NDgive_structure;
from GRcontext        import  GRgetinstance;


VDGetRefFiles(ref_os, ref_path,nb_ref)

  GRspacenum         **ref_os;
  DIchar            ***ref_path;
  int                 *nb_ref;

{

  /* Find all the reference files */

  long            status,loc_msg;
  IGRchar         osname[OM_K_MAXOSNAME_LEN];
  IGRshort        mx_type, flag;
  OMuint          count;

  IGRlong         i,j;     /* loop index                        */
  IGRint          tnb_ref;
  GRspacenum     *tref, ref_osnum;

  OM_S_CHANSELECT super_chan, ref_chan;

  struct GRid     Super, ctx_id;
  IGRmatrix       ctx_matrix;

  tref = NULL;
  tnb_ref = 0;
  status = OM_S_SUCCESS;

  if(ref_os) *ref_os = NULL;
  if(ref_path) *ref_path = NULL;
  if(nb_ref) *nb_ref = 0;

  status = om$make_chanselect(channame = "Super_rfmgr.to_context",
                            p_chanselect = &super_chan);
  as$status(action = RET_STATUS);

  status = om$make_chanselect(channame = "GRcontext.to_reffile",
                            p_chanselect = &ref_chan);
  as$status(action = RET_STATUS);


                                /* get the context Super        */
  status = GRgetctxsuper(&loc_msg,&Super);
  if(!(status&loc_msg&1)) return OM_E_ABORT;

  status = om$get_channel_count( osnum = Super.osnum,
                                 objid = Super.objid,
                          p_chanselect = &super_chan,
                                 count = &count);
  if(!(status & 1))
   {
     status = OM_E_ABORT;
     goto error;
   }

  tref = _MALLOC (count, GRspacenum);
  _CheckAlloc (tref, "malloc:tref", status, FALSE, error);
  
  for (i=0; i<count; ++i)
  {                        /* get each context object        */
     status =
     om$send( msg = message GRcontext.GRgetinstance
                              (&loc_msg,&mx_type,ctx_matrix,&ref_osnum,
                               &flag,&ctx_id),
          senderid = Super.objid,
          targetos = Super.osnum,
      p_chanselect = &super_chan,
                to = i,
              from = i);
     if(!(status&loc_msg&1)) continue;
        
   /* see if this object space is active before
    * trying to use this context object.
    */

     status = om$os_number_to_name(osnum=ref_osnum,
                                      osname = osname);
     if(!(status&1)) continue;
     if ( !( flag & GRACTIVATED_CONTEXT)) continue;

     for(j=0;j<tnb_ref;j++) if(ref_osnum == tref[j]) break;

     if(j >= tnb_ref) 
     {
       tref[tnb_ref] = ref_osnum;
       tnb_ref = tnb_ref + 1;
     }
  }

  if(nb_ref) *nb_ref = tnb_ref;
  if(ref_os && tnb_ref)
  {
       (*ref_os) = _MALLOC (tnb_ref, GRspacenum);
       _CheckAlloc ((*ref_os), "malloc:(*ref_os)", status, OM_E_ABORT, error);
       for(i=0;i<tnb_ref;i++) (*ref_os)[i] = tref[i];
  }

  if(ref_path && tnb_ref)
  {
    (*ref_path) = _MALLOC (tnb_ref, DIchar* );
    _CheckAlloc ((*ref_path), "malloc:(*ref_path)", status, OM_E_ABORT, error);

    for(i=0;i<tnb_ref;i++)
      (*ref_path)[i] = NULL;

    for(i=0;i<tnb_ref;i++)
    {
      (*ref_path)[i] = _MALLOC (DI_PATH_MAX, DIchar);
      _CheckAlloc ((*ref_path)[i], "malloc:(*ref_path)[i]", status,
			OM_E_ABORT, error);
      status = di$give_pathname( osnum = tref[i],
                              pathname = (*ref_path)[i]);

      if(status != DIR_S_SUCCESS)
      {
        printf("error di$give_pathname\n");
        goto error;
      }
    }
  }

  _FREE(tref);

  return( OM_S_SUCCESS );

error:

  _FREE(tref);

  /* These are free output parameters */
  if (ref_os) _FREE(*ref_os);
  _LOOPFREE(*ref_path, tnb_ref);

  return( OM_E_ABORT );
}

/*1  ----------------------- VDGetProjectNb ---------------------------*/
/*        
/*        function that explores the directories sub_system to find 
/*        the given expression name. The search begins at the directory
/*        ":filename".
/*        Only one expression (value) is returned, the one in the current
/*        os if it exists, otherwise the first one found.
/*        The flag diff_val indicates if there are some expressions 
/*        with different values.
/*        Each output can be set to NULL if not needed.
/*        
/*        Return 1 if OK.
/**/

IGRint VDGetProjectNb(proj_name, proj_nb, exp_id, diff_val, found)

IGRchar         *proj_name;  /* (I) name of expression to search */
IGRchar         *proj_nb;    /* (O) returned value of expression */
struct GRid     *exp_id;     /* (O) returned id of expression */
IGRboolean      *diff_val;   /* (O) diff_val = TRUE if different values */
IGRboolean      *found;      /* (O) found = FALSE if no expression is found */

{
  IGRint            i, nb_ref, line_index, stat;
  DIchar            tmp_nb[DI_PATH_MAX], start_dir[DI_PATH_MAX], 
                  **refnames, ret_value[DI_PATH_MAX];
  IGRboolean        err_flag, IsValid , diff ;
  IGRlong           msg, sizebuf, nret;
  DIgrid           *grids, p_obj;

  struct GRmd_env         act_env;
  struct ret_struct       str;
  GRspacenum             *ref_os;

  nb_ref = 0;
  ref_os = NULL;
  refnames = NULL;
  grids = NULL;
  err_flag = FALSE;
  line_index = -1;
  
  
  IsValid = FALSE;
  diff    = FALSE;
  p_obj.objid = NULL_OBJID;

  if(proj_name == NULL)
  {
    printf("ERROR, no proj_name defined\n");
    goto wrapup;
  }

  sizebuf = sizeof(struct GRmd_env);
  gr$get_module_env( msg     = &msg,
                     sizbuf  = &sizebuf,
                     buffer  = &act_env,
                     nret    = &nret);

  /* first, look in the directory ":transient" */
  
  strcpy(start_dir,":transient");
  stat = di$translate(  objname = proj_name,
                        path    = start_dir,
                        p_objid = &p_obj.objid,
                        p_osnum = &p_obj.osnum);

 if(stat == DIR_S_SUCCESS)
 {
   /* if the project name is found in transient, that means all
           the verifications has been already done */

   IsValid = TRUE;
   diff = FALSE;

   if(proj_nb)
   {
     /* get the value of the expression */
     stat = om$send(msg = message NDnode.NDgive_structure(&msg, &str, NULL),
               senderid = NULL_OBJID,
               targetid = p_obj.objid,
               targetos = p_obj.osnum);
      strcpy(tmp_nb, str.var.text_st.text_string);
    }
    goto wrapup;
  }

  /* then, look in the directory ":'filename':usr" */

  stat = di$give_pathname( osnum = act_env.md_id.osnum,
                        pathname = start_dir);
  
  if(stat != DIR_S_SUCCESS)
  {
    printf("error di$give_pathname\n");
    err_flag = TRUE;
    goto wrapup;
  }
  strcat(start_dir,":usr");

  stat = di$translate(  objname = proj_name,
                        path    = start_dir,
                        p_objid = &p_obj.objid,
                        p_osnum = &p_obj.osnum);

  if(stat == DIR_S_SUCCESS)
  {
    stat = om$send(msg = message NDnode.NDgive_structure(&msg, &str, NULL),
              senderid = NULL_OBJID,
              targetid = p_obj.objid,
              targetos = p_obj.osnum);
    strcpy(tmp_nb, str.var.text_st.text_string);

    IsValid = TRUE;
    if(diff_val == NULL) goto wrapup;
  }        

  /* search in the ref files to see if there are others expressions with
        the same name */

  VDGetRefFiles( &ref_os, &refnames, &nb_ref);

  if(nb_ref)
  {
    grids = _MALLOC (nb_ref, DIgrid);
    _CheckAlloc (grids, "malloc:grids", err_flag, TRUE, wrapup);

    for(i=0;i<nb_ref;i++)
    {
      sprintf(start_dir,"%s%s",refnames[i],":usr");
      stat = di$translate( objname = proj_name,
                           path    = start_dir,
                           p_objid = &grids[i].objid,
                           p_osnum = &grids[i].osnum);
    }
  }
  
  for(i=0;i<nb_ref;i++)
  {
    /* the return lines must be a text expression */
    
    if( !SMIsKindOf( (struct GRid *)&grids[i], OPP_text_exp_class_id) )
                   grids[i].objid = NULL_OBJID;
    else
    {
      line_index = i; 

      if(!IsValid)
      {
        p_obj = grids[line_index];
        stat =
        om$send(msg = message NDnode.NDgive_structure(&msg, &str, NULL),
           senderid = NULL_OBJID,
           targetid = p_obj.objid,
           targetos = p_obj.osnum);
        strcpy(tmp_nb, str.var.text_st.text_string);
      }

      IsValid = TRUE;
      break;
    }
  }

  if(line_index == -1)
  {
    /* there is no valid project nb in ref files */

    diff = FALSE;
    goto wrapup;
  }

  if(diff_val)
  {
    diff = FALSE;
    for(i=0;i<nb_ref;i++)
    {
       stat =
       om$send(msg = message NDnode.NDgive_structure(&msg, &str, NULL),
          senderid = NULL_OBJID,
          targetid = grids[i].objid,
          targetos = grids[i].osnum);
       strcpy(ret_value, str.var.text_st.text_string);
        
       if(strcmp(tmp_nb,ret_value))
       {
         diff = TRUE;
         break;
       }        
     }
  }
  
wrapup:
  
  if(refnames)
  {
    for(i=0;i<nb_ref;i++)
       if(refnames[i]){_FREE(refnames[i]);refnames[i] = NULL;}
    _FREE(refnames); refnames = NULL;
  }

  if(ref_os){_FREE(ref_os); ref_os = NULL;}
  if(grids){_FREE(grids);grids = NULL;}
  
  if(err_flag)
  {
    if(proj_nb) proj_nb[0] = '\0';
    if(exp_id)  exp_id->objid = NULL_OBJID;
    if(diff_val) *diff_val = FALSE;
    if(found)    *found = FALSE;
    return 0;
  }
  else
  {
    if(exp_id)
    {
       exp_id->objid = p_obj.objid;
       exp_id->osnum = p_obj.osnum;
    }
    if(proj_nb) strcpy(proj_nb, tmp_nb);
    if(found) *found = IsValid;
    if(diff_val) *diff_val = diff;

    return(1);
  }
}

/* This is a wrapper round  VDGetProjectNb looking for expression in
   the current design file & the attached reference files.
*/

/* LIMITATION */
/* PROJECT NUMBER CANNOT HAVE '"' or a ' '  */

/* COMMENTED ******************************************************************

int VDCheckProjectNum(osnum, proj_nb, proj_rev, found, inref)
OMuword                osnum;                
IGRchar                *proj_nb;
IGRchar                *proj_rev;        
IGRboolean        *found;        
IGRboolean        *inref;
{
   IGRchar        *exp_name;
   struct GRid        exp_id;
   IGRint        sts;
   IGRboolean        diff_val=FALSE;
   IGRchar        temp_proj[40];
   IGRchar        tmpstr[40];
   IGRint        i,len,j=0;

   *found = FALSE;
   *inref = FALSE;

   exp_name=VD_PRJNUMBER_EXP;
   sts = VDGetProjectNb(exp_name, temp_proj, &exp_id, &diff_val, found);
   if( sts == 0) {printf("Error: Getting Project Number\n"); return 0;}

   if (diff_val)
   {
      UI_status("Multiple Project Numbers found");
      sts = 0;
      return sts;
   }
   if( *found == TRUE && exp_id.osnum != osnum && exp_id.osnum != 1)
      *inref = TRUE;
   len = strlen(temp_proj);
   for ( i = 0; i < len; i++ )
      if( temp_proj[i] != '\0' && temp_proj[i] != '\"' && temp_proj[i] != ' ')
         tmpstr[j++] = temp_proj[i];
   tmpstr[j] ='\0';

   if(*found == TRUE )
      VDCreateExp( tmpstr ); 

   UI_status(" ");

   if(strchr(tmpstr,'|'))
     strcpy(proj_nb, strtok(tmpstr,"|"));
   else
   {
     strcpy(proj_nb,tmpstr);
     strcpy(proj_rev,"NULL");
   }

   return 1; 
}
*******************************************************************************/


IGRint VDCheckProjectNum(osnum,prj_number, prj_rev, prj_units,
                          prj_no,found,inref )

OMuword      osnum;         /* [I] osnum of current file        */
IGRchar     *prj_number;    /* [O] project number                */
IGRchar     *prj_rev;       /* [O] project revision                */
IGRint      *prj_units;     /* [O] project units                */
IGRint      *prj_no;        /* [O] project no                */
IGRboolean  *found;         /* [O] if found then TRUE        */
IGRboolean  *inref;         /* [O] if in reference file TRUE*/

{
   IGRchar        *exp_name;
   struct GRid     exp_id;
   IGRint          sts;
   IGRboolean      diff_val=FALSE;
   IGRboolean      in_trans=FALSE;
   IGRchar         temp_proj[40];
   IGRchar         tmpstr[40];
   IGRchar        *tmp=NULL,*tmp1=NULL;
   IGRint          i,len,j=0;
   OMuword         exec_osnum;

   exp_name=VD_PRJNUMBER_EXP;

   *found = FALSE;
   *inref = FALSE;

   ex$get_exec_id ( osnum=&exec_osnum );

   sts = VDGetProjectNb(exp_name, temp_proj, &exp_id, &diff_val, found);

   if( sts == 0) {printf("Error: Getting Project Number\n"); return 0;}

   if( diff_val)
   {
/*
      UI_status("Multiple Project Numbers found");
      sts = 0;
      return sts;
*/
      printf ("Warning, different project numbers in reference file\n");
   }
/*
   UI_status(" ");
*/
   if( !(*found))
   {
      return 1;
   }

   if( *found && exp_id.osnum != osnum && exp_id.osnum != exec_osnum)
      *inref = TRUE;

   if( *found && exp_id.osnum == exec_osnum) 
      in_trans = TRUE;  /* Present in Transient */

   len = strlen(temp_proj);
   if(len == 0) { printf("Bad Project Number\n"); return 0;}

   for ( i = 0; i < len; i++ )
     if( temp_proj[i] != '\0' && temp_proj[i] != '\"' && temp_proj[i] != ' ')
       tmpstr[j++] = temp_proj[i];

   tmpstr[j] ='\0';

   if(tmp = strchr(tmpstr,'|'))
   {

     /* PROJECT NUMBER is of the format proj_nb|units|prj_no|prj_rev */

     tmp1 = &tmp[1];
     *tmp='\0';                        /* NULL terminate tmpstr */
     strcpy(prj_number,tmpstr);
     if(tmp = strchr(tmp1,'|'))
     {
        *tmp = '\0';
        sscanf(tmp1,"%d",prj_units);
        tmp1 = &tmp[1];
        if(tmp = strchr(tmp1,'|'))
        {
           *tmp='\0';
           sscanf(tmp1,"%d",prj_no );
           strcpy(prj_rev,&tmp[1]);   /* Project Revision Exists */
        }
        else
        {
           sscanf(tmp1,"%d",prj_no );
           strcpy(prj_rev,"NULL");   /* Project Revision does not exist */
                                     /* Return NULL */
        }
     }
     else
     {
        printf("Bad Project Number\n");
        return 0;
     }
   }
   else
   {
     strcpy(prj_number,tmpstr);
     strcpy(prj_rev,"NULL");
     *prj_units = 1;
     *prj_no = 0;
   }

   if(*found == TRUE && in_trans != TRUE)
   {
      if(VDValidateProject(prj_number,prj_rev,*prj_units))
      {
         sprintf( tmpstr,"%s|%d|%d|%s",prj_number,*prj_units,*prj_no,prj_rev);
         VDCreateExp( tmpstr,TRUE );  /* Create the expression if found in   */
                                      /* Reference file, in current & trans. */
      }
      else
      {}
   }
   /*
   printf("WARNING:Invalid Project: %s, %s %d\n",prj_number,prj_rev,*prj_units);
   */

   return 1;
}

end implementation Root;

