
/* $Id: VCTmacfun.I,v 1.1.1.1 2001/01/04 21:12:39 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcterm/VCTmacfun.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCTmacfun.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:12:39  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  05:23:34  pinnacle
# Integ into Route 02040304
#
# Revision 1.3  1997/03/12  16:36:02  pinnacle
# Replaced: vcterm/VCTmacfun.I for:  by hverstee for cabling
#
# Revision 1.2  1996/08/29  22:37:24  pinnacle
# Replaced: vcterm/VCTmacfun.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:28:38  pinnacle
# Created: vcterm/VCTmacfun.I by hverstee for cabling
#
 *
 * History:
 *
 *************************************************************************/

class implementation Root;


#include "OMminimum.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "AS_status.h"
#include "gr.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "macro.h"
#include "acmacros.h"
#include "parametric.h"
#include "VRdef.h"
#include "VRdimdef.h"
#include "VRstructs.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "msdef.h"
#include "exmacros.h"
#include "VDmem.h"
#include <stdio.h>

/*
#define MY_DEBUG
*/

from ACcpx_defn    import   ACgive_temp_desc;
from ACcpx_defn    import   ACgive_feet_desc;
from ACmacro_defn  import   ACtake_template;
from NDmacro       import   ACreturn_foot;
from NDmacro       import   ACgive_structure;

from ACcpx         import   find_macro;
from nci_macro     import   user_func;

/*****************************************************************************/

IGRint
VCget_cache_attr (struct  GRid        *my_model,   /* I */
                          int          num_pts,    /* I */
                  struct  VRcp_attr   *attr)
{
  int       i,status;
  IGRlong   msg;
  char      str[16];
  struct   GRid   foot_GRid;
     
/*"ATTR  name of model %d\n", my_model->objid  */

  for(i=0;i<num_pts;i++)
  {
    sprintf(str,"VRcpt_%02d",i);
     /*"ATTR  name of cpt [%d] : %s\n", i, str */
    status =
    om$send (msg = message NDmacro.ACreturn_foot
                                        (&msg, str,&foot_GRid,NULL,NULL),
        senderid = my_model->objid,
        targetid = my_model->objid,
        targetos = my_model->osnum );
    as$status(  );

    status =
    om$send (msg = message nci_macro.user_func
                                        ("cpt_attr",NULL,(char *) &(attr[i])),
        senderid = my_model->objid,
        targetid = foot_GRid.objid,
        targetos = foot_GRid.osnum );
    as$status(  );
  }

  return OM_S_SUCCESS;
}/* end VCget_cache_attr */

/*****************************************************************************/

IGRint
VCget_cp_attr (struct  GRid       *my_model,  /* I */
                       IGRshort    nCpNum,    /* I */
               struct  VRcp_attr  *attr)

{
  int      status;
  IGRlong  msg;
  char     str[16];
  struct   GRid   foot_GRid;

  /*"ATTR  name of model %d\n", my_model->objid  */

  sprintf(str,"VRcpt_%02d",nCpNum);
  /*"ATTR  name of cpt [%d] : %s\n", nCpNum, str */
  status =
  om$send (msg = message NDmacro.ACreturn_foot
                                        (&msg, str,&foot_GRid,NULL,NULL),
      senderid = my_model->objid,
      targetid = my_model->objid,
      targetos = my_model->osnum );
  as$status( action = RET_STATUS );

  status =
  om$send (msg = message nci_macro.user_func
                                        ("cpt_attr",NULL,(char *) attr),
      senderid = my_model->objid,
      targetid = foot_GRid.objid,
      targetos = foot_GRid.osnum );

  return status;
}/* end VCget_cp_attr */

/*****************************************************************************/

IGRint
VCget_cache_pnts (struct GRid       *my_model,  /* I */
                         int        *num_pts,   /* I */
                         IGRdouble  *cpt_geom,  /* I/O your array i fill it */
                  struct GRmd_env   *md_env)

{
  int     i,j,status,suc,m_1;
  char    str[20];

  struct ret_struct  r_pnt;

  for(i=0;i< *num_pts;i++)
  {
    sprintf(str,"VRcpt_%02d:graphic",i);
    /*" name of cpt [%d] : %s\n", i, str */

    m_1=-1;
    status =
    om$send (msg = message NDmacro.ACgive_structure
                                           (&suc,&m_1,str,&r_pnt,md_env),
        senderid = my_model->objid,
        targetid = my_model->objid,
        targetos = my_model->osnum );
    as$status(  );

    for(j=0;j<3;j++)
    {
      cpt_geom[i*3+j] = r_pnt.var.point_st.pt[j];
    }
  }

  return OM_S_SUCCESS;
}/* end VCget_cache_pnts */

/*****************************************************************************/

IGRint
VCnum_cpts (char     *mac_name,    /* I */
            int      *num_pts)
{
  int     i,status;
  int     feet_num; 

  struct   GRid   mac_def;
  struct   myfeet *myfeet;

  status =
  ac$find_macro_defn (action    = ACfind_load,
                   macro_name   = mac_name,
              p_macro_defn_id   = &mac_def );
  if ( !(status & OM_S_SUCCESS) ) return OM_E_ABORT;

  status =
  om$send (msg = message ACcpx_defn.ACgive_feet_desc(&feet_num,&myfeet),
      senderid = mac_def.objid,
      targetid = mac_def.objid,
      targetos = mac_def.osnum );
  as$status( action = RET_STATUS );

  *num_pts=0;

  for(i=0;i<feet_num;i=i+1)
  {
    if(!strncmp(myfeet[i].name,"VRcpt_",6)) *num_pts +=1;
  }

  return OM_S_SUCCESS;
}/* end VCnum_cpts */

/*****************************************************************************/

IGRint
VCGetGeom (struct GRid       *pGraphicsId,  /* I : macro occurrence Id */
                  IGRint      CpFrom,
                  IGRint      CpTo,
                  IGRdouble  *dCpCoors,
           struct GRmd_env   *md_env)
{
  IGRint      status;
  IGRlong     retmsg;
  IGRint      CpNum,Index=-1;
  IGRchar     footname[20];

  struct ret_struct  AttrSt;

  if ( CpFrom > CpTo || CpFrom < 0 || CpTo > VR_MAX_CPTS ) return OM_E_INVARG;

  /* -- Get Cpt coordinates -- */

  for (CpNum = CpFrom; CpNum <= CpTo; CpNum++ )
  {
    sprintf ( footname,"VRcpt_0%d:graphic",CpNum);

    status = 
    om$send (msg = message NDmacro.ACgive_structure 
                              ( (IGRint *) &retmsg, &Index,
                               footname, &AttrSt, md_env ),
        senderid = NULL_OBJID,
        targetid = pGraphicsId->objid,
        targetos = pGraphicsId->osnum );
    as$status ( action = RET_STATUS );

    dCpCoors[3*CpNum  ] = AttrSt.var.point_st.pt[0];
    dCpCoors[3*CpNum+1] = AttrSt.var.point_st.pt[1];
    dCpCoors[3*CpNum+2] = AttrSt.var.point_st.pt[2];
  }/* end loop on connect points */

  return OM_S_SUCCESS;
}/* end VCGetGeom */

/*****************************************************************************/

IGRint VCedit_macro (char      *mac_name,   /* I    this is the macro name */
                     int        num_up,     /* I     */
             struct  GRid      *temp_GRid,  /* I     */
                     int       *rep_test,
             struct  GRmd_env  *md_env)
{
  IGRint             temp_num, status,i,j,m_1,suc,rep_inc;
  struct stemp      *dtemp,*sstemp;
  struct sup        *dup;
  struct ret_struct  r_value;
  struct GRid        macro_defn;

  /*" Edition of macro : %s\n",mac_name */
  status = 
  ac$find_macro_defn (action    = ACfind_load,
                   macro_name   = mac_name,
              p_macro_defn_id   = &macro_defn );
  if (!(status & OM_S_SUCCESS) ) return (status);

  /*| locate macro find template definition */
  status =
  om$send (msg = message ACcpx_defn.ACgive_temp_desc (&temp_num, &sstemp),
      senderid = macro_defn.objid,
      targetid = macro_defn.objid,
      targetos = macro_defn.osnum );
  as$status( action = RET_STATUS );

#ifdef MY_DEBUG
  printf (" templates in, mac %d %d\n",num_up, temp_num);
#endif

  rep_inc=0;

  if(!strcmp("~rep",sstemp[0].name)) 
  {
       /*| Theirs a ~rep in here  */
       rep_inc=1;
  }
        *rep_test=rep_inc;

  for(i=0;i<temp_num;i++)
  {
#ifdef MY_DEBUG
    printf (" stemp arr %s %s %d %d %d\n",
                       sstemp[i].down_scan, sstemp[i].name,
                       sstemp[i].type, sstemp[i].back, sstemp[i].direct_index);
#endif
    if(strcmp(sstemp[i].down_scan,".")) return(OM_S_SUCCESS);
  }

  dup   = NULL;
  dtemp = NULL;

  if(temp_num) 
  {
    dup   = _MALLOC ((num_up+rep_inc), struct sup);
    dtemp = _MALLOC (temp_num, struct stemp);
    if (!dup || !dtemp)
    { printf ("MALLOC FAILED \n"); return OM_E_ABORT;}
  }

  if(rep_inc) 
  {
    sprintf(dup[0].prompt,"~rep");
    strcpy(dup[0].up_scan,".");
    dtemp[0]=sstemp[0];
    dup[0].type=dtemp[0].type;
  }

  for(i=rep_inc;i<num_up+rep_inc;i++)
  {
    sprintf(dup[i].prompt,"PBOX%d",i);
    strcpy(dup[i].up_scan,".");
    dup[i].type=macro_generic;
  }

  for(i=rep_inc;i<temp_num;i++)
  {
    dtemp[i]=sstemp[i];
    for(j=rep_inc;j<num_up+rep_inc;j++)
    {
      m_1=-1;
#ifdef MY_DEBUG
  printf (" To give_struct %s\n", dtemp[i].name);
#endif

      status =
      om$send (msg = message NDmacro.ACgive_structure
                           (&suc,&m_1,dtemp[i].name,&r_value,md_env ),
          senderid = macro_defn.objid,
          targetid = temp_GRid[j-rep_inc].objid,
          targetos = temp_GRid[j-rep_inc].osnum );
      as$status();

      if(suc&1)
      {
        strcpy(dtemp[i].down_scan,dtemp[i].name);
        dtemp[i].back=j;
        goto Lsucc;
      }
    }
    printf("** VCedit failed to find %s in a para box \n", dtemp[i].name);
    return OM_E_ABORT;

    Lsucc:
    j=0;
  }

#ifdef MY_DEBUG
  printf (" To macdef - take template\n");
#endif

  status =
  om$send (msg = message ACmacro_defn.ACtake_template
                                    (num_up+rep_inc,dup,temp_num,dtemp),
      senderid = macro_defn.objid,
      targetid = macro_defn.objid,
      targetos = macro_defn.osnum  );
  as$status();

  if(temp_num) 
  {
    _FREE(dup); 
    _FREE(dtemp); 
  }

#ifdef MY_DEBUG
  printf (" Normal end VCedit\n");
#endif

  return OM_S_SUCCESS;
}/* end VCedit */


/* ========================================================================= */

IGRint  VCtest_macro (char       *mac_name,    /* I  this is the macro name */
                      int         num_up,      /* I   */
              struct  GRid       *temp_GRid,   /* I   */
              struct  GRmd_env   *md_env)
{
  IGRint      temp_num, status,i,j,m_1,suc,rep_inc;
  char        full_name[DI_PATH_MAX];

  struct GRid        macro_defn,def_GRid;
  struct stemp      *sstemp;
  struct ret_struct  r_value;

  /*" Test macro : %s\n",mac_name */
  status = 
  ac$find_macro_defn (action    = ACfind_load,
                   macro_name   = mac_name,
              p_macro_defn_id   = &macro_defn );
  as$status( action = RET_STATUS );

  /*| Get templates' names */
  status =
  om$send(  msg = message ACcpx_defn.ACgive_temp_desc (&temp_num, &sstemp),
       senderid = macro_defn.objid,
       targetid = macro_defn.objid,
       targetos = macro_defn.osnum );
  as$status( action = RET_STATUS );

  rep_inc=0;
  if(!strcmp("~rep",sstemp[0].name)) 
  {
    /*| Theirs a ~rep in here  */
    rep_inc=1;
  }

  /* -- Get Default Parameters Collection Id -- */

  status =
  di$untranslate(objid = macro_defn.objid,
                 osnum = macro_defn.osnum,
               objname = full_name);

  def_GRid.objid=NULL_OBJID;

  if (status & OM_S_SUCCESS)
  { 
    strcat(full_name,"$def");
    status = 
    di$translate (objname = full_name,
                  p_objid = &def_GRid.objid,
                  p_osnum = &def_GRid.osnum);
    if (status & OM_S_SUCCESS)
    {
      /*"def_id was %d %d\n",def_GRid.objid,def_GRid.osnum */
    }
  }

  /* -- Scan for Templates' existence int he specified template objects -- */

  for(i=rep_inc;i<temp_num;i++)
  {
    /* -- Try to find the template name in one of the specified objects -- */
    for(j=0;j<num_up;j++)
    {
      m_1=-1;
      /*"temp name  %s\n", sstemp[i].name */
      status =
      om$send (msg = message NDmacro.ACgive_structure
                               (&suc,&m_1,sstemp[i].name,&r_value,md_env ),
          senderid = macro_defn.objid,
          targetid = temp_GRid[j].objid,
          targetos = temp_GRid[j].osnum );
      as$status();

      if(suc&1)
      {
        goto Lsucc;
      }
    }/* end loop on template objects */

    printf ("-------> template %s is missing <-------\n",sstemp[i].name);

    Lsucc:
    j=0;
  }

  return OM_S_SUCCESS;
}/* end VCtest */


/*  ----------------------------------------------------------------------  */
/*  This function must be called first with NULL as TempNames to get back the 
/*  number of templates (NbTemp) and allocate a big enough array of TempNames */
/*  ----------------------------------------------------------------------  */

IGRint  VCGetTempNames (char     *mac_name,  /* I  this is the macro name */
                        int      *NbTemp,    /* O  */
                        IGRchar  *TempNames[])
{
  IGRint      status;

  struct GRid     macro_defn;
  struct stemp    *sstemp;

  /*" Macro name : %s\n",mac_name */
  status = 
  ac$find_macro_defn (action    = ACfind_load,
                   macro_name   = mac_name,
              p_macro_defn_id   = &macro_defn );
  as$status( action = RET_STATUS );

  /*| Get templates' names */
  status =
  om$send (msg = message ACcpx_defn.ACgive_temp_desc (NbTemp, &sstemp),
      senderid = macro_defn.objid,
      targetid = macro_defn.objid,
      targetos = macro_defn.osnum );
  as$status( action = RET_STATUS );

  /*" %d templates\n", *NbTemp */

  /* -- If TempNames array is specified, fill it with the names -- */

  if ( TempNames )
  {
    register IGRint  i;

    /*| Return the template names */

    for ( i=0; i<*NbTemp; i++ )
    {
       TempNames[i] = sstemp[i].name;
    }

  }/* end return TempNames */

  return OM_S_SUCCESS;

}/* end VCGetTempNames */

end implementation Root;

