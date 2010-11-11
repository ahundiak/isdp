/* Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved. */

# ifndef bsconic_include
# define bsconic_include

# define BSCIRCLE_NUM_SPANS      3
# define BSCIRCLE_NUM_POLES_MAX  7
# define BSCIRCLE_ORDER          3
# define BSCIRCLE_NUM_KNOTS_MAX (BSCIRCLE_NUM_POLES_MAX + BSCIRCLE_ORDER)

# define BSCNO_TYPE              0 /* cleverly FALSE */
/* The following must all be non-zero and non-one! */
# define BSCUNKNOWNTYPE         -1
# define BSCNOT_COPLANAR         2
# define BSCPARALLEL             3
# define BSCCOINCIDENT           4
# define BSCINTERSECTING         5
# define BSCPARABOLA             6
# define BSCHYPERBOLA            7
# define BSCELLIPSE              8
# define BSCCIRCLE               9
# define BSCOTHER               BSCLINE
# define BSCARCCIRCULAR         BSCCIRCLE
# define BSCARCPARABOLIC        BSCPARABOLA
# define BSCARCHYPERBOLIC       BSCHYPERBOLA
# define BSCARCELLIPTIC         BSCELLIPSE
# define BSCLINEINTER           14
# define BSCNONINTER            15
# define BSCPOINTINTER          16
# define BSC2LINESINTER         24
# define BSCLINE                17
# define BSCPOINT               18
# define BSURIGHTBND            19
# define BSULEFTBND             20
# define BSVRIGHTBND            21
# define BSVLEFTBND             22
# define BSUPLEFTCOR            25
# define BSUPRIGHTCOR           26
# define BSBTLEFTCOR            27
# define BSBTRIGHTCOR           28
# define BSUMINBNDK             29
# define BSUMAXBNDK             30
# define BSVMINBNDK             31
# define BSVMAXBNDK             32
# define BSUMINBNDR             33
# define BSUMAXBNDR             34
# define BSVMINBNDR             35
# define BSVMAXBNDR             36

# endif /* bsconic_include */
