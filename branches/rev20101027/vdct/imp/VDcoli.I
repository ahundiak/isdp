/* $Id: VDcoli.I,v 1.2 2001/01/10 22:10:47 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct/imp/VDcoli.I
 *
 * Description: Basic Collector Object
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDcoli.I,v $
 *      Revision 1.2  2001/01/10 22:10:47  art
 *      sp merge
 *
 *      Revision 1.1.1.1  2001/01/04 21:07:58  cvs
 *      Initial import to CVS
 *
# Revision 1.1  2000/12/06  14:53:10  pinnacle
# ah
#
# Revision 1.1  2000/07/25  13:45:30  pinnacle
# ah
#
# Revision 1.2  1999/05/30  14:24:46  pinnacle
# ct
#
# Revision 1.1  1999/05/28  13:59:18  pinnacle
# ct
#
 * Revision 1.1  1999/05/28  12:43:54  pinnacle
 * ct
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/28/99  ah      Creation
 * 07/23/00  ah      Problem when creating private attribute
 * 01/10/01  ah      sp merge
 ***************************************************************************/

class implementation VDcol;

#include "VDcol.h"

/* -----------------------------------------------
 * Generic get attribute by name or index
 */
method vdcolGetAttr(IGRint   f; 
                    IGRchar *name;
                    IGRint   i_nth;  
                    IGRint  *o_nth; 
                    TVDfld  *fld; 
                    TVDfld **fldp) 
{
  IGRstat retFlag = 0;
  IGRuint i;
  IGRuint cnt;

  // Name or index
  if (name == NULL) {
  
    // Index lookup
    switch(f) {
    
    case VDCOL_VLA_INT:
      cnt = om$dimension_of(varray = me->vdcolFld0);
      if ((i_nth < 0) || (i_nth >= cnt)) goto wrapup;
      i = i_nth;
      
      if (fld )  *fld   =  me->vdcolFld0[i];
      if (fldp)  *fldp  = &me->vdcolFld0[i];
      if (o_nth) *o_nth =  i;

      retFlag = 1;
      goto wrapup;
  
    case VDCOL_VLA_EXT:
      cnt = om$dimension_of(varray = me->vdcolFld1);
      if ((i_nth < 0) || (i_nth >= cnt)) goto wrapup;
      i = i_nth;
      
      if (fld )  *fld   =  me->vdcolFld1[i];
      if (fldp)  *fldp  = &me->vdcolFld1[i];
      if (o_nth) *o_nth =  i;
      
      retFlag = 1;
      goto wrapup;
    }
  }
  
  // Do It for name
  switch(f) {
    
  case VDCOL_VLA_INT:
    cnt = om$dimension_of(varray = me->vdcolFld0);
    for(i = 0; (i < cnt) && (strcmp(name,me->vdcolFld0[i].name)); i++);
    if (i == cnt) goto wrapup;
    
    if (fld )  *fld   =  me->vdcolFld0[i];
    if (fldp)  *fldp  = &me->vdcolFld0[i];
    if (o_nth) *o_nth =  i;
    
    retFlag = 1;
    goto wrapup;
      
  case VDCOL_VLA_EXT:
    cnt = om$dimension_of(varray = me->vdcolFld1);
    for(i = 0; (i < cnt) && (strcmp(name,me->vdcolFld1[i].name)); i++);
    if (i == cnt) goto wrapup;
    
    if (fld )  *fld   =  me->vdcolFld1[i];
    if (fldp)  *fldp  = &me->vdcolFld1[i];
    if (o_nth) *o_nth =  i;
    
    retFlag = 1;
    goto wrapup;
    
  }
  goto wrapup;
  
wrapup:
  
  // Clear output if nothing found
  if (!(retFlag & 1)) {
    if (fld)   memset(fld,0,sizeof(fld));
    if (fldp)  *fldp = NULL;
    if (o_nth) *o_nth  = -1;
  }
  return retFlag;
}

/* -----------------------------------------------
 * Generic get attributes
 */
method vdcolGetAttrs(IGRint   f; 
                     IGRint   cntMax; 
                     IGRint  *a_cnt; 
                     TVDfld  *flds; 
                     TVDfld **fldp) 
{
  IGRstat retFlag = 0;
  IGRint  cnt;
  
  IGRuint i;
  			     
  // Do it
  switch(f) {
  case VDCOL_VLA_INT:
    
    // Get the real count
    cnt = om$dimension_of(varray = me->vdcolFld0);
    if (a_cnt) *a_cnt = cnt;
    if (fldp)  *fldp = me->vdcolFld0;
    
    // Xfer data
    if (flds != NULL) {
      // Limit to cntMax if one was given
      if ((cntMax > 0) && (cntMax < cnt)) cnt = cntMax;
      
      for(i = 0; i < cnt; i++) {
        flds[i] = me->vdcolFld0[i];
      }
    }
    retFlag = 1;
    goto wrapup;
    
  case VDCOL_VLA_EXT:
    
    // Get the real count
    cnt = om$dimension_of(varray = me->vdcolFld1);
    if (a_cnt) *a_cnt = cnt;
    if (fldp)  *fldp = me->vdcolFld1;
    
    // Xfer data
    if (flds != NULL) {
      
      // Limit to cntMax if one was given
      if ((cntMax > 0) && (cntMax < cnt)) cnt = cntMax;
      
      for(i = 0; i < cnt; i++) {
        flds[i] = me->vdcolFld1[i];
      }
    }
    retFlag = 1;
    goto wrapup;
}
  
 wrapup:
  
  // No need to clear outputs, rely on proper f
  return retFlag;
}

/* -----------------------------------------------
 * Generic set one attribute by index
 */
method vdcolSetAttr(IGRint   f; 
                    IGRint   nth;   
                    TVDfld  *fld) 
{
  IGRstat retFlag = 0;
  IGRint  cnt;

  // Doit
  switch(f) {
    
  case VDCOL_VLA_INT:
      
    // Get the real count
    cnt = om$dimension_of(varray = me->vdcolFld0);
      
    // Allow appending
    if (nth == cnt) {
      om$vla_set_dimension(varray = me->vdcolFld0, size = cnt + 1);
    }
    if ((nth < 0) || (nth > cnt)) goto wrapup;
      
    if (fld == NULL) memset(&me->vdcolFld0[nth],0,  sizeof(TVDfld));
    else             memcpy(&me->vdcolFld0[nth],fld,sizeof(TVDfld));
      
    retFlag = 1;
    goto wrapup;
      
  case VDCOL_VLA_EXT:
      
    // Get the real count
    cnt = om$dimension_of(varray = me->vdcolFld1);
      
    // Allow appending
    if (nth == cnt) {
      om$vla_set_dimension(varray = me->vdcolFld1, size = cnt + 1);
    }
    if ((nth < 0) || (nth > cnt)) goto wrapup;
      
    if (fld == NULL) memset(&me->vdcolFld1[nth],0,  sizeof(TVDfld));
    else             memcpy(&me->vdcolFld1[nth],fld,sizeof(TVDfld));
      
    retFlag = 1;
      goto wrapup;
      
  }
  
wrapup:
  return retFlag;
}

/* -------------------------------------------
 * Generic set attributes
 */
method vdcolSetAttrs(IGRint f; IGRint cnt; TVDfld *flds) 
{
  IGRstat retFlag = 0;
  IGRuint i;
  
  // Do it
  if (cnt < 0) cnt = 0;
  
  switch(f) {
    
  case VDCOL_VLA_INT:
    om$vla_set_dimension(varray = me->vdcolFld0, size = cnt);
    if (flds != NULL) {
      for(i = 0; i < cnt; i++) {
	me->vdcolFld0[i] = flds[i];
      }
    }
    retFlag = 1;
    goto wrapup;
      
  case VDCOL_VLA_EXT:
    om$vla_set_dimension(varray = me->vdcolFld1, size = cnt);
    if (flds != NULL) {
      for(i = 0; i < cnt; i++) {
	me->vdcolFld1[i] = flds[i];
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
method vdcolUpdAttrs(IGRint f; IGRint updCnt; TVDfld *flds) 
{
  IGRstat   retFlag = 0;
  IGRuint   fldCnt,fldCntx;
  IGRuint   updI,fldI;
  TVDfld   *fld;
  
  // Arg Chk
  if (flds == NULL) goto wrapup;
  
  // Which one
  switch(f) {
    
  case VDCOL_VLA_INT:
      
    fldCnt  = om$dimension_of(varray = me->vdcolFld0);
    fldCntx = fldCnt;
      
    for(updI = 0; updI < updCnt; updI++) {
      
      /* -----------------------------------------
       * 23 July 2000 - ah
       * This started core dumping when adding a new
       * variable.  
       *
       * fld = &me->vdcolFld0[updI];
       */
      fld = &flds[updI];

      for(fldI = 0; 
	  (fldI < fldCnt) && (strcmp(fld->name,me->vdcolFld0[fldI].name)); 
	  fldI++);
	
      if (fldI != fldCnt) me->vdcolFld0[fldI] = *fld;
      else {
	// Append new attribute
	fldCntx++;
	om$vla_set_dimension(varray = me->vdcolFld0, size = fldCntx);
	me->vdcolFld0[fldI] = *fld;
      }
    }
    retFlag = 1;
    goto wrapup;
    
  case VDCOL_VLA_EXT:
      
    fldCnt  = om$dimension_of(varray = me->vdcolFld1);
    fldCntx = fldCnt;
    
    for(updI = 0; updI < updCnt; updI++) {
	
      fld = &flds[updI];
	
      for(fldI = 0; 
	  (fldI < fldCnt) && (strcmp(fld->name,me->vdcolFld1[fldI].name)); 
	  fldI++);
	
      if (fldI != fldCnt) me->vdcolFld1[fldI] = *fld;
      else {
	// Append new attribute
	fldCntx++;
	om$vla_set_dimension(varray = me->vdcolFld1, size = fldCntx);
	me->vdcolFld1[fldI] = *fld;
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
 * Not real hard, just needs to be done
 */
#argsused
method vdcolDelAttrs(IGRint f; IGRint cnt; TVDfld *flds) 
{
  IGRstat retFlag = 0;
  IGRint  l_cnt = 0;
  
  switch(f) {
    
    case VDCOL_VLA_INT:
      om$vla_set_dimension(varray = me->vdcolFld0, size = l_cnt);
      retFlag = 1;
      goto wrapup;
      
    case VDCOL_VLA_EXT:
      om$vla_set_dimension(varray = me->vdcolFld1, size = l_cnt);
      retFlag = 1;
      goto wrapup;
      
  }
  
wrapup:
  return retFlag;
  
}

/* ------------------------------------------------------------
 * Warning - Not tested
 */
method vdcolGetData(IGRint    bufMax;  // I - Length of buf(protects buf)
		                       //     0 means give me it all 
		    IGRint   *bufLen;  // O - Length of data
		    IGRchar  *buf;     // O - Copy data to here
		    IGRchar **bufp)    // O - Set to internal pointer
{
  IGRstat retFlag = 0;
  
  IGRint bufLenx;
  
  // Check real length
  bufLenx  = om$dimension_of(varray = me->vdcolData);
  if ((bufMax > 0) && (bufLenx > bufMax)) bufLenx = bufMax;
  
  // Return length
  if (bufLen) *bufLen = bufLenx;
  
  // Xfer data
  if (buf) {
    memcpy(buf,me->vdcolData,bufLenx);
  }
  
  // Dangerous
  if (bufp) *bufp = me->vdcolData;
  
  // Done
  retFlag = 1;

//wrapup:  
  return retFlag;
}

/* ---------------------------------------------------------------------
 * Just for emergency data
 */
method vdcolSetData(IGRint   bufLen;  // I - Length of data
		    IGRchar *buf)     // I - Set to internal pointer
{
  IGRstat retFlag = 0;

  // Adjust size
  if (bufLen < 0) bufLen = 0;
  om$vla_set_dimension(varray = me->vdcolData, size = bufLen);

  // Xfer data
  if (buf != NULL) {  
    memcpy(me->vdcolData,buf,bufLen);
  }
  
  retFlag = 1;
  
//wrapup:
  return retFlag;
}

end implementation VDcol;









