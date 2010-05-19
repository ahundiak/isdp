/* $Id: VDbtBasei.I,v 1.1.1.1 2001/01/04 21:07:57 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdbt/imp/VDbtBasei.I
 *
 * Description: Base Method Implementation
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDbtBasei.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:57  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.4  1998/04/07  14:33:40  pinnacle
# ah
#
# Revision 1.2  1998/04/02  21:22:22  pinnacle
# ah
#
# Revision 1.1  1998/03/29  14:13:54  pinnacle
# AssyTree
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/27/98  ah      Creation
 *
 ***************************************************************************/

class implementation VDbtBase;

/* -----------------------------------------------
 * Generic get attribute by name or index
 */
method getAttrBy(IGRint f; IGRint ind; IGRchar *name; TVDfld *fld) 
{
  IGRstat retFlag = 0;
  IGRuint i;
  IGRuint cnt;

  // Arg Check
  if (fld == NULL) goto wrapup;
  memset(fld,0,sizeof(TVDfld));

  // Name or index
  if (name == NULL) {

    // Index lookup
    switch(f) {

    case 0: // Internal
      cnt = om$dimension_of(varray = me->fldx);
      if ((ind < 0) || (ind >= cnt)) goto wrapup;
      *fld = me->fldx[ind];
      retFlag = 1;
      goto wrapup;
  
    case 1: // User
      cnt = om$dimension_of(varray = me->flds);
      if ((ind < 0) || (ind >= cnt)) goto wrapup;
      *fld = me->flds[ind];
      retFlag = 1;
      goto wrapup;
    }
  }

  // Do It
  switch(f) {

  case 0: // Internal
    cnt = om$dimension_of(varray = me->fldx);
    for(i = 0; (i < cnt) && (strcmp(name,me->fldx[i].name)); i++);
    if (i == cnt) goto wrapup;
    *fld = me->fldx[i];
    retFlag = 1;
    goto wrapup;

  case 1: // User
    cnt = om$dimension_of(varray = me->flds);
    for(i = 0; (i < cnt) && (strcmp(name,me->flds[i].name)); i++);
    if (i == cnt) goto wrapup;
    *fld = me->flds[i];
    retFlag = 1;
    goto wrapup;
  }

wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Generic get attributes
 */
method getAttrs(IGRint f; TVDfld *flds; IGRint *cnt) 
{
  IGRstat retFlag = 0;
  IGRuint i;

  // Arg Check, flds can be NULL
  if (cnt == NULL) goto wrapup;

  // Do it
  switch(f) {

  case 0: // Internal
    *cnt = om$dimension_of(varray = me->fldx);
    if (flds != NULL) {
      for(i = 0; i < *cnt; i++) {
        flds[i] = me->fldx[i];
      }
    }
    retFlag = 1;
    goto wrapup;

  case 1: // User
    *cnt = om$dimension_of(varray = me->flds);
    if (flds != NULL) {
      for(i = 0; i < *cnt; i++) {
        flds[i] = me->flds[i];
      }
    }
    retFlag = 1;
    goto wrapup;
  }

wrapup:
  return retFlag;
}

/* -------------------------------------------
 * Generic set attributes
 */
method setAttrs(IGRint f; TVDfld *flds; IGRint cnt) 
{
  IGRstat retFlag = 0;
  IGRuint i;

  // Do it
  if (cnt < 0) cnt = 0;
  
  switch(f) {

  case 0: // Internal
    om$vla_set_dimension(varray = me->fldx, size = cnt);
    if (flds != NULL) {
      for(i = 0; i < cnt; i++) {
        me->fldx[i] = flds[i];
      }
    }
    retFlag = 1;
    goto wrapup;

  case 1: // User
    om$vla_set_dimension(varray = me->flds, size = cnt);
    if (flds != NULL) {
      for(i = 0; i < cnt; i++) {
        me->flds[i] = flds[i];
      }
    }
    retFlag = 1;
    goto wrapup;
  }

wrapup:
  return retFlag;
}

/* -------------------------------------------
 * Update attributes with same name
 */
method updAttrs(IGRint f; TVDfld *flds; IGRint updCNT) 
{
  IGRstat   retFlag = 0;
  IGRuint   fldCNT,fldCNTx;
  IGRuint   updI,fldI;
  TVDfld   *fld;

  // Arg Chk
  if (flds == NULL) goto wrapup;

  // Which one
  switch(f) {

  case 0:  // Internal

    fldCNT  = om$dimension_of(varray = me->fldx);
    fldCNTx = fldCNT;

    for(updI = 0; updI < updCNT; updI++) {
  
      fld = &flds[updI];

      for(fldI = 0; 
         (fldI < fldCNT) && (strcmp(fld->name,me->fldx[fldI].name)); 
          fldI++);

      if (fldI != fldCNT) me->fldx[fldI] = *fld;
      else {
        // Append new attribute
        fldCNTx++;
        om$vla_set_dimension(varray = me->fldx, size = fldCNTx);
        me->fldx[fldI] = *fld;
      }
    }
    retFlag = 1;
    goto wrapup;

  case 1: // User

    fldCNT  = om$dimension_of(varray = me->flds);
    fldCNTx = fldCNT;

    for(updI = 0; updI < updCNT; updI++) {
  
      fld = &flds[updI];

      for(fldI = 0; 
         (fldI < fldCNT) && (strcmp(fld->name,me->flds[fldI].name)); 
          fldI++);

      if (fldI != fldCNT) me->flds[fldI] = *fld;
      else {
        // Append new attribute
        fldCNTx++;
        om$vla_set_dimension(varray = me->flds, size = fldCNTx);
        me->flds[fldI] = *fld;
      }
    }
    retFlag = 1;
    goto wrapup;
  }

wrapup:
  return retFlag;
}

/* -------------------------------------------
 * Delete all attributes
 * needs to support selective deleting as well
 */
#argsused
method delAttrs(IGRint f; TVDfld *flds; IGRint cnt) 
{
  IGRstat retFlag = 0;
  IGRint  l_cnt = 0;

  switch(f) {

  case 0:
    om$vla_set_dimension(varray = me->fldx, size = l_cnt);
    retFlag = 1;
    goto wrapup;

  case 1:
    om$vla_set_dimension(varray = me->flds, size = l_cnt);
    retFlag = 1;
    goto wrapup;

  }

wrapup:
  return retFlag;

}
  
method getType(IGRlong *type)
{
  if (type == NULL) return 0;
  *type = me->fldx[0].type;
  return 1;
}
method setType(IGRlong type)
{
  me->fldx[0].type = type;
  return 1;
}
method getFlag(IGRlong *flag)
{
  if (flag == NULL) return 0;
  *flag = me->fldx[0].flag;
  return 1;
}
method setFlag(IGRlong flag)
{
  me->fldx[0].flag = flag;
  return 1;
}
method getName(IGRchar *name)
{
  if (name == NULL) return 0;
  strcpy(name,me->fldx[0].name);
  return 1;
}
method setName(IGRchar *name)
{
  if (name == NULL) return 0;
  strcpy(me->fldx[0].name,name);
  return 1;
}
method getAttr(TVDfld *fld)
{
  if (fld == NULL) return 0;
  *fld = me->fldx[0];
  return 1;
}
method setAttr(TVDfld *fld)
{
  if (fld == NULL) return 0;
  me->fldx[0] = *fld;
  return 1;
}

end implementation VDbtBase;
