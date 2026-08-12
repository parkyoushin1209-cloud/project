`include "uvm_macros.svh"
import uvm_pkg::*;

class field_4bit_t extends uvm_reg_field;
`uvm_object_utils(field_4bit_t)

function new(string name = "field_4bit_t");
super.new(name);
endfunction : new

endclass : field_4bit_t 

class field_8bit_t extends uvm_reg_field;
`uvm_object_utils(field_8bit_t)

function new(string name = "field_8bit_t");
super.new(name);
endfunction : new

endclass : field_8bit_t 


//레지스터===========================================================

class gpio_data_reg_t extends uvm_reg;
`uvm_object_utils(gpio_data_reg_t)

rand field_8bit_t DATA_F;

function new(string name = "gpio_data_reg");
super.new(name, 32, UVM_NO_COVERAGE);
endfunction : new

virtual function void build();
DATA_F = field_8bit_t::type_id::create("DATA_F");
DATA_F.configure(this, 8, 0, "RW", 0, 'h00, 1, 1, 0);
endfunction : build

endclass : gpio_data_reg_t


class gpio_dir_reg_t extends uvm_reg;
`uvm_object_utils(gpio_dir_reg_t)

rand field_8bit_t DIR_F;

function new(string name = "gpio_dir_reg_t");
super.new(name, 32, UVM_NO_COVERAGE);
endfunction : new

virtual function void build();
DIR_F = field_8bit_t::type_id::create("DIR_F");
DIR_F.configure(this, 8, 0, "RW", 0, 'h00, 1, 1, 0);
endfunction : build

endclass : gpio_dir_reg_t


class gpio_is_reg_t extends uvm_reg;
`uvm_object_utils(gpio_is_reg_t)

rand field_8bit_t IS_F;

function new(string name = "gpio_is_reg_t");
super.new(name, 32, UVM_NO_COVERAGE);
endfunction : new

virtual function void build();
IS_F = field_8bit_t::type_id::create("IS_F");
IS_F.configure(this, 8, 0, "RW", 0, 'h00, 1, 1, 0);
endfunction : build

endclass : gpio_is_reg_t


class gpio_ibe_reg_t extends uvm_reg;
`uvm_object_utils(gpio_ibe_reg_t)

rand field_8bit_t IBE_F;

function new(string name = "gpio_ibe_reg_t");
super.new(name, 32, UVM_NO_COVERAGE);
endfunction : new

virtual function void build();
IBE_F = field_8bit_t::type_id::create("IBE_F");
IBE_F.configure(this, 8, 0, "RW", 0, 'h00, 1, 1, 0);
endfunction : build

endclass : gpio_ibe_reg_t


class gpio_iev_reg_t extends uvm_reg;
`uvm_object_utils(gpio_iev_reg_t)

rand field_8bit_t IEV_F;

function new(string name = "gpio_iev_reg_t");
super.new(name, 32, UVM_NO_COVERAGE);
endfunction : new

virtual function void build();
IEV_F = field_8bit_t::type_id::create("IEV_F");
IEV_F.configure(this, 8, 0, "RW", 0, 'h00, 1, 1, 0);
endfunction : build

endclass : gpio_iev_reg_t


class gpio_ie_reg_t extends uvm_reg;
`uvm_object_utils(gpio_ie_reg_t)

rand field_8bit_t IE_F;

function new(string name = "gpio_ie_reg_t");
super.new(name, 32, UVM_NO_COVERAGE);
endfunction : new

virtual function void build();
IE_F = field_8bit_t::type_id::create("IE_F");
IE_F.configure(this, 8, 0, "RW", 0, 'h00, 1, 1, 0);
endfunction : build

endclass : gpio_ie_reg_t


class gpio_ris_reg_t extends uvm_reg;
`uvm_object_utils(gpio_ris_reg_t)

rand field_8bit_t RIS_F;

function new(string name = "gpio_ris_reg_t");
super.new(name, 32, UVM_NO_COVERAGE);
endfunction : new

virtual function void build();
RIS_F = field_8bit_t::type_id::create("RIS_F");
RIS_F.configure(this, 8, 0, "RO", 0, 'h00, 1, 1, 0);
endfunction : build

endclass : gpio_ris_reg_t


class gpio_mis_reg_t extends uvm_reg;
`uvm_object_utils(gpio_mis_reg_t)

rand field_8bit_t MIS_F;

function new(string name = "gpio_mis_reg_t");
super.new(name, 32, UVM_NO_COVERAGE);
endfunction : new

virtual function void build();
MIS_F = field_8bit_t::type_id::create("MIS_F");
MIS_F.configure(this, 8, 0, "RO", 0, 'h00, 1, 1, 0);
endfunction : build

endclass : gpio_mis_reg_t


class gpio_ic_reg_t extends uvm_reg;
`uvm_object_utils(gpio_ic_reg_t)

rand field_8bit_t IC_F;

function new(string name = "gpio_ic_reg_t");
super.new(name, 32, UVM_NO_COVERAGE);
endfunction : new

virtual function void build();
IC_F = field_8bit_t::type_id::create("IC_F");
  IC_F.configure(this, 8, 0, "WO", 0, 'h00, 1, 1, 0);
endfunction : build

endclass : gpio_ic_reg_t


class gpio_af_sel_reg_t extends uvm_reg;
`uvm_object_utils(gpio_af_sel_reg_t)

rand field_8bit_t AFSEL_F;

function new(string name = "gpio_af_sel_reg_t");
super.new(name, 32, UVM_NO_COVERAGE);
endfunction : new

virtual function void build();
AFSEL_F = field_8bit_t::type_id::create("AFSEL_F");
AFSEL_F.configure(this, 8, 0, "RW", 0, 'h00, 1, 1, 0);
endfunction : build

endclass : gpio_af_sel_reg_t

class gpio_periph_id0_reg_t extends uvm_reg;
`uvm_object_utils(gpio_periph_id0_reg_t)

rand field_8bit_t PARTNUMBER0;

function new(string name = "gpio_periph_id0_reg_t");
super.new(name, 32,UVM_NO_COVERAGE);
endfunction : new

virtual function void build();
PARTNUMBER0 = field_8bit_t::type_id::create("PARTNUMBER0");
PARTNUMBER0.configure(this, 8, 0, "RO", 0, 'h61, 1, 1, 0);
endfunction : build

endclass : gpio_periph_id0_reg_t


class gpio_periph_id1_reg_t extends uvm_reg;
`uvm_object_utils(gpio_periph_id1_reg_t)

rand field_4bit_t PARTNUMBER1;
rand field_4bit_t PERIPH_ID1_F;

function new(string name = "gpio_periph_id1_reg_t");
super.new(name, 32, UVM_NO_COVERAGE);
endfunction : new

virtual function void build();
PARTNUMBER1 = field_4bit_t::type_id::create("PARTNUMBER1");
PARTNUMBER1.configure(this, 4, 0, "RO", 0, 'h0, 1, 1, 0);
PERIPH_ID1_F = field_4bit_t::type_id::create("PERIPH_ID1_F");
PERIPH_ID1_F.configure(this, 4, 4, "RO", 0, 'h1, 1, 1, 0);
endfunction : build

endclass : gpio_periph_id1_reg_t


class gpio_periph_id2_reg_t extends uvm_reg;
`uvm_object_utils(gpio_periph_id2_reg_t)

rand field_4bit_t DESIGNER1;
rand field_4bit_t REVISION;

function new(string name = "gpio_periph_id2_reg_t");
super.new(name, 32, UVM_NO_COVERAGE);
endfunction : new

virtual function void build();
DESIGNER1 = field_4bit_t::type_id::create("DESIGNER1");
DESIGNER1.configure(this, 4, 0, "RO", 0, 'h4, 1, 1, 0);
REVISION = field_4bit_t::type_id::create("REVISION");
REVISION.configure(this, 4, 4, "RO", 0, 'h0, 1, 1, 0);
endfunction : build

endclass : gpio_periph_id2_reg_t

class gpio_periph_id3_reg_t extends uvm_reg;
`uvm_object_utils(gpio_periph_id3_reg_t)

rand field_8bit_t CONFIGURE;

function new(string name = "gpio_periph_id3_reg_t");
super.new(name, 32, UVM_NO_COVERAGE);
endfunction : new

virtual function void build();
CONFIGURE = field_8bit_t::type_id::create("CONFIGURE");
CONFIGURE.configure(this, 8, 0, "RO", 0, 'h00, 1, 1, 0);
endfunction : build

endclass : gpio_periph_id3_reg_t


class gpio_pcell_id0_reg_t extends uvm_reg;
`uvm_object_utils(gpio_pcell_id0_reg_t)

rand field_8bit_t GPIOPCELLID0;

function new(string name = "gpio_pcell_id0_reg_t");
super.new(name, 32, UVM_NO_COVERAGE);
endfunction : new

virtual function void build();
GPIOPCELLID0 = field_8bit_t::type_id::create("GPIOPCELLID0");
GPIOPCELLID0.configure(this, 8, 0, "RO", 0, 'h0D, 1, 1, 0);
endfunction : build

endclass : gpio_pcell_id0_reg_t


class gpio_pcell_id1_reg_t extends uvm_reg;
`uvm_object_utils(gpio_pcell_id1_reg_t)

rand field_8bit_t GPIOPCELLID1;

function new(string name = "gpio_pcell_id1_reg_t");
super.new(name, 32, UVM_NO_COVERAGE);
endfunction : new

virtual function void build();
GPIOPCELLID1 = field_8bit_t::type_id::create("GPIOPCELLID1");
GPIOPCELLID1.configure(this, 8, 0, "RO", 0, 'h0F, 1, 1, 0);
endfunction : build

endclass : gpio_pcell_id1_reg_t


class gpio_pcell_id2_reg_t extends uvm_reg;
`uvm_object_utils(gpio_pcell_id2_reg_t)

rand field_8bit_t GPIOPCELLID2;

function new(string name = "gpio_pcell_id2_reg_t");
super.new(name, 32, UVM_NO_COVERAGE);
endfunction : new

virtual function void build();
GPIOPCELLID2 = field_8bit_t::type_id::create("GPIOPCELLID2");
GPIOPCELLID2.configure(this, 8, 0, "RO", 0, 'h05, 1, 1, 0);
endfunction : build

endclass : gpio_pcell_id2_reg_t


class gpio_pcell_id3_reg_t extends uvm_reg;
`uvm_object_utils(gpio_pcell_id3_reg_t)

rand field_8bit_t GPIOPCELLID3;

function new(string name = "gpio_pcell_id3_reg_t");
super.new(name, 32, UVM_NO_COVERAGE);
endfunction : new

virtual function void build();
GPIOPCELLID3 = field_8bit_t::type_id::create("GPIOPCELLID3");
GPIOPCELLID3.configure(this, 8, 0, "RO", 0, 'hB1, 1, 1, 0);
endfunction : build

endclass : gpio_pcell_id3_reg_t

class gpio_reg_block_t extends uvm_reg_block;
`uvm_object_utils(gpio_reg_block_t)
rand gpio_data_reg_t GPIODATA;
rand gpio_dir_reg_t GPIODIR;
rand gpio_is_reg_t GPIOIS;
rand gpio_ibe_reg_t GPIOIBE;
rand gpio_iev_reg_t GPIOIEV;
rand gpio_ie_reg_t GPIOIE;
rand gpio_ris_reg_t GPIORIS;
rand gpio_mis_reg_t GPIOMIS;
rand gpio_ic_reg_t GPIOIC;
rand gpio_af_sel_reg_t GPIOAFSEL;
rand gpio_periph_id0_reg_t GPIOPERIPHID0;
rand gpio_periph_id1_reg_t GPIOPERIPHID1;
rand gpio_periph_id2_reg_t GPIOPERIPHID2;
rand gpio_periph_id3_reg_t GPIOPERIPHID3;
rand gpio_pcell_id0_reg_t GPIOPCELLID0;
rand gpio_pcell_id1_reg_t GPIOPCELLID1;
rand gpio_pcell_id2_reg_t GPIOPCELLID2;
rand gpio_pcell_id3_reg_t GPIOPCELLID3;

  protected logic[11:0] addr;

covergroup gpio_addr_cg;
cp_addr : coverpoint addr{
    bins DATA      = {['h000 : 'h3FF]};
    bins DIR       = {['h400 : 'h403]};
    bins IS        = {['h404 : 'h407]};
    bins IBE       = {['h408 : 'h40B]};
    bins IEV       = {['h40C : 'h40F]};
    bins IE        = {['h410 : 'h413]};
    bins RIS       = {['h414 : 'h417]};
    bins MIS       = {['h418 : 'h41B]};
    bins IC        = {['h41C : 'h41F]};
    bins AF_SEL    = {['h420 : 'h423]};
    ignore_bins RESERVED1 = {['h424 : 'hFCF]};
    ignore_bins RESERVED2 = {['hFD0 : 'hFDF]};
    bins PERIPHID  = {['hFE0 : 'hFEF]};
    bins PCELLID   = {['hFF0 : 'hFFF]};
    bins NOT_COVER = default;
}
endgroup : gpio_addr_cg

function new(string name = "gpio_reg_block_t");
super.new(name, UVM_CVR_ADDR_MAP);
if(has_coverage(UVM_CVR_ADDR_MAP)) gpio_addr_cg = new(); 
endfunction : new

  virtual function void sample(uvm_reg_data_t offset, bit is_read, uvm_reg_map map);
if(get_coverage(UVM_CVR_ADDR_MAP)) begin
  super.sample(offset, is_read, map);
    gpio_addr_cg.sample();
end
endfunction : sample

virtual function void build();
default_map = create_map("default_map", 'h1000, 4, UVM_LITTLE_ENDIAN);

GPIODATA = gpio_data_reg_t::type_id::create("GPIODATA");
GPIODATA.configure(this, null, "GPIODATA");
GPIODATA.build();
default_map.add_reg(GPIODATA, 'h000, "RW");

GPIODIR = gpio_dir_reg_t::type_id::create("GPIODIR");
GPIODIR.configure(this, null, "GPIODIR");
GPIODIR.build();
default_map.add_reg(GPIODIR, 'h400, "RW");

GPIOIS = gpio_is_reg_t::type_id::create("GPIOIS");
GPIOIS.configure(this, null, "GPIOIS");
GPIOIS.build();
default_map.add_reg(GPIOIS, 'h404, "RW");

GPIOIBE = gpio_ibe_reg_t::type_id::create("GPIOBE");
GPIOIBE.configure(this, null, "GPIOIBE");
GPIOIBE.build();
default_map.add_reg(GPIOIBE,'h408, "RW");

GPIOIEV = gpio_iev_reg_t::type_id::create("GPIOIEV");
GPIOIEV.configure(this, null, "GPIOIEV");
GPIOIEV.build();
default_map.add_reg(GPIOIEV, 'h40C, "RW");

GPIOIE = gpio_ie_reg_t::type_id::create("GPIOIE");
GPIOIE.configure(this, null, "GPIOIE");
GPIOIE.build();
default_map.add_reg(GPIOIE, 'h410, "RW");

GPIORIS = gpio_ris_reg_t::type_id::create("GPIORIS");
GPIORIS.configure(this, null, "GPIORIS");
GPIORIS.build();
default_map.add_reg(GPIORIS, 'h414, "RO");

GPIOMIS = gpio_mis_reg_t::type_id::create("GPIOMIS");
GPIOMIS.configure(this, null, "GPIOMIS");
GPIOMIS.build();
default_map.add_reg(GPIOMIS, 'h418, "RO");

GPIOIC = gpio_ic_reg_t::type_id::create("GPIOIC");
GPIOIC.configure(this, null, "GPIOIC");
GPIOIC.build();
  default_map.add_reg(GPIOIC, 'h41C, "WO");

GPIOAFSEL = gpio_af_sel_reg_t::type_id::create("GPIOAFSEL");
GPIOAFSEL.configure(this, null, "GGPIOAFSEL");
GPIOAFSEL.build();
default_map.add_reg(GPIOAFSEL, 'h420, "RW");

GPIOPERIPHID0 = gpio_periph_id0_reg_t::type_id::create("GPIOPERIPHID0");
GPIOPERIPHID0.configure(this, null, "GPIOPERIPHID0");
GPIOPERIPHID0.build();
default_map.add_reg(GPIOPERIPHID0, 'hFE0, "RO");

GPIOPERIPHID1 = gpio_periph_id1_reg_t::type_id::create("GPIOPERIPHID1");
GPIOPERIPHID1.configure(this, null, "GPIOPERIPHID1");
GPIOPERIPHID1.build();
default_map.add_reg(GPIOPERIPHID1, 'hFE4, "RO");

GPIOPERIPHID2 = gpio_periph_id2_reg_t::type_id::create("GPIOPERIPHID2");
GPIOPERIPHID2.configure(this, null, "GPIOPERIPHID2");
GPIOPERIPHID2.build();
default_map.add_reg(GPIOPERIPHID2, 'hFE8, "RO");

GPIOPERIPHID3 = gpio_periph_id3_reg_t::type_id::create("GPIOPERIPHID3");
GPIOPERIPHID3.configure(this, null, "GPIOPERIPHID3");
GPIOPERIPHID3.build();
default_map.add_reg(GPIOPERIPHID3, 'hFEC, "RO");

GPIOPCELLID0 = gpio_pcell_id0_reg_t::type_id::create("GPIOPCELLID0");
GPIOPCELLID0.configure(this, null, "GPIOPCELLID0");
GPIOPCELLID0.build();
default_map.add_reg(GPIOPCELLID0,  'hFF0, "RO");

GPIOPCELLID1 = gpio_pcell_id1_reg_t::type_id::create("GPIOPCELLID1");
GPIOPCELLID1.configure(this, null, "GPIOPCELLID1");
GPIOPCELLID1.build();
default_map.add_reg(GPIOPCELLID1,  'hFF4, "RO");

GPIOPCELLID2 = gpio_pcell_id2_reg_t::type_id::create("GPIOPCELLID2");
GPIOPCELLID2.configure(this, null, "GPIOPCELLID2");
GPIOPCELLID2.build();
default_map.add_reg(GPIOPCELLID2,  'hFF8, "RO");

GPIOPCELLID3 = gpio_pcell_id3_reg_t::type_id::create("GPIOPCELLID3");
GPIOPCELLID3.configure(this, null, "GPIOPCELLID3");
GPIOPCELLID3.build();
default_map.add_reg(GPIOPCELLID3,  'hFFC, "RO");
endfunction : build

endclass : gpio_reg_block_t

