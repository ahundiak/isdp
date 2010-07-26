/*
Name
  COchfunc.I

Description
  These functions perform the actions used by the COchange commands.

History
        mrm     08/16/88    created by extracting code from existing commands
        jhw     01/23/89    added gr$gsdisplay in COch_dis_on (TR#89N0291)
        mrm     02/24/89    I/DRAW changes
                05/04/89    added COch_cp_layer
                09/25/89    removed COch_symbology, COch_color, COch_layer,
                            COch_style, COch_weight, COch_cp_layer
        jsd     01/21/92    prefix names with ".deleted_"
                            for COch_delete, COch_undelete
        jsd     01/23/92    added support for graphic group/set
                            for COch_delete, COch_undelete
        jsd     03/24/92    removed incorrect I/DRAW defs and fixed removal
                            of ".deleted_" from objects
        jsd     09/08/92    1. changed di$rename to GRvg.GRchgname (TR 92N5839)
                               This added objid and osnum to COpre_* functions.
                            2. removed multiple calls to make_chanselect.
                            3. replaced strcmp with om$is_ancestry_valid.
        jsd     05/10/93    COpre_undelete_name now removes all ".deleted_"
                            that have been added to a name.
 
        abhijit  01/16/98   Avoided attaching '.deleted' prefix for Base
                            Coordinate System object  
*/

class implementation CEO_GSLOCATE;

#include "coimport.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "dpmacros.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DImacros.h"
#include "DIprims.h"
#include "lcmacros.h"
#include <alloca.h>
#include "grmsg.h"

from GRgraphics import GRdisplay;
from GRvg import GRchgdp, GRchgcolor, GRchglevel, GRchgstyle,
                 GRchgweight, GRchgname, GRchgprops;
from GRundo import GRudsave, GRudundo, GRudonoff;

%safe
static OM_S_CHANSELECT GRgrsetChanStruct = { OM_e_name, 0 };
static OM_S_CHANSELECT GRcmpownerChanStruct = { OM_e_name, 0 };
static OM_S_CHANSELECT GRundoChanStruct = { OM_e_name, 0 };
static OM_S_CHANSELECT *pGRgrsetChanStruct = NULL;
static OM_S_CHANSELECT *pGRcmpownerChanStruct = NULL;
static OM_S_CHANSELECT *pGRundoChanStruct = NULL;
%endsafe


/*

Name
  COpre_delete_name

Abstract
  This function is used during the process of deleting a named object
  by adding '.deleted_' prefix to the name of an object so the Directory
  Commands Form can be updated.  If undelete is off, then this name
  will be deleted from the directory subsystem.  If undelete is on, then 
  the name will be hidden from the display but will still exist in the
  directory subsystem and can be retrieved by using COpre_undelete_name.

Synopsis
  IGRint COpre_delete_name ( name_count, objid, osnum )

  IGRint           name_count
  OM_S_OBJID       objid
  OMuword          osnum

Description

Return Value
   OM_S_SUCCESS always

Notes
  Example:
  name before call to COpre_delete_name == :test.dgn:usr:my_name
  name after  call to COpre_delete_name == :test.dgn:usr:.deleted_my_name

Index

Keywords
  delete undelete directory name

History
  Unknown  : Unknown          : created 
  02/10/93 : Shelley R. Heard : corrected header

 */

IGRint COpre_delete_name ( name_count, objid, osnum )

IGRint           name_count;
OM_S_OBJID       objid;
OMuword          osnum;

{
   IGRint        sts, ii;
   IGRlong       msg;
   IGRchar       full_name[DI_PATH_MAX],
                 old_name[DI_PATH_MAX],
                 dir_name[DI_PATH_MAX],
                 new_name[DI_PATH_MAX];
   struct GRmd_env dummy_env;

   for ( ii=0; ii < name_count; ii++ )
   { /* Get the name of all the synonyms */
     sts = di$fetch_untrans( index   = ii,
                             objname = full_name );

     if (sts == DIR_S_SUCCESS)
     {
       sts = di$split ( pathname = full_name,
                        dirname  = dir_name,
                        name     = old_name );

       /* 5/6/93 - JSD - Do not prepend more than one .deleted_ */
       sts = strncmp ( old_name, ".deleted_", strlen( ".deleted_" ));
       if (sts)
       {
         strcpy ( new_name, ".deleted_" );
         strcat ( new_name, old_name );

         sts = di$strcat ( to   = dir_name,
                           from = new_name );

         sts = om$send (msg = message GRvg.GRchgname
                              (&msg, &dummy_env, new_name),
                        senderid = objid,
                        targetid = objid,
                        targetos = osnum);
       }
     }
   }

   return ( OM_S_SUCCESS );
}

/*
Name 
  COpre_undelete_name

Abstract
  This function is used during the process of undeleting a named object
  by truncating the '.deleted_' prefix from the name so the Directory
  Commands Form can be updated.

Synopsis
  IGRint COpre_undelete_name ()

  IGRint           name_count
  OM_S_OBJID       objid
  OMuword          osnum

Return Value
   OM_S_SUCCESS always

Notes

  name before call to COpre_delete_name == :test.dgn:usr:.deleted_my_name
  name after  call to COpre_delete_name == :test.dgn:usr:my_name

Keywords
  delete undelete directory name

*/

IGRint COpre_undelete_name ( name_count, objid, osnum )

IGRint           name_count;
OM_S_OBJID       objid;
OMuword          osnum;

{
   IGRint        sts, ii, flag=FALSE;
   IGRlong       msg;
   IGRchar       full_name[DI_PATH_MAX],
                 old_name[DI_PATH_MAX],
                 dir_name[DI_PATH_MAX],
                 new_name[DI_PATH_MAX];
   struct GRmd_env dummy_env;

   for ( ii=0; ii < name_count; ii++ )
   { /* Get the names of all the synonyms */
     sts = di$fetch_untrans( index   = ii,
                             objname = full_name );

     if (sts == DIR_S_SUCCESS)
     {
       sts = di$split ( pathname = full_name,
                        dirname  = dir_name,
                        name     = old_name );

       /* if the name starts with ".deleted_" then truncate it */
       while ( ! ( strncmp( old_name, ".deleted_", strlen( ".deleted_" ))))
       {
         flag = TRUE;
         strcpy ( new_name, old_name + strlen ( ".deleted_" ));
         strcpy ( old_name, new_name );
       }
  
       if ( flag )
       {
         sts = di$strcat ( to = dir_name, from = new_name );

         sts = om$send (msg = message GRvg.GRchgname
                              (&msg, &dummy_env, new_name),
                        senderid = objid,
                        targetid = objid,
                        targetos = osnum);
       }
     }
   }

   return ( OM_S_SUCCESS );
}

/*
Name 
  COch_delete

Abstract
  This function passes the located object(s) to the Undo object, which
  either deletes or saves the object(s), depending on whether undelete
  is on or off.  The object(s) should be erased prior to calling this
  function.  In the case of I/DRAW, the object is deleted immediately.

Synopsis

  IGRint COch_delete (msg, caller_id, caller_os, mod, events,
                      gschan, userdata)


  IGRlong         *msg;       o - return code
                                  MSSUCC if successful

  OM_S_OBJID       caller_id  i - calling object's id

  OMuword          caller_os  i - calling object's id

  struct GRmd_env *mod        i - current module information

  struct GRevent  *events[]   i - array of pointers to events
                                  events[0] - locate event; unused
                                  events[1] - accept event; unused
                                  events[2] - gr$gslocate argument locate_event

  OM_S_CHANSELECT *gschan     i - channel pointing to objects to work with

  char            *userdata   i - pointer to info the individual
                                  function may optionally require

Return Value
   TRUE  if successful
   FALSE if unsuccessful

Keywords
  delete undelete 

History
        ???     ??/??/??    ??? 
        jsd     01/21/92    prefix names with ".deleted_"
        jsd     01/23/92    added support for graphic group/set
*/

#argsused
IGRint COch_delete (msg, caller_id, caller_os, mod, events, gschan, userdata)

IGRlong         *msg;           /* return code */
OM_S_OBJID       caller_id;     /* calling object's id */
OMuword          caller_os;     /* calling object's osnum */
struct GRmd_env *mod;           /* current module information */
struct GRevent  *events[];      /* event pointer array */
OM_S_CHANSELECT *gschan;        /* containing object(s) to work with */
char            *userdata;      /* unused */

{
    IGRint sts,sts2,stat;
    struct GRid *objgrid;
    struct GRmd_env *objmod;
    IGRchar class_name[30];
    OMuint chan_count = 0,
           gg_count = 0,
           gs_count = 0;
    DIint  name_count = 0,
           ii;
    OM_S_OBJID undo_object;
    OM_S_OBJECT_LINKAGE *channel_list = NULL,
                         ChannelLinkage[1];
    GRclassid            elem_classid;

    objgrid = &events[2]->located_object[0].located_obj;
    objmod = &events[2]->located_object[0].module_info;

    /*
     *  get the undo object's id
     */

    sts = ex$get_super (mod_id = mod->md_id.objid,
                        mod_osnum = mod->md_id.osnum,
                        super_name = "UNDO_OBJECT",
                        create = TRUE,
                        super_class = "GRundo",
                        super_id = &undo_object);
    if (!(sts & 1))
    {
#ifdef DEBUG
        printf ("COch_delete: ex$get_super failed\n");
#endif DEBUG
        goto finish;
    }

    sts = om$get_classid( objid     = objgrid->objid,
                          osnum     = objgrid->osnum,
                          p_classid = &elem_classid );

    /* Is it a Graphic Set/Group/Object ? */
    sts = om$is_ancestry_valid( subclassid     = elem_classid,
                                superclassname = "GRgrset" );

    if( sts == OM_S_SUCCESS )
    { /* gotta graphic set */

       if ( pGRgrsetChanStruct == NULL )
       {
         pGRgrsetChanStruct = &GRgrsetChanStruct;

         sts = om$make_chanselect(channame     = "GRgrset.to_sets",
                                  p_chanselect = pGRgrsetChanStruct );
       }

       /* Get the grid of the GRsvset */
       sts = om$get_channel_objects( objid        =  objgrid->objid,
                                     osnum        =  objgrid->osnum,
                                     p_chanselect =  pGRgrsetChanStruct,
                                     list         =  ChannelLinkage,
                                     size         =  1,
                                     count        = &chan_count);
       if (!(sts & 1))
       {
#ifdef DEBUG
           printf ("COch_delete: om$get_channel_objects failed\n");
#endif DEBUG
           goto finish;
       }

       if (! chan_count)
         goto finish;

       if ( pGRcmpownerChanStruct == NULL )
       {
         pGRcmpownerChanStruct = &GRcmpownerChanStruct;

         sts = om$make_chanselect(channame     = "GRcmpowner.to_components",
                                  p_chanselect = pGRcmpownerChanStruct );
       }

       sts = om$get_channel_count( objid        =  ChannelLinkage[0].S_objid,
                                   osnum        =  ChannelLinkage[0].osnum,
                                   p_chanselect =  pGRcmpownerChanStruct,
                                   count        = &gs_count);
       if (!(sts & 1))
       {
#ifdef DEBUG
           printf ("COch_delete: om$get_channel_count failed\n");
#endif DEBUG
           goto finish;
       }

       if (! gs_count)
         goto finish;

       channel_list = (OM_S_OBJECT_LINKAGE *) alloca (sizeof(OM_S_OBJECT_LINKAGE) * gs_count);

       sts = om$get_channel_objects( objid        =  ChannelLinkage[0].S_objid,
                                     osnum        =  ChannelLinkage[0].osnum,
                                     p_chanselect =  pGRcmpownerChanStruct,
                                     list         =  channel_list,
                                     size         =  gs_count,
                                     count        = &gs_count);

       for ( ii=0; ii < gs_count; ii++ )
       {
         /* does the object have a name ? */
         sts = di$start_untrans( osnum   =  channel_list[ii].osnum,
                                 objid   =  channel_list[ii].S_objid,
                                 ptr     = &name_count );

         if (sts == DIR_S_SUCCESS)
         {
           sts2 = om$get_classname(classname=class_name,
                                     osnum = channel_list[ii].osnum,
                                     objid = channel_list[ii].S_objid);

                stat = strcmp(class_name,"GRcsbase");

           if(stat)
           sts = COpre_delete_name( name_count,
                                    channel_list[ii].S_objid,
                                    channel_list[ii].osnum );
         }
       }
       sts = di$update_dir_form();
    }
    else
    {
      sts = om$is_ancestry_valid( subclassid     = elem_classid,
                                  superclassname = "GRgrgrp" );

      if( sts == OM_S_SUCCESS )
      { /* gotta graphic group */

         if ( pGRcmpownerChanStruct == NULL )
         {
           pGRcmpownerChanStruct = &GRcmpownerChanStruct;

           sts = om$make_chanselect(channame     = "GRcmpowner.to_components",
                                    p_chanselect = pGRcmpownerChanStruct );
         }

         sts = om$get_channel_count( objid        =  objgrid->objid,
                                     osnum        =  objgrid->osnum,
                                     p_chanselect =  pGRcmpownerChanStruct,
                                     count        = &gg_count);
         if (!(sts & 1))
         {
#ifdef DEBUG
             printf ("COch_delete: om$get_channel_objects failed\n");
#endif DEBUG
             goto finish;
         }

         if (! gg_count)
           goto finish;

         channel_list = (OM_S_OBJECT_LINKAGE *) alloca (sizeof(OM_S_OBJECT_LINKAGE) * gg_count);

         sts = om$get_channel_objects( objid        =  objgrid->objid,
                                       osnum        =  objgrid->osnum,
                                       p_chanselect =  pGRcmpownerChanStruct,
                                       list         =  channel_list,
                                       size         =  gg_count,
                                       count        = &gg_count);

         for ( ii=0; ii < gg_count; ii++ )
         {
           /* does the object have a name ? */
           sts = di$start_untrans( osnum   =  channel_list[ii].osnum,
                                   objid   =  channel_list[ii].S_objid,
                                   ptr     = &name_count );

           if (sts == DIR_S_SUCCESS)
           {
             sts2 = om$get_classname(classname=class_name,
                                     osnum = channel_list[ii].osnum,
                                     objid = channel_list[ii].S_objid);

                stat = strcmp(class_name,"GRcsbase");

             if(stat)
             sts = COpre_delete_name( name_count,
                                      channel_list[ii].S_objid,
                                      channel_list[ii].osnum );
           }
         }
         sts = di$update_dir_form();
      }
      else
      { /* gotta graphic object */

        /* does the object have a name ? */
        sts = di$start_untrans( osnum   =  objgrid->osnum,
                                objid   =  objgrid->objid,
                                ptr     = &name_count );

        if (sts == DIR_S_SUCCESS)
        {
           sts2 = om$get_classname(classname=class_name,
                                     osnum = objgrid->osnum,
                                     objid = objgrid->objid);
                stat = strcmp(class_name,"GRcsbase");

           if(stat)
          {
           sts = COpre_delete_name( name_count,
                                    objgrid->objid,
                                    objgrid->osnum );
          }
           sts = di$update_dir_form();
        }
      }
    }

    /*
     *  send the object(s) to the undo manager
     */

    sts = om$send (msg = message GRundo.GRudsave (msg, objgrid, objmod),
                   senderid = caller_id,
                   targetid = undo_object,
                   targetos = mod->md_id.osnum);

#ifdef DEBUG
    if (!(sts & *msg & 1))
        printf ("COch_delete: GRundo.GRudsave failed\n");
#endif DEBUG

finish:

#ifdef DEBUG
    if (!(*msg & 1)) printf ("COch_delete: *msg = %x\n", *msg);
    if (!(sts & 1)) om$report_error (sts = sts);
#endif

    return (sts & *msg & 1);
}


/*
Name 
  COch_undelete

Abstract
  This function invokes the undo method on the undo manager.

Synopsis
  IGRint COch_undelete(msg, caller_id, caller_os, mod, events, gschan, userdata)

  *msg       IGRlong           return code
                                 MSFAIL            Failure
                                 MSSUCC            Success
                                 GR_F_UndelOff     Undo is turned off
                                 GR_F_NothUndel    No undo information is available

  caller_id  OM_S_OBJID        calling object's id 

  caller_os  OMuword           calling object's osnum 

  *mod       struct GRmd_env   current module information 

  *events    struct GRevent    not used in this function

  *gschan    OM_S_CHANSELECT   containing object(s) to work with

  *userdata  char              unused

Return Value
  TRUE  - successful
  FALSE - unsuccessful

Keywords
  undelete

History
        ???     ??/??/??    ??? 
        jsd     01/21/92    retrieve the names from the ".deleted_" list
        jsd     01/23/92    added support for graphic group/set
*/

#argsused
IGRint COch_undelete (msg, caller_id, caller_os, mod, events, gschan, userdata)

IGRlong         *msg;           /* return code: 0 if */
OM_S_OBJID       caller_id;     /* calling object's id */
OMuword          caller_os;     /* calling object's osnum */
struct GRmd_env *mod;           /* current module information */
struct GRevent  *events[];      /* event pointer array */
OM_S_CHANSELECT *gschan;        /* containing object(s) to work with */
char            *userdata;      /* unused */

{
  IGRint      sts, ret = 1;
  OM_S_OBJID  undo_object;
  OMuint chan_count = 0,
         gg_count = 0,
         gs_count = 0;
  DIint  name_count = 0,
         ii;
  OM_S_OBJECT_LINKAGE  ChannelLinkage[1];
  OM_S_OBJECT_LINKAGE  GRsvsetLinkage[1];
  OM_S_OBJECT_LINKAGE *channel_list = NULL;
  GRclassid            elem_classid;

  /*
   *  get the undo object's id
   */

  sts = ex$get_super (mod_id = mod->md_id.objid,
                      mod_osnum = mod->md_id.osnum,
                      super_name = "UNDO_OBJECT",
                      create = TRUE,
                      super_class = "GRundo",
                      super_id = &undo_object);
  if (!(sts & 1))
  {
#ifdef DEBUG
    printf ("COch_undelete: ex$get_super failed\n");
#endif
    goto finish;
  }

  if ( pGRcmpownerChanStruct == NULL )
  {
    pGRcmpownerChanStruct = &GRcmpownerChanStruct;

    sts = om$make_chanselect(channame     = "GRcmpowner.to_components",
                             p_chanselect = pGRcmpownerChanStruct );
    if (!(sts & 1))
    {
#ifdef DEBUG
      printf ("om$make_chanselect GRcmpowner.to_components failed\n" );
#endif
      goto finish;
    }
  }

  sts = om$get_channel_objects( objid = undo_object,
                                osnum = mod->md_id.osnum,
                                p_chanselect = pGRcmpownerChanStruct,
                                list = ChannelLinkage,
                                size = 1,
                                count = &chan_count );
  if (!(sts & 1))
  {
#ifdef DEBUG
    printf ("om$get_channel_objects GRcmpowner.to_components failed\n" );
#endif
    goto finish;
  }

  if ( ! chan_count )
  { /* Gotta Graphic Set */
    if ( pGRundoChanStruct == NULL )
    {
      pGRundoChanStruct = &GRundoChanStruct;

      sts = om$make_chanselect(channame     = "GRundo.to_grset",
                               p_chanselect = pGRundoChanStruct );
      if (!(sts & 1))
      {
#ifdef DEBUG
        printf ("om$make_chanselect GRundo.to_grset failed\n" );
#endif
      goto finish;
      }
    }

    sts = om$get_channel_objects( objid = undo_object,
                                  osnum = mod->md_id.osnum,
                                  p_chanselect = pGRundoChanStruct,
                                  list = ChannelLinkage,
                                  size = 1,
                                  count = &chan_count );
    if (!(sts & 1))
    {
#ifdef DEBUG
      printf ("om$get_channel_objects GRundo.to_grset failed\n" );
#endif
      goto finish;
    }

    if (! chan_count)
    {
      goto finish;
    }

    if ( pGRgrsetChanStruct == NULL )
    {
      pGRgrsetChanStruct = &GRgrsetChanStruct;

      sts = om$make_chanselect(channame     = "GRgrset.to_sets",
                               p_chanselect = pGRgrsetChanStruct );
    }

    sts = om$get_channel_objects( objid        =  ChannelLinkage[0].S_objid,
                                  osnum        =  ChannelLinkage[0].osnum,
                                  p_chanselect =  pGRgrsetChanStruct,
                                  list         =  GRsvsetLinkage,
                                  size         =  1,
                                  count        = &gs_count);
    if (!(sts & 1))
    {
#ifdef DEBUG
      printf ("om$get_channel_objects GRgrset.to_sets failed\n" );
#endif
      goto finish;
    }

    if (! gs_count)
      goto finish;

    if ( pGRcmpownerChanStruct == NULL )
    {
      pGRcmpownerChanStruct = &GRcmpownerChanStruct;

      sts = om$make_chanselect(channame     = "GRcmpowner.to_components",
                               p_chanselect = pGRcmpownerChanStruct );
    }

    sts = om$get_channel_count( objid        =  GRsvsetLinkage[0].S_objid,
                                osnum        =  GRsvsetLinkage[0].osnum,
                                p_chanselect =  pGRcmpownerChanStruct,
                                count        = &gs_count);
   if (!(sts & 1))
   {
#ifdef DEBUG
     printf ("om$get_channel_count GRcmpowner.to_components failed\n" );
#endif
     goto finish;
   }

   if (! gs_count)
     goto finish;

    channel_list = (OM_S_OBJECT_LINKAGE *) alloca (sizeof(OM_S_OBJECT_LINKAGE) * gs_count);

    sts = om$get_channel_objects( objid        =  GRsvsetLinkage[0].S_objid,
                                  osnum        =  GRsvsetLinkage[0].osnum,
                                  p_chanselect =  pGRcmpownerChanStruct,
                                  list         =  channel_list,
                                  size         =  gs_count,
                                  count        = &gs_count);

    for ( ii=0; ii < gs_count; ii++ )
    {
      /* does the object have a name ? */
      sts = di$start_untrans( osnum   =  channel_list[ii].osnum,
                              objid   =  channel_list[ii].S_objid,
                              ptr     = &name_count );

      if (sts == DIR_S_SUCCESS)
      {
        sts = COpre_undelete_name( name_count,
                                   channel_list[ii].S_objid,
                                   channel_list[ii].osnum );
      }
    }

    sts = di$update_dir_form();
  }
  else
  {
    sts = om$get_classid( objid     = ChannelLinkage[0].S_objid,
                          osnum     = ChannelLinkage[0].osnum,
                          p_classid = &elem_classid );

    /* Is it a Graphic Set/Group/Object ? */
    sts = om$is_ancestry_valid( subclassid     = elem_classid,
                                superclassname = "GRgrgrp" );

    if( sts == OM_S_SUCCESS )
    { /* gotta graphic group */

      if ( pGRcmpownerChanStruct == NULL )
      {
        pGRcmpownerChanStruct = &GRcmpownerChanStruct;

        sts = om$make_chanselect(channame     = "GRcmpowner.to_components",
                                 p_chanselect = pGRcmpownerChanStruct );
      }

      sts = om$get_channel_count( objid        =  ChannelLinkage[0].S_objid,
                                  osnum        =  ChannelLinkage[0].osnum,
                                  p_chanselect =  pGRcmpownerChanStruct,
                                  count        = &gg_count);
    if (!(sts & 1))
    {
#ifdef DEBUG
      printf ("om$get_channel_count GRcmpowner.to_components failed\n" );
#endif
      goto finish;
    }

    if (! gg_count)
      goto finish;

      channel_list = 
	(OM_S_OBJECT_LINKAGE *) alloca (sizeof(OM_S_OBJECT_LINKAGE) * gg_count);

      sts = om$get_channel_objects( objid        =  ChannelLinkage[0].S_objid,
                                    osnum        =  ChannelLinkage[0].osnum,
                                    p_chanselect =  pGRcmpownerChanStruct,
                                    list         =  channel_list,
                                    size         =  gg_count,
                                    count        = &gg_count);

      for ( ii=0; ii < gg_count; ii++ )
      {
        /* does the object have a name ? */
        sts = di$start_untrans( osnum   =  channel_list[ii].osnum,
                                objid   =  channel_list[ii].S_objid,
                                ptr     = &name_count );

        if (sts == DIR_S_SUCCESS)
        {
          sts = COpre_undelete_name( name_count,
                                     channel_list[ii].S_objid,
                                     channel_list[ii].osnum );
        }
      }
      sts = di$update_dir_form();
    }
    else
    { /* gotta graphic object */
      /* does the object have a name ? */
      sts = di$start_untrans( osnum   =  ChannelLinkage[0].osnum,
                              objid   =  ChannelLinkage[0].S_objid,
                              ptr     = &name_count );

      if (sts == DIR_S_SUCCESS)
      {
         sts = COpre_undelete_name( name_count,
                                    ChannelLinkage[0].S_objid,
                                    ChannelLinkage[0].osnum );

         sts = di$update_dir_form();
      }
    }
  }

finish:
  /* 
   *  UNCONDITIONALLY undo the previous deletion
   *  *** TR # 119300685 02/10/93 SRH *** 
   */
  sts = om$send (msg = message GRundo.GRudundo (msg, &ret),
                 senderid = caller_id,
                 targetid = undo_object,
                 targetos = mod->md_id.osnum);

  if ( sts & 1 )
  {
    if ( ret == GR_F_UndelOff | ret == GR_F_NothUndel )
    {
      *msg = ret;
    }
  }
#ifdef DEBUG
  else
  {
    printf ("COch_undelete: GRundo.GRudundo failed\n");
  }
#endif


#ifdef DEBUG
  if (!(*msg & 1)) printf ("COch_undelete: *msg = %x\n", *msg);
  if (!(sts & 1)) om$report_error (sts = sts);
#endif

  return (sts & *msg & 1);
}


/*

Name
  COch_undel_toggle

Abstract
  This function toggles the state of undelete.

Synopsis
  IGRint COch_undel_toggle( msg, caller_id, caller_os, mod, events,
                            gschan, userdata)

  *msg       IGRlong           return code (0=set off ; 1 = set on)
  caller_id  OM_S_OBJID        calling object's id 
  caller_os  OMuword           calling object's osnum 
  *mod       struct GRmd_env   current module information 
  *events    struct GRevent    not used in this function
  *gschan    OM_S_CHANSELECT   containing object(s) to work with
  *userdata  char              unused

Description

Return Value
  TRUE  - successful
  FALSE - unsuccessful

Notes

Index

Keywords
  undelete toggle

History
  unknown  : unknown          : created
  02/09/93 : Shelley R. Heard : Fixed TR # 119300685/toggle status not returned

 */

#argsused
IGRint COch_undel_toggle (msg, caller_id, caller_os, mod, events, gschan, userdata)

IGRlong         *msg;           /* return code */
OM_S_OBJID       caller_id;     /* calling object's id */
OMuword          caller_os;     /* calling object's osnum */
struct GRmd_env *mod;           /* current module information */
struct GRevent  *events[];      /* event pointer array */
OM_S_CHANSELECT *gschan;        /* containing object(s) to work with */
char            *userdata;      /* unused */

{
  IGRint      sts, ret;
  OM_S_OBJID  undo_object;

  /*
   *  get the undo object's id
   */

  sts = ex$get_super (mod_id = mod->md_id.objid,
                      mod_osnum = mod->md_id.osnum,
                      super_name = "UNDO_OBJECT",
                      create = TRUE,
                      super_class = "GRundo",
                      super_id = &undo_object);
  if (!(sts & 1))
  {
#ifdef DEBUG
    printf ("COch_undel_toggle: ex$get_super failed\n");
#endif
    goto finish;
  }

  /*
   *  toggle undelete state
   */

  sts = om$send (msg = message GRundo.GRudonoff (msg, &ret),
                 senderid = caller_id,
                 targetid = undo_object,
                 targetos = mod->md_id.osnum);
  if ((sts & *msg & 1))
  {
    /* *** TR # 119300685 02/10/93 SRH *** */
    *msg = ret;  /* so that calling routine knows the current setting */
  }
#ifdef DEBUG
  else
  {
    printf ("COch_undel_toggle: GRundo.GRudonoff failed\n");
  }
#endif

finish:

#ifdef DEBUG
  if (!(*msg & 1)) printf ("COch_undel_toggle: *msg = %x\n", *msg);
  if (!(sts & 1)) om$report_error (sts = sts);
#endif

  return (sts & *msg & 1);
}



/*
Name 
  COch_name

Abstract
  This object passes the GRvg.GRchgname message to the object on the
  graphic set channel.

Synopsis
  IGRint COch_name (msg, caller_id, caller_os, mod, events, gschan, userdata)

  *msg       IGRlong          return code
                                MSSUCC - success
                                MSFAIL - failure
                                GR_E_INV_REQUEST - duplicate name
                                GRw_no_value - null name was passed in events[1]
  caller_id  OM_S_OBJID       calling object's id 
  caller_os  OMuword          calling object's osnum 
  *mod       struct GRmd_env  current module information 
  *events    struct GRevent   events[1] - keyin field used as new name
  *gschan    OM_S_CHANSELECT  containing object(s) to work with
  *userdata  char             unused

Return Values
  TRUE  - successful
  FALSE - unsuccessful

Keywords
  modify name 

*/

#argused
IGRint COch_name (msg, caller_id, caller_os, mod, events, gschan, userdata)

IGRlong         *msg;           /* return code */
OM_S_OBJID       caller_id;     /* calling object's id */
OMuword          caller_os;     /* calling object's osnum */
struct GRmd_env *mod;           /* current module information */
struct GRevent  *events[];      /* event pointer array */
OM_S_CHANSELECT *gschan;        /* containing object(s) to work with */
char            *userdata;      /* unused */

{
    IGRint              sts, ret;       /* return code */
    struct GRmd_env     dummy_mod;      /* filled in by gr$gspass */

    if (strlen (events[1]->event.keyin))
    {
        /* send the change name message */

        sts = gr$gspass (msg = &ret,
                         pass_msg = message GRvg.GRchgname
                                   (msg, &dummy_mod, events[1]->event.keyin),
                         path = &dummy_mod,
                         senderid = caller_id,
                         senderos = caller_os,
                         p_chanselect = gschan);

        /* update the directory form */
        di$update_dir_form();
    }
    else
    {
        /* don't give objects NULL names */

        *msg = GRw_no_value;
        ret = MSSUCC;
        sts = OM_S_SUCCESS;
    }

#ifdef DEBUG
    if (!(*msg & 1)) printf ("COch_name: *msg = %#x\n", *msg);
    if (!(ret & 1)) printf ("COch_name: ret = %#x\n", ret); 
    if (!(sts & 1)) om$report_error (sts = sts);
#endif

    return (sts & ret & *msg & 1);
}


/*
Name
  COch_dis_on

Abstract
  This function turns on the display of the object(s) on gschan.

Synopsis
  IGRint COch_name (msg, caller_id, caller_os, mod, events, gschan, userdata)

  *msg       IGRlong           return code set by GRvg.GRchgprops ( msg, ...)
  caller_id  OM_S_OBJID        calling object's id 
  caller_os  OMuword           calling object's osnum 
  *mod       struct GRmd_env   current module information 
  *events    struct GRevent    not used in this function
  *gschan    OM_S_CHANSELECT   containing object(s) to work with
  *userdata  char              unused

Return Value
  TRUE  - successful
  FALSE - unsuccessful

Keywords
  change properties display on

*/

#argsused
IGRint COch_dis_on (msg, caller_id, caller_os, mod, events, gschan, userdata)

IGRlong         *msg;           /* return code */
OM_S_OBJID       caller_id;     /* calling object's id */
OMuword          caller_os;     /* calling object's osnum */
struct GRmd_env *mod;           /* current module information */
struct GRevent  *events[];      /* event pointer array */
OM_S_CHANSELECT *gschan;        /* containing object(s) to work with */
char            *userdata;      /* unused */

{
    IGRshort            set = 1;    /* set property */
    IGRshort            property;   /* to change */
    IGRint              sts, ret;   /* return codes */
    enum GRdpmode       mode;       /* display mode */

    /*
     *  make the object(s) displayable
     */

    property = GRIS_DISPLAYABLE;

    sts = gr$gspass (msg = &ret,
                     pass_msg = message GRvg.GRchgprops (msg, &set, &property),
                     senderid = caller_id,
                     senderos = caller_os,
                     p_chanselect = gschan);

    /*
     * Display the object in the graphic set.
     */
    mode = GRbdhe;

    sts = gr$gsdisplay (msg = &ret,
                        dpmode = mode,
                        display_id = &(mod->md_id),
                        senderid = caller_id,
                        senderos = caller_os,
                        p_chanselect = gschan );
     
#ifdef DEBUG
    if (!(sts & ret & *msg & 1))
    {
        printf ("COch_dis_on: GRvg.GRchgprops failed\n");
    }

    if (!(*msg & 1)) printf ("COch_dis_on: *msg = %#x\n", *msg);
    if (!(ret & 1)) printf ("COch_dis_on: ret = %#x\n", ret); 
    if (!(sts & 1)) om$report_error (sts = sts);
#endif

    return (sts & ret & *msg & 1);
}


/*
Name 
  COch_dis_off

Abstract
  This function turns off the display of the object(s) on gschan.

Synopsis
  IGRint COch_dis_off (msg, caller_id, caller_os, mod, events, gschan, userdata)

  *msg       IGRlong           return msg set by GRchgprops(msg, ... )
  caller_id  OM_S_OBJID        calling object's id 
  caller_os  OMuword           calling object's osnum 
  *mod       struct GRmd_env   current module information 
  *events    struct GRevent    not used in this function
  *gschan    OM_S_CHANSELECT   containing object(s) to work with
  *userdata  char              unused

Return Value
  TRUE  - successful
  FALSE - unsuccessful

Keywords
  change properties display off

*/

#argsused
IGRint COch_dis_off (msg, caller_id, caller_os, mod, events, gschan, userdata)

IGRlong         *msg;           /* return code */
OM_S_OBJID       caller_id;     /* calling object's id */
OMuword          caller_os;     /* calling object's osnum */
struct GRmd_env *mod;           /* current module information */
struct GRevent  *events[];      /* event pointer array */
OM_S_CHANSELECT *gschan;        /* containing object(s) to work with */
char            *userdata;      /* unused */

{
    IGRshort            set = 0;    /* clear property */
    IGRshort            property;   /* to change */
    IGRint              sts, ret;   /* return codes */

    /*
     *  make the object(s) nondisplayable
     */

    property = GRIS_DISPLAYABLE;

    sts = gr$gspass (msg = &ret,
                     pass_msg = message GRvg.GRchgprops (msg, &set, &property),
                     senderid = caller_id,
                     senderos = caller_os,
                     p_chanselect = gschan);

#ifdef DEBUG
    if (!(sts & ret & *msg & 1))
    {
        printf ("COch_dis_off: GRvg.GRchgprops failed\n");
    }

    if (!(*msg & 1)) printf ("COch_dis_off: *msg = %#x\n", *msg);
    if (!(ret & 1)) printf ("COch_dis_off: ret = %#x\n", ret); 
    if (!(sts & 1)) om$report_error (sts = sts);
#endif

    return (sts & ret & *msg & 1);
}

/*

Name
  COch_loc_on

Abstract
  This function turns on the locatability of the object(s) on gschan.

Synopsis
  IGRint COch_loc_on (msg, caller_id, caller_os, mod, events, gschan, userdata)

  *msg       IGRlong           return code
  caller_id  OM_S_OBJID        calling object's id 
  caller_os  OMuword           calling object's osnum 
  *mod       struct GRmd_env   current module information 
  *events    struct GRevent    not used in this function
  *gschan    OM_S_CHANSELECT   containing object(s) to work with
  *userdata  char              unused


Description

Return Value
  TRUE  - successful
  FALSE - unsuccessful

Notes

Index

Keywords
  change locate properties

History
  02/10/93 : Shelley R. Heard : created

 */

#argsused
IGRint COch_loc_on (msg, caller_id, caller_os, mod, events, gschan, userdata)

IGRlong         *msg;           /* return code */
OM_S_OBJID       caller_id;     /* calling object's id */
OMuword          caller_os;     /* calling object's osnum */
struct GRmd_env *mod;           /* current module information */
struct GRevent  *events[];      /* event pointer array */
OM_S_CHANSELECT *gschan;        /* containing object(s) to work with */
char            *userdata;      /* unused */

{
    IGRshort            set = 1;    /* set property */
    IGRshort            property;   /* to change */
    IGRint              sts, ret;   /* return codes */

    /*
     *  make the object(s) locatable
     */

    property = GRIS_LOCATABLE;

    sts = gr$gspass (msg = &ret,
                     pass_msg = message GRvg.GRchgprops (msg, &set, &property),
                     senderid = caller_id,
                     senderos = caller_os,
                     p_chanselect = gschan);

#ifdef DEBUG
    if (!(sts & ret & *msg & 1))
    {
        printf ("COch_loc_on: GRvg.GRchgprops failed\n");
    }

    if (!(*msg & 1)) printf ("COch_loc_on: *msg = %#x\n", *msg);
    if (!(ret & 1)) printf ("COch_loc_on: ret = %#x\n", ret); 
    if (!(sts & 1)) om$report_error (sts = sts);
#endif

    return (sts & ret & *msg & 1);
}

/*
Name 
  COch_loc_off

Abstract
  This function turns off the locatability of the object(s) on gschan.

Synopsis
  IGRint COch_loc_off(msg, caller_id, caller_os, mod, events, gschan, userdata)

  *msg       IGRlong           return code
  caller_id  OM_S_OBJID        calling object's id 
  caller_os  OMuword           calling object's osnum 
  *mod       struct GRmd_env   current module information 
  *events    struct GRevent    not used in this function
  *gschan    OM_S_CHANSELECT   containing object(s) to work with
  *userdata  char              unused

Return Value
  TRUE  - successful
  FALSE - unsuccessful

Keywords
  change properties locate off

*/

#argsused
IGRint COch_loc_off (msg, caller_id, caller_os, mod, events, gschan, userdata)

IGRlong         *msg;           /* return code */
OM_S_OBJID       caller_id;     /* calling object's id */
OMuword          caller_os;     /* calling object's osnum */
struct GRmd_env *mod;           /* current module information */
struct GRevent  *events[];      /* event pointer array */
OM_S_CHANSELECT *gschan;        /* containing object(s) to work with */
char            *userdata;      /* unused */

{
    IGRshort            set = 0;    /* clear property */
    IGRshort            property;   /* to change */
    IGRint              sts, ret;   /* return codes */

    /*
     *  make the object(s) locatable
     */

    property = GRIS_LOCATABLE;

    sts = gr$gspass (msg = &ret,
                     pass_msg = message GRvg.GRchgprops (msg, &set, &property),
                     senderid = caller_id,
                     senderos = caller_os,
                     p_chanselect = gschan);

#ifdef DEBUG
    if (!(sts & ret & *msg & 1))
    {
        printf ("COch_loc_on: GRvg.GRchgprops failed\n");
    }

    if (!(*msg & 1)) printf ("COch_loc_on: *msg = %#x\n", *msg);
    if (!(ret & 1)) printf ("COch_loc_on: ret = %#x\n", ret); 
    if (!(sts & 1)) om$report_error (sts = sts);
#endif

    return (sts & ret & *msg & 1);
}

end implementation CEO_GSLOCATE;
