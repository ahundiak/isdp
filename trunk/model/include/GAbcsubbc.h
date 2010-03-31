#ifndef GAbcsubbc_h
#define GAbcsubbc_h 1

/*
 * Types 1-4 are used by the model space counterparts. Hence do not
 * use the same.
 */

#define GAbcsubbc_AScurve_by_data_reduction 5

struct GAbcsubbc_AScurve_by_data_reduction_info
{
#define GR_beginning_tangent 0x1
#define GR_end_tangent       0x2
#define GRis_periodic        0x4
 IGRchar props;
 IGRchar order;
 IGRdouble cht;
};

/*
 * This structure is used as a vehicle for communicating information
 * resulting from data reduction, fitting etc.
 */
struct EMfit_error_info
{
 IGRdouble average_error;
 IGRdouble max_error;
 IGRlong max_indicator;
 IGRpoint error_line[2];
};

struct GAbcsubbc_ASdirect_fit_curve
{
#define GR_preserve_beg_tangent 0x1
#define GR_preserve_end_tangent 0x2
#define GR_is_periodic 0x4
 IGRchar props;
 IGRchar order;
};
#endif
