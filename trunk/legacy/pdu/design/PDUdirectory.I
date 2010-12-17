class implementation COpdu;
#include	<unistd.h>
#include	<PDUintdef.h>
#include	<PDUint.h>
#include	<maerr.h>
#include	<madef.h>
#include	<exdef.h>
#include	<exmacros.h>
#include	<godef.h>
#include	<OMminimum.h>
#include	<OMlimits.h>
#include	<OMerrordef.h>
#include	<igetypedef.h>
#include	<igrtypedef.h>
#include	<gr.h>
#include	<igr.h>
#include	<igrdp.h>
#include	<go.h>
#include	<DItypedef.h>
#include	<DIprims.h>
#include	<DIdef.h>
#include	<DImacros.h>
#include	<DIglob.h>
#include        <PDUerror.h>
#include	<PDUextdef.h> 
#include	<PDUintdef.h> 
#include        <string.h>

extern struct PDUrefresh	*refresh;

/* BETH added declaration of debug flag */
extern int	PDM_debug_on;

/****************************************************************************

Document:	PDUcheck_uniqueness

Description:

           This function checks to see if a alt tag no 
           is unique in the specified directory structure. 
Algoritm:
        1. Get all the s entries under the parts directory.
        2. For each s entry, check to see if the alt tag no 
           exists under the s entry.
        3. if it does, return PDM_E_DUP_ALTTAGNO.
        4. if not, return PDM_S_SUCCESS.

Return Status:
	PDM_S_SUCCESS	-	Success
	Other Status	-	other codes returned by di$find, di$free,  
                                and DIstmocpy macros.
	PDM_E_DUP_ALTTAGNO -    Duplicate alt tag no.	

Notes:
       if alt tag name is not unique, a message will be displayed to the
       user to change the alt tag name. 
History:
        11/4/90	      Jamal Shakra	Created

*****************************************************************************/


IGRint	PDUcheck_uniqueness (alt_tag_value,osnum)

  OMuword	osnum;			/* i - object space number */
  IGRchar       *alt_tag_value;         /* i - hold alt tag value */
  {
  IGRint	status = PDM_S_SUCCESS;	/* return status */
  IGRint        entry_count;		/* count of all s entries */
  IGRint        tmp_entry_count;	/* count of all s entries */
  IGRchar       dir_path[DI_PATH_MAX];     /* holds path name */
  IGRchar       **part_ids;             /* holds all s entries */
  IGRchar       **tmp_part_ids;         /* holds all s entries */
  IGRint        i;                      /* for loop index */
  IGRchar       cat_path[DI_PATH_MAX];     /* catpartrev path */
  IGRchar	catpartrev[100];	/* holds catalog part rev */
  IGRchar       tmp_path[DI_PATH_MAX];     /* temp path */
  IGRchar       value_path[DI_PATH_MAX];   /* holds dir value search path */
  IGRint        stat;                   /* status for di$find macro */
  IGRchar       *old_alt_tag_value = NULL; /* old alt tag value */
  IGRint        update_same;            /* flag to indicate same part update */


  _pdm_debug("In the function PDUcheck_uniqueness", 0);
  _pdm_debug("tag_value at entry = <%s>",alt_tag_value);

  /* if tag_value = "", return PDM_S_SUCCESS */
  if (strcmp(alt_tag_value,"") == 0)
     {
      _pdm_debug("alt tag no is NULL",0);
      return(PDM_S_SUCCESS);
     }

  sprintf(catpartrev,"%s!%s!%s", refresh->rev_catalog, refresh->rev_partid,
	  refresh->rev_revision);
  
  /* get array of s  (cat!part!rev) entries in specified directory */
  status = DIstmocpy(dir_path,PDU_MAIN_DIR,PDU_PARTS_DIR,"",NULL,osnum); 
  _pdm_status ("DIstmocpy", status);

  if ( 1&status )
     {
	status = di$strcpy(to = cat_path, from = dir_path);
	_pdm_status ("di$strcpy", status );

        status = DIstmcat(cat_path, catpartrev, "", NULL);
	_pdm_status ("DIstmcat",status );

	_pdm_debug("abs cat path = <%s>", cat_path);


       /* get all s entries into the array part_ids */
       status = di$find(
                        start_dir = dir_path,
                        regexp = "*!*!*",
                        lines = &part_ids,
                        grids = NULL,
                        ptr = &entry_count,
                        max_level = 1
                       );
       _pdm_status("di$find",status);

       if (PDM_debug_on)
         stat = di$report_error(sts = status,
                              comment = "di$find 1 status"); 

       if (status != DIR_S_SUCCESS) 
          return(PDM_S_SUCCESS); /* dir not found, ok to add any alt value */

       _pdm_debug("entry_count = <%d>",entry_count);

       /* loop through each s entry checking uniqueness */
       update_same = FALSE; 
       for (i = 0;i < entry_count; ++i) 
          {
	    if (PDM_debug_on)	   
             printf("PDU -- for i = %d\n ",i);
            _pdm_debug("part_ids[i] = <%s> ",part_ids[i]);

            /* if same part, see if alt tag no needs updating */
	    if (strcmp(part_ids[i],cat_path) == 0)
               {
                /* extract old alt tag value from dir structure */
                sprintf(value_path,"%s:%s",catpartrev,"alt_tag");
                status = PDUget_dyn_attr_value(value_path,
                                               osnum,
                                               PDU_ALTTAG_DIR,
                                               &old_alt_tag_value);
                if (status != PDM_S_SUCCESS) 
                   {
                    _pdm_debug("PDUget_dyn_attr_value failed",0);
                    return(status);
                   }

                if (strcmp(old_alt_tag_value,alt_tag_value) != 0) 
                   {
                    /* set a flag to indicate the need for update, still 
                       need to check uniqueness of new value of alt tag no 
                       across all other <cat!part!rev> directories. */   

                    update_same = TRUE;
                    continue;
                   }

                 else
	            continue;
            }

            /* construct full search path */
            sprintf(tmp_path,"%s%s:", part_ids[i],PDU_ALTTAG_DIR);
            _pdm_debug("full search path = <%s>",tmp_path);
            status = di$find (
                               start_dir = tmp_path,
                               regexp = alt_tag_value,
                               lines = &tmp_part_ids,
                               ptr = &tmp_entry_count,
                               max_level = 1
                                    );
            _pdm_status("di$find",status);

            if (PDM_debug_on)
            stat = di$report_error(sts = status, comment = "di$find 2 status"); 
                  
            if (status == DIR_S_SUCCESS)
              {
                _pdm_debug("duplicate alt tag no ",0);
                di$free (lines = part_ids,count = entry_count);
                return(PDM_E_DUP_ALTTAGNO);
              }
            }

            /* check to see if update same part alt tag no flag is set */
            if (update_same)
               {
                    status = PDUupdate_dir_value(catpartrev,
                                                 osnum,
                                                 PDU_ALTTAG_DIR,
                                                 old_alt_tag_value,
                                                 alt_tag_value);
                    if (status != PDM_S_SUCCESS) 
                       {
                        _pdm_debug("PDUupdate_dir_value failed",0);
                        return(status);
                       }
                    /* reset flag */
                    update_same = FALSE;
               }

            di$free (lines = part_ids,count = entry_count);
            status = PDM_S_SUCCESS; 
      }
  return (status);
  }

/****************************************************************************

Document:	PDUget_tag_no

Description:
        This function gets the tag value for the specified part from 
        the part placement directory structure.

Return Status:
	PDM_S_SUCCESS	-	Success
	Other Status	-	other codes returned by di$find  
                                and di$free macros.
		

History:
        11/4/90	      Jamal Shakra	Created

*****************************************************************************/


IGRint	PDUget_tag_no (tag_value,osnum,catalog,partid,revision)
/* begin BETH pass in the catalog, partid, revision */
/*
IGRint	PDUget_tag_no (tag_value,osnum)
*/
  IGRchar       **tag_value;            /* i/o - hold tag value */
  OMuword	osnum;			/* i - object space number */
  IGRchar	*catalog;		/* i - catalog */
  IGRchar	*partid;		/* i - part num */
  IGRchar	*revision;		/* i - revision */
  {
  IGRint	status = PDM_S_SUCCESS;	/* return status */
/* begin BETH changed to character array */
  IGRchar       s[100];                 /* holds <cat!part!rev> */
/*
  IGRchar       *s;                     
*/
/* end BETH */
  IGRint        entry_count;		/* count of all s entries */
  IGRchar       dir_path[DI_PATH_MAX];     /* holds path name */
  IGRchar       **tags;                 /* holds tag values */


  _pdm_debug("In the function PDUget_tag_no", 0);
/* begin BETH need to check if part already has a tag no. */
  /* get <cat!part!rev> from refresh area */
/*
  sprintf(s,"%s!%s!%s",
                    refresh->rev_catalog,
                    refresh->rev_partid,
                    refresh->rev_revision);
*/
/* use the catalog partid revision passed in */
  sprintf(s,"%s!%s!%s",catalog,partid,revision);
  _pdm_debug("<cat!part!rev> = <%s>",s);
/* end BETH */

/* begin BETH changed to take out tag_gen directory and added part path */
/*
  status = DIstmocpy(dir_path,PDU_MAIN_DIR,PDU_PARTS_DIR,PDU_TAGGEN_DIR,
                     PDU_TAGCNT_DIR,"",NULL,osnum); 
  _pdm_status ("DIstmocpy", status);
*/
  status = DIstmocpy(dir_path,PDU_MAIN_DIR,PDU_PARTS_DIR,s,PDU_TAGNO_DIR,"",
			NULL,osnum); 
  _pdm_status ("DIstmocpy", status);

  _pdm_debug ("dir_path = <%s>",dir_path);

/* end BETH */
  if ( 1&status )
     {
       /* get the tag value for the part */
       status = di$find(
                        start_dir = dir_path,
                        regexp = "*",
                        lines = &tags,
                        grids = NULL,
                        ptr = &entry_count,
                        max_level = 1,
                        deep = NULL,
                        options = NULL);

       if (status == DIR_S_SUCCESS) 
          {
/* begin BETH changed to get tag no */
           status = PDUextract_dir_value(tags[0],PDU_TAGNO_DIR,tag_value);
/*
           status = PDUextract_dir_value(tags[0],PDU_TAGCNT_DIR,tag_value);
*/
/* end BETH */
           if (status == PDM_S_SUCCESS)
              {
               /* free up tags  and entry_count */
               di$free (lines = tags,count = entry_count);
               status = PDM_S_SUCCESS; 
              }
          }
       else
          {
           /* free up tags  and entry_count */
           di$free (lines = tags,count = entry_count);

/* begin BETH added to get the next valid tag */
	   /* get the next valid tag to assign */
	   status = DIstmocpy(dir_path,PDU_MAIN_DIR,PDU_PARTS_DIR,
                     PDU_TAGCNT_DIR,"",NULL,osnum); 
	   _pdm_status ("DIstmocpy", status);

	   _pdm_debug ("dir_path = <%s>",dir_path);

           /* get the tag value for the part */
           status = di$find(
           	             start_dir = dir_path,
                	     regexp = "*",
                             lines = &tags,
                             grids = NULL,
                             ptr = &entry_count,
                             max_level = 1,
                             deep = NULL,
                             options = NULL);

	   if (status == DIR_S_SUCCESS) 
             {
	       status = PDUextract_dir_value(tags[0],PDU_TAGCNT_DIR,tag_value);

	       if (status == PDM_S_SUCCESS)
                 {
                   /* free up tags  and entry_count */
                   di$free (lines = tags,count = entry_count);
                   status = PDM_S_SUCCESS; 
                 }
            }
          else
            {
              /* free up tags  and entry_count */
              di$free (lines = tags,count = entry_count);
	    }
/* end BETH */
          }
     }
  return (status);
  }

/****************************************************************************

Document:	PDUget_alttag_no

Description:
        This function gets the alt tag value for the specified part from 
        the part placement directory structure.

Return Status:
	PDM_S_SUCCESS	-	Success
	Other Status	-	other codes returned by di$find  
                                and di$free macros.
		

History:
        11/4/90	      Jamal Shakra	Created

*****************************************************************************/
IGRint	PDUget_alttag_no (alt_tag_value,osnum,catalog, partid, revision)

/* BETH added catalog, partid, and revision as parameters */
/*
IGRint	PDUget_alttag_no (alt_tag_value,osnum)
*/
  IGRchar       **alt_tag_value;        /* i/o - hold alt tag value */
  OMuword	osnum;			/* i - object space number */
/* BETH added */
  IGRchar	*catalog;		/* i - catalog */
  IGRchar	*partid;		/* i - part number */
  IGRchar	*revision;		/* i - revision */
  {
  IGRint	status = PDM_S_SUCCESS;	/* return status */
  IGRchar       s[100];                 /* holds <cat!part!rev> */
  IGRint        entry_count;			/* count of all s entries */
  IGRchar       dir_path[DI_PATH_MAX];     /* holds path name */
  IGRchar       **alt_tags;             /* holds alt tag value */
  IGRint        stat;                   /* holds status of di$report macro */


  _pdm_debug("In the function PDUget_alttag_no", 0);

  /* get <cat!part!rev> from refresh area */
/* BETH changed to use catalog partid and revision passed in */
/*
  sprintf(s,"%s!%s!%s",
                    refresh->rev_catalog,
                    refresh->rev_partid,
                    refresh->rev_revision);
*/
  sprintf(s,"%s!%s!%s",catalog,partid,revision);
  _pdm_debug("<cat!part!rev> = <%s>",s);

/* begin BETH changed to take out tag_gen directory */
/*
  status = DIstmocpy(dir_path,PDU_MAIN_DIR,PDU_PARTS_DIR,PDU_TAGGEN_DIR,
                     s,PDU_ALTTAG_DIR,"",NULL,osnum); 
  _pdm_status ("DIstmocpy", status);
*/
  status = DIstmocpy(dir_path,PDU_MAIN_DIR,PDU_PARTS_DIR,s,PDU_ALTTAG_DIR,"",
			NULL,osnum); 
  _pdm_status ("DIstmocpy", status);
/* end BETH */
  _pdm_debug ("dir_path = <%s>",dir_path);

  if ( 1&status )
     {
       /* get the alt tag value for this s directory if it exists */
       status = di$find(
                        start_dir = dir_path,
                        regexp = "*",
                        lines = &alt_tags,
                        grids = NULL,
                        ptr = &entry_count,
                        max_level = 1,
                        deep = NULL,
                        options = NULL);
/* BETH check debug flag */
       if (PDM_debug_on)
       stat = di$report_error(sts = status, comment = "di$find status");

       if (status == DIR_S_SUCCESS) 
       /* alt tag value was found */
          {
           status = PDUextract_dir_value(alt_tags[0],PDU_ALTTAG_DIR,
                                         alt_tag_value);
           if (status == PDM_S_SUCCESS)
              {
               /* free up alt_tags  and entry_count */
               di$free (lines = alt_tags,count = entry_count);
		
	       status = PDM_S_SUCCESS;
              }
          }

       else
       /* alt tag has not been created yet, default alt tag value  to "" */
          {
           PDUfill_in_string(alt_tag_value,"");
           _pdm_debug("alt tag value was defaulted to a null string",0);

           /* free up alt_tags  and entry_count */
           di$free (lines = alt_tags,count = entry_count);

           status = PDM_S_SUCCESS;
          }
      }
  return (status);
  }

/****************************************************************************

Document:	PDUget_dyn_attr_value

Description:
        This function gets the value for the dynamic attr specified  
        by a given dir path from the directory structure.

Return Status:
	PDM_S_SUCCESS	-	Success
	Other Status	-	other codes returned by di$find  
                                and di$free macros.
		

History:
        11/27/90	      Jamal Shakra	Created

*****************************************************************************/

IGRint	PDUget_dyn_attr_value (dir_name,osnum,attr_name,attr_value)

  IGRchar       *dir_name;              /* i - holds dir path of dyn attr */
  OMuword	osnum;			/* i - object space number */
  IGRchar       *attr_name;             /* i - dyn attr name */
  IGRchar       **attr_value;           /* i/o - holds dyn attr value  */
  {
  IGRint	status = PDM_S_SUCCESS;	/* return status */
  IGRint        entry_count;		/* count of all attr value entries */
  IGRchar       dir_path[DI_PATH_MAX];     /* holds path name */
  IGRchar       **dyn_attr_value;       /* holds full dir path for dyn value */
  IGRint        stat;                   /* holds status of di$report macro */


  _pdm_debug("In the function PDUget_dyn_attr_value", 0);

  status = DIstmocpy(dir_path,PDU_MAIN_DIR,PDU_PARTS_DIR,dir_name,"",
			NULL,osnum); 
  _pdm_status ("DIstmocpy", status);
  _pdm_debug ("dir_path = <%s>",dir_path);

  if ( 1&status )
     {
       /* get the dyn attr value for this dyn attr name if it exists */
       status = di$find(
                        start_dir = dir_path,
                        regexp = "*",
                        lines = &dyn_attr_value,
                        grids = NULL,
                        ptr = &entry_count,
                        max_level = 1,
                        deep = NULL,
                        options = NULL);

       if (PDM_debug_on)
       stat = di$report_error(sts = status, comment = "di$find status");

       if (status == DIR_S_SUCCESS) 
       /* dyn attr value was found */
          {
           status = PDUextract_dir_value(dyn_attr_value[0],attr_name,
                                         attr_value);
           if (status == PDM_S_SUCCESS)
              {
               /* free up dyn_attr_value and entry_count */
               di$free (lines = dyn_attr_value,count = entry_count);
		
	       status = PDM_S_SUCCESS;
              }
          }
       else
       /* search for dyn attr value was unsuccessful */
          {
           _pdm_debug("dyn attr value was not found",0);
           _pdm_debug("dyn attr value will be set to null string",0);

           /* set attr_value to NULL string */
           PDUfill_in_string(attr_value,"");

           /* free up dyn_attr_value and entry_count */
           di$free (lines = dyn_attr_value,count = entry_count);

	   status = PDM_S_SUCCESS;
          }
      }
  return (status);
  }

/****************************************************************************

Document:	PDUcheck_tag_count 

Description:
        This function checks to see if the subdirectory 
        PDU_TAGCNT_DIR (tag count) is associated with 
        the specified object space. If it is, it will
        return successfully. If not, it will create it 
        and return PDM_S_SUCCESS.

Return Status:
	PDM_S_SUCCESS	-	Success
	Other Status	-	other codes returned by di$find  
                                and di$free macros.
		

History:
        11/6/90	      Jamal Shakra	Created

*****************************************************************************/


IGRint	PDUcheck_tag_count (osnum,found)

  OMuword	osnum;			/* i - object space number */
  int           *found;                 /* o - dir found/not found */
  {
  IGRint	status = PDM_S_SUCCESS;	/* return status */
  IGRint        cnt = 1;                /* tag count (int) */
  IGRint        counter;                /* holds tag count (int) */
  IGRchar       tag_count[20];          /* holds tag count (char) */
  IGRchar       dir_path[DI_PATH_MAX];     /* holds path name */
  IGRchar       **tag = NULL;           /* holds tag count value */
  IGRint        stat;                   /* status for di$report macro */  
  IGRchar       *tag_value = NULL;      /* holds tag count value */

  


  _pdm_debug("In the function PDUcheck_tag_count", 0);
  status = DIstmocpy(dir_path,PDU_MAIN_DIR,PDU_PARTS_DIR,PDU_TAGCNT_DIR,"",
			NULL,osnum); 
  _pdm_status ("DIstmocpy", status);

  _pdm_debug("path_name = <%s>",dir_path);
  if (PDM_debug_on)
  stat = di$report_error(sts = status, comment = "step 1");

  if ( 1&status )
     {
      /* see if directory PDU_TAGCNT_DIR exists */
      status = di$mkpath(pathname = dir_path);
      _pdm_status("di$mkpath",status);

      switch (status)
      {

      case DIR_E_DIR_DUP:
      /* if it does exist , do nothing */
         
       if (PDM_debug_on)
          stat = di$report_error(sts = status, comment = "step 2");
          _pdm_debug("PDU_TAGCNT_DIR exists",0);
          _pdm_debug("path = <%s>",dir_path);
          *found = 1;

          break;
        

      case DIR_S_SUCCESS:
      /* create and initialize tag count */
        _pdm_debug("PDU_TAGCNT_DIR will be created",0);
        sprintf(tag_count,"%d",cnt);
        status = DIstmocpy(dir_path,PDU_MAIN_DIR,PDU_PARTS_DIR,
               			PDU_TAGCNT_DIR,tag_count,"",NULL,osnum); 
        _pdm_status ("DIstmocpy", status);
        status = di$mkpath(pathname = dir_path);
        _pdm_status("di$mkpath",status);

       if (PDM_debug_on)
        stat = di$report_error(sts = status, comment = "step 3");
        _pdm_debug("path = <%s>",dir_path);
       *found = 0;
        
        break;
   
      default: 
       
        _pdm_debug("mk$path failure",0);
       if (PDM_debug_on)
        stat = di$report_error(sts = status, comment = "step 4");
        return(status);
        /*break;					APOGEE */
      }
     
     /* display tag counter value */
     if ( (status == DIR_E_DIR_DUP) || (status == DIR_S_SUCCESS) )
        { 
         status = DIstmocpy(dir_path,PDU_MAIN_DIR,PDU_PARTS_DIR,
		                     PDU_TAGCNT_DIR,"",NULL,osnum); 
         _pdm_status ("DIstmocpy", status);
         _pdm_debug("path = <%s>",dir_path);
         status = di$find(start_dir = dir_path,
                          regexp = "*",
                          lines = &tag,
                          ptr = &counter,
                          max_level = 1
                         );
         _pdm_status("di$find",status);    
       if (PDM_debug_on)
         stat = di$report_error(sts = status, comment = "step 5");
         if (status == DIR_S_SUCCESS)
            {
       if (PDM_debug_on)
             stat = di$report_error(sts = status, comment = "step 6");
             _pdm_debug("entries found in tag = <%d>",counter);
             _pdm_debug("tag entry value = <%s>",tag[0]);

             /* extract tag count value from tag[0] */   
             status = PDUextract_dir_value(tag[0],PDU_TAGCNT_DIR,&tag_value);
             if (status != PDM_S_SUCCESS)
                return (status); 
             _pdm_debug("tag count value = <%s>",tag_value);
 
             /* free memory */
             di$free(lines = tag, count = counter);
       if (PDM_debug_on)
             stat = di$report_error(sts = status, comment = "step 7");
             status = PDM_S_SUCCESS;
            }
       if (PDM_debug_on)
         stat = di$report_error(sts = status, comment = "step 8");
        }
     }

  return (status);
  }

/****************************************************************************

Document:	PDUget_incbom

Description:
        This function gets the inc bom value for the specified part from 
        the part placement directory structure.

Return Status:
	PDM_S_SUCCESS	-	Success
	Other Status	-	other codes returned by di$find  
                                and di$free macros.
		

History:
        11/19/90	      Beth Weeks	Created

*****************************************************************************/
IGRint	PDUget_incbom (incbom_value,osnum,catalog, partid, revision, serial)
  IGRchar       **incbom_value;        /* i/o - hold alt tag value */
  OMuword	osnum;			/* i - object space number */
  IGRchar	*catalog;		/* i - catalog */
  IGRchar	*partid;		/* i - part number */
  IGRchar	*revision;		/* i - revision */
  IGRchar	*serial;		/* i - serial number */
  {
  IGRint	status = PDM_S_SUCCESS;	/* return status */
  IGRchar       s[100];                 /* holds <cat!part!rev> */
  IGRint        entry_count;			/* count of all s entries */
  IGRchar       dir_path[DI_PATH_MAX];     /* holds path name */
  IGRchar       **incbom;             /* holds include bom value */
  IGRint        stat;                   /* holds status of di$report macro */


  _pdm_debug("In the function PDUget_incbom", 0);

  sprintf(s,"%s!%s!%s",catalog,partid,revision);
  _pdm_debug("<cat!part!rev> = <%s>",s);

  status = DIstmocpy(dir_path,PDU_MAIN_DIR,PDU_PARTS_DIR,s,
			PDU_SERIAL_DIR,serial,PDU_INCBOM_DIR,"",
			NULL,osnum); 
  _pdm_status ("DIstmocpy", status);

  _pdm_debug ("dir_path = <%s>",dir_path);

  if ( 1&status )
     {
       /* get the inc bom value for this s directory if it exists */
       status = di$find(
                        start_dir = dir_path,
                        regexp = "*",
                        lines = &incbom,
                        grids = NULL,
                        ptr = &entry_count,
                        max_level = 1,
                        deep = NULL,
                        options = NULL);

       if (PDM_debug_on)
         stat = di$report_error(sts = status, comment = "di$find status");

       if (status == DIR_S_SUCCESS) 
       /* inc bom value was found */
          {
           status = PDUextract_dir_value(incbom[0],PDU_INCBOM_DIR,
                                         incbom_value);
           if (status == PDM_S_SUCCESS)
              {
               /* free up incbom and entry_count */
               di$free (lines = incbom,count = entry_count);
		
	       status = PDM_S_SUCCESS;
              }
          }

       else
       /* inc bom has not been created yet, default it to "Y" */
          {
           PDUfill_in_string(incbom_value,"Y");
           _pdm_debug("inc bom value was defaulted to 'Y'",0);

           /* free up alt_tags  and entry_count */
           di$free (lines = incbom,count = entry_count);

           status = PDM_S_SUCCESS;
          }
      }
  return (status);
  }

/****************************************************************************

Document:	PDUget_incasm

Description:
        This function gets the inc asm value for the specified part from 
        the part placement directory structure.

Return Status:
	PDM_S_SUCCESS	-	Success
	Other Status	-	other codes returned by di$find  
                                and di$free macros.
		

History:
       12/03/90      Jamal Shakra 	Created

*****************************************************************************/

IGRint	PDUget_incasm (incasm_value,osnum,catalog, partid, revision, serial)
  IGRchar       **incasm_value;         /* i/o - hold inc asm value */
  OMuword	osnum;			/* i - object space number */
  IGRchar	*catalog;		/* i - catalog */
  IGRchar	*partid;		/* i - part number */
  IGRchar	*revision;		/* i - revision */
  IGRchar	*serial;		/* i - serial number */
  {
  IGRint	status = PDM_S_SUCCESS;	/* return status */
  IGRchar       s[100];                 /* holds <cat!part!rev> */
  IGRint        entry_count;		/* count of all s entries */
  IGRchar       dir_path[DI_PATH_MAX];     /* holds path name */
  IGRchar       **incasm;               /* holds include asm value */
  IGRint        stat;                   /* holds status of di$report macro */


  _pdm_debug("In the function PDUget_incasm", 0);

  sprintf(s,"%s!%s!%s",catalog,partid,revision);
  _pdm_debug("<cat!part!rev> = <%s>",s);

  status = DIstmocpy(dir_path,PDU_MAIN_DIR,PDU_PARTS_DIR,s,
			PDU_SERIAL_DIR,serial,PDU_ASMSTR_DIR,"",
			NULL,osnum); 
  _pdm_status ("DIstmocpy", status);

  _pdm_debug ("dir_path = <%s>",dir_path);

  if ( 1&status )
     {
       /* get the inc asm value for this s directory if it exists */
       status = di$find(
                        start_dir = dir_path,
                        regexp = "*",
                        lines = &incasm,
                        grids = NULL,
                        ptr = &entry_count,
                        max_level = 1,
                        deep = NULL,
                        options = NULL);

       if (PDM_debug_on)
         stat = di$report_error(sts = status, comment = "di$find status");

       if (status == DIR_S_SUCCESS) 
       /* inc asm value was found */
          {
           status = PDUextract_dir_value(incasm[0],PDU_ASMSTR_DIR,
                                         incasm_value);
           if (status == PDM_S_SUCCESS)
              {
               /* free up incbom and entry_count */
               di$free (lines = incasm,count = entry_count);
		
	       status = PDM_S_SUCCESS;
              }
          }

       else
       /* inc asm has not been created yet, default it to "Y" */
          {
           PDUfill_in_string(incasm_value,"Y");
           _pdm_debug("inc asm value was defaulted to 'Y'",0);

           /* free up incasm  and entry_count */
           di$free (lines = incasm,count = entry_count);

           status = PDM_S_SUCCESS;
          }
      }
  return (status);
  }

/****************************************************************************

Document:	PDUget_explodebom

Description:
        This function gets the explode in bom value for the specified part from 
        the part placement directory structure.

Return Status:
	PDM_S_SUCCESS	-	Success
	Other Status	-	other codes returned by di$find  
                                and di$free macros.
		

History:
        11/19/90	      Beth Weeks	Created

*****************************************************************************/
IGRint	PDUget_explodebom (explode_value,osnum,catalog, partid, revision, serial)
  IGRchar       **explode_value;        /* i/o - hold bom explode value */
  OMuword	osnum;			/* i - object space number */
  IGRchar	*catalog;		/* i - catalog */
  IGRchar	*partid;		/* i - part number */
  IGRchar	*revision;		/* i - revision */
  IGRchar	*serial;		/* i - serial number */
  {
  IGRint	status = PDM_S_SUCCESS;	/* return status */
  IGRchar       s[100];                 /* holds <cat!part!rev> */
  IGRint        entry_count;		/* count of all s entries */
  IGRchar       dir_path[DI_PATH_MAX];     /* holds path name */
  IGRchar       **explode;              /* holds bom explode value */
  IGRint        stat;                   /* holds status of di$report macro */

  _pdm_debug("In the function PDUget_explodebom", 0);

  sprintf(s,"%s!%s!%s",catalog,partid,revision);
  _pdm_debug("<cat!part!rev> = <%s>",s);

  status = DIstmocpy(dir_path,PDU_MAIN_DIR,PDU_PARTS_DIR,s,
			PDU_SERIAL_DIR,serial,PDU_EXPBOM_DIR,"",
			NULL,osnum); 
  _pdm_status ("DIstmocpy", status);

  _pdm_debug ("dir_path = <%s>",dir_path);

  if ( 1&status )
     {
       /* get the explode bom value for this s directory if it exists */
       status = di$find(
                        start_dir = dir_path,
                        regexp = "*",
                        lines = &explode,
                        grids = NULL,
                        ptr = &entry_count,
                        max_level = 1,
                        deep = NULL,
                        options = NULL);

       if (PDM_debug_on)
         stat = di$report_error(sts = status, comment = "di$find status");

       if (status == DIR_S_SUCCESS) 
       /* explode value was found */
          {
           status = PDUextract_dir_value(explode[0],PDU_EXPBOM_DIR,
                                         explode_value);
           if (status == PDM_S_SUCCESS)
              {
               /* free up explode and entry_count */
               di$free (lines = explode,count = entry_count);
		
	       status = PDM_S_SUCCESS;
              }
          }
       else
       /* explode bom has not been created yet, default it to "Y" */
          {
           PDUfill_in_string(explode_value,"Y");
           _pdm_debug("explode value was defaulted to 'Y'",0);

           /* free up explode and entry_count */
           di$free (lines = explode,count = entry_count);

           status = PDM_S_SUCCESS;
          }
      }
  return (status);
  }

/****************************************************************************

Document:	PDUupdate_dir_value


Description:
            This function updates the value of a given directory attribute. 

Return Status:
	PDM_S_SUCCESS	-	Success
	Other Status	-	other codes returned by di$find  
                                and di$free macros.
		

History:
       12/06/90 	     Jamal Shakra 	Created

*****************************************************************************/

IGRint	PDUupdate_dir_value(path_name,osnum,attr_name,old_value,new_value)

  IGRchar       path_name[DI_PATH_MAX];    /* i - holds old value dir path */ 
  OMuword	osnum;			/* i - object space number */
  IGRchar	*attr_name;		/* i - attr_name to be updated */
  IGRchar	*old_value;		/* i - old dir attr value */
  IGRchar	*new_value;		/* i - new dir attr value */
  {
  IGRint	status = PDM_S_SUCCESS;	/* return status */
  IGRchar       dir_path[DI_PATH_MAX];     /* holds full path */ 
  IGRint        stat;                   /* holds status of di$report macro */

  _pdm_debug("In the function PDUupdate_dir_value", 0);

  status = DIstmocpy(dir_path,PDU_MAIN_DIR,PDU_PARTS_DIR,
                     path_name,attr_name,"",NULL,osnum);
  _pdm_status ("DIstmocpy", status);

  _pdm_debug("old value full path name = <%s>",dir_path);
  _pdm_debug("obj space no = %d",osnum);
  _pdm_debug("directory attribute name = <%s>",attr_name);
  _pdm_debug("dir attr old value = <%s>",old_value);
  _pdm_debug("dir attr new value = <%s>",new_value);

  if ( 1&status )
     {
       /* delete old dir attr value dir entry from directory structure */
       status = di$rmdir(dirname = old_value, path = dir_path);
       _pdm_status("di$rmdir",status);

       if (PDM_debug_on)
         stat = di$report_error(sts = status, comment = "di$rmdir status");

       /* make new dir entry with updated dir attr value */
       status = DIstmocpy(dir_path,PDU_MAIN_DIR,PDU_PARTS_DIR,
                          path_name,attr_name,new_value,"",NULL,osnum);
       _pdm_status ("DIstmocpy", status);
       _pdm_debug("new dir attr value full path name = <%s>",dir_path);

       status = di$mkpath(pathname = dir_path);

       if (PDM_debug_on)
         stat = di$report_error(sts = status, comment = "di$mkpath status");

       if (status == DIR_S_SUCCESS)
          status = PDM_S_SUCCESS;
    } 
    return(status);
 }

/****************************************************************************

Document:	PDUremove_tree


Description:
            This function removes a directory tree. Caution must be 
            exercised in using this function.

Return Status:
	PDM_S_SUCCESS	-	Success
	Other Status	-	other codes returned by di$find  
                                and di$free macros.
		

History:
       01/08/91 	     Jamal Shakra 	Created

*****************************************************************************/

IGRint	PDUremove_tree(osnum,path_name,dir_name)

  OMuword	osnum;			/* i - object space number */
  IGRchar       path_name[DI_PATH_MAX];    /* i - holds path to dir name */
  IGRchar	*dir_name;		/* i - dir tree name */

  {
  IGRint	status = PDM_S_SUCCESS;	/* return status */
  IGRchar       dir_path[DI_PATH_MAX];     /* holds full path */ 
  IGRchar       tmp_path[DI_PATH_MAX];     /* holds incomplete path */
  IGRchar       *s;                     /* temp string */
  IGRchar       *temp_str = NULL;       /* temp string */
  IGRchar       *temp_str1 = NULL;      /* temp string */
  IGRint        stat;                   /* holds status of di$report macro */
  IGRchar       **entries;              /* holds tree entries */
  IGRint        entry_count = 0;        /* holds entries count */
  IGRint        tmpcnt = 0;             /* holds temp entries count */
  IGRint        serial_found;           /* a flag */
  IGRint        i;                      /* array index */

  _pdm_debug("In the function PDUremove_tree", 0);

  /* check if path name is provided */
  if (strcmp(path_name,"") != 0)
    {
     status = DIstmocpy(dir_path,PDU_MAIN_DIR,PDU_PARTS_DIR,path_name,
                         dir_name,"",NULL,osnum);

     status = DIstmocpy(tmp_path,PDU_MAIN_DIR,PDU_PARTS_DIR,path_name,
                        "",NULL,osnum);
    }

  else
    {
     status = DIstmocpy(dir_path,PDU_MAIN_DIR,PDU_PARTS_DIR,dir_name,
                        "",NULL,osnum);

     status = DIstmocpy(tmp_path,PDU_MAIN_DIR,PDU_PARTS_DIR,
                        "",NULL,osnum);
    }

    
  _pdm_status ("DIstmocpy", status);
  _pdm_debug("abs tree path = <%s>",dir_path);
  _pdm_debug("tmp tree path = <%s>",tmp_path);

  /* need to check tree name exists in the first place */
  /* tree name could be cat!part!rev or serial no. value */
  status = di$find(
                   start_dir = tmp_path,
                   regexp = dir_name,
                   lines = &entries,
                   grids = NULL,
                   ptr = &entry_count,
                   max_level = 1,
                   deep = NULL,
                   options = NULL
                  );
  _pdm_status("di$find",status);

  if (PDM_debug_on)
     stat = di$report_error(sts = status, comment = "di$find"); 
       
  if (status != DIR_S_SUCCESS)
     {
      _pdm_debug("tree name was not found",0);

      /* free up entries and entry_count */
      di$free (lines = entries,count = entry_count);

      return(PDM_S_SUCCESS);
     }


  if ( status == DIR_S_SUCCESS )
     {
       /* find all entries under the tree name */
       status = di$find(
                        start_dir = dir_path,
                        regexp = "*",
                        lines = &entries,
                        grids = NULL,
                        ptr = &entry_count,
                        max_level = -1,
                        deep = NULL,
                        options = NULL
                       );
       _pdm_status("di$find",status);

       if (PDM_debug_on)
       stat = di$report_error(sts = status, comment = "1st di$find"); 
       
       if (status != DIR_S_SUCCESS)
          {
           _pdm_debug("No entries were found under tree name <%s>",dir_name);

           /* free up entries and entry_count */
           di$free (lines = entries,count = entry_count);
           return(status);
          }

       while ((status == DIR_S_SUCCESS) && 
              (entry_count) &&
              (entry_count != tmpcnt))
          {
           _pdm_debug("entry_count = %d",entry_count);

           /* save entry count in tmpcnt */
           tmpcnt = entry_count;

           /* remove leaf_level directories */
           for (i = 0; i < entry_count; ++i)
            {
            /* need to make sure that dynamic attributes (expressions)
               will not get removed as directories */
               serial_found = FALSE;
               PDUfill_in_string(&temp_str1,entries[i]);
               PDUfill_in_string(&temp_str,"");
               s = strtok(temp_str1,":");

               while(s)
                    {
                     _pdm_debug("token = <%s>",s);
                     if ((strcmp(s,"serial") == 0) && (s))
                        {
                         s = strtok(0,":");
                         if (!s)
                            {
                             _pdm_debug("no more tokens found",0);
                             PDUfill_in_string(&temp_str,"");
                             break;
                            }

                         s = strtok(0,":");
                         if (!s)
                            {
                             _pdm_debug("no more tokens found",0);
                             PDUfill_in_string(&temp_str,"");
                             break;
                            }

                         PDUfill_in_string(&temp_str,s);
                         serial_found = TRUE;
                         _pdm_debug("temp_str = <%s>",temp_str);
                         break;
                        }
                      else
                        {
                         s = strtok(0,":");
                         PDUfill_in_string(&temp_str,"");
                        }
                    }

               if ( (strcmp(temp_str,"asm_incl_str") != 0) && 
                    (strcmp(temp_str,"incl_BOM") != 0) && 
                    (strcmp(temp_str,"") != 0) && 
                    (strcmp(temp_str,"p_explode") != 0) && serial_found )
                    {
                     /* must be an expression dyn attr, remove it */
                     _pdm_debug("an expression was encountered",0);
                     status = PDUdelete_expression(
                                                   1,
                                                   "",
                                                   entries[i],
                                                   0
                                                  );
                     _pdm_status("PDUdelete_expression",status);

                     status = di$rm_name(regexp = entries[i], path = NULL);
                     _pdm_status("di$rm_name",status);

                     if (PDM_debug_on)
                        {
                         stat = di$report_error(sts = status,
                                                comment = "di$rm_name status");

                         if (status == DIR_S_SUCCESS)
                         _pdm_debug("entry <%s> was removed successfully",
                                     entries[i]);

                         if (status != DIR_S_SUCCESS) 
                         _pdm_debug("entry <%s> is not empty, can't be removed",
                                     entries[i]);
                        }
                    }
               else
                    {
                     status = di$rmdir(dirname = entries[i], path = NULL);
                     _pdm_status("di$rmdir",status);

                     if (PDM_debug_on)
                        {
                         stat = di$report_error(sts = status,
                                                comment = "di$rmdir status");

                         if (status == DIR_S_SUCCESS)
                         _pdm_debug("entry <%s> was removed successfully",
                                     entries[i]);

                         if (status != DIR_S_SUCCESS) 
                         _pdm_debug("entry <%s> is not empty, can't be removed",
                                     entries[i]);
                        }
                     }
             } /* end for loop */

           /* extract existing undeleted entries */
           status = di$find(
                        start_dir = dir_path,
                        regexp = "*",
                        lines = &entries,
                        grids = NULL,
                        ptr = &entry_count,
                        max_level = -1,
                        deep = NULL,
                        options = NULL
                       );
           _pdm_status("di$find",status);

           if (PDM_debug_on)
           stat = di$report_error(sts = status, comment = "2nd di$find"); 

         } /* end while */

       /* now, tree name can be removed */

       if (strcmp(path_name,"") != 0)
          status = DIstmocpy(dir_path,PDU_MAIN_DIR,PDU_PARTS_DIR,
                             path_name,"",NULL,osnum);

       else 
          status = DIstmocpy(dir_path,PDU_MAIN_DIR,PDU_PARTS_DIR,
                            "",NULL,osnum);
        
       _pdm_status ("DIstmocpy", status);

       _pdm_debug("tree name path = <%s>",dir_path);

       status = di$rmdir(dirname = dir_name, path = dir_path);
       _pdm_status("di$rmdir",status);

       if (PDM_debug_on)
          stat = di$report_error(sts = status, comment = "di$rmdir status");

       if (status == DIR_S_SUCCESS)
          {
            _pdm_debug("tree name <%s> was removed successfully",dir_name);
            status = PDM_S_SUCCESS;
          }
              
       else
          {
            _pdm_debug("failed in removing tree name <%s>",dir_name);
            status = PDM_S_SUCCESS;
          }
          

       /* free up entries and entry_count */
       di$free (lines = entries,count = entry_count);
    } 

    return(status);
 }

/****************************************************************************

Document:	PDUget_exp_objects

Description:
	This function allocates and fills in an array of structures
	containing the objid id/osnum for all the objects in the
	specified directory. It can also be used to get only the count
	of entries in the specified directory, by using NULL for the
	objects pointer.

	directory into the object id for the corresponding object.

Algoritm:
	1. Get absolute path for the specified PDU directory (DIstmocpy).
	2. Translate object name to object id (di$translate).

Return Status:
	PDM_S_SUCCESS	-	Success
	PDM_E_DIR_ACCESS -	Error accessing directory system

Notes:
	The array of object structures must be deallocated by the caller.
	To get only the count of entries in the specified directory,
	use  NULL for the pointer to the objects array.

History:
	05/15/91	Jamal Shakra	Created	

*****************************************************************************/

IGRint	PDUget_exp_objects (directory,exp_type,exp_objects,object_count)

  IGRchar	*directory;		/* i - PDU subdirectory name */
  IGRint        exp_type;               /* i - expression object type */
  struct GRid	**exp_objects;		/* o - expression objects */
  IGRint        *object_count;          /* o - expression object count */
  {
  IGRint	status = PDM_S_SUCCESS;	/* return status */
  OM_p_CLASSLIST classlist;
  OMuword	classid;
  IGRchar       *classname = NULL;
  IGRchar       *dir_path = NULL;
  IGRint        i;

  _pdm_debug("In the function PDUget_exp_object",0);

  PDUfill_in_string(&dir_path,directory);
  strcat(dir_path,"*"); 
  _pdm_debug("absolute directory path = <%s>", dir_path);

  if ( 1&status )
     {
     *object_count = 0;

     /* check which class to be used */
     if (exp_type == NUMERIC)
        {
         _pdm_debug("class name was set to expression",0);
         PDUfill_in_string(&classname,"expression");
        }

     if (exp_type == TEXT)
        {
         _pdm_debug("class name was set to text_exp",0);
         PDUfill_in_string(&classname,"text_exp");
        }

     _pdm_debug("get the class id ",0);

     status = om$get_classid(classname = classname,
		 	     p_classid = &classid);
     _pdm_status("om$get_classid", status);
     _pdm_debug("class id = %d",classid);

     _pdm_debug("malloc classlist",0);
     classlist = (struct OM_sd_classlist *) malloc (sizeof 
 		                                      (struct OM_sd_classlist));

     _pdm_debug("set word count and flags",0);
     classlist->w_count = 1;
     classlist->w_flags = OM_CLST_internal;
     classlist->p_classes = &classid;

     _pdm_debug("calling di$dump",0);
     status = di$dump ( regexp = dir_path, p_classes = classlist,
			grids = (DIgrid **)exp_objects,
			ptr = object_count);

     _pdm_status ("di$dump", status);
     _pdm_debug("directory object count = %d", *object_count);
     
     /* see if any directory in path does not exist */
     switch ( status )
	{
	case DIR_W_NAME_NOT_FOUND:
/*	case OM_W_NAMENOTFOUND:				APOGEE */
	     /* if directory doesn't exist, set object count to 0 */
             _pdm_debug("directory name does not exist",0);
	     *object_count = 0;
             return(status);
           /*break;					APOGEE */

	case DIR_S_SUCCESS:
             if (*object_count > 0)
                {

                 if (PDM_debug_on) 
                    {
                     _pdm_debug("list of expression id's found",0);
                     for (i = 0; i < (*object_count); ++i)
                        _pdm_debug("expression objid = %d",
                                                      (*exp_objects)[i].objid);
                     }

                 }
	     status = PDM_S_SUCCESS;

	     break;
	}
     }
 
  if ( 1&status )
     status = PDM_S_SUCCESS;
  else
     status = PDM_E_DIR_ACCESS;

  return (status);
  }

/****************************************************************************

Document:	PDUevaluate_dyn_attr_expression

Description:
        This function gets the value for the dynamic attr expression specified  
        by a given dir path from the directory structure.

Return Status:
	PDM_S_SUCCESS	-	Success
	Other Status	-	other codes returned by di$find  
                                and di$free macros.
		

History:
       05/17/91 	      Jamal Shakra	Created

*****************************************************************************/

IGRint	PDUevaluate_dyn_attr_expression(dir_name,osnum,exp_name,exp_value)

  IGRchar       *dir_name;              /* i - holds dir path of dyn attr */
  OMuword	osnum;			/* i - object space number */
  IGRchar       *exp_name;              /* i - dyn attr expression name */
  IGRchar       **exp_value;            /* i/o - holds dyn attr expression value  */
  {
  IGRint	status = PDM_S_SUCCESS;	/* return status */
  IGRchar       dir_path[DI_PATH_MAX];     /* holds path name */
  IGRchar       RHS[EXP_MAX_LEN];       /* holds RHS */
  IGRchar       *tmp_str;               /* temp pointer */

  _pdm_debug("In the function PDUevaluate_dyn_attr_expression", 0);

  status = DIstmocpy(dir_path,PDU_MAIN_DIR,PDU_PARTS_DIR,dir_name,"",
			NULL,osnum); 
  _pdm_status ("DIstmocpy", status);
  _pdm_debug ("dir_path = <%s>",dir_path);

  if ( 1&status )
     {
       /* extract expression RHS */
       status = PDUextract_expression_RHS(
                                          dir_path,
                                          exp_name,
                                          RHS
                                         );
       _pdm_status("PDUextract_expression_RHS",status);

       if (strcmp(RHS,"") == 0)
          {
           _pdm_debug("no RHS was found for this dynamic attribute",0);
           PDUfill_in_string(exp_value,"");
           return(PDM_S_SUCCESS);
          }

       else
         {
          _pdm_debug("RHS is not empty",0);
          _pdm_debug("RHS = <%s>",RHS);
          
          /* copy RHS to tmp_str */
          tmp_str = NULL; 
          PDUfill_in_string(&tmp_str,RHS);
          
          /* need to identify expression type */
          if (RHS[0] == '"') 
             {
              _pdm_debug("RHS type is TEXT",0);

              /* unquote RHS string */
              PDUunquote(tmp_str);
              _pdm_debug("unquoted string = <%s>",tmp_str);

              /* copy unquoted string to exp_value */
              PDUfill_in_string(exp_value,tmp_str);
              free(tmp_str);
             }

          else
             {
              _pdm_debug("RHS type is NUMERIC",0);
             
              /* extract value of numeric expression */
            /*
              s = strtok(tmp_str," ");
              _pdm_debug("RHS expression = <%s>",s);
            */
              /* calculate RHS of expression */
              status = PDUevaluate_expression(
                                              dir_path,
                                              exp_name,
                                              exp_value 
                                             );
              _pdm_status("PDUevaluate_expression",status);
             /*  free(tmp_str); */
             }

          status = PDM_S_SUCCESS;
         }
      }
  return (status);
  }

/****************************************************************************

Document:	PDUconvert_dyn_attrs

Description:

        This function converts a dynamic attribute and its value from
        string representation to expression representation.

Return Status:
	PDM_S_SUCCESS	-	Success
	Other Status	-	other codes returned by di$find, di$free,  
                                and DIstmocpy macros.
History:
        06/10/91 	      Jamal Shakra	Created

*****************************************************************************/


IGRint	PDUconvert_dyn_attrs (catalog,partid,revision,dyn_name,dyn_type)

  IGRchar       *catalog;               /* i - hold alt tag value */
  IGRchar       *partid;                /* i - part id */
  IGRchar       *revision;              /* i - revision */
  IGRchar       *dyn_name;              /* i - dynamic attribute name */
  IGRint        dyn_type;               /* i - dynamic attribute type */
  {
  OMuword	osnum;			/* active object space number */
  IGRint	status = PDM_S_SUCCESS;	/* return status */
  IGRint	stat;	                /* return status */
  IGRint        entry_count;		/* count of all s entries */
  IGRchar       dir_path[DI_PATH_MAX];     /* holds path name */
  IGRchar       serial_path[DI_PATH_MAX];  /* holds serial path */
  IGRchar       attr_path[DI_PATH_MAX];    /* holds attribute path */
  IGRchar       value_path[DI_PATH_MAX];   /* holds attribute value path */
  IGRchar       tmp_path[DI_PATH_MAX];     /* holds temp. value path */
  IGRchar       *entry;                 /* holds entry name */
  IGRchar       *serial_no = NULL;      /* holds serial number */
  IGRchar       **entries;              /* holds entries */
  IGRchar       *dyn_value = NULL;      /* dynamic value */
  IGRint        i;                      /* for loop index */
  IGRchar	catpartrev[100];	/* holds catalog part rev */
  IGRchar       *s;                     /* holds half search path */


  _pdm_debug("In the function PDUconvert_dyn_attrs", 0);

  _pdm_debug("catalog name = <%s>",catalog);
  _pdm_debug("part id = <%s>",partid);
  _pdm_debug("part revision = <%s>",revision);
  _pdm_debug("dynamic attribute name = <%s>",dyn_name);
  _pdm_debug("dynamic attribute type = %d",dyn_type);

  /* construct cat!part!rev string */
  sprintf(catpartrev,"%s!%s!%s",catalog, partid, revision);
 
  /* get active module info */
  status = ex$get_cur_mod ( osnum = &osnum );
  _pdm_status ("ex$get_cur_mod", status);

  /* get array of entries matching regualr expression in specified directory */
  status = DIstmocpy(dir_path,PDU_MAIN_DIR,PDU_PARTS_DIR,catpartrev,
                     "",NULL,osnum); 
  _pdm_status ("DIstmocpy", status);
  _pdm_debug("dir_path = <%s>",dir_path);

  if ( 1&status )
     {
       /* get all entries representing dyn_attr_values for the given dynamic
          attribute name */
       status = di$find(
                        start_dir = dir_path,
                        regexp = dyn_name,
                        lines = &entries,
                        grids = NULL,
                        ptr = &entry_count,
                        max_level = -1
                       );
       _pdm_status("di$find",status);

       if (PDM_debug_on)
         stat = di$report_error(sts = status,
                              comment = "di$find status"); 

       _pdm_debug("entry_count = <%d>",entry_count);

       if ( (status != DIR_S_SUCCESS) || (entry_count <= 0) ) 
          {
           _pdm_debug("No entry found that matches regular expression",0);
           return(PDM_S_SUCCESS); 
          }

       /* loop through each entry converting dynamic attribute */
       for (i = 0; i < entry_count; ++i) 
          {
            _pdm_debug("entries[i] = <%s> ",entries[i]);

            /* extract serial number */ 
            PDUfill_in_string(&entry,entries[i]);
            s = strtok(entry,":");
            while(s)
                   {
                    _pdm_debug("token = <%s>",s);
                    if (strcmp(s,"serial") == 0)

                       {
                        s = strtok(0,":");
                        PDUfill_in_string(&serial_no,s);
                        _pdm_debug("extracted serial number = <%s>",serial_no);
                        break;
                       }
                        s = strtok(0,":");
                    }

            /* construct dynamic attribute path */
            status = DIstmocpy(attr_path,
                               PDU_MAIN_DIR,
                               PDU_PARTS_DIR,
                               catpartrev,
                               PDU_SERIAL_DIR,
                               serial_no,
                               dyn_name,
                               "",
                               NULL,
                               osnum); 

            /* construct serial path */
            status = DIstmocpy(serial_path,
                               PDU_MAIN_DIR,
                               PDU_PARTS_DIR,
                               catpartrev,
                               PDU_SERIAL_DIR,
                               serial_no,
                               "",
                               NULL,
                               osnum); 

            /* extract dynamic attribute value */
            PDUfill_in_string(&dyn_value,"OSNUM");
            sprintf(tmp_path,"%s:serial:%s:%s",catpartrev,serial_no,dyn_name);

            status = PDUextract_dyn_attr_value(tmp_path,dyn_name,1,&dyn_value);
            _pdm_status("PDUextract_dyn_attr_value",status);

            if ( (strcmp(dyn_value,"") != 0) && (dyn_value) )
               {
                /* construct dynamic value path */
                status = DIstmocpy(value_path,
                                   PDU_MAIN_DIR,
                                   PDU_PARTS_DIR,
                                   catpartrev,
                                   PDU_SERIAL_DIR,
                                   serial_no,
                                   dyn_name,
                                   dyn_value,
                                   "",
                                   NULL,
                                   osnum); 
                        
                /* need to delete both dynamic attr name and value
                   directories */
                status = di$rmdir(dirname = value_path, path = NULL);
                _pdm_status("di$rmdir",status);
                        
                status = di$rmdir(dirname = attr_path, path = NULL);
                _pdm_status("di$rmdir",status);

                /* create expression */
                status = PDUcreate_expression(
                                              dyn_type,
                                              serial_path,
                                              dyn_name,
                                              dyn_value
                                             ); 
                _pdm_status("PDUcreate_expression",status);
                        
                if (status != PDM_S_SUCCESS)
                   {
                    _pdm_debug("could not create expression",0);
                    return(status);
                   }

               }

            else
               {
                /* dynamic attribute does not have a value, need only
                   to delete attribute directory */
                status = di$rmdir(dirname = attr_path, path = NULL);
                _pdm_status("di$rmdir",status);
               }
          }
          di$free (lines = entries, count = entry_count);
          status = PDM_S_SUCCESS; 
      }
  return (status);
  }


/****************************************************************************

Document:	PDUextract_catpartrev_entries

Description:
        This function extracts all cat!part!rev entries found in a 
        given object space.

Return Status:
	PDM_S_SUCCESS	-	Success
	Other Status	-	other codes returned by di$find  
                                and di$free macros.
		

History:
        06/12/1991 	      Jamal Shakra	Created

*****************************************************************************/


IGRint	PDUextract_catpartrev_entries(entries,entry_count)

  IGRchar       ***entries;             /* o - entries found */
  IGRint        *entry_count;           /* o - entries count */

  {
  OMuword	osnum;			/* object space number */
  IGRint	status = PDM_S_SUCCESS;	/* return status */
  IGRchar       dir_path[DI_PATH_MAX];     /* holds path name */
  IGRint        stat;                   /* holds di$find status */

  _pdm_debug("In the function PDUextract_catpartrev_entries", 0);

  /* get osnum of active space */
  status = ex$get_cur_mod ( osnum = &osnum );
  _pdm_status ("ex$get_cur_mod", status);

  status = DIstmocpy(dir_path,PDU_MAIN_DIR,PDU_PARTS_DIR,"",NULL,osnum);
  _pdm_status ("DIstmocpy", status);

  _pdm_debug ("dir_path = <%s>",dir_path);

  if ( 1&status )
     {
       /* set count initially to 0 */
       *entry_count = 0;

       /* check if that s directory exists under the parts directory */
       status = di$find(
                        start_dir = dir_path,
                        regexp = "*!*!*",
                        lines = entries,
                        grids = NULL,
                        ptr = entry_count,
                        max_level = 1
                       );
       _pdm_status("di$find",status);

       if (PDM_debug_on)
       stat = di$report_error(sts = status, comment = "di$find"); 

       if (status == DIR_S_SUCCESS) 
          {
           _pdm_debug("entries were found",0);
           status = PDM_S_SUCCESS; 
          }

       else
          {
           _pdm_debug("entries were not found",0);

           /* free up entries and entry_count */
           di$free (lines = *entries, count = *entry_count);
          }
     }
  return (status);
  }

/****************************************************************************

Document:	PDUcheck_if_need_conversion

Description:
        This function checks to see if a conversion of dynamic attribute 
        to expressions is necessary.

Return Status:
	PDM_S_SUCCESS	-	Success
	Other Status	-	other codes returned by di$find  
                                and di$free macros.
		

History:
        06/12/1991 	      Jamal Shakra	Created

*****************************************************************************/


IGRint	PDUcheck_if_need_conversion()

  {
  OMuword	osnum;			/* object space number */
  IGRint	status = PDM_S_SUCCESS;	/* return status */
  IGRchar       dir_path[DI_PATH_MAX];     /* holds path name */
  IGRint        stat;                   /* holds di$find status */
  IGRchar       **entries;              /* holds entries found */
  IGRint        entry_count;            /* holds entry count */

  _pdm_debug("In the function PDUcheck_if_need_conversion", 0);

  /* get osnum of active space */
  status = ex$get_cur_mod ( osnum = &osnum );
  _pdm_status ("ex$get_cur_mod", status);

  _pdm_debug("osnum = %d",osnum);

  status = DIstmocpy(dir_path,PDU_MAIN_DIR,PDU_PARTS_DIR,"",NULL,osnum);
  _pdm_status ("DIstmocpy", status);

  _pdm_debug ("dir_path = <%s>",dir_path);

  if ( 1&status )
     {
       /* check if that directory exists under the PDU directory */
       status = di$find(
                        start_dir = dir_path,
                        regexp = PDU_CONVERT_DIR,
                        lines = &entries,
                        grids = NULL,
                        ptr = &entry_count,
                        max_level = 1,
                        deep = NULL,
                        options = NULL
                       );
       _pdm_status("di$find",status);

       if (PDM_debug_on)
       stat = di$report_error(sts = status, comment = "di$find"); 

       if (status == DIR_S_SUCCESS) 
          {
           _pdm_debug("PDU_CONVERT_DIR was found",0);

           /* free up entries and entry_count */
           di$free (lines = entries, count = entry_count);
           return(status);
          }

       else
          {
           _pdm_debug("PDU_CONVERT_DIR was not found",0);

           /* free up entries and entry_count */
           di$free (lines = entries, count = entry_count);
           status = PDM_S_SUCCESS;
          }

     }
  return (status);
  }


/****************************************************************************

Document:	PDUflag_object_space

Description:
        This function flags the active object space for successful
        completion of conversion. It does so by creating the directory
        PDU_CONVERT_DIR. 

Return Status:
	PDM_S_SUCCESS	-	Success
	Other Status	-	other codes returned by di$find  
                                and di$free macros.
		

History:
        06/12/1991 	      Jamal Shakra	Created

*****************************************************************************/


IGRint	PDUflag_object_space()

  {
  OMuword	osnum;			/* object space number */
  IGRint	status = PDM_S_SUCCESS;	/* return status */
  IGRchar       dir_path[DI_PATH_MAX];     /* holds path name */
  IGRint        stat;                   /* holds di$find status */

  _pdm_debug("In the function PDUflag_object_space", 0);

  /* get osnum of active space */
  status = ex$get_cur_mod ( osnum = &osnum );
  _pdm_status ("ex$get_cur_mod", status);

  status = DIstmocpy(dir_path,PDU_MAIN_DIR,PDU_PARTS_DIR,
                              PDU_CONVERT_DIR,"",NULL,osnum);
  _pdm_status ("DIstmocpy", status);

  _pdm_debug ("dir_path = <%s>",dir_path);

  if ( 1&status )
     {
       status = di$mkpath(pathname = dir_path);
       _pdm_status("di$mkpath",status);

       if (PDM_debug_on)
       stat = di$report_error(sts = status, comment = "di$mkpath"); 

       if (status == DIR_S_SUCCESS) 
          {
           _pdm_debug("PDU_CONVERT_DIR was created successfully",0);
           status = PDM_S_SUCCESS; 
          }

       else
          {
           _pdm_debug("PDU_CONVERT_DIR was not created successfully",0);
          }
     }
  return (status);
  }


/*   This function removes a directory tree starting from the given path.  
     Audra Romans  4/6/94  Created
*/
IGRint PDU_remove_dir_tree(start_path,mod_env)
IGRchar start_path[DI_PATH_MAX];
struct GRmd_env *mod_env;
{
  long status;
  char **exp,expname[DI_PATH_MAX];
  int entry_count,exp_count,i,j;
  struct PDUid *exp_ids;
  OM_p_CLASSLIST classlist;
  OMuword classid;

  _pdm_debug("In the function PDU_remove_dir_tree",0);
  _pdm_debug("start_path %s",start_path);

  status = PDM_S_SUCCESS;
  exp = NULL;
  exp_count = 0;
  entry_count = 0;

  /* Get the class id of GRpart */

   status = om$get_classid(
                           classname = "text_exp",
                           p_classid = &classid
                          );

  /* Malloc classlist */
  classlist = (struct OM_sd_classlist *) malloc(sizeof (struct OM_sd_classlist));
  classlist->w_count = 1;
  classlist->w_flags = OM_CLST_internal;
  classlist->p_classes = &classid;

  /* Get all directories and expressions */

  status = di$find(
                   start_dir = start_path,
                   regexp = "*",
                   lines = &exp,
                   ptr = &entry_count,
                   max_level = -1,
                   deep = NULL,
                   options = NULL
                  ); 
  if (status != DIR_S_SUCCESS)
   {
     _pdm_debug("path %s does not exist",start_path);
     return(status); 
   }
  else
   {
     if (entry_count != 0)
      {
        /* remove leaf expressions */
        for (i=entry_count - 1; i >= 0; i = i - 1)
        {
          strcpy(expname,exp[i]);
          strcat(expname,":*");
          _pdm_debug("expname |%s|",expname);
       
          /* extract all expresseion objects under current path */
          status = di$dump(
                            regexp = expname,
                            p_classes = classlist,
                            grids = (DIgrid **) &exp_ids,
                            ptr = &exp_count
                            );
          _pdm_debug("exp_count %d",exp_count);
          _pdm_debug("di$dump status <0x%.8x>",status); 
  
          if ((exp_count > 0) && (status == DIR_S_SUCCESS))
           {
                /* Delete current expressions */
              for (j=0; j < exp_count; j = j + 1)
                {
                  _pdm_debug("delete expression %s",exp_ids[j]);
                   status = PDUdelete_exp(exp_ids[j], *mod_env);
                   _pdm_status("PDUdelete_exp",status);

                   if (status != PDM_S_SUCCESS)
                     {
                        _pdm_debug("PDUdelete_exp failed",0);
                        break;
                     }
                    /* Remove expression from part directory */
                    
                    status = di$rm_objid(
                                         objid = exp_ids[j].objid,
                                         osnum = exp_ids[j].osnum
                                         );
                     _pdm_status("di$rm_objid",status);
                }
             di$free(lines = (char **)exp_ids, count = exp_count);
             exp_ids = NULL;
             exp_count = 0;
           }
        }
        di$free(lines = exp, count = entry_count);
        exp = NULL;
        entry_count = 0;

        /* find directories that are left */

        status = di$find(
                   start_dir = start_path,
                   regexp = "*",
                   lines = &exp,
                   ptr = &entry_count,
                   max_level = -1,
                   deep = NULL,
                   options = NULL
                  ); 

        for (i = entry_count - 1; i >= 0; i = i - 1)
         {
              /* Delete dir */
           _pdm_debug("delete directory = |%s|",exp[i]);
           status = PDUrmdir(exp[i]);
           if (status != DIR_S_SUCCESS)
           {
              _pdm_debug("Error: could not remove %s",exp[i]); 
              _pdm_status("PDUrmdir",status);
           }
         }
      }

         /* Delete top level dir */
         _pdm_debug("delete top level directory = |%s|",start_path);
         status = PDUrmdir(start_path);
         if (status != DIR_S_SUCCESS)
         {
           _pdm_debug("Error: Could not remove %s",start_path);
           _pdm_status("PDUrmdir",status);
         }
   }
  return (status); 
}
end implementation COpdu;
