class implementation Root;

#include <stdio.h>
#include "EMSmsgdef.h"
#include "emsmacros.h"
#include "EMSbnddef.h"
#include "OMmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "emsdef.h"
#include "EMS.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "igetypedef.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "EMSmsgdef.h"
#include "emserr.h"

from EMSassoc import EMget_info;

IGRlong EFprint_comps(objid, osnum, findex, tindex)
GRobjid objid;
OMuword osnum;
IGRint  *findex, *tindex;
{
 IGRlong          OM_stat;
 OMuint           count, ii;
 OM_S_CHANSELECT  to_comps;
 IGRchar          name[OM_K_MAXCLASS_LEN];
 extern IGRlong   EFprint_assoc_info();

  
 EMmake_chanselect(GRcmpowner_to_components, &to_comps);
 OM_stat = om$get_channel_count(objid = objid,
                                osnum = osnum,
                                p_chanselect = &to_comps,
                                count = &count);
 if (!(1 & OM_stat)) goto wrapup;

 if(count) 
 {
   GRobjid comp_id;
   OMuword dumosnum;
   IGRchar keyin='n';       /*DECL*/

   fprintf(stderr,"\n\n Component list:");
   for(ii=0; ii<count; ii++)
   {
     OM_stat = om$get_objid_at_index(objid = objid,
                                     osnum = osnum,
                                     p_chanselect = &to_comps,
                                     index = ii,
                                     objidaddr = &comp_id,
                                     osnumaddr = &dumosnum);
     if (!(1 & OM_stat)) goto wrapup;

     OM_stat = om$get_classname(objid = comp_id,
                                osnum = osnum,
                                classname = name);
     if (! (1 & OM_stat)) goto wrapup;
 
     fprintf(stderr, 
             "\n Index=%d, Comp Id=%d, Classname=%s", ii, comp_id, name);
   }        

   EFgetchar (stderr, "\nDebug components? y/n [n] ", &keyin);
   if (toupper (keyin) == 'Y')
   {
     EFgetchar (stderr, "\nDebug all components? y/n [n] ", &keyin);
     if (toupper (keyin) != 'Y')
     {
       fprintf(stderr,"\n Enter from index : ");
       fflush(stdin);
       scanf("%d", findex);

       fprintf(stderr,"\n Enter to index : ");
       fflush(stdin);
       scanf("%d", tindex);
       fprintf(stderr,"\n");
     }
     else
     {
       *findex = 0;
       *tindex = OM_K_MAXINT;
     }
   }
   else
   {
     *findex = OM_K_MAXINT;
     *tindex = OM_K_MAXINT;
   }
 }
wrapup:
 return(OM_stat);
}

IGRlong EFprint_assoc_info(objid, osnum)
GRobjid objid;
OMuword osnum;
{
  IGRlong EMmsg=EMS_S_Success, OM_stat=OM_S_SUCCESS;
  IGRuint info_type=0, info_size=0;

  om$send(msg = message EMSassoc.EMget_info(&EMmsg, NULL, &info_type,
                &info_size, NULL),
          senderid = NULL_OBJID,
          targetid = objid,
          targetos = osnum);

  fprintf(stderr,"\n associative type = %d", info_type);
  fprintf(stderr,"\n associative info size = %d\n", info_size);

  { /*INTENTIONAL*/
    OMuint          count, ii;
    OM_S_CHANSELECT to_father, to_child;
    IGRchar         name[OM_K_MAXCLASS_LEN];

    EMmake_chanselect(NDfather_father, &to_father);
    OM_stat = om$get_channel_count(objid = objid, osnum = osnum,
                     p_chanselect = &to_father, count = &count);
    if (!(1 & OM_stat)) goto wrapup;
    if(count) 
    {
      GRobjid father_id;
      OMuword dumosnum;

      fprintf(stderr,"\n Parent list:");
      for(ii=0; ii<count; ii++)
      {
        OM_stat = om$get_objid_at_index(objid = objid, osnum = osnum,
                         p_chanselect = &to_father, index = ii,
                         objidaddr = &father_id, osnumaddr = &dumosnum);
        if (!(1 & OM_stat)) goto wrapup;
        OM_stat = om$get_classname(objid = father_id, osnum = osnum,
                                   classname = name);
        if (! (1 & OM_stat)) goto wrapup;

        fprintf(stderr, 
             "\n Index=%d, Father Id=%d, Classname=%s", ii, father_id, name);
      }
    }

    EMmake_chanselect(NDchildren_children, &to_child);
    OM_stat = om$get_channel_count(objid = objid, osnum = osnum,
                     p_chanselect = &to_child, count = &count);
    if (!(1 & OM_stat)) goto wrapup;
    if(count) 
    {
      GRobjid child_id;
      OMuword dumosnum;

      fprintf(stderr,"\n\n Child list:");
      for(ii=0; ii<count; ii++)
      {
        OM_stat = om$get_objid_at_index(objid = objid, osnum = osnum,
                         p_chanselect = &to_child, index = ii,
                         objidaddr = &child_id, osnumaddr = &dumosnum);
        if (!(1 & OM_stat)) goto wrapup;
        OM_stat = om$get_classname(objid = child_id, osnum = osnum,
                                   classname = name);
        if (! (1 & OM_stat)) goto wrapup;

        fprintf(stderr, 
             "\n Index=%d, Child Id=%d, Classname=%s", ii, child_id, name);
      }
      fprintf(stderr,"\n");
    }
  }
wrapup:
  return(OM_S_SUCCESS);
}

end implementation Root;
