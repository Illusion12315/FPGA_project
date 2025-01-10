
/*
* @Author       : Chen Xiong Zhi
* @Date         : 2022-08-16 08:39:08
* @LastEditTime : 2025-01-09 06:08:05
* @LastEditors  : Chen Xiong Zhi
* @Description  : jn807 reg map cfg
* @FilePath     : g:\project\JN807\new_build\srcs\reg_map\jn807_reg_map_cfg.v
*/

module jn807_reg_map_cfg
(
    //System
    input               sys_clk_i                   ,
    input               rst_n_i                     ,

    //Ram interface
    input               ram_wr_en_i                 ,
    input      [32-1:0] ram_wr_addr_i               ,
    input      [32-1:0] ram_wr_data_i               ,
    input               ram_rd_en_i                 ,
    input      [32-1:0] ram_rd_addr_i               ,
    output reg [32-1:0] ram_rd_data_o               ,

    //reg map
    output     [16-1:0] Workmod                     ,//output slv_reg001 Workmod [16-1:0]
    output     [16-1:0] Func                        ,//output slv_reg002 Func [16-1:0]
    output     [16-1:0] SENSE                       ,//output slv_reg003 SENSE [16-1:0]
    output     [16-1:0] Model                       ,//output slv_reg004 Model [16-1:0]
    output     [16-1:0] Worktype                    ,//output slv_reg005 Worktype [16-1:0]
    output     [16-1:0] M_S                         ,//output slv_reg006 M_S [16-1:0]
    output     [16-1:0] Clear_alarm                 ,//output slv_reg007 Clear_alarm [16-1:0]
    output     [16-1:0] RUN_flag                    ,//output slv_reg008 RUN_flag [16-1:0]
    output     [16-1:0] Short                       ,//output slv_reg009 Short [16-1:0]
    output     [32-1:0] Von                         ,//output slv_reg00a Von [32-1:0]
    output     [32-1:0] SR_slew                     ,//output slv_reg00b SR_slew [32-1:0]
    output     [32-1:0] SF_slew                     ,//output slv_reg00c SF_slew [32-1:0]
    output     [16-1:0] sense_err_threshold         ,//output slv_reg00d sense_err_threshold [16-1:0]
    output     [16-1:0] Von_Latch                   ,//output slv_reg00f Von_Latch [16-1:0]
    output     [32-1:0] Voff                        ,//output slv_reg010 Voff [32-1:0]
    output     [32-1:0] Iset_L                      ,//output slv_reg011 Iset_L [32-1:0]
    output     [32-1:0] Iset_H                      ,//output slv_reg012 Iset_H [32-1:0]
    output     [32-1:0] Vset_L                      ,//output slv_reg013 Vset_L [32-1:0]
    output     [32-1:0] Vset_H                      ,//output slv_reg014 Vset_H [32-1:0]
    output     [32-1:0] Pset_L                      ,//output slv_reg015 Pset_L [32-1:0]
    output     [32-1:0] Pset_H                      ,//output slv_reg016 Pset_H [32-1:0]
    output     [32-1:0] Rset_L                      ,//output slv_reg017 Rset_L [32-1:0]
    output     [32-1:0] Rset_H                      ,//output slv_reg018 Rset_H [32-1:0]
    output     [32-1:0] Iset1_L                     ,//output slv_reg019 Iset1_L [32-1:0]
    output     [32-1:0] Iset1_H                     ,//output slv_reg01a Iset1_H [32-1:0]
    output     [32-1:0] Iset2_L                     ,//output slv_reg01b Iset2_L [32-1:0]
    output     [32-1:0] Iset2_H                     ,//output slv_reg01c Iset2_H [32-1:0]
    output     [32-1:0] Vset1_L                     ,//output slv_reg01d Vset1_L [32-1:0]
    output     [32-1:0] Vset1_H                     ,//output slv_reg01e Vset1_H [32-1:0]
    output     [32-1:0] Vset2_L                     ,//output slv_reg01f Vset2_L [32-1:0]
    output     [32-1:0] Vset2_H                     ,//output slv_reg020 Vset2_H [32-1:0]
    output     [32-1:0] Pset1_L                     ,//output slv_reg021 Pset1_L [32-1:0]
    output     [32-1:0] Pset1_H                     ,//output slv_reg022 Pset1_H [32-1:0]
    output     [32-1:0] Pset2_L                     ,//output slv_reg023 Pset2_L [32-1:0]
    output     [32-1:0] Pset2_H                     ,//output slv_reg024 Pset2_H [32-1:0]
    output     [32-1:0] Rset1_L                     ,//output slv_reg025 Rset1_L [32-1:0]
    output     [32-1:0] Rset1_H                     ,//output slv_reg026 Rset1_H [32-1:0]
    output     [32-1:0] Rset2_L                     ,//output slv_reg027 Rset2_L [32-1:0]
    output     [32-1:0] Rset2_H                     ,//output slv_reg028 Rset2_H [32-1:0]
    output     [32-1:0] DR_slew                     ,//output slv_reg02d DR_slew [32-1:0]
    output     [32-1:0] DF_slew                     ,//output slv_reg02e DF_slew [32-1:0]
    output     [16-1:0] Vrange                      ,//output slv_reg02f Vrange [16-1:0]
    output     [32-1:0] CVspeed                     ,//output slv_reg030 CVspeed [32-1:0]
    output     [32-1:0] CV_slew                     ,//output slv_reg031 CV_slew [32-1:0]
    output     [32-1:0] filter_period               ,//output slv_reg033 filter_period [32-1:0]
    output     [32-1:0] num_paral                   ,//output slv_reg034 num_paral [32-1:0]
    output     [32-1:0] I_lim_L                     ,//output slv_reg041 I_lim_L [32-1:0]
    output     [32-1:0] I_lim_H                     ,//output slv_reg042 I_lim_H [32-1:0]
    output     [32-1:0] V_lim_L                     ,//output slv_reg043 V_lim_L [32-1:0]
    output     [32-1:0] V_lim_H                     ,//output slv_reg044 V_lim_H [32-1:0]
    output     [32-1:0] P_lim_L                     ,//output slv_reg045 P_lim_L [32-1:0]
    output     [32-1:0] P_lim_H                     ,//output slv_reg046 P_lim_H [32-1:0]
    output     [32-1:0] CV_lim_L                    ,//output slv_reg047 CV_lim_L [32-1:0]
    output     [32-1:0] CV_lim_H                    ,//output slv_reg048 CV_lim_H [32-1:0]
    output     [32-1:0] Pro_time                    ,//output slv_reg049 Pro_time [32-1:0]
    output     [32-1:0] VH_k                        ,//output slv_reg051 VH_k [32-1:0]
    output     [32-1:0] VH_a                        ,//output slv_reg052 VH_a [32-1:0]
    output     [32-1:0] VsH_k                       ,//output slv_reg053 VsH_k [32-1:0]
    output     [32-1:0] VsH_a                       ,//output slv_reg054 VsH_a [32-1:0]
    output     [32-1:0] I1_k                        ,//output slv_reg055 I1_k [32-1:0]
    output     [32-1:0] I1_a                        ,//output slv_reg056 I1_a [32-1:0]
    output     [32-1:0] I2_k                        ,//output slv_reg057 I2_k [32-1:0]
    output     [32-1:0] I2_a                        ,//output slv_reg058 I2_a [32-1:0]
    output     [32-1:0] VL_k                        ,//output slv_reg059 VL_k [32-1:0]
    output     [32-1:0] VL_a                        ,//output slv_reg05a VL_a [32-1:0]
    output     [32-1:0] VsL_k                       ,//output slv_reg05b VsL_k [32-1:0]
    output     [32-1:0] VsL_a                       ,//output slv_reg05c VsL_a [32-1:0]
    output     [32-1:0] It1_k                       ,//output slv_reg05d It1_k [32-1:0]
    output     [32-1:0] It1_a                       ,//output slv_reg05e It1_a [32-1:0]
    output     [32-1:0] It2_k                       ,//output slv_reg05f It2_k [32-1:0]
    output     [32-1:0] It2_a                       ,//output slv_reg060 It2_a [32-1:0]
    output     [32-1:0] CC_k                        ,//output slv_reg061 CC_k [32-1:0]
    output     [32-1:0] CC_a                        ,//output slv_reg062 CC_a [32-1:0]
    output     [32-1:0] CVH_k                       ,//output slv_reg063 CVH_k [32-1:0]
    output     [32-1:0] CVH_a                       ,//output slv_reg064 CVH_a [32-1:0]
    output     [32-1:0] CVL_k                       ,//output slv_reg065 CVL_k [32-1:0]
    output     [32-1:0] CVL_a                       ,//output slv_reg066 CVL_a [32-1:0]
    output     [32-1:0] CVHs_k                      ,//output slv_reg067 CVHs_k [32-1:0]
    output     [32-1:0] CVHs_a                      ,//output slv_reg068 CVHs_a [32-1:0]
    output     [32-1:0] CVLs_k                      ,//output slv_reg069 CVLs_k [32-1:0]
    output     [32-1:0] CVLs_a                      ,//output slv_reg06a CVLs_a [32-1:0]
    output     [32-1:0] s_k                         ,//output slv_reg06b s_k [32-1:0]
    output     [32-1:0] s_a                         ,//output slv_reg06c s_a [32-1:0]
    output     [32-1:0] m_k                         ,//output slv_reg06d m_k [32-1:0]
    output     [32-1:0] m_a                         ,//output slv_reg06e m_a [32-1:0]
    output     [32-1:0] f_k                         ,//output slv_reg06f f_k [32-1:0]
    output     [32-1:0] f_a                         ,//output slv_reg070 f_a [32-1:0]
    output     [32-1:0] CV_mode                     ,//output slv_reg071 CV_mode [32-1:0]
    output     [32-1:0] T1_L_cc                     ,//output slv_reg080 T1_L_cc [32-1:0]
    output     [32-1:0] T1_H_cc                     ,//output slv_reg086 T1_H_cc [32-1:0]
    output     [32-1:0] T2_L_cc                     ,//output slv_reg087 T2_L_cc [32-1:0]
    output     [32-1:0] T2_H_cc                     ,//output slv_reg088 T2_H_cc [32-1:0]
    output     [32-1:0] Dyn_trig_mode               ,//output slv_reg090 Dyn_trig_mode [32-1:0]
    output     [32-1:0] Dyn_trig_source             ,//output slv_reg091 Dyn_trig_source [32-1:0]
    output     [32-1:0] Dyn_trig_gen                ,//output slv_reg092 Dyn_trig_gen [32-1:0]
    output     [32-1:0] BT_STOP                     ,//output slv_reg0B1 BT_STOP [32-1:0]
    output     [32-1:0] VB_stop_L                   ,//output slv_reg0B3 VB_stop_L [32-1:0]
    output     [32-1:0] VB_stop_H                   ,//output slv_reg0B4 VB_stop_H [32-1:0]
    output     [32-1:0] TB_stop_L                   ,//output slv_reg0B5 TB_stop_L [32-1:0]
    output     [32-1:0] TB_stop_H                   ,//output slv_reg0B6 TB_stop_H [32-1:0]
    output     [32-1:0] CB_stop_L                   ,//output slv_reg0B7 CB_stop_L [32-1:0]
    output     [32-1:0] CB_stop_H                   ,//output slv_reg0B8 CB_stop_H [32-1:0]
    output     [32-1:0] VB_pro_L                    ,//output slv_reg0B9 VB_pro_L [32-1:0]
    output     [32-1:0] VB_pro_H                    ,//output slv_reg0Ba VB_pro_H [32-1:0]
    output     [32-1:0] TOCP_Von_set_L              ,//output slv_reg0C0 TOCP_Von_set_L [32-1:0]
    output     [32-1:0] TOCP_Von_set_H              ,//output slv_reg0C1 TOCP_Von_set_H [32-1:0]
    output     [32-1:0] TOCP_Istart_set_L           ,//output slv_reg0C2 TOCP_Istart_set_L [32-1:0]
    output     [32-1:0] TOCP_Istartl_set_H          ,//output slv_reg0C3 TOCP_Istartl_set_H [32-1:0]
    output     [32-1:0] TOCP_Icut_set_L             ,//output slv_reg0C4 TOCP_Icut_set_L [32-1:0]
    output     [32-1:0] TOCP_Icut_set_H             ,//output slv_reg0C5 TOCP_Icut_set_H [32-1:0]
    output     [32-1:0] TOCP_Istep_set              ,//output slv_reg0C6 TOCP_Istep_set [32-1:0]
    output     [32-1:0] TOCP_Tstep_set              ,//output slv_reg0C7 TOCP_Tstep_set [32-1:0]
    output     [32-1:0] TOCP_Vcut_set_L             ,//output slv_reg0C8 TOCP_Vcut_set_L [32-1:0]
    output     [32-1:0] TOCP_Vcut_set_H             ,//output slv_reg0C9 TOCP_Vcut_set_H [32-1:0]
    output     [32-1:0] TOCP_Imin_set_L             ,//output slv_reg0Ca TOCP_Imin_set_L [32-1:0]
    output     [32-1:0] TOCP_Imin_set_H             ,//output slv_reg0Cb TOCP_Imin_set_H [32-1:0]
    output     [32-1:0] TOCP_Imax_set_L             ,//output slv_reg0Cc TOCP_Imax_set_L [32-1:0]
    output     [32-1:0] TOCP_Imax_set_H             ,//output slv_reg0Cd TOCP_Imax_set_H [32-1:0]
    input      [32-1:0] TOCP_I_L                    ,//input slv_reg0CE TOCP_I_L [32-1:0]
    input      [32-1:0] TOCP_I_H                    ,//input slv_reg0CF TOCP_I_H [32-1:0]
    output     [32-1:0] TOPP_Von_set_L              ,//output slv_reg0D0 TOPP_Von_set_L  [32-1:0]
    output     [32-1:0] TOPP_Von_set_H              ,//output slv_reg0D1 TOPP_Von_set_H  [32-1:0]
    output     [32-1:0] TOPP_Pstart_set_L           ,//output slv_reg0D2 TOPP_Pstart_set_L [32-1:0]
    output     [32-1:0] TOPP_Pstart_set_H           ,//output slv_reg0D3 TOPP_Pstart_set_H [32-1:0]
    output     [32-1:0] TOPP_Pcut_set_L             ,//output slv_reg0D4 TOPP_Pcut_set_L [32-1:0]
    output     [32-1:0] TOPP_Pcut_set_H             ,//output slv_reg0D5 TOPP_Pcut_set_H [32-1:0]
    output     [32-1:0] TOPP_Pstep_set              ,//output slv_reg0D6 TOPP_Pstep_set [32-1:0]
    output     [32-1:0] TOPP_Tstep_set              ,//output slv_reg0D7 TOPP_Tstep_set [32-1:0]
    output     [32-1:0] TOPP_Vcut_set_L             ,//output slv_reg0D8 TOPP_Vcut_set_L [32-1:0]
    output     [32-1:0] TOPP_Vcut_set_H             ,//output slv_reg0D9 TOPP_Vcut_set_H [32-1:0]
    output     [32-1:0] TOPP_Pmin_set_L             ,//output slv_reg0Da TOPP_Pmin_set_L [32-1:0]
    output     [32-1:0] TOPP_Pmin_set_H             ,//output slv_reg0Db TOPP_Pmin_set_H [32-1:0]
    output     [32-1:0] TOPP_Pmax_set_L             ,//output slv_reg0Dc TOPP_Pmax_set_L [32-1:0]
    output     [32-1:0] TOPP_Pmax_set_H             ,//output slv_reg0Dd TOPP_Pmax_set_H [32-1:0]
    input      [32-1:0] TOPP_P_L                    ,//input slv_reg0De TOPP_P_L [32-1:0]
    input      [32-1:0] TOPP_P_H                    ,//input slv_reg0Df TOPP_P_H  [32-1:0]
    output     [32-1:0] Stepnum                     ,//output slv_reg0f1 Stepnum [32-1:0]
    output     [32-1:0] Count                       ,//output slv_reg0f2 Count [32-1:0]
    output     [32-1:0] Step                        ,//output slv_reg0f3 Step [32-1:0]
    output     [32-1:0] Mode                        ,//output slv_reg0f4 Mode [32-1:0]
    output     [32-1:0] Value_L                     ,//output slv_reg0f5 Value_L [32-1:0]
    output     [32-1:0] Value_H                     ,//output slv_reg0f6 Value_H [32-1:0]
    output     [32-1:0] Tstep_L                     ,//output slv_reg0f7 Tstep_L [32-1:0]
    output     [32-1:0] Tstep_H                     ,//output slv_reg0f8 Tstep_H [32-1:0]
    output     [32-1:0] Repeat                      ,//output slv_reg0f9 Repeat [32-1:0]
    output     [32-1:0] Goto                        ,//output slv_reg0fa Goto [32-1:0]
    output     [32-1:0] Loops                       ,//output slv_reg0fb Loops [32-1:0]
    output     [32-1:0] Save_step                   ,//output slv_reg0fc Save_step [32-1:0]
    input      [16-1:0] rd_Fault_status             ,//input rd_slv_reg000 rd_Fault_status [16-1:0]
    input      [16-1:0] rd_Workmod                  ,//input rd_slv_reg001 rd_Workmod [16-1:0]
    input      [16-1:0] rd_Func                     ,//input rd_slv_reg202 rd_Func [16-1:0]
    input      [16-1:0] rd_SENSE                    ,//input rd_slv_reg203 rd_SENSE [16-1:0]
    input      [16-1:0] rd_Model                    ,//input rd_slv_reg204 rd_Model [16-1:0]
    input      [16-1:0] rd_Worktype                 ,//input rd_slv_reg205 rd_Worktype [16-1:0]
    input      [16-1:0] rd_M_S                      ,//input rd_slv_reg206 rd_M_S [16-1:0]
    input      [16-1:0] rd_Clear_alarm              ,//input rd_slv_reg207 rd_Clear_alarm [16-1:0]
    input      [16-1:0] rd_Run_status               ,//input rd_slv_reg208 rd_Run_status [16-1:0]
    input      [16-1:0] rd_Short                    ,//input rd_slv_reg209 rd_Short [16-1:0]
    input      [32-1:0] rd_Von                      ,//input rd_slv_reg210 rd_Von [32-1:0]
    input      [32-1:0] rd_SR_slew                  ,//input rd_slv_reg211 rd_SR_slew [32-1:0]
    input      [32-1:0] rd_SF_slew                  ,//input rd_slv_reg212 rd_SF_slew [32-1:0]
    input      [16-1:0] rd_sense_err_threshold      ,//input rd_slv_reg213 rd_sense_err_threshold [16-1:0]
    input      [16-1:0] rd_Von_Latch                ,//input rd_slv_reg00f rd_Von_Latch [16-1:0]
    input      [32-1:0] rd_Voff                     ,//input rd_slv_reg010 rd_Voff [32-1:0]
    input      [32-1:0] rd_Iset_L                   ,//input rd_slv_reg011 rd_Iset_L [32-1:0]
    input      [32-1:0] rd_Iset_H                   ,//input rd_slv_reg012 rd_Iset_H [32-1:0]
    input      [32-1:0] rd_Vset_L                   ,//input rd_slv_reg013 rd_Vset_L [32-1:0]
    input      [32-1:0] rd_Vset_H                   ,//input rd_slv_reg014 rd_Vset_H [32-1:0]
    input      [32-1:0] rd_Pset_L                   ,//input rd_slv_reg015 rd_Pset_L [32-1:0]
    input      [32-1:0] rd_Pset_H                   ,//input rd_slv_reg016 rd_Pset_H [32-1:0]
    input      [32-1:0] rd_Rset_L                   ,//input rd_slv_reg017 rd_Rset_L [32-1:0]
    input      [32-1:0] rd_Rset_H                   ,//input rd_slv_reg018 rd_Rset_H [32-1:0]
    input      [32-1:0] rd_Iset1_L                  ,//input rd_slv_reg019 rd_Iset1_L [32-1:0]
    input      [32-1:0] rd_Iset1_H                  ,//input rd_slv_reg01a rd_Iset1_H [32-1:0]
    input      [32-1:0] rd_Iset2_L                  ,//input rd_slv_reg01b rd_Iset2_L [32-1:0]
    input      [32-1:0] rd_Iset2_H                  ,//input rd_slv_reg01c rd_Iset2_H [32-1:0]
    input      [32-1:0] rd_Vset1_L                  ,//input rd_slv_reg01d rd_Vset1_L [32-1:0]
    input      [32-1:0] rd_Vset1_H                  ,//input rd_slv_reg01e rd_Vset1_H [32-1:0]
    input      [32-1:0] rd_Vset2_L                  ,//input rd_slv_reg01f rd_Vset2_L [32-1:0]
    input      [32-1:0] rd_Vset2_H                  ,//input rd_slv_reg020 rd_Vset2_H [32-1:0]
    input      [32-1:0] rd_Pset1_L                  ,//input rd_slv_reg021 rd_Pset1_L [32-1:0]
    input      [32-1:0] rd_Pset1_H                  ,//input rd_slv_reg022 rd_Pset1_H [32-1:0]
    input      [32-1:0] rd_Pset2_L                  ,//input rd_slv_reg023 rd_Pset2_L [32-1:0]
    input      [32-1:0] rd_Pset2_H                  ,//input rd_slv_reg024 rd_Pset2_H [32-1:0]
    input      [32-1:0] rd_Rset1_L                  ,//input rd_slv_reg025 rd_Rset1_L [32-1:0]
    input      [32-1:0] rd_Rset1_H                  ,//input rd_slv_reg026 rd_Rset1_H [32-1:0]
    input      [32-1:0] rd_Rset2_L                  ,//input rd_slv_reg027 rd_Rset2_L [32-1:0]
    input      [32-1:0] rd_Rset2_H                  ,//input rd_slv_reg028 rd_Rset2_H [32-1:0]
    input      [32-1:0] rd_DR_slew                  ,//input rd_slv_reg02d rd_DR_slew [32-1:0]
    input      [32-1:0] rd_DF_slew                  ,//input rd_slv_reg02e rd_DF_slew [32-1:0]
    input      [16-1:0] rd_Vrange                   ,//input rd_slv_reg02f rd_Vrange [16-1:0]
    input      [32-1:0] rd_CVspeed                  ,//input rd_slv_reg030 rd_CVspeed [32-1:0]
    input      [32-1:0] rd_CV_slew                  ,//input rd_slv_reg031 rd_CV_slew [32-1:0]
    input      [32-1:0] rd_filter_period            ,//input rd_slv_reg033 rd_filter_period [32-1:0]
    input      [32-1:0] rd_num_paral                ,//input rd_slv_reg034 rd_num_paral [32-1:0]
    input      [32-1:0] rd_I_lim_L                  ,//input rd_slv_reg041 rd_I_lim_L [32-1:0]
    input      [32-1:0] rd_I_lim_H                  ,//input rd_slv_reg042 rd_I_lim_H [32-1:0]
    input      [32-1:0] rd_V_lim_L                  ,//input rd_slv_reg043 rd_V_lim_L [32-1:0]
    input      [32-1:0] rd_V_lim_H                  ,//input rd_slv_reg044 rd_V_lim_H [32-1:0]
    input      [32-1:0] rd_P_lim_L                  ,//input rd_slv_reg045 rd_P_lim_L [32-1:0]
    input      [32-1:0] rd_P_lim_H                  ,//input rd_slv_reg046 rd_P_lim_H [32-1:0]
    input      [32-1:0] rd_CV_lim_L                 ,//input rd_slv_reg047 rd_CV_lim_L [32-1:0]
    input      [32-1:0] rd_CV_lim_H                 ,//input rd_slv_reg048 rd_CV_lim_H [32-1:0]
    input      [32-1:0] rd_Pro_time                 ,//input rd_slv_reg049 rd_Pro_time [32-1:0]
    input      [32-1:0] rd_VH_k                     ,//input rd_slv_reg051 rd_VH_k [32-1:0]
    input      [32-1:0] rd_VH_a                     ,//input rd_slv_reg052 rd_VH_a [32-1:0]
    input      [32-1:0] rd_VsH_k                    ,//input rd_slv_reg053 rd_VsH_k [32-1:0]
    input      [32-1:0] rd_VsH_a                    ,//input rd_slv_reg054 rd_VsH_a [32-1:0]
    input      [32-1:0] rd_I1_k                     ,//input rd_slv_reg055 rd_I1_k [32-1:0]
    input      [32-1:0] rd_I1_a                     ,//input rd_slv_reg056 rd_I1_a [32-1:0]
    input      [32-1:0] rd_I2_k                     ,//input rd_slv_reg057 rd_I2_k [32-1:0]
    input      [32-1:0] rd_I2_a                     ,//input rd_slv_reg058 rd_I2_a [32-1:0]
    input      [32-1:0] rd_VL_k                     ,//input rd_slv_reg059 rd_VL_k [32-1:0]
    input      [32-1:0] rd_VL_a                     ,//input rd_slv_reg05a rd_VL_a [32-1:0]
    input      [32-1:0] rd_VsL_k                    ,//input rd_slv_reg05b rd_VsL_k [32-1:0]
    input      [32-1:0] rd_VsL_a                    ,//input rd_slv_reg05c rd_VsL_a [32-1:0]
    input      [32-1:0] rd_It1_k                    ,//input rd_slv_reg05d rd_It1_k [32-1:0]
    input      [32-1:0] rd_It1_a                    ,//input rd_slv_reg05e rd_It1_a [32-1:0]
    input      [32-1:0] rd_It2_k                    ,//input rd_slv_reg05f rd_It2_k [32-1:0]
    input      [32-1:0] rd_It2_a                    ,//input rd_slv_reg060 rd_It2_a [32-1:0]
    input      [32-1:0] rd_CC_k                     ,//input rd_slv_reg061 rd_CC_k [32-1:0]
    input      [32-1:0] rd_CC_a                     ,//input rd_slv_reg062 rd_CC_a [32-1:0]
    input      [32-1:0] rd_CVH_k                    ,//input rd_slv_reg063 rd_CVH_k [32-1:0]
    input      [32-1:0] rd_CVH_a                    ,//input rd_slv_reg064 rd_CVH_a [32-1:0]
    input      [32-1:0] rd_CVL_k                    ,//input rd_slv_reg065 rd_CVL_k [32-1:0]
    input      [32-1:0] rd_CVL_a                    ,//input rd_slv_reg066 rd_CVL_a [32-1:0]
    input      [32-1:0] rd_CVHs_k                   ,//input rd_slv_reg067 rd_CVHs_k [32-1:0]
    input      [32-1:0] rd_CVHs_a                   ,//input rd_slv_reg068 rd_CVHs_a [32-1:0]
    input      [32-1:0] rd_CVLs_k                   ,//input rd_slv_reg069 rd_CVLs_k [32-1:0]
    input      [32-1:0] rd_CVLs_a                   ,//input rd_slv_reg06a rd_CVLs_a [32-1:0]
    input      [32-1:0] rd_s_k                      ,//input rd_slv_reg06b rd_s_k [32-1:0]
    input      [32-1:0] rd_s_a                      ,//input rd_slv_reg06c rd_s_a [32-1:0]
    input      [32-1:0] rd_m_k                      ,//input rd_slv_reg06d rd_m_k [32-1:0]
    input      [32-1:0] rd_m_a                      ,//input rd_slv_reg06e rd_m_a [32-1:0]
    input      [32-1:0] rd_f_k                      ,//input rd_slv_reg06f rd_f_k [32-1:0]
    input      [32-1:0] rd_f_a                      ,//input rd_slv_reg070 rd_f_a [32-1:0]
    input      [32-1:0] rd_CV_mode                  ,//input rd_slv_reg071 rd_CV_mode [32-1:0]
    input      [32-1:0] rd_T1_L_cc                  ,//input rd_slv_reg080 rd_T1_L_cc [32-1:0]
    input      [32-1:0] rd_T1_H_cc                  ,//input rd_slv_reg086 rd_T1_H_cc [32-1:0]
    input      [32-1:0] rd_T2_L_cc                  ,//input rd_slv_reg087 rd_T2_L_cc [32-1:0]
    input      [32-1:0] rd_T2_H_cc                  ,//input rd_slv_reg088 rd_T2_H_cc [32-1:0]
    input      [32-1:0] rd_Dyn_trig_mode            ,//input rd_slv_reg090 rd_Dyn_trig_mode [32-1:0]
    input      [32-1:0] rd_Dyn_trig_source          ,//input rd_slv_reg091 rd_Dyn_trig_source [32-1:0]
    input      [32-1:0] rd_Dyn_trig_gen             ,//input rd_slv_reg092 rd_Dyn_trig_gen [32-1:0]
    input      [32-1:0] rd_BT_STOP                  ,//input rd_slv_reg0B1 rd_BT_STOP [32-1:0]
    input      [32-1:0] rd_VB_stop_L                ,//input rd_slv_reg0B3 rd_VB_stop_L [32-1:0]
    input      [32-1:0] rd_VB_stop_H                ,//input rd_slv_reg0B4 rd_VB_stop_H [32-1:0]
    input      [32-1:0] rd_TB_stop_L                ,//input rd_slv_reg0B5 rd_TB_stop_L [32-1:0]
    input      [32-1:0] rd_TB_stop_H                ,//input rd_slv_reg0B6 rd_TB_stop_H [32-1:0]
    input      [32-1:0] rd_CB_stop_L                ,//input rd_slv_reg0B7 rd_CB_stop_L [32-1:0]
    input      [32-1:0] rd_CB_stop_H                ,//input rd_slv_reg0B8 rd_CB_stop_H [32-1:0]
    input      [32-1:0] rd_VB_pro_L                 ,//input rd_slv_reg0B9 rd_VB_pro_L [32-1:0]
    input      [32-1:0] rd_VB_pro_H                 ,//input rd_slv_reg0Ba rd_VB_pro_H [32-1:0]
    input      [32-1:0] rd_TOCP_Von_set_L           ,//input rd_slv_reg0C0 rd_TOCP_Von_set_L [32-1:0]
    input      [32-1:0] rd_TOCP_Von_set_H           ,//input rd_slv_reg0C1 rd_TOCP_Von_set_H [32-1:0]
    input      [32-1:0] rd_TOCP_Istart_set_L        ,//input rd_slv_reg0C2 rd_TOCP_Istart_set_L [32-1:0]
    input      [32-1:0] rd_TOCP_Istartl_set_H       ,//input rd_slv_reg0C3 rd_TOCP_Istartl_set_H [32-1:0]
    input      [32-1:0] rd_TOCP_Icut_set_L          ,//input rd_slv_reg0C4 rd_TOCP_Icut_set_L [32-1:0]
    input      [32-1:0] rd_TOCP_Icut_set_H          ,//input rd_slv_reg0C5 rd_TOCP_Icut_set_H [32-1:0]
    input      [32-1:0] rd_TOCP_Istep_set           ,//input rd_slv_reg0C6 rd_TOCP_Istep_set [32-1:0]
    input      [32-1:0] rd_TOCP_Tstep_set           ,//input rd_slv_reg0C7 rd_TOCP_Tstep_set [32-1:0]
    input      [32-1:0] rd_TOCP_Vcut_set_L          ,//input rd_slv_reg0C8 rd_TOCP_Vcut_set_L [32-1:0]
    input      [32-1:0] rd_TOCP_Vcut_set_H          ,//input rd_slv_reg0C9 rd_TOCP_Vcut_set_H [32-1:0]
    input      [32-1:0] rd_TOCP_Imin_set_L          ,//input rd_slv_reg0Ca rd_TOCP_Imin_set_L [32-1:0]
    input      [32-1:0] rd_TOCP_Imin_set_H          ,//input rd_slv_reg0Cb rd_TOCP_Imin_set_H [32-1:0]
    input      [32-1:0] rd_TOCP_Imax_set_L          ,//input rd_slv_reg0Cc rd_TOCP_Imax_set_L [32-1:0]
    input      [32-1:0] rd_TOCP_Imax_set_H          ,//input rd_slv_reg0Cd rd_TOCP_Imax_set_H [32-1:0]
    input      [32-1:0] rd_TOCP_I_L                 ,//input rd_slv_reg0CE rd_TOCP_I_L [32-1:0]
    input      [32-1:0] rd_TOCP_result              ,//input rd_slv_reg0CF rd_TOCP_result [32-1:0]
    input      [32-1:0] rd_TOPP_Von_set_L           ,//input rd_slv_reg0D0 rd_TOPP_Von_set_L  [32-1:0]
    input      [32-1:0] rd_TOPP_Von_set_H           ,//input rd_slv_reg0D1 rd_TOPP_Von_set_H  [32-1:0]
    input      [32-1:0] rd_TOPP_Pstart_set_L        ,//input rd_slv_reg0D2 rd_TOPP_Pstart_set_L [32-1:0]
    input      [32-1:0] rd_TOPP_Pstart_set_H        ,//input rd_slv_reg0D3 rd_TOPP_Pstart_set_H [32-1:0]
    input      [32-1:0] rd_TOPP_Pcut_set_L          ,//input rd_slv_reg0D4 rd_TOPP_Pcut_set_L [32-1:0]
    input      [32-1:0] rd_TOPP_Pcut_set_H          ,//input rd_slv_reg0D5 rd_TOPP_Pcut_set_H [32-1:0]
    input      [32-1:0] rd_TOPP_Pstep_set           ,//input rd_slv_reg0D6 rd_TOPP_Pstep_set [32-1:0]
    input      [32-1:0] rd_TOPP_Tstep_set           ,//input rd_slv_reg0D7 rd_TOPP_Tstep_set [32-1:0]
    input      [32-1:0] rd_TOPP_Vcut_set_L          ,//input rd_slv_reg0D8 rd_TOPP_Vcut_set_L [32-1:0]
    input      [32-1:0] rd_TOPP_Vcut_set_H          ,//input rd_slv_reg0D9 rd_TOPP_Vcut_set_H [32-1:0]
    input      [32-1:0] rd_TOPP_Pmin_set_L          ,//input rd_slv_reg0Da rd_TOPP_Pmin_set_L [32-1:0]
    input      [32-1:0] rd_TOPP_Pmin_set_H          ,//input rd_slv_reg0Db rd_TOPP_Pmin_set_H [32-1:0]
    input      [32-1:0] rd_TOPP_Pmax_set_L          ,//input rd_slv_reg0Dc rd_TOPP_Pmax_set_L [32-1:0]
    input      [32-1:0] rd_TOPP_Pmax_set_H          ,//input rd_slv_reg0Dd rd_TOPP_Pmax_set_H [32-1:0]
    input      [32-1:0] rd_TOPP_P_L                 ,//input rd_slv_reg0De rd_TOPP_P_L [32-1:0]
    input      [32-1:0] rd_TOPP_result              ,//input rd_slv_reg0Df rd_TOPP_result [32-1:0]
    input      [32-1:0] rd_Stepnum                  ,//input rd_slv_reg0f1 rd_Stepnum [32-1:0]
    input      [32-1:0] rd_Count                    ,//input rd_slv_reg0f2 rd_Count [32-1:0]
    input      [32-1:0] rd_Step                     ,//input rd_slv_reg0f3 rd_Step [32-1:0]
    input      [32-1:0] rd_Mode                     ,//input rd_slv_reg0f4 rd_Mode [32-1:0]
    input      [32-1:0] rd_Value_L                  ,//input rd_slv_reg0f5 rd_Value_L [32-1:0]
    input      [32-1:0] rd_Value_H                  ,//input rd_slv_reg0f6 rd_Value_H [32-1:0]
    input      [32-1:0] rd_Tstep_L                  ,//input rd_slv_reg0f7 rd_Tstep_L [32-1:0]
    input      [32-1:0] rd_Tstep_H                  ,//input rd_slv_reg0f8 rd_Tstep_H [32-1:0]
    input      [32-1:0] rd_Repeat                   ,//input rd_slv_reg0f9 rd_Repeat [32-1:0]
    input      [32-1:0] rd_Goto                     ,//input rd_slv_reg0fa rd_Goto [32-1:0]
    input      [32-1:0] rd_Loops                    ,//input rd_slv_reg0fb rd_Loops [32-1:0]
    input      [32-1:0] rd_Repeat_now               ,//input rd_slv_reg0fc rd_Repeat_now [32-1:0]
    input      [32-1:0] rd_Count_now                ,//input rd_slv_reg0fd rd_Count_now [32-1:0]
    input      [32-1:0] rd_Step_now                 ,//input rd_slv_reg0fe rd_Step_now [32-1:0]
    input      [32-1:0] rd_Loops_now                ,//input rd_slv_reg0ff rd_Loops_now [32-1:0]
    input      [32-1:0] rd_I_Board_L_l              ,//input rd_slv_reg301 rd_I_Board_L_l [32-1:0]
    input      [32-1:0] rd_I_Board_L_h              ,//input rd_slv_reg302 rd_I_Board_L_h [32-1:0]
    input      [32-1:0] rd_I_Board_H_l              ,//input rd_slv_reg303 rd_I_Board_H_l [32-1:0]
    input      [32-1:0] rd_I_Board_H_h              ,//input rd_slv_reg304 rd_I_Board_H_h [32-1:0]
    input      [32-1:0] rd_I_SUM_Total_L_l          ,//input rd_slv_reg305 rd_I_SUM_Total_L_l [32-1:0]
    input      [32-1:0] rd_I_SUM_Total_L_h          ,//input rd_slv_reg306 rd_I_SUM_Total_L_h [32-1:0]
    input      [32-1:0] rd_I_SUM_Total_H_l          ,//input rd_slv_reg307 rd_I_SUM_Total_H_l [32-1:0]
    input      [32-1:0] rd_I_SUM_Total_H_h          ,//input rd_slv_reg308 rd_I_SUM_Total_H_h [32-1:0]
    input      [32-1:0] rd_I_Board_unit_l           ,//input rd_slv_reg309 rd_I_Board_unit_l [32-1:0]
    input      [32-1:0] rd_I_Board_unit_h           ,//input rd_slv_reg30a rd_I_Board_unit_h [32-1:0]
    input      [32-1:0] rd_I_Sum_unit_l             ,//input rd_slv_reg30b rd_I_Sum_unit_l [32-1:0]
    input      [32-1:0] rd_I_Sum_unit_h             ,//input rd_slv_reg30c rd_I_Sum_unit_h [32-1:0]
    input      [32-1:0] rd_P_rt                     ,//input rd_slv_reg30e rd_P_rt [32-1:0]
    input      [32-1:0] rd_R_rt                     ,//input rd_slv_reg30f rd_R_rt [32-1:0]
    input      [32-1:0] rd_V_L                      ,//input rd_slv_reg311 rd_V_L [32-1:0]
    input      [32-1:0] rd_V_H                      ,//input rd_slv_reg312 rd_V_H [32-1:0]
    input      [32-1:0] rd_I_L                      ,//input rd_slv_reg313 rd_I_L [32-1:0]
    input      [32-1:0] rd_I_H                      ,//input rd_slv_reg314 rd_I_H [32-1:0]
    input      [32-1:0] Vopen_L                     ,//input rd_slv_reg3b1 Vopen_L [32-1:0]
    input      [32-1:0] Vopen_H                     ,//input rd_slv_reg3b2 Vopen_H [32-1:0]
    input      [32-1:0] Ri_L                        ,//input rd_slv_reg3b3 Ri_L [32-1:0]
    input      [32-1:0] Ri_H                        ,//input rd_slv_reg3b4 Ri_H [32-1:0]
    input      [32-1:0] TB_L                        ,//input rd_slv_reg3b5 TB_L [32-1:0]
    input      [32-1:0] TB_H                        ,//input rd_slv_reg3b6 TB_H [32-1:0]
    input      [32-1:0] Cap1_L                      ,//input rd_slv_reg3b7 Cap1_L [32-1:0]
    input      [32-1:0] Cap1_H                      ,//input rd_slv_reg3b8 Cap1_H [32-1:0]
    input      [32-1:0] Cap2_L                      ,//input rd_slv_reg3b9 Cap2_L [32-1:0]
    input      [32-1:0] Cap2_H                      ,//input rd_slv_reg3ba Cap2_H [32-1:0]
    input      [32-1:0] Tpro_L                      ,//input rd_slv_reg3bb Tpro_L [32-1:0]
    input      [32-1:0] Tpro_H                      ,//input rd_slv_reg3bc Tpro_H [32-1:0]
    input      [32-1:0] temperature_0               ,//input rd_slv_reg3c1 temperature_0 [32-1:0]
    input      [32-1:0] temperature_1               ,//input rd_slv_reg3c2 temperature_1 [32-1:0]
    input      [32-1:0] temperature_2               ,//input rd_slv_reg3c3 temperature_2 [32-1:0]
    input      [32-1:0] temperature_3               ,//input rd_slv_reg3c4 temperature_3 [32-1:0]
    input      [32-1:0] temperature_4               ,//input rd_slv_reg3c5 temperature_4 [32-1:0]
    input      [32-1:0] temperature_5               ,//input rd_slv_reg3c6 temperature_5 [32-1:0]
    input      [32-1:0] temperature_6               ,//input rd_slv_reg3c7 temperature_6 [32-1:0]
    input      [32-1:0] temperature_7               ,//input rd_slv_reg3c8 temperature_7 [32-1:0]
    input      [32-1:0] SUM_UNIT_0                  ,//input rd_slv_reg3d1 SUM_UNIT_0 [32-1:0]
    input      [32-1:0] SUM_UNIT_1                  ,//input rd_slv_reg3d2 SUM_UNIT_1 [32-1:0]
    input      [32-1:0] SUM_UNIT_2                  ,//input rd_slv_reg3d3 SUM_UNIT_2 [32-1:0]
    input      [32-1:0] SUM_UNIT_3                  ,//input rd_slv_reg3d4 SUM_UNIT_3 [32-1:0]
    input      [32-1:0] SUM_UNIT_4                  ,//input rd_slv_reg3d5 SUM_UNIT_4 [32-1:0]
    input      [32-1:0] SUM_UNIT_5                  ,//input rd_slv_reg3d6 SUM_UNIT_5 [32-1:0]
    input      [32-1:0] SUM_UNIT_6                  ,//input rd_slv_reg3d7 SUM_UNIT_6 [32-1:0]
    input      [32-1:0] SUM_UNIT_7                  ,//input rd_slv_reg3d8 SUM_UNIT_7 [32-1:0]
    input      [32-1:0] BOARD_UNIT_0                ,//input rd_slv_reg3e1 BOARD_UNIT_0 [32-1:0]
    input      [32-1:0] BOARD_UNIT_1                ,//input rd_slv_reg3e2 BOARD_UNIT_1 [32-1:0]
    input      [32-1:0] BOARD_UNIT_2                ,//input rd_slv_reg3e3 BOARD_UNIT_2 [32-1:0]
    input      [32-1:0] BOARD_UNIT_3                ,//input rd_slv_reg3e4 BOARD_UNIT_3 [32-1:0]
    input      [32-1:0] BOARD_UNIT_4                ,//input rd_slv_reg3e5 BOARD_UNIT_4 [32-1:0]
    input      [32-1:0] BOARD_UNIT_5                ,//input rd_slv_reg3e6 BOARD_UNIT_5 [32-1:0]
    input      [32-1:0] BOARD_UNIT_6                ,//input rd_slv_reg3e7 BOARD_UNIT_6 [32-1:0]
    input      [32-1:0] BOARD_UNIT_7                ,//input rd_slv_reg3e8 BOARD_UNIT_7 [32-1:0]
    input      [32-1:0] Version_number               //input rd_slv_reg3ff Version_number [32-1:0]
);

//----------------------------local parameter---------------------------------------------
localparam SLV_REG001    = 32'h0   + 32'h4  ;
localparam SLV_REG002    = 32'h0   + 32'h8  ;
localparam SLV_REG003    = 32'h0   + 32'hc  ;
localparam SLV_REG004    = 32'h0   + 32'h10 ;
localparam SLV_REG005    = 32'h0   + 32'h14 ;
localparam SLV_REG006    = 32'h0   + 32'h18 ;
localparam SLV_REG007    = 32'h0   + 32'h1c ;
localparam SLV_REG008    = 32'h0   + 32'h20 ;
localparam SLV_REG009    = 32'h0   + 32'h24 ;
localparam SLV_REG00A    = 32'h0   + 32'h28 ;
localparam SLV_REG00B    = 32'h0   + 32'h2c ;
localparam SLV_REG00C    = 32'h0   + 32'h30 ;
localparam SLV_REG00D    = 32'h0   + 32'h34 ;
localparam SLV_REG00F    = 32'h0   + 32'h3c ;
localparam SLV_REG010    = 32'h0   + 32'h40 ;
localparam SLV_REG011    = 32'h0   + 32'h44 ;
localparam SLV_REG012    = 32'h0   + 32'h48 ;
localparam SLV_REG013    = 32'h0   + 32'h4c ;
localparam SLV_REG014    = 32'h0   + 32'h50 ;
localparam SLV_REG015    = 32'h0   + 32'h54 ;
localparam SLV_REG016    = 32'h0   + 32'h58 ;
localparam SLV_REG017    = 32'h0   + 32'h5c ;
localparam SLV_REG018    = 32'h0   + 32'h60 ;
localparam SLV_REG019    = 32'h0   + 32'h64 ;
localparam SLV_REG01A    = 32'h0   + 32'h68 ;
localparam SLV_REG01B    = 32'h0   + 32'h6c ;
localparam SLV_REG01C    = 32'h0   + 32'h70 ;
localparam SLV_REG01D    = 32'h0   + 32'h74 ;
localparam SLV_REG01E    = 32'h0   + 32'h78 ;
localparam SLV_REG01F    = 32'h0   + 32'h7c ;
localparam SLV_REG020    = 32'h0   + 32'h80 ;
localparam SLV_REG021    = 32'h0   + 32'h84 ;
localparam SLV_REG022    = 32'h0   + 32'h88 ;
localparam SLV_REG023    = 32'h0   + 32'h8c ;
localparam SLV_REG024    = 32'h0   + 32'h90 ;
localparam SLV_REG025    = 32'h0   + 32'h94 ;
localparam SLV_REG026    = 32'h0   + 32'h98 ;
localparam SLV_REG027    = 32'h0   + 32'h9c ;
localparam SLV_REG028    = 32'h0   + 32'ha0 ;
localparam SLV_REG02D    = 32'h0   + 32'hb4 ;
localparam SLV_REG02E    = 32'h0   + 32'hb8 ;
localparam SLV_REG02F    = 32'h0   + 32'hbc ;
localparam SLV_REG030    = 32'h0   + 32'hc0 ;
localparam SLV_REG031    = 32'h0   + 32'hc4 ;
localparam SLV_REG033    = 32'h0   + 32'hcc ;
localparam SLV_REG034    = 32'h0   + 32'hd0 ;
localparam SLV_REG041    = 32'h0   + 32'h104;
localparam SLV_REG042    = 32'h0   + 32'h108;
localparam SLV_REG043    = 32'h0   + 32'h10c;
localparam SLV_REG044    = 32'h0   + 32'h110;
localparam SLV_REG045    = 32'h0   + 32'h114;
localparam SLV_REG046    = 32'h0   + 32'h118;
localparam SLV_REG047    = 32'h0   + 32'h11c;
localparam SLV_REG048    = 32'h0   + 32'h120;
localparam SLV_REG049    = 32'h0   + 32'h124;
localparam SLV_REG051    = 32'h0   + 32'h144;
localparam SLV_REG052    = 32'h0   + 32'h148;
localparam SLV_REG053    = 32'h0   + 32'h14c;
localparam SLV_REG054    = 32'h0   + 32'h150;
localparam SLV_REG055    = 32'h0   + 32'h154;
localparam SLV_REG056    = 32'h0   + 32'h158;
localparam SLV_REG057    = 32'h0   + 32'h15c;
localparam SLV_REG058    = 32'h0   + 32'h160;
localparam SLV_REG059    = 32'h0   + 32'h164;
localparam SLV_REG05A    = 32'h0   + 32'h168;
localparam SLV_REG05B    = 32'h0   + 32'h16c;
localparam SLV_REG05C    = 32'h0   + 32'h170;
localparam SLV_REG05D    = 32'h0   + 32'h174;
localparam SLV_REG05E    = 32'h0   + 32'h178;
localparam SLV_REG05F    = 32'h0   + 32'h17c;
localparam SLV_REG060    = 32'h0   + 32'h180;
localparam SLV_REG061    = 32'h0   + 32'h184;
localparam SLV_REG062    = 32'h0   + 32'h188;
localparam SLV_REG063    = 32'h0   + 32'h18c;
localparam SLV_REG064    = 32'h0   + 32'h190;
localparam SLV_REG065    = 32'h0   + 32'h194;
localparam SLV_REG066    = 32'h0   + 32'h198;
localparam SLV_REG067    = 32'h0   + 32'h19c;
localparam SLV_REG068    = 32'h0   + 32'h1a0;
localparam SLV_REG069    = 32'h0   + 32'h1a4;
localparam SLV_REG06A    = 32'h0   + 32'h1a8;
localparam SLV_REG06B    = 32'h0   + 32'h1ac;
localparam SLV_REG06C    = 32'h0   + 32'h1b0;
localparam SLV_REG06D    = 32'h0   + 32'h1b4;
localparam SLV_REG06E    = 32'h0   + 32'h1b8;
localparam SLV_REG06F    = 32'h0   + 32'h1bc;
localparam SLV_REG070    = 32'h0   + 32'h1c0;
localparam SLV_REG071    = 32'h0   + 32'h1c4;
localparam SLV_REG080    = 32'h0   + 32'h200;
localparam SLV_REG086    = 32'h0   + 32'h218;
localparam SLV_REG087    = 32'h0   + 32'h21c;
localparam SLV_REG088    = 32'h0   + 32'h220;
localparam SLV_REG090    = 32'h0   + 32'h240;
localparam SLV_REG091    = 32'h0   + 32'h244;
localparam SLV_REG092    = 32'h0   + 32'h248;
localparam SLV_REG0B1    = 32'h0   + 32'h2c4;
localparam SLV_REG0B3    = 32'h0   + 32'h2cc;
localparam SLV_REG0B4    = 32'h0   + 32'h2d0;
localparam SLV_REG0B5    = 32'h0   + 32'h2d4;
localparam SLV_REG0B6    = 32'h0   + 32'h2d8;
localparam SLV_REG0B7    = 32'h0   + 32'h2dc;
localparam SLV_REG0B8    = 32'h0   + 32'h2e0;
localparam SLV_REG0B9    = 32'h0   + 32'h2e4;
localparam SLV_REG0BA    = 32'h0   + 32'h2e8;
localparam SLV_REG0C0    = 32'h0   + 32'h300;
localparam SLV_REG0C1    = 32'h0   + 32'h304;
localparam SLV_REG0C2    = 32'h0   + 32'h308;
localparam SLV_REG0C3    = 32'h0   + 32'h30c;
localparam SLV_REG0C4    = 32'h0   + 32'h310;
localparam SLV_REG0C5    = 32'h0   + 32'h314;
localparam SLV_REG0C6    = 32'h0   + 32'h318;
localparam SLV_REG0C7    = 32'h0   + 32'h31c;
localparam SLV_REG0C8    = 32'h0   + 32'h320;
localparam SLV_REG0C9    = 32'h0   + 32'h324;
localparam SLV_REG0CA    = 32'h0   + 32'h328;
localparam SLV_REG0CB    = 32'h0   + 32'h32c;
localparam SLV_REG0CC    = 32'h0   + 32'h330;
localparam SLV_REG0CD    = 32'h0   + 32'h334;
localparam SLV_REG0CE    = 32'h0   + 32'h338;
localparam SLV_REG0CF    = 32'h0   + 32'h33c;
localparam SLV_REG0D0    = 32'h0   + 32'h340;
localparam SLV_REG0D1    = 32'h0   + 32'h344;
localparam SLV_REG0D2    = 32'h0   + 32'h348;
localparam SLV_REG0D3    = 32'h0   + 32'h34c;
localparam SLV_REG0D4    = 32'h0   + 32'h350;
localparam SLV_REG0D5    = 32'h0   + 32'h354;
localparam SLV_REG0D6    = 32'h0   + 32'h358;
localparam SLV_REG0D7    = 32'h0   + 32'h35c;
localparam SLV_REG0D8    = 32'h0   + 32'h360;
localparam SLV_REG0D9    = 32'h0   + 32'h364;
localparam SLV_REG0DA    = 32'h0   + 32'h368;
localparam SLV_REG0DB    = 32'h0   + 32'h36c;
localparam SLV_REG0DC    = 32'h0   + 32'h370;
localparam SLV_REG0DD    = 32'h0   + 32'h374;
localparam SLV_REG0DE    = 32'h0   + 32'h378;
localparam SLV_REG0DF    = 32'h0   + 32'h37c;
localparam SLV_REG0F1    = 32'h0   + 32'h3c4;
localparam SLV_REG0F2    = 32'h0   + 32'h3c8;
localparam SLV_REG0F3    = 32'h0   + 32'h3cc;
localparam SLV_REG0F4    = 32'h0   + 32'h3d0;
localparam SLV_REG0F5    = 32'h0   + 32'h3d4;
localparam SLV_REG0F6    = 32'h0   + 32'h3d8;
localparam SLV_REG0F7    = 32'h0   + 32'h3dc;
localparam SLV_REG0F8    = 32'h0   + 32'h3e0;
localparam SLV_REG0F9    = 32'h0   + 32'h3e4;
localparam SLV_REG0FA    = 32'h0   + 32'h3e8;
localparam SLV_REG0FB    = 32'h0   + 32'h3ec;
localparam SLV_REG0FC    = 32'h0   + 32'h3f0;
localparam RD_SLV_REG000 = 32'h800 + 32'h0  ;
localparam RD_SLV_REG001 = 32'h800 + 32'h4  ;
localparam RD_SLV_REG202 = 32'h800 + 32'h808;
localparam RD_SLV_REG203 = 32'h800 + 32'h80c;
localparam RD_SLV_REG204 = 32'h800 + 32'h810;
localparam RD_SLV_REG205 = 32'h800 + 32'h814;
localparam RD_SLV_REG206 = 32'h800 + 32'h818;
localparam RD_SLV_REG207 = 32'h800 + 32'h81c;
localparam RD_SLV_REG208 = 32'h800 + 32'h820;
localparam RD_SLV_REG209 = 32'h800 + 32'h824;
localparam RD_SLV_REG210 = 32'h800 + 32'h840;
localparam RD_SLV_REG211 = 32'h800 + 32'h844;
localparam RD_SLV_REG212 = 32'h800 + 32'h848;
localparam RD_SLV_REG213 = 32'h800 + 32'h84c;
localparam RD_SLV_REG00F = 32'h800 + 32'h3c ;
localparam RD_SLV_REG010 = 32'h800 + 32'h40 ;
localparam RD_SLV_REG011 = 32'h800 + 32'h44 ;
localparam RD_SLV_REG012 = 32'h800 + 32'h48 ;
localparam RD_SLV_REG013 = 32'h800 + 32'h4c ;
localparam RD_SLV_REG014 = 32'h800 + 32'h50 ;
localparam RD_SLV_REG015 = 32'h800 + 32'h54 ;
localparam RD_SLV_REG016 = 32'h800 + 32'h58 ;
localparam RD_SLV_REG017 = 32'h800 + 32'h5c ;
localparam RD_SLV_REG018 = 32'h800 + 32'h60 ;
localparam RD_SLV_REG019 = 32'h800 + 32'h64 ;
localparam RD_SLV_REG01A = 32'h800 + 32'h68 ;
localparam RD_SLV_REG01B = 32'h800 + 32'h6c ;
localparam RD_SLV_REG01C = 32'h800 + 32'h70 ;
localparam RD_SLV_REG01D = 32'h800 + 32'h74 ;
localparam RD_SLV_REG01E = 32'h800 + 32'h78 ;
localparam RD_SLV_REG01F = 32'h800 + 32'h7c ;
localparam RD_SLV_REG020 = 32'h800 + 32'h80 ;
localparam RD_SLV_REG021 = 32'h800 + 32'h84 ;
localparam RD_SLV_REG022 = 32'h800 + 32'h88 ;
localparam RD_SLV_REG023 = 32'h800 + 32'h8c ;
localparam RD_SLV_REG024 = 32'h800 + 32'h90 ;
localparam RD_SLV_REG025 = 32'h800 + 32'h94 ;
localparam RD_SLV_REG026 = 32'h800 + 32'h98 ;
localparam RD_SLV_REG027 = 32'h800 + 32'h9c ;
localparam RD_SLV_REG028 = 32'h800 + 32'ha0 ;
localparam RD_SLV_REG02D = 32'h800 + 32'hb4 ;
localparam RD_SLV_REG02E = 32'h800 + 32'hb8 ;
localparam RD_SLV_REG02F = 32'h800 + 32'hbc ;
localparam RD_SLV_REG030 = 32'h800 + 32'hc0 ;
localparam RD_SLV_REG031 = 32'h800 + 32'hc4 ;
localparam RD_SLV_REG033 = 32'h800 + 32'hcc ;
localparam RD_SLV_REG034 = 32'h800 + 32'hd0 ;
localparam RD_SLV_REG041 = 32'h800 + 32'h104;
localparam RD_SLV_REG042 = 32'h800 + 32'h108;
localparam RD_SLV_REG043 = 32'h800 + 32'h10c;
localparam RD_SLV_REG044 = 32'h800 + 32'h110;
localparam RD_SLV_REG045 = 32'h800 + 32'h114;
localparam RD_SLV_REG046 = 32'h800 + 32'h118;
localparam RD_SLV_REG047 = 32'h800 + 32'h11c;
localparam RD_SLV_REG048 = 32'h800 + 32'h120;
localparam RD_SLV_REG049 = 32'h800 + 32'h124;
localparam RD_SLV_REG051 = 32'h800 + 32'h144;
localparam RD_SLV_REG052 = 32'h800 + 32'h148;
localparam RD_SLV_REG053 = 32'h800 + 32'h14c;
localparam RD_SLV_REG054 = 32'h800 + 32'h150;
localparam RD_SLV_REG055 = 32'h800 + 32'h154;
localparam RD_SLV_REG056 = 32'h800 + 32'h158;
localparam RD_SLV_REG057 = 32'h800 + 32'h15c;
localparam RD_SLV_REG058 = 32'h800 + 32'h160;
localparam RD_SLV_REG059 = 32'h800 + 32'h164;
localparam RD_SLV_REG05A = 32'h800 + 32'h168;
localparam RD_SLV_REG05B = 32'h800 + 32'h16c;
localparam RD_SLV_REG05C = 32'h800 + 32'h170;
localparam RD_SLV_REG05D = 32'h800 + 32'h174;
localparam RD_SLV_REG05E = 32'h800 + 32'h178;
localparam RD_SLV_REG05F = 32'h800 + 32'h17c;
localparam RD_SLV_REG060 = 32'h800 + 32'h180;
localparam RD_SLV_REG061 = 32'h800 + 32'h184;
localparam RD_SLV_REG062 = 32'h800 + 32'h188;
localparam RD_SLV_REG063 = 32'h800 + 32'h18c;
localparam RD_SLV_REG064 = 32'h800 + 32'h190;
localparam RD_SLV_REG065 = 32'h800 + 32'h194;
localparam RD_SLV_REG066 = 32'h800 + 32'h198;
localparam RD_SLV_REG067 = 32'h800 + 32'h19c;
localparam RD_SLV_REG068 = 32'h800 + 32'h1a0;
localparam RD_SLV_REG069 = 32'h800 + 32'h1a4;
localparam RD_SLV_REG06A = 32'h800 + 32'h1a8;
localparam RD_SLV_REG06B = 32'h800 + 32'h1ac;
localparam RD_SLV_REG06C = 32'h800 + 32'h1b0;
localparam RD_SLV_REG06D = 32'h800 + 32'h1b4;
localparam RD_SLV_REG06E = 32'h800 + 32'h1b8;
localparam RD_SLV_REG06F = 32'h800 + 32'h1bc;
localparam RD_SLV_REG070 = 32'h800 + 32'h1c0;
localparam RD_SLV_REG071 = 32'h800 + 32'h1c4;
localparam RD_SLV_REG080 = 32'h800 + 32'h200;
localparam RD_SLV_REG086 = 32'h800 + 32'h218;
localparam RD_SLV_REG087 = 32'h800 + 32'h21c;
localparam RD_SLV_REG088 = 32'h800 + 32'h220;
localparam RD_SLV_REG090 = 32'h800 + 32'h240;
localparam RD_SLV_REG091 = 32'h800 + 32'h244;
localparam RD_SLV_REG092 = 32'h800 + 32'h248;
localparam RD_SLV_REG0B1 = 32'h800 + 32'h2c4;
localparam RD_SLV_REG0B3 = 32'h800 + 32'h2cc;
localparam RD_SLV_REG0B4 = 32'h800 + 32'h2d0;
localparam RD_SLV_REG0B5 = 32'h800 + 32'h2d4;
localparam RD_SLV_REG0B6 = 32'h800 + 32'h2d8;
localparam RD_SLV_REG0B7 = 32'h800 + 32'h2dc;
localparam RD_SLV_REG0B8 = 32'h800 + 32'h2e0;
localparam RD_SLV_REG0B9 = 32'h800 + 32'h2e4;
localparam RD_SLV_REG0BA = 32'h800 + 32'h2e8;
localparam RD_SLV_REG0C0 = 32'h800 + 32'h300;
localparam RD_SLV_REG0C1 = 32'h800 + 32'h304;
localparam RD_SLV_REG0C2 = 32'h800 + 32'h308;
localparam RD_SLV_REG0C3 = 32'h800 + 32'h30c;
localparam RD_SLV_REG0C4 = 32'h800 + 32'h310;
localparam RD_SLV_REG0C5 = 32'h800 + 32'h314;
localparam RD_SLV_REG0C6 = 32'h800 + 32'h318;
localparam RD_SLV_REG0C7 = 32'h800 + 32'h31c;
localparam RD_SLV_REG0C8 = 32'h800 + 32'h320;
localparam RD_SLV_REG0C9 = 32'h800 + 32'h324;
localparam RD_SLV_REG0CA = 32'h800 + 32'h328;
localparam RD_SLV_REG0CB = 32'h800 + 32'h32c;
localparam RD_SLV_REG0CC = 32'h800 + 32'h330;
localparam RD_SLV_REG0CD = 32'h800 + 32'h334;
localparam RD_SLV_REG0CE = 32'h800 + 32'h338;
localparam RD_SLV_REG0CF = 32'h800 + 32'h33c;
localparam RD_SLV_REG0D0 = 32'h800 + 32'h340;
localparam RD_SLV_REG0D1 = 32'h800 + 32'h344;
localparam RD_SLV_REG0D2 = 32'h800 + 32'h348;
localparam RD_SLV_REG0D3 = 32'h800 + 32'h34c;
localparam RD_SLV_REG0D4 = 32'h800 + 32'h350;
localparam RD_SLV_REG0D5 = 32'h800 + 32'h354;
localparam RD_SLV_REG0D6 = 32'h800 + 32'h358;
localparam RD_SLV_REG0D7 = 32'h800 + 32'h35c;
localparam RD_SLV_REG0D8 = 32'h800 + 32'h360;
localparam RD_SLV_REG0D9 = 32'h800 + 32'h364;
localparam RD_SLV_REG0DA = 32'h800 + 32'h368;
localparam RD_SLV_REG0DB = 32'h800 + 32'h36c;
localparam RD_SLV_REG0DC = 32'h800 + 32'h370;
localparam RD_SLV_REG0DD = 32'h800 + 32'h374;
localparam RD_SLV_REG0DE = 32'h800 + 32'h378;
localparam RD_SLV_REG0DF = 32'h800 + 32'h37c;
localparam RD_SLV_REG0F1 = 32'h800 + 32'h3c4;
localparam RD_SLV_REG0F2 = 32'h800 + 32'h3c8;
localparam RD_SLV_REG0F3 = 32'h800 + 32'h3cc;
localparam RD_SLV_REG0F4 = 32'h800 + 32'h3d0;
localparam RD_SLV_REG0F5 = 32'h800 + 32'h3d4;
localparam RD_SLV_REG0F6 = 32'h800 + 32'h3d8;
localparam RD_SLV_REG0F7 = 32'h800 + 32'h3dc;
localparam RD_SLV_REG0F8 = 32'h800 + 32'h3e0;
localparam RD_SLV_REG0F9 = 32'h800 + 32'h3e4;
localparam RD_SLV_REG0FA = 32'h800 + 32'h3e8;
localparam RD_SLV_REG0FB = 32'h800 + 32'h3ec;
localparam RD_SLV_REG0FC = 32'h800 + 32'h3f0;
localparam RD_SLV_REG0FD = 32'h800 + 32'h3f4;
localparam RD_SLV_REG0FE = 32'h800 + 32'h3f8;
localparam RD_SLV_REG0FF = 32'h800 + 32'h3fc;
localparam RD_SLV_REG301 = 32'h0   + 32'hc04;
localparam RD_SLV_REG302 = 32'h0   + 32'hc08;
localparam RD_SLV_REG303 = 32'h0   + 32'hc0c;
localparam RD_SLV_REG304 = 32'h0   + 32'hc10;
localparam RD_SLV_REG305 = 32'h0   + 32'hc14;
localparam RD_SLV_REG306 = 32'h0   + 32'hc18;
localparam RD_SLV_REG307 = 32'h0   + 32'hc1c;
localparam RD_SLV_REG308 = 32'h0   + 32'hc20;
localparam RD_SLV_REG309 = 32'h0   + 32'hc24;
localparam RD_SLV_REG30A = 32'h0   + 32'hc28;
localparam RD_SLV_REG30B = 32'h0   + 32'hc2c;
localparam RD_SLV_REG30C = 32'h0   + 32'hc30;
localparam RD_SLV_REG30E = 32'h0   + 32'hc38;
localparam RD_SLV_REG30F = 32'h0   + 32'hc3c;
localparam RD_SLV_REG311 = 32'h0   + 32'hc44;
localparam RD_SLV_REG312 = 32'h0   + 32'hc48;
localparam RD_SLV_REG313 = 32'h0   + 32'hc4c;
localparam RD_SLV_REG314 = 32'h0   + 32'hc50;
localparam RD_SLV_REG3B1 = 32'h0   + 32'hec4;
localparam RD_SLV_REG3B2 = 32'h0   + 32'hec8;
localparam RD_SLV_REG3B3 = 32'h0   + 32'hecc;
localparam RD_SLV_REG3B4 = 32'h0   + 32'hed0;
localparam RD_SLV_REG3B5 = 32'h0   + 32'hed4;
localparam RD_SLV_REG3B6 = 32'h0   + 32'hed8;
localparam RD_SLV_REG3B7 = 32'h0   + 32'hedc;
localparam RD_SLV_REG3B8 = 32'h0   + 32'hee0;
localparam RD_SLV_REG3B9 = 32'h0   + 32'hee4;
localparam RD_SLV_REG3BA = 32'h0   + 32'hee8;
localparam RD_SLV_REG3BB = 32'h0   + 32'heec;
localparam RD_SLV_REG3BC = 32'h0   + 32'hef0;
localparam RD_SLV_REG3C1 = 32'h0   + 32'hf04;
localparam RD_SLV_REG3C2 = 32'h0   + 32'hf08;
localparam RD_SLV_REG3C3 = 32'h0   + 32'hf0c;
localparam RD_SLV_REG3C4 = 32'h0   + 32'hf10;
localparam RD_SLV_REG3C5 = 32'h0   + 32'hf14;
localparam RD_SLV_REG3C6 = 32'h0   + 32'hf18;
localparam RD_SLV_REG3C7 = 32'h0   + 32'hf1c;
localparam RD_SLV_REG3C8 = 32'h0   + 32'hf20;
localparam RD_SLV_REG3D1 = 32'h0   + 32'hf44;
localparam RD_SLV_REG3D2 = 32'h0   + 32'hf48;
localparam RD_SLV_REG3D3 = 32'h0   + 32'hf4c;
localparam RD_SLV_REG3D4 = 32'h0   + 32'hf50;
localparam RD_SLV_REG3D5 = 32'h0   + 32'hf54;
localparam RD_SLV_REG3D6 = 32'h0   + 32'hf58;
localparam RD_SLV_REG3D7 = 32'h0   + 32'hf5c;
localparam RD_SLV_REG3D8 = 32'h0   + 32'hf60;
localparam RD_SLV_REG3E1 = 32'h0   + 32'hf84;
localparam RD_SLV_REG3E2 = 32'h0   + 32'hf88;
localparam RD_SLV_REG3E3 = 32'h0   + 32'hf8c;
localparam RD_SLV_REG3E4 = 32'h0   + 32'hf90;
localparam RD_SLV_REG3E5 = 32'h0   + 32'hf94;
localparam RD_SLV_REG3E6 = 32'h0   + 32'hf98;
localparam RD_SLV_REG3E7 = 32'h0   + 32'hf9c;
localparam RD_SLV_REG3E8 = 32'h0   + 32'hfa0;
localparam RD_SLV_REG3FF = 32'h0   + 32'hffc;

//----------------------------local wire/reg declaration------------------------------------------

//slv_reg001
reg  [32-1:0] slv_reg001_reg        ;//wr
wire [32-1:0] slv_reg001            ;//rd

//slv_reg002
reg  [32-1:0] slv_reg002_reg        ;//wr
wire [32-1:0] slv_reg002            ;//rd

//slv_reg003
reg  [32-1:0] slv_reg003_reg        ;//wr
wire [32-1:0] slv_reg003            ;//rd

//slv_reg004
reg  [32-1:0] slv_reg004_reg        ;//wr
wire [32-1:0] slv_reg004            ;//rd

//slv_reg005
reg  [32-1:0] slv_reg005_reg        ;//wr
wire [32-1:0] slv_reg005            ;//rd

//slv_reg006
reg  [32-1:0] slv_reg006_reg        ;//wr
wire [32-1:0] slv_reg006            ;//rd

//slv_reg007
reg  [32-1:0] slv_reg007_reg        ;//wr
wire [32-1:0] slv_reg007            ;//rd

//slv_reg008
reg  [32-1:0] slv_reg008_reg        ;//wr
wire [32-1:0] slv_reg008            ;//rd

//slv_reg009
reg  [32-1:0] slv_reg009_reg        ;//wr
wire [32-1:0] slv_reg009            ;//rd

//slv_reg00a
reg  [32-1:0] slv_reg00a_reg        ;//wr
wire [32-1:0] slv_reg00a            ;//rd

//slv_reg00b
reg  [32-1:0] slv_reg00b_reg        ;//wr
wire [32-1:0] slv_reg00b            ;//rd

//slv_reg00c
reg  [32-1:0] slv_reg00c_reg        ;//wr
wire [32-1:0] slv_reg00c            ;//rd

//slv_reg00d
reg  [32-1:0] slv_reg00d_reg        ;//wr
wire [32-1:0] slv_reg00d            ;//rd

//slv_reg00f
reg  [32-1:0] slv_reg00f_reg        ;//wr
wire [32-1:0] slv_reg00f            ;//rd

//slv_reg010
reg  [32-1:0] slv_reg010_reg        ;//wr
wire [32-1:0] slv_reg010            ;//rd

//slv_reg011
reg  [32-1:0] slv_reg011_reg        ;//wr
wire [32-1:0] slv_reg011            ;//rd

//slv_reg012
reg  [32-1:0] slv_reg012_reg        ;//wr
wire [32-1:0] slv_reg012            ;//rd

//slv_reg013
reg  [32-1:0] slv_reg013_reg        ;//wr
wire [32-1:0] slv_reg013            ;//rd

//slv_reg014
reg  [32-1:0] slv_reg014_reg        ;//wr
wire [32-1:0] slv_reg014            ;//rd

//slv_reg015
reg  [32-1:0] slv_reg015_reg        ;//wr
wire [32-1:0] slv_reg015            ;//rd

//slv_reg016
reg  [32-1:0] slv_reg016_reg        ;//wr
wire [32-1:0] slv_reg016            ;//rd

//slv_reg017
reg  [32-1:0] slv_reg017_reg        ;//wr
wire [32-1:0] slv_reg017            ;//rd

//slv_reg018
reg  [32-1:0] slv_reg018_reg        ;//wr
wire [32-1:0] slv_reg018            ;//rd

//slv_reg019
reg  [32-1:0] slv_reg019_reg        ;//wr
wire [32-1:0] slv_reg019            ;//rd

//slv_reg01a
reg  [32-1:0] slv_reg01a_reg        ;//wr
wire [32-1:0] slv_reg01a            ;//rd

//slv_reg01b
reg  [32-1:0] slv_reg01b_reg        ;//wr
wire [32-1:0] slv_reg01b            ;//rd

//slv_reg01c
reg  [32-1:0] slv_reg01c_reg        ;//wr
wire [32-1:0] slv_reg01c            ;//rd

//slv_reg01d
reg  [32-1:0] slv_reg01d_reg        ;//wr
wire [32-1:0] slv_reg01d            ;//rd

//slv_reg01e
reg  [32-1:0] slv_reg01e_reg        ;//wr
wire [32-1:0] slv_reg01e            ;//rd

//slv_reg01f
reg  [32-1:0] slv_reg01f_reg        ;//wr
wire [32-1:0] slv_reg01f            ;//rd

//slv_reg020
reg  [32-1:0] slv_reg020_reg        ;//wr
wire [32-1:0] slv_reg020            ;//rd

//slv_reg021
reg  [32-1:0] slv_reg021_reg        ;//wr
wire [32-1:0] slv_reg021            ;//rd

//slv_reg022
reg  [32-1:0] slv_reg022_reg        ;//wr
wire [32-1:0] slv_reg022            ;//rd

//slv_reg023
reg  [32-1:0] slv_reg023_reg        ;//wr
wire [32-1:0] slv_reg023            ;//rd

//slv_reg024
reg  [32-1:0] slv_reg024_reg        ;//wr
wire [32-1:0] slv_reg024            ;//rd

//slv_reg025
reg  [32-1:0] slv_reg025_reg        ;//wr
wire [32-1:0] slv_reg025            ;//rd

//slv_reg026
reg  [32-1:0] slv_reg026_reg        ;//wr
wire [32-1:0] slv_reg026            ;//rd

//slv_reg027
reg  [32-1:0] slv_reg027_reg        ;//wr
wire [32-1:0] slv_reg027            ;//rd

//slv_reg028
reg  [32-1:0] slv_reg028_reg        ;//wr
wire [32-1:0] slv_reg028            ;//rd

//slv_reg02d
reg  [32-1:0] slv_reg02d_reg        ;//wr
wire [32-1:0] slv_reg02d            ;//rd

//slv_reg02e
reg  [32-1:0] slv_reg02e_reg        ;//wr
wire [32-1:0] slv_reg02e            ;//rd

//slv_reg02f
reg  [32-1:0] slv_reg02f_reg        ;//wr
wire [32-1:0] slv_reg02f            ;//rd

//slv_reg030
reg  [32-1:0] slv_reg030_reg        ;//wr
wire [32-1:0] slv_reg030            ;//rd

//slv_reg031
reg  [32-1:0] slv_reg031_reg        ;//wr
wire [32-1:0] slv_reg031            ;//rd

//slv_reg033
reg  [32-1:0] slv_reg033_reg        ;//wr
wire [32-1:0] slv_reg033            ;//rd

//slv_reg034
reg  [32-1:0] slv_reg034_reg        ;//wr
wire [32-1:0] slv_reg034            ;//rd

//slv_reg041
reg  [32-1:0] slv_reg041_reg        ;//wr
wire [32-1:0] slv_reg041            ;//rd

//slv_reg042
reg  [32-1:0] slv_reg042_reg        ;//wr
wire [32-1:0] slv_reg042            ;//rd

//slv_reg043
reg  [32-1:0] slv_reg043_reg        ;//wr
wire [32-1:0] slv_reg043            ;//rd

//slv_reg044
reg  [32-1:0] slv_reg044_reg        ;//wr
wire [32-1:0] slv_reg044            ;//rd

//slv_reg045
reg  [32-1:0] slv_reg045_reg        ;//wr
wire [32-1:0] slv_reg045            ;//rd

//slv_reg046
reg  [32-1:0] slv_reg046_reg        ;//wr
wire [32-1:0] slv_reg046            ;//rd

//slv_reg047
reg  [32-1:0] slv_reg047_reg        ;//wr
wire [32-1:0] slv_reg047            ;//rd

//slv_reg048
reg  [32-1:0] slv_reg048_reg        ;//wr
wire [32-1:0] slv_reg048            ;//rd

//slv_reg049
reg  [32-1:0] slv_reg049_reg        ;//wr
wire [32-1:0] slv_reg049            ;//rd

//slv_reg051
reg  [32-1:0] slv_reg051_reg        ;//wr
wire [32-1:0] slv_reg051            ;//rd

//slv_reg052
reg  [32-1:0] slv_reg052_reg        ;//wr
wire [32-1:0] slv_reg052            ;//rd

//slv_reg053
reg  [32-1:0] slv_reg053_reg        ;//wr
wire [32-1:0] slv_reg053            ;//rd

//slv_reg054
reg  [32-1:0] slv_reg054_reg        ;//wr
wire [32-1:0] slv_reg054            ;//rd

//slv_reg055
reg  [32-1:0] slv_reg055_reg        ;//wr
wire [32-1:0] slv_reg055            ;//rd

//slv_reg056
reg  [32-1:0] slv_reg056_reg        ;//wr
wire [32-1:0] slv_reg056            ;//rd

//slv_reg057
reg  [32-1:0] slv_reg057_reg        ;//wr
wire [32-1:0] slv_reg057            ;//rd

//slv_reg058
reg  [32-1:0] slv_reg058_reg        ;//wr
wire [32-1:0] slv_reg058            ;//rd

//slv_reg059
reg  [32-1:0] slv_reg059_reg        ;//wr
wire [32-1:0] slv_reg059            ;//rd

//slv_reg05a
reg  [32-1:0] slv_reg05a_reg        ;//wr
wire [32-1:0] slv_reg05a            ;//rd

//slv_reg05b
reg  [32-1:0] slv_reg05b_reg        ;//wr
wire [32-1:0] slv_reg05b            ;//rd

//slv_reg05c
reg  [32-1:0] slv_reg05c_reg        ;//wr
wire [32-1:0] slv_reg05c            ;//rd

//slv_reg05d
reg  [32-1:0] slv_reg05d_reg        ;//wr
wire [32-1:0] slv_reg05d            ;//rd

//slv_reg05e
reg  [32-1:0] slv_reg05e_reg        ;//wr
wire [32-1:0] slv_reg05e            ;//rd

//slv_reg05f
reg  [32-1:0] slv_reg05f_reg        ;//wr
wire [32-1:0] slv_reg05f            ;//rd

//slv_reg060
reg  [32-1:0] slv_reg060_reg        ;//wr
wire [32-1:0] slv_reg060            ;//rd

//slv_reg061
reg  [32-1:0] slv_reg061_reg        ;//wr
wire [32-1:0] slv_reg061            ;//rd

//slv_reg062
reg  [32-1:0] slv_reg062_reg        ;//wr
wire [32-1:0] slv_reg062            ;//rd

//slv_reg063
reg  [32-1:0] slv_reg063_reg        ;//wr
wire [32-1:0] slv_reg063            ;//rd

//slv_reg064
reg  [32-1:0] slv_reg064_reg        ;//wr
wire [32-1:0] slv_reg064            ;//rd

//slv_reg065
reg  [32-1:0] slv_reg065_reg        ;//wr
wire [32-1:0] slv_reg065            ;//rd

//slv_reg066
reg  [32-1:0] slv_reg066_reg        ;//wr
wire [32-1:0] slv_reg066            ;//rd

//slv_reg067
reg  [32-1:0] slv_reg067_reg        ;//wr
wire [32-1:0] slv_reg067            ;//rd

//slv_reg068
reg  [32-1:0] slv_reg068_reg        ;//wr
wire [32-1:0] slv_reg068            ;//rd

//slv_reg069
reg  [32-1:0] slv_reg069_reg        ;//wr
wire [32-1:0] slv_reg069            ;//rd

//slv_reg06a
reg  [32-1:0] slv_reg06a_reg        ;//wr
wire [32-1:0] slv_reg06a            ;//rd

//slv_reg06b
reg  [32-1:0] slv_reg06b_reg        ;//wr
wire [32-1:0] slv_reg06b            ;//rd

//slv_reg06c
reg  [32-1:0] slv_reg06c_reg        ;//wr
wire [32-1:0] slv_reg06c            ;//rd

//slv_reg06d
reg  [32-1:0] slv_reg06d_reg        ;//wr
wire [32-1:0] slv_reg06d            ;//rd

//slv_reg06e
reg  [32-1:0] slv_reg06e_reg        ;//wr
wire [32-1:0] slv_reg06e            ;//rd

//slv_reg06f
reg  [32-1:0] slv_reg06f_reg        ;//wr
wire [32-1:0] slv_reg06f            ;//rd

//slv_reg070
reg  [32-1:0] slv_reg070_reg        ;//wr
wire [32-1:0] slv_reg070            ;//rd

//slv_reg071
reg  [32-1:0] slv_reg071_reg        ;//wr
wire [32-1:0] slv_reg071            ;//rd

//slv_reg080
reg  [32-1:0] slv_reg080_reg        ;//wr
wire [32-1:0] slv_reg080            ;//rd

//slv_reg086
reg  [32-1:0] slv_reg086_reg        ;//wr
wire [32-1:0] slv_reg086            ;//rd

//slv_reg087
reg  [32-1:0] slv_reg087_reg        ;//wr
wire [32-1:0] slv_reg087            ;//rd

//slv_reg088
reg  [32-1:0] slv_reg088_reg        ;//wr
wire [32-1:0] slv_reg088            ;//rd

//slv_reg090
reg  [32-1:0] slv_reg090_reg        ;//wr
wire [32-1:0] slv_reg090            ;//rd

//slv_reg091
reg  [32-1:0] slv_reg091_reg        ;//wr
wire [32-1:0] slv_reg091            ;//rd

//slv_reg092
reg  [32-1:0] slv_reg092_reg        ;//wr
wire [32-1:0] slv_reg092            ;//rd

//slv_reg0B1
reg  [32-1:0] slv_reg0b1_reg        ;//wr
wire [32-1:0] slv_reg0b1            ;//rd

//slv_reg0B3
reg  [32-1:0] slv_reg0b3_reg        ;//wr
wire [32-1:0] slv_reg0b3            ;//rd

//slv_reg0B4
reg  [32-1:0] slv_reg0b4_reg        ;//wr
wire [32-1:0] slv_reg0b4            ;//rd

//slv_reg0B5
reg  [32-1:0] slv_reg0b5_reg        ;//wr
wire [32-1:0] slv_reg0b5            ;//rd

//slv_reg0B6
reg  [32-1:0] slv_reg0b6_reg        ;//wr
wire [32-1:0] slv_reg0b6            ;//rd

//slv_reg0B7
reg  [32-1:0] slv_reg0b7_reg        ;//wr
wire [32-1:0] slv_reg0b7            ;//rd

//slv_reg0B8
reg  [32-1:0] slv_reg0b8_reg        ;//wr
wire [32-1:0] slv_reg0b8            ;//rd

//slv_reg0B9
reg  [32-1:0] slv_reg0b9_reg        ;//wr
wire [32-1:0] slv_reg0b9            ;//rd

//slv_reg0Ba
reg  [32-1:0] slv_reg0ba_reg        ;//wr
wire [32-1:0] slv_reg0ba            ;//rd

//slv_reg0C0
reg  [32-1:0] slv_reg0c0_reg        ;//wr
wire [32-1:0] slv_reg0c0            ;//rd

//slv_reg0C1
reg  [32-1:0] slv_reg0c1_reg        ;//wr
wire [32-1:0] slv_reg0c1            ;//rd

//slv_reg0C2
reg  [32-1:0] slv_reg0c2_reg        ;//wr
wire [32-1:0] slv_reg0c2            ;//rd

//slv_reg0C3
reg  [32-1:0] slv_reg0c3_reg        ;//wr
wire [32-1:0] slv_reg0c3            ;//rd

//slv_reg0C4
reg  [32-1:0] slv_reg0c4_reg        ;//wr
wire [32-1:0] slv_reg0c4            ;//rd

//slv_reg0C5
reg  [32-1:0] slv_reg0c5_reg        ;//wr
wire [32-1:0] slv_reg0c5            ;//rd

//slv_reg0C6
reg  [32-1:0] slv_reg0c6_reg        ;//wr
wire [32-1:0] slv_reg0c6            ;//rd

//slv_reg0C7
reg  [32-1:0] slv_reg0c7_reg        ;//wr
wire [32-1:0] slv_reg0c7            ;//rd

//slv_reg0C8
reg  [32-1:0] slv_reg0c8_reg        ;//wr
wire [32-1:0] slv_reg0c8            ;//rd

//slv_reg0C9
reg  [32-1:0] slv_reg0c9_reg        ;//wr
wire [32-1:0] slv_reg0c9            ;//rd

//slv_reg0Ca
reg  [32-1:0] slv_reg0ca_reg        ;//wr
wire [32-1:0] slv_reg0ca            ;//rd

//slv_reg0Cb
reg  [32-1:0] slv_reg0cb_reg        ;//wr
wire [32-1:0] slv_reg0cb            ;//rd

//slv_reg0Cc
reg  [32-1:0] slv_reg0cc_reg        ;//wr
wire [32-1:0] slv_reg0cc            ;//rd

//slv_reg0Cd
reg  [32-1:0] slv_reg0cd_reg        ;//wr
wire [32-1:0] slv_reg0cd            ;//rd

//slv_reg0CE
wire [32-1:0] slv_reg0ce            ;//rd

//slv_reg0CF
wire [32-1:0] slv_reg0cf            ;//rd

//slv_reg0D0
reg  [32-1:0] slv_reg0d0_reg        ;//wr
wire [32-1:0] slv_reg0d0            ;//rd

//slv_reg0D1
reg  [32-1:0] slv_reg0d1_reg        ;//wr
wire [32-1:0] slv_reg0d1            ;//rd

//slv_reg0D2
reg  [32-1:0] slv_reg0d2_reg        ;//wr
wire [32-1:0] slv_reg0d2            ;//rd

//slv_reg0D3
reg  [32-1:0] slv_reg0d3_reg        ;//wr
wire [32-1:0] slv_reg0d3            ;//rd

//slv_reg0D4
reg  [32-1:0] slv_reg0d4_reg        ;//wr
wire [32-1:0] slv_reg0d4            ;//rd

//slv_reg0D5
reg  [32-1:0] slv_reg0d5_reg        ;//wr
wire [32-1:0] slv_reg0d5            ;//rd

//slv_reg0D6
reg  [32-1:0] slv_reg0d6_reg        ;//wr
wire [32-1:0] slv_reg0d6            ;//rd

//slv_reg0D7
reg  [32-1:0] slv_reg0d7_reg        ;//wr
wire [32-1:0] slv_reg0d7            ;//rd

//slv_reg0D8
reg  [32-1:0] slv_reg0d8_reg        ;//wr
wire [32-1:0] slv_reg0d8            ;//rd

//slv_reg0D9
reg  [32-1:0] slv_reg0d9_reg        ;//wr
wire [32-1:0] slv_reg0d9            ;//rd

//slv_reg0Da
reg  [32-1:0] slv_reg0da_reg        ;//wr
wire [32-1:0] slv_reg0da            ;//rd

//slv_reg0Db
reg  [32-1:0] slv_reg0db_reg        ;//wr
wire [32-1:0] slv_reg0db            ;//rd

//slv_reg0Dc
reg  [32-1:0] slv_reg0dc_reg        ;//wr
wire [32-1:0] slv_reg0dc            ;//rd

//slv_reg0Dd
reg  [32-1:0] slv_reg0dd_reg        ;//wr
wire [32-1:0] slv_reg0dd            ;//rd

//slv_reg0De
wire [32-1:0] slv_reg0de            ;//rd

//slv_reg0Df
wire [32-1:0] slv_reg0df            ;//rd

//slv_reg0f1
reg  [32-1:0] slv_reg0f1_reg        ;//wr
wire [32-1:0] slv_reg0f1            ;//rd

//slv_reg0f2
reg  [32-1:0] slv_reg0f2_reg        ;//wr
wire [32-1:0] slv_reg0f2            ;//rd

//slv_reg0f3
reg  [32-1:0] slv_reg0f3_reg        ;//wr
wire [32-1:0] slv_reg0f3            ;//rd

//slv_reg0f4
reg  [32-1:0] slv_reg0f4_reg        ;//wr
wire [32-1:0] slv_reg0f4            ;//rd

//slv_reg0f5
reg  [32-1:0] slv_reg0f5_reg        ;//wr
wire [32-1:0] slv_reg0f5            ;//rd

//slv_reg0f6
reg  [32-1:0] slv_reg0f6_reg        ;//wr
wire [32-1:0] slv_reg0f6            ;//rd

//slv_reg0f7
reg  [32-1:0] slv_reg0f7_reg        ;//wr
wire [32-1:0] slv_reg0f7            ;//rd

//slv_reg0f8
reg  [32-1:0] slv_reg0f8_reg        ;//wr
wire [32-1:0] slv_reg0f8            ;//rd

//slv_reg0f9
reg  [32-1:0] slv_reg0f9_reg        ;//wr
wire [32-1:0] slv_reg0f9            ;//rd

//slv_reg0fa
reg  [32-1:0] slv_reg0fa_reg        ;//wr
wire [32-1:0] slv_reg0fa            ;//rd

//slv_reg0fb
reg  [32-1:0] slv_reg0fb_reg        ;//wr
wire [32-1:0] slv_reg0fb            ;//rd

//slv_reg0fc
reg  [32-1:0] slv_reg0fc_reg        ;//wr
wire [32-1:0] slv_reg0fc            ;//rd

//rd_slv_reg000
wire [32-1:0] rd_slv_reg000         ;//rd

//rd_slv_reg001
wire [32-1:0] rd_slv_reg001         ;//rd

//rd_slv_reg202
wire [32-1:0] rd_slv_reg202         ;//rd

//rd_slv_reg203
wire [32-1:0] rd_slv_reg203         ;//rd

//rd_slv_reg204
wire [32-1:0] rd_slv_reg204         ;//rd

//rd_slv_reg205
wire [32-1:0] rd_slv_reg205         ;//rd

//rd_slv_reg206
wire [32-1:0] rd_slv_reg206         ;//rd

//rd_slv_reg207
wire [32-1:0] rd_slv_reg207         ;//rd

//rd_slv_reg208
wire [32-1:0] rd_slv_reg208         ;//rd

//rd_slv_reg209
wire [32-1:0] rd_slv_reg209         ;//rd

//rd_slv_reg210
wire [32-1:0] rd_slv_reg210         ;//rd

//rd_slv_reg211
wire [32-1:0] rd_slv_reg211         ;//rd

//rd_slv_reg212
wire [32-1:0] rd_slv_reg212         ;//rd

//rd_slv_reg213
wire [32-1:0] rd_slv_reg213         ;//rd

//rd_slv_reg00f
wire [32-1:0] rd_slv_reg00f         ;//rd

//rd_slv_reg010
wire [32-1:0] rd_slv_reg010         ;//rd

//rd_slv_reg011
wire [32-1:0] rd_slv_reg011         ;//rd

//rd_slv_reg012
wire [32-1:0] rd_slv_reg012         ;//rd

//rd_slv_reg013
wire [32-1:0] rd_slv_reg013         ;//rd

//rd_slv_reg014
wire [32-1:0] rd_slv_reg014         ;//rd

//rd_slv_reg015
wire [32-1:0] rd_slv_reg015         ;//rd

//rd_slv_reg016
wire [32-1:0] rd_slv_reg016         ;//rd

//rd_slv_reg017
wire [32-1:0] rd_slv_reg017         ;//rd

//rd_slv_reg018
wire [32-1:0] rd_slv_reg018         ;//rd

//rd_slv_reg019
wire [32-1:0] rd_slv_reg019         ;//rd

//rd_slv_reg01a
wire [32-1:0] rd_slv_reg01a         ;//rd

//rd_slv_reg01b
wire [32-1:0] rd_slv_reg01b         ;//rd

//rd_slv_reg01c
wire [32-1:0] rd_slv_reg01c         ;//rd

//rd_slv_reg01d
wire [32-1:0] rd_slv_reg01d         ;//rd

//rd_slv_reg01e
wire [32-1:0] rd_slv_reg01e         ;//rd

//rd_slv_reg01f
wire [32-1:0] rd_slv_reg01f         ;//rd

//rd_slv_reg020
wire [32-1:0] rd_slv_reg020         ;//rd

//rd_slv_reg021
wire [32-1:0] rd_slv_reg021         ;//rd

//rd_slv_reg022
wire [32-1:0] rd_slv_reg022         ;//rd

//rd_slv_reg023
wire [32-1:0] rd_slv_reg023         ;//rd

//rd_slv_reg024
wire [32-1:0] rd_slv_reg024         ;//rd

//rd_slv_reg025
wire [32-1:0] rd_slv_reg025         ;//rd

//rd_slv_reg026
wire [32-1:0] rd_slv_reg026         ;//rd

//rd_slv_reg027
wire [32-1:0] rd_slv_reg027         ;//rd

//rd_slv_reg028
wire [32-1:0] rd_slv_reg028         ;//rd

//rd_slv_reg02d
wire [32-1:0] rd_slv_reg02d         ;//rd

//rd_slv_reg02e
wire [32-1:0] rd_slv_reg02e         ;//rd

//rd_slv_reg02f
wire [32-1:0] rd_slv_reg02f         ;//rd

//rd_slv_reg030
wire [32-1:0] rd_slv_reg030         ;//rd

//rd_slv_reg031
wire [32-1:0] rd_slv_reg031         ;//rd

//rd_slv_reg033
wire [32-1:0] rd_slv_reg033         ;//rd

//rd_slv_reg034
wire [32-1:0] rd_slv_reg034         ;//rd

//rd_slv_reg041
wire [32-1:0] rd_slv_reg041         ;//rd

//rd_slv_reg042
wire [32-1:0] rd_slv_reg042         ;//rd

//rd_slv_reg043
wire [32-1:0] rd_slv_reg043         ;//rd

//rd_slv_reg044
wire [32-1:0] rd_slv_reg044         ;//rd

//rd_slv_reg045
wire [32-1:0] rd_slv_reg045         ;//rd

//rd_slv_reg046
wire [32-1:0] rd_slv_reg046         ;//rd

//rd_slv_reg047
wire [32-1:0] rd_slv_reg047         ;//rd

//rd_slv_reg048
wire [32-1:0] rd_slv_reg048         ;//rd

//rd_slv_reg049
wire [32-1:0] rd_slv_reg049         ;//rd

//rd_slv_reg051
wire [32-1:0] rd_slv_reg051         ;//rd

//rd_slv_reg052
wire [32-1:0] rd_slv_reg052         ;//rd

//rd_slv_reg053
wire [32-1:0] rd_slv_reg053         ;//rd

//rd_slv_reg054
wire [32-1:0] rd_slv_reg054         ;//rd

//rd_slv_reg055
wire [32-1:0] rd_slv_reg055         ;//rd

//rd_slv_reg056
wire [32-1:0] rd_slv_reg056         ;//rd

//rd_slv_reg057
wire [32-1:0] rd_slv_reg057         ;//rd

//rd_slv_reg058
wire [32-1:0] rd_slv_reg058         ;//rd

//rd_slv_reg059
wire [32-1:0] rd_slv_reg059         ;//rd

//rd_slv_reg05a
wire [32-1:0] rd_slv_reg05a         ;//rd

//rd_slv_reg05b
wire [32-1:0] rd_slv_reg05b         ;//rd

//rd_slv_reg05c
wire [32-1:0] rd_slv_reg05c         ;//rd

//rd_slv_reg05d
wire [32-1:0] rd_slv_reg05d         ;//rd

//rd_slv_reg05e
wire [32-1:0] rd_slv_reg05e         ;//rd

//rd_slv_reg05f
wire [32-1:0] rd_slv_reg05f         ;//rd

//rd_slv_reg060
wire [32-1:0] rd_slv_reg060         ;//rd

//rd_slv_reg061
wire [32-1:0] rd_slv_reg061         ;//rd

//rd_slv_reg062
wire [32-1:0] rd_slv_reg062         ;//rd

//rd_slv_reg063
wire [32-1:0] rd_slv_reg063         ;//rd

//rd_slv_reg064
wire [32-1:0] rd_slv_reg064         ;//rd

//rd_slv_reg065
wire [32-1:0] rd_slv_reg065         ;//rd

//rd_slv_reg066
wire [32-1:0] rd_slv_reg066         ;//rd

//rd_slv_reg067
wire [32-1:0] rd_slv_reg067         ;//rd

//rd_slv_reg068
wire [32-1:0] rd_slv_reg068         ;//rd

//rd_slv_reg069
wire [32-1:0] rd_slv_reg069         ;//rd

//rd_slv_reg06a
wire [32-1:0] rd_slv_reg06a         ;//rd

//rd_slv_reg06b
wire [32-1:0] rd_slv_reg06b         ;//rd

//rd_slv_reg06c
wire [32-1:0] rd_slv_reg06c         ;//rd

//rd_slv_reg06d
wire [32-1:0] rd_slv_reg06d         ;//rd

//rd_slv_reg06e
wire [32-1:0] rd_slv_reg06e         ;//rd

//rd_slv_reg06f
wire [32-1:0] rd_slv_reg06f         ;//rd

//rd_slv_reg070
wire [32-1:0] rd_slv_reg070         ;//rd

//rd_slv_reg071
wire [32-1:0] rd_slv_reg071         ;//rd

//rd_slv_reg080
wire [32-1:0] rd_slv_reg080         ;//rd

//rd_slv_reg086
wire [32-1:0] rd_slv_reg086         ;//rd

//rd_slv_reg087
wire [32-1:0] rd_slv_reg087         ;//rd

//rd_slv_reg088
wire [32-1:0] rd_slv_reg088         ;//rd

//rd_slv_reg090
wire [32-1:0] rd_slv_reg090         ;//rd

//rd_slv_reg091
wire [32-1:0] rd_slv_reg091         ;//rd

//rd_slv_reg092
wire [32-1:0] rd_slv_reg092         ;//rd

//rd_slv_reg0B1
wire [32-1:0] rd_slv_reg0b1         ;//rd

//rd_slv_reg0B3
wire [32-1:0] rd_slv_reg0b3         ;//rd

//rd_slv_reg0B4
wire [32-1:0] rd_slv_reg0b4         ;//rd

//rd_slv_reg0B5
wire [32-1:0] rd_slv_reg0b5         ;//rd

//rd_slv_reg0B6
wire [32-1:0] rd_slv_reg0b6         ;//rd

//rd_slv_reg0B7
wire [32-1:0] rd_slv_reg0b7         ;//rd

//rd_slv_reg0B8
wire [32-1:0] rd_slv_reg0b8         ;//rd

//rd_slv_reg0B9
wire [32-1:0] rd_slv_reg0b9         ;//rd

//rd_slv_reg0Ba
wire [32-1:0] rd_slv_reg0ba         ;//rd

//rd_slv_reg0C0
wire [32-1:0] rd_slv_reg0c0         ;//rd

//rd_slv_reg0C1
wire [32-1:0] rd_slv_reg0c1         ;//rd

//rd_slv_reg0C2
wire [32-1:0] rd_slv_reg0c2         ;//rd

//rd_slv_reg0C3
wire [32-1:0] rd_slv_reg0c3         ;//rd

//rd_slv_reg0C4
wire [32-1:0] rd_slv_reg0c4         ;//rd

//rd_slv_reg0C5
wire [32-1:0] rd_slv_reg0c5         ;//rd

//rd_slv_reg0C6
wire [32-1:0] rd_slv_reg0c6         ;//rd

//rd_slv_reg0C7
wire [32-1:0] rd_slv_reg0c7         ;//rd

//rd_slv_reg0C8
wire [32-1:0] rd_slv_reg0c8         ;//rd

//rd_slv_reg0C9
wire [32-1:0] rd_slv_reg0c9         ;//rd

//rd_slv_reg0Ca
wire [32-1:0] rd_slv_reg0ca         ;//rd

//rd_slv_reg0Cb
wire [32-1:0] rd_slv_reg0cb         ;//rd

//rd_slv_reg0Cc
wire [32-1:0] rd_slv_reg0cc         ;//rd

//rd_slv_reg0Cd
wire [32-1:0] rd_slv_reg0cd         ;//rd

//rd_slv_reg0CE
wire [32-1:0] rd_slv_reg0ce         ;//rd

//rd_slv_reg0CF
wire [32-1:0] rd_slv_reg0cf         ;//rd

//rd_slv_reg0D0
wire [32-1:0] rd_slv_reg0d0         ;//rd

//rd_slv_reg0D1
wire [32-1:0] rd_slv_reg0d1         ;//rd

//rd_slv_reg0D2
wire [32-1:0] rd_slv_reg0d2         ;//rd

//rd_slv_reg0D3
wire [32-1:0] rd_slv_reg0d3         ;//rd

//rd_slv_reg0D4
wire [32-1:0] rd_slv_reg0d4         ;//rd

//rd_slv_reg0D5
wire [32-1:0] rd_slv_reg0d5         ;//rd

//rd_slv_reg0D6
wire [32-1:0] rd_slv_reg0d6         ;//rd

//rd_slv_reg0D7
wire [32-1:0] rd_slv_reg0d7         ;//rd

//rd_slv_reg0D8
wire [32-1:0] rd_slv_reg0d8         ;//rd

//rd_slv_reg0D9
wire [32-1:0] rd_slv_reg0d9         ;//rd

//rd_slv_reg0Da
wire [32-1:0] rd_slv_reg0da         ;//rd

//rd_slv_reg0Db
wire [32-1:0] rd_slv_reg0db         ;//rd

//rd_slv_reg0Dc
wire [32-1:0] rd_slv_reg0dc         ;//rd

//rd_slv_reg0Dd
wire [32-1:0] rd_slv_reg0dd         ;//rd

//rd_slv_reg0De
wire [32-1:0] rd_slv_reg0de         ;//rd

//rd_slv_reg0Df
wire [32-1:0] rd_slv_reg0df         ;//rd

//rd_slv_reg0f1
wire [32-1:0] rd_slv_reg0f1         ;//rd

//rd_slv_reg0f2
wire [32-1:0] rd_slv_reg0f2         ;//rd

//rd_slv_reg0f3
wire [32-1:0] rd_slv_reg0f3         ;//rd

//rd_slv_reg0f4
wire [32-1:0] rd_slv_reg0f4         ;//rd

//rd_slv_reg0f5
wire [32-1:0] rd_slv_reg0f5         ;//rd

//rd_slv_reg0f6
wire [32-1:0] rd_slv_reg0f6         ;//rd

//rd_slv_reg0f7
wire [32-1:0] rd_slv_reg0f7         ;//rd

//rd_slv_reg0f8
wire [32-1:0] rd_slv_reg0f8         ;//rd

//rd_slv_reg0f9
wire [32-1:0] rd_slv_reg0f9         ;//rd

//rd_slv_reg0fa
wire [32-1:0] rd_slv_reg0fa         ;//rd

//rd_slv_reg0fb
wire [32-1:0] rd_slv_reg0fb         ;//rd

//rd_slv_reg0fc
wire [32-1:0] rd_slv_reg0fc         ;//rd

//rd_slv_reg0fd
wire [32-1:0] rd_slv_reg0fd         ;//rd

//rd_slv_reg0fe
wire [32-1:0] rd_slv_reg0fe         ;//rd

//rd_slv_reg0ff
wire [32-1:0] rd_slv_reg0ff         ;//rd

//rd_slv_reg301
wire [32-1:0] rd_slv_reg301         ;//rd

//rd_slv_reg302
wire [32-1:0] rd_slv_reg302         ;//rd

//rd_slv_reg303
wire [32-1:0] rd_slv_reg303         ;//rd

//rd_slv_reg304
wire [32-1:0] rd_slv_reg304         ;//rd

//rd_slv_reg305
wire [32-1:0] rd_slv_reg305         ;//rd

//rd_slv_reg306
wire [32-1:0] rd_slv_reg306         ;//rd

//rd_slv_reg307
wire [32-1:0] rd_slv_reg307         ;//rd

//rd_slv_reg308
wire [32-1:0] rd_slv_reg308         ;//rd

//rd_slv_reg309
wire [32-1:0] rd_slv_reg309         ;//rd

//rd_slv_reg30a
wire [32-1:0] rd_slv_reg30a         ;//rd

//rd_slv_reg30b
wire [32-1:0] rd_slv_reg30b         ;//rd

//rd_slv_reg30c
wire [32-1:0] rd_slv_reg30c         ;//rd

//rd_slv_reg30e
wire [32-1:0] rd_slv_reg30e         ;//rd

//rd_slv_reg30f
wire [32-1:0] rd_slv_reg30f         ;//rd

//rd_slv_reg311
wire [32-1:0] rd_slv_reg311         ;//rd

//rd_slv_reg312
wire [32-1:0] rd_slv_reg312         ;//rd

//rd_slv_reg313
wire [32-1:0] rd_slv_reg313         ;//rd

//rd_slv_reg314
wire [32-1:0] rd_slv_reg314         ;//rd

//rd_slv_reg3b1
wire [32-1:0] rd_slv_reg3b1         ;//rd

//rd_slv_reg3b2
wire [32-1:0] rd_slv_reg3b2         ;//rd

//rd_slv_reg3b3
wire [32-1:0] rd_slv_reg3b3         ;//rd

//rd_slv_reg3b4
wire [32-1:0] rd_slv_reg3b4         ;//rd

//rd_slv_reg3b5
wire [32-1:0] rd_slv_reg3b5         ;//rd

//rd_slv_reg3b6
wire [32-1:0] rd_slv_reg3b6         ;//rd

//rd_slv_reg3b7
wire [32-1:0] rd_slv_reg3b7         ;//rd

//rd_slv_reg3b8
wire [32-1:0] rd_slv_reg3b8         ;//rd

//rd_slv_reg3b9
wire [32-1:0] rd_slv_reg3b9         ;//rd

//rd_slv_reg3ba
wire [32-1:0] rd_slv_reg3ba         ;//rd

//rd_slv_reg3bb
wire [32-1:0] rd_slv_reg3bb         ;//rd

//rd_slv_reg3bc
wire [32-1:0] rd_slv_reg3bc         ;//rd

//rd_slv_reg3c1
wire [32-1:0] rd_slv_reg3c1         ;//rd

//rd_slv_reg3c2
wire [32-1:0] rd_slv_reg3c2         ;//rd

//rd_slv_reg3c3
wire [32-1:0] rd_slv_reg3c3         ;//rd

//rd_slv_reg3c4
wire [32-1:0] rd_slv_reg3c4         ;//rd

//rd_slv_reg3c5
wire [32-1:0] rd_slv_reg3c5         ;//rd

//rd_slv_reg3c6
wire [32-1:0] rd_slv_reg3c6         ;//rd

//rd_slv_reg3c7
wire [32-1:0] rd_slv_reg3c7         ;//rd

//rd_slv_reg3c8
wire [32-1:0] rd_slv_reg3c8         ;//rd

//rd_slv_reg3d1
wire [32-1:0] rd_slv_reg3d1         ;//rd

//rd_slv_reg3d2
wire [32-1:0] rd_slv_reg3d2         ;//rd

//rd_slv_reg3d3
wire [32-1:0] rd_slv_reg3d3         ;//rd

//rd_slv_reg3d4
wire [32-1:0] rd_slv_reg3d4         ;//rd

//rd_slv_reg3d5
wire [32-1:0] rd_slv_reg3d5         ;//rd

//rd_slv_reg3d6
wire [32-1:0] rd_slv_reg3d6         ;//rd

//rd_slv_reg3d7
wire [32-1:0] rd_slv_reg3d7         ;//rd

//rd_slv_reg3d8
wire [32-1:0] rd_slv_reg3d8         ;//rd

//rd_slv_reg3e1
wire [32-1:0] rd_slv_reg3e1         ;//rd

//rd_slv_reg3e2
wire [32-1:0] rd_slv_reg3e2         ;//rd

//rd_slv_reg3e3
wire [32-1:0] rd_slv_reg3e3         ;//rd

//rd_slv_reg3e4
wire [32-1:0] rd_slv_reg3e4         ;//rd

//rd_slv_reg3e5
wire [32-1:0] rd_slv_reg3e5         ;//rd

//rd_slv_reg3e6
wire [32-1:0] rd_slv_reg3e6         ;//rd

//rd_slv_reg3e7
wire [32-1:0] rd_slv_reg3e7         ;//rd

//rd_slv_reg3e8
wire [32-1:0] rd_slv_reg3e8         ;//rd

//rd_slv_reg3ff
wire [32-1:0] rd_slv_reg3ff         ;//rd

//----------------------------control logic---------------------------------------------
wire ram_wr_en        = ram_wr_en_i                                   ;
wire ram_rd_en        = ram_rd_en_i                                   ;

//slv_reg001
wire slv_reg001_wr    = ( ram_wr_addr_i == SLV_REG001    ) && ram_wr_en;

//slv_reg002
wire slv_reg002_wr    = ( ram_wr_addr_i == SLV_REG002    ) && ram_wr_en;

//slv_reg003
wire slv_reg003_wr    = ( ram_wr_addr_i == SLV_REG003    ) && ram_wr_en;

//slv_reg004
wire slv_reg004_wr    = ( ram_wr_addr_i == SLV_REG004    ) && ram_wr_en;

//slv_reg005
wire slv_reg005_wr    = ( ram_wr_addr_i == SLV_REG005    ) && ram_wr_en;

//slv_reg006
wire slv_reg006_wr    = ( ram_wr_addr_i == SLV_REG006    ) && ram_wr_en;

//slv_reg007
wire slv_reg007_wr    = ( ram_wr_addr_i == SLV_REG007    ) && ram_wr_en;

//slv_reg008
wire slv_reg008_wr    = ( ram_wr_addr_i == SLV_REG008    ) && ram_wr_en;

//slv_reg009
wire slv_reg009_wr    = ( ram_wr_addr_i == SLV_REG009    ) && ram_wr_en;

//slv_reg00a
wire slv_reg00a_wr    = ( ram_wr_addr_i == SLV_REG00A    ) && ram_wr_en;

//slv_reg00b
wire slv_reg00b_wr    = ( ram_wr_addr_i == SLV_REG00B    ) && ram_wr_en;

//slv_reg00c
wire slv_reg00c_wr    = ( ram_wr_addr_i == SLV_REG00C    ) && ram_wr_en;

//slv_reg00d
wire slv_reg00d_wr    = ( ram_wr_addr_i == SLV_REG00D    ) && ram_wr_en;

//slv_reg00f
wire slv_reg00f_wr    = ( ram_wr_addr_i == SLV_REG00F    ) && ram_wr_en;

//slv_reg010
wire slv_reg010_wr    = ( ram_wr_addr_i == SLV_REG010    ) && ram_wr_en;

//slv_reg011
wire slv_reg011_wr    = ( ram_wr_addr_i == SLV_REG011    ) && ram_wr_en;

//slv_reg012
wire slv_reg012_wr    = ( ram_wr_addr_i == SLV_REG012    ) && ram_wr_en;

//slv_reg013
wire slv_reg013_wr    = ( ram_wr_addr_i == SLV_REG013    ) && ram_wr_en;

//slv_reg014
wire slv_reg014_wr    = ( ram_wr_addr_i == SLV_REG014    ) && ram_wr_en;

//slv_reg015
wire slv_reg015_wr    = ( ram_wr_addr_i == SLV_REG015    ) && ram_wr_en;

//slv_reg016
wire slv_reg016_wr    = ( ram_wr_addr_i == SLV_REG016    ) && ram_wr_en;

//slv_reg017
wire slv_reg017_wr    = ( ram_wr_addr_i == SLV_REG017    ) && ram_wr_en;

//slv_reg018
wire slv_reg018_wr    = ( ram_wr_addr_i == SLV_REG018    ) && ram_wr_en;

//slv_reg019
wire slv_reg019_wr    = ( ram_wr_addr_i == SLV_REG019    ) && ram_wr_en;

//slv_reg01a
wire slv_reg01a_wr    = ( ram_wr_addr_i == SLV_REG01A    ) && ram_wr_en;

//slv_reg01b
wire slv_reg01b_wr    = ( ram_wr_addr_i == SLV_REG01B    ) && ram_wr_en;

//slv_reg01c
wire slv_reg01c_wr    = ( ram_wr_addr_i == SLV_REG01C    ) && ram_wr_en;

//slv_reg01d
wire slv_reg01d_wr    = ( ram_wr_addr_i == SLV_REG01D    ) && ram_wr_en;

//slv_reg01e
wire slv_reg01e_wr    = ( ram_wr_addr_i == SLV_REG01E    ) && ram_wr_en;

//slv_reg01f
wire slv_reg01f_wr    = ( ram_wr_addr_i == SLV_REG01F    ) && ram_wr_en;

//slv_reg020
wire slv_reg020_wr    = ( ram_wr_addr_i == SLV_REG020    ) && ram_wr_en;

//slv_reg021
wire slv_reg021_wr    = ( ram_wr_addr_i == SLV_REG021    ) && ram_wr_en;

//slv_reg022
wire slv_reg022_wr    = ( ram_wr_addr_i == SLV_REG022    ) && ram_wr_en;

//slv_reg023
wire slv_reg023_wr    = ( ram_wr_addr_i == SLV_REG023    ) && ram_wr_en;

//slv_reg024
wire slv_reg024_wr    = ( ram_wr_addr_i == SLV_REG024    ) && ram_wr_en;

//slv_reg025
wire slv_reg025_wr    = ( ram_wr_addr_i == SLV_REG025    ) && ram_wr_en;

//slv_reg026
wire slv_reg026_wr    = ( ram_wr_addr_i == SLV_REG026    ) && ram_wr_en;

//slv_reg027
wire slv_reg027_wr    = ( ram_wr_addr_i == SLV_REG027    ) && ram_wr_en;

//slv_reg028
wire slv_reg028_wr    = ( ram_wr_addr_i == SLV_REG028    ) && ram_wr_en;

//slv_reg02d
wire slv_reg02d_wr    = ( ram_wr_addr_i == SLV_REG02D    ) && ram_wr_en;

//slv_reg02e
wire slv_reg02e_wr    = ( ram_wr_addr_i == SLV_REG02E    ) && ram_wr_en;

//slv_reg02f
wire slv_reg02f_wr    = ( ram_wr_addr_i == SLV_REG02F    ) && ram_wr_en;

//slv_reg030
wire slv_reg030_wr    = ( ram_wr_addr_i == SLV_REG030    ) && ram_wr_en;

//slv_reg031
wire slv_reg031_wr    = ( ram_wr_addr_i == SLV_REG031    ) && ram_wr_en;

//slv_reg033
wire slv_reg033_wr    = ( ram_wr_addr_i == SLV_REG033    ) && ram_wr_en;

//slv_reg034
wire slv_reg034_wr    = ( ram_wr_addr_i == SLV_REG034    ) && ram_wr_en;

//slv_reg041
wire slv_reg041_wr    = ( ram_wr_addr_i == SLV_REG041    ) && ram_wr_en;

//slv_reg042
wire slv_reg042_wr    = ( ram_wr_addr_i == SLV_REG042    ) && ram_wr_en;

//slv_reg043
wire slv_reg043_wr    = ( ram_wr_addr_i == SLV_REG043    ) && ram_wr_en;

//slv_reg044
wire slv_reg044_wr    = ( ram_wr_addr_i == SLV_REG044    ) && ram_wr_en;

//slv_reg045
wire slv_reg045_wr    = ( ram_wr_addr_i == SLV_REG045    ) && ram_wr_en;

//slv_reg046
wire slv_reg046_wr    = ( ram_wr_addr_i == SLV_REG046    ) && ram_wr_en;

//slv_reg047
wire slv_reg047_wr    = ( ram_wr_addr_i == SLV_REG047    ) && ram_wr_en;

//slv_reg048
wire slv_reg048_wr    = ( ram_wr_addr_i == SLV_REG048    ) && ram_wr_en;

//slv_reg049
wire slv_reg049_wr    = ( ram_wr_addr_i == SLV_REG049    ) && ram_wr_en;

//slv_reg051
wire slv_reg051_wr    = ( ram_wr_addr_i == SLV_REG051    ) && ram_wr_en;

//slv_reg052
wire slv_reg052_wr    = ( ram_wr_addr_i == SLV_REG052    ) && ram_wr_en;

//slv_reg053
wire slv_reg053_wr    = ( ram_wr_addr_i == SLV_REG053    ) && ram_wr_en;

//slv_reg054
wire slv_reg054_wr    = ( ram_wr_addr_i == SLV_REG054    ) && ram_wr_en;

//slv_reg055
wire slv_reg055_wr    = ( ram_wr_addr_i == SLV_REG055    ) && ram_wr_en;

//slv_reg056
wire slv_reg056_wr    = ( ram_wr_addr_i == SLV_REG056    ) && ram_wr_en;

//slv_reg057
wire slv_reg057_wr    = ( ram_wr_addr_i == SLV_REG057    ) && ram_wr_en;

//slv_reg058
wire slv_reg058_wr    = ( ram_wr_addr_i == SLV_REG058    ) && ram_wr_en;

//slv_reg059
wire slv_reg059_wr    = ( ram_wr_addr_i == SLV_REG059    ) && ram_wr_en;

//slv_reg05a
wire slv_reg05a_wr    = ( ram_wr_addr_i == SLV_REG05A    ) && ram_wr_en;

//slv_reg05b
wire slv_reg05b_wr    = ( ram_wr_addr_i == SLV_REG05B    ) && ram_wr_en;

//slv_reg05c
wire slv_reg05c_wr    = ( ram_wr_addr_i == SLV_REG05C    ) && ram_wr_en;

//slv_reg05d
wire slv_reg05d_wr    = ( ram_wr_addr_i == SLV_REG05D    ) && ram_wr_en;

//slv_reg05e
wire slv_reg05e_wr    = ( ram_wr_addr_i == SLV_REG05E    ) && ram_wr_en;

//slv_reg05f
wire slv_reg05f_wr    = ( ram_wr_addr_i == SLV_REG05F    ) && ram_wr_en;

//slv_reg060
wire slv_reg060_wr    = ( ram_wr_addr_i == SLV_REG060    ) && ram_wr_en;

//slv_reg061
wire slv_reg061_wr    = ( ram_wr_addr_i == SLV_REG061    ) && ram_wr_en;

//slv_reg062
wire slv_reg062_wr    = ( ram_wr_addr_i == SLV_REG062    ) && ram_wr_en;

//slv_reg063
wire slv_reg063_wr    = ( ram_wr_addr_i == SLV_REG063    ) && ram_wr_en;

//slv_reg064
wire slv_reg064_wr    = ( ram_wr_addr_i == SLV_REG064    ) && ram_wr_en;

//slv_reg065
wire slv_reg065_wr    = ( ram_wr_addr_i == SLV_REG065    ) && ram_wr_en;

//slv_reg066
wire slv_reg066_wr    = ( ram_wr_addr_i == SLV_REG066    ) && ram_wr_en;

//slv_reg067
wire slv_reg067_wr    = ( ram_wr_addr_i == SLV_REG067    ) && ram_wr_en;

//slv_reg068
wire slv_reg068_wr    = ( ram_wr_addr_i == SLV_REG068    ) && ram_wr_en;

//slv_reg069
wire slv_reg069_wr    = ( ram_wr_addr_i == SLV_REG069    ) && ram_wr_en;

//slv_reg06a
wire slv_reg06a_wr    = ( ram_wr_addr_i == SLV_REG06A    ) && ram_wr_en;

//slv_reg06b
wire slv_reg06b_wr    = ( ram_wr_addr_i == SLV_REG06B    ) && ram_wr_en;

//slv_reg06c
wire slv_reg06c_wr    = ( ram_wr_addr_i == SLV_REG06C    ) && ram_wr_en;

//slv_reg06d
wire slv_reg06d_wr    = ( ram_wr_addr_i == SLV_REG06D    ) && ram_wr_en;

//slv_reg06e
wire slv_reg06e_wr    = ( ram_wr_addr_i == SLV_REG06E    ) && ram_wr_en;

//slv_reg06f
wire slv_reg06f_wr    = ( ram_wr_addr_i == SLV_REG06F    ) && ram_wr_en;

//slv_reg070
wire slv_reg070_wr    = ( ram_wr_addr_i == SLV_REG070    ) && ram_wr_en;

//slv_reg071
wire slv_reg071_wr    = ( ram_wr_addr_i == SLV_REG071    ) && ram_wr_en;

//slv_reg080
wire slv_reg080_wr    = ( ram_wr_addr_i == SLV_REG080    ) && ram_wr_en;

//slv_reg086
wire slv_reg086_wr    = ( ram_wr_addr_i == SLV_REG086    ) && ram_wr_en;

//slv_reg087
wire slv_reg087_wr    = ( ram_wr_addr_i == SLV_REG087    ) && ram_wr_en;

//slv_reg088
wire slv_reg088_wr    = ( ram_wr_addr_i == SLV_REG088    ) && ram_wr_en;

//slv_reg090
wire slv_reg090_wr    = ( ram_wr_addr_i == SLV_REG090    ) && ram_wr_en;

//slv_reg091
wire slv_reg091_wr    = ( ram_wr_addr_i == SLV_REG091    ) && ram_wr_en;

//slv_reg092
wire slv_reg092_wr    = ( ram_wr_addr_i == SLV_REG092    ) && ram_wr_en;

//slv_reg0B1
wire slv_reg0b1_wr    = ( ram_wr_addr_i == SLV_REG0B1    ) && ram_wr_en;

//slv_reg0B3
wire slv_reg0b3_wr    = ( ram_wr_addr_i == SLV_REG0B3    ) && ram_wr_en;

//slv_reg0B4
wire slv_reg0b4_wr    = ( ram_wr_addr_i == SLV_REG0B4    ) && ram_wr_en;

//slv_reg0B5
wire slv_reg0b5_wr    = ( ram_wr_addr_i == SLV_REG0B5    ) && ram_wr_en;

//slv_reg0B6
wire slv_reg0b6_wr    = ( ram_wr_addr_i == SLV_REG0B6    ) && ram_wr_en;

//slv_reg0B7
wire slv_reg0b7_wr    = ( ram_wr_addr_i == SLV_REG0B7    ) && ram_wr_en;

//slv_reg0B8
wire slv_reg0b8_wr    = ( ram_wr_addr_i == SLV_REG0B8    ) && ram_wr_en;

//slv_reg0B9
wire slv_reg0b9_wr    = ( ram_wr_addr_i == SLV_REG0B9    ) && ram_wr_en;

//slv_reg0Ba
wire slv_reg0ba_wr    = ( ram_wr_addr_i == SLV_REG0BA    ) && ram_wr_en;

//slv_reg0C0
wire slv_reg0c0_wr    = ( ram_wr_addr_i == SLV_REG0C0    ) && ram_wr_en;

//slv_reg0C1
wire slv_reg0c1_wr    = ( ram_wr_addr_i == SLV_REG0C1    ) && ram_wr_en;

//slv_reg0C2
wire slv_reg0c2_wr    = ( ram_wr_addr_i == SLV_REG0C2    ) && ram_wr_en;

//slv_reg0C3
wire slv_reg0c3_wr    = ( ram_wr_addr_i == SLV_REG0C3    ) && ram_wr_en;

//slv_reg0C4
wire slv_reg0c4_wr    = ( ram_wr_addr_i == SLV_REG0C4    ) && ram_wr_en;

//slv_reg0C5
wire slv_reg0c5_wr    = ( ram_wr_addr_i == SLV_REG0C5    ) && ram_wr_en;

//slv_reg0C6
wire slv_reg0c6_wr    = ( ram_wr_addr_i == SLV_REG0C6    ) && ram_wr_en;

//slv_reg0C7
wire slv_reg0c7_wr    = ( ram_wr_addr_i == SLV_REG0C7    ) && ram_wr_en;

//slv_reg0C8
wire slv_reg0c8_wr    = ( ram_wr_addr_i == SLV_REG0C8    ) && ram_wr_en;

//slv_reg0C9
wire slv_reg0c9_wr    = ( ram_wr_addr_i == SLV_REG0C9    ) && ram_wr_en;

//slv_reg0Ca
wire slv_reg0ca_wr    = ( ram_wr_addr_i == SLV_REG0CA    ) && ram_wr_en;

//slv_reg0Cb
wire slv_reg0cb_wr    = ( ram_wr_addr_i == SLV_REG0CB    ) && ram_wr_en;

//slv_reg0Cc
wire slv_reg0cc_wr    = ( ram_wr_addr_i == SLV_REG0CC    ) && ram_wr_en;

//slv_reg0Cd
wire slv_reg0cd_wr    = ( ram_wr_addr_i == SLV_REG0CD    ) && ram_wr_en;

//slv_reg0D0
wire slv_reg0d0_wr    = ( ram_wr_addr_i == SLV_REG0D0    ) && ram_wr_en;

//slv_reg0D1
wire slv_reg0d1_wr    = ( ram_wr_addr_i == SLV_REG0D1    ) && ram_wr_en;

//slv_reg0D2
wire slv_reg0d2_wr    = ( ram_wr_addr_i == SLV_REG0D2    ) && ram_wr_en;

//slv_reg0D3
wire slv_reg0d3_wr    = ( ram_wr_addr_i == SLV_REG0D3    ) && ram_wr_en;

//slv_reg0D4
wire slv_reg0d4_wr    = ( ram_wr_addr_i == SLV_REG0D4    ) && ram_wr_en;

//slv_reg0D5
wire slv_reg0d5_wr    = ( ram_wr_addr_i == SLV_REG0D5    ) && ram_wr_en;

//slv_reg0D6
wire slv_reg0d6_wr    = ( ram_wr_addr_i == SLV_REG0D6    ) && ram_wr_en;

//slv_reg0D7
wire slv_reg0d7_wr    = ( ram_wr_addr_i == SLV_REG0D7    ) && ram_wr_en;

//slv_reg0D8
wire slv_reg0d8_wr    = ( ram_wr_addr_i == SLV_REG0D8    ) && ram_wr_en;

//slv_reg0D9
wire slv_reg0d9_wr    = ( ram_wr_addr_i == SLV_REG0D9    ) && ram_wr_en;

//slv_reg0Da
wire slv_reg0da_wr    = ( ram_wr_addr_i == SLV_REG0DA    ) && ram_wr_en;

//slv_reg0Db
wire slv_reg0db_wr    = ( ram_wr_addr_i == SLV_REG0DB    ) && ram_wr_en;

//slv_reg0Dc
wire slv_reg0dc_wr    = ( ram_wr_addr_i == SLV_REG0DC    ) && ram_wr_en;

//slv_reg0Dd
wire slv_reg0dd_wr    = ( ram_wr_addr_i == SLV_REG0DD    ) && ram_wr_en;

//slv_reg0f1
wire slv_reg0f1_wr    = ( ram_wr_addr_i == SLV_REG0F1    ) && ram_wr_en;

//slv_reg0f2
wire slv_reg0f2_wr    = ( ram_wr_addr_i == SLV_REG0F2    ) && ram_wr_en;

//slv_reg0f3
wire slv_reg0f3_wr    = ( ram_wr_addr_i == SLV_REG0F3    ) && ram_wr_en;

//slv_reg0f4
wire slv_reg0f4_wr    = ( ram_wr_addr_i == SLV_REG0F4    ) && ram_wr_en;

//slv_reg0f5
wire slv_reg0f5_wr    = ( ram_wr_addr_i == SLV_REG0F5    ) && ram_wr_en;

//slv_reg0f6
wire slv_reg0f6_wr    = ( ram_wr_addr_i == SLV_REG0F6    ) && ram_wr_en;

//slv_reg0f7
wire slv_reg0f7_wr    = ( ram_wr_addr_i == SLV_REG0F7    ) && ram_wr_en;

//slv_reg0f8
wire slv_reg0f8_wr    = ( ram_wr_addr_i == SLV_REG0F8    ) && ram_wr_en;

//slv_reg0f9
wire slv_reg0f9_wr    = ( ram_wr_addr_i == SLV_REG0F9    ) && ram_wr_en;

//slv_reg0fa
wire slv_reg0fa_wr    = ( ram_wr_addr_i == SLV_REG0FA    ) && ram_wr_en;

//slv_reg0fb
wire slv_reg0fb_wr    = ( ram_wr_addr_i == SLV_REG0FB    ) && ram_wr_en;

//slv_reg0fc
wire slv_reg0fc_wr    = ( ram_wr_addr_i == SLV_REG0FC    ) && ram_wr_en;

//--------------------------------processing------------------------------------------------

//slv_reg001
assign slv_reg001[31:16]       = 16'h0                ;
assign Workmod                 = slv_reg001_reg[15:0] ;
assign slv_reg001[15:0]        = Workmod              ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg001_reg <= 'ha5a5;
    else if( slv_reg001_wr )
        slv_reg001_reg <= ram_wr_data_i;
end


//slv_reg002
assign slv_reg002[31:16]       = 16'h0                ;
assign Func                    = slv_reg002_reg[15:0] ;
assign slv_reg002[15:0]        = Func                 ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg002_reg <= 'h5a00;
    else if( slv_reg002_wr )
        slv_reg002_reg <= ram_wr_data_i;
end


//slv_reg003
assign slv_reg003[31:16]       = 16'h0                ;
assign SENSE                   = slv_reg003_reg[15:0] ;
assign slv_reg003[15:0]        = SENSE                ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg003_reg <= 'h5a5a;
    else if( slv_reg003_wr )
        slv_reg003_reg <= ram_wr_data_i;
end


//slv_reg004
assign slv_reg004[31:16]       = 16'h0                ;
assign Model                   = slv_reg004_reg[15:0] ;
assign slv_reg004[15:0]        = Model                ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg004_reg <= 'h0;
    else if( slv_reg004_wr )
        slv_reg004_reg <= ram_wr_data_i;
end


//slv_reg005
assign slv_reg005[31:16]       = 16'h0                ;
assign Worktype                = slv_reg005_reg[15:0] ;
assign slv_reg005[15:0]        = Worktype             ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg005_reg <= 'h5a5a;
    else if( slv_reg005_wr )
        slv_reg005_reg <= ram_wr_data_i;
end


//slv_reg006
assign slv_reg006[31:16]       = 16'h0                ;
assign M_S                     = slv_reg006_reg[15:0] ;
assign slv_reg006[15:0]        = M_S                  ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg006_reg <= 'h5a5a;
    else if( slv_reg006_wr )
        slv_reg006_reg <= ram_wr_data_i;
end


//slv_reg007
assign slv_reg007[31:16]        = 16'h0                ;
assign Clear_alarm              = slv_reg007_reg[15:0] ;
assign slv_reg007[15:0]         = Clear_alarm          ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg007_reg <= 'h5a5a;
    else if( slv_reg007_wr )
        slv_reg007_reg <= ram_wr_data_i;
end


//slv_reg008
assign slv_reg008[31:16]       = 16'h0                ;
assign RUN_flag                = slv_reg008_reg[15:0] ;
assign slv_reg008[15:0]        = RUN_flag             ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg008_reg <= 'ha5a5;
    else if( slv_reg008_wr )
        slv_reg008_reg <= ram_wr_data_i;
end


//slv_reg009
assign slv_reg009[31:16]       = 16'h0                ;
assign Short                   = slv_reg009_reg[15:0] ;
assign slv_reg009[15:0]        = Short                ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg009_reg <= 'ha5a5;
    else if( slv_reg009_wr )
        slv_reg009_reg <= ram_wr_data_i;
end


//slv_reg00a
assign Von                     = slv_reg00a_reg[31:0] ;
assign slv_reg00a[31:0]        = Von                  ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg00a_reg <= 'h0;
    else if( slv_reg00a_wr )
        slv_reg00a_reg <= ram_wr_data_i;
end


//slv_reg00b
assign SR_slew                 = slv_reg00b_reg[31:0] ;
assign slv_reg00b[31:0]        = SR_slew              ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg00b_reg <= 'h1;
    else if( slv_reg00b_wr )
        slv_reg00b_reg <= ram_wr_data_i;
end


//slv_reg00c
assign SF_slew                 = slv_reg00c_reg[31:0] ;
assign slv_reg00c[31:0]        = SF_slew              ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg00c_reg <= 'h1;
    else if( slv_reg00c_wr )
        slv_reg00c_reg <= ram_wr_data_i;
end


//slv_reg00d
assign slv_reg00d[31:16]                = 16'h0                ;
assign sense_err_threshold              = slv_reg00d_reg[15:0] ;
assign slv_reg00d[15:0]                 = sense_err_threshold  ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg00d_reg <= 'h0;
    else if( slv_reg00d_wr )
        slv_reg00d_reg <= ram_wr_data_i;
end


//slv_reg00f
assign slv_reg00f[31:16]       = 16'h0                ;
assign Von_Latch               = slv_reg00f_reg[15:0] ;
assign slv_reg00f[15:0]        = Von_Latch            ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg00f_reg <= 'h5a5a;
    else if( slv_reg00f_wr )
        slv_reg00f_reg <= ram_wr_data_i;
end


//slv_reg010
assign Voff                    = slv_reg010_reg[31:0] ;
assign slv_reg010[31:0]        = Voff                 ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg010_reg <= 'h0;
    else if( slv_reg010_wr )
        slv_reg010_reg <= ram_wr_data_i;
end


//slv_reg011
assign Iset_L                  = slv_reg011_reg[31:0] ;
assign slv_reg011[31:0]        = Iset_L               ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg011_reg <= 'h0;
    else if( slv_reg011_wr )
        slv_reg011_reg <= ram_wr_data_i;
end


//slv_reg012
assign Iset_H                  = slv_reg012_reg[31:0] ;
assign slv_reg012[31:0]        = Iset_H               ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg012_reg <= 'h0;
    else if( slv_reg012_wr )
        slv_reg012_reg <= ram_wr_data_i;
end


//slv_reg013
assign Vset_L                  = slv_reg013_reg[31:0] ;
assign slv_reg013[31:0]        = Vset_L               ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg013_reg <= 'h0;
    else if( slv_reg013_wr )
        slv_reg013_reg <= ram_wr_data_i;
end


//slv_reg014
assign Vset_H                  = slv_reg014_reg[31:0] ;
assign slv_reg014[31:0]        = Vset_H               ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg014_reg <= 'h0;
    else if( slv_reg014_wr )
        slv_reg014_reg <= ram_wr_data_i;
end


//slv_reg015
assign Pset_L                  = slv_reg015_reg[31:0] ;
assign slv_reg015[31:0]        = Pset_L               ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg015_reg <= 'h0;
    else if( slv_reg015_wr )
        slv_reg015_reg <= ram_wr_data_i;
end


//slv_reg016
assign Pset_H                  = slv_reg016_reg[31:0] ;
assign slv_reg016[31:0]        = Pset_H               ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg016_reg <= 'h0;
    else if( slv_reg016_wr )
        slv_reg016_reg <= ram_wr_data_i;
end


//slv_reg017
assign Rset_L                  = slv_reg017_reg[31:0] ;
assign slv_reg017[31:0]        = Rset_L               ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg017_reg <= 'h0;
    else if( slv_reg017_wr )
        slv_reg017_reg <= ram_wr_data_i;
end


//slv_reg018
assign Rset_H                  = slv_reg018_reg[31:0] ;
assign slv_reg018[31:0]        = Rset_H               ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg018_reg <= 'h0;
    else if( slv_reg018_wr )
        slv_reg018_reg <= ram_wr_data_i;
end


//slv_reg019
assign Iset1_L                 = slv_reg019_reg[31:0] ;
assign slv_reg019[31:0]        = Iset1_L              ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg019_reg <= 'h0;
    else if( slv_reg019_wr )
        slv_reg019_reg <= ram_wr_data_i;
end


//slv_reg01a
assign Iset1_H                 = slv_reg01a_reg[31:0] ;
assign slv_reg01a[31:0]        = Iset1_H              ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg01a_reg <= 'h0;
    else if( slv_reg01a_wr )
        slv_reg01a_reg <= ram_wr_data_i;
end


//slv_reg01b
assign Iset2_L                 = slv_reg01b_reg[31:0] ;
assign slv_reg01b[31:0]        = Iset2_L              ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg01b_reg <= 'h0;
    else if( slv_reg01b_wr )
        slv_reg01b_reg <= ram_wr_data_i;
end


//slv_reg01c
assign Iset2_H                 = slv_reg01c_reg[31:0] ;
assign slv_reg01c[31:0]        = Iset2_H              ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg01c_reg <= 'h0;
    else if( slv_reg01c_wr )
        slv_reg01c_reg <= ram_wr_data_i;
end


//slv_reg01d
assign Vset1_L                 = slv_reg01d_reg[31:0] ;
assign slv_reg01d[31:0]        = Vset1_L              ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg01d_reg <= 'h0;
    else if( slv_reg01d_wr )
        slv_reg01d_reg <= ram_wr_data_i;
end


//slv_reg01e
assign Vset1_H                 = slv_reg01e_reg[31:0] ;
assign slv_reg01e[31:0]        = Vset1_H              ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg01e_reg <= 'h0;
    else if( slv_reg01e_wr )
        slv_reg01e_reg <= ram_wr_data_i;
end


//slv_reg01f
assign Vset2_L                 = slv_reg01f_reg[31:0] ;
assign slv_reg01f[31:0]        = Vset2_L              ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg01f_reg <= 'h0;
    else if( slv_reg01f_wr )
        slv_reg01f_reg <= ram_wr_data_i;
end


//slv_reg020
assign Vset2_H                 = slv_reg020_reg[31:0] ;
assign slv_reg020[31:0]        = Vset2_H              ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg020_reg <= 'h0;
    else if( slv_reg020_wr )
        slv_reg020_reg <= ram_wr_data_i;
end


//slv_reg021
assign Pset1_L                 = slv_reg021_reg[31:0] ;
assign slv_reg021[31:0]        = Pset1_L              ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg021_reg <= 'h0;
    else if( slv_reg021_wr )
        slv_reg021_reg <= ram_wr_data_i;
end


//slv_reg022
assign Pset1_H                 = slv_reg022_reg[31:0] ;
assign slv_reg022[31:0]        = Pset1_H              ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg022_reg <= 'h0;
    else if( slv_reg022_wr )
        slv_reg022_reg <= ram_wr_data_i;
end


//slv_reg023
assign Pset2_L                 = slv_reg023_reg[31:0] ;
assign slv_reg023[31:0]        = Pset2_L              ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg023_reg <= 'h0;
    else if( slv_reg023_wr )
        slv_reg023_reg <= ram_wr_data_i;
end


//slv_reg024
assign Pset2_H                 = slv_reg024_reg[31:0] ;
assign slv_reg024[31:0]        = Pset2_H              ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg024_reg <= 'h0;
    else if( slv_reg024_wr )
        slv_reg024_reg <= ram_wr_data_i;
end


//slv_reg025
assign Rset1_L                 = slv_reg025_reg[31:0] ;
assign slv_reg025[31:0]        = Rset1_L              ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg025_reg <= 'h0;
    else if( slv_reg025_wr )
        slv_reg025_reg <= ram_wr_data_i;
end


//slv_reg026
assign Rset1_H                 = slv_reg026_reg[31:0] ;
assign slv_reg026[31:0]        = Rset1_H              ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg026_reg <= 'h0;
    else if( slv_reg026_wr )
        slv_reg026_reg <= ram_wr_data_i;
end


//slv_reg027
assign Rset2_L                 = slv_reg027_reg[31:0] ;
assign slv_reg027[31:0]        = Rset2_L              ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg027_reg <= 'h0;
    else if( slv_reg027_wr )
        slv_reg027_reg <= ram_wr_data_i;
end


//slv_reg028
assign Rset2_H                 = slv_reg028_reg[31:0] ;
assign slv_reg028[31:0]        = Rset2_H              ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg028_reg <= 'h0;
    else if( slv_reg028_wr )
        slv_reg028_reg <= ram_wr_data_i;
end


//slv_reg02d
assign DR_slew                 = slv_reg02d_reg[31:0] ;
assign slv_reg02d[31:0]        = DR_slew              ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg02d_reg <= 'h1;
    else if( slv_reg02d_wr )
        slv_reg02d_reg <= ram_wr_data_i;
end


//slv_reg02e
assign DF_slew                 = slv_reg02e_reg[31:0] ;
assign slv_reg02e[31:0]        = DF_slew              ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg02e_reg <= 'h1;
    else if( slv_reg02e_wr )
        slv_reg02e_reg <= ram_wr_data_i;
end


//slv_reg02f
assign slv_reg02f[31:16]       = 16'h0                ;
assign Vrange                  = slv_reg02f_reg[15:0] ;
assign slv_reg02f[15:0]        = Vrange               ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg02f_reg <= 'h5a5a;
    else if( slv_reg02f_wr )
        slv_reg02f_reg <= ram_wr_data_i;
end


//slv_reg030
assign CVspeed                 = slv_reg030_reg[31:0] ;
assign slv_reg030[31:0]        = CVspeed              ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg030_reg <= 'h3;
    else if( slv_reg030_wr )
        slv_reg030_reg <= ram_wr_data_i;
end


//slv_reg031
assign CV_slew                 = slv_reg031_reg[31:0] ;
assign slv_reg031[31:0]        = CV_slew              ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg031_reg <= 'h1;
    else if( slv_reg031_wr )
        slv_reg031_reg <= ram_wr_data_i;
end


//slv_reg033
assign filter_period              = slv_reg033_reg[31:0] ;
assign slv_reg033[31:0]           = filter_period        ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg033_reg <= 'h0;
    else if( slv_reg033_wr )
        slv_reg033_reg <= ram_wr_data_i;
end


//slv_reg034
assign num_paral               = slv_reg034_reg[31:0] ;
assign slv_reg034[31:0]        = num_paral            ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg034_reg <= 'h0;
    else if( slv_reg034_wr )
        slv_reg034_reg <= ram_wr_data_i;
end


//slv_reg041
assign I_lim_L                 = slv_reg041_reg[31:0] ;
assign slv_reg041[31:0]        = I_lim_L              ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg041_reg <= 'h9c40;
    else if( slv_reg041_wr )
        slv_reg041_reg <= ram_wr_data_i;
end


//slv_reg042
assign I_lim_H                 = slv_reg042_reg[31:0] ;
assign slv_reg042[31:0]        = I_lim_H              ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg042_reg <= 'h0;
    else if( slv_reg042_wr )
        slv_reg042_reg <= ram_wr_data_i;
end


//slv_reg043
assign V_lim_L                 = slv_reg043_reg[31:0] ;
assign slv_reg043[31:0]        = V_lim_L              ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg043_reg <= 'hd4c0;
    else if( slv_reg043_wr )
        slv_reg043_reg <= ram_wr_data_i;
end


//slv_reg044
assign V_lim_H                 = slv_reg044_reg[31:0] ;
assign slv_reg044[31:0]        = V_lim_H              ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg044_reg <= 'h1;
    else if( slv_reg044_wr )
        slv_reg044_reg <= ram_wr_data_i;
end


//slv_reg045
assign P_lim_L                 = slv_reg045_reg[31:0] ;
assign slv_reg045[31:0]        = P_lim_L              ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg045_reg <= 'h900;
    else if( slv_reg045_wr )
        slv_reg045_reg <= ram_wr_data_i;
end


//slv_reg046
assign P_lim_H                 = slv_reg046_reg[31:0] ;
assign slv_reg046[31:0]        = P_lim_H              ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg046_reg <= 'h3d;
    else if( slv_reg046_wr )
        slv_reg046_reg <= ram_wr_data_i;
end


//slv_reg047
assign CV_lim_L                = slv_reg047_reg[31:0] ;
assign slv_reg047[31:0]        = CV_lim_L             ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg047_reg <= 'h9c40;
    else if( slv_reg047_wr )
        slv_reg047_reg <= ram_wr_data_i;
end


//slv_reg048
assign CV_lim_H                = slv_reg048_reg[31:0] ;
assign slv_reg048[31:0]        = CV_lim_H             ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg048_reg <= 'h0;
    else if( slv_reg048_wr )
        slv_reg048_reg <= ram_wr_data_i;
end


//slv_reg049
assign Pro_time                = slv_reg049_reg[31:0] ;
assign slv_reg049[31:0]        = Pro_time             ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg049_reg <= 'ha;
    else if( slv_reg049_wr )
        slv_reg049_reg <= ram_wr_data_i;
end


//slv_reg051
assign VH_k                    = slv_reg051_reg[31:0] ;
assign slv_reg051[31:0]        = VH_k                 ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg051_reg <= 'h9933;
    else if( slv_reg051_wr )
        slv_reg051_reg <= ram_wr_data_i;
end


//slv_reg052
assign VH_a                    = slv_reg052_reg[31:0] ;
assign slv_reg052[31:0]        = VH_a                 ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg052_reg <= 'h0;
    else if( slv_reg052_wr )
        slv_reg052_reg <= ram_wr_data_i;
end


//slv_reg053
assign VsH_k                   = slv_reg053_reg[31:0] ;
assign slv_reg053[31:0]        = VsH_k                ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg053_reg <= 'h9933;
    else if( slv_reg053_wr )
        slv_reg053_reg <= ram_wr_data_i;
end


//slv_reg054
assign VsH_a                   = slv_reg054_reg[31:0] ;
assign slv_reg054[31:0]        = VsH_a                ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg054_reg <= 'h0;
    else if( slv_reg054_wr )
        slv_reg054_reg <= ram_wr_data_i;
end


//slv_reg055
assign I1_k                    = slv_reg055_reg[31:0] ;
assign slv_reg055[31:0]        = I1_k                 ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg055_reg <= 'he20e;
    else if( slv_reg055_wr )
        slv_reg055_reg <= ram_wr_data_i;
end


//slv_reg056
assign I1_a                    = slv_reg056_reg[31:0] ;
assign slv_reg056[31:0]        = I1_a                 ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg056_reg <= 'h0;
    else if( slv_reg056_wr )
        slv_reg056_reg <= ram_wr_data_i;
end


//slv_reg057
assign I2_k                    = slv_reg057_reg[31:0] ;
assign slv_reg057[31:0]        = I2_k                 ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg057_reg <= 'h169b;
    else if( slv_reg057_wr )
        slv_reg057_reg <= ram_wr_data_i;
end


//slv_reg058
assign I2_a                    = slv_reg058_reg[31:0] ;
assign slv_reg058[31:0]        = I2_a                 ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg058_reg <= 'h0;
    else if( slv_reg058_wr )
        slv_reg058_reg <= ram_wr_data_i;
end


//slv_reg059
assign VL_k                    = slv_reg059_reg[31:0] ;
assign slv_reg059[31:0]        = VL_k                 ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg059_reg <= 'hded;
    else if( slv_reg059_wr )
        slv_reg059_reg <= ram_wr_data_i;
end


//slv_reg05a
assign VL_a                    = slv_reg05a_reg[31:0] ;
assign slv_reg05a[31:0]        = VL_a                 ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg05a_reg <= 'h0;
    else if( slv_reg05a_wr )
        slv_reg05a_reg <= ram_wr_data_i;
end


//slv_reg05b
assign VsL_k                   = slv_reg05b_reg[31:0] ;
assign slv_reg05b[31:0]        = VsL_k                ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg05b_reg <= 'hded;
    else if( slv_reg05b_wr )
        slv_reg05b_reg <= ram_wr_data_i;
end


//slv_reg05c
assign VsL_a                   = slv_reg05c_reg[31:0] ;
assign slv_reg05c[31:0]        = VsL_a                ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg05c_reg <= 'h0;
    else if( slv_reg05c_wr )
        slv_reg05c_reg <= ram_wr_data_i;
end


//slv_reg05d
assign It1_k                   = slv_reg05d_reg[31:0] ;
assign slv_reg05d[31:0]        = It1_k                ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg05d_reg <= 'hd802;
    else if( slv_reg05d_wr )
        slv_reg05d_reg <= ram_wr_data_i;
end


//slv_reg05e
assign It1_a                   = slv_reg05e_reg[31:0] ;
assign slv_reg05e[31:0]        = It1_a                ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg05e_reg <= 'h0;
    else if( slv_reg05e_wr )
        slv_reg05e_reg <= ram_wr_data_i;
end


//slv_reg05f
assign It2_k                   = slv_reg05f_reg[31:0] ;
assign slv_reg05f[31:0]        = It2_k                ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg05f_reg <= 'h159a;
    else if( slv_reg05f_wr )
        slv_reg05f_reg <= ram_wr_data_i;
end


//slv_reg060
assign It2_a                   = slv_reg060_reg[31:0] ;
assign slv_reg060[31:0]        = It2_a                ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg060_reg <= 'h0;
    else if( slv_reg060_wr )
        slv_reg060_reg <= ram_wr_data_i;
end


//slv_reg061
assign CC_k                    = slv_reg061_reg[31:0] ;
assign slv_reg061[31:0]        = CC_k                 ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg061_reg <= 'h39ac;
    else if( slv_reg061_wr )
        slv_reg061_reg <= ram_wr_data_i;
end


//slv_reg062
assign CC_a                    = slv_reg062_reg[31:0] ;
assign slv_reg062[31:0]        = CC_a                 ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg062_reg <= 'h555;
    else if( slv_reg062_wr )
        slv_reg062_reg <= ram_wr_data_i;
end


//slv_reg063
assign CVH_k                   = slv_reg063_reg[31:0] ;
assign slv_reg063[31:0]        = CVH_k                ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg063_reg <= 'hd7ed;
    else if( slv_reg063_wr )
        slv_reg063_reg <= ram_wr_data_i;
end


//slv_reg064
assign CVH_a                   = slv_reg064_reg[31:0] ;
assign slv_reg064[31:0]        = CVH_a                ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg064_reg <= 'h0;
    else if( slv_reg064_wr )
        slv_reg064_reg <= ram_wr_data_i;
end


//slv_reg065
assign CVL_k                   = slv_reg065_reg[31:0] ;
assign slv_reg065[31:0]        = CVL_k                ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg065_reg <= 'hd7ed;
    else if( slv_reg065_wr )
        slv_reg065_reg <= ram_wr_data_i;
end


//slv_reg066
assign CVL_a                   = slv_reg066_reg[31:0] ;
assign slv_reg066[31:0]        = CVL_a                ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg066_reg <= 'h0;
    else if( slv_reg066_wr )
        slv_reg066_reg <= ram_wr_data_i;
end


//slv_reg067
assign CVHs_k                  = slv_reg067_reg[31:0] ;
assign slv_reg067[31:0]        = CVHs_k               ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg067_reg <= 'hd7ed;
    else if( slv_reg067_wr )
        slv_reg067_reg <= ram_wr_data_i;
end


//slv_reg068
assign CVHs_a                  = slv_reg068_reg[31:0] ;
assign slv_reg068[31:0]        = CVHs_a               ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg068_reg <= 'h0;
    else if( slv_reg068_wr )
        slv_reg068_reg <= ram_wr_data_i;
end


//slv_reg069
assign CVLs_k                  = slv_reg069_reg[31:0] ;
assign slv_reg069[31:0]        = CVLs_k               ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg069_reg <= 'hd7ed;
    else if( slv_reg069_wr )
        slv_reg069_reg <= ram_wr_data_i;
end


//slv_reg06a
assign CVLs_a                  = slv_reg06a_reg[31:0] ;
assign slv_reg06a[31:0]        = CVLs_a               ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg06a_reg <= 'h0;
    else if( slv_reg06a_wr )
        slv_reg06a_reg <= ram_wr_data_i;
end


//slv_reg06b
assign s_k                     = slv_reg06b_reg[31:0] ;
assign slv_reg06b[31:0]        = s_k                  ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg06b_reg <= 'h320;
    else if( slv_reg06b_wr )
        slv_reg06b_reg <= ram_wr_data_i;
end


//slv_reg06c
assign s_a                     = slv_reg06c_reg[31:0] ;
assign slv_reg06c[31:0]        = s_a                  ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg06c_reg <= 'h5;
    else if( slv_reg06c_wr )
        slv_reg06c_reg <= ram_wr_data_i;
end


//slv_reg06d
assign m_k                     = slv_reg06d_reg[31:0] ;
assign slv_reg06d[31:0]        = m_k                  ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg06d_reg <= 'h5dc;
    else if( slv_reg06d_wr )
        slv_reg06d_reg <= ram_wr_data_i;
end


//slv_reg06e
assign m_a                     = slv_reg06e_reg[31:0] ;
assign slv_reg06e[31:0]        = m_a                  ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg06e_reg <= 'h64;
    else if( slv_reg06e_wr )
        slv_reg06e_reg <= ram_wr_data_i;
end


//slv_reg06f
assign f_k                     = slv_reg06f_reg[31:0] ;
assign slv_reg06f[31:0]        = f_k                  ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg06f_reg <= 'hc8;
    else if( slv_reg06f_wr )
        slv_reg06f_reg <= ram_wr_data_i;
end


//slv_reg070
assign f_a                     = slv_reg070_reg[31:0] ;
assign slv_reg070[31:0]        = f_a                  ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg070_reg <= 'h5;
    else if( slv_reg070_wr )
        slv_reg070_reg <= ram_wr_data_i;
end


//slv_reg071
assign CV_mode                 = slv_reg071_reg[31:0] ;
assign slv_reg071[31:0]        = CV_mode              ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg071_reg <= 'h0;
    else if( slv_reg071_wr )
        slv_reg071_reg <= ram_wr_data_i;
end


//slv_reg080
assign T1_L_cc                 = slv_reg080_reg[31:0] ;
assign slv_reg080[31:0]        = T1_L_cc              ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg080_reg <= 'h0;
    else if( slv_reg080_wr )
        slv_reg080_reg <= ram_wr_data_i;
end


//slv_reg086
assign T1_H_cc                 = slv_reg086_reg[31:0] ;
assign slv_reg086[31:0]        = T1_H_cc              ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg086_reg <= 'h0;
    else if( slv_reg086_wr )
        slv_reg086_reg <= ram_wr_data_i;
end


//slv_reg087
assign T2_L_cc                 = slv_reg087_reg[31:0] ;
assign slv_reg087[31:0]        = T2_L_cc              ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg087_reg <= 'h0;
    else if( slv_reg087_wr )
        slv_reg087_reg <= ram_wr_data_i;
end


//slv_reg088
assign T2_H_cc                 = slv_reg088_reg[31:0] ;
assign slv_reg088[31:0]        = T2_H_cc              ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg088_reg <= 'h0;
    else if( slv_reg088_wr )
        slv_reg088_reg <= ram_wr_data_i;
end


//slv_reg090
assign Dyn_trig_mode              = slv_reg090_reg[31:0] ;
assign slv_reg090[31:0]           = Dyn_trig_mode        ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg090_reg <= 'h5a5a;
    else if( slv_reg090_wr )
        slv_reg090_reg <= ram_wr_data_i;
end


//slv_reg091
assign Dyn_trig_source              = slv_reg091_reg[31:0] ;
assign slv_reg091[31:0]             = Dyn_trig_source      ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg091_reg <= 'h0;
    else if( slv_reg091_wr )
        slv_reg091_reg <= ram_wr_data_i;
end


//slv_reg092
assign Dyn_trig_gen              = slv_reg092_reg[31:0] ;
assign slv_reg092[31:0]          = Dyn_trig_gen         ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg092_reg <= 'h0;
    else if( slv_reg092_wr )
        slv_reg092_reg <= ram_wr_data_i;
end


//slv_reg0B1
assign BT_STOP                 = slv_reg0b1_reg[31:0] ;
assign slv_reg0b1[31:0]        = BT_STOP              ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg0b1_reg <= 'h0;
    else if( slv_reg0b1_wr )
        slv_reg0b1_reg <= ram_wr_data_i;
end


//slv_reg0B3
assign VB_stop_L               = slv_reg0b3_reg[31:0] ;
assign slv_reg0b3[31:0]        = VB_stop_L            ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg0b3_reg <= 'h0;
    else if( slv_reg0b3_wr )
        slv_reg0b3_reg <= ram_wr_data_i;
end


//slv_reg0B4
assign VB_stop_H               = slv_reg0b4_reg[31:0] ;
assign slv_reg0b4[31:0]        = VB_stop_H            ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg0b4_reg <= 'h0;
    else if( slv_reg0b4_wr )
        slv_reg0b4_reg <= ram_wr_data_i;
end


//slv_reg0B5
assign TB_stop_L               = slv_reg0b5_reg[31:0] ;
assign slv_reg0b5[31:0]        = TB_stop_L            ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg0b5_reg <= 'h0;
    else if( slv_reg0b5_wr )
        slv_reg0b5_reg <= ram_wr_data_i;
end


//slv_reg0B6
assign TB_stop_H               = slv_reg0b6_reg[31:0] ;
assign slv_reg0b6[31:0]        = TB_stop_H            ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg0b6_reg <= 'h0;
    else if( slv_reg0b6_wr )
        slv_reg0b6_reg <= ram_wr_data_i;
end


//slv_reg0B7
assign CB_stop_L               = slv_reg0b7_reg[31:0] ;
assign slv_reg0b7[31:0]        = CB_stop_L            ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg0b7_reg <= 'h0;
    else if( slv_reg0b7_wr )
        slv_reg0b7_reg <= ram_wr_data_i;
end


//slv_reg0B8
assign CB_stop_H               = slv_reg0b8_reg[31:0] ;
assign slv_reg0b8[31:0]        = CB_stop_H            ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg0b8_reg <= 'h0;
    else if( slv_reg0b8_wr )
        slv_reg0b8_reg <= ram_wr_data_i;
end


//slv_reg0B9
assign VB_pro_L                = slv_reg0b9_reg[31:0] ;
assign slv_reg0b9[31:0]        = VB_pro_L             ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg0b9_reg <= 'h0;
    else if( slv_reg0b9_wr )
        slv_reg0b9_reg <= ram_wr_data_i;
end


//slv_reg0Ba
assign VB_pro_H                = slv_reg0ba_reg[31:0] ;
assign slv_reg0ba[31:0]        = VB_pro_H             ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg0ba_reg <= 'h0;
    else if( slv_reg0ba_wr )
        slv_reg0ba_reg <= ram_wr_data_i;
end


//slv_reg0C0
assign TOCP_Von_set_L              = slv_reg0c0_reg[31:0] ;
assign slv_reg0c0[31:0]            = TOCP_Von_set_L       ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg0c0_reg <= 'h0;
    else if( slv_reg0c0_wr )
        slv_reg0c0_reg <= ram_wr_data_i;
end


//slv_reg0C1
assign TOCP_Von_set_H              = slv_reg0c1_reg[31:0] ;
assign slv_reg0c1[31:0]            = TOCP_Von_set_H       ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg0c1_reg <= 'h0;
    else if( slv_reg0c1_wr )
        slv_reg0c1_reg <= ram_wr_data_i;
end


//slv_reg0C2
assign TOCP_Istart_set_L              = slv_reg0c2_reg[31:0] ;
assign slv_reg0c2[31:0]               = TOCP_Istart_set_L    ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg0c2_reg <= 'h0;
    else if( slv_reg0c2_wr )
        slv_reg0c2_reg <= ram_wr_data_i;
end


//slv_reg0C3
assign TOCP_Istartl_set_H              = slv_reg0c3_reg[31:0] ;
assign slv_reg0c3[31:0]                = TOCP_Istartl_set_H   ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg0c3_reg <= 'h0;
    else if( slv_reg0c3_wr )
        slv_reg0c3_reg <= ram_wr_data_i;
end


//slv_reg0C4
assign TOCP_Icut_set_L              = slv_reg0c4_reg[31:0] ;
assign slv_reg0c4[31:0]             = TOCP_Icut_set_L      ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg0c4_reg <= 'h0;
    else if( slv_reg0c4_wr )
        slv_reg0c4_reg <= ram_wr_data_i;
end


//slv_reg0C5
assign TOCP_Icut_set_H              = slv_reg0c5_reg[31:0] ;
assign slv_reg0c5[31:0]             = TOCP_Icut_set_H      ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg0c5_reg <= 'h0;
    else if( slv_reg0c5_wr )
        slv_reg0c5_reg <= ram_wr_data_i;
end


//slv_reg0C6
assign TOCP_Istep_set              = slv_reg0c6_reg[31:0] ;
assign slv_reg0c6[31:0]            = TOCP_Istep_set       ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg0c6_reg <= 'h0;
    else if( slv_reg0c6_wr )
        slv_reg0c6_reg <= ram_wr_data_i;
end


//slv_reg0C7
assign TOCP_Tstep_set              = slv_reg0c7_reg[31:0] ;
assign slv_reg0c7[31:0]            = TOCP_Tstep_set       ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg0c7_reg <= 'h0;
    else if( slv_reg0c7_wr )
        slv_reg0c7_reg <= ram_wr_data_i;
end


//slv_reg0C8
assign TOCP_Vcut_set_L              = slv_reg0c8_reg[31:0] ;
assign slv_reg0c8[31:0]             = TOCP_Vcut_set_L      ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg0c8_reg <= 'h0;
    else if( slv_reg0c8_wr )
        slv_reg0c8_reg <= ram_wr_data_i;
end


//slv_reg0C9
assign TOCP_Vcut_set_H              = slv_reg0c9_reg[31:0] ;
assign slv_reg0c9[31:0]             = TOCP_Vcut_set_H      ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg0c9_reg <= 'h0;
    else if( slv_reg0c9_wr )
        slv_reg0c9_reg <= ram_wr_data_i;
end


//slv_reg0Ca
assign TOCP_Imin_set_L              = slv_reg0ca_reg[31:0] ;
assign slv_reg0ca[31:0]             = TOCP_Imin_set_L      ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg0ca_reg <= 'h0;
    else if( slv_reg0ca_wr )
        slv_reg0ca_reg <= ram_wr_data_i;
end


//slv_reg0Cb
assign TOCP_Imin_set_H              = slv_reg0cb_reg[31:0] ;
assign slv_reg0cb[31:0]             = TOCP_Imin_set_H      ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg0cb_reg <= 'h0;
    else if( slv_reg0cb_wr )
        slv_reg0cb_reg <= ram_wr_data_i;
end


//slv_reg0Cc
assign TOCP_Imax_set_L              = slv_reg0cc_reg[31:0] ;
assign slv_reg0cc[31:0]             = TOCP_Imax_set_L      ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg0cc_reg <= 'h0;
    else if( slv_reg0cc_wr )
        slv_reg0cc_reg <= ram_wr_data_i;
end


//slv_reg0Cd
assign TOCP_Imax_set_H              = slv_reg0cd_reg[31:0] ;
assign slv_reg0cd[31:0]             = TOCP_Imax_set_H      ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg0cd_reg <= 'h0;
    else if( slv_reg0cd_wr )
        slv_reg0cd_reg <= ram_wr_data_i;
end


//slv_reg0CE
assign slv_reg0ce[31:0]      = TOCP_I_L;

//slv_reg0CF
assign slv_reg0cf[31:0]      = TOCP_I_H;

//slv_reg0D0
assign TOPP_Von_set_L               = slv_reg0d0_reg[31:0] ;
assign slv_reg0d0[31:0]             = TOPP_Von_set_L       ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg0d0_reg <= 'h0;
    else if( slv_reg0d0_wr )
        slv_reg0d0_reg <= ram_wr_data_i;
end


//slv_reg0D1
assign TOPP_Von_set_H               = slv_reg0d1_reg[31:0] ;
assign slv_reg0d1[31:0]             = TOPP_Von_set_H       ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg0d1_reg <= 'h0;
    else if( slv_reg0d1_wr )
        slv_reg0d1_reg <= ram_wr_data_i;
end


//slv_reg0D2
assign TOPP_Pstart_set_L              = slv_reg0d2_reg[31:0] ;
assign slv_reg0d2[31:0]               = TOPP_Pstart_set_L    ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg0d2_reg <= 'h0;
    else if( slv_reg0d2_wr )
        slv_reg0d2_reg <= ram_wr_data_i;
end


//slv_reg0D3
assign TOPP_Pstart_set_H              = slv_reg0d3_reg[31:0] ;
assign slv_reg0d3[31:0]               = TOPP_Pstart_set_H    ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg0d3_reg <= 'h0;
    else if( slv_reg0d3_wr )
        slv_reg0d3_reg <= ram_wr_data_i;
end


//slv_reg0D4
assign TOPP_Pcut_set_L              = slv_reg0d4_reg[31:0] ;
assign slv_reg0d4[31:0]             = TOPP_Pcut_set_L      ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg0d4_reg <= 'h0;
    else if( slv_reg0d4_wr )
        slv_reg0d4_reg <= ram_wr_data_i;
end


//slv_reg0D5
assign TOPP_Pcut_set_H              = slv_reg0d5_reg[31:0] ;
assign slv_reg0d5[31:0]             = TOPP_Pcut_set_H      ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg0d5_reg <= 'h0;
    else if( slv_reg0d5_wr )
        slv_reg0d5_reg <= ram_wr_data_i;
end


//slv_reg0D6
assign TOPP_Pstep_set              = slv_reg0d6_reg[31:0] ;
assign slv_reg0d6[31:0]            = TOPP_Pstep_set       ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg0d6_reg <= 'h0;
    else if( slv_reg0d6_wr )
        slv_reg0d6_reg <= ram_wr_data_i;
end


//slv_reg0D7
assign TOPP_Tstep_set              = slv_reg0d7_reg[31:0] ;
assign slv_reg0d7[31:0]            = TOPP_Tstep_set       ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg0d7_reg <= 'h0;
    else if( slv_reg0d7_wr )
        slv_reg0d7_reg <= ram_wr_data_i;
end


//slv_reg0D8
assign TOPP_Vcut_set_L              = slv_reg0d8_reg[31:0] ;
assign slv_reg0d8[31:0]             = TOPP_Vcut_set_L      ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg0d8_reg <= 'h0;
    else if( slv_reg0d8_wr )
        slv_reg0d8_reg <= ram_wr_data_i;
end


//slv_reg0D9
assign TOPP_Vcut_set_H              = slv_reg0d9_reg[31:0] ;
assign slv_reg0d9[31:0]             = TOPP_Vcut_set_H      ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg0d9_reg <= 'h0;
    else if( slv_reg0d9_wr )
        slv_reg0d9_reg <= ram_wr_data_i;
end


//slv_reg0Da
assign TOPP_Pmin_set_L              = slv_reg0da_reg[31:0] ;
assign slv_reg0da[31:0]             = TOPP_Pmin_set_L      ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg0da_reg <= 'h0;
    else if( slv_reg0da_wr )
        slv_reg0da_reg <= ram_wr_data_i;
end


//slv_reg0Db
assign TOPP_Pmin_set_H              = slv_reg0db_reg[31:0] ;
assign slv_reg0db[31:0]             = TOPP_Pmin_set_H      ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg0db_reg <= 'h0;
    else if( slv_reg0db_wr )
        slv_reg0db_reg <= ram_wr_data_i;
end


//slv_reg0Dc
assign TOPP_Pmax_set_L              = slv_reg0dc_reg[31:0] ;
assign slv_reg0dc[31:0]             = TOPP_Pmax_set_L      ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg0dc_reg <= 'h0;
    else if( slv_reg0dc_wr )
        slv_reg0dc_reg <= ram_wr_data_i;
end


//slv_reg0Dd
assign TOPP_Pmax_set_H              = slv_reg0dd_reg[31:0] ;
assign slv_reg0dd[31:0]             = TOPP_Pmax_set_H      ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg0dd_reg <= 'h0;
    else if( slv_reg0dd_wr )
        slv_reg0dd_reg <= ram_wr_data_i;
end


//slv_reg0De
assign slv_reg0de[31:0]      = TOPP_P_L;

//slv_reg0Df
assign slv_reg0df[31:0]       = TOPP_P_H ;

//slv_reg0f1
assign Stepnum                 = slv_reg0f1_reg[31:0] ;
assign slv_reg0f1[31:0]        = Stepnum              ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg0f1_reg <= 'h0;
    else if( slv_reg0f1_wr )
        slv_reg0f1_reg <= ram_wr_data_i;
end


//slv_reg0f2
assign Count                   = slv_reg0f2_reg[31:0] ;
assign slv_reg0f2[31:0]        = Count                ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg0f2_reg <= 'h0;
    else if( slv_reg0f2_wr )
        slv_reg0f2_reg <= ram_wr_data_i;
end


//slv_reg0f3
assign Step                    = slv_reg0f3_reg[31:0] ;
assign slv_reg0f3[31:0]        = Step                 ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg0f3_reg <= 'h0;
    else if( slv_reg0f3_wr )
        slv_reg0f3_reg <= ram_wr_data_i;
end


//slv_reg0f4
assign Mode                    = slv_reg0f4_reg[31:0] ;
assign slv_reg0f4[31:0]        = Mode                 ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg0f4_reg <= 'h0;
    else if( slv_reg0f4_wr )
        slv_reg0f4_reg <= ram_wr_data_i;
end


//slv_reg0f5
assign Value_L                 = slv_reg0f5_reg[31:0] ;
assign slv_reg0f5[31:0]        = Value_L              ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg0f5_reg <= 'h0;
    else if( slv_reg0f5_wr )
        slv_reg0f5_reg <= ram_wr_data_i;
end


//slv_reg0f6
assign Value_H                 = slv_reg0f6_reg[31:0] ;
assign slv_reg0f6[31:0]        = Value_H              ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg0f6_reg <= 'h0;
    else if( slv_reg0f6_wr )
        slv_reg0f6_reg <= ram_wr_data_i;
end


//slv_reg0f7
assign Tstep_L                 = slv_reg0f7_reg[31:0] ;
assign slv_reg0f7[31:0]        = Tstep_L              ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg0f7_reg <= 'h0;
    else if( slv_reg0f7_wr )
        slv_reg0f7_reg <= ram_wr_data_i;
end


//slv_reg0f8
assign Tstep_H                 = slv_reg0f8_reg[31:0] ;
assign slv_reg0f8[31:0]        = Tstep_H              ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg0f8_reg <= 'h0;
    else if( slv_reg0f8_wr )
        slv_reg0f8_reg <= ram_wr_data_i;
end


//slv_reg0f9
assign Repeat                  = slv_reg0f9_reg[31:0] ;
assign slv_reg0f9[31:0]        = Repeat               ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg0f9_reg <= 'h0;
    else if( slv_reg0f9_wr )
        slv_reg0f9_reg <= ram_wr_data_i;
end


//slv_reg0fa
assign Goto                    = slv_reg0fa_reg[31:0] ;
assign slv_reg0fa[31:0]        = Goto                 ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg0fa_reg <= 'h0;
    else if( slv_reg0fa_wr )
        slv_reg0fa_reg <= ram_wr_data_i;
end


//slv_reg0fb
assign Loops                   = slv_reg0fb_reg[31:0] ;
assign slv_reg0fb[31:0]        = Loops                ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg0fb_reg <= 'h0;
    else if( slv_reg0fb_wr )
        slv_reg0fb_reg <= ram_wr_data_i;
end


//slv_reg0fc
assign Save_step               = slv_reg0fc_reg[31:0] ;
assign slv_reg0fc[31:0]        = Save_step            ;
always @ ( posedge sys_clk_i )
begin
    if( ~rst_n_i )
        slv_reg0fc_reg <= 'h0;
    else if( slv_reg0fc_wr )
        slv_reg0fc_reg <= ram_wr_data_i;
end


//rd_slv_reg000
assign rd_slv_reg000[31:16]         = 16'h0          ;
assign rd_slv_reg000[15:0]          = rd_Fault_status;

//rd_slv_reg001
assign rd_slv_reg001[31:16]    = 16'h0     ;
assign rd_slv_reg001[15:0]     = rd_Workmod;

//rd_slv_reg202
assign rd_slv_reg202[31:16]  = 16'h0   ;
assign rd_slv_reg202[15:0]   = rd_Func ;

//rd_slv_reg203
assign rd_slv_reg203[31:16]  = 16'h0   ;
assign rd_slv_reg203[15:0]   = rd_SENSE;

//rd_slv_reg204
assign rd_slv_reg204[31:16]  = 16'h0   ;
assign rd_slv_reg204[15:0]   = rd_Model;

//rd_slv_reg205
assign rd_slv_reg205[31:16]     = 16'h0      ;
assign rd_slv_reg205[15:0]      = rd_Worktype;

//rd_slv_reg206
assign rd_slv_reg206[31:16]  = 16'h0   ;
assign rd_slv_reg206[15:0]   = rd_M_S  ;

//rd_slv_reg207
assign rd_slv_reg207[31:16]        = 16'h0         ;
assign rd_slv_reg207[15:0]         = rd_Clear_alarm;

//rd_slv_reg208
assign rd_slv_reg208[31:16]       = 16'h0        ;
assign rd_slv_reg208[15:0]        = rd_Run_status;

//rd_slv_reg209
assign rd_slv_reg209[31:16]  = 16'h0   ;
assign rd_slv_reg209[15:0]   = rd_Short;

//rd_slv_reg210
assign rd_slv_reg210[31:0] = rd_Von;

//rd_slv_reg211
assign rd_slv_reg211[31:0]     = rd_SR_slew;

//rd_slv_reg212
assign rd_slv_reg212[31:0]     = rd_SF_slew;

//rd_slv_reg213
assign rd_slv_reg213[31:16]                = 16'h0                 ;
assign rd_slv_reg213[15:0]                 = rd_sense_err_threshold;

//rd_slv_reg00f
assign rd_slv_reg00f[31:16]      = 16'h0       ;
assign rd_slv_reg00f[15:0]       = rd_Von_Latch;

//rd_slv_reg010
assign rd_slv_reg010[31:0]  = rd_Voff;

//rd_slv_reg011
assign rd_slv_reg011[31:0]    = rd_Iset_L;

//rd_slv_reg012
assign rd_slv_reg012[31:0]    = rd_Iset_H;

//rd_slv_reg013
assign rd_slv_reg013[31:0]    = rd_Vset_L;

//rd_slv_reg014
assign rd_slv_reg014[31:0]    = rd_Vset_H;

//rd_slv_reg015
assign rd_slv_reg015[31:0]    = rd_Pset_L;

//rd_slv_reg016
assign rd_slv_reg016[31:0]    = rd_Pset_H;

//rd_slv_reg017
assign rd_slv_reg017[31:0]    = rd_Rset_L;

//rd_slv_reg018
assign rd_slv_reg018[31:0]    = rd_Rset_H;

//rd_slv_reg019
assign rd_slv_reg019[31:0]     = rd_Iset1_L;

//rd_slv_reg01a
assign rd_slv_reg01a[31:0]     = rd_Iset1_H;

//rd_slv_reg01b
assign rd_slv_reg01b[31:0]     = rd_Iset2_L;

//rd_slv_reg01c
assign rd_slv_reg01c[31:0]     = rd_Iset2_H;

//rd_slv_reg01d
assign rd_slv_reg01d[31:0]     = rd_Vset1_L;

//rd_slv_reg01e
assign rd_slv_reg01e[31:0]     = rd_Vset1_H;

//rd_slv_reg01f
assign rd_slv_reg01f[31:0]     = rd_Vset2_L;

//rd_slv_reg020
assign rd_slv_reg020[31:0]     = rd_Vset2_H;

//rd_slv_reg021
assign rd_slv_reg021[31:0]     = rd_Pset1_L;

//rd_slv_reg022
assign rd_slv_reg022[31:0]     = rd_Pset1_H;

//rd_slv_reg023
assign rd_slv_reg023[31:0]     = rd_Pset2_L;

//rd_slv_reg024
assign rd_slv_reg024[31:0]     = rd_Pset2_H;

//rd_slv_reg025
assign rd_slv_reg025[31:0]     = rd_Rset1_L;

//rd_slv_reg026
assign rd_slv_reg026[31:0]     = rd_Rset1_H;

//rd_slv_reg027
assign rd_slv_reg027[31:0]     = rd_Rset2_L;

//rd_slv_reg028
assign rd_slv_reg028[31:0]     = rd_Rset2_H;

//rd_slv_reg02d
assign rd_slv_reg02d[31:0]     = rd_DR_slew;

//rd_slv_reg02e
assign rd_slv_reg02e[31:0]     = rd_DF_slew;

//rd_slv_reg02f
assign rd_slv_reg02f[31:16]   = 16'h0    ;
assign rd_slv_reg02f[15:0]    = rd_Vrange;

//rd_slv_reg030
assign rd_slv_reg030[31:0]     = rd_CVspeed;

//rd_slv_reg031
assign rd_slv_reg031[31:0]     = rd_CV_slew;

//rd_slv_reg033
assign rd_slv_reg033[31:0]           = rd_filter_period;

//rd_slv_reg034
assign rd_slv_reg034[31:0]       = rd_num_paral;

//rd_slv_reg041
assign rd_slv_reg041[31:0]     = rd_I_lim_L;

//rd_slv_reg042
assign rd_slv_reg042[31:0]     = rd_I_lim_H;

//rd_slv_reg043
assign rd_slv_reg043[31:0]     = rd_V_lim_L;

//rd_slv_reg044
assign rd_slv_reg044[31:0]     = rd_V_lim_H;

//rd_slv_reg045
assign rd_slv_reg045[31:0]     = rd_P_lim_L;

//rd_slv_reg046
assign rd_slv_reg046[31:0]     = rd_P_lim_H;

//rd_slv_reg047
assign rd_slv_reg047[31:0]      = rd_CV_lim_L;

//rd_slv_reg048
assign rd_slv_reg048[31:0]      = rd_CV_lim_H;

//rd_slv_reg049
assign rd_slv_reg049[31:0]      = rd_Pro_time;

//rd_slv_reg051
assign rd_slv_reg051[31:0]  = rd_VH_k;

//rd_slv_reg052
assign rd_slv_reg052[31:0]  = rd_VH_a;

//rd_slv_reg053
assign rd_slv_reg053[31:0]   = rd_VsH_k;

//rd_slv_reg054
assign rd_slv_reg054[31:0]   = rd_VsH_a;

//rd_slv_reg055
assign rd_slv_reg055[31:0]  = rd_I1_k;

//rd_slv_reg056
assign rd_slv_reg056[31:0]  = rd_I1_a;

//rd_slv_reg057
assign rd_slv_reg057[31:0]  = rd_I2_k;

//rd_slv_reg058
assign rd_slv_reg058[31:0]  = rd_I2_a;

//rd_slv_reg059
assign rd_slv_reg059[31:0]  = rd_VL_k;

//rd_slv_reg05a
assign rd_slv_reg05a[31:0]  = rd_VL_a;

//rd_slv_reg05b
assign rd_slv_reg05b[31:0]   = rd_VsL_k;

//rd_slv_reg05c
assign rd_slv_reg05c[31:0]   = rd_VsL_a;

//rd_slv_reg05d
assign rd_slv_reg05d[31:0]   = rd_It1_k;

//rd_slv_reg05e
assign rd_slv_reg05e[31:0]   = rd_It1_a;

//rd_slv_reg05f
assign rd_slv_reg05f[31:0]   = rd_It2_k;

//rd_slv_reg060
assign rd_slv_reg060[31:0]   = rd_It2_a;

//rd_slv_reg061
assign rd_slv_reg061[31:0]  = rd_CC_k;

//rd_slv_reg062
assign rd_slv_reg062[31:0]  = rd_CC_a;

//rd_slv_reg063
assign rd_slv_reg063[31:0]   = rd_CVH_k;

//rd_slv_reg064
assign rd_slv_reg064[31:0]   = rd_CVH_a;

//rd_slv_reg065
assign rd_slv_reg065[31:0]   = rd_CVL_k;

//rd_slv_reg066
assign rd_slv_reg066[31:0]   = rd_CVL_a;

//rd_slv_reg067
assign rd_slv_reg067[31:0]    = rd_CVHs_k;

//rd_slv_reg068
assign rd_slv_reg068[31:0]    = rd_CVHs_a;

//rd_slv_reg069
assign rd_slv_reg069[31:0]    = rd_CVLs_k;

//rd_slv_reg06a
assign rd_slv_reg06a[31:0]    = rd_CVLs_a;

//rd_slv_reg06b
assign rd_slv_reg06b[31:0] = rd_s_k;

//rd_slv_reg06c
assign rd_slv_reg06c[31:0] = rd_s_a;

//rd_slv_reg06d
assign rd_slv_reg06d[31:0] = rd_m_k;

//rd_slv_reg06e
assign rd_slv_reg06e[31:0] = rd_m_a;

//rd_slv_reg06f
assign rd_slv_reg06f[31:0] = rd_f_k;

//rd_slv_reg070
assign rd_slv_reg070[31:0] = rd_f_a;

//rd_slv_reg071
assign rd_slv_reg071[31:0]     = rd_CV_mode;

//rd_slv_reg080
assign rd_slv_reg080[31:0]     = rd_T1_L_cc;

//rd_slv_reg086
assign rd_slv_reg086[31:0]     = rd_T1_H_cc;

//rd_slv_reg087
assign rd_slv_reg087[31:0]     = rd_T2_L_cc;

//rd_slv_reg088
assign rd_slv_reg088[31:0]     = rd_T2_H_cc;

//rd_slv_reg090
assign rd_slv_reg090[31:0]           = rd_Dyn_trig_mode;

//rd_slv_reg091
assign rd_slv_reg091[31:0]             = rd_Dyn_trig_source;

//rd_slv_reg092
assign rd_slv_reg092[31:0]          = rd_Dyn_trig_gen;

//rd_slv_reg0B1
assign rd_slv_reg0b1[31:0]     = rd_BT_STOP;

//rd_slv_reg0B3
assign rd_slv_reg0b3[31:0]       = rd_VB_stop_L;

//rd_slv_reg0B4
assign rd_slv_reg0b4[31:0]       = rd_VB_stop_H;

//rd_slv_reg0B5
assign rd_slv_reg0b5[31:0]       = rd_TB_stop_L;

//rd_slv_reg0B6
assign rd_slv_reg0b6[31:0]       = rd_TB_stop_H;

//rd_slv_reg0B7
assign rd_slv_reg0b7[31:0]       = rd_CB_stop_L;

//rd_slv_reg0B8
assign rd_slv_reg0b8[31:0]       = rd_CB_stop_H;

//rd_slv_reg0B9
assign rd_slv_reg0b9[31:0]      = rd_VB_pro_L;

//rd_slv_reg0Ba
assign rd_slv_reg0ba[31:0]      = rd_VB_pro_H;

//rd_slv_reg0C0
assign rd_slv_reg0c0[31:0]            = rd_TOCP_Von_set_L;

//rd_slv_reg0C1
assign rd_slv_reg0c1[31:0]            = rd_TOCP_Von_set_H;

//rd_slv_reg0C2
assign rd_slv_reg0c2[31:0]               = rd_TOCP_Istart_set_L;

//rd_slv_reg0C3
assign rd_slv_reg0c3[31:0]                = rd_TOCP_Istartl_set_H;

//rd_slv_reg0C4
assign rd_slv_reg0c4[31:0]             = rd_TOCP_Icut_set_L;

//rd_slv_reg0C5
assign rd_slv_reg0c5[31:0]             = rd_TOCP_Icut_set_H;

//rd_slv_reg0C6
assign rd_slv_reg0c6[31:0]            = rd_TOCP_Istep_set;

//rd_slv_reg0C7
assign rd_slv_reg0c7[31:0]            = rd_TOCP_Tstep_set;

//rd_slv_reg0C8
assign rd_slv_reg0c8[31:0]             = rd_TOCP_Vcut_set_L;

//rd_slv_reg0C9
assign rd_slv_reg0c9[31:0]             = rd_TOCP_Vcut_set_H;

//rd_slv_reg0Ca
assign rd_slv_reg0ca[31:0]             = rd_TOCP_Imin_set_L;

//rd_slv_reg0Cb
assign rd_slv_reg0cb[31:0]             = rd_TOCP_Imin_set_H;

//rd_slv_reg0Cc
assign rd_slv_reg0cc[31:0]             = rd_TOCP_Imax_set_L;

//rd_slv_reg0Cd
assign rd_slv_reg0cd[31:0]             = rd_TOCP_Imax_set_H;

//rd_slv_reg0CE
assign rd_slv_reg0ce[31:0]      = rd_TOCP_I_L;

//rd_slv_reg0CF
assign rd_slv_reg0cf[31:0]         = rd_TOCP_result;

//rd_slv_reg0D0
assign rd_slv_reg0d0[31:0]             = rd_TOPP_Von_set_L ;

//rd_slv_reg0D1
assign rd_slv_reg0d1[31:0]             = rd_TOPP_Von_set_H ;

//rd_slv_reg0D2
assign rd_slv_reg0d2[31:0]               = rd_TOPP_Pstart_set_L;

//rd_slv_reg0D3
assign rd_slv_reg0d3[31:0]               = rd_TOPP_Pstart_set_H;

//rd_slv_reg0D4
assign rd_slv_reg0d4[31:0]             = rd_TOPP_Pcut_set_L;

//rd_slv_reg0D5
assign rd_slv_reg0d5[31:0]             = rd_TOPP_Pcut_set_H;

//rd_slv_reg0D6
assign rd_slv_reg0d6[31:0]            = rd_TOPP_Pstep_set;

//rd_slv_reg0D7
assign rd_slv_reg0d7[31:0]            = rd_TOPP_Tstep_set;

//rd_slv_reg0D8
assign rd_slv_reg0d8[31:0]             = rd_TOPP_Vcut_set_L;

//rd_slv_reg0D9
assign rd_slv_reg0d9[31:0]             = rd_TOPP_Vcut_set_H;

//rd_slv_reg0Da
assign rd_slv_reg0da[31:0]             = rd_TOPP_Pmin_set_L;

//rd_slv_reg0Db
assign rd_slv_reg0db[31:0]             = rd_TOPP_Pmin_set_H;

//rd_slv_reg0Dc
assign rd_slv_reg0dc[31:0]             = rd_TOPP_Pmax_set_L;

//rd_slv_reg0Dd
assign rd_slv_reg0dd[31:0]             = rd_TOPP_Pmax_set_H;

//rd_slv_reg0De
assign rd_slv_reg0de[31:0]      = rd_TOPP_P_L;

//rd_slv_reg0Df
assign rd_slv_reg0df[31:0]         = rd_TOPP_result;

//rd_slv_reg0f1
assign rd_slv_reg0f1[31:0]     = rd_Stepnum;

//rd_slv_reg0f2
assign rd_slv_reg0f2[31:0]   = rd_Count;

//rd_slv_reg0f3
assign rd_slv_reg0f3[31:0]  = rd_Step;

//rd_slv_reg0f4
assign rd_slv_reg0f4[31:0]  = rd_Mode;

//rd_slv_reg0f5
assign rd_slv_reg0f5[31:0]     = rd_Value_L;

//rd_slv_reg0f6
assign rd_slv_reg0f6[31:0]     = rd_Value_H;

//rd_slv_reg0f7
assign rd_slv_reg0f7[31:0]     = rd_Tstep_L;

//rd_slv_reg0f8
assign rd_slv_reg0f8[31:0]     = rd_Tstep_H;

//rd_slv_reg0f9
assign rd_slv_reg0f9[31:0]    = rd_Repeat;

//rd_slv_reg0fa
assign rd_slv_reg0fa[31:0]  = rd_Goto;

//rd_slv_reg0fb
assign rd_slv_reg0fb[31:0]   = rd_Loops;

//rd_slv_reg0fc
assign rd_slv_reg0fc[31:0]        = rd_Repeat_now;

//rd_slv_reg0fd
assign rd_slv_reg0fd[31:0]       = rd_Count_now;

//rd_slv_reg0fe
assign rd_slv_reg0fe[31:0]      = rd_Step_now;

//rd_slv_reg0ff
assign rd_slv_reg0ff[31:0]       = rd_Loops_now;

//rd_slv_reg301
assign rd_slv_reg301[31:0]         = rd_I_Board_L_l;

//rd_slv_reg302
assign rd_slv_reg302[31:0]         = rd_I_Board_L_h;

//rd_slv_reg303
assign rd_slv_reg303[31:0]         = rd_I_Board_H_l;

//rd_slv_reg304
assign rd_slv_reg304[31:0]         = rd_I_Board_H_h;

//rd_slv_reg305
assign rd_slv_reg305[31:0]             = rd_I_SUM_Total_L_l;

//rd_slv_reg306
assign rd_slv_reg306[31:0]             = rd_I_SUM_Total_L_h;

//rd_slv_reg307
assign rd_slv_reg307[31:0]             = rd_I_SUM_Total_H_l;

//rd_slv_reg308
assign rd_slv_reg308[31:0]             = rd_I_SUM_Total_H_h;

//rd_slv_reg309
assign rd_slv_reg309[31:0]            = rd_I_Board_unit_l;

//rd_slv_reg30a
assign rd_slv_reg30a[31:0]            = rd_I_Board_unit_h;

//rd_slv_reg30b
assign rd_slv_reg30b[31:0]          = rd_I_Sum_unit_l;

//rd_slv_reg30c
assign rd_slv_reg30c[31:0]          = rd_I_Sum_unit_h;

//rd_slv_reg30e
assign rd_slv_reg30e[31:0]  = rd_P_rt;

//rd_slv_reg30f
assign rd_slv_reg30f[31:0]  = rd_R_rt;

//rd_slv_reg311
assign rd_slv_reg311[31:0] = rd_V_L;

//rd_slv_reg312
assign rd_slv_reg312[31:0] = rd_V_H;

//rd_slv_reg313
assign rd_slv_reg313[31:0] = rd_I_L;

//rd_slv_reg314
assign rd_slv_reg314[31:0] = rd_I_H;

//rd_slv_reg3b1
assign rd_slv_reg3b1[31:0]  = Vopen_L;

//rd_slv_reg3b2
assign rd_slv_reg3b2[31:0]  = Vopen_H;

//rd_slv_reg3b3
assign rd_slv_reg3b3[31:0] = Ri_L;

//rd_slv_reg3b4
assign rd_slv_reg3b4[31:0] = Ri_H;

//rd_slv_reg3b5
assign rd_slv_reg3b5[31:0] = TB_L;

//rd_slv_reg3b6
assign rd_slv_reg3b6[31:0] = TB_H;

//rd_slv_reg3b7
assign rd_slv_reg3b7[31:0] = Cap1_L;

//rd_slv_reg3b8
assign rd_slv_reg3b8[31:0] = Cap1_H;

//rd_slv_reg3b9
assign rd_slv_reg3b9[31:0] = Cap2_L;

//rd_slv_reg3ba
assign rd_slv_reg3ba[31:0] = Cap2_H;

//rd_slv_reg3bb
assign rd_slv_reg3bb[31:0] = Tpro_L;

//rd_slv_reg3bc
assign rd_slv_reg3bc[31:0] = Tpro_H;

//rd_slv_reg3c1
assign rd_slv_reg3c1[31:0]        = temperature_0;

//rd_slv_reg3c2
assign rd_slv_reg3c2[31:0]        = temperature_1;

//rd_slv_reg3c3
assign rd_slv_reg3c3[31:0]        = temperature_2;

//rd_slv_reg3c4
assign rd_slv_reg3c4[31:0]        = temperature_3;

//rd_slv_reg3c5
assign rd_slv_reg3c5[31:0]        = temperature_4;

//rd_slv_reg3c6
assign rd_slv_reg3c6[31:0]        = temperature_5;

//rd_slv_reg3c7
assign rd_slv_reg3c7[31:0]        = temperature_6;

//rd_slv_reg3c8
assign rd_slv_reg3c8[31:0]        = temperature_7;

//rd_slv_reg3d1
assign rd_slv_reg3d1[31:0]     = SUM_UNIT_0;

//rd_slv_reg3d2
assign rd_slv_reg3d2[31:0]     = SUM_UNIT_1;

//rd_slv_reg3d3
assign rd_slv_reg3d3[31:0]     = SUM_UNIT_2;

//rd_slv_reg3d4
assign rd_slv_reg3d4[31:0]     = SUM_UNIT_3;

//rd_slv_reg3d5
assign rd_slv_reg3d5[31:0]     = SUM_UNIT_4;

//rd_slv_reg3d6
assign rd_slv_reg3d6[31:0]     = SUM_UNIT_5;

//rd_slv_reg3d7
assign rd_slv_reg3d7[31:0]     = SUM_UNIT_6;

//rd_slv_reg3d8
assign rd_slv_reg3d8[31:0]     = SUM_UNIT_7;

//rd_slv_reg3e1
assign rd_slv_reg3e1[31:0]       = BOARD_UNIT_0;

//rd_slv_reg3e2
assign rd_slv_reg3e2[31:0]       = BOARD_UNIT_1;

//rd_slv_reg3e3
assign rd_slv_reg3e3[31:0]       = BOARD_UNIT_2;

//rd_slv_reg3e4
assign rd_slv_reg3e4[31:0]       = BOARD_UNIT_3;

//rd_slv_reg3e5
assign rd_slv_reg3e5[31:0]       = BOARD_UNIT_4;

//rd_slv_reg3e6
assign rd_slv_reg3e6[31:0]       = BOARD_UNIT_5;

//rd_slv_reg3e7
assign rd_slv_reg3e7[31:0]       = BOARD_UNIT_6;

//rd_slv_reg3e8
assign rd_slv_reg3e8[31:0]       = BOARD_UNIT_7;

//rd_slv_reg3ff
assign rd_slv_reg3ff[31:0]         = Version_number;

//reg map read
always @ ( * )
begin
    case( ram_rd_addr_i )
        SLV_REG001:
            ram_rd_data_o <= slv_reg001;
        SLV_REG002:
            ram_rd_data_o <= slv_reg002;
        SLV_REG003:
            ram_rd_data_o <= slv_reg003;
        SLV_REG004:
            ram_rd_data_o <= slv_reg004;
        SLV_REG005:
            ram_rd_data_o <= slv_reg005;
        SLV_REG006:
            ram_rd_data_o <= slv_reg006;
        SLV_REG007:
            ram_rd_data_o <= slv_reg007;
        SLV_REG008:
            ram_rd_data_o <= slv_reg008;
        SLV_REG009:
            ram_rd_data_o <= slv_reg009;
        SLV_REG00A:
            ram_rd_data_o <= slv_reg00a;
        SLV_REG00B:
            ram_rd_data_o <= slv_reg00b;
        SLV_REG00C:
            ram_rd_data_o <= slv_reg00c;
        SLV_REG00D:
            ram_rd_data_o <= slv_reg00d;
        SLV_REG00F:
            ram_rd_data_o <= slv_reg00f;
        SLV_REG010:
            ram_rd_data_o <= slv_reg010;
        SLV_REG011:
            ram_rd_data_o <= slv_reg011;
        SLV_REG012:
            ram_rd_data_o <= slv_reg012;
        SLV_REG013:
            ram_rd_data_o <= slv_reg013;
        SLV_REG014:
            ram_rd_data_o <= slv_reg014;
        SLV_REG015:
            ram_rd_data_o <= slv_reg015;
        SLV_REG016:
            ram_rd_data_o <= slv_reg016;
        SLV_REG017:
            ram_rd_data_o <= slv_reg017;
        SLV_REG018:
            ram_rd_data_o <= slv_reg018;
        SLV_REG019:
            ram_rd_data_o <= slv_reg019;
        SLV_REG01A:
            ram_rd_data_o <= slv_reg01a;
        SLV_REG01B:
            ram_rd_data_o <= slv_reg01b;
        SLV_REG01C:
            ram_rd_data_o <= slv_reg01c;
        SLV_REG01D:
            ram_rd_data_o <= slv_reg01d;
        SLV_REG01E:
            ram_rd_data_o <= slv_reg01e;
        SLV_REG01F:
            ram_rd_data_o <= slv_reg01f;
        SLV_REG020:
            ram_rd_data_o <= slv_reg020;
        SLV_REG021:
            ram_rd_data_o <= slv_reg021;
        SLV_REG022:
            ram_rd_data_o <= slv_reg022;
        SLV_REG023:
            ram_rd_data_o <= slv_reg023;
        SLV_REG024:
            ram_rd_data_o <= slv_reg024;
        SLV_REG025:
            ram_rd_data_o <= slv_reg025;
        SLV_REG026:
            ram_rd_data_o <= slv_reg026;
        SLV_REG027:
            ram_rd_data_o <= slv_reg027;
        SLV_REG028:
            ram_rd_data_o <= slv_reg028;
        SLV_REG02D:
            ram_rd_data_o <= slv_reg02d;
        SLV_REG02E:
            ram_rd_data_o <= slv_reg02e;
        SLV_REG02F:
            ram_rd_data_o <= slv_reg02f;
        SLV_REG030:
            ram_rd_data_o <= slv_reg030;
        SLV_REG031:
            ram_rd_data_o <= slv_reg031;
        SLV_REG033:
            ram_rd_data_o <= slv_reg033;
        SLV_REG034:
            ram_rd_data_o <= slv_reg034;
        SLV_REG041:
            ram_rd_data_o <= slv_reg041;
        SLV_REG042:
            ram_rd_data_o <= slv_reg042;
        SLV_REG043:
            ram_rd_data_o <= slv_reg043;
        SLV_REG044:
            ram_rd_data_o <= slv_reg044;
        SLV_REG045:
            ram_rd_data_o <= slv_reg045;
        SLV_REG046:
            ram_rd_data_o <= slv_reg046;
        SLV_REG047:
            ram_rd_data_o <= slv_reg047;
        SLV_REG048:
            ram_rd_data_o <= slv_reg048;
        SLV_REG049:
            ram_rd_data_o <= slv_reg049;
        SLV_REG051:
            ram_rd_data_o <= slv_reg051;
        SLV_REG052:
            ram_rd_data_o <= slv_reg052;
        SLV_REG053:
            ram_rd_data_o <= slv_reg053;
        SLV_REG054:
            ram_rd_data_o <= slv_reg054;
        SLV_REG055:
            ram_rd_data_o <= slv_reg055;
        SLV_REG056:
            ram_rd_data_o <= slv_reg056;
        SLV_REG057:
            ram_rd_data_o <= slv_reg057;
        SLV_REG058:
            ram_rd_data_o <= slv_reg058;
        SLV_REG059:
            ram_rd_data_o <= slv_reg059;
        SLV_REG05A:
            ram_rd_data_o <= slv_reg05a;
        SLV_REG05B:
            ram_rd_data_o <= slv_reg05b;
        SLV_REG05C:
            ram_rd_data_o <= slv_reg05c;
        SLV_REG05D:
            ram_rd_data_o <= slv_reg05d;
        SLV_REG05E:
            ram_rd_data_o <= slv_reg05e;
        SLV_REG05F:
            ram_rd_data_o <= slv_reg05f;
        SLV_REG060:
            ram_rd_data_o <= slv_reg060;
        SLV_REG061:
            ram_rd_data_o <= slv_reg061;
        SLV_REG062:
            ram_rd_data_o <= slv_reg062;
        SLV_REG063:
            ram_rd_data_o <= slv_reg063;
        SLV_REG064:
            ram_rd_data_o <= slv_reg064;
        SLV_REG065:
            ram_rd_data_o <= slv_reg065;
        SLV_REG066:
            ram_rd_data_o <= slv_reg066;
        SLV_REG067:
            ram_rd_data_o <= slv_reg067;
        SLV_REG068:
            ram_rd_data_o <= slv_reg068;
        SLV_REG069:
            ram_rd_data_o <= slv_reg069;
        SLV_REG06A:
            ram_rd_data_o <= slv_reg06a;
        SLV_REG06B:
            ram_rd_data_o <= slv_reg06b;
        SLV_REG06C:
            ram_rd_data_o <= slv_reg06c;
        SLV_REG06D:
            ram_rd_data_o <= slv_reg06d;
        SLV_REG06E:
            ram_rd_data_o <= slv_reg06e;
        SLV_REG06F:
            ram_rd_data_o <= slv_reg06f;
        SLV_REG070:
            ram_rd_data_o <= slv_reg070;
        SLV_REG071:
            ram_rd_data_o <= slv_reg071;
        SLV_REG080:
            ram_rd_data_o <= slv_reg080;
        SLV_REG086:
            ram_rd_data_o <= slv_reg086;
        SLV_REG087:
            ram_rd_data_o <= slv_reg087;
        SLV_REG088:
            ram_rd_data_o <= slv_reg088;
        SLV_REG090:
            ram_rd_data_o <= slv_reg090;
        SLV_REG091:
            ram_rd_data_o <= slv_reg091;
        SLV_REG092:
            ram_rd_data_o <= slv_reg092;
        SLV_REG0B1:
            ram_rd_data_o <= slv_reg0b1;
        SLV_REG0B3:
            ram_rd_data_o <= slv_reg0b3;
        SLV_REG0B4:
            ram_rd_data_o <= slv_reg0b4;
        SLV_REG0B5:
            ram_rd_data_o <= slv_reg0b5;
        SLV_REG0B6:
            ram_rd_data_o <= slv_reg0b6;
        SLV_REG0B7:
            ram_rd_data_o <= slv_reg0b7;
        SLV_REG0B8:
            ram_rd_data_o <= slv_reg0b8;
        SLV_REG0B9:
            ram_rd_data_o <= slv_reg0b9;
        SLV_REG0BA:
            ram_rd_data_o <= slv_reg0ba;
        SLV_REG0C0:
            ram_rd_data_o <= slv_reg0c0;
        SLV_REG0C1:
            ram_rd_data_o <= slv_reg0c1;
        SLV_REG0C2:
            ram_rd_data_o <= slv_reg0c2;
        SLV_REG0C3:
            ram_rd_data_o <= slv_reg0c3;
        SLV_REG0C4:
            ram_rd_data_o <= slv_reg0c4;
        SLV_REG0C5:
            ram_rd_data_o <= slv_reg0c5;
        SLV_REG0C6:
            ram_rd_data_o <= slv_reg0c6;
        SLV_REG0C7:
            ram_rd_data_o <= slv_reg0c7;
        SLV_REG0C8:
            ram_rd_data_o <= slv_reg0c8;
        SLV_REG0C9:
            ram_rd_data_o <= slv_reg0c9;
        SLV_REG0CA:
            ram_rd_data_o <= slv_reg0ca;
        SLV_REG0CB:
            ram_rd_data_o <= slv_reg0cb;
        SLV_REG0CC:
            ram_rd_data_o <= slv_reg0cc;
        SLV_REG0CD:
            ram_rd_data_o <= slv_reg0cd;
        SLV_REG0CE:
            ram_rd_data_o <= slv_reg0ce;
        SLV_REG0CF:
            ram_rd_data_o <= slv_reg0cf;
        SLV_REG0D0:
            ram_rd_data_o <= slv_reg0d0;
        SLV_REG0D1:
            ram_rd_data_o <= slv_reg0d1;
        SLV_REG0D2:
            ram_rd_data_o <= slv_reg0d2;
        SLV_REG0D3:
            ram_rd_data_o <= slv_reg0d3;
        SLV_REG0D4:
            ram_rd_data_o <= slv_reg0d4;
        SLV_REG0D5:
            ram_rd_data_o <= slv_reg0d5;
        SLV_REG0D6:
            ram_rd_data_o <= slv_reg0d6;
        SLV_REG0D7:
            ram_rd_data_o <= slv_reg0d7;
        SLV_REG0D8:
            ram_rd_data_o <= slv_reg0d8;
        SLV_REG0D9:
            ram_rd_data_o <= slv_reg0d9;
        SLV_REG0DA:
            ram_rd_data_o <= slv_reg0da;
        SLV_REG0DB:
            ram_rd_data_o <= slv_reg0db;
        SLV_REG0DC:
            ram_rd_data_o <= slv_reg0dc;
        SLV_REG0DD:
            ram_rd_data_o <= slv_reg0dd;
        SLV_REG0DE:
            ram_rd_data_o <= slv_reg0de;
        SLV_REG0DF:
            ram_rd_data_o <= slv_reg0df;
        SLV_REG0F1:
            ram_rd_data_o <= slv_reg0f1;
        SLV_REG0F2:
            ram_rd_data_o <= slv_reg0f2;
        SLV_REG0F3:
            ram_rd_data_o <= slv_reg0f3;
        SLV_REG0F4:
            ram_rd_data_o <= slv_reg0f4;
        SLV_REG0F5:
            ram_rd_data_o <= slv_reg0f5;
        SLV_REG0F6:
            ram_rd_data_o <= slv_reg0f6;
        SLV_REG0F7:
            ram_rd_data_o <= slv_reg0f7;
        SLV_REG0F8:
            ram_rd_data_o <= slv_reg0f8;
        SLV_REG0F9:
            ram_rd_data_o <= slv_reg0f9;
        SLV_REG0FA:
            ram_rd_data_o <= slv_reg0fa;
        SLV_REG0FB:
            ram_rd_data_o <= slv_reg0fb;
        SLV_REG0FC:
            ram_rd_data_o <= slv_reg0fc;
        RD_SLV_REG000:
            ram_rd_data_o <= rd_slv_reg000;
        RD_SLV_REG001:
            ram_rd_data_o <= rd_slv_reg001;
        RD_SLV_REG202:
            ram_rd_data_o <= rd_slv_reg202;
        RD_SLV_REG203:
            ram_rd_data_o <= rd_slv_reg203;
        RD_SLV_REG204:
            ram_rd_data_o <= rd_slv_reg204;
        RD_SLV_REG205:
            ram_rd_data_o <= rd_slv_reg205;
        RD_SLV_REG206:
            ram_rd_data_o <= rd_slv_reg206;
        RD_SLV_REG207:
            ram_rd_data_o <= rd_slv_reg207;
        RD_SLV_REG208:
            ram_rd_data_o <= rd_slv_reg208;
        RD_SLV_REG209:
            ram_rd_data_o <= rd_slv_reg209;
        RD_SLV_REG210:
            ram_rd_data_o <= rd_slv_reg210;
        RD_SLV_REG211:
            ram_rd_data_o <= rd_slv_reg211;
        RD_SLV_REG212:
            ram_rd_data_o <= rd_slv_reg212;
        RD_SLV_REG213:
            ram_rd_data_o <= rd_slv_reg213;
        RD_SLV_REG00F:
            ram_rd_data_o <= rd_slv_reg00f;
        RD_SLV_REG010:
            ram_rd_data_o <= rd_slv_reg010;
        RD_SLV_REG011:
            ram_rd_data_o <= rd_slv_reg011;
        RD_SLV_REG012:
            ram_rd_data_o <= rd_slv_reg012;
        RD_SLV_REG013:
            ram_rd_data_o <= rd_slv_reg013;
        RD_SLV_REG014:
            ram_rd_data_o <= rd_slv_reg014;
        RD_SLV_REG015:
            ram_rd_data_o <= rd_slv_reg015;
        RD_SLV_REG016:
            ram_rd_data_o <= rd_slv_reg016;
        RD_SLV_REG017:
            ram_rd_data_o <= rd_slv_reg017;
        RD_SLV_REG018:
            ram_rd_data_o <= rd_slv_reg018;
        RD_SLV_REG019:
            ram_rd_data_o <= rd_slv_reg019;
        RD_SLV_REG01A:
            ram_rd_data_o <= rd_slv_reg01a;
        RD_SLV_REG01B:
            ram_rd_data_o <= rd_slv_reg01b;
        RD_SLV_REG01C:
            ram_rd_data_o <= rd_slv_reg01c;
        RD_SLV_REG01D:
            ram_rd_data_o <= rd_slv_reg01d;
        RD_SLV_REG01E:
            ram_rd_data_o <= rd_slv_reg01e;
        RD_SLV_REG01F:
            ram_rd_data_o <= rd_slv_reg01f;
        RD_SLV_REG020:
            ram_rd_data_o <= rd_slv_reg020;
        RD_SLV_REG021:
            ram_rd_data_o <= rd_slv_reg021;
        RD_SLV_REG022:
            ram_rd_data_o <= rd_slv_reg022;
        RD_SLV_REG023:
            ram_rd_data_o <= rd_slv_reg023;
        RD_SLV_REG024:
            ram_rd_data_o <= rd_slv_reg024;
        RD_SLV_REG025:
            ram_rd_data_o <= rd_slv_reg025;
        RD_SLV_REG026:
            ram_rd_data_o <= rd_slv_reg026;
        RD_SLV_REG027:
            ram_rd_data_o <= rd_slv_reg027;
        RD_SLV_REG028:
            ram_rd_data_o <= rd_slv_reg028;
        RD_SLV_REG02D:
            ram_rd_data_o <= rd_slv_reg02d;
        RD_SLV_REG02E:
            ram_rd_data_o <= rd_slv_reg02e;
        RD_SLV_REG02F:
            ram_rd_data_o <= rd_slv_reg02f;
        RD_SLV_REG030:
            ram_rd_data_o <= rd_slv_reg030;
        RD_SLV_REG031:
            ram_rd_data_o <= rd_slv_reg031;
        RD_SLV_REG033:
            ram_rd_data_o <= rd_slv_reg033;
        RD_SLV_REG034:
            ram_rd_data_o <= rd_slv_reg034;
        RD_SLV_REG041:
            ram_rd_data_o <= rd_slv_reg041;
        RD_SLV_REG042:
            ram_rd_data_o <= rd_slv_reg042;
        RD_SLV_REG043:
            ram_rd_data_o <= rd_slv_reg043;
        RD_SLV_REG044:
            ram_rd_data_o <= rd_slv_reg044;
        RD_SLV_REG045:
            ram_rd_data_o <= rd_slv_reg045;
        RD_SLV_REG046:
            ram_rd_data_o <= rd_slv_reg046;
        RD_SLV_REG047:
            ram_rd_data_o <= rd_slv_reg047;
        RD_SLV_REG048:
            ram_rd_data_o <= rd_slv_reg048;
        RD_SLV_REG049:
            ram_rd_data_o <= rd_slv_reg049;
        RD_SLV_REG051:
            ram_rd_data_o <= rd_slv_reg051;
        RD_SLV_REG052:
            ram_rd_data_o <= rd_slv_reg052;
        RD_SLV_REG053:
            ram_rd_data_o <= rd_slv_reg053;
        RD_SLV_REG054:
            ram_rd_data_o <= rd_slv_reg054;
        RD_SLV_REG055:
            ram_rd_data_o <= rd_slv_reg055;
        RD_SLV_REG056:
            ram_rd_data_o <= rd_slv_reg056;
        RD_SLV_REG057:
            ram_rd_data_o <= rd_slv_reg057;
        RD_SLV_REG058:
            ram_rd_data_o <= rd_slv_reg058;
        RD_SLV_REG059:
            ram_rd_data_o <= rd_slv_reg059;
        RD_SLV_REG05A:
            ram_rd_data_o <= rd_slv_reg05a;
        RD_SLV_REG05B:
            ram_rd_data_o <= rd_slv_reg05b;
        RD_SLV_REG05C:
            ram_rd_data_o <= rd_slv_reg05c;
        RD_SLV_REG05D:
            ram_rd_data_o <= rd_slv_reg05d;
        RD_SLV_REG05E:
            ram_rd_data_o <= rd_slv_reg05e;
        RD_SLV_REG05F:
            ram_rd_data_o <= rd_slv_reg05f;
        RD_SLV_REG060:
            ram_rd_data_o <= rd_slv_reg060;
        RD_SLV_REG061:
            ram_rd_data_o <= rd_slv_reg061;
        RD_SLV_REG062:
            ram_rd_data_o <= rd_slv_reg062;
        RD_SLV_REG063:
            ram_rd_data_o <= rd_slv_reg063;
        RD_SLV_REG064:
            ram_rd_data_o <= rd_slv_reg064;
        RD_SLV_REG065:
            ram_rd_data_o <= rd_slv_reg065;
        RD_SLV_REG066:
            ram_rd_data_o <= rd_slv_reg066;
        RD_SLV_REG067:
            ram_rd_data_o <= rd_slv_reg067;
        RD_SLV_REG068:
            ram_rd_data_o <= rd_slv_reg068;
        RD_SLV_REG069:
            ram_rd_data_o <= rd_slv_reg069;
        RD_SLV_REG06A:
            ram_rd_data_o <= rd_slv_reg06a;
        RD_SLV_REG06B:
            ram_rd_data_o <= rd_slv_reg06b;
        RD_SLV_REG06C:
            ram_rd_data_o <= rd_slv_reg06c;
        RD_SLV_REG06D:
            ram_rd_data_o <= rd_slv_reg06d;
        RD_SLV_REG06E:
            ram_rd_data_o <= rd_slv_reg06e;
        RD_SLV_REG06F:
            ram_rd_data_o <= rd_slv_reg06f;
        RD_SLV_REG070:
            ram_rd_data_o <= rd_slv_reg070;
        RD_SLV_REG071:
            ram_rd_data_o <= rd_slv_reg071;
        RD_SLV_REG080:
            ram_rd_data_o <= rd_slv_reg080;
        RD_SLV_REG086:
            ram_rd_data_o <= rd_slv_reg086;
        RD_SLV_REG087:
            ram_rd_data_o <= rd_slv_reg087;
        RD_SLV_REG088:
            ram_rd_data_o <= rd_slv_reg088;
        RD_SLV_REG090:
            ram_rd_data_o <= rd_slv_reg090;
        RD_SLV_REG091:
            ram_rd_data_o <= rd_slv_reg091;
        RD_SLV_REG092:
            ram_rd_data_o <= rd_slv_reg092;
        RD_SLV_REG0B1:
            ram_rd_data_o <= rd_slv_reg0b1;
        RD_SLV_REG0B3:
            ram_rd_data_o <= rd_slv_reg0b3;
        RD_SLV_REG0B4:
            ram_rd_data_o <= rd_slv_reg0b4;
        RD_SLV_REG0B5:
            ram_rd_data_o <= rd_slv_reg0b5;
        RD_SLV_REG0B6:
            ram_rd_data_o <= rd_slv_reg0b6;
        RD_SLV_REG0B7:
            ram_rd_data_o <= rd_slv_reg0b7;
        RD_SLV_REG0B8:
            ram_rd_data_o <= rd_slv_reg0b8;
        RD_SLV_REG0B9:
            ram_rd_data_o <= rd_slv_reg0b9;
        RD_SLV_REG0BA:
            ram_rd_data_o <= rd_slv_reg0ba;
        RD_SLV_REG0C0:
            ram_rd_data_o <= rd_slv_reg0c0;
        RD_SLV_REG0C1:
            ram_rd_data_o <= rd_slv_reg0c1;
        RD_SLV_REG0C2:
            ram_rd_data_o <= rd_slv_reg0c2;
        RD_SLV_REG0C3:
            ram_rd_data_o <= rd_slv_reg0c3;
        RD_SLV_REG0C4:
            ram_rd_data_o <= rd_slv_reg0c4;
        RD_SLV_REG0C5:
            ram_rd_data_o <= rd_slv_reg0c5;
        RD_SLV_REG0C6:
            ram_rd_data_o <= rd_slv_reg0c6;
        RD_SLV_REG0C7:
            ram_rd_data_o <= rd_slv_reg0c7;
        RD_SLV_REG0C8:
            ram_rd_data_o <= rd_slv_reg0c8;
        RD_SLV_REG0C9:
            ram_rd_data_o <= rd_slv_reg0c9;
        RD_SLV_REG0CA:
            ram_rd_data_o <= rd_slv_reg0ca;
        RD_SLV_REG0CB:
            ram_rd_data_o <= rd_slv_reg0cb;
        RD_SLV_REG0CC:
            ram_rd_data_o <= rd_slv_reg0cc;
        RD_SLV_REG0CD:
            ram_rd_data_o <= rd_slv_reg0cd;
        RD_SLV_REG0CE:
            ram_rd_data_o <= rd_slv_reg0ce;
        RD_SLV_REG0CF:
            ram_rd_data_o <= rd_slv_reg0cf;
        RD_SLV_REG0D0:
            ram_rd_data_o <= rd_slv_reg0d0;
        RD_SLV_REG0D1:
            ram_rd_data_o <= rd_slv_reg0d1;
        RD_SLV_REG0D2:
            ram_rd_data_o <= rd_slv_reg0d2;
        RD_SLV_REG0D3:
            ram_rd_data_o <= rd_slv_reg0d3;
        RD_SLV_REG0D4:
            ram_rd_data_o <= rd_slv_reg0d4;
        RD_SLV_REG0D5:
            ram_rd_data_o <= rd_slv_reg0d5;
        RD_SLV_REG0D6:
            ram_rd_data_o <= rd_slv_reg0d6;
        RD_SLV_REG0D7:
            ram_rd_data_o <= rd_slv_reg0d7;
        RD_SLV_REG0D8:
            ram_rd_data_o <= rd_slv_reg0d8;
        RD_SLV_REG0D9:
            ram_rd_data_o <= rd_slv_reg0d9;
        RD_SLV_REG0DA:
            ram_rd_data_o <= rd_slv_reg0da;
        RD_SLV_REG0DB:
            ram_rd_data_o <= rd_slv_reg0db;
        RD_SLV_REG0DC:
            ram_rd_data_o <= rd_slv_reg0dc;
        RD_SLV_REG0DD:
            ram_rd_data_o <= rd_slv_reg0dd;
        RD_SLV_REG0DE:
            ram_rd_data_o <= rd_slv_reg0de;
        RD_SLV_REG0DF:
            ram_rd_data_o <= rd_slv_reg0df;
        RD_SLV_REG0F1:
            ram_rd_data_o <= rd_slv_reg0f1;
        RD_SLV_REG0F2:
            ram_rd_data_o <= rd_slv_reg0f2;
        RD_SLV_REG0F3:
            ram_rd_data_o <= rd_slv_reg0f3;
        RD_SLV_REG0F4:
            ram_rd_data_o <= rd_slv_reg0f4;
        RD_SLV_REG0F5:
            ram_rd_data_o <= rd_slv_reg0f5;
        RD_SLV_REG0F6:
            ram_rd_data_o <= rd_slv_reg0f6;
        RD_SLV_REG0F7:
            ram_rd_data_o <= rd_slv_reg0f7;
        RD_SLV_REG0F8:
            ram_rd_data_o <= rd_slv_reg0f8;
        RD_SLV_REG0F9:
            ram_rd_data_o <= rd_slv_reg0f9;
        RD_SLV_REG0FA:
            ram_rd_data_o <= rd_slv_reg0fa;
        RD_SLV_REG0FB:
            ram_rd_data_o <= rd_slv_reg0fb;
        RD_SLV_REG0FC:
            ram_rd_data_o <= rd_slv_reg0fc;
        RD_SLV_REG0FD:
            ram_rd_data_o <= rd_slv_reg0fd;
        RD_SLV_REG0FE:
            ram_rd_data_o <= rd_slv_reg0fe;
        RD_SLV_REG0FF:
            ram_rd_data_o <= rd_slv_reg0ff;
        RD_SLV_REG301:
            ram_rd_data_o <= rd_slv_reg301;
        RD_SLV_REG302:
            ram_rd_data_o <= rd_slv_reg302;
        RD_SLV_REG303:
            ram_rd_data_o <= rd_slv_reg303;
        RD_SLV_REG304:
            ram_rd_data_o <= rd_slv_reg304;
        RD_SLV_REG305:
            ram_rd_data_o <= rd_slv_reg305;
        RD_SLV_REG306:
            ram_rd_data_o <= rd_slv_reg306;
        RD_SLV_REG307:
            ram_rd_data_o <= rd_slv_reg307;
        RD_SLV_REG308:
            ram_rd_data_o <= rd_slv_reg308;
        RD_SLV_REG309:
            ram_rd_data_o <= rd_slv_reg309;
        RD_SLV_REG30A:
            ram_rd_data_o <= rd_slv_reg30a;
        RD_SLV_REG30B:
            ram_rd_data_o <= rd_slv_reg30b;
        RD_SLV_REG30C:
            ram_rd_data_o <= rd_slv_reg30c;
        RD_SLV_REG30E:
            ram_rd_data_o <= rd_slv_reg30e;
        RD_SLV_REG30F:
            ram_rd_data_o <= rd_slv_reg30f;
        RD_SLV_REG311:
            ram_rd_data_o <= rd_slv_reg311;
        RD_SLV_REG312:
            ram_rd_data_o <= rd_slv_reg312;
        RD_SLV_REG313:
            ram_rd_data_o <= rd_slv_reg313;
        RD_SLV_REG314:
            ram_rd_data_o <= rd_slv_reg314;
        RD_SLV_REG3B1:
            ram_rd_data_o <= rd_slv_reg3b1;
        RD_SLV_REG3B2:
            ram_rd_data_o <= rd_slv_reg3b2;
        RD_SLV_REG3B3:
            ram_rd_data_o <= rd_slv_reg3b3;
        RD_SLV_REG3B4:
            ram_rd_data_o <= rd_slv_reg3b4;
        RD_SLV_REG3B5:
            ram_rd_data_o <= rd_slv_reg3b5;
        RD_SLV_REG3B6:
            ram_rd_data_o <= rd_slv_reg3b6;
        RD_SLV_REG3B7:
            ram_rd_data_o <= rd_slv_reg3b7;
        RD_SLV_REG3B8:
            ram_rd_data_o <= rd_slv_reg3b8;
        RD_SLV_REG3B9:
            ram_rd_data_o <= rd_slv_reg3b9;
        RD_SLV_REG3BA:
            ram_rd_data_o <= rd_slv_reg3ba;
        RD_SLV_REG3BB:
            ram_rd_data_o <= rd_slv_reg3bb;
        RD_SLV_REG3BC:
            ram_rd_data_o <= rd_slv_reg3bc;
        RD_SLV_REG3C1:
            ram_rd_data_o <= rd_slv_reg3c1;
        RD_SLV_REG3C2:
            ram_rd_data_o <= rd_slv_reg3c2;
        RD_SLV_REG3C3:
            ram_rd_data_o <= rd_slv_reg3c3;
        RD_SLV_REG3C4:
            ram_rd_data_o <= rd_slv_reg3c4;
        RD_SLV_REG3C5:
            ram_rd_data_o <= rd_slv_reg3c5;
        RD_SLV_REG3C6:
            ram_rd_data_o <= rd_slv_reg3c6;
        RD_SLV_REG3C7:
            ram_rd_data_o <= rd_slv_reg3c7;
        RD_SLV_REG3C8:
            ram_rd_data_o <= rd_slv_reg3c8;
        RD_SLV_REG3D1:
            ram_rd_data_o <= rd_slv_reg3d1;
        RD_SLV_REG3D2:
            ram_rd_data_o <= rd_slv_reg3d2;
        RD_SLV_REG3D3:
            ram_rd_data_o <= rd_slv_reg3d3;
        RD_SLV_REG3D4:
            ram_rd_data_o <= rd_slv_reg3d4;
        RD_SLV_REG3D5:
            ram_rd_data_o <= rd_slv_reg3d5;
        RD_SLV_REG3D6:
            ram_rd_data_o <= rd_slv_reg3d6;
        RD_SLV_REG3D7:
            ram_rd_data_o <= rd_slv_reg3d7;
        RD_SLV_REG3D8:
            ram_rd_data_o <= rd_slv_reg3d8;
        RD_SLV_REG3E1:
            ram_rd_data_o <= rd_slv_reg3e1;
        RD_SLV_REG3E2:
            ram_rd_data_o <= rd_slv_reg3e2;
        RD_SLV_REG3E3:
            ram_rd_data_o <= rd_slv_reg3e3;
        RD_SLV_REG3E4:
            ram_rd_data_o <= rd_slv_reg3e4;
        RD_SLV_REG3E5:
            ram_rd_data_o <= rd_slv_reg3e5;
        RD_SLV_REG3E6:
            ram_rd_data_o <= rd_slv_reg3e6;
        RD_SLV_REG3E7:
            ram_rd_data_o <= rd_slv_reg3e7;
        RD_SLV_REG3E8:
            ram_rd_data_o <= rd_slv_reg3e8;
        RD_SLV_REG3FF:
            ram_rd_data_o <= rd_slv_reg3ff;
        default:
            ram_rd_data_o <= 'h5555_AAAA;
    endcase
end


endmodule
