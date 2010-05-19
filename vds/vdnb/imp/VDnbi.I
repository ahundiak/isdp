/* $Id: VDnbi.I,v 1.2 2001/01/19 22:18:22 jayadev Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdnb/imp/VDnbi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDnbi.I,v $
 *      Revision 1.2  2001/01/19 22:18:22  jayadev
 *      *** empty log message ***
 *
# Revision 1.1  2000/06/30  17:01:48  pinnacle
# Created: vds/vdnb/VDnbi.I by rchennup for Service Pack
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/12/17  23:15:24  pinnacle
# VDnb
#
 *
 *
 * History:
 *      MM/DD/YY  AUTHOR  DESCRIPTION
 *      12/17/97  ah      Created
 *      06/26/00  Jayadev VDCreateNBFromASCII for vd_$createNB() macro 
 ***************************************************************************/

class implementation VDnb;
extern IGRint getNewName();

method getText(IGRchar *bufPnt; IGRlong bufMax; IGRlong *bufCnt)
{
  IGRlong noteLen;
  IGRlong i;

  // Get buffer length
  if (bufCnt != NULL) *bufCnt = 0;
  noteLen = om$dimension_of(varray = me->notes);

  // If pointer is null then just return length
  if (bufPnt == NULL) {
    if (bufCnt != NULL) *bufCnt = noteLen;
    return 1;
  }

  // Check on valid max buf size
  if (bufMax <= 0) {
    return 0;
  }
  *bufPnt = 0;
  if (bufCnt != NULL) *bufCnt = noteLen;

  // Have two nulls at very end, drop one off
  noteLen--;

  // Make sure have room in buffer for text plus null
  if (noteLen >= bufMax) {
    noteLen = bufMax - 1;
  }

  // Transfer data
  for(i = 0; i < noteLen; i++) {

    if (me->notes[i] != 0) *bufPnt = me->notes[i];
    else                   *bufPnt = '\n';

    bufPnt++;
  }

  // Terminate NULL
  *bufPnt = 0;

  return 1;
}
method setText(IGRchar *bufPnt; IGRlong bufCnt)
{
  int ii;
  om$vla_set_dimension ( varray = me->notes, size = bufCnt );
  
  for(ii=0;ii<bufCnt;ii++) me->notes[ii] = bufPnt[ii];
 
  return 1;
}

extern VDclassid OPP_GRnb_class_id;
extern VDclassid OPP_VDnb_class_id;

IGRstat VDnbGetTextFromID  (TGRid   *nbID, IGRint textSize, IGRchar *text);
IGRstat VDnbGetTextFromPath(IGRchar *path, IGRint textSize, IGRchar *text);

IGRstat VDnbGetTextTest()
{
  IGRchar buf[1024];

  VDnbGetTextFromPath(":junk2.m:ref:junk.m:NoteBook:NoteBook",1024,buf);

  printf("BUF\n%s\n",buf);

  return 1;
}

/* -----------------------------------
 * Gets a copy of the text buffer
 * Given a path to the notebook object
 */
IGRstat VDnbGetTextFromPath(IGRchar *path, IGRint textSize, IGRchar *text)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  TGRid   nbID;

  if (text) *text = 0;

  nbID.objid = NULL_OBJID;
  sts = di$translate(	
    objname =  path,
    p_osnum = &nbID.osnum,
    p_objid = &nbID.objid
  );

  if (nbID.objid == NULL_OBJID) {
    // printf("Could not find notebook object for %s\n",path);
    goto wrapup;
  }

  retFlag = VDnbGetTextFromID(&nbID,textSize,text);

wrapup:
  return retFlag;
}

/* -----------------------------------
 * Gets a copy of the text buffer
 * Given an id
 */
IGRstat VDnbGetTextFromID(TGRid *nbID, IGRint textSize, IGRchar *text)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  VDclassid nbCLASS;
  TGRid     nbIDcopy;
  IGRint    alreadyNB = FALSE;

  // Init
  nbIDcopy.objid = NULL_OBJID;

  // Empty buffer
  if (text) *text = 0;

  // Check args
  if ((textSize < 1) || (text == NULL)) {
    printf("No text buffer for notebook object\n");
    goto wrapup;
  }

  // Check object class
  nbCLASS = 0;
  om$get_classid(
    objid = nbID->objid,
    osnum = nbID->osnum,
    p_classid = &nbCLASS
  );
  if ((nbCLASS != OPP_GRnb_class_id)&&(nbCLASS != OPP_VDnb_class_id)) {
    VDbroPrintObj(nbID);
    goto wrapup;
  }
  if(nbCLASS == OPP_VDnb_class_id) alreadyNB = TRUE;
  if(!alreadyNB){
  // Make a copy
  nbIDcopy.objid = NULL_OBJID;
  nbIDcopy.osnum = OM_Gw_current_OS;
  sts = om$construct_and_copy ( 
    objid     = nbID->objid,
    obj_osnum = nbID->osnum,
    osnum   =  nbIDcopy.osnum,
    p_objid = &nbIDcopy.objid
  );
  if (nbIDcopy.objid == NULL_OBJID) {
    VDbroPrintObj(nbID);
    goto wrapup;
  }

  // Chenge class to use new methods
  sts = om$change_class(
    objid = nbIDcopy.objid,
    osnum = nbIDcopy.osnum,
    classname = "VDnb"
  );
  if (!(sts & 1)) {
    VDbroPrintObj(nbID);
    goto wrapup;
  }
  }
  else{
    nbIDcopy.objid = nbID->objid;
    nbIDcopy.osnum = nbID->osnum;
  }              
  // Get the buffer
  sts = om$send(
    msg = message VDnb.getText(text,textSize,NULL),
    senderid = NULL_OBJID,
    targetid = nbIDcopy.objid,
    targetos = nbIDcopy.osnum
  );
  if (!(sts & 1)) {
    VDbroPrintObj(nbID);
    goto wrapup;
  }

  retFlag = 1;

wrapup:

  // Get rid of copy
  if ((nbIDcopy.objid != NULL_OBJID)&&(!alreadyNB)) {
    om$send(
      msg = message Root.delete(0),
      senderid = NULL_OBJID,
      targetid = nbIDcopy.objid,
      targetos = nbIDcopy.osnum
    );
  }

  return retFlag;

}

IGRint VDCreateNBFromASCII(char *ASFile, char *nbName, struct GRid *nbID )
{
 int status ,retFlag = 0;
 struct GRid obj;
 int ret_type = 0,nbCnt;
 GRspacenum osnum,tmpos;
 GRobjid    objid,tmpobj;
 IGRlong    sts;
 FILE *file;
 int  ret, size, line, i,j;
 char buf1[256];
 char *ptr,*ptr_tmp,tmp[512];
 IGRchar osPath[DI_PATH_MAX];
 IGRchar nbPath[DI_PATH_MAX];
 IGRchar current_dir[DI_PATH_MAX];
 char mesg[DI_PATH_MAX];
 char full_name[DI_PATH_MAX];

 line = 0;
 size = 0;

 // Open file
 file = NULL;
 file = fopen(ASFile,"r");
 if (file == NULL) {
   printf("Error Opening ASCII File %s\n",ASFile);
 }
 while(fgets(buf1,sizeof(buf1),file)) {
     size = size+ strlen ( buf1 );
     line = line+1;
   }
 fclose(file);

 ptr = (char *)malloc(size*sizeof(char));

 // Open file again
 file = NULL;
 file = fopen(ASFile,"r");
 if (file == NULL) {
   printf("Error Opening ASCII File %s\n",ASFile);
 }

 //record the file contents
 i=0;
 while(fgets(buf1,sizeof(buf1),file)) {
     for (ptr_tmp = buf1; *ptr_tmp!='\n';){
       ptr[i++] = *ptr_tmp++;
     }
     ptr[i++] = '\0'; 
 }
 fclose(file);
 ex$get_cur_mod ( osnum = &osnum );

 // check if a directory by the name NoteBook exist in the current OS

 di$give_pathname(osnum = osnum, pathname = osPath);
 sprintf(nbPath,"%s:NoteBook",osPath);
 nbCnt = 0;

 di$start_find(start_dir = nbPath, ptr = &nbCnt);
 if(!nbCnt) di$mkdir ( osnum = osnum, dirname = "NoteBook" );
  
      status = om$construct(classname = "VDnb",p_objid = &objid,osnum = osnum);

 if (status & 1)
 {
      // check any object for duplicate name in this NoteBook directory
      di$pwd(dirname = current_dir);
      di$cd ( dirname = nbPath );
      sprintf(full_name,"%s:%s",nbPath,nbName);

      if(di$translate ( objname = full_name, p_objid = &tmpobj, p_osnum = &tmpos) == DIR_S_SUCCESS)
      {
          ret_type = getNewName(nbName,current_dir,nbName);
          if(!ret_type){
		sprintf(mesg,"Name %s exists: failed to change it ",nbName),
          	UI_status(mesg);
		goto wrapup;
	   }
          sprintf(mesg,"Duplicate %s -> New name %s",full_name,nbName);
          UI_status(mesg);
          sleep(2);

      }
      // restore back the current directory
      di$cd ( dirname = current_dir );
      
      status = di$add_name ( osnum = osnum, path = "NoteBook", objname = nbName, objid = objid );
 }
  // Set the buffer
  sts = om$send(
    msg = message VDnb.setText(ptr,size),
    senderid = NULL_OBJID,
    targetid = objid,
    targetos = osnum);
  if (!(sts & 1)) {
    printf("Problem setting text for [%d,%d]\n",objid,osnum);
    goto wrapup;
  }
  nbID->objid = objid ;
  nbID->osnum = osnum ;

  retFlag = 1;
wrapup:
  if(ptr) free(ptr); ptr = NULL;
  return retFlag;
}

end implementation VDnb;

