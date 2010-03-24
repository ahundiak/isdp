class implementation OMOSCO;                                       /*+private*/

#include <stdio.h>
#include <string.h>
#include "OMerrordef.h"
#include "OMmacros.h"
#include "OMmetaclass.h"
#include "OMminimum.h"
#include "OMcluster.h"
#include "OMspecify.h"
#include "OMrelation.h"
#include "OMintprims.h"

extern int OM_Gi_defchan_size;
extern int OM_Gi_defchan_ext;
extern OMuint OM_Gf_unk_obj_support;
extern OMuint OM_Gf_dload_mode;

from OMObjSpace import add_class;


/*                               
----------- Method Description ------------------------------------------------

   Method name:      OMOSCO.initialize

   Input arguments:  OM_p_CLASSDEF    p_acld   Pointer to class definition
                                                for OSCO being constructed.
                     int              init_cnt Initial count for i_refcnt.
   Output arguments: None.

   The method initialize for OMOSCO is used when an OSCO object is newly
  constructed.  It adds the direct pointer to the OSCO instance to the
  OSCO_list in the OSD.  The method also works its way up the ancestry
  tree to Root and constructs any OSCOs that do not exist.  All instance
  data is initialized within this method.  The newly constructed OSCO
  object is connected to the OSO.

----------- Revision History --------------------------------------------------

 Oct-17-86  EMS   Added logic to set up the ActToFil and FilToAct maps
                  On this same day,  OMFiledOSi.I was modified to init
                  the maps to zeros instead of a one-to-one mapping.
                  This yields an easy way to find free entries in the 
                  FilToAct map.

Oct-31-86  TLG    Added logic to grow FilToAct map so we can add classes
		  dynamicly

-------------------------------------------------------------------------------
*/

method initialize ( OM_p_CLASSDEF p_acld; int init_cnt )
{
   int                 sts;
   int                 num_res, len, res_ptr;
   char                *cptr;
   OMuword             fil_classid;
   OMuword             comp_offset, num_vla;
   OM_S_OBJID          parent_objid;
   OM_S_NEIGHBOR       neighbor;
   OM_p_ANCESTRY       p_ancestor;
   OM_S_CHANSELECT     to_sel;
   OM_S_CHANSELECT     fr_sel;
   OM_p_CHANNEL_DEFN   p_chdef;
   OM_p_VARLENARR_DEFN p_vladef;
   char *new_p;
   OMuword             i;

#ifdef DEBUG
  printf ("OSCO.initialize - enter for OSCO of class %s\n",p_acld->s_name);
#endif

   /*================================================*/
   /*  add the new OSCO to the OSCO_list in the OSO  */
   /*================================================*/

   OM_Gp_CurOSD->OSCO_list[p_acld->w_classid] = &ME.OMOSCO->OSCO;

   /*=====================================================================*/
   /*  for each direct ancestor:                                          */
   /*   1) check if an OSCO exists and construct it if it does not exist  */
   /*   2) increment the child refcnt for the ancestor                    */
   /*=====================================================================*/

   if ( p_acld->w_classid != OM_K_ROOT_ACTCLASSID )
   {
      p_ancestor = p_acld->A_ancestor_list;
      for ( i=0; i<p_acld->w_numparents; i++, p_ancestor++ )
      {
         if ( OM_Gp_CurOSD->OSCO_list[*p_ancestor->p_classid] == NULL )
         {
#ifdef DEBUG
  printf ("OSCO.initialize - issue construct for OSCO of class %s\n",
           OM_GA_active_classes[*p_ancestor->p_classid]->s_name);
#endif
            neighbor.clusterid = 0;
            neighbor.groupid   = OM_GS_NULL_NEIGHBOR.groupid;

            sts = om$construct (classid  = OM_K_OMOSCO_ACTCLASSID,
                                osnum    = OM_Gw_current_OS,
                                p_objid  = &parent_objid,
                                neighbor = neighbor,
                                msg      = message OMOSCO.initialize
                             (OM_GA_active_classes[*p_ancestor->p_classid],0));
            if (!(1&sts)) return (sts);
         }
         OM_Gp_CurOSD->OSCO_list[*p_ancestor->p_classid]->w_child_refcnt++;
      }
   }

   /*==============================================*/
   /*  update p_spacemap if spacemap was streched  */
   /*==============================================*/

   p_spacemap = &OM_GA_OSDs[OM_Gw_current_OS]->Spacemap[my_id];

   /*=========================================*/
   /*  initialize ActToFil and FilToAct maps  */
   /*=========================================*/

   if ( p_acld->w_classid >= OM_GA_fa_mapsize[OM_Gw_current_OS] )
   {
      new_p = om$realloc(ptr=(char *) OM_GA_filed_to_active,
                            size=(p_acld->w_classid+1)*sizeof(OMuword));
      if ( new_p == NULL ) return(OM_E_NODYNMEM);
      OM_GA_filed_to_active = (OMuword *)(new_p);
      OM_GA_OSDs[OM_Gw_current_OS]->FilToAct = (OMuword *)(new_p);
      for (i=OM_GA_fa_mapsize[OM_Gw_current_OS];i<=p_acld->w_classid;i++)
           OM_GA_filed_to_active[i] = 0;
      OM_GA_fa_mapsize[OM_Gw_current_OS] = p_acld->w_classid + 1;
   }

   /*===================*/
   /* check for 1-1 map */
   /*===================*/

   if ( (!OM_GA_filed_to_active[p_acld->w_classid]) ||
        (OM_GA_filed_to_active[p_acld->w_classid] == p_acld->w_classid))
   {
      fil_classid = p_acld->w_classid;
   }
   else
   {
      for ( fil_classid=OM_K_NUM_META_CLASSES;
            fil_classid<OM_GA_fa_mapsize[OM_Gw_current_OS]; fil_classid++ )
      {
         if ( ! OM_GA_filed_to_active[fil_classid] ) break;
      }
   }

   OM_GA_active_to_filed[p_acld->w_classid] = fil_classid;
   OM_GA_filed_to_active[fil_classid] = p_acld->w_classid;

   /*=======================*/
   /*  initialize the OSCO  */
   /*=======================*/

   ME.OMOSCO->OSCO.w_classid        = fil_classid;
   ME.OMOSCO->OSCO.w_child_refcnt   = 0;
   strncpy (ME.OMOSCO->OSCO.s_name, p_acld->s_name, OM_K_MAXCLASS_LEN);
   ME.OMOSCO->OSCO.w_oppmaj_version = p_acld->w_oppmaj_version;
   ME.OMOSCO->OSCO.w_oppmin_version = p_acld->w_oppmin_version;
   ME.OMOSCO->OSCO.w_major_version  = p_acld->w_major_version;
   ME.OMOSCO->OSCO.w_minor_version  = p_acld->w_minor_version;
   ME.OMOSCO->OSCO.i_refcnt         = init_cnt;
   ME.OMOSCO->OSCO.OSCO_oid         = my_id;

   ME.OMOSCO->num_parents = p_acld->w_numparents;

   /*========================*/
   /*  store component info  */
   /*========================*/

   sts = om$vla_set_dimension(varray = ME.OMOSCO->component_list,
                              size   = p_acld->NumMsgClasses);
   if (!(sts&1)) return(sts);

   for ( i = 0; i<p_acld->NumMsgClasses; i++ )
   {
      ME.OMOSCO->component_list[i].classid =
        OM_GA_active_to_filed[p_acld->MsgMap[i].classid];
      ME.OMOSCO->component_list[i].offset = p_acld->MsgMap[i].offset;
   }

   /*===============================================================*/
   /*  the following will prevent storing VLA and channel info for  */
   /*  classes that have been rejected or have no instance data     */
   /*===============================================================*/

   if ( p_acld->MsgMap[p_acld->NumMsgClasses-1].offset )
   {
      /*============================================*/
      /*  store VLA info about this component only  */
      /*============================================*/

      comp_offset = p_acld->MsgMap[p_acld->NumMsgClasses-1].offset;
      p_vladef    = p_acld->p_varlenarr_defns;
      num_vla     = 0;
      for ( i=0; i<p_acld->w_num_varlenarrays; ++i, ++p_vladef )
      {
         if ((p_vladef->w_offset >= comp_offset) && 
             (!p_vladef->type)) ++num_vla;
      }

      if ( num_vla )
      {
         sts = om$vla_set_dimension(varray = ME.OMOSCO->vla_list,
                                    size   = num_vla);
         if (!(sts&1)) return(sts);
  
         p_vladef = p_acld->p_varlenarr_defns;
         num_vla  = 0;
         for ( i=0; i<p_acld->w_num_varlenarrays; ++i, ++p_vladef )
         {
            if ((p_vladef->w_offset >= comp_offset) && (!p_vladef->type))
            {
               ME.OMOSCO->vla_list[num_vla].elt_size =p_vladef->w_per_elt_size;
               ME.OMOSCO->vla_list[num_vla++].offset = 
                              p_vladef->w_offset - comp_offset; /*relative*/
            }
         }
      }

      /*======================*/
      /*  store channel info  */
      /*======================*/

      sts = om$vla_set_dimension(varray = ME.OMOSCO->chan_info,
                                 size   = p_acld->w_numchannels);
      if (!(sts&1)) return(sts);
 
      num_res = 0;
      res_ptr = 0;
      p_chdef = p_acld->ChanDefns;
      for ( i=0; i<p_acld->w_numchannels; ++i )
      {
         if ( p_chdef[i].p_type->w_flags & CD_restricted )
         {
            ++num_res;
            cptr = (char *) strchr((char *) p_chdef[i].p_type->classids,'.');
            len = (OMuint)cptr - (OMuint)p_chdef[i].p_type->classids;
            sts = om$vla_set_dimension(varray = ME.OMOSCO->res_classname,
                                       size   = res_ptr+len+1);
            if (!(sts&1)) return(sts);
            sts = om$vla_set_dimension(varray = ME.OMOSCO->res_channum,
                                       size   = num_res);
            if (!(sts&1)) return(sts);

            ME.OMOSCO->res_channum[num_res-1] = p_chdef[i].p_type->channum.number;
            strncpy(&ME.OMOSCO->res_classname[res_ptr],
                    (char *) p_chdef[i].p_type->classids, len);
            res_ptr += len;
            ME.OMOSCO->res_classname[res_ptr++] = 0;
            ME.OMOSCO->chan_info[i].offset = (OMuword)p_chdef[i].i_offset;
            ME.OMOSCO->chan_info[i].type   = p_chdef[i].p_type->w_flags;
         }
         else
         {
            ME.OMOSCO->chan_info[i].offset = p_chdef[i].i_offset;
            ME.OMOSCO->chan_info[i].type   = p_chdef[i].p_type->w_flags;
         }
      }
   }

   ME.OMOSCO->component_size = p_acld->NewInstanceSize;

   /*============================================================*/
   /*  special boot-up case for OSCO OSCO to up refcnt for Root  */
   /*  and one of either OMMOSDOS, OMTransOS, or OMFiledOS       */
   /*============================================================*/

   if ( p_acld->w_classid == OM_K_OMOSCO_ACTCLASSID )
   {
      ME.OMOSCO->OSCO.i_refcnt += 2;
   }

   to_sel.type = OM_e_name;
   to_sel.u_sel.name = "OMObjSpace.to_OSCOs";

   fr_sel.type = OM_e_addr;
   fr_sel.u_sel.addr = &ME.OMOSCO->to_OSO;

   /*===================================*/
   /*  connect the new OSCO to the OSO  */
   /*===================================*/

#ifdef DEBUG
  printf ("OSCO.initialize - connecting OSCO of class %s to OSO\n",
          p_acld->s_name);
#endif

   sts = om$send ( msg=message Root.connect(to_sel, 0, my_id,
                                            OM_Gw_current_OS, fr_sel, 0),
                   targetid=OM_GO_current_OS_objid );
   if (!(1&sts)) return (sts);

   return (OM_S_SUCCESS);
}


/*
----------- Method Description ------------------------------------------------
  
   Method name:      OMOSCO.set_up

   Input arguments:  

   Output arguments: 

   The set_up method for OMOSCO is used to add the direct pointer to the
  OSCO instance data to the OSCO_list in the OSD.  The set_up method is
  invoked via a channel send out the OSO's OSCO channel when an object
  space is being constructed (read in).  The set_up method also builds
  the filed_to_active and active_to_filed class maps for an object space.

----------- Revision History --------------------------------------------------

Oct-31-86  TLG	Added logic to grow FilToAct map if needed so we can
		add classes dynamicly.

-------------------------------------------------------------------------------
*/

method set_up ()
{
   int      sts, i;
   OMuword  act_classid, fil_classid;
   char     filed_only = 0;
   char     *new_p;
   int                    *p_parent_list;
   char                   *p_class;     /* for dynamic class */
   OM_p_CLASSDEF           p_acld;
   struct component_list_struct *p_tmp_list;

#ifdef UNK_CLASS
   int      j, k, l, m, comp_dim, chan_dim, vla_dim, num_res,
            res_ptr, len=0;
   int      res1chan_count=0;
   OMuword  comp_offset, num_parents,
            fclassid, num_vla, chan_off, aclassid, anc_offset,
            this_comp_offset;

   OM_p_OBJECTHDR          my_me;
   OM_p_CLASSDEF           p_anc_acld;
   OMuint                  size;
   OM_p_OBJECTHDR          p_instance;
   OM_S_CREATECLASS_ARGS   cc_args;
   OM_p_CHANNEL_DEFN       p_chdef=0;
   OM_p_CHANNEL_TYPE_DEFN  p_chtyp=0;
   OM_p_VARLENARR_DEFN     p_vladef=0, p_cc_vladef=0;
   OM_p_ANCESTRY           p_ances=0;
   OM_p_COMPCLASSDEF       p_comp=0;
#endif

   /*====================================*/
   /*  determine if this class is known  */
   /*====================================*/

   sts = om$get_class(classname = ME.OMOSCO->OSCO.s_name,
                      p_classid = &act_classid,
                      pp_cld    = &p_acld );
   if ( sts == OM_E_NOSUCHCLASS )
   {
      filed_only = 1;
   }
   else
   {
      if ( ! ( sts & 1 ) ) return( sts );
   }

   fil_classid = ME.OMOSCO->OSCO.w_classid;

   if ( OM_GA_fa_mapsize[OM_Gw_current_OS] < (OMuword) (fil_classid+1))
   {
        new_p = om$realloc(ptr=(char *) OM_GA_filed_to_active,
                              size=(fil_classid+1)*sizeof(OMuword));
        if ( new_p == NULL )
                return(OM_E_NODYNMEM);
        OM_GA_filed_to_active = (OMuword *)(new_p);
        OM_GA_OSDs[OM_Gw_current_OS]->FilToAct = (OMuword *)(new_p);
        for (i=OM_GA_fa_mapsize[OM_Gw_current_OS]; i<=(int)fil_classid; i++ )
           OM_GA_filed_to_active[i] = 0;
        OM_GA_fa_mapsize[OM_Gw_current_OS] = fil_classid + 1;
   }

#ifdef UNK_CLASS
   /*==============================*/
   /*  check for an unknown class  */
   /*==============================*/

   if ( filed_only && ME.OMOSCO->OSCO.w_oppmaj_version && 
        OM_Gf_unk_obj_support )
   {
      /*===========================*/
      /*  build create class args  */
      /*===========================*/

      num_parents = ME.OMOSCO->num_parents;
      comp_dim    = OM_DIMENSION_OF(ME.OMOSCO->component_list);
      comp_offset = ME.OMOSCO->component_list[comp_dim-1].offset;
      chan_dim    = OM_DIMENSION_OF(ME.OMOSCO->chan_info);
      vla_dim     = OM_DIMENSION_OF(ME.OMOSCO->vla_list);

      cc_args.oppMajVer = ME.OMOSCO->OSCO.w_oppmaj_version;
      cc_args.oppMinVer = ME.OMOSCO->OSCO.w_oppmin_version;
      cc_args.MajVer    = ME.OMOSCO->OSCO.w_major_version;
      cc_args.MinVer    = ME.OMOSCO->OSCO.w_minor_version;
      strncpy (cc_args.s_name, ME.OMOSCO->OSCO.s_name, OM_K_MAXCLASS_LEN);
      cc_args.NewInstanceSize = ME.OMOSCO->component_size;
      cc_args.InstanceSize    = ME.OMOSCO->component_size + comp_offset;

      cc_args.NumParents    = num_parents;
      cc_args.NumMethods    = 0;
      cc_args.NumComponents = comp_dim;
      cc_args.NumChannels   = chan_dim;

      /*========================*/
      /*  create channel defns  */
      /*========================*/

      if ( chan_dim )
      {
         p_chdef = (OM_p_CHANNEL_DEFN) om$malloc
                        ( size = (chan_dim * sizeof(OM_S_CHANNEL_DEFN)) );
         if (!p_chdef) return(OM_E_NODYNMEM);
         p_chtyp = (OM_p_CHANNEL_TYPE_DEFN) om$malloc
                        ( size = (chan_dim * sizeof(OM_S_CHANNEL_TYPE_DEFN)) );
         if (!p_chtyp) return(OM_E_NODYNMEM);

         num_res = 0;
         res_ptr = 0;
         for ( i=0; i<chan_dim; ++i )
         {
            p_chdef[i].p_type     = &p_chtyp[i];
            p_chdef[i].i_offset   = (int)(ME.OMOSCO->chan_info[i].offset);
            p_chdef[i].s_name     = "XXX";
            p_chtyp[i].w_flags    = ME.OMOSCO->chan_info[i].type;
            p_chtyp[i].s_name     = "YYY";
            p_chtyp[i].ClassCount = 0;
            p_chtyp[i].classids   = 0;
            if ( p_chtyp[i].w_flags & (CD_1_1|CD_m_1))
            {
               p_chtyp[i].InitCount  = -1;
               p_chtyp[i].ExtCount   = -1;
            }
            else
            {
               p_chtyp[i].InitCount  = OM_Gi_defchan_size;
               p_chtyp[i].ExtCount   = OM_Gi_defchan_ext;
            }  
            if (p_chtyp[i].w_flags & CD_restricted)
            {
               if (p_chtyp[i].w_flags & (CD_1_1|CD_m_1)) ++res1chan_count;
               p_chtyp[i].channum.number = ME.OMOSCO->res_channum[num_res];
               len = strlen(&ME.OMOSCO->res_classname[res_ptr]);
               p_chtyp[i].classids = om$calloc(num=1, size=len+1);
               strcpy(p_chtyp[i].classids, &ME.OMOSCO->res_classname[res_ptr]);
               p_chtyp[i].ClassCount = 1;
               res_ptr += (len + 1);
               ++num_res;
            }
            else
            {
               p_chtyp[i].channum = NULL_CHANNUM;
            }
         }
         cc_args.p_ChannelDefns = p_chdef;
      }
      else
      {
         cc_args.p_ChannelDefns = 0;
      }

      /*=============================*/
      /*  create the VLA defnitions  */
      /*=============================*/

      num_vla = 0;
      p_cc_vladef = 0;

      for ( i=0; i<comp_dim-1; ++i ) 
      {
         fclassid = ME.OMOSCO->component_list[i].classid;
         aclassid = OM_GA_filed_to_active[fclassid];

         if ( aclassid == OM_K_NOTUSING_CLASSID ||
              ((aclassid == 0) && ((i) != 0))) continue;
            
         p_anc_acld = OM_GA_active_classes[aclassid];
         anc_offset = p_anc_acld->MsgMap[p_anc_acld->NumMsgClasses-1].offset;
         if (!anc_offset) continue;
         this_comp_offset = ME.OMOSCO->component_list[i].offset;

         p_vladef = p_anc_acld->p_varlenarr_defns;
         for ( j=0; j < p_anc_acld->w_num_varlenarrays; ++j, ++p_vladef )
         {
            if ( p_vladef->w_offset >= anc_offset )
            {
               if ( p_cc_vladef )
                  p_cc_vladef = om$realloc (
                                size = sizeof(OM_S_VARLENARR_DEFN)*(num_vla+1),
                                ptr  = (char *) p_cc_vladef);
               else
                  p_cc_vladef = om$malloc (
                                size = sizeof(OM_S_VARLENARR_DEFN));
               if (!p_cc_vladef) return (OM_E_NODYNMEM);

               p_cc_vladef[num_vla].w_count = 0;
               p_cc_vladef[num_vla].w_per_elt_size = p_vladef->w_per_elt_size;
               p_cc_vladef[num_vla].type = p_vladef->type;
               p_cc_vladef[num_vla].w_offset = this_comp_offset + 
                                     (p_vladef->w_offset - anc_offset);
               ++num_vla;
            }
         }
      }

      /*=====================================*/
      /*  now process this component's VLAs  */
      /*=====================================*/

      j = 0;
      k = 0;
      for ( i=0; i<(chan_dim + vla_dim); ++i )
      {
         l = 0;       /* assume vla */
         if ( j < chan_dim && k < vla_dim )
         {
            if (ME.OMOSCO->chan_info[j].offset < ME.OMOSCO->vla_list[k].offset)
               l = 1;
         }
         else
         {
            if ( j < chan_dim ) l = 1;   /* must be channel */
         }

         /*==================*/
         /*  skip res1chans  */
         /*==================*/

         if ( l && ((ME.OMOSCO->chan_info[j].type & CD_restricted) &&
                    (ME.OMOSCO->chan_info[j].type & (CD_1_1|CD_m_1))))
         {
            ++j;
            continue;
         }
         if ( p_cc_vladef )
            p_cc_vladef = om$realloc (
                              size = sizeof(OM_S_VARLENARR_DEFN)*(num_vla+1),
                              ptr  = (char *) p_cc_vladef);
         else
            p_cc_vladef = om$malloc (size = sizeof(OM_S_VARLENARR_DEFN));
         if (!p_cc_vladef) return (OM_E_NODYNMEM);

         p_cc_vladef[num_vla].w_count = 0;
         if ( l )
         {
            p_cc_vladef[num_vla].w_per_elt_size = 4;
            p_cc_vladef[num_vla].type = 1;
            p_cc_vladef[num_vla].w_offset = comp_offset + 
                                            ME.OMOSCO->chan_info[j++].offset;
         }
         else
         {
            p_cc_vladef[num_vla].w_per_elt_size = ME.OMOSCO->vla_list[k].elt_size;
            p_cc_vladef[num_vla].type = 0;
            p_cc_vladef[num_vla].w_offset = comp_offset + 
                                            ME.OMOSCO->vla_list[k++].offset;
         }
         ++num_vla;
      }

      if ( num_vla )
         cc_args.p_VLAdefns = p_cc_vladef;
      else
         cc_args.p_VLAdefns = 0;

      cc_args.NumVLAs     = num_vla;
      cc_args.p_MethDefns = 0;

      /*===============================*/
      /*  create ancestry definitions  */
      /*===============================*/

      p_ances = (OM_p_ANCESTRY) om$malloc
                  ( size = (num_parents * sizeof(OM_S_ANCESTRY)) );
      if (!p_ances) return (OM_E_NODYNMEM);

      for ( i=num_parents-1; i>=0; --i )
      {
         fclassid = ME.OMOSCO->component_list[comp_dim-2-i].classid;
         aclassid = OM_GA_filed_to_active[fclassid];

         if ( aclassid == OM_K_NOTUSING_CLASSID ||
              ((aclassid == 0) && ((comp_dim-2-i) != 0))) continue;
            
         p_anc_acld = OM_GA_active_classes[aclassid];
         p_ances[i].p_classid     = &p_anc_acld->w_classid;
         p_ances[i].p_create_args = 0;
         p_ances[i].MajVer        = p_anc_acld->w_major_version;
         p_ances[i].MinVer        = p_anc_acld->w_minor_version;
         p_ances[i].p_sibling     = 0;
         p_ances[i].p_classdef    = 0;
      }

      cc_args.ancestors = p_ances;

      /*================================*/
      /*  create component definitions  */
      /*================================*/

      p_comp = (OM_p_COMPCLASSDEF) om$malloc
                  ( size = (comp_dim * sizeof(OM_S_COMPCLASSDEF)) );
      if (!p_comp) return (OM_E_NODYNMEM);

      for ( i=0; i<comp_dim; ++i )
      {
         p_comp[i].NumOverRides = 0;
         p_comp[i].NumInherits  = 0;
         p_comp[i].OverRides    = 0;
         p_comp[i].Inherits     = 0;
         p_comp[i].offset       = ME.OMOSCO->component_list[i].offset;
         if ( i < comp_dim-1 )
         {
            fclassid = ME.OMOSCO->component_list[i].classid;
            aclassid = OM_GA_filed_to_active[fclassid];

            if ( aclassid == OM_K_NOTUSING_CLASSID ||
                 ((aclassid == 0) && (i != 0))) continue;
            
            p_anc_acld = OM_GA_active_classes[aclassid];
            p_comp[i].p_classid = &p_anc_acld->w_classid;
         }
         else
         {
            p_comp[i].p_classid = &act_classid;
         }
      }

      cc_args.components = p_comp;
      cc_args.ClassDispTbl = 0;
      cc_args.p_class_id = &act_classid;

      /*====================================*/
      /*  create the poor ostricized class  */
      /*====================================*/

      sts = som_create_class ( &cc_args, &act_classid );

      /*===============*/
      /*  free memory  */
      /*===============*/

      if ( p_chdef )  om$dealloc ( ptr = (char *) p_chdef );
      if ( p_chtyp )  om$dealloc ( ptr = (char *) p_chtyp );
      if ( p_cc_vladef ) om$dealloc ( ptr = (char *) p_cc_vladef );
      if ( p_ances )  om$dealloc ( ptr = (char *) p_ances );
      if ( p_comp  )  om$dealloc ( ptr = (char *) p_comp );

      /*==================================================================*/
      /*  send add_class message to this OS to stretch A/F and OSCO_list  */
      /*==================================================================*/

      sts = om$send ( msg = message OMObjSpace.add_class
                                         (ME.OMOSCO->OSCO.s_name,act_classid),
                      targetid = OM_GO_current_OS_objid );
      if (!(1&sts)) return (sts);
   }
#endif   /* UNK_CLASS */

   /*=======================================*/
   /* Are we dealing with a dynamic class ? */
   /*=======================================*/

   if ( (ME.OMOSCO->OSCO.w_oppmaj_version == 0) && filed_only )
   {

#ifdef DEBUG
printf("\n******* Calling om$dynamic_class from OSCO.set_up *******\n");
#endif
      OM_GA_filed_to_active[fil_classid] = OM_K_NOTUSING_CLASSID;

      /* Malloc the parent class list */

      if (NULL == (p_parent_list = (int *)om$malloc
                     (size=sizeof(OM_p_FUNCPTR)*ME.OMOSCO->num_parents)))
      {
         return(OM_E_NODYNMEM);
      }
      if (NULL == (p_class = om$malloc
                     (size=OM_K_MAXCLASS_LEN*ME.OMOSCO->num_parents)))
      {
         om$dealloc ( ptr = (char *) p_parent_list );
         return(OM_E_NODYNMEM);
      }

      p_tmp_list =
        &ME.OMOSCO->component_list[ME.OMOSCO->component_list_descr.i_count-2];
      for ( i=0; i<(int) ME.OMOSCO->num_parents; i++ )
      {
         sts=om$get_classname(classid=OM_GA_filed_to_active[p_tmp_list->classid],
                              classname=&p_class[i*OM_K_MAXCLASS_LEN]);
         if (!(sts&1)) {   /* unknown component -- don't error out */
            om$dealloc ( ptr = (char *) p_parent_list );
            om$dealloc ( ptr = (char *) p_class );
            return(OM_S_SUCCESS);
         }

         p_parent_list[i] = (int)&p_class[i*OM_K_MAXCLASS_LEN];

#ifdef DEBUG
printf("\n*** parent %d : %s\n", i, p_parent_list[i]);
#endif
         p_tmp_list--;
      }

      sts = om$dynamic_class(p_parent_class=(char **)p_parent_list,
                             num_parents=ME.OMOSCO->num_parents,
                             maj_version=ME.OMOSCO->OSCO.w_major_version,
                             min_version=ME.OMOSCO->OSCO.w_minor_version,
                             p_dynamic_class=ME.OMOSCO->OSCO.s_name);
      if ( (!(sts&1)) && (sts!=OM_W_CLASS_EXISTS) )
      {
         om$dealloc ( ptr = (char *) p_parent_list );
         om$dealloc ( ptr = (char *) p_class );
         return(sts);
      }

      sts = om$get_classid(classname=ME.OMOSCO->OSCO.s_name,p_classid=&act_classid);
      if ( !(sts&1)) {
         om$dealloc ( ptr = (char *) p_parent_list );
         om$dealloc ( ptr = (char *) p_class );
         return (sts);
      }

#ifdef DEBUG
printf("\n*** Call OMOSCO.add_class from set_up and grow the OSCO list***\n");
printf("OM_Gw_numclasses: %d     act_classid: %d  \n",OM_Gw_numclasses, act_classid);
#endif

      new_p = om$realloc(ptr= (char *) OM_Gp_CurOSD->OSCO_list,
                            size=OM_Gw_numclasses*sizeof(OM_p_OSCO) );
      if ( new_p == NULL) return(OM_E_NODYNMEM);
      OM_Gp_CurOSD->OSCO_list = ( OM_p_OSCO *)(new_p);
      OM_Gp_CurOSD->OSCO_list[act_classid] = &ME.OMOSCO->OSCO;

      sts = om$send(msg=message OMOSCO.add_class(ME.OMOSCO->OSCO.s_name,
                        act_classid),
                    senderid=my_id,
                    targetid=my_id);
      if ( !(sts&1) ) {
         om$dealloc ( ptr = (char *) p_parent_list );
         om$dealloc ( ptr = (char *) p_class );
         return (sts);
      }
      om$dealloc ( ptr = (char *) p_parent_list );
      om$dealloc ( ptr = (char *) p_class );
   }
   else

   {
      /*======================================*/
      /*  initialize the filed to active map  */
      /*======================================*/

      if ( filed_only )
      {
         OM_GA_filed_to_active[fil_classid] = OM_K_NOTUSING_CLASSID;
      }
      else
      {
         OM_GA_filed_to_active[fil_classid] = act_classid;
         OM_GA_active_to_filed[act_classid] = fil_classid;

         /*====================================*/
         /*  add new OSCO to OSCO_list in OSO  */
         /*====================================*/

         OM_Gp_CurOSD->OSCO_list[act_classid] = &ME.OMOSCO->OSCO;
      }

#ifdef DEBUG
  printf ("OSCO.set_up - adding OSCO for class %s to list in OS %d\n",
   OM_GA_active_classes[act_classid]->s_name, OM_Gw_current_OS);
#endif

   }

   return (OM_S_SUCCESS);
}


/*
----------- Method Description ------------------------------------------------

   Method name:      OMOSCO.delete

   Input arguments:  int       defer_flag       Not used

   Output arguments: None.

   The OMOSCO delete method performs a number of clean-up tasks prior to
  issuing a Root.delete on the OSCO object.  The only way an OSCO object
  will be deleted is if all objects of the class the OSCO represents are
  deleted from an object space.  The other catch is that if an instance
  exists from a subclass of the OSCO being deleted,  then the OSCO must
  remain in existence.  The field "child_refcnt" is used to mark that 
  an OSCO exists that represents a subclass of the OSCO in question.
  This method will remove the direct pointer to the OSCO from the list
  in the OSD.

-------------------------------------------------------------------------------
*/

method delete ( int defer_flag )
{
   int            sts;
   OMuword        a_classid, f_classid;
   OM_p_CLASSDEF  p_acld;
   OM_p_ANCESTRY  p_ancestor;
   OM_p_OSCO      p_OSCO;
   OMuword        i;

#ifdef DEBUG
  printf ("OSCO.delete - deleting OSCO for class %s in OS %d\n",
   OM_GA_active_classes[OM_GA_filed_to_active[ME.OMOSCO->OSCO.w_classid]]->
   s_name, OM_Gw_current_OS);
#endif

   /*=================================================*/
   /*  remove the OSCO from the OSCO_list in the OSO  */
   /*=================================================*/

   f_classid = ME.OMOSCO->OSCO.w_classid;
   a_classid = OM_GA_filed_to_active[f_classid];

   OM_Gp_CurOSD->OSCO_list[a_classid] = NULL;

   p_acld = OM_GA_active_classes[a_classid];

   /*=====================================================================*/
   /*  run thru the direct parent list and decriment the child refcnt for */
   /*  the parent's OSCO - if parent's child refcnt goes to zero and its  */
   /*  refcnt is zero - delete it                                         */
   /*=====================================================================*/

   p_ancestor = p_acld->A_ancestor_list;
   for ( i=0; i<p_acld->w_numparents; i++, p_ancestor++ )
   {
      p_OSCO = OM_Gp_CurOSD->OSCO_list[*p_ancestor->p_classid];

      if ( (--p_OSCO->w_child_refcnt == 0) && (p_OSCO->i_refcnt == 0) )
      {
#ifdef DEBUG
  printf ("OSCO.delete - sending delete to OSCO of class %s\n",p_OSCO->s_name);
#endif
         sts = om$send ( msg=message OMOSCO.delete(defer_flag),
                         senderid=p_OSCO->OSCO_oid,
                         targetid=p_OSCO->OSCO_oid );
         if (!(1&sts)) return (sts);
      }
   }

   /*==============================================*/
   /*  send Root.delete to the OSCO being deleted  */
   /*==============================================*/

   sts = om$send ( mode=OM_e_wrt_message, msg=message Root.delete(defer_flag),
                   senderid=my_id, targetid=my_id );
   if (!(1&sts)) return (sts);

   OM_GA_filed_to_active[f_classid] = 0;
   OM_GA_active_to_filed[a_classid] = 0;

   return (OM_S_SUCCESS);
}


/*
----------- Method Description ------------------------------------------------

   Method name:      OMOSCO.add_class

   Input arguments:  char *classname;
		     OMuword act_classid;

   Output arguments: None.

   If the classname equals OSCO classname, we grow the ActToFil array
   by one, fill it in and do the same for the FilToAct if necessary.
   Return STOP_SENDING if match was found, else return success.

-------------------------------------------------------------------------------
*/

method add_class( char *name; OMuword classid )

{
char    *new_p;
OMuword i;

#ifdef DEBUG
printf("\n*** Entering OMOSCO.add_class ***\n\n");
printf("classname: %s\n", name);
printf("classid: %d\n", classid);
#endif

if ( strcmp(ME.OMOSCO->OSCO.s_name, name)==0 )

	{
	
	/* Update A->F array by one and store filed classid in last entry.
	   OM_Gw_numclasses has already been increased by one */

#ifdef DEBUG
printf("\n*** Update A->F in OMOSCO.add_class by 1 and store\n");
printf("filed classid in last entry. \n");
#endif
	new_p = om$realloc(ptr= (char *) OM_GA_active_to_filed,
			      size=OM_Gw_numclasses*sizeof(OMuword));
	if ( new_p == NULL )	
		return(OM_E_NODYNMEM);
	OM_GA_active_to_filed = (OMuword *)(new_p);
	OM_GA_OSDs[OM_Gw_current_OS]->ActToFil = (OMuword *)(new_p);
	OM_GA_active_to_filed[OM_Gw_numclasses-1] = ME.OMOSCO->OSCO.w_classid;
	
	if ( OM_GA_fa_mapsize[OM_Gw_current_OS] <
             (OMuword) (ME.OMOSCO->OSCO.w_classid+1))
		{
#ifdef DEBUG
printf("\n*** Update F->A array in OMOSCO.add_class ***\n\n");
#endif
		new_p = om$realloc(ptr= (char *) OM_GA_filed_to_active,
				      size=(ME.OMOSCO->OSCO.w_classid+1)*
			              sizeof(OMuword));
		if ( new_p == NULL )
			return(OM_E_NODYNMEM);
		OM_GA_filed_to_active = (OMuword *)(new_p);
		OM_GA_OSDs[OM_Gw_current_OS]->FilToAct = (OMuword *)(new_p);
                for ( i=OM_GA_fa_mapsize[OM_Gw_current_OS];
                      i<=ME.OMOSCO->OSCO.w_classid; i++ )
                   OM_GA_filed_to_active[i] = 0;
		OM_GA_fa_mapsize[OM_Gw_current_OS] = ME.OMOSCO->OSCO.w_classid + 1;
		OM_GA_filed_to_active[ME.OMOSCO->OSCO.w_classid] = classid;
		}

	else if (OM_GA_filed_to_active[ME.OMOSCO->OSCO.w_classid]==OM_K_NOTUSING_CLASSID)
		{
		OM_GA_filed_to_active[ME.OMOSCO->OSCO.w_classid] = classid;
		}
#ifdef DEBUG
printf("\n*** Return STOP SENDING from OMOSCO.add_class ***\n\n");
#endif
        /*============================================================*/
        /* if dynamic load of class then we must update the OSCO_list */
        /*============================================================*/

        if (OM_Gf_dload_mode) {
           new_p = om$realloc(ptr= (char *) OM_Gp_CurOSD->OSCO_list,
                                 size=OM_Gw_numclasses*sizeof(OM_p_OSCO ) );
           if ( new_p == NULL ) return(OM_E_NODYNMEM);

           OM_Gp_CurOSD->OSCO_list = ( OM_p_OSCO *)(new_p);
           OM_Gp_CurOSD->OSCO_list[OM_Gw_numclasses-1] = &ME.OMOSCO->OSCO;
        }

	return( OM_I_STOP_SENDING );

	}

return( OM_S_SUCCESS );

}


method get_res_cnum ( OMuword cnum; OMuword *res_cnum )
{
   *res_cnum = ME.OMOSCO->res_channum[cnum];
   return (OM_S_SUCCESS);
}

/*================================================================*/
/* this private method is used by connect_build_fake_side to      */
/* find the OSCO info representing a channel of an unknown class  */
/*================================================================*/

method get_chan_info ( OMuword fil_classid; OM_S_CHANNUM channum; 
                       int *p_compoff; int *p_chanoff; OMuword *p_type )
{
   int  i, sts, comp_dim, comp2_off;
   OM_S_CHANSELECT csel;
   
   /*======================================*/
   /*  must find a match on filed classid  */
   /*======================================*/

   if (fil_classid == ME.OMOSCO->OSCO.w_classid) {

      /*=====================================================*/
      /*  This method can be used to get the component_size  */
      /*  by giving a channum.classid of 0xffff              */
      /*=====================================================*/
 
      if (channum.classid == 0xffff) {
         *p_compoff = ME.OMOSCO->component_size;
         return (OM_I_STOP_SENDING);
      }

      comp_dim = om$dimension_of ( varray = ME.OMOSCO->component_list );
      for (i=0; i<comp_dim; ++i) {
         if (ME.OMOSCO->component_list[i].classid == channum.classid) {
            *p_compoff = ME.OMOSCO->component_list[i].offset;
            break;
         }
      }

      if (i == comp_dim) {
         printf("OMOSCO.get_chan_info::could not find component\n");
         return(OM_E_NOSUCHCLASS);
      }
 
      /*=====================================*/
      /*  is the classid this component's ?  */
      /*=====================================*/

      if (i == comp_dim-1) {
         *p_chanoff = ME.OMOSCO->chan_info[channum.number].offset;
         *p_type   = ME.OMOSCO->chan_info[channum.number].type;
      }
      else {
         /*=================================================*/
         /* channel must be in another component - send to  */
         /* OSCOs to find component and get channel offset  */
         /*=================================================*/
         
         csel.type = OM_e_name;
         csel.u_sel.name = "OMObjSpace.to_OSCOs";
         sts = om$send ( msg = message OMOSCO.get_chan_info (channum.classid,
                                      channum, &comp2_off, p_chanoff, p_type),
                         senderid = 0,
                         p_chanselect = &csel );
         if (!(1&sts)) {
            printf ("OMOSCO.get_chan_info::send for component info fail\n");
         }                       
      }
      return (OM_I_STOP_SENDING);
   }
   return (OM_S_SUCCESS);
}


/*=======================================*/
/*  this private method is used to form  */
/*  vla definitions for unknown classes  */
/*=======================================*/

method get_vla_info ( OMuword fil_classid; int comp_offset;
                      struct OM_sd_varlenarr_defn **pp_vad; OMuword *num_vla )
{
   int chan_dim, vla_dim, i, j, k, l;

   if (fil_classid == ME.OMOSCO->OSCO.w_classid) {
      chan_dim = om$dimension_of ( varray = ME.OMOSCO->chan_info );
      vla_dim  = om$dimension_of ( varray = ME.OMOSCO->vla_list );
      j = 0;
      k = 0;
      for (i=0; i<(chan_dim+vla_dim); ++i) {
         l = 0; /* assume vla */
         if ( j < chan_dim && k < vla_dim ) {
            if (ME.OMOSCO->chan_info[j].offset < ME.OMOSCO->vla_list[k].offset)
               l = 1;
         }
         else {
            if ( j < chan_dim ) l = 1;
         }

         /*==================*/
         /*  skip res1chans  */
         /*==================*/

         if ( l && ((ME.OMOSCO->chan_info[j].type & CD_restricted) &&
                    (ME.OMOSCO->chan_info[j].type & (CD_1_1|CD_m_1)))) {
            ++j;
            continue;
         }

         if (*pp_vad) 
            *pp_vad = (struct OM_sd_varlenarr_defn *) om$realloc (
                      size = sizeof(OM_S_VARLENARR_DEFN) * (*num_vla+1),
                      ptr  = (char *) *pp_vad );
         else 
            *pp_vad = (struct OM_sd_varlenarr_defn *)
               om$malloc (size = sizeof(OM_S_VARLENARR_DEFN));
         if (! *pp_vad) return (OM_E_NODYNMEM);

         (*pp_vad)[*num_vla].w_count = 0;
         if (l) {
            (*pp_vad)[*num_vla].w_per_elt_size = 4;
            (*pp_vad)[*num_vla].type = 1;
            (*pp_vad)[*num_vla].w_offset = comp_offset +
                                           ME.OMOSCO->chan_info[j++].offset;
         }
         else {
            (*pp_vad)[*num_vla].w_per_elt_size = 
                                              ME.OMOSCO->vla_list[k].elt_size;
            (*pp_vad)[*num_vla].type = 0;
            (*pp_vad)[*num_vla].w_offset = comp_offset +
                                           ME.OMOSCO->vla_list[k++].offset;
         }
         ++*num_vla;
      }

            
      return (OM_I_STOP_SENDING);
   }
   return (OM_S_SUCCESS);
}


/*=======================================================*/
/*  this private method is used to get all vla info for  */
/*  a given component designated by the fil_classid      */
/*=======================================================*/

method get_all_vla_info ( OMuword fil_classid; OMuint *fixed_size;
                       struct OM_sd_varlenarr_defn **pp_vad; OMuword *num_vla )
{
   int             i, sts, comp_dim, comp_size, dum1;
   OMuword         dum2;
   OM_S_CHANNUM    cnum;
   OM_S_CHANSELECT csel;

   if (fil_classid == ME.OMOSCO->OSCO.w_classid) {
      /*=============================================*/
      /*  for each component that has instance data  */
      /*  send to create its vla definitions         */
      /*=============================================*/

      csel.type = OM_e_name;
      csel.u_sel.name = "OMObjSpace.to_OSCOs";

      comp_dim = om$dimension_of ( varray = ME.OMOSCO->component_list );
      if (ME.OMOSCO->component_list[comp_dim-1].offset) {
         *fixed_size = ME.OMOSCO->component_list[comp_dim-1].offset +
                       ME.OMOSCO->component_size;
      }
      else {
         /*===============================================*/
         /*  This component was rejected - find the last  */
         /*  component that was not rejected              */
         /*===============================================*/

         for (i=comp_dim-1; i>0; --i) {
            if (ME.OMOSCO->component_list[i].offset) {
               cnum.classid = 0xffff;
               sts = om$send ( msg = message OMOSCO.get_chan_info
                                      ( ME.OMOSCO->component_list[i].classid,
                                        cnum, &comp_size, &dum1, &dum2 ),
                               senderid = 0,
                               p_chanselect = &csel );
               if (!(1&sts)) return (sts);                         
               *fixed_size = ME.OMOSCO->component_list[i].offset + comp_size;
               break;
            }
         }
         if (i==0) *fixed_size = sizeof(OM_S_OBJECTHDR);
      }


      for (i=0; i<comp_dim-1; ++i) {
         if (! ME.OMOSCO->component_list[i].offset) continue;
 
         sts = om$send ( msg = message OMOSCO.get_vla_info ( 
                               ME.OMOSCO->component_list[i].classid,
                               ME.OMOSCO->component_list[i].offset,
                               pp_vad, num_vla ),
                         senderid = 0,
                         p_chanselect = &csel );
         if (!(1&sts)) return (sts);                         
      }

      if (ME.OMOSCO->component_list[comp_dim-1].offset) {
         sts = om$send ( msg = message OMOSCO.get_vla_info (
                                 ME.OMOSCO->component_list[comp_dim-1].classid,
                                 ME.OMOSCO->component_list[comp_dim-1].offset,
                                 pp_vad, num_vla ),
                         targetid = my_id );
         if (!(1&sts)) return (sts);
      }
      return (OM_I_STOP_SENDING);
   }
   return (OM_S_SUCCESS);
}


end implementation OMOSCO;
