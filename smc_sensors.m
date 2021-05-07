#import <Foundation/Foundation.h>
#import <IOKit/IOKitLib.h>

#include <arpa/inet.h>

struct sensorTemperature4CC {
  unsigned int sensor4CC[15];
};

struct sensorTemperatureData {
  float sensorTemperature[15];
};

kern_return_t SMCSensorDispatcherOpen(io_connect_t* conn) {
  kern_return_t result;
  mach_port_t masterPort;
  io_service_t service;

  result = IOMasterPort(MACH_PORT_NULL, &masterPort);

  CFMutableDictionaryRef matchingDictionary = IOServiceMatching("AppleSMCSensorDispatcher");
  NSLog(@"matched %@", matchingDictionary);
  service = IOServiceGetMatchingService(masterPort, matchingDictionary);
  NSLog(@"matched %d", service);

  result = IOServiceOpen(service, mach_task_self(), 0, conn);
  if (result != kIOReturnSuccess) {
    printf("Error: IOServiceOpen() = 0x%08x\n", result);
    printf("Error: IOServiceOpen() = 0x%08x\n", kIOReturnUnsupported);
    return 1;
  }

  return kIOReturnSuccess;
}

int main(int argc, char* argv[]) {
  io_connect_t connection;
  SMCSensorDispatcherOpen(&connection);

  uint64_t sensors;
  uint32_t sensorCount = 1;

  kern_return_t kret = IOConnectCallScalarMethod(connection, 0, NULL, 0, &sensors, &sensorCount);
  if (kret) {
    NSLog(@"failed to get sensor count, ret = 0x%08x", kret);
    exit(-1);
  }

  NSLog(@"sensor = 0x%llx", sensors);
  NSLog(@"sensor_count = %u", sensorCount);

  struct sensorTemperature4CC sensors4CCKeys;
  size_t sensors4CCCount = 0x3c;
  kret = IOConnectCallStructMethod(connection, 1, NULL, 0, &sensors4CCKeys, &sensors4CCCount);
  NSLog(@"sensor_count = %zu", sensors4CCCount);

  for (int i = 0; i < sensors; i++) {
    unsigned int foo = htonl(sensors4CCKeys.sensor4CC[i]);
    char* fourCC = (char*)&foo;
    fourCC[4] = '\0';
    NSLog(@"sensor 4CC[%2d] = %s", i, fourCC);
  }

  struct sensorTemperatureData sensorsData;
  kret = IOConnectCallStructMethod(connection, 2, NULL, 0, &sensorsData, &sensors4CCCount);
  // NSLog(@"sensor_count = %zu", sensors4CCCount);
  // NSLog(@"kret = 0x%08x", kret);
  for (int i = 0; i < 12; i++) {
    NSLog(@"sensor data [%2d] = %6.2f", i, sensorsData.sensorTemperature[i]);
  }
}
