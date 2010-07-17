
/* $Id: VCTexpand.I,v 1.2 2001/02/20 01:11:34 build Exp $  */

/* --------------------------------------------------------------------
 * I/CABLE
 *
 * File:  vcterm/VCTexpand.I
 *
 * Description:
 *
 *  This function will scan an equipment object and place real
 *  counterparts of embedded dummy terminals.
 *
 *  This will generate extermal terminals from the embedded
 *      VCTembed object each time an equipment instance is placed.
 *
 * Revision History:
 *     $Log: VCTexpand.I,v $
 *     Revision 1.2  2001/02/20 01:11:34  build
 *     Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *     Revision 1.1.1.1  2001/01/04 21:12:38  cvs
 *     Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.5  1998/04/20  04:18:28  pinnacle
# Replaced: vcterm/VCTexpand.I for:  by kddinov for route
#
# Revision 1.4  1997/12/10  11:17:48  pinnacle
# Replaced: vcterm/VCTexpand.I for:  by apazhani for route
#
# Revision 1.3  1997/12/03  17:10:08  pinnacle
# Replaced: vcterm/VCTexpand.I for:  by r250_int for route
#
# Revision 1.7  1997/12/02  21:54:28  pinnacle
# Replaced: vcterm/VCTexpand.I for:  by vc241 for cabling
#
# Revision 1.6  1997/11/26  18:42:26  pinnacle
# Replaced: vcterm/VCTexpand.I for:  by apazhani for cabling
#
# Revision 1.4  1997/07/14  22:09:00  pinnacle
# Replaced: vcterm/VCTexpand.I for:  by hverstee for cabling
#
# Revision 1.3  1997/05/22  15:22:44  pinnacle
# Replaced: vcterm/VCTexpand.I for:  by hverstee for cabling
#
# Revision 1.2  1997/05/19  13:50:38  pinnacle
# Replaced: vcterm/VCTexpand.I for:  by hverstee for cabling
#
 *
 * History:
 *  MM/DD/YY  AUTHOR    DESCRIPTION
 *  11/24/97  Alwin     The way the embedded terminals working has been modified
 *                      Presently, When the Equipment containing the embedded
 *                      Terminal is placed using the "Place PID Eqpt" command,
 *                      when we find the VCEmbed in the foot list of the Eqpt
 *                      the control gets transferred to place the Terminal 
 *                      directly as a child of the Route PID Equipment.
 *  12/10/97  Alwin     Scaling of the Terminals has been done.
 *
 * -------------------------------------------------------------------*/

class implementation VCTerm;

#include "vrdbgmacros.h"
#include "VCproto.h"
#include "vc_default.h"

/*
#define MY_DEBUG
*/

from     ACcpx_defn  import  ACgive_feet_desc;

from     VCEmbed     import  VCETGetIns;
from     VCEmbed     import  VCETGetMat;
from     VCEmbed     import  VCEGiveAtt;

  extern OM_S_CHANSELECT   AC_mto_graf_chns;

  extern GRclassid   OPP_ACconst_class_id;
  extern GRclassid   OPP_ACheader_class_id;
  extern GRclassid   OPP_VCEmbed_class_id;
  extern GRclassid   OPP_VDequipment_class_id;
  extern GRclassid   OPP_VREquipment_class_id;
  extern GRclassid   OPP_VCTerm_class_id;
  extern GRclassid   OPP_VCElTerm_class_id;
  extern GRclassid   OPP_VCFoTerm_class_id;

extern int ACread();
extern IGRint   VCGetDefaultInfo( IGRint, IGRint, char *);


IGRint   VC_termexpand (IGRlong      *msg,
                        IGRint       *nNum,
                 struct GRid         *MACRO_ID,
                 struct GRmd_env     *MOD_ENV)
{
  IGRlong       retmsg;
  IGRint        status;
  IGRint        i, j;
  OMuint        Size;
  IGRint        iSize;
  IGRshort      nSYS, nUSR;
  IGRint        NumFeet;
  GRclassid     ClassId;
  GRclassid     TermClassId;
  IGRshort      nMatType;
  IGRdouble     dMatrix[16];
  IGRdouble     dMAT[16];
  IGRchar       ClassName[100];
  IGRboolean    bEquip;
  IGRshort      xxType;

  struct ACrg_coll         SysAttrib[200];
  struct ACrg_coll         UsrAttrib[200];
  struct GRid              TempList[5];
  struct VCET_ins          EmbInstance;
  struct VCGenInfo         TermIns;
  struct GRsymbology       Symb;

  struct GRid      GraphicsId;  /* Macro occurrence Id */
  struct GRid      FootId;      /* Macro's foot Id     */
  struct GRid      DefId;       /* macro definition Id */
  struct GRid      RefId;       /* pretend parent Id   */
  struct GRid      TermId;      /* Created Term Id     */
  struct GRid      CsId;        /* Parent CS id        */
  struct myfeet   *FeetDesc;

  OM_S_OBJECT_LINKAGE       GRnots[500];

   SetProc( VC_termexpand ); Begin 

  /* -- Initialize templates -- */

  *msg  = MSSUCC;
  *nNum = 0;

  bEquip = FALSE;

  for ( i=0; i<5; i=i+1 )
  {
    TempList[i].objid = NULL_OBJID;
    TempList[i].osnum = MOD_ENV->md_id.osnum;
  }

  /* ------------------- KLUDGE : If it is an equipment, get its macro foot */

  /* This kludge should be replaced by getting all objects on the
     owner-component graph ( deep scann ) */

  om$get_classid(  objid  = MACRO_ID->objid,
                   osnum  = MACRO_ID->osnum,
                p_classid = &ClassId);

  /*      VRequipment ??????   */

  if ( ClassId == OPP_VDequipment_class_id )
  { /*| for equipments, go deeper in the owner graph to find the graphics */

    __DBGpr_com( " It's VDS Equipment " );
    status =
    om$get_channel_count( osnum   = MACRO_ID->osnum,
                          objid   = MACRO_ID->objid ,
                     p_chanselect = &AC_mto_graf_chns,
                          count   = &Size );

    iSize = Size;

    /* verify that there is only one foot */
    if (Size != 1)
    {
      printf ("Not Implemented\n");
      return (OM_S_SUCCESS);
    }

    /* Get the graphics macro id */
    ACread (&MACRO_ID, &AC_mto_graf_chns, &GraphicsId, iSize);
    bEquip = TRUE;
    xxType = VC_TERM_EQ;
  }
  else
  if ( ClassId == OPP_VREquipment_class_id )
  {
    OMuint     nnc;

    __DBGpr_com( " It's a Route PID Equipment " );
    status =
    om$get_channel_objects( objid    = MACRO_ID->objid,
                            osnum    = MACRO_ID->osnum,
                        p_chanselect = &AS_to_comp,
                                list = GRnots,
                              size   = 500,
                              count  = &nnc);

    NumFeet = nnc;

    GraphicsId.objid = GRnots[0].S_objid;
    GraphicsId.osnum = GRnots[0].osnum;

    bEquip = TRUE;
    xxType = VC_TERM_RE;
  }
  else
  {
    IGRint        NbRoots;

    struct GRid  *buffer;

    GraphicsId.objid = MACRO_ID->objid;
    GraphicsId.osnum = MACRO_ID->osnum;
    bEquip = FALSE;
    xxType = VC_TERM_CS;

    status =
    om$send (msg = message NDnode.NDget_objects
                                   (ND_ROOT | ND_IN_BUF, NULL, 0, &buffer,
                                    0, OM_K_MAXINT, &NbRoots ),
        senderid = NULL_OBJID,
        targetid = GraphicsId.objid,
        targetos = GraphicsId.osnum );

    if (NbRoots > 0)
      CsId = buffer[NbRoots-1];
  }

#ifdef  MY_DEBUG
  om$get_classname( objid   = GraphicsId.objid,
                    osnum   = GraphicsId.osnum,
                  classname = ClassName);
  printf ("POST PLACEMENT for Object<%d,%d> = <%s>\n",
           GraphicsId.objid,GraphicsId.osnum, ClassName );
#endif

  /* -------------------end of kludge */

  if (bEquip)
  {
    /* We have to go through the macro definition in the case the graphics
       is an ACheader (no feet connected to it */

    /* -- Get definition of the graphic macro -- */

    status =
    om$send ( msg = message ACcpx.find_macro ( &DefId ),
         senderid = NULL_OBJID,
         targetid = GraphicsId.objid,
         targetos = GraphicsId.osnum );

#ifdef  MY_DEBUG
      printf ("Def <%d,%d>\n", DefId.objid,DefId.osnum );
#endif

    status =
    om$send ( msg = message ACcpx_defn.ACgive_feet_desc(&NumFeet, &FeetDesc),
         senderid = NULL_OBJID,
         targetid = DefId.objid,
         targetos = DefId.osnum );
  }
  else
  {
    OMuint     nnc;

    status =
    om$get_channel_objects( objid    = GraphicsId.objid,
                            osnum    = GraphicsId.osnum,
                        p_chanselect = &AS_to_comp,
                                list = GRnots,
                              size   = 500,
                              count  = &nnc);

    NumFeet = nnc;

    DefId.objid = GraphicsId.objid;
    DefId.osnum = GraphicsId.osnum;
  }

  /* -- Get feet names from definition -- */

#ifdef  MY_DEBUG
  printf (" Returned feet %d\n",NumFeet);
#endif

  /* -- Loop on macro's feet -- */
  for ( i=0; i<NumFeet; i=i+1 )
  {
    /* -- Get the foot id -- */

    if (bEquip)
    {
#ifdef  MY_DEBUG
      printf ("Foot[%d]\t Name <%s>\n Type <%d>\n Pos :<%d>\n Prop <%d>\n",
                    i, FeetDesc[i].name, FeetDesc[i].chan,
                       FeetDesc[i].pos, FeetDesc[i].prop );
#endif

      status =
      om$send ( msg = message NDmacro.ACreturn_foot
                                       (&retmsg, FeetDesc[i].name,
                                        &FootId,&nMatType, dMatrix),
           senderid = NULL_OBJID,
           targetid = GraphicsId.objid,
           targetos = GraphicsId.osnum );
    }
    else
    {
      FootId.objid = GRnots[i].S_objid;
      FootId.osnum = GRnots[i].osnum;
    }

#ifdef  MY_DEBUG
    om$get_classname( objid   = FootId.objid,
                      osnum   = FootId.osnum,
                    classname = ClassName);
    printf ("Object<%d,%d> = <%s>\n", FootId.objid,FootId.osnum, ClassName );

    VC_printmat (" EMBEDDED ",dMatrix);

#endif

    /* -- Get foot class -- */

    om$get_classid(  objid  = FootId.objid,
                     osnum  = FootId.osnum,
                  p_classid = &ClassId);

    /* -- For each foot which is a VCEmbed : -- */

    if ( ClassId == OPP_VCEmbed_class_id )
    {
      TermId.objid = NULL_OBJID;
      TermId.osnum = FootId.osnum;

      /* -- Generate attributes collections -- */

      /* Get instance from VCEmbed */

      __DBGpr_com( " It's Embedded Terminal " );
      status =
      om$send (msg = message VCEmbed.VCETGetIns (&retmsg, &EmbInstance),
          senderid = NULL_OBJID,
          targetid = FootId.objid,
          targetos = FootId.osnum );

      /* get attributes */
      status =
      om$send (msg = message VCEmbed.VCEGiveAtt
                              (&retmsg, &nSYS, SysAttrib, &nUSR, UsrAttrib),
          senderid = NULL_OBJID,
          targetid = FootId.objid,
          targetos = FootId.osnum );

      /* Before creating the collections we can set the pid-scale value,
      obtaining it from the Parent Equipment. This is only needed for Terminals
      which has ROUTE PID Equipment as their parent. Alwin */
 
      if( bEquip )
      {
        IGRint Index=-1;
        IGRlong retmsg;
        struct ret_struct AttrSt;
 
        __DBGpr_obj( " Equipment Id ", *MACRO_ID );
        status =
        om$send ( msg = message ACncpx.ACgive_structure( (IGRint*)&retmsg,
                                             &Index, VR_N_PID_SCALE_DB,
                                             &AttrSt, MOD_ENV ),
                                 senderid = NULL_OBJID,
                                 targetid = MACRO_ID->objid,
                                 targetos = MACRO_ID->osnum );
 
        __DBGpr_dbl( "Route Eqpt. Scale factor ", AttrSt.var.root_pm_st.value );
 
        if( AttrSt.var.root_pm_st.value != 1 )
        {
           IGRint ii;
           IGRboolean bPidScale=FALSE;
           IGRdouble TerminalScale=1.0;
           struct ret_struct TerminalSt;
           struct ACrg_coll list_att[2];

           /* Get the Terminal's pid-scale value, if it exists */
           status =
           om$send ( msg = message ACncpx.ACgive_structure( (IGRint*)&retmsg,
                                             &Index, VR_N_PID_SCALE_DB,
                                             &TerminalSt, MOD_ENV ),
                                 senderid = NULL_OBJID,
                                 targetid = FootId.objid,
                                 targetos = FootId.osnum );
 
           if( retmsg & status &  1 )
             TerminalScale = TerminalSt.var.root_pm_st.value;
 
           __DBGpr_dbl( "Terminals PID scale factor", TerminalScale );
 
           for( ii=0; ii<nSYS && !bPidScale; ii++ )
           {
              if( !strcmp( SysAttrib[ii].name, VR_N_PID_SCALE_DB ) )
              {
                __DBGpr_com( " Attribute already exists in the collector ");
 
                strcpy( SysAttrib[ii].name, VR_N_PID_SCALE_DB );
                SysAttrib[ii].desc.type = AC_ATTRIB_DOUBLE;
                SysAttrib[ii].desc.value.att_exp = AttrSt.var.root_pm_st.value *
                                            TerminalScale;
 
                bPidScale = TRUE;
              }
           }
 
           /* In case if the attribute is listed/present in the collector, then
           add it into the list of attributes which are going to form the
           Collector */
           if( !bPidScale )
           {
             __DBGpr_com( " Attribute added to the collector ");
 
             strcpy( SysAttrib[nSYS].name, VR_N_PID_SCALE_DB );
             SysAttrib[nSYS].desc.type = AC_ATTRIB_DOUBLE;
             SysAttrib[nSYS].desc.value.att_exp = AttrSt.var.root_pm_st.value *
                                         TerminalScale;
             nSYS++;
           }
 
        } /* If Equipment scale != 1 loop ends */
      }/* If ROUTE PID Equipment loop ends */

      /* create collections */

      status =
      VC_CreateColl (&retmsg, nSYS, SysAttrib, &TempList[0]);

      status =
      VC_CreateColl (&retmsg, nUSR, UsrAttrib, &TempList[1]);

      status = 
      om$send ( msg = message GRvg.GRgetsymb (&retmsg, &Symb ),
           senderid = NULL_OBJID,
           targetid = FootId.objid,
           targetos = FootId.osnum );

      /* -- Place a term -- */

      TermIns.nStat     = VC_STATUS_INIT;
      TermIns.nType     = VC_GEN_TERM | VC_GEN_EXTERN |
                           xxType | VC_TOFF_C_FULL;

      TermIns.nNbAttr   = 2;
      TermIns.nNbTopo   = 1;
      TermIns.nProduct  = EmbInstance.Product;;
      TermIns.bNoMtoFlg = FALSE;

      strcpy (TermIns.szCode, EmbInstance.szCode);
      strcpy (TermIns.szTagno, EmbInstance.szTag);

      status =
      om$send (msg = message ACncpx.ACget_NV_rep
                      ((unsigned char *) &TermIns.cRep),
          senderid = NULL_OBJID,
          targetid = MACRO_ID->objid,
          targetos = MACRO_ID->osnum );
      as$status ();

      if (TermIns.cRep == 0) TermIns.cRep = 4;

      TermIns.Attr.Term.nCpt = 0;

      /*    offsets from cs.......    */

      status =
      om$send (msg = message VCEmbed.VCETGetMat (&retmsg, dMAT),
          senderid = NULL_OBJID,
          targetid = FootId.objid,
          targetos = FootId.osnum );

      TermIns.Attr.Term.nOff    = 16;
      TermIns.Attr.Term.dOffVal = dMAT;

      /* get the right object to connect to */

      if (bEquip)
      {
        status =
        om$send (msg = message ASnode.ACgive_path
                              ( (IGRint *) &retmsg, &GraphicsId, ClassName  ),
            senderid = NULL_OBJID,
            targetid = MACRO_ID->objid,
            targetos = MACRO_ID->osnum );

        strcat (ClassName, ":");
        strcat (ClassName, FeetDesc[i].name);
#ifdef  MY_DEBUG
        printf (" Foot path = <%s>\n", ClassName );
#endif

         status =
         om$send ( msg = message ASnode.ACconnect_pretend
                                ( (IGRint *) &retmsg, ClassName, &RefId  ),
              senderid = NULL_OBJID,
              targetid = MACRO_ID->objid,
              targetos = MACRO_ID->osnum );

#ifdef  MY_DEBUG
        printf ("RefId = <%d,%d>\n", RefId.objid,RefId.osnum );
#endif

        TempList[2] = RefId;
      }
      else
        TempList[2] = CsId;

      for( j=0; j<3; j++ )
      {
         __DBGpr_int( " Parent No. ", j );
         __DBGpr_obj( " Parent Object. ", TempList[j] );
      }

/* 4-98 KDD use single point default selection function
*      if (EmbInstance.Product == VC_PROD_ELEC)
*        TermClassId = OPP_VCElTerm_class_id;
*      else
*        TermClassId = OPP_VCFoTerm_class_id;
*/

      status = VCGetDefaultInfo( EmbInstance.Product,
                                VC_GET_TERM_CLASS_ID, (char *) &TermClassId);


      __DBGpr_com( " Creating the Terminal " );
      status =
      VC_CreateTerm (&retmsg, 3, TempList, &TermIns, Symb.level,
                      &Symb.display_attr, MOD_ENV, &TermId);

      if ( ! (status&1) || (retmsg != MSSUCC) )
      {
        printf ("Terminal placement failed \n");
        if ( TermId.objid != NULL_OBJID )
          printf ("DELETE TERMINAl\n");

        continue;
      }

      status =
      om$send( msg = message NDnode.NDdisplay(0,GRbd,MOD_ENV),
          senderid = NULL_OBJID,
          targetid = TermId.objid,
          targetos = TermId.osnum);

      (*nNum)++;

    }/* end generate Terminal */
    else
    if (om$is_ancestry_valid
           (subclassid = ClassId,
          superclassid = OPP_VCTerm_class_id ) == OM_S_SUCCESS)
    {
      IGRboolean    bCreate;

      bCreate = TRUE;

      status =
      VCT_virtualize (&retmsg, bCreate, &FootId, MOD_ENV, 
                                        &TermId, MOD_ENV);

      if (retmsg == MSSUCC) (*nNum)++;
    }


  }/* end loop on feet */

  End
  return OM_S_SUCCESS;

}/* end post_placement */

end implementation VCTerm;

