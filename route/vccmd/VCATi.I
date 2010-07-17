
/* $Id: VCATi.I,v 1.2 2001/02/20 01:09:24 build Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:  vccmd/VCATi.I
 *
 * Description:
 *      Implementation file for command objects that handle attributes
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VCATi.I,v $
 *  Revision 1.2  2001/02/20 01:09:24  build
 *  Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *  Revision 1.1.1.1  2001/01/04 21:12:27  cvs
 *  Initial import to CVS
 *
# Revision 1.3  1999/11/10  12:49:52  pinnacle
# Replaced: vccmd/VCATi.I for:  by svngidug for route
#
# Revision 1.2  1998/12/22  16:59:54  pinnacle
# Replaced: vccmd/VCATi.I for:  by lawaddel for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/11/30  16:07:40  pinnacle
# Replaced: vccmd/VCATi.I for:  by r250_int for route
#
# Revision 1.11  1997/11/07  19:37:14  pinnacle
# Replaced: vccmd/VCATi.I for:  by apazhani for cabling
#
# Revision 1.10  1997/07/22  16:05:02  pinnacle
# Replaced: vccmd/VCATi.I for:  by hverstee for cabling
#
# Revision 1.9  1997/07/14  22:50:44  pinnacle
# Replaced: vccmd/VCATi.I for:  by hverstee for cabling
#
# Revision 1.8  1997/05/22  14:44:18  pinnacle
# Replaced: vccmd/VCATi.I for:  by hverstee for cabling
#
# Revision 1.7  1997/05/19  14:06:48  pinnacle
# Replaced: vccmd/VCATi.I for:  by hverstee for cabling
#
# Revision 1.6  1997/04/28  22:35:24  pinnacle
# Replaced: vccmd/VCATi.I for:  by hverstee for cabling
#
# Revision 1.5  1997/03/12  21:59:52  pinnacle
# Replaced: vccmd/VCATi.I for:  by hverstee for cabling
#
# Revision 1.4  1997/01/23  23:51:14  pinnacle
# Replaced: vccmd/VCATi.I for:  by hverstee for cabling
#
# Revision 1.3  1997/01/09  23:05:20  pinnacle
# Replaced: vccmd/VCATi.I for:  by hverstee for cabling
#
# Revision 1.2  1997/01/09  19:57:40  pinnacle
# Replaced: vccmd/VCATi.I for:  by hverstee for cabling
#
 *
 * History:
 *  12/20/96      hv      New
 *  11/08/97      Alwin   Modified the method VCAT_load to get the proper
 *                        terminal, so that it will get us the right parent,
 *                        which will prevent the crash.
 *  12/02/98      law     CR179802404 - Put VC_N_PID_ANGLE_DB in collection
 *                        for communicating from form to placement.
 *  11/08/99      Satish  Modified the method VCAT_getcoll for CR179702190  
 *************************************************************************/

class implementation VCAT;

#include "VCCmdForm.h"

#include "VDmem.h"
#include "vrdbgmacros.h"

%safe
#include "VX_FIproto.h"
%endsafe

/*
#define  MY_DEBUG
*/

from  ACrg_collect  import  ACset_list_attribute;
from  ACrg_collect  import  AClist_attribute;
from  ACrg_collect  import  GRchgname;
from  ACrg_collect  import  ACcreate;

from  VCRoot        import  VCGetParams;
from  VCRoot        import  VCGetMtoFlag;

from  NDnode        import  NDget_objects;
from  NDnode        import  NDdelete;
from  NDnode        import  NDchg_state;
from  NDmacro       import  ACreturn_foot; //added by alwin

extern GRclassid            OPP_ACrg_collect_class_id;



/*C  Initialize my instance  */
method init (int   type; char * strptr)
{
  IGRint             status;
  IGRlong            retmsg;

  struct GRsymbology esymb;

  me->iSynType       = type;

  status =
  om$send(  msg = message VDS_LOCATE.init ( type, strptr ) ,
           mode = OM_e_wrt_message,
       targetid = my_id);

  me->bSyschg        = FALSE;
  me->bUsrchg        = FALSE;

  me->bSysUp         = FALSE;
  me->bUsrUp         = FALSE;

  me->nSysref        = 0;
  me->nUsrref        = 0;

  me->My_OS        = me->ModuleInfo.md_id.osnum;
  me->CATenv       = me->ModuleInfo;

  ac$get_def_rep(prep = &(me->nACTrep), esymb = &esymb);

  me->SysCId.objid = NULL_OBJID;
  me->SysCId.osnum = me->My_OS;
  me->UsrCId.objid = NULL_OBJID;
  me->UsrCId.osnum = me->My_OS;

  /*    get the active collections     */

  status =
  om$send(  msg = message VCAT.VCAT_act (&retmsg),
       targetid = my_id);

  me->RefCId.objid = NULL_OBJID;
  me->RefCId.osnum = me->My_OS;

  return OM_S_SUCCESS;
}

method VCAT_set (IGRlong     *msg;
                 IGRint       nSys_usr;
                 IGRchar     *szNam;
                 IGRint       nType;
                 IGRchar     *szVal;
                 IGRdouble    dAtt)
{
  IGRint      status;
  IGRint      num, i;

  *msg = MSFAIL;

  if ((szNam == NULL) && (szVal == NULL))
  {
    *msg = MSSUCC;

    if (nSys_usr == VC_SYSTEM)
    {
      status =
      om$vla_set_dimension (varray = me->Syscoll,
                            size   = 0);
    }
    else
    {
      status =
      om$vla_set_dimension (varray = me->Usrcoll,
                            size   = 0);
    }
  }
  else
  {

    if (nSys_usr == VC_SYSTEM)
    {
      num = om$dimension_of (varray = me->Syscoll);

      for (i=0; i<num; i++)
      {
        if (strcmp (szNam, me->Syscoll[i].name) == 0)
        {
          *msg = MSSUCC;

          me->Syscoll[i].desc.type = nType;
          if (nType == AC_ATTRIB_TEXT)
            strcpy (me->Syscoll[i].desc.value.att_txt, szVal);
          else
            me->Syscoll[i].desc.value.att_exp = dAtt;

          me->bSyschg    = TRUE;
          goto quit;
        }
      }

      status =
      om$vla_set_dimension (varray = me->Syscoll,
                            size   = num+1);

      *msg             = MSSUCC;
      strcpy (me->Syscoll[num].name, szNam);
      me->Syscoll[num].desc.type = nType;

      if (nType == AC_ATTRIB_TEXT)
        strcpy (me->Syscoll[num].desc.value.att_txt, szVal);
      else
        me->Syscoll[num].desc.value.att_exp = dAtt;

      me->bSyschg      = TRUE;

    }
    else
    {
      num = om$dimension_of (varray = me->Usrcoll);
      for (i=0; i<num; i++)
      {
        if (strcmp (szNam, me->Usrcoll[i].name) == 0)
        {
          *msg = MSSUCC;

          me->Usrcoll[i].desc.type = nType;
          if (nType == AC_ATTRIB_TEXT)
            strcpy (me->Usrcoll[i].desc.value.att_txt, szVal);
          else
            me->Usrcoll[i].desc.value.att_exp = dAtt;

          me->bUsrchg    = TRUE;
          goto quit;
        }
      }

      status =
      om$vla_set_dimension (varray = me->Usrcoll,
                            size   = num+1);

      *msg             = MSSUCC;

      strcpy (me->Usrcoll[num].name, szNam);
      me->Usrcoll[num].desc.type = nType;

      if (nType == AC_ATTRIB_TEXT)
        strcpy (me->Usrcoll[num].desc.value.att_txt, szVal);
      else
        me->Usrcoll[num].desc.value.att_exp = dAtt;

      me->bUsrchg      = TRUE;
    }
  }

  quit:
  return OM_S_SUCCESS;
}

method VCAT_get (IGRlong     *msg;
                 IGRint       nSys_usr;
                 IGRint       nCode;
                 IGRchar    *szName;
                 IGRint     *nATnum;
          struct ACrg_coll  *Attr)
{
  IGRint      num, i;
  IGRchar    *pLOC;

  *msg    = MSFAIL;
  *nATnum = 0;
  pLOC    = NULL;

  /*   kick out double spec    */

  if (szName != NULL)
    pLOC = szName;
  else
  if (nCode >= 0)
  {
    pLOC = VCDB_AttrNumToNam ((IGRshort) nCode);
    if (pLOC == NULL)  return OM_S_SUCCESS;
  }

  *msg = MSSUCC;

  if (nSys_usr == VC_SYSTEM)
  {
    num = om$dimension_of (varray = me->Syscoll);

    for (i=0; i<num; i++)
    {
      if ((pLOC == NULL) || (strcmp (pLOC, me->Syscoll[i].name) == 0))
      {
        Attr[*nATnum] = me->Syscoll[i];
        (*nATnum)++;
      }
    }
  }
  else
  {
    num = om$dimension_of (varray = me->Usrcoll);

    for (i=0; i<num; i++)
    {
      if ((pLOC == NULL) || (strcmp (pLOC, me->Usrcoll[i].name) == 0))
      {
        Attr[*nATnum] = me->Usrcoll[i];
        (*nATnum)++;
      }
    }
  }

  return OM_S_SUCCESS;
}


method  VCAT_act  (IGRlong     *sts)
{
  IGRint             status;
  IGRlong            retmsg;

  SetProc( VCAT_act ); Begin

  __DBGpr_com( "Calling Fn VC_AT_getact SYSTEM" );

  status =
  VC_AT_getact (&retmsg, VC_SYSTEM, me->My_OS, &me->SysCId);

  __DBGpr_com( "Calling Fn VC_AT_getact USER" );

  status =
  VC_AT_getact (&retmsg, VC_USER, me->My_OS, &me->UsrCId);

  me->SysACT = me->SysCId;
  me->UsrACT = me->UsrCId;

  __DBGpr_com( "Calling Md VCAT_getcoll USER" );

  status =
  om$send (msg = message VCAT.VCAT_getcoll (sts),
      targetid = my_id);

  End
  return OM_S_SUCCESS;
}


method VCAT_load (IGRlong     *sts;
           struct GRid        *RefId)
{
  IGRint             status;
  IGRshort           iNum;
  IGRlong            retmsg;

  struct GRid        ParamId[2];

  SetProc( VCAT_load ); Begin

#ifdef MY_DEBUG
  printf (" Ref Id.objid %d\t", RefId->objid);
  printf (" Ref Id.osnum %d\t\n", RefId->osnum);
#endif

  __DBGpr_com( "Calling the Md VCRoot.VCGetParams" );
  __DBGpr_int(" Reference Id.objid ", RefId->objid );
  __DBGpr_int(" Reference Id.osnum ", RefId->osnum );

  iNum=0;
  ParamId[0].objid = NULL_OBJID;
  ParamId[1].objid = NULL_OBJID;

  /* This will get the Real Object from associative grapphic object, in case
  if there is one. Or else if we pass the graphic object itself it will return
  graphic object as the output. added by alwin for TR179701970 */
  status = om$send ( msg = message NDmacro.ACreturn_foot( &retmsg, "", RefId,
                                     NULL, NULL ),
                                targetid = RefId->objid,
                                targetos = RefId->osnum);
  status =
  om$send (msg = message VCRoot.VCGetParams (&retmsg, &iNum, ParamId),
      targetid = RefId->objid,
      targetos = RefId->osnum);

  /* me->RefCId = *RefId; */    /* Commented for CR179702190 */
  /*************************************************************************
  *  The RefCId instance variable is set to NULL in the init method. Because
  *  this particular varible is not used  anywhere else, decided to use it 
  *  as a handle for distinguishing among various cases wrt CR179702190  
  *************************************************************************/

  me->SysCId = ParamId[0];
  me->UsrCId = ParamId[1];

  __DBGpr_int(" System Id.objid ", me->SysCId.objid );  
  __DBGpr_int(" System Id.osnum ", me->SysCId.osnum );  

  __DBGpr_int(" User Id.objid ", me->UsrCId.objid );  
  __DBGpr_int(" User Id.osnum ", me->UsrCId.osnum );

#ifdef MY_DEBUG
  printf (" In VCAT_load \t");
  printf (" sysc Id.objid %d\t", me->SysCId.objid);
  printf (" sysc Id.osnum %d\t\n", me->SysCId.osnum);
#endif
#ifdef MY_DEBUG
  printf (" In VCAT_load \t");
  printf (" sysact Id.objid %d\t", me->SysACT.objid);
  printf (" sysact Id.osnum %d\t\n", me->SysACT.osnum);
#endif
#ifdef MY_DEBUG
  printf (" In VCAT_load \t");
  printf (" usr Id.objid %d\t", me->UsrCId.objid);
  printf (" usr Id.osnum %d\t\n", me->UsrCId.osnum);
#endif
  __DBGpr_com( "Calling Md VCAT.VCAT_getcoll" );
  status =
  om$send (msg = message VCAT.VCAT_getcoll (sts),
      targetid = my_id);

  __DBGpr_com( "Calling Md VCRoot.VCGetMtoFlag" );
  status =
  om$send (msg = message VCRoot.VCGetMtoFlag (&me->bMTO, NULL),
      targetid = RefId->objid,
      targetos = RefId->osnum);

  End
  return OM_S_SUCCESS;
}


method  VCAT_coll (IGRlong     *sts;
            struct GRid        *Sys;
            struct GRid        *Usr)
{
  *sts = MSSUCC;

  *Sys = me->SysCId;
  *Usr = me->UsrCId;

  return OM_S_SUCCESS;
}



method VCAT_getcoll (IGRlong     *sts)
{
  IGRint             status;
  IGRint             iNum;
  IGRint             i;
  IGRint             j;
  IGRlong            retmsg;
  IGRboolean         bPID,bROT;
  /************************************************************************
  *  CR179702190 requires the additional label information NOT to be copied
  *  from the located object when the 'copy attributes' gadget is selected.
  *
  *  If a particular attribute is not to be copied:
  *  Define the attribute label in the SysAttribList array variable defined
  *  below and increase the count of nSysAttToRetain by ONE.
  *
  *  NOTE : The instance varible RefCId is used to distinguish 
  *  among the possible cases where VCAT_getcoll method is called. Its value 
  *  has been set in VCSALoadLnAttr method accordingly for the SetAtt
  *  command. For the place terminal/guide/backshell commands, RefCId value
  *  set in init method of VCAT class has not been touched anywhere else.
  *					       - Satish for CR179702190
  *************************************************************************/
  struct ACrg_coll   *colltmp;
  const IGRchar*     SysAttribList[] ={VC_N_ADD_LABEL_AN} ;
  const IGRint       nSysAttToRetain = 1;
  IGRint             itmp;

  /* The above variables are defined for the CR179702190 */
  /*************************************************************************/
  

  struct GRid       *buffer;

  SetProc( VCAT_getcoll ); Begin

  *sts = MSSUCC;
  bPID = FALSE;
  bROT = FALSE;

  me->bSyschg = FALSE;
  me->bUsrchg = FALSE;
  me->dPScale = 1.0;

  /*   get sys coll   */

  __DBGpr_com( "Calling Md ACrg_collect.AClist_attribute" );
  iNum = 0;
  __DBGpr_com( " AClist_attribute is being called with ... ");
  __DBGpr_obj( " SysCId ", me->SysCId);
  status =
  om$send (msg = message ACrg_collect.AClist_attribute
                                      (&retmsg, 0, NULL, &iNum),
      targetid = me->SysCId.objid,
      targetos = me->SysCId.osnum);

  __DBGpr_int( "No of Items in Sys Coll ", iNum );
  /*************************************************************************
  *  If 'my' instance variable Syscoll is already populated, store them into
  *  the local variable, colltmp for future use. Once the AClist_attributes
  *  method is called, Syscoll gets filled with the instance data of the
  *  located object.
  *              - Satish for CR179702190
  **************************************************************************/
  itmp=0;
  i= om$dimension_of (varray = me->Syscoll);
  __DBGpr_int( " Size of Syscoll array is ",i);
  __DBGpr_obj( " RefCId", me->RefCId);
  
  if( me->RefCId.objid==NULL_OBJID && i!=0 )
  {
    __DBGpr_com( " Getting the values in Syscoll before calling list attribs");
        colltmp = (struct ACrg_coll*) malloc( i * sizeof(struct ACrg_coll));
      for (itmp=0;itmp<i;itmp++)
      {
        colltmp[itmp] = me->Syscoll[itmp];
       __DBGpr_str( " Temp struct contains",colltmp[itmp].desc.value.att_txt);
      }

  }
  __DBGpr_int( " itmp = ",itmp);

  status =
  om$vla_set_dimension (varray = me->Syscoll,
                        size   = iNum);

  __DBGpr_com( "Calling Md ACrg_collect.AClist_attribute" );
  status =
  om$send (msg = message ACrg_collect.AClist_attribute
                              (&retmsg, iNum, me->Syscoll, &iNum),
      targetid = me->SysCId.objid,
      targetos = me->SysCId.osnum);

  /***********************************************************************
  *  Reset the attributes in the Syscoll instance varible according to the
  *  labels specified in the SysAttribList array above. For the time being
  *  only 'Additional Label' attribute needs to prevented from being over
  *  written by that of the located object.
  *            - Satish for CR179702190
  ************************************************************************/

  if( me->RefCId.objid == NULL_OBJID && itmp != 0)
  {
      for( j=0;j<nSysAttToRetain;j++)
      {
        for (i=0; i<iNum; i++)
        {
           if (strcmp (me->Syscoll[i].name, SysAttribList[j]) == 0)
           {
              strcpy( me->Syscoll[i].desc.value.att_txt ,
                                                colltmp[i].desc.value.att_txt);
              __DBGpr_str("Retained attrib is",
                                            me->Syscoll[i].desc.value.att_txt);
	      /* To make sure the values in syscoll are used while saving */
    		me->bSyschg = TRUE;
           }
        }
      }
  }


#ifdef MY_DEBUG
  printf (" def syscoll %d\n", iNum);
#endif
  /*** CR179802404-rotation added to collection as temporary value */
  for (i=0; i<iNum; i++)
  {
    /* Added for CR179802404 */
    if (strcmp (me->Syscoll[i].name, VC_N_PID_ANGLE_DB) == 0)
    {
      bROT = TRUE;
    }
    if (strcmp (me->Syscoll[i].name, VC_N_PID_SCALE_DB) == 0)
    {
      me->dPScale = me->Syscoll[i].desc.value.att_exp;
      bPID = TRUE;
    }
  }

  if ( bVC_IS_PID(me->nACTrep) && (!(bPID)))
  {  /*  add pid scale attribute   */
    status =
    om$vla_set_dimension (varray = me->Syscoll,
                          size   = iNum + 1);

    strcpy (me->Syscoll[iNum].name, VC_N_PID_SCALE_DB);

    me->Syscoll[iNum].desc.value.att_exp = me->dPScale;
    me->Syscoll[iNum].desc.type          = AC_ATTRIB_DOUBLE;
    iNum++;
    me->nSysref = 0;
    me->bSyschg = TRUE;
  }
  /* Added for CR179802404 rotation added */
  if ( bVC_IS_PID(me->nACTrep) && (!(bROT)))
  {  /*  add pid scale attribute   */
    status =
    om$vla_set_dimension (varray = me->Syscoll,
                          size   = iNum + 1);

    strcpy (me->Syscoll[iNum].name, VC_N_PID_ANGLE_DB);

    me->Syscoll[iNum].desc.value.att_exp = 0.0;
    me->Syscoll[iNum].desc.type          = AC_ATTRIB_DOUBLE;

    me->nSysref = 0;
    me->bSyschg = TRUE;
  }

  if (me->SysCId.osnum != me->My_OS)
  {
    me->nSysref = 0;
    me->bSyschg = TRUE;
  }
  else
  {
    status =
    om$send (msg = message NDnode.NDget_objects
                                (ND_CHILDREN | ND_IN_BUF, NULL, 0,
                                 &buffer, 0, OM_K_MAXINT, &me->nSysref ),
        targetid = me->SysCId.objid,
        targetos = me->SysCId.osnum);
  }

  /*   get usr coll   */

  __DBGpr_com( "Calling Md ACrg_collect.AClist_attribute" );
  status =
  om$send (msg = message ACrg_collect.AClist_attribute
                                      (&retmsg, 0, NULL, &iNum),
      targetid = me->UsrCId.objid,
      targetos = me->UsrCId.osnum);

  __DBGpr_int( "No of Items in User Coll ", iNum );
  status =
  om$vla_set_dimension (varray = me->Usrcoll,
                        size   = iNum);

  __DBGpr_com( "Calling Md ACrg_collect.AClist_attribute" );
  status =
  om$send (msg = message ACrg_collect.AClist_attribute
                              (&retmsg, iNum, me->Usrcoll, &iNum),
      targetid = me->UsrCId.objid,
      targetos = me->UsrCId.osnum);

#ifdef MY_DEBUG
  printf (" def usrcoll %d\n", iNum);
#endif

  if (me->UsrCId.osnum != me->My_OS)
  {
    me->nUsrref = 0;
    me->bUsrchg = TRUE;
  }
  else
  {
    status =
    om$send (msg = message NDnode.NDget_objects
                                (ND_CHILDREN | ND_IN_BUF, NULL, 0,
                                 &buffer, 0, OM_K_MAXINT, &me->nUsrref ),
        targetid = me->UsrCId.objid,
        targetos = me->UsrCId.osnum);
  }

  __DBGpr_int( " Value of  me->bUsrchg ",  me->bUsrchg );
  __DBGpr_int( " Value of  me->bSyschg ",  me->bSyschg );
  End
  return (OM_S_SUCCESS);
}



method VCAT_sav  (IGRlong     *sts)
{
  IGRint             status;
  IGRlong            retmsg;
  IGRint             NumAtt;
  IGRchar            szPathName[10];

  *sts = MSSUCC;

  VC_INITSTR (szPathName);

#ifdef MY_DEBUG
  printf (" Inside save method\t");
  printf (" sysc Id.objid %d\t", me->SysCId.objid);
  printf (" sysc Id.osnum %d\t\n", me->SysCId.osnum);
#endif

  if ((me->bSyschg) && (me->nSysref != 0))
  {
    me->SysCId.objid = NULL_OBJID;

    status =
    om$construct ( classid = OPP_ACrg_collect_class_id,
                   p_objid = &(me->SysCId.objid),
                   osnum   = me->SysCId.osnum,
                   msg     = message ACrg_collect.ACcreate
                                              (&retmsg,szPathName ) ) ;
#ifdef MY_DEBUG
  printf (" Constructed new SysCId\t");
  printf (" sysc Id.objid %d\t", me->SysCId.objid);
  printf (" sysc Id.osnum %d\t\n", me->SysCId.osnum);
  printf("path <%s>\n",szPathName );
#endif

    status =
    om$send( msg = message NDnode.NDchg_state
                           ((IGRchar)ND_DEL_NO_CH ,(IGRchar)~ND_DEL_NO_CH),
        targetid = me->SysCId.objid,
        targetos = me->SysCId.osnum ) ;
    as$status ();

    me->nSysref = 0;
  }

#ifdef MY_DEBUG
  printf (" Inside save method\t");
  printf (" sysact Id.objid %d\t", me->SysACT.objid);
  printf (" sysact Id.osnum %d\t\n", me->SysACT.osnum);
#endif

  if (me->SysCId.objid != me->SysACT.objid)
  {
    status =
    VC_AT_setact (&retmsg, VC_SYSTEM, me->SysCId.osnum,
                  &me->SysACT, &me->SysCId, &me->ModuleInfo);

    me->SysACT = me->SysCId;
  }


  if (me->bSyschg)
  {
    NumAtt = om$dimension_of (varray = me->Syscoll);

    status =
    om$send( msg = message ACrg_collect.ACset_list_attribute
                                       (&retmsg, NumAtt, me->Syscoll),
        targetid = me->SysCId.objid,
        targetos = me->SysCId.osnum ) ;

    me->bSyschg        = FALSE;
  }

  if ((me->bUsrchg) && (me->nUsrref != 0))
  {
    me->UsrCId.objid = NULL_OBJID;

    status =
    om$construct ( classid = OPP_ACrg_collect_class_id,
                   p_objid = &(me->UsrCId.objid),
                   osnum   = me->UsrCId.osnum,
                   msg     = message ACrg_collect.ACcreate
                                              (&retmsg,szPathName ) ) ;
    status =
    om$send( msg = message NDnode.NDchg_state
                           ((IGRchar)ND_DEL_NO_CH ,(IGRchar)~ND_DEL_NO_CH),
        targetid = me->UsrCId.objid,
        targetos = me->UsrCId.osnum ) ;
    as$status ();

    me->nUsrref = 0;
  }

  if (me->UsrCId.objid != me->UsrACT.objid)
  {
    status =
    VC_AT_setact (&retmsg, VC_USER, me->UsrCId.osnum,
                  &me->UsrACT, &me->UsrCId, &me->ModuleInfo);

    me->UsrACT = me->UsrCId;
  }

  if (me->bUsrchg)
  {
    NumAtt = om$dimension_of (varray = me->Usrcoll);

    status =
    om$send( msg = message ACrg_collect.ACset_list_attribute
                                       (&retmsg, NumAtt, me->Usrcoll),
        targetid = me->UsrCId.objid,
        targetos = me->UsrCId.osnum ) ;

    me->bUsrchg        = FALSE;
  }

  return (OM_S_SUCCESS);
}


method  VCAT_sdsp (IGRlong     *sts;
                   IGRchar     *fptr)
{
  IGRshort        iloop;
  IGRshort        iAttr;
  IGRint          inum;

  *sts = MSSUCC;
  inum = om$dimension_of (varray = me->Syscoll);

  for (iloop = 0; iloop < inum; iloop++)
  {
    iAttr = VCDB_AttrNamToNum (me->Syscoll[iloop].name);

#ifdef MY_DEBUG
    printf (" sysatt %d %d, %s %s\n", iloop, iAttr, 
                          me->Syscoll[iloop].name,
                          me->Syscoll[iloop].desc.value.att_txt);
#endif

    switch (iAttr)
    {
      case VC_X_UNIT_AN:
        FIg_set_text (fptr, VC_GDG_FLD_UNITNUMBER,
                                me->Syscoll[iloop].desc.value.att_txt);
        break;

      case VC_X_SYST_NAME_AN:
        FIg_set_text (fptr, VC_GDG_FLD_SYSNUMBER,
                                me->Syscoll[iloop].desc.value.att_txt);
        break;

      case VC_X_APPRV_STAT_AN:
        FIg_set_text (fptr, VC_GDG_FLD_APPSTAT,
                                me->Syscoll[iloop].desc.value.att_txt);
        break;

      case VC_X_CONSTR_STAT_AN:
        FIg_set_text (fptr, VC_GDG_FLD_CONSTR,
                                me->Syscoll[iloop].desc.value.att_txt);
        break;

      case VC_X_CHG_REQ_NUM_AN:
        FIg_set_text (fptr, VC_GDG_FLD_CHGNO,
                                me->Syscoll[iloop].desc.value.att_txt);
        break;

      case VC_X_COMP_NOTE_AN:
        FIg_set_text (fptr, VC_GDG_FLD_NOTES,
                                me->Syscoll[iloop].desc.value.att_txt);
        break;

      case VC_X_ADD_LABEL_AN:
        FIg_set_text (fptr, VC_GDG_FLD_ADDLABEL,
                                me->Syscoll[iloop].desc.value.att_txt);
        break;

      case VC_X_PID_SCALE_DB:
        FIg_set_value (fptr, VC_GDG_FLD_SCALE,
                                me->Syscoll[iloop].desc.value.att_exp);
        break;
    }
  }

  return (OM_S_SUCCESS);
}

method  VCAT_udsp (IGRlong     *sts;
                   IGRchar     *fptr)
{
  IGRint          iloop;
  IGRint          inum;

  *sts = MSSUCC;
  inum = om$dimension_of (varray = me->Usrcoll);

  FIfld_set_num_rows( fptr, VC_GDG_MFL_USERPAR, inum);

  for (iloop = 0; iloop < inum; iloop++)
  {
    FIfld_set_text (fptr, VC_GDG_MFL_USERPAR, iloop, 0,
                       me->Usrcoll[iloop].name, 0);

    if (me->Usrcoll[iloop].desc.type == AC_ATTRIB_TEXT)
      FIfld_set_text  (fptr, VC_GDG_MFL_USERPAR, iloop, 1,
                    me->Usrcoll[iloop].desc.value.att_txt, 0);
    else
      FIfld_set_value (fptr, VC_GDG_MFL_USERPAR, iloop, 1,
                    me->Usrcoll[iloop].desc.value.att_exp, 0);
  }

  return (OM_S_SUCCESS);
}

method VCAT_pid( IGRlong     *sts ) /* PID returncode    */
{

  if (bVC_IS_PID_ACTIVE)
    me->ret = *sts = VC_RTC_PID;
  else
    me->ret = *sts = VC_RTC_ALLOK;

  return (OM_S_SUCCESS);
}

method wakeup ( int pos )
{
  int     status;

  status = om$send (mode     = OM_e_wrt_message,
                    msg      = message VDS_LOCATE.wakeup( pos ),
                    targetid = my_id);

  if( pos & EX_suspend )
  {
    if (me->bSysUp)
      FIf_display( me->pSysAtt );
    if (me->bUsrUp)
      FIf_display( me->pUsrAtt );
  }

  return (OM_S_SUCCESS);
}

method sleep ( int pos )
{
  int             status;

  if( pos & EX_suspend )
  {
    if (me->bSysUp)
      FIf_erase ( me->pSysAtt );
    if (me->bUsrUp)
      FIf_erase ( me->pUsrAtt );
  }

  status = om$send (mode     = OM_e_wrt_message,
                    msg      = message VDS_LOCATE.sleep( pos ),
                    targetid = my_id);

  return (OM_S_SUCCESS);
}

end implementation VCAT;

