CC=clang
CFLAGS=-Wall -O2 -g

FRAMEWORKS=-framework Foundation -framework IOKit

TARGETS=smc_sensors

all: ${TARGETS}

smc_sensors: smc_sensors.o
	${CC} -o $@ $< ${FRAMEWORKS} ${LIBS}
	codesign --entitlements entitlement.xml -s "Apple Development" $@

clean:
	rm -rf ${TARGETS} *.o
