`ifndef _TEST_VH_
`define _TEST_VH_

`timescale 1ps / 1ps

`define DUMP_ALL(file) \
    initial begin \
        $dumpfile(file); \
        $dumpvars; \
    end

`define SET_LIMIT(domain, cnt) \
    initial begin \
        wait ((domain.CNT) >= (cnt)); \
        forever begin \
            $display("[LIMIT EXCEEDED] in %m: limit = %d", (cnt)); \
            $finish; \
        end \
    end

`define WAIT_FOR(domain, cnt) \
    repeat (cnt) \
        @(domain.eCLK);

`define WAIT_UNTIL(domain, cond) \
    while (!(cond)) \
        @(domain.eCLK);

`define ASSERT_COND(cond, desc) \
    if (!(cond)) begin \
        $display("[ASSERTION FAILED] in %m: %s", (desc)); \
        $finish; \
    end

`define ASSERT_EQUAL(val0, val1) \
    if ((val0) !== (val1)) begin \
        $display( "[ASSERTION FAILED] in %m: `0x%h` is not equal to `0x%h`" \
                , (val0) \
                , (val1) \
                ); \
        $finish; \
    end

`endif
