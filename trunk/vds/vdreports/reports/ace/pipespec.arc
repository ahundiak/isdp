    _               �      B       ��   
b   ��        ��   
k   ��        "��        %��   
m   )��   
o   ,��   
x   /��   
�   3��   
�   6��   
�   9��   
�   =��        @��        C��   
�   K��           S# o@FAoBb oC$�և�A60��Ax0	�oD ad$A60�oE
addoF$��ZoGad$����oJad oK��Z� ~oMdoN$oO�ad$�oPad� ~ oSHAZ��oUdoV$A%0�)oWad$A%0�eoXad$A%0��oYad$A%0��
A_0��oZad$A%0�)o[addo\$A)0��o]��ad$A)0�o^�1addo_$A)0�<�X�`o` ad$A)0�doa��ad$A)0��ob��ad$A)0���̈́`oc ad$A)0�ڇ��`od ad$A)0���`oe ad$A)0�,of�Had$A)0�Rog�nad$A)0�zoh��ad$A)0�����`oi ad$A)0�ˇ�`oj ad$A)0��� �okad$A)0�!�=�`ol ad$A)0�J�f�`om ad$A)0�p���`on ad$A)0�����`oo ad$A)0�ć��`op ad$A)0��oq�	ad$A)0�	or�	/ad$A)0�	:�	V� �osad$A)0�	a�	}�`ot ad$A)0�	��	��`ou ad�'ovFowb��oyFAo{bFo|�	�bF�	�o}bF�	�o~b�	�Z�	��	�Z��o�Fo��	�bF�	�o�b��o�Fo��	�bF�	�o�bF�	�o�b�	�A_�	�Z�		�Z�Ko�Fo��	�bF�	�o�b�Ko�F	o��	�bF
�	�o�bF�	�o�b�	�A_�	�Z�	Շ	�Z��o�F
o��	�bF�	�o�b��o�Fo��	�bF�	�o�bF�	�o�b�	�Z�	�	�Z��o�Fo��	�bF�	�o�b��o�Fo��	�b$��o�A0o����	� �	�o��	��	� o�A0o��	� �	�o��

�	� o�A0o��̈́
 o�A 0o��
o�A'0o��
%o�A.0o��
1o�A:0o�H�
 Ho�H�
> o�AC0o�HHo�Ho�AO0o�H	Ho�H
o�A[0o�H�
 Ho�H�
> o�Ac0o�Ho�At0o��
B�
K o�Ax0o��
P�
 o�A}0oÇ
X�
_o� a)d o�HZ�o�Foɇ	�bF�	�o�bF�	�o�b�	�Z�	��	�Z�)o�Fo·	�bF�	�o�b�)o�Fo҇	�bF�	�o�bF�	�o�b�	�A_�	�Z�		�Z�uo�Foׇ	�bF�	�o�b�uo�F	oۇ	�bF
�	�o�bF�	�o�b�	�A_�	�Z�	Շ	�Z��o�F
o��	�bF�	�o�b��o�Fo�	�bF�	�o�bF�	�o�b�	�Z�	�	�Z�o�Fo�	�bF�	�o�b�o�Fo�	�b$A0o���	� �	�o��	��	� o�A0o�	� �	�o�

�	� o�A0o��̈́
 o�A 0o��
o�A'0o��
%o�A.0o��
1o�A:0o�H�
 Ho�H�
> o�AC0� HH�H�AO0�H	H�H
�A[0�H�
 H�H�
> �Ac0�	H�
At0��
B�
K �Ax0��
P�
 �A}0��
X�
_� a(d��F�b �d 
� training12 specif newcomp pby p1 p2 rby r1 r2 sby s1 s2 eby e1 e2 geomstd pagenum Spec name>  pipespec.rpt select
   "nfmadmin".piping_spec.*, 
   comps.*,
   comps.comp_code aabbcc,
   "nfmadmin".piping_comp_type.*,
   geom.long_txt geo,
   ctype.long_txt cat
from
   "nfmadmin".piping_comps comps,
   "nfmadmin".piping_spec,
   outer "nfmadmin".piping_codelist geom,
   outer ("nfmadmin".piping_comp_type, outer "nfmadmin".piping_codelist ctype)
where
   "nfmadmin".piping_spec.spec_name= ?      			    and
   comps.spec_no="nfmadmin".piping_spec.spec_no  		    and
   (geom.list_num=575 and geom.code_num =comps.geom_std)    and
   (comps.comp_code="nfmadmin".piping_comp_type.comp_code and
   comps.short_code="nfmadmin".piping_comp_type.comp_shcode)           and
   (ctype.list_num=422 and ctype.code_num="nfmadmin".piping_comp_type.comp_rptcat)
order by
   comp_rptcat,
   aabbcc,
   size_g_low,
   size_r_low,
   opt_code
 comp_rptcat aabbcc size_g_low size_r_low opt_code Spec  :  spec_name -- PIPING COMPONENT LIST -- Page <<    DATE:  Comp   Size 1    Size 2    Opt Scode  Family Part        End Prep  Pr Rating   Sched/Thk   End Std Geom Standard    Mtl  Wtf Fc ====== ========= ========= === ====== ====== =========== ========  =========== =========== ======= ================ ==== === == cat ============= =========================================================== | P I P I N G    S P E C I F I C A T I O N    R E P O R T | |                                                         | |                  DATE:  | Specification Name       :  Service Description      :  serv_descr Components Table         :  spec_no ##& Generic Material Type    :  d_mtl_descr Default Fluid            :  d_flcode Bend Table               :  chgdir_tblno Branch Table             :  branch_tblno Adapter Table            :  adaptr_tblno Pipe Comp Code           :  dflt_pipe Conc Reducer Comp Code   :  dflt_conred Ecc Reducer Comp Code    :  dflt_eccred End Compatabilty Table   :  compat_tblno Min Pipe Length Table    :  minlen_tblno Default Gasket Thickness :  gask_sep &.&&& " Gasket Gap Table         :  gskgap_tblno Allowable Npd Table      :  npd_tblno Temp/Press Limits Table  :  tp_lim_tblno Materials Data Table     :  mtl_data_tblno Tap Properties Table     :  tap_tblno Wall Thickness Equation  :  wall_thk_eqn Vent/ Drain Assembly     :  vd_assmbly Corrosion Allowance      :  corr_allow General Note 1           :  note_a General Note 2           :  note_b prep_g   prep_r x rating_g rating_r sch_thk_g sch_thk_r end_std_g end_std_r geo ##.# - size_g_high size_r_high ### short_code family_name part_no_prfx <<< material #### wt_fctr fabcat ##                                                                       	 � ������ V� ���� � ��������� ��������� ��������
           l�              �� 