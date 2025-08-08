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
*-5.043881 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1
[treeopen] testbench.
[sst_width] 239
[signals_width] 180
[sst_expanded] 1
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
.PHONY: clean tarea tareaSinConfig

# Regla para compilar y simular la tarea.
tarea:
	$(file >ondas.gtkw,$(configuracionGTKW))
	iverilog -o salida testbench.v
	vvp salida
	gtkwave resultados.vcd ondas.gtkw

# Regla para compilar y simular la tarea sin las configuraciones de gtkwave.
tareaSinConfig:
	iverilog -o salida testbench.v
	vvp salida
	gtkwave resultados.vcd

# Regla para limpiar los archivos generados.
clean:
	$(cleanCommand) salida resultados.vcd ondas.gtkw