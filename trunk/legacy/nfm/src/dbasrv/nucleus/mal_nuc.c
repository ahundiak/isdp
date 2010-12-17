/* $Revision: 1.1 $ */
#include "dba.ext"
#include "dmalloc.def"

/* Function:	dba_malloc_ent */
int dba_malloc_ent (ent_ptr, in_ent_ptr)
struct dba_ent **ent_ptr, *in_ent_ptr;
{
  *ent_ptr =
    (struct dba_ent *) dba_dmalloc (sizeof (struct dba_ent), DM_TABLE);
  if (!in_ent_ptr)
    memset (*ent_ptr, 0, sizeof (struct dba_ent));
  else
    { memcpy (*ent_ptr, in_ent_ptr, sizeof (struct dba_ent));
    (*ent_ptr)->fatt = 0;  (*ent_ptr)->latt = 0;  (*ent_ptr)->built = 0;
    if (in_ent_ptr->cond_lng)
      { (*ent_ptr)->cond = dba_dmalloc (in_ent_ptr->cond_lng, DM_MEMBER);
      strcpy ((*ent_ptr)->cond, in_ent_ptr->cond); }
    if (in_ent_ptr->alias) 
      (*ent_ptr)->alias = (char *) dba_dstrdup (in_ent_ptr->alias, DM_MEMBER); }
  (*ent_ptr)->key = dba_dmalloc (40, DM_MEMBER);
  (*ent_ptr)->key_lng = 40;
  memset ((*ent_ptr)->key, 0, 40);
  (*ent_ptr)->curkey = dba_dmalloc (40, DM_MEMBER);
  (*ent_ptr)->curkey_lng = 40;
  memset ((*ent_ptr)->curkey, 0, 40);

  return (0);
}
/* Function:	dba_free_ent */
int dba_free_ent (ent_ptr)
struct dba_ent **ent_ptr;
{
  struct dba_att *catt, *tatt;
  struct dba_gadget *cgadg, *tgadg;

  for (catt=tatt=(*ent_ptr)->fatt; tatt; )
    { tatt = catt->natt;
    dba_free_att (&catt);
    catt = tatt; }
  for (cgadg=tgadg=(*ent_ptr)->fgadget; tgadg; )
    { tgadg = cgadg->ngadget;
    dba_free_gadget (&cgadg);
    cgadg = tgadg; }
  if ((*ent_ptr)->cond) dba_dfree ((*ent_ptr)->cond);
  if ((*ent_ptr)->key) dba_dfree ((*ent_ptr)->key); 
  if ((*ent_ptr)->curkey) dba_dfree ((*ent_ptr)->curkey); 
  if ((*ent_ptr)->order) dba_dfree ((*ent_ptr)->order); 
  if ((*ent_ptr)->where) dba_dfree ((*ent_ptr)->where); 
  if ((*ent_ptr)->menu_script) dba_dfree ((*ent_ptr)->menu_script); 
  if ((*ent_ptr)->notify_script) dba_dfree ((*ent_ptr)->notify_script); 
  if ((*ent_ptr)->alias) dba_dfree ((*ent_ptr)->alias); 
  if ((*ent_ptr)->display_id) dba_dfree ((*ent_ptr)->display_id); 
  dba_dfree (*ent_ptr);  *ent_ptr = 0;

  return (0);
}
/* Function:	dba_malloc_att */
int dba_malloc_att (att_ptr, in_att_ptr)
struct dba_att **att_ptr, *in_att_ptr;
{
  *att_ptr =
    (struct dba_att *) dba_dmalloc (sizeof (struct dba_att), DM_COLUMN);
  memset (*att_ptr, 0, sizeof (struct dba_att));

  if (in_att_ptr)
    { memcpy (*att_ptr, in_att_ptr, sizeof (struct dba_att));
    (*att_ptr)->attval = dba_dmalloc (in_att_ptr->alen + 1, DM_MEMBER);
    (*att_ptr)->attval[0] = 0;
    if (in_att_ptr->defval) 
      (*att_ptr)->defval = (char *) dba_dstrdup (in_att_ptr->defval, DM_MEMBER);
    if (in_att_ptr->alias) 
      (*att_ptr)->alias = (char *) dba_dstrdup (in_att_ptr->alias, DM_MEMBER); 
    if (in_att_ptr->format) 
      (*att_ptr)->format = (char *) dba_dstrdup (in_att_ptr->format, DM_MEMBER);
    if (in_att_ptr->join_from)
      { (*att_ptr)->join_from = dba_dmalloc (in_att_ptr->from_lng, DM_MEMBER);
      strcpy ((*att_ptr)->join_from, in_att_ptr->join_from); }
    if (in_att_ptr->join_to)
      { (*att_ptr)->join_to = dba_dmalloc (in_att_ptr->to_lng, DM_MEMBER);
      strcpy ((*att_ptr)->join_to, in_att_ptr->join_to); } }

  return (0);
}
/* Function:	dba_free_att */
int dba_free_att (att_ptr)
struct dba_att **att_ptr;
{
  if ((*att_ptr)->attval) dba_dfree ((*att_ptr)->attval);
  if ((*att_ptr)->defval) dba_dfree ((*att_ptr)->defval); 
  if ((*att_ptr)->alias) dba_dfree ((*att_ptr)->alias); 
  if ((*att_ptr)->format) dba_dfree ((*att_ptr)->format); 
  if ((*att_ptr)->join_from) dba_dfree ((*att_ptr)->join_from); 
  if ((*att_ptr)->join_to) dba_dfree ((*att_ptr)->join_to); 
  dba_dfree (*att_ptr);
  *att_ptr = 0;

  return (0);
}
/* Function:    dba_free_gadget */
int dba_free_gadget (gadget_ptr)
struct dba_gadget **gadget_ptr;
{
  struct dba_gadget *cgadg, *tgadg;

  if ((*gadget_ptr)->off_text) dba_dfree ((*gadget_ptr)->off_text);
  if ((*gadget_ptr)->on_text) dba_dfree ((*gadget_ptr)->on_text);
  if ((*gadget_ptr)->before_script) dba_dfree ((*gadget_ptr)->before_script);
  if ((*gadget_ptr)->after_script) dba_dfree ((*gadget_ptr)->after_script);
  if ((*gadget_ptr)->field_script) dba_dfree ((*gadget_ptr)->field_script);
  if ((*gadget_ptr)->query) dba_dfree ((*gadget_ptr)->query);
  if ((*gadget_ptr)->join_from) dba_dfree ((*gadget_ptr)->join_from); 
  if ((*gadget_ptr)->join_to) dba_dfree ((*gadget_ptr)->join_to); 

  if ((*gadget_ptr)->rtbnam) dba_dfree ((*gadget_ptr)->rtbnam); 
  if ((*gadget_ptr)->entnam) dba_dfree ((*gadget_ptr)->entnam); 
  if ((*gadget_ptr)->attnam) dba_dfree ((*gadget_ptr)->attnam); 
  if ((*gadget_ptr)->fontname) dba_dfree ((*gadget_ptr)->fontname); 
  if ((*gadget_ptr)->help_topic) dba_dfree ((*gadget_ptr)->help_topic); 
  if ((*gadget_ptr)->filename) dba_dfree ((*gadget_ptr)->filename); 
  if ((*gadget_ptr)->command) dba_dfree ((*gadget_ptr)->command); 

  for (cgadg=tgadg=(*gadget_ptr)->fgadget; tgadg; )
    { tgadg = cgadg->ngadget;
    dba_free_gadget (&cgadg);
    cgadg = tgadg; }
  dba_dfree (*gadget_ptr);
  *gadget_ptr = 0;

  return (0);
}
