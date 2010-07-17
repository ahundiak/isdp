/* --------------------------------------------------------------------
 * I/AIM
 *
 * File:	src/ppl/aimppl.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: aimppl.m,v $
 *	Revision 1.5  2002/05/10 21:55:57  tlstalli
 *	add showAimAssem.u to build
 *	
 *	Revision 1.4  2002/02/08 20:02:02  tlstalli
 *	TLS - AMDC Enhancements and fix for TR 5996
 *	
 *	Revision 1.3  2001/11/14 15:21:11  jdsauby
 *	JTSMP CR 5551, jds
 *	
 *	Revision 1.2  2001/10/29 17:25:58  jdsauby
 *	JTS MP CR 5522 - jds
 *	
 *	Revision 1.1.1.1  2001/06/01 20:06:27  tlstalli
 *	Creating aim module
 *	
 *	
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	02/28/01	tls		File Creation
 *	01/24/02	tls		Added procAimassem.u
 * -------------------------------------------------------------------*/

CCIOPT	-Xnoptrchk -Xnoargchk -m -q
CopyUID.u
getARs.u
NonInteract.u
VDpostconn.u
COz_ModTag.u
VDRefresh.u
aimstartup.u
CleanUID.u
CpSRRData.u
procAimAssem.u
chkSirTable.u
fixSirTable.u
showAimAssem.u
