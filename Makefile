
# Top level makefile for building Marlin

LIBS=-Ibuild-libs/LiquidCrystal_I2C/LiquidCrystal_I2C \
		-Ibuild-libs/LiquidTWI2 \
		-Ibuild-libs/U8glib \
		-IArduinoAddons/Arduino_1.x.x/libraries/TMC26XStepper\
		-IArduinoAddons/Arduino_1.x.x/libraries/L6470

all: firmware.hex

firmware.hex: build-libs build-arduino
	-ln -s Marlin src
	rm -f Marlin/Marlin.pde
	ino build --verbose --arduino-dist=build-arduino -m atmega1284m --cppflags="-ffunction-sections -fdata-sections -g -Os -w $(LIBS)"
	cp .build/atmega*/firmware.* .

#
# Set up build library dependencies
#
build-libs:
	mkdir build-libs
	cd build-libs && \
	git clone https://github.com/kiyoshigawa/LiquidCrystal_I2C.git && \
	git clone https://github.com/lincomatic/LiquidTWI2.git && \
	ln -s ../ArduinoAddons/Arduino_1.5.x/hardware/marlin/avr/libraries/U8glib

#
# Make our own copy of the arduino distribution, 
# to fix a number of crazy broken/dependency problems\
# (admittedly brute force)
#
build-arduino:
	cp -r /usr/share/arduino $@
	cp ArduinoAddons/Arduino_1.0.x/hardware/Sanguino/boards.txt \
		$@/hardware/arduino/boards.txt
	-rm -rf $@/libraries/Robot_Control

clean:
	ino clean
	-rm firmware.hex firmware.elf

deep-clean: clean
	-rm -rf build-libs build-arduino