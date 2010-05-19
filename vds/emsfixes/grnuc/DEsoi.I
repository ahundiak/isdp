class implementation DEso;
#include <alloca.h>
#include <stdio.h>
#include <memory.h>
#include <sys/types.h>
#include <sys/param.h>
#include <tools.h>
#include "msdef.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "ex.h"
#include "exmacros.h"
#include "gr.h"
#include "godef.h"
#include "DEso.h"
#include "DEglob.h"
#include "igrtypedef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "grdpb.h"
#include "dpdef.h"

#include "grmsg.h" 
#include "FI.h"
#include "msmacros.h"

#include "grio.h"
#include "griodef.h"
#include "griomacros.h"
#include "refdef.h"

%safe
/*
 *  ANSI static prototype
 */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif
#if defined(__cplusplus)
extern "C" {
#endif

static int DEset_dirty __((DEsoe *soes, int size, int index, 
                           OM_S_OBJID objid, int state));
static int DEmalloc_parms __((void));
static int DEcompare_soe __((DEsoe *p1, DEsoe *p2));
static int DEsort_boundaries __((DEsoe *soes, int size, int index, 
                                OM_S_OBJID so_objid));

void DEdsp_error(void);

#if defined(__cplusplus)
}
#endif
#undef __
%endsafe


from GRvg         import    GRgeomprops;

/* make sure that d1 <= d2 */
#define DEsort(d1,d2) if (d2<d1) { double d=d1; d1=d2; d2=d; }

#define DEhash_func(objid,win_ndx,ctx_ndx,size,key) \
{  \
   unsigned long jn; \
                        \
   jn = (int)objid * ( win_ndx + 1 ) * ( ctx_ndx > 0 ? (ctx_ndx + 1) : 1 ); \
   jn = jn < 65536 ? jn * jn : jn; \
   jn >>= 4; \
   key = jn % size; \
}

DEresolve_inter ( done, used, count, bdrys, sbts, ptr, entry, win, wn_ndx, md_env, 
                  ctx_ndx, type, target_id )
                  int             *done    /* Has entry been added ?    OUT */;
                  int             *used    /* Number of used entries IN/OUT */;
                  int             count    /* Number of boundaries      IN  */;
                  double          *bdrys   /* Boundaries                IN  */;
                  struct IGRdisplay *sbts /* The symbologies of the bdrys IN */;
                  DEsoe           *ptr     /* The existing entry         IN  */,
                                  *entry   /* The entry to be added      IN  */;
                  struct GRid     *win     /* The window of the new over IN  */;
                  short           wn_ndx   /* The index of that window   IN  */;
                  struct GRmd_env *md_env  /* The md_env of the new over IN  */;
                  short           ctx_ndx  /* The index of that md_env   IN  */;
                  int             type     /* The type of the new entry  IN  */;
                  OM_S_OBJID      target_id /* The objid of DEso         IN  */;
/*
   This procedure resolves the interferences between existing boundaries 
   (already in the table) and the entry we're trying to add (*ptr).
*/
{
  long msg;
  int  status;
  IGRboolean b_sts;
  struct GRprops props;
  IGRmatrix tmp_matrix;
  IGRdouble *tmp_ptr;
  IGRshort  tmp_matrix_type;

  if (md_env)
  {
    tmp_matrix_type = md_env->md_env.matrix_type;
    tmp_ptr = md_env->md_env.matrix;
  }
  else
  {
    tmp_matrix_type = 2;
    b_sts = MAidmx( &msg, tmp_matrix );
    tmp_ptr = tmp_matrix;
  }

  status = om$send( msg = message GRvg.GRgeomprops(
                                      &msg,
                                      &tmp_matrix_type,
                                       tmp_ptr,
                                      &props ),
                    senderid = ptr->objid,
                    targetid = ptr->objid );

  switch (count)
  {
    case  0: break;
    case  1: /* one entry is left */
             ptr->type = DE_DELETED;
             (*used)--;
             entry->u1 = bdrys [0];
             entry->u2 = bdrys [1];
             break;
    case  2: /* both entries are modified */

             if (bdrys [0] == bdrys [1])
             {
               ptr->type = DE_DELETED;
               (*used)--;
             }
             else
             {
               if ( entry->u1 <= ptr->u1 )
               {
                 entry->u1 = bdrys [0];
                 entry->u2 = bdrys [1];
                 ptr->u1   = bdrys [2];
                 ptr->u2   = bdrys [3];
               }
               else
               {
                 ptr->u1   = bdrys [0];
                 ptr->u2   = bdrys [1];
                 entry->u1 = bdrys [2];
                 entry->u2 = bdrys [3];
               }
             }

             if (ptr->type != DE_DELETED)
               if (ptr->u1 == 0.0 || ptr->u2 == 1.0)
                 if ( props.phy_closed )
                   ptr->type  = ptr->type | DE_OVERLAP;
                 else
                   ptr->type = ptr->type & (~ DE_OVERLAP);
               else
                 ptr->type = ptr->type & (~ DE_OVERLAP);

             break;
    case  3: /* we need to add two entries instead of one */
             if (bdrys [0] == bdrys [1])
             {
               ptr->type = DE_DELETED;
               (*used)--;
             }
             else
             {
               ptr->osymb = sbts [0];
               ptr->u1 = bdrys [0];
               ptr->u2 = bdrys [1];

               if (ptr->u1 == 0.0)
                 if ( props.phy_closed )
                   ptr->type = ptr->type | DE_OVERLAP;
                 else
                   ptr->type = ptr->type & (~ DE_OVERLAP);
               else
                 ptr->type = ptr->type & (~ DE_OVERLAP);
             }

             if (bdrys[2] == 0.0 || bdrys[3] == 1.0)
               if ( props.phy_closed )
                 type = entry->type | DE_OVERLAP;
               else
                 type = entry->type & (~ DE_OVERLAP);
             else
               type = entry->type & (~ DE_OVERLAP);
                     
             /* recursive call because the vla can move */
             status = om$send ( msg = message DEso.DEadd ( &msg, type, ptr->objid, bdrys [2], 
                                                           bdrys [3], &sbts [1], win, wn_ndx,
                                                           md_env, ctx_ndx ),
                                senderid = target_id,
                                targetid = target_id );
             if (!(status & 1))
               break;

             if (bdrys[4] == 0.0 || bdrys[5] == 1.0)
               if ( props.phy_closed )
                 type = ptr->type | DE_OVERLAP;
               else
                 type = ptr->type & (~ DE_OVERLAP);
             else
               type = ptr->type & (~ DE_OVERLAP);

             status = om$send ( msg = message DEso.DEadd ( &msg, type, ptr->objid, 
                                                           bdrys [4], bdrys [5],
                                                           &sbts [2], win, wn_ndx,
                                                           md_env, ctx_ndx ),
                                senderid = target_id,
                                targetid = target_id );
             *done = 1;
             break;
    default: printf ( "DEso$DEadd: bad count from DEinter_bound\n" );
  }

  return OM_S_SUCCESS;
}


method DEinit ( long *msg; IGRushort osnum; int size )
/*              long   *msg   The returned status       OUT */
/*              IGRushort osnum  The os the soo is for     IN  */
/*              int    size   The initial size          IN  */ 
{
  int i;

  *msg = MSSUCC;

  if (size <= 0) size = DE_MINIMUM;
  om$vla_set_dimension ( varray = me->soo,
                         size = size,
                         move_data = 0 );
  for (i = 0; i < size; i++)
    me->soo [i].type = DE_EMPTY;
  me->used = 0;
  me->osnum = osnum;
  DEsos [osnum] = my_id;

  return OM_S_SUCCESS;
}


method debug ()
{
  DEsoe *soes;
  int   i, count = 0, last_type=0, debug_objid = 0;

  printf("Enter the objid to restrict output / 0 for all :");
  scanf("%d", &debug_objid);
  
  om$send ( msg = message DEso.DEdump ( &count, &soes, 1 ), 
            targetid = my_id );
  printf ( "soo for os %d (size: %d, used: %d)\n", 
           me->osnum, count, me->used );
  printf ( "(view - context) - (color - style - weight) - objid - u1 - u2) dirty:\n" );
  for (i = 0; i < count; i++)
  {
   if((soes [i].objid == debug_objid) || (debug_objid == 0))
    {

    if (soes [i].type != last_type || (soes [i].type & (DE_SOE | DE_HIDDEN | DE_INVIS | DE_VIS)))
    {
      printf ( "soo [%2d]: ", i );
      switch (soes [i].type)
      {
        case DE_EMPTY  : printf ( "EMPTY" );
                         break;
        case DE_DELETED: printf ( "DELETED" );
                         break;
        default        : if (soes [i].type & DE_INVIS)
                           printf ( "INVIS " );
                         if (soes [i].type & DE_HIDDEN)
                           printf ( "HIDDEN " );
                         if (soes [i].type & DE_OVERLAP)
                           printf ( "OVERLAP " );
                         if (soes [i].type & DE_VIS)
                           printf ( "VIS " );
                         printf ( "(%d - %d) - (%d - %d - %d) - %d - (%lf -> %lf) - %d",
                                  soes [i].view, soes [i].context,
                                  soes [i].osymb.color,
                                  soes [i].osymb.style, 
                                  soes [i].osymb.weight,
                                  soes [i].objid,
                                  soes [i].u1, 
                                  soes [i].u2,
                                  soes [i].dirty );
      }

      printf ( "\n" );
    }

    last_type = soes [i].type;

   } /* remove this before delivering - JACK */

  }

  return OM_S_SUCCESS;
}


method DEdump ( int *p_count; DEsoe **p_soes; int all )
/*              int   *p_count    pointer to # of soe's      OUT */
/*              DEsoe **p_soes    pointer to soe's           OUT */
/*              int   all         do we want all entries ?   IN  */
{
  int          i, j, size;
  static DEsoe *soes = 0;
  static int   soes_size = 0;
  
  size = om$dimension_of ( varray = me->soo );
  if (!soes_size)
    soes = (DEsoe *)malloc ( (soes_size = size) * sizeof ( DEsoe ) );
  else
    if (soes_size < size)
      soes = (DEsoe *)realloc ( soes, (soes_size = size) * sizeof ( DEsoe ) );
  if (!soes)
    return OM_E_NODYNMEM;

  if (all)
  {
    memcpy ( soes, &(me->soo [0]), size * sizeof ( DEsoe ) );
    if (p_count)
      *p_count = size;
  }
  else
  {
    for (i = 0, j = 0; i < size; i++)
      if (me->soo [i].type != DE_DELETED && me->soo [i].type != DE_EMPTY)
        soes [j++] = me->soo [i];

    if (p_count)
      *p_count = j;
  }

  if (p_soes)
    *p_soes = soes;

  return OM_S_SUCCESS;
}


method DEget_view_index ( long *msg; short *p_view; short *p_context; int add; 
                          OM_S_OBJID window; OM_S_OBJID context )
/*                        long     *msg       return status          OUT */
/*                        short    *p_view    index of the view      OUT */
/*                        short    *p_context index of the context   OUT */
/*                        int      add        add if not found       IN  */
/*                        OM_S_OBJID  window  window id              IN  */
/*                        OM_S_OBJID  context context id             IN  */
/*
   This method looks for window/context pair on the to_context and
   winsup channels.  If a connection is found then its index is returned 
   else if add then the pair is connected and the index of this new 
   connection is returned.
*/
{
  int index, status, ii;
  struct OM_sd_big_tail tail;
  GRobjid chan_obj;
  OMuword chan_os;

  status = OM_S_SUCCESS;

  /* we look for the window */
  *msg = MSSUCC;
  if (window != NULL_OBJID)
  {
    status = om$get_index ( objid_c = my_id,
                            p_chanselect = &DEso_to_windows_chanselect,
                            objid = window,
                            indexaddr = (OMuint *)&index );
    if (!(status & 1))
      if (add)
      {
        /* we connect these guys */
        status = om$send ( msg = message Root.connect ( IGEgragad_winsup_chanselect,
                                                        OM_K_MAXINT, my_id, OM_Gw_current_OS,
                                                        DEso_to_windows_chanselect,
                                                        OM_K_MAXINT ),
                           targetid = window );
        if (!(1 & status)) return status;
    
        /* let's get the index */
        status = om$get_channel_count ( objid = my_id,
                                        p_chanselect = &DEso_to_windows_chanselect,
                                        count = (OMuint *)&index );
        if (!(1 & status)) return status;
        index--;
      }
      else
      {
        index = -1;
        *msg = MSFAIL;
      }

    if ((status & 1) && p_view)
      *p_view = index;
  }

  /* we look for the context */
  if (context != NULL_OBJID)
  {
    status = om$get_index ( objid_c = my_id,
                            p_chanselect = &DEso_to_contexts_chanselect,
                            objid = context,
                            indexaddr = (OMuint *)&index );
    if (!(status & 1))
      if (add)
      {
        /* we connect these guys */
        /* KLUDGE WARE BEGINS SS */
        /* Get the number of entries in the channel */
        tail.last_index = 0;
        if ( me->to_contexts )
        {
           OM_GET_TAIL( me->to_contexts, tail );
        }
        for ( ii = 0; ii < tail.last_index; ii++)
        {
           om$get_objid_at_index( objid = my_id,
                                  p_chanselect = &DEso_to_contexts_chanselect,
                                  index = ii,
                                  objidaddr = &chan_obj,
                                  osnumaddr = &chan_os );
           if ( chan_obj == NULL_OBJID )
           {
              break;
           }
        }
           
        status = om$send ( msg = message Root.connect ( GRcontext_to_misc_chanselect,
                                                        OM_K_MAXINT, my_id, OM_Gw_current_OS,
                                                        DEso_to_contexts_chanselect,
                                                        ii ),
                           targetid = context );
        if (!(1 & status)) return status;
    
        /* let's get the index */
        status = om$get_channel_count ( objid = my_id,
                                        p_chanselect = &DEso_to_contexts_chanselect,
                                        count = (OMuint *)&index );
        if (!(1 & status)) return status;
        index--;
      }
      else
      {
        index = -1;
        *msg = MSFAIL;
      }

    if ((status & 1) && p_context)
      *p_context = index;
  }
  else
    if (p_context)
      *p_context = -1;

  return status;
}


method DEchange_size ( long *msg; int new_size )
/*                     long *msg      return status     OUT */
/*                     int  new_size  the new size      IN  */
/*
   This method is used to change the size of the hash table.
*/
{
  int   i, status, old_size, index;
  DEsoe *tmp_soo;
  
  long    msg1 ;
  int     size, valid_cnt;
  short   num_alias;
  OMuword mod_os;
  char    name[MAXPATHLEN],
          tmp_name[MAXPATHLEN];

  *msg = MSSUCC;

  old_size = om$dimension_of ( varray = me->soo );
  if (new_size < DE_MINIMUM)
    new_size = DE_MINIMUM;
  if (new_size < me->used * 1.25)
    new_size = me->used * 1.25;

  valid_cnt = 0;
  for( i=0; i<old_size; ++i )
  {
     if( me->soo[i].type != DE_EMPTY && me->soo[i].type != DE_DELETED )
        valid_cnt++;
  }

  if( new_size < valid_cnt )  new_size = valid_cnt * 1.25;

  /* copy the old one in a temporary area */
  tmp_soo = (DEsoe *) malloc ( old_size * sizeof ( DEsoe ) );
  if (tmp_soo == NULL)
  {
     /* blow away all the entries in the hash table */
     status = om$vla_set_dimension ( varray = me->soo,
                                     size = 0 ,
                                     move_data = 0 );
     me->used = 0;

     /* display the error box */
     DEdsp_error();

     strcpy ( name, "soo_" );
     if (me->osnum == OM_Gw_current_OS)
     {
        strcpy ( &name [4], "master" );
     }
     else
     {
        status = om$os_number_to_name ( osnum = me->osnum, osname = tmp_name );
        if (status & 1)
        {
           /* om$os_number_to_name may return a full path name for the osname.
              This will put only the osname into name[4].
           */
           DEfind_refname(tmp_name, name);
        }
     }
     strcat (name, "_5535");
     num_alias = (short)1;
     /* DElete the variable fron GRvar object. */
     status = co$delvar(msg = &msg1,
                        num_alias = &num_alias,
                        input_alias = name);
     return om$send ( msg = message Root.delete ( 0 ), targetid = my_id );
  }

  memcpy ( tmp_soo, &(me->soo [0]), old_size * sizeof ( DEsoe ) );
  status = om$vla_set_dimension ( varray = me->soo,
                                  size = new_size,
                                  move_data = 0 );
  if (!(status & 1))
  {
    return status;
  }
  
  /* re-hash the contents */
  for (i = 0; i < new_size; i++)
    me->soo [i].type = DE_EMPTY;
  for (i = 0; i < old_size; i++)
    if (tmp_soo [i].type != DE_EMPTY && tmp_soo [i].type != DE_DELETED)
    {
      /* this one needs to be added */
      DEhash_func(tmp_soo[i].objid,tmp_soo[i].view,tmp_soo[i].context,
                  new_size,index);
      for (;me->soo [index].type != DE_EMPTY;)
        if (++index == new_size)
          index = 0;

      /* insert the new entry */
      me->soo [index] = tmp_soo [i];
/* Hash table size has changed. Need to sort the table and for that need
   to set the dirty bit.  -- Fix for TR11926617 --Mrudula. */
      me->soo [index].dirty = 1;
    }
  
  return status;  
}


void DEdsp_error (void)
/*
   This function is used to display an error box
*/
{  
    char      DEmsg0[80], DEmsg1[80];
    char      DEmsg2[80], DEmsg3[80];
    char      DEmessage[400];

    ex$message (msgnumb = GR_E_MemAllocErr0, buff = DEmsg0);
    ex$message (msgnumb = GR_E_MemAllocErr1, buff = DEmsg1);
    ex$message (msgnumb = GR_E_MemAllocErr2, buff = DEmsg2);
    ex$message (msgnumb = GR_E_MemAllocErr3, buff = DEmsg3);

    sprintf (DEmessage, "%s  %s\n %s\n %s",
             DEmsg0, DEmsg1, DEmsg2, DEmsg3);

    FI_message_box (FI_CURRENT_SCREEN, -1, -1,
                    "", FI_RED, "swiss742", 36.0,
                    DEmessage, FI_BLACK, "swiss742", 18.0,
                    FI_LEFT_JUSTIFIED, 40);
   
}   /* DEdsp_error */
    

method DEget_size ( long *msg; int *size )
/*                  long *msg      return status           OUT */
/*                  int  *size     the size                OUT */
/*
   This method is used to get the size of the hash table.
*/
{
  *msg = MSSUCC;

  *size = om$dimension_of( varray = me->soo );

  return OM_S_SUCCESS;
}


DEbuild_entry ( msg, entry, sooid, add, type, objid, u1, u2, symb,
                window, wn_ndx, md_env, ctx_ndx )
                long              *msg    /* return status             OUT */;
                DEsoe             *entry  /* the entry to build        OUT */;
                OM_S_OBJID        sooid   /* soo to work with          IN  */;
                int               add     /* is entry gonna be added ? IN  */;
                int               type    /* type of the new entry     IN  */;
                OM_S_OBJID        objid   /*    graphic object         IN  */;
                IGRdouble         u1, u2  /* u parms                   IN  */;
                struct IGRdisplay *symb   /* override symbology        IN  */;
                struct GRid       *window /* window of override        IN  */;
                short             wn_ndx  /* window index              IN  */;
                struct GRmd_env   *md_env /* context of override       IN  */;
                short             ctx_ndx /* index of the context      IN  */;
/*
   This method builds an entry for the soo.
*/
{
  int         status;
  struct GRid context;

  *msg = MSSUCC;
  status = OM_S_SUCCESS;
  
  /* build the entry */
  entry->type = type;
  DEsort ( u1, u2 );  
  entry->u1 = u1;
  entry->u2 = u2;    
  entry->objid = objid;
  entry->dirty = 1;
  if (symb) entry->osymb = *symb;

  /* get the window/context (view) index */
  if (md_env)
  {
    GRfindcontext ( msg, &md_env->md_env.matrix_type, md_env->md_env.matrix, 
                    &md_env->md_id.osnum, &context );
    if (*msg != MSSUCC)
      context.objid = NULL_OBJID;
  }

  if (md_env || window)
  {
    status = om$send ( msg = message DEso.DEget_view_index 
                       ( msg, &(entry->view), &(entry->context), add, 
                         window ? window->objid : NULL_OBJID, 
                         md_env ? context.objid : NULL_OBJID ),
                       targetid = sooid,
                       senderid = sooid );
    if (!(status & 1)) return status;
    if (*msg != MSSUCC) return OM_S_SUCCESS;
    if (!window)
      entry->view = wn_ndx;
    if (!md_env)
      entry->context = ctx_ndx;
  }
  else
  {
    entry->view = wn_ndx;
    entry->context = ctx_ndx;
  }

  return status;
}


static DEset_dirty ( soes, size, index, objid, state )
  DEsoe      *soes        /* The soes to be sorted                    IN/OUT */;
  int        size          /* The size of the table                   IN  */;
  int        index        /* The index to start from                  IN  */;
  OM_S_OBJID objid        /* The objid to work with                   IN  */;
  int        state        /* The state of the dirty bit (TRUE/FALSE)  IN  */;

/*
   This routine sets the dirty bit for an element.  The dirty bit set means
   that the list of objids is no longer sorted.  That bit is checked in DEget
   to trigger a sort on the overrides of a given element.  Note that all the
   dirty bits have to be set (not only the first one) because we don't want
   to maintain it during all operations (delete, modify, re-shuffle, ...).
*/
{
  DEsoe *ptr, *ptr_s, *last;
  
  last = &(soes [size]);
  ptr_s = &(soes [index]); /* save the first location */
  for (ptr = &(soes [index]); ptr->type != DE_EMPTY; )
  {
    if (ptr->objid == objid && ptr->type != DE_DELETED)
    {
      ptr->dirty = state;

      if((ptr->u1 == 0.0) && (ptr->u2 == 1.0))
         break;
    }

           /* to avoid inf. loop if no DE_EMPTY slots exist */
    if(ptr_s == soes) /* then we started at the top, no need to wrap when we hit last */
     {
      if(ptr++ == last)
         break;
     }       
    else if(ptr_s == last) /* then we started at the bottom, reset to top and continue */
         {
          if(ptr == last)
            ptr = soes;                      
          else if(++ptr == last)
                    break;
         }
        else  /* then we started somewhere other than top or bottom */
          {
           if(++ptr == ptr_s)
              break;
           else if (ptr == last) /* wrap around */    
                  ptr = soes;
          }

  }
  
  return 1;
}


method DEadd ( long *msg; int type; OM_S_OBJID objid; double u1; double u2; 
               struct IGRdisplay *symb; struct GRid *window; short wn_ndx;
               struct GRmd_env *md_env; short ctx_ndx )
/*             long              *msg       return status          OUT */
/*             int               type       type of the new entry  IN  */
/*             OM_S_OBJID        objid      graphic object         IN  */
/*             double            u1, u2     u parms                IN  */
/*             struct IGRdisplay *symb      override symbology     IN  */
/*             struct GRid       *window    window of override     IN  */
/*             short             wn_ndx     window index           IN  */
/*             struct GRmd_env   *md_env    context of override    IN  */
/*             short             ctx_ndx    index of the context   IN  */
/*
   This method adds an entry to the soo.
*/
{
  int   status = OM_S_SUCCESS, nb_entries = 1, done, size;
  DEsoe *ptr, *ptr_s, *last, *slot, entry;
  int	hindx;

  size = om$dimension_of ( varray = me->soo );
  if ((me->used + 3) > size * 0.75)
  {
    /* it is time to grow */
    status = om$send ( msg = message DEso.DEchange_size 
                           ( msg, (int)(((me->used + nb_entries ) * 1.5 ) + 1)),
                       targetid = my_id );
    if (!(status & 1)) return status;
    if (*msg != MSSUCC) return OM_S_SUCCESS;
    size = om$dimension_of ( varray = me->soo );
  }

  DEbuild_entry ( msg, &entry, my_id, 1, type, objid, u1, u2, symb,
                  window, wn_ndx, md_env, ctx_ndx );
  if (*msg != MSSUCC)
    return OM_S_SUCCESS;
  
  /* we need to make sure that the new entry doesn't overlap any existing one */
  /* scan the entries we are interested in */

  last = &me->soo [size];
  DEhash_func(entry.objid,entry.view,entry.context,size,hindx);

  ptr = &me->soo [hindx];
  ptr_s = &me->soo [hindx];
  done = 0;

  for (slot = NULL; ptr->type != DE_EMPTY; )
  {
    /* the entry must be there and point to objid */
    if (ptr->type == DE_DELETED)
    {
      if (!slot)
        slot = ptr;
    }
    else
      /* they might interfere if they are for the same view,
         the same context and the same object */
      if (ptr->objid == objid && ptr->view == entry.view && 
          ptr->context == entry.context)
      {
        int               count;
        struct IGRdisplay sbts [3];
        double            bdrys [6];

        if ((ptr->type & DE_SOE) && !(entry.type & DE_SOE))
        {
          DEsoe tmp_ptr;

          tmp_ptr.type = ptr->type;
          tmp_ptr.view = ptr->view;
          tmp_ptr.objid = ptr->objid;
          tmp_ptr.context = ptr->context;
          tmp_ptr.osymb = ptr->osymb;
          tmp_ptr.u1 = ptr->u1;
          tmp_ptr.u2 = ptr->u2;

          /* we need to remove the old one */
          status = om$send ( msg = message DEso.DEremove ( msg,
                                                           tmp_ptr.type,
                                                           tmp_ptr.objid,
                                                           tmp_ptr.u1,
                                                           tmp_ptr.u2, 
                                                          &tmp_ptr.osymb, 
                                                           window,
                                                           md_env ),
                             targetid = my_id );

          /* we need to add the new one */
          status = om$send ( msg = message DEso.DEadd ( msg,
                                                        entry.type,
                                                        entry.objid,
                                                        entry.u1,
                                                        entry.u2, 
                                                       &entry.osymb, 
                                                        window,
                                                        NULL_INDEX,
                                                        md_env,
                                                        NULL_INDEX ),
                             targetid = my_id );

          /* we need to add the old one */
          status = om$send ( msg = message DEso.DEadd ( msg,
                                                        tmp_ptr.type,
                                                        tmp_ptr.objid,
                                                        tmp_ptr.u1,
                                                        tmp_ptr.u2, 
                                                       &tmp_ptr.osymb, 
                                                        window,
                                                        NULL_INDEX,
                                                        md_env,
                                                        NULL_INDEX ),
                             targetid = my_id );
          done = 1;
        }
        else
        {
          DEinter_bound ( &count, bdrys, sbts, ptr->u1, ptr->u2,
                           entry.u1, entry.u2, &ptr->osymb, &entry.osymb );

          DEresolve_inter ( &done, &(me->used), count, bdrys, sbts, ptr, &entry, window, wn_ndx,
                            md_env, ctx_ndx, type, my_id );
        }
      }
  
      /* when done, ptr and last may be bogus: don't test them */    
      if (done)
        break;

           /* to avoid inf. loop if no DE_EMPTY slots exist */
   if(ptr_s == &me->soo[0]) /* then we started at the top, no need to wrap when we hit last */
    {
     if(ptr++ == last)
       break;
    }       
  else if(ptr_s == last) /* then we started at the bottom, reset to top and continue */
         {
          if(ptr == last)
            ptr = &me->soo [0];                      
          else if(++ptr == last)
                    break;
         }
        else  /* then we started somewhere other than top or bottom */
          {
           if(++ptr == ptr_s)
              break;
           else if (ptr == last) /* wrap around */    
                  ptr = &me->soo [0];
          }

  }

  if (!done && (entry.u1 != entry.u2))
  {
    /* In case of total symbology override, we can simply set the dirty
     * bit and not call the set_dirty routine
     */

    if((entry.u1 == 0.0)&&(entry.u2 == 1.0))
       entry.dirty = 1;

    if (slot)
      *slot = entry;
    else
      *ptr = entry;
    me->used++;
  
    /* set the SO bit in the graphics object */
    {
      short action = 1, property = DEHAS_OVERRIDE;
      
      status = om$send ( msg = message GRgraphics.GRchgprops ( msg, &action,
                                                               &property ),
                         senderid = my_id,
                         targetid = objid,
                         targetos = me->osnum );
      if (!(status & 1)) return status;
    }
  }

  /* set the dirty bit */
  /* We do not have to call the set_dirty routine if there is a total
   * symbology override.  We have already set the dirty bit for this case.
   */

  if( (entry.u1 != 0.0) || (entry.u2 != 1.0) )
  { 
     DEhash_func(entry.objid,entry.view,entry.context,size,hindx);    

     DEset_dirty ( me->soo, size, hindx , objid , 1 );
  }
    
  return status;
}


method DEadd_entries ( long *msg; int nb_entries; DEsoe *entries )
/*                     long  *msg          return status        OUT */
/*                     int   nb_entries   # of entries to add   IN  */
/*                     DEsoe *entries     entries to be added   IN  */
/*
   This function adds nb_entries to the soo.  WARNING: it doesn't check for
   interferences.
*/
{
  int   status, i, size;
  DEsoe *ptr, *ptr_s, *last;
  int	hindx;

  /* make sure we have enough room */
  size = om$dimension_of ( varray = me->soo );
  if ((me->used + nb_entries) > size * 0.75)
  {
    /* it is time to grow */
    status = om$send ( msg = message DEso.DEchange_size 
                          ( msg, (int)(((me->used + nb_entries ) * 1.5 ) + 1)),
                       targetid = my_id );
    if (!(status & 1)) return status;
    if (*msg != MSSUCC) return OM_S_SUCCESS;
    size = om$dimension_of ( varray = me->soo );
  }

  for (i = 0, last = &me->soo [size]; i < nb_entries; i++)
  {
    DEhash_func(entries [i].objid,entries[i].view,
                entries[i].context,size,hindx);
    ptr_s = &me->soo [hindx]; 
    for (ptr = &me->soo [hindx]; 
         ptr->type != DE_EMPTY && ptr->type != DE_DELETED;)
           /* to avoid inf. loop if no DE_EMPTY slots exist */
     if(ptr_s == &me->soo[0]) /* then we started at the top, no need to wrap when we hit last */
      {
       if(ptr++ == last)
         break;
      }       
     else if(ptr_s == last) /* then we started at the bottom, reset to top and continue */
           {
            if(ptr == last)
              ptr = &me->soo [0];                      
            else if(++ptr == last)
                      break;
           }
          else  /* then we started somewhere other than top or bottom */
           {
            if(++ptr == ptr_s)
               break;
            else if (ptr == last) /* wrap around */    
                   ptr = &me->soo [0];
           }


    *ptr = entries [i];

    /* set the SO bit in the graphics object */
    {
      short action = 1, property = DEHAS_OVERRIDE;

      status = om$send ( msg = message GRgraphics.GRchgprops ( msg, &action,
                                                               &property ),
                         senderid = my_id,
                         targetid = entries [i].objid,
                         targetos = me->osnum );
      if (!(status & 1)) return status;
    }
  }

  me->used += nb_entries;
  
  return OM_S_SUCCESS;
}


%safe
static double            *parms;
static struct IGRdisplay *attributes;
static int               *types;
static int               nb_parms = 0;
%endsafe


static DEmalloc_parms ()
/*
    This function mallocs enough space for parms, attributes and types.
*/
{
  if (nb_parms)
  {
    parms = (double *)realloc ( parms, (nb_parms + 32) * sizeof ( double ) );
    attributes = (struct IGRdisplay *)
                 realloc ( attributes, (nb_parms + 32) * 2 * sizeof ( struct IGRdisplay ) );
    types = (int *)realloc ( types, (nb_parms + 32) * sizeof ( int ) );
    nb_parms += 32;
  }
  else
  {
    parms = (double *)malloc ( 32 * sizeof ( double ) );
    attributes = (struct IGRdisplay *)malloc ( 64 * sizeof ( struct IGRdisplay ) );
    types = (int *)malloc ( (nb_parms + 32) * sizeof ( int ) );
    nb_parms = 32;
  }
  
  return (parms && attributes && types) ? OM_S_SUCCESS : OM_E_NODYNMEM;
}


DElock_view ( msg, viewid )
              long    *msg        /* return code              OUT */;
              OM_S_OBJID viewid   /* the view to be locked    IN  */;
/*
   This function locks a view, i.e. symbology override will be ignored in
   that view.
*/
{
  int i;
  
  for (i = 0, *msg = MSFAIL; i < MAX_WINDOW; i++)
    if (DElocked_views [i] == NULL_OBJID)
    {
      DElocked_views [i] = viewid;
      *msg = MSSUCC;
      break;
    }
  
  return OM_S_SUCCESS;
}


DEunlock_view ( msg, viewid )
                long       *msg     /* return code               OUT */;
                OM_S_OBJID viewid   /* the view to be unlocked   IN  */;
/*
   This function unlocks a view.
*/
{
  int i;
  
  for (i = 0, *msg = MSFAIL; i < MAX_WINDOW; i++)
    if (DElocked_views [i] == viewid)
    {
      DElocked_views [i] = NULL_OBJID;
      *msg = MSSUCC;
      break;
    }
  
  return OM_S_SUCCESS;
}


DEis_locked ( viewid )
              OM_S_OBJID viewid        /* the view to be checked   IN  */;
/*
   This functions returns TRUE if a view is locked and FALSE otherwise.
*/
{
  int i;
  
  for (i = 0; i < MAX_WINDOW; i++)
    if (DElocked_views [i] == viewid)
      return 1;
  
  return 0;
}


static DEcompare_soe ( p1, p2 )
                       DEsoe *p1, *p2;
/*
   We realy compare the boundaries.
*/
{
  return ((p1->u1 < p2->u1) && (p1->u2 < p2->u2)) ? -1 : 1;
}

static DEis_any_other_override (so_objid, objid, osnum, soes, size)
/* Check the so table for any other override for the object. If the object
   does not have any, then clear the DEHAS_OVERRIDE bit. This needs to be
   done because override entries are scattered in the so table.         
*/
   OM_S_OBJID  so_objid;
   OM_S_OBJID  objid;
   uword       osnum;
   DEsoe *soes   /* The soes to be sorted                       IN/OUT */;
   int   size    /* The size of the table                       IN  */;
{
    DEsoe      *ptr, *ptr_s, *last;
    int        count, hindx,
             win_cnt, ctx_cnt, 
             win_idx, ctx_idx, status;
    IGRlong   msg;

  /* How many windows for this SO table */
  status = om$get_channel_count ( objid = so_objid,
                                  p_chanselect = &DEso_to_windows_chanselect,
                                  count = (OMuint *)&win_cnt );
  if (!(1 & status)) return status;

  /* How many context objects for this SO table */
  status = om$get_channel_count ( objid = so_objid,
                                  p_chanselect = &DEso_to_contexts_chanselect,
                                  count = (OMuint *)&ctx_cnt );
  if (!(1 & status)) return status;
  msg = MSFAIL;
  for(win_idx = 0; win_idx < win_cnt; win_idx++)
  {
  /* for each context in each window. Note: if there are no context
     objects, we set the ctx_idx to -1 to force one pass through the
     sort. */
  for(ctx_idx = (ctx_cnt == 0) ? -1 : 0; ctx_idx < ctx_cnt; ctx_idx++) 
   {
     DEhash_func(objid,win_idx,ctx_idx,size,hindx);     
     ptr_s = &(soes [hindx]); /* save a pointer to the start index */
     for (ptr = &(soes [hindx]), last = &(soes [size]), count = 0; 
           ptr->type != DE_EMPTY;)
    {
      if ((ptr->objid == objid) && (ptr->type != DE_DELETED)) {
         msg = MSSUCC;
         break;  /* Override found */
      }
      else if(ptr_s == soes) /* then we started at the top, no need to wrap when we hit last */
        {
             if(ptr++ == last)
               break;
        }     
      else if(ptr_s == last) /* then we started at the bottom, reset to top and continue */
         {
          if(ptr == last)
            ptr = soes;                      
          else if(++ptr == last)
                    break;
         }
      else  /* then we started somewhere other than top or bottom */
          {
           if(++ptr == ptr_s)
              break;
           else if (ptr == last) /* wrap around */    
                  ptr = soes;
        }         
      }
    if (msg == MSSUCC)
        break;
   }
   if (msg == MSSUCC) 
      break;
  }
  if (msg == MSFAIL) {  /* Override not found. */
    short action = 0, property = DEHAS_OVERRIDE;
    
    /* clear the SO bit in the graphics object */
    status = om$send ( msg = message GRgraphics.GRchgprops ( &msg, &action,
                                                             &property ),
                       senderid = so_objid,
                       targetid = objid,
                       targetos = osnum );
    if (!(status & 1)) return status;
    msg = MSSUCC;
  }

  return OM_S_SUCCESS;

}


static DEsort_boundaries ( soes, size, index, so_objid )
  DEsoe *soes   /* The soes to be sorted                       IN/OUT */;
  int   size    /* The size of the table                       IN  */;
  int   index   /* The index to start from                     IN  */;
  OM_S_OBJID so_objid /* The objid of the DEso that called us  IN  */;
/*
   This procedure sorts the spans (gpipe must have them sorted).
*/
{
  OM_S_OBJID objid = soes [index].objid;
  DEsoe      *ptr, *ptr_s, *last, *copy = 0;
  int        i, count,
             win_cnt, ctx_cnt, 
             win_idx, ctx_idx, status;
  int        tot_sym_over = 0;

  ptr_s = &(soes [index]); /* save a pointer to the start index */

  /* How many windows for this SO table */
  status = om$get_channel_count ( objid = so_objid,
                                  p_chanselect = &DEso_to_windows_chanselect,
                                  count = (OMuint *)&win_cnt );
  if (!(1 & status)) return status;

  /* How many context objects for this SO table */
  status = om$get_channel_count ( objid = so_objid,
                                  p_chanselect = &DEso_to_contexts_chanselect,
                                  count = (OMuint *)&ctx_cnt );
  if (!(1 & status)) return status;


 /* for each window */
 for(win_idx = 0; win_idx < win_cnt; win_idx++)
  {
  /* for each context in each window. Note: if there are no context
     objects, we set the ctx_idx to -1 to force one pass through the
     sort. */
  for(ctx_idx = (ctx_cnt == 0) ? -1 : 0; ctx_idx < ctx_cnt; ctx_idx++) 
   {
    /* we build an array of the soes we have to sort */
    for (ptr = &(soes [index]), last = &(soes [size]), count = 0; 
           ptr->type != DE_EMPTY;)
    {
      if ((ptr->objid == objid) && (ptr->type != DE_DELETED) &&
          (ptr->context == ctx_idx) && (ptr->view == win_idx))
       {
        if (!(count % 32))
         {
          /* it's a realloc */
          DEsoe *tmp_copy = (DEsoe *)alloca ( (count + 32) * sizeof ( DEsoe ) );

          if (tmp_copy)
          {
            memcpy ( tmp_copy, copy, count * sizeof ( DEsoe ) );
            copy = tmp_copy;
          }
          else
            return OM_E_NODYNMEM;
         }

          copy [count++] = *ptr;
          if((ptr->u1 == 0.0) && (ptr->u2 == 1.0))
          {
             tot_sym_over = 1;
             break;
          }
       }

           /* to avoid inf. loop if no DE_EMPTY slots exist */
   if(ptr_s == soes) /* then we started at the top, no need to wrap when we hit last */
    {
     if(ptr++ == last)
       break;
    }       
  else if(ptr_s == last) /* then we started at the bottom, reset to top and continue */
         {
          if(ptr == last)
            ptr = soes;                      
          else if(++ptr == last)
                    break;
         }
        else  /* then we started somewhere other than top or bottom */
          {
           if(++ptr == ptr_s)
              break;
           else if (ptr == last) /* wrap around */    
                  ptr = soes;
          }

    }
  
    /* we sort that copy */
    qsort ( copy, count, sizeof ( DEsoe ), DEcompare_soe );

    /* we put the entries were they belong */
    for (i = 0, ptr = &(soes [index]); ptr->type != DE_EMPTY;)
     {
      if ((ptr->objid == objid) && (ptr->type != DE_DELETED) &&
          (ptr->context == ctx_idx) && (ptr->view == win_idx))
        *ptr = copy [i++];

           /* to avoid inf. loop if no DE_EMPTY slots exist */
      if(ptr_s == soes) /* then we started at the top, no need to wrap when we hit last */
       {
        if(ptr++ == last)
          break;
       }       
     else if(ptr_s == last) /* then we started at the bottom, reset to top and continue */
         {
          if(ptr == last)
            ptr = soes;                      
          else if(++ptr == last)
                    break;
         }
        else  /* then we started somewhere other than top or bottom */
          {
           if(++ptr == ptr_s)
              break;
           else if (ptr == last) /* wrap around */    
                  ptr = soes;
          }

     }
  } /* end loop for each context */
 } /* end loop for each window */

  /* reset the dirty bit */
  DEset_dirty ( soes, size, index, objid, 0 );
 
  return OM_S_SUCCESS;
}


method DEget ( long *msg; int **p_types; double **p_parms; int *p_count; 
               struct IGRdisplay **p_attr; struct IGRdisplay *ele_attr;
               OM_S_OBJID objid, viewid;
               short *type; IGRmatrix matrix; int sel_flag; int ret_invis )
/*             long       *msg       returned status             OUT */
/*             int        **p_types  pointer to list of types    OUT */
/*             double     **p_parms  pointer to list of parms    OUT */
/*             int        *p_count   number of parms             OUT */
/*             struct     IGRdisplay **p_attr
                                     display attributes          OUT */
/*             struct     IGRdisplay *ele_attr
                                     original element attributes IN  */
/*             OM_S_OBJID objid      the object with override    IN  */
/*             OM_S_OBJID viewid     the view we display in      IN  */
/*             short      *type             the matrix type      IN  */
/*             IGRmatrix  matrix     the matrix itself           IN  */
/*             int        sel_flag   the selection flag          IN  */
/*             int        ret_invis  return invis SOs if invis is OFF   IN  */
/*
   This method returns the display parameters for an object.
*/
{
  int         i, j, size, unlocked, status;
  DEsoe       *ptr, *ptr_s, *last;
  struct GRid tmp_view, tmp_context, context;
  short	      win_idx, ctx_idx;
  int 	      hindx;
  IGRboolean  tot_sym_over = 0;

  /* is the view locked (used only for DE_HIDDEN entries) */
  unlocked = !DEis_locked ( viewid );
  
  /* find the objid of the context (if any) */
  GRcheckref ( msg, type, matrix, 0, &me->osnum );
  if (*msg == MSSUCC)
  {
    GRfindcontext ( msg, type, matrix, &me->osnum, &context );
    if (*msg != MSSUCC)
    {
      context.objid = NULL_OBJID;
      context.osnum = 0xffff;
    }
  }
  else
  {
    context.objid = NULL_OBJID;
    context.osnum = 0xffff;
  }

  /* scan the entries we are interested in */
  last = &me->soo [size = om$dimension_of ( varray = me->soo )];

  status = om$send ( msg = message DEso.DEget_view_index 
             ( msg, &win_idx, &ctx_idx, 0, 
               viewid,
               context.objid),
           targetid = my_id,
           senderid = my_id );

  if(*msg == MSSUCC)
  {
     DEhash_func(objid,win_idx,ctx_idx,size,hindx);
  }
  else {
     hindx = objid % size;
  }
  
  ptr_s = &me->soo [hindx];
  for (i = 0, j = 0, ptr = &me->soo [hindx], *msg = MSFAIL; ptr->type != DE_EMPTY;)
  {
    /* the entry must be there, point to objid and be of the type we want */
    if (ptr->type != DE_DELETED && ptr->objid == objid)
    {
      if (*msg == MSFAIL)
      {
        /* set to MSSUCC to prevent from clearing the HAS_OVERRIDE bit (we found at least one) */
        *msg = MSSUCC;

        if (ptr->dirty)
        {
          /* The dirty bit is on, we must sort the boundaries.  But if
           * this is a total symbology override, there is no need to 
           * sort the boundaries and we can simply reset the dirty bit
           */
          
          if((ptr->u1 == 0.0) && (ptr->u2 == 1.0))
          {
             ptr->dirty = 0;
          }
          else
          {
             DEsort_boundaries ( me->soo, size, ((int)ptr - (int)me->soo) / sizeof ( DEsoe ), my_id );
          }
        }
      }

      if ((sel_flag == 0) || ((sel_flag == 1) && !(ptr->type & DE_SOE)) ||
         ((sel_flag == 2) && (ptr->type & DE_SOE)))
      {
        /* make sure this is for this view */
        tmp_view.objid = NULL_OBJID;
        om$get_objid_at_index ( objid = my_id,
                                p_chanselect = &DEso_to_windows_chanselect,
                                index = ptr->view,
                                objidaddr = &tmp_view.objid,
                                osnumaddr = &tmp_view.osnum );
        if (tmp_view.objid == viewid)
        {
          /* make sure this is for this context */
          tmp_context.objid = NULL_OBJID;
          tmp_context.osnum = 0xffff;
          if (ptr->context != -1)
            om$get_objid_at_index ( objid = my_id,
                                    p_chanselect = &DEso_to_contexts_chanselect,
                                    index = ptr->context,
                                    objidaddr = &tmp_context.objid,
                                    osnumaddr = &tmp_context.osnum );

          if (tmp_context.osnum == context.osnum &&
              tmp_context.objid == context.objid)
          {
            if( (ptr->u1 == 0.0) && (ptr->u2 == 1.0) )
               tot_sym_over = 1;

            if (unlocked)
            {
              if (i == nb_parms)
                DEmalloc_parms ();

              if (ptr->type & DE_VIS)
              {
                attributes [j] = *ele_attr;
                parms [i++] = ptr->u1;
                parms [i++] = ptr->u2;
                types [j++] = ptr->type;
              }
              else
                if (ptr->type & DE_HIDDEN)
                {
                  IGRboolean hidden_on;

                  status = gr$get_hidden_so_on( msg    =  msg,
                                                buffer = &hidden_on );

                  if (hidden_on)
                  {
                    struct GRhesym heattr;

                    status = gr$get_hidden_edge_sym( msg    =  msg,
                                                     buffer = &heattr );

                    if (heattr.flags & DPB_USE_ORIG_COLOR)
                      attributes [j].color = ele_attr->color;
                    else
                      attributes [j].color = heattr.color;

                    if (heattr.flags & DPB_USE_ORIG_WEIGHT)
                      attributes [j].weight = ele_attr->weight;
                    else
                      attributes [j].weight = heattr.weight;

                    if (heattr.flags & DPB_USE_ORIG_STYLE)
                      attributes [j].style = ele_attr->style;
                    else
                      attributes [j].style = heattr.style;
                  }
                  else
                  {
                    attributes [j].color  = (IGRushort)DP_INVISIBLE_COLOR;
                    attributes [j].weight = (IGRuchar)DP_INVISIBLE_COLOR;
                    attributes [j].style  = (IGRuchar)DP_INVISIBLE_COLOR;
                  }

                  parms [i++] = ptr->u1;
                  parms [i++] = ptr->u2;
                  types [j++] = ptr->type;
                }
                else
                  if (ptr->type & DE_INVIS)
                  {
                    IGRboolean invis_on;

                    status = gr$get_invis_so_on( msg    =  msg,
                                                 buffer = &invis_on );

                    if (invis_on)
                    {
                      attributes [j].color  = (IGRushort)DP_INVISIBLE_COLOR;
                      attributes [j].weight = (IGRuchar)DP_INVISIBLE_COLOR;
                      attributes [j].style  = (IGRuchar)DP_INVISIBLE_COLOR;

                      parms [i++] = ptr->u1;
                      parms [i++] = ptr->u2;
                      types [j++] = ptr->type;
                    }
                    else
                    {
                      if (ret_invis)
                      {
                        attributes [j].color  = ele_attr->color;
                        attributes [j].weight = ele_attr->weight;
                        attributes [j].style  = ele_attr->style;

                        parms [i++] = ptr->u1;
                        parms [i++] = ptr->u2;
                        types [j++] = ptr->type;
                      }
                    }
                  }
                  else
                  {
                    attributes [j] = ptr->osymb;
                    parms [i++] = ptr->u1;
                    parms [i++] = ptr->u2;
                    types [j++] = ptr->type;
                  }
            }
          }
        }
      }
    }

   if(tot_sym_over)
      break;
    
        /* to avoid inf. loop if no DE_EMPTY slots exist */
   if(ptr_s == &me->soo[0]) /* then we started at the top, no need to wrap when we hit last */
    {
     if(ptr++ == last)
       break;
    }       
  else if(ptr_s == last) /* then we started at the bottom, reset to top and continue */
         {
          if(ptr == last)
            ptr = &me->soo [0];                      
          else if(++ptr == last)
                    break;
         }
        else  /* then we started somewhere other than top or bottom */
          {
           if(++ptr == ptr_s)
              break;
           else if (ptr == last) /* wrap around */    
                  ptr = &me->soo [0];
          }

  }

  *p_parms = parms;
  *p_count = j;
  *p_attr  = attributes;
  if (p_types) *p_types = types;

  return OM_S_SUCCESS;
}


method DEremove_by_objid ( long *msg; OM_S_OBJID objid )
/*                         long       *msg   returned status       OUT */
/*                         OM_S_OBJID objid  the object to remove  IN  */
/*
   This method removes an objid (all of its overrides) from the table.
   It is called (among other things) by delete and drop override.
*/
{
  int   status, size;
  DEsoe *ptr, *ptr_s, *last;

  *msg = MSFAIL;

  /* Start the search at the top of the table. */
  last = &me->soo [size = om$dimension_of ( varray = me->soo )];
  ptr_s = &me->soo [0];
  for (ptr = &me->soo [0];;)
  {
    /* the entry must be there and point to objid */
    if (ptr->type != DE_DELETED && ptr->objid == objid)
    {
      ptr->type = DE_DELETED;
      me->used--;
      *msg = MSSUCC;      
    }
   if(ptr++ == last)
       break;
  }

  if (*msg == MSSUCC)
  {
    short action = 0, property = DEHAS_OVERRIDE;
    
    /* clear the SO bit in the graphics object */
    status = om$send ( msg = message GRgraphics.GRchgprops ( msg, &action,
                                                             &property ),
                       senderid = my_id,
                       targetid = objid,
                       targetos = me->osnum );
    if (!(status & 1)) return status;
    *msg = MSSUCC;
  }

  return OM_S_SUCCESS;
}


method DEremove ( long *msg; int type; OM_S_OBJID objid; double u1; double u2; 
                  struct IGRdisplay *symb; struct GRid *window; 
                  struct GRmd_env *md_env )
/*                long              *msg     return status       OUT */
/*                int               type     type of entry       IN  */
/*                OM_S_OBJID        objid    graphic object      IN  */
/*                double            u1, u2   u parms             IN  */
/*                struct IGRdisplay *symb    override symbology  IN  */
/*                struct GRid       *window  window of override  IN  */
/*                struct GRmd_env   *md_env  context             IN  */
/*
   This method removes an entry from the soo.
*/
{
  int         size;
  DEsoe       entry, *ptr, *ptr_s, *last;
  long 	      hindx;    /* hash index */

  /* build the entry */
  DEbuild_entry ( msg, &entry, my_id, 0, type, objid, u1, u2, symb,
                  window, NULL_INDEX, md_env, NULL_INDEX );
  if (*msg != MSSUCC)
    return OM_S_SUCCESS;
  
  /* search for that entry in the table */
  last = &me->soo [size = om$dimension_of ( varray = me->soo )];
  DEsort ( u1, u2 );

  DEhash_func(entry.objid,entry.view,entry.context,size,hindx);

  ptr_s = &me->soo [hindx];
  for (ptr = &me->soo [hindx], *msg = MSFAIL; ptr->type != DE_EMPTY;)
  {
    /* the entry must be there and contain what we're looking for */
    if (ptr->type == type && 
        ptr->objid == objid &&
        ptr->u1 == u1 &&
        ptr->u2 == u2 &&
        ( ( type & (DE_HIDDEN | DE_INVIS | DE_VIS) ) ||
        (!memcmp(&(ptr->osymb),&(entry.osymb),sizeof(struct IGRdisplay))) ) &&
        ptr->context == entry.context &&
        ptr->view == entry.view )
    {
      ptr->type = DE_DELETED;
      me->used--;
      *msg = MSSUCC;

      /* For the case of total symbology override, we can terminate 
         further search */

         break;
    }

        /* to avoid inf. loop if no DE_EMPTY slots exist */
   if(ptr_s == &me->soo[0]) /* then we started at the top, no need to wrap when we hit last */
    {
     if(ptr++ == last)
       break;
    }       
  else if(ptr_s == last) /* then we started at the bottom, reset to top and continue */
         {
          if(ptr == last)
            ptr = &me->soo [0];                      
          else if(++ptr == last)
                    break;
         }
        else  /* then we started somewhere other than top or bottom */
          {
           if(++ptr == ptr_s)
              break;
           else if (ptr == last) /* wrap around */    
                  ptr = &me->soo [0];
          }

  }
  if (*msg == MSSUCC) {
    DEis_any_other_override (my_id, objid, me->osnum, me->soo, size);
  }
  return OM_S_SUCCESS;
}


method DEremove_in_view ( long *msg; OM_S_OBJID objid;
                          struct GRid *window; struct GRmd_env *md_env )
/*                long              *msg     return status       OUT */
/*                OM_S_OBJID        objid    graphic object      IN  */
/*                struct GRid       *window  window of override  IN  */
/*                struct GRmd_env   *md_env  context             IN  */
/*
   This method removes the override of a go in the specified view.
*/
{
  int         size;
  DEsoe       entry, *ptr, *ptr_s, *last;
  long	      hindx;   /* hash index */

  /* build the entry */
  DEbuild_entry ( msg, &entry, my_id, 0, DE_SOE, objid, 0.0, 0.0,
                  (struct IGRdisplay *)NULL, window, NULL_INDEX,
                  md_env, NULL_INDEX );
  if (*msg != MSSUCC)
    return OM_S_SUCCESS;
  
  /* search for that entry in the table */
  last = &me->soo [size = om$dimension_of ( varray = me->soo )];
  DEhash_func(entry.objid,entry.view,entry.context,size,hindx);

  ptr_s = &me->soo [hindx];
  for (ptr = &me->soo [hindx], *msg = MSFAIL; ptr->type != DE_EMPTY;)
  {
    int match = 0;
    
    /* the entry must be there and contain what we're looking for */
    if (ptr->objid == objid)
    {
      if (md_env && window)
        match = ptr->context == entry.context && ptr->view == entry.view;
      else
        if (md_env)
          match = ptr->context == entry.context;
        else
          if (window)
            match = ptr->view == entry.view;
          else
            match = 1;
      if (match)
      {
        ptr->type = DE_DELETED;
        me->used--;
        *msg = MSSUCC;

      /* For the case of total symbology override, we can terminate 
         further search */

        if((ptr->u1 == 0.0) && (ptr->u2 == 1.0))
           break;
      }
    }

        /* to avoid inf. loop if no DE_EMPTY slots exist */
   if(ptr_s == &me->soo[0]) /* then we started at the top, no need to wrap when we hit last */
    {
     if(ptr++ == last)
       break;
    }       
  else if(ptr_s == last) /* then we started at the bottom, reset to top and continue */
         {
          if(ptr == last)
            ptr = &me->soo [0];                      
          else if(++ptr == last)
                    break;
         }
        else  /* then we started somewhere other than top or bottom */
          {
           if(++ptr == ptr_s)
              break;
           else if (ptr == last) /* wrap around */    
                  ptr = &me->soo [0];
          }
  }
  if (*msg == MSSUCC) {
    DEis_any_other_override (my_id, objid, me->osnum, me->soo, size);
  }
  return OM_S_SUCCESS;
}


method DEmodify ( long *msg; int old_type; struct IGRdisplay *old_symbology; 
                  double old_u1; double old_u2; struct GRid *old_window; 
                  struct GRmd_env *old_md_env; 
                  int type; struct IGRdisplay *symbology; double u1; double u2; 
                  OM_S_OBJID objid; struct GRid *window; 
                  struct GRmd_env *md_env; int interference )
/*
     This message is used to modify an entry of the soo.
  
     Argument description:
     --------------------
  
       long *msg                    : the return status                (OUT)
                                        MSSUCC: the entry has been modified
                                        MSFAIL: the entry could not be modified
  
       int old_type                 : the old type of the entry        (IN)
       
       struct IGRdisplay *old_symbology: the old symbology override    (IN)
  
       double old_u1, old_u2           : the old u parms               (IN)
       
       struct GRid *old_window         : the old view of the override  (IN)
  
       struct GRmd_env *old_md_env     : the old context of the override(IN)
       
       int type                        : type of the entry             (IN)
       
       struct IGRdisplay *symbology    : the new symbology             (IN)
       
       double u1, u2                   : the new u parms               (IN)
       
       struct GRid *go                 : the object with the override  (IN)
       
       struct GRid *window             : the new view for the override (IN)
       
       struct GRmd_env *md_env         : the new context of the override(IN)
       
       int interference                : interference checking ?       (IN)
*/
{
  int   size, status = OM_S_SUCCESS;
  DEsoe entry, *ptr, *ptr_s, *last;
  long		hindx; /* hash index */

  /* build the entry */
  DEbuild_entry ( msg, &entry, my_id, 0, old_type, objid, old_u1, old_u2, 
                  old_symbology, old_window, NULL_INDEX, old_md_env, NULL_INDEX );
  if (*msg != MSSUCC)
    return OM_S_SUCCESS;
  
  /* search for that entry in the table */
  last = &me->soo [size = om$dimension_of ( varray = me->soo )];
  DEsort ( old_u1, old_u2 );

  DEhash_func(entry.objid,entry.view,entry.context,size,hindx);

  ptr_s = &me->soo [hindx];
  for (ptr = &me->soo [hindx], *msg = MSFAIL; ptr->type != DE_EMPTY;)
  {
    /* the entry must be there and contain what we're looking for */
    if (ptr->type == old_type && 
        ptr->objid == objid &&
        ptr->u1 == old_u1 &&
        ptr->u2 == old_u2 &&
/*        ptr->osymb == entry.osymb && */
        (!memcmp(&(ptr->osymb),&(entry.osymb),sizeof(struct IGRdisplay))) &&
        ptr->context == entry.context &&
        ptr->view == entry.view )
    {
      ptr->type = DE_DELETED;
      me->used--;
      
      /* we need to add the new one */
      status = om$send ( msg = message DEso.DEadd ( msg, type, objid, u1, u2, 
                                                    symbology, 
                                                    window, NULL_INDEX,
                                                    md_env, NULL_INDEX ),
                         targetid = my_id );
      *msg = MSSUCC;      
      break;
    }

        /* to avoid inf. loop if no DE_EMPTY slots exist */
   if(ptr_s == &me->soo[0]) /* then we started at the top, no need to wrap when we hit last */
    {
     if(ptr++ == last)
       break;
    }       
  else if(ptr_s == last) /* then we started at the bottom, reset to top and continue */
         {
          if(ptr == last)
            ptr = &me->soo [0];                      
          else if(++ptr == last)
                    break;
         }
        else  /* then we started somewhere other than top or bottom */
          {
           if(++ptr == ptr_s)
              break;
           else if (ptr == last) /* wrap around */    
                  ptr = &me->soo [0];
          }

  }
  
  return status;
}

extern DEsoe *DElast_retrieve;         /* last retrieved entry */

method DEretrieve ( long *msg; int *p_type; struct IGRdisplay *p_symb; 
                    double *p_u1; double *p_u2; OM_S_OBJID objid; 
                    double u; struct GRid *view; struct GRmd_env *md_env )
/*                  long *msg                 the return status    OUT */
/*                  int *p_type               the type of overr.   OUT */
/*                  struct GRdisplay *symb    the symbology        OUT */
/*                  double *p_u1, *p_u2       parms of override    OUT */
/*                  OM_S_OBJID objid          the objid            IN  */
/*                  double u                  the u parm           IN  */
/*                  struct GRid *view         the view             IN  */
/*                  struct GRmd_env *md_env   the context          IN  */
/*
   This method retrieves an entry from the soo.  The entry is specified by
   objid, view objid, (eventually) context objid and u parm.  This method
   is mainly used to "locate" a symbology override.

*/
{
  int   size, status = OM_S_SUCCESS;
  DEsoe entry, *ptr, *ptr_s, *last;
  long	hindx;     /* hash index */

  /* build the entry */
  DEbuild_entry ( msg, &entry, my_id, 0, DE_SOE, objid, 0.0, 1.0, 
                  (struct IGRdisplay *)NULL, view, NULL_INDEX,
                  md_env, NULL_INDEX );
  if (*msg != MSSUCC)
    return OM_S_SUCCESS;
  
  /* search for that entry in the table (if only one entry, the u parm
     is ignored) */
  last = &me->soo [size = om$dimension_of ( varray = me->soo )];

  DEhash_func(entry.objid,entry.view,entry.context,size,hindx);

  ptr_s = &me->soo [hindx];
  for (ptr = &me->soo [hindx], *msg = MSFAIL; ptr->type != DE_EMPTY;)
  {
    /* the entry must be there and contain what we're looking for */
    if (ptr->type != DE_DELETED &&
        ptr->objid == objid &&
        ptr->context == entry.context &&
        ptr->view == entry.view )
    {
      if (ptr->u1 <= u && ptr->u2 >= u)
      {
        DElast_retrieve = ptr;
        if (p_type) *p_type = ptr->type;
        if (p_symb) *p_symb = ptr->osymb;
        if (p_u1) *p_u1 = ptr->u1;
        if (p_u2) *p_u2 = ptr->u2;
      
        *msg = MSSUCC;          
        break;
      }      
      else
      {
        if (DElast_retrieve)
          if ( ! (DElast_retrieve->type & DE_OVERLAP && ptr->type & DE_OVERLAP))
          {
            DElast_retrieve = 0;
            *msg = MSFAIL;
          }
      }
    }

        /* to avoid inf. loop if no DE_EMPTY slots exist */
   if(ptr_s == &me->soo[0]) /* then we started at the top, no need to wrap when we hit last */
    {
     if(ptr++ == last)
       break;
    }       
  else if(ptr_s == last) /* then we started at the bottom, reset to top and continue */
         {
          if(ptr == last)
            ptr = &me->soo [0];                      
          else if(++ptr == last)
                    break;
         }
        else  /* then we started somewhere other than top or bottom */
          {
           if(++ptr == ptr_s)
              break;
           else if (ptr == last) /* wrap around */    
                  ptr = &me->soo [0];
          }

  }
  
  return status;
}


method DEnext ( long *msg; int *p_type; struct IGRdisplay *p_symb;
                double *p_u1; double *p_u2 )
/*              long *msg                 the return status    OUT */
/*              int *p_type               the type of overr.   OUT */
/*              struct GRdisplay *p_symb  the symbology        OUT */
/*              double *p_u1, *p_u2       parms of override    OUT */
/*
   This method retrieves the next entry from the soo.  This is used after
   a retrieve when an entry is a 1/0 overlap so that the command can
   make it look like one entry to the user.
*/
{
  int   size, status = OM_S_SUCCESS;
  DEsoe *ptr, *last;
  long	hindx;    /* hash index */

  last = &me->soo [size = om$dimension_of ( varray = me->soo )];
  if (DElast_retrieve < &me->soo [0])
  {
    *msg = MSFAIL;
    return OM_S_SUCCESS;
  }
  
  /* search for that entry in the table */
  for (ptr = DElast_retrieve, *msg = MSFAIL; ;)
  {
    /* wrap around */    
    if (++ptr == last)
      ptr = &me->soo [0];

    if (ptr->type == DE_EMPTY)
    {
      DEhash_func(DElast_retrieve->objid,DElast_retrieve->view,
                  DElast_retrieve->context,size,hindx);
      ptr = &me->soo [hindx];
    }

    if (ptr == DElast_retrieve)
      break;

    /* the entry must be there and contain what we're looking for */
    if (ptr->type & DE_OVERLAP && 
        ptr->view == DElast_retrieve->view &&
        ptr->context == DElast_retrieve->context &&
        ptr->objid == DElast_retrieve->objid)
    {
      if (DElast_retrieve != ptr &&
          ((DElast_retrieve->u2 == 1.0 && ptr->u1 == 0.0) ||
           (DElast_retrieve->u1 == 0.0 && ptr->u2 == 1.0)))
      {
        DElast_retrieve = NULL;
        if (p_type)
          *p_type = ptr->type;
        if (p_symb)
          *p_symb = ptr->osymb;
        if (p_u1)
          *p_u1 = ptr->u1;
        if (p_u2)
          *p_u2 = ptr->u2;

        *msg = MSSUCC;
      }
      else
        /* we didn't find it -> clear the bit for next time */
        ptr->type &= ~DE_OVERLAP;

      break;
    }
  }
  
  return status;
}


method DEobjid_changed ( long *msg; struct GRid *old_id, *new_id )
/*                       long        *msg      The returned status   OUT */
/*                       struct GRid old_id    The Old GRid          IN  */
/*                       struct GRid new_id    The New GRid          IN  */
/*
   That method gets called when the objid of an object that has SO's is
   about (i.e. BEFORE) to change.
*/
{
  int   status, size;
  DEsoe *ptr, *ptr_s, *last;
  
  if (old_id->osnum != new_id->osnum)
  {
    *msg = MSFAIL;
    return OM_S_SUCCESS;
  }

  /* Perform a linear search    */

  last = &me->soo [size = om$dimension_of ( varray = me->soo )];
  for (ptr = &me->soo [0];;)
  {
    if (ptr->objid == old_id->objid)
    {
      int type = ptr->type;
    
      /* delete this one */
      ptr->type = DE_DELETED;
      me->used--;

      /* add it back with the new id */
      status = om$send ( msg = message DEso.DEadd ( msg, type, new_id->objid, 
                                                    ptr->u1, ptr->u2, &ptr->osymb,
                                                    NULL, ptr->view, NULL, 
                                                    ptr->context ),
                         targetid = my_id );
      if (*msg != MSSUCC || !(status & 1))
        break;
    }
    if(ptr++ == last)
       break;


  }

  return status;
}

end implementation DEso;
