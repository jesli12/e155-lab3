if {[catch {

# define run engine funtion
source [file join {C:/lscc/radiant/2026.1} scripts tcl flow run_engine.tcl]
# define global variables
global para
set para(gui_mode) "1"
set para(prj_dir) "C:/Users/jesli/Documents/GitHub/e155-lab3/AI_proto/ai_prototype"
if {![file exists {C:/Users/jesli/Documents/GitHub/e155-lab3/AI_proto/ai_prototype/impl_1}]} {
  file mkdir {C:/Users/jesli/Documents/GitHub/e155-lab3/AI_proto/ai_prototype/impl_1}
}
cd {C:/Users/jesli/Documents/GitHub/e155-lab3/AI_proto/ai_prototype/impl_1}
# synthesize IPs
# synthesize VMs
# propgate constraints
file delete -force -- ai_prototype_impl_1_cpe.ldc
::radiant::runengine::run_engine_newmsg cpe -syn lse -f "ai_prototype_impl_1.cprj" -a "iCE40UP"  -o ai_prototype_impl_1_cpe.ldc
# synthesize top design
file delete -force -- ai_prototype_impl_1.vm ai_prototype_impl_1.ldc
::radiant::runengine::run_engine_newmsg synthesis -f "C:/Users/jesli/Documents/GitHub/e155-lab3/AI_proto/ai_prototype/impl_1/ai_prototype_impl_1_lattice.synproj" -logfile "ai_prototype_impl_1_lattice.srp"
::radiant::runengine::run_postsyn [list -a iCE40UP -p iCE40UP5K -t SG48 -sp High-Performance_1.2V -oc Industrial -top -w -o ai_prototype_impl_1_syn.udb ai_prototype_impl_1.vm] [list ai_prototype_impl_1.ldc]

} out]} {
   ::radiant::runengine::runtime_log $out
   exit 1
}
