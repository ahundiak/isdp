/* $Id: VDvla2.I,v 1.3 2001/01/11 16:34:32 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdah/VDvla2.I
 *
 * Description: Predefined arrays of arbitary size
 *              Second generation effort
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDvla2.I,v $
 *      Revision 1.3  2001/01/11 16:34:32  art
 *      sp merge
 *
 *      Revision 1.1  2001/01/11 16:20:59  art
 *      s merge
 *
# Revision 1.1  2000/12/06  14:53:10  pinnacle
# ah
#
# Revision 1.1  2000/05/15  20:11:12  pinnacle
# initial revision
#
# Revision 1.5  1999/06/16  15:58:12  pinnacle
# (No comment)
#
# Revision 1.4  1999/05/24  18:16:34  pinnacle
# ah
#
# Revision 1.3  1999/05/06  21:35:58  pinnacle
# (No comment)
#
# Revision 1.2  1999/04/26  21:17:24  pinnacle
# ah
#
# Revision 1.1  1999/04/26  19:20:34  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/26/99  ah      Creation
 ***************************************************************************/

class implementation Root;

#include "VDtypedef.h"
#include "VDvla2.h"
#include "VDobj.h"
#include "VDchn.h"

// static IGRint traceFlag;

/* ----------------------------------------------------
 * Append item, grow if necesary
 */
IGRstat VDvlaAppend(TVDvla  *vla, 
                    IGRchar *data)
{
  IGRstat retFlag = 0;

  TVDvlax *vlax,*vlaxx;

  // Arg check
  if ((vla == NULL) || (data == NULL)) goto wrapup;

  // Room in first section
  if (vla->cnt < vla->max) {
    memcpy(vla->data + (vla->cnt * vla->siz), data, vla->siz);
    vla->cnt++;
    retFlag = 1;
    goto wrapup;
  }
  
  // Find empty chunk
  for(vlax = (TVDvlax*)vla->next; 
     (vlax) && (vlax->cnt >= vlax->max); 
      vlax = (TVDvlax*)vlax->next);
  
  // Might need to allocate more
  if (vlax == NULL) {
    vlax = (TVDvlax*)calloc(1,sizeof(TVDvlax) + (vla->siz * vla->add));
    if (vlax == NULL) {
      printf("Problem allocating vla memory\n");
      goto wrapup;
    }
    vlax->cnt  = 0;
    vlax->max  = vla->add;
    vlax->next = NULL;
    vlax->data = (IGRchar*)(vlax + 1);
  
    if (vla->next == NULL) vla->next = (IGRchar*)vlax;
    else {
      for(vlaxx = (TVDvlax*)vla->next; 
          vlaxx->next; 
          vlaxx = (TVDvlax*)vlaxx->next);
      vlaxx->next = (IGRchar*)vlax;
    }

    // If init function was passed, execute it
    if (vla->init) (*vla->init)(vlax->data,vla->add);
  
  }
  
  // Xfer
  memcpy(vlax->data + (vlax->cnt * vla->siz), data, vla->siz);
  vlax->cnt++;
  
  // Done
  retFlag = 1;

wrapup:
  return retFlag;
}

/*
** ----------------------------------------------------
** Overwrite item
** ----------------------------------------------------
*/
IGRstat VDvlaOverwriteNth( TVDvla  *vla, 
			   IGRint  *nth,
                           IGRchar *data,
			   IGRchar **dataP,
			   IGRchar **dataPNew )
{
  IGRstat retFlag;
  TVDvlax *vlax, *vlaxx;
  IGRint  position_num, num;
  IGRint  i;


  retFlag = 0;
  num     = *nth + 1;

  /*
  ** Arg check
  */
  if( (vla==NULL) || (data==NULL && dataP==NULL) ) goto wrapup;

  /*
  ** If it is in first section
  */
  if( *nth < vla->max )
  {
    if( dataP )
    {
      memcpy( ((vla->data)+((*nth)*(vla->siz))), *dataP, vla->siz );
      if( dataPNew ) *dataPNew = ((vla->data)+((*nth)*(vla->siz)));
      retFlag = 1;
      goto wrapup;
    }

    if( !(dataP) && data )
    {
      memcpy( ((vla->data)+((*nth)*(vla->siz))), data, vla->siz );
      if( dataPNew ) *dataPNew = ((vla->data)+((*nth)*(vla->siz)));
      retFlag = 1;
      goto wrapup;
    }

    goto wrapup;
  }
  
  /*
  ** Find proper position
  */
  vlax = (TVDvlax*)vla->next;
  if( vlax == NULL )
  {
    printf("Problem finding the nth position\n");
    goto wrapup;
  }

  num -= vla->max;
  while( vlax )
  {
    vlaxx = (TVDvlax *)vlax->next;
    if( num <= vlax->max )
    {
      position_num = num - 1;
      break;
    }
    num -= vlax->max;
    vlax = vlaxx;
    if( vlax == NULL )
    {
      printf("Problem finding the nth position\n");
      goto wrapup;
    }
  }

  if( dataP )
  {
    memcpy( ((vlax->data)+((position_num)*(vla->siz))), *dataP, vla->siz );
    if( dataPNew ) *dataPNew = ((vlax->data)+((position_num)*(vla->siz)));
    retFlag = 1;
    goto wrapup;
  }
  
  if( !(dataP) && data )
  {
    memcpy( ((vlax->data)+((position_num)*(vla->siz))), data, vla->siz );
    if( dataPNew ) *dataPNew = ((vlax->data)+((position_num)*(vla->siz)));
    retFlag = 1;
    goto wrapup;
  }


wrapup:
  return retFlag;
} /* VDvlaOverwriteNth */

/*
** ----------------------------------------------------
** Overwrite item
** ----------------------------------------------------
*/
IGRstat VDvlaRearrangeVla( TVDvla  *vla, 
			   IGRint  *numOp,
                           IGRint  *totalNumOp )
{
  IGRstat retFlag;
  TVDvlax *vlax, *vlaxx, *vlaxxx;
  IGRint  i, opPosition;
  IGRint  num;


  retFlag    = 0;
  num        = *numOp;

  /*
  ** Arg check
  */
  if( vla == NULL ) goto wrapup;

  /*
  ** If it is in first section
  */
  if( *numOp <= vla->max )
  {
    vla->cnt = *numOp;
    vlax = (TVDvlax *)vla->next;

    while( vlax )
    {
      vlaxx = (TVDvlax *)vlax->next;
      free(vlax);
      vlax = vlaxx;
    }

    vla->next = NULL;
    retFlag = 1;
    goto wrapup;
  }
  
  /*
  ** Find proper section downstream
  */
  vlax = (TVDvlax *)vla->next;
  num -= vla->max;
  while( vlax )
  {
    vlaxx = (TVDvlax *)vlax->next;
    if( num <= vlax->max )
    {
      opPosition = num - 1;
      break;
    }
    num -= vlax->max;
    vlax = vlaxx;
  }

  /*
  ** Fill the data
  */
  vlax->cnt = opPosition + 1;
  while( vlaxx )
  {
    vlaxxx = (TVDvlax *)vlaxx->next;
    free(vlaxx);
    vlaxx = vlaxxx;
  }
  vlax->next = NULL;
  
  /*
  ** Done
  */
  retFlag = 1;


wrapup:
  return retFlag;
} /* VDvlaRearrangeVla */

/* ----------------------------------------------------
 * Gets a pointer to the next available item and
 * reserves it for the user, 
 * Note that this does not clear the memory 
 */
IGRstat VDvlaGetAppend(TVDvla *vla, IGRchar **dataP)
{
  IGRstat retFlag = 0;
  TVDvlax *vlax,*vlaxx;
  
  // Arg check
  if (dataP) *dataP = NULL;
  if (vla == NULL) goto wrapup;
  
  // Is in first
  if (vla->cnt < vla->max) {
    *dataP = vla->data + (vla->cnt * vla->siz);
    vla->cnt++;
    retFlag = 1;
    goto wrapup;
  }
  
  // Find chunk
  vlax = (TVDvlax*)vla->next;
  while((vlax) && (vlax->cnt >= vlax->max)) {
    vlax = (TVDvlax*)vlax->next;
  }

  // Might need to allocate
  if (vlax == NULL) {
    vlax = (TVDvlax*)calloc(1,sizeof(TVDvlax) + (vla->siz * vla->add));
    if (vlax == NULL) {
      printf("Problem allocating vla memory\n");
      goto wrapup;
    }
    vlax->cnt  = 0;
    vlax->max  = vla->add;
    vlax->next = NULL;
    vlax->data = (IGRchar*)(vlax + 1);
  
    // Link to the list
    if (vla->next == NULL) vla->next = (IGRchar*)vlax;
    else {
      for(vlaxx = (TVDvlax*)vla->next; 
          vlaxx->next; 
          vlaxx = (TVDvlax*)vlaxx->next);
      vlaxx->next = (IGRchar*)vlax;
    }
    // If init function was passed, execute it
    if (vla->init) (*vla->init)(vlax->data,vla->add);
  }
    
  // Xfer
  if (dataP) *dataP = vlax->data + (vlax->cnt * vla->siz);
  vlax->cnt++;
  
  // Done
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ----------------------------------------------------
 * Get the nth item
 */
IGRstat VDvlaGetNth(TVDvla   *vla, 
		    IGRint    nth,
		    IGRchar  *data,
		    IGRchar **dataP)
{
  IGRstat retFlag = 0;
  TVDvlax *vlax;
  
  // Arg check
  if (dataP) *dataP = NULL;
  if (vla == NULL) goto wrapup;
  
  // Is in first
  if (nth < vla->cnt) {
    if (data) memcpy(data,vla->data + (nth * vla->siz),vla->siz);
    if (dataP) *dataP   = vla->data + (nth * vla->siz);
    retFlag = 1;
    goto wrapup;
  }
  
  // Find chunk
  nth -= vla->max;
  vlax = (TVDvlax*)vla->next;
  while((vlax) && (nth >= vlax->cnt)) {
    nth -= vlax->cnt;
    vlax = (TVDvlax*)vlax->next;
  }
  if (vlax == NULL) goto wrapup;
  
  // Xfer
  if (data) memcpy(data,vlax->data + (nth * vla->siz),vla->siz);
  if (dataP) *dataP   = vlax->data + (nth * vla->siz);
  
  // Done
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ----------------------------------------------------
 * Get item count
 */
IGRstat VDvlaGetCnt(TVDvla *vla, 
		    IGRint *cnt)
{
  IGRstat retFlag = 0;
  TVDvlax *vlax;
  
  // Arg check
  if (cnt == NULL) goto wrapup;
  *cnt = 0;
  if (vla == NULL) goto wrapup;

  *cnt = vla->cnt;
  
  for(vlax = (TVDvlax*)vla->next; vlax; vlax = (TVDvlax*)vlax->next) {
    *cnt = *cnt + vlax->cnt;
  }

  // Done
  retFlag = 1;

wrapup:
  return retFlag;
}
/* ----------------------------------------------------
 * Allocates and initializes a new vla
 */
IGRstat VDvlaAlloc(TVDvla **vlaP,
                   IGRint   siz,
                   IGRint   max,
                   IGRint   add,
		  IGRint  (*init)(void *data, IGRint cnt),
		  IGRint  (*sort)(void *p1, void *p2))
{
  IGRstat retFlag = 0;
  TVDvla *vla = NULL;

  // Arg check
  if (vlaP == NULL) goto wrapup;
  *vlaP = NULL;

  // Allocate first node
  vla = (TVDvla*)calloc(1,sizeof(TVDvla) + (siz * max));
  if (vla == NULL) goto wrapup;
  *vlaP = vla;

  // Transfer data
  vla->cnt  = 0;
  vla->max  = max;
  vla->add  = add;
  vla->siz  = siz;
  vla->init = init;
  vla->sort = sort;
  vla->next = NULL;
  vla->data = (IGRchar*)(vla + 1);

  // If init function was passed, execute it
  if (init) (*init)(vla->data,max);

  // Done
  retFlag = 1;

wrapup:
  if (vla == NULL) {
    printf("Problem allocating TVDvla data\n");
  }
  return retFlag;
}

/* ----------------------------------------------------
 * Initialize, vla must already be allocated 
 */
IGRstat VDvlaInit(TVDvla  *vla,
                  IGRint   siz,
		  IGRint   max,
		  IGRint   add,
		  IGRint  (*init)(void *data, IGRint cnt),
		  IGRint  (*sort)(void *p1, void *p2))
{
  IGRstat retFlag = 0;

  // Arg Check
  if (vla == NULL) goto wrapup;

  // Clear everything, mainly to get rid of pointers in data structures
  memset(vla,0,sizeof(TVDvla) + (siz * max));
  
  // Do it
  vla->cnt  = 0;
  vla->siz  = siz;
  vla->max  = max;
  vla->add  = add;
  vla->init = init;
  vla->sort = sort;
  vla->next = NULL;
  vla->data = (IGRchar*)(vla + 1);

  // If init function was passed, execute it
  if (init) (*init)(vla->data,max);
  
  // Done
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ----------------------------------------------------
 * Free
 */
IGRstat VDvlaFree(TVDvla *vla, IGRint freeFlag)
{
  IGRstat retFlag = 0;

  TVDvlax *vlax,*vlaxx;
  
  // Arg check
  if (vla == NULL) goto wrapup;

  // Free any downstream items
  vlax = (TVDvlax*)vla->next;

  while(vlax) {
    vlaxx = (TVDvlax*)vlax->next;
    free(vlax);
    vlax = vlaxx;
  }

  // If flag is set, get rid of it
  if (freeFlag) free(vla);
 
  // Done
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ----------------------------------------------------
 * Empties but does not actually free
 */
IGRstat VDvlaEmpty(TVDvla *vla)
{
  IGRstat retFlag = 0;
  TVDvlax *vlax;
  
  // Arg check
  if (vla == NULL) goto wrapup;
  vla->cnt = 0;
  
  for(vlax = (TVDvlax*)vla->next; vlax; vlax = (TVDvlax*)vlax->next) {
    vlax->cnt = 0;
  }

  // Done
  retFlag = 1;

wrapup:
  return retFlag;
}

/* -------------------------------------------
 * Wrapper for TGRid
 */
IGRint VDvlaidInitData(void *data, IGRint cnt)
{
  IGRstat retFlag = 0;
  TGRid  *id;
  IGRint  i;
  
  // Arg check
  if (data == NULL) goto wrapup;
  id = (TGRid *)data;
  for(i = 0; i < cnt; i++) {
    id[i].osnum = 0;
    id[i].objid = NULL_OBJID;
  }
  retFlag = 1;
  
wrapup:
  return retFlag;
}

IGRstat VDvlaidInit(TVDvlaid *vla)
{
  IGRstat retFlag = 0;
  IGRint  max = VDVLA_ID_MAX;
  IGRint  add = VDVLA_ID_ADD;
  
  // Pass onto standard routine
  retFlag = VDvlaInit((TVDvla*)vla,sizeof(TGRid),max,add,NULL,NULL);

  return retFlag;
}

IGRstat VDvlaidFree(TVDvlaid *vla)
{
  IGRstat retFlag = 0;
  
  // Pass onto standard routine
  retFlag = VDvlaFree((TVDvla*)vla,0);
  
  return retFlag;
}

IGRstat VDvlaidEmpty(TVDvlaid *vla)
{
  IGRstat retFlag = 0;
  
  // Pass onto standard routine
  retFlag = VDvlaEmpty((TVDvla*)vla);
  
  return retFlag;
}
IGRstat VDvlaidAppend(TVDvlaid *vla, TGRid *data)
{
  IGRstat retFlag = 0;
  
  // Pass onto standard routine
  retFlag = VDvlaAppend((TVDvla*)vla,(IGRchar*)data);
  
  return retFlag;
}
IGRstat VDvlaidGetCnt(TVDvlaid *vla, IGRint *cnt)
{
  IGRstat retFlag = 0;
  
  // Pass onto standard routine
  retFlag = VDvlaGetCnt((TVDvla*)vla,cnt);
  
  return retFlag;
}
IGRstat VDvlaidGetNth(TVDvlaid *vla, IGRint nth, TGRid *data, TGRid **dataP)
{
  IGRstat retFlag = 0;
  
  // Pass onto standard routine
  retFlag = VDvlaGetNth((TVDvla*)vla,nth,(IGRchar*)data,(IGRchar**)dataP);
  
  return retFlag;
}

/* -------------------------------------------
 * Wrapper for TGRobj_env
 */
IGRstat VDvlaoeInit(TVDvlaoe *vla)
{
  IGRstat retFlag = 0;
  IGRint  max = VDVLA_OE_MAX;
  IGRint  add = VDVLA_OE_ADD;
  
  // Pass onto standard routine
  retFlag = VDvlaInit((TVDvla*)vla,sizeof(TGRobj_env),max,add,NULL,NULL);

  return retFlag;
}

IGRstat VDvlaoeFree(TVDvlaoe *vla)
{
  IGRstat retFlag = 0;
  
  // Pass onto standard routine
  retFlag = VDvlaFree((TVDvla*)vla,0);
  
  return retFlag;
}

IGRstat VDvlaoeEmpty(TVDvlaoe *vla)
{
  IGRstat retFlag = 0;
  
  // Pass onto standard routine
  retFlag = VDvlaEmpty((TVDvla*)vla);
  
  return retFlag;
}
IGRstat VDvlaoeAppend(TVDvlaoe *vla, TGRobj_env *data)
{
  IGRstat retFlag = 0;
  
  // Pass onto standard routine
  retFlag = VDvlaAppend((TVDvla*)vla,(IGRchar*)data);
  
  return retFlag;
}
IGRstat VDvlaoeGetCnt(TVDvlaoe *vla, IGRint *cnt)
{
  IGRstat retFlag = 0;
  
  // Pass onto standard routine
  retFlag = VDvlaGetCnt((TVDvla*)vla,cnt);
  
  return retFlag;
}
IGRstat VDvlaoeGetNth(TVDvlaoe *vla, IGRint nth, TGRobj_env *data, TGRobj_env **dataP)
{
  IGRstat retFlag = 0;
  
  // Pass onto standard routine
  retFlag = VDvlaGetNth((TVDvla*)vla,nth,(IGRchar*)data,(IGRchar**)dataP);
  
  return retFlag;
}

/* -------------------------------------------
 * Testing routine
 */
IGRstat VDvlaidTest()
{
  IGRstat retFlag = 0;

  TVDvlaid vla;
  TGRid   data;
  
  IGRint i,cnt,max;

  // Init
  VDvlaidInit(&vla);
  for(i = 0; i < 5; i++) {
    printf("Init ID %d,%d\n",vla.data[i].osnum,vla.data[i].objid);
  }
  
  // Fill it up
  max = 35;
  for(i = 0; i < max; i = i + 1) {
    data.objid = i;
    VDvlaidAppend(&vla,&data);
  }

  // Get each one
  for(i = 0; VDvlaidGetNth(&vla,i,&data,NULL); i = i + 1) {
    printf("%2d %2d\n",i,data.objid);
  }

  // Check count
  VDvlaidGetCnt(&vla,&cnt);
  printf("Count %2d %2d\n",i,cnt);

  // Check empty
  VDvlaidEmpty(&vla);
  VDvlaidGetCnt(&vla,&cnt);
  printf("Count After Empty %2d\n",cnt);

  // Check free
  VDvlaidFree(&vla);

  // Done
  printf("Done\n");
  retFlag = 1;
  return retFlag;
}

end implementation Root;






