/* $Id: VDMgmTagNum.C,v 1.1.1.1 2001/01/04 21:09:31 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdutil / VDMgmTagNum.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDMgmTagNum.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:31  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.2  1995/11/29  13:55:46  pinnacle
 * Replaced: ./vdutil/VDMgmTagNum.C for:  by ksundar for vds.240
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

#include        <stdio.h>

#include        "exmacros.h"
#include        "OMerrordef.h"

#include        "ms.h"
#include        "msdef.h"
#include        "msmacros.h"

#include        "VDDbDef.h"
#include        "vdbmacros.h"
#include        "VDSutil.h"
#include        "VDmsg.h"
#include 	"grdpbdef.h"
#include 	"grdpbmacros.h"
#include 	"VDSequipdef.h"



/*
 *   Functions allowing a commomn management of the tag number 
 *
 */

#define VD_ID_LIST_SIZE		10
#define VD_ID_STRING_SIZE	16

/*
 * MgnTagNum:
 *
 * If behaviour == 0 => no Id management.
 * If behaviour == 1 => Group Id management.
 * If behaviour == 2 => Unic Id management.
 *
 * If no id management, we do as if it was some management but no 
 * check is performed. The Id is lock in case of somebody else wants
 * Id management to be sure to use this Id.
 *
 *  Mode:  VDTagNumberInit.   Intitilize the list (called at init_form_notif only).
 *	:  VDTagNumberVerif.  Verify the Tag number.
 *	:  VDTagNumberAuto.   Select automatically a free tag number. 
 *	:  VDTagNumberModif.  The tag number has been modified.
 *	:  VDTagNumberModel.  We are in Model mode eles schematic.
 *	:  VDTagNumberGetNewList. Force to get a new list (initial_form_notif).
 *
 *
 *  Only the selected Id is locked. This means that because the list is not locked
 *  somebody else can have used the selected one. It is really too time consuming
 *  to lock the list.
 *
 *  The VDTagNumberModif must be used when the object has been already created
 *  with a tag number and this one is modified (The PreTagNumber must be defined).
 *
 *  Mode can be modified to specified that the list must be reinitialize the
 *  next time (when a tag number was already locked).
 */

VDMngTagNum(msg, FormPtr, Label, MsgLabel, Mode, System, PreSystem, Category, 
	    Behaviour, Original, OldTagNumber, TagNumber)
IGRlong		*msg;		/* O : Complection code 		*/
IGRchar		*FormPtr;	/* I : Form pointer			*/
IGRint		Label;		/* I : Gadget id			*/
IGRint		MsgLabel;	/* I : Gadget id			*/
IGRint		*Mode;		/* I/O : Selection mode			*/
IGRchar		*System;	/* I : System name			*/
IGRchar		*PreSystem;	/* I : Previous System name		*/
IGRint		Category;	/* I : category				*/
IGRint		Behaviour;	/* I : behaviour			*/
IGRint		Original;	/* I : 1 if original			*/
IGRchar		*OldTagNumber;	/* I : Prev tag number			*/
IGRchar		*TagNumber;	/* O : tag number state management	*/
{
 IGRchar	PreTagNumber[VD_ID_STRING_SIZE], IdString[VD_ID_STRING_SIZE];
 IGRint		IdList[VD_ID_LIST_SIZE];
 IGRint         row = 0, col = 0, sel_flag = 0;
 
 /*
  * The user wants a unic number (behaviour = 2):
  *
  *   	- The user can keyin the number
  *
  *	- The user can select it in the list
  *
  *	- A number can be automatically proposed.
  */

if(OldTagNumber) strcpy(PreTagNumber,OldTagNumber); /* This allow to have the same pointer */

if(Behaviour == 0)
 {
  FIg_set_text(FormPtr, MsgLabel,"Mode: No tag number management");
  for(row=0;row<10;row++) VDfld_set_list_text(FormPtr, Label, row, col, "", sel_flag );
  /* FIg_set_text(FormPtr, Label,""); */
 
  *msg = MSSUCC;
  return OM_S_SUCCESS;
 }

if((Original != 1) && (*Mode & VDTagNumberInit))
 {
  /* It is a reference one .
  /* Should get the list or corresponding original ...
  /* */


 if(0)
 {
  FIg_set_text(FormPtr, MsgLabel,"Key-in the original tag number");
  for(row=0;row<10;row++) VDfld_set_list_text(FormPtr, Label, row, col, "", sel_flag );
  /*  FIg_set_text(FormPtr, Label,""); */
 }
 else
 {
  /* Get the list of existing (database components) */
  for(row=0;row<10;row++) VDfld_set_list_text(FormPtr, Label, row, col, "", sel_flag );
  FIg_set_text(FormPtr, Label,"");
  if(!(VRGetRefAutoID(FormPtr, Label, MsgLabel, FALSE, System, Category ) & 1))
   {
    FIg_set_text(FormPtr, MsgLabel,"Error getting the referenced components");
    for(row=0;row<10;row++) VDfld_set_list_text(FormPtr, Label, row, col, "", sel_flag );
    *msg = MSFAIL;
    return OM_S_SUCCESS;
   }
 }
  /* if => original, I need a new list of Ids */
  *Mode = (*Mode & 0x1011) | VDTagNumberGetNewList;
    
  *msg = MSSUCC;
  return OM_S_SUCCESS;
 }


/* printf("Mode: %d\n", *Mode);  
/* printf("tag number: <%s>\n",TagNumber);
/* */

if(*Mode & VDTagNumberInit)
 {
  IGRint NbDefRow = 0;

  if(Behaviour == 0 || *Mode & VDTagNumberModel)
   {
    /* No tag number management */
    if(*Mode & VDTagNumberModel)FIg_set_text(FormPtr, MsgLabel,"No tag number management, schematic only");
    else                        FIg_set_text(FormPtr, MsgLabel,"No Tag number management ");
    for(row=0;row<10;row++) VDfld_set_list_text(FormPtr, Label, row, col, "", sel_flag );
    /* FIg_set_text(FormPtr, Label,""); */
    *msg = MSSUCC;
    return OM_S_SUCCESS;
   }

  FIfld_get_list_num_rows(FormPtr, Label, 0, &NbDefRow);
  if(!(*Mode & VDTagNumberGetNewList) && NbDefRow > 0)
   {
    /* Use the current list */
    *msg = MSSUCC;
    return OM_S_SUCCESS;
   }

  FIg_set_text(FormPtr, MsgLabel,"Get the list of free tag numbers");    
  if(VDGetListOfIDs(System, Category, IdList) != 1)
   {
    /* Problem retrieving Ids ... (may the connection to the db */
    FIg_set_text(FormPtr, MsgLabel,"Error getting free tag number");    
    *msg = MSFAIL;
    return OM_W_ABORT;
   }
  FIg_set_text(FormPtr, MsgLabel," ");    

  /* For the next time to avoid to get the new list */
  *Mode = *Mode & ~VDTagNumberGetNewList;

  for(row=0;row<VD_ID_LIST_SIZE;row++)
   {
    if(sprintf(IdString, "%05d", IdList[row]) < 0) continue;
    VDfld_set_list_text(FormPtr, Label, row, col, IdString, sel_flag);
   }

  if(*Mode & VDTagNumberAuto && Original == 1)
   {
    /* Just take the first one and lock it */
    FIg_set_text(FormPtr, MsgLabel,"Lock the tag number ");    
    if(VDLockSelectedID(System, Category, IdList[0]) != 1)
     {
      /* Unable to lock this one, continue  */
      FIg_set_text(FormPtr, MsgLabel,"Cannot lock the tag number !!!");    
      FIg_set_text(FormPtr,Label,"");
     }
    else
     {
      sprintf(IdString, "%05d", IdList[0]);
      FIg_set_text(FormPtr,Label,IdString);
      if(TagNumber) strcpy(TagNumber, IdString);
     }
    FIg_set_text(FormPtr, MsgLabel," ");    
   }
  *msg = MSSUCC;
  return OM_S_SUCCESS;
 }
   

if(*Mode & VDTagNumberVerif)
 {
  IGRint IdNum, PrevIdNum;

  PrevIdNum = -1;
  FIg_get_text(FormPtr,Label,IdString);


  if(TagNumber) strcpy(TagNumber, IdString);
  if((strcmp(IdString, PreTagNumber) == 0) && (strcmp(PreSystem, System) == 0))
   {
    /* Same tag number, do nothing */
    FIg_set_text(FormPtr, MsgLabel," ");
    if(Original != 1 || Behaviour == 0)
     {
      /* Dont free it the next time */
      *Mode = *Mode | VDTagNumberDontFreePrev;
     }
    *msg = MSSUCC;
    return OM_S_SUCCESS;
   }

  /* the previous tag number is: PreTagNumber */
  if(PreTagNumber != NULL)
   {
    if(sscanf(PreTagNumber, "%5d", &PrevIdNum) != 1)
     {
      PrevIdNum = -1;
      /* FIg_set_text(FormPtr, MsgLabel,"The Tag number was not locked"); */
     }
   }

  if(sscanf(IdString, "%5d", &IdNum) != 1)
   {
    /* ASCII or NULL */
    IdNum = -1;
    if(IdString[0] == '\0') 
     {
      FIg_set_text(FormPtr, MsgLabel,"No tag number defined");    
     }
    else 
     {
      FIg_set_text(FormPtr, MsgLabel,"ASCII Tag number => NO UNICITY CHECK");    
     }
    /* If the system name has changed juste delete the tag else modify */

    if(*Mode & VDTagNumberModif)
     {
      /* Do not allow to not be inconsistant */
      FIg_set_text(FormPtr, MsgLabel, "Select a number");    
      if(TagNumber) strcpy(TagNumber, PreTagNumber);
      FIg_set_text(FormPtr, Label, PreTagNumber);
     }
    else if(PrevIdNum != -1 && !(*Mode & VDTagNumberDontFreePrev))
     {
      FIg_set_text(FormPtr, MsgLabel,"Free the previous tag number");
      VDUnLockID(PreSystem, Category, PrevIdNum);
      FIg_set_text(FormPtr, MsgLabel,"");
     }
   }
  else
   {
    /* We got a number */
    if(*Mode & VDTagNumberModif)
     {
      FIg_set_text(FormPtr, MsgLabel,"");
      *Mode = *Mode  & ~VDTagNumberDontFreePrev;
     }
    else
     {	
      if(PrevIdNum >=0 && (!(*Mode & VDTagNumberModel)) && !(*Mode & VDTagNumberDontFreePrev))
       {
        /* We have to free the previous one */
        FIg_set_text(FormPtr, MsgLabel,"Free the previous tag number");
        VDUnLockID(PreSystem, Category, PrevIdNum);
        FIg_set_text(FormPtr, MsgLabel,"");
       }
      *Mode = *Mode  & ~VDTagNumberDontFreePrev;
     }

    if(*Mode & VDTagNumberModel)
     {
      /* Just verify if a schematic one has been defiend */
      FIg_set_text(FormPtr, MsgLabel,"Verifying the tag number...");    
      if( VDVerifyIfIDisUsed(System, Category, IdNum) == VDS_ID_IS_USED)
       {
        FIg_set_text(FormPtr, MsgLabel, "A schematic component uses the same tag number");    
       }
      else
       {
        FIg_set_text(FormPtr, MsgLabel, "");    
       }      
     }
    else if(Original == 1)
     {
      /* verify and Lock it in case of not locked */
      FIg_set_text(FormPtr, MsgLabel,"Verifying and lock the tag number...");    
      if(VDLockSelectedID(System, Category, IdNum) == 1)
       {
        FIg_set_text(FormPtr, MsgLabel," ");    
        *Mode = *Mode  & ~VDTagNumberDontFreePrev;
        if(*Mode & VDTagNumberModif)
         {
	  /* We perform a modif only when it is locked */
	  if(strcmp(PreSystem, System) == 0)
           {
            FIg_set_text(FormPtr, MsgLabel,"Change tag number");
            VDModifyID(System, Category, PrevIdNum, IdNum);
           }
          else if(PrevIdNum != -1 && !(*Mode & VDTagNumberDontFreePrev))
           {
            /* Unlock the previous one ... because no management of dif system */
            FIg_set_text(FormPtr, MsgLabel,"Free the previous tag number");
            VDUnLockID(PreSystem, Category, PrevIdNum);
	   }
          FIg_set_text(FormPtr, MsgLabel,"");
          *Mode = *Mode | VDTagNumberDontFreePrev;
         }
       }
      else
       {
        FIg_set_text(FormPtr, MsgLabel, "WARNING: Tag number already used!!!");    
        /* When the user tries a tag which is used, we always reinit the list */
        *Mode = *Mode | VDTagNumberGetNewList | VDTagNumberDontFreePrev;
        if(*Mode & VDTagNumberModif)
         {
	  /* Cannot accept in modification to allow this */
	  FIg_set_text(FormPtr, MsgLabel, "ERROR: Tag number already used");    
          if(TagNumber) strcpy(TagNumber, PreTagNumber);
          FIg_set_text(FormPtr, Label, PreTagNumber);
	 }
       }
     }
    else if(Original != 1)
     {
      if(!(VRGetRefAutoID(FormPtr, Label, MsgLabel, TRUE, System, Category ) & 1))
       {
        FIg_set_text(FormPtr, MsgLabel,"Error getting the referenced components");
        for(row=0;row<10;row++) VDfld_set_list_text(FormPtr, Label, row, col, "", sel_flag );
        *Mode = *Mode | VDTagNumberGetNewList | VDTagNumberDontFreePrev;
        *msg = MSFAIL;
        return OM_S_SUCCESS;
       }
     }
   }
  if(Original != 1 || Behaviour == 0)
   {
    /* Dont free it the next time */
    *Mode = *Mode | VDTagNumberDontFreePrev;
   }
  *msg = MSSUCC;
  return OM_S_SUCCESS;
 }
*msg = MSFAIL;
return OM_W_ABORT;
}

/* TBD :

	*. try to avoid access to DB to display the description of the
	   original at the time of notification .
	
  Note  : AutoIds are used for LSQ number in I/ROUTE. So please do 
	  consider about meaningful messages( context is not always
	  tagnumber in case of I/ROUTE , it is also LSQ some times ).
	  So the generic function at VDS levelmust be able to
	  distinguish both these cases.
**/

IGRint	VRGetRefAutoID( FormPtr, GadNum, MsgFldNum, 
			bMode, SysName, Cat )
	IGRchar		*FormPtr;	/* I : form ptr		*/
	IGRint		GadNum;		/* I : gad num		*/
	IGRint		MsgFldNum;	/* I : message field num to
					       display the messages
					      0 : displays in the error
						field
					*/
	IGRboolean	bMode;		/* I : mode 0 : init
						    1 : process the string
					*/
	IGRchar		*SysName;	/* I : system name	*/
	IGRint		Cat;		/* I : category		*/
{
	IGRint		status=OM_S_SUCCESS;
	IGRint		i;

	/*A validate the input arguments */
	if( !FormPtr || GadNum < 0 || MsgFldNum < 0 ||
		!SysName )
		return	OM_E_INVARG;
	
	/*A initialization */
	if ( !bMode )
	{
	  IGRint		NbIds=0, NbRows=0;
	  struct id_desc	*pIdDesc=NULL;

	  /*A get all the original list ( checked in to Database ) */
          FIg_set_text(FormPtr, MsgFldNum,
		"Getting the list of original components");
	  status = VDGetIDDescription( SysName, Cat, &NbIds,
			&pIdDesc );
          FIg_set_text(FormPtr, MsgFldNum,"");
	  if ( !(status&1) )
	  {
	     if ( !MsgFldNum )
	     {
		ex$message( field   = ERROR_FIELD,
			in_buff = "Failed to get tag number list" );
	     } else FIg_set_text( FormPtr, MsgFldNum,
			"Failed to get tag number list" );

	    if( pIdDesc ) free( pIdDesc );
	    goto error;
	  }

	  /*A display error message if no used ids found */
	  if ( !NbIds )
	  {
	     if ( !MsgFldNum )
	     {
		ex$message( field   = ERROR_FIELD,
			in_buff = "No elements to refer : list not set" );
	     } else FIg_set_text( FormPtr, MsgFldNum,
			"No elements to refer :list not set " );
	     goto success;

	  }/* num of ids zero */

	  /*A get the num rows */
	  for ( i=0; i<NbIds; i++ )
	    if( pIdDesc[i].original == 1 )
		NbRows++;
	 
	  /*A set the max num of rows */
	  FIfld_set_list_num_rows( FormPtr, GadNum, 0, NbRows );

	  for ( i=0; i<NbIds; i++ )
	    if( pIdDesc[i].original == 1 )
		VDfld_set_list_text( FormPtr, GadNum, i, 0, 
			pIdDesc[i].tag_number, FALSE);

	  /*C free the memory */
	  if( pIdDesc ) free( pIdDesc );

	}
	else /* at the time of notification */
	{
	  IGRint		NbIds=0, NbRows=0;
	  struct id_desc	*pIdDesc=NULL;
	  IGRdouble		dValue;
	  IGRchar		*sEnd=NULL;
	  IGRboolean		bFound=FALSE, bIsLocked=FALSE;
	  extern IGRdouble	strtod ();
	  IGRint		SelFlag, j;
	  IGRchar		ListText[VD_ID_STRING_SIZE],
				IdStr[VD_ID_STRING_SIZE];

	  /*A get the tag number */
	  FIg_get_text( FormPtr, GadNum, IdStr );

	  dValue = strtod ( IdStr, &sEnd);

	  /*A ascii */
	  if ( strlen( sEnd ) )
	  {
	     if ( !MsgFldNum )
	     {
		ex$message( field   = ERROR_FIELD,
			in_buff = "Tag Num is ASCII => No UNICITY CHECK" );
	     } else FIg_set_text( FormPtr, MsgFldNum,
			"Tag Num is ASCII => No UNICITY CHECK" );
	     goto success;
	  }

	  /*A negative number check or higher number */
	  if( dValue <= 0 || dValue > 10000 )	
	  {
	     if ( !MsgFldNum )
	     {
		ex$message( field   = ERROR_FIELD,
			in_buff = "Inavlid Tag Number" );
	     } else FIg_set_text( FormPtr, MsgFldNum,
			"InValid Tag Number" );
	     goto success;
	  }

	  /*A get the number */
	  FIfld_get_list_num_rows ( FormPtr,GadNum, 0,&NbRows );

	  /*A verify the keyed in or selected tag num wrt assoc the list */
	  for ( i=0; i<NbRows; i++ )
	  {	  
	     FIfld_get_list_text( FormPtr, GadNum, i, 0,
			13, ListText, &SelFlag );
	     
	     if( (int)dValue == (int)atoi( ListText ) )
	     {
		bFound = TRUE;

	  	/*A get all the original list ( checked in to Database ) */
	        NbIds=0;
	  	status = 
		VDGetIDDescription( SysName, Cat, &NbIds, &pIdDesc );

		if ( !(status&1) ) {
			if( pIdDesc ) free( pIdDesc );
			goto error;
	  	}

		/*A process the list */
		for ( j=0; j<NbIds; i++ )
		if( pIdDesc[j].original == 1 && 
			(int)dValue == (int)atoi(pIdDesc[j].tag_number) )
		{
		  /*A display the description */
	          if ( !MsgFldNum )
	          {
		    ex$message( field   = ERROR_FIELD,
			in_buff = pIdDesc[j].descript );

		  } else FIg_set_text( FormPtr, MsgFldNum, 
				pIdDesc[j].descript );
		  break;

	        }

		if( pIdDesc ) free( pIdDesc );

		break;
	
	     } /* end found in the list */

	  } /* end check in the list */
	
	  if( bFound ) goto success;

	  if( !NbRows || !bFound )
	  {
		status = VDVerifyIfIDisUsed( SysName, Cat, (int)dValue );

	  	if ( status == VDS_ID_IS_USED ) bIsLocked = TRUE;
	  }

	  if ( bIsLocked )
	  {
	     if ( !MsgFldNum )
	     {
		ex$message( field   = ERROR_FIELD,
		in_buff = "Original is not yet posted to DB" );
	     } else
		FIg_set_text( FormPtr, MsgFldNum, 
		 "Original is not yet posted to DB");
	  } 
	  else 
	  {
	     if ( !MsgFldNum )
	     {
		ex$message( field   = ERROR_FIELD,
		  in_buff = "Invalid reference : original not existing" );
	     } else
		FIg_set_text( FormPtr, MsgFldNum, 
			"Invalid reference : original not existing");
	  }

	} /* end form_notification */

success:
	return 	OM_S_SUCCESS;

error :
	return	status;
}
