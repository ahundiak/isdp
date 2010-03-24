class	implementation	OMObjSpace;

/*
Class:		OMObjSpace

This file contains methods for following messages:

		debug
		dissolve_ISOs
		resolve_ISOs
		fixup_for_write

Author:		Kerry Kilbride
Creation Date:	apr-1986
Imported Methods:

		OMISO.dissolve_yourself
		OMISO.resolve_yourself
		OMISO.fixup_for_write

Change History:	

cgp001	29-apr-1986	OM3.2	Change resolve_ISOs to get rid of any 
				ISOs that might have been left to transient
				OS. Add fixup_for_write method.

*/

#include	<stdio.h>
#include	<string.h>
#include	<ctype.h>
#include 	"OMobjectcomm.h"
#include	"OMmetaclass.h"
#include	"OMspecify.h"
#include	"OMrelation.h"
#include	"OMintprims.h"

extern int	som_ISO_construct();
extern int	som_ISO_init_iso();
extern int	som_ISO_print();

extern OMuword  OM_Gw_defISOdir_size;
extern OMuword  OM_Gw_defISOdir_ext;

from	OMISO	import	dissolve_yourself, resolve_yourself, fixup_for_write,
                        unlink_all;


/*
  Dissolves all ISO's to Transient spaces from this space to any connections.
*/

method	dissolve_ISOs ()
{
  int		ii, sts, upper_bound;
  OMuword	target_OSnum;
  
#ifdef DEBUG
  printf("OMObjSpace_dissolve_ISOs obj=%d,%d\n",
		OM_Gw_current_OS,my_id);
#endif
  upper_bound = om$dimension_of(varray=ME.OMObjSpace->iso_d);
  for (ii=(upper_bound-1); ii >= 0; ii--)
  {
    if (!ME.OMObjSpace->iso_d) break;
    if ((ME.OMObjSpace->iso_d[ii].s_int_os_name[0] != 0)
    			    &&
        (1&(sts = om$os_internal_name_to_number(
		osname = ME.OMObjSpace->iso_d[ii].s_int_os_name,
		p_osnum = &target_OSnum))))
    {
      om$send (mode = OM_e_wrt_message, 
	  		msg = message OMISO.dissolve_yourself (target_OSnum), 
			targetid = ME.OMObjSpace->iso_d[ii].iso_u.s_objid);
    }
  }
  return (OM_S_SUCCESS);
}



/*
  Resolves all ISOs from this space to any foreign OS.
  If ISOs are found that pointed to transient OS,  get rid of them.
*/

method	resolve_ISOs ()
{
  int		ii, upper_bound;
  
#ifdef DEBUG
  printf("OMObjSpace_resolve_ISOs obj=%d,%d\n",
		OM_Gw_current_OS,my_id);
#endif
  upper_bound = om$dimension_of(varray=ME.OMObjSpace->iso_d);
  for (ii=(upper_bound-1); ii >= 0; ii--)
  {
    if (!ME.OMObjSpace->iso_d) break;
    if (ME.OMObjSpace->iso_d[ii].s_int_os_name[0] != 0)
    {
      om$send (msg = message OMISO.resolve_yourself 
			(ME.OMObjSpace->iso_d[ii].s_int_os_name), 
		   targetid = ME.OMObjSpace->iso_d[ii].iso_u.s_objid);
    }
  }
  return (OM_S_SUCCESS);
}


/*
   fixup_for_write sens a fixup for write message to all ISOs who have
   targets
*/
method	fixup_for_write () 
{
  int		ii, sts, upper_bound;
  OMuword	target_OSnum;
  
#ifdef DEBUG
  printf("OMObjSpace_fixup_for_write obj=%d,%d\n",
		OM_Gw_current_OS,my_id);
#endif
  upper_bound = om$dimension_of(varray=ME.OMObjSpace->iso_d);
  for (ii=(upper_bound-1); ii >= 0; ii--)
  {
    if (!ME.OMObjSpace->iso_d) break;
    if ((ME.OMObjSpace->iso_d[ii].s_int_os_name[0] != 0)
    			    &&
        (1&(sts = om$os_internal_name_to_number (
        	     osname = ME.OMObjSpace->iso_d[ii].s_int_os_name, 
		     p_osnum = &target_OSnum))))
    {
      om$send (msg = message OMISO.fixup_for_write (), 
		  targetid = ME.OMObjSpace->iso_d[ii].iso_u.s_objid);
    }
  }
  return (OM_S_SUCCESS);
}



/*
   Bridge to find_iso method -- used by OMconnect.C to avoid having to 
   do a send in a non opp'd file
   Passes parameters to find_ISO method.
*/
som_ISOdir_find_iso(f_osn, t_osn, p_oid)
 OMuword f_osn;			/* this or "from" OS number */
 OMuword t_osn;			/* target OS number */
 OM_p_OBJID p_oid;		/* will contain  ISO oid in this OS whose
				   target is t_osn */
 {
  OM_p_OSD f_osp;

  if (f_osn >= OM_Gw_maxOS || (f_osp = OM_GA_OSDs[f_osn]) == NULL) {
    return(OM_E_NOSUCHOS);
  }
  return(om$send(msg = message OMObjSpace.find_iso(t_osn, p_oid),
		 senderid = 0,
		 targetid = f_osp->OSO_Oid, targetos = f_osn));
 }


/* 
   locate ISO in ISOdir for target os
   if successful return (via passed pointer) ISO objid

   OMuword t_osn - OS number of target object space.
   OM_p_OBJID    - will be used to store oid of ISO in current OS
		   with target OS equal to t_osn.
*/
method find_iso(OMuword t_osn; OM_p_OBJID p_oid)
 {
  struct ISOd_data *p_idir;
  char t_name[OM_K_MAXOSNAME_LEN], *int_name;
  int i, sts, vsz;

#ifdef DEBUG
  printf("ISOdir_find_iso fosn=%d tosn=%d\n",OM_Gw_current_OS,t_osn);
#endif

  /*  Check for special usage - if t_osn set to OM_K_OSNOTHERE (-1),
  **  then return internal_os_name for ISOdir entry which matches the
  **  iso_oid passed in via *p_oid
  */

  if (t_osn == (OMuword)OM_K_OSNOTHERE) {
     vsz = om$dimension_of(varray=ME.OMObjSpace->iso_d);
     p_idir = ME.OMObjSpace->iso_d;
     for (i=0; i < vsz; i++) {
        if (IF_EQ_OBJID(*p_oid,p_idir->iso_u.s_objid)) {
           break;
        }
        p_idir++;
     }
     if ( i == vsz ) {
       return(OM_E_NOSUCHOBJ); /* this ISO oid not found in ISOdir */
     }
     int_name = om$malloc (size = OM_K_MAXINTOSNAME_LEN);
     if (!int_name) return (OM_E_NODYNMEM);
     strcpy(int_name,p_idir->s_int_os_name);
     *p_oid = (OM_S_OBJID) int_name;
     return (OM_S_SUCCESS);
  }

  /*  OK - now back to the normal code - sorry for the interruption  */

  sts = om$os_number_to_internal_name(osnum = t_osn, osname = t_name);
  if (!(1&sts)) {
     return(sts);
  }
  {  /* remove any non printable characters */
  char *s;

  s = t_name;
  while ( *s ) {
     if ( ! isgraph(*s)) {
        *s = '?';
     }
     s++;
  }
  }
  vsz = om$dimension_of(varray=ME.OMObjSpace->iso_d);
  p_idir = ME.OMObjSpace->iso_d;
  for (i=0; i < vsz; i++) {
     if ( ! strcmp(p_idir->s_int_os_name,t_name)){
	 break;
     }
     p_idir++;
  }
  if ( i == vsz ) {
     return(OM_E_NOSUCHOBJ); /* ISO for target os not in ISOdir */
  }
  *p_oid = p_idir->iso_u.s_objid;
#ifdef DEBUG
  printf("ISOdir_find_iso - found oid=%d\n",*p_oid);
#endif
  return(OM_S_SUCCESS);
 }    


/*
   Bridge to get_iso method -- used by OMconnect.C to avoid doing 
   a send from a non opp'ed file.
*/
som_ISOdir_get_iso(f_osn, t_osn, p_oid)
 OMuword f_osn;			/* this or "from" OS number */	
 OMuword t_osn;			/* target OS number */
 OM_p_OBJID p_oid;		/* will contain oid of ISO linking
				   this to target OS */
 {
  OM_p_OSD f_osp;

  if (f_osn >= OM_Gw_maxOS || (f_osp = OM_GA_OSDs[f_osn]) == NULL) {
    return(OM_E_NOSUCHOS);
  }
  return(om$send(msg = message OMObjSpace.get_iso(t_osn, p_oid),
		 senderid = 0,
		 targetid = f_osp->OSO_Oid, targetos = f_osn));
 }


/*
   locate ISO in ISOdir for target os
   if no ISOdir make one - in both this and target os
   if no ISOdir entry for target make ISO objects in both os 
   if successful return (via passed pointer) ISO objid

   OMuword t_osn - OS number of target object space.
   OM_p_OBJID p_oid - used to store oid of linking ISO
*/
method get_iso(OMuword t_osn; OM_p_OBJID p_oid)
 {
  OM_S_OBJID  f_oid, t_oid;
  OM_p_OSD    t_osp;
  int sts;

#ifdef DEBUG
  printf("ISOdir_get_iso fosn=%d tosn=%d\n",OM_Gw_current_OS,t_osn);
#endif
  if (t_osn >= OM_Gw_maxOS || (t_osp = OM_GA_OSDs[t_osn]) == NULL) {
     return(OM_E_NOSUCHOS);
  }
	/* if ISO already exists - return pointer */
  sts = om$send(msg = message OMObjSpace.find_iso (t_osn, &f_oid),
		targetid = my_id);
  if ( sts == OM_S_SUCCESS ) {
     *p_oid = f_oid;
     return (sts);
  }
  else if ( sts != OM_E_NOSUCHOBJ ) {
     return (sts);  	/* something bad like no such os so quit */
  }
 	/* if ISO exists that is target for this os - thats bad */
  sts = om$send(msg = message OMObjSpace.find_iso(OM_Gw_current_OS, &t_oid),
		targetid = t_osp->OSO_Oid, targetos = t_osn);
  if ( sts == OM_S_SUCCESS ) {
     om$send ( msg = message OMISO.resolve_yourself("OuTrAgEoUs_NaMe"),
               targetid = t_oid,
               targetos = t_osn );
     sts = om$send(msg = message OMObjSpace.find_iso(OM_Gw_current_OS, &t_oid),
                   targetid = t_osp->OSO_Oid, targetos = t_osn);
     if ( sts == OM_S_SUCCESS ) {
        sts = om$send ( msg = message OMISO.unlink_all(),
                        targetid = t_oid,
                        targetos = t_osn );
        if (!(1&sts)) {
           printf("OMISOdir.get_iso::ISO.unlink_all fail\n");
           om$report_error(sts=sts);
           return(sts);
        }
     }
  }
  else if ( sts != OM_E_NOSUCHOBJ ) {
     return (sts);
  }
	/* construct an ISO pair - one in each os */
  if (!(1&(sts=som_ISO_construct(OM_Gw_current_OS, &f_oid)))) {
     BUGCHECK("som_ISOdir_get_iso: som_ISO_construct 1 fail");
     return (OM_F_BUGCHECK);
  }
  if (!(1&(sts=som_ISO_construct(t_osn, &t_oid)))) {
     BUGCHECK("som_ISOdir_get_iso: som_ISO_construct 2 fail");
     return (OM_F_BUGCHECK);
  }
  som_ISO_init_iso(OM_Gw_current_OS,f_oid, t_osn,t_oid);
  som_ISO_init_iso(t_osn,t_oid, OM_Gw_current_OS,f_oid);
	/* now stick each half of ISO pair in respective ISOdir */
  sts = om$send(msg = message OMObjSpace.make_iso_entry (f_oid, t_osn),
	        targetid = my_id);
  if (!(1 & sts)) {
     BUGCHECK("ISOdir_get_iso: ISOdir_make_iso_entry 1 fail");
     return (OM_F_BUGCHECK);
  }
  sts = om$send(msg=message OMObjSpace.make_iso_entry(t_oid, OM_Gw_current_OS),
		targetid = t_osp->OSO_Oid, targetos = t_osn);
  if (!( 1 & sts)) {
     BUGCHECK("ISOdir_get_iso: ISOdir_make_iso_entry 2 fail");
     return (OM_F_BUGCHECK);
  }
  *p_oid = f_oid;
#ifdef DEBUG
  printf("ISOdir_get_iso - return oid=%d,%d\n",OM_Gw_current_OS,*p_oid);
#endif
  return(OM_S_SUCCESS);
 }


/*
   add an ISO entry to ISOdir 
   ISOdir object will be created if none exists

   OM_S_OBJID iso_oid - oid of ISO object to be added to ISO directory.
   OMuword    t_osn   - OS number that is target of this ISO object.
*/
method make_iso_entry(OM_S_OBJID iso_oid; OMuword t_osn)
 {
  struct ISOd_data *p_idir;
  char t_name [OM_K_MAXOSNAME_LEN];
  int sz_idir, i;
  int sts;
		/* validate and point to os descriptors */
#ifdef DEBUG
  printf("ISOdir_make_entry called i_osn=%d i_oid=%d t_osn=%d\n",
			OM_Gw_current_OS,iso_oid,t_osn);
#endif
  sts = om$os_number_to_internal_name(osnum = t_osn, osname = t_name);
  if (!(1&sts)) {
    return(sts);
  }
  {  /* remove non printable characters */
  char *s;

  s = t_name;
  while ( *s ) {
     if ( ! isgraph(*s)) {
        *s = '?';
     }
     s++;
  }
  }
  sz_idir = om$dimension_of(varray=ME.OMObjSpace->iso_d);
		/* if var len array empty then make initial size */
  if ( ! sz_idir ) {
     om$vla_set_dimension(varray=ME.OMObjSpace->iso_d, size=OM_Gw_defISOdir_size);
     p_idir = ME.OMObjSpace->iso_d;
     sz_idir = om$dimension_of(varray=ME.OMObjSpace->iso_d);
     ME.OMObjSpace->FirstISO = 0;
     for (i=0; i < sz_idir; ) {
	p_idir->s_int_os_name[0] = '\0'; /* mark not in use */
	(p_idir++)->iso_u.i_next = ++i;
     }
     (p_idir-1)->iso_u.i_next = -1;
  }
	/* if new entry alread present - bugcheck */
  p_idir = ME.OMObjSpace->iso_d;
  for (i=0; i < sz_idir; i++) {
     if ( ! strcmp(p_idir->s_int_os_name,t_name)){
	 BUGCHECK("ISOdir_make_entry: entry already present");
	 return(OM_F_BUGCHECK);
     }
     p_idir++;
  }
	/* if no room for a new entry - extend VLA */
  if (ME.OMObjSpace->FirstISO < 0) { 
     om$vla_set_dimension(varray=ME.OMObjSpace->iso_d, 
                          size=(sz_idir + OM_Gw_defISOdir_ext));
     ME.OMObjSpace->FirstISO = sz_idir;
     p_idir = &ME.OMObjSpace->iso_d[sz_idir];
     sz_idir = om$dimension_of(varray=ME.OMObjSpace->iso_d);
     for (i=ME.OMObjSpace->FirstISO; i < sz_idir; ) {
	 p_idir->s_int_os_name[0] = '\0'; /* mark not in use */
	 (p_idir++)->iso_u.i_next = ++i;
     }
     (p_idir-1)->iso_u.i_next = -1; 
  }
  p_idir = &ME.OMObjSpace->iso_d[ME.OMObjSpace->FirstISO];
  ME.OMObjSpace->FirstISO = p_idir->iso_u.i_next;
  strncpy(p_idir->s_int_os_name,t_name,OM_K_MAXINTOSNAME_LEN);
  p_idir->iso_u.s_objid = iso_oid;
	/* if VLA was extended - cause object to be united */
#ifdef DEBUG
  printf("ISOdir_make_entry - vsz=%d\n",sz_idir);
#endif
  return(OM_S_SUCCESS);
 }    


/* 
   print contents of ISOdir

   flg - 0 then when printing director entries just print ISO oids.
       - != 0 then print contents of all ISO's in directory
*/
method print_isodir (int flg)
 {
  struct ISOd_data *p_idir;
  int i, vsz;

		/* validate and point to os descriptors */
  vsz = om$dimension_of(varray=ME.OMObjSpace->iso_d);
  PMSPRNTHDR
  (("------------ ISOdir for os=%d VLA_sz=%d oso_addr=0x%x ------------\n",
			OM_Gw_current_OS,vsz,me));
  p_idir = ME.OMObjSpace->iso_d;
  for (i=0; i < vsz; i++) {
     if (p_idir->s_int_os_name[0] != '\0') {
	PMSPRNT((" ISOdir entry=%d for %s",i,p_idir->s_int_os_name));
	if ( ! flg ) {
	   PMSPRNT((" iso_objid=%u\n",p_idir->iso_u.s_objid));
	}
	else {
	   if (!som_ISO_print(OM_Gw_current_OS, p_idir->iso_u.s_objid)) 
	    return (0);
	}
     }
     p_idir++;
  }
  return(1);
 }    


/* 
   Remove an ISO entry from ISOdir.
   If resulting ISOdir is empty - delete and delink.
   If available entries at end of VLA are less than extend size plus
     one - reduce size of VLA.
   Note: assumed that find_iso called successfully before this and
	 therefor osn is valid and ISOdir present.

   OM_S_OBJID i_oid - oid of ISO object to be removed from directory
*/
 method remove_iso (OM_S_OBJID i_oid)
 {
  struct ISOd_data *p_idir, *t_idir;
  int i, vsz, lndx, tndx;

#ifdef DEBUG
  printf("ISOdir_remove_iso osn=%d i_oid=%d\n",
			OM_Gw_current_OS,i_oid);
#endif
  vsz = om$dimension_of(varray=ME.OMObjSpace->iso_d);
  p_idir = ME.OMObjSpace->iso_d;
  t_idir = NULL;
  tndx   = 0;
  lndx   = -1;
  for (i=0; i < vsz; i++) {
    if (p_idir->s_int_os_name[0] != '\0') {
	if (IF_EQ_OBJID(i_oid, p_idir->iso_u.s_objid)) {
	   t_idir = p_idir;  /* point to entry to be removed */
	   tndx = i;         /* index of entry to be removed */
	}
	else {
	   lndx = i;   /* last valid entry index */  
	}
    }
    p_idir++;
  }
  if ( t_idir == NULL ) { /* did not find one to be removed */
#ifdef DEBUG
    printf("ISOdir_remove_iso: can't find entry\n");
    exit(1);
#endif
    BUGCHECK("ISOdir_remove_iso: can't find entry");
    return(OM_F_BUGCHECK);
  }
  t_idir->s_int_os_name[0] = '\0'; 	/* mark as empty */
  t_idir->iso_u.i_next = ME.OMObjSpace->FirstISO; /* add to avail link */
  ME.OMObjSpace->FirstISO = tndx;

  if ( lndx == -1 ) {  /* no entries left set VLA to zero */
    om$vla_set_dimension(varray=ME.OMObjSpace->iso_d, size=0);
  }
	/* perhaps should reduce size of VLA */
  else {
    if (++lndx < (int) OM_Gw_defISOdir_ext) {
      lndx = OM_Gw_defISOdir_ext;
    }
    if ((vsz - lndx) > (int) OM_Gw_defISOdir_ext) {
     while ((vsz - lndx) > (int) OM_Gw_defISOdir_ext) {
	  vsz -= OM_Gw_defISOdir_ext;
     }     
     om$vla_set_dimension(varray=ME.OMObjSpace->iso_d,size=vsz);
     ME.OMObjSpace->FirstISO = -1;   /* relink avail entries */
     vsz = om$dimension_of(varray=ME.OMObjSpace->iso_d) - 1;
     p_idir = &ME.OMObjSpace->iso_d[vsz];
     for (i=vsz; i >= 0; i--) {
	if (p_idir->s_int_os_name[0] == '\0') {
	   p_idir->iso_u.i_next = ME.OMObjSpace->FirstISO;
	   ME.OMObjSpace->FirstISO = i;
	}
	p_idir--;
     }
    }
  }
#ifdef DEBUG
  printf("xISOdir_remove_iso vsz=%d\n",vsz);
#endif
   return (OM_S_SUCCESS);
 }

end	implementation	OMObjSpace;
