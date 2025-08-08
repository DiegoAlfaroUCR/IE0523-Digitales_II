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
[size] 1908 987
[pos] -1 -1
*-4.260482 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1
[treeopen] testbench.
[sst_width] 239
[signals_width] 209
[sst_expanded] 1
[sst_vpaned_height] 288
@200
-Señales genéricas
@28
testbench.C0.Clk
testbench.C0.Reset
@22
testbench.C0.EstPres[6:0]
testbench.C0.ProxEstado[6:0]
@200
-
-Entradas Estáticas
@28
testbench.C0.TARJETA_RECIBIDA
@22
testbench.C0.PIN[15:0]
@24
testbench.C0.BALANCE_INICIAL[63:0]
@28
testbench.C0.TIPO_TRANS
@200
-
-Entradas dinámicas
@22
testbench.C0.DIGITO[3:0]
@28
testbench.C0.DIGITO_STB
@24
testbench.C0.MONTO[31:0]
@28
testbench.C0.MONTO_STB
@200
-
-Registros internos
@24
testbench.C0.BALANCE[63:0]
testbench.C0.INTENTOS[1:0]
@200
-
-Digitos y contadores
@22
testbench.C0.DIGITOS_IN[15:0]
@24
testbench.C0.numDIGITOS[2:0]
testbench.C0.next_numDIGITOS[2:0]
@200
-
-Salidas
@28
testbench.C0.BALANCE_ACTUALIZADO
testbench.C0.ENTREGAR_DINERO
testbench.C0.PIN_INCORRECTO
testbench.C0.ADVERTENCIA
testbench.C0.BLOQUEO
testbench.C0.FONDOS_INSUFICIENTES
[pattern_trace] 1
[pattern_trace] 0
endef

# Esto evita que se haga conflictos si tiene archivos llamados clean o tarea.
.PHONY: test CMOS RTLIL

# Regla para limpiar los archivos generados.
clean:
	$(cleanCommand) salida resultados.vcd ondas.gtkw CajeroSynth.v

# Regla para crear y simular el modulo con CMOS.
simular:
	yosys -p "read_liberty -lib ./lib/cmos_cells.lib; read_verilog Cajero.v; \
	synth; opt; fsm; opt -full; \
	dfflibmap -liberty ./lib/cmos_cells.lib; abc -liberty ./lib/cmos_cells.lib; \
	share; opt -full; clean; write_verilog CajeroSynth.v;"
	$(file >ondas.gtkw,$(configuracionGTKW))
	iverilog -o salida testbench.v
	vvp salida
	gtkwave resultados.vcd ondas.gtkw


# Regla para crear, simular y mostrar el modulo con CMOS.
full:
# Se agrega read_liberty -lib para leer las librerías y que se vea bien el diagrama.
# share es para que nodos compartidos se junten.
# synth corre la mayoría de los comandos de sintesis.
	yosys -p "read_liberty -lib ./lib/cmos_cells.lib; read_verilog Cajero.v; \
	synth; opt; fsm; opt -full; \
	dfflibmap -liberty ./lib/cmos_cells.lib; abc -liberty ./lib/cmos_cells.lib; \
	share; opt -full; clean; show; write_verilog CajeroSynth.v;"
	$(file >ondas.gtkw,$(configuracionGTKW))
	iverilog -o salida testbench.v
	vvp salida
	gtkwave resultados.vcd ondas.gtkw
