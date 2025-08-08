# Se determina el OS y se asignan el comando de borrado acordemente.
ifeq ($(OS), Windows_NT)
	cleanCommand = del
else
	cleanCommand = rm -f
endif

# Este define es para recrear la configuración usada en gtkwave con las ondas ya puestas
# se copia el contenido del archivo de configuración en configuracionGTKW y se escribe al archivo.
define configuracionGTKW
[timestart] 0
[size] 1920 991
[pos] -1 -1
*-14.879094 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1
[treeopen] testbench.
[sst_width] 42
[signals_width] 180
[sst_expanded] 0
[sst_vpaned_height] 283
@22
testbench.C0.EstPres[6:0]
testbench.C0.ProxEstado[6:0]
@28
testbench.C0.Clk
testbench.C0.Reset
@22
testbench.C0.Clave[15:0]
@28
testbench.C0.Enter
testbench.C0.Entrada
testbench.C0.Salida
testbench.C0.Abrir
testbench.C0.Cerrar
@29
testbench.C0.AlrmInt
testbench.C0.AlrmCom
[pattern_trace] 1
[pattern_trace] 0
endef

# Esto evita que se haga conflictos si tiene archivos llamados clean o tarea.
.PHONY: clean RTLIL CMOS CMOSretardos

# Regla para limpiar los archivos generados.
clean:
	$(cleanCommand) salida resultados.vcd ondas.gtkw ControladorSynth.v

# Regla para crear y simular el modulo con RTLIL.
RTLIL:
	yosys -p "read_verilog Controlador.v; \
	synth; opt; fsm; share; opt -full; \
	show; clean; write_verilog ControladorSynth.v;"
	$(file >ondas.gtkw,$(configuracionGTKW))
	iverilog -o salida testbench.v
	vvp salida
	gtkwave resultados.vcd ondas.gtkw

# Regla para crear y simular el modulo con CMOS.
CMOS:
# Se agrega read_liberty -lib para leer las librerías y que se vea bien el diagrama.
# share es para que nodos compartidos se junten.
# synth corre la mayoría de los comandos de sintesis.
	yosys -p "read_liberty -lib ./lib/cmos_cells.lib; read_verilog Controlador.v; \
	synth; opt; fsm; opt -full; \
	dfflibmap -liberty ./lib/cmos_cells.lib; abc -liberty ./lib/cmos_cells.lib; \
	share; opt -full; clean; show; write_verilog ControladorSynth.v;"
	$(file >ondas.gtkw,$(configuracionGTKW))
	iverilog -o salida testbench.v
	vvp salida
	gtkwave resultados.vcd ondas.gtkw

# Regla para crear y simular el modulo con CMOS y con retardos.
CMOSretardos:
	yosys -p "read_liberty -lib ./lib/cmos_cells_retardos.lib; read_verilog Controlador.v; \
	synth; opt; fsm; opt -full; \
	dfflibmap -liberty ./lib/cmos_cells_retardos.lib; abc -liberty ./lib/cmos_cells_retardos.lib; \
	share; opt -full; clean; show; write_verilog ControladorSynth.v;"
	$(file >ondas.gtkw,$(configuracionGTKW))
	iverilog -o salida testbench.v
	vvp salida
	gtkwave resultados.vcd ondas.gtkw