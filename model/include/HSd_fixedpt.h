
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:56 $
$Locker:  $
*/

#ifndef HSd_fixedpt_include
#define HSd_fixedpt_include 1
/*
 *  Structure for fixed point arithmetic
 */
 
struct HSfixedpt
	{
	HSzbuf	active;
	int	d_whole;
	int	d_fract;
	int	running;
	int	sign;
	};

 
struct HSfixedpt_z
	{
	HSzbuf	active;
	int	running;
	};

 
struct HSfixedpt_dz
	{
	int	whole;
	int	fract;
	int	sign;
	};

/*
 *  Macro's for fixed point arithmetic
 */

#define Fixed_add( z )				\
						\
	{					\
	z.running += z.d_fract;			\
	z.active += ( z.d_whole * z.sign );	\
						\
	if( z.running < 0 )			\
		{				\
		z.active += z.sign;		\
		z.running &= 0x7fffffff;	\
		}				\
	}

#define Fixed_subtract( z )			\
						\
	{					\
	z.running -= z.d_fract;			\
	z.active -= ( z.d_whole * z.sign );	\
						\
	if (z.running < 0) {			\
		z.active -= z.sign;		\
		z.running &= 0x7fffffff;	\
	}					\
	}
#endif
