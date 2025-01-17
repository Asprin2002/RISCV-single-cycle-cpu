#include <common.h>
#include <cstdio>
#include <defs.h>



void difftest_skip_ref();

extern "C" void dpi_ebreak(int pc){
	SIMTRAP(pc, 0);
}

extern "C" int dpi_mem_read(int addr, int len){
	if(addr == 0) return 0;
	if(addr >=  CONFIG_RTC_MMIO && addr < CONFIG_RTC_MMIO + 4){
		int time = get_time();
		IFDEF(CONFIG_DIFFTEST, difftest_skip_ref());
		return time;
	}else{
		unsigned int data = pmem_read(addr, len);
		return data;
	}
}
extern "C" void dpi_mem_write(int addr, int data, int len){
	if(addr == CONFIG_SERIAL_MMIO){
		char ch = data;
		printf("%c", ch);
		fflush(stdout);
		IFDEF(CONFIG_DIFFTEST, difftest_skip_ref());
	}else{
		pmem_write(addr, len, data);
	}
}


