/* $Id: VDProjFn.I,v 1.1.1.1 2001/01/04 21:09:05 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdproject/func/VDProjFn.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDProjFn.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:05  cvs
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
# Revision 1.7  1996/05/08  13:51:50  pinnacle
# Replaced: vdproject/func/VDProjFn.I for:  by sljenks for vds.240
#
# Revision 1.6  1995/12/18  10:48:50  pinnacle
# Replaced: vdproject/func/VDProjFn.I for:  by rgade for vds.240
#
# Revision 1.5  1995/12/15  23:29:26  pinnacle
# Replaced: vdproject/func/VDProjFn.I for:  by hverstee for vds.240
#
# Revision 1.4  1995/12/06  20:03:52  pinnacle
# Replaced: vdproject/func/VDProjFn.I for:  by yzhu for vds.240
#
# Revision 1.3  1995/12/06  19:43:04  pinnacle
# Replaced: vdproject/func/VDProjFn.I for:  by yzhu for vds.240
#
# Revision 1.2  1995/09/25  22:56:42  pinnacle
# Replaced: vdproject/func/VDProjFn.I for:  by sundar for vds.240
#
# Revision 1.1  1995/07/24  20:59:30  pinnacle
# Created: vdproject/func/VDProjFn.I by hverstee for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *      12/06/95        yZHU            modify VdsSetProjectData for TR179528484
 *      05/08/96        slj		moved vdb$risbuffer to free up memory
 * -------------------------------------------------------------------*/

class implementation Root;

#include  <stdio.h>
#include <ctype.h>
#include <string.h>

#include  "OMerrordef.h"
#include  "OMminimum.h"
#include  "OMprimitives.h"
#include  "igrtypedef.h"
#include  "igetypedef.h"
#include  "gr.h"
#include  "godef.h"
#include  "igr.h"
#include  "igrdp.h"
#include  "go.h"
#include  "grdpbdef.h"
#include  "grdpbmacros.h"
#include  "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "refdef.h"

#include   "ms.h"
#include   "msdef.h"
#include   "msmacros.h"

#include   "exdef.h"
#include  "exmacros.h"
#include  "vdbmacros.h"

#include  "expression.h"
#include  "expmacros.h"

#include  "PDUerror.h"
#include  "VDprojdef.h"
#include  "VDDbDef.h"
#include  "VDmsg.h"
#include "v_dbgmacros.h"
#include "v_miscmacros.h"


%safe
#include  "VX_FIproto.h"
%endsafe

from NDnode import  NDgive_structure;

/*
/* FUNCTION VDCreateExp()  Creates the expression VD_PRJNUMBER_EXP 
/* It first verifies if the expression already exists. If it exists
/* then compares it with the input value VDproject_num, if it is 
/* different then modifies the expression. If the expression does not
/* exist then it creates it either in :transient or <file>:usr .
*/

int VDCreateExp( VDproject_num,intrans )

char         *VDproject_num;  /* I - Syntax of Expr to create */
IGRboolean    intrans;        /* I - TRUE  if in transient        */
                              /*     FALSE if in usr                */
{
  char          file_name[100], cur_dir[100], dest_dir[100];
  DIchar        ret_value[DI_PATH_MAX];
  IGRint        sts;
  IGRlong       msg;
  GRspacenum    cur_os;

  struct GRid         tmp_obj;
  struct ret_struct   str;

  di$pwd(dirname = cur_dir);

  ex$get_cur_mod( osnum = &cur_os );

  if (intrans)
     strcpy(dest_dir,":transient");
  else
  {
     VDSget_filename(file_name);
     sprintf(dest_dir,"%s%s",file_name,":usr");
  }
  di$cd(dirname = dest_dir );

  sts = di$translate(objname=VD_PRJNUMBER_EXP,
		     p_objid = &tmp_obj.objid,
		     p_osnum = &tmp_obj.osnum );
  if(sts == DIR_S_SUCCESS)
  {
     sts =
     om$send( msg = message NDnode.NDgive_structure(&msg, &str, NULL),
	 senderid = NULL_OBJID,
	 targetid = tmp_obj.objid,
	 targetos = tmp_obj.osnum);

      strcpy(ret_value, str.var.text_st.text_string);

      if(strcmp(ret_value,VDproject_num))
      {
	 sts = exp$modify(exp_id = tmp_obj.objid,
			  osnum  = tmp_obj.osnum,
		      exp_syntax = VDproject_num);
         if(!(sts & 1))
            printf("Cant modify expression VDproject_number\n");
      }
  }
  else
  {
     sts = exp$create(exp_name   = VD_PRJNUMBER_EXP,
                      exp_syntax = VDproject_num,
		      osnum      = cur_os,
                      p_exp_id   = &tmp_obj,
		      type_rq    = EXP_TEXT);
     if(!(sts & 1))
        printf("Cant create expression VDproject_number\n");
  }

  di$cd(dirname = cur_dir);

  return  1;
}


int  VDSverify_project()
{
  OMuword         osnum; 
  IGRchar         proj_nb[20];
  IGRchar         proj_rev[20];
  IGRint	  prj_units,prj_no;
  IGRboolean      found=FALSE; 
  IGRboolean      inref; 
  IGRchar	  **buf;
  IGRchar	  VDproj_number[50];
  IGRint	  num,ret_msg; 
  int             rtc;

  rtc = OM_S_SUCCESS;

  ex$get_cur_mod( osnum = &osnum );

  if(VDCheckProjectNum(osnum, proj_nb,proj_rev, &prj_units,
                        &prj_no, &found, &inref)!=1)
     return OM_E_ABORT;

  if(!found)
  {
     ret_msg = 
     vdb$RisSelect(   select   =  "prj_number,prj_units_set,prj_no,prj_version",
                      table_name = "vds_project",
                      where      = NULL,
                      order      = NULL,
                      group      = NULL,
                      numselect  = 4,
                      p_numrows  = &num,
                      p_buffer   = &buf );
     if( ret_msg !=1 )
     {
      return OM_E_ABORT;
     }
     if( num != 1)
     {
       ex$message(msgnumb = VD_E_PrUsNotSel);
       rtc = OM_E_ABORT;
     }
     else
     {
       sprintf(VDproj_number,"%s|%s|%s|%s",buf[0],buf[1],buf[2],buf[3]);
       VDCreateExp(VDproj_number,TRUE);
       VDCreateExp(VDproj_number,FALSE);
       rtc = OM_S_SUCCESS;
     }

     vdb$RisFreeBuffer( buffer =  buf,
                        size   =  num);
  }

  return rtc;
}

int VDValidateProject(project_num, project_ver, prj_units)

IGRchar	 *project_num;
IGRchar  *project_ver;
IGRint	 prj_units;

{
   char    *table=NULL;
   char    *select=NULL;
   char    search[MAX_WHERE_SIZE];
   char    **buf;
   int     num;
   long    msgnumb;
   int     ret_msg; 

   table =  "VDS_PROJECT";
   select = "prj_no";
   ret_msg = 1;

   /* Verify if project version is NULL or defined */
   if(!strcmp(project_ver,"NULL") || !strcmp(project_ver,""))
      sprintf( search, "prj_number = '%s' and prj_units_set = %d\0",
                       project_num,prj_units);
   else
      sprintf( search,
   "prj_number = '%s' and prj_version = '%s' and prj_units_set = %d\0",
                       project_num,project_ver,prj_units);
   ret_msg =  
   vdb$RisSelect(  select     =       select,
                   table_name =       table,
                   where      =       search,
                   order      =       NULL,
                   group      =       NULL,
                   numselect  =       1,
                   p_numrows  =       &num,
                   p_buffer   =       &buf );
   if ( ret_msg  != 1 )
   {
      msgnumb= VD_E_PrVdsPrj;
      ex$message(msgnumb= VD_E_PrjNotFound,
		  type = "%s", var = `project_num`);
      ret_msg = 0;
   }

   vdb$RisFreeBuffer(  buffer    =    buf,
                       size      =    num);

   if ( num == 0) ret_msg =  0;
   return (ret_msg);
}

int  VDGetProjectNumber( proj_nb)

IGRchar	 *proj_nb; 		  /* [O] project number found     */

{
  OMuword         osnum;          /* [I] osnum of current file    */
  IGRchar         proj_rev[20];
  IGRint	  prj_units,prj_no;
  IGRboolean      found;          /* [O] if found then TRUE       */
  IGRboolean      inref;          /* [O] if in reference file TRUE*/

  SetProc( VDGetProjectNumber ); Begin

  ex$get_cur_mod( osnum = &osnum );

  if(!VDCheckProjectNum(osnum, proj_nb,proj_rev, &prj_units,&prj_no, 
                        &found, &inref))
  {
      __DBGpr_com (" return OM_E_ABORT ");
     	End
        return OM_E_ABORT;
  }

  if(!found)
  {
     ex$message(msgnumb = VD_E_PrUsNotSel);
     __DBGpr_com(" return OM_E_ABORT ");
     End
     return OM_E_ABORT;
  }

  __DBGpr_com(" return OM_S_SUCCESS ");
  End
  return OM_S_SUCCESS;
}

int  VDGetProjectNumRev( proj_nb,proj_rev,prj_units)

IGRchar	 *proj_nb; 		  /* [O] project number found     */
IGRchar	 *proj_rev; 		  /* [O] project revision found   */
IGRint	 *prj_units;		  /* [O] project units found	  */

{
  OMuword         osnum;          /* [I] osnum of current file    */
  IGRint	  prj_no;
  IGRboolean      found;          /* [O] if found then TRUE       */
  IGRboolean      inref;          /* [O] if in reference file TRUE*/

  /*osnum = 2;*/
  ex$get_cur_mod( osnum = &osnum );
  if( !VDCheckProjectNum(osnum, proj_nb,proj_rev,prj_units,
                         &prj_no, &found, &inref)) 
    return 0;

  if(!found)
  {
     ex$message(msgnumb = VD_E_CanNotExPrNotSel);
     return 0;
  }
  return 1;
}

int  VdsSetProjectData( project_num, project_ver, VDSproject, msgnumb )

char               *project_num;        /* [I]  VDS PROJECT NUMBER        */
char               *project_ver;        /* [I]  VDS PROJECT VERSION        */
struct VDSproject  *VDSproject;         /* [O]  All Attributes of Project */
IGRlong            *msgnumb;            /* [O]  error message             */

{
   char    *table=NULL;
   char    *select=NULL;
   char    search[MAX_WHERE_SIZE];
   char    **buf;
   int     num,ret_msg;

   SetProc( VdsSetProjectData ); Begin
   *msgnumb = 0;

   if ( VDSverify_login() != PDM_S_SUCCESS )
   {
       ex$message(msgnumb= VD_E_PrUsNotLog);
       __DBGpr_com(" VDSverify_login() != PDM_S_SUCCESS ");
       End
       return 0;
   }

   table =  "VDS_PROJECT";
   select = "prj_no, prj_client, prj_name, prj_descr, prj_location, prj_units_set, checkin_dgn, ship_name, ship_number, ship_user, dept_name";

   /* Verify if project version is NULL or defined */

   if(!strcmp(project_ver,"NULL") || !strcmp(project_ver,""))
   {
      sprintf( search, "prj_number = '%s'", project_num);
      strcpy(VDSproject->prj_version,"");
   }
   else
   {
      sprintf( search, "prj_number = '%s' and prj_version = '%s'",
                        project_num,project_ver);
      strcpy(VDSproject->prj_version, project_ver);
   }

   ret_msg = 
   vdb$RisSelect(  select     =     select,
                   table_name =     table,
                   where      =     search,
                   order      =     NULL,
                   group      =     NULL,
                   numselect  =     11,
                   p_numrows  =     &num,
                   p_buffer   =     &buf );

   if ( ret_msg != 1  )
   {
      *msgnumb= VD_E_PrVdsPrj;
      ex$message(msgnumb= VD_E_PrjNotFound,
		  type = "%s", var = `project_num`);
      vdb$RisFreeBuffer( buffer   =     buf,
                         size     =     num);

       __DBGpr_com(" vdb$RisSelect unsucessful");
       End
      return 0;
   }

   if ( !buf   ){  /* yzhu TR 179528484  */
      *msgnumb= VD_E_PrVdsPrj;
      ex$message(msgnumb= VD_E_PrjNotFound,
                  type = "%s", var = `project_num`);
      __DBGpr_com(" buf is empty");
      End
      return 0;
   } 

   strcpy(VDSproject->prj_number,project_num);
   sscanf(buf[0],"%d",&VDSproject->prj_no);
   strcpy(VDSproject->prj_client,buf[1]);
   strcpy(VDSproject->prj_name,buf[2]);
   strcpy(VDSproject->prj_descr,buf[3]);
   strcpy(VDSproject->prj_location,buf[4]);
   sscanf(buf[5],"%d",&VDSproject->prj_units_set);
   sscanf(buf[6],"%d",&VDSproject->checkin_flag);
   strcpy(VDSproject->ship_name,buf[7]);
   strcpy(VDSproject->ship_number,buf[8]);
   strcpy(VDSproject->ship_user,buf[9]);
   strcpy(VDSproject->dept_name,buf[10]);

   vdb$RisFreeBuffer( buffer      =         buf,
                      size        =         num);
   End
   return 1;
}

end implementation Root;
