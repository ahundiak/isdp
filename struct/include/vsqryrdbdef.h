/*
	I/STRUCT
*/
#ifndef vsqryrdbdef_include
#define vsqryrdbdef_include

#define VS_K_MAXDBNAME	64

/*
 * Type of queries which will be done by VSqryRdbCmd :
 * VS_K_BEAM_QY	: queries for beams or stiffeners.
 * VS_K_PLATE_QY: queries for plates.
 */
#define	VS_K_BEAM_QY	0
#define	VS_K_PLATE_QY	1

/*
 * Mask for `action' argument of message `loadAny' of class `VSqryRdbCmd'
 */
#define	VS_m_mat	0x01
#define	VS_m_grd	0x02
#define	VS_m_fam	0x04
#define	VS_m_prt	0x08
#define VS_m_par	0x10
#define VS_m_tot	0x20
#define VS_m_force	0x40

#endif
