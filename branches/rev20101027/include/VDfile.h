/* $Id: VDfile.h,v 1.4 2001/08/12 02:19:10 paul_noel Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdfile/VDfile.h
 *              Supports operations in the vds/vdfile/
 *
 * Description: Definitions for basic generic file browser
 *
 * Dependencies:
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/16/01  pn      Creation
 ***************************************************************************/


#ifndef VDfile_include
#define VDfile_include


/* define the File control form gadgets */
#define VDTR_FILE_B_ACCEPT     1
#define VDTR_FILE_B_CANCEL     4
#define VDTR_FILE_TITLE       13
#define VDTR_FILE_NAME        11
#define VDTR_FILE_DIR         18
#define VDTR_FILE_TYPE        16
#define VDTR_FILE_T_NAME      12
#define VDTR_FILE_T_DIR       21
#define VDTR_FILE_T_TYPE      17
#define VDTR_FILE_L_NAME      20
#define VDTR_FILE_L_DIR       19
#define VDTR_FILE_T_PATHS     24
#define VDTR_FILE_B_SAVE      26
#define VDTR_FILE_B_DEL       27
#define VDTR_FILE_B_FSAVE     28
#define VDTR_FILE_B_FDEL      29

/* -----------------------------------------------
 * Holds info needed to access the data from the form
 */
typedef struct {
  char    fdir[1023]; 
  char    fname[80];
  char    ftype[80];
  char    sFile[1023];
  char    lFile[1023];
  int     ftog;
  int     fbrowse;
} TVDfileInfo;

/*****************************************************
 *
 * DRIVE the Whole Thing 
 * Runs the entire Operation in one location
 * No input values are required It will operate
 * more to user satisfaction if these values are 
 * set to the user needs.
 * all values are output and all values are input
 * It is most likely that the user will want to set 
 * the values so:
 * *Flag == 1;  This turns off user selection of File Types
 *              Use this option if you want to limit the selections
 * *Path is most likely better if it has no value
 *       it is highly recommended that this value be set to '\0'
 *       This is a combination of the Dir and the Name.
 *
 *      *** Manage the list of path choices ***
 * *sFile is a server file path for the list of files gadget
 *       it has a default path, it is not required
 * *lFile is the local file path for the list of files gadget
 *       it has a default path, it is not required
 *     *** Done with list of path choices ***
 *
 * *Dir should be set to the starting directory for browsing
 * *Name probably should have no initial value
 *       it can have a value but is likely to result in no value
 * *Type This should be set to all of the selection filters at 
 *       one time.  If Flag != 1 it will not be limited to this filter set
 *       The user selection is limited to this set if an entry is made
 *       Entries should look like standard file filtering phrases with 
 *       '*' for wildcards and any text format as desired.
 *       '*.*' fetches any file name which has a extension
 *       '*'   fetches any file name 
 *       '*.txt' will fetch all files with the extension '.txt'
 *       '.txt' will only fetch a file named '.txt'
 *       '*12.*txt'  will fetch any file name with the prefix ending in '12' and any 
 *                   extension ending in 'txt'  
 *       There is no limit to the sequencing of these filters.
 *       It is a valid filter for example to say 'A.12*.B*.x.*txt*'  It might not be useful
 *       but the filter is valid.
 * *Selected  This is so that you can know if the selection was made on the form or if you 
 *            should ignore the return values
 * LocalDir is used to set a flag to lookup and limit input to the local directory
 *          if(LocalDir != 0) sets Dir to the vds local directory
 *          if(LocalDir == -1) will only look in the vds local directory
 *          if(LocalDir == 0) will use the Dir sent in or the default as
 *          the case may be. IS NOT REQUIRED!
 *
 *
 * ABSOLUTELY NO VALUES ARE REQUIRED!
 *
 * BUT IF YOU DON'T SEND THE VARIABLE ------
 *        YOU WILL NOT GET THAT VARIABLE'S VALUES BACK.
 *
 *****************************************************/
extern IGRint VDfileBrowseFiles __((IGRchar *Dir,
				    IGRchar *Name, 
				    IGRchar *Type, 
				    IGRchar *Path, 
				    IGRchar *sFile,
				    IGRchar *lFile,
				    IGRint  *Flag,
				    IGRint  *Selected,
				    IGRint  *LocalDir));

#omdef vdfile$BrowseFiles(Dir      = NULL,
			  Name     = NULL,
			  Type     = NULL,
			  Path     = NULL,
			  sFile    = NULL,
			  lFile    = NULL,
			  Flag     = 0,
			  Selected = 0,
			  LocalDir = 0);


VDfileBrowseFiles((Dir) ,
		  (Name),
		  (Type),
		  (Path),
		  (sFile),
		  (lFile),
		  (Flag),
		  (Selected),
		  (LocalDir)) 
#endomdef 

/************************************************
 * 
 * Get the current local path and file etc
 * may be pretty useful because it fetches 
 * the Unix path and file that corresponds to
 * the currently active file 
 *
 ************************************************/
extern IGRint VDfileGetLocalPath __((IGRchar *path, 
				     IGRchar *dir, 
				     IGRchar *file));
#omdef vdfile$GetLocalPath(path,
			   dir,
			   file);
VDfileGetLocalPath((path),
		   (dir),
		   (file))

#endomdef


/*****************************************************
 *
 * Starts up the file browser
 * fully protected with default input values
 * no user imput is required
 * prototyped in VDfile.h as 
 * VDfile$BrowseBegin with all input pointers 
 * default to null! 
 * will ignore the dir and name if the path is supplied
 *
 *****************************************************/
extern IGRint VDfileBrowseBegin __((IGRchar *dir,
				    IGRchar *name,
				    IGRchar *type,
				    IGRchar *path,
				    IGRchar *sFile,
				    IGRchar *lFile,
				    IGRint *flag));

#omdef vdfile$BrowseBegin(dir   = NULL,
			  name  = NULL,
			  type  = NULL,
			  path  = NULL,
			  sFile = NULL,
			  lFile = NULL,
			  flag  = 0);

VDfileBrowseBegin((dir),
		  (name),
		  (type),
		  (path),
		  (sFile),
		  (lFile),
		  (flag))

#endomdef

/*****************************************************
 *
 * Set up the structure data from user input
 * sets fileInfo and defaults if the user
 * sends in blank data
 * This is for the user to reset the form settings 
 * This is because the form can remember and is used to
 * make it forget the older settings.
 *
 *****************************************************/
extern IGRint VDfileSetFormData __((IGRchar *dir,
				     IGRchar *name,
				     IGRchar *type,
				     IGRchar *path,
				     IGRint  *flag));

#omdef vdfile$SetFormData(dir  = NULL,
			  name = NULL,
			  type = NULL,
			  path = NULL,
			  flag = 0);


VDfileSetFormData((dir),
		  (name),
		  (type),
		  (path),
		  (flag))

#endomdef

/*****************************************************
 *
 * Retrieves the data for the user from the form after 
 * it has been accepted and deleted
 * the function return value is the IS_ACCEPTED
 *
 *****************************************************/
extern IGRint VDfileGetFormData __((IGRchar *dir,
				     IGRchar *name, 
				     IGRchar *type,
				     IGRchar *path,
				     IGRint  *flag,
				     IGRint  *done));

#omdef vdfile$GetFormData(dir  = NULL,
			  name = NULL,
			  type = NULL,
			  path = NULL,
			  flag = 0,
			  done = 0)

VDfileGetFormData((dir),
		  (name),
		  (type),
		  (path),
		  (flag),
		  (done))
#endomdef


  /*
   * A bunch of useful functions exist in this operation which may be of 
   * considerable use to others in other locations 
   * most of the operations are not even form specific
   * if they contain (char *form) type declarations they can be used almost 
   * anywhere a form exists
   * gadgets are also refed this way.
   * see VDfileBrowse.I for those functions which are based on forms
   *
   *
   *
   * Else the following data handling functions may be quite useful outside of this 
   * set of operations 
   */

  /* 
   * Useful Operations for handling data 
   */
/*****************************************************
 *
 * check string against filter
 * no memory allocation
 * This operation allows the user to submit a filter string which may 
 * include '*' wildcards of an unlimited number and an unlimited number of 
 * text characters in the mix and get back if the 
 * name string is a match to the filter
 * if you are using a file name or such to match to you 
 * will need the vdfile$FilterSplit operation to make this useful
 *
 *****************************************************/
extern IGRint VDfileIsFilterMatch __((IGRchar *filter,
				       IGRchar *name));
#omdef vdfile$IsFilterMatch(filter,
			    name)
VDfileIsFilterMatch((filter),
		    (name))
#endomdef

/*****************************************************
 *
 * split the filters around the last '.'
 * no memory allocation 
 * this splits up a filename for comparison 
 * use the vdfile$IsFilterMatch operation to 
 * to compare each part of the filter to each part of the 
 * file name.  Both names and filters use this method 
 * of splitting up the names for comparison
 *
 *****************************************************/
extern IGRint VDfileGetFilterSplit __((IGRchar *filter,
			     IGRchar *frontFilter,
			     IGRchar *backFilter));
#omdef vdfile$GetFilterSplit(filter,
			     frontFilter,
			     backFilter)
VDfileGetFilterSplit((filter),
		     (frontFilter),
		     (backFilter))
#endomdef

/*****************************************************
 *
 * Gets the Dir Info /no hidden files/
 * does not display anything just gets the data!
 * allocates memory!
 * fetches starting at the specified dir_name 
 * finds only one level below
 * could be most incredibly useful!
 *
 *****************************************************/
  extern IGRint VDfileGetDirInfo __((IGRchar *dir_name,
				    IGRchar ***dirList,
				    IGRchar ***fileList, 
				    IGRint *dirCnt, 
				    IGRint *fileCnt,
				    IGRint *typeFlag));

#omdef vdfile$GetDirInfo(dir_name,
			 dirList,
			 fileList,
			 dirCnt,
			 fileCnt,
			 typeFlag)

VDfileGetDirInfo((dir_name),
		 (dirList),
		 (fileList),
		 (dirCnt),
		 (fileCnt),
		 (typeFlag))

#endomdef

/*****************************************************
 *
 * Filter the fileNames to match the input filter string
 * this string can be pretty simple or pretty complex
 * the delimit between any filter and its individual filters 
 * is a space.
 * ALLOCATES MEMORY (outList)
 * this allows you to handle a list of items to filter
 * this automates the process in the filtering  and includes 
 * the split operations above
 * requires a list of names to be supplied for filtering
 * requires a filter as well.  This can be complex filter including
 * multiple filters in one line
 * the in list is a list of file names (***) pointer
 *
 *****************************************************/
extern IGRint VDfileFilterNames __((IGRchar   *filter,
				     IGRchar  **inList,
				     IGRchar ***outList,
				     IGRint    *inCnt,
				     IGRint    *outCnt));


#omdef vdfile$FilterNames(filter,
			  inList,
			  outList,
			  inCnt,
			  outCnt)

VDfileFilterNames((filter),
		  (inList),
		  (outList),
		  (inCnt),
		  (outCnt))
#endomdef

/*****************************************************
 *
 * Clip the blanks on the front of a string
 * could be really useful at times 
 * just removes all the leading blank spaces from a string
 *
 *****************************************************/
extern IGRint VDfileClipFrontSpaces __((IGRchar *buffer));

#omdef vdfile$ClipFrontSpaces(buffer)

VDfileClipFrontSpaces((buffer))

#endomdef

/*****************************************************
 *
 * count the number of spaces in the front of a string
 * returns -1 if the string is blank.
 * returns -1 if the string is all spaces.
 * returns the count of spaces befor the first non-space
 * another fun toy that might be really useful at times
 *
 *****************************************************/
extern IGRint VDfileCountOffset __((IGRchar *dirPath));

#omdef vdfile$CountOffset(dirPath)

VDfileCountOffset((dirPath))

#endomdef

/*****************************************************
 *
 * Tells if a string is really a path
 * the function return value is the useful part
 *
 *****************************************************/
extern IGRint VDfileIsPath __((IGRchar *path));

#omdef vdfile$IsPath(path)

VDfileIsPath((path))

#endomdef

  /* some file browser operations */

extern IGRint VDfileInitForm __((char *form));
 
#omdef vdfile$InitForm(form)

VDfileInitForm((form))
#endomdef

extern IGRint VDfileFormNotification __((char *form));

#omdef vdfile$FormNotification(form)

VDfileFormNotification((form))
#endomdef 

extern IGRint VDfileSetForm __((char *form));
#omdef vdfile$SetForm(form)
VDfileSetForm((form))
#endomdef

extern IGRint VDfileNotifyForm __((char   *form,
				   IGRint  gadget));
#omdef vdfile$NotifyForm(form,
			 gadget)
VDfileNotifyForm((form),
		 (gadget))
#endomdef

#endif 
