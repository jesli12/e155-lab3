if {[catch {

# define run engine funtion
source [file join {C:/lscc/radiant/2026.1} scripts tcl flow run_engine.tcl]
# define global variables
global para
set para(gui_mode) "1"
set para(prj_dir) "C:/Users/jesli/Documents/GitHub/e155-lab3/AI_proto/ai_proto2"
if {![file exists {C:/Users/jesli/Documents/GitHub/e155-lab3/AI_proto/ai_proto2/implementation}]} {
  file mkdir {C:/Users/jesli/Documents/GitHub/e155-lab3/AI_proto/ai_proto2/implementation}
}
cd {C:/Users/jesli/Documents/GitHub/e155-lab3/AI_proto/ai_proto2/implementation}
# synthesize IPs
# synthesize VMs
# synthesize top design
file delete -force -- ai_proto2_implementation.vm ai_proto2_implementation.ldc
::radiant::runengine::run_engine_newmsg synthesis -f "C:/Users/jesli/Documents/GitHub/e155-lab3/AI_proto/ai_proto2/implementation/ai_proto2_implementation_lattice.synproj" -logfile "ai_proto2_implementation_lattice.srp"
::radiant::runengine::run_postsyn [list -a iCE40UP -p iCE40UP5K -t SG48 -sp High-Performance_1.2V -oc Industrial -top -w -o ai_proto2_implementation_syn.udb ai_proto2_implementation.vm] [list ai_proto2_implementation.ldc]

} out]} {
   ::radiant::runengine::runtime_log $out
   exit 1
}
