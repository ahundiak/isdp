
/* $Id: vdtblmacros.h,v 1.2 2001/02/20 23:08:53 ylong Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/include/vdtblmacros.h
 *
 * Description:
 *
 *     Include file to define function prototypes and retrieval macros for
 *     table layout parameters.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdtblmacros.h,v $
 *      Revision 1.2  2001/02/20 23:08:53  ylong
 *      added vd$tbl_get_hdr
 *
 *      Revision 1.1.1.1  2001/01/04 21:07:31  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.6  1998/01/04  15:30:14  pinnacle
 * growner.h
 *
 * Revision 1.5  1997/12/29  04:48:36  pinnacle
 * Replaced: include/vdtblmacros.h for:  by ksundar for vds
 *
 * Revision 1.4  1997/11/06  08:31:26  pinnacle
 * Replaced: include/vdtblmacros.h for:  by ksundar for vds
 *
 * Revision 1.3  1997/11/05  08:40:08  pinnacle
 * Replaced: include/vdtblmacros.h for:  by ksundar for vds
 *
 * Revision 1.2  1997/10/21  03:45:06  pinnacle
 * Replaced: include/vdtblmacros.h for:  by ksundar for vds
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.1  1995/08/25  15:00:22  pinnacle
 * Created: include/vdtblmacros.h by hverstee for vds.240
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR  DESCRIPTION
 *
 *      08/22/95        HV    	New
 *	10/13/97	Sundar	Added expression tables macros
 *	01/04/97	ah	Added growner.h to clear warnings
 * -------------------------------------------------------------------*/

#ifndef  vdtblmacros_h

#define  vdtblmacros_h

#include "growner.h"
#include "ACrg_collect.h"

/*
#include "v_miscmacros.h"
*/


/****************************************************************************/
/*      INTERFACE:    dlo == drawing table layout access                    */
/*                    stc == sort criteria                                  */
/*                    suc == summarization criteria                         */
/*                    ads == attribute driven symbolset                     */
/****************************************************************************/
/*                    --- Function prototypes ---                           */
/****************************************************************************/

extern IGRint  VDtbl_dlo_open (IGRlong      *msg,
                               GRspacenum    cur_os);
extern IGRint  VDtbl_stc_open (IGRlong      *msg,
                               GRspacenum    cur_os);
extern IGRint  VDtbl_suc_open (IGRlong      *msg,
                               GRspacenum    cur_os);
extern IGRint  VDtbl_ads_open (IGRlong      *msg,
                               GRspacenum    cur_os);

/*   initializes in-memory index

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
cur_os         I                 Object space number

   ------------------------------------------------------------------------ */

extern IGRint  VDtbl_dlo_close (IGRlong      *msg);
extern IGRint  VDtbl_stc_close (IGRlong      *msg);
extern IGRint  VDtbl_suc_close (IGRlong      *msg);
extern IGRint  VDtbl_ads_close (IGRlong      *msg);

/*   closes in-memory index and frees memory

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code

   ------------------------------------------------------------------------ */


extern IGRint  VDtbl_dlo_new  (IGRlong      *msg,
                               GRspacenum    cur_os,
                               IGRchar      *Tabnam,
                               IGRchar      *Tabtyp,
                        struct GRid         *DRWloid);
extern IGRint  VDtbl_stc_new  (IGRlong      *msg,
                               GRspacenum    cur_os,
                               IGRchar      *Tabnam,
                        struct GRid         *DRWloid);
extern IGRint  VDtbl_suc_new  (IGRlong      *msg,
                               GRspacenum    cur_os,
                               IGRchar      *Tabnam,
                        struct GRid         *DRWloid);
extern IGRint  VDtbl_ads_new  (IGRlong      *msg,
                               GRspacenum    cur_os,
                               IGRchar      *Tabnam,
                        struct GRid         *DRWloid);
extern IGRint  VDtbl_exp_new  (IGRlong      *msg,
                               GRspacenum    cur_os,
                               IGRchar      *Tabnam,
                        struct GRid         *Expid);
extern IGRlong VDtbl_exp_set (IGRlong           *msg,
                        GRspacenum              cur_os,
                        IGRchar                 *Tabnam,
                        struct GRid             *Expid,
                        struct VDdrwexp_tab     *Exptab,
                        IGRint                  num_exp_data,
                        struct VDdrwexp_data    *Expdat);
extern IGRlong  VDtbl_exp_exec (IGRlong                 *msg,
                        GRspacenum              cur_os,
                        IGRchar                 *Tabnam,
                        struct GRid             *Expid,
                        IGRchar                 *in_buffer,
                        IGRshort                Xflag,
                        IGRshort                mode,
                        IGRint                  num_objs,
                        struct GRobj_env        *objList,
                        struct ACrg_coll        *coll);

/*   adds new entry to in-memory index , expands index when necessary

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
cur_os         I                 Object space number
Tabnam         I                 Table name
Tabtyp         I                 Table type
DRWloid        O                 object id

   ------------------------------------------------------------------------ */

extern IGRint  VDtbl_dlo_del  (IGRlong      *msg,
                               GRspacenum    cur_os,
                               IGRchar      *Tabnam,
                               IGRchar      *Tabtyp);
extern IGRint  VDtbl_stc_del  (IGRlong      *msg,
                               GRspacenum    cur_os,
                               IGRchar      *Tabnam);
extern IGRint  VDtbl_suc_del  (IGRlong      *msg,
                               GRspacenum    cur_os,
                               IGRchar      *Tabnam);
extern IGRint  VDtbl_ads_del  (IGRlong      *msg,
                               GRspacenum    cur_os,
                               IGRchar      *Tabnam);
extern IGRint  VDtbl_exp_del  (IGRlong      *msg,
                               GRspacenum    cur_os,
                               IGRchar      *Tabnam);


/*   deletes local object, modifies in-memory index 

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
cur_os         I                 Object space number
Tabnam         I                 Table name
Tabtyp         I                 Table type

   ------------------------------------------------------------------------ */

extern IGRint  VDtbl_dlo_getid (IGRlong      *msg,
                                GRspacenum    cur_os,
                                IGRchar      *Tabnam,
                                IGRchar      *Tabtyp,
                         struct GRid         *DRWloid);
extern IGRint  VDtbl_stc_getid (IGRlong      *msg,
                                GRspacenum    cur_os,
                                IGRchar      *Tabnam,
                         struct GRid         *DRWloid);
extern IGRint  VDtbl_suc_getid (IGRlong      *msg,
                                GRspacenum    cur_os,
                                IGRchar      *Tabnam,
                         struct GRid         *DRWloid);
extern IGRint  VDtbl_ads_getid (IGRlong      *msg,
                                GRspacenum    cur_os,
                                IGRchar      *Tabnam,
                         struct GRid         *DRWloid);
extern IGRint  VDtbl_exp_getid (IGRlong      *msg,
                                GRspacenum    cur_os,
                                IGRchar      *Tabnam,
                         struct GRid         *Expid);


/*   returns  object id of the parameter object and creates it from the 
     database if needed

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
cur_os         I                 Object space number
Tabnam         I                 Table name
Tabtyp         I                 Table type
DRWloid        O                 returned object id

   ------------------------------------------------------------------------ */


extern IGRint  VDtbl_dlo_getx (IGRlong      *msg,
                               GRspacenum    cur_os,
                               IGRboolean    bLocal,
                               IGRboolean    bDB,
                               IGRchar      *TTin,
                               IGRshort     *nCount,
                               IGRchar      *Tabnam,
                               IGRchar      *Tabtyp,
                               IGRchar      *Tabdes);
extern IGRint  VDtbl_stc_getx (IGRlong      *msg,
                               GRspacenum    cur_os,
                               IGRboolean    bLocal,
                               IGRboolean    bDB,
                               IGRshort     *nCount,
                               IGRchar      *Tabnam,
                               IGRchar      *Tabdes);
extern IGRint  VDtbl_suc_getx (IGRlong      *msg,
                               GRspacenum    cur_os,
                               IGRboolean    bLocal,
                               IGRboolean    bDB,
                               IGRshort     *nCount,
                               IGRchar      *Tabnam,
                               IGRchar      *Tabdes);
extern IGRint  VDtbl_ads_getx (IGRlong      *msg,
                               GRspacenum    cur_os,
                               IGRboolean    bLocal,
                               IGRboolean    bDB,
                               IGRshort     *nCount,
                               IGRchar      *Tabnam,
                               IGRchar      *Tabdes);
extern IGRint  VDtbl_exp_getx (IGRlong      *msg,
                               GRspacenum    cur_os,
                               IGRboolean    bLocal,
                               IGRboolean    bDB,
                               IGRshort     *nCount,
			       IGRchar      *Tabtyp,
                               IGRchar      *Tabnam,
                               IGRchar      *Tabdes);
extern IGRint  VDtbl_exp_getnd (IGRlong      *msg,
                        	GRspacenum    cur_os,
                        	IGRboolean    bLocal,
                        	IGRboolean    bDB,
                        	IGRchar      *p_type,
                        	IGRshort     *nCount,
                        	IGRchar      *Tabnam,
                        	IGRchar      *Tabdes);

/*   returns a list of the appropriate index

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
cur_os         I                 Object space number
bLocal         I                 Flag, return local objects
bDB            I                 Flag, return database objects
TTin           I                 (optional) table type input
nCount         O                 Number of items returned
Tabnam         O      yes        Array of Table names
Tabtyp         O      yes        Array of Table types
Tabdes         O      yes        Array of Table descriptions

   ------------------------------------------------------------------------ */

extern IGRint  VDtbl_dlo_gett (IGRlong      *msg,
                               GRspacenum    cur_os,
                               IGRboolean    bLocal,
                               IGRboolean    bDB,
                               IGRshort     *nCount,
                               IGRchar      *Tabtyp);
extern IGRint  VDtbl_exp_gett (IGRlong      *msg,
                               GRspacenum    cur_os,
                               IGRboolean    bLocal,
                               IGRboolean    bDB,
                               IGRshort     *nCount,
                               IGRchar      *Tabtyp);

/*   returns a list of the available types
     NOTE: only available for table layouts.

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
cur_os         I                 Object space number
bLocal         I                 Flag, return local objects
bDB            I                 Flag, return database objects
nCount         O                 Number of items returned
Tabtyp         O      yes        Array of Table types

   ------------------------------------------------------------------------ */


/****************************************************************************/
/*                             M A C R O S                                  */
/****************************************************************************/

/*      new - add new object to directory     */

#omdef  vd$tbldlo_new ( msg,
                        status = status,
                        osnum = OM_Gw_current_OS,
                        tabnam,
                        tabtyp = NULL,
                        GRid)
      status =
      VDtbl_dlo_new ( (msg), (osnum) , (tabnam) , (tabtyp) , (GRid) )
#endomdef

#omdef  vd$tblstc_new ( msg,
                        status = status,
                        osnum = OM_Gw_current_OS,
                        tabnam,
                        GRid)
      status =
      VDtbl_stc_new ( (msg), (osnum) , (tabnam) , (GRid) )
#endomdef

#omdef  vd$tblsuc_new ( msg,
                        status = status,
                        osnum = OM_Gw_current_OS,
                        tabnam,
                        GRid)
      status =
      VDtbl_suc_new ( (msg), (osnum) , (tabnam) , (GRid) )
#endomdef

#omdef  vd$tblads_new ( msg,
                        status = status,
                        osnum = OM_Gw_current_OS,
                        tabnam,
                        GRid)
      status =
      VDtbl_ads_new ( (msg), (osnum) , (tabnam) , (GRid) )
#endomdef

#omdef  vd$tblexp_new ( msg,
                        status = status,
                        osnum = OM_Gw_current_OS,
                        tabnam,
                        GRid)
      status =
      VDtbl_exp_new ( (msg), (osnum) , (tabnam) , (GRid) )
#endomdef


#omdef  vd$tblexp_set ( msg,
               status = status,
               osnum = OM_Gw_current_OS,
               tabnam=NULL ^ tab_id=NULL ,
               drwexp_tab,
               num_exp_data = 1,
               drwexp_data )
status =
VDtbl_exp_set ( (msg), (osnum) , (tabnam) , (tab_id), 
                                (drwexp_tab ), (num_exp_data), (drwexp_data))
#endomdef

#omdef  vd$tblexp_exec ( msg,
               status = status,
               osnum = OM_Gw_current_OS,
               tabnam=NULL ^ tab_id=NULL ^ buffer=NULL ,
	       flag = TRUE,
	       mode = VD_EXP_VERBOSE,
	       num_objs = 0,
	       objList = NULL,
	       attr )
status =
VDtbl_exp_exec ( (msg), (osnum) , (tabnam) , (tab_id), (buffer),
                (flag ), (mode), (num_objs) ,(objList), (attr))
#endomdef


/*      del - delete object from directory     */

#omdef  vd$tbldlo_del ( msg,
                        status = status,
                        osnum = OM_Gw_current_OS,
                        tabnam,
                        tabtyp = NULL )
      status =
      VDtbl_dlo_del ( (msg), (osnum) , (tabnam) , (tabtyp) )
#endomdef

#omdef  vd$tblstc_del ( msg,
                        status = status,
                        osnum = OM_Gw_current_OS,
                        tabnam )
      status =
      VDtbl_stc_del ( (msg), (osnum) , (tabnam) )
#endomdef

#omdef  vd$tblsuc_del ( msg,
                        status = status,
                        osnum = OM_Gw_current_OS,
                        tabnam )
      status =
      VDtbl_suc_del ( (msg), (osnum) , (tabnam) )
#endomdef

#omdef  vd$tblads_del ( msg,
                        status = status,
                        osnum = OM_Gw_current_OS,
                        tabnam )
      status =
      VDtbl_ads_del ( (msg), (osnum) , (tabnam) )
#endomdef

#omdef  vd$tblexp_del ( msg,
                        status = status,
                        osnum = OM_Gw_current_OS,
                        tabnam )
      status =
      VDtbl_exp_del ( (msg), (osnum) , (tabnam) )
#endomdef

/*      old - retrieve existing object (automatic load from DB)  */

#omdef  vd$tbldlo_old ( msg,
                        status = status,
                        osnum = OM_Gw_current_OS,
                        tabnam,
                        tabtyp = NULL,
                        GRid)
      status =
      VDtbl_dlo_getid ( (msg), (osnum) , (tabnam) , (tabtyp) , (GRid) )
#endomdef

#omdef  vd$tblstc_old ( msg,
                        status = status,
                        osnum = OM_Gw_current_OS,
                        tabnam,
                        GRid)
      status =
      VDtbl_stc_getid ( (msg), (osnum) , (tabnam) , (GRid) )
#endomdef

#omdef  vd$tblsuc_old ( msg,
                        status = status,
                        osnum = OM_Gw_current_OS,
                        tabnam,
                        GRid)
      status =
      VDtbl_suc_getid ( (msg), (osnum) , (tabnam) , (GRid) )
#endomdef

#omdef  vd$tblads_old ( msg,
                        status = status,
                        osnum = OM_Gw_current_OS,
                        tabnam,
                        GRid)
      status =
      VDtbl_ads_getid ( (msg), (osnum) , (tabnam) , (GRid) )
#endomdef

#omdef  vd$tblexp_old ( msg,
                        status = status,
                        osnum = OM_Gw_current_OS,
                        tabnam,
                        GRid)
      status =
      VDtbl_exp_getid ( (msg), (osnum) , (tabnam) , (GRid) )
#endomdef


/*      idx - retrieve object index   */

#omdef  vd$tbldlo_idx ( msg,
                        status = status,
                        osnum = OM_Gw_current_OS,
                        typin = NULL,
                        local = TRUE,
                        dbget = TRUE,
                        p_count,
                        p_nams = NULL,
                        p_typs = NULL,
                        p_desc = NULL    )

#      if om$equal (local, FALSE) && om$equal (dbget, FALSE)
#      omerror "vd$tbldlo_idx: no output specified"
#      else
           status =
           VDtbl_dlo_getx ( (msg), (osnum), (local), (dbget), (typin),
                            (p_count), (p_nams), (p_typs), (p_desc) )
#      endif
#endomdef

#omdef  vd$tblstc_idx ( msg,
                        status = status,
                        osnum = OM_Gw_current_OS,
                        local = TRUE,
                        dbget = TRUE,
                        p_count,
                        p_nams = NULL,
                        p_desc = NULL    )

#      if om$equal (local, FALSE) && om$equal (dbget, FALSE)
#      omerror "vd$tblstc_idx: no output specified"
#      else
           status =
           VDtbl_stc_getx ( (msg), (osnum), (local), (dbget),
                            (p_count), (p_nams), (p_desc) )
#      endif
#endomdef

#omdef  vd$tblsuc_idx ( msg,
                        status = status,
                        osnum = OM_Gw_current_OS,
                        local = TRUE,
                        dbget = TRUE,
                        p_count,
                        p_nams = NULL,
                        p_desc = NULL    )

#      if om$equal (local, FALSE) && om$equal (dbget, FALSE)
#      omerror "vd$tblsuc_idx: no output specified"
#      else
           status =
           VDtbl_suc_getx ( (msg), (osnum), (local), (dbget), 
                            (p_count), (p_nams), (p_desc) )
#      endif
#endomdef

#omdef  vd$tblads_idx ( msg,
                        status = status,
                        osnum = OM_Gw_current_OS,
                        local = TRUE,
                        dbget = TRUE,
                        p_count,
                        p_nams = NULL,
                        p_desc = NULL    )

#      if om$equal (local, FALSE) && om$equal (dbget, FALSE)
#      omerror "vd$tblads_idx: no output specified"
#      else
           status =
           VDtbl_ads_getx ( (msg), (osnum), (local), (dbget), 
                            (p_count), (p_nams), (p_desc) )
#      endif
#endomdef

#omdef  vd$tblexp_idx ( msg,
                        status = status,
                        osnum = OM_Gw_current_OS,
                        local = TRUE,
                        dbget = TRUE,
                        p_count,
			p_typs = NULL,
                        p_nams = NULL,
                        p_desc = NULL)
 
#      if om$equal (local, FALSE) && om$equal (dbget, FALSE)
#      omerror "vd$tblexp_idx: no output specified"
#      else
           status =
           VDtbl_exp_getx ( (msg), (osnum), (local), (dbget), 
                            (p_count), (p_typs), (p_nams), (p_desc) )
#      endif
#endomdef

#omdef  vd$tblexp_idnd ( msg,
                        status = status,
                        osnum = OM_Gw_current_OS,
                        local = TRUE,
                        dbget = TRUE,
                        p_type = NULL,
                        p_count,
                        p_nams = NULL,
                        p_desc = NULL)
 
#      if om$equal (local, FALSE) && om$equal (dbget, FALSE)
#      omerror "vd$tblexp_idnd: no output specified"
#      else
           status =
           VDtbl_exp_getnd ( (msg), (osnum), (local), (dbget), (p_type),
                            (p_count), (p_nams), (p_desc) )
#      endif
#endomdef

#omdef  vd$tblexp_idt ( msg,
                        status = status,
                        osnum = OM_Gw_current_OS,
                        local = TRUE,
                        dbget = TRUE,
                        p_count,
                        p_typs = NULL)
 
#      if om$equal (local, FALSE) && om$equal (dbget, FALSE)
#      omerror "vd$tblexp_idt: no output specified"
#      else
           status =
           VDtbl_exp_gett ( (msg), (osnum), (local), (dbget),
                            (p_count), (p_typs) )
#      endif
#endomdef

/*      idt - retrieve types list (table layout only)    */

#omdef  vd$tbldlo_idt ( msg,
                        status = status,
                        osnum = OM_Gw_current_OS,
                        local = TRUE,
                        dbget = TRUE,
                        p_count,
                        p_typs = NULL)

#      if om$equal (local, FALSE) && om$equal (dbget, FALSE)
#      omerror "vd$tbldlo_idt: no output specified"
#      else
           status =
           VDtbl_dlo_gett ( (msg), (osnum), (local), (dbget),
                            (p_count), (p_typs) )
#      endif
#endomdef


/***************************************************************************
 *                      TABLE LAYOUT RETRIEVAL                             *
 *         macros to retrieve specific info from a table layout            *
 *         (correspond to messages handled by the layout object)           *
 ***************************************************************************/

#omdef vd$tbldlo_gtab     (msg,
                           status = status,
                           osnum = OM_Gw_current_OS,
                           tabnam,
                           tabrec)

/*    returns the id structure of the table layout object

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
osnum          I                 Object space number
tabnam         I                 Table name
tabrec         O                 Table id record
*/

{
  struct GRid   LGRID;

  vd$tbldlo_old (msg    = msg,
                 osnum  = osnum,
                 tabnam = tabnam,
                 GRid   = &LGRID);

  if (status & OM_S_SUCCESS)
  status =
   _VD_SEND_OBJN (LGRID, VDdrwlo.VDdrwlo_gtab (msg, tabrec));
}
#endomdef
/* ------------------------------------------------------------------------ */


#omdef vd$tbldlo_gfix     (msg,
                           status = status,
                           osnum = OM_Gw_current_OS,
                           tabnam,
                           ngrp = VD_DRWLO_EN_ALL,
                           xlode = 0.0,
                           ylode = 0.0,
                           nExt = 0,
                           Exrec = NULL,
                           height,
                           count,
                           recs = NULL)

/*    returns array of fixed (builtin) components of a table layout

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
Tabnam         I                 Table name
nGrptyp        I                 group type requested
xLode          I                 section corner x coordinate
yLode          I                 section corner y coordinate
nExt           I                 number of extensions requested
Exrec          I                 extension records
dHgt           O                 total height of field or row
nCount         O                 number of field records to be returned
Fldrec         O      yes        Array of returned records
*/

{
  struct GRid   LGRID;

  vd$tbldlo_old (msg = msg,
                 osnum = osnum,
                 tabnam = tabnam,
                 GRid = &LGRID);

  if (status & OM_S_SUCCESS)
  status =
   _VD_SEND_OBJN (LGRID, VDdrwlo.VDdrwlo_gfix (msg, ngrp,
                              xlode, ylode, nExt, Exrec, height, count, recs));
}
#endomdef
/* ------------------------------------------------------------------------ */

#omdef vd$tbldlo_gdata    (msg,
                           status = status,
                           osnum = OM_Gw_current_OS,
                           tabnam,
                           ngrp = VD_DRWLO_EN_ALL,
                           xlode = 0.0,
                           ylode = 0.0,
                           nExt = 0,
                           Exrec = NULL,
                           height,
                           count,
                           recs = NULL)

/*    returns array of replaceable (data) components of a table layout

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
Tabnam         I                 Table name
nGrptyp        I                 group type requested
xLode          I                 section corner x coordinate
yLode          I                 section corner y coordinate
nExt           I                 number of extensions requested
Exrec          I                 extension records
dHgt           O                 total height of field or row
nCount         O                 number of field records to be returned
Fldrec         O      yes        Array of returned records
*/

{
  struct GRid   LGRID;

  vd$tbldlo_old (msg = msg,
                 osnum = osnum,
                 tabnam = tabnam,
                 GRid = &LGRID);

  if (status & OM_S_SUCCESS)
  status =
   _VD_SEND_OBJN (LGRID, VDdrwlo.VDdrwlo_gdata (msg, ngrp,
                              xlode, ylode, nExt, Exrec, height, count, recs));
}
#endomdef
/* ------------------------------------------------------------------------ */

#omdef vd$tbldlo_grect    (msg,
                           status = status,
                           osnum = OM_Gw_current_OS,
                           tabnam,
                           ngrp = VD_DRWLO_EN_ALL,
                           ncol = 0,
                           pfield = NULL,
                           nExt = 0,
                           Exrec = NULL,
                           xlow,
                           ylow,
                           xhig,
                           yhig)

/*    returns total size of a table section

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
Tabnam         I                 Table name
nGrptyp        I                 group type requested
nColno         I                 column number requested (if column group)
                                  (EN_ALL for all columns -- overall rect)
pFieldid       I                 fieldid requested (if header/trailer group)
                                  (NULL for all fields -- overall rect)
nExt           I                 number of extensions requested
Exrec          I                 extension records
xLow           O                 Returned lower x
yLow           O                 Returned lower y
xHig           O                 Returned upper x
yHig           O                 Returned upper y

*/

{
  struct GRid   LGRID;

  vd$tbldlo_old (msg = msg,
                 osnum = osnum,
                 tabnam = tabnam,
                 GRid = &LGRID);

  if (status & OM_S_SUCCESS)
  status =
   _VD_SEND_OBJN (LGRID, VDdrwlo.VDdrwlo_grect (msg, ngrp, ncol, pfield,
                              nExt, Exrec, xlow, ylow, xhig, yhig));
}
#endomdef

/* ------------------------------------------------------------------------ */

/*    NOTES:

   1. Lode point (generally bottom left corner) coordinates are optional 
      input. All output coordinates will be corrected for these
   2. Extension records are optional input. 
      By submitting the number of auto extended lines needed for every
      applicable column the program can:
         a. offset the coordinates where needed
         b. extend the vertical lines to cover the increased column height

*/


/***************************************************************************
 *                      SORT CRITERIA RETRIEVAL                            *
 *         macros to retrieve specific info from a sort criterion          *
 *         (correspond to messages handled by the layout object)           *
 ***************************************************************************/

#omdef vd$tblstc_gtab     (msg,
                           status = status,
                           osnum = OM_Gw_current_OS,
                           tabnam,
                           tabrec)

/*    returns the id structure of the table layout object

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
osnum          I                 Object space number
tabnam         I                 Table name
tabrec         O                 Table id record
*/

{
  struct GRid   LGRID;

  vd$tblstc_old (msg    = msg,
                 osnum  = osnum,
                 tabnam = tabnam,
                 GRid   = &LGRID);

  if (status & OM_S_SUCCESS)
  status =
   _VD_SEND_OBJN (LGRID, VDSSC.VDSSC_gtab (msg, tabrec));
}
#endomdef

/* ------------------------------------------------------------------------ */

#omdef vd$tblstc_gsort    (msg,
                           status = status,
                           osnum = OM_Gw_current_OS,
                           tabnam,
                           index = -1,
                           count,
                           recs = NULL)

/*    returns array of sort records 

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
osnum          I                 Object space number
tabnam         I                 Table name
index          I                 Sortkey index (or VD_DRWLO_EN_ALL)
count          O                 Number of records returned
recs           O      yes        Sort criteria records
*/

{
  struct GRid   LGRID;

  vd$tblstc_old (msg    = msg,
                 osnum  = osnum,
                 tabnam = tabnam,
                 GRid   = &LGRID);

  if (status & OM_S_SUCCESS)
  status =
   _VD_SEND_OBJN (LGRID, VDSSC.VDSSC_gsort (msg, index, count, recs));
}
#endomdef



/***************************************************************************
 *                   SUMMARIZATION CRITERIA RETRIEVAL                      *
 *    macros to retrieve specific info from a summarization criterion      *
 *         (correspond to messages handled by the layout object)           *
 ***************************************************************************/

#omdef vd$tblsuc_gtab     (msg,
                           status = status,
                           osnum = OM_Gw_current_OS,
                           tabnam,
                           tabrec)

/*    returns the id structure of the table layout object

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
osnum          I                 Object space number
tabnam         I                 Table name
tabrec         O                 Table id record
*/

{
  struct GRid   LGRID;

  vd$tblsuc_old (msg    = msg,
                 osnum  = osnum,
                 tabnam = tabnam,
                 GRid   = &LGRID);

  if (status & OM_S_SUCCESS)
  status =
   _VD_SEND_OBJN (LGRID, VDSSC.VDSSC_gtab (msg, tabrec));
}
#endomdef

/* ------------------------------------------------------------------------ */

#omdef vd$tblsuc_gsqty    (msg,
                           status = status,
                           osnum = OM_Gw_current_OS,
                           tabnam,
                           cat = NULL,
                           subcat = NULL,
                           count,
                           recs = NULL)

/*    returns array of summ qty records

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
osnum          I                 Object space number
tabnam         I                 Table name
cat            I                 Category name (NULL for all)
subcat         I                 SubCategory name (NULL for all)
count          O                 Number of records returned
recs           O      yes        summ criteria records
*/

{
  struct GRid   LGRID;

  vd$tblsuc_old (msg    = msg,
                 osnum  = osnum,
                 tabnam = tabnam,
                 GRid   = &LGRID);

  if (status & OM_S_SUCCESS)
  status =
   _VD_SEND_OBJN (LGRID, VDSSC.VDSSC_gsqty (msg, cat, subcat, count, recs));
}
#endomdef

/* ------------------------------------------------------------------------ */

#omdef vd$tblsuc_gsmtc    (msg,
                           status = status,
                           osnum = OM_Gw_current_OS,
                           tabnam,
                           cat = NULL,
                           subcat = NULL,
                           index = -1,
                           count,
                           recs = NULL)

/*    returns array of summ mtc records

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
osnum          I                 Object space number
tabnam         I                 Table name
cat            I                 Category name (NULL for all)
subcat         I                 SubCategory name (NULL for all)
index          I                 Index of record to seek
count          O                 Number of records returned
recs           O      yes        summ criteria records
*/

{
  struct GRid   LGRID;

  vd$tblsuc_old (msg    = msg,
                 osnum  = osnum,
                 tabnam = tabnam,
                 GRid   = &LGRID);

  if (status & OM_S_SUCCESS)
  status =
   _VD_SEND_OBJN (LGRID,
                  VDSSC.VDSSC_gsmtc (msg, cat, subcat, index, count, recs));
}

#endomdef


/***************************************************************************
 *                 ATTRIBUTE DRIVEN SYMBOLS RETRIEVAL                      *
 *  macros to retrieve specific info from an attribute driven symbolset    *
 *         (correspond to messages handled by the layout object)           *
 ***************************************************************************/

#omdef vd$tblads_gtab     (msg,
                           status = status,
                           osnum = OM_Gw_current_OS,
                           tabnam,
                           tabrec)

/*    returns the id structure of the table layout object

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
osnum          I                 Object space number
tabnam         I                 Table name
tabrec         O                 Table id record
*/

{
  struct GRid   LGRID;

  vd$tblads_old (msg    = msg,
                 osnum  = osnum,
                 tabnam = tabnam,
                 GRid   = &LGRID);

  if (status & OM_S_SUCCESS)
  status =
   _VD_SEND_OBJN (LGRID, VDADS.VDADS_gtab (msg, tabrec));
}
#endomdef

/* ------------------------------------------------------------------------ */

#omdef vd$tblads_grec     (msg,
                           status = status,
                           osnum = OM_Gw_current_OS,
                           tabnam,
                           attnam = NULL,
                           attval = NULL,
                           count,
                           recs = NULL)

/*    returns array of ads records

parameter     I/O   suppress     Description
                    if NULL
msg            O                 Returned error code
osnum          I                 Object space number
tabnam         I                 Table name
attnam         I                 attribute name (NULL for all)
attval         I                 attribute value name (NULL for all)
count          O                 Number of records returned
recs           O      yes        ads records
*/

{
  struct GRid   LGRID;

  vd$tblads_old (msg    = msg,
                 osnum  = osnum,
                 tabnam = tabnam,
                 GRid   = &LGRID);

  if (status & OM_S_SUCCESS)
  status =
   _VD_SEND_OBJN (LGRID,
                  VDADS.VDADS_grec (msg, attnam, attval, count, recs));
}
#endomdef

/*----------------------------------------------------------
 * get table header from a table row id
 *
 * input:	rowID, a table row id
 * output:	msg, error message
 *		hdrID, table header which rowID belongs to
 *
 * Implementation function is in VDdrw_tblfunc.I.
 */
extern IGRlong  VDtbl_get_hdr (	IGRlong		*msg,
				struct	GRid	*rowID,
				struct	GRid	*hdrID);

#omdef	vd$tbl_get_hdr	(	msg,
				rowID,
				hdrID )

	VDtbl_get_hdr ((msg), (rowID), (hdrID));
#endomdef

#endif

