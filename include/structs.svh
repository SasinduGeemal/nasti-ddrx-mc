/**
 * This file defines structures that encapsulate transactions within the
 * memory controller.
 */

`include "defines.svh"

typedef struct packed {
    logic [  `C_NASTI_ID_WIDTH-1:0] ar_id   ;
    logic [`C_NASTI_ADDR_WIDTH-1:0] ar_addr ;
    logic [                    7:0] ar_len  ;
    logic [                    2:0] ar_size ;
    logic [                    1:0] ar_burst;
    logic [`C_NASTI_USER_WIDTH-1:0] ar_user ;
} ar_trans;

typedef struct packed {
    logic [  `C_NASTI_ID_WIDTH-1:0] aw_id   ;
    logic [`C_NASTI_ADDR_WIDTH-1:0] aw_addr ;
    logic [                    7:0] aw_len  ;
    logic [                    2:0] aw_size ;
    logic [                    1:0] aw_burst;
    logic [`C_NASTI_USER_WIDTH-1:0] aw_user ;
} aw_trans;

typedef struct packed {
    logic [  `C_NASTI_DATA_WIDTH-1:0] w_data;
    logic [`C_NASTI_DATA_WIDTH/8-1:0] w_strb;
    logic                             w_last;
    logic [  `C_NASTI_USER_WIDTH-1:0] w_user;
} w_trans;

typedef struct packed {
    logic [  `C_NASTI_ID_WIDTH-1:0] r_id  ;
    logic [`C_NASTI_DATA_WIDTH-1:0] r_data;
    logic                          r_last;
    logic [                   1:0] r_resp;
    logic [`C_NASTI_USER_WIDTH-1:0] r_user;
} r_trans;

typedef struct packed {
    logic [  `C_NASTI_ID_WIDTH-1:0] b_id  ;
    logic [                    1:0] b_resp;
    logic [`C_NASTI_USER_WIDTH-1:0] b_user;
} b_trans;

typedef struct packed {
    logic [                  4:0] id       ;
    logic                         rw       ;
    logic [`C_DFI_BANK_WIDTH-1:0] bank     ;
    logic [                 15:0] row      ;
    logic [                 11:0] col      ;
    logic                         burst_len;
} sdram_trans;
