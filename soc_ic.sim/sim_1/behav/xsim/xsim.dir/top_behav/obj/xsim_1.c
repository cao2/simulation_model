/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                         */
/*  \   \        Copyright (c) 2003-2013 Xilinx, Inc.                 */
/*  /   /        All Right Reserved.                                  */
/* /---/   /\                                                         */
/* \   \  /  \                                                        */
/*  \___\/\___\                                                       */
/**********************************************************************/


#include "iki.h"
#include <string.h>
#include <math.h>
#ifdef __GNUC__
#include <stdlib.h>
#else
#include <malloc.h>
#define alloca _alloca
#endif
/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                         */
/*  \   \        Copyright (c) 2003-2013 Xilinx, Inc.                 */
/*  /   /        All Right Reserved.                                  */
/* /---/   /\                                                         */
/* \   \  /  \                                                        */
/*  \___\/\___\                                                       */
/**********************************************************************/


#include "iki.h"
#include <string.h>
#include <math.h>
#ifdef __GNUC__
#include <stdlib.h>
#else
#include <malloc.h>
#define alloca _alloca
#endif
typedef void (*funcp)(char *, char *);
extern int main(int, char**);
extern void execute_76(char*, char *);
extern void execute_478(char*, char *);
extern void execute_479(char*, char *);
extern void execute_849(char*, char *);
extern void execute_850(char*, char *);
extern void execute_851(char*, char *);
extern void execute_852(char*, char *);
extern void execute_853(char*, char *);
extern void execute_80(char*, char *);
extern void execute_81(char*, char *);
extern void execute_93(char*, char *);
extern void execute_105(char*, char *);
extern void execute_117(char*, char *);
extern void execute_129(char*, char *);
extern void execute_141(char*, char *);
extern void execute_153(char*, char *);
extern void execute_165(char*, char *);
extern void execute_177(char*, char *);
extern void execute_189(char*, char *);
extern void execute_201(char*, char *);
extern void execute_213(char*, char *);
extern void execute_225(char*, char *);
extern void execute_237(char*, char *);
extern void execute_249(char*, char *);
extern void execute_261(char*, char *);
extern void execute_273(char*, char *);
extern void execute_285(char*, char *);
extern void execute_297(char*, char *);
extern void execute_309(char*, char *);
extern void execute_321(char*, char *);
extern void execute_333(char*, char *);
extern void execute_345(char*, char *);
extern void execute_357(char*, char *);
extern void execute_369(char*, char *);
extern void execute_381(char*, char *);
extern void execute_393(char*, char *);
extern void execute_405(char*, char *);
extern void execute_417(char*, char *);
extern void execute_429(char*, char *);
extern void execute_441(char*, char *);
extern void execute_453(char*, char *);
extern void execute_465(char*, char *);
extern void execute_477(char*, char *);
extern void execute_83(char*, char *);
extern void execute_84(char*, char *);
extern void execute_85(char*, char *);
extern void execute_86(char*, char *);
extern void execute_87(char*, char *);
extern void execute_88(char*, char *);
extern void execute_89(char*, char *);
extern void execute_90(char*, char *);
extern void execute_91(char*, char *);
extern void execute_92(char*, char *);
extern void execute_95(char*, char *);
extern void execute_96(char*, char *);
extern void execute_97(char*, char *);
extern void execute_98(char*, char *);
extern void execute_99(char*, char *);
extern void execute_100(char*, char *);
extern void execute_101(char*, char *);
extern void execute_102(char*, char *);
extern void execute_103(char*, char *);
extern void execute_104(char*, char *);
extern void execute_481(char*, char *);
extern void execute_509(char*, char *);
extern void execute_513(char*, char *);
extern void execute_514(char*, char *);
extern void execute_516(char*, char *);
extern void execute_517(char*, char *);
extern void execute_551(char*, char *);
extern void execute_601(char*, char *);
extern void execute_602(char*, char *);
extern void execute_603(char*, char *);
extern void execute_604(char*, char *);
extern void execute_605(char*, char *);
extern void execute_558(char*, char *);
extern void execute_573(char*, char *);
extern void execute_574(char*, char *);
extern void execute_575(char*, char *);
extern void execute_576(char*, char *);
extern void execute_577(char*, char *);
extern void execute_578(char*, char *);
extern void execute_579(char*, char *);
extern void execute_580(char*, char *);
extern void execute_581(char*, char *);
extern void execute_557(char*, char *);
extern void execute_560(char*, char *);
extern void execute_562(char*, char *);
extern void execute_564(char*, char *);
extern void execute_566(char*, char *);
extern void execute_568(char*, char *);
extern void execute_570(char*, char *);
extern void execute_586(char*, char *);
extern void execute_589(char*, char *);
extern void execute_590(char*, char *);
extern void execute_591(char*, char *);
extern void execute_585(char*, char *);
extern void execute_593(char*, char *);
extern void execute_596(char*, char *);
extern void execute_597(char*, char *);
extern void execute_598(char*, char *);
extern void execute_600(char*, char *);
extern void execute_663(char*, char *);
extern void execute_664(char*, char *);
extern void execute_662(char*, char *);
extern void execute_714(char*, char *);
extern void execute_717(char*, char *);
extern void execute_756(char*, char *);
extern void execute_757(char*, char *);
extern void execute_764(char*, char *);
extern void execute_667(char*, char *);
extern void execute_679(char*, char *);
extern void execute_681(char*, char *);
extern void execute_683(char*, char *);
extern void execute_699(char*, char *);
extern void execute_713(char*, char *);
extern void execute_719(char*, char *);
extern void execute_723(char*, char *);
extern void execute_733(char*, char *);
extern void execute_737(char*, char *);
extern void execute_747(char*, char *);
extern void execute_759(char*, char *);
extern void execute_766(char*, char *);
extern void execute_770(char*, char *);
extern void execute_776(char*, char *);
extern void execute_777(char*, char *);
extern void execute_778(char*, char *);
extern void execute_779(char*, char *);
extern void execute_780(char*, char *);
extern void execute_781(char*, char *);
extern void execute_782(char*, char *);
extern void execute_837(char*, char *);
extern void execute_838(char*, char *);
extern void execute_839(char*, char *);
extern void execute_840(char*, char *);
extern void execute_841(char*, char *);
extern void execute_842(char*, char *);
extern void execute_836(char*, char *);
extern void execute_802(char*, char *);
extern void execute_803(char*, char *);
extern void execute_804(char*, char *);
extern void execute_805(char*, char *);
extern void execute_807(char*, char *);
extern void execute_808(char*, char *);
extern void execute_809(char*, char *);
extern void execute_811(char*, char *);
extern void execute_812(char*, char *);
extern void execute_813(char*, char *);
extern void execute_814(char*, char *);
extern void execute_815(char*, char *);
extern void execute_816(char*, char *);
extern void execute_817(char*, char *);
extern void execute_818(char*, char *);
extern void execute_819(char*, char *);
extern void execute_820(char*, char *);
extern void execute_833(char*, char *);
extern void execute_834(char*, char *);
extern void execute_835(char*, char *);
extern void execute_847(char*, char *);
extern void execute_848(char*, char *);
extern void execute_846(char*, char *);
extern void vhdl_transfunc_eventcallback(char*, char*, unsigned, unsigned, unsigned, char *);
extern void transaction_31(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_33(char*, char*, unsigned, unsigned, unsigned);
funcp funcTab[164] = {(funcp)execute_76, (funcp)execute_478, (funcp)execute_479, (funcp)execute_849, (funcp)execute_850, (funcp)execute_851, (funcp)execute_852, (funcp)execute_853, (funcp)execute_80, (funcp)execute_81, (funcp)execute_93, (funcp)execute_105, (funcp)execute_117, (funcp)execute_129, (funcp)execute_141, (funcp)execute_153, (funcp)execute_165, (funcp)execute_177, (funcp)execute_189, (funcp)execute_201, (funcp)execute_213, (funcp)execute_225, (funcp)execute_237, (funcp)execute_249, (funcp)execute_261, (funcp)execute_273, (funcp)execute_285, (funcp)execute_297, (funcp)execute_309, (funcp)execute_321, (funcp)execute_333, (funcp)execute_345, (funcp)execute_357, (funcp)execute_369, (funcp)execute_381, (funcp)execute_393, (funcp)execute_405, (funcp)execute_417, (funcp)execute_429, (funcp)execute_441, (funcp)execute_453, (funcp)execute_465, (funcp)execute_477, (funcp)execute_83, (funcp)execute_84, (funcp)execute_85, (funcp)execute_86, (funcp)execute_87, (funcp)execute_88, (funcp)execute_89, (funcp)execute_90, (funcp)execute_91, (funcp)execute_92, (funcp)execute_95, (funcp)execute_96, (funcp)execute_97, (funcp)execute_98, (funcp)execute_99, (funcp)execute_100, (funcp)execute_101, (funcp)execute_102, (funcp)execute_103, (funcp)execute_104, (funcp)execute_481, (funcp)execute_509, (funcp)execute_513, (funcp)execute_514, (funcp)execute_516, (funcp)execute_517, (funcp)execute_551, (funcp)execute_601, (funcp)execute_602, (funcp)execute_603, (funcp)execute_604, (funcp)execute_605, (funcp)execute_558, (funcp)execute_573, (funcp)execute_574, (funcp)execute_575, (funcp)execute_576, (funcp)execute_577, (funcp)execute_578, (funcp)execute_579, (funcp)execute_580, (funcp)execute_581, (funcp)execute_557, (funcp)execute_560, (funcp)execute_562, (funcp)execute_564, (funcp)execute_566, (funcp)execute_568, (funcp)execute_570, (funcp)execute_586, (funcp)execute_589, (funcp)execute_590, (funcp)execute_591, (funcp)execute_585, (funcp)execute_593, (funcp)execute_596, (funcp)execute_597, (funcp)execute_598, (funcp)execute_600, (funcp)execute_663, (funcp)execute_664, (funcp)execute_662, (funcp)execute_714, (funcp)execute_717, (funcp)execute_756, (funcp)execute_757, (funcp)execute_764, (funcp)execute_667, (funcp)execute_679, (funcp)execute_681, (funcp)execute_683, (funcp)execute_699, (funcp)execute_713, (funcp)execute_719, (funcp)execute_723, (funcp)execute_733, (funcp)execute_737, (funcp)execute_747, (funcp)execute_759, (funcp)execute_766, (funcp)execute_770, (funcp)execute_776, (funcp)execute_777, (funcp)execute_778, (funcp)execute_779, (funcp)execute_780, (funcp)execute_781, (funcp)execute_782, (funcp)execute_837, (funcp)execute_838, (funcp)execute_839, (funcp)execute_840, (funcp)execute_841, (funcp)execute_842, (funcp)execute_836, (funcp)execute_802, (funcp)execute_803, (funcp)execute_804, (funcp)execute_805, (funcp)execute_807, (funcp)execute_808, (funcp)execute_809, (funcp)execute_811, (funcp)execute_812, (funcp)execute_813, (funcp)execute_814, (funcp)execute_815, (funcp)execute_816, (funcp)execute_817, (funcp)execute_818, (funcp)execute_819, (funcp)execute_820, (funcp)execute_833, (funcp)execute_834, (funcp)execute_835, (funcp)execute_847, (funcp)execute_848, (funcp)execute_846, (funcp)vhdl_transfunc_eventcallback, (funcp)transaction_31, (funcp)transaction_33};
const int NumRelocateId= 164;

void relocate(char *dp)
{
	iki_relocate(dp, "xsim.dir/top_behav/xsim.reloc",  (void **)funcTab, 164);
	iki_vhdl_file_variable_register(dp + 1258544);
	iki_vhdl_file_variable_register(dp + 1258600);
	iki_vhdl_file_variable_register(dp + 1290608);
	iki_vhdl_file_variable_register(dp + 1290736);
	iki_vhdl_file_variable_register(dp + 1290880);


	/*Populate the transaction function pointer field in the whole net structure */
}

void sensitize(char *dp)
{
	iki_sensitize(dp, "xsim.dir/top_behav/xsim.reloc");
}

void simulate(char *dp)
{
	iki_schedule_processes_at_time_zero(dp, "xsim.dir/top_behav/xsim.reloc");
	// Initialize Verilog nets in mixed simulation, for the cases when the value at time 0 should be propagated from the mixed language Vhdl net
	iki_execute_processes();

	// Schedule resolution functions for the multiply driven Verilog nets that have strength
	// Schedule transaction functions for the singly driven Verilog nets that have strength

}
#include "iki_bridge.h"
void relocate(char *);

void sensitize(char *);

void simulate(char *);

int main(int argc, char **argv)
{
    iki_heap_initialize("ms", "isimmm", 0, 2147483648) ;
    iki_set_sv_type_file_path_name("xsim.dir/top_behav/xsim.svtype");
    iki_set_crvs_dump_file_path_name("xsim.dir/top_behav/xsim.crvsdump");
    void* design_handle = iki_create_design("xsim.dir/top_behav/xsim.mem", (void *)relocate, (void *)sensitize, (void *)simulate, 0, isimBridge_getWdbWriter(), 0, argc, argv);
     iki_set_rc_trial_count(100);
    (void) design_handle;
    return iki_simulate_design();
}
