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
[pos] 32898 32905
*-5.956394 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1
[treeopen] testbench.
[sst_width] 42
[signals_width] 246
[sst_expanded] 0
[sst_vpaned_height] 214
@200
-Señales CPU/Registros Chip
@28
testbench.T1.Clk
testbench.T1.Reset
testbench.T1.START_STB
testbench.T1.RNW
testbench.T1.I2C_ADDR_Gen[6:0]
testbench.T1.I2C_ADDR_Rec[6:0]
testbench.T1.WR_DATA_Gen[15:0]
testbench.T1.RD_DATA_Rec[15:0]
@200
-
-Comunicación Serial
@28
testbench.G1.SCL
testbench.G1.SDA_OE
testbench.G1.SDA_OUT
testbench.G1.SDA_IN
@200
-
-Registros Generador
@22
testbench.G1.EstPres[6:0]
@24
testbench.G1.cont_BYTES[4:0]
@28
testbench.G1.RD_DATA[15:0]
@200
-
-Registros Receptor
@22
testbench.R1.EstPres[6:0]
@24
testbench.R1.cont_BYTES[4:0]
@28
testbench.R1.WR_DATA[15:0]
[pattern_trace] 1
[pattern_trace] 0
endef

# Esto evita que se haga conflictos si tiene archivos llamados clean o tarea.
.PHONY: tarea clean

# Regla para limpiar los archivos generados.
clean:
	$(cleanCommand) salida resultados.vcd ondas.gtkw

# Regla para crear y simular el módulo.
tarea:
	$(file >ondas.gtkw,$(configuracionGTKW))
	iverilog -o salida testbench.v
	vvp salida
	gtkwave resultados.vcd ondas.gtkw
