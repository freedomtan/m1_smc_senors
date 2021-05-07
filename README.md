# m1_smc_senors
Retrieve some SMC temperature sensors names (in 4CC) and values.

Use AppleSMC.ext's `AppleSMCSensorDispatcher` service to retrieve temperature sensors name. and values.
Tested on M1 machines. Need to have
1. System Integrity Protection (SIP) disabled `csrutil disable`, and
2. Apple Mobile File Integrity (AMFI) diabled, `nvram boot-args="amfi_get_out_of_my_way=0x1"`
